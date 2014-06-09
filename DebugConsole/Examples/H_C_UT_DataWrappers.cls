//
//This class contains Unit tests for all data wrappers
//Used abbreviations:
// - UT means 'Unit test'
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (10-09-2013)
@IsTest
private class H_C_UT_DataWrappers
{
    //
    //Unit tests for 'H_C_sObjectControllerWrapper' class
    //
	@IsTest
	private static void test_sObjectControllerWrapper()
    {
    	//prepare test data
    	Account account1 = H_C_UnitTestUtils.createAccount('Account1');
    	
    	//TEST #1: check that links are correct (we do not pass URL-parameters in wrapper)
    	H_C_sObjectControllerWrapper wrapper1 = new H_C_sObjectControllerWrapper(account1);
		System.assertNotEquals(null, wrapper1.getLinkToView());
		System.assertNotEquals(null, wrapper1.getLinkToEdit());
		System.assertNotEquals(null, wrapper1.getLinkToDelete());
		
		//TEST #2: check that links are correct (we pass URL-parameters in wrapper)
		Map<String, String> urlParameters = new Map<String, String>();
		urlParameters.put('retURL', '/' + account1.Id);
		H_C_sObjectControllerWrapper wrapper2 = new H_C_sObjectControllerWrapper(account1, urlParameters);
		System.assertNotEquals(null, wrapper2.getLinkToView());
		System.assertNotEquals(null, wrapper2.getLinkToEdit());
		System.assertNotEquals(null, wrapper2.getLinkToDelete());
		
		//TEST #3: wrapper can't be initialized
		try
		{
			H_C_sObjectControllerWrapper wrapper3 = new H_C_sObjectControllerWrapper(null);
			System.assert(false);
		}
		catch (H_C_Exception error)
		{
			System.assert(true);
		}
    }
	//
    
    
    
    
    
    //
    //Unit tests for 'H_C_OpenActivityWrapper' class
    //
	@IsTest(SeeAllData = true)
	private static void test_OpenActivityWrapper()
    {
    	//#IMPORTANT:
		//we must use 'SeeAllData = true' property here, because Unit tests can't select
		//list of 'OpenActivity' objects without it
		
    	//prepare test data
    	DateTime commonActivityDate = DateTime.newInstanceGmt(Date.today().addDays(5),
    		Time.newInstance(12, 0, 0, 0));
    	Account account1 = H_C_UnitTestUtils.createAccount('Account1');
    	Event event1 = H_C_UnitTestUtils.constructEvent('Event1', account1.Id, commonActivityDate, 120);
    	Task task1 = H_C_UnitTestUtils.constructTask('Task1', commonActivityDate.date(), account1.Id);
    	insert new sObject[] {event1, task1};
    	
    	//reread open activities
    	OpenActivity[] openActivities = H_C_ActivityDAO.getOpenActivitiesByAccountId(account1.Id, false);
		System.assertEquals(2, openActivities.size());
		Map<Id, OpenActivity> mapOfActivities = new Map<Id, OpenActivity>(openActivities);
		
		//create url parameters
		Map<String, String> urlParameters = new Map<String, String>();
		urlParameters.put('retURL', '/' + account1.Id);
		
		//initialize wrappers
		H_C_OpenActivityWrapper wrapper1 =
			new H_C_OpenActivityWrapper(mapOfActivities.get(event1.Id), urlParameters);
		H_C_OpenActivityWrapper wrapper2 =
			new H_C_OpenActivityWrapper(mapOfActivities.get(task1.Id), urlParameters);
		
		//TEST #1: check that links are correct
		System.assertNotEquals(null, wrapper1.getLinkToView());
		System.assertNotEquals(null, wrapper1.getLinkToEdit());
		System.assertNotEquals(null, wrapper1.getLinkToDelete());
		//only task can be closed
		System.assertEquals(null, wrapper1.getLinkToCloseTask());
		
		System.assertNotEquals(null, wrapper2.getLinkToView());
		System.assertNotEquals(null, wrapper2.getLinkToEdit());
		System.assertNotEquals(null, wrapper2.getLinkToCloseTask());
		System.assertNotEquals(null, wrapper2.getLinkToDelete());
		
		//TEST #2: check start date time
		System.assertEquals(commonActivityDate, wrapper1.startDateTime);
		System.assertEquals(commonActivityDate.date(), wrapper2.startDateTime);
		
		//TEST #3: check 'H_C_IDynamicObjectWrapper' implementation
		System.assertEquals(event1.Subject, wrapper1.getFieldValue('Subject'));
		System.assertEquals(commonActivityDate, wrapper1.getFieldValue('StartDateTime'));
		
		System.assertEquals(task1.Subject, wrapper2.getFieldValue('Subject'));
		System.assertEquals(commonActivityDate.date(), wrapper2.getFieldValue('StartDateTime'));
		
		//TEST #4: check 'Comparble' implementation and the mechanism of mutable sorting
		//test 4.1:
		List<H_C_SortingUtils.SortingParameter> parameters = new H_C_SortingUtils.SortingParameter[0];
		//create a new sorting parameter to sort by Subject
		H_C_SortingUtils.SortingParameter parameter1 = new H_C_SortingUtils.SortingParameter('Subject');
		parameters.add(parameter1);
		H_C_OpenActivityWrapper.setSortingParameters(parameters);
		//'Event1' word is before 'Task1' word
		System.assert(wrapper1.compareTo(wrapper2) < 0);
		System.assert(wrapper2.compareTo(wrapper1) > 0);
		
		//test 4.2:
		//update sorting parameters to set descending order
		parameter1.sortingOrder = H_C_SortingUtils.SortingOrder.Descending;
		H_C_OpenActivityWrapper.setSortingParameters(parameters);
		//'Event1' word is after 'Task1' word now
		System.assert(wrapper1.compareTo(wrapper2) > 0);
		System.assert(wrapper2.compareTo(wrapper1) < 0);
		
		//test 4.3:
		//set sorting parameters to null (in this case default parameters should be used). It means
		//that wrappers will be sorted by 'StartDateTime' field in ascending order
		H_C_OpenActivityWrapper.setSortingParameters(null);
		//event1 will start at 12:00, but task1 has no concrete time, i.e. its time is 00:00
		System.assert(wrapper1.compareTo(wrapper2) > 0);
		System.assert(wrapper2.compareTo(wrapper1) < 0);
    }
    //
    
    
    
    
    
