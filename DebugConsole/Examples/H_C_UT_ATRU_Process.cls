//
//This class provides Unit tests for the rollup mechanism
//Used abbreviations:
// - UT means 'Unit tests'
// - ATRU means 'Account Team Roll-Up'
// - ATM means 'Account Team Member'
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (9-09-2013)
@IsTest
public class H_C_UT_ATRU_Process
{
	//
	//Static service methods
	//
	public static void setSettingsForKeyAccount(Double minimalParticipation,
		AccountShare permitsForNewATM, String[] rolesForNewATMs)
	{
		H_C_UnitTestUtils.createSetting(H_C_CustomSettings.ATRU_TA_2_KA_MINIMAL_PARTICIPATION,
			String.valueOf(minimalParticipation));
		H_C_UnitTestUtils.createSetting(H_C_CustomSettings.ATRU_TA_2_KA_ROLES_FOR_NEW_ATMs,
			String.join(rolesForNewATMs, H_C_CustomSettings.SEPARATOR_OF_ROLES));
		
		String stringOfPermits = 'AccountAccessLevel:' + permitsForNewATM.AccountAccessLevel
			+ ',OpportunityAccessLevel:' + permitsForNewATM.OpportunityAccessLevel
			+ ',CaseAccessLevel:' + permitsForNewATM.CaseAccessLevel; 
		H_C_UnitTestUtils.createSetting(H_C_CustomSettings.ATRU_TA_2_KA_PERMITS_FOR_NEW_ATMs,
			stringOfPermits);
	}
	
	public static void setSettingsForContractAccount(Double minimalParticipation,
		AccountShare permitsForNewATM, String[] rolesForNewATMs)
	{
		H_C_UnitTestUtils.createSetting(H_C_CustomSettings.ATRU_KA_2_CA_MINIMAL_PARTICIPATION,
			String.valueOf(minimalParticipation));
		H_C_UnitTestUtils.createSetting(H_C_CustomSettings.ATRU_KA_2_CA_ROLES_FOR_NEW_ATMs,
			String.join(rolesForNewATMs, H_C_CustomSettings.SEPARATOR_OF_ROLES));
		
		String stringOfPermits = 'AccountAccessLevel:' + permitsForNewATM.AccountAccessLevel
			+ ',OpportunityAccessLevel:' + permitsForNewATM.OpportunityAccessLevel
			+ ',CaseAccessLevel:' + permitsForNewATM.CaseAccessLevel; 
		H_C_UnitTestUtils.createSetting(H_C_CustomSettings.ATRU_KA_2_CA_PERMITS_FOR_NEW_ATMs,
			stringOfPermits);
	}
	
	public static AccountShare createTestShare()
	{
		AccountShare share = new AccountShare();
		share.AccountAccessLevel = H_C_AccessLevel.EDIT;
		share.OpportunityAccessLevel = H_C_AccessLevel.READ;
		share.CaseAccessLevel = H_C_AccessLevel.READ;
		return share;
	}
	//
	
