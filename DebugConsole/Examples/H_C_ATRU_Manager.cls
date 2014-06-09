//
//This class manages the rollup process for account teams.
//Used abbreviations:
// - ATRU means 'Account Team Roll-Up'
// - ATM means 'Account Team Member'
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (6-09-2013)
public without sharing class H_C_ATRU_Manager
{
	//
	//Constructors
	//
	public H_C_ATRU_Manager(Account[] accounts, Options options)
	{
		//check the correctness of the data
		if (accounts == null || options == null)
		{
			throw new H_C_Exception('H_C_ATRU_Manager was initialized by incorrect parameters.\nAccounts = '
				+ accounts + '\nOptions = ' + options);
		}
		
		this.sourceAccounts = accounts;
		this.options = options;
	}
	
	public H_C_ATRU_Manager(String[] accountsIds, Options options)
	{
		//get source accounts by Ids from DB and recall another constructor
		this(H_C_AccountDAO.getAccountsByIds(accountsIds), options);
	}
	//
	
	//
	//Constants
	//
	//a list of account record types which teams can be updated by the rollup mechanism
	private static String[] POSSIBLE_TARGET_RECORD_TYPES = new String[] {
		H_C_AccountRecordType.KEY_REGION_ACCOUNT, H_C_AccountRecordType.CONTRACT_ACCOUNT};
	//
	
	//
	//Variables
	//
	private Options options;
	
	private Account[] sourceAccounts;
	private H_C_AccountHelper childAccountsHelper;
	private H_C_AccountTeamMemberHelper childAccountsATMsHelper;
	
	private List<Account> deferredAccounts = new List<Account>();
	//
	
	//
	//Private static methods
	//	
	//this method creates filter for ATMs and fills it correctly
	private static H_C_AccountTeamMemberDAO.Filter buildFilterForATMs(String[] parentAccountsIds)
	{
		H_C_AccountTeamMemberDAO.Filter filter = null;
		//create a real filter only if a main filtering aspect (parentAccountsIds) can be applied
		if (parentAccountsIds != null && parentAccountsIds.size() > 0)
		{
			filter = new H_C_AccountTeamMemberDAO.Filter();
			//set parentAccountsIds according to the input parameters
			filter.parentAccountsIds = parentAccountsIds;
			//we should not work with team members who are ignored during roll up
			filter.ignorableTeamRoles = H_C_CustomSettings.getIgnorableTeamRolesDuringRollup();
			//we should ignore team members for inactive users, because new team members can't
			//be created for them
			filter.ignoreInactiveUsers = true;
		}
		//return created filter
		return filter;
	}
	
	private static Boolean isAnyRollUpProcessPossible()
	{
		for (String targetAccountRecordType : POSSIBLE_TARGET_RECORD_TYPES)
		{
			H_C_ATRU_Options options = H_C_CustomSettings.getATRU_Options(targetAccountRecordType);
			if (options.isProcessEnabled)
			{
				//return TRUE if at least 1 level of accounts can be processed
				return true;
			}
		}
		//return FALSE, if the rollup mechanism is disabled on all levels
		return false;
	}
	//
	
	private void filterSourceAccounts()
	{
		//select accounts which have parental rights only, because only their teams can be updated
		if (this.options.allAccountsHaveParentalRights)
		{
			//if there is a guarantee that all accounts have parental rights then
			//we don't filter them
			return;
		}
		else
		{
			//if we need to check parental rights then the code selects accounts which can be a parent
			List<Account> selectedAccounts = new List<Account>();
			//iterate through all input accounts
			for (Account account : this.sourceAccounts)
			{
				if (H_C_ATR_Utils.accountHasParentalRights(account))
				{
					//if account has parental rights then add it into the service list
					selectedAccounts.add(account);
				}
			}
			
			//set selected accounts as source accounts
			this.sourceAccounts = selectedAccounts;
		}
	}
	
	private void regroupSourceAccounts()
	{
		//if there is a guarantee that all passed accounts have same record type, then
		//we can process all passed accounts without special filtering
		if (this.options.allAccountsOfSameType)
		{
			return;
		}
		
		//if accounts have different record types then this method uses the following logic
		//to filter them:
		//- all accounts which are parent for other accounts among the passed accounts
		//will be ignored in the current transaction and deferred till the next transaction
		//(it's needed because a parent cannot be correctly updated before its children are updated)
		//- all other accounts (child accounts and parent accounts which have no child accounts
		//among the passed ones) can be processed in the current transaction
		
		//intialize the list to store accounts selected for the current transaction
		List<Account> selectedAccounts = new List<Account>();
		
		//initialize a helper for all passed accounts
		H_C_AccountHelper accountsHelper = H_C_AccountHelper.createHelperByAccountsList(this.sourceAccounts);
		for (Account account : this.sourceAccounts)
		{
			//if a current account is not a parent of at least 1 account among the passed
			//accounts then we select it, else add it to the array of deferred accounts
			if (accountsHelper.getAccountsByParentId(account.Id).size() == 0)
			{
				selectedAccounts.add(account);
			}
			else
			{
				this.deferredAccounts.add(account);
			}
		}
		
		//replace the list of passed accounts by the filtered list
		this.sourceAccounts = selectedAccounts;
	}
	
	private void prepareSourceAccounts()
	{
		//firstly, we should filter source accounts
		this.filterSourceAccounts();
		//secondly, we should check if we need to re-group source accounts
		this.regroupSourceAccounts();
	}
	
	//the method creates new ATMs for a parent account 
	private H_C_ATR_Results createATMsForParentAccount(Account parentAccount)
	{
		//extract child accounts for the current parent account
    	Account[] childAccounts = this.childAccountsHelper.getAccountsByParentId(parentAccount.Id);
		//initial check which is used to stop the method without large costs
    	if (childAccounts.size() == 0)
    	{
    		//return empty results
    		return new H_C_ATR_Results();
    	}
    	
    	//initialize creator of ATMs
    	H_C_ATRU_ATMsCreator creator = new H_C_ATRU_ATMsCreator(
    		parentAccount, childAccounts, this.childAccountsATMsHelper);
    	
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
		
		//STEP #1: if entire hierarchy of accounts should be processed then we analyze
		//updated accounts and extract their parents to update their teams
		if (this.options.processEntireHierarchy)
		{
			Set<String> setOfAccountsIdsForNextTransaction = new Set<String>();
	        //iterate through all updated accounts
	        for (Account updatedAccount : currentResults.updatedAccounts)
	        {
	        	//if the current account is a correct child then select its parental reference
	            if (H_C_ATR_Utils.isChildAccount(updatedAccount))
	            {
	            	//add ParentId into the set of account Ids
	                setOfAccountsIdsForNextTransaction.add(updatedAccount.ParentId);
	            }
	        }
	        
	        //it doesn't make sence to re-read accounts which were deferred. That's why we remove
	        //Ids of deferred accounts from the set (it will save SOQL limits)
	        setOfAccountsIdsForNextTransaction.removeAll(
	        	H_C_AccountHelper.extractAccountsIds(this.deferredAccounts));
	        //get correct parent accounts of updated accounts for the next transaction
			Account[] parentsOfUpdatedAccounts = H_C_AccountDAO.getAccountsByIds(
				new List<String>(setOfAccountsIdsForNextTransaction));
			if (parentsOfUpdatedAccounts != null)
			{
				accountsForNextTransaction.addAll(parentsOfUpdatedAccounts);
			}
		}
		
		//STEP #2: if there are deferred accounts which could not be correctly updated during
		//the current transaction then we add them into the list
		if (this.deferredAccounts.size() > 0)
		{
			accountsForNextTransaction.addAll(this.deferredAccounts);
		}
		
		//STEP #3: initialize a new manager and start a next transaction
		if (accountsForNextTransaction.size() > 0)
		{
			Options optionsForNextTransaction = this.options.clone();
			//all accounts have been already filtered
			optionsForNextTransaction.allAccountsHaveParentalRights = true;
			//this is because all deffered accounts and parents of updated accounts should
			//be on the same level
			optionsForNextTransaction.allAccountsOfSameType = true;
			
			//initialize a new manager by the list of accounts and a copy of the current options 
			H_C_ATRU_Manager newManager =
				new H_C_ATRU_Manager(accountsForNextTransaction, optionsForNextTransaction);
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
		//if the rollup mechanism is disabled on all levels then we stop the method
		if (!isAnyRollUpProcessPossible())
		{
			//stop the method
			return;
		}
		
		//STEP #1: prepare source accounts before the code processes them
		this.prepareSourceAccounts();
		
		//STEP #2: try perform the current transaction
		//this object will contain new ATMs, their shares and the list of updated accounts
        H_C_ATR_Results allResults = new H_C_ATR_Results();
		if (this.sourceAccounts.size() > 0)
		{
			//2.1) get all necessary data from DB and initialize helpers
			//2.1.1) initialize a helper for all child accounts of source accounts
			String[] accountsIds = H_C_AccountHelper.extractAccountsIds(this.sourceAccounts);
	        this.childAccountsHelper = H_C_AccountHelper.createHelperByParentsIds(accountsIds);
	        
	        //2.1.2) create a helper for all ATMs of child accounts
	        this.childAccountsATMsHelper = H_C_AccountTeamMemberHelper.createHelperByFilter(
	        	buildFilterForATMs(accountsIds));
	        
	        //2.2) process an every account that can be processed in the current transaction
	        for (Account account : this.sourceAccounts)
	        {
	        	//try to create new ATMs and their shares for the current account
	        	H_C_ATR_Results currentResults = this.createATMsForParentAccount(account);
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
			this.allAccountsHaveParentalRights = false;
			this.processEntireHierarchy = false;
		}
		//
		
		//
		//Properties
		//
		public Boolean allAccountsOfSameType {get; set;}
		public Boolean allAccountsHaveParentalRights {get; set;}
		public Boolean processEntireHierarchy {get; set;}
		//
	}
	//
}