    //
    //Unit tests for 'H_C_ActivityHistoryWrapper' class
    //
    @IsTest(SeeAllData = true)
	private static void test_ActivityHistoryWrapper()
    {
    	//#IMPORTANT:
		//we must use 'SeeAllData = true' property here, because Unit tests can't select
		//list of 'ActivityHistory' objects without it
		
    	//prepare test data
    	//we will use passed date
    	DateTime commonActivityDate = DateTime.newInstanceGmt(
    		Date.today().addDays(-5), Time.newInstance(12, 0, 0, 0));
    	Account account1 = H_C_UnitTestUtils.createAccount('Account1');
    	Event event1 = H_C_UnitTestUtils.constructEvent('Event1', account1.Id, commonActivityDate, 120);
    	Task task1 = H_C_UnitTestUtils.constructTask('Task1', commonActivityDate.date(), account1.Id);
    	task1.Status = 'Completed';
    	insert new sObject[] {event1, task1};
    	
    	//reread open activities
    	ActivityHistory[] activities = H_C_ActivityDAO.getActivityHistoriesByAccountId(account1.Id, false);
		System.assertEquals(2, activities.size());
		Map<Id, ActivityHistory> mapOfActivities = new Map<Id, ActivityHistory>(activities);
		
		//create url parameters
		Map<String, String> urlParameters = new Map<String, String>();
		urlParameters.put('retURL', '/' + account1.Id);
		
		//initialize wrappers
		H_C_ActivityHistoryWrapper wrapper1 =
			new H_C_ActivityHistoryWrapper(mapOfActivities.get(event1.Id), urlParameters);
		H_C_ActivityHistoryWrapper wrapper2 =
			new H_C_ActivityHistoryWrapper(mapOfActivities.get(task1.Id), urlParameters);
		
		//TEST #1: check that links are correct
		System.assertNotEquals(null, wrapper1.getLinkToView());
		System.assertNotEquals(null, wrapper1.getLinkToEdit());
		System.assertNotEquals(null, wrapper1.getLinkToDelete());
		
		System.assertNotEquals(null, wrapper2.getLinkToView());
		System.assertNotEquals(null, wrapper2.getLinkToEdit());
		System.assertNotEquals(null, wrapper2.getLinkToDelete());
		
		//TEST #2: check start date time
		System.assertEquals(commonActivityDate, wrapper1.startDateTime);
		System.assertEquals(commonActivityDate.date(), wrapper2.startDateTime);
		
		//TEST #3: check 'H_C_IDynamicObjectWrapper' implementation
		System.assertEquals(event1.Subject, wrapper1.getFieldValue('Subject'));
		System.assertEquals(commonActivityDate, wrapper1.getFieldValue('StartDateTime'));
		
		System.assertEquals(task1.Subject, wrapper2.getFieldValue('Subject'));
		System.assertEquals(commonActivityDate.date(), wrapper2.getFieldValue('StartDateTime'));
		
		//TEST #4: check 'Comparble' implementation and the mechanism of mutable sorting
		//test 4.1:
		List<H_C_SortingUtils.SortingParameter> parameters = new H_C_SortingUtils.SortingParameter[0];
		//create a new sorting parameter to sort by Subject
		H_C_SortingUtils.SortingParameter parameter1 = new H_C_SortingUtils.SortingParameter('Subject');
		parameters.add(parameter1);
		H_C_ActivityHistoryWrapper.setSortingParameters(parameters);
		//'Event1' word is before 'Task1' word
		System.assert(wrapper1.compareTo(wrapper2) < 0);
		System.assert(wrapper2.compareTo(wrapper1) > 0);
		
		//test 4.2:
		//update sorting parameters to set descending order
		parameter1.sortingOrder = H_C_SortingUtils.SortingOrder.Descending;
		H_C_ActivityHistoryWrapper.setSortingParameters(parameters);
		//'Event1' word is after 'Task1' word now
		System.assert(wrapper1.compareTo(wrapper2) > 0);
		System.assert(wrapper2.compareTo(wrapper1) < 0);
		
		//test 4.3:
		//set sorting parameters to null (in this case default parameters should be used). It means
		//that wrappers will be sorted by 'StartDateTime' field in descending order
		H_C_ActivityHistoryWrapper.setSortingParameters(null);
		//event1 will start at 12:00, but task1 has no concrete time, i.e. its time is 00:00
		System.assert(wrapper1.compareTo(wrapper2) < 0);
		System.assert(wrapper2.compareTo(wrapper1) > 0);
    }
    //
    
    
    
    
    
