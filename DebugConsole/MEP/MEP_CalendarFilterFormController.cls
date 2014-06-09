public with sharing class MEP_CalendarFilterFormController implements MEP_RemoteActionClient
{
    //
    //Constructors
    //
    public MEP_CalendarFilterFormController()
    {
        this.initializeListOfEventsViews();
        this.initializeListOfEventTypes();
        
        this.selectedEventsView = DEFAULT_EVENTS_VIEW;
        this.selectedEventType = ALL_EVENT_TYPES;
    }
    //
    
    //
    //Varibales and constants
    //
    private static final String SEPARATOR_FOR_SPEAKERS_IDS = ',';
    private static final String DEFAULT_EVENTS_VIEW = MEP_CalendarEventsViewType.ALL_EVENTS;
    private static final String ALL_EVENT_TYPES = 'All';
    //
    
    //
    //Properties
    //
    //properties for component's attributes
    public MEP_CalendarFilter filter
    {
        get;
        set;
    }
    
    public MEP_FilterFormBinder binder
    {
        get;
        set;
    }
    
    //properties for input controls
    //keyword search
    public String searchPattern
    {
        get;
        set;
    }
    
    //events view
    public List<SelectOption> listOfEventsViews
    {
        get;
        set;
    }
    
    public String selectedEventsView
    {
        get;
        set;
    }
    //
    
    //channel
    public String channelId
    {
        get;
        set;
    }
    
    public List<Selectoption> getChannels()
    {
	    List<SelectOption> values = new List<SelectOption>();
	    values.add(new SelectOption('', '---'));
	    for (MEP_CHANNELS__c channel : MEP_ChannelDAO.getAllChannels())
	    {
	        values.add(new SelectOption(channel.Id, channel.CHANNEL_CODE__c + ' (' + channel.CHANNEL_NAME__c + ')'));
    	}
    	return values;
    }
    
    //event type
    public List<SelectOption> listOfEventTypes
    {
        get;
        private set;
    }
    
    public String selectedEventType
    {
        get;
        set;
    }
    //
    
    //speakers
    public String selectedSpeakersIds
    {
        get;
        set;
    }
    //
    
    //location
    public String country
    {
        get;
        set;
    }
    
    public String state
    {
        get;
        set;
    }
    
    public String city
    {
        get;
        set;
    }
    //
    
    
    //
    //Private methods
    //
    private void initializeListOfEventsViews()
    {
        this.listOfEventsViews = new List<SelectOption>();
        
        for (String eventsViewType : MEP_CalendarEventsViewType.ALL_TYPES)
        {
            this.listOfEventsViews.add(new SelectOption(eventsViewType, eventsViewType));
        }
    }
    
    private void initializeListOfEventTypes()
    {
        this.listOfEventTypes = new List<SelectOption>();
        
        this.listOfEventTypes.add(new SelectOption(ALL_EVENT_TYPES, ALL_EVENT_TYPES));
        for (String eventType : MEP_EventType.ALL_TYPES)
        {
            this.listOfEventTypes.add(new selectOption(eventType, eventType));              
        }
    }
    
    private void setFilter()
    {
        if (this.filter != null)
        {
            this.filter.searchPattern = this.searchPattern;
            this.filter.eventsView = this.selectedEventsView;
            this.filter.channelId = this.channelId;
            
            if (this.selectedEventType == ALL_EVENT_TYPES)
            {
                this.filter.eventType = null;
            }
            else
            {               
                this.filter.eventType = this.selectedEventType;
            }
            
            //the next expression returns an array with one value: ''.split(',')
            if (this.selectedSpeakersIds != null && this.selectedSpeakersIds != '')
            {
                this.filter.speakers = this.selectedSpeakersIds.split(SEPARATOR_FOR_SPEAKERS_IDS);
            }
            else
            {
                this.filter.speakers = null;
            }
            
            this.filter.location = new MEP_LocationDTO(this.country, this.state, this.city);
        }
    }
    
    private void generateEvent()
    {
        if (this.binder != null)
        {
            this.binder.onFilterUpdated();
        }
    }
    //
    
    //
    //Public methods
    //
    public void applyFilter()
    {
        this.setFilter();
        this.generateEvent();
    }
    
    public void clearFilter()
    {
        this.searchPattern = null;
        this.selectedEventsView = DEFAULT_EVENTS_VIEW;
        this.channelId = null;
        this.selectedEventType = null;
        this.selectedSpeakersIds = null;
        this.country = null;
        this.state = null;
        this.city = null;
        
        this.setFilter();
        this.generateEvent();
    }
    //
    
    //
    //Remote actions
    //
    //These remote action were moved to MEP_RemoteActionProvider
    /*@RemoteAction
    public static List<MEP_LocationDTO> getCountries(String partialCountryName)
    {
        return MEP_LocationDAO.getCountries(partialCountryName);
    }
    
    @RemoteAction
    public static List<MEP_LocationDTO> getStates(String country, String partialStateName)
    {
        return MEP_LocationDAO.getStates(country, partialStateName);
    }
    
    @RemoteAction
    public static List<MEP_LocationDTO> getCities(String country, String state, String partialCityName)
    {
        return MEP_LocationDAO.getCities(country, state, partialCityName);
    }*/
    //
}