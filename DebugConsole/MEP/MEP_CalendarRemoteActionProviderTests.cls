@isTest
private class MEP_CalendarRemoteActionProviderTests {
    static testMethod void test_getCalendarEvents() {
        MEP_EventMeetingCalendarController controller = new MEP_EventMeetingCalendarController();
        MEP_CalendarRemoteActionProvider remoteActionProvaider = new MEP_CalendarRemoteActionProvider(controller);
        MEP_TestUtils.Autorize(MEP_RoleKey.APPROVER);
        MEP_EVENT_MEETINGS__c meeting =MEP_TestUtils.createTestMeeting();    	 
	 	MEP_TestUtils.createTestMeetingSpeaker(meeting);
		System.assert(MEP_CalendarRemoteActionProvider.getSpeakers(meeting.Id).size()>0);
	}
 	static testMethod void test_getSpeakers() {
 	 	MEP_EventMeetingCalendarController controller = new MEP_EventMeetingCalendarController();
        MEP_CalendarRemoteActionProvider remoteActionProvaider = new MEP_CalendarRemoteActionProvider(controller);
        MEP_TestUtils.Autorize(MEP_RoleKey.APPROVER);
        System.assert(MEP_CalendarRemoteActionProvider.getCalendarEvents(controller.serializedFilter)!=null);
 	}	
 	static testMethod void test_RemoteAction_getCalendarEvents()
	{
		MEP_EVENTS__c event = MEP_TestUtils.createTestEvent();
		event.VISIBILITY__c = MEP_EventVisibility.PUBLIC_VISIBILITY;
		event.EVENT_STATE__c = MEP_EventState.SUBMITTED_TO_GATEKEEPERS;
		update event;
		MEP_EVENT_MEETINGS__c meeting = MEP_TestUtils.createTestMeeting(event);
		MEP_CalendarFilter filter=new MEP_CalendarFilter();
		System.assertEquals(MEP_CalendarRemoteActionProvider.getCalendarEvents(Json.serialize(filter)).size(),1);
				
	}
	static testMethod void test_RemoteAction_getSpeakers()
	{
		MEP_EVENTS__c event = MEP_TestUtils.createTestEvent();
		event.VISIBILITY__c = MEP_EventVisibility.PUBLIC_VISIBILITY;
		update event;
		MEP_EVENT_MEETINGS__c meeting = MEP_TestUtils.createTestMeeting(event);
		MEP_TestUtils.createTestMeetingSpeaker(meeting);
		MEP_CalendarFilter filter=new MEP_CalendarFilter();
		System.assertEquals(MEP_CalendarRemoteActionProvider.getSpeakers(meeting.id).size(),1);	
		event.VISIBILITY__c = MEP_EventVisibility.PRIVATE_VISIBILITY;
		update event;
		System.assertEquals(MEP_CalendarRemoteActionProvider.getSpeakers(meeting.id),null);		
	}
}