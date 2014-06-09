//
//This class contains Unit tests for all controllers and extensions
//Used abbreviations:
// - UT means 'Unit test'
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (10-09-2013)
@IsTest
public class H_C_UT_ControllersAndExtensions
{
	//
    //Unit tests for 'H_C_AdminController' class
    //
    @IsTest
    private static void testAdminController_properties()
    {
    	//test unusual cases
    	H_C_AdminController controller = new H_C_AdminController();
    	System.assertNotEquals(null, controller.codeOfAccountHierarchyManager);
    	System.assertNotEquals(null, controller.codeOfATRU_Manager);
    	System.assertNotEquals(null, controller.codeOfATRD_Manager);
    	System.assertNotEquals(null, controller.codeOfAccountRelatedListsManager);
    }

    @IsTest
    private static void testAdminController_publicMethods()
    {
    	H_C_AdminController controller = new H_C_AdminController();
    	System.assertNotEquals(null, controller.mapOfJobsIds);
    	System.assertNotEquals(null, controller.mapOfJobsMessages);

    	controller.updateHierarchy();
    	controller.updateHierarchy();

    	controller.rollUpAccountTeams();
    	controller.rollUpAccountTeams();
    	
    	controller.rollDownAccountTeams();
    	controller.rollDownAccountTeams();

    	controller.rollupAccountRelatedLists();
    	controller.rollupAccountRelatedLists();

    	controller.startScheduledAccountsManager();
    	controller.startScheduledAccountsManager();
    }
    //
    
    
    
    
    
    //
	//Unit tests for 'H_C_SearchAccountsController' class
	//
	@IsTest
	private static void testSearchAccountsController_searchAccounts()
	{
		H_C_SearchAccountsController controller = new H_C_SearchAccountsController();
		System.assertNotEquals(null, controller.serializedARTNsWithoutShipping);
		System.assertNotEquals(null, controller.accountRecordTypes);
		
		controller.accountName = 'Gennadiy';
		controller.selectedAccountRecordType = H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT;
		controller.shippingCity = 'Boston';
		System.assertNotEquals(null, controller.searchAccounts());
	}
	//
	
	
	
	
	
	//
    //Unit tests for 'H_C_RedirectManager' class
    //
    @IsTest
    private static void testRedirectManager_viewMode()
    {
    	//set one of the view pages for the test 
    	Test.setCurrentPage(Page.H_C_Opportunity_View);
    	
    	//create test data and initalize controller
    	Account account1 = H_C_UnitTestUtils.createAccount('Account1');
    	Opportunity opportunity1 = H_C_UnitTestUtils.createOpportunity('Opportunity1', account1.Id);
    	ApexPages.StandardController controller = new ApexPages.StandardController(
    		H_C_UnitTestUtils.createAccountOpportunityMapping(account1, opportunity1));
    	
    	//initialize manager
    	H_C_RedirectManager manager = new H_C_RedirectManager(controller);
    	//check that redirect is correct
    	System.assertNotEquals(null, manager.redirect());
    }
    
    @IsTest
    private static void testRedirectManager_editMode()
    {
    	//set one of the view pages for the test 
    	Test.setCurrentPage(Page.H_C_Contact_Edit);
    	
    	//create test data and initalize controller
    	Account account1 = H_C_UnitTestUtils.createAccount('Account1');
    	Contact contact1 = H_C_UnitTestUtils.createContact('Tester', account1.Id);
    	ApexPages.StandardController controller = new ApexPages.StandardController(
    		H_C_UnitTestUtils.createAccountContactMapping(account1, contact1));
    	
    	//initialize manager
    	H_C_RedirectManager manager = new H_C_RedirectManager(controller);
    	//check that redirect is correct
    	System.assertNotEquals(null, manager.redirect());
    }
    
    
    
    
    
    
    //
    //Unit tests for 'H_C_AccountExtension' class
    //
    @IsTest
	private static void testAccountExtension_unusualCase()
	{
		//we test only unusual case here
		try
		{
			H_C_AccountExtension extension = new H_C_OpenActivitiesExtension(null);
			System.assert(false);
		}
		catch (H_C_Exception error)
		{
			System.assert(true);
		}
	}
    //
    
    
    
    
    