	@IsTest
    private static void testManager_updateTeams_CorrectData()
    {
        // CORRECT PARAMETERS:
        //STEP #1: set the environment
        //disable triggers to increase the performance of the test and test the logic
        //separately from them
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        String role1 = 'Role1';
        String role2 = 'Role2';
        String role3 = 'Role3';
        //set ignorable team roles in custom setting
        H_C_UnitTestUtils.createSetting(H_C_CustomSettings.ATRU_IGNORABLE_TEAM_ROLES, role2);
        
        //set options for key accounts
        String[] rolesForNewATMs = new String[] {role1, H_C_CustomSettings.ANY_ROLE_NAME};
        setSettingsForKeyAccount(Double.valueOf(50), createTestShare(), rolesForNewATMs);
        
        //set options for contract accounts
        rolesForNewATMs = new String[] {role3};
        setSettingsForContractAccount(100, createTestShare(), rolesForNewATMs);
        
        //STEP #2: create test data:
        //HIERARCHY OF ACCOUNTS:
        //- contractAccount1 -> keyAccount1 -> (trAccount1, trAccount2, trAccount3)
        //ATMs:
        //- contractAccount1 has no ATMs
        //- keyAccount1 has User1-Role3 and User4-Role2 in ATMs
        //- trAccount1 has User1-Role1, User2-Role3, User3-Role1 in ATMs
        //- trAccount2 has User1-Role1, User2-Role3, User3-Role2 in ATMs (Role2 is ignorable for rollup)
        //- trAccount3 has User1-Role1, User2-Role2 in ATMs (Role2 is ignorable for rollup)
        
        //1) create accounts
        Account contractAccount1 = H_C_UnitTestUtils.createAccount('Contract Account1');
        contractAccount1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
        
        Account keyAccount1 = H_C_UnitTestUtils.createAccount('Key Account1', contractAccount1.Id);
        keyAccount1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        
        Account trAccount1 = H_C_UnitTestUtils.createAccount('Transactional Account1', keyAccount1.Id);
        trAccount1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        Account trAccount2 = H_C_UnitTestUtils.createAccount('Transactional Account2', keyAccount1.Id);
        trAccount2.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        Account trAccount3 = H_C_UnitTestUtils.createAccount('Transactional Account3', keyAccount1.Id);
        trAccount3.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        
        update new Account[] {contractAccount1, keyAccount1, trAccount1, trAccount2, trAccount3};
        
        //2) create users
        User user1 = H_C_UnitTestUtils.createSfUser('User1');
        User user2 = H_C_UnitTestUtils.createSfUser('User2');
        User user3 = H_C_UnitTestUtils.createSfUser('User3');
        User user4 = H_C_UnitTestUtils.createSfUser('User4');
        
        //3) create ATMs
        AccountTeamMember keyMember1 = H_C_UnitTestUtils.constructAccountTeamMember(
        	keyAccount1.Id, user1.Id, role3);
        AccountTeamMember keyMember2 = H_C_UnitTestUtils.constructAccountTeamMember(
        	keyAccount1.Id, user4.Id, role2);
        
        AccountTeamMember trMember11 = H_C_UnitTestUtils.constructAccountTeamMember(
        	trAccount1.Id, user1.Id, role1);
        AccountTeamMember trMember12 = H_C_UnitTestUtils.constructAccountTeamMember(
        	trAccount1.Id, user2.Id, role3);
        AccountTeamMember trMember13 = H_C_UnitTestUtils.constructAccountTeamMember(
        	trAccount1.Id, user3.Id, role1);
        
        AccountTeamMember trMember21 = H_C_UnitTestUtils.constructAccountTeamMember(
        	trAccount2.Id, user1.Id, role1);
        AccountTeamMember trMember22 = H_C_UnitTestUtils.constructAccountTeamMember(
        	trAccount2.Id, user2.Id, role3);
        AccountTeamMember trMember23 = H_C_UnitTestUtils.constructAccountTeamMember(
        	trAccount2.Id, user3.Id, role2);
        
        AccountTeamMember trMember31 = H_C_UnitTestUtils.constructAccountTeamMember(
        	trAccount3.Id, user1.Id, role1);
        AccountTeamMember trMember32 = H_C_UnitTestUtils.constructAccountTeamMember(
        	trAccount3.Id, user2.Id, role2);
        
        insert new AccountTeamMember[] {keyMember1, keyMember2, trMember11, trMember12, trMember13,
            trMember21, trMember22, trMember23, trMember31, trMember32};
        
        //STEP #3: start the process (we especially transfer contractAccount1 before keyAccount1,
        //because the system should find correct order for the process: if contractAccount1 is
        //processed before keyAccount then it will have incorrect ATMs (User1-Role3 is in keyAccount1
        //initially and it can be rolled up, but the system should start with keyAccount1 and update
        //User1-Role3 to User1-Role1 => User1-Role1 will not be rolled up)
        
        //initialize options for a manager
        H_C_ATRU_Manager.Options options = new H_C_ATRU_Manager.Options();
        options.allAccountsHaveParentalRights = true;
        options.allAccountsOfSameType = false;
        options.processEntireHierarchy = true;
        
        //initialize a manager
        Account[] processedAccounts = H_C_AccountDAO.getAccountsByIds(
        	new String[] {contractAccount1.Id, keyAccount1.Id});
        H_C_ATRU_Manager manager = new H_C_ATRU_Manager(processedAccounts, options);
        //start the process
        manager.updateTeams();
        
        //we should get the following state for teams:
        //- trAccount1 has User1-Role1, User2-Role3, User3-Role1 in ATMs - NOTHING SHOULD BE CHANGED
        //- trAccount2 has User1-Role1, User2-Role3, User3-Role2 in ATMs - NOTHING SHOULD BE CHANGED
        //- trAccount3 has User1-Role1, User2-Role2 in ATMs - NOTHING SHOULD BE CHANGED
        //- keyAccount1 has User1-Role1, User2-Role3, User4-Role2 in ATMs
        //- contractAccount1 has User2-Role3 in ATMs (Role2 is ignored by the mechanism initially
        //(User4 will be rejected) and Role1 is ignored during creation of a new ATM)
        
        //STEP #4: check the results:
        //get ATMs of key account and contract account
        AccountTeamMember[] allParentTeamMembers = H_C_AccountTeamMemberDAO.getATMsByAccountsIds(
        	new String[] {contractAccount1.Id, keyAccount1.Id});
        H_C_AccountTeamMemberHelper parentATMsHelper =
        	H_C_AccountTeamMemberHelper.createHelperByATMsList(allParentTeamMembers);
        
        //4.1) check key account
        AccountTeamMember[] currentATMs = parentATMsHelper.getATMsByAccountId(keyAccount1.Id);
        System.assertEquals(3, currentATMs.size());
        H_C_AccountTeamMemberHelper currentATMsHelper =
        	H_C_AccountTeamMemberHelper.createHelperByATMsList(currentATMs);
        
        //4.1.1) check User1 (User1-Role2 should be UPDATED to User1-Role1)
        AccountTeamMember currentAtm = currentATMsHelper.getATMsByUserId(user1.Id)[0];
        System.assertEquals(role1, currentAtm.TeamMemberRole);
        //4.1.2) check User2 (User2-Role3 should be CREATED)
        currentAtm = currentATMsHelper.getATMsByUserId(user2.Id)[0];
        System.assertEquals(role3, currentAtm.TeamMemberRole);
        //4.1.3) check User4 (User4-Role2 should NOT be UPDATED)
        currentAtm = currentATMsHelper.getATMsByUserId(user4.Id)[0];
        System.assertEquals(role2, currentAtm.TeamMemberRole);
        
        //4.2) check contract account
        currentATMs = parentATMsHelper.getATMsByAccountId(contractAccount1.Id);
        System.assertEquals(1, currentATMs.size());
        currentATMsHelper = H_C_AccountTeamMemberHelper.createHelperByATMsList(currentATMs);
        
        //4.2.1) check User2 (User2-Role3 should be CREATED)
        currentAtm = currentATMsHelper.getATMsByUserId(user2.Id)[0];
        System.assertEquals(role3, currentAtm.TeamMemberRole);
    }
    
