public with sharing class MEP_ClientDAO
{
	//
	//Variables and constants
	//
	private static final String CLIENT_TABLE = 'MEP_CLIENTS__c';
	private static final String FIELDS = 'Id, CLIENT_NAME__c';
	//
	
	//
	//Public static methods
	//
	public static MEP_CLIENTS__c getClientById(String clientId)
	{
		if (clientId == null || clientId == '')
		{
			return null;
		}
		
		MEP_SoqlQueryBuilder queryBuilder = new MEP_SoqlQueryBuilder(FIELDS, CLIENT_TABLE);
		queryBuilder.condition = 'Id = \'' + clientId + '\'';
		return (MEP_CLIENTS__c)MEP_SoqlUtils.performSingleResultQuery(queryBuilder);
	}
	
	public static List<MEP_CLIENTS__c> searchClientByPartName(String partName) {
		String conditions = 'INT_ROW_IS_ARCHIVED__c = false AND CLIENT_NAME__c like \'%'
			+ MEP_SoqlUtils.escapeSpecialCharsForLikeOperator(partName) + '%\'';
		MEP_SoqlQueryBuilder queryBuilder = new MEP_SoqlQueryBuilder(FIELDS, CLIENT_TABLE, conditions);
		queryBuilder.limitOfResultSet = 10;
		return MEP_SoqlUtils.performQuery(queryBuilder);
	}
	
	
	//
	//Tests
	//
	@isTest
	private static void test_getClientById()
	{
		System.assertEquals(null, getClientById(null));
		
		MEP_CLIENTS__c client1 = MEP_TestUtils.createTestClient();
		if (client1 != null)
		{
			MEP_CLIENTS__c clien2 = getClientById(client1.Id);
			System.assertEquals(client1.Id, clien2.Id);
		}
	}
	
	@isTest
	private static void testSearchClientByPartName() {
		List<MEP_CLIENTS__c> clients = searchClientByPartName('');
	}
}