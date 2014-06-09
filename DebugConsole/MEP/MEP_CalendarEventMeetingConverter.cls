public with sharing class MEP_CalendarEventMeetingConverter implements MEP_Converter<MEP_CalendarEventMeetingDTO, MEP_EVENT_MEETINGS__c>
{
	//
	//Private methods
	//
	public static String getCssClassName(String meetingType)
	{
		if (meetingType == null || meetingType =='')
		{
			return 'meeting-type-default'; 
		}
		
		return 'meeting-type-' + meetingType.replace(' ', '-').toLowerCase();
	}
	//
	
	//
	//Public methods
	//
	//implementation of 'MEP_Converter' interface
	public MEP_CalendarEventMeetingDTO convertToDTO(MEP_EVENT_MEETINGS__c databaseMeeting)
	{
		if (databaseMeeting == null)
		{
			return null;
		}
		
		MEP_CalendarEventMeetingDTO convertedMeeting = new MEP_CalendarEventMeetingDTO();
		
		convertedMeeting.id = databaseMeeting.Id;
		//get and convert datetime values 
		convertedMeeting.startDate = MEP_DateTimeUtils.convertDateTimeFromGmt(
			databaseMeeting.MEETING_START_DATE__c, MEP_DateTimeUtils.DEFAULT_TIME_ZONE);
		convertedMeeting.endDate = MEP_DateTimeUtils.convertDateTimeFromGmt(
			databaseMeeting.MEETING_END_DATE__c, MEP_DateTimeUtils.DEFAULT_TIME_ZONE);
		convertedMeeting.formattedDateTimeRange = MEP_DateTimeUtils.formatDateTimeRange(
			databaseMeeting.MEETING_START_DATE__c, databaseMeeting.MEETING_END_DATE__c, MEP_DateTimeUtils.DEFAULT_TIME_ZONE);
		
		convertedMeeting.eventId = databaseMeeting.MEP_EVENT_REFERENCE__c;
		convertedMeeting.eventType = databaseMeeting.MEP_EVENT_REFERENCE__r.EVENT_TYPE__c;
		convertedMeeting.eventVisibility = databaseMeeting.MEP_EVENT_REFERENCE__r.VISIBILITY__c;
		
		if (databaseMeeting.MEP_EVENT_REFERENCE__r.VISIBILITY__c == MEP_EventVisibility.PRIVATE_VISIBILITY)
		{
			convertedMeeting.eventName = 'Private event';
			convertedMeeting.meetingName = 'Private meeting';
			if (convertedMeeting.eventType != MEP_EventType.QUARTERLY_EVENT)
			{
				convertedMeeting.formattedLocation = 'Private location';
			}
		}
		else
		{
			convertedMeeting.meetingName = databaseMeeting.MEETING_NAME__c;
			convertedMeeting.eventName = databaseMeeting.MEP_EVENT_REFERENCE__r.EVENT_NAME__c;
			//according to TA115 we shouldn't show location information for Quarterly Events
			if (convertedMeeting.eventType != MEP_EventType.QUARTERLY_EVENT)
			{
				convertedMeeting.location = new MEP_LocationDTO();
				convertedMeeting.location.address1 = databaseMeeting.MEETING_LOCATION_ADDRESS_1__c;
				convertedMeeting.location.address2 = databaseMeeting.MEETING_LOCATION_ADDRESS_2__c;
				convertedMeeting.location.city = databaseMeeting.MEETING_LOCATION_CITY__c;
				convertedMeeting.location.country = databaseMeeting.MEETING_LOCATION_COUNTRY__c;
				convertedMeeting.location.room = databaseMeeting.MEETING_LOCATION_ROOM__c;
				convertedMeeting.location.state = databaseMeeting.MEETING_LOCATION_STATE__c;
				convertedMeeting.location.zipCode = databaseMeeting.MEETING_LOCATION_ZIP_CODE__c;
				convertedMeeting.formattedLocation = convertedMeeting.location.getFormattedLocation();
			}
		}
		
		convertedMeeting.cssClassName = getCssClassName(databaseMeeting.MEETING_TYPE__c);
		convertedMeeting.allDay = false;
		
		return convertedMeeting;
	}
	
	public List<MEP_CalendarEventMeetingDTO> convertToDTO(List<MEP_EVENT_MEETINGS__c> databaseMeetings)
	{
		if (databaseMeetings == null)
		{
			return null;
		}
		
		List<MEP_CalendarEventMeetingDTO> convertedMeetings = new List<MEP_CalendarEventMeetingDTO>();
		for (MEP_EVENT_MEETINGS__c meeting : databaseMeetings)
		{
			convertedMeetings.add(this.convertToDTO(meeting));
		}
		
		return convertedMeetings;
	}
	
}