    //
    //Unit tests for 'H_C_OpenActivitiesExtension' class
    //
    @IsTest(SeeAllData = true)
	private static void testOpenActivitiesExtension()
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
    	
    	//set current page
    	PageReference currentPage = Page.H_C_OpenActivities;
    	Test.setCurrentPage(currentPage);
		
		//initialize an extension1
		H_C_OpenActivitiesExtension extension1 = new H_C_OpenActivitiesExtension(
			new ApexPages.StandardController(account1));
		System.assertEquals(2, extension1.openActivityWrappers.size());
		
		//TEST #1: activities should be sorted by StartDateTime in ascending order
		System.assertEquals(task1.Id, extension1.openActivityWrappers[0].info.Id);
		System.assertEquals(event1.Id, extension1.openActivityWrappers[1].info.Id);
		
		//TEST #2: we try to set new sorting, but do not pass correct parameters
		extension1.onNewSortingSelected();
		//nothing should be changed
		System.assertEquals(task1.Id, extension1.openActivityWrappers[0].info.Id);
		System.assertEquals(event1.Id, extension1.openActivityWrappers[1].info.Id);
		
		//TEST #3: set new sorting order for the field which is already selected
		currentPage.getParameters().put(H_C_RequestParameters.SORTING_COLUMN, 'StartDateTime');
		extension1.onNewSortingSelected();
		System.assertEquals(event1.Id, extension1.openActivityWrappers[0].info.Id);
		System.assertEquals(task1.Id, extension1.openActivityWrappers[1].info.Id);
		
		//TEST #4: test complex sorting fields (simply to cover corresponding code lines)
		currentPage.getParameters().put(H_C_RequestParameters.SORTING_COLUMN, 'Who.FullName');
		extension1.onNewSortingSelected();
		currentPage.getParameters().put(H_C_RequestParameters.SORTING_COLUMN, 'Owner.FullName');
		extension1.onNewSortingSelected();
		
		//TEST #5: test methods for pagination
		System.assertNotEquals(null, extension1.getPaginationBinder());
		
		H_C_PaginationParameters currentParameters = extension1.getPaginationParameters();
		System.assertNotEquals(null, currentParameters);
		H_C_PaginationParameters newParameters = new H_C_PaginationParameters(
			currentParameters.totalRecordsNumber, 1, currentParameters.currentPageNumber);
		extension1.setPaginationParameters(newParameters);
		System.assertEquals(1, extension1.getPaginationParameters().numberOfRecordsPerPage);
		
