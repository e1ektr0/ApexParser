@isTest
private class MEP_ChannelConverterTests {

   	private static testMethod void test_convertToDTO_SingleObject()
	{
		MEP_CHANNELS__c channelTest = MEP_TestUtils.createTestChannel();
		MEP_ChannelDTO channelDTO = new MEP_ChannelConverter().convertToDTO(channelTest);
		baseDTOAssert(channelDTO,channelTest);
	}
	private static void baseDTOAssert(MEP_ChannelDTO channelDTO,MEP_CHANNELS__c channelTest )
	{
		System.assertEquals(channelDTO.id,channelTest.id);
		System.assertEquals(channelDTO.name,channelTest.CHANNEL_NAME__c);
		System.assertEquals(channelDTO.WorkflowInAutoApproveMode, channelTest.WORKFLOW_IN_AUTO_APPROVE_MODE__c);
	}
	
	private static testMethod void test_convertToDTO_list()
	{
		MEP_CHANNELS__c channelTest = MEP_TestUtils.createTestChannel();
		list<MEP_CHANNELS__c> channelTestList = new list<MEP_CHANNELS__c>();
		channelTestList.add(channelTest);
		MEP_ChannelDTO channelDTO = new MEP_ChannelConverter().convertToDTO(channelTestList)[0];
		System.assertEquals(new MEP_ChannelConverter().convertToDTO(channelTestList).size(),1);
		baseDTOAssert(channelDTO,channelTest);
	}
}