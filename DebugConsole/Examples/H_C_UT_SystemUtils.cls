//
//This class contains Unit tests for all classes which provide system utilities
//Used abbreviations:
// - UT means 'Unit test'
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (10-09-2013)
@IsTest
public class H_C_UT_SystemUtils
{
	//
	//Unit tests for 'H_C_ApexJobUtils' class
	//
	@IsTest(SeeAllData = true)
    private static void testApexJobUtils_getJobStatusMessage()
    {
    	//wrong parameters
    	System.assertEquals(H_C_ApexJobUtils.JOB_NOT_FOUND_MESSAGE,
    		H_C_ApexJobUtils.getJobStatusMessage(null));
    	
    	//correct parameters
		H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder('Id', 'AsyncApexJob');
        queryBuilder.condition = 'TotalJobItems != 0';
        queryBuilder.limitOfResultSet = 1;
        AsyncApexJob realApexJob = (AsyncApexJob)H_C_SoqlUtils.performSingleResultQuery(queryBuilder);
        if (realApexJob != null)
        {
        	System.assertNotEquals(null, H_C_ApexJobUtils.getJobStatusMessage(realApexJob.Id));
        }
    }
    
    @IsTest
    private static void testApexJobUtils_startJob()
    {
    	//WRONG PARAMETERS:
    	//TEST #1
    	H_C_ApexJobUtils.StartResults results = H_C_ApexJobUtils.startJob(null, -1);
    	System.assertEquals(false, results.isStartSuccessful);
    	
    	//TEST #2
    	results = H_C_ApexJobUtils.startJob(new H_C_ApexJobUtils.PreStartInfo());
    	System.assertEquals(false, results.isStartSuccessful);
    	
    	//TEST #3
    	results = H_C_ApexJobUtils.startJob(new H_C_ApexJobUtils.PreStartInfo(null, -1));
    	System.assertEquals(false, results.isStartSuccessful);
    	
    	//CORRECT PARAMETERS:
    	//TEST #1
    	results = H_C_ApexJobUtils.startJob(
    		new H_C_BgAccountHierarchiesManager('Select Id From Account limit 10'),
    		H_C_ApexJobUtils.JOB_UPDATE_ACCOUNT_HIERARCHY);
    	System.assertEquals(true, results.isStartSuccessful);
    	
    	//TEST #2
    	H_C_ApexJobUtils.PreStartInfo preStartJobInfo = new H_C_ApexJobUtils.PreStartInfo();
    	preStartJobInfo.jobManager =
    		new H_C_BgAccountHierarchiesManager('Select Id From Account limit 10');
    	preStartJobInfo.jobCode = H_C_ApexJobUtils.JOB_UPDATE_ACCOUNT_HIERARCHY;
    	
    	results = H_C_ApexJobUtils.startJob(preStartJobInfo);
    	System.assertEquals(true, results.isStartSuccessful);
    }
    //
    
    
    
    
    
    //
    //Unit tests for 'H_C_ApexTypeUtils' class
    //
    @IsTest
    private static void testApexTypeUtils_getType()
    {
        System.assertEquals(null, H_C_ApexTypeUtils.getType(null));
        System.assertEquals(null, H_C_ApexTypeUtils.getType('Unknown_class_name'));
        System.assertNotEquals(null, H_C_ApexTypeUtils.getType('User'));
    }
    
    @IsTest
    private static void testApexTypeUtils_createEmptyListByTypeName()
    {
        //WRONG PARAMTERS
        System.assertEquals(null, H_C_ApexTypeUtils.createEmptyListByTypeName(null));
        System.assertEquals(null, H_C_ApexTypeUtils.createEmptyListByTypeName('Unknown_class_name'));
        
        //GOOD PARAMETERS
        //try to create array of 'User' objects 
        User[] users = (User[])H_C_ApexTypeUtils.createEmptyListByTypeName('User');
        System.assertEquals(0, users.size());
        
        //try to add new User
        users.add(new User());
        System.assertEquals(1, users.size());
        
        //try to create array of 'User' objects and add a new Account
        //(wrong type is used to show that array contains objects of a concrete type)
        List<Object> objectArray;
        try
        {
            objectArray = H_C_ApexTypeUtils.createEmptyListByTypeName('User');
            objectArray.add(new Account());
            System.assert(false);
        }
        catch (System.TypeException e)
        {
            System.assert(true);
            System.assertEquals(0, objectArray.size());
        }
    }
    //
    
    
    
    
    
    //
    //
	//Unit tests for 'H_C_ComparisonUtils' class
	//
	@IsTest
	private static void testComparisonUtils_compareDateTimeValues()
	{
		//get current DateTime
		DateTime currentDT = DateTime.now();
		
		//we do not use specific options here, but update global default options
		H_C_SortingUtils.DEFAULT_SORTING_OPTIONS.blankValuesAtEnd = true;
		System.assertEquals(0, H_C_ComparisonUtils.compareDateTimeValues(null, null));
		System.assertEquals(0, H_C_ComparisonUtils.compareDateTimeValues(currentDT, currentDT));
		System.assertEquals(1, H_C_ComparisonUtils.compareDateTimeValues(currentDT.addMinutes(1), currentDT));
		System.assertEquals(-1, H_C_ComparisonUtils.compareDateTimeValues(currentDT.addMinutes(-1), currentDT));
		System.assertEquals(-1, H_C_ComparisonUtils.compareDateTimeValues(currentDT, null));
		System.assertEquals(1, H_C_ComparisonUtils.compareDateTimeValues(null, currentDT));
		
		//we use specific options here
		H_C_SortingUtils.SortingOptions options = new H_C_SortingUtils.SortingOptions();
		options.blankValuesAtEnd = false;
		//nothing should be changed for next 4 assertions
		System.assertEquals(0, H_C_ComparisonUtils.compareDateTimeValues(null, null, options));
		System.assertEquals(0, H_C_ComparisonUtils.compareDateTimeValues(currentDT, currentDT, options));
		System.assertEquals(1, H_C_ComparisonUtils.compareDateTimeValues(currentDT.addMinutes(1), currentDT, options));
		System.assertEquals(-1, H_C_ComparisonUtils.compareDateTimeValues(currentDT.addMinutes(-1), currentDT, options));
		//null values should be placed at the start now
		System.assertEquals(1, H_C_ComparisonUtils.compareDateTimeValues(currentDT, null, options));
		System.assertEquals(-1, H_C_ComparisonUtils.compareDateTimeValues(null, currentDT, options));
	}
	