    @IsTest
    private static void testManager_updateTeams_CorrectData2()
    {
        // CORRECT PARAMETERS:
        //STEP #1: set the environment
        //disable triggers to increase the performance of the test and test the logic
        //separately from them
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        String role1 = 'Role1';
        String role2 = 'Role2';
        String role3 = 'Role3';
        //set ignorable team roles in custom setting
        H_C_UnitTestUtils.createSetting(H_C_CustomSettings.ATRU_IGNORABLE_TEAM_ROLES, role2);
        
        //set options for key accounts
        String[] rolesForNewATMs = new String[] {role1, H_C_CustomSettings.ANY_ROLE_NAME};
        setSettingsForKeyAccount(Double.valueOf(50), createTestShare(), rolesForNewATMs);
        
        //set options for contract accounts
        rolesForNewATMs = new String[] {role1, role3};
        setSettingsForContractAccount(100, createTestShare(), rolesForNewATMs);
        
        //STEP #2: create test data:
        //HIERARCHY OF ACCOUNTS:
        //- contractAccount1 -> (keyAccount1, keyAccount2)
        //- keyAccount1 -> (trAccount1, trAccount2, trAccount3)
        //- keyAccount2 has no child accounts
        //ATMs:
        //- contractAccount1 has no ATMs
        //- keyAccount1 has User1-Role2 and User4-Role2 in ATMs
        //- keyAccount2 has User1-Role3 and User4-Role2 in ATMs
        //- trAccount1 has User1-Role1, User2-Role3, User3-Role1 in ATMs
        //- trAccount2 has User1-Role1, User2-Role3, User3-Role2 in ATMs (Role2 is ignorable for rollup)
        //- trAccount3 has User1-Role1, User2-Role2 in ATMs
        
        //1) create accounts
        Account contractAccount1 = H_C_UnitTestUtils.createAccount('Contract Account1');
        contractAccount1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
        update contractAccount1;
        
        Account keyAccount1 = H_C_UnitTestUtils.constructAccount('Key Account1', contractAccount1.Id);
        keyAccount1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        Account keyAccount2 = H_C_UnitTestUtils.constructAccount('Key Account2', contractAccount1.Id);
        keyAccount2.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        insert new Account[] {keyAccount1, keyAccount2};
        
        Account trAccount1 = H_C_UnitTestUtils.constructAccount('Transactional Account1', keyAccount1.Id);
        trAccount1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        Account trAccount2 = H_C_UnitTestUtils.constructAccount('Transactional Account2', keyAccount1.Id);
        trAccount2.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        Account trAccount3 = H_C_UnitTestUtils.constructAccount('Transactional Account3', keyAccount1.Id);
        trAccount3.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        insert new Account[] {trAccount1, trAccount2, trAccount3};
        
        //2) create users
        User user1 = H_C_UnitTestUtils.createSfUser('User1');
        User user2 = H_C_UnitTestUtils.createSfUser('User2');
        User user3 = H_C_UnitTestUtils.createSfUser('User3');
        User user4 = H_C_UnitTestUtils.createSfUser('User4');
        
        //3) create ATMs
        AccountTeamMember keyMember11 = H_C_UnitTestUtils.constructAccountTeamMember(
        	keyAccount1.Id, user1.Id, role2);
        AccountTeamMember keyMember12 = H_C_UnitTestUtils.constructAccountTeamMember(
        	keyAccount1.Id, user4.Id, role2);
        
        AccountTeamMember keyMember21 = H_C_UnitTestUtils.constructAccountTeamMember(
        	keyAccount2.Id, user1.Id, role3);
        AccountTeamMember keyMember22 = H_C_UnitTestUtils.constructAccountTeamMember(
        	keyAccount2.Id, user4.Id, role2);
        
        AccountTeamMember trMember11 = H_C_UnitTestUtils.constructAccountTeamMember(
        	trAccount1.Id, user1.Id, role1);
        AccountTeamMember trMember12 = H_C_UnitTestUtils.constructAccountTeamMember(
        	trAccount1.Id, user2.Id, role3);
        AccountTeamMember trMember13 = H_C_UnitTestUtils.constructAccountTeamMember(
        	trAccount1.Id, user3.Id, role1);
        
        AccountTeamMember trMember21 = H_C_UnitTestUtils.constructAccountTeamMember(
        	trAccount2.Id, user1.Id, role1);
        AccountTeamMember trMember22 = H_C_UnitTestUtils.constructAccountTeamMember(
        	trAccount2.Id, user2.Id, role3);
        AccountTeamMember trMember23 = H_C_UnitTestUtils.constructAccountTeamMember(
        	trAccount2.Id, user3.Id, role2);
        
        AccountTeamMember trMember31 = H_C_UnitTestUtils.constructAccountTeamMember(
        	trAccount3.Id, user1.Id, role1);
        AccountTeamMember trMember32 = H_C_UnitTestUtils.constructAccountTeamMember(
        	trAccount3.Id, user2.Id, role2);
        
        insert new AccountTeamMember[] {keyMember11, keyMember12, keyMember21, keyMember22,
        	trMember11, trMember12, trMember13, trMember21, trMember22, trMember23,
        	trMember31, trMember32};
        
        //STEP #3: perform the method (trAccount1 has no child records, but we pass it to
        //be sure that this moment will be caught)
        
        //initialize options for a manager
        H_C_ATRU_Manager.Options options = new H_C_ATRU_Manager.Options();
        options.allAccountsHaveParentalRights = false;
        options.allAccountsOfSameType = false;
        options.processEntireHierarchy = true;
        
        //initialize a manager
        Account[] processedAccounts = H_C_AccountDAO.getAccountsByIds(
        	new String[] {keyAccount1.Id, trAccount1.Id});
        H_C_ATRU_Manager manager = new H_C_ATRU_Manager(processedAccounts, options);
        //start the process
        manager.updateTeams();
        
        //we should get the following state for teams:
        //- trAccount1 has User1-Role1, User2-Role3, User3-Role1 in ATMs - NOTHING SHOULD BE CHANGED
        //- trAccount2 has User1-Role1, User2-Role3, User3-Role2 in ATMs (Role2 is ignorable for rollup) - NOTHING SHOULD BE CHANGED
        //- trAccount3 has User1-Role1, User2-Role2 in ATMs - NOTHING SHOULD BE CHANGED
        //- keyAccount1 has User1-Role1, User2-Role3, User4-Role2 in ATMs
        //- keyAccount2 has User1-Role3 and User4-Role2 in ATMs - NOTHING SHOULD BE CHANGED
        //- contractAccount1 has User1-Role1 in ATMs (because minimal participation is 100%
        //(User2 will be rejected) and Role2 is ignorable (User4 will be rejected))
        
        //STEP #4: check the results:
        //get ATMs of key account and contract account
        AccountTeamMember[] allParentTeamMembers = H_C_AccountTeamMemberDAO.getATMsByAccountsIds(
        	new String[] {contractAccount1.Id, keyAccount1.Id});
        H_C_AccountTeamMemberHelper parentATMsHelper =
        	H_C_AccountTeamMemberHelper.createHelperByATMsList(allParentTeamMembers);
        
        //4.1) check key account
        AccountTeamMember[] currentATMs = parentATMsHelper.getATMsByAccountId(keyAccount1.Id);
        System.assertEquals(3, currentATMs.size());
        H_C_AccountTeamMemberHelper currentATMsHelper =
        	H_C_AccountTeamMemberHelper.createHelperByATMsList(currentATMs);
        
        //4.1.1) check User1 (User1-Role2 should be UPDATED to User1-Role1)
        AccountTeamMember currentAtm = currentATMsHelper.getATMsByUserId(user1.Id)[0];
        System.assertEquals(role1, currentAtm.TeamMemberRole);
        //4.1.2) check User2 (User2-Role3 should be CREATED)
        currentAtm = currentATMsHelper.getATMsByUserId(user2.Id)[0];
        System.assertEquals(role3, currentAtm.TeamMemberRole);
        //4.1.3) check User4 (User4-Role2 should NOT be UPDATED)
        currentAtm = currentATMsHelper.getATMsByUserId(user4.Id)[0];
        System.assertEquals(role2, currentAtm.TeamMemberRole);
        
        //4.2) check contract account
        currentATMs = parentATMsHelper.getATMsByAccountId(contractAccount1.Id);
        System.assertEquals(1, currentATMs.size());
        currentATMsHelper = H_C_AccountTeamMemberHelper.createHelperByATMsList(currentATMs);
        
        //4.2.1) check User1 (User1-Role1 should be CREATED)
        currentAtm = currentATMsHelper.getATMsByUserId(user1.Id)[0];
        System.assertEquals(role1, currentAtm.TeamMemberRole);
    }
    
