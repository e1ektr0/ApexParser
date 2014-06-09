//
//This class contains Unit tests for all data helpers
//Used abbreviations:
// - UT means 'Unit test'
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (10-09-2013)
@IsTest
public class H_C_UT_DataHelpers
{
	//
    //Unit tests for 'H_C_AccountHelper' class
    //
    @IsTest
    private static void testAccountHelper_getAccountById()
    {
        //create test data
        //disable triggers to improve performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        Account account1 = H_C_UnitTestUtils.createAccount('Account1');
        Account account2 = H_C_UnitTestUtils.createAccount('Account2');
        
        //1) WRONG PARAMETERS
        H_C_AccountHelper helper = H_C_AccountHelper.createHelperByIds(null);
        System.assertEquals(null, helper.getAccountById(null));
        System.assertEquals(null, helper.getAccountById(account1.Id));
        System.assertEquals(null, helper.getAccountById(account2.Id));
        
        //2) CORRECT PARAMETERS (optimizer is used automaticall)
        helper = H_C_AccountHelper.createHelperByIds(new String[] {account1.Id, account2.Id});
        System.assertEquals(2, helper.allAccounts.size());
        System.assertEquals(null, helper.getAccountById(null));
        System.assertEquals(account1.Id, helper.getAccountById(account1.Id).Id);
        System.assertEquals(account2.Id, helper.getAccountById(account2.Id).Id);
    }
    
    @IsTest
    private static void testAccountHelper_getAccountByExternalId()
    {
        //create test data
        //disable triggers to improve performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        Account account1 = H_C_UnitTestUtils.createAccount('Contract Account1');
        account1.CUST_NUMBER_OP_UNIT_SFDC__c = 'External_Id1';
        account1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
        
        Account account2 = H_C_UnitTestUtils.createAccount('Contract Account2');
        account2.CUST_NUMBER_OP_UNIT_SFDC__c = 'External_Id2';
        account2.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
            
        Account account3 = H_C_UnitTestUtils.createAccount('Key Region Account1');
        account3.KEY_ACCOUNT_NUMBER_SFDC__c = 'External_Id3';
        account3.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        
        Account[] accounts = new Account[] {account1, account2, account3};
        update accounts;
        
        //1) WRONG PARAMETERS
        H_C_AccountHelper helper = H_C_AccountHelper.createHelperByAccountsList(null);
        System.assertEquals(null, helper.getAccountByExternalId(null));
        System.assertEquals(null, helper.getAccountByExternalId(account1.CUST_NUMBER_OP_UNIT_SFDC__c));
        System.assertEquals(null, helper.getAccountByExternalId(account3.KEY_ACCOUNT_NUMBER_SFDC__c));
        
        //2) CORRECT PARAMETERS (optimizer is used automatically)
        helper = H_C_AccountHelper.createHelperByAccountsList(accounts);
        System.assertEquals(3, helper.allAccounts.size());
        System.assertEquals(null, helper.getAccountByExternalId(null));
        System.assertEquals(account1.Id, helper.getAccountByExternalId(account1.CUST_NUMBER_OP_UNIT_SFDC__c).Id);
        System.assertEquals(account2.Id, helper.getAccountByExternalId(account2.CUST_NUMBER_OP_UNIT_SFDC__c).Id);
        System.assertEquals(account3.Id, helper.getAccountByExternalId(account3.KEY_ACCOUNT_NUMBER_SFDC__c).Id);
    }
    
    @IsTest
    private static void testAccountHelper_getAccountsByParentId()
    {
        //create test data
        //disable triggers to improve performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        Account parentAccount1 = H_C_UnitTestUtils.createAccount('Parent Account1');
        Account parentAccount2 = H_C_UnitTestUtils.createAccount('Parent Account2');
        
        Account account1 = H_C_UnitTestUtils.createAccount('Account1', parentAccount1.Id);
        Account account2 = H_C_UnitTestUtils.createAccount('Account2', parentAccount1.Id);
        Account account3 = H_C_UnitTestUtils.createAccount('Account3', parentAccount2.Id);
        
        //1) WRONG PARAMETERS
        H_C_AccountHelper helper = H_C_AccountHelper.createHelperByParentsIds(null);
        System.assertEquals(null, helper.getAccountsByParentId(null));
        System.assertEquals(0, helper.getAccountsByParentId(parentAccount1.Id).size());
        
        //2) CORRECT PARAMETERS (optimizer is used automatically)
        helper = H_C_AccountHelper.createHelperByParentsIds(
            new String[] {parentAccount1.Id, parentAccount2.Id});
        
        Account[] selectedAccounts = helper.getAccountsByParentId(parentAccount1.Id);
        
        System.assertEquals(2, selectedAccounts.size());
        System.assert(account1.Id == selectedAccounts[0].Id && account2.Id == selectedAccounts[1].Id
            || account1.Id == selectedAccounts[1].Id && account2.Id == selectedAccounts[0].Id);
        
        selectedAccounts = helper.getAccountsByParentId(parentAccount2.Id);
        System.assertEquals(1, selectedAccounts.size());
        System.assertEquals(account3.Id, selectedAccounts[0].Id);
        
        selectedAccounts = helper.getAccountsByParentId(account1.Id);
        System.assertEquals(0, selectedAccounts.size());
        
    }
    
