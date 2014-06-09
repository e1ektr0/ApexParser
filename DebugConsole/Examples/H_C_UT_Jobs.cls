//
//The class contains Unit tests for APEX jobs and scheduled jobs
//Used abbreviations:
// - UT means 'Unit test'
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (10-09-2013)
@IsTest
public class H_C_UT_Jobs
{
	/*//
	//Unit tests for 'H_C_BgAccountDependenciesManager' class
	//
	@IsTest
	private static void test_BgAccountDependenciesManager()
	{
		//the test simply covers the methods of the class 
		H_C_BgAccountDependenciesManager manager = new H_C_BgAccountDependenciesManager(null);
		manager.start(null);
		manager.execute(null, new Account[0]);
		Account testAccount1 = H_C_UnitTestUtils.createAccount('Account1');
		manager.allFailedAccountsIds = new String[] {testAccount1.Id};
		manager.finish(null);
	}
	//*/
	
	
	
	
	
	//
    //Unit tests for 'H_C_BgAccountHierarchiesManager' class
    //
    @IsTest
    private static void test_BgAccountHierarchiesManager()
    {
        //the test simply covers the methods of the class 
        H_C_BgAccountHierarchiesManager creator = new H_C_BgAccountHierarchiesManager(null);
        creator.start(null);
        creator.execute(null, new Account[0]);
        creator.finish(null);
    }
    //
	
	
	
	
	
	//
    //Unit tests for 'H_C_ATRU_BgManager' class
    //
    @IsTest
    private static void test_ATRU_BgManager1()
    {
    	//TEST #1: wrong parameters
    	try
    	{
    		String query = null;
    		H_C_ATRU_BgManager manager = new H_C_ATRU_BgManager(query, null);
    		System.assert(false);
    	}
    	catch (H_C_Exception error)
    	{
    		System.assert(true);
    	}
    	
        //TEST #2: simply cover the methods of the class (the logic of 'H_C_ATRU_Manager' class is
        //covered in separate Unit tests)
        String incorrectQueryString = 'Select Id From UnknownStandardObject limit 1'; 
        H_C_ATRU_BgManager manager =
        	new H_C_ATRU_BgManager(incorrectQueryString, new H_C_ATRU_Manager.Options());
        manager.start(null);
        manager.execute(null, new Account[0]);
        manager.finish(null);
    }
    
    @IsTest
    private static void test_ATRU_BgManager2()
    {
    	//TEST #1: wrong parameters
    	try
    	{
    		H_C_SoqlUtils.IQueryCreator queryCreator = null;
    		H_C_ATRU_BgManager manager =
    			new H_C_ATRU_BgManager(queryCreator, new H_C_ATRU_Manager.Options());
    		System.assert(false);
    	}
    	catch (H_C_Exception error)
    	{
    		System.assert(true);
    	}
    	
        //TEST #2: simply cover the methods of the class (the logic of 'H_C_ATRU_Manager' class is
        //covered in separate Unit tests)
        SimpleQueryCreator queryCreator = new SimpleQueryCreator('Select Id From Account limit 1'); 
        H_C_ATRU_BgManager manager =
        	new H_C_ATRU_BgManager(queryCreator, new H_C_ATRU_Manager.Options());
        manager.start(null);
        manager.execute(null, new Account[0]);
        manager.finish(null);
    }
    //
    
    
    
    
    
    //
    //Unit tests for 'H_C_ATRD_BgManager' class
    //
    @IsTest
    private static void test_ATRD_BgManager1()
    {
    	//TEST #1: wrong parameters
    	try
    	{
    		String query = null;
    		H_C_ATRD_BgManager manager = new H_C_ATRD_BgManager(query, null);
    		System.assert(false);
    	}
    	catch (H_C_Exception error)
    	{
    		System.assert(true);
    	}
    	
        //TEST #2: simply cover the methods of the class (the logic of 'H_C_ATRD_Manager' class is
        //covered in separate Unit tests)
        String incorrectQueryString = 'Select Id From UnknownStandardObject limit 1'; 
        H_C_ATRD_BgManager manager =
        	new H_C_ATRD_BgManager(incorrectQueryString, new H_C_ATRD_Manager.Options());
        manager.start(null);
        manager.execute(null, new Account[0]);
        manager.finish(null);
    }
    
    @IsTest
    private static void test_ATRD_BgManager2()
    {
    	//TEST #1: wrong parameters
    	try
    	{
    		H_C_SoqlUtils.IQueryCreator queryCreator = null;
    		H_C_ATRD_BgManager manager =
    			new H_C_ATRD_BgManager(queryCreator, new H_C_ATRD_Manager.Options());
    		System.assert(false);
    	}
    	catch (H_C_Exception error)
    	{
    		System.assert(true);
    	}
    	
        //TEST #2: simply cover the methods of the class (the logic of 'H_C_ATRU_Manager' class is
        //covered in separate Unit tests)
        SimpleQueryCreator queryCreator = new SimpleQueryCreator('Select Id From Account limit 1'); 
        H_C_ATRD_BgManager manager =
        	new H_C_ATRD_BgManager(queryCreator, new H_C_ATRD_Manager.Options());
        manager.start(null);
        manager.execute(null, new Account[0]);
        manager.finish(null);
    }
    //
    
    
    
    
    