	@IsTest
	private static void testComparisonUtils_compareStringValues()
	{
		//get current DateTime
		DateTime currentDT = DateTime.now();
		
		//we do not use specific options here, but update global default options
		H_C_SortingUtils.DEFAULT_SORTING_OPTIONS.blankValuesAtEnd = true;
		H_C_SortingUtils.DEFAULT_SORTING_OPTIONS.ignoreStringCase = true;
		System.assertEquals(0, H_C_ComparisonUtils.compareStringValues(null, null));
		System.assertEquals(0, H_C_ComparisonUtils.compareStringValues('', ''));
		System.assertEquals(0, H_C_ComparisonUtils.compareStringValues('Gennadiy', 'Gennadiy'));
		System.assertEquals(-1, H_C_ComparisonUtils.compareStringValues('A', null));
		System.assertEquals(1, H_C_ComparisonUtils.compareStringValues(null, 'A'));
		System.assert(H_C_ComparisonUtils.compareStringValues('A', 'B') < 0);
		System.assert(H_C_ComparisonUtils.compareStringValues('B', 'A') > 0);
		System.assert(H_C_ComparisonUtils.compareStringValues('a', 'B') < 0);
		System.assert(H_C_ComparisonUtils.compareStringValues('B', 'a') > 0);
		
		//we use specific options here
		H_C_SortingUtils.SortingOptions options = new H_C_SortingUtils.SortingOptions();
		options.blankValuesAtEnd = false;
		options.ignoreStringCase = false;
		//nothing should be changed for next 3 assertions
		System.assertEquals(0, H_C_ComparisonUtils.compareStringValues(null, null, options));
		System.assertEquals(0, H_C_ComparisonUtils.compareStringValues('', '', options));
		System.assertEquals(0, H_C_ComparisonUtils.compareStringValues('Gennadiy', 'Gennadiy', options));
		//null values should be placed at the start now
		System.assertEquals(1, H_C_ComparisonUtils.compareStringValues('A', null, options));
		System.assertEquals(-1, H_C_ComparisonUtils.compareStringValues(null, 'A', options));
		//nothing should be changed for next 2 assertions
		System.assert(H_C_ComparisonUtils.compareStringValues('A', 'B', options) < 0);
		System.assert(H_C_ComparisonUtils.compareStringValues('B', 'A', options) > 0);
		//next 2 assertions give another result, because case is considered now
		System.assert(H_C_ComparisonUtils.compareStringValues('a', 'B', options) > 0);
		System.assert(H_C_ComparisonUtils.compareStringValues('B', 'a', options) < 0);
	}
	
	@IsTest
	private static void testComparisonUtils_compareIntegerValues()
	{
		//we do not use specific options here, but update global default options
		H_C_SortingUtils.DEFAULT_SORTING_OPTIONS.blankValuesAtEnd = true;
		System.assertEquals(0, H_C_ComparisonUtils.compareIntegerValues(null, null));
		System.assertEquals(0, H_C_ComparisonUtils.compareIntegerValues(5, 5));
		System.assertEquals(4, H_C_ComparisonUtils.compareIntegerValues(5, 1));
		System.assertEquals(-4, H_C_ComparisonUtils.compareIntegerValues(1, 5));
		System.assertEquals(-1, H_C_ComparisonUtils.compareIntegerValues(5, null));
		System.assertEquals(1, H_C_ComparisonUtils.compareIntegerValues(null, 5));
		
		//we use specific options here
		H_C_SortingUtils.SortingOptions options = new H_C_SortingUtils.SortingOptions();
		options.blankValuesAtEnd = false;
		//nothing should be changed for next 4 assertions
		System.assertEquals(0, H_C_ComparisonUtils.compareIntegerValues(null, null, options));
		System.assertEquals(0, H_C_ComparisonUtils.compareIntegerValues(5, 5, options));
		System.assertEquals(4, H_C_ComparisonUtils.compareIntegerValues(5, 1, options));
		System.assertEquals(-4, H_C_ComparisonUtils.compareIntegerValues(1, 5, options));
		//null values should be placed at the start now
		System.assertEquals(1, H_C_ComparisonUtils.compareIntegerValues(5, null, options));
		System.assertEquals(-1, H_C_ComparisonUtils.compareIntegerValues(null, 5, options));
	}
	
	@IsTest
	private static void testComparisonUtils_compareBooleanValues()
	{
		//we do not use specific options here, but update global default options
		H_C_SortingUtils.DEFAULT_SORTING_OPTIONS.blankValuesAtEnd = true;
		System.assertEquals(0, H_C_ComparisonUtils.compareBooleanValues(null, null));
		System.assertEquals(0, H_C_ComparisonUtils.compareBooleanValues(true, true));
		System.assertEquals(0, H_C_ComparisonUtils.compareBooleanValues(false, false));
		System.assertEquals(1, H_C_ComparisonUtils.compareBooleanValues(true, false));
		System.assertEquals(-1, H_C_ComparisonUtils.compareBooleanValues(false, true));
		System.assertEquals(-1, H_C_ComparisonUtils.compareBooleanValues(true, null));
		System.assertEquals(-1, H_C_ComparisonUtils.compareBooleanValues(false, null));
		System.assertEquals(1, H_C_ComparisonUtils.compareBooleanValues(null, true));
		System.assertEquals(1, H_C_ComparisonUtils.compareBooleanValues(null, false));
		
		//we use specific options here
		H_C_SortingUtils.SortingOptions options = new H_C_SortingUtils.SortingOptions();
		options.blankValuesAtEnd = false;
		//nothing should be changed for next 5 assertions
		System.assertEquals(0, H_C_ComparisonUtils.compareBooleanValues(null, null, options));
		System.assertEquals(0, H_C_ComparisonUtils.compareBooleanValues(true, true, options));
		System.assertEquals(0, H_C_ComparisonUtils.compareBooleanValues(false, false, options));
		System.assertEquals(1, H_C_ComparisonUtils.compareBooleanValues(true, false, options));
		System.assertEquals(-1, H_C_ComparisonUtils.compareBooleanValues(false, true, options));
		//null values should be placed at the start now
		System.assertEquals(1, H_C_ComparisonUtils.compareBooleanValues(true, null, options));
		System.assertEquals(1, H_C_ComparisonUtils.compareBooleanValues(false, null, options));
		System.assertEquals(-1, H_C_ComparisonUtils.compareBooleanValues(null, true, options));
		System.assertEquals(-1, H_C_ComparisonUtils.compareBooleanValues(null, false, options));
	}
	