    @IsTest
    private static void testManager_updateTeams_CorrectData3()
    {
        // CORRECT PARAMETERS:
        //STEP #1: set the environment
        //disable triggers to increase the performance of the test and test the logic
        //separately from them
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        String role1 = 'Role1';
        String role2 = 'Role2';
        //set ignorable team roles in custom setting
        H_C_UnitTestUtils.createSetting(H_C_CustomSettings.ATRU_IGNORABLE_TEAM_ROLES, role2);
        
        //set options for key accounts
        String[] rolesForNewATMs = new String[] {role1, H_C_CustomSettings.ANY_ROLE_NAME};
        setSettingsForKeyAccount(Double.valueOf(50), createTestShare(), rolesForNewATMs);
        
        //set options for contract accounts
        rolesForNewATMs = new String[] {role1};
        setSettingsForContractAccount(100, createTestShare(), rolesForNewATMs);
        
        //STEP #2: create test data:
        //HIERARCHY OF ACCOUNTS:
        //- contractAccount1 -> keyAccount1 -> (trAccount1)
        //ATMs:
        //- contractAccount1 has no ATMs
        //- keyAccount1 has User1-Role1 and User2-Role2 in ATMs
        //- trAccount1 has no ATMs
        //Such configuration allows us to test that deferred accounts will be correctly updated
        //in later transactions. keyAccount1 should be updated in the 1st transaction, contractAccount1
        //should be update in the 2nd one. Even if ATMs of keyAccount1 are not be updated, ATMs of
        //contractAccount1 will be updated
        
        //1) create accounts
        Account contractAccount1 = H_C_UnitTestUtils.createAccount('Contract Account1');
        contractAccount1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
        
        Account keyAccount1 = H_C_UnitTestUtils.createAccount('Key Account1', contractAccount1.Id);
        keyAccount1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        
        Account trAccount1 = H_C_UnitTestUtils.createAccount('Transactional Account1', keyAccount1.Id);
        trAccount1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        
        update new Account[] {contractAccount1, keyAccount1, trAccount1};
        
        //2) create users
        User user1 = H_C_UnitTestUtils.createSfUser('User1');
        User user2 = H_C_UnitTestUtils.createSfUser('User2');
        
        //3) create ATMs
        AccountTeamMember keyMember1 = H_C_UnitTestUtils.constructAccountTeamMember(
        	keyAccount1.Id, user1.Id, role1);
        AccountTeamMember keyMember2 = H_C_UnitTestUtils.constructAccountTeamMember(
        	keyAccount1.Id, user2.Id, role2);
        
        insert new AccountTeamMember[] {keyMember1, keyMember2};
        
        //STEP #3: start the process
        
        //initialize options for a manager
        H_C_ATRU_Manager.Options options = new H_C_ATRU_Manager.Options();
        options.allAccountsHaveParentalRights = true;
        options.allAccountsOfSameType = false;
        options.processEntireHierarchy = true;
        
        //initialize a manager
        Account[] processedAccounts = H_C_AccountDAO.getAccountsByIds(
        	new String[] {contractAccount1.Id, keyAccount1.Id});
        H_C_ATRU_Manager manager = new H_C_ATRU_Manager(processedAccounts, options);
        //start the process
        manager.updateTeams();
        
        //we should get the following state for teams:
        //- trAccount1 has no ATMs - NOTHING SHOULD BE CHANGED
        //- keyAccount1 has User1-Role1, User2-Role2 in ATMs - NOTHING SHOULD BE CHANGED
        //- contractAccount1 has User1-Role1 in ATMs (Role2 is ignored by the rollup mechanism initially)
        
        //STEP #4: check the results:
        //get ATMs of key account and contract account
        AccountTeamMember[] allParentTeamMembers = H_C_AccountTeamMemberDAO.getATMsByAccountsIds(
        	new String[] {contractAccount1.Id, keyAccount1.Id});
        H_C_AccountTeamMemberHelper parentATMsHelper =
        	H_C_AccountTeamMemberHelper.createHelperByATMsList(allParentTeamMembers);
        
        //4.1) check key account
        AccountTeamMember[] currentATMs = parentATMsHelper.getATMsByAccountId(keyAccount1.Id);
        System.assertEquals(2, currentATMs.size());
        System.assert(currentATMs[0].Id == keyMember1.Id && currentATMs[1].Id == keyMember2.Id
        	|| currentATMs[1].Id == keyMember1.Id && currentATMs[0].Id == keyMember2.Id);
        
        //4.2) check contract account
        currentATMs = parentATMsHelper.getATMsByAccountId(contractAccount1.Id);
        System.assertEquals(1, currentATMs.size());
        System.assertEquals(role1, currentAtms[0].TeamMemberRole);
        System.assertEquals(user1.Id, currentAtms[0].UserId);
    }
    
