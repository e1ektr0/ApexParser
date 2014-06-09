public with sharing class MEP_CalendarEventMeetingDTO
{
	//
	//Constructors
	//
	public MEP_CalendarEventMeetingDTO()
	{		
	}
	//
	
	//
	//Properties
	//
	public String id
	{
		get;
		set;
	}
	
	public String meetingName
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
	
	public String formattedDateTimeRange
	{
		get;
		set;
	}
	
	public MEP_LocationDTO location
	{
		get;
		set;
	}
	
	public String formattedLocation
	{
		get;
		set;
	}
	
	public String eventId
	{
		get;
		set;
	}
	
	public String eventName
	{
		get;
		set;
	}
	
	public String eventVisibility
	{
		get;
		set;
	}
	
	public String eventType
	{
		get;
		set;
	}
	
	public Boolean allDay
	{
		get;
		set;
	}
	
	public String cssClassName
	{
		get;
		set;
	}
	
	public String getJsonString()
	{
		return String.escapeSingleQuotes(JSON.serialize(this));
	}
	//
}