    @IsTest
    private static void testAccountHelper_getAccountsByRecordTypeName()
    {
        //create test data
        //disable triggers to improve performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        Account account1 = H_C_UnitTestUtils.createAccount('Contract Account1');
        account1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
        
        Account account2 = H_C_UnitTestUtils.createAccount('Contract Account2');
        account2.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
            
        Account account3 = H_C_UnitTestUtils.createAccount('Key Region Account1');
        account3.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        
        Account account4 = H_C_UnitTestUtils.createAccount('Transactional Account1');
        account4.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        
        Account[] accounts = new Account[] {account1, account2, account3, account4};
        update accounts;
        
        //1) WRONG PARAMETERS
        H_C_AccountHelper helper = H_C_AccountHelper.createHelperByAccountsList(null);
        System.assertEquals(null, helper.getAccountsByRecordTypeName(null));
        System.assertEquals(0, helper.getAccountsByRecordTypeName(
            H_C_AccountRecordType.CONTRACT_ACCOUNT).size());
        
        //2) CORRECT PARAMETERS (optimizer is used automatically)
        helper = H_C_AccountHelper.createHelperByAccountsList(accounts);
        
        Account[] selectedAccounts = helper.getAccountsByRecordTypeName(
            H_C_AccountRecordType.CONTRACT_ACCOUNT);
        System.assertEquals(2, selectedAccounts.size());
        System.assert(account1.Id == selectedAccounts[0].Id && account2.Id == selectedAccounts[1].Id
            || account1.Id == selectedAccounts[1].Id && account2.Id == selectedAccounts[0].Id);
        
        selectedAccounts = helper.getAccountsByRecordTypeName(H_C_AccountRecordType.KEY_REGION_ACCOUNT);
        System.assertEquals(1, selectedAccounts.size());
        System.assertEquals(account3.Id, selectedAccounts[0].Id);
        
        selectedAccounts = helper.getAccountsByRecordTypeName(H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT);
        System.assertEquals(1, selectedAccounts.size());
        System.assertEquals(account4.Id, selectedAccounts[0].Id);
    }
    
    @IsTest
    private static void testAccountHelper_getAccountsByOwnerId()
    {
        //create test data
        //disable triggers to improve performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        Account account1 = H_C_UnitTestUtils.constructAccount('Account1');
        Account account2 = H_C_UnitTestUtils.constructAccount('Account2');
        insert new Account[] {account1, account2};
        
        User user1 = H_C_UnitTestUtils.createSfUser('User1');
        
        //initialize a helper
        H_C_AccountHelper helper = H_C_AccountHelper.createHelperByIds(
        	new String[] {account1.Id, account2.Id});
        
        //1) WRONG PARAMETERS
        System.assertEquals(null, helper.getAccountsByOwnerId(null));
        System.assertEquals(0, helper.getAccountsByOwnerId('UnknownId').size());
        
        //2) CORRECT PARAMETERS (optimizer is used automatically)
        Account[] selectedAccounts = helper.getAccountsByOwnerId(user1.Id);
        System.assertEquals(0, selectedAccounts.size());
        
        //current user is an owner for created accounts
        selectedAccounts = helper.getAccountsByOwnerId(UserInfo.getUserId());
        System.assertEquals(2, selectedAccounts.size());
        System.assert(account1.Id == selectedAccounts[0].Id && account2.Id == selectedAccounts[1].Id
        	|| account1.Id == selectedAccounts[1].Id && account2.Id == selectedAccounts[0].Id);
    }
    