    //This method tests a simple set of data and rollup process will be disabled
    //at KA->CA direction  
    @IsTest
    private static void testManager_updateTeams_CorrectData4()
    {
        // CORRECT PARAMETERS:
        //STEP #1: set the environment
        //disable triggers to increase the performance of the test and test the logic
        //separately from them
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        String role1 = 'Role1';
        //set only options for key accounts
        String[] rolesForNewATMs = new String[] {H_C_CustomSettings.ANY_ROLE_NAME};
        setSettingsForKeyAccount(Double.valueOf(50), createTestShare(), rolesForNewATMs);
        
        //STEP #2: create test data:
        //HIERARCHY OF ACCOUNTS:
        //- contractAccount1 -> keyAccount1 -> trAccount1
        //ATMs:
        //- contractAccount1 has no ATMs
        //- keyAccount1 has no ATMs
        //- trAccount1 has User1-Role1 in ATMs
        //Such data allow us to test disabling of the mechanism at different levels
        
        //1) create accounts
        Account contractAccount1 = H_C_UnitTestUtils.createAccount('Contract Account1');
        contractAccount1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
        
        Account keyAccount1 = H_C_UnitTestUtils.createAccount('Key Account1', contractAccount1.Id);
        keyAccount1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        
        Account trAccount1 = H_C_UnitTestUtils.createAccount('Transactional Account1', keyAccount1.Id);
        trAccount1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        
        update new Account[] {contractAccount1, keyAccount1, trAccount1};
        
        //2) create users
        User user1 = H_C_UnitTestUtils.createSfUser('User1');
        
        //3) create ATMs
        AccountTeamMember trMember1 = H_C_UnitTestUtils.constructAccountTeamMember(
        	trAccount1.Id, user1.Id, role1);
        insert new AccountTeamMember[] {trMember1};
        
        
        //STEP #3: start the process
        
        //create a separate transaction in the test to run a real code separately from
        //service code of the Unit test
        Test.startTest();
	        //initialize options for a manager
	        H_C_ATRU_Manager.Options options = new H_C_ATRU_Manager.Options();
	        options.allAccountsHaveParentalRights = true;
	        options.allAccountsOfSameType = false;
	        options.processEntireHierarchy = false;
	        
	        //initialize a manager
	        H_C_ATRU_Manager manager = new H_C_ATRU_Manager(
	        	new String[] {keyAccount1.Id, contractAccount1.Id}, options);
	        //start the process
	        manager.updateTeams();
        Test.stopTest();
        
        
        //STEP #4: check the results:
        //we should get the following state for teams:
        //- contractAccount1 has no ATMs - THERE ARE NO SETTINGS TO ROLL UP ATMs TO CONTRACT LEVEL
        //- keyAccount1 has has User1-Role1 in ATMs - NEW ATM SHOULD BE CREATED
        //- trAccount1 has User1-Role1 in ATMs - NOTHING SHOULD BE CHANGED
        
        //get ATMs of key account and contract account
        AccountTeamMember[] allParentTeamMembers = H_C_AccountTeamMemberDAO.getATMsByAccountsIds(
        	new String[] {contractAccount1.Id, keyAccount1.Id});
        H_C_AccountTeamMemberHelper parentATMsHelper =
        	H_C_AccountTeamMemberHelper.createHelperByATMsList(allParentTeamMembers);
        
        //4.1) check key account
        AccountTeamMember[] currentATMs = parentATMsHelper.getATMsByAccountId(keyAccount1.Id);
        System.assertEquals(1, currentATMs.size());
        System.assertEquals(role1, currentAtms[0].TeamMemberRole);
        System.assertEquals(user1.Id, currentAtms[0].UserId);
        
        //4.2) check contract account
        currentATMs = parentATMsHelper.getATMsByAccountId(contractAccount1.Id);
        System.assertEquals(0, currentATMs.size());
    }
    
