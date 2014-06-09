//
//The class covers some triggers by Unit tests
//Used abbreviations:
// - UT means 'Unit test'
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (31-05-2013)
@IsTest
public class H_C_UT_Triggers
{
	//
	//Unit tests for 'H_C_OpportunityBackgroundJobs' trigger
	//
	@IsTest
    private static void test_manageAccountOpportunities_onOpportunitiesInserted()
    {
    	//STEP #1: create test data
        //enable all triggers to be sure that they work
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(true);
        
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
        Opportunity opportunity1 = H_C_UnitTestUtils.constructOpportunity('Opportunity1', account2.Id);
        Opportunity opportunity2 = H_C_UnitTestUtils.constructOpportunity('Opportunity2', account2.Id);
        
        //insert new opportunities
        insert new Opportunity[] {opportunity1, opportunity2};
        
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
    private static void test_manageAccountOpportunities_onOpportunitiesUpdated()
    {
    	//STEP #1: create test data
        //enable all triggers to be sure that they work
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(true);
        
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
        Opportunity opportunity1 = H_C_UnitTestUtils.constructOpportunity('Opportunity1', account2.Id);
        Opportunity opportunity2 = H_C_UnitTestUtils.constructOpportunity('Opportunity2', account2.Id);
        Opportunity[] opportunities = new Opportunity[] {opportunity1, opportunity2};
        insert opportunities;
        
        //update AccountId for both of opportunities
        opportunity1.AccountId = account1.Id;
        opportunity2.AccountId = account2.Id;
        //update Name for opportunity1
        opportunity2.Name += ' (updated)';
        update opportunities;
        
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
        mappings = H_C_AccountOpportunityUtils.getObjectsByOpportunitiesIds(new String[] {opportunity2.Id});
        System.assertEquals(2, mappings.size());
        
        //reread opportunity2 object, because there are workflow rules which can change
        //name of an opportunity on UAT and PRD
        opportunity2 = H_C_AccountOpportunityUtils.getOpportunitiesByIds(new String[] {opportunity2.Id})[0];
        for (H_C_AccountOpportunity__c mapping : mappings)
        {
        	System.assertEquals(opportunity2.Name, mapping.Name);
        }
    }
	//
	
	
	
	
	
	//
	//Unit tests for 'H_C_ContactBackgroundJobs' trigger
	//
	@IsTest
	private static void test_ContactBackgroundJobs()
	{
		//construct a new contact
		Contact newContact = new Contact();
		newContact.LastName = 'Test_Contact';
		
		//enable all trigger to be sure that they works
		H_C_CustomSettings.setTriggersSettingForCurrentRequest(true);
		//perform DML operations
		insert newContact;
		update newContact;
		
		//disable the triggers to cover a checking of the condition
		H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
		update newContact;
	}
	//
	
	//
	//Unit tests for 'H_C_CapitalEquipmentInstalledBaseBackgroundJobs' trigger
	//
	@IsTest
	private static void test_CapitalEquipmentInstalledBaseBackgroundJobs()
	{
		//construct a new contact
		Capital_Equipment_Installed_Base__c capitalEquipment = new Capital_Equipment_Installed_Base__c();
		capitalEquipment.Name = 'Test_Contact';
		
		//enable all trigger to be sure that they works
		H_C_CustomSettings.setTriggersSettingForCurrentRequest(true);
		//perform DML operations
		insert capitalEquipment;
		update capitalEquipment;
		
		//disable the triggers to cover a checking of the condition
		H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
		update capitalEquipment;
	}
	//
	
	//
	//Unit tests for 'H_C_ContractBackgroundJobs' trigger
	//
	@IsTest
	private static void test_ContractBackgroundJobs()
	{
		//construct a new contact
		Contract newContract = new Contract();
		//newContract.LastName = 'Test_Contact';
		
		//enable all trigger to be sure that they works
		H_C_CustomSettings.setTriggersSettingForCurrentRequest(true);
		//perform DML operations
		insert newContract;
		update newContract;
		
		//disable the triggers to cover a checking of the condition
		H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
		update newContract;
	}
	//
}