	@IsTest
	private static void testComparisonUtils_compareObjects1()
	{
		H_C_SortingUtils.SortingOptions options = new H_C_SortingUtils.SortingOptions();
		options.ignoreStringCase = true;
		options.blankValuesAtEnd = true;
		
		//compare Null values
		System.assertEquals(0, H_C_ComparisonUtils.compareObjects(null, null, options));
		//compare DateTime values
		System.assertEquals(-1, H_C_ComparisonUtils.compareObjects(DateTime.now(), DateTime.now().addHours(5), options));
		//compare String values
		System.assertEquals(-1, H_C_ComparisonUtils.compareObjects('A', 'b', options));
		//compare Integer values
		System.assertEquals(-4, H_C_ComparisonUtils.compareObjects(1, 5, options));
		//compare Integer and Null values
		System.assertEquals(-1, H_C_ComparisonUtils.compareObjects(1, null, options));
		//compare Boolean values
		System.assertEquals(-1, H_C_ComparisonUtils.compareObjects(false, true, options));
		
		//compare values which are unknown by the method
		try
		{
			H_C_ComparisonUtils.compareObjects(new H_C_ComparisonUtils(), new H_C_ComparisonUtils(), options);
			System.assert(false);
		}
		catch (H_C_Exception error)
		{
			System.debug('Correct exception: ' + error);
			System.assert(true);
		}
	}
	
	@IsTest(SeeAllData = true)
	private static void testComparisonUtils_compareObjects2()
	{
		//#IMPORTANT:
		//we must use 'SeeAllData = true' property here, because Unit tests can't select
		//list of 'OpenActivity' objects without it
		
		//create test data
		Account account = H_C_UnitTestUtils.createAccount('Account1');
		Task task1 = H_C_UnitTestUtils.createTask('Task', Date.today(), account.Id);
		Task task2 = H_C_UnitTestUtils.createTask('Task', Date.today().addDays(5), account.Id);
		Task task3 = H_C_UnitTestUtils.createTask('aTask', Date.today(), account.Id);
		
		//reread test data and prepare wrappers which implements 'H_C_IDynamicObjectWrapper' interface
		OpenActivity[] openActivities = H_C_ActivityDAO.getOpenActivitiesByAccountId(account.Id, false);
		System.assertEquals(3, openActivities.size());
		Map<Id, OpenActivity> mapOfActivities = new Map<Id, OpenActivity>(openActivities);
		H_C_OpenActivityWrapper wrapper1 = new H_C_OpenActivityWrapper(mapOfActivities.get(task1.Id), null);
		H_C_OpenActivityWrapper wrapper2 = new H_C_OpenActivityWrapper(mapOfActivities.get(task2.Id), null);
		H_C_OpenActivityWrapper wrapper3 = new H_C_OpenActivityWrapper(mapOfActivities.get(task3.Id), null);
		
		
		//TEST #1: compare wrappers without sorting parameters
		System.assertEquals(0, H_C_ComparisonUtils.compareObjects(wrapper1, wrapper2, null));
		System.assertEquals(0, H_C_ComparisonUtils.compareObjects(wrapper1, wrapper2, new H_C_SortingUtils.SortingParameter[0]));
		
		//TEST #2: this block tests work with Null values
		List<H_C_SortingUtils.SortingParameter> parameters = new H_C_SortingUtils.SortingParameter[0];
		//create a new sorting parameter
		H_C_SortingUtils.SortingParameter parameter1 = new H_C_SortingUtils.SortingParameter('Subject');
		parameters.add(parameter1);
		//set default options
		H_C_SortingUtils.DEFAULT_SORTING_OPTIONS.blankValuesAtEnd = false;
		System.assertEquals(1, H_C_ComparisonUtils.compareObjects(wrapper1, null, parameters));
		System.assertEquals(-1, H_C_ComparisonUtils.compareObjects(null, wrapper2, parameters));
		System.assertEquals(0, H_C_ComparisonUtils.compareObjects(null, null, parameters));
		//set default options
		H_C_SortingUtils.DEFAULT_SORTING_OPTIONS.blankValuesAtEnd = true;
		System.assertEquals(-1, H_C_ComparisonUtils.compareObjects(wrapper1, null, parameters));
		System.assertEquals(1, H_C_ComparisonUtils.compareObjects(null, wrapper2, parameters));
		System.assertEquals(0, H_C_ComparisonUtils.compareObjects(null, null, parameters));
		
		//TEST #3: compare wrappers by their subjects in ascending order: t3 -> t1,t2
		System.assertEquals(0, H_C_ComparisonUtils.compareObjects(wrapper1, wrapper2, parameters));
		System.assert(H_C_ComparisonUtils.compareObjects(wrapper1, wrapper3, parameters) > 0);
		System.assert(H_C_ComparisonUtils.compareObjects(wrapper2, wrapper3, parameters) > 0);
		//reverse sorting: t1,t2 -> t3
		parameter1.sortingOrder = H_C_SortingUtils.SortingOrder.Descending;
		System.assert(H_C_ComparisonUtils.compareObjects(wrapper1, wrapper3, parameters) < 0);
		System.assert(H_C_ComparisonUtils.compareObjects(wrapper2, wrapper3, parameters) < 0);
		
		//TEST #4: compare wrappers by their activity dates in ascending order: t1,t3 -> t2
		//create a new sorting parameter
		H_C_SortingUtils.SortingParameter parameter2 = new H_C_SortingUtils.SortingParameter('StartDateTime');
		parameters.clear();
		parameters.add(parameter2);
		System.assertEquals(0, H_C_ComparisonUtils.compareObjects(wrapper1, wrapper3, parameters));
		System.assertEquals(-1, H_C_ComparisonUtils.compareObjects(wrapper1, wrapper2, parameters));
		System.assertEquals(1, H_C_ComparisonUtils.compareObjects(wrapper2, wrapper3, parameters));
		
		//TEST #5: compare wrappers by 2 parameters: subject in ascending order and
		//activity date in descending order: t3 -> t2 -> t1
		parameters.clear();
		parameter1.sortingOrder = H_C_SortingUtils.SortingOrder.Ascending;
		parameter2.sortingOrder = H_C_SortingUtils.SortingOrder.Descending;
		parameters.add(parameter1);
		parameters.add(parameter2);
		System.assert(H_C_ComparisonUtils.compareObjects(wrapper1, wrapper2, parameters) > 0);
		System.assert(H_C_ComparisonUtils.compareObjects(wrapper1, wrapper3, parameters) > 0);
		System.assert(H_C_ComparisonUtils.compareObjects(wrapper2, wrapper3, parameters) > 0);
		
		//TEST #6: compare wrappers by 2 parameters: subject in ascending order and
		//activity date in ascending order: t3 -> t1 -> t2
		parameter2.sortingOrder = H_C_SortingUtils.SortingOrder.Ascending;
		System.assert(H_C_ComparisonUtils.compareObjects(wrapper1, wrapper2, parameters) < 0);
		System.assert(H_C_ComparisonUtils.compareObjects(wrapper1, wrapper3, parameters) > 0);
		System.assert(H_C_ComparisonUtils.compareObjects(wrapper2, wrapper3, parameters) > 0);
	}
	
