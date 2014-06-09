@isTest
private class MEP_ChannelDAOTests {

	private static testMethod void test_getChannelById()
	{
		MEP_CHANNELS__c testChannel = MEP_TestUtils.createTestChannel();
		
		System.assertEquals(null, MEP_ChannelDAO.getChannelById(null));
		System.assertEquals(testChannel.Id,  MEP_ChannelDAO.getChannelById(testChannel.Id).Id);
		
		testChannel.INT_ROW_IS_ARCHIVED__c = false;
		MEP_SoqlUtils.performDmlOperation(MEP_DmlOperation.Updating, testChannel);
		System.assertEquals(testChannel.Id,  MEP_ChannelDAO.getChannelById(testChannel.Id, true).Id);
	}

	private static testMethod void test_getChannelsByPartialName()
	{
		System.assertEquals(null,  MEP_ChannelDAO.getChannelsByPartialName(null));
		MEP_CHANNELS__c testChannel = MEP_TestUtils.createTestChannel();
		testChannel.CHANNEL_NAME__c = 'FideLIty';
		update testChannel;
		List<MEP_CHANNELS__c> channels = MEP_ChannelDAO.getChannelsByPartialName(testChannel.CHANNEL_NAME__c.substring(0,2));
		System.assertEquals(channels.size(), 1);
	}

	private static testMethod void test_getChannelByCode()
	{
		System.assertEquals(null,  MEP_ChannelDAO.getChannelByCode(null));
		MEP_CHANNELS__c testChannel = MEP_TestUtils.createTestChannel();
		MEP_CHANNELS__c channel =  MEP_ChannelDAO.getChannelByCode(testChannel.CHANNEL_CODE__c);
		System.assertEquals(testChannel.Id, channel.Id);
	}
	
	private static testMethod void test_getChannelByMepUser()
	{
		System.assertEquals(null,  MEP_ChannelDAO.getChannelByMepUser(null));		
		MEP_USERS__c user = MEP_TestUtils.createTestUser(); 
		MEP_CHANNELS__c testChannel = MEP_TestUtils.createTestChannel();
		testChannel.CHANNEL_CODE__c = user.BUSINESS_UNIT_CODE__c;
		MEP_SoqlUtils.performDmlOperation(MEP_DmlOperation.Updating, testChannel);		
		MEP_CHANNELS__c channel =  MEP_ChannelDAO.getChannelByMepUser(user.Id);
		System.assertEquals(testChannel.Id, channel.Id);
	}
	
}