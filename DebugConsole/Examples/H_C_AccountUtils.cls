//
//This class provides utilities for working with 'Account' object 
//
//Author: CERVELLO INC - Anil Tumati / Sergey Trusov (07-02-2014)
public with sharing class H_C_AccountUtils {
	
	//
    //Public static methods
    //
    public static void computeAllAccountsChildren(List<Account> accounts) {
    	/*
    	// Store Accounts, which needs update
    	List<Account> accountsForUpdate = new List<Account>();
    	
    	// Create Helper for optimize work with Accounts
        H_C_AccountHelper accountHeler = H_C_AccountHelper.createHelperByAccountsList(accounts);
        
        // Number of children for current Account
        Integer currentAccountChildrenNumbder = 0;
        
        for(Account currentAccount : accounts) {
        	// Compute number of children for current Account
        	currentAccountChildrenNumbder = accountHeler.getAccountsByParentId(currentAccount.Id).size();
        	
        	// If needs update number of children and add to list for save the changes
        	if (currentAccount.NoOfChildren__c != currentAccountChildrenNumbder) {
        		currentAccount.NoOfChildren__c = currentAccountChildrenNumbder;
        		accountsForUpdate.add(currentAccount);
        	}
        }
        
        // If needs perform 1 DML operation to save the changes
        if (accountsForUpdate.size() > 0) {
        	H_C_SoqlUtils.tryPerformDmlOperation(H_C_SoqlUtils.DmlOperation.Updating, accountsForUpdate);
        }
        */
    }
    
    public static void updateAccountsChildrenNumber(Map<Id, Account> accountsBeforeUpdate, 
    													Map<Id, Account> accountsAfterUpdate) {
/*
    	// Map between Account Id number of children changes
    	Map<String, Integer> accountIdNumberChildMap = new Map<String, Integer>();
    	// Account parent id before update
    	String accountParentBeforeUpdate = '';
    	// Account parent id after update
    	String accountParentAfterUpdate = '';
    	// Account children number
    	Integer currentAccountChildrenNumber = 0;
		for(String accountId : accountsBeforeUpdate.keySet()) {
			accountParentBeforeUpdate = accountsBeforeUpdate.get(accountId).ParentId;
    		accountParentAfterUpdate = accountsAfterUpdate.get(accountId).ParentId;
    		// Compare parent ids
			if (accountParentBeforeUpdate != accountParentAfterUpdate) {
				// Decrement number for parent before update
				currentAccountChildrenNumber = getZeroIfNull(accountIdNumberChildMap.get(accountParentBeforeUpdate));
				accountIdNumberChildMap.put(accountParentBeforeUpdate, currentAccountChildrenNumber - 1);
				
				// Increment number for parent after update
				currentAccountChildrenNumber = getZeroIfNull(accountIdNumberChildMap.get(accountParentAfterUpdate));
				accountIdNumberChildMap.put(accountParentAfterUpdate, currentAccountChildrenNumber + 1);
			}
		}
		// If needs update number of children and perform 1 DML operation to save the changes
		if(accountIdNumberChildMap.keySet().size() > 0) {
			List<Account> accountsForUpdate = H_C_AccountDAO.getAccountsByIds(new List<String>(accountIdNumberChildMap.keySet()));
			for(Account currentAccount : accountsForUpdate) {
				currentAccount.NoOfChildren__c += accountIdNumberChildMap.get(currentAccount.Id);
			}
			
	        H_C_SoqlUtils.tryPerformDmlOperation(H_C_SoqlUtils.DmlOperation.Updating, accountsForUpdate);
		}
		*/
    }
    
    public static void updateAccountsChildrenNumberAfterInsert(Account[] accounts) {
    	/*
    	manageAccountsChildrenNumber(accounts, 1);
    	*/
    }
    
    public static void updateAccountsChildrenNumberAfterDelete(Account[] accounts) {
    	/*
    	manageAccountsChildrenNumber(accounts, -1);
    	*/
    }
    
    public static void runJobForComputeAccountChildren() {
    	/*
    	// Create query for get Accounts
		String queryString = H_C_AccountDAO.createQueryByRecordTypeNames(new String[] {
	        H_C_AccountRecordType.CONTRACT_ACCOUNT,
	        H_C_AccountRecordType.KEY_REGION_ACCOUNT,
	        H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT});
	    // Create job manager
		Database.Batchable<sObject> jobManager = new H_C_BgAccountComputeChildManager(queryString);
		// Start job
		H_C_ApexJobUtils.StartResults results =
			H_C_ApexJobUtils.startJob(jobManager, H_C_ApexJobUtils.JOB_COMPUTE_ACCOUNT_CHILDREN_COUNT);
			*/
    }
    
    //
    //Private static methods
    //
    private static void manageAccountsChildrenNumber(Account[] newAccounts, Integer incrementNumber) {
		/*
		// Create Helper for optimize work with Accounts
        H_C_AccountHelper accountHeler = H_C_AccountHelper.createHelperByAccountsList(newAccounts);
        
        //Extract parent Ids from Account list
        List<String> parentAccountIds = accountHeler.extractParentAccountsIds();
        
        if (parentAccountIds.size() > 0) {
	        // Get Account which have new children
	        List<Account> accountsForUpdate = H_C_AccountDAO.getAccountsByIds(parentAccountIds);
	        
	        // Increment number of Account children
	        for(Account currentAccount : accountsForUpdate) {
				currentAccount.NoOfChildren__c += incrementNumber;
			}
			// Perform 1 DML operation to save the changes
	        H_C_SoqlUtils.tryPerformDmlOperation(H_C_SoqlUtils.DmlOperation.Updating, accountsForUpdate);
        }
        */
    }
    
    //! Move to another class
    private static Integer getZeroIfNull(Integer value) {
		if (value == null) {
			value = 0;
		}
		return value;
    }

}