	@IsTest(SeeAllData = true)
	private static void testComparisonUtils_getMinAndMaxElements()
	{
		//#IMPORTANT:
		//we must use 'SeeAllData = true' property here, because Unit tests can't select
		//list of 'OpenActivity' objects without it
		
		//WRONG PARAMETERS
		System.assertEquals(null, H_C_ComparisonUtils.getMinimalElement(null));
		System.assertEquals(null, H_C_ComparisonUtils.getMinimalElement(new Comparable[0]));
		System.assertEquals(null, H_C_ComparisonUtils.getMaximalElement(null));
		System.assertEquals(null, H_C_ComparisonUtils.getMaximalElement(new Comparable[0]));
		
		//CORRECT PARAMETERS
		//create test data
		Account account = H_C_UnitTestUtils.createAccount('Account1');
		Task task1 = H_C_UnitTestUtils.createTask('Task', Date.today(), account.Id);
		Task task2 = H_C_UnitTestUtils.createTask('Task', Date.today().addDays(5), account.Id);
		Task task3 = H_C_UnitTestUtils.createTask('aTask', Date.today(), account.Id);
		
		//reread test data and prepare wrappers which implements 'H_C_IDynamicObjectWrapper' interface
		OpenActivity[] openActivities = H_C_ActivityDAO.getOpenActivitiesByAccountId(account.Id, false);
		System.assertEquals(3, openActivities.size());
		Map<Id, OpenActivity> mapOfActivities = new Map<Id, OpenActivity>(openActivities);
		H_C_OpenActivityWrapper wrapper1 = new H_C_OpenActivityWrapper(mapOfActivities.get(task1.Id), null);
		H_C_OpenActivityWrapper wrapper2 = new H_C_OpenActivityWrapper(mapOfActivities.get(task2.Id), null);
		H_C_OpenActivityWrapper wrapper3 = new H_C_OpenActivityWrapper(mapOfActivities.get(task3.Id), null);
		
		H_C_OpenActivityWrapper[] wrappers = new H_C_OpenActivityWrapper[] {wrapper1, wrapper2, wrapper3};
		//get minimal element
		H_C_OpenActivityWrapper minWrapper =
			(H_C_OpenActivityWrapper)H_C_ComparisonUtils.getMinimalElement(wrappers);
		System.assertEquals(wrapper3, minWrapper);
		//get maximal element
		H_C_OpenActivityWrapper maxWrapper =
			(H_C_OpenActivityWrapper)H_C_ComparisonUtils.getMaximalElement(wrappers);
		System.assertEquals(wrapper2, maxWrapper);
	}
	//
    
    
    
    
    
    //
    //Unit tests for 'H_C_ScheduledJobUtils' class
    //
    @IsTest
    private static void testScheduledJobUtils_startJob()
    {
    	H_C_ScheduledJobUtils.StartResults results = H_C_ScheduledJobUtils.startJob(null);
    	System.assertEquals(false, results.isStartSuccessful);
    	
    	results = H_C_ScheduledJobUtils.startJob(H_C_ScheduledJobUtils.JOB_SCHEDULED_ACCOUNTS_MANAGER);
    	System.assertEquals(true, results.isStartSuccessful);
    }
    //
    
    
    
    
    
    //
	//Unit tests for 'H_C_SFLimits' class
	//
	@IsTest
	private static void testSFLimits_getNumberOfAllowedDMLRows()
	{
		//disable all triggers to test the logic separately from them
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
		
		Integer numberOfAllowedDMLRows = H_C_SFLimits.getNumberOfAllowedDMLRows();
		Account account1 = H_C_UnitTestUtils.constructAccount('Account1');
		insert account1;
		System.assertEquals(numberOfAllowedDMLRows - 1, H_C_SFLimits.getNumberOfAllowedDMLRows()); 
	}
	
	@IsTest
	private static void testSFLimits_getNumberOfAllowedDMLStatements()
	{
		//disable all triggers to test the logic separately from them
        H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
		
		Integer numberOfAllowedDMLStatements = H_C_SFLimits.getNumberOfAllowedDMLStatements();
		Account account1 = H_C_UnitTestUtils.constructAccount('Account1');
		insert account1;
		System.assertEquals(numberOfAllowedDMLStatements - 1, H_C_SFLimits.getNumberOfAllowedDMLStatements()); 
	}
	//
	
	
	
	
	
	//
	//Unit tests for 'H_C_sObjectUtils' class
	//
	@IsTest
    private static void testSObjectUtils_getFieldValue()
    {
    	Account account = H_C_UnitTestUtils.createAccount();
    	
    	//wrong parameters
    	System.assertEquals(null, H_C_sObjectUtils.getFieldValue(null, null));
    	System.assertEquals(null, H_C_sObjectUtils.getFieldValue(null, 'Id'));
    	System.assertEquals(null, H_C_sObjectUtils.getFieldValue(account, 'Unknown_Field'));
    	
    	//correct parameters
    	System.assertEquals(account.Id, H_C_sObjectUtils.getFieldValue(account, 'Id'));
    }
    
    @IsTest
    private static void testSObjectUtils_getComplexFieldValue()
    {
    	//disable all triggers to test the logic separately from them
		H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
    	
    	//create test data
    	Account parentAccount = H_C_UnitTestUtils.createAccount('Parent Account 1');
    	Account childAccount = H_C_UnitTestUtils.createAccount('Child Account 1', parentAccount.Id);
    	
    	//reread childAccount to include necessary fields
    	childAccount = [SELECT Id, Name, ParentId, Parent.Name FROM Account WHERE Id =: childAccount.Id];
    	
    	//wrong parameters
    	System.assertEquals(null, H_C_sObjectUtils.getComplexFieldValue(null, null));
    	System.assertEquals(null, H_C_sObjectUtils.getComplexFieldValue(null, 'Id'));
    	System.assertEquals(null, H_C_sObjectUtils.getComplexFieldValue(childAccount, 'Unknown_Field'));
    	System.assertEquals(null, H_C_sObjectUtils.getComplexFieldValue(childAccount, 'UnknownParent.UnknownField'));
    	System.assertEquals(null, H_C_sObjectUtils.getComplexFieldValue(childAccount, 'Parent.UnknownParent.UnknownField'));
    	
    	//correct parameters
    	System.assertEquals(childAccount.Id, H_C_sObjectUtils.getComplexFieldValue(childAccount, 'Id'));
    	System.assertEquals(parentAccount.Name, H_C_sObjectUtils.getComplexFieldValue(childAccount, 'Parent.Name'));
    }
    
