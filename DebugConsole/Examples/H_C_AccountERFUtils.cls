//
//This class provides utilities for working with 'H_C_AccountERF__c' object 
//
//Author: CERVELLO INC - Anil Tumati / Sergey Trusov (27-02-2014)
public without sharing class H_C_AccountERFUtils
{
    //
    //Private static methods
    //
    private static H_C_AccountERF__c constructMapping(
        ERF__c erf, String accountId)
    {
        H_C_AccountERF__c newMapping = new H_C_AccountERF__c();
        newMapping.Account__c = accountId;
        newMapping.ERF__c = erf.Id;
        newMapping.Name = erf.Name;
        return newMapping;
    }

    private static H_C_AccountERF__c[] constructMappings(ERF__c erf)
    {
        List<H_C_AccountERF__c> newObjects = new List<H_C_AccountERF__c>();
        //create account-erf mapping for the current account
        if (String.isNotBlank(erf.Ship_To_Account__c))
        {
            newObjects.add(constructMapping(erf, erf.Ship_To_Account__c));
        }
        
        //create account-erf mapping for a parent of the current account
        if (String.isNotBlank(erf.Ship_To_Account__r.ParentId))
        {
            newObjects.add(constructMapping(erf, erf.Ship_To_Account__r.ParentId));
        }
        
        //create account-erf mapping for a parent of a parent of the current account
        if (String.isNotBlank(erf.Ship_To_Account__r.Parent.ParentId))
        {
            newObjects.add(constructMapping(erf, erf.Ship_To_Account__r.Parent.ParentId));
        }
        return newObjects;
    }
    
    private static H_C_OperationResults createNewMappings(ERF__c[] erfs)
    {
    	//if there are no passed objects that nothing can be created
    	if (erfs == null || erfs.size() == 0)
    	{
    		//in this case we consider that the method executed successfully, because
    		//there were no any internal errors
    		return new H_C_OperationResults(true);
    	}
    	
    	//construct new mappings
        List<H_C_AccountERF__c> newMappings = new List<H_C_AccountERF__c>();
        for (ERF__c erf : erfs)
        {
            newMappings.addAll(constructMappings(erf));
        }
        //insert new mappings (perform 1 DML operation to insert all new mappings)
        return H_C_SoqlUtils.performSafeDmlOperation(H_C_SoqlUtils.DmlOperation.Inserting, newMappings);
    }
    
    private static void processERF_onUpdateAccountLinks(
    	Map<Id, ERF__c> oldERFs, ERF__c[] updatedERFs)
    {
        //STEP #1: analyze updated erfs and select only those erfs
        //which 'AccountId' reference has been changed
        List<String> selectedERFIds = new List<String>();
        for (ERF__c updatedERF : updatedERFs)
        {
            ERF__c oldERF = oldERFs.get(updatedERF.Id);
            if (updatedERF.Ship_To_Account__c != oldERF.Ship_To_Account__c)
            {
                selectedERFIds.add(updatedERF.Id);
            }
        }
        //if there are no erfs which are interesting for this method then we stop it
        if (selectedERFIds.size() == 0)
        {
        	return;
        }
        
        //STEP #2: manage existing mappings
        //we should get and delete all existing mappings for updated erfs,
        //because they are not actual now
        H_C_AccountERF__c[] existingMappings =
        	H_C_AccountERFUtils.getObjectsByERFIds(selectedERFIds);
        //perform 1 DML operation to delete all new mappings
        H_C_SoqlUtils.tryPerformDmlOperation(H_C_SoqlUtils.DmlOperation.Deleting, existingMappings);
        
        //STEP #3: manage new mappings
        //reread the selected erfs to include all necessary fields
        ERF__c[] selectedERFs = getERFByIds(selectedERFIds);
        //generate and insert new mappings
        createNewMappings(selectedERFs);
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
            //get all existing mappings for erfs of source accounts and delete them
            H_C_AccountERF__c[] existingMappings =
                H_C_AccountERFUtils.getObjectsByERFAccountsIds(accountsIds);
            //try to safely delete existing mappings and save intermediate results
            //into the final results
            results = H_C_SoqlUtils.performSafeDmlOperation(
            	H_C_SoqlUtils.DmlOperation.Deleting, existingMappings);
            
            //we can continue only if there were no errors during the previous steps 
            if (results.isOperationSuccessful)
            {
	            //get all erfs for source accounts and create new mappings for them
	            ERF__c[] accountErfs = getERFByAccountsIds(accountsIds);
	            //try to generate and insert new mappings, and update the final results
	            results = createNewMappings(accountErfs);
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
    
    public static void manageMappings_onERFInserted(ERF__c[] insertedERFs)
    {
        //check the input parameter
        if (insertedERFs == null || insertedERFs.size() == 0)
        {
            return;
        }
        
        //STEP #1: reread the accountPlans to include all necessary fields
        String[] insertedERFIds = extractERFIds(insertedERFs);
        insertedERFs = getERFByIds(insertedERFIds);
        
        //STEP #2: create and insert new mappings
        createNewMappings(insertedERFs);
    }
    
    public static void manageMappings_onERFUpdated(
    	Map<Id, ERF__c> oldERFs, Map<Id, ERF__c> updatedERFs)
    {
        //check input parameters
        if (oldERFs == null || updatedERFs == null)
        {
            return;
        }
        
        //STEP #1: manage mappings for accountPlans which 'Account' references have been changed
        processERF_onUpdateAccountLinks(oldERFs, updatedERFs.values());
        
        //#WARNING: this call should be parameterized, because some objects have 'auto number' Name
        //which can't be changed (like, ERF__c). In this case, it's useless to check changes
        //in name
        //STEP #2 (the name of 'ERF__c' object can't be changed):
        //manage mappings for accountPlans which names have been changed
        //processErf_onUpdateNames(oldErf, updatedErfs);
    }
    //
    
    
    //
	//This code is used to provide access to 'H_C_AccountERF__c' object
	//(it has been implemented in a separate class, but was moved here to simplify
	//the procedure of creation of new mappings)
    //
    //Variables and constants
    //
    private static String BASIC_FIELDS = 'Id, Name, Account__c, ERF__c';
    private static String OBJECT_NAME = 'H_C_AccountERF__c';
    //
    
    //
    //Public static methods
    //
    private static H_C_AccountERF__c[] getObjectsByIds(String[] objectsIds)
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
    
    private static H_C_AccountERF__c[] getObjectsByAccountsIds(String[] accountsIds)
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
    private static H_C_AccountERF__c[] getObjectsByERFAccountsIds(String[] accountsIds)
    {
        String stringOfAccountsIds = H_C_SoqlUtils.joinStringsForINSection(accountsIds);
        if (String.isBlank(stringOfAccountsIds))
        {
            return null;
        }
        
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        queryBuilder.condition = 'ERF__r.Ship_To_Account__c IN (' + stringOfAccountsIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    
    private static H_C_AccountERF__c[] getObjectsByErfIds(String[] accountPlansIds)
    {
        //join Ids and check the string
        String stringOfErfIds = H_C_SoqlUtils.joinStringsForINSection(accountPlansIds);
        if (String.isBlank(stringOfErfIds))
        {
            return null;
        }
        
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        queryBuilder.condition = 'ERF__c IN (' + stringOfErfIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    //


	//AccountPLanDAO Section
	//
	//This Section provides access to 'ERF__c' object
	//
	//Author: CERVELLO INC - Anil Tumati / Sergey Trusov (27-02-2014)

    //
    //Variables and constants
    //
    private static String BASIC_FIELDS_2 = 'Id, Name, Ship_To_Account__c, '
    	+ 'Ship_To_Account__r.ParentId, Ship_To_Account__r.Parent.ParentId';
    private static String OBJECT_NAME_2 = 'ERF__c';
    //
    
    //
    //Public static methods
    //
    private static ERF__c[] getERFByIds(String[] accountPlansIds)
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
    
    private static ERF__c[] getERFByAccountsIds(String[] accountsIds)
    {
        String stringOfAccountsIds = H_C_SoqlUtils.joinStringsForINSection(accountsIds);
        if (String.isBlank(stringOfAccountsIds))
        {
            return null;
        }
        
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS_2, OBJECT_NAME_2);
        queryBuilder.condition = 'Ship_To_Account__c IN (' + stringOfAccountsIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    
    private static String[] extractERFIds(ERF__c[] erfs)
    {
        if (erfs == null)
        {
            return null;
        }
        
        Set<String> setOfErfIds = new Set<String>();
        for (ERF__c erf : erfs)
        {
            if (String.isNotBlank(erf.Id))
            {
                setOfErfIds.add(erf.Id);
            }
        }
        
        List<String> listOfErfIds = new List<String>();
        listOfErfIds.addAll(setOfErfIds);
        return listOfErfIds;
    }
    //
    
    //
    //Unit tests
    //
    @IsTest
    private static void test_privateMethods()
    {
        //this method tests unusual cases in private methods
        System.assertEquals(true, createNewMappings(null).isOperationSuccessful);
        System.assertEquals(true, createNewMappings(new ERF__c [0]).isOperationSuccessful);
    }
}