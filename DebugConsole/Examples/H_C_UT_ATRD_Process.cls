//
//This class provides Unit tests for the roll-down mechanism
//Used abbreviations:
// - UT means 'Unit tests'
// - ATRD means 'Account Team Roll-Down'
// - ATM means 'Account Team Member'
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (23-10-2013)
@IsTest
public class H_C_UT_ATRD_Process
{
	//
	//Static service methods
	//
	public static void setSettingsForKeyAccount(String[] ignorableRoles)
	{
		H_C_UnitTestUtils.createSetting(H_C_CustomSettings.ATRD_CA_2_KA_IGNORABLE_TEAM_ROLES,
			String.join(ignorableRoles, H_C_CustomSettings.SEPARATOR_OF_ROLES));
		
		H_C_UnitTestUtils.createSetting(H_C_CustomSettings.ATRD_PROCESS_ENABLED, 'TRUE');
	}
	
	public static void setSettingsForTransactionalAccount(String[] ignorableRoles)
	{
		H_C_UnitTestUtils.createSetting(H_C_CustomSettings.ATRD_KA_2_TA_IGNORABLE_TEAM_ROLES,
			String.join(ignorableRoles, H_C_CustomSettings.SEPARATOR_OF_ROLES));
		
		H_C_UnitTestUtils.createSetting(H_C_CustomSettings.ATRD_PROCESS_ENABLED, 'TRUE');
	}
	
	private static void compareEqualPermissions(AccountShare share1, AccountShare share2)
	{
		System.assertEquals(share1.AccountAccessLevel, share2.AccountAccessLevel);
		System.assertEquals(share1.OpportunityAccessLevel, share2.OpportunityAccessLevel);
		System.assertEquals(share1.CaseAccessLevel, share2.CaseAccessLevel);
	}
	
	private static String[] extractAccountsIds(AccountWrapper[] accountWrappers)
	{
		List<Account> accounts = new List<Account>();
		for (AccountWrapper accountWrapper : accountWrappers)
		{
			accounts.add(accountWrapper.account);
		}
		
		return H_C_AccountHelper.extractAccountsIds(accounts);
	}
	
	private static void checkDesiredResults(AccountWrapper[] desiredAccounts)
	{
		//STEP #1: get all necessary data from the DB
		String[] allAccountsIds = extractAccountsIds(desiredAccounts);
		
		//get ATMs of all accounts and initialize a helper for them
        AccountTeamMember[] allTeamMembers =
        	H_C_AccountTeamMemberDAO.getATMsByAccountsIds(allAccountsIds);
        H_C_AccountTeamMemberHelper atmsHelper =
        	H_C_AccountTeamMemberHelper.createHelperByATMsList(allTeamMembers);
        
        //get shares of all accounts and initialize a helper for them
        H_C_AccountShareDAO.Filter sharesFilter = new H_C_AccountShareDAO.Filter();
        sharesFilter.accountsIds = allAccountsIds;
        H_C_AccountShareHelper sharesHelper = H_C_AccountShareHelper.createHelperByFilter(sharesFilter);
		
		
		//STEP #2: check that real data equal to desired data
		for (AccountWrapper desiredAccount : desiredAccounts)
		{
			AccountTeamMember[] currentATMs = atmsHelper.getATMsByAccountId(desiredAccount.account.Id);
	        System.assertEquals(desiredAccount.atmWrappers.size(), currentATMs.size());
	        
	        for (ATM_Wrapper desiredAtm : desiredAccount.atmWrappers)
	        {
		        AccountTeamMember currentAtm = atmsHelper.getATMByAccountIdAndUserId(
		        	desiredAccount.account.Id, desiredAtm.userId);
		        System.assertEquals(desiredAtm.teamMemberRole, currentAtm.TeamMemberRole);
		        
		        AccountShare currentShare = sharesHelper.getShareByAccountIdAndUserId(
		        	desiredAccount.account.Id, desiredAtm.userId);
		        compareEqualPermissions(desiredAtm.permissions, currentShare);
	        }
		}
	}
	//
	
	
    
    
    
