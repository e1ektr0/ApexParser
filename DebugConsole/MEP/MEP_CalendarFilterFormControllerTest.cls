@isTest
public with sharing class MEP_CalendarFilterFormControllerTest 
{
	private static MEP_EVENT_MEETINGS__c createTestMeeting()
    {
    	MEP_EVENTS__c event = MEP_TestUtils.createTestEvent();
		event.VISIBILITY__c =MEP_EventVisibility.PUBLIC_VISIBILITY;
		update event;
		MEP_TestUtils.createTestMeeting(event);
		
		MEP_SoqlQueryBuilder queryBuilder = new MEP_SoqlQueryBuilder(MEP_EventMeetingDAO.FIELDS_FOR_CALENDAR,'MEP_EVENT_MEETINGS__c');
        MEP_EVENT_MEETINGS__c meeting =	(MEP_EVENT_MEETINGS__c)MEP_SoqlUtils.performSingleResultQuery(queryBuilder);
        insert meeting;
        return meeting;
        
    }
	
	private static testMethod void test_MEP_CalendarFilterFormControllerBaseFunctions()
	{
		MEP_TestUtils.createTestChannel();
		MEP_CalendarFilterFormController controller = new MEP_CalendarFilterFormController();
		System.assertEquals(controller.getChannels().size(),2);
		System.assert(controller.listOfEventsViews.size()>0);
		System.assert(controller.listOfEventTypes.size()>0);
		controller.searchPattern = 'Test';
		controller.filter = new MEP_CalendarFilter();
		controller.applyFilter();
		System.assertEquals(controller.searchPattern, controller.filter.searchPattern);
		System.assertEquals(controller.filter.eventType, null);
		System.assertEquals(controller.filter.speakers, null);
		controller.selectedEventType = 'eventType';
		controller.selectedSpeakersIds='id,id2';
		controller.applyFilter();
		System.assertEquals(controller.filter.eventType, 'eventType');
		System.assertEquals(controller.filter.speakers.size(), 2);
		controller.clearFilter();
		System.assertEquals(controller.filter.eventType, null);
		System.assertEquals(controller.filter.speakers, null);
	}
	
}