///
///Channel data provider
///Using on MEP_ManageChannelsController
///
///Author: Maxim Feofilov
public with sharing class MEP_ChannelsProvider {
	public MEP_ChannelFilter filter{get;set;}
	public MEP_ChannelsProvider()
	{
		filter= new MEP_ChannelFilter();
	}
	//return list of Data
	public List<MEP_ChannelDTO> getData()
	{
		MEP_ChannelConverter converter = new MEP_ChannelConverter();
		return converter.convertToDTO(MEP_ChannelDAO.getChannelByFilter(filter));
	}
	//return count of data without filte on resultLimit and resultOffset
	//needed for paginator(total pages)
	public Integer getCount()
	{		
		Integer templimit = filter.resultLimit;
		filter.resultLimit = null;
		Integer tempOffset = filter.resultOffset;
		filter.resultOffset = 0;
		Integer result = getData().size();
		filter.resultLimit =templimit;
		filter.resultOffset = tempOffset;
		return result;
	}
}