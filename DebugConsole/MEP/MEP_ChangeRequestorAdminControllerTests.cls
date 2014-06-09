@isTest
private class MEP_ChangeRequestorAdminControllerTests {
    private static testMethod void test_MEP_ChangeRequestorAdminControllerBaseFunctions()
    {
        MEP_ChangeRequestorAdminController controller = new MEP_ChangeRequestorAdminController();
        MEP_USERS__c user = MEP_TestUtils.createTestUser();    
        user.BUSINESS_UNIT_CODE__c = MEP_TestUtils.createTestChannel().CHANNEL_CODE__c;
        update user;
        controller.EventId =MEP_TestUtils.createTestEvent().id;
        controller.RequestorId = user.Id;
        controller.Save();
        System.assert(MEP_EventDAO.getEventById(controller.EventId).REQUESTED_BY_USER__c == controller.RequestorId);
    }
    private static testMethod void test_MEP_ChangeRequestorAdminController_getEvents()
    {               
    	MEP_HttpUtils.testResponsesCollection.add(MEP_TestUtils.createAutorizeResponse());
    	MEP_EVENTS__c event =MEP_TestUtils.createTestEvent();
    	event.EVENT_STATE__c = MEP_EventState.SUBMITTED_TO_CHANNEL;
    	event.ROLLUP_EVENT_START_DATE__c = DateTime.now().addDays(1);
    	MEP_SoqlUtils.performDmlOperation(MEP_DmlOperation.Updating, event);
    	System.assertEquals(MEP_ChangeRequestorAdminController.getEvents(event.EVENT_NAME__c).size(),1);
    }
    private static testMethod void test_MEP_ChangeRequestorAdminController_getRequestors()
    {               
        MEP_USERS__c user = MEP_TestUtils.createTestUser();    
        user.BUSINESS_UNIT_CODE__c = MEP_TestUtils.createTestChannel().CHANNEL_CODE__c;
        update user;         
        System.assertEquals(MEP_ChangeRequestorAdminController.getRequestors(user.FULL_NAME__c,user.BUSINESS_UNIT_CODE__c ).size(),1);
    }
}