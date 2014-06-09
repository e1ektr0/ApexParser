public with sharing class MEP_CalendarEventMeetingsDataProvider implements MEP_DataProvider<MEP_CalendarEventMeetingDTO>
{
	//
	//Constructors
	//
	public MEP_CalendarEventMeetingsDataProvider(MEP_CalendarFilter filter)
	{
		this.filter = filter;
	}
	//
	
	//
	//Properties
	//
	public MEP_CalendarFilter filter
	{
		get;
		set;
	}
	//
	
	//
	//Public methods
	//
	//implementation of 'MEP_DataProvider' interface
	public List<MEP_CalendarEventMeetingDTO> getDataList()
	{
		MEP_CalendarEventMeetingConverter converter = new MEP_CalendarEventMeetingConverter();
		
		return converter.convertToDTO(MEP_EventMeetingDAO.getCalendarEventMeetings(this.filter));
	}
	
	
	
	
	

}