//
//This class provides utilities for working with 'H_C_AccountCapitalEquipmentIB__c' object 
//
//Author: CERVELLO INC - Anil Tumati / Sergey Trusov (27-02-2014)
public without sharing class H_C_AccountCapitalEquipmentIBUtils
{
    //
    //Private static methods
    //
    private static H_C_AccountCapitalEquipmentIB__c constructMapping(
        Capital_Equipment_Installed_Base__c capitalEquipment, String accountId)
    {
        H_C_AccountCapitalEquipmentIB__c newMapping = new H_C_AccountCapitalEquipmentIB__c();
        newMapping.Account__c = accountId;
        newMapping.CapitalEquipmentInstalledBase__c = capitalEquipment.Id;
        newMapping.Name = capitalEquipment.Name;
        return newMapping;
    }

    private static H_C_AccountCapitalEquipmentIB__c[] constructMappings(Capital_Equipment_Installed_Base__c capitalEquipment)
    {
        List<H_C_AccountCapitalEquipmentIB__c> newObjects = new List<H_C_AccountCapitalEquipmentIB__c>();
        //create account-capitalEquipment mapping for the current account
        if (String.isNotBlank(capitalEquipment.Account__c))
        {
            newObjects.add(constructMapping(capitalEquipment, capitalEquipment.Account__c));
        }
        
        //create account-capitalEquipment mapping for a parent of the current account
        if (String.isNotBlank(capitalEquipment.Account__r.ParentId))
        {
            newObjects.add(constructMapping(capitalEquipment, capitalEquipment.Account__r.ParentId));
        }
        
        //create account-capitalEquipment mapping for a parent of a parent of the current account
        if (String.isNotBlank(capitalEquipment.Account__r.Parent.ParentId))
        {
            newObjects.add(constructMapping(capitalEquipment, capitalEquipment.Account__r.Parent.ParentId));
        }
        return newObjects;
    }
    
    private static H_C_OperationResults createNewMappings(Capital_Equipment_Installed_Base__c[] capitalEquipments)
    {
    	//if there are no passed objects that nothing can be created
    	if (capitalEquipments == null || capitalEquipments.size() == 0)
    	{
    		//in this case we consider that the method executed successfully, because
    		//there were no any internal errors
    		return new H_C_OperationResults(true);
    	}
    	
    	//construct new mappings
        List<H_C_AccountCapitalEquipmentIB__c> newMappings = new List<H_C_AccountCapitalEquipmentIB__c>();
        for (Capital_Equipment_Installed_Base__c capitalEquipment : capitalEquipments)
        {
            newMappings.addAll(constructMappings(capitalEquipment));
        }
        //insert new mappings (perform 1 DML operation to insert all new mappings)
        return H_C_SoqlUtils.performSafeDmlOperation(H_C_SoqlUtils.DmlOperation.Inserting, newMappings);
    }
    
    private static void processCapitalEquipments_onUpdateAccountLinks(
    	Map<Id, Capital_Equipment_Installed_Base__c> oldCapitalEquipments, Capital_Equipment_Installed_Base__c[] updatedCapitalEquipments)
    {
        //STEP #1: analyze updated capitalEquipments and select only those capitalEquipments
        //which 'AccountId' reference has been changed
        List<String> selectedCapitalEquipmentsIds = new List<String>();
        for (Capital_Equipment_Installed_Base__c updatedCapitalEquipment : updatedCapitalEquipments)
        {
            Capital_Equipment_Installed_Base__c oldCapitalEquipment = oldCapitalEquipments.get(updatedCapitalEquipment.Id);
            if (updatedCapitalEquipment.Account__c != oldCapitalEquipment.Account__c)
            {
                selectedCapitalEquipmentsIds.add(updatedCapitalEquipment.Id);
            }
        }
        //if there are no capitalEquipments which are interesting for this method then we stop it
        if (selectedCapitalEquipmentsIds.size() == 0)
        {
        	return;
        }
        
        //STEP #2: manage existing mappings
        //we should get and delete all existing mappings for updated capitalEquipments,
        //because they are not actual now
        H_C_AccountCapitalEquipmentIB__c[] existingMappings =
        	H_C_AccountCapitalEquipmentIBUtils.getObjectsByCapitalEquipmentsIds(selectedCapitalEquipmentsIds);
        //perform 1 DML operation to delete all new mappings
        H_C_SoqlUtils.tryPerformDmlOperation(H_C_SoqlUtils.DmlOperation.Deleting, existingMappings);
        
        //STEP #3: manage new mappings
        //reread the selected capitalEquipments to include all necessary fields
        Capital_Equipment_Installed_Base__c[] selectedCapitalEquipments = getCapitalEquipmentsByIds(selectedCapitalEquipmentsIds);
        //generate and insert new mappings
        createNewMappings(selectedCapitalEquipments);
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
            //get all existing mappings for capitalEquipments of source accounts and delete them
            H_C_AccountCapitalEquipmentIB__c[] existingMappings =
                H_C_AccountCapitalEquipmentIBUtils.getObjectsByCapitalEquipmentAccountsIds(accountsIds);
            //try to safely delete existing mappings and save intermediate results
            //into the final results
            results = H_C_SoqlUtils.performSafeDmlOperation(
            	H_C_SoqlUtils.DmlOperation.Deleting, existingMappings);
            
            //we can continue only if there were no errors during the previous steps 
            if (results.isOperationSuccessful)
            {
	            //get all capitalEquipments for source accounts and create new mappings for them
	            Capital_Equipment_Installed_Base__c[] accountCapitalEquipments = getCapitalEquipmentsByAccountsIds(accountsIds);
	            //try to generate and insert new mappings, and update the final results
	            results = createNewMappings(accountCapitalEquipments);
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
    
    public static void manageMappings_onCapitalEquipmentsInserted(Capital_Equipment_Installed_Base__c[] insertedCapitalEquipments)
    {
        //check the input parameter
        if (insertedCapitalEquipments == null || insertedCapitalEquipments.size() == 0)
        {
            return;
        }
        
        //STEP #1: reread the capitalEquipments to include all necessary fields
        String[] insertedCapitalEquipmentsIds = extractCapitalEquipmentsIds(insertedCapitalEquipments);
        insertedCapitalEquipments = getCapitalEquipmentsByIds(insertedCapitalEquipmentsIds);
        
        //STEP #2: create and insert new mappings
        createNewMappings(insertedCapitalEquipments);
    }
    
    public static void manageMappings_onCapitalEquipmentsUpdated(
    	Map<Id, Capital_Equipment_Installed_Base__c> oldCapitalEquipments, Map<Id, Capital_Equipment_Installed_Base__c> updatedCapitalEquipments)
    {
        //check input parameters
        if (oldCapitalEquipments == null || updatedCapitalEquipments == null)
        {
            return;
        }
        
        //STEP #1: manage mappings for capitalEquipments which 'Account' references have been changed
        processCapitalEquipments_onUpdateAccountLinks(oldCapitalEquipments, updatedCapitalEquipments.values());
        
        //#WARNING: this call should be parameterized, because some objects have 'auto number' Name
        //which can't be changed (like, Capital_Equipment_Installed_Base__c). In this case, it's useless to check changes
        //in name
        //STEP #2 (the name of 'Capital_Equipment_Installed_Base__c' object can't be changed):
        //manage mappings for capitalEquipments which names have been changed
        //processCapitalEquipments_onUpdateNames(oldCapitalEquipments, updatedCapitalEquipments);
    }
    //
    
    
    //
	//This code is used to provide access to 'H_C_AccountCapitalEquipmentIB__c' object
	//(it has been implemented in a separate class, but was moved here to simplify
	//the procedure of creation of new mappings)
    //
    //Variables and constants
    //
    private static String BASIC_FIELDS = 'Id, Name, Account__c, CapitalEquipmentInstalledBase__c';
    private static String OBJECT_NAME = 'H_C_AccountCapitalEquipmentIB__c';
    //
    
    //
    //Public static methods
    //
    private static H_C_AccountCapitalEquipmentIB__c[] getObjectsByIds(String[] objectsIds)
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
    
    private static H_C_AccountCapitalEquipmentIB__c[] getObjectsByAccountsIds(String[] accountsIds)
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
    
    //this method returns all mappings which contain capitalEquipment that belong to the passed accounts
    //(for example, if we pass only one account Id, then this method returns all mappings which
    //contain capitalEquipments of that account)
    private static H_C_AccountCapitalEquipmentIB__c[] getObjectsByCapitalEquipmentAccountsIds(String[] accountsIds)
    {
        String stringOfAccountsIds = H_C_SoqlUtils.joinStringsForINSection(accountsIds);
        if (String.isBlank(stringOfAccountsIds))
        {
            return null;
        }
        
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        queryBuilder.condition = 'CapitalEquipmentInstalledBase__r.Account__c IN (' + stringOfAccountsIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    
    private static H_C_AccountCapitalEquipmentIB__c[] getObjectsByCapitalEquipmentsIds(String[] shipmentsIds)
    {
        //join Ids and check the string
        String stringOfCapitalEquipmentsIds = H_C_SoqlUtils.joinStringsForINSection(shipmentsIds);
        if (String.isBlank(stringOfCapitalEquipmentsIds))
        {
            return null;
        }
        
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        queryBuilder.condition = 'CapitalEquipmentInstalledBase__c IN (' + stringOfCapitalEquipmentsIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    //


	//CapitalEquipmentDAO Section
	//
	//This Section provides access to 'Capital_Equipment_Installed_Base__c' object
	//
	//Author: CERVELLO INC - Anil Tumati / Sergey Trusov (27-02-2014)

    //
    //Variables and constants
    //
    private static String BASIC_FIELDS_2 = 'Id, Name, Account__c, '
    	+ 'Account__r.ParentId, Account__r.Parent.ParentId';
    private static String OBJECT_NAME_2 = 'Capital_Equipment_Installed_Base__c';
    //
    
    //
    //Public static methods
    //
    private static Capital_Equipment_Installed_Base__c[] getCapitalEquipmentsByIds(String[] shipmentsIds)
    {
        //join Ids and check the string
        String stringOfIds = H_C_SoqlUtils.joinStringsForINSection(shipmentsIds);
        if (String.isBlank(stringOfIds))
        {
            return null;
        }
        
        //initialize query builder and perform the query
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS_2, OBJECT_NAME_2);
        queryBuilder.condition = 'Id IN (' + stringOfIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    
    private static Capital_Equipment_Installed_Base__c[] getCapitalEquipmentsByAccountsIds(String[] accountsIds)
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
    
    private static String[] extractCapitalEquipmentsIds(Capital_Equipment_Installed_Base__c[] capitalEquipments)
    {
        if (capitalEquipments == null)
        {
            return null;
        }
        
        Set<String> setOfCapitalEquipmentsIds = new Set<String>();
        for (Capital_Equipment_Installed_Base__c capitalEquipment : capitalEquipments)
        {
            if (String.isNotBlank(capitalEquipment.Id))
            {
                setOfCapitalEquipmentsIds.add(capitalEquipment.Id);
            }
        }
        
        List<String> listOfCapitalEquipmentsIds = new List<String>();
        listOfCapitalEquipmentsIds.addAll(setOfCapitalEquipmentsIds);
        return listOfCapitalEquipmentsIds;
    }
    //
}