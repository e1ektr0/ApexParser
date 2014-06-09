//
//This is DAO class for 'MEP_CHANNELS__c' objects
//
public with sharing class MEP_ChannelDAO
{
	//
	//Variables
	//
	private static final String CHANNEL_TABLE = 'MEP_CHANNELS__c';
	
	private static final String BASIC_FIELDS = 'Id, CHANNEL_NAME__c, WORKFLOW_IN_AUTO_APPROVE_MODE__c, CHANNEL_CODE__c, GROUP_CODE__c, GROUP_NAME__c';

	//	
	//
	//Private static methods
	//
	private static String createConditionForActualChannels()
	{
		return 'IsDeleted = FALSE AND INT_ROW_IS_ARCHIVED__c = FALSE';
	}
	//
	
	//
	//Public static methods
	//
	public static MEP_CHANNELS__c getChannelById(String channelId)
	{
		return getChannelById(channelId, false);
	}
	public static void changeAutoApprovalMode(String channelId, Boolean IsAutoApprovalMode)
	{
		MEP_CHANNELS__c chanel = getChannelById(channelId);
		chanel.WORKFLOW_IN_AUTO_APPROVE_MODE__c = IsAutoApprovalMode;
		MEP_SoqlUtils.performDmlOperation(MEP_DmlOperation.Updating, chanel);
	}
	public static MEP_CHANNELS__c getChannelById(String channelId, Boolean getOnlyActualChannel)
	{
		if (channelId == null || channelId == '')
		{
			return null;
		}
		
		List<String> conditions = new List<String>();
		conditions.add('Id = \'' + channelId + '\'');
		if (getOnlyActualChannel)
		{
			conditions.add(createConditionForActualChannels());
		}
		MEP_SoqlQueryBuilder queryBuilder = new MEP_SoqlQueryBuilder(BASIC_FIELDS, CHANNEL_TABLE);
		queryBuilder.condition = MEP_SoqlUtils.joinConditions(conditions, MEP_LogicOperator.AND_Operator);
		
		return (MEP_CHANNELS__c)MEP_SoqlUtils.performSingleResultQuery(queryBuilder);
	}
	
	public static List<MEP_CHANNELS__c> getChannelsByPartialName(String partialName)
	{
		if (partialName == null || partialName == '')
		{
			return null;
		}
		
		MEP_SoqlQueryBuilder queryBuilder = new MEP_SoqlQueryBuilder('Id, CHANNEL_NAME__c', CHANNEL_TABLE);
		queryBuilder.condition = 'CHANNEL_NAME__c LIKE \''
			+ MEP_SoqlUtils.escapeSpecialCharsForLikeOperator(partialName) + '%\'';
			
		return MEP_SoqlUtils.performQuery(queryBuilder);
	}
	
	public static MEP_CHANNELS__c getChannelByCode(String channelCode)
	{
		if (channelCode == null || channelCode == '')
		{
			return null;
		}
		
		MEP_SoqlQueryBuilder queryBuilder = new MEP_SoqlQueryBuilder(BASIC_FIELDS, CHANNEL_TABLE);
		queryBuilder.condition = 'CHANNEL_CODE__c = \'' + channelCode + '\'';
		return (MEP_CHANNELS__c)MEP_SoqlUtils.performSingleResultQuery(queryBuilder);
	}
	
	public static MEP_CHANNELS__c getChannelByMepUser(String mepUserId)
	{
		MEP_USERS__c user = MEP_MepUserDAO.getMepUserById(mepUserId);
		if (user == null)
		{
			return null;
		}
		
		return getChannelByCode(user.BUSINESS_UNIT_CODE__c);
	}
	
	public static List<MEP_CHANNELS__c> getAllChannels() {
		MEP_SoqlQueryBuilder queryBuilder = new MEP_SoqlQueryBuilder(BASIC_FIELDS, CHANNEL_TABLE);
		queryBuilder.condition = createConditionForActualChannels();
		queryBuilder.setOrderByBlock('CHANNEL_CODE__c', MEP_SortingOrder.Ascending);
		return MEP_SoqlUtils.performQuery(queryBuilder);
	}
	//
	
	
	public static List<MEP_CHANNELS__c> getChannelByFilter(MEP_ChannelFilter filter)
	{
		
		MEP_SoqlQueryBuilder queryBuilder = new MEP_SoqlQueryBuilder(BASIC_FIELDS, CHANNEL_TABLE);
		List<String> conditionals = new List<String>();
		if(filter.userId!=null)//#important it's logic is temp
		{
			MEP_USERS__c user = MEP_MepUserDAO.getMepUserById(filter.userId);
			conditionals.add('CHANNEL_CODE__c = \'' + user.BUSINESS_UNIT_CODE__c + '\'');
		}
		if(!MEP_StringUtils.isNullOrEmpty(filter.searchText))
		{
			List<String> searchConditionals = new List<String>();
			searchConditionals.add('CHANNEL_NAME__c LIKE \'%'+ MEP_SoqlUtils.escapeSpecialCharsForLikeOperator(filter.searchText) + '%\'');
			searchConditionals.add('CHANNEL_CODE__c LIKE \'%'+ MEP_SoqlUtils.escapeSpecialCharsForLikeOperator(filter.searchText) + '%\'');
			searchConditionals.add('GROUP_CODE__c LIKE \'%'+ MEP_SoqlUtils.escapeSpecialCharsForLikeOperator(filter.searchText) + '%\'');
			conditionals.add('('+MEP_SoqlUtils.joinConditions(searchConditionals, MEP_LogicOperator.OR_Operator)+')');
		}
		if(!MEP_StringUtils.isNullOrEmpty(filter.userIds))
		{
			List<String> usersIdList = new List<String>();
			for(String userId : filter.userIds.split(','))
				usersIdList.add(userId.trim());
			
			conditionals.add('ID in ( Select CHANNEL__c from  MEP_USER_CHANNEL_ROLE_MAPPINGS__c where '+ 
			'INT_ROW_IS_ARCHIVED__c = false and ISDELETED = false and USER__c in ('+MEP_SoqlUtils.joinStringsForINSection(usersIdList)+'))');
		}
		queryBuilder.condition = MEP_SoqlUtils.joinConditions(conditionals, MEP_LogicOperator.AND_Operator);
		if (filter.sortingField != null&&BASIC_FIELDS.contains(filter.sortingField.name))
			queryBuilder.setOrderByBlock(filter.sortingField.name, filter.sortingField.sortingOrder);
		if (filter.resultLimit != null) 
			queryBuilder.limitOfResultSet = filter.resultLimit;
		if (filter.resultOffset != null)
			queryBuilder.offsetOfResult = filter.resultOffset;
		System.debug(queryBuilder.buildQuery());
		return MEP_SoqlUtils.performQuery(queryBuilder);
	}
	
	
	
	//
	//Tests
	//
	@IsTest(SeeAllData=true)
	private static void test_getChannelById()
	{
		MEP_CHANNELS__c testChannel = MEP_TestUtils.createTestChannel();
		
		System.assertEquals(null, getChannelById(null));
		System.assertEquals(testChannel.Id, getChannelById(testChannel.Id).Id);
		
		testChannel.INT_ROW_IS_ARCHIVED__c = false;
		MEP_SoqlUtils.performDmlOperation(MEP_DmlOperation.Updating, testChannel);
		System.assertEquals(testChannel.Id, getChannelById(testChannel.Id, true).Id);
	}
	
	@IsTest(SeeAllData=true)
	private static void test_getChannelsByPartialName()
	{
		System.assertEquals(null, getChannelsByPartialName(null));
		
		List<MEP_CHANNELS__c> channels = MEP_ChannelDAO.getChannelsByPartialName('FideLIty');
		System.debug('****** Size = ' + channels.size());
		for (MEP_CHANNELS__c channel : channels)
		{
			System.debug('****** Name = ' + channel.CHANNEL_NAME__c);
		}
	}
	
	@IsTest(SeeAllData=true)
	private static void test_getChannelByCode()
	{
		System.assertEquals(null, getChannelByCode(null));
		
		MEP_CHANNELS__c testChannel = MEP_TestUtils.createTestChannel();
		MEP_CHANNELS__c channel = getChannelByCode(testChannel.CHANNEL_CODE__c);
		System.assertEquals(testChannel.Id, channel.Id);
	}
	
	@IsTest(SeeAllData=true)
	private static void test_getChannelByMepUser()
	{
		System.assertEquals(null, getChannelByMepUser(null));
		
		MEP_USERS__c user = MEP_TestUtils.createTestUser(); 
		MEP_CHANNELS__c testChannel = MEP_TestUtils.createTestChannel();
		testChannel.CHANNEL_CODE__c = user.BUSINESS_UNIT_CODE__c;
		MEP_SoqlUtils.performDmlOperation(MEP_DmlOperation.Updating, testChannel);
		
		MEP_CHANNELS__c channel = getChannelByMepUser(user.Id);
		System.assertEquals(testChannel.Id, channel.Id);
	}
}