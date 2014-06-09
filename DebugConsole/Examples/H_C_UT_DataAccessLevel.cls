//
//This class contains Unit tests for all classes which provide access to objects.
//Used abbreviations:
// -//Used abbreviations:
// - UT means 'Unit test'
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (10-09-2013)
@IsTest
public class H_C_UT_DataAccessLevel
{
	//
    //Unit tests for 'H_C_AccountDAO' class
    //
    @IsTest
    private static void testAccountDAO_getMaps()
    {
        System.assertNotEquals(null, H_C_AccountDAO.getMapOfFieldsForExternalIds());
        System.assertNotEquals(null, H_C_AccountDAO.getMapOfFieldsForExternalParentIds());
    }
    
    @IsTest
    private static void testAccountDAO_getAccountsByFilter()
    {
    	//disable triggers to improve performance of the test
    	H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
    	
    	//WRONG PARAMETERS
        System.assertEquals(null, H_C_AccountDAO.getAccountsByFilter(null));
        
        //CORRECT PARAMETERS
        //create test data
        Account account1 = H_C_UnitTestUtils.constructAccount('Contract Account1');
        account1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
            
        Account account2 = H_C_UnitTestUtils.constructAccount('Key Region Account1');
        account2.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        
        Account account3 = H_C_UnitTestUtils.constructAccount('Transactional Account1');
        account3.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        
        insert new Account[] {account1, account2, account3};
        
        account3.ParentId = account2.Id;
        account2.ParentId = account1.Id;
        update new Account[] {account2, account3};
        
        //TEST #1
    	H_C_AccountDAO.Filter filter = new H_C_AccountDAO.Filter();
    	filter.accountsIds = new String[] {account1.Id, account2.Id};
    	Account[] resultAccounts = H_C_AccountDAO.getAccountsByFilter(filter);
    	
    	System.assertEquals(2, resultAccounts.size());
    	System.assert(resultAccounts[0].Id == account1.Id && resultAccounts[1].Id == account2.Id
    		|| resultAccounts[1].Id == account1.Id && resultAccounts[0].Id == account2.Id);
    	
    	//TEST #2
    	filter.accountRecordTypes = new String[] {H_C_AccountRecordType.CONTRACT_ACCOUNT};
    	resultAccounts = H_C_AccountDAO.getAccountsByFilter(filter);
    	
    	System.assertEquals(1, resultAccounts.size());
    	System.assert(resultAccounts[0].Id == account1.Id);
    	
    	//TEST #3
    	filter.accountRecordTypes = null;
    	filter.ignoreAccountsWithoutParent = true;
    	resultAccounts = H_C_AccountDAO.getAccountsByFilter(filter);
    	
    	System.assertEquals(1, resultAccounts.size());
    	System.assert(resultAccounts[0].Id == account2.Id);
    	
    	//TEST #4
    	filter = new H_C_AccountDAO.Filter();
    	filter.parentAccountsIds = new String[] {account1.Id, account2.Id};
    	filter.ignorableAccountsIds = new String[] {account2.Id};
    	
    	resultAccounts = H_C_AccountDAO.getAccountsByFilter(filter);
    	
    	System.assertEquals(1, resultAccounts.size());
    	System.assert(resultAccounts[0].Id == account3.Id);
    }
    
    @IsTest
    private static void testAccountDAO_getAccountsByIds()
    {
    	//disable triggers to improve performance of the test
    	H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
    	
        //wrong parameters
        System.assertEquals(null, H_C_AccountDAO.getAccountsByIds(null));
        
        //correct parameters
        Account account1 = H_C_UnitTestUtils.constructAccount('Account1');
        Account account2 = H_C_UnitTestUtils.constructAccount('Account2');
        Account account3 = H_C_UnitTestUtils.constructAccount('Account3');
        insert new Account[] {account1, account2, account3};
        
        Account[] accounts = H_C_AccountDAO.getAccountsByIds(new String[] {account1.Id, account2.Id});
        System.assertEquals(2, accounts.size());
        System.assert(account1.Id == accounts[0].Id && account2.Id == accounts[1].Id
            || account1.Id == accounts[1].Id && account2.Id == accounts[0].Id);
    }
    
    @IsTest
    private static void testAccountDAO_getAccountsByParentsIds()
    {
    	//disable triggers to improve performance of the test
    	H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
    	
        //wrong parameters
        System.assertEquals(null, H_C_AccountDAO.getAccountsByParentsIds(null));
        
        //correct parameters
        Account parentAccount1 = H_C_UnitTestUtils.constructAccount('Parent Account1');
        Account parentAccount2 = H_C_UnitTestUtils.constructAccount('Parent Account2');
        insert new Account[] {parentAccount1, parentAccount2};
        
        Account account1 = H_C_UnitTestUtils.constructAccount('Account1', parentAccount1.Id);
        Account account2 = H_C_UnitTestUtils.constructAccount('Account2', parentAccount2.Id);
        Account account3 = H_C_UnitTestUtils.constructAccount('Account3');
        insert new Account[] {account1, account2, account3};
        
        Account[] accounts = H_C_AccountDAO.getAccountsByParentsIds(
        	new String[] {parentAccount1.Id, parentAccount2.Id});
        System.assertEquals(2, accounts.size());
        System.assert(account1.Id == accounts[0].Id && account2.Id == accounts[1].Id
            || account1.Id == accounts[1].Id && account2.Id == accounts[0].Id);
    }
    
    @IsTest
    private static void testAccountDAO_getAccountsByExternalIds()
    {
    	//disable triggers to improve performance of the test
    	H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
    	
        //wrong parameters
        System.assertEquals(null, H_C_AccountDAO.getAccountsByExternalIds(null, null));
        
        //correct parameters
        //disable all triggers to improve the performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        Account account1 = H_C_UnitTestUtils.constructAccount('Contract Account1');
        account1.CUST_NUMBER_OP_UNIT_SFDC__c = 'External_Id1';
        account1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
        
        Account account2 = H_C_UnitTestUtils.constructAccount('Contract Account2');
        account2.CUST_NUMBER_OP_UNIT_SFDC__c = 'External_Id2';
        account2.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
            
        Account account3 = H_C_UnitTestUtils.constructAccount('Key Region Account1');
        account3.KEY_ACCOUNT_NUMBER_SFDC__c = 'External_Id3';
        account3.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        
        insert new Account[] {account1, account2, account3};
        
        Account[] accounts = H_C_AccountDAO.getAccountsByExternalIds(
        	new String[] {'External_Id1', 'External_Id2'}, H_C_AccountRecordType.CONTRACT_ACCOUNT);
        System.assertEquals(2, accounts.size());
        System.assert(account1.Id == accounts[0].Id && account2.Id == accounts[1].Id
            || account1.Id == accounts[1].Id && account2.Id == accounts[0].Id);
        
        accounts = H_C_AccountDAO.getAccountsByExternalIds(new String[] {'External_Id3'},
            H_C_AccountRecordType.KEY_REGION_ACCOUNT);
        System.assertEquals(1, accounts.size());
        System.assert(account3.Id == accounts[0].Id);
    }
    
    @IsTest
    private static void testAccountDAO_getAccountsByRecordTypeNames()
    {
    	//disable triggers to improve performance of the test
    	H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
    	
        //wrong parameters
        System.assertEquals(null, H_C_AccountDAO.getAccountsByRecordTypeNames(null));
        
        //correct parameters
        //disable all triggers to improve the performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        Account account1 = H_C_UnitTestUtils.constructAccount('Contract Account1');
        account1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
            
        Account account2 = H_C_UnitTestUtils.constructAccount('Key Region Account1');
        account2.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        
        Account account3 = H_C_UnitTestUtils.constructAccount('Transactional Account1');
        account3.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
            H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        
        insert new Account[] {account1, account2, account3};
        
        //perform the method and check the results
        Account[] accounts = H_C_AccountDAO.getAccountsByRecordTypeNames(new String[] {
        	H_C_AccountRecordType.CONTRACT_ACCOUNT, H_C_AccountRecordType.KEY_REGION_ACCOUNT});
        System.assertEquals(2, accounts.size());
        System.assert(account1.Id == accounts[0].Id && account2.Id == accounts[1].Id
            || account1.Id == accounts[1].Id && account2.Id == accounts[0].Id);
        
        accounts = H_C_AccountDAO.getAccountsByRecordTypeNames(new String[] {
    		H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT});
        System.assertEquals(1, accounts.size());
        System.assert(account3.Id == accounts[0].Id);
        
        accounts = H_C_AccountDAO.getAccountsByRecordTypeNames(new String[] {
    		H_C_AccountRecordType.CONTRACT_ACCOUNT});
        System.assertEquals(1, accounts.size());
        System.assert(account1.Id == accounts[0].Id);
    }
    
