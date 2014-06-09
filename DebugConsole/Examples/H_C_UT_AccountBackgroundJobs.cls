//
//This class provides Unit tests for 'H_C_AccountBackgroundJobs' trigger
//Used abbreviations:
// - UT means 'Unit test'
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (15-05-2013)
@IsTest
public class H_C_UT_AccountBackgroundJobs
{
    @IsTest
    private static void test_updateHierarchy_onAccountsInserted()
    {
        //STEP #1: create test data
        //enable all triggers to be sure that they work
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(true);
        
        Account account1 = H_C_UnitTestUtils.constructAccount('Contract Account1');
        account1.CUST_NUMBER_OP_UNIT_SFDC__c = 'Ext_Id1';
        account1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
        account1.ParentId = null;
            
        Account account2 = H_C_UnitTestUtils.constructAccount('Key Region Account1');
        account2.KEY_ACCOUNT_NUMBER_SFDC__c = 'Ext_Id2';
        account2.CUST_NUMBER_OP_UNIT_SFDC__c = 'Ext_Id1';
        account2.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        account2.ParentId = null;
        
        //the reference to a parent should be updated
        Account account3 = H_C_UnitTestUtils.constructAccount('Transactional Account1');
        account3.Site_Use_ID_SFDC__c = 'Ext_Id3';
        account3.KEY_ACCOUNT_NUMBER_SFDC__c = 'Ext_Id2';
        account3.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        account3.ParentId = account1.Id;
        
        //the reference to a parent should be cleared
        Account account4 = H_C_UnitTestUtils.constructAccount('Key Region Account2');
        account4.KEY_ACCOUNT_NUMBER_SFDC__c = 'Ext_Id4';
        account4.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        account4.ParentId = account1.Id;
        
        //the reference to a parent should be cleared
        Account account5 = H_C_UnitTestUtils.constructAccount('Transactional Account2');
        account5.Site_Use_ID_SFDC__c = 'Ext_Id5';
        account5.CUST_NUMBER_OP_UNIT_SFDC__c = 'Ext_Id1';
        account5.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        account5.ParentId = account1.Id;
        
        Account[] accounts = new Account[] {account1, account2, account3, account4, account5};
        
        //STEP #2: insert accounts
        insert accounts;
        
        //STEP #3: check the results
        //reread the data and check the results
        H_C_AccountHelper accountsHelper = H_C_AccountHelper.createHelperByIds(
            H_C_AccountHelper.extractAccountsIds(accounts));
        System.assertEquals(null, accountsHelper.getAccountById(account1.Id).ParentId);
        System.assertEquals(account1.Id, accountsHelper.getAccountById(account2.Id).ParentId);
        System.assertEquals(account2.Id, accountsHelper.getAccountById(account3.Id).ParentId);
        System.assertEquals(null, accountsHelper.getAccountById(account4.Id).ParentId);
        System.assertEquals(null, accountsHelper.getAccountById(account5.Id).ParentId);
    }
    
    @IsTest
    private static void test_updateHierarchy_onAccountsUpdated()
    {
        //STEP #1: create test data
        //enable all triggers to be sure that they work
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(true);
        
        Account account1 = H_C_UnitTestUtils.createAccount('Contract Account1');
        account1.CUST_NUMBER_OP_UNIT_SFDC__c = 'Ext_Id1';
        account1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
            
        Account account2 = H_C_UnitTestUtils.createAccount('Key Region Account1');
        account2.KEY_ACCOUNT_NUMBER_SFDC__c = 'Ext_Id2';
        account2.CUST_NUMBER_OP_UNIT_SFDC__c = 'Ext_Id1';
        account2.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        
        //the reference to a parent should be updated
        Account account3 = H_C_UnitTestUtils.createAccount('Transactional Account1',
            account1.Id);
        account3.Site_Use_ID_SFDC__c = 'Ext_Id3';
        account3.KEY_ACCOUNT_NUMBER_SFDC__c = 'Ext_Id2';
        account3.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        
        //the reference to a parent should be cleared
        Account account4 = H_C_UnitTestUtils.createAccount('Transactional Account2');
        account4.Site_Use_ID_SFDC__c = 'Ext_Id5';
        account4.CUST_NUMBER_OP_UNIT_SFDC__c = 'Ext_Id1';
        account4.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        
        Account[] accounts = new Account[] {account1, account2, account3, account4};
        
        //STEP #2: update accounts
        update accounts;
        
        //STEP #3: check the results
        //reread the data and check the results
        H_C_AccountHelper accountsHelper = H_C_AccountHelper.createHelperByIds(
            H_C_AccountHelper.extractAccountsIds(accounts));
        System.assertEquals(null, accountsHelper.getAccountById(account1.Id).ParentId);
        System.assertEquals(account1.Id, accountsHelper.getAccountById(account2.Id).ParentId);
        System.assertEquals(account2.Id, accountsHelper.getAccountById(account3.Id).ParentId);
        System.assertEquals(null, accountsHelper.getAccountById(account4.Id).ParentId);
    }
    
