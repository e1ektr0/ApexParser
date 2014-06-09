//
//This class provides utilities for working with 'H_C_AccountContact__c' object 
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (22-05-2013)
public without sharing class H_C_AccountContactUtils
{
    //
    //Private static methods
    //
    private static H_C_AccountContact__c constructMapping(
        Contact contact, String accountId)
    {
        H_C_AccountContact__c newMapping = new H_C_AccountContact__c();
        newMapping.Account__c = accountId;
        newMapping.Contact__c = contact.Id;
        newMapping.Name = contact.Name;
        return newMapping;
    }

    private static H_C_AccountContact__c[] constructMappings(Contact contact)
    {
        List<H_C_AccountContact__c> newObjects = new List<H_C_AccountContact__c>();
        //create account-contact mapping for the current account
        if (String.isNotBlank(contact.AccountId))
        {
            newObjects.add(constructMapping(contact, contact.AccountId));
        }
        
        //create account-contact mapping for a parent of the current account
        if (String.isNotBlank(contact.Account.ParentId))
        {
            newObjects.add(constructMapping(contact, contact.Account.ParentId));
        }
        
        //create account-contact mapping for a parent of a parent of the current account
        if (String.isNotBlank(contact.Account.Parent.ParentId))
        {
            newObjects.add(constructMapping(contact, contact.Account.Parent.ParentId));
        }
        return newObjects;
    }
    
    private static H_C_OperationResults createNewMappings(Contact[] contacts)
    {
    	//if there are no passed objects that nothing can be created 
    	if (contacts == null || contacts.size() == 0)
    	{
    		//in this case we consider that the method executed successfully, because
    		//there were no any internal errors
    		return new H_C_OperationResults(true);
    	}
    	
    	//construct new mappings
        List<H_C_AccountContact__c> newMappings = new List<H_C_AccountContact__c>();
        for (Contact contact : contacts)
        {
            newMappings.addAll(constructMappings(contact));
        }
        //insert new mappings (perform 1 DML operation to insert all new mappings)
        return H_C_SoqlUtils.performSafeDmlOperation(H_C_SoqlUtils.DmlOperation.Inserting, newMappings);
    }
    
    private static void processContacts_onUpdateAccountLinks(
    	Map<Id, Contact> oldContacts, Contact[] updatedContacts)
    {
        //STEP #1: analyze updated contacts and select only those contacts
        //which 'AccountId' reference has been changed
        List<String> selectedContactsIds = new List<String>();
        for (Contact updatedContact : updatedContacts)
        {
            Contact oldContact = oldContacts.get(updatedContact.Id);
            if (updatedContact.AccountId != oldContact.AccountId)
            {
                selectedContactsIds.add(updatedContact.Id);
            }
        }
        //if there are no contacts which are interesting for this method then we stop it
        if (selectedContactsIds.size() == 0)
        {
        	return;
        }
        
        //STEP #2: manage existing mappings
        //we should get and delete all existing mappings for updated contacts,
        //because they are not actual now
        H_C_AccountContact__c[] existingMappings =
        	H_C_AccountContactUtils.getObjectsByContactsIds(selectedContactsIds);
        //perform 1 DML operation to delete all new mappings
        H_C_SoqlUtils.tryPerformDmlOperation(H_C_SoqlUtils.DmlOperation.Deleting, existingMappings);
        
        //STEP #3: manage new mappings
        //reread the selected contacts to include all necessary fields
        Contact[] selectedContacts = getContactsByIds(selectedContactsIds);
        //generate and insert new mappings
        createNewMappings(selectedContacts);
    }
    
    private static void processContacts_onUpdateNames(
    	Map<Id, Contact> oldContacts, Map<Id, Contact> updatedContacts)
    {
        //STEP #1: analyze updated contacts and select only those contacts
        //which 'Name' field has been changed
        List<String> selectedContactsIds = new List<String>();
        for (Contact updatedContact : updatedContacts.values())
        {
            Contact oldContact = oldContacts.get(updatedContact.Id);
            //#WARNING: this condition should be parameterized
            if (updatedContact.FirstName != oldContact.FirstName
            	|| updatedContact.LastName != oldContact.LastName)
            {
                selectedContactsIds.add(updatedContact.Id);
            }
        }
        //if there are no contacts which are interesting for this method then we stop it
        if (selectedContactsIds.size() == 0)
        {
        	return;
        }
        
        //STEP #2: manage existing mappings
        //we should update names of existing mappings according to current names
        //of corresponding contacts
        H_C_AccountContact__c[] existingMappings =
        	H_C_AccountContactUtils.getObjectsByContactsIds(selectedContactsIds);
        if (existingMappings.size() > 0)
        {
        	//#WARNING: reread mechanism should be parameterized, because only few standard objects
        	//have formula for 'Name' field (if it's simple text field then we shouldn't reread objects again)
        	//we should reread updated contacts here to get correct values in 'Name' field, because
        	//this field is calculated via the formula (this field is not filled in trigger variables)
        	Contact[] selectedUpdatedContacts = getContactsByIds(selectedContactsIds);
        	//create map contacts which were reread from the DB
        	Map<Id, Contact> mapOfSelectedUpdatedContacts = new Map<Id, Contact>(selectedUpdatedContacts);
        	
        	//update name of an every service mapping according to its real object
	        for (H_C_AccountContact__c mapping : existingMappings)
	        {
	        	Contact relatedContact = mapOfSelectedUpdatedContacts.get(mapping.Contact__c);
	        	mapping.Name = relatedContact.Name;
	        }
        }
        
        //perform 1 DML operation to save the changes
        H_C_SoqlUtils.tryPerformDmlOperation(H_C_SoqlUtils.DmlOperation.Updating, existingMappings);
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
        	//get all existing mappings for contacts of source accounts and delete them
            H_C_AccountContact__c[] existingMappings =
            	getObjectsByContactAccountsIds(accountsIds);
            //try to safely delete existing mappings and save intermediate results
            //into the final results
            results = H_C_SoqlUtils.performSafeDmlOperation(
            	H_C_SoqlUtils.DmlOperation.Deleting, existingMappings);
            
            //we can continue only if there were no errors during the previous steps 
            if (results.isOperationSuccessful)
            {
	            //get all contacts for source accounts and create new mappings for them
            	Contact[] accountContacts = getContactsByAccountsIds(accountsIds);
	            //try to generate and insert new mappings, and update the final results
	            results = createNewMappings(accountContacts);
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
    
    public static void manageMappings_onContactsInserted(Contact[] insertedContacts)
    {
        //check the input parameter
        if (insertedContacts == null || insertedContacts.size() == 0)
        {
            return;
        }
        
        //STEP #1: reread the contacts to include all necessary fields
        String[] insertedContactsIds = extractContactsIds(insertedContacts);
        insertedContacts = getContactsByIds(insertedContactsIds);
        
        //STEP #2: create and insert new mappings
        createNewMappings(insertedContacts);
    }
    
    public static void manageMappings_onContactsUpdated(
    	Map<Id, Contact> oldContacts, Map<Id, Contact> updatedContacts)
    {
        //check input parameters
        if (oldContacts == null || updatedContacts == null)
        {
            return;
        }
        
        //STEP #1: manage mappings for contacts which 'Account' references have been changed
        processContacts_onUpdateAccountLinks(oldContacts, updatedContacts.values());
        //STEP #2: manage mappings for contacts which names have been changed
        processContacts_onUpdateNames(oldContacts, updatedContacts);
    }
    //
    
    
    //
	//This code is used to provides access to 'H_C_AccountContact__c' object
	//(it has been implemented in a separate class, but was moved here to simplify
	//the procedure of creation of new mappings)
    //
    //Variables and constants
    //
    private static String BASIC_FIELDS = 'Id, Name, Account__c, Contact__c';
    private static String OBJECT_NAME = 'H_C_AccountContact__c';
    //
    
    //
    //Public static methods
    //
    private static H_C_AccountContact__c[] getObjectsByIds(String[] objectsIds)
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
    
    private static H_C_AccountContact__c[] getObjectsByAccountsIds(String[] accountsIds)
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
    
    //this method returns all mappings which contain contact that belong to the passed accounts
    //(for example, if we pass only one account Id, then this method returns all mappings which
    //contain contacts of that account)
    private static H_C_AccountContact__c[] getObjectsByContactAccountsIds(String[] accountsIds)
    {
        String stringOfAccountsIds = H_C_SoqlUtils.joinStringsForINSection(accountsIds);
        if (String.isBlank(stringOfAccountsIds))
        {
            return null;
        }
        
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        queryBuilder.condition = 'Contact__r.AccountId IN (' + stringOfAccountsIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    
    private static H_C_AccountContact__c[] getObjectsByContactsIds(String[] contactsIds)
    {
        //join Ids and check the string
        String stringOfContactsIds = H_C_SoqlUtils.joinStringsForINSection(contactsIds);
        if (String.isBlank(stringOfContactsIds))
        {
            return null;
        }
        
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        queryBuilder.condition = 'Contact__c IN (' + stringOfContactsIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    //


	//ContactDAO Section
	//
	//This Section provides access to 'Contact' object
	//
	//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (15-05-2013)

    //
    //Variables and constants
    //
    private static String BASIC_FIELDS_2 = 'Id, Name, AccountId, Account.ParentId, Account.Parent.ParentId';
    private static String OBJECT_NAME_2 = 'Contact';
    //
    
    //
    //Public static methods
    //
    private static Contact[] getContactsByIds(String[] contactsIds)
    {
        //join Ids and check the string
        String stringOfIds = H_C_SoqlUtils.joinStringsForINSection(contactsIds);
        if (String.isBlank(stringOfIds))
        {
            return null;
        }
        
        //initialize query builder and perform the query
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS_2, OBJECT_NAME_2);
        queryBuilder.condition = 'Id IN (' + stringOfIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    
    private static Contact[] getContactsByAccountsIds(String[] accountsIds)
    {
        String stringOfAccountsIds = H_C_SoqlUtils.joinStringsForINSection(accountsIds);
        if (String.isBlank(stringOfAccountsIds))
        {
            return null;
        }
        
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS_2, OBJECT_NAME_2);
        queryBuilder.condition = 'AccountId IN (' + stringOfAccountsIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    
    private static String[] extractContactsIds(Contact[] contacts)
    {
        if (contacts == null)
        {
            return null;
        }
        
        Set<String> setOfContactsIds = new Set<String>();
        for (Contact contact : contacts)
        {
            if (String.isNotBlank(contact.Id))
            {
                setOfContactsIds.add(contact.Id);
            }
        }
        
        List<String> listOfContactsIds = new List<String>();
        listOfContactsIds.addAll(setOfContactsIds);
        return listOfContactsIds;
    }
    //
}