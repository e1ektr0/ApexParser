@isTest(SeeAllData=true)
private class MEP_CreateEventStep1ComponentTests {

    static testMethod void myUnitTest() {
    	MEP_TestUtils.Autorize(MEP_RoleKey.GATEKEEPER);
        MEP_CreateEventStep1Component component = new MEP_CreateEventStep1Component();
        System.assert(component.eventTypes.size()>0);
        MEP_EVENTS__c event = MEP_TestUtils.createTestEvent();
        MEP_EventConverter converter = new MEP_EventConverter();
        component.setEvent(converter.convertToDTO(event));
        System.assert(component.getEvent()!=null);
        
    }
}