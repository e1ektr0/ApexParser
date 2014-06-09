/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class MEP_CreateEventFromTaskTest {
	
	//create locations string
    private static String address1 = 'Address 1';
    private static String address2 = 'Address 2';
    private static String city = 'City';
    private static String state = 'State';
    private static String country = 'Country';
    private static String zipCode = 'Zip Code';
    private static Boolean triggerTest = false;
	
	static {
		createMepUser();
	}
	
    static testMethod void createEventFromTaskFromPageTest() {
    	MEP_TestUtils.setEnableTrigger(false);
		Task newTask = createTask();
		insert newTask;
		
		Task t = getTaskById(newTask.Id);
		
		try {
	       	MEP_EVENTS__c event = MEP_CreateEventFromTask.createEventFromTask(t);
	       	System.assert(event != null);
	       	System.assertEquals(t.MEP_Event_Id__c, event.Id);
	       	
	       	//test subject changes
	       	testSubjectChanges(t);
	       	
	       	//test assigned attendees 
	       	testAssignedAttendees(t);
	       	
	       	//test locations
	       	testSimpleLocation(event);
	       	testLocationFromDB(t);
	       	testLocationsFromSelect(t);
	       	
	       	//test time zone
	       	testTimeZone(t);
	       	
		} catch (MEP_Exception e) {
			System.assert(false, e.getMessage());
		}
    }
    /*
    static testMethod void createEventFromTaskFromTrigger() {
    	triggerTest = true;
		try {
			Task newTask = createTask();
			newTask.MEP_Create_Event__c = true;
			insert newTask;
			
			
			
			Task t = getTaskById(newTask.Id);
			System.assert(t.MEP_Event_Id__c != null);
			
	       	MEP_EVENTS__c event = MEP_EventDAO.getEventById(t.MEP_Event_Id__c);
	       	System.assert(event != null);
	       	System.assertEquals(t.MEP_Event_Id__c, event.Id);
	       	//test subject changes
	       	testSubjectChanges(t);
	       	
	       	
	       	
	       	//test locations
	       	testSimpleLocation(event);
	       	testLocationFromDB(t);
	       	testLocationsFromSelect(t);
	       	
	       	//test time zone
	       	testTimeZone(t);
	       	
	       	//MEP_TestUtils.setEnableTrigger(false);
			//test assigned attendees 
	       	//testAssignedAttendees(t);
			
		} catch (Exception e) {
			System.assert(false, e.getMessage());
		}
    }*/
    
    static testMethod void deleteTaskTest() {
    	try {
			Task newTask = createTask();
			newTask.MEP_Create_Event__c = true;
			insert newTask;
		
			Task t = getTaskById(newTask.Id);
			System.assert(t.MEP_Event_Id__c != null);
			
			String eventId = t.MEP_Event_Id__c;
			
			delete t;
			
	       	MEP_EVENTS__c event = MEP_EventDAO.getEventById(eventId);
	       	System.assert(event != null);
	       	System.assertEquals(MEP_EventState.CANCELLED, event.EVENT_STATE__c);
	       	
		} catch (Exception e) {
			System.assert(false, e.getMessage());
		}
    }
    
    private static void testSimpleLocation(MEP_EVENTS__c event) {
    	MEP_EVENT_MEETINGS__c[] meetings = MEP_EventMeetingDAO.getEventMeetingsByEventId(event.Id);
    	if (meetings != null && meetings.size() == 1) {
    		System.assertEquals(city, meetings[0].MEETING_LOCATION_CITY__c);
	    	System.assertEquals(state, meetings[0].MEETING_LOCATION_STATE__c);
	    	System.assertEquals(country, meetings[0].MEETING_LOCATION_COUNTRY__c);
    	} else {
    		System.assert(false);
    	}
    	
    }
    
    private static void testLocationFromDB(Task testTask) {
    	//create test location
    	MEP_LOCATIONS__c location = MEP_TestUtils.createTestLocation();
    	
    	
    	//update task
    	testTask.Meeting_Location__c = location.QUICK_NAME__c;
    	if (triggerTest) {
    		update testTask;
    	} else {
    		MEP_CreateEventFromTask.updateEvent(testTask);
    	}
    	
    	//get updated meeting
    	MEP_EVENT_MEETINGS__c[] meetings = MEP_EventMeetingDAO.getEventMeetingsByEventId(testTask.MEP_Event_Id__c);
    	
    	//test exists location 
    	if (meetings != null && meetings.size() == 1) {
    		System.assertEquals(location.ADDRESS_1__c, meetings[0].MEETING_LOCATION_ADDRESS_1__c);
    		System.assertEquals(location.ADDRESS_2__c, meetings[0].MEETING_LOCATION_ADDRESS_2__c);
    		System.assertEquals(location.CITY__c, meetings[0].MEETING_LOCATION_CITY__c);
	    	System.assertEquals(location.STATE__c, meetings[0].MEETING_LOCATION_STATE__c);
	    	System.assertEquals(location.COUNTRY__c, meetings[0].MEETING_LOCATION_COUNTRY__c);
	    	System.assertEquals(location.ZIP_CODE__c, meetings[0].MEETING_LOCATION_ZIP_CODE__c);
    	} else {
    		System.assert(false);
    	}
    }
    
    private static void testSubjectChanges(Task testTask) {
    	String newSubject = 'New subject';
    	testTask.Subject = newSubject;
    	//update task
    	if (triggerTest) {
    		update testTask;
    	} else {
    		MEP_CreateEventFromTask.updateEvent(testTask);
    	}
    	
    	MEP_EVENTS__c event = MEP_EventDAO.getEventById(testTask.MEP_Event_Id__c);
    	System.assert(event != null);
    	System.assertEquals(newSubject, event.EVENT_NAME__c);
    	
    	//get updated meeting
    	MEP_EVENT_MEETINGS__c[] meetings = MEP_EventMeetingDAO.getEventMeetingsByEventId(testTask.MEP_Event_Id__c);
    	
    	//test exists location 
    	if (meetings != null && meetings.size() == 1) {
    		System.assertEquals(newSubject, meetings[0].MEETING_NAME__c);
    	} else {
    		System.assert(false);
    	}
    }
    
    private static void testLocationsFromSelect(Task testTask) {
		//set address1 from 'select' value
    	testTask.Meeting_Location__c = address1;
    	
    	//update task
    	if (triggerTest) {
    		update testTask;
    	} else {
    		MEP_CreateEventFromTask.updateEvent(testTask);
    	}
    	
    	//get updated meeting
    	MEP_EVENT_MEETINGS__c[] meetings = MEP_EventMeetingDAO.getEventMeetingsByEventId(testTask.MEP_Event_Id__c);
    	
    	//test location address
    	if (meetings != null && meetings.size() == 1) {
    		System.assertEquals(address1, meetings[0].MEETING_LOCATION_ADDRESS_1__c);
    		System.assertEquals(testTask.City__c, meetings[0].MEETING_LOCATION_CITY__c);
	    	System.assertEquals(testTask.States__c, meetings[0].MEETING_LOCATION_STATE__c);
	    	System.assertEquals(testTask.Country__c, meetings[0].MEETING_LOCATION_COUNTRY__c);
    	} else {
    		System.assert(false);
    	}
    	
    	//set address1,address2 from 'select' value
    	testTask.Meeting_Location__c = address1 + ',' + address2;
    	
    	//update task
    	if (triggerTest) {
    		update testTask;
    	} else {
    		MEP_CreateEventFromTask.updateEvent(testTask);
    	}
    	meetings = MEP_EventMeetingDAO.getEventMeetingsByEventId(testTask.MEP_Event_Id__c);
    	
    	//test location address
    	if (meetings != null && meetings.size() == 1) {
    		System.assertEquals(address1, meetings[0].MEETING_LOCATION_ADDRESS_1__c);
    		System.assertEquals(address2, meetings[0].MEETING_LOCATION_ADDRESS_2__c);
    		System.assertEquals(testTask.City__c, meetings[0].MEETING_LOCATION_CITY__c);
	    	System.assertEquals(testTask.States__c, meetings[0].MEETING_LOCATION_STATE__c);
	    	System.assertEquals(testTask.Country__c, meetings[0].MEETING_LOCATION_COUNTRY__c);
    	} else {
    		System.assert(false);
    	}
    	
    	//set address1, city, state, from 'select' value
    	testTask.Meeting_Location__c = address1 + ',' + city + ',' + state;
    	
    	//update task
    	if (triggerTest) {
    		update testTask;
    	} else {
    		MEP_CreateEventFromTask.updateEvent(testTask);
    	}
    	meetings = MEP_EventMeetingDAO.getEventMeetingsByEventId(testTask.MEP_Event_Id__c);
    	
    	//test location address
    	if (meetings != null && meetings.size() == 1) {
    		System.assertEquals(address1, meetings[0].MEETING_LOCATION_ADDRESS_1__c);
    		System.assertEquals(city, meetings[0].MEETING_LOCATION_CITY__c);
	    	System.assertEquals(state, meetings[0].MEETING_LOCATION_STATE__c);
	    	System.assertEquals(testTask.Country__c, meetings[0].MEETING_LOCATION_COUNTRY__c);
    	} else {
    		System.assert(false);
    	}
    	
    	//set address1, city, state, coutry from 'select' value
    	testTask.Meeting_Location__c = address1 + ',' + city + ',' + state + ',' + country;
    	
    	//update task
    	if (triggerTest) {
    		update testTask;
    	} else {
    		MEP_CreateEventFromTask.updateEvent(testTask);
    	}
    	
    	meetings = MEP_EventMeetingDAO.getEventMeetingsByEventId(testTask.MEP_Event_Id__c);
    	
    	//test location address
    	if (meetings != null && meetings.size() == 1) {
    		System.assertEquals(address1, meetings[0].MEETING_LOCATION_ADDRESS_1__c);
    		System.assertEquals(city, meetings[0].MEETING_LOCATION_CITY__c);
	    	System.assertEquals(state, meetings[0].MEETING_LOCATION_STATE__c);
	    	System.assertEquals(country, meetings[0].MEETING_LOCATION_COUNTRY__c);
    	} else {
    		System.assert(false);
    	}
    	
    	//set address1, city, state, coutry, zip code from 'select' value
    	testTask.Meeting_Location__c = address1 + ',' + city + ',' + state + ',' + country + ',' + zipCode;
    	
    	//update task
    	if (triggerTest) {
    		update testTask;
    	} else {
    		MEP_CreateEventFromTask.updateEvent(testTask);
    	}
    	
    	meetings = MEP_EventMeetingDAO.getEventMeetingsByEventId(testTask.MEP_Event_Id__c);
    	
    	//test location address
    	if (meetings != null && meetings.size() == 1) {
    		System.assertEquals(address1, meetings[0].MEETING_LOCATION_ADDRESS_1__c);
    		System.assertEquals(city, meetings[0].MEETING_LOCATION_CITY__c);
	    	System.assertEquals(state, meetings[0].MEETING_LOCATION_STATE__c);
	    	System.assertEquals(country, meetings[0].MEETING_LOCATION_COUNTRY__c);
	    	System.assertEquals(zipCode, meetings[0].MEETING_LOCATION_ZIP_CODE__c);
    	} else {
    		System.assert(false);
    	}
    	
    }
    
    private static void testTimeZone(Task testTask) {
    	testTask.time_zone__c = 'GMT-4';
    	if (triggerTest) {
    		update testTask;
    	} else {
    		MEP_CreateEventFromTask.updateEvent(testTask);
    	}
    	
    	//get updated meeting
    	MEP_EVENT_MEETINGS__c[] meetings = MEP_EventMeetingDAO.getEventMeetingsByEventId(testTask.MEP_Event_Id__c);
    	
    	//test location address
    	if (meetings != null && meetings.size() == 1) {
    		System.assertEquals(testTask.time_zone__c, meetings[0].MEETING_TIMEZONE__c);
    	} else {
    		System.assert(false);
    	}
    }
    
    private static void testAssignedAttendees(Task testTask) {
    	MEP_EVENT_MEETING_ATTENDEES__c[] attendees = MEP_EventMeetingAttendeeDAO.getAttendeesByEventId(testTask.MEP_Event_Id__c);
    	System.assert(attendees != null);
    	
    	for (MEP_EVENT_MEETING_ATTENDEES__c attendee : attendees) {
    		System.debug(attendee.ATTENDEE_FULL_NAME__c);
    	}
    	if (triggerTest) {
    		System.assert(attendees.size() > 2);
    	} else {
    		System.assert(attendees.size() == 2);
    	}
    }
    
    
    private static Task createTask() {
    	
    	Task testTask = new Task();
    	testTask.Subject = 'test subject';
    	testTask.ActivityDate = Date.today();
    	testTask.WhatId = createAccount().Id;
    	testTask.Description = 'test description';
    	testTask.City__c = city;
    	testTask.States__c = state;
    	testTask.Country__c = country;
    	testTask.Discussion_Topics__c = 'Relationship Building';
    	testTask.Meeting_Time__c = '1:45pm';
    	testTask.Meeting_End_Time__c = '2:45pm';
    	//attendee
    	testTask.Fidelity_Attendees__c = createUser().FULL_NAME__c;
    	//attendee
    	testTask.Fidelity_IPM_Attendees__c = createUser().FULL_NAME__c;
    	//speaker
    	testTask.Fidelity_PM_Attendees__c = createUser().FULL_NAME__c;
    	return testTask;
    }
    
    private static Account createAccount() {
    	Account acc = new Account();
    	acc.Name = 'test account';
    	acc.PGA_Account_Type__c = 'Prospect';
    	acc.Total_Client_IM_Assets__c = 123456;
    	insert acc;
    	return acc;
    }
    
    private static MEP_USERS__c createMepUser() {
    	MEP_USERS__c mepUser = MEP_TestUtils.createTestUser();
    	if (mepUser.SALESFORCE_CHATTER_USER_REFERENCE__c == null) {
    		mepUser.SALESFORCE_CHATTER_USER_REFERENCE__c = Userinfo.getUserId();
    		update mepUser;
    	}
    	return mepUser;
    }
    
    private static MEP_USERS__c createUser() {
    	MEP_USERS__c mepUser = MEP_TestUtils.createTestUser();
    	mepUser.FULL_NAME__c = mepUser.FULL_NAME__c + ' (' + mepUser.CORPORATE_ID__c + ')';
    	update mepUser;
    	return mepUser;
    }
    
    private static Task getTaskById(String taskId) {
    	try {
            Task t = [select Id, Subject, Description, Meeting_Time__c, ActivityDate, Meeting_End_Time__c, MEP_Event_Id__c, 
                Discussion_Topics__c, time_zone__c, AccountId, Account.Name, Account.PGA_Account_Type__c, Account.Total_Client_IM_Assets__c, 
                    City__c, Country__c, States__c, Meeting_Location__c, Fidelity_PM_Attendees__c, 
                    	Fidelity_IPM_Attendees__c, Fidelity_Attendees__c From Task where Id = :taskId];
            return t;
        } catch (System.Queryexception e) {
			System.assert(false, e.getMessage());
        }
        return null;
    }
    
}