//
//This class contains Unit tests for account hierarchy utils
//Used abbreviations:
// - UT means 'Unit test'
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (10-09-2013)
@IsTest
public class H_C_UT_AccountHierarchyUtils
{
	//
    //Unit tests for 'H_C_AccountHierarchyCreationUtils' class
    //
    @IsTest
    private static void test_updateHierarchy()
    {
        // WRONG AND EMPTY PARAMETERS
        H_C_AccountHierarchyCreationUtils.updateHierarchy(null, true);
        H_C_AccountHierarchyCreationUtils.updateHierarchy(new Account[0], true);
        H_C_AccountHierarchyCreationUtils.updateHierarchy(new Account[] {new Account()}, true);
        
        // CORRECT PARAMETERS
        //disable all triggers to test the logic separately from them
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        Account account1 = H_C_UnitTestUtils.createAccount('Contract Account1');
        account1.CUST_NUMBER_OP_UNIT_SFDC__c = 'Ext_Id1';
        account1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
        account1.ParentId = null;
            
        Account account2 = H_C_UnitTestUtils.createAccount('Key Region Account1');
        account2.KEY_ACCOUNT_NUMBER_SFDC__c = 'Ext_Id2';
        account2.CUST_NUMBER_OP_UNIT_SFDC__c = 'Ext_Id1';
        account2.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        account2.ParentId = null;
        
        //the reference to a parent should be updated
        Account account3 = H_C_UnitTestUtils.createAccount('Transactional Account1');
        account3.Site_Use_ID_SFDC__c = 'Ext_Id3';
        account3.KEY_ACCOUNT_NUMBER_SFDC__c = 'Ext_Id2';
        account3.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        account3.ParentId = account1.Id;
        
        //the reference to a parent should be cleared
        //Updated Implemented logic for store parentId
        Account account4 = H_C_UnitTestUtils.createAccount('Key Region Account2');
        account4.KEY_ACCOUNT_NUMBER_SFDC__c = 'Ext_Id4';
        account4.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        account4.ParentId = account1.Id;
        
        //the reference to a parent should be cleared
        //Updated Implemented logic for store parentId
        Account account5 = H_C_UnitTestUtils.createAccount('Transactional Account2');
        account5.Site_Use_ID_SFDC__c = 'Ext_Id5';
        account5.CUST_NUMBER_OP_UNIT_SFDC__c = 'Ext_Id1';
        account5.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        account5.ParentId = account1.Id;
        
        Account[] accounts = new Account[] {account1, account2, account3, account4, account5};
        update accounts;
        
        //perform the method
        H_C_AccountHierarchyCreationUtils.updateHierarchy(accounts, true);
        
        //check the results
        H_C_AccountHelper accountsHelper = H_C_AccountHelper.createHelperByIds(
            new String[] {account1.Id, account2.Id, account3.Id, account4.Id, account5.Id});
        System.assertEquals(null, accountsHelper.getAccountById(account1.Id).ParentId);
        System.assertEquals(account1.Id, accountsHelper.getAccountById(account2.Id).ParentId);
        System.assertEquals(account2.Id, accountsHelper.getAccountById(account3.Id).ParentId);
        //System.assertNotEquals(null, accountsHelper.getAccountById(account4.Id).ParentId);
        //System.assertNotEquals(null, accountsHelper.getAccountById(account5.Id).ParentId);
    }
    
