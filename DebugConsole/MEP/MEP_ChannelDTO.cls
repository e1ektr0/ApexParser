public with sharing class MEP_ChannelDTO extends MEP_BaseDTO
{
	public String channelCode{get;set;}
	public String channelGroupCode{get;set;}
	public String channelGroupName{get;set;}
	public Boolean workflowInAutoApproveMode{get;set;}
	
	public String getJsonString()
	{
		return String.escapeSingleQuotes(JSON.serialize(this));
	}	
}