    //This method tests how an account without child accounts is processed by the rollup mechanism
    @IsTest
    private static void testManager_updateTeams_CorrectData5()
    {
        // CORRECT PARAMETERS:
        //STEP #1: set the environment
        //disable triggers to increase the performance of the test and test the logic
        //separately from them
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        //set only options for contract accounts
        String[] rolesForNewATMs = new String[] {H_C_CustomSettings.ANY_ROLE_NAME};
        setSettingsForContractAccount(Double.valueOf(50), createTestShare(), rolesForNewATMs);
        
        //STEP #2: create test data:
        //- contractAccount1 has no ATMs
        //1) create account
        Account contractAccount1 = H_C_UnitTestUtils.constructAccount('Contract Account1');
        contractAccount1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
        insert new Account[] {contractAccount1};
        //2) create users
        User user1 = H_C_UnitTestUtils.createSfUser('User1');
        
        //STEP #3: start the process
        //create a separate transaction in the test to run a real code separately from
        //service code of the Unit test
        Test.startTest();
	        //initialize options for a manager
	        H_C_ATRU_Manager.Options options = new H_C_ATRU_Manager.Options();
	        options.allAccountsHaveParentalRights = true;
	        options.allAccountsOfSameType = true;
	        options.processEntireHierarchy = true;
	        
	        //initialize a manager
	        H_C_ATRU_Manager manager = new H_C_ATRU_Manager(new String[] {contractAccount1.Id}, options);
	        //start the process
	        manager.updateTeams();
        Test.stopTest();
        
        //STEP #4: check the results: NOTHING SHOULD BE CHANGED
        //get ATMs of key account and contract account
        AccountTeamMember[] allParentTeamMembers = H_C_AccountTeamMemberDAO.getATMsByAccountsIds(
        	new String[] {contractAccount1.Id});
        System.assertEquals(0, allParentTeamMembers.size());
    }
    
