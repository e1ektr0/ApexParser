//this class simulates enumeration
//it is more comfortable to use this class instead of enumeration because some values consist of some words 
public with sharing class MEP_CalendarEventsViewType
{
	public static final String ALL_EVENTS = 'All Events';
	public static final String APPROVED_EVENTS = 'Approved Events';
	//public static final String SAVED_DATES = 'Saved Dates';
	public static final String EVENTS_WITH_RESERVED_DATES = 'Reserve the Date';
	
	public static final String[] ALL_TYPES;
		
	static
	{
		ALL_TYPES = new String[] { ALL_EVENTS, APPROVED_EVENTS,	EVENTS_WITH_RESERVED_DATES };
	}
}