    @IsTest
    private static void test_manageAccountOpportunityMappings_onAccountsUpdated()
    {
        //STEP #1: create test data
        //enable all triggers to be sure that they work
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(true);
        
        //create accounts
        Account account1 = H_C_UnitTestUtils.constructAccount('Contract Account1');
        account1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
            
        Account account2 = H_C_UnitTestUtils.constructAccount('Key Region Account1');
        account2.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        
        Account account3 = H_C_UnitTestUtils.constructAccount('Transactional Account1');
        account3.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        
        Account[] insertedAccounts = new Account[] {account1, account2, account3};
        insert insertedAccounts;
        
        //create opportunities
        Opportunity opportunity2 = H_C_UnitTestUtils.createOpportunity('Opportunity2', account2.Id);
        //Opportunity opportunity3 = H_C_UnitTestUtils.createOpportunity('Opportunity3', account3.Id);
        
        //reread accounts from DB and update them
        H_C_AccountHelper accountsHelper = H_C_AccountHelper.createHelperByIds(
            H_C_AccountHelper.extractAccountsIds(insertedAccounts));
        account1 = accountsHelper.getAccountById(account1.Id);
        account2 = accountsHelper.getAccountById(account2.Id);
        account3 = accountsHelper.getAccountById(account3.Id);
        
        account1.CUST_NUMBER_OP_UNIT_SFDC__c = 'CA_Id1';
        account2.KEY_ACCOUNT_NUMBER_SFDC__c = 'KR_Id1';
        account2.CUST_NUMBER_OP_UNIT_SFDC__c = 'CA_Id1';
        account3.Site_Use_ID_SFDC__c = 'TR_Id1';
        account3.KEY_ACCOUNT_NUMBER_SFDC__c = 'KR_Id1';
        update new Account[] {account1, account2, account3};
        
        //check the results
        //check mappings for the 1st account
        H_C_AccountOpportunity__c[] mappings =
            H_C_AccountOpportunityUtils.getObjectsByAccountsIds(new String[] {account1.Id});
        System.assertEquals(1, mappings.size());
        //System.assert(opportunity2.Id == mappings[0].Opportunity__c && opportunity3.Id == mappings[1].Opportunity__c
        //    || opportunity3.Id == mappings[0].Opportunity__c && opportunity2.Id == mappings[1].Opportunity__c);
        
        //check mappings for the 2nd account
        mappings = H_C_AccountOpportunityUtils.getObjectsByAccountsIds(new String[] {account2.Id});
        System.assertEquals(1, mappings.size());
        //System.assert(opportunity2.Id == mappings[0].Opportunity__c && opportunity3.Id == mappings[1].Opportunity__c
        //    || opportunity3.Id == mappings[0].Opportunity__c && opportunity2.Id == mappings[1].Opportunity__c);
        
        //check mappings for the 3rd account
        mappings = H_C_AccountOpportunityUtils.getObjectsByAccountsIds(new String[] {account3.Id});
        System.assertEquals(0, mappings.size());
        //System.assert(opportunity3.Id == mappings[0].Opportunity__c);
    }
}