@isTest
private class MEP_ArchiveUtilTests {
	public static testMethod void test_archiveEvent() {
		MEP_HttpUtils.testResponsesCollection.add(MEP_TestUtils.createAutorizeResponse());
		MEP_EVENTS__c event = MEP_TestUtils.createTestEvent();
		MEP_ArchiveUtil.archiveEvent(event);
		System.assert(event.INT_ROW_IS_ARCHIVED__c == true);
	}
	
	public static testMethod void test_archiveMeeting() {
		MEP_EVENTS__c event = MEP_TestUtils.createTestEvent();
		MEP_EVENT_MEETINGS__c meeting = MEP_TestUtils.createTestMeeting(event);
		MEP_HttpUtils.testResponsesCollection.add(MEP_TestUtils.createAutorizeResponse());
   	  	MEP_HttpUtils.testResponsesCollection.add(MEP_TestUtils.createAutorizeResponse());
		MEP_TestUtils.createTestMeetingSpeaker(meeting);
		MEP_ArchiveUtil.archiveEvent(event);
		MEP_ArchiveUtil.archiveMeeting(meeting);
		System.assert(event.INT_ROW_IS_ARCHIVED__c == true);
	}
}