//
//This class implements scheduled process which manages automatic background jobs for accounts
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (18-10-2013)
public class H_C_ScheduledAccountsManager implements Schedulable
{
	//
	//Constants
	//
	private static final Integer NUMBER_OF_CHECKED_HOURS_FOR_TEAMS = -2;
	//
	
	//
	//Private static methods
	//
	//this method creates a job which is able to fix problems in a hierarchy of accounts
	private static H_C_ApexJobUtils.PreStartInfo createAccountHierarchiesManager()
	{
		//STEP #1: we should generate query to get only accounts which have external
		//parent references, but real parents are not specified for them in SF
		String queryString = H_C_AccountDAO.createQueryForAccountsWithoutProperParents(
			new String[] {H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT});
		
		//STEP #2: initialize the job. This step is possible only if queryString is correct
		H_C_ApexJobUtils.PreStartInfo jobPreStartInfo = null;
		if (String.isNotBlank(queryString))
		{
			H_C_BgAccountHierarchiesManager jobManager = new H_C_BgAccountHierarchiesManager(queryString);
			jobPreStartInfo = new H_C_ApexJobUtils.PreStartInfo(jobManager,
				H_C_ApexJobUtils.JOB_UPDATE_ACCOUNT_HIERARCHY);
		}
		return jobPreStartInfo;
	}
	
	//this method creates list of jobs which are necessary to perform the rollup process
	private static H_C_ApexJobUtils.PreStartInfo[] createATRU_Managers()
	{
		//STEP #1: initialize and fill the basic filter by common parameters: we should get
		//ATMs who belong to child accounts and were updated last hours
		H_C_AccountTeamMemberDAO.Filter basicATMsFilter = new H_C_AccountTeamMemberDAO.Filter();
		//this filter is used to get only ATMs whose accounts have parents
		basicATMsFilter.ignoreAccountsWithoutParent = true;
		//this filter is used to get only last changes
		basicATMsFilter.startModifiedDateTime = DateTime.now().addHours(NUMBER_OF_CHECKED_HOURS_FOR_TEAMS);
		//this filter is used to ignore updated ATMs who have roles which are not included
		//in the rollup mechanism
		basicATMsFilter.ignorableTeamRoles = H_C_CustomSettings.getIgnorableTeamRolesDuringRollup();
		//this filter is used to ignore ATMs of inactive users, because new ATMs can't
		//be created for them
		basicATMsFilter.ignoreInactiveUsers = true;
		
		
		//STEP #2: initialize the jobs
		//2.1) initialize correct options for ATRU managers
		H_C_ATRU_Manager.Options managerOptions = new H_C_ATRU_Manager.Options();
		//we can guarantee this because of the 1st step (queries select only key and contract accounts)
		managerOptions.allAccountsHaveParentalRights = true;
		//we can guarantee this, because each query selects accounts of one type only
		managerOptions.allAccountsOfSameType = true;
		//we don't want that entire hierarchy will be updated automatically. We want that 2 different
		//jobs will update parents for all transactional accounts (they are key accounts) at first,
		//and then parents for all key accounts (they are contract accounts)
		managerOptions.processEntireHierarchy = false;
		
		//2.2) create and fill the list of jobs
		List<H_C_ApexJobUtils.PreStartInfo> orderedJobs = new List<H_C_ApexJobUtils.PreStartInfo>();
		
		//2.3) generate job managers for key accounts and then for contract accounts
		String[] orderedRecordTypes = new String[] {H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT,
			H_C_AccountRecordType.KEY_REGION_ACCOUNT};
		for (String recordTypeName : orderedRecordTypes)
		{
			//clone the basic filter
			H_C_AccountTeamMemberDAO.Filter atmsFilter = basicATMsFilter.clone();
			//update the filter to look at a concrete record type of an account
			atmsFilter.accountRecordTypes = new String[] {recordTypeName};
			//update the filter to look at a concrete record type of a parent account
			atmsFilter.parentAccountRecordTypes = new String[] {
				H_C_AccountRecordType.mapOfParentRecordTypes.get(recordTypeName)};
			
			//initialize a query creator
			H_C_SoqlUtils.IQueryCreator queryCreator = new ATRU_QueryCreator(atmsFilter);
			
			//create the job
			H_C_ATRU_BgManager jobManager = new H_C_ATRU_BgManager(queryCreator, managerOptions);
			//create pre-start info for the job and add it into the ordered list
			orderedJobs.add(new H_C_ApexJobUtils.PreStartInfo(jobManager,
				H_C_ApexJobUtils.JOB_ROLL_UP_ACCOUNT_TEAMS));
		}
		
		return orderedJobs;
	}
	
