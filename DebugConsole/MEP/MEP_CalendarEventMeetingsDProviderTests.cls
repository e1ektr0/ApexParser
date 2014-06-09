@isTest
private class MEP_CalendarEventMeetingsDProviderTests {

    static testMethod void test_MEP_CalendarEventMeetingsDataProviderBaseFunctions() {
    	MEP_EVENTS__c event = MEP_TestUtils.createTestEvent();
		event.VISIBILITY__c = MEP_EventVisibility.PUBLIC_VISIBILITY;
		event.EVENT_STATE__c = MEP_EventState.SUBMITTED_TO_GATEKEEPERS;
		update event;
		MEP_EVENT_MEETINGS__c meeting = MEP_TestUtils.createTestMeeting(event);
    	MEP_CalendarFilter filter = new MEP_CalendarFilter();
        MEP_CalendarEventMeetingsDataProvider dataProvider = new MEP_CalendarEventMeetingsDataProvider(filter);
    	System.assertEquals(dataProvider.filter,filter);
    	System.assertEquals(dataProvider.getDataList().size(), 1);
    }
}