//
//This class manages the roll-down process for account teams.
//Used abbreviations:
// - ATRD means 'Account Team Roll-Down'
// - ATM means 'Account Team Member'
// - RTN means 'Record Type Name'.
//Specific behaviour: the class processes each level of hierarchy in different transactions.
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (14-10-2013)
public without sharing class H_C_ATRD_Manager
{
	//
	//Constructors
	//
	public H_C_ATRD_Manager(Account[] accounts, Options options)
	{
		//check the correctness of the data
		if (accounts == null || options == null)
		{
			throw new H_C_Exception('H_C_ATRD_Manager was initialized by incorrect parameters.\nAccounts = '
				+ accounts + '\nOptions = ' + options);
		}
		
		this.options = options;
		this.sourceAccounts = accounts;
	}
	
	public H_C_ATRD_Manager(String[] accountsIds, Options options)
	{
		//get source accounts by Ids from DB and recall another constructor
		this(H_C_AccountDAO.getAccountsByIds(accountsIds), options);
	}
	//
	
	//
	//Variables
	//
	private Options options;
	private H_C_ATRD_Options currentRollDownOptions;
	private String currentAccountRecordType;
	
	private Account[] sourceAccounts;
	private H_C_AccountHelper sourceAccountsHelper;
	private H_C_AccountTeamMemberHelper sourceAccountsATMsHelper;
	
	private H_C_AccountTeamMemberHelper parentAccountsATMsHelper;
	private H_C_AccountShareHelper parentAccountsSharesHelper;
	
	private List<Account> deferredAccounts = new List<Account>();
	//
	
	//
	//Constants
	//
	//a list of account record types which teams can be updated by the roll-down mechanism
	private static Set<String> POSSIBLE_TARGET_RECORD_TYPES = new Set<String> {
		H_C_AccountRecordType.KEY_REGION_ACCOUNT, H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT};
	//
	
	//
	//Private static methods
	//	
	//this method creates filter to get ATMs and fills it correctly
	private static H_C_AccountTeamMemberDAO.Filter buildFilterForATMs(String[] accountsIds)
	{
		H_C_AccountTeamMemberDAO.Filter filter = null;
		//create a real filter only if a main filtering aspect (accountsIds) can be applied
		if (accountsIds != null && accountsIds.size() > 0)
		{
			filter = new H_C_AccountTeamMemberDAO.Filter();
			//set accountsIds according to the input parameters
			filter.accountsIds = accountsIds;
			//we should ignore ATMs for inactive users, because new ATMs can't be created for them
			filter.ignoreInactiveUsers = true;
			//return created filter
		}
		return filter;
	}
	
	private static H_C_AccountTeamMemberDAO.Filter buildFilterForATMs(
		String[] accountsIds, H_C_ATRD_Options rollDownOptions)
	{
		//1) build a basic filter
		H_C_AccountTeamMemberDAO.Filter filter = buildFilterForATMs(accountsIds);
		//2) try to apply roll-down options
		if (filter != null)
		{
			//we should not work with team members who are ignored by the roll-down process
			filter.ignorableTeamRoles = rollDownOptions.ignorableTeamRoles;
		}
		return filter;
	}
	
	private static H_C_AccountShareDAO.Filter buildFilterForAccountShares(
		AccountTeamMember[] teamMembers)
	{
		H_C_AccountShareDAO.Filter filter = null;
		//create a real filter only if a main filtering aspect (teamMembers) can be applied
		if (teamMembers != null && teamMembers.size() > 0)
		{
			//initialize and fill a filter
			filter = new H_C_AccountShareDAO.Filter();
			filter.teamMembers = teamMembers;
		}
		return filter;
	}
	//
	
	//
	//Private methods
	//
	private void regroupSourceAccounts()
	{
		//if there is a guarantee that all passed accounts have same record type, then
		//we can process all passed accounts without special filtering
		if (this.options.allAccountsOfSameType)
		{
			return;
		}
		
		//if accounts have different record types then we group them:
		//- all key accounts will be processed in the 1st transaction
		//- all transactional accounts will be processed in the 2nd transaction
		//- all other accounts will be ignored by the manager
		
		//initialize a helper for all passed accounts
		H_C_AccountHelper accountsHelper =
			H_C_AccountHelper.createHelperByAccountsList(this.sourceAccounts);
		
		//extract key accounts
		Account[] keyAccounts = accountsHelper.getAccountsByRecordTypeName(
			H_C_AccountRecordType.KEY_REGION_ACCOUNT);
		//extract transactional accounts
		Account[] transactionalAccounts = accountsHelper.getAccountsByRecordTypeName(
			H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT);
		
		if (keyAccounts.size() > 0)
		{
			//set accounts for the current and next transactions
			this.sourceAccounts = keyAccounts;
			this.deferredAccounts = transactionalAccounts;
		}
		else if (transactionalAccounts.size() > 0)
		{
			//set accounts for the current transaction only
			this.sourceAccounts = transactionalAccounts;
		}
		else
		{
			//the manager works with either key or transactional accounts only
			this.sourceAccounts = new Account[0];
		}
	}
	
	private void setServiceData()
	{
		if (this.sourceAccounts.size() > 0)
		{
			//extract record type of the 1st source account
			String recordTypeOfFirstAccount = H_C_AccountRecordType.mapOfIdsAndNames.get(
				this.sourceAccounts[0].RecordTypeId);
			
			//service data can be correctly filled only if type of accounts specified for the
			//current transaction can be processed by the roll-down manager
			if (POSSIBLE_TARGET_RECORD_TYPES.contains(recordTypeOfFirstAccount))
			{
				//set record type name of the 1st source account
				this.currentAccountRecordType = recordTypeOfFirstAccount;
				
				//set options according to the record type of source accounts
				this.currentRollDownOptions = H_C_CustomSettings.getATRD_Options(
					this.currentAccountRecordType);
			}
		}
	}
	
	private void prepareCurrentTransaction()
	{
		this.regroupSourceAccounts();
		this.setServiceData();
	}
	
	private Boolean isCurrentTransactionPossible()
	{
		return (this.sourceAccounts.size() > 0
			&& String.isNotBlank(this.currentAccountRecordType)
			&& this.currentRollDownOptions != null
			&& this.currentRollDownOptions.isProcessEnabled);
	}
	
	//the method creates new ATMs for child accounts of a parent account 
	private H_C_ATR_Results createATMsForChildAccounts(String parentAccountId)
	{
		//STEP #1: extract necessary data
		//1.1) extract child accounts for the current parent account
    	Account[] childAccounts =
    		this.sourceAccountsHelper.getAccountsByParentId(parentAccountId);
    	
    	//1.2) extract ATMs for the current parent account
    	AccountTeamMember[] parentAccountATMs =
    		this.parentAccountsATMsHelper.getATMsByAccountId(parentAccountId);
    	
    	//initialize creator of ATMs
    	H_C_ATRD_ATMsCreator creator = new H_C_ATRD_ATMsCreator(parentAccountATMs,
    		this.parentAccountsSharesHelper, childAccounts, this.sourceAccountsATMsHelper);
    	
    	//create new ATMs and return the result
    	return creator.createNewATMs();
	}
	
	//this method starts a next transaction to process
	//- accounts which should be updated because of the changes made during
	//the current transaction
	//- accounts which could not be updated together with other accounts during
	//the current transaction
	private void tryStartNextTransaction(H_C_ATR_Results currentResults)
	{
		//initialize a list of accounts which should be processed in a next transaction
		List<Account> accountsForNextTransaction = new List<Account>();
		
		//STEP #1: get child accounts of updated accounts from DB. Important moment: it doesn't
		//make sence to re-read those accounts which match deferred accounts.
		
		//if entire hierarchy of accounts should be processed then we should find
		//child accounts of updated accounts
		if (this.options.processEntireHierarchy && currentResults.updatedAccounts.size() > 0)
		{
			//get name of a record type that should be processed during the next transaction
			String recordTypeOfNextChildLevel =
				H_C_AccountRecordType.mapOfChildRecordTypes.get(this.currentAccountRecordType);
			//if a next level exists (for example, key accounts has a next child level -
			//transactional accounts) then the system should process children of updated accounts
			if (String.isNotBlank(recordTypeOfNextChildLevel))
			{
				//create a filter to get new accounts for the next transaction
				H_C_AccountDAO.Filter filter = new H_C_AccountDAO.Filter();
				//new accounts should be children of updated accounts
				filter.parentAccountsIds =
					H_C_AccountHelper.extractAccountsIds(currentResults.updatedAccounts);
				//we don't need to re-read accounts which were deferred (it will save SOQL limits)
				filter.ignorableAccountsIds =
					H_C_AccountHelper.extractAccountsIds(this.deferredAccounts);
				//we don't need get accounts which belong to updated accounts if they have
				//incorrect record type
				filter.accountRecordTypes = new String[] {recordTypeOfNextChildLevel};
				
				//get correct accounts for the next transaction
				Account[] childrenOfUpdatedAccounts = H_C_AccountDAO.getAccountsByFilter(filter);
				if (childrenOfUpdatedAccounts != null)
				{
					accountsForNextTransaction.addAll(childrenOfUpdatedAccounts);
				}
			}
		}
		
		//STEP #2: if there are deferred accounts which could not be correctly updated during
		//the current transaction then the system will process them in the next transaction
		if (this.deferredAccounts.size() > 0)
		{
			accountsForNextTransaction.addAll(this.deferredAccounts);
		}
		
		//STEP #3: initialize a new manager and start a next transaction
		if (accountsForNextTransaction.size() > 0)
		{
			Options optionsForNextTransaction = this.options.clone();
			//accounts have been re-grouped already
			optionsForNextTransaction.allAccountsOfSameType = true;
			//initialize a new manager by the list of accounts and the options 
			H_C_ATRD_Manager newManager =
				new H_C_ATRD_Manager(accountsForNextTransaction, optionsForNextTransaction);
			//start a new transaction: similar to a RECURSIVE call
			newManager.updateTeams();
		}
	}
	
	//
	//Public methods
	//
	//this method gets accounts which are parent accounts and starts the roll up mechanism for them
	public void updateTeams()
	{
		//STEP #1: prepare the current transaction for work
		this.prepareCurrentTransaction();
		
		//STEP #2: try perform the current transaction
		//this object will contain new ATMs, their shares and the list of updated accounts
        H_C_ATR_Results allResults = new H_C_ATR_Results();
		if (this.isCurrentTransactionPossible())
		{
			//2.1) get all necessary data from DB and initialize helpers
			//2.1.1) initialize a helper for all source accounts
			this.sourceAccountsHelper =
				H_C_AccountHelper.createHelperByAccountsList(this.sourceAccounts);
			
			//2.1.2) extract Ids of all source accounts, get their ATMs and initialize a helper
			//for them. Note that we need to get all ATMs without any filtering
			String[] sourceAccountsIds = sourceAccountsHelper.extractAccountsIds();
			this.sourceAccountsATMsHelper = H_C_AccountTeamMemberHelper.createHelperByFilter(
	        	buildFilterForATMs(sourceAccountsIds));
			
			//2.1.3) extract Ids of parent accounts of source accounts, get their ATMs and initialize
			//a helper for them. Note that these ATMs should be filtered by using roll-down options
			//and the helper will be empty if parentAccountsIds is empty
			String[] parentAccountsIds = sourceAccountsHelper.extractParentAccountsIds();
			this.parentAccountsATMsHelper = H_C_AccountTeamMemberHelper.createHelperByFilter(
	        	buildFilterForATMs(parentAccountsIds, this.currentRollDownOptions));
	        
	        //2.1.4) get all shares for ATMs who were obtained on the previous step and initialize
	        //a helper for them. Note that the helper will be empty if parentAccountsIds is empty
	        this.parentAccountsSharesHelper = H_C_AccountShareHelper.createHelperByFilter(
	        	buildFilterForAccountShares(this.parentAccountsATMsHelper.allTeamMembers));
	        
	        
	        //2.2) process an every account that can be processed in the current transaction
	        for (String parentAccountId : parentAccountsIds)
	        {
	        	//try to create new ATMs and their shares for the current account
	        	H_C_ATR_Results currentResults = this.createATMsForChildAccounts(parentAccountId);
        		//join current results with full results
        		allResults.joinResults(currentResults);
	        }
	        
	        //2.3) insert all new objects in DB
	        allResults.insertObjectsInDB();
		}
        
        //STEP #3: IMPORTANT:
        //after the current transaction is finished we check if it's needed to start a next
        //transaction according to the options and the source data: similar to a RECURSIVE call
        tryStartNextTransaction(allResults);
	}
	//
	
	
	
	//
	//Data types
	//
	public class Options
	{
		//
		//Constructors
		//
		public Options()
		{
			//set default values for all properties
			this.allAccountsOfSameType = false;
			this.processEntireHierarchy = false;
		}
		//
		
		//
		//Properties
		//
		public Boolean allAccountsOfSameType {get; set;}
		public Boolean processEntireHierarchy {get; set;}
		//
	}
	//
}