		//TEST #6: set new parameters for the current page and initialize another extension
		currentPage.getParameters().put(H_C_RequestParameters.IS_PAGE_INLINE, 'true');
		H_C_OpenActivitiesExtension extension2 = new H_C_OpenActivitiesExtension(
			new ApexPages.StandardController(account1));
		//parameters for outgoing links should be other
		String returnUrlFromExtension1 = extension1.openActivityWrappers[0]
			.getLinkToView().getParameters().get(H_C_RequestParameters.RETURN_URL);
		String returnUrlFromExtension2 = extension2.openActivityWrappers[0]
			.getLinkToView().getParameters().get(H_C_RequestParameters.RETURN_URL);
		System.assertNotEquals(returnUrlFromExtension1, returnUrlFromExtension2);
	}
    //
    
    
    
    
    
    //
    //Unit tests for 'H_C_ActivityHistoriesExtension' class
    //
    @IsTest(SeeAllData = true)
	private static void testActivityHistoriesExtension()
	{
		//#IMPORTANT:
		//we must use 'SeeAllData = true' property here, because Unit tests can't select
		//list of 'ActivityHistory' objects without it
		
    	//prepare test data
    	DateTime commonActivityDate = DateTime.newInstanceGmt(Date.today().addDays(-5),
    		Time.newInstance(12, 0, 0, 0));
    	Account account1 = H_C_UnitTestUtils.createAccount('Account1');
    	Event event1 = H_C_UnitTestUtils.constructEvent('Event1', account1.Id, commonActivityDate, 120);
    	Task task1 = H_C_UnitTestUtils.constructTask('Task1', commonActivityDate.date(), account1.Id);
    	task1.Status = 'Completed';
    	insert new sObject[] {event1, task1};
    	
    	//set current page
    	PageReference currentPage = Page.H_C_ActivityHistories;
    	Test.setCurrentPage(currentPage);
		
		//initialize an extension1
		H_C_ActivityHistoriesExtension extension1 = new H_C_ActivityHistoriesExtension(
			new ApexPages.StandardController(account1));
		System.assertEquals(2, extension1.activityHistoryWrappers.size());
		
		//TEST #1: activities should be sorted by StartDateTime in descending order
		System.assertEquals(event1.Id, extension1.activityHistoryWrappers[0].info.Id);
		System.assertEquals(task1.Id, extension1.activityHistoryWrappers[1].info.Id);
		
		//TEST #2: we try to set new sorting, but do not pass correct parameters
		extension1.onNewSortingSelected();
		//nothing should be changed
		System.assertEquals(event1.Id, extension1.activityHistoryWrappers[0].info.Id);
		System.assertEquals(task1.Id, extension1.activityHistoryWrappers[1].info.Id);
		
		//TEST #3: set new sorting order for the field which is already selected
		currentPage.getParameters().put(H_C_RequestParameters.SORTING_COLUMN, 'StartDateTime');
		extension1.onNewSortingSelected();
		System.assertEquals(task1.Id, extension1.activityHistoryWrappers[0].info.Id);
		System.assertEquals(event1.Id, extension1.activityHistoryWrappers[1].info.Id);
		
		//TEST #4: set new sorting field
		currentPage.getParameters().put(H_C_RequestParameters.SORTING_COLUMN, 'Subject');
		extension1.onNewSortingSelected();
		//'Event1' word is before 'Task1' word
		System.assertEquals(event1.Id, extension1.activityHistoryWrappers[0].info.Id);
		System.assertEquals(task1.Id, extension1.activityHistoryWrappers[1].info.Id);
		
		//TEST #5: test complex sorting fields (simply to cover corresponding code lines)
		currentPage.getParameters().put(H_C_RequestParameters.SORTING_COLUMN, 'Who.FullName');
		extension1.onNewSortingSelected();
		currentPage.getParameters().put(H_C_RequestParameters.SORTING_COLUMN, 'Owner.FullName');
		extension1.onNewSortingSelected();
		
		//TEST #6: test methods for pagination
		System.assertNotEquals(null, extension1.getPaginationBinder());
		
		H_C_PaginationParameters currentParameters = extension1.getPaginationParameters();
		System.assertNotEquals(null, currentParameters);
		H_C_PaginationParameters newParameters = new H_C_PaginationParameters(
			currentParameters.totalRecordsNumber, 1, currentParameters.currentPageNumber);
		extension1.setPaginationParameters(newParameters);
		System.assertEquals(1, extension1.getPaginationParameters().numberOfRecordsPerPage);
		
		//TEST #7: set new parameters for the current page and initialize another extension
		currentPage.getParameters().put(H_C_RequestParameters.IS_PAGE_INLINE, 'true');
		H_C_ActivityHistoriesExtension extension2 = new H_C_ActivityHistoriesExtension(
			new ApexPages.StandardController(account1));
		//parameters for outgoing links should be other
		String returnUrlFromExtension1 = extension1.activityHistoryWrappers[0]
			.getLinkToView().getParameters().get(H_C_RequestParameters.RETURN_URL);
		String returnUrlFromExtension2 = extension2.activityHistoryWrappers[0]
			.getLinkToView().getParameters().get(H_C_RequestParameters.RETURN_URL);
		System.assertNotEquals(returnUrlFromExtension1, returnUrlFromExtension2);
	}
    //
    
    
    
    
    
    //
    //Unit tests for 'H_C_NotesAndAttachmentsExtension' class
    //
    @IsTest(SeeAllData = true)
	private static void testNotesAndAttachmentsExtension()
	{
		//#IMPORTANT:
		//we must use 'SeeAllData = true' property here, because Unit tests can't select
		//list of 'ActivityHistory' objects without it
		
    	//prepare test data
    	Account account1 = H_C_UnitTestUtils.createAccount('Account1');
    	Attachment attachment1 = H_C_UnitTestUtils.constructAttachment('Attachment1',
    		account1.Id, Blob.valueOf('Test Body of an Attachment'));
    	Note note1 = H_C_UnitTestUtils.constructNote('Note1', account1.Id, 'Test Note');
    	insert new sObject[] {attachment1, note1};
    	
    	//set current page
    	PageReference currentPage = Page.H_C_NotesAndAttachments;
    	Test.setCurrentPage(currentPage);
		
		//initialize an extension1
		H_C_NotesAndAttachmentsExtension extension1 = new H_C_NotesAndAttachmentsExtension(
			new ApexPages.StandardController(account1));
		System.assertEquals(2, extension1.noteAndAttachmentWrappers.size());
		
		//TEST #1: activities should be sorted by Title in ascending order
		System.assertEquals(attachment1.Id, extension1.noteAndAttachmentWrappers[0].info.Id);
		System.assertEquals(note1.Id, extension1.noteAndAttachmentWrappers[1].info.Id);
		
		//TEST #2: we try to set new sorting, but do not pass correct parameters
		extension1.onNewSortingSelected();
		//nothing should be changed
		System.assertEquals(attachment1.Id, extension1.noteAndAttachmentWrappers[0].info.Id);
		System.assertEquals(note1.Id, extension1.noteAndAttachmentWrappers[1].info.Id);
		
		//TEST #3: set new sorting order for the field which is already selected
		currentPage.getParameters().put(H_C_RequestParameters.SORTING_COLUMN, 'Title');
		extension1.onNewSortingSelected();
		System.assertEquals(note1.Id, extension1.noteAndAttachmentWrappers[0].info.Id);
		System.assertEquals(attachment1.Id, extension1.noteAndAttachmentWrappers[1].info.Id);
		
		//TEST #4: set new sorting field
		currentPage.getParameters().put(H_C_RequestParameters.SORTING_COLUMN, 'IsNote');
		extension1.onNewSortingSelected();
		//false should be before true => Attachment should be before Note
		System.assertEquals(attachment1.Id, extension1.noteAndAttachmentWrappers[0].info.Id);
		System.assertEquals(note1.Id, extension1.noteAndAttachmentWrappers[1].info.Id);
		
		//TEST #5: test complex sorting fields (simply to cover corresponding code lines)
		currentPage.getParameters().put(H_C_RequestParameters.SORTING_COLUMN, 'Owner.FullName');
		extension1.onNewSortingSelected();
		
		//TEST #6: test methods for pagination
		System.assertNotEquals(null, extension1.getPaginationBinder());
		
		H_C_PaginationParameters currentParameters = extension1.getPaginationParameters();
		System.assertNotEquals(null, currentParameters);
		H_C_PaginationParameters newParameters = new H_C_PaginationParameters(
			currentParameters.totalRecordsNumber, 1, currentParameters.currentPageNumber);
		extension1.setPaginationParameters(newParameters);
		System.assertEquals(1, extension1.getPaginationParameters().numberOfRecordsPerPage);
		
		//TEST #7: set new parameters for the current page and initialize another extension
		currentPage.getParameters().put(H_C_RequestParameters.IS_PAGE_INLINE, 'true');
		H_C_NotesAndAttachmentsExtension extension2 = new H_C_NotesAndAttachmentsExtension(
			new ApexPages.StandardController(account1));
		//parameters for outgoing links should be other
		String returnUrlFromExtension1 = extension1.noteAndAttachmentWrappers[0]
			.getLinkToView().getParameters().get(H_C_RequestParameters.RETURN_URL);
		String returnUrlFromExtension2 = extension2.noteAndAttachmentWrappers[0]
			.getLinkToView().getParameters().get(H_C_RequestParameters.RETURN_URL);
		System.assertNotEquals(returnUrlFromExtension1, returnUrlFromExtension2);
	}
    //
    
    
    
    
    
    //
    //Unit tests for 'H_C_PaginatorController' class
    //
    @IsTest
	private static void testPaginatorController_properties()
	{
		//initialize a controller
		H_C_PaginatorController controller = new H_C_PaginatorController();
		//check properties
		System.assert(controller.optionsForRecordsPerPage.size() > 0);
		System.assertNotEquals(null, controller.parameters);
		System.assertEquals(String.valueOf(controller.parameters.currentPageNumber),
			controller.selectedPageNumberInString);
		System.assertEquals(null, controller.binderAttribute);
		H_C_PaginationParameters defaultParameters = controller.parameters;
		
		//set a binder
		H_C_PaginationParameters newParameters = new H_C_PaginationParameters(100, 10, 5);
		PaginationManager paginationManager = new PaginationManager(newParameters);
		controller.binderAttribute = paginationManager;
		
		System.assertNotEquals(defaultParameters, controller.parameters);
		System.assertEquals(newParameters, controller.parameters);
		
		//check selectedPageNumberInString
		System.assertEquals(String.valueOf(controller.parameters.currentPageNumber),
			controller.selectedPageNumberInString);
	}
	
	@IsTest
	private static void testPaginatorController_publicMethods()
	{
		//set a page for this test
		PageReference currentPage = Page.H_C_OpenActivities;
		Test.setCurrentPage(currentPage);
		
		//initialize a controller
		H_C_PaginatorController controller = new H_C_PaginatorController();
		//set a binder (we have 105 records, 10 records per page and now we are on 5th page)
		H_C_PaginationParameters newParameters = new H_C_PaginationParameters(105, 10, 5);
		PaginationManager paginationManager = new PaginationManager(newParameters);
		controller.binderAttribute = paginationManager;
		
		//call the methods and check the results:
		//1) go to next page (from 5th to 6th page)
		controller.goToNextPage();
		//controller should have a correct current page number
		System.assertEquals(6, controller.parameters.currentPageNumber);
		//manager has been notified about the change and it should have a correct current page number too
		System.assertEquals(6, paginationManager.parameters.currentPageNumber);
		
		//2) go to previous page (from 6th to 5th page)
		controller.goToPreviousPage();
		//controller should have a correct current page number
		System.assertEquals(5, controller.parameters.currentPageNumber);
		//manager has been notified about the change and it should have a correct current page number too
		System.assertEquals(5, paginationManager.parameters.currentPageNumber);
		
		//3) go to a concrete page via URL-parameters (from 5th to 9th page)
		//set necessary URL-parameters
		currentPage.getParameters().put(H_C_RequestParameters.PAGE_NUMBER, '9');
		controller.goToPage();
		//controller should have a correct current page number
		System.assertEquals(9, controller.parameters.currentPageNumber);
		//manager has been notified about the change and it should have a correct current page number too
		System.assertEquals(9, paginationManager.parameters.currentPageNumber);
		
		//4.1) go to a concrete page via special property (wrong page number)
		controller.selectedPageNumberInString = 'wrong number';
		controller.tryGoToSelectedPage();
		//nothing should be changed
		System.assertEquals(9, controller.parameters.currentPageNumber);
		
		//4.2) go to a concrete page via special property (from 9th to 5th page)
		controller.selectedPageNumberInString = '5';
		controller.tryGoToSelectedPage();
		//controller should have a correct current page number
		System.assertEquals(5, controller.parameters.currentPageNumber);
		//manager has been notified about the change and it should have a correct current page number too
		System.assertEquals(5, paginationManager.parameters.currentPageNumber);
		
		//5) set a new number of records per page
		controller.parameters.numberOfRecordsPerPage = 50;
		controller.applyNumberOfRecordsPerPage();
		//manager should a correct number of records per page
		System.assertEquals(50, paginationManager.parameters.numberOfRecordsPerPage);
		//the current page number should be reset to 1
		System.assertEquals(1, controller.parameters.currentPageNumber);
		//manager has been notified about the change and it should have a correct current page number too
		System.assertEquals(1, paginationManager.parameters.currentPageNumber);
	}
	
	private class PaginationManager implements H_C_PaginatorBinder
	{
		//
		//Contructors
		//
		public PaginationManager(H_C_PaginationParameters initialParameters)
		{
			this.parameters = initialParameters;
		}
		//
		
		//
		//Properties
		//
		public H_C_PaginationParameters parameters {get; private set;}
		//
		
		//
		//Implementation of 'H_C_PaginatorBinder' interface
		//
		public H_C_PaginationParameters getPaginationParameters()
		{
			return this.parameters;
		}
		
		public void setPaginationParameters(H_C_PaginationParameters newParameters)
		{
			this.parameters = newParameters;
		}
		//
	}
    //
}