    //
    //Unit tests
    //
    //This method tests a complex situation
    @IsTest
    private static void testManager_updateTeams_CorrectData()
    {
        //STEP #1: set the environment
        //disable triggers to increase the performance of the test and test the logic
        //separately from them
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        String role1 = 'Role1';
        String role2 = 'Role2';
        String role3 = 'Role3';
        
        //set options for key accounts (role2 will be ignored)
        setSettingsForKeyAccount(new String[] {role2});
        //set options for transactional accounts (role3 will be ignored)
        setSettingsForTransactionalAccount(new String[] {role3});
        
        //STEP #2: create test data:
        //HIERARCHY OF ACCOUNTS:
        //- contractAccount1 -> keyAccount1, keyAccount2
        //-- keyAccount1 -> trAccount11, trAccount12
        //-- keyAccount2 -> trAccount21
        //ATMs:
        //- contractAccount1 has ATMS: User1-Role1, User2-Role2, User3-Role1
        //-- keyAccount1 has ATMS: User2-Role3
        //-- keyAccount2 has ATMS: User3-Role3
        //--- trAccount11 has ATMS: User1-Role3
        //--- trAccount12 and trAccount21 has no ATMs
        
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
        
        Account trAccount11 = H_C_UnitTestUtils.createAccount('Transactional Account1', keyAccount1.Id);
        trAccount11.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        Account trAccount12 = H_C_UnitTestUtils.createAccount('Transactional Account2', keyAccount1.Id);
        trAccount12.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        
        Account trAccount21 = H_C_UnitTestUtils.createAccount('Transactional Account1', keyAccount2.Id);
        trAccount21.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        
        update new Account[] {contractAccount1, keyAccount1, keyAccount2, trAccount11,
        	trAccount12, trAccount21};
        
        //2) create users
        User user1 = H_C_UnitTestUtils.createSfUser('User1');
        User user2 = H_C_UnitTestUtils.createSfUser('User2');
        User user3 = H_C_UnitTestUtils.createSfUser('User3');
        
        //3) create ATMs and their shares
        AccountTeamMember contractMember1 = H_C_UnitTestUtils.constructAccountTeamMember(
        	contractAccount1.Id, user1.Id, role1);
        AccountShare contractShare1 = H_C_UnitTestUtils.constructAccountShare(contractAccount1.Id,
        	user1.Id, H_C_AccessLevel.EDIT, H_C_AccessLevel.EDIT, H_C_AccessLevel.EDIT);
        
        AccountTeamMember contractMember2 = H_C_UnitTestUtils.constructAccountTeamMember(
        	contractAccount1.Id, user2.Id, role2);
        AccountShare contractShare2 = H_C_UnitTestUtils.constructAccountShare(contractAccount1.Id,
        	user2.Id, H_C_AccessLevel.EDIT, H_C_AccessLevel.EDIT, H_C_AccessLevel.EDIT);
        
        AccountTeamMember contractMember3 = H_C_UnitTestUtils.constructAccountTeamMember(
        	contractAccount1.Id, user3.Id, role1);
        AccountShare contractShare3 = H_C_UnitTestUtils.constructAccountShare(contractAccount1.Id,
        	user3.Id, H_C_AccessLevel.EDIT, H_C_AccessLevel.EDIT, H_C_AccessLevel.EDIT);
        
        AccountTeamMember keyMember11 = H_C_UnitTestUtils.constructAccountTeamMember(
        	keyAccount1.Id, user2.Id, role3);
        AccountShare keyShare11 = H_C_UnitTestUtils.constructAccountShare(keyAccount1.Id,
        	user2.Id, H_C_AccessLevel.READ, H_C_AccessLevel.READ, H_C_AccessLevel.READ);
        
        AccountTeamMember keyMember21 = H_C_UnitTestUtils.constructAccountTeamMember(
        	keyAccount2.Id, user3.Id, role3);
        AccountShare keyShare21 = H_C_UnitTestUtils.constructAccountShare(keyAccount2.Id,
        	user3.Id, H_C_AccessLevel.READ, H_C_AccessLevel.READ, H_C_AccessLevel.READ);
        
        AccountTeamMember trMember11 = H_C_UnitTestUtils.constructAccountTeamMember(
        	trAccount11.Id, user1.Id, role3);
        AccountShare trShare11 = H_C_UnitTestUtils.constructAccountShare(trAccount11.Id,
        	user1.Id, H_C_AccessLevel.EDIT, H_C_AccessLevel.READ, H_C_AccessLevel.NONE);
        
        insert new AccountTeamMember[] {contractMember1, contractMember2, contractMember3,
        	keyMember11, keyMember21, trMember11};
        insert new AccountShare[] {contractShare1, contractShare2, contractShare3,
        	keyShare11, keyShare21, trShare11};
        
        //STEP #3: perform the process (we especially transfer trAccount11 before keyAccount1,
        //because the system should find correct order for the process: if trAccount11 is
        //processed before keyAccount1 then it will not have ATMs who rolled down from
        //contractAccount1
        
        //create a separate transaction in the test to run a real code separately from
        //service code of the Unit test  
        Test.startTest();
        
	        //initialize options for a manager
	        H_C_ATRD_Manager.Options options = new H_C_ATRD_Manager.Options();
	        options.allAccountsOfSameType = false;
	        options.processEntireHierarchy = true;
	        
	        //initialize a manager
	        Account[] processedAccounts = H_C_AccountDAO.getAccountsByIds(
	        	new String[] {trAccount11.Id, keyAccount1.Id, keyAccount2.Id});
	        H_C_ATRD_Manager manager = new H_C_ATRD_Manager(processedAccounts, options);
	        //start the process
	        manager.updateTeams();
        
        Test.stopTest();
        
        
        //STEP #5: fill desired data. We should get the following state for teams:
        //- contractAccount1 has ATMS: User1-Role1, User2-Role2, User3-Role1 - NOTHING CHANGED
        //-- keyAccount1 has ATMS: User1-Role1, User2-Role3, User3-Role1
        //-- keyAccount2 has ATMS: User1-Role1, User3-Role3
        //--- trAccount11 has ATMS: User1-Role3, User3-Role1
        //--- trAccount12 has ATMS: User1-Role1, User3-Role1
        //--- trAccount21 has ATMS: User1-Role1
        List<AccountWrapper> desiredAccountWrappers = new List<AccountWrapper>(); 
        
        //4.1) fill desired results for contractAccount1 (NOTHING should be changed)
        AccountWrapper currentAccountWrapper = new AccountWrapper(contractAccount1);
        desiredAccountWrappers.add(currentAccountWrapper);
        //a) fill User1-Role1
        currentAccountWrapper.atmWrappers.add(new ATM_Wrapper(user1.Id, role1, contractShare1));
        //b) fill User2-Role2
        currentAccountWrapper.atmWrappers.add(new ATM_Wrapper(user2.Id, role2, contractShare2));
        //c) fill User3-Role1
        currentAccountWrapper.atmWrappers.add(new ATM_Wrapper(user3.Id, role1, contractShare3));
        
        //4.2) fill desired results for keyAccount1
        currentAccountWrapper = new AccountWrapper(keyAccount1);
        desiredAccountWrappers.add(currentAccountWrapper);
        //a) fill User1-Role1 with permissions from contract level (he should be CREATED)
        currentAccountWrapper.atmWrappers.add(new ATM_Wrapper(user1.Id, role1, contractShare1));
        //b) fill User2-Role3 with own initial permissions (he should NOT be UPDATED)
        currentAccountWrapper.atmWrappers.add(new ATM_Wrapper(user2.Id, role3, keyShare11));
        //c) fill User3-Role1 with permissions from contract level (he should be CREATED)
        currentAccountWrapper.atmWrappers.add(new ATM_Wrapper(user3.Id, role1, contractShare3));
        
        //4.3) fill desired results for keyAccount2
        currentAccountWrapper = new AccountWrapper(keyAccount2);
        desiredAccountWrappers.add(currentAccountWrapper);
        //a) fill User1-Role1 with permissions from contract level (he should be CREATED)
        currentAccountWrapper.atmWrappers.add(new ATM_Wrapper(user1.Id, role1, contractShare1));
        //b) fill User3-Role3 with own initial permissions (he should NOT be UPDATED)
        currentAccountWrapper.atmWrappers.add(new ATM_Wrapper(user3.Id, role3, keyShare21));
        
        //4.4) fill desired results for trAccount11
        currentAccountWrapper = new AccountWrapper(trAccount11);
        desiredAccountWrappers.add(currentAccountWrapper);
        //a) fill User1-Role3 with own initial permissions (he should NOT be UPDATED)
        currentAccountWrapper.atmWrappers.add(new ATM_Wrapper(user1.Id, role3, trShare11));
        //b) fill User3-Role1 with permissions from contract->key level (he should be CREATED)
        currentAccountWrapper.atmWrappers.add(new ATM_Wrapper(user3.Id, role1, contractShare1));
        
        //4.5) fill desired results for trAccount12
        currentAccountWrapper = new AccountWrapper(trAccount12);
        desiredAccountWrappers.add(currentAccountWrapper);
        //a) fill User1-Role1 with permissions from contract->key level (he should be CREATED)
        currentAccountWrapper.atmWrappers.add(new ATM_Wrapper(user1.Id, role1, contractShare1));
        //b) fill User3-Role1 with permissions from contract->key level (he should be CREATED)
        currentAccountWrapper.atmWrappers.add(new ATM_Wrapper(user3.Id, role1, contractShare3));
        
        //4.6) fill desired results for trAccount21
        currentAccountWrapper = new AccountWrapper(trAccount21);
        desiredAccountWrappers.add(currentAccountWrapper);
        //a) fill User1-Role1 with permissions from contract->key level (he should be CREATED)
        currentAccountWrapper.atmWrappers.add(new ATM_Wrapper(user1.Id, role1, contractShare1));
        
        
        //STEP #5: check that real data correcpond to desired data
        checkDesiredResults(desiredAccountWrappers); 
    }
    
    
    //This method tests a simple situation (ATMs should be rolled down from a key level
    //to a transactional level)
    @IsTest
    private static void testManager_updateTeams_CorrectData2()
    {
        //STEP #1: set the environment
        //disable triggers to increase the performance of the test and test the logic
        //separately from them
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        String role1 = 'Role1';
        String role2 = 'Role2';
        
        //set options for transactional accounts (there will not be ignorable roles)
        setSettingsForTransactionalAccount(new String[0]);
        
        //STEP #2: create test data:
        //HIERARCHY OF ACCOUNTS:
        //contractAccount1 -> keyAccount1 -> trAccount1
        //ATMs:
        //- contractAccount1 has no ATMs
        //-- keyAccount1 has ATMS: User1-Role1, User2-Role2
        //--- trAccount1 has ATMS: User2-Role1
        
        //1) create accounts
        Account contractAccount1 = H_C_UnitTestUtils.createAccount('Contract Account1');
        contractAccount1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
        
        Account keyAccount1 = H_C_UnitTestUtils.createAccount('Key Account1');
        keyAccount1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        
        Account trAccount1 = H_C_UnitTestUtils.createAccount('Transactional Account1', keyAccount1.Id);
        trAccount1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT).Id;
        
