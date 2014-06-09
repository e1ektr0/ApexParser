public with sharing class MEP_ChatterGroupConverter implements MEP_Converter<MEP_ChatterGroupDTO, CollaborationGroup> {
	
	public List<MEP_ChatterGroupDTO> convertToDTO(List<CollaborationGroup> objList) {
		List<MEP_ChatterGroupDTO> chatterGroups = new List<MEP_ChatterGroupDTO>();
		for (CollaborationGroup obj : objList) {
			chatterGroups.add(convertToDTO(obj));
		}
		return chatterGroups;
	}
	
	public MEP_ChatterGroupDTO convertToDTO(CollaborationGroup obj) {
		MEP_ChatterGroupDTO chatterGroup = new MEP_ChatterGroupDTO();
		chatterGroup.id = obj.id;
		chatterGroup.name = obj.Name;
		chatterGroup.ownerId = obj.OwnerId;
		return chatterGroup;
	}
	
	
	
	
	//
	//
	//Test
	//
	//
	
	@isTest
	private static void test_convertToDTO_SingleObject()
	{
		CollaborationGroup chatterTest = new CollaborationGroup();
		chatterTest.OwnerId = Userinfo.getUserId();
		chatterTest.Name = 'test group';
		chatterTest.CollaborationType = 'Private';
		insert chatterTest;
		
		System.debug(new MEP_ChatterGroupConverter().convertToDTO(chatterTest));
	}
	
	@isTest
	private static void test_convertToDTO_list()
	{
		CollaborationGroup chatterTest = new CollaborationGroup();
		chatterTest.OwnerId = Userinfo.getUserId();
		chatterTest.Name = 'test group';
		chatterTest.CollaborationType = 'Private';
		insert chatterTest;
		
		list <CollaborationGroup> chatterListTest = new list <CollaborationGroup>();
		chatterListTest.add(chatterTest);
		
		System.debug(new MEP_ChatterGroupConverter().convertToDTO(chatterListTest));
	}

}