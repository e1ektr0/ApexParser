global class MEP_ChatterManagerBatch implements Database.Batchable<CollaborationGroupMember>, Database.AllowsCallouts {
	
	global String eventId;
	global List<CollaborationGroupMember> members;
	
	global MEP_ChatterManagerActionType actionType = MEP_ChatterManagerActionType.ASSIGN; 
	global String defaultMemberRole = 'Standard';
	
	public MEP_ChatterManagerBatch(String eventId) {
		this.eventId = eventId;
	}
	
	public MEP_ChatterManagerBatch(String eventId, List<CollaborationGroupMember> members, MEP_ChatterManagerActionType actionType) {
		this.eventId = eventId;
		this.members = members;
		this.actionType = actionType;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
	global Iterable<CollaborationGroupMember> start(Database.BatchableContext BC) {

		String chatterGroupId = null;
		MEP_EVENTS__c event = MEP_EventDAO.getEventById(eventId);
		if (event == null) {
			System.debug('Event not found by event id: ' + eventId);
			return new List<CollaborationGroupMember>();
		}
		
		if (event.ROLLUP_EVENT_START_DATE__c < Datetime.now().addHours(5)) {
			System.debug('Chatter group creation was aborted, because event start date less than current date!');
			return new List<CollaborationGroupMember>();
		}
		//create chatter group
		if (event.SALESFORCE_CHATTER_GROUP_REFERENCE__c == null && members == null) {
			MEP_GroupManager<MEP_EVENTS__c> gm = new MEP_ChatterGroupEventManagerImpl();
			chatterGroupId = gm.createGroup(event);
			if (chatterGroupId != null) {
				event.SALESFORCE_CHATTER_GROUP_REFERENCE__c = chatterGroupId;
			 	MEP_SoqlUtils.performDmlOperation(MEP_DmlOperation.Updating, event);
				
			} else {
				System.debug('Chatter group creation was aborted!');
				System.abortJob(BC.getJobId());
				return new List<CollaborationGroupMember>();
			}
			
		} else if (event.SALESFORCE_CHATTER_GROUP_REFERENCE__c != null) {
			chatterGroupId = event.SALESFORCE_CHATTER_GROUP_REFERENCE__c;
		}
		
		//get all users that assigned to event
		//List<CollaborationGroupMember> members = new List<CollaborationGroupMember>();
		if (members == null && chatterGroupId != null) {
			members = new List<CollaborationGroupMember>();
			MEP_EVENT_MEETINGS__c[] meetings = MEP_EventMeetingDAO.getEventMeetingsByEventId(eventId);
	       	for (MEP_EVENT_MEETINGS__c meeting : meetings) {
	       		//get speakers for meeting
	       		MEP_EVENT_MEETING_SPEAKERS__c[] speakers = MEP_EventMeetingSpeakerMappingDAO.getMappingsByEventMeetingId(meeting.Id);
	       		for (MEP_EVENT_MEETING_SPEAKERS__c speaker : speakers) {
	       			if (speaker.SPEAKER__r.SALESFORCE_CHATTER_USER_REFERENCE__c != null) {
	       				members.add(createGroupMember(speaker.SPEAKER__r.SALESFORCE_CHATTER_USER_REFERENCE__c, chatterGroupId, defaultMemberRole));
	       			}
	       			/*
	       			//get gatekeepers for speaker
	       			MEP_USERS__c[] gatekeepers = MEP_MepUserDAO.getGatekeepersForChannel(speaker.SPEAKER_CHANNEL__c);
	       			for (MEP_USERS__c gatekeeper : gatekeepers) {
	       				if (gatekeeper.SALESFORCE_CHATTER_USER_REFERENCE__c != null) {
		       				members.add(createGroupMember(gatekeeper.SALESFORCE_CHATTER_USER_REFERENCE__c, chatterGroupId, 'Admin'));
	       				} 
	       			}*/
	       			
	       			
	       			//get gatekeepers and approvers for meeting
	       			MEP_USER_CHANNEL_ROLE_MAPPINGS__c[] users = MEP_UserChannelRoleMappingDAO.getMappingsByChannelAndRoles(speaker.SPEAKER_CHANNEL__c, new String[] { MEP_RoleKey.GATEKEEPER, MEP_RoleKey.APPROVER }, true);
	       			
	       			if (users != null) {
	       				Map<String, CollaborationGroupMember> posibleMembers= new Map<String, CollaborationGroupMember>();
	       				for (MEP_USER_CHANNEL_ROLE_MAPPINGS__c user : users) {
	       					if (user.USER__r.SALESFORCE_CHATTER_USER_REFERENCE__c != null) {
		       					if (user.ROLE__r.KEY__c == MEP_RoleKey.GATEKEEPER) {
		       						posibleMembers.put(user.Id, createGroupMember(user.USER__r.SALESFORCE_CHATTER_USER_REFERENCE__c, chatterGroupId, 'Admin'));
		       					} else {
		       						posibleMembers.put(user.Id, createGroupMember(user.USER__r.SALESFORCE_CHATTER_USER_REFERENCE__c, chatterGroupId, defaultMemberRole));
		       					}
	       					}
	       				}
	       				if (posibleMembers.size() != 0) {
	       					members.addAll(posibleMembers.values());
	       				}
	       			}
	       		}
				
				
	       		//get attendees for meeting
	       		MEP_EVENT_MEETING_ATTENDEES__c[] attendees = MEP_EventMeetingAttendeeDAO.getAttendeesByEventMeetingId(meeting.Id);
	       		for (MEP_EVENT_MEETING_ATTENDEES__c attendee : attendees) {
	       			if (attendee.ATTENDEE_USER_REFERENCE__r.SALESFORCE_CHATTER_USER_REFERENCE__c != null) {
	       				members.add(createGroupMember(attendee.ATTENDEE_USER_REFERENCE__r.SALESFORCE_CHATTER_USER_REFERENCE__c, chatterGroupId, defaultMemberRole));
	       			}
	       		}
	       	}
	       	
	       	//get BEHALF OF user
	       	if (event.REQUESTED_ON_BEHALF_OF__c != null) {
	       		MEP_USERS__c u = MEP_MepUserDAO.getMepUserById(event.REQUESTED_ON_BEHALF_OF__c);
	       		if (u.SALESFORCE_CHATTER_USER_REFERENCE__c != null) {
					members.add(createGroupMember(u.SALESFORCE_CHATTER_USER_REFERENCE__c, chatterGroupId, defaultMemberRole));
	       		}
	       	}
	       	
	       	//get all tasks for event
	       	MEP_TASKS__c[] tasks = MEP_TaskDAO.getTasksByEventId(eventId);
	       	for (MEP_TASKS__c task : tasks) {
	       		if (task.ASSIGNED_TO_USER__r.SALESFORCE_CHATTER_USER_REFERENCE__c != null) {
	       			members.add(createGroupMember(task.ASSIGNED_TO_USER__r.SALESFORCE_CHATTER_USER_REFERENCE__c, chatterGroupId, defaultMemberRole));
	   			}
	       	}
	       	
	       	/*
	       	//get approver for event
	       	if (event.DISTRIBUTION_CHANNEL_APPROVED_BY_USER__c != null) {
	   			if (event.DISTRIBUTION_CHANNEL_APPROVED_BY_USER__r.SALESFORCE_CHATTER_USER_REFERENCE__c != null) {
	   				members.add(createGroupMember(event.DISTRIBUTION_CHANNEL_APPROVED_BY_USER__r.SALESFORCE_CHATTER_USER_REFERENCE__c, chatterGroupId, defaultMemberRole));
	   			}
	       	}*/
	       	
		} else if (chatterGroupId != null) {
			for (CollaborationGroupMember member: members) {
				if (member.CollaborationRole == null) {
					member.CollaborationRole = defaultMemberRole;
				}
				
				if (member.CollaborationGroupId == null) {
					member.CollaborationGroupId = chatterGroupId;
				}
			}
		}
		
		return members;
		
	}
	
	global void execute(Database.BatchableContext BC, List<CollaborationGroupMember> members) {
		MEP_GroupManager<MEP_EVENTS__c> gm = new MEP_ChatterGroupEventManagerImpl();
		for (CollaborationGroupMember member : members) {
			if (actionType == MEP_ChatterManagerActionType.ASSIGN) {
				gm.assignPerson(member);
			} else {
				gm.unassignPerson(member.CollaborationGroupId, member.MemberId);
			}
			
		}
	}
	
	
	
	global CollaborationGroupMember createGroupMember(String chatterUserId, String chatterGroupId, String chatterUserRole) {
		CollaborationGroupMember m = new CollaborationGroupMember();
		m.CollaborationGroupId = chatterGroupId;
		m.MemberId = chatterUserId;
		m.CollaborationRole = chatterUserRole;
		return m;
	}

}