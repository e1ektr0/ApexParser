//
//This class provides utility methods for the rollup mechanism of an account team
//Used abbreviations:
// - ATM means 'Account Team Member'
// - ATR means 'Account Team Rolling (both directions: up and down)'
// - ATRU means 'Account Team Roll-Up'
// - ATRD means 'Account Team Roll-Down'
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (6-09-2013)
public without sharing class H_C_ATR_Utils
{
	//
	//Public static methods
	//
	//this method returns TRUE only if an account takes part in roll mechanisms as a child
    public static Boolean isChildAccount(Account account)
    {
        //if an account has no parent then we shouldn't use it at all
        if (String.isBlank(account.ParentId))
        {
            return false;
        }
        
        //extract a name of a record type for the account
        String recordTypeName = H_C_AccountRecordType.mapOfIdsAndNames.get(account.RecordTypeId);
        //if an account has a parent, but its record type is not considered as a child type
        //by the application then we shouldn't consider that it's child
        return (recordTypeName == H_C_AccountRecordType.KEY_REGION_ACCOUNT
            || recordTypeName == H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT);
    }
    
    //this method returns TRUE only if an account takes part in roll mechanisms as a parent
    public static Boolean accountHasParentalRights(Account account)
    {
        //extract a name of a record type for the account
        String recordTypeName = H_C_AccountRecordType.mapOfIdsAndNames.get(account.RecordTypeId);
        //an account can be a parent only if it is Contract Account or Key(Region) Account
        return (recordTypeName == H_C_AccountRecordType.CONTRACT_ACCOUNT
            || recordTypeName == H_C_AccountRecordType.KEY_REGION_ACCOUNT);
    }
	
	public static void updateTeamsInTrigger_onAccountsUpdated(
        Map<Id, Account> oldAccounts, Account[] updatedAccounts)
    {
        //if input parameters are incorrect then stop the method
        if (oldAccounts == null || updatedAccounts == null)
        {
        	//stop the method
            return;
        }
        
        //STEP #1: analyze updated accounts
        //initialize and fill the list of Ids of parent accounts which teams can be updated
        //by the rollup mechanism
        List<String> selectedParentAccountsIds = new List<String>();
        //initialize and fill the list of accounts which teams can be updated by the
        //roll-down mechanism
        List<Account> selectedChildAccounts = new List<Account>();
        
        //iterate through all updated accounts
        for (Account updatedAccount : updatedAccounts)
        {
        	//get old version of the current updated account
            Account oldAccount = oldAccounts.get(updatedAccount.Id);
            //if updatedAccount is a child account and its ParentId has been changed then
            //select this account and its parent
            if (isChildAccount(updatedAccount) && updatedAccount.ParentId != oldAccount.ParentId)
            {
                selectedParentAccountsIds.add(updatedAccount.ParentId);
                selectedChildAccounts.add(updatedAccount);
            }
        }
        
        //STEP #2: start the ROLLUP mechanism for selected parent accounts Ids
        if (selectedParentAccountsIds.size() > 0)
        {
        	//initialize correct options for ATR manager
        	H_C_ATRU_Manager.Options managerOptions = new H_C_ATRU_Manager.Options();
        	//initially it was supposed that the organization has no incorrect hierarchies
        	//of accounts (the flag was set to 'true' because of the 1st step). But later we found
        	//that sometimes the system is used in an unexpected way (like, transactional account
        	//is used as a parent for another account), in this case our code should ignore such
        	//problems in hierarchies, but of course it shouldn't start the rollup process for them.
        	//As a result, we can't guarantee that all accounts in the trigger has parental rights
        	managerOptions.allAccountsHaveParentalRights = false;
        	//we can't guarantee this, because trigger can be started for a set of different accounts
        	managerOptions.allAccountsOfSameType = false;
        	//we want that entire hierarchy will be updated automatically (accounts, their parents and etc)
        	managerOptions.processEntireHierarchy = true;
        	
        	//initialize ATR manager and start the process for the selected parent accounts Ids
        	H_C_ATRU_Manager manager = new H_C_ATRU_Manager(selectedParentAccountsIds, managerOptions);
        	manager.updateTeams();
        }
        
        //STEP #3: start the ROLL-DOWN mechanism for the selected parent accounts Ids
        if (selectedChildAccounts.size() > 0)
        {
        	//initialize correct options for ATRD manager
        	H_C_ATRD_Manager.Options managerOptions = new H_C_ATRD_Manager.Options();
        	//we can't guarantee this, because trigger can be started for a set of different accounts
        	managerOptions.allAccountsOfSameType = false;
        	//we want that entire hierarchy will be updated automatically (accounts, their children and etc)
        	managerOptions.processEntireHierarchy = true;
        	
        	//initialize ATRD manager and start the process for the selected child accounts
        	H_C_ATRD_Manager manager = new H_C_ATRD_Manager(selectedChildAccounts, managerOptions);
        	manager.updateTeams();
        }
    }
	//
}