    //
	//Unit tests for 'H_C_ScheduledAccountsManager' class
	//
	@IsTest
	private static void test_ScheduledAccountsManager()
	{
		//STEP #1: SET THE ENVIRONMENT
		//disable triggers to increase the performance of the test and test the logic
        //separately from them
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
        
        String role1 = 'Role1';
        String role2 = 'Role2';
        
        //1.1) set options for the ROLL-UP process
        //set options for key accounts
        String[] rolesForNewATMs = new String[] {H_C_CustomSettings.ANY_ROLE_NAME};
        H_C_UT_ATRU_Process.setSettingsForKeyAccount(
        	100, H_C_UT_ATRU_Process.createTestShare(), rolesForNewATMs);
        //set options for contract accounts
        H_C_UT_ATRU_Process.setSettingsForContractAccount(
        	100, H_C_UT_ATRU_Process.createTestShare(), rolesForNewATMs);
        
        //1.2) set options for the ROLL-DOWN process
        ////set options for key accounts
        H_C_UT_ATRD_Process.setSettingsForKeyAccount(new String[0]);
        //set options for transactional accounts
        H_C_UT_ATRD_Process.setSettingsForTransactionalAccount(new String[0]);
        
		
		//STEP #2: CREATE TEST DATA
		//HIERARCHY OF ACCOUNTS:
        //- contractAccount1 -> keyAccount1
        //ATMs:
        //- contractAccount1 has ATMS: User1-Role1
        //-- keyAccount1 has ATMS: User2-Role2
        
        //create accounts
        Account contractAccount1 = H_C_UnitTestUtils.constructAccount('Contract Account1');
        Account keyAccount1 = H_C_UnitTestUtils.constructAccount('Key Region Account1');
        Account[] accounts = new Account[] {contractAccount1, keyAccount1};
        insert accounts;
		
        contractAccount1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.CONTRACT_ACCOUNT).Id;
        
        keyAccount1.RecordTypeId = H_C_AccountRecordType.mapOfNamesAndRecordTypes.get(
        	H_C_AccountRecordType.KEY_REGION_ACCOUNT).Id;
        keyAccount1.ParentId = contractAccount1.Id;
        
        update accounts;
        
        //create SF user
        User user1 = H_C_UnitTestUtils.createSfUser('User1');
        User user2 = H_C_UnitTestUtils.createSfUser('User2');
        
        //create ATMs
        AccountTeamMember contractMember1 = H_C_UnitTestUtils.constructAccountTeamMember(
        	contractAccount1.Id, user1.Id, role1);
        AccountTeamMember keyMember1 = H_C_UnitTestUtils.constructAccountTeamMember(
        	keyAccount1.Id, user2.Id, role2);
        insert new AccountTeamMember[] {contractMember1, keyMember1};
        
        
        //STEP #3: START THE SCHEDULER
        Test.startTest();
	        H_C_ScheduledAccountsManager scheduler = new H_C_ScheduledAccountsManager();
			scheduler.execute(null);
		Test.stopTest();
		
		
		//STEP #4: CHECK THE RESULTS
		//We should get the following state for teams:
        //- contractAccount1 has ATMS: User1-Role1, User2-Role2
        //-- keyAccount1 has ATMS: User1-Role1, User2-Role2
        
		//get ATMs of all accounts and initialize a helper for them
        AccountTeamMember[] allTeamMembers = H_C_AccountTeamMemberDAO.getATMsByAccountsIds(
        	new String[] {contractAccount1.Id, keyAccount1.Id});
        H_C_AccountTeamMemberHelper atmsHelper =
        	H_C_AccountTeamMemberHelper.createHelperByATMsList(allTeamMembers);
        
        //check contractAccount1
        AccountTeamMember[] currentATMs = atmsHelper.getATMsByAccountId(contractAccount1.Id);
        System.assertEquals(2, currentATMs.size());
        //- check User1-Role-1
        AccountTeamMember currentATM = atmsHelper.getATMByAccountIdAndUserId(contractAccount1.Id, user1.Id);
        System.assertEquals(role1, currentATM.TeamMemberRole);
        //- check User2-Role-2
        currentATM = atmsHelper.getATMByAccountIdAndUserId(contractAccount1.Id, user2.Id);
        System.assertEquals(role2, currentATM.TeamMemberRole);
        
        //check keyAccount1
        currentATMs = atmsHelper.getATMsByAccountId(keyAccount1.Id);
        System.assertEquals(2, currentATMs.size());
        //- check User1-Role-1
        currentATM = atmsHelper.getATMByAccountIdAndUserId(keyAccount1.Id, user1.Id);
        System.assertEquals(role1, currentATM.TeamMemberRole);
        //- check User2-Role-2
        currentATM = atmsHelper.getATMByAccountIdAndUserId(keyAccount1.Id, user2.Id);
        System.assertEquals(role2, currentATM.TeamMemberRole);
        
	}
	//
	
	
	
	
	
	//
	//Data types
	//
	private class SimpleQueryCreator implements H_C_SoqlUtils.IQueryCreator
	{
		//
		//Constructors
		//
		public SimpleQueryCreator(String queryString)
		{
			this.queryString = queryString;
		}
		//
		
		//
		//Variables
		//
		private String queryString;
		//
		
		//
		//Implementation of 'H_C_SoqlUtils.IQueryCreator' interface
		//
		public String createQuery()
		{
			return this.queryString;
		}
		//
	}
	//
}