    @IsTest
    private static void testSObjectUtils_getParentObject()
    {
    	//disable all triggers to test the logic separately from them
		H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
    	
    	//create test data
    	Account parentAccount = H_C_UnitTestUtils.createAccount('Parent Account 1');
    	Account childAccount = H_C_UnitTestUtils.createAccount('Child Account 1', parentAccount.Id);
    	
    	//reread childAccount to include necessary fields
    	childAccount = [SELECT Id, Name, ParentId, Parent.Name FROM Account WHERE Id =: childAccount.Id];
    	
    	//wrong parameters
    	System.assertEquals(null, H_C_sObjectUtils.getParentObject(null, null));
    	System.assertEquals(null, H_C_sObjectUtils.getParentObject(null, 'UnknownParentReference'));
    	System.assertEquals(null, H_C_sObjectUtils.getParentObject(childAccount, 'UnknownParentReference'));
    	
    	//correct parameters
    	Account extractedParent = (Account)H_C_sObjectUtils.getParentObject(childAccount, 'Parent');
    	System.assertEquals(parentAccount.Id, extractedParent.Id);
    	System.assertEquals(parentAccount.Name, extractedParent.Name);
    }
    
    @IsTest
    private static void testSObjectUtils_getChildObjects()
    {
    	Account account = H_C_UnitTestUtils.createAccount();
    	
    	//wrong parameters
    	System.assertEquals(null, H_C_sObjectUtils.getChildObjects(account, null));
    	System.assertEquals(null, H_C_sObjectUtils.getChildObjects(account, 'UnknownRelationship'));
    	
    	//correct parameters
    	//TEST #1: child objects do not exist
    	System.assertEquals(null, H_C_sObjectUtils.getChildObjects(account, 'Opportunities'));
    	
    	//TEST #2: child object exists
    	Opportunity opportunity = H_C_UnitTestUtils.createOpportunity('Test Opportunity', account.Id);
    	account = [SELECT Id, (SELECT Name FROM Opportunities) FROM Account WHERE Id =: account.Id limit 1];
    	sObject[] childObjects = H_C_sObjectUtils.getChildObjects(account, 'Opportunities');
    	System.assertEquals(1, childObjects.size());
    	System.assertEquals(opportunity.Id, childObjects[0].Id);
    }
    //
    
    
    
    
    
    //
    //Unit tests for 'H_C_SoqlUtils' class
    //
    @IsTest
	private static void testSoqlUtils_joinStringsForINSection()
	{
		System.assertEquals(null, H_C_SoqlUtils.joinStringsForINSection(null));
		System.assertEquals(null, H_C_SoqlUtils.joinStringsForINSection(new String[]{null, ''}));
		
		String[] input = new String[]{'firstId', 'secondId'};
		String joinedStrings = H_C_SoqlUtils.joinStringsForINSection(input);
		System.assert('\'firstId\',\'secondId\'' == joinedStrings
			|| '\'secondId\',\'firstId\'' == joinedStrings);
		
		System.assertEquals('\'firstId\'', H_C_SoqlUtils.joinStringsForINSection(new String[]{'firstId'}));
		
	}
	
	@IsTest
	private static void testSoqlUtils_formatDateTime()
	{
		DateTime dt = DateTime.newInstanceGmt(2012, 4, 15, 14, 28, 55);
		System.assertEquals('2012-04-15T14:28:55Z', H_C_SoqlUtils.formatDateTime(dt));
		
		dt = null;
		System.assertEquals(null, H_C_SoqlUtils.formatDateTime(dt));
	}
	
	@IsTest
	private static void testSoqlUtils_formatDateTime2()
	{
		Date dt = null;
		System.assertEquals(null, H_C_SoqlUtils.formatDateTime(dt));
		
		dt = Date.newInstance(2012, 4, 15);
		System.assertEquals('2012-04-15T00:00:00Z', H_C_SoqlUtils.formatDateTime(dt));
	}
	
	@IsTest
	private static void testSoqlUtils_formatDate()
	{
		Date date1 = Date.newInstance(2012, 4, 15);
		DateTime datetime1 = DateTime.newInstance(2012, 4, 15, 14, 28, 55);
		
		System.assertEquals('2012-04-15', H_C_SoqlUtils.formatDate(date1));
		System.assertEquals('2012-04-15', H_C_SoqlUtils.formatDate(datetime1));
		date1 = null;
		System.assertEquals(null, H_C_SoqlUtils.formatDate(date1));
		datetime1 = null;
		System.assertEquals(null, H_C_SoqlUtils.formatDate(datetime1));
	}
	
	@IsTest
	private static void testSoqlUtils_joinConditions()
	{
		String result = H_C_SoqlUtils.joinConditions(new String[]{'','',''}, H_C_SoqlUtils.LogicOperator.AND_Operator);
		System.assertEquals(null, result);
		
		result = H_C_SoqlUtils.joinConditions(null, H_C_SoqlUtils.LogicOperator.AND_Operator);
		System.assertEquals(null, result);
		
		result = H_C_SoqlUtils.joinConditions(
			new String[]{null,'condition1','condition2'}, H_C_SoqlUtils.LogicOperator.AND_Operator);
		System.assertEquals('(condition1) AND (condition2)', result);
		
		result = H_C_SoqlUtils.joinConditions(
			new String[]{null,'','condition'}, H_C_SoqlUtils.LogicOperator.AND_Operator);
		System.assertEquals('(condition)', result);
		
		result = H_C_SoqlUtils.joinConditions(
			new String[]{'condition1','condition2', 'condition3'}, H_C_SoqlUtils.LogicOperator.OR_Operator);
		System.assertEquals('(condition1) OR (condition2) OR (condition3)', result);
		
		result = H_C_SoqlUtils.joinConditions(
			new String[]{'condition1','', 'condition3'}, H_C_SoqlUtils.LogicOperator.AND_Operator);
		System.assertEquals('(condition1) AND (condition3)', result);
	}
	
	@IsTest
	private static void testSoqlUtils_escapeSpecialCharsForSimpleCondition()
	{
		//wrong parameters
		System.assertEquals(null, H_C_SoqlUtils.escapeSpecialCharsForSimpleCondition(null));
		
		//good parameters
		String sourceString = 'Part1\'Part2';
		System.assertEquals(String.escapeSingleQuotes(sourceString),
			H_C_SoqlUtils.escapeSpecialCharsForSimpleCondition(sourceString));
	}
	
