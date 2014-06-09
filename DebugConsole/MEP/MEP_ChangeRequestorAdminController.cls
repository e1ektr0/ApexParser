///
///Controller for MEP_ChangeRequestorAdmin.page
///On this page user can change requestor for event
///
///Author:Maxim Feofilov
public with sharing class MEP_ChangeRequestorAdminController {
        public String  EventId{get;set;}
    public String RequestorId{get;set;}
    public String Error{get;set;}
    ///save new requestor for events
    public PageReference Save()
    {
        MEP_EventDAO.setNewRequestor(EventId, RequestorId);
        return null;
    }
    ///get events for autocomplet
        @RemoteAction
    public static List<MEP_EventDTO> getEvents(String partialCityName)
    {
        MEP_EventConverter eventConverter = new MEP_EventConverter();
        return eventConverter.convertToDTO(MEP_EventDAO.getEventsForChangeRequestor(10,partialCityName));
    }
    ///get new requestors for autocomplet
    @RemoteAction
    public static List<MEP_UserDTO> getRequestors(String partialName, String requestedChannelCode)
    {
        MEP_UserConverter userConverter = new MEP_UserConverter();
        List<MEP_USERS__c> requestors = MEP_MepUserDAO.getMepUsersByPartialName(partialName);
        return userConverter.convertToDTO(requestors);
    }
        
}