public with sharing class MEP_CreateEventHeaderController {
    
    public MEP_EventDTO event {get; set;}
    public MEP_StepNumber stepNumber {get; set;}
    public String reservDateStatus {get; set;}
    
    public Pagereference reservDate() {
        if (reservDateStatus != null) {
            event.isReservDate = Boolean.valueOf(reservDateStatus);
        }
        
        return null;
    }

}