	@IsTest
	private static void testSoqlUtils_escapeSpecialCharsForLikeOperator()
	{
		//wrong parameters
		System.assertEquals(null, H_C_SoqlUtils.escapeSpecialCharsForLikeOperator(null));
		
		//good parameters
		//create source string
		String sourceString = 'Part';
		for (String specialChar : H_C_SoqlUtils.SPECIAL_CHARS_FOR_LIKE_OPERATOR)
		{
			sourceString += specialChar + 'Part';
		}
		
		//perform operation
		String escapedString = H_C_SoqlUtils.escapeSpecialCharsForLikeOperator(sourceString);
		
		//remove escaped subsequences
		for (String specialChar : H_C_SoqlUtils.SPECIAL_CHARS_FOR_LIKE_OPERATOR)
		{
			escapedString = escapedString.replace('\\' + specialChar, '');
		}
		//check that there are no free special chars in escaped string
		for (String specialChar : H_C_SoqlUtils.SPECIAL_CHARS_FOR_LIKE_OPERATOR)
		{
			System.assert(!escapedString.contains(specialChar));
		}
	}
	
	@IsTest
	private static void testSoqlUtils_tryPerformDmlOperation_SingleObject()
	{
		//WRONG DATA
		sObject testNullObject = null;
		System.assertEquals(false, H_C_SoqlUtils.tryPerformDmlOperation(null, testNullObject));
		
		//GOOD DATA
		//create test data
		Account testAccount = H_C_UnitTestUtils.createAccount('Test Account');
		
		//clone Account without Id
		Account newTestAccount = testAccount.clone(false);
		newTestAccount.Name = 'Test Account 2';
		
		//INSERT data
		System.assert(newTestAccount.Id == null);
		System.assert(H_C_SoqlUtils.tryPerformDmlOperation(H_C_SoqlUtils.DmlOperation.Inserting, newTestAccount));
		System.assert(newTestAccount.Id != null);
		
		//UPDATE object
		newTestAccount.Name = 'Test Account 2 - new';
		System.assert(H_C_SoqlUtils.tryPerformDmlOperation(H_C_SoqlUtils.DmlOperation.Updating, newTestAccount));
		
		//UPSERT object
		newTestAccount.Name = 'Test Account 2 - new2';
		System.assert(H_C_SoqlUtils.tryPerformDmlOperation(H_C_SoqlUtils.DmlOperation.Upserting, newTestAccount));
		
		//DELETE object
		System.assert(H_C_SoqlUtils.tryPerformDmlOperation(H_C_SoqlUtils.DmlOperation.Deleting, newTestAccount));
		
		//UNDELETE object
		System.assert(H_C_SoqlUtils.tryPerformDmlOperation(H_C_SoqlUtils.DmlOperation.Undeleting, newTestAccount));
	}
	
	@IsTest
	private static void testSoqlUtils_tryPerformDmlOperation_ObjectsList()
	{
		//WRONG DATA
		sObject[] testNullObjects = null;
		System.assertEquals(false, H_C_SoqlUtils.tryPerformDmlOperation(null, testNullObjects));
		
		//GOOD DATA
		//create test data
		Account testAccount = H_C_UnitTestUtils.createAccount('Test Account');
		
		//clone Account without Id
		Account newTestAccount = testAccount.clone(false);
		newTestAccount.Name = 'Test Account 2';
		
		//INSERT data
		System.assert(newTestAccount.Id == null);
		System.assert(H_C_SoqlUtils.tryPerformDmlOperation(H_C_SoqlUtils.DmlOperation.Inserting,
			new Account[] {newTestAccount}));
		System.assert(newTestAccount.Id != null);
		
		//UPDATE object
		newTestAccount.Name = 'Test Account 2 - new';
		System.assert(H_C_SoqlUtils.tryPerformDmlOperation(H_C_SoqlUtils.DmlOperation.Updating,
			new Account[] {newTestAccount}));
		
		//UPSERT object
		newTestAccount.Name = 'Test Account 2 - new2';
		System.assert(H_C_SoqlUtils.tryPerformDmlOperation(H_C_SoqlUtils.DmlOperation.Upserting,
			new Account[] {newTestAccount}));
		
		//DELETE object
		System.assert(H_C_SoqlUtils.tryPerformDmlOperation(H_C_SoqlUtils.DmlOperation.Deleting,
			new Account[] {newTestAccount}));
		
		//UNDELETE object
		System.assert(H_C_SoqlUtils.tryPerformDmlOperation(H_C_SoqlUtils.DmlOperation.Undeleting,
			new Account[] {newTestAccount}));
		
		//INSERT WRONG ACCOUNT (Name is empty)
		System.assertEquals(false, H_C_SoqlUtils.tryPerformDmlOperation(H_C_SoqlUtils.DmlOperation.Inserting,
			new Account[] {new Account()}));
	}
	