    //
    //Unit tests for 'H_C_NoteAndAttachmentWrapper' class
    //
    @IsTest(SeeAllData = true)
	private static void test_NoteAndAttachmentWrapper()
    {
    	//#IMPORTANT:
		//we must use 'SeeAllData = true' property here, because Unit tests can't select
		//list of 'NoteAndAttachment' objects without it
		
    	//prepare test data
    	Account account1 = H_C_UnitTestUtils.createAccount('Account1');
    	Attachment attachment1 = H_C_UnitTestUtils.createAttachment('Attachment1',
    		account1.Id, Blob.valueOf('Test Body of an Attachment'));
    	Note note1 = H_C_UnitTestUtils.createNote('Note1', account1.Id, 'Test Note');
    	
    	//reread open activities
    	NoteAndAttachment[] notesAndAttachments =
    		H_C_NoteAndAttachmentDAO.getNotesAndAttachmentsByAccountId(account1.Id, false);
		System.assertEquals(2, notesAndAttachments.size());
		Map<Id, NoteAndAttachment> mapOfNotesAndAttachments = new Map<Id, NoteAndAttachment>(notesAndAttachments);
		
		//create url parameters
		Map<String, String> urlParameters = new Map<String, String>();
		urlParameters.put('retURL', '/' + account1.Id);
		
		//initialize wrappers
		H_C_NoteAndAttachmentWrapper wrapper1 = new H_C_NoteAndAttachmentWrapper(
			mapOfNotesAndAttachments.get(attachment1.Id), urlParameters);
		H_C_NoteAndAttachmentWrapper wrapper2 = new H_C_NoteAndAttachmentWrapper(
			mapOfNotesAndAttachments.get(note1.Id), urlParameters);
		
		//TEST #1: check that links are correct
		System.assertNotEquals(null, wrapper1.getLinkToView());
		System.assertNotEquals(null, wrapper1.getLinkToEdit());
		System.assertNotEquals(null, wrapper1.getLinkToDelete());
		
		System.assertNotEquals(null, wrapper2.getLinkToView());
		System.assertNotEquals(null, wrapper2.getLinkToEdit());
		System.assertNotEquals(null, wrapper2.getLinkToDelete());
		
		//TEST #2: check 'H_C_IDynamicObjectWrapper' implementation
		System.assertEquals(attachment1.Name, wrapper1.getFieldValue('Title'));
		System.assertEquals(false, wrapper1.getFieldValue('IsNote'));
		System.assertEquals(account1.Id, wrapper1.getFieldValue('ParentId'));
		
		System.assertEquals(note1.Title, wrapper2.getFieldValue('Title'));
		System.assertEquals(true, wrapper2.getFieldValue('IsNote'));
		System.assertEquals(account1.Id, wrapper2.getFieldValue('ParentId'));
		
		//TEST #3: check 'Comparble' implementation and the mechanism of mutable sorting
		//test 3.1:
		List<H_C_SortingUtils.SortingParameter> parameters = new H_C_SortingUtils.SortingParameter[0];
		//create a new sorting parameter to sort by 'IsNote' flag
		H_C_SortingUtils.SortingParameter parameter1 = new H_C_SortingUtils.SortingParameter('IsNote');
		parameters.add(parameter1);
		H_C_NoteAndAttachmentWrapper.setSortingParameters(parameters);
		//false should be before true => Attachment should be before Note
		System.assert(wrapper1.compareTo(wrapper2) < 0);
		System.assert(wrapper2.compareTo(wrapper1) > 0);
		
		//test 3.2:
		//update sorting parameters to set descending order
		parameter1.sortingOrder = H_C_SortingUtils.SortingOrder.Descending;
		H_C_NoteAndAttachmentWrapper.setSortingParameters(parameters);
		//true should be before false => Note should be before Attachment
		System.assert(wrapper1.compareTo(wrapper2) > 0);
		System.assert(wrapper2.compareTo(wrapper1) < 0);
		
		//test 3.3:
		//set sorting parameters to null (in this case default parameters should be used). It means
		//that wrappers will be sorted by 'Title' field in ascending order
		H_C_NoteAndAttachmentWrapper.setSortingParameters(null);
		//'Attachment1' word is before 'Note1' word
		System.assert(wrapper1.compareTo(wrapper2) < 0);
		System.assert(wrapper2.compareTo(wrapper1) > 0);
    }
    //
    
    
    
    
    
