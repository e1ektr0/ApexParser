///
///Data rpovider for MEP_ManageChatterGroupsController
///
///Author: Maxim Feofilov
public with sharing class MEP_ChatterGroupDataProvider {
	public MEP_EventsFilter filter{get;set;}
	public MEP_ChatterGroupDataProvider()
	{
		filter= new MEP_EventsFilter();
	}
	///return events with chatter group
	///also using filter
	public List<MEP_EventDTO> getData()
	{		
		MEP_EventConverter converter = new MEP_EventConverter();
		return converter.convertToDTO(MEP_EventDAO.getEventsWithChatterGroup(filter));
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