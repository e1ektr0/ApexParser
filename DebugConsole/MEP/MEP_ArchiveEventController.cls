///
///Controller of  MEP_ArchiveEvent.page
///On this page user can archive event
///
///Author:Maxim  Feofilov
public with sharing class MEP_ArchiveEventController implements MEP_RemoteActionClient {
    public String eventId{get;set;}
    public MEP_EventDTO event{get;private set;}
    public String defaultEventName{get;set;}
    public void updateEvent()
    {
    	if(!MEP_StringUtils.isNullOrEmpty(eventId))
        	event= new MEP_EventConverter().convertToDTO(MEP_EventDAO.getEventById(eventId));
    	else event = null;
    }
    public void archive()
    {
       MEP_ArchiveUtil.archiveEvent(MEP_EventDAO.getEventById(eventId));
       event=null;
       defaultEventName = null;
    }
}