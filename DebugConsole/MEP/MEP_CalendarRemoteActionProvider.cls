public with sharing class MEP_CalendarRemoteActionProvider
{
    //
    //Data types
    //
    public interface IRemoteActionClient
    {
        //This interface is empty and plays the role of attribute for a class.
        //A component or a page which want to call remote actions from 'MEP_CalendarRemoteActionProvider'
        //class should use it as extension. To use 'MEP_CalendarRemoteActionProvider' class as extension
        //a page or a component must have a controller that implements 'IRemoteActionClient' interface
    }
    //
    
    //
    //Constructor
    //
    public MEP_CalendarRemoteActionProvider(IRemoteActionClient client)
    {
    }
    //
    
    //
    //Public static remote methods
    //
    @RemoteAction
    public static List<MEP_CalendarEventMeetingDTO> getCalendarEvents(String serializedFilter)
    {
        //System.debug('getCalendarEvents');
        MEP_CalendarFilter filter;
        try
        {
            System.debug('***** => ' + serializedFilter);
            filter = (MEP_CalendarFilter)JSON.deserialize(serializedFilter, MEP_CalendarFilter.class);
            System.debug('***** => start = ' + filter.startDate);
            System.debug('***** => end = ' + filter.endDate);
        }
        catch (JSONException e)
        {
            filter = null;
            System.debug(e.getMessage());
        }
        
        if (filter != null)
        {
            MEP_CalendarEventMeetingsDataProvider dataProvider = new MEP_CalendarEventMeetingsDataProvider(filter);
            return dataProvider.getDataList();
        }
        return null;
    }
    
    @RemoteAction
    public static List<MEP_EventMeetingSpeakerMappingDTO> getSpeakers(String meetingId)
    {
        //if a meeting belongs an event which is public then we can get speakers for this meeting
        MEP_EventMeetingDetailsDTO meeting = (new MEP_EventMeetingDetailsConverter()).convertToDTO(
            MEP_EventMeetingDAO.getEventMeetingById(meetingId));
        
        if (meeting != null)
        {
            MEP_EventDTO event = (new MEP_EventConverter()).convertToDTO(
                MEP_EventDAO.getEventById(meeting.eventId));
                    
            if (event != null && event.visibility == MEP_EventVisibility.PUBLIC_VISIBILITY)
            {
                return (new MEP_EventMeetingSpeakerMappingConverter()).convertToDTO(
                    MEP_EventMeetingSpeakerMappingDAO.getMappingsByEventMeetingId(meetingId));
            }
        }
        return null;
    }
    //
}