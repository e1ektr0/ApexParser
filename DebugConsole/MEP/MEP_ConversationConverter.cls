public with sharing class MEP_ConversationConverter implements MEP_ConverterFromXML<MEP_ConversationDTO> {
	
	private MEP_PrivateMessageConverter privateMessageConverter = new MEP_PrivateMessageConverter();
	private MEP_UserConverter userConverter = new MEP_UserConverter();
	
	public List<MEP_ConversationDTO> convertToDTOFromXML(Dom.Document doc) {
		List<MEP_ConversationDTO> conversatoionsList = new List<MEP_ConversationDTO>();
		
		if (doc == null) {
			return conversatoionsList;
		}
		
		Dom.Xmlnode root = doc.getRootElement();
		Dom.Xmlnode conversations = root.getChildElement('conversations', null);
		
		if (conversations == null) {
			return conversatoionsList;
		}
		
		for (Dom.Xmlnode conversation : conversations.getChildElements()) {
			conversatoionsList.add(parseConversationSummary(conversation));
		}
		
		if (conversatoionsList.size() > 0) {
			Dom.Xmlnode nextPage = root.getChildElement('nextPageUrl', null);
			if (nextPage.getText() != '') {
				conversatoionsList.get(conversatoionsList.size() - 1).hasMore = true;
			}
		}
		return conversatoionsList;
	}
	
	private MEP_ConversationDTO parseConversationSummary(Dom.Xmlnode conversationSummary) {
		MEP_ConversationDTO conversation = new MEP_ConversationDTO();
		for (Dom.xmlnode node : conversationSummary.getChildElements()) {
			if (node.getName().equals('id')) {
				conversation.id = node.getText();
			} else if (node.getName().equals('read')) {
				conversation.isRead = Boolean.valueOf(node.getText());
			} else if (node.getName().equals('latestMessage')) {
				conversation.latestMessage = privateMessageConverter.parseMessage(node);
			} else if (node.getName().equals('members')) {
				conversation.members.addAll(parseMembers(node));
			}
		}
		return conversation;
	}
	
	private List<MEP_UserDTO> parseMembers(Dom.Xmlnode node) {
		List<MEP_UserDTO> users = new List<MEP_UserDTO>();
		for (Dom.Xmlnode userSummary : node.getChildElements()) {
			users.add(userConverter.getUserFromXml(userSummary));
		}
		return users;
	}
	
	@isTest
	private static void testConverter() {
		String testString = MEP_TestUtils.createTestConverterXML();
		Dom.Document doc = new Dom.Document();
		doc.load(testString);
		
		MEP_ConversationConverter converter = new MEP_ConversationConverter();
		System.debug(converter.convertToDTOFromXML(doc));
	}
}