        update new Account[] {contractAccount1, keyAccount1, trAccount1};
        
        //2) create users
        User user1 = H_C_UnitTestUtils.createSfUser('User1');
        User user2 = H_C_UnitTestUtils.createSfUser('User2');
        
        //3) create ATMs and their shares
        AccountTeamMember keyMember1 = H_C_UnitTestUtils.constructAccountTeamMember(
        	keyAccount1.Id, user1.Id, role1);
        AccountShare keyShare1 = H_C_UnitTestUtils.constructAccountShare(keyAccount1.Id,
        	user1.Id, H_C_AccessLevel.EDIT, H_C_AccessLevel.EDIT, H_C_AccessLevel.EDIT);
        
        AccountTeamMember keyMember2 = H_C_UnitTestUtils.constructAccountTeamMember(
        	keyAccount1.Id, user2.Id, role2);
        AccountShare keyShare2 = H_C_UnitTestUtils.constructAccountShare(keyAccount1.Id,
        	user2.Id, H_C_AccessLevel.EDIT, H_C_AccessLevel.EDIT, H_C_AccessLevel.EDIT);
        
        AccountTeamMember trMember1 = H_C_UnitTestUtils.constructAccountTeamMember(
        	trAccount1.Id, user2.Id, role1);
        AccountShare trShare1 = H_C_UnitTestUtils.constructAccountShare(trAccount1.Id,
        	user2.Id, H_C_AccessLevel.READ, H_C_AccessLevel.READ, H_C_AccessLevel.READ);
        