	@IsTest
	private static void testSoqlUtils_performDmlOperation_ObjectsList()
	{
		//WRONG DATA
		H_C_OperationResults operationResults = H_C_SoqlUtils.performDmlOperation(null, null, null); 
		System.assertEquals(false, operationResults.isOperationSuccessful);
		
		//GOOD DATA
		//create test data
		Account testAccount1 = H_C_UnitTestUtils.constructAccount('Test Account1');
		Account testAccount2 = new Account();
		Account[] testAccounts = new Account[] {testAccount1, testAccount2};
		
		//TEST #1.1: INSERT data (a list can't be inserted partially)
		Database.DMLOptions dmlOptions = new Database.DMLOptions();
		dmlOptions.optAllOrNone = true;
		operationResults = H_C_SoqlUtils.performDmlOperation(
			H_C_SoqlUtils.DmlOperation.Inserting, testAccounts, dmlOptions);
		System.assertEquals(false, operationResults.isOperationSuccessful);
		System.assert(operationResults.exceptions.size() > 0);
		
		//TEST #1.2: INSERT data (a list can be inserted partially)
		dmlOptions = new Database.DMLOptions();
		dmlOptions.optAllOrNone = false;
		operationResults = H_C_SoqlUtils.performDmlOperation(
			H_C_SoqlUtils.DmlOperation.Inserting, testAccounts, dmlOptions);
		System.assertEquals(true, operationResults.isOperationSuccessful);
		Database.SaveResult[] insertResults = (Database.SaveResult[])operationResults.results;
		System.assertEquals(2, insertResults.size());
		//check that the 1st account was inserted successfully
		System.assertEquals(true, insertResults[0].isSuccess());
		//check that the 2nd account was not inserted
		System.assertEquals(false, insertResults[1].isSuccess());
		
		
		//TEST #2: UPDATE data (a list can be updated partially)
		testAccount1.Name += ' - new 2';
		operationResults = H_C_SoqlUtils.performDmlOperation(
			H_C_SoqlUtils.DmlOperation.Updating, testAccounts, dmlOptions);
		System.assertEquals(true, operationResults.isOperationSuccessful);
		Database.SaveResult[] updateResults = (Database.SaveResult[])operationResults.results;
		System.assertEquals(2, updateResults.size());
		//check that the 1st account was updated successfully
		System.assertEquals(true, updateResults[0].isSuccess());
		//check that the 2nd account was not updated
		System.assertEquals(false, updateResults[1].isSuccess());
		
		
		//TEST #3.1: UPSERT data (upsert operation works in a special way: DML options
		//are not considered)
		testAccount1.Name += ' - new 3.1';
		operationResults = H_C_SoqlUtils.performDmlOperation(
			H_C_SoqlUtils.DmlOperation.Upserting, testAccounts, dmlOptions);
		System.assertEquals(false, operationResults.isOperationSuccessful);
		
		//TEST #3.2: UPSERT data (upsert operation works in a special way: DML options
		//are not considered)
		testAccount1.Name += ' - new 3.2';
		testAccount2.Name += ' - new 3.2';
		operationResults = H_C_SoqlUtils.performDmlOperation(
			H_C_SoqlUtils.DmlOperation.Upserting, testAccounts, dmlOptions);
		System.assertEquals(true, operationResults.isOperationSuccessful);
		
		
		//TEST #4.1: DELETE data (delete only the 1st account)
		operationResults = H_C_SoqlUtils.performDmlOperation(H_C_SoqlUtils.DmlOperation.Deleting,
			new Account[] {testAccount1}, dmlOptions);
		System.assertEquals(true, operationResults.isOperationSuccessful);
		Database.DeleteResult[] deleteResults = (Database.DeleteResult[])operationResults.results;
		System.assertEquals(1, deleteResults.size());
		//check that the 1st account was deleted successfully
		System.assertEquals(true, deleteResults[0].isSuccess());
		
		//TEST #4.2: DELETE data (delete both accounts)
		operationResults = H_C_SoqlUtils.performDmlOperation(H_C_SoqlUtils.DmlOperation.Deleting,
			testAccounts, dmlOptions);
		System.assertEquals(true, operationResults.isOperationSuccessful);
		deleteResults = (Database.DeleteResult[])operationResults.results;
		System.assertEquals(2, deleteResults.size());
		//the 1st account has been already deleted
		System.assertEquals(false, deleteResults[0].isSuccess());
		//check that the 2nd account was deleted sucessfully
		System.assertEquals(true, deleteResults[1].isSuccess());
		
		
		//TEST #5.1: UNDELETE data (undelete only the 1st account)
		operationResults = H_C_SoqlUtils.performDmlOperation(H_C_SoqlUtils.DmlOperation.Undeleting,
			new Account[] {testAccount1}, dmlOptions);
		System.assertEquals(true, operationResults.isOperationSuccessful);
		Database.UndeleteResult[] undeleteResults = (Database.UndeleteResult[])operationResults.results;
		System.assertEquals(1, undeleteResults.size());
		//check that the 1st account was undeleted successfully
		System.assertEquals(true, undeleteResults[0].isSuccess());
		
		//TEST #5.2: UNDELETE data (undelete both accounts)
		operationResults = H_C_SoqlUtils.performDmlOperation(H_C_SoqlUtils.DmlOperation.Undeleting,
			testAccounts, dmlOptions);
		System.assertEquals(true, operationResults.isOperationSuccessful);
		undeleteResults = (Database.UndeleteResult[])operationResults.results;
		System.assertEquals(2, undeleteResults.size());
		//the 1st account has been already undeleted
		System.assertEquals(false, undeleteResults[0].isSuccess());
		//check that the 2nd account was undeleted sucessfully
		System.assertEquals(true, undeleteResults[1].isSuccess());
	}
	
	@IsTest
	private static void testSoqlUtils_performSafeDmlOperation_checkDMLStatements()
	{
		//disable triggers to improve performance of the test
    	H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
		
		//WRONG DATA
		System.assertEquals(false, H_C_SoqlUtils.performSafeDmlOperation(null, null).isOperationSuccessful);
		
		//GOOD DATA
		//create test data
		Account testAccount = H_C_UnitTestUtils.createAccount('Test Account');
		Integer numberOfAllowedDmlStatements = H_C_SFLimits.getNumberOfAllowedDMLStatements();
		H_C_OperationResults results;
		for (Integer indexOfOperation = 0; indexOfOperation < numberOfAllowedDmlStatements;
			indexOfOperation++)
		{
			results = H_C_SoqlUtils.performSafeDmlOperation(H_C_SoqlUtils.DmlOperation.Updating,
				new sObject[] {testAccount});
			System.assertEquals(true, results.isOperationSuccessful);
		}
		//here we are already out of the limits
		results = H_C_SoqlUtils.performSafeDmlOperation(H_C_SoqlUtils.DmlOperation.Updating,
			new sObject[] {testAccount});
		System.assertEquals(false, results.isOperationSuccessful);
		System.assertEquals(H_C_OperationResults.ErrorType.DMLStatementsLimitExceeded, results.errors[0]);
	}
	
	@IsTest
	private static void testSoqlUtils_performSafeDmlOperation_checkDMLRows()
	{
		//disable triggers to improve performance of the test
    	H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
		
		//WRONG DATA
		System.assertEquals(false, H_C_SoqlUtils.performSafeDmlOperation(null, null).isOperationSuccessful);
		
		//GOOD DATA
		//create test data
		List<Account> testAccounts = new List<Account>();
		for (Integer indexOfAccount = 0; indexOfAccount < 100; indexOfAccount++)
		{
			testAccounts.add(H_C_UnitTestUtils.constructAccount('Test Account' + indexOfAccount));
		}
		insert testAccounts;
		
		Integer numberOfAllowedDmlRows = H_C_SFLimits.getNumberOfAllowedDMLRows();
		H_C_OperationResults results;
		for (Integer indexOfUpdate = 0; indexOfUpdate < numberOfAllowedDmlRows / testAccounts.size();
			indexOfUpdate++)
		{
			results = H_C_SoqlUtils.performSafeDmlOperation(
				H_C_SoqlUtils.DmlOperation.Updating, testAccounts);
			System.assertEquals(true, results.isOperationSuccessful, 'OP = ' + indexOfUpdate + '\n' + results);
		}
		//here we are already out of the limits
		results = H_C_SoqlUtils.performSafeDmlOperation(H_C_SoqlUtils.DmlOperation.Updating, testAccounts);
		System.assertEquals(false, results.isOperationSuccessful);
		System.assertEquals(H_C_OperationResults.ErrorType.DMLRowsLimitExceeded, results.errors[0]);
	}
	
