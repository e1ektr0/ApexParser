//
//This class provides utilities for working with 'H_C_AccountOpportunity__c' object 
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (15-05-2013)
public without sharing class H_C_AccountOpportunityUtils
{
    //
    //Private static methods
    //
    private static H_C_AccountOpportunity__c constructMapping(
        Opportunity opportunity, String accountId)
    {
        H_C_AccountOpportunity__c newMapping = new H_C_AccountOpportunity__c();
        newMapping.Account__c = accountId;
        newMapping.Opportunity__c = opportunity.Id;
        newMapping.Name = opportunity.Name;
        return newMapping;
    }

    private static H_C_AccountOpportunity__c[] constructMappings(Opportunity opportunity)
    {
        List<H_C_AccountOpportunity__c> newObjects = new List<H_C_AccountOpportunity__c>();
        //create account-opportunity mapping for the current account
        if (String.isNotBlank(opportunity.AccountId))
        {
            newObjects.add(constructMapping(opportunity, opportunity.AccountId));
        }
        
        //create account-opportunity mapping for a parent of the current account
        if (String.isNotBlank(opportunity.Account.ParentId))
        {
            newObjects.add(constructMapping(opportunity, opportunity.Account.ParentId));
        }
        
        //create account-opportunity mapping for a parent of a parent of the current account
        if (String.isNotBlank(opportunity.Account.Parent.ParentId))
        {
            newObjects.add(constructMapping(opportunity, opportunity.Account.Parent.ParentId));
        }
        return newObjects;
    }
    
    private static H_C_OperationResults createNewMappings(Opportunity[] opportunities)
    {
    	//if there are no passed objects that nothing can be created
    	if (opportunities == null || opportunities.size() == 0)
    	{
    		//in this case we consider that the method executed successfully, because
    		//there cannot be any internal errors
    		return new H_C_OperationResults(true);
    	}
    	
    	//construct new mappings
        List<H_C_AccountOpportunity__c> newMappings = new List<H_C_AccountOpportunity__c>();
        for (Opportunity opportunity : opportunities)
        {
            newMappings.addAll(constructMappings(opportunity));
        }
        //insert new mappings (perform 1 DML operation to insert all new mappings)
        return H_C_SoqlUtils.performSafeDmlOperation(H_C_SoqlUtils.DmlOperation.Inserting, newMappings);
    }
    
    private static void processOpportunities_onUpdateAccountLinks(
    	Map<Id, Opportunity> oldOpportunities, Opportunity[] updatedOpportunities)
    {
        //STEP #1: analyze updated opportunities and select only those opportunities
        //which 'AccountId' reference has been changed
        List<String> selectedOpportunitiesIds = new List<String>();
        for (Opportunity updatedOpportunity : updatedOpportunities)
        {
            Opportunity oldOpportunity = oldOpportunities.get(updatedOpportunity.Id);
            if (updatedOpportunity.AccountId != oldOpportunity.AccountId)
            {
                selectedOpportunitiesIds.add(updatedOpportunity.Id);
            }
        }
        //if there are no opportunities which are interesting for this method then we stop it
        if (selectedOpportunitiesIds.size() == 0)
        {
        	return;
        }
        
        //STEP #2: manage existing mappings
        //we should get and delete all existing mappings for updated opportunities,
        //because they are not actual now
        H_C_AccountOpportunity__c[] existingMappings =
        	getObjectsByOpportunitiesIds(selectedOpportunitiesIds);
        //perform 1 DML operation to delete all new mappings
        H_C_SoqlUtils.tryPerformDmlOperation(H_C_SoqlUtils.DmlOperation.Deleting, existingMappings);
        
        //STEP #3: manage new mappings
        //reread the selected opportunities to include all necessary fields
        Opportunity[] selectedOpportunities = getOpportunitiesByIds(selectedOpportunitiesIds);
        //generate and insert new mappings
        createNewMappings(selectedOpportunities);
    }
    
    private static void processOpportunities_onUpdateNames(
    	Map<Id, Opportunity> oldOpportunities, Map<Id, Opportunity> updatedOpportunities)
    {
        //STEP #1: analyze updated opportunities and select only those opportunities
        //which 'Name' field has been changed
        List<String> selectedOpportunitiesIds = new List<String>();
        for (Opportunity updatedOpportunity : updatedOpportunities.values())
        {
            Opportunity oldOpportunity = oldOpportunities.get(updatedOpportunity.Id);
            if (updatedOpportunity.Name != oldOpportunity.Name)
            {
                selectedOpportunitiesIds.add(updatedOpportunity.Id);
            }
        }
        //if there are no opportunities which are interesting for this method then we stop it
        if (selectedOpportunitiesIds.size() == 0)
        {
        	return;
        }
        
        //STEP #2: manage existing mappings
        //we should update names of existing mappings according to current names
        //of corresponding opportunities
        H_C_AccountOpportunity__c[] existingMappings =
        	getObjectsByOpportunitiesIds(selectedOpportunitiesIds);
        for (H_C_AccountOpportunity__c mapping : existingMappings)
        {
        	String newName = updatedOpportunities.get(mapping.Opportunity__c).Name;
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
    	//occur then the method will update this object with results
    	H_C_OperationResults results = new H_C_OperationResults(true);
    	
        //if there are no accounts for this method then we can do nothing
        if (accountsIds != null && accountsIds.size() > 0)
        {
            //get all existing mappings for opportunities of source accounts
            H_C_AccountOpportunity__c[] existingMappings =
            	H_C_AccountOpportunityUtils.getObjectsByOpportunityAccountsIds(accountsIds);
            //try to safely delete existing mappings and save intermediate results
            //into the final results
            results = H_C_SoqlUtils.performSafeDmlOperation(
            	H_C_SoqlUtils.DmlOperation.Deleting, existingMappings);
            
            //we can continue only if there were no errors during the previous steps 
            if (results.isOperationSuccessful)
            {
	            //get all opportunities for source accounts and create new mappings for them
	            Opportunity[] accountOpportunities = getOpportunitiesByAccountsIds(accountsIds);
	            //try to generate and insert new mappings, and update the final results
	            results = createNewMappings(accountOpportunities);
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
    
    public static void manageMappings_onOpportunitiesInserted(Opportunity[] insertedOpportunities)
    {
        //check the input parameter
        if (insertedOpportunities == null || insertedOpportunities.size() == 0)
        {
            return;
        }
        
        //STEP #1: reread the opportunities to include all necessary fields
        String[] insertedOpportunitiesIds = extractOpportunitiesIds(insertedOpportunities);
        insertedOpportunities = getOpportunitiesByIds(insertedOpportunitiesIds);
        
        //STEP #2: create and insert new mappings
        createNewMappings(insertedOpportunities);
    }
    
    public static void manageMappings_onOpportunitiesUpdated(
    	Map<Id, Opportunity> oldOpportunities, Map<Id, Opportunity> updatedOpportunities)
    {
        //check input parameters
        if (oldOpportunities == null || updatedOpportunities == null)
        {
            return;
        }
        
        //STEP #1: manage mappings for opportunities which 'Account' references have been changed
        processOpportunities_onUpdateAccountLinks(oldOpportunities, updatedOpportunities.values());
        //STEP #2: manage mappings for opportunities which names have been changed
        processOpportunities_onUpdateNames(oldOpportunities, updatedOpportunities);
    }
    //
    
    
    //
	//This code is used to provide access to 'H_C_AccountOpportunity__c' object
	//(it has been implemented in a separate class, but was moved here to simplify
	//the procedure of creation of new mappings)
    //
    //Variables and constants
    //
    private static String BASIC_FIELDS = 'Id, Name, Account__c, Opportunity__c';
    private static String OBJECT_NAME = 'H_C_AccountOpportunity__c';
    //
    
    //
    //Public static methods
    //
    public static H_C_AccountOpportunity__c[] getObjectsByIds(String[] objectsIds)
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
    
    public static H_C_AccountOpportunity__c[] getObjectsByAccountsIds(String[] accountsIds)
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
    
    //this method returns all mappings which contain opportunity that belong to the passed accounts
    //(for example, if we pass only one account Id, then this method returns all mappings which
    //contain opportunities of that account)
    public static H_C_AccountOpportunity__c[] getObjectsByOpportunityAccountsIds(String[] accountsIds)
    {
        String stringOfAccountsIds = H_C_SoqlUtils.joinStringsForINSection(accountsIds);
        if (String.isBlank(stringOfAccountsIds))
        {
            return null;
        }
        
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        queryBuilder.condition = 'Opportunity__r.AccountId IN (' + stringOfAccountsIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    
    public static H_C_AccountOpportunity__c[] getObjectsByOpportunitiesIds(String[] opportunitiesIds)
    {
        //join Ids and check the string
        String stringOfOpportunitiesIds = H_C_SoqlUtils.joinStringsForINSection(opportunitiesIds);
        if (String.isBlank(stringOfOpportunitiesIds))
        {
            return null;
        }
        
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        queryBuilder.condition = 'Opportunity__c IN (' + stringOfOpportunitiesIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
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
        System.assertEquals(true, createNewMappings(new Opportunity[0]).isOperationSuccessful);
    }
    
    @IsTest
    private static void test_manageMappingsForAccounts()
    {
        // WRONG AND EMPTY PARAMETERS
        manageMappingsForAccounts(null);
        manageMappingsForAccounts(new String[0]);
        
        // CORRECT PARAMETERS
        //disable all triggers to test the logic separately from them
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        //create accounts
        Account account1 = H_C_UnitTestUtils.createAccount('Contract Account1');
        account1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
        account1.ParentId = null;
            
        Account account2 = H_C_UnitTestUtils.createAccount('Key Region Account1');
        account2.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        account2.ParentId = account1.Id;
        
        Account account3 = H_C_UnitTestUtils.createAccount('Transactional Account1');
        account3.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        account3.ParentId = account2.Id;
        
        Account account4 = H_C_UnitTestUtils.createAccount('Contract Account2');
        account4.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
        
        Account[] accounts = new Account[] {account1, account2, account3, account4};
        String[] accountsIds = new String[] {account1.Id, account2.Id, account3.Id};
        update accounts;
        
        //create opportunities
        Opportunity opportunity1 = H_C_UnitTestUtils.createOpportunity('Opportunity1', account2.Id);
        Opportunity opportunity2 = H_C_UnitTestUtils.createOpportunity('Opportunity2', account2.Id);
        
        //create 'H_C_AccountOpportunity__c' mapping for opportunity1 and account 4 to
        //similate deprecated relationship between account2 and account4
        H_C_AccountOpportunity__c mapping1 =
            H_C_UnitTestUtils.createAccountOpportunityMapping(account4, opportunity1);
        //create 'H_C_AccountOpportunity__c' mapping for opportunity2 and account 4 to
        //similate deprecated relationship between account3 and account4
        H_C_AccountOpportunity__c mapping2 =
            H_C_UnitTestUtils.createAccountOpportunityMapping(account4, opportunity2);
        
        //perform the method
        manageMappingsForAccounts(accountsIds);
        
        //check the results
        //check mappings for the 1st account
        H_C_AccountOpportunity__c[] mappings =
            H_C_AccountOpportunityUtils.getObjectsByAccountsIds(new String[] {account1.Id});
        System.assertEquals(2, mappings.size());
        System.assert(opportunity1.Id == mappings[0].Opportunity__c && opportunity2.Id == mappings[1].Opportunity__c
            || opportunity2.Id == mappings[0].Opportunity__c && opportunity1.Id == mappings[1].Opportunity__c);
        
        //check mappings for the 2nd account
        mappings = H_C_AccountOpportunityUtils.getObjectsByAccountsIds(new String[] {account2.Id});
        System.assertEquals(2, mappings.size());
        System.assert(opportunity1.Id == mappings[0].Opportunity__c && opportunity2.Id == mappings[1].Opportunity__c
            || opportunity2.Id == mappings[0].Opportunity__c && opportunity1.Id == mappings[1].Opportunity__c);
        
        //check mappings for the 3rd account
        mappings = H_C_AccountOpportunityUtils.getObjectsByAccountsIds(new String[] {account3.Id});
        System.assertEquals(0, mappings.size());
        //System.assert(opportunity2.Id == mappings[0].Opportunity__c);
        
        //check that initial mappings don't exist anymore (they became irrelevant now)
        System.assertEquals(0, H_C_AccountOpportunityUtils.getObjectsByIds(
            new String[] {mapping1.Id, mapping2.Id}).size());
    }
    
    @IsTest
    private static void test_manageMappings_onAccountsUpdated()
    {
        // WRONG AND EMPTY PARAMETERS
        manageMappings_onAccountsUpdated(null, null);
        manageMappings_onAccountsUpdated(new Map<Id, Account>(), new Account[0]);
        
        // CORRECT PARAMETERS
        //disable all triggers to test the logic separately from them
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        //create accounts
        Account account1 = H_C_UnitTestUtils.createAccount('Contract Account1');
        account1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
            
        Account account2 = H_C_UnitTestUtils.createAccount('Key Region Account1');
        account2.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        account2.ParentId = account1.Id;
        
        Account account3 = H_C_UnitTestUtils.createAccount('Transactional Account1');
        account3.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        account3.ParentId = account2.Id;
        
        update new Account[] {account1, account2, account3};
        
        //create opportunities
        Opportunity opportunity1 = H_C_UnitTestUtils.createOpportunity('Opportunity1', account2.Id);
        Opportunity opportunity2 = H_C_UnitTestUtils.createOpportunity('Opportunity2', account2.Id);
        
        //simulate updated accounts
        List<Account> updatedAccounts = new Account[] {account2, account3};
        //simulate old accounts
        Account oldAccount2 = account2.clone(true);
        oldAccount2.ParentId = null;
        Account oldAccount3 = account3.clone(true);
        oldAccount3.ParentId = null;
        Map<Id, Account> oldAccounts = new Map<Id, Account>(new Account[] {oldAccount2, oldAccount3});
        
        //perform the method
        manageMappings_onAccountsUpdated(oldAccounts, updatedAccounts);
        
        //check the results
        //check mappings for the 1st account
        H_C_AccountOpportunity__c[] mappings =
            H_C_AccountOpportunityUtils.getObjectsByAccountsIds(new String[] {account1.Id});
        System.assertEquals(2, mappings.size());
        System.assert(opportunity1.Id == mappings[0].Opportunity__c && opportunity2.Id == mappings[1].Opportunity__c
            || opportunity2.Id == mappings[0].Opportunity__c && opportunity1.Id == mappings[1].Opportunity__c);
        
        //check mappings for the 2nd account
        mappings = H_C_AccountOpportunityUtils.getObjectsByAccountsIds(new String[] {account2.Id});
        System.assertEquals(2, mappings.size());
        System.assert(opportunity1.Id == mappings[0].Opportunity__c && opportunity2.Id == mappings[1].Opportunity__c
            || opportunity2.Id == mappings[0].Opportunity__c && opportunity1.Id == mappings[1].Opportunity__c);
        
        //check mappings for the 3rd account
        mappings = H_C_AccountOpportunityUtils.getObjectsByAccountsIds(new String[] {account3.Id});
        System.assertEquals(0, mappings.size());
        //System.assert(opportunity2.Id == mappings[0].Opportunity__c);
    }
    
    @IsTest
    private static void test_manageMappings_onOpportunitiesInserted()
    {
        // WRONG AND EMPTY PARAMETERS
        manageMappings_onOpportunitiesInserted(null);
        manageMappings_onOpportunitiesInserted(new Opportunity[0]);
        
        // CORRECT PARAMETERS
        //disable all triggers to test the logic separately from them
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        //create accounts
        Account account1 = H_C_UnitTestUtils.createAccount('Contract Account1');
        account1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
            
        Account account2 = H_C_UnitTestUtils.createAccount('Key Region Account1');
        account2.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        account2.ParentId = account1.Id;
        
        Account account3 = H_C_UnitTestUtils.createAccount('Transactional Account1');
        account3.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        account3.ParentId = account2.Id;
        
        update new Account[] {account1, account2, account3};
        
        //create opportunities
        Opportunity opportunity1 = H_C_UnitTestUtils.createOpportunity('Opportunity1', account2.Id);
        Opportunity opportunity2 = H_C_UnitTestUtils.createOpportunity('Opportunity2', account2.Id);
        
        //perform the method
        manageMappings_onOpportunitiesInserted(new Opportunity[] {opportunity1, opportunity2});
        
        //check the results
        //check mappings for the 1st account
        H_C_AccountOpportunity__c[] mappings =
            H_C_AccountOpportunityUtils.getObjectsByAccountsIds(new String[] {account1.Id});
        System.assertEquals(2, mappings.size());
        System.assert(opportunity1.Id == mappings[0].Opportunity__c && opportunity2.Id == mappings[1].Opportunity__c
            || opportunity2.Id == mappings[0].Opportunity__c && opportunity1.Id == mappings[1].Opportunity__c);
        
        //check mappings for the 2nd account
        mappings = H_C_AccountOpportunityUtils.getObjectsByAccountsIds(new String[] {account2.Id});
        System.assertEquals(2, mappings.size());
        System.assert(opportunity1.Id == mappings[0].Opportunity__c && opportunity2.Id == mappings[1].Opportunity__c
            || opportunity2.Id == mappings[0].Opportunity__c && opportunity1.Id == mappings[1].Opportunity__c);
        
        //check mappings for the 3rd account
        mappings = H_C_AccountOpportunityUtils.getObjectsByAccountsIds(new String[] {account3.Id});
        System.assertEquals(0, mappings.size());
        //System.assert(opportunity2.Id == mappings[0].Opportunity__c);
    }
    
    @IsTest
    private static void test_manageMappings_onOpportunitiesUpdated()
    {
        // WRONG AND EMPTY PARAMETERS
        manageMappings_onOpportunitiesUpdated(null, null);
        manageMappings_onOpportunitiesUpdated(new Map<Id, Opportunity>(), new Map<Id, Opportunity>());
        
        // CORRECT PARAMETERS
        //disable all triggers to test the logic separately from them
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        //create accounts
        Account account1 = H_C_UnitTestUtils.createAccount('Contract Account1');
        account1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
            
        Account account2 = H_C_UnitTestUtils.createAccount('Key Region Account1');
        account2.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        account2.ParentId = account1.Id;
        
        Account account3 = H_C_UnitTestUtils.createAccount('Transactional Account1');
        account3.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        account3.ParentId = account2.Id;
        
        update new Account[] {account1, account2, account3};
        
        //create opportunities
        Opportunity opportunity1 = H_C_UnitTestUtils.createOpportunity('Opportunity1', account2.Id);
        Opportunity opportunity2 = H_C_UnitTestUtils.createOpportunity('Opportunity2', account2.Id);
        Opportunity[] opportunities = new Opportunity[] {opportunity1, opportunity2};
        
        //perform the following method to create mappings
        manageMappings_onOpportunitiesInserted(opportunities);
        
        //simulate old opportunities
        Map<Id, Opportunity> oldOpportunities = new Map<Id, Opportunity>();
        oldOpportunities.put(opportunity1.Id, opportunity1.clone(true));
        oldOpportunities.put(opportunity2.Id, opportunity2.clone(true));
        
        //update AccountId for both of opportunities
        opportunity1.AccountId = account1.Id;
        opportunity2.AccountId = account2.Id;
        //update Name for opportunity1
        opportunity2.Name += ' (updated)';
        update opportunities;
        
        //perform the method
        manageMappings_onOpportunitiesUpdated(oldOpportunities, new Map<Id, Opportunity>(opportunities));
        
        //check the results
        //check mappings for the 1st account
        H_C_AccountOpportunity__c[] mappings =
            H_C_AccountOpportunityUtils.getObjectsByAccountsIds(new String[] {account1.Id});
        System.assertEquals(2, mappings.size());
        System.assert(opportunity1.Id == mappings[0].Opportunity__c && opportunity2.Id == mappings[1].Opportunity__c
            || opportunity2.Id == mappings[0].Opportunity__c && opportunity1.Id == mappings[1].Opportunity__c);
        
        //check mappings for the 2nd account
        mappings = H_C_AccountOpportunityUtils.getObjectsByAccountsIds(new String[] {account2.Id});
        System.assertEquals(1, mappings.size());
        System.assert(opportunity2.Id == mappings[0].Opportunity__c);
        
        //check mappings for the 3rd account
        mappings = H_C_AccountOpportunityUtils.getObjectsByAccountsIds(new String[] {account3.Id});
        System.assertEquals(0, mappings.size());
        
        //check new name of the mappings
        mappings = getObjectsByOpportunitiesIds(new String[] {opportunity2.Id});
        System.assertEquals(2, mappings.size());
        for (H_C_AccountOpportunity__c mapping : mappings)
        {
        	System.assertEquals(opportunity2.Name, mapping.Name);
        }
    }
    
    @IsTest
    private static void test_getObjectsByIds()
    {
        //wrong parameters
        System.assertEquals(null, getObjectsByIds(null));
        
        //correct parameters
        //disable all triggers to improve the performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        Account account1 = H_C_UnitTestUtils.constructAccount('Account1');
        Account account2 = H_C_UnitTestUtils.constructAccount('Account2');
        insert new Account[] {account1, account2};
        Opportunity opportunity1 = H_C_UnitTestUtils.createOpportunity('Opportunity 1', account2.Id);
        
        H_C_AccountOpportunity__c mapping1 =
        	H_C_UnitTestUtils.createAccountOpportunityMapping(account1, opportunity1);
        H_C_AccountOpportunity__c mapping2 =
        	H_C_UnitTestUtils.createAccountOpportunityMapping(account2, opportunity1);
        
        //perform the method and check the results
        H_C_AccountOpportunity__c[] mappings = getObjectsByIds(
        	new String[] {mapping1.Id, mapping2.Id});
        System.assertEquals(2, mappings.size());
        System.assert(mapping1.Id == mappings[0].Id && mapping2.Id == mappings[1].Id
            || mapping1.Id == mappings[1].Id && mapping2.Id == mappings[0].Id);
    }
    
    @IsTest
    private static void test_getObjectsByAccountsIds()
    {
        //wrong parameters
        System.assertEquals(null, getObjectsByAccountsIds(null));
        
        //correct parameters
        //disable all triggers to improve the performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        Account account1 = H_C_UnitTestUtils.constructAccount('Account1');
        Account account2 = H_C_UnitTestUtils.constructAccount('Account2');
        insert new Account[] {account1, account2};
        Opportunity opportunity1 = H_C_UnitTestUtils.createOpportunity('Opportunity 1', account2.Id);
        
        H_C_AccountOpportunity__c mapping1 =
        	H_C_UnitTestUtils.createAccountOpportunityMapping(account1, opportunity1);
        H_C_AccountOpportunity__c mapping2 =
        	H_C_UnitTestUtils.createAccountOpportunityMapping(account2, opportunity1);
        
        //perform the method and check the results
        H_C_AccountOpportunity__c[] mappings = getObjectsByAccountsIds(
        	new String[] {account1.Id, account2.Id});
        System.assertEquals(2, mappings.size());
        System.assert(mapping1.Id == mappings[0].Id && mapping2.Id == mappings[1].Id
        	|| mapping1.Id == mappings[1].Id && mapping2.Id == mappings[0].Id);
        
        //perform the method and check the results
        mappings = getObjectsByAccountsIds(new String[] {account1.Id});
        System.assertEquals(1, mappings.size());
        System.assert(mapping1.Id == mappings[0].Id);
    }
    
    @IsTest
    private static void test_getObjectsByOpportunityAccountsIds()
    {
        //wrong parameters
        System.assertEquals(null, getObjectsByOpportunityAccountsIds(null));
        
        //correct parameters
        //disable all triggers to improve the performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        Account account1 = H_C_UnitTestUtils.constructAccount('Account1');
        Account account2 = H_C_UnitTestUtils.constructAccount('Account2');
        insert new Account[] {account1, account2};
        Opportunity opportunity1 = H_C_UnitTestUtils.createOpportunity('Opportunity 1', account2.Id);
        
        H_C_AccountOpportunity__c mapping1 =
        	H_C_UnitTestUtils.createAccountOpportunityMapping(account1, opportunity1);
        H_C_AccountOpportunity__c mapping2 =
        	H_C_UnitTestUtils.createAccountOpportunityMapping(account2, opportunity1);
        
        //perform the method and check the results
        H_C_AccountOpportunity__c[] mappings =
        	getObjectsByOpportunityAccountsIds(new String[] {account2.Id});
        System.assertEquals(2, mappings.size());
        System.assert(mapping1.Id == mappings[0].Id && mapping2.Id == mappings[1].Id
            || mapping1.Id == mappings[1].Id && mapping2.Id == mappings[0].Id);
    }
    
    @IsTest
    private static void test_getObjectsByOpportunitiesIds()
    {
        //wrong parameters
        System.assertEquals(null, getObjectsByOpportunitiesIds(null));
        
        //correct parameters
        //disable all triggers to improve the performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        Account account1 = H_C_UnitTestUtils.constructAccount('Account1');
        Account account2 = H_C_UnitTestUtils.constructAccount('Account2');
        insert new Account[] {account1, account2};
        
        Opportunity opportunity1 = H_C_UnitTestUtils.constructOpportunity('Opportunity 1', account1.Id);
        Opportunity opportunity2 = H_C_UnitTestUtils.constructOpportunity('Opportunity 2', account2.Id);
        insert new Opportunity[] {opportunity1, opportunity2};
        
        H_C_AccountOpportunity__c mapping1 =
        	H_C_UnitTestUtils.createAccountOpportunityMapping(account1, opportunity1);
        H_C_AccountOpportunity__c mapping2 =
        	H_C_UnitTestUtils.createAccountOpportunityMapping(account2, opportunity2);
        
        //perform the method and check the results
        H_C_AccountOpportunity__c[] mappings =
        	getObjectsByOpportunitiesIds(new String[] {opportunity1.Id, opportunity2.Id});
        System.assertEquals(2, mappings.size());
        System.assert(mapping1.Id == mappings[0].Id && mapping2.Id == mappings[1].Id
        	|| mapping1.Id == mappings[1].Id && mapping2.Id == mappings[0].Id);
        
        mappings = getObjectsByOpportunitiesIds(new String[] {opportunity1.Id});
        System.assertEquals(1, mappings.size());
        System.assert(mapping1.Id == mappings[0].Id);
    }
    //


	//OpportunityDAO Section
	//
	//This Section provides access to 'Opportunity' object
	//
	//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (15-05-2013)

    //
    //Variables and constants
    //
    private static String BASIC_FIELDS_2 = 'Id, Name, AccountId, Account.ParentId, Account.Parent.ParentId';
    private static String OBJECT_NAME_2 = 'Opportunity';
    //
    
    //
    //Public static methods
    //
    public static Opportunity[] getOpportunitiesByIds(String[] opportunitiesIds)
    {
        //join Ids and check the string
        String stringOfIds = H_C_SoqlUtils.joinStringsForINSection(opportunitiesIds);
        if (String.isBlank(stringOfIds))
        {
            return null;
        }
        
        //initialize query builder and perform the query
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS_2, OBJECT_NAME_2);
        queryBuilder.condition = 'Id IN (' + stringOfIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    
    public static Opportunity[] getOpportunitiesByAccountsIds(String[] accountsIds)
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
    
    public static String[] extractOpportunitiesIds(Opportunity[] opportunities)
    {
        if (opportunities == null)
        {
            return null;
        }
        
        Set<String> setOfOpportunitiesIds = new Set<String>();
        for (Opportunity opportunity : opportunities)
        {
            if (String.isNotBlank(opportunity.Id))
            {
                setOfOpportunitiesIds.add(opportunity.Id);
            }
        }
        
        List<String> listOfOpportunitiesIds = new List<String>();
        listOfOpportunitiesIds.addAll(setOfOpportunitiesIds);
        return listOfOpportunitiesIds;
    }
    //
    
    
    
    
    
    //
    //Unit tests
    //
    @IsTest
    private static void test_getOpportunitiesByIds()
    {
        //wrong parameters
        System.assertEquals(null, getOpportunitiesByIds(null));
        
        //correct parameters
        //disable all triggers to improve the performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        Opportunity opportunity1 = H_C_UnitTestUtils.constructOpportunity('Opportunity 1', null);
        Opportunity opportunity2 = H_C_UnitTestUtils.constructOpportunity('Opportunity 2', null);
        insert new Opportunity[] {opportunity1, opportunity2};
        
        //perform the method and check the results
        Opportunity[] opportunities = getOpportunitiesByIds(
        	new String[] {opportunity1.Id, opportunity2.Id});
        System.assertEquals(2, opportunities.size());
        System.assert(opportunity1.Id == opportunities[0].Id && opportunity2.Id == opportunities[1].Id
        	|| opportunity1.Id == opportunities[1].Id && opportunity2.Id == opportunities[0].Id);
        
        opportunities = getOpportunitiesByIds(new String[] {opportunity1.Id});
        System.assertEquals(1, opportunities.size());
        System.assert(opportunity1.Id == opportunities[0].Id);
    }
    
    @IsTest
    private static void test_getOpportunitiesByAccountsIds()
    {
        //wrong parameters
        System.assertEquals(null, getOpportunitiesByAccountsIds(null));
        
        //correct parameters
        //disable all triggers to improve the performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        Account account1 = H_C_UnitTestUtils.constructAccount('Account1');
        Account account2 = H_C_UnitTestUtils.constructAccount('Account2');
        insert new Account[] {account1, account2};
        
        Opportunity opportunity1 = H_C_UnitTestUtils.constructOpportunity('Opportunity 1', account1.Id);
        Opportunity opportunity2 = H_C_UnitTestUtils.constructOpportunity('Opportunity 2', account2.Id);
        insert new Opportunity[] {opportunity1, opportunity2};
        
        //perform the method and check the results
        Opportunity[] opportunities = getOpportunitiesByAccountsIds(
        	new String[] {account1.Id, account2.Id});
        System.assertEquals(2, opportunities.size());
        System.assert(opportunity1.Id == opportunities[0].Id && opportunity2.Id == opportunities[1].Id
        	|| opportunity1.Id == opportunities[1].Id && opportunity2.Id == opportunities[0].Id);
        
        opportunities = getOpportunitiesByAccountsIds(new String[] {account1.Id});
        System.assertEquals(1, opportunities.size());
        System.assert(opportunity1.Id == opportunities[0].Id);
    }
    
    @IsTest
    private static void test_extractOpportunitiesIds()
    {
        //wrong parameters
        System.assertEquals(null, extractOpportunitiesIds(null));
        
        //correct parameters
        //disable all triggers to improve the performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        Opportunity opportunity1 = H_C_UnitTestUtils.constructOpportunity('Opportunity 1', null);
        Opportunity opportunity2 = H_C_UnitTestUtils.constructOpportunity('Opportunity 2', null);
        Opportunity[] opportunities = new Opportunity[] {opportunity1, opportunity2};
        insert opportunities;
        
        //perform the method and check the results
        String[] opportunitiesIds = extractOpportunitiesIds(opportunities);
        System.assertEquals(2, opportunitiesIds.size());
        System.assert(opportunity1.Id == opportunitiesIds[0] && opportunity2.Id == opportunitiesIds[1]
        	|| opportunity1.Id == opportunitiesIds[1] && opportunity2.Id == opportunitiesIds[0]);
    }
}