    @IsTest
    private static void testAccountHelper_extractAccountsIds()
    {
    	//disable triggers to improve performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
    	//PART #1: test static method
        //WRONG PARAMETERS:
        System.assertEquals(null, H_C_AccountHelper.extractAccountsIds(null));
        
        //CORRECT PARAMETERS:
        //create test data
        Account account1 = H_C_UnitTestUtils.constructAccount('Account1');
        Account account2 = H_C_UnitTestUtils.constructAccount('Account2');
        Account[] accounts = new Account[] {account1, account2};
        insert accounts;
        
        String[] accountsIds = H_C_AccountHelper.extractAccountsIds(accounts);
        System.assertEquals(2, accountsIds.size());
        System.assert(account1.Id == accountsIds[0] && account2.Id == accountsIds[1]
        	|| account1.Id == accountsIds[1] && account2.Id == accountsIds[0]);
        
        
        //PART #2: test instance method
        //WRONG PARAMETERS:
        H_C_AccountHelper helper = H_C_AccountHelper.createHelperByAccountsList(null);
        System.assertEquals(0, helper.extractAccountsIds().size());
        
        //CORRECT PARAMETERS:
        helper = H_C_AccountHelper.createHelperByAccountsList(accounts);
        accountsIds = helper.extractAccountsIds();
        System.assertEquals(2, accountsIds.size());
        System.assert(account1.Id == accountsIds[0] && account2.Id == accountsIds[1]
        	|| account1.Id == accountsIds[1] && account2.Id == accountsIds[0]);
    }
    
    @IsTest
    private static void testAccountHelper_extractParentAccountsIds()
    {
    	//disable triggers to improve performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
    	
    	//PART #1: test static method
        //WRONG PARAMETERS:
        System.assertEquals(null, H_C_AccountHelper.extractParentAccountsIds(null));
        
        //CORRECT PARAMETERS:
        //create test data
        Account account1 = H_C_UnitTestUtils.createAccount('Account1');
        Account account2 = H_C_UnitTestUtils.createAccount('Account2', account1.Id);
        Account account3 = H_C_UnitTestUtils.createAccount('Account3', account2.Id);
        
        Account[] accounts = new Account[] {account1, account2, account3};
        
        String[] parentAccountsIds = H_C_AccountHelper.extractParentAccountsIds(accounts);
        System.assertEquals(2, parentAccountsIds.size());
        System.assert(account1.Id == parentAccountsIds[0] && account2.Id == parentAccountsIds[1]
        	|| account1.Id == parentAccountsIds[1] && account2.Id == parentAccountsIds[0]);
        
        
        //PART #2: test instance method
        //WRONG PARAMETERS:
        H_C_AccountHelper helper = H_C_AccountHelper.createHelperByAccountsList(null);
        System.assertEquals(0, helper.extractParentAccountsIds().size());
        
        //CORRECT PARAMETERS:
        helper = H_C_AccountHelper.createHelperByAccountsList(accounts);
        parentAccountsIds = helper.extractParentAccountsIds();
        System.assertEquals(2, parentAccountsIds.size());
        System.assert(account1.Id == parentAccountsIds[0] && account2.Id == parentAccountsIds[1]
        	|| account1.Id == parentAccountsIds[1] && account2.Id == parentAccountsIds[0]);
    }
    //
    
    
    
    
    
