public with sharing class MEP_CreateEventStep1Component implements MEP_RemoteActionClient {
        
    public MEP_StepNumber step {get; set;}
    private MEP_EventDTO event;
    
    public MEP_UserDTO currentUser {get;set;}
    public MEP_UserDTO otherRequestor {get;set;}
    public Boolean hasOtherRequestor {get;set;}
    public List<Selectoption> eventTypes {get;set;}
    public Boolean showEventType {get; private set;}
        
    public MEP_CreateEventStep1Component() {
        showEventType = false;
        hasOtherRequestor = false;
        otherRequestor = new MEP_UserDTO();
        if (currentUser == null) {
            String mepUserId = MEP_MepUserDAO.getCurrentMepUserId();
            if (mepUserId != null) {
                currentUser = new MEP_UserConverter().convertToDTO(MEP_MepUserDAO.getMepUserById(mepUserId));
            }
        }

        eventTypes = new List<Selectoption>();
        MEP_ROLES__c[] roles = MEP_UserRoleDAO.getCurrentUserRoles();
        if (MEP_RoleUtils.hasRoles(roles, new String[] { MEP_RoleKey.GATEKEEPER, MEP_RoleKey.BIZADMIN, MEP_RoleKey.MANAGER }, false)) {
            eventTypes.add(new Selectoption(MEP_EventType.REGULAR_EVENT , MEP_EventType.REGULAR_EVENT));
            eventTypes.add(new Selectoption(MEP_EventType.MEDIA_EVENT , MEP_EventType.MEDIA_EVENT));
            eventTypes.add(new Selectoption(MEP_EventType.QUARTERLY_EVENT , MEP_EventType.QUARTERLY_EVENT));
            showEventType = true;
        }
    }
        
    public Pagereference step2() {
        if (step != null 
                && MEP_Validators.eventValidate(event)) {
            if (event.Id != null) {
                MEP_EventDAO.updateEvent(event);
            }
            step.num = 2;
        }
        return null;
    }
    
    public MEP_EventDTO getEvent() {
        return event;
    }
    
    public void setEvent(MEP_EventDTO event) {
        this.event = event;
        if (event != null) {
            if (event.requestedOnBehalfOf != null && event.requestedOnBehalfOf.length() != 0) {
                hasOtherRequestor = true;
                otherRequestor = new MEP_UserConverter()
                    .convertToDTO(MEP_MepUserDAO.getMepUserById(event.requestedOnBehalfOf));
            }
        }
    }
}