	@IsTest
	private static void testSoqlUtils_performQuery()
	{
		//wrong data
		H_C_SoqlQueryBuilder queryBuilder = null;
		System.assertEquals(null, H_C_SoqlUtils.performQuery(queryBuilder));
		System.assertEquals(null, H_C_SoqlUtils.performQuery(''));
		System.assertEquals(null, H_C_SoqlUtils.performQuery('Wrong Query'));
		
		//good data
		queryBuilder = new H_C_SoqlQueryBuilder('Id', 'User');
		queryBuilder.condition = 'Id = \'' + UserInfo.getUserId() + '\'';
		
		//check the 1st overload
		User[] users = H_C_SoqlUtils.performQuery(queryBuilder);
		System.assertEquals(1, users.size());
		
		//check the 2nd overload
		users = H_C_SoqlUtils.performQuery(queryBuilder.buildQuery());
		System.assertEquals(1, users.size());
	}
	
	@IsTest
	private static void testSoqlUtils_performSingleResultQuery()
	{
		//wrong data
		H_C_SoqlQueryBuilder queryBuilder = null;
		System.assertEquals(null, H_C_SoqlUtils.performSingleResultQuery(queryBuilder));
		System.assertEquals(null, H_C_SoqlUtils.performSingleResultQuery(''));
		
		//good data
		queryBuilder = new H_C_SoqlQueryBuilder('Id', 'User');
		queryBuilder.condition = 'Id = \'' + UserInfo.getUserId() + '\'';
		
		//check the 1st overload
		User user = (User)H_C_SoqlUtils.performSingleResultQuery(queryBuilder);
		System.assertEquals(UserInfo.getUserId(), user.Id);
		
		//check the 2nd overload
		user = (User)H_C_SoqlUtils.performSingleResultQuery(queryBuilder.buildQuery());
		System.assertEquals(UserInfo.getUserId(), user.Id);
	}
	
	@IsTest
	private static void testSoqlUtils_createQueryLocator()
	{
		//wrong parameters
		System.assertEquals(null, H_C_SoqlUtils.createQueryLocator(null));
		System.assertEquals(null, H_C_SoqlUtils.createQueryLocator(''));
		System.assertEquals(null, H_C_SoqlUtils.createQueryLocator('Wrong query string'));
		
		//correct parameters
		System.assertNotEquals(null, H_C_SoqlUtils.createQueryLocator('Select Id From Account limit 10'));
	}
    //
    
    
    
    
    
    //
    //Unit tests for 'H_C_SoqlQueryBuilder' class
    //  
    @IsTest
    private static void testSoqlQueryBuilder_buildQuery()
    {
        H_C_SoqlQueryBuilder builder = new H_C_SoqlQueryBuilder('Id, Name', 'ObjectName');
        builder.condition = 'Id = 55555';
        builder.setOrderByBlock('', null);
        System.assertEquals('SELECT Id, Name FROM ObjectName WHERE Id = 55555', builder.buildQuery());
        
        builder = new H_C_SoqlQueryBuilder('Id, Name', 'ObjectName');
        builder.condition = 'Id = 55555';
        builder.setOrderByBlock('Name', H_C_SortingUtils.SortingOrder.Descending);
        System.assertEquals('SELECT Id, Name FROM ObjectName WHERE Id = 55555 ORDER BY Name DESC', builder.buildQuery());
        
        builder = new H_C_SoqlQueryBuilder('Id, Name', 'ObjectName', 'Id = 55555');
        builder.setOrderByBlock('Name', H_C_SortingUtils.SortingOrder.Ascending);
        builder.limitOfResultSet = 100;
        builder.offsetOfResult = 10;
        builder.groupByFields = 'Name';
        System.assertEquals('SELECT Id, Name FROM ObjectName WHERE Id = 55555 GROUP BY Name ORDER BY Name ASC LIMIT 100 OFFSET 10', builder.buildQuery());
        
        builder = new H_C_SoqlQueryBuilder('', null);
        System.assertEquals(null, builder.buildQuery());
    }
    //
    
    
    
    
    
    //
	//Unit tests for 'H_C_SortingUtils' class
	//
	@IsTest
	private static void testSortingUtils_SortingParameter()
	{
		//initialize parameter 
		H_C_SortingUtils.SortingParameter parameter = new H_C_SortingUtils.SortingParameter('Field1');
		//check initial state
		System.assertEquals('Field1', parameter.fieldName);
		System.assertEquals(H_C_SortingUtils.SortingOrder.Ascending, parameter.sortingOrder);
		System.assertEquals(String.valueOf(H_C_SortingUtils.SortingOrder.Ascending),
			parameter.sortingOrderName);
		System.assertEquals(H_C_SortingUtils.DEFAULT_SORTING_OPTIONS.ignoreStringCase,
			parameter.options.ignoreStringCase);
		System.assertEquals(H_C_SortingUtils.DEFAULT_SORTING_OPTIONS.blankValuesAtEnd,
			parameter.options.blankValuesAtEnd);
		
		//change sorting order
		parameter.sortingOrder = H_C_SortingUtils.SortingOrder.Descending;
		System.assertEquals(H_C_SortingUtils.SortingOrder.Descending, parameter.sortingOrder);
		System.assertEquals(String.valueOf(H_C_SortingUtils.SortingOrder.Descending),
			parameter.sortingOrderName);
		
		//change options
		H_C_SortingUtils.SortingOptions options = new H_C_SortingUtils.SortingOptions();
		options.ignoreStringCase = false;
		options.blankValuesAtEnd = false;
		parameter.options = options;
		System.assertEquals(options.ignoreStringCase, parameter.options.ignoreStringCase);
		System.assertEquals(options.blankValuesAtEnd, parameter.options.blankValuesAtEnd);
		
		//clone
		H_C_SortingUtils.SortingParameter[] clonedParameters = parameter.clone(null);
		System.assertEquals(1, clonedParameters.size());
		System.assertEquals(parameter.fieldName, clonedParameters[0].fieldName);
		
		clonedParameters = parameter.clone(new String[] {'NewField1', null, '', null, 'NewField5'});
		System.assertEquals(2, clonedParameters.size());
		System.assert(clonedParameters[0].fieldName == 'NewField1' && clonedParameters[1].fieldName == 'NewField5'
			|| clonedParameters[1].fieldName == 'NewField1' && clonedParameters[0].fieldName == 'NewField5'); 
	}
	
	@IsTest
	private static void testSortingUtils_getInverseSortingOrder()
	{
		System.assertEquals(H_C_SortingUtils.SortingOrder.Ascending,
			H_C_SortingUtils.getInverseSortingOrder(null));
		System.assertEquals(H_C_SortingUtils.SortingOrder.Ascending,
			H_C_SortingUtils.getInverseSortingOrder(H_C_SortingUtils.SortingOrder.Descending));
		System.assertEquals(H_C_SortingUtils.SortingOrder.Descending,
			H_C_SortingUtils.getInverseSortingOrder(H_C_SortingUtils.SortingOrder.Ascending));
	}
	//
}