    //
    //Unit tests for 'H_C_AccountTeamMemberHelper' class
    //
    @IsTest
    private static void testATMHelper_getATMsByAccountId()
    {
    	//create test data
        //disable triggers to improve performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        //create accounts
        Account account1 = H_C_UnitTestUtils.createAccount('Account1');
        Account account2 = H_C_UnitTestUtils.createAccount('Account2');
        
        //create SF users
        User user1 = H_C_UnitTestUtils.createSfUser('User1');
        User user2 = H_C_UnitTestUtils.createSfUser('User2');
        
        //create team members
        String operableTeamRole = 'Account Manager';
        AccountTeamMember teamMember1 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account1.Id, user1.Id, operableTeamRole);
        AccountTeamMember teamMember2 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account1.Id, user2.Id, operableTeamRole);
        AccountTeamMember teamMember3 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account2.Id, user1.Id, operableTeamRole);
        AccountTeamMember[] teamMembers = new AccountTeamMember[] {
        	teamMember1, teamMember2, teamMember3};
        insert teamMembers;
        
        //1) WRONG PARAMETERS
        H_C_AccountTeamMemberHelper helper =
        	H_C_AccountTeamMemberHelper.createHelperByFilter(null);
        System.assertEquals(null, helper.getATMsByAccountId(null));
        System.assertEquals(0, helper.getATMsByAccountId(account1.Id).size());
        System.assertEquals(0, helper.allTeamMembers.size());
        
        //2) CORRECT PARAMETERS
        helper = H_C_AccountTeamMemberHelper.createHelperByATMsList(teamMembers);
        System.assertEquals(3, helper.allTeamMembers.size());
        
        AccountTeamMember[] selectedTeamMembers = helper.getATMsByAccountId(account1.Id);
        System.assertEquals(2, selectedTeamMembers.size());
        System.assert(teamMember1.Id == selectedTeamMembers[0].Id && teamMember2.Id == selectedTeamMembers[1].Id
            || teamMember1.Id == selectedTeamMembers[1].Id && teamMember2.Id == selectedTeamMembers[0].Id);
        
        selectedTeamMembers = helper.getATMsByAccountId(account2.Id);
        System.assertEquals(1, selectedTeamMembers.size());
        System.assertEquals(teamMember3.Id, selectedTeamMembers[0].Id);
    }
    
    @IsTest
    private static void testATMHelper_getATMsByAccountsIds()
    {
    	//create test data
        //disable triggers to improve performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        //create accounts
        Account account1 = H_C_UnitTestUtils.createAccount('Account1');
        Account account2 = H_C_UnitTestUtils.createAccount('Account2');
        Account account3 = H_C_UnitTestUtils.createAccount('Account3');
        
        //create SF users
        User user1 = H_C_UnitTestUtils.createSfUser('User1');
        User user2 = H_C_UnitTestUtils.createSfUser('User2');
        
        //create team members
        String operableTeamRole = 'Account Manager';
        AccountTeamMember teamMember11 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account1.Id, user1.Id, operableTeamRole);
        AccountTeamMember teamMember21 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account2.Id, user1.Id, operableTeamRole);
        AccountTeamMember teamMember31 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account3.Id, user2.Id, operableTeamRole);
        	
        AccountTeamMember[] teamMembers = new AccountTeamMember[] {
        	teamMember11, teamMember21, teamMember31};
        insert teamMembers;
        
        //1) WRONG PARAMETERS
        H_C_AccountTeamMemberHelper helper =
        	H_C_AccountTeamMemberHelper.createHelperByFilter(null);
        System.assertEquals(null, helper.getATMsByAccountsIds(null));
        System.assertEquals(0, helper.getATMsByAccountsIds(new String[] {account1.Id}).size());
        System.assertEquals(0, helper.allTeamMembers.size());
        
        //2) CORRECT PARAMETERS
        helper = H_C_AccountTeamMemberHelper.createHelperByATMsList(teamMembers);
        System.assertEquals(3, helper.allTeamMembers.size());
        
        //2.1) test the 1st account only
        AccountTeamMember[] selectedTeamMembers = helper.getATMsByAccountsIds(new String[] {account1.Id});
        System.assertEquals(1, selectedTeamMembers.size());
        System.assertEquals(teamMember11.Id, selectedTeamMembers[0].Id);
        
        //2.2) test the 2nd account only
        selectedTeamMembers = helper.getATMsByAccountsIds(new String[] {account2.Id});
        System.assertEquals(1, selectedTeamMembers.size());
        System.assertEquals(teamMember21.Id, selectedTeamMembers[0].Id);
        
        //2.3) test the 1st and the 3rd accounts
        selectedTeamMembers = helper.getATMsByAccountsIds(new String[] {account1.Id, account3.Id});
        System.assertEquals(2, selectedTeamMembers.size());
        System.assert(teamMember11.Id == selectedTeamMembers[0].Id && teamMember31.Id == selectedTeamMembers[1].Id
            || teamMember11.Id == selectedTeamMembers[1].Id && teamMember31.Id == selectedTeamMembers[0].Id);
    }
    
    @IsTest
    private static void testATMHelper_getATMsByUserId()
    {
    	//create test data
        //disable triggers to improve performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        //create accounts
        Account account1 = H_C_UnitTestUtils.createAccount('Account1');
        Account account2 = H_C_UnitTestUtils.createAccount('Account2');
        Account account3 = H_C_UnitTestUtils.createAccount('Account3');
        
        //create SF users
        User user1 = H_C_UnitTestUtils.createSfUser('User1');
        User user2 = H_C_UnitTestUtils.createSfUser('User2');
        
        //create team members
        String operableTeamRole = 'Account Manager';
        AccountTeamMember teamMember11 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account1.Id, user1.Id, operableTeamRole);
        AccountTeamMember teamMember21 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account2.Id, user1.Id, operableTeamRole);
        AccountTeamMember teamMember31 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account3.Id, user2.Id, operableTeamRole);
        	
        AccountTeamMember[] teamMembers = new AccountTeamMember[] {
        	teamMember11, teamMember21, teamMember31};
        insert teamMembers;
        
        //1) WRONG PARAMETERS
        H_C_AccountTeamMemberHelper helper =
        	H_C_AccountTeamMemberHelper.createHelperByFilter(null);
        System.assertEquals(null, helper.getATMsByUserId(null));
        System.assertEquals(0, helper.getATMsByUserId(user1.Id).size());
        System.assertEquals(0, helper.allTeamMembers.size());
        
        //2) CORRECT PARAMETERS
        helper = H_C_AccountTeamMemberHelper.createHelperByATMsList(teamMembers);
        System.assertEquals(3, helper.allTeamMembers.size());
        
        //2.1) test the 1st user
        AccountTeamMember[] selectedTeamMembers = helper.getATMsByUserId(user1.Id);
        System.assertEquals(2, selectedTeamMembers.size());
        System.assert(teamMember11.Id == selectedTeamMembers[0].Id && teamMember21.Id == selectedTeamMembers[1].Id
            || teamMember11.Id == selectedTeamMembers[1].Id && teamMember21.Id == selectedTeamMembers[0].Id);
        
        //2.2) test the 2nd user
        selectedTeamMembers = helper.getATMsByUserId(user2.Id);
        System.assertEquals(1, selectedTeamMembers.size());
        System.assertEquals(teamMember31.Id, selectedTeamMembers[0].Id);
    }
    
    @IsTest
    private static void testATMHelper_getATMByAccountIdAndUserId()
    {
    	//disable triggers to improve performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
    	
    	//create test data
        //create accounts
        Account account1 = H_C_UnitTestUtils.createAccount('Account1');
        Account account2 = H_C_UnitTestUtils.createAccount('Account2');
        
        //create SF users
        User user1 = H_C_UnitTestUtils.createSfUser('User1');
        User user2 = H_C_UnitTestUtils.createSfUser('User2');
        
        //create team members
        String operableTeamRole = 'Account Manager';
        AccountTeamMember teamMember11 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account1.Id, user1.Id, operableTeamRole);
        AccountTeamMember teamMember21 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account2.Id, user2.Id, operableTeamRole);
        	
        AccountTeamMember[] teamMembers =
        	new AccountTeamMember[] {teamMember11, teamMember21};
        insert teamMembers;
        
        //1) WRONG PARAMETERS
        H_C_AccountTeamMemberHelper helper =
        	H_C_AccountTeamMemberHelper.createHelperByFilter(null);
        System.assertEquals(null, helper.getATMByAccountIdAndUserId(null, null));
        System.assertEquals(null, helper.getATMByAccountIdAndUserId(account1.Id, user1.Id));
        
        //2) CORRECT PARAMETERS
        helper = H_C_AccountTeamMemberHelper.createHelperByATMsList(teamMembers);
        System.assertEquals(2, helper.allTeamMembers.size());
        
        //2.1) get the 1st ATM
        AccountTeamMember selectedATM = helper.getATMByAccountIdAndUserId(account1.Id, user1.Id);
        System.assertEquals(teamMember11.Id, selectedATM.Id);
        
        //2.2) get the 2nd ATM
        selectedATM = helper.getATMByAccountIdAndUserId(account2.Id, user2.Id);
        System.assertEquals(teamMember21.Id, selectedATM.Id);
        
        //2.3) try to get unknown ATM
        selectedATM = helper.getATMByAccountIdAndUserId(account1.Id, user2.Id);
        System.assertEquals(null, selectedATM);
    }
    
    @IsTest
    private static void testATMHelper_extractUsersIds()
    {
    	//create test data
        //disable triggers to improve performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        //create accounts
        Account account1 = H_C_UnitTestUtils.createAccount('Account1');
        Account account2 = H_C_UnitTestUtils.createAccount('Account2');
        Account account3 = H_C_UnitTestUtils.createAccount('Account3');
        
        //create SF users
        User user1 = H_C_UnitTestUtils.createSfUser('User1');
        User user2 = H_C_UnitTestUtils.createSfUser('User2');
        
        //create team members
        String operableTeamRole = 'Account Manager';
        AccountTeamMember teamMember11 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account1.Id, user1.Id, operableTeamRole);
        AccountTeamMember teamMember21 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account2.Id, user1.Id, operableTeamRole);
        AccountTeamMember teamMember31 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account3.Id, user2.Id, operableTeamRole);
        	
        AccountTeamMember[] teamMembers = new AccountTeamMember[] {
        	teamMember11, teamMember21, teamMember31};
        insert teamMembers;
        
        //1) CORRECT PARAMETERS
        H_C_AccountTeamMemberHelper helper = H_C_AccountTeamMemberHelper.createHelperByATMsList(teamMembers);
        System.assertEquals(3, helper.allTeamMembers.size());
        
        //extract users Ids
        Set<String> usersIds = helper.extractUsersIds();
        System.assertEquals(2, usersIds.size());
        System.assert(usersIds.contains(user1.Id) && usersIds.contains(user2.Id));
    }
    //
    
    
    
    
    
    //
    //Unit tests for 'H_C_AccountShareHelper' class
    //
    @IsTest
    private static void testAccountShareHelper_getShareByAccountIdAndUserId()
    {
    	//disable triggers to improve performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
    	//create test data
        //create accounts
        Account account1 = H_C_UnitTestUtils.createAccount('Account1');
        Account account2 = H_C_UnitTestUtils.createAccount('Account2');
        
        //create SF users
        User user1 = H_C_UnitTestUtils.createSfUser('User1');
        User user2 = H_C_UnitTestUtils.createSfUser('User2');
        
        //create team members
        String teamMemberRole = 'Account Manager';
        AccountTeamMember teamMember1 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account1.Id, user1.Id, teamMemberRole);
        AccountTeamMember teamMember2 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account2.Id, user2.Id, teamMemberRole);
        insert new AccountTeamMember[] {teamMember1, teamMember2};
        
        //1) WRONG PARAMETERS
        H_C_AccountShareHelper helper = H_C_AccountShareHelper.createHelperBySharesList(null);
        System.assertEquals(null, helper.getShareByAccountIdAndUserId(null, null));
        System.assertEquals(null, helper.getShareByAccountIdAndUserId(account1.Id, user1.Id));
        System.assertEquals(0, helper.allAccountShares.size());
        
        //2) CORRECT PARAMETERS
        H_C_AccountShareDAO.Filter filter = new H_C_AccountShareDAO.Filter();
        filter.accountsIds = new String[] {account1.Id, account2.Id};
        helper = H_C_AccountShareHelper.createHelperByFilter(filter);
        //account onwers and team members should have 1 share => 2 owners + 2 members = 4 shares
        //System.assertEquals(4, helper.allAccountShares.size());
        /*
        //test 2.1: check a share for an owner of the 1st account
        AccountShare share = helper.getShareByAccountIdAndUserId(account1.Id, UserInfo.getUserId());
        System.assertEquals(account1.Id, share.AccountId);
        System.assertEquals(UserInfo.getUserId(), share.UserOrGroupId);
        System.assertEquals('Owner', share.RowCause);
        
        //test 2.2: check a share for an owner of the 2nd account
        share = helper.getShareByAccountIdAndUserId(account2.Id, UserInfo.getUserId());
        System.assertEquals(account2.Id, share.AccountId);
        System.assertEquals(UserInfo.getUserId(), share.UserOrGroupId);
        System.assertEquals('Owner', share.RowCause);
        
        //test 2.3: check a share for a team member of the 1st account
        share = helper.getShareByAccountIdAndUserId(account1.Id, user1.Id);
        System.assertEquals(account1.Id, share.AccountId);
        System.assertEquals(user1.Id, share.UserOrGroupId);
        System.assertEquals('Team', share.RowCause);
        
        //test 2.4: check a share for a team member of the 2nd account
        share = helper.getShareByAccountIdAndUserId(account2.Id, user2.Id);
        System.assertEquals(account2.Id, share.AccountId);
        System.assertEquals(user2.Id, share.UserOrGroupId);
        System.assertEquals('Team', share.RowCause);
        */
    }
    //
}