    //
    //Unit tests for 'H_C_PaginationParameters' class
    //
    @IsTest
	private static void test_PaginationParameters()
	{
		//initialize parameters
		H_C_PaginationParameters parameters = new H_C_PaginationParameters(0, 10, 0);
		System.assertEquals(0, parameters.currentPageNumber);
		System.assertEquals(0, parameters.totalRecordsNumber);
		System.assertEquals(0, parameters.quantityOfPages);
		System.assertEquals(10, parameters.numberOfRecordsPerPage);
		
		//check properties
		//1) set the current page number (quantity of pages is 0, that's why nothing should be changed)
		parameters.currentPageNumber = 10;
		System.assertEquals(0, parameters.currentPageNumber);
		System.assertEquals(0, parameters.firstRecordOffset);
		System.assertEquals(false, parameters.hasNextPage);
		System.assertEquals(false, parameters.hasPreviousPage);
		
		//2) set the total records number
		parameters.totalRecordsNumber = 105;
		System.assertEquals(11, parameters.quantityOfPages);
		System.assertEquals(1, parameters.currentPageNumber);
		System.assertEquals(0, parameters.firstRecordOffset);
		
		//3) set the current page number
		parameters.currentPageNumber = 10;
		System.assertEquals(11, parameters.quantityOfPages);
		System.assertEquals(10, parameters.currentPageNumber);
		System.assertEquals(90, parameters.firstRecordOffset);
		System.assertEquals(true, parameters.hasNextPage);
		System.assertEquals(true, parameters.hasPreviousPage);
		
		//4) set another number of records per page
		parameters.numberOfRecordsPerPage = 50;
		System.assertEquals(3, parameters.quantityOfPages);
		System.assertEquals(3, parameters.currentPageNumber);
		System.assertEquals(100, parameters.firstRecordOffset);
		System.assertEquals(false, parameters.hasNextPage);
		System.assertEquals(true, parameters.hasPreviousPage);
		
		//5) reinitialize parameters via empty constructor
		parameters = new H_C_PaginationParameters();
		System.assertEquals(0, parameters.currentPageNumber);
		System.assertEquals(0, parameters.totalRecordsNumber);
		System.assertEquals(0, parameters.quantityOfPages);
	}
	//
}