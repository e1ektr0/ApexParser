public with sharing class MEP_ConversationDTO extends MEP_BaseDTO {
	
	public MEP_PrivateMessageDTO latestMessage {get; set;}
	public Boolean isRead {get; set;}
	public List<MEP_PrivateMessageDTO> messages {get; set;}
	public Boolean hasMore {get; set;}
	public List<MEP_UserDTO> members {get; set;}
	
	public MEP_ConversationDTO() {
		hasMore = false;
		messages = new List<MEP_PrivateMessageDTO>();
		members = new List<MEP_UserDTO>();
	}
}