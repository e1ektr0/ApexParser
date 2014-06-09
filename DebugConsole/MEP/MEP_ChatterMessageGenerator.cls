//
//This class contains static methods which create chatter messages for a different situations
//(all messages should be created here, but not elsewhere in the system)
//
//Author: Gennadiy Pervukhin
public with sharing class MEP_ChatterMessageGenerator
{
	//
	//Public static methods
	//
	public static String createMessage_SpeakerApproved(String gatekeeperFullName,
		String speakerFullName, String meetingName)
	{
		if (MEP_StringUtils.isNullOrEmpty(gatekeeperFullName)
			|| MEP_StringUtils.isNullOrEmpty(speakerFullName)
			|| MEP_StringUtils.isNullOrEmpty(meetingName))
		{
			return null;
		}
		
		//@LoggedInUser(FULL_NAME__c) Approved "Corresponding Row Speaker(FULL_NAME__C)"
		//of "[Meeting Name]"
		String messageText = MEP_ChatterFeedUtils.createChatterUserLink(gatekeeperFullName)
			+ ' approved ' + speakerFullName + ' of \'' + meetingName + '\'';
		
		return messageText;
	}
	
	public static String createMessage_SpeakerDeclined(String gatekeeperFullName,
		String speakerFullName, String meetingName, String decliningReason)
	{
		if (MEP_StringUtils.isNullOrEmpty(gatekeeperFullName)
			|| MEP_StringUtils.isNullOrEmpty(speakerFullName)
			|| MEP_StringUtils.isNullOrEmpty(meetingName))
		{
			return null;
		}
		
		//@LoggedInUser(FULL_NAME__c) Rejected "Corresponding Row Speaker(FULL_NAME__C)"
		//of "[Meeting Name"] for textbox.text
		String messageText = MEP_ChatterFeedUtils.createChatterUserLink(gatekeeperFullName)
			+ ' rejected ' + speakerFullName + ' of \'' + meetingName + '\'';
		if (!MEP_StringUtils.isNullOrEmpty(decliningReason))
		{
			messageText += ' for ' + decliningReason;
		}
		
		return messageText;
	}
	
	public static String createMessage_EventCancelledByRequestor(String requestorFullName,
		String eventName)
	{
		if (MEP_StringUtils.isNullOrEmpty(requestorFullName) || MEP_StringUtils.isNullOrEmpty(eventName))
		{
			return null;
		}
		
		//@LoggedInUser(FULL_NAME__c) Cancelled the event "[Event Name]"
		String messageText = MEP_ChatterFeedUtils.createChatterUserLink(requestorFullName)
			+ ' cancelled the event \'' + eventName + '\'';		
		
		return messageText;
	}
	
	public static String createMessage_EventSubmittedForApprovals(String requestorFullName,
		String eventName)
	{
		if (MEP_StringUtils.isNullOrEmpty(requestorFullName) || MEP_StringUtils.isNullOrEmpty(eventName))
		{
			return null;
		}
		
		//@LoggedInUser(FULL_NAME__c) Submitted the event "[Event Name]" for Approvals
		String messageText = MEP_ChatterFeedUtils.createChatterUserLink(requestorFullName)
			+ ' submitted the event \'' + eventName + '\' for approvals';		
		
		return messageText;
	}
	
	public static String createMessage_EventReSubmittedToGatekeepers(String requestorFullName,
		String eventName)
	{
		if (MEP_StringUtils.isNullOrEmpty(requestorFullName) || MEP_StringUtils.isNullOrEmpty(eventName))
		{
			return null;
		}
		
		//@LoggedInUser(FULL_NAME__c) re-submitted the event "[Event Name]" to gatekeepers
		String messageText = MEP_ChatterFeedUtils.createChatterUserLink(requestorFullName)
			+ ' re-submitted the event \'' + eventName + '\' to gatekeepers';		
		
		return messageText;
	}
	
	public static String createMessage_EventApprovedBySystem(String eventName)
	{
		if (MEP_StringUtils.isNullOrEmpty(eventName))
		{
			return null;
		}
		
		//Submitted event "[Event Name]" was Auto-Approved (Channel)
		String messageText = 'Submitted event \'' + eventName + '\' was auto-approved (channel)';
		
		return messageText;
	}
	
	public static String createMessage_EventApprovedByApprover(String approverFullName, String eventName)
	{
		if (MEP_StringUtils.isNullOrEmpty(approverFullName)
			|| MEP_StringUtils.isNullOrEmpty(eventName))
		{
			return null;
		}
		
		//@LoggedInUser(FULL_NAME__c) Approved (Channel) the event "[Event Name]"
		String messageText = MEP_ChatterFeedUtils.createChatterUserLink(approverFullName)
			+ ' approved (channel) the event \'' + eventName + '\'';		
		
		return messageText;
	}
	
	public static String createMessage_EventRejectedByApprover(
		String approverFullName, String eventName)
	{
		if (MEP_StringUtils.isNullOrEmpty(approverFullName)
			|| MEP_StringUtils.isNullOrEmpty(eventName))
		{
			return null;
		}
		
		//@LoggedInUser(FULL_NAME__c) Rejected (Channel) the event "[Event Name]"
		String messageText = MEP_ChatterFeedUtils.createChatterUserLink(approverFullName)
			+ ' rejected (channel) the event \'' + eventName + '\'';		
		
		return messageText;
	}
	
	public static String createMessage_EventCompleted(String eventName)
	{
		if (MEP_StringUtils.isNullOrEmpty(eventName))
		{
			return null;
		}
		
		//The Event "Event Name" is completed
		String messageText = 'The event \'' + eventName + '\' is completed';
		return messageText;
	}
	
	public static String createMessage_EventStateChanged(String eventName,
		String previousEventState, String currentEventState)
	{
		if (MEP_StringUtils.isNullOrEmpty(eventName) || MEP_StringUtils.isNullOrEmpty(previousEventState)
			|| MEP_StringUtils.isNullOrEmpty(currentEventState))
		{
			return null;
		}
		
		//The state of the event 'Event Name" has been changed from
		//"the previous state" to "the current state"
		String messageText = 'The state of the event \'' + eventName + '\' has been changed from \''
			+ previousEventState + '\' to \'' + currentEventState + '\'';
		return messageText;
	}
	
	public static String createMessage_EventArchived(String eventName)
	{
		if (MEP_StringUtils.isNullOrEmpty(eventName))
		{
			return null;
		}
		
		//The Event "Event Name" is going to get archived.
		String messageText = 'The event \'' + eventName + '\' is going to get archived';
		return messageText;
	}
	
	public static String createMessage_EventPushedBackToRequestor(String initiatorFullName,
		String eventName, String requestorFullName)
	{
		if (MEP_StringUtils.isNullOrEmpty(initiatorFullName)
			|| MEP_StringUtils.isNullOrEmpty(eventName)
			|| MEP_StringUtils.isNullOrEmpty(requestorFullName))
		{
			return null;
		}
		
		//@LoggedInUser(FULL_NAME__c) pushed the event "Event Name" back to the Requestor "REQUESTED_BY_USER__c"
		String messageText = MEP_ChatterFeedUtils.createChatterUserLink(initiatorFullName)
			+ ' pushed the event \'' + eventName + '\' back to the requestor '
			+ MEP_ChatterFeedUtils.createChatterUserLink(requestorFullName);
		
		return messageText;
	}
	
	public static String createMessage_TaskAssigned(String taskOwnerFullName,
		String taskName, DateTime taskDueDate)
	{
		if (MEP_StringUtils.isNullOrEmpty(taskOwnerFullName)
			|| MEP_StringUtils.isNullOrEmpty(taskName) || taskDueDate == null)
		{
			return null;
		}
		
		//@"ASSIGNED_TO_USER__c", You have a new Task "TASK_NAME__c" due on DUE_DATE__c
		String messageText = MEP_ChatterFeedUtils.createChatterUserLink(taskOwnerFullName)
			+ ' has got a new task \'' + taskName + '\' on ' + taskDueDate;
		return messageText;
	}
	
	public static String createMessage_TaskReassigned(String taskOwnerFullName,
		String taskName, String gatekeeperFullName)
	{
		if (MEP_StringUtils.isNullOrEmpty(taskOwnerFullName)
			|| MEP_StringUtils.isNullOrEmpty(taskName)
			|| MEP_StringUtils.isNullOrEmpty(gatekeeperFullName))
		{
			return null;
		}
		
		//Task "TASK_NAME__c" was re-assigned to "ASSIGNED_TO_USER__c" by @LoggedInUser(FULL_NAME__c)
		String messageText = 'Task \'' + taskName + '\' was re-assigned to '
			+ MEP_ChatterFeedUtils.createChatterUserLink(taskOwnerFullName) + ' by '
			+ MEP_ChatterFeedUtils.createChatterUserLink(gatekeeperFullName);
		return messageText;
	}
	
	public static String createMessage_TaskCompleted(String taskOwnerFullName, String taskName)
	{
		if (MEP_StringUtils.isNullOrEmpty(taskOwnerFullName) || MEP_StringUtils.isNullOrEmpty(taskName))
		{
			return null;
		}
		
		//"ASSIGNED_TO_USER__c" completed the task "TASK_NAME__c"
		String messageText = MEP_ChatterFeedUtils.createChatterUserLink(taskOwnerFullName)
			+ ' completed the task \'' + taskName + '\'';
		return messageText;
	}
	
	public static String createMessage_TaskCancelled(String gatekeeperFullName, String taskName)
	{
		if (MEP_StringUtils.isNullOrEmpty(gatekeeperFullName) || MEP_StringUtils.isNullOrEmpty(taskName))
		{
			return null;
		}
		
		//@LoggedInUser(FULL_NAME__c) cancelled the Task "TASK_NAME__c"
		String messageText = MEP_ChatterFeedUtils.createChatterUserLink(gatekeeperFullName)
			+ ' cancelled the task \'' + taskName + '\'';
		return messageText;
	}
	
	public static String createMessage_TaskForceClosed(String taskName,
		String taskOwnerFullName, String taskStatus)
	{
		if (MEP_StringUtils.isNullOrEmpty(taskName)
			|| MEP_StringUtils.isNullOrEmpty(taskOwnerFullName)
			|| MEP_StringUtils.isNullOrEmpty(taskStatus))
		{
			return null;
		}
		
		//Systemforce closed the Task "TASK_NAME__c" assigned to "ASSIGNED_TO_USER__c"
		//which was in the state of STATUS__c
		String messageText = 'System force closed the task \'' + taskName + ' assigned to '
			+ MEP_ChatterFeedUtils.createChatterUserLink(taskOwnerFullName)
			+ ' which was in the state of ' + taskStatus;
		return messageText;
	}
	
	public static String createMessage_RemindAboutReservedDate(MEP_EventDTO event)
	{
		if (event == null || MEP_StringUtils.isNullOrEmpty(event.chatterGroupId)
			|| !event.isReservDate)
		{
			return null;
		}
		
		//This event is marked with Reserve the date, there are only (Event.ROLLUP_EVENT_START_DATE__c -
		//CurrentDate) days for the event to happen. Please confirm the event.
		String messageText = 'This event is marked with Reserve the date, there are only '
			+ (Date.today().daysBetween(event.startDate.date()))
			+ ' days for the event to happen. Please confirm the event.';
		return messageText;
	}
	//
	
	
}