    @IsTest
    private static void testManager_updateTeams_IncorrectData()
    {
        //WRONG AND EMPTY PARAMETERS
        //1.1) incorrent parameters in a constructor
        try
        {
        	H_C_ATRU_Manager manager = new H_C_ATRU_Manager(new Account[0], null);
        	System.assert(false);
        }
        catch (H_C_Exception error)
        {
        	System.assert(true);
        }
        
        //1.2) incorrent parameters in a constructor
        try
        {
        	String[] accountsIds = null;
        	H_C_ATRU_Manager manager = new H_C_ATRU_Manager(accountsIds, null);
        	System.assert(false);
        }
        catch (H_C_Exception error)
        {
        	System.assert(true);
        }
        
        //1.3) pass account which has no parental rights
        //initialize options for a manager
        H_C_ATRU_Manager.Options options = new H_C_ATRU_Manager.Options();
        options.allAccountsHaveParentalRights = false;
        options.allAccountsOfSameType = true;
        options.processEntireHierarchy = true;
        //create test account
        Account unknownAccount = H_C_UnitTestUtils.createAccount('Unknown Account');
        //initialize a manager and start the process
        H_C_ATRU_Manager manager = new H_C_ATRU_Manager(new Account[] {unknownAccount}, options);
        manager.updateTeams();
        
        //1.4) pass account which has no child accounts
        Account keyAccount = H_C_UnitTestUtils.constructAccount('Test Key Account');
        keyAccount.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        insert keyAccount;
        //initialize a manager and start the process
        manager = new H_C_ATRU_Manager(new Account[] {keyAccount}, options);
        manager.updateTeams();
    }
    
