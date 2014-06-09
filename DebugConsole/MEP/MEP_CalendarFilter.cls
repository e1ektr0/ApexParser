public with sharing class MEP_CalendarFilter
{
	//
	//Constructors
	//
	public MEP_CalendarFilter()
	{
		//set default values
		this.eventsView = MEP_CalendarEventsViewType.ALL_EVENTS;
	}
	
	//
	//Properties
	//
	public String searchPattern
	{
		get;
		set;
	}
	
	public String eventsView
	{
		get;
		set;
	}
	
	public String channelId
	{
		get;
		set;
	}
	
	public String eventType
	{
		get;
		set;
	}
	
	public MEP_LocationDTO location
	{
		get;
		set;
	}
	
	public List<String> speakers
	{
		get;
		set;
	}
	
	public DateTime startDate
	{
		get;
		set;
	}
	
	public DateTime endDate
	{
		get;
		set;
	}
	//
}