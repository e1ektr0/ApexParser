public with sharing class MEP_ChannelConverter implements MEP_Converter<MEP_ChannelDTO, MEP_CHANNELS__c> {
	
	public List<MEP_ChannelDTO> convertToDTO(List<MEP_CHANNELS__c> objsList) {
        List<MEP_ChannelDTO> convertedChannels = new List<MEP_ChannelDTO>();
        for (MEP_CHANNELS__c obj : objsList) {
            convertedChannels.add(convertToDTO(obj));
        }
        return convertedChannels;
    }
    
    public MEP_ChannelDTO convertToDTO(MEP_CHANNELS__c channel) {
		MEP_ChannelDTO dto = new MEP_ChannelDTO();
		dto.id = channel.Id;
		dto.name = channel.CHANNEL_NAME__c;
		try
		{
			dto.WorkflowInAutoApproveMode = channel.WORKFLOW_IN_AUTO_APPROVE_MODE__c;
			dto.ChannelGroupCode = channel.GROUP_CODE__c;
			dto.ChannelCode = channel.CHANNEL_CODE__c;
			dto.ChannelGroupName = channel.GROUP_NAME__c;			
		}
		catch(Exception ex)
    	{System.debug('Error!');}	
		return dto;
	}
}