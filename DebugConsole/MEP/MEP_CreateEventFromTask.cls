/*
*	Author: SLegostaev
*/
public with sharing class MEP_CreateEventFromTask {
	
	private static Task task;
	
	public static MEP_EVENTS__c createEventFromTask(Task newTask) {
		task = newTask;
		if (task != null) {
            if (task.MEP_Event_Id__c == null) {
                String sfUserId = Userinfo.getUserId();
                MEP_USERS__c mepUser = MEP_MepUserDAO.getMepUserByUserId(sfUserId);
                if (mepUser != null) {
                    MEP_EVENTS__c newEvent = createEvent(mepUser.Id);
                    createEventMeeting(newEvent.Id, null);
                    task.MEP_Event_Id__c = newEvent.Id;
                    return newEvent;
                } else {
                     //System.debug('WARNING! Mep user not found, MEP event has not been created!');
                     throw new MEP_Exception('You are not activated as a MEP user. Please contact mep-help@fmr.com for assistance.');
                }
            } else {
            	throw new MEP_Exception('Event already exists!');
                //System.debug('Event already exists!');
            }
    	} else {
    		throw new MEP_Exception('Task not found!');
    		//System.debug('Task not found!');
    	}
    	return null;
	}
	
	public static void updateEvent(Task newTask) {
		task = newTask;
		if (newTask.MEP_Event_Id__c != null) {
			MEP_EVENTS__c mepEvent = MEP_EventDAO.getEventById(newTask.MEP_Event_Id__c);
			if (mepEvent != null && mepEvent.EVENT_STATE__c == MEP_EventState.DRAFT) {
				
				MEP_EVENT_MEETINGS__c[] meetings = MEP_EventMeetingDAO.getEventMeetingsByEventId(mepEvent.Id);
				for (MEP_EVENT_MEETINGS__c meeting: meetings) {
					if (meeting.MEETING_NAME__c == mepEvent.EVENT_NAME__c) {
						createEventMeeting(null, meeting);
						break;
					}
				}
				
				mepEvent.EVENT_NAME__c = newTask.Subject;
				update mepEvent;
			}
		}
	}
	
	private static MEP_EVENTS__c createEvent(String mepUserId) {
        MEP_EVENTS__c mepEvent = new MEP_EVENTS__c();
        mepEvent.EVENT_NAME__c = task.subject;
        mepEvent.REQUESTED_BY_USER__c = mepUserId;
        mepEvent.EVENT_STATE__c = 'Draft';
        mepEvent.EVENT_TYPE__c = 'Regular Event';
        MEP_Validators.eventFromTaskValidate(mepEvent);
        MEP_SoqlUtils.performDmlOperation(MEP_DmlOperation.Inserting, mepEvent);
        return mepEvent;
    }
    
    private static MEP_EVENT_MEETINGS__c createEventMeeting(String eventId, MEP_EVENT_MEETINGS__c meeting) {
    	
    	//for new meeting
    	if (meeting == null) {
    		meeting = new MEP_EVENT_MEETINGS__c();
    		meeting.MEP_EVENT_REFERENCE__c = eventId;
    	}
    	
    	//for new meeting or changed meeting 
        meeting.MEETING_NAME__c = task.subject;
        meeting.MEETING_TYPE__c = MEP_EventMeetingType.OTHER;
        meeting.MEETING_DETAILS_REASON__c = task.Description;
        meeting.MEETING_PURPOSE__c = getMeetingPurposeFromTask();
        
        if (task.Account.Total_Client_IM_Assets__c != null || task.Account.PGA_Account_Type__c != null || task.Account.Name != null) {
        	//if job was runnig from page
        	meeting.CLIENT_COMPANY_NAME__c = task.Account.Name;
        	setMeetingAssets(meeting, task.Account.Total_Client_IM_Assets__c);
	        setClientType(meeting, task.Account.PGA_Account_Type__c);
        } else {
        	//if job was runnig from trigger
        	try {
        		Account acc = [select Name, Total_Client_IM_Assets__c, PGA_Account_Type__c from Account where Id = :task.AccountId];
        		meeting.CLIENT_COMPANY_NAME__c = acc.Name;
        		setMeetingAssets(meeting, acc.Total_Client_IM_Assets__c);
        		setClientType(meeting, acc.PGA_Account_Type__c);
        	} catch (System.Queryexception e) {
        		System.debug(LoggingLevel.WARN, e);
        	}
        }
        
        //use usd by default
        meeting.CLIENT_ASSETS_IN_CURRENCY__c = 'USD (US Dollars)';
        setMeetingLocation(meeting);
        
        if (task.time_zone__c != null) {
            meeting.MEETING_TIMEZONE__c = task.time_zone__c;
        } else {
            meeting.MEETING_TIMEZONE__c = 'America/New_York';
        }
        meeting.MEETING_START_DATE__c = getStartTime(meeting.MEETING_TIMEZONE__c);
        meeting.MEETING_END_DATE__c = getEndTime(meeting.MEETING_TIMEZONE__c);
        
        //udate or insert meeting;
        MEP_SoqlUtils.performDmlOperation(MEP_DmlOperation.Upserting, meeting);
        if (meeting.Id != null) {
        	setAttendees(meeting, task.Fidelity_Attendees__c);
    		setAttendees(meeting, task.Fidelity_IPM_Attendees__c);
    		setSpeakers(meeting, task.Fidelity_PM_Attendees__c);
        }
        return meeting;
    }
    
    private static Datetime getStartTime(String timeZoneName) {
        if (task.ActivityDate != null && task.Meeting_Time__c != null) {
            Time startTime = parseTime(task.Meeting_Time__c);
            
            if (startTime != null) {
                //Datetime gmtDT = Datetime.newInstanceGmt(task.ActivityDate, startTime);
                return getDateTime(task.ActivityDate, startTime, timeZoneName);
            }
        }
        return Datetime.now();
    }
    
    private static Datetime getEndTime(String timeZoneName) {
        if (task.ActivityDate != null && task.Meeting_End_Time__c != null) {
            Time endTime = parseTime(task.Meeting_End_Time__c);
            if (endTime != null) {
            	return getDateTime(task.ActivityDate, endTime, timeZoneName);
                //return Datetime.newInstanceGmt(task.ActivityDate, endTime);
            }
        }
        return Datetime.now().addDays(1);
    }
    
    private static Datetime getDateTime(Date dateTask, Time timeTask, String timeZoneName) {
    	Datetime gmtDT = Datetime.newInstanceGmt(dateTask, timeTask);
       	return MEP_DateTimeUtils.convertDateTimeToGmt(gmtDT, timeZoneName);
    }
    
    private static String getMeetingPurposeFromTask() {
        if (task.Discussion_Topics__c != null) {
            String[] discussions = task.Discussion_Topics__c.split(';');
            List<Schema.PicklistEntry> purposes = MEP_EVENT_MEETINGS__c.MEETING_PURPOSE__c.getDescribe().getPicklistValues();
            for (String discussion : discussions) {
                for (Schema.PicklistEntry purpose : purposes) {
                    if (purpose.getValue() == discussion) {
                        return purpose.getValue();
                    }
                }
            }
        }
        return 'Other';
    }
    
    private static Time parseTime(String timeString) {
        Pattern p = Pattern.compile('(?i:([0-1]?[0-9]?)(:|.)([0-5]?[0-9]?)(am|pm))');
        Matcher m = p.matcher(timeString);
        if (m.matches()) {
            Integer hours = Integer.valueOf(m.group(1));
            if (m.group(4).toLowerCase() == 'pm' && hours < 12) {
                hours += 12;
            }
            return Time.newInstance(hours, Integer.valueOf(m.group(3)), 0, 0);
        }
        return null;
    }
    
    private static void setClientType(MEP_EVENT_MEETINGS__c meeting, String pgaType) {
        if (pgaType != null) {
            if (pgaType.equals('Prospect')) {
                    meeting.CLIENT_TYPE__c = MEP_ClientType.NEW_CLIENT;
            } else if (pgaType.equals('Client')) {
                    meeting.CLIENT_TYPE__c = MEP_ClientType.EXIST_CLIENT;
            } else if (pgaType.equals('Consultant')) {
                    meeting.CLIENT_TYPE__c = MEP_ClientType.CONSULTANTS;
            } else {
                    meeting.CLIENT_TYPE__c = MEP_ClientType.OTHER;
            }
        }
    }
    
    private static void setMeetingLocation(MEP_EVENT_MEETINGS__c meeting) {
    	if (task != null) {
    		if (task.Meeting_Location__c != null) {
    			String[] locations = task.Meeting_Location__c.split(',');
    			if (locations.size() != 0) {
    				MEP_LOCATIONS__c location = MEP_LocationDAO.getLocationByQuickName(locations[0]);
    				if (location != null) {
    					meeting.MEETING_LOCATION_ADDRESS_1__c = location.ADDRESS_1__c;
    					meeting.MEETING_LOCATION_ADDRESS_2__c = location.ADDRESS_2__c;
    					meeting.MEETING_LOCATION_CITY__c = location.CITY__c;
    					meeting.MEETING_LOCATION_STATE__c = location.STATE__c;
    					meeting.MEETING_LOCATION_COUNTRY__c = location.COUNTRY__c;
    					meeting.MEETING_LOCATION_ZIP_CODE__c = location.ZIP_CODE__c;
    				} else {
    					if (locations.size() == 1) {
    						meeting.MEETING_LOCATION_ADDRESS_1__c = locations[0];
    						meeting.MEETING_LOCATION_CITY__c = task.City__c;
					        meeting.MEETING_LOCATION_STATE__c = task.States__c;
					        meeting.MEETING_LOCATION_COUNTRY__c = task.Country__c;
    					} else if (locations.size() == 2) {
    						meeting.MEETING_LOCATION_ADDRESS_1__c = locations[0];
    						meeting.MEETING_LOCATION_ADDRESS_2__c = locations[1];
    						meeting.MEETING_LOCATION_CITY__c = task.City__c;
					        meeting.MEETING_LOCATION_STATE__c = task.States__c;
					        meeting.MEETING_LOCATION_COUNTRY__c = task.Country__c;
    					} else if (locations.size() == 3) {
    						meeting.MEETING_LOCATION_ADDRESS_1__c = locations[0];
    						meeting.MEETING_LOCATION_CITY__c = locations[1];
					        meeting.MEETING_LOCATION_STATE__c = locations[2];
					        meeting.MEETING_LOCATION_COUNTRY__c = task.Country__c;
    					} else if (locations.size() == 4) {
    						meeting.MEETING_LOCATION_ADDRESS_1__c = locations[0];
    						meeting.MEETING_LOCATION_CITY__c = locations[1];
					        meeting.MEETING_LOCATION_STATE__c = locations[2];
					        meeting.MEETING_LOCATION_COUNTRY__c = locations[3];
    					} else {
    						meeting.MEETING_LOCATION_ADDRESS_1__c = locations[0];
    						meeting.MEETING_LOCATION_CITY__c = locations[1];
					        meeting.MEETING_LOCATION_STATE__c = locations[2];
					        meeting.MEETING_LOCATION_COUNTRY__c = locations[3];
					        meeting.MEETING_LOCATION_ZIP_CODE__c = locations[4];
    					}
    				}
    			}
    		} else {
    			meeting.MEETING_LOCATION_CITY__c = task.City__c;
		        meeting.MEETING_LOCATION_STATE__c = task.States__c;
		        meeting.MEETING_LOCATION_COUNTRY__c = task.Country__c;
    		}
    	}
    }
    
    private static void setMeetingAssets(MEP_EVENT_MEETINGS__c meeting, Decimal val) {
    	if (val != null && val != 0) {
        	meeting.CLIENT_ASSETS_WITH_FIDELITY_NUMBER__c = val/100000;
        	meeting.CLIENT_ASSETS_WITH_FIDELITY_EXISTS_FLAG__c = true;
        } else {
        	meeting.CLIENT_ASSETS_WITH_FIDELITY_NUMBER__c = 0;
        	meeting.CLIENT_ASSETS_WITH_FIDELITY_EXISTS_FLAG__c = false;
        }
    }
    
    private static void setAttendees(MEP_EVENT_MEETINGS__c meeting, String attendeesStr) {
		List<String> corpIds = getCorpsIdsFromUsersNamesString(attendeesStr);
		if (corpIds.size() > 0) {
			Map<String, MEP_EVENT_MEETING_ATTENDEES__c> attendees = new Map<String, MEP_EVENT_MEETING_ATTENDEES__c>();
			
			MEP_EVENT_MEETING_ATTENDEES__c[] attendeesThatAlreadyExists = MEP_EventMeetingAttendeeDAO.getAttendeesByEventMeetingId(meeting.Id);
			for (MEP_EVENT_MEETING_ATTENDEES__c attendee : attendeesThatAlreadyExists) {
				attendees.put(attendee.ATTENDEE_USER_REFERENCE__c, attendee);
			}
			
			MEP_USERS__c[] mepUsers = MEP_MepUserDAO.getMepUsersByCorporateIds(corpIds);
			for (MEP_USERS__c mepUser : mepUsers) {
				if (!attendees.containsKey(mepUser.Id)) {
					MEP_EVENT_MEETING_ATTENDEES__c attendee = new MEP_EVENT_MEETING_ATTENDEES__c();
					attendee.ATTENDEE_FULL_NAME__c = mepUser.FULL_NAME__c;
					attendee.ATTENDEE_TYPE__c = MEP_AttendeeType.OTHER;
					attendee.ATTENDEE_USER_REFERENCE__c = mepUser.Id;
					attendee.MEP_MEETING_REFERENCE__c = meeting.Id;
					attendees.put(mepUser.Id, attendee);
				}
			}
	    		
			if (attendees.values() != null && attendees.values().size() > 0) {
				upsert attendees.values();
			}
		}
    }
    
    private static void setSpeakers(MEP_EVENT_MEETINGS__c meeting, String speakersStr) {
    	List<String> corpIds = getCorpsIdsFromUsersNamesString(speakersStr);
		if (corpIds.size() > 0) {
			
			Map<String, MEP_EVENT_MEETING_SPEAKERS__c> speakers = new Map<String, MEP_EVENT_MEETING_SPEAKERS__c>();
			
			MEP_EVENT_MEETING_SPEAKERS__c[] speakersThatAlreadyExists = MEP_EventMeetingSpeakerMappingDAO.getMappingsByEventMeetingId(meeting.Id);
			for (MEP_EVENT_MEETING_SPEAKERS__c speaker : speakersThatAlreadyExists) {
				speakers.put(speaker.SPEAKER__c, speaker);
			}
			
			
			MEP_USERS__c[] mepUsers = MEP_MepUserDAO.getMepUsersByCorporateIds(corpIds);
			for (MEP_USERS__c mepUser : mepUsers) {
				if (!speakers.containsKey(mepUser.Id)) {
					MEP_EVENT_MEETING_SPEAKERS__c speaker = new MEP_EVENT_MEETING_SPEAKERS__c();
					speaker.SPEAKER_FULL_NAME__c = mepUser.FULL_NAME__c;
					speaker.COMMUNICATION_TYPE__c = MEP_CommunicationType.IN_PERSON;
					speaker.SPEAKER__c = mepUser.Id;
					speaker.MEP_MEETING_REFERENCE__c = meeting.Id;
					MEP_CHANNELS__c channel = MEP_ChannelDAO.getChannelByMepUser(mepUser.Id);
					if (channel != null) {
						speaker.SPEAKER_CHANNEL__c = channel.Id;
					}
					speakers.put(mepUser.Id, speaker);
				}
			}
	    		
			if (speakers.values() != null && speakers.values().size() > 0) {
				upsert speakers.values();
			}
		}
    }
    
    private static String getCorpIdFromFullName(String fullName) {
    	return fullName.substring(fullName.indexOf('(') + 1, fullName.indexOf(')'));
    }
    
    private static List<String> getCorpsIdsFromUsersNamesString(String usersNamesStr) {
    	List<String> corpIds = new List<String>();
    	if (!MEP_StringUtils.isNullOrEmpty(usersNamesStr)) {
    		String[] usersNames = usersNamesStr.split(';');
    		for (String userName : usersNames) {
    			corpIds.add(getCorpIdFromFullName(userName));
    		}
    		
    	}
    	return corpIds;
    }
    
    
    @isTest
    private static void testGetCorpsIdsFromUsersNamesString() {
    	List<String> corpsIds = getCorpsIdsFromUsersNamesString('Sergey Legostaev (a999T002);Sergey Legostaev (a999T002)');
    	System.assert(corpsIds.size() == 2);
    	for (String s : corpsIds) {
    		System.assertEquals('a999T002', s);
    	}
    }
}