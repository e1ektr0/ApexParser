//
//This class provides utilities for working with 'H_C_AccountAccountPlan__c' object 
//
//Author: CERVELLO INC - Anil Tumati / Sergey Trusov (27-02-2014)
public without sharing class H_C_AccountAccountPlanUtils
{
    //
    //Private static methods
    //
    private static H_C_AccountAccountPlan__c constructMapping(
        Account_Plan__c accountPlan, String accountId)
    {
        H_C_AccountAccountPlan__c newMapping = new H_C_AccountAccountPlan__c();
        newMapping.Account__c = accountId;
        newMapping.AccountPlan__c = accountPlan.Id;
        newMapping.Name = accountPlan.Name;
        return newMapping;
    }

    private static H_C_AccountAccountPlan__c[] constructMappings(Account_Plan__c accountPlan)
    {
        List<H_C_AccountAccountPlan__c> newObjects = new List<H_C_AccountAccountPlan__c>();
        //create account-accountPlan mapping for the current account
        if (String.isNotBlank(accountPlan.Account__c))
        {
            newObjects.add(constructMapping(accountPlan, accountPlan.Account__c));
        }
        
        //create account-accountPlan mapping for a parent of the current account
        if (String.isNotBlank(accountPlan.Account__r.ParentId))
        {
            newObjects.add(constructMapping(accountPlan, accountPlan.Account__r.ParentId));
        }
        
        //create account-accountPlan mapping for a parent of a parent of the current account
        if (String.isNotBlank(accountPlan.Account__r.Parent.ParentId))
        {
            newObjects.add(constructMapping(accountPlan, accountPlan.Account__r.Parent.ParentId));
        }
        return newObjects;
    }
    
    private static H_C_OperationResults createNewMappings(Account_Plan__c[] accountPlans)
    {
    	//if there are no passed objects that nothing can be created
    	if (accountPlans == null || accountPlans.size() == 0)
    	{
    		//in this case we consider that the method executed successfully, because
    		//there were no any internal errors
    		return new H_C_OperationResults(true);
    	}
    	
    	//construct new mappings
        List<H_C_AccountAccountPlan__c> newMappings = new List<H_C_AccountAccountPlan__c>();
        for (Account_Plan__c accountPlan : accountPlans)
        {
            newMappings.addAll(constructMappings(accountPlan));
        }
        //insert new mappings (perform 1 DML operation to insert all new mappings)
        return H_C_SoqlUtils.performSafeDmlOperation(H_C_SoqlUtils.DmlOperation.Inserting, newMappings);
    }
    
    private static void processAccountPlans_onUpdateAccountLinks(
    	Map<Id, Account_Plan__c> oldAccountPlans, Account_Plan__c[] updatedAccountPlans)
    {
        //STEP #1: analyze updated accountPlans and select only those accountPlans
        //which 'AccountId' reference has been changed
        List<String> selectedAccountPlanIds = new List<String>();
        for (Account_Plan__c updatedAccountPlan : updatedAccountPlans)
        {
            Account_Plan__c oldAccountPlan = oldAccountPlans.get(updatedAccountPlan.Id);
            if (updatedAccountPlan.Account__c != oldAccountPlan.Account__c)
            {
                selectedAccountPlanIds.add(updatedAccountPlan.Id);
            }
        }
        //if there are no accountPlans which are interesting for this method then we stop it
        if (selectedAccountPlanIds.size() == 0)
        {
        	return;
        }
        
        //STEP #2: manage existing mappings
        //we should get and delete all existing mappings for updated accountPlans,
        //because they are not actual now
        H_C_AccountAccountPlan__c[] existingMappings =
        	H_C_AccountAccountPlanUtils.getObjectsByAccountPlanIds(selectedAccountPlanIds);
        //perform 1 DML operation to delete all new mappings
        H_C_SoqlUtils.tryPerformDmlOperation(H_C_SoqlUtils.DmlOperation.Deleting, existingMappings);
        
        //STEP #3: manage new mappings
        //reread the selected accountPlans to include all necessary fields
        Account_Plan__c[] selectedAccountPlans = getAccountPlanByIds(selectedAccountPlanIds);
        //generate and insert new mappings
        createNewMappings(selectedAccountPlans);
    }
    //
    
    //
    //Public static methods
    //
    public static H_C_OperationResults manageMappingsForAccounts(String[] accountsIds)
    {
    	//we make an assumption that the method will be executed successfully, and if any errors
    	//occur then the method will update this results    	
    	H_C_OperationResults results = new H_C_OperationResults(true);
    	
        //if there are no accounts for this method then we can do nothing
        if (accountsIds != null && accountsIds.size() > 0)
        {
            //get all existing mappings for accountPlans of source accounts and delete them
            H_C_AccountAccountPlan__c[] existingMappings =
                H_C_AccountAccountPlanUtils.getObjectsByAccountPLanAccountsIds(accountsIds);
            //try to safely delete existing mappings and save intermediate results
            //into the final results
            results = H_C_SoqlUtils.performSafeDmlOperation(
            	H_C_SoqlUtils.DmlOperation.Deleting, existingMappings);
            
            //we can continue only if there were no errors during the previous steps 
            if (results.isOperationSuccessful)
            {
	            //get all accountPlans for source accounts and create new mappings for them
	            Account_Plan__c[] accountaccountPlans = getAccountPlanByAccountsIds(accountsIds);
	            //try to generate and insert new mappings, and update the final results
	            results = createNewMappings(accountAccountPlans);
            }
        }
        
        return results;
    }
    
    public static void manageMappings_onAccountsUpdated(
        Map<Id, Account> oldAccounts, Account[] updatedAccounts)
    {
        //check input parameters
        if (oldAccounts == null || updatedAccounts == null)
        {
            return;
        }
        
        //STEP #1: analyze updated accounts and select only those accounts which
        //parent reference has been changed
        List<String> selectedAccountsIds = new List<String>();
        for (Account updatedAccount : updatedAccounts)
        {
            Account oldAccount = oldAccounts.get(updatedAccount.Id);
            if (updatedAccount.ParentId != oldAccount.ParentId)
            {
                selectedAccountsIds.add(updatedAccount.Id);
            }
        }
        
        //STEP #2: change existing or create new mappings 
        manageMappingsForAccounts(selectedAccountsIds);
    }
    
    public static void manageMappings_onAccountPlanInserted(Account_Plan__c[] insertedAccountPlans)
    {
        //check the input parameter
        if (insertedAccountPlans == null || insertedAccountPlans.size() == 0)
        {
            return;
        }
        
        //STEP #1: reread the accountPlans to include all necessary fields
        String[] insertedAccountPlanIds = extractAccountPlanIds(insertedAccountPlans);
        insertedaccountPlans = getAccountPlanByIds(insertedAccountPlanIds);
        
        //STEP #2: create and insert new mappings
        createNewMappings(insertedAccountPlans);
    }
    
    public static void manageMappings_onAccountPlanUpdated(
    	Map<Id, Account_Plan__c> oldAccountPlans, Map<Id, Account_Plan__c> updatedAccountPlans)
    {
        //check input parameters
        if (oldAccountPlans == null || updatedaccountPlans == null)
        {
            return;
        }
        
        //STEP #1: manage mappings for accountPlans which 'Account' references have been changed
        processAccountPlans_onUpdateAccountLinks(oldAccountPlans, updatedAccountPlans.values());
        
        //#WARNING: this call should be parameterized, because some objects have 'auto number' Name
        //which can't be changed (like, Account_Plan__c). In this case, it's useless to check changes
        //in name
        //STEP #2 (the name of 'Account_Plan__c' object can't be changed):
        //manage mappings for accountPlans which names have been changed
        //processAccountPlan_onUpdateNames(oldAccountPlan, updatedAccountPlans);
    }
    //
    
    
    //
	//This code is used to provide access to 'H_C_AccountAccountPlan__c' object
	//(it has been implemented in a separate class, but was moved here to simplify
	//the procedure of creation of new mappings)
    //
    //Variables and constants
    //
    private static String BASIC_FIELDS = 'Id, Name, Account__c, AccountPlan__c';
    private static String OBJECT_NAME = 'H_C_AccountAccountPlan__c';
    //
    
    //
    //Public static methods
    //
    private static H_C_AccountAccountPlan__c[] getObjectsByIds(String[] objectsIds)
    {
        //join Ids and check the string
        String stringOfIds = H_C_SoqlUtils.joinStringsForINSection(objectsIds);
        if (String.isBlank(stringOfIds))
        {
            return null;
        }
        
        //initialize query builder and perform the query
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        queryBuilder.condition = 'Id IN (' + stringOfIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    
    private static H_C_AccountAccountPlan__c[] getObjectsByAccountsIds(String[] accountsIds)
    {
        //join Ids and check the string
        String stringOfAccountsIds = H_C_SoqlUtils.joinStringsForINSection(accountsIds);
        if (String.isBlank(stringOfAccountsIds))
        {
            return null;
        }
        
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        queryBuilder.condition = 'Account__c IN (' + stringOfAccountsIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    
    //this method returns all mappings which contain accountPlan that belong to the passed accounts
    //(for example, if we pass only one account Id, then this method returns all mappings which
    //contain accountPlans of that account)
    private static H_C_AccountAccountPlan__c[] getObjectsByAccountPLanAccountsIds(String[] accountsIds)
    {
        String stringOfAccountsIds = H_C_SoqlUtils.joinStringsForINSection(accountsIds);
        if (String.isBlank(stringOfAccountsIds))
        {
            return null;
        }
        
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        queryBuilder.condition = 'Account_Plan__r.Account__c IN (' + stringOfAccountsIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    
    private static H_C_AccountAccountPlan__c[] getObjectsByAccountPlanIds(String[] accountPlansIds)
    {
        //join Ids and check the string
        String stringOfAccountPlanIds = H_C_SoqlUtils.joinStringsForINSection(accountPlansIds);
        if (String.isBlank(stringOfAccountPlanIds))
        {
            return null;
        }
        
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        queryBuilder.condition = 'Account_Plan__c IN (' + stringOfAccountPlanIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    //


	//AccountPLanDAO Section
	//
	//This Section provides access to 'Account_Plan__c' object
	//
	//Author: CERVELLO INC - Anil Tumati / Sergey Trusov (27-02-2014)

    //
    //Variables and constants
    //
    private static String BASIC_FIELDS_2 = 'Id, Name, Account__c, '
    	+ 'Account__r.ParentId, Account__r.Parent.ParentId';
    private static String OBJECT_NAME_2 = 'Account_Plan__c';
    //
    
    //
    //Public static methods
    //
    private static Account_Plan__c[] getAccountPlanByIds(String[] accountPlansIds)
    {
        //join Ids and check the string
        String stringOfIds = H_C_SoqlUtils.joinStringsForINSection(accountPlansIds);
        if (String.isBlank(stringOfIds))
        {
            return null;
        }
        
        //initialize query builder and perform the query
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS_2, OBJECT_NAME_2);
        queryBuilder.condition = 'Id IN (' + stringOfIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    
    private static Account_Plan__c[] getAccountPlanByAccountsIds(String[] accountsIds)
    {
        String stringOfAccountsIds = H_C_SoqlUtils.joinStringsForINSection(accountsIds);
        if (String.isBlank(stringOfAccountsIds))
        {
            return null;
        }
        
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS_2, OBJECT_NAME_2);
        queryBuilder.condition = 'Account__c IN (' + stringOfAccountsIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    
    private static String[] extractAccountPlanIds(Account_Plan__c[] accountPlans)
    {
        if (accountPlans == null)
        {
            return null;
        }
        
        Set<String> setOfAccountPlanIds = new Set<String>();
        for (Account_Plan__c accountPlan : accountPlans)
        {
            if (String.isNotBlank(accountPlan.Id))
            {
                setOfAccountPlanIds.add(accountPlan.Id);
            }
        }
        
        List<String> listOfAccountPlanIds = new List<String>();
        listOfAccountPlanIds.addAll(setOfAccountPlanIds);
        return listOfAccountPlanIds;
    }
    //
}