	//this method creates list of jobs which are necessary to perform the roll-down process
	private static H_C_ApexJobUtils.PreStartInfo[] createATRD_Managers()
	{
		//STEP #1: initialize and fill the basic filter by common parameters: we should
		//get ATMs who belong to parent accounts and were updated last hours, then we should
		//find child accounts for these parent accounts
		H_C_AccountTeamMemberDAO.Filter basicATMsFilter = new H_C_AccountTeamMemberDAO.Filter();
		//this filter is used to get only last changes
		basicATMsFilter.startModifiedDateTime = DateTime.now().addHours(NUMBER_OF_CHECKED_HOURS_FOR_TEAMS);
		//this filter is used to ignore ATMs of inactive users, because new ATMs can't
		//be created for them
		basicATMsFilter.ignoreInactiveUsers = true;
		
		//STEP #2: initialize the jobs
		//2.1) initialize correct options for ATRD managers
		H_C_ATRD_Manager.Options managerOptions = new H_C_ATRD_Manager.Options();
		//we can guarantee this, because each query selects accounts of one type only
		managerOptions.allAccountsOfSameType = true;
		//we don't want that entire hierarchy will be updated automatically. We want that 2 different
		//jobs will update children for all contract accounts (they are key accounts) at first,
		//and then update children for all key accounts (they are transactional accounts)
		managerOptions.processEntireHierarchy = false;
		
		//2.2) create and fill the list of jobs
		List<H_C_ApexJobUtils.PreStartInfo> orderedJobs = new List<H_C_ApexJobUtils.PreStartInfo>();
		
		//2.3) generate job managers for key accounts and then for transactional accounts
		String[] orderedRecordTypes = new String[] {H_C_AccountRecordType.CONTRACT_ACCOUNT,
			H_C_AccountRecordType.KEY_REGION_ACCOUNT};
		for (String recordTypeName : orderedRecordTypes)
		{
			//get account record type which will be updated by the roll-down mechanism
			String targetRecordTypeName =
				H_C_AccountRecordType.mapOfChildRecordTypes.get(recordTypeName);
			//get roll-down options for the target account record type
			H_C_ATRD_Options rollDownOptions = H_C_CustomSettings.getATRD_Options(targetRecordTypeName);
			
			//clone the basic filter
			H_C_AccountTeamMemberDAO.Filter atmsFilter = basicATMsFilter.clone();
			//update the filter to look at a concrete record type of an account
			atmsFilter.accountRecordTypes = new String[] {recordTypeName};
			//update the filter to ignore ATMs who have roles which are ignored by the roll-down mechanism
			atmsFilter.ignorableTeamRoles = rollDownOptions.ignorableTeamRoles;
			
			//initialize a query creator
			H_C_SoqlUtils.IQueryCreator queryCreator =
				new ATRD_QueryCreator(atmsFilter, targetRecordTypeName);
			
			//create the job
			H_C_ATRD_BgManager jobManager = new H_C_ATRD_BgManager(queryCreator, managerOptions);
			//create pre-start info for the job and add it into the ordered list
			orderedJobs.add(new H_C_ApexJobUtils.PreStartInfo(jobManager,
				H_C_ApexJobUtils.JOB_ROLL_DOWN_ACCOUNT_TEAMS));
		}
		
		return orderedJobs;
	}
	
	private static H_C_ApexJobUtils.PreStartInfo[] createChainOfJobs()
	{
		//STEP #1: create the ordered list of jobs
		List<H_C_ApexJobUtils.PreStartInfo> orderedJobs = new List<H_C_ApexJobUtils.PreStartInfo>();
		//1.1) at first, we should fix problems in account hierarchies if they exist
		H_C_ApexJobUtils.PreStartInfo hierarchiesManager = createAccountHierarchiesManager();
		if (hierarchiesManager != null)
		{
			orderedJobs.add(hierarchiesManager);
		}
		//1.2) at second, we should perform the rollup process
		orderedJobs.addAll(createATRU_Managers());
		//1.3) at third, we should perform the roll-down process
		orderedJobs.addAll(createATRD_Managers());
		
		//STEP #2: connect jobs into a chain
		for (Integer indexOfJob = 0; indexOfJob < orderedJobs.size() - 1; indexOfJob++)
		{
			//it is supposed that all job managers are instance of H_C_ExtendedApexJob in this class
			H_C_ExtendedApexJob currentJobManager =
				(H_C_ExtendedApexJob)orderedJobs[indexOfJob].jobManager;
			//set a next job for the current job
			currentJobManager.nextApexJob = orderedJobs[indexOfJob + 1];
		}
		
		return orderedJobs;
	}
	//
	
	//
    //Public methods (implementation of 'Schedulable' interface)
    //
	public void execute(SchedulableContext sc)
	{
		H_C_ApexJobUtils.PreStartInfo[] chainOfJobs = createChainOfJobs();
		if (chainOfJobs.size() > 0)
		{
			//try to start the 1st APEX job in the chain of jobs
			H_C_ApexJobUtils.StartResults startResults = H_C_ApexJobUtils.startJob(chainOfJobs[0]);
			
			if (startResults.isStartSuccessful)
			{
				System.debug(LoggingLevel.INFO, 'Scheduled job has started the 1st APEX job '
					+ 'from the chain of jobs. APEX Job Id = ' + startResults.jobId);
			}
			else
			{
				System.debug(LoggingLevel.INFO, 'Scheduled job has NOT started the 1st APEX job '
					+ 'from the chain of jobs. Error Message : ' + startResults.errorMessage);
			}
		}
	}
	//
	
	
	
	//
	//Data types
	//
	public class ATRU_QueryCreator implements H_C_SoqlUtils.IQueryCreator
	{
		//
		//Constructors
		//
		public ATRU_QueryCreator(H_C_AccountTeamMemberDAO.Filter atmsFilter)
		{
			this.atmsFilter = atmsFilter;
		}
		//
		
		//
		//Variables
		//
		private H_C_AccountTeamMemberDAO.Filter atmsFilter;
		//
		
		//
		//Implementation of 'H_C_SoqlUtils.IQueryCreator' interface
		//
		public String createQuery()
		{
			//get parent accounts Ids of accounts of selected ATMs
			String[] parentAccountsIds =
				H_C_AccountTeamMemberDAO.getParentAccountsIdsByFilter(this.atmsFilter);
			//generate a final query for parent accounts
			return H_C_AccountDAO.createQueryByAccountsIds(parentAccountsIds);
		}
		//
	}
	
	public class ATRD_QueryCreator implements H_C_SoqlUtils.IQueryCreator
	{
		//
		//Constructors
		//
		public ATRD_QueryCreator(H_C_AccountTeamMemberDAO.Filter atmsFilter,
			String targetRecordTypeName)
		{
			this.atmsFilter = atmsFilter;
			this.targetRecordTypeName = targetRecordTypeName;
		}
		//
		
		//
		//Variables
		//
		private H_C_AccountTeamMemberDAO.Filter atmsFilter;
		private String targetRecordTypeName;
		//
		
		//
		//Implementation of 'H_C_SoqlUtils.IQueryCreator' interface
		//
		public String createQuery()
		{
			String resultQuery = null;
			
			//get accounts Ids of selected ATMs
			String[] accountsIds = H_C_AccountTeamMemberDAO.getAccountsIdsByFilter(this.atmsFilter);
			//generate a final query to get child accounts of selected parent accounts
			if (accountsIds != null && accountsIds.size() > 0)
			{
				H_C_AccountDAO.Filter accountsFilter = new H_C_AccountDAO.Filter();
				//set the filter by parents Ids
				accountsFilter.parentAccountsIds = accountsIds;
				//set the filter by record type to be sure that correct accounts will be taken
				accountsFilter.accountRecordTypes = new String[] {this.targetRecordTypeName};
				
				//generate the query to get child accounts of selected accounts
				resultQuery = H_C_AccountDAO.createQueryByFilter(accountsFilter);
			}
			return resultQuery;
		}
		//
	}
	//
}