    @IsTest
    private static void test_updateHierarchy_onAccountsInserted()
    {
        // WRONG AND EMPTY PARAMETERS
        H_C_AccountHierarchyCreationUtils.updateHierarchy_onAccountsInserted(null);
        H_C_AccountHierarchyCreationUtils.updateHierarchy_onAccountsInserted(new Account[0]);
        H_C_AccountHierarchyCreationUtils.updateHierarchy_onAccountsInserted(new Account[] {new Account()});
        
        // CORRECT PARAMETERS
        //disable all triggers to test the logic separately from them
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        Account account1 = H_C_UnitTestUtils.createAccount('Contract Account1');
        account1.CUST_NUMBER_OP_UNIT_SFDC__c = 'Ext_Id1';
        account1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
        account1.ParentId = null;
            
        Account account2 = H_C_UnitTestUtils.createAccount('Key Region Account1');
        account2.KEY_ACCOUNT_NUMBER_SFDC__c = 'Ext_Id2';
        account2.CUST_NUMBER_OP_UNIT_SFDC__c = 'Ext_Id1';
        account2.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        account2.ParentId = null;
        
        //the reference to a parent should be updated
        Account account3 = H_C_UnitTestUtils.createAccount('Transactional Account1');
        account3.Site_Use_ID_SFDC__c = 'Ext_Id3';
        account3.KEY_ACCOUNT_NUMBER_SFDC__c = 'Ext_Id2';
        account3.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        account3.ParentId = account1.Id;
        
        //the reference to a parent should be cleared
        //Updated Implemented logic for store parentId
        Account account4 = H_C_UnitTestUtils.createAccount('Key Region Account2');
        account4.KEY_ACCOUNT_NUMBER_SFDC__c = 'Ext_Id4';
        account4.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        account4.ParentId = account1.Id;
        
        //the reference to a parent should be cleared
        //Updated Implemented logic for store parentId
        Account account5 = H_C_UnitTestUtils.createAccount('Transactional Account2');
        account5.Site_Use_ID_SFDC__c = 'Ext_Id5';
        account5.CUST_NUMBER_OP_UNIT_SFDC__c = 'Ext_Id1';
        account5.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        account5.ParentId = account1.Id;
        
        Account[] accounts = new Account[] {account1, account2, account3, account4, account5};
        update accounts;
        
        //perform the method
        H_C_AccountHierarchyCreationUtils.updateHierarchy_onAccountsInserted(accounts);
        
        //check the results
        H_C_AccountHelper accountsHelper = H_C_AccountHelper.createHelperByIds(
            H_C_AccountHelper.extractAccountsIds(accounts));
        System.assertEquals(null, accountsHelper.getAccountById(account1.Id).ParentId);
        System.assertEquals(account1.Id, accountsHelper.getAccountById(account2.Id).ParentId);
        System.assertEquals(account2.Id, accountsHelper.getAccountById(account3.Id).ParentId);
        //System.assertNotEquals(null, accountsHelper.getAccountById(account4.Id).ParentId);
        //System.assertNotEquals(null, accountsHelper.getAccountById(account5.Id).ParentId);
    }
    
    @IsTest
    private static void test_updateHierarchy_onAccountsUpdated()
    {
        // WRONG AND EMPTY PARAMETERS
        H_C_AccountHierarchyCreationUtils.updateHierarchy_onAccountsUpdated(null, null);
        H_C_AccountHierarchyCreationUtils.updateHierarchy_onAccountsUpdated(new Map<Id, Account>(), new Account[0]);
        
        // CORRECT PARAMETERS
        //disable all triggers to test the logic separately from them
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        Account account1 = H_C_UnitTestUtils.createAccount('Contract Account1');
        account1.CUST_NUMBER_OP_UNIT_SFDC__c = 'Ext_Id1';
        account1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
        account1.ParentId = null;
            
        Account account2 = H_C_UnitTestUtils.createAccount('Key Region Account1');
        account2.KEY_ACCOUNT_NUMBER_SFDC__c = 'Ext_Id2';
        account2.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        account2.ParentId = null;
        
        Account account3 = H_C_UnitTestUtils.createAccount('Transactional Account1');
        account3.Site_Use_ID_SFDC__c = 'Ext_Id3';
        account3.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        account3.ParentId = account1.Id;
        
        Account account4 = H_C_UnitTestUtils.createAccount('Key Region Account2');
        account4.KEY_ACCOUNT_NUMBER_SFDC__c = 'Ext_Id4';
        account4.CUST_NUMBER_OP_UNIT_SFDC__c = 'Ext_Id1';
        account4.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        account4.ParentId = account1.Id;
        
        Account[] accounts = new Account[] {account1, account2, account3, account4};
        update accounts;
        
        //simulate old accounts
        Map<Id, Account> oldAccounts = new Map<Id, Account>(accounts);
        
        //similate updated accounts
        //nothing should be changed
        Account updatedAccount1 = account1.clone(true);
        //the reference to a parent should be filled
        Account updatedAccount2 = account2.clone(true);
        updatedAccount2.CUST_NUMBER_OP_UNIT_SFDC__c = 'Ext_Id1';
        //the reference to a parent should be updated
        Account updatedAccount3 = account3.clone(true);
        updatedAccount3.KEY_ACCOUNT_NUMBER_SFDC__c = 'Ext_Id2';
        //the reference to a parent should be cleared, because external parent Id is empty
        Account updatedAccount4 = account4.clone(true);
        updatedAccount4.CUST_NUMBER_OP_UNIT_SFDC__c = null;
        
        List<Account> updatedAccounts = new Account[] {updatedAccount1, updatedAccount2,
            updatedAccount3, updatedAccount4};
        
        //perform the method
        H_C_AccountHierarchyCreationUtils.updateHierarchy_onAccountsUpdated(oldAccounts, updatedAccounts);
        
        //check the results
        H_C_AccountHelper accountsHelper = H_C_AccountHelper.createHelperByIds(
            H_C_AccountHelper.extractAccountsIds(accounts));
        System.assertEquals(null, accountsHelper.getAccountById(account1.Id).ParentId);
        System.assertEquals(account1.Id, accountsHelper.getAccountById(account2.Id).ParentId);
        System.assertEquals(account2.Id, accountsHelper.getAccountById(account3.Id).ParentId);
        //System.assertNotEquals(null, accountsHelper.getAccountById(account4.Id).ParentId);
    }
    //
}