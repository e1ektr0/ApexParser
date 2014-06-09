//
//This class provides utilities for working with 'H_C_AccountContract__c' object 
//
//Author: CERVELLO INC - Anil Tumati / Sergey Trusov (27-02-2014)
public without sharing class H_C_AccountContractUtils
{
    //
    //Private static methods
    //
    private static H_C_AccountContract__c constructMapping(
        Contract contract, String accountId)
    {
        H_C_AccountContract__c newMapping = new H_C_AccountContract__c();
        newMapping.Account__c = accountId;
        newMapping.Contract__c = contract.Id;
        newMapping.Name = contract.Name;
        return newMapping;
    }

    private static H_C_AccountContract__c[] constructMappings(Contract contract)
    {
        List<H_C_AccountContract__c> newObjects = new List<H_C_AccountContract__c>();
        //create account-contract mapping for the current account
        if (String.isNotBlank(contract.AccountId))
        {
            newObjects.add(constructMapping(contract, contract.AccountId));
        }
        
        //create account-contract mapping for a parent of the current account
        if (String.isNotBlank(contract.Account.ParentId))
        {
            newObjects.add(constructMapping(contract, contract.Account.ParentId));
        }
        
        //create account-contract mapping for a parent of a parent of the current account
        if (String.isNotBlank(contract.Account.Parent.ParentId))
        {
            newObjects.add(constructMapping(contract, contract.Account.Parent.ParentId));
        }
        return newObjects;
    }
    
    private static H_C_OperationResults createNewMappings(Contract[] contracts)
    {
    	//if there are no passed objects that nothing can be created 
    	if (contracts == null || contracts.size() == 0)
    	{
    		//in this case we consider that the method executed successfully, because
    		//there were no any internal errors
    		return new H_C_OperationResults(true);
    	}
    	
    	//construct new mappings
        List<H_C_AccountContract__c> newMappings = new List<H_C_AccountContract__c>();
        for (Contract contract : contracts)
        {
            newMappings.addAll(constructMappings(contract));
        }
        //insert new mappings (perform 1 DML operation to insert all new mappings)
        return H_C_SoqlUtils.performSafeDmlOperation(H_C_SoqlUtils.DmlOperation.Inserting, newMappings);
    }
    
    private static void processContracts_onUpdateAccountLinks(
    	Map<Id, Contract> oldContracts, Contract[] updatedContracts)
    {
        //STEP #1: analyze updated contracts and select only those contracts
        //which 'AccountId' reference has been changed
        List<String> selectedContractsIds = new List<String>();
        for (Contract updatedContract : updatedContracts)
        {
            Contract oldContract = oldContracts.get(updatedContract.Id);
            if (updatedContract.AccountId != oldContract.AccountId)
            {
                selectedContractsIds.add(updatedContract.Id);
            }
        }
        //if there are no contracts which are interesting for this method then we stop it
        if (selectedContractsIds.size() == 0)
        {
        	return;
        }
        
        //STEP #2: manage existing mappings
        //we should get and delete all existing mappings for updated contracts,
        //because they are not actual now
        H_C_AccountContract__c[] existingMappings =
        	H_C_AccountContractUtils.getObjectsByContractsIds(selectedContractsIds);
        //perform 1 DML operation to delete all new mappings
        H_C_SoqlUtils.tryPerformDmlOperation(H_C_SoqlUtils.DmlOperation.Deleting, existingMappings);
        
        //STEP #3: manage new mappings
        //reread the selected contracts to include all necessary fields
        Contract[] selectedContracts = getContractsByIds(selectedContractsIds);
        //generate and insert new mappings
        createNewMappings(selectedContracts);
    }
    
    private static void processContracts_onUpdateNames(
    	Map<Id, Contract> oldContracts, Map<Id, Contract> updatedContracts)
    {
        //STEP #1: analyze updated contracts and select only those contracts
        //which 'Name' field has been changed
        List<String> selectedContractsIds = new List<String>();
        for (Contract updatedContract : updatedContracts.values())
        {
            Contract oldContract = oldContracts.get(updatedContract.Id);
            //#WARNING: this condition should be parameterized
            if (updatedContract.Name != oldContract.Name)
            {
                selectedContractsIds.add(updatedContract.Id);
            }
        }
        //if there are no contracts which are interesting for this method then we stop it
        if (selectedContractsIds.size() == 0)
        {
        	return;
        }
        
        //STEP #2: manage existing mappings
        //we should update names of existing mappings according to current names
        //of corresponding opportunities
        H_C_AccountContract__c[] existingMappings =
        	getObjectsByContractsIds(selectedContractsIds);
        for (H_C_AccountContract__c mapping : existingMappings)
        {
        	String newName = updatedContracts.get(mapping.Contract__c).Name;
        	mapping.Name = newName;
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
        	//get all existing mappings for contracts of source accounts and delete them
            H_C_AccountContract__c[] existingMappings =
            	getObjectsByContractAccountsIds(accountsIds);
            //try to safely delete existing mappings and save intermediate results
            //into the final results
            results = H_C_SoqlUtils.performSafeDmlOperation(
            	H_C_SoqlUtils.DmlOperation.Deleting, existingMappings);
            
            //we can continue only if there were no errors during the previous steps 
            if (results.isOperationSuccessful)
            {
	            //get all contracts for source accounts and create new mappings for them
            	Contract[] accountContracts = getContractsByAccountsIds(accountsIds);
	            //try to generate and insert new mappings, and update the final results
	            results = createNewMappings(accountContracts);
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
    
    public static void manageMappings_onContractsInserted(Contract[] insertedContracts)
    {
        //check the input parameter
        if (insertedContracts == null || insertedContracts.size() == 0)
        {
            return;
        }
        
        //STEP #1: reread the contracts to include all necessary fields
        String[] insertedContractsIds = extractContractsIds(insertedContracts);
        insertedContracts = getContractsByIds(insertedContractsIds);
        
        //STEP #2: create and insert new mappings
        createNewMappings(insertedContracts);
    }
    
    public static void manageMappings_onContractsUpdated(
    	Map<Id, Contract> oldContracts, Map<Id, Contract> updatedContracts)
    {
        //check input parameters
        if (oldContracts == null || updatedContracts == null)
        {
            return;
        }
        
        //STEP #1: manage mappings for contracts which 'Account' references have been changed
        processContracts_onUpdateAccountLinks(oldContracts, updatedContracts.values());
        //STEP #2: manage mappings for contracts which names have been changed
        processContracts_onUpdateNames(oldContracts, updatedContracts);
    }
    //
    
    
    //
	//This code is used to provides access to 'H_C_AccountContract__c' object
	//(it has been implemented in a separate class, but was moved here to simplify
	//the procedure of creation of new mappings)
    //
    //Variables and constants
    //
    private static String BASIC_FIELDS = 'Id, Name, Account__c, Contract__c';
    private static String OBJECT_NAME = 'H_C_AccountContract__c';
    //
    
    //
    //Public static methods
    //
    private static H_C_AccountContract__c[] getObjectsByIds(String[] objectsIds)
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
    
    private static H_C_AccountContract__c[] getObjectsByAccountsIds(String[] accountsIds)
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
    
    //this method returns all mappings which contain contract that belong to the passed accounts
    //(for example, if we pass only one account Id, then this method returns all mappings which
    //contain contracts of that account)
    private static H_C_AccountContract__c[] getObjectsByContractAccountsIds(String[] accountsIds)
    {
        String stringOfAccountsIds = H_C_SoqlUtils.joinStringsForINSection(accountsIds);
        if (String.isBlank(stringOfAccountsIds))
        {
            return null;
        }
        
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        queryBuilder.condition = 'Contract__r.AccountId IN (' + stringOfAccountsIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    
    private static H_C_AccountContract__c[] getObjectsByContractsIds(String[] contactsIds)
    {
        //join Ids and check the string
        String stringOfContractsIds = H_C_SoqlUtils.joinStringsForINSection(contactsIds);
        if (String.isBlank(stringOfContractsIds))
        {
            return null;
        }
        
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        queryBuilder.condition = 'Contract__c IN (' + stringOfContractsIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    //


	//ContractDAO Section
	//
	//This Section provides access to 'Contract' object
	//
	//Author: CERVELLO INC - Anil Tumati / Sergey Trusov (27-02-2014)

    //
    //Variables and constants
    //
    private static String BASIC_FIELDS_2 = 'Id, Name, AccountId, Account.ParentId, Account.Parent.ParentId';
    private static String OBJECT_NAME_2 = 'Contract';
    //
    
    //
    //Public static methods
    //
    private static Contract[] getContractsByIds(String[] contactsIds)
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
    
    private static Contract[] getContractsByAccountsIds(String[] accountsIds)
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
    
    private static String[] extractContractsIds(Contract[] contracts)
    {
        if (contracts == null)
        {
            return null;
        }
        
        Set<String> setOfContractsIds = new Set<String>();
        for (Contract contract : contracts)
        {
            if (String.isNotBlank(contract.Id))
            {
                setOfContractsIds.add(contract.Id);
            }
        }
        
        List<String> listOfContractsIds = new List<String>();
        listOfContractsIds.addAll(setOfContractsIds);
        return listOfContractsIds;
    }
    //
}