    @IsTest
    private static void testUtils_updateTeamsInTrigger_onAccountsUpdated()
    {
    	//disable triggers
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
    	
        // WRONG AND EMPTY PARAMETERS (we should not get exceptions)
        H_C_ATR_Utils.updateTeamsInTrigger_onAccountsUpdated(null, null);
        H_C_ATR_Utils.updateTeamsInTrigger_onAccountsUpdated(new Map<Id, Account>(), new Account[0]);
        //test account which has no record type
        Account testAccount = H_C_UnitTestUtils.createAccount('Test Account');
        H_C_ATR_Utils.updateTeamsInTrigger_onAccountsUpdated(
        	new Map<Id, Account> {testAccount.Id => testAccount}, new Account[] {testAccount});
        
        // CORRECT PARAMETERS
        //STEP #1: set the environment
        String role1 = 'Role1';
        String role2 = 'Role2';
        //set ignorable team roles in custom setting
        H_C_UnitTestUtils.createSetting(H_C_CustomSettings.ATRU_IGNORABLE_TEAM_ROLES, role2);
        
        //set options for contract accounts
        String[] rolesForNewATMs = new String[] {role1};
        setSettingsForContractAccount(Double.valueOf(80), createTestShare(), rolesForNewATMs);
        
        //STEP #2: create test data:
        //HIERARCHY OF ACCOUNTS:
        //- contractAccount1 -> (keyAccount1, keyAccount2)
        //ATMs:
        //- contractAccount1 has no ATMs
        //- keyAccount1 has User1-Role1, User2-Role1 in ATMs
        //- keyAccount2 has User1-Role1, User2-Role2 in ATMs
        
        //1) create accounts
        Account contractAccount1 = H_C_UnitTestUtils.createAccount('Contract Account1');
        contractAccount1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
        
        Account keyAccount1 = H_C_UnitTestUtils.createAccount('Key Account1', contractAccount1.Id);
        keyAccount1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        
        Account keyAccount2 = H_C_UnitTestUtils.createAccount('Key Account2', contractAccount1.Id);
        keyAccount2.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        
        update new Account[] {contractAccount1, keyAccount1, keyAccount2};
        
        //2) create users
        User user1 = H_C_UnitTestUtils.createSfUser('User1');
        User user2 = H_C_UnitTestUtils.createSfUser('User2');
        
        //3) create ATMs
        AccountTeamMember keyMember11 = H_C_UnitTestUtils.constructAccountTeamMember(
        	keyAccount1.Id, user1.Id, role1);
        AccountTeamMember keyMember12 = H_C_UnitTestUtils.constructAccountTeamMember(
        	keyAccount1.Id, user2.Id, role1);
        
        AccountTeamMember keyMember21 = H_C_UnitTestUtils.constructAccountTeamMember(
        	keyAccount2.Id, user1.Id, role1);
        AccountTeamMember keyMember22 = H_C_UnitTestUtils.constructAccountTeamMember(
        	keyAccount2.Id, user2.Id, role2);
        
        insert new AccountTeamMember[] {keyMember11, keyMember12, keyMember21, keyMember22};
        
        //simulate old accounts
        Map<Id, Account> oldAccounts = new Map<Id, Account>();
        Account oldAccount = keyAccount1.clone(true);
        oldAccount.ParentId = null;
        oldAccounts.put(oldAccount.Id, oldAccount);
        
        //STEP #3: perform the method
        H_C_ATR_Utils.updateTeamsInTrigger_onAccountsUpdated(oldAccounts, new Account[] {keyAccount1});
        //STEP #4: check the results:
        AccountTeamMember[] contractAccountATMs = H_C_AccountTeamMemberDAO.getATMsByAccountsIds(
        	new String[] {contractAccount1.Id});
        System.assertEquals(1, contractAccountATMs.size());
        AccountTeamMember contractAccountATM = contractAccountATMs[0];
        System.assertEquals(user1.Id, contractAccountATM.UserId);
        System.assertEquals(role1, contractAccountATM.TeamMemberRole);
    }
    
    
    @IsTest
    private static void test_IncorrectUsingOfATMsCreator()
    {
    	//H_C_ATRU_ATMsCreator can correctly work with contract accounts and key accounts only
    	Account trAccount1 = H_C_UnitTestUtils.constructAccount('Transactional Account1');
        trAccount1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        insert trAccount1;
        
        try
        {
	        //initialize creator by incorrect parameters
	        H_C_ATRU_ATMsCreator creator = new H_C_ATRU_ATMsCreator(trAccount1, new Account[0],
	        	H_C_AccountTeamMemberHelper.createHelperByATMsList(null));
	        System.assert(false);
        }
        catch (H_C_Exception error)
        {
        	System.assert(true);
        }
    }
}