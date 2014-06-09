@isTest
private class MEP_CalendarEventMeetingConverterTests {

	private static testMethod void test_getCssClassName()
	{
		System.assertEquals('meeting-type-default', MEP_CalendarEventMeetingConverter.getCssClassName(null));
		
		for (String meetingType : MEP_EventMeetingType.ALL_TYPES)
		{
			System.debug(MEP_CalendarEventMeetingConverter.getCssClassName(meetingType));
		}
	}
	
	private static testMethod void  test_convertToDTONullParams()
    {
    	MEP_CalendarEventMeetingConverter converter = new MEP_CalendarEventMeetingConverter();
    	MEP_EVENT_MEETINGS__c meeting = null;
    	System.assertEquals(null, converter.convertToDTO(meeting));
    	
    	MEP_EVENT_MEETINGS__c[] listOfMeetings = null;
    	System.assertEquals(null, converter.convertToDTO(listOfMeetings));
    }
    private static void test_MeetingConvert(MEP_CalendarEventMeetingDTO meetingDTO, MEP_EVENT_MEETINGS__c meeting)
    {
    	System.assertEquals(meetingDTO.id, meeting.Id);    	
    	System.assertEquals(meetingDTO.cssClassName, MEP_CalendarEventMeetingConverter.getCssClassName(meeting.MEETING_TYPE__c));
    	if(meeting.MEP_EVENT_REFERENCE__r.VISIBILITY__c ==MEP_EventVisibility.PUBLIC_VISIBILITY)
	    	//assert if event.VISIBILITY__c = MEP_EventVisibility.PUBLIC_VISIBILITY;
	    	System.assertEquals(meetingDTO.meetingName, meeting.MEETING_NAME__c);
    	else if(meeting.MEP_EVENT_REFERENCE__r.VISIBILITY__c==MEP_EventVisibility.PRIVATE_VISIBILITY)
	    	//assert if event.VISIBILITY__c = MEP_EventVisibility.PRIVATE_VISIBILITY;
	    	System.assertEquals(meetingDTO.meetingName, 'Private meeting');    	
    }
    private static MEP_EVENT_MEETINGS__c createTestMeeting(String eventVisibility)
    {
    	MEP_EVENTS__c event = MEP_TestUtils.createTestEvent();
		event.VISIBILITY__c =eventVisibility;
		update event;
		MEP_TestUtils.createTestMeeting(event);
		
		MEP_SoqlQueryBuilder queryBuilder = new MEP_SoqlQueryBuilder(MEP_EventMeetingDAO.FIELDS_FOR_CALENDAR,'MEP_EVENT_MEETINGS__c');
        MEP_EVENT_MEETINGS__c meeting =	(MEP_EVENT_MEETINGS__c)MEP_SoqlUtils.performSingleResultQuery(queryBuilder);
        return meeting;
    }
    private static testMethod void test_convertToDTOSingleObject()
    {
    	MEP_CalendarEventMeetingConverter converter = new MEP_CalendarEventMeetingConverter(); 
    	
    	MEP_EVENT_MEETINGS__c meeting=createTestMeeting(MEP_EventVisibility.PUBLIC_VISIBILITY);
    	MEP_CalendarEventMeetingDTO meetingDTO= converter.convertToDTO(meeting);
    	test_MeetingConvert(meetingDTO,meeting);
    	
    	meeting=createTestMeeting(MEP_EventVisibility.PRIVATE_VISIBILITY);
    	meetingDTO= converter.convertToDTO(meeting);
    	test_MeetingConvert(meetingDTO,meeting);
    }
    
    
    private static testMethod void test_convertToDTOList()
    {
    	MEP_CalendarEventMeetingConverter converter = new MEP_CalendarEventMeetingConverter();
    	MEP_EVENT_MEETINGS__c meeting=createTestMeeting(MEP_EventVisibility.PUBLIC_VISIBILITY);
    	List<MEP_CalendarEventMeetingDTO> listDTO= converter.convertToDTO(new MEP_EVENT_MEETINGS__c[]{meeting});
    	test_MeetingConvert(listDTO[0],meeting);    		
    }
}