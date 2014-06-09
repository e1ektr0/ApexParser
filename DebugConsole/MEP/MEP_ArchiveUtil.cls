/**
 Utiliy class for Archiving different entities 
 Author: DLuzyanov
**/
public with sharing class MEP_ArchiveUtil {

	/*
	  Archive event and associated entities
	*/
	public static void archiveEvent(MEP_EVENTS__c event) {
		 event.INT_ROW_IS_ARCHIVED__c = true;
		  //archiving chatter groups
		 new MEP_AdminUtils().archiveGroupForEvent(event.id);
         MEP_SoqlUtils.performDmlOperation(MEP_DmlOperation.Updating, event);
         // archiving meetings
         MEP_EventMeetingDAO.archiveEventMeetings(event.id);
         // archiving activities
       	 MEP_PostEventActivityDAO.archiveEventActivity(event.id);
         // archiving view states of an event
         MEP_EventViewStateDAO.archiveEventViewStates(event.id);
         // archiving tasks for this event
         MEP_TaskDAO.archivingTaskForEvent(event.id);
        
	}	
	
	public static void archiveMeeting(MEP_EVENT_MEETINGS__c meeting) {
		//archive event speakers mapping
		MEP_EventMeetingSpeakerMappingDAO.archiveEventMeetingSpeakers(meeting.id);
		//arcive event attendies mapping
		MEP_EventMeetingAttendeeDAO.archiveEventMeetingMapping(meeting.id);
	}
}