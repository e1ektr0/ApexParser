public with sharing class MEP_CreateEventPageController implements MEP_CalendarRemoteActionProvider.IRemoteActionClient {
        
    public MEP_EventDTO event {get; set;}
    public MEP_StepNumber stepNumber {get; set;}
    public String reservDateStatus {get; set;}
    public Boolean allowCreateEvent {get; set;}
    
    //public String errorMessage {get; set;}
    
    public MEP_CreateEventPageController() {
        allowCreateEvent = false;
        String eventId = Apexpages.currentPage().getParameters().get('id');
        if (eventId == null) {
            event = new MEP_EventDTO();
            String mepUserId = MEP_MepUserDAO.getCurrentMepUserId();
            if (mepUserId != null) {
                event.requestedById = mepUserId;
                if (MEP_MepUserDAO.getMepUserById(mepUserId).BUSINESS_UNIT_CODE__c != null) {
                    allowCreateEvent = true;
                } else {
                    MEP_MessagesManager.addInfoMessage('You are not associated to any Business unit. Please contact system administrator for assistance.');
                }
            }
            //ONLY FOR TEST!!!!
            //event.meetings.addAll(getGenerateMeetings());
        } else {
            event = new MEP_EventConverter().convertToDTO(MEP_EventDAO.getEventById(eventId));
        }
        
        
        if (stepNumber == null) {
            stepNumber = new MEP_StepNumber(1);
        }
        //ONLY FOR TEST!!!!
                //event.name = 'test event';
                //stepNumber.num = 2;
    }
    
    public Pagereference reservDate() {
        if (reservDateStatus != null) {
            event.isReservDate = Boolean.valueOf(reservDateStatus);
        }
        
        return null;
    }
        

    //ONLY FOR TEST!!!!
    private List<MEP_EventMeetingDTO> getGenerateMeetings() {
        List<MEP_EventMeetingDTO> meetings = new List<MEP_EventMeetingDTO>();
        for (Integer i = 0; i < 5; i++) {
                MEP_EventMeetingDTO meeting = new MEP_EventMeetingDTO();
                meeting.name = 'Meeting ' + i;
                meetings.add(meeting);
        }
        return meetings;
    }
}