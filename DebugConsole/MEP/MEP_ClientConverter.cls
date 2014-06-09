public with sharing class MEP_ClientConverter implements MEP_Converter<MEP_ClientDTO, MEP_CLIENTS__c>
{
	//
	//Implementation
	//
	public MEP_ClientDTO convertToDTO(MEP_CLIENTS__c databaseClient)
	{
		if (databaseClient == null)
		{
			return null;
		}
		
		MEP_ClientDTO clientDto = new MEP_ClientDTO();
		clientDto.id = databaseClient.Id;
		clientDto.name = databaseClient.CLIENT_NAME__c;
		//clientDto.companyName = databaseClient.Company_Name__c;
		
		return clientDto;
	}
	
	public List<MEP_ClientDTO> convertToDTO(List<MEP_CLIENTS__c> listOfDatabaseClients)
	{
		if (listOfDatabaseClients == null)
		{
			return null;
		}
		
		List<MEP_ClientDTO> listOfDto = new List<MEP_ClientDTO>();
		for (MEP_CLIENTS__c databaseClient : listOfDatabaseClients)
		{
			listOfDto.add(convertToDTO(databaseClient));
		}
		
		return listOfDto;
	}
	//
	//
	//Test
	//
	//
	@isTest(SeeAllData=false)
	private static void test_convertToDTO_SingleObject()
	{
		MEP_ClientConverter converter = new MEP_ClientConverter();
		
		//null parameter
		MEP_CLIENTS__c testClient = null;
		System.assertEquals(null, converter.convertToDTO(testClient));
		
		//not null parameter
		testClient = MEP_TestUtils.createTestClient();
		testClient = MEP_ClientDAO.getClientById(testClient.Id);
		System.assertEquals(testClient.Id, converter.convertToDTO(testClient).id);
	}
	
	@isTest(SeeAllData=false)
	private static void test_convertToDTO_list()
	{
		MEP_ClientConverter converter = new MEP_ClientConverter();
		
		//null parameter
		MEP_CLIENTS__c[] testClients = null;
		System.assertEquals(null, converter.convertToDTO(testClients));
		
		//not null parameter
		MEP_CLIENTS__c testClient = MEP_TestUtils.createTestClient();
		testClients = new MEP_CLIENTS__c[]{MEP_ClientDAO.getClientById(testClient.Id)};
		MEP_ClientDTO[] convertedClients = converter.convertToDTO(testClients);
		System.assertEquals(1, convertedClients.size());
		System.assertEquals(testClient.Id, convertedClients[0].id);
	}
}