        insert new AccountTeamMember[] {keyMember1, keyMember2, trMember1};
        insert new AccountShare[] {keyShare1, keyShare2, trShare1};
        
        //STEP #3: perform the process (we intentionally pass contract account along with
        //transactional account, because the manager should filter source accounts
        //and skip contract accounts)
        
        //create a separate transaction in the test to run a real code separately from
        //service code of the Unit test  
        Test.startTest();
        
	        //initialize options for a manager
	        H_C_ATRD_Manager.Options options = new H_C_ATRD_Manager.Options();
	        options.allAccountsOfSameType = false;
	        options.processEntireHierarchy = false;
	        
	        //initialize a manager
	        H_C_ATRD_Manager manager = new H_C_ATRD_Manager(
	        	new String[] {contractAccount1.Id, trAccount1.Id}, options);
	        //start the process
	        manager.updateTeams();
        
        Test.stopTest();
        
        
        //STEP #5: fill desired data. We should get the following state for teams:
        //- keyAccount1 has ATMS: User1-Role1, User2-Role2 - NOTHING CHANGED
        //-- trAccount1 has ATMS: User1-Role1, User2-Role1
        List<AccountWrapper> desiredAccountWrappers = new List<AccountWrapper>(); 
        
        //4.1) fill desired results for keyAccount1 (NOTHING should be changed)
        AccountWrapper currentAccountWrapper = new AccountWrapper(keyAccount1);
        desiredAccountWrappers.add(currentAccountWrapper);
        //a) fill User1-Role1
        currentAccountWrapper.atmWrappers.add(new ATM_Wrapper(user1.Id, role1, keyShare1));
        //b) fill User2-Role2
        currentAccountWrapper.atmWrappers.add(new ATM_Wrapper(user2.Id, role2, keyShare2));
        
