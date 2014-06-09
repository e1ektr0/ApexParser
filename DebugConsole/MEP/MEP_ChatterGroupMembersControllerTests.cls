@isTest
private class MEP_ChatterGroupMembersControllerTests {

    static testMethod void myUnitTest() {
		MEP_TestUtils.Autorize();
		MEP_HttpUtils.testResponsesCollection.add(MEP_TestUtils.createAutorizeResponse());
		MEP_ChatterGroupMembersController controller = new MEP_ChatterGroupMembersController();
		controller.init();
		//System.assert(controller.getEveryone().size() > 0);
    }
}