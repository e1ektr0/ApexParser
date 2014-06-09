@isTest(SeeAllData=true)
public with sharing class MEP_CreateEventPageControllerTest 
{
	@isTest(SeeAllData=true)
	private static void test_MEP_CreateEventPageController()
	{
		MEP_CreateEventPageController controller = new MEP_CreateEventPageController();
		//System.debug(controller.errorMessage);
		MEP_EventDTO events = new MEP_EventDTO();
		controller.event = events;
		System.debug(controller.event);
		controller.reservDateStatus = 'DateStatusTest';
		System.debug(controller.reservDateStatus);
		System.debug(controller.stepNumber);
		
		controller.reservDate();

	}
}