    @IsTest
    private static void testAccountDAO_createQueryForAccountsWithoutProperParents()
    {
    	//disable triggers to avoid any changes in test data
    	H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
    	
        //wrong parameters
        System.assertEquals(null, H_C_AccountDAO.createQueryForAccountsWithoutProperParents(null));
        System.assertEquals(null, H_C_AccountDAO.createQueryForAccountsWithoutProperParents(new String[0]));
        System.assertEquals(null, H_C_AccountDAO.createQueryForAccountsWithoutProperParents(new String[] {'Unknown RTN'}));
        
        //correct parameters
        Account account1 = H_C_UnitTestUtils.constructAccount('Key Region Account1');
        account1.KEY_ACCOUNT_NUMBER_SFDC__c = 'External_Id2';
        account1.CUST_NUMBER_OP_UNIT_SFDC__c = 'External_Id1';
        account1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        insert account1;
        
        Account account2 = H_C_UnitTestUtils.constructAccount('Transactional Account1');
        account2.Site_Number_SFDC__c = 'Ext_Id3';
        account2.KEY_ACCOUNT_NUMBER_SFDC__c = 'External_Id2';
        account2.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        
        Account account3 = H_C_UnitTestUtils.constructAccount('Transactional Account2');
        account3.Site_Number_SFDC__c = 'Ext_Id4';
        account3.KEY_ACCOUNT_NUMBER_SFDC__c = 'External_Id2';
        account3.ParentId = account1.Id;
        account3.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        
        insert new Account[] {account2, account3};
        
        //test #1
        String query = H_C_AccountDAO.createQueryForAccountsWithoutProperParents(
        	new String[] {H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT});
        Account[] accounts = H_C_SoqlUtils.performQuery(query);
        System.assertEquals(1, accounts.size());
        System.assert(account2.Id == accounts[0].Id);
        
        //test #1
        query = H_C_AccountDAO.createQueryForAccountsWithoutProperParents(new String[] {
        	H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT, H_C_AccountRecordType.KEY_REGION_ACCOUNT});
        accounts = H_C_SoqlUtils.performQuery(query);
        System.assertEquals(2, accounts.size());
        System.assert(account1.Id == accounts[0].Id && account2.Id == accounts[1].Id
            || account1.Id == accounts[1].Id && account2.Id == accounts[0].Id);
    }
    
    @IsTest
    private static void testAccountDAO_createConditionByAccountId()
    {
    	//wrong parameters
    	System.assertEquals(null, H_C_AccountDAO.createConditionByAccountId(null, true));
    	
    	//correct parameters
    	//the 1st test
    	System.assertEquals('(Id = \'accountId\')', H_C_AccountDAO.createConditionByAccountId('accountId', false));
    	//the 2nd test
    	System.assertEquals('(Id = \'accountId\') OR (ParentId = \'accountId\') OR (Parent.ParentId = \'accountId\')',
    		H_C_AccountDAO.createConditionByAccountId('accountId', true));
    }
    
    @IsTest
    private static void testAccountDAO_getChildObjectsByAccountId()
    {
    	//wrong parameters
    	System.assertEquals(null, H_C_AccountDAO.getChildObjectsByAccountId(null, null, true));
    	System.assertEquals(null, H_C_AccountDAO.getChildObjectsByAccountId('accountId', null, true));
    	System.assertEquals(null, H_C_AccountDAO.getChildObjectsByAccountId(
    		'accountId', new H_C_SoqlQueryBuilder(null, null), true));
    	
    	//correct parameters
    	//disable all triggers to test the logic separately from them
		H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
    	
    	//prepare test data
    	Account account1 = H_C_UnitTestUtils.createAccount('Account1');
    	Opportunity opportunity11 = H_C_UnitTestUtils.constructOpportunity('Test Opportunity1', account1.Id);
    	
    	Account account2 = H_C_UnitTestUtils.createAccount('Account2', account1.Id);
    	Opportunity opportunity21 = H_C_UnitTestUtils.constructOpportunity('Test Opportunity2', account2.Id);
    	insert new Opportunity[] {opportunity11, opportunity21};
    	
    	//TEST #1: do no take objects from child accounts
    	H_C_SoqlQueryBuilder opportunitiesQueryBuilder = new H_C_SoqlQueryBuilder('Id, Name', 'Opportunities');
    	Opportunity[] opportunities = H_C_AccountDAO.getChildObjectsByAccountId(
    		account1.Id, opportunitiesQueryBuilder, false);
    	System.assertEquals(1, opportunities.size());
    	System.assertEquals(opportunity11.Id, opportunities[0].Id);
    	
    	//TEST #2: take objects from child accounts
    	opportunities = H_C_AccountDAO.getChildObjectsByAccountId(
    		account1.Id, opportunitiesQueryBuilder, true);
    	System.assertEquals(2, opportunities.size());
    	System.assert(opportunity11.Id == opportunities[0].Id && opportunity21.Id == opportunities[1].Id
    		|| opportunity11.Id == opportunities[1].Id && opportunity21.Id == opportunities[0].Id);
    }
    //
    
    
    
    
    
    //
    //Unit tests for 'H_C_AccountShareDAO' class
    //
    @IsTest
    private static void testAccountShareDAO_getAccountSharesByFilter()
    {
    	//WRONG PARAMETERS
        System.assertEquals(null, H_C_AccountShareDAO.getAccountSharesByFilter(null));
        System.assertEquals(null, H_C_AccountShareDAO.getAccountSharesByFilter(
        	new H_C_AccountShareDAO.Filter()));
        
        //CORRECT PARAMETERS
        //Create Test Data:
        //disable all triggers to improve the performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        //create accounts
        Account account1 = H_C_UnitTestUtils.constructAccount('Account1');
        Account account2 = H_C_UnitTestUtils.constructAccount('Account2');
        insert new Account[] {account1, account2};
        
        //create filter
        H_C_AccountShareDAO.Filter filter = new H_C_AccountShareDAO.Filter();
        
        //TEST #1: test selection by accounts Ids (account owners should have shares)
        //test 1.1: select shares for 1st account only
        filter.accountsIds = new String[] {account1.Id};
        AccountShare[] shares = H_C_AccountShareDAO.getAccountSharesByFilter(filter);
        //System.assertEquals(1, shares.size());
    	System.assertEquals('Owner', shares[0].RowCause);
    	System.assertEquals(UserInfo.getUserId(), shares[0].UserOrGroupId);
    	
        //test 1.2: select shares for both accounts
        filter.accountsIds = new String[] {account1.Id, account2.Id};
        shares = H_C_AccountShareDAO.getAccountSharesByFilter(filter);
        //System.assertEquals(2, shares.size());
        /*
        for (AccountShare share : shares)
        {
        	System.assertEquals('Owner', share.RowCause);
        	System.assertEquals(UserInfo.getUserId(), share.UserOrGroupId);
        }
        
        
        //Add Additional Test Data
        //create SF user
        User user1 = H_C_UnitTestUtils.createSfUser('User1');
        User user2 = H_C_UnitTestUtils.createSfUser('User2');
        //create team members
        String teamMemberRole = 'Account Manager';
        AccountTeamMember teamMember11 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account1.Id, user1.Id, teamMemberRole);
        AccountTeamMember teamMember12 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account1.Id, user2.Id, teamMemberRole);
        
        AccountTeamMember teamMember21 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account2.Id, user1.Id, teamMemberRole);
        AccountTeamMember teamMember22 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account2.Id, user2.Id, teamMemberRole);
        insert new AccountTeamMember[] {teamMember11, teamMember12, teamMember21, teamMember22};
        
        
        //TEST #2: test selection by accounts Ids (an every owner and team member should have 1 share)
        filter.accountsIds = new String[] {account1.Id};
        shares = H_C_AccountShareDAO.getAccountSharesByFilter(filter);
        System.assertEquals(3, shares.size());
        
        //TEST #3: test selection by accounts Ids and row cause (every team member should have 1 share)
        filter.rowCauses = new String[] {'Team'};
        shares = H_C_AccountShareDAO.getAccountSharesByFilter(filter);
        System.assertEquals(2, shares.size());
        for (AccountShare share : shares)
        {
        	System.assertEquals('Team', share.RowCause);
        }
        
        //TEST #4: test selection by accounts Ids, row cause and userId
        filter.usersOrGroupsIds = new String[] {user1.Id};
        shares = H_C_AccountShareDAO.getAccountSharesByFilter(filter);
        System.assertEquals(1, shares.size());
    	System.assertEquals('Team', shares[0].RowCause);
    	System.assertEquals(user1.Id, shares[0].UserOrGroupId);
    	System.assertEquals(account1.Id, shares[0].AccountId);
    	
    	//TEST #5: test selection by team members only
    	filter = new H_C_AccountShareDAO.Filter();
    	filter.teamMembers = new AccountTeamMember[] {teamMember11, teamMember22};
    	shares = H_C_AccountShareDAO.getAccountSharesByFilter(filter);
        System.assertEquals(2, shares.size());
        System.assert(account1.Id == shares[0].AccountId && account2.Id == shares[1].AccountId
    		|| account2.Id == shares[0].AccountId && account1.Id == shares[1].AccountId);
    	System.assert(user1.Id == shares[0].UserOrGroupId && user2.Id == shares[1].UserOrGroupId
    		|| user2.Id == shares[0].UserOrGroupId && user1.Id == shares[1].UserOrGroupId);
    	*/
    }
    //
    
    
    
    
    