        //4.2) fill desired results for trAccount1
        currentAccountWrapper = new AccountWrapper(trAccount1);
        desiredAccountWrappers.add(currentAccountWrapper);
        //a) fill User1-Role1 with permissions from key level (he should be CREATED)
        currentAccountWrapper.atmWrappers.add(new ATM_Wrapper(user1.Id, role1, keyShare1));
        //b) fill User2-Role1 with own initial permissions (he should NOT be UPDATED)
        currentAccountWrapper.atmWrappers.add(new ATM_Wrapper(user2.Id, role1, trShare1));
        
        
        //STEP #5: check that real data correcpond to desired data
        checkDesiredResults(desiredAccountWrappers); 
    }
    
    //This method tests how the manager works with incorrect data
    @IsTest
    private static void testManager_updateTeams_IncorrectData()
    {
    	//STEP #1: set the environment
        //disable triggers to increase the performance of the test and test the logic
        //separately from them
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
    	
    	//STEP #2: perform tests
        //WRONG AND EMPTY PARAMETERS
        //1.1) incorrent parameters in a constructor
        try
        {
        	H_C_ATRD_Manager manager = new H_C_ATRD_Manager(new Account[0], null);
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
        	H_C_ATRD_Manager manager = new H_C_ATRD_Manager(accountsIds, new H_C_ATRD_Manager.Options());
        	System.assert(false);
        }
        catch (H_C_Exception error)
        {
        	System.assert(true);
        }
        
        
        //1.3) pass accounts which can not be child accounts
        //create test data: 
        //- create test contract account
        Account contractAccount = H_C_UnitTestUtils.constructAccount('Contract Account');
        contractAccount.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
        //- create test unknown account
        Account unknownAccount = H_C_UnitTestUtils.constructAccount('Unknown Account');
        //- insert data
        insert new Account[] {contractAccount, unknownAccount};
        
        //initialize options for a manager
        H_C_ATRD_Manager.Options options = new H_C_ATRD_Manager.Options();
        options.allAccountsOfSameType = false;
        options.processEntireHierarchy = true;
        //initialize a manager and start the process
        H_C_ATRD_Manager manager = new H_C_ATRD_Manager(
        	new String[] {contractAccount.Id, unknownAccount.Id}, options);
        manager.updateTeams();
        
        
        //1.4) test work with a single contract account (contract account can't be processed
        //by the roll-down mechanism)
        options.allAccountsOfSameType = true;
        //initialize a manager and start the process
        manager = new H_C_ATRD_Manager(new String[] {contractAccount.Id}, options);
        manager.updateTeams();
        
        
        //1.5) pass key account which has no parent
        //set options for key accounts (there will not be ignorable roles)
        setSettingsForKeyAccount(new String[0]);
        
        Account keyAccount = H_C_UnitTestUtils.constructAccount('Key Account');
        keyAccount.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        insert keyAccount;
        
        //initialize a manager and start the process
        manager = new H_C_ATRD_Manager(new String[] {keyAccount.Id}, options);
        manager.updateTeams();
    }
    //
    
    
    
    
    
    //
    //Data types
    //
    private class AccountWrapper
    {
    	//
    	//Constructors
    	//
    	public AccountWrapper(Account account)
    	{
    		this.account = account;
    		this.atmWrappers = new List<ATM_Wrapper>();
    	}
    	//
    	
    	//
    	//Properties
    	//
    	public Account account {get; set;}
    	public List<ATM_Wrapper> atmWrappers {get; private set;}
    	//
    }
    
    private class ATM_Wrapper
    {
    	//
    	//Constructors
    	//
    	public ATM_Wrapper(String userId, String teamMemberRole, AccountShare permissions)
    	{
    		this.userId = userId;
    		this.teamMemberRole = teamMemberRole;
    		this.permissions = permissions;
    	}
    	//
    	
    	//
    	//Properties
    	//
    	public String userId {get; set;}
    	public String teamMemberRole {get; set;}
    	public AccountShare permissions {get; set;}
    	//
    }
    //
}