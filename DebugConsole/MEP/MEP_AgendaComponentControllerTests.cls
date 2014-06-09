@isTest
private class MEP_AgendaComponentControllerTests {
	
	private static MEP_EVENT_MEETINGS__c createMeeting(String eventState)
	{
		MEP_EVENTS__c event = MEP_TestUtils.createTestEvent();
        event.EVENT_STATE__c = eventState;
        update event;
        MEP_EVENT_MEETINGS__c meeting = MEP_TestUtils.createTestMeeting(event);
        meeting.MEETING_START_DATE__c = Date.today().addDays(1);
        update meeting;
        return meeting;
	}
	//TODO: fix!!!
    /*
    static testMethod void test_initAgenda() {
    	MEP_ApplicationSettings__c setting = new MEP_ApplicationSettings__c();
    	setting.Name = 'DEFAULT_AGENDA_PERIOD';
    	setting.value__c = '7';
    	insert setting;
    	createMeeting(MEP_EventState.DRAFT);
        MEP_AgendaComponentController controller = new MEP_AgendaComponentController();
    	System.assert(controller.dp!=null);
    	assertCheckCurrentDate(controller);
    	System.assertEquals(totalMeetingsCount(controller),0);    	
    	createMeeting(MEP_EventState.ALL_CONFIRMED);
    	controller.initAgenda();
    	System.assertEquals(totalMeetingsCount(controller),1);    
    }
	static testMethod void test_agendaNavigation() {
	 	MEP_ApplicationSettings__c setting = new MEP_ApplicationSettings__c();
    	setting.Name = 'DEFAULT_AGENDA_PERIOD';
    	setting.value__c = '7';
    	insert setting;
    	MEP_AgendaComponentController controller = new MEP_AgendaComponentController();
    	controller.agendaNext();
    	System.assertEquals(controller.agendaStartDate.date(), Date.today().addDays(1));
    	controller.agendaToday();
    	System.assertEquals(controller.agendaStartDate.date(), Date.today().addDays(0));
    	controller.agendaPrev();
    	System.assertEquals(controller.agendaStartDate.date(), Date.today().addDays(-1));
	}
	*/
    static void assertCheckCurrentDate(MEP_AgendaComponentController controller)
    {
    	System.assertEquals(controller.isToDay, controller.agendaStartDate.date() == Datetime.now().date());    	
    }
    static Integer totalMeetingsCount( MEP_AgendaComponentController controller)
    {
    	Integer result = 0;
    	for(MEP_AgendaComponentController.AgentaMeeting agendaRow:  controller.wrapper)
    		result+=agendaRow.meetings.size();
		return result;
    } 
}