    //
    //Unit tests for 'H_C_AccountTeamMemberDAO' class
    //
    @IsTest
    private static void testATM_DAO_getATMsByFilter()
    {
    	//WRONG PARAMETERS
        System.assertEquals(null, H_C_AccountTeamMemberDAO.getATMsByFilter(null));
        System.assertEquals(null, H_C_AccountTeamMemberDAO.getATMsByFilter(
        	new H_C_AccountTeamMemberDAO.Filter()));
        
        //CORRECT PARAMETERS
        //disable all triggers to improve the performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        //create accounts
        Account account1 = H_C_UnitTestUtils.constructAccount('Contract Account1');
        Account account2 = H_C_UnitTestUtils.constructAccount('Key Region Account1');
        Account account3 = H_C_UnitTestUtils.constructAccount('Transactional Account1');
        Account account4 = H_C_UnitTestUtils.constructAccount('Transactional Account2');
        Account[] accounts = new Account[] {account1, account2, account3, account4};
        insert accounts;
         
        account1.CUST_NUMBER_OP_UNIT_SFDC__c = 'Ext_Id1';
        account1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
        
        account2.KEY_ACCOUNT_NUMBER_SFDC__c = 'Ext_Id2';
        account2.CUST_NUMBER_OP_UNIT_SFDC__c = 'Ext_Id1';
        account2.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        account2.ParentId = account1.Id;
        
        account3.Site_Use_ID_SFDC__c = 'Ext_Id3';
        account3.KEY_ACCOUNT_NUMBER_SFDC__c = 'Ext_Id2';
        account3.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        account3.ParentId = account2.Id;
        
        account4.Site_Use_ID_SFDC__c = 'Ext_Id4';
        account4.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        account4.ParentId = null;
        
        update accounts;
        
        //create SF users
        User user1 = H_C_UnitTestUtils.createSfUser('User1');
        User user2 = H_C_UnitTestUtils.createSfUser('User2');
        User user3 = H_C_UnitTestUtils.createSfUser('User3');
        
        //create team members
        String operableTeamRole = 'Account Manager';
        String ignorableTeamRole = 'Super Manager';
        AccountTeamMember teamMember1 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account1.Id, user1.Id, operableTeamRole);
        AccountTeamMember teamMember2 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account2.Id, user2.Id, ignorableTeamRole);
        AccountTeamMember teamMember3 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account3.Id, user3.Id, operableTeamRole);
        AccountTeamMember teamMember4 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account4.Id, user1.Id, operableTeamRole);
        insert new AccountTeamMember[] {teamMember1, teamMember2, teamMember3, teamMember4};
    	
    	//1.1) perform the method and check the results
    	H_C_AccountTeamMemberDAO.Filter filter = new H_C_AccountTeamMemberDAO.Filter();
    	filter.accountsIds = new String[] {account1.Id, account2.Id};
    	filter.accountRecordTypes = new String[] {H_C_AccountRecordType.CONTRACT_ACCOUNT};
    	AccountTeamMember[] teamMembers = H_C_AccountTeamMemberDAO.getATMsByFilter(filter);
    	
    	System.assertEquals(1, teamMembers.size());
    	System.assert(teamMember1.Id == teamMembers[0].Id);
    	
    	//2.1) perform the method and check the results
    	filter = new H_C_AccountTeamMemberDAO.Filter();
    	filter.accountRecordTypes = new String[] {H_C_AccountRecordType.CONTRACT_ACCOUNT,
    		H_C_AccountRecordType.KEY_REGION_ACCOUNT};
    	filter.ignorableTeamRoles = new String[] {ignorableTeamRole};
    	teamMembers = H_C_AccountTeamMemberDAO.getATMsByFilter(filter);
    	System.assertEquals(1, teamMembers.size());
    	System.assert(teamMember1.Id == teamMembers[0].Id);
    	
    	//3.1) perform the method and check the results
    	filter = new H_C_AccountTeamMemberDAO.Filter();
    	filter.parentAccountsIds = new String[] {account1.Id, account2.Id};
    	filter.ignoreInactiveUsers = true;
    	teamMembers = H_C_AccountTeamMemberDAO.getATMsByFilter(filter);
    	System.assertEquals(2, teamMembers.size());
    	System.assert(teamMember2.Id == teamMembers[0].Id && teamMember3.Id == teamMembers[1].Id
    		|| teamMember2.Id == teamMembers[1].Id && teamMember3.Id == teamMembers[0].Id);
    	
    	//3.2) perform the method and check the results
    	filter.startModifiedDateTime = DateTime.now().addDays(1);
    	teamMembers = H_C_AccountTeamMemberDAO.getATMsByFilter(filter);
    	System.assertEquals(0, teamMembers.size());
    	
    	//4.1) perform the method and check the results
    	filter = new H_C_AccountTeamMemberDAO.Filter();
    	filter.accountRecordTypes = new String[] {H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT};
    	teamMembers = H_C_AccountTeamMemberDAO.getATMsByFilter(filter);
    	System.assertEquals(2, teamMembers.size());
    	System.assert(teamMember3.Id == teamMembers[0].Id && teamMember4.Id == teamMembers[1].Id
    		|| teamMember3.Id == teamMembers[1].Id && teamMember4.Id == teamMembers[0].Id);
    	
    	//4.2) perform the method and check the results
    	filter.ignoreAccountsWithoutParent = true;
    	teamMembers = H_C_AccountTeamMemberDAO.getATMsByFilter(filter);
    	System.assertEquals(1, teamMembers.size());
    	System.assert(teamMember3.Id == teamMembers[0].Id);
    	
    	//5.1) perform the method and check the results
    	filter = new H_C_AccountTeamMemberDAO.Filter();
    	filter.parentAccountRecordTypes = new String[] {H_C_AccountRecordType.CONTRACT_ACCOUNT};
    	teamMembers = H_C_AccountTeamMemberDAO.getATMsByFilter(filter);
    	System.assertEquals(1, teamMembers.size());
    	System.assert(teamMember2.Id == teamMembers[0].Id);
    }
    
    @IsTest
    private static void testATM_DAO_getParentAccountsIdsByFilter()
    {
    	//WRONG PARAMETERS
        System.assertEquals(null, H_C_AccountTeamMemberDAO.getParentAccountsIdsByFilter(null));
        System.assertEquals(null, H_C_AccountTeamMemberDAO.getParentAccountsIdsByFilter(
        	new H_C_AccountTeamMemberDAO.Filter()));
        
        //CORRECT PARAMETERS
        //disable all triggers to improve the performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        //create accounts
        Account account1 = H_C_UnitTestUtils.constructAccount('Contract Account1');
        Account account2 = H_C_UnitTestUtils.constructAccount('Key Region Account1');
        Account account3 = H_C_UnitTestUtils.constructAccount('Transactional Account1');
        Account account4 = H_C_UnitTestUtils.constructAccount('Transactional Account2');
        Account[] accounts = new Account[] {account1, account2, account3, account4};
        insert accounts;
         
        account1.CUST_NUMBER_OP_UNIT_SFDC__c = 'Ext_Id1';
        account1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
        
        account2.KEY_ACCOUNT_NUMBER_SFDC__c = 'Ext_Id2';
        account2.CUST_NUMBER_OP_UNIT_SFDC__c = 'Ext_Id1';
        account2.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        account2.ParentId = account1.Id;
        
        account3.Site_Use_ID_SFDC__c = 'Ext_Id3';
        account3.KEY_ACCOUNT_NUMBER_SFDC__c = 'Ext_Id2';
        account3.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        account3.ParentId = account2.Id;
        
        account4.Site_Use_ID_SFDC__c = 'Ext_Id4';
        account4.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        account4.ParentId = null;
        
        update accounts;
        
        //create SF users
        User user1 = H_C_UnitTestUtils.createSfUser('User1');
        
        //create team members
        String operableTeamRole = 'Account Manager';
        String ignorableTeamRole = 'Super Manager';
        AccountTeamMember teamMember1 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account1.Id, user1.Id, operableTeamRole);
        AccountTeamMember teamMember2 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account2.Id, user1.Id, ignorableTeamRole);
        AccountTeamMember teamMember3 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account3.Id, user1.Id, operableTeamRole);
        AccountTeamMember teamMember4 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account4.Id, user1.Id, operableTeamRole);
        insert new AccountTeamMember[] {teamMember1, teamMember2, teamMember3, teamMember4};
    	
    	//perform the method and check the results
    	H_C_AccountTeamMemberDAO.Filter filter = new H_C_AccountTeamMemberDAO.Filter();
    	filter.accountRecordTypes = new String[] {H_C_AccountRecordType.KEY_REGION_ACCOUNT,
    		H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT};
    	filter.ignoreAccountsWithoutParent = true;
    	String[] parentAccountsIds = H_C_AccountTeamMemberDAO.getParentAccountsIdsByFilter(filter);
    	System.assertEquals(2, parentAccountsIds.size());
    	System.assert(account1.Id == parentAccountsIds[0] && account2.Id == parentAccountsIds[1]
    		|| account1.Id == parentAccountsIds[1] && account2.Id == parentAccountsIds[0]);
    }
    
    @IsTest
    private static void testATM_DAO_getAccountsIdsByFilter()
    {
    	//WRONG PARAMETERS
        System.assertEquals(null, H_C_AccountTeamMemberDAO.getAccountsIdsByFilter(null));
        System.assertEquals(null, H_C_AccountTeamMemberDAO.getAccountsIdsByFilter(
        	new H_C_AccountTeamMemberDAO.Filter()));
        
        //CORRECT PARAMETERS
        //disable all triggers to improve the performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        //create accounts
        Account account1 = H_C_UnitTestUtils.constructAccount('Contract Account1');
        Account account2 = H_C_UnitTestUtils.constructAccount('Key Region Account1');
        Account account3 = H_C_UnitTestUtils.constructAccount('Transactional Account1');
        Account account4 = H_C_UnitTestUtils.constructAccount('Transactional Account2');
        Account[] accounts = new Account[] {account1, account2, account3, account4};
        insert accounts;
         
        account1.CUST_NUMBER_OP_UNIT_SFDC__c = 'Ext_Id1';
        account1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
        
        account2.KEY_ACCOUNT_NUMBER_SFDC__c = 'Ext_Id2';
        account2.CUST_NUMBER_OP_UNIT_SFDC__c = 'Ext_Id1';
        account2.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        account2.ParentId = account1.Id;
        
        account3.Site_Use_ID_SFDC__c = 'Ext_Id3';
        account3.KEY_ACCOUNT_NUMBER_SFDC__c = 'Ext_Id2';
        account3.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        account3.ParentId = account2.Id;
        
        account4.Site_Use_ID_SFDC__c = 'Ext_Id4';
        account4.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        account4.ParentId = null;
        
        update accounts;
        
        //create SF users
        User user1 = H_C_UnitTestUtils.createSfUser('User1');
        
        //create team members
        String operableTeamRole = 'Account Manager';
        String ignorableTeamRole = 'Super Manager';
        AccountTeamMember teamMember1 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account1.Id, user1.Id, operableTeamRole);
        AccountTeamMember teamMember2 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account2.Id, user1.Id, ignorableTeamRole);
        AccountTeamMember teamMember3 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account3.Id, user1.Id, operableTeamRole);
        AccountTeamMember teamMember4 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account4.Id, user1.Id, operableTeamRole);
        insert new AccountTeamMember[] {teamMember1, teamMember2, teamMember3, teamMember4};
    	
    	//perform the method and check the results
    	H_C_AccountTeamMemberDAO.Filter filter = new H_C_AccountTeamMemberDAO.Filter();
    	filter.accountRecordTypes = new String[] {H_C_AccountRecordType.KEY_REGION_ACCOUNT,
    		H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT};
    	filter.ignoreAccountsWithoutParent = true;
    	String[] accountsIds = H_C_AccountTeamMemberDAO.getAccountsIdsByFilter(filter);
    	System.assertEquals(2, accountsIds.size());
    	System.assert(account2.Id == accountsIds[0] && account3.Id == accountsIds[1]
    		|| account2.Id == accountsIds[1] && account3.Id == accountsIds[0]);
    }
    
    @IsTest
    private static void testATM_DAO_getATMsByAccountsIds()
    {
    	//WRONG PARAMETERS
        System.assertEquals(null, H_C_AccountTeamMemberDAO.getATMsByAccountsIds(null));
        System.assertEquals(null, H_C_AccountTeamMemberDAO.getATMsByAccountsIds(new String[0]));
        
        //CORRECT PARAMETERS
        //disable all triggers to improve the performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        //create accounts
        Account account1 = H_C_UnitTestUtils.constructAccount('Contract Account1');
        Account account2 = H_C_UnitTestUtils.constructAccount('Key Region Account1');
        insert new Account[] {account1, account2};
        
        //create SF users
        User user1 = H_C_UnitTestUtils.createSfUser('User1');
        
        //create team members
        String operableTeamRole = 'Account Manager';
        AccountTeamMember teamMember1 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account1.Id, user1.Id, operableTeamRole);
        AccountTeamMember teamMember2 = H_C_UnitTestUtils.constructAccountTeamMember(
        	account2.Id, user1.Id, operableTeamRole);
        insert new AccountTeamMember[] {teamMember1, teamMember2};
    	
    	//1) perform the method and check the results
    	AccountTeamMember[] teamMembers = H_C_AccountTeamMemberDAO.getATMsByAccountsIds(
    		new String[] {account1.Id, account2.Id});
    	System.assertEquals(2, teamMembers.size());
    	System.assert(teamMember1.Id == teamMembers[0].Id && teamMember2.Id == teamMembers[1].Id
    		|| teamMember1.Id == teamMembers[1].Id && teamMember2.Id == teamMembers[0].Id);
    	
    	//2) perform the method and check the results
    	teamMembers = H_C_AccountTeamMemberDAO.getATMsByAccountsIds(new String[] {account1.Id});
    	System.assertEquals(1, teamMembers.size());
    	System.assert(teamMember1.Id == teamMembers[0].Id);
    }
    //
    
    
    
    
        
    //
    //Unit tests for 'H_C_ActivityDAO' class
    //
    @IsTest(SeeAllData = true)
    private static void testActivityDAO_getOpenActivitiesByAccountId()
    {
    	//#IMPORTANT:
		//we must use 'SeeAllData = true' property here, because Unit tests can't select
		//list of 'OpenActivity' objects without it
    	
    	//wrong parameters
    	System.assertEquals(null, H_C_ActivityDAO.getOpenActivitiesByAccountId(null, true));
    	System.assertEquals(null, H_C_ActivityDAO.getOpenActivitiesByAccountId('wrongId', true));
    	
    	//correct parameters
    	//disable all triggers to test the logic separately from them
		H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
    	
    	//prepare test data
    	Account account1 = H_C_UnitTestUtils.createAccount('Account1');
    	Task task1 = H_C_UnitTestUtils.constructTask('Task1', Date.today(), account1.Id);
    	
    	Account account2 = H_C_UnitTestUtils.createAccount('Account2', account1.Id);
    	Task task2 = H_C_UnitTestUtils.constructTask('Task2', Date.today(), account2.Id);
    	insert new Task[] {task1, task2};
    	
    	//TEST #1: do no take objects from child account
    	OpenActivity[] activities = H_C_ActivityDAO.getOpenActivitiesByAccountId(account1.Id, false);
    	System.assertEquals(1, activities.size());
    	System.assertEquals(task1.Id, activities[0].Id);
    	
    	//TEST #2: take objects from child account
    	activities = H_C_ActivityDAO.getOpenActivitiesByAccountId(account1.Id, true);
    	System.assertEquals(2, activities.size());
    	System.assert(task1.Id == activities[0].Id && task2.Id == activities[1].Id
    		|| task1.Id == activities[1].Id && task2.Id == activities[0].Id);
    }
    
    @IsTest(SeeAllData = true)
    private static void testActivityDAO_getActivityHistoriesByAccountId()
    {
    	//#IMPORTANT:
		//we must use 'SeeAllData = true' property here, because Unit tests can't select
		//list of 'ActivityHistory' objects without it
    	
    	//wrong parameters
    	System.assertEquals(null, H_C_ActivityDAO.getActivityHistoriesByAccountId(null, true));
    	System.assertEquals(null, H_C_ActivityDAO.getActivityHistoriesByAccountId('wrongId', true));
    	
    	//correct parameters
    	//disable all triggers to test the logic separately from them
		H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
    	
    	//prepare test data
    	Account account1 = H_C_UnitTestUtils.createAccount('Account1');
    	Task task1 = H_C_UnitTestUtils.constructTask('Task1', Date.today(), account1.Id);
    	task1.Status = 'Completed';
    	
    	Account account2 = H_C_UnitTestUtils.createAccount('Account2', account1.Id);
    	Task task2 = H_C_UnitTestUtils.constructTask('Task2', Date.today(), account2.Id);
    	task2.Status = 'Completed';
    	insert new Task[] {task1, task2};
    	
    	//TEST #1: do no take objects from child account
    	ActivityHistory[] activities = H_C_ActivityDAO.getActivityHistoriesByAccountId(account1.Id, false);
    	System.assertEquals(1, activities.size());
    	System.assertEquals(task1.Id, activities[0].Id);
    	
    	//TEST #2: take objects from child account
    	activities = H_C_ActivityDAO.getActivityHistoriesByAccountId(account1.Id, true);
    	System.assertEquals(2, activities.size());
    	System.assert(task1.Id == activities[0].Id && task2.Id == activities[1].Id
    		|| task1.Id == activities[1].Id && task2.Id == activities[0].Id);
    }
    //
    
    
    
    
    
    //
    //Unit tests
    //
    @IsTest(SeeAllData = true)
    private static void testNoteAndAttachmentDAO_getNotesAndAttachmentsByAccountId()
    {
    	//#IMPORTANT:
		//we must use 'SeeAllData = true' property here, because Unit tests can't select
		//list of 'NoteAndAttachment' objects without it
		
		//wrong parameters
    	System.assertEquals(null,
    		H_C_NoteAndAttachmentDAO.getNotesAndAttachmentsByAccountId(null, true));
    	System.assertEquals(null,
    		H_C_NoteAndAttachmentDAO.getNotesAndAttachmentsByAccountId('wrongId', true));
    	
    	//correct parameters
    	//disable all triggers to test the logic separately from them
    	H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
    	
    	//prepare test data
    	Account account1 = H_C_UnitTestUtils.createAccount('Account1');
    	Note note1 = H_C_UnitTestUtils.constructNote('Note1', account1.Id, 'Test Note 1');
    	
    	Account account2 = H_C_UnitTestUtils.createAccount('Account2', account1.Id);
    	Note note2 = H_C_UnitTestUtils.constructNote('Note2', account2.Id, 'Test Note 2');
    	insert new Note[] {note1, note2};
    	
    	//TEST #1: do no take objects from child account
    	NoteAndAttachment[] notesAndAttachments =
    		H_C_NoteAndAttachmentDAO.getNotesAndAttachmentsByAccountId(account1.Id, false);
    	System.assertEquals(1, notesAndAttachments.size());
    	System.assertEquals(note1.Id, notesAndAttachments[0].Id);
    	
    	//TEST #2: take objects from child account
    	notesAndAttachments = H_C_NoteAndAttachmentDAO.getNotesAndAttachmentsByAccountId(account1.Id, true);
    	System.assertEquals(2, notesAndAttachments.size());
    	System.assert(note1.Id == notesAndAttachments[0].Id && note2.Id == notesAndAttachments[1].Id
    		|| note1.Id == notesAndAttachments[1].Id && note2.Id == notesAndAttachments[0].Id);
    }
    //
    
    
    
    
    
    //
    //Unit tests for 'H_C_AROM_RealObjectDAO' class
    //
    @IsTest
    private static void testAROM_RealObjectDAO_initialization()
    {
    	H_C_AROM_RealObjectDAO dao;
    	//wrong parameters
    	try
    	{
    		dao = new H_C_AROM_RealObjectDAO(null);
    		System.assert(false);
    	}
    	catch (Exception e)
    	{
    		System.assert(true);
    	}
    	
    	//correct parameters
    	dao = new H_C_AROM_RealObjectDAO(H_C_AROM_Configurator.getMetadata('Opportunity'));
    	System.assertNotEquals(null, dao);
    	dao = new H_C_AROM_RealObjectDAO(H_C_AROM_Configurator.getMetadata('Contact'));
    	System.assertNotEquals(null, dao);
    }
    
    @IsTest
    private static void testAROM_RealObjectDAO_getObjectsByIds()
    {
    	//initialize DAO
    	H_C_AROM_RealObjectDAO dao = new H_C_AROM_RealObjectDAO(
    		H_C_AROM_Configurator.getMetadata('Opportunity'));
        
        //disable all triggers to improve the performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        //create test data        
        sObject opportunity1 = H_C_UnitTestUtils.constructOpportunity('Opportunity 1', null);
        sObject opportunity2 = H_C_UnitTestUtils.constructOpportunity('Opportunity 2', null);
        insert new sObject[] {opportunity1, opportunity2};
        
        //perform the method with incorrect parameters
        System.assertEquals(null, dao.getObjectsByIds(null));
        
        //perform the method with correct parameters
        sObject[] resultObjects = dao.getObjectsByIds(new String[] {opportunity1.Id, opportunity2.Id});
        System.assertEquals(2, resultObjects.size());
        System.assert(opportunity1.Id == resultObjects[0].Id && opportunity2.Id == resultObjects[1].Id
        	|| opportunity1.Id == resultObjects[1].Id && opportunity2.Id == resultObjects[0].Id);
        
        resultObjects = dao.getObjectsByIds(new String[] {opportunity1.Id});
        System.assertEquals(1, resultObjects.size());
        System.assert(opportunity1.Id == resultObjects[0].Id);
    }
    
    @IsTest
    private static void testAROM_RealObjectDAO_getObjectsByAccountsIds()
    {
    	//initialize DAO
    	H_C_AROM_RealObjectDAO dao = new H_C_AROM_RealObjectDAO(
    		H_C_AROM_Configurator.getMetadata('Opportunity'));
        
        //disable all triggers to improve the performance of the test
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        //create test data
        Account account1 = H_C_UnitTestUtils.constructAccount('Account1');
        Account account2 = H_C_UnitTestUtils.constructAccount('Account2');
        insert new Account[] {account1, account2};
        
        Opportunity opportunity1 = H_C_UnitTestUtils.constructOpportunity('Opportunity 1', account1.Id);
        Opportunity opportunity2 = H_C_UnitTestUtils.constructOpportunity('Opportunity 2', account2.Id);
        insert new Opportunity[] {opportunity1, opportunity2};
        
        //perform the method with incorrect parameters
        System.assertEquals(null, dao.getObjectsByAccountsIds(null));
        
        //perform the method and check the results
        sObject[] resultObjects = dao.getObjectsByAccountsIds(new String[] {account1.Id, account2.Id});
        System.assertEquals(2, resultObjects.size());
        System.assert(opportunity1.Id == resultObjects[0].Id && opportunity2.Id == resultObjects[1].Id
        	|| opportunity1.Id == resultObjects[1].Id && opportunity2.Id == resultObjects[0].Id);
        
        resultObjects = dao.getObjectsByAccountsIds(new String[] {account1.Id});
        System.assertEquals(1, resultObjects.size());
        System.assert(opportunity1.Id == resultObjects[0].Id);
    }
    //
    
    
    
    
    
    //
    //Unit tests for 'H_C_AROM_ServiceMappingDAO' class
    //
    @IsTest
    private static void testAROM_ServiceMappingObjectDAO_initialization()
    {
    	H_C_AROM_ServiceMappingDAO dao;
    	//wrong parameters
    	try
    	{
    		dao = new H_C_AROM_ServiceMappingDAO(null);
    		System.assert(false);
    	}
    	catch (Exception e)
    	{
    		System.assert(true);
    	}
    	
    	//correct parameters
    	dao = new H_C_AROM_ServiceMappingDAO(H_C_AROM_Configurator.getMetadata('Opportunity'));
    	System.assertNotEquals(null, dao);
    	dao = new H_C_AROM_ServiceMappingDAO(H_C_AROM_Configurator.getMetadata('Contact'));
    	System.assertNotEquals(null, dao);
    }
    
    @IsTest
    private static void testAROM_ServiceMappingObjectDAO_getMappingById()
    {
    	//initialize DAO
    	H_C_AROM_ServiceMappingDAO dao = new H_C_AROM_ServiceMappingDAO(
    		H_C_AROM_Configurator.getMetadata('Opportunity'));
    	
    	//disable the trigger to test the code separately from them and to improve the
    	//performance of the test
    	H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
    	//create test data
    	Account account1 = H_C_UnitTestUtils.createAccount('Account1');
    	Opportunity opportunity1 = H_C_UnitTestUtils.createOpportunity('Opportunity1', account1.Id);
    	sObject mapping1 = H_C_UnitTestUtils.createAccountOpportunityMapping(account1, opportunity1);
    	sObject mapping2 = H_C_UnitTestUtils.createAccountOpportunityMapping(account1, opportunity1);
    	
    	//perform the method with incorrect parameters
    	System.assertEquals(null, dao.getMappingById(null));
    	
    	//perform the method with correct parameters
    	System.assertEquals(mapping1.Id, dao.getMappingById(mapping1.Id).Id);
    	System.assertEquals(mapping2.Id, dao.getMappingById(mapping2.Id).Id);
    }
    
    @IsTest
    private static void testAROM_ServiceMappingObjectDAO_getMappingsByIds()
    {
    	//initialize DAO
    	H_C_AROM_ServiceMappingDAO dao = new H_C_AROM_ServiceMappingDAO(
    		H_C_AROM_Configurator.getMetadata('Opportunity'));
    	
    	//disable the trigger to test the code separately from them and to improve the
    	//performance of the test
    	H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
    	//create test data
    	Account account1 = H_C_UnitTestUtils.createAccount('Account1');
    	Opportunity opportunity1 = H_C_UnitTestUtils.createOpportunity('Opportunity1', account1.Id);
    	sObject mapping1 = H_C_UnitTestUtils.createAccountOpportunityMapping(account1, opportunity1);
    	sObject mapping2 = H_C_UnitTestUtils.createAccountOpportunityMapping(account1, opportunity1);
    	sObject mapping3 = H_C_UnitTestUtils.createAccountOpportunityMapping(account1, opportunity1);
    	
    	//perform the method with incorrect parameters
    	System.assertEquals(null, dao.getMappingsByIds(null));
    	
    	//perform the method with correct parameters
    	sObject[] resultMappings = dao.getMappingsByIds(new String[] {mapping1.Id, mapping2.Id});
    	System.assertEquals(2, resultMappings.size());
    	System.assert(resultMappings[0].Id == mapping1.Id && resultMappings[1].Id == mapping2.Id
    		|| resultMappings[1].Id == mapping1.Id && resultMappings[0].Id == mapping2.Id);
    	
    	resultMappings = dao.getMappingsByIds(new String[] {mapping3.Id});
    	System.assertEquals(1, resultMappings.size());
    	System.assertEquals(mapping3.Id, resultMappings[0].Id);
    }
    
    @IsTest
    private static void testAROM_ServiceMappingObjectDAO_getMappingsByAccountsIds()
    {
    	//initialize DAO
    	H_C_AROM_ServiceMappingDAO dao = new H_C_AROM_ServiceMappingDAO(
    		H_C_AROM_Configurator.getMetadata('Opportunity'));
    	
    	//disable the trigger to test the code separately from them and to improve the
    	//performance of the test
    	H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
    	//create test data
    	Account account1 = H_C_UnitTestUtils.constructAccount('Account1');
    	Account account2 = H_C_UnitTestUtils.constructAccount('Account2');
    	Account account3 = H_C_UnitTestUtils.constructAccount('Account3');
    	insert new Account[] {account1, account2, account3};
    	Opportunity opportunity1 = H_C_UnitTestUtils.createOpportunity('Opportunity1', account1.Id);
    	sObject mapping1 = H_C_UnitTestUtils.createAccountOpportunityMapping(account1, opportunity1);
    	sObject mapping2 = H_C_UnitTestUtils.createAccountOpportunityMapping(account2, opportunity1);
    	sObject mapping3 = H_C_UnitTestUtils.createAccountOpportunityMapping(account3, opportunity1);
    	
    	//perform the method with incorrect parameters
    	System.assertEquals(null, dao.getMappingsByAccountsIds(null));
    	
    	//perform the method with correct parameters
    	sObject[] resultMappings = dao.getMappingsByAccountsIds(new String[] {account1.Id, account2.Id});
    	System.assertEquals(2, resultMappings.size());
    	System.assert(resultMappings[0].Id == mapping1.Id && resultMappings[1].Id == mapping2.Id
    		|| resultMappings[1].Id == mapping1.Id && resultMappings[0].Id == mapping2.Id);
    	
    	resultMappings = dao.getMappingsByAccountsIds(new String[] {account3.Id});
    	System.assertEquals(1, resultMappings.size());
    	System.assertEquals(mapping3.Id, resultMappings[0].Id);
    }
    
    @IsTest
    private static void testAROM_ServiceMappingObjectDAO_getMappingsByAccountLinksOfRealObjects()
    {
    	//initialize DAO
    	H_C_AROM_ServiceMappingDAO dao = new H_C_AROM_ServiceMappingDAO(
    		H_C_AROM_Configurator.getMetadata('Opportunity'));
    	
    	//disable the trigger to test the code separately from them and to improve the
    	//performance of the test
    	H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
    	//create test data
    	Account account1 = H_C_UnitTestUtils.constructAccount('Account1');
    	Account account2 = H_C_UnitTestUtils.constructAccount('Account2');
    	Account account3 = H_C_UnitTestUtils.constructAccount('Account3');
    	insert new Account[] {account1, account2, account3};
    	
    	Opportunity opportunity1 = H_C_UnitTestUtils.constructOpportunity('Opportunity1', account1.Id);
    	Opportunity opportunity2 = H_C_UnitTestUtils.constructOpportunity('Opportunity2', account3.Id);
    	insert new Opportunity[] {opportunity1, opportunity2};
    	
    	sObject mapping1 = H_C_UnitTestUtils.createAccountOpportunityMapping(account1, opportunity1);
    	sObject mapping2 = H_C_UnitTestUtils.createAccountOpportunityMapping(account2, opportunity1);
    	sObject mapping3 = H_C_UnitTestUtils.createAccountOpportunityMapping(account3, opportunity2);
    	
    	//perform the method with incorrect parameters
    	System.assertEquals(null, dao.getMappingsByAccountLinksOfRealObjects(null));
    	
    	//perform the method with correct parameters
    	//opportunity1 is a real object which refers to account1
    	sObject[] resultMappings = dao.getMappingsByAccountLinksOfRealObjects(new String[] {account1.Id});
    	System.assertEquals(2, resultMappings.size());
    	System.assert(resultMappings[0].Id == mapping1.Id && resultMappings[1].Id == mapping2.Id
    		|| resultMappings[1].Id == mapping1.Id && resultMappings[0].Id == mapping2.Id);
    	
    	//opportunity2 is a real object which refers to account3
    	resultMappings = dao.getMappingsByAccountLinksOfRealObjects(new String[] {account3.Id});
    	System.assertEquals(1, resultMappings.size());
    	System.assertEquals(mapping3.Id, resultMappings[0].Id);
    }
    
    @IsTest
    private static void testAROM_ServiceMappingObjectDAO_getMappingsByRealObjectsIds()
    {
    	//initialize DAO
    	H_C_AROM_ServiceMappingDAO dao = new H_C_AROM_ServiceMappingDAO(
    		H_C_AROM_Configurator.getMetadata('Opportunity'));
    	
    	//disable the trigger to test the code separately from them and to improve the
    	//performance of the test
    	H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
    	//create test data
    	Account account1 = H_C_UnitTestUtils.constructAccount('Account1');
    	Account account2 = H_C_UnitTestUtils.constructAccount('Account2');
    	insert new Account[] {account1, account2};
    	
    	Opportunity opportunity1 = H_C_UnitTestUtils.constructOpportunity('Opportunity1', account1.Id);
    	Opportunity opportunity2 = H_C_UnitTestUtils.constructOpportunity('Opportunity2', account2.Id);
    	insert new Opportunity[] {opportunity1, opportunity2};
    	
    	sObject mapping1 = H_C_UnitTestUtils.createAccountOpportunityMapping(account1, opportunity1);
    	sObject mapping2 = H_C_UnitTestUtils.createAccountOpportunityMapping(account2, opportunity2);
    	
    	//perform the method with incorrect parameters
    	System.assertEquals(null, dao.getMappingsByRealObjectsIds(null));
    	
    	//perform the method with correct parameters
    	//opportunity1 is a real object which refers to account1
    	sObject[] resultMappings = dao.getMappingsByRealObjectsIds(new String[] {
    		opportunity1.Id, opportunity2.Id});
    	System.assertEquals(2, resultMappings.size());
    	System.assert(resultMappings[0].Id == mapping1.Id && resultMappings[1].Id == mapping2.Id
    		|| resultMappings[1].Id == mapping1.Id && resultMappings[0].Id == mapping2.Id);
    	
    	//opportunity2 is a real object which refers to account3
    	resultMappings = dao.getMappingsByRealObjectsIds(new String[] {opportunity1.Id});
    	System.assertEquals(1, resultMappings.size());
    	System.assertEquals(mapping1.Id, resultMappings[0].Id);
    }
    //
    
    
    
    
    
    //
    //Unit tests for 'H_C_CustomSettings' class
    //
    @IsTest
    private static void testCustomSettings_getStringValueByName()
    {
    	//setting does not exist
    	System.assertEquals(null, H_C_CustomSettings.getStringValueByName(
    		H_C_CustomSettings.TRIGGERS_ENABLED));
    	//name is too long => exception should be thrown
    	System.assertEquals(null, H_C_CustomSettings.getStringValueByName('Name'.repeat(10)));
    	
    	//setting exists
    	H_C_UnitTestUtils.createSetting(H_C_CustomSettings.TRIGGERS_ENABLED, 'TRUE');
    	System.assertEquals('TRUE', H_C_CustomSettings.getStringValueByName(
    		H_C_CustomSettings.TRIGGERS_ENABLED));
    }
    
    @IsTest
    private static void testCustomSettings_getIntegerValueByName()
    {
    	//setting does not exist
    	System.assertEquals(null, H_C_CustomSettings.getIntegerValueByName(
    		H_C_CustomSettings.SCOPE_FOR_ACCOUNT_HIERARCHY_MANAGER));
    	//name is too long => exception should be thrown
    	System.assertEquals(null, H_C_CustomSettings.getIntegerValueByName('Name'.repeat(10)));
    	
    	//setting exists
    	H_C_UnitTestUtils.createSetting(H_C_CustomSettings.SCOPE_FOR_ACCOUNT_HIERARCHY_MANAGER, '555');
    	System.assertEquals(555, H_C_CustomSettings.getIntegerValueByName(
    		H_C_CustomSettings.SCOPE_FOR_ACCOUNT_HIERARCHY_MANAGER));
    }
    
    @IsTest
    private static void testCustomSettings_getDoubleValueByName()
    {
    	//setting does not exist
    	System.assertEquals(null, H_C_CustomSettings.getDoubleValueByName(
    		H_C_CustomSettings.ATRU_TA_2_KA_MINIMAL_PARTICIPATION));
    	//name is too long => exception should be thrown
    	System.assertEquals(null, H_C_CustomSettings.getDoubleValueByName('Name'.repeat(10)));
    	
    	//setting exists
    	H_C_UnitTestUtils.createSetting(H_C_CustomSettings.ATRU_TA_2_KA_MINIMAL_PARTICIPATION, '55.55');
    	System.assertEquals(55.55, H_C_CustomSettings.getDoubleValueByName(
    		H_C_CustomSettings.ATRU_TA_2_KA_MINIMAL_PARTICIPATION));
    }
    
    @IsTest
    private static void testCustomSettings_getBooleanValueByName()
    {
    	final String TEST_BOOLEAN_SETTING_NAME = 'TEST_BOOLEAN_PROPERTY';
    	 
    	//setting does not exist
    	System.assertEquals(null, H_C_CustomSettings.getBooleanValueByName(TEST_BOOLEAN_SETTING_NAME));
    	//name is too long => exception should be thrown
    	System.assertEquals(null, H_C_CustomSettings.getBooleanValueByName('Name'.repeat(10)));
    	
    	//setting exists
    	H_C_UnitTestUtils.createSetting(TEST_BOOLEAN_SETTING_NAME, 'true');
    	System.assertEquals(true, H_C_CustomSettings.getBooleanValueByName(TEST_BOOLEAN_SETTING_NAME));
    }
    
    @IsTest
    private static void testCustomSettings_getAccountShareByName()
    {
    	//1) setting does not exist
    	System.assertEquals(null, H_C_CustomSettings.getAccountShareByName(
    		H_C_CustomSettings.ATRU_TA_2_KA_PERMITS_FOR_NEW_ATMs));
    	//name is too long => exception should be thrown
    	System.assertEquals(null, H_C_CustomSettings.getAccountShareByName('Name'.repeat(10)));
    	
    	//2) bad format of the setting
    	H_C_Settings__c setting = H_C_UnitTestUtils.createSetting(
    		H_C_CustomSettings.ATRU_TA_2_KA_PERMITS_FOR_NEW_ATMs, 'unknown format');
    	System.assertEquals(null, H_C_CustomSettings.getAccountShareByName(
    		H_C_CustomSettings.ATRU_TA_2_KA_PERMITS_FOR_NEW_ATMs));
    	
    	//setting exists
    	setting.Value__c = 'AccountAccessLevel:Edit, OpportunityAccessLevel:Read, CaseAccessLevel:None';
    	update setting;
    	AccountShare share = H_C_CustomSettings.getAccountShareByName(
    		H_C_CustomSettings.ATRU_TA_2_KA_PERMITS_FOR_NEW_ATMs);
    	System.assertEquals(H_C_AccessLevel.EDIT, share.AccountAccessLevel);
    	System.assertEquals(H_C_AccessLevel.READ, share.OpportunityAccessLevel);
    	System.assertEquals(H_C_AccessLevel.NONE, share.CaseAccessLevel);
    }
    
    @IsTest
    private static void testCustomSettings_getIgnorableTeamRolesDuringRollup()
    {
    	//create test setting
    	H_C_UnitTestUtils.createSetting(H_C_CustomSettings.ATRU_IGNORABLE_TEAM_ROLES, ' Role1 , Role2 ');
    	//call the method and check the result
    	String[] ignorableRoles = H_C_CustomSettings.getIgnorableTeamRolesDuringRollup();
    	System.assertEquals(2, ignorableRoles.size());
    	System.assert(ignorableRoles[0] == 'Role1' && ignorableRoles[1] == 'Role2'
    		|| ignorableRoles[1] == 'Role1' && ignorableRoles[0] == 'Role2');
    }
    
    @IsTest
    private static void testCustomSettings_getATRU_OptionsForKeyAccount()
	{
		//create settings
		H_C_UnitTestUtils.createSetting(H_C_CustomSettings.ATRU_TA_2_KA_MINIMAL_PARTICIPATION, '55');
		H_C_UnitTestUtils.createSetting(H_C_CustomSettings.ATRU_TA_2_KA_ROLES_FOR_NEW_ATMs, ' Role1, Role2 ');
		H_C_UnitTestUtils.createSetting(H_C_CustomSettings.ATRU_TA_2_KA_PERMITS_FOR_NEW_ATMs,
			'AccountAccessLevel:Edit, OpportunityAccessLevel:Read, CaseAccessLevel:None');
		
		//perform the methods and check the results
		H_C_ATRU_Options options = H_C_CustomSettings.getATRU_Options(
			H_C_AccountRecordType.KEY_REGION_ACCOUNT);
		System.assertEquals(true, options.isProcessEnabled);
		
		System.assertEquals(0.55, options.minimalParticipation);
		
		System.assertEquals(2, options.rolesForNewATMs.size());
		System.assert(options.rolesForNewATMs[0] == 'Role1' && options.rolesForNewATMs[1] == 'Role2');
		System.assertEquals(false, options.isAnyRoleAllowed);
		
    	System.assertEquals(H_C_AccessLevel.EDIT, options.permissionsForNewATM.AccountAccessLevel);
    	System.assertEquals(H_C_AccessLevel.READ, options.permissionsForNewATM.OpportunityAccessLevel);
    	System.assertEquals(H_C_AccessLevel.NONE, options.permissionsForNewATM.CaseAccessLevel);
	}
	
	@IsTest
    private static void testCustomSettings_getATRU_OptionsForContractAccount()
	{
		//create settings
		H_C_UnitTestUtils.createSetting(H_C_CustomSettings.ATRU_KA_2_CA_MINIMAL_PARTICIPATION, '55');
		H_C_UnitTestUtils.createSetting(H_C_CustomSettings.ATRU_KA_2_CA_ROLES_FOR_NEW_ATMs, ' Role1, Role2 ');
		H_C_UnitTestUtils.createSetting(H_C_CustomSettings.ATRU_KA_2_CA_PERMITS_FOR_NEW_ATMs,
			'AccountAccessLevel:Edit, OpportunityAccessLevel:Read, CaseAccessLevel:None');
		
		//perform the methods and check the results
		H_C_ATRU_Options options = H_C_CustomSettings.getATRU_Options(
			H_C_AccountRecordType.CONTRACT_ACCOUNT);
		System.assertEquals(true, options.isProcessEnabled);
		
		System.assertEquals(0.55, options.minimalParticipation);
		
		System.assertEquals(2, options.rolesForNewATMs.size());
		System.assert(options.rolesForNewATMs[0] == 'Role1' && options.rolesForNewATMs[1] == 'Role2');
		System.assertEquals(false, options.isAnyRoleAllowed);
		
    	System.assertEquals(H_C_AccessLevel.EDIT, options.permissionsForNewATM.AccountAccessLevel);
    	System.assertEquals(H_C_AccessLevel.READ, options.permissionsForNewATM.OpportunityAccessLevel);
    	System.assertEquals(H_C_AccessLevel.NONE, options.permissionsForNewATM.CaseAccessLevel);
	}
	
	@IsTest
    private static void testCustomSettings_getATRU_OptionsForUnknownAccount()
	{
		try
		{
			//perform the methods and check the results
			H_C_ATRU_Options options = H_C_CustomSettings.getATRU_Options(
				H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT);
			System.assert(false);
		}
		catch (H_C_Exception error)
		{
			System.assert(true);
		}
	}
	
	@IsTest
    private static void testCustomSettings_getATRD_OptionsForKeyAccount()
	{
		//create settings
		H_C_UnitTestUtils.createSetting(H_C_CustomSettings.ATRD_CA_2_KA_IGNORABLE_TEAM_ROLES, ' Role1, Role2 ');
		H_C_UnitTestUtils.createSetting(H_C_CustomSettings.ATRD_PROCESS_ENABLED, 'TRUE');
		
		//perform the methods and check the results
		H_C_ATRD_Options options = H_C_CustomSettings.getATRD_Options(
			H_C_AccountRecordType.KEY_REGION_ACCOUNT);
		System.assertEquals(true, options.isProcessEnabled);
		
		System.assertEquals(2, options.ignorableTeamRoles.size());
		System.assert(options.ignorableTeamRoles[0] == 'Role1' && options.ignorableTeamRoles[1] == 'Role2');
	}
	
	@IsTest
    private static void testCustomSettings_getATRD_OptionsForTransactionalAccount()
	{
		//create settings
		H_C_UnitTestUtils.createSetting(H_C_CustomSettings.ATRD_KA_2_TA_IGNORABLE_TEAM_ROLES, ' Role1, Role2 ');
		H_C_UnitTestUtils.createSetting(H_C_CustomSettings.ATRD_PROCESS_ENABLED, 'FALSE');
		
		//perform the methods and check the results
		H_C_ATRD_Options options = H_C_CustomSettings.getATRD_Options(
			H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT);
		System.assertEquals(false, options.isProcessEnabled);
		
		System.assertEquals(2, options.ignorableTeamRoles.size());
		System.assert(options.ignorableTeamRoles[0] == 'Role1' && options.ignorableTeamRoles[1] == 'Role2');
	}
	
	@IsTest
    private static void testCustomSettings_getATRD_OptionsForUnknownAccount()
	{
		try
		{
			//perform the methods and check the results
			H_C_ATRD_Options options = H_C_CustomSettings.getATRD_Options(
				H_C_AccountRecordType.CONTRACT_ACCOUNT);
			System.assert(false);
		}
		catch (H_C_Exception error)
		{
			System.assert(true);
		}
	}
    
    @IsTest
    private static void testCustomSettings_triggersEnabled()
    {
    	//setting does not exist (by default, triggers are enabled)
    	System.assertEquals(true, H_C_CustomSettings.triggersEnabled());
    	
    	//disable triggers for current request only
    	H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
    	System.assertEquals(false, H_C_CustomSettings.triggersEnabled());
    	
    	//enable triggers for current request only
    	H_C_CustomSettings.setTriggersSettingForCurrentRequest(true);
    	System.assertEquals(true, H_C_CustomSettings.triggersEnabled());
    }
    
    @IsTest
    private static void testCustomSettings_triggersDisabled()
    {
    	//read setting
    	H_C_UnitTestUtils.createSetting(H_C_CustomSettings.TRIGGERS_ENABLED, 'FALSE');
    	System.assertEquals(false, H_C_CustomSettings.triggersEnabled());
    	
    	//enable triggers for current request only
    	H_C_CustomSettings.setTriggersSettingForCurrentRequest(true);
    	System.assertEquals(true, H_C_CustomSettings.triggersEnabled());
    	
    	//disable triggers for current request only
    	H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
    	System.assertEquals(false, H_C_CustomSettings.triggersEnabled());
    }
    //
}