//
//This class is used as a controller for 'H_C_Admin' page
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (16-05-2013)
public with sharing class H_C_AdminController
{
    //
    //Constructors
    //
    public H_C_AdminController()
    {
        //fill 2 public maps
        this.mapOfJobsIds = new Map<Integer, String>();
        this.mapOfJobsMessages = new Map<Integer, String>();
        for (Integer jobCode : H_C_ApexJobUtils.ALL_JOBS)
        {
            this.mapOfJobsIds.put(jobCode, '');
            this.mapOfJobsMessages.put(jobCode, JOB_NOT_STARTED_MESSAGE);
        }

        //fill status message for scheduled job
        this.accountTeamsScheduledJobStatus = NO_INFO_FOR_SCHEDULED_JOB_MESSAGE;
    }
    //

    //
    //Constants
    //
    private static final String JOB_NOT_STARTED_MESSAGE = 'Job is not started yet';

    private static final String NO_INFO_FOR_SCHEDULED_JOB_MESSAGE = 'No information about scheduled job';
    private static final String SCHEDULED_JOB_STARTED_MESSAGE = 'Scheduled job has been started successfully';
    //

    //
    //Properties
    //
    public Map<Integer, String> mapOfJobsIds {get; private set;}
    public Map<Integer, String> mapOfJobsMessages {get; private set;}

    //these properties return the codes of jobs
    //they are used to avoid of hardcoded codes on a page side
    public Integer codeOfAccountHierarchyManager
    {
        get
        {
            return H_C_ApexJobUtils.JOB_UPDATE_ACCOUNT_HIERARCHY;
        }
    }

    public Integer codeOfATRU_Manager
    {
        get
        {
            return H_C_ApexJobUtils.JOB_ROLL_UP_ACCOUNT_TEAMS;
        }
    }
    
    public Integer codeOfATRD_Manager
    {
        get
        {
            return H_C_ApexJobUtils.JOB_ROLL_DOWN_ACCOUNT_TEAMS;
        }
    }

    public Integer codeOfAccountRelatedListsManager
    {
        get
        {
            return H_C_ApexJobUtils.JOB_ROLLUP_ACCOUNT_RELATED_LISTS;
        }
    }
    
    public Integer codeOfComputeAccountChildrenCountManager
    {
        get
        {
            return H_C_ApexJobUtils.JOB_COMPUTE_ACCOUNT_CHILDREN_COUNT;
        }
    }
    //

    public String accountTeamsScheduledJobStatus {get; private set;}
    //

    //
    //Private methods
    //
    private static Database.Batchable<sObject> createJob(Integer jobCode)
    {
        Database.Batchable<sObject> jobManager = null;
        if (jobCode == H_C_ApexJobUtils.JOB_UPDATE_ACCOUNT_HIERARCHY)
        {
            //this job should work with all accounts which can be child accounts
            String queryString = H_C_AccountDAO.createQueryByRecordTypeNames(new String[] {
                H_C_AccountRecordType.KEY_REGION_ACCOUNT,
                H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT});
                
            //Old Implementation
             jobManager = new H_C_BgAccountHierarchiesManager(queryString);
            
            
            //New Implementation    
            /*    
            H_C_BgAccountHierarchiesManager extendedJobManager = new H_C_BgAccountHierarchiesManager(queryString);
            
            //Run Compute children job after Update Account Hierarchy
            extendedJobManager.nextApexJob = new H_C_ApexJobUtils.PreStartInfo(createJob(
            	H_C_ApexJobUtils.JOB_COMPUTE_ACCOUNT_CHILDREN_COUNT), 
            	H_C_ApexJobUtils.JOB_COMPUTE_ACCOUNT_CHILDREN_COUNT);
            	
            jobManager = extendedJobManager;
            */
        }
        else if (jobCode == H_C_ApexJobUtils.JOB_ROLL_UP_ACCOUNT_TEAMS)
        {
            //1) initialize correct options for ATRU managers
            H_C_ATRU_Manager.Options managerOptions = new H_C_ATRU_Manager.Options();
            //we can guarantee this, because each query selects accounts of one type only
            //(key or contract)
            managerOptions.allAccountsHaveParentalRights = true;
            //we can guarantee this, because each query selects accounts of one type only
            managerOptions.allAccountsOfSameType = true;
            //we don't want that entire hierarchy will be updated automatically. We want that the
            //jobs will update all key accounts at first, and then all contract accounts
            managerOptions.processEntireHierarchy = false;
            
            //2) prepare 2 job managers
            String queryForKeyAccounts = H_C_AccountDAO.createQueryByRecordTypeNames(
                new String[] {H_C_AccountRecordType.KEY_REGION_ACCOUNT});
            H_C_ATRU_BgManager keyLevelManager =
                new H_C_ATRU_BgManager(queryForKeyAccounts, managerOptions);
            
            String queryForContractAccounts = H_C_AccountDAO.createQueryByRecordTypeNames(
                new String[] {H_C_AccountRecordType.CONTRACT_ACCOUNT});
            H_C_ATRU_BgManager contractLevelManager =
                new H_C_ATRU_BgManager(queryForContractAccounts, managerOptions);
            
            //3) order of jobs is important. All key accounts should be processed before
            //contract accounts
            keyLevelManager.nextApexJob = new H_C_ApexJobUtils.PreStartInfo(
                contractLevelManager, jobCode);

            //the 1st job from the chain of jobs should be returned
            jobManager = keyLevelManager;
        }
        else if (jobCode == H_C_ApexJobUtils.JOB_ROLL_DOWN_ACCOUNT_TEAMS)
        {
            //1) initialize correct options for ATRU managers
            H_C_ATRD_Manager.Options managerOptions = new H_C_ATRD_Manager.Options();
            //we can guarantee this, because each query selects accounts of one type only
            //(key or transactional)
            managerOptions.allAccountsOfSameType = true;
            //we don't want that entire hierarchy will be updated automatically. We want that 2 different
            //jobs will update children for all contract accounts (they are key accounts) at first,
            //and then update children for all key accounts (they are transactional accounts)
            managerOptions.processEntireHierarchy = false;
            
            //2) prepare 2 job managers
            H_C_AccountDAO.Filter accountsFilter = new H_C_AccountDAO.Filter();
            //it doesn't make sence to start roll-down process for accounts without parents
            accountsFilter.ignoreAccountsWithoutParent = true;
            
            //2.1) create the job to process key accounts
            accountsFilter.accountRecordTypes = new String[] {H_C_AccountRecordType.KEY_REGION_ACCOUNT};
            H_C_ATRD_BgManager keyLevelManager = new H_C_ATRD_BgManager(
                H_C_AccountDAO.createQueryByFilter(accountsFilter), managerOptions);
            
            //2.2) create the job to process transactional accounts
            accountsFilter.accountRecordTypes = new String[] {H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT};
            H_C_ATRD_BgManager transactionalLevelManager = new H_C_ATRD_BgManager(
                H_C_AccountDAO.createQueryByFilter(accountsFilter), managerOptions);
            
            //3) order of jobs is important. All key accounts should be processed before
            //transactional accounts
            keyLevelManager.nextApexJob = new H_C_ApexJobUtils.PreStartInfo(
                transactionalLevelManager, jobCode);

            //the 1st job from the chain of jobs should be returned
            jobManager = keyLevelManager;
        }
        else if (jobCode == H_C_ApexJobUtils.JOB_ROLLUP_ACCOUNT_RELATED_LISTS)
        {
            //this job should manage objects only for 3 types of accounts. All other accounts
            //are not used in an external hierarchy of accounts
            String queryString = H_C_AccountDAO.createQueryByRecordTypeNames(new String[] {
                H_C_AccountRecordType.CONTRACT_ACCOUNT,
                H_C_AccountRecordType.KEY_REGION_ACCOUNT,
                H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT});
            jobManager = new H_C_BgAccountDependenciesManager(queryString);
        }
        else if (jobCode == H_C_ApexJobUtils.JOB_COMPUTE_ACCOUNT_CHILDREN_COUNT)
        {
            //this job should work with all accounts
            String queryString = H_C_AccountDAO.createQueryByRecordTypeNames(new String[] {
                H_C_AccountRecordType.CONTRACT_ACCOUNT,
                H_C_AccountRecordType.KEY_REGION_ACCOUNT,
                H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT});
            jobManager = new H_C_BgAccountComputeChildManager(queryString);
        }
        
        return jobManager;
    }

    private void startOrCheckJob(Integer jobCode)
    {
        String jobId = this.mapOfJobsIds.get(jobCode);
        if (String.isBlank(jobId))
        {
            //if the job has not been created yet then we should try to start it
            H_C_ApexJobUtils.StartResults results =
                H_C_ApexJobUtils.startJob(createJob(jobCode), jobCode);
            if (results.isStartSuccessful)
            {
                //save jobId in the map
                this.mapOfJobsIds.put(jobCode, results.jobId);
                //put informational message for this action
                this.mapOfJobsMessages.put(jobCode, H_C_ApexJobUtils.getJobStatusMessage(results.jobId));
            }
            else
            {
                //put error message for this action
                this.mapOfJobsMessages.put(jobCode, results.errorMessage);
            }
        }
        else
        {
            //if the job has been already created then we update status message
            this.mapOfJobsMessages.put(jobCode, H_C_ApexJobUtils.getJobStatusMessage(jobId));
        }
    }
    //

    //
    //Public methods
    //
    public void updateHierarchy()
    {
        this.startOrCheckJob(H_C_ApexJobUtils.JOB_UPDATE_ACCOUNT_HIERARCHY);
    }

    public void rollUpAccountTeams()
    {
        this.startOrCheckJob(H_C_ApexJobUtils.JOB_ROLL_UP_ACCOUNT_TEAMS);
    }
    
    public void rollDownAccountTeams()
    {
        this.startOrCheckJob(H_C_ApexJobUtils.JOB_ROLL_DOWN_ACCOUNT_TEAMS);
    }

    public void rollUpAccountRelatedLists()
    {
        this.startOrCheckJob(H_C_ApexJobUtils.JOB_ROLLUP_ACCOUNT_RELATED_LISTS);
    }
    
    public void computeAccountChildrenCount()
    {
        this.startOrCheckJob(H_C_ApexJobUtils.JOB_COMPUTE_ACCOUNT_CHILDREN_COUNT);
    }

    public void startScheduledAccountsManager()
    {
        H_C_ScheduledJobUtils.StartResults results = H_C_ScheduledJobUtils.startJob(
            H_C_ScheduledJobUtils.JOB_SCHEDULED_ACCOUNTS_MANAGER);
        if (results.isStartSuccessful)
        {
            //fill informational message for this action
            this.accountTeamsScheduledJobStatus = SCHEDULED_JOB_STARTED_MESSAGE;
        }
        else
        {
            //fill error message for this action
            this.accountTeamsScheduledJobStatus = results.errorMessage;
        }
    }
    //





    //
    //Private Unit tests (I wanted to use @TestVisible annotation for private methods and
    //test them in a separate class, but this annotation is still not supported by IDE
    //and breaks Outline window)
    //
    
    @IsTest
    private static void testAdminController_coverPrivateMethods()
    {
        //test unusual cases
        H_C_AdminController controller = new H_C_AdminController();
        controller.startOrCheckJob(null);
    }

    @IsTest
    private static void testAdminController_createJob()
    {
        System.assertNotEquals(null, createJob(H_C_ApexJobUtils.JOB_UPDATE_ACCOUNT_HIERARCHY));
        System.assertNotEquals(null, createJob(H_C_ApexJobUtils.JOB_ROLL_UP_ACCOUNT_TEAMS));
        System.assertNotEquals(null, createJob(H_C_ApexJobUtils.JOB_ROLL_DOWN_ACCOUNT_TEAMS));
        System.assertNotEquals(null, createJob(H_C_ApexJobUtils.JOB_ROLLUP_ACCOUNT_RELATED_LISTS));
        System.assertEquals(null, createJob(null));
    }
    
    //
}