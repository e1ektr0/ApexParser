@isTest(SeeAllData=true)
private class MEP_ChatterMessageGeneratorTests {

    static testMethod void createMessage_SpeakerApproved() 
    {
    	System.assert(MEP_ChatterMessageGenerator.createMessage_SpeakerApproved('Name', 'Name', 'Name').contains('Name'));
    	System.assert(MEP_ChatterMessageGenerator.createMessage_SpeakerApproved(null, null, null)==null);
    }
    static testMethod void createMessage_SpeakerDeclined() 
    {
    	System.assert(MEP_ChatterMessageGenerator.createMessage_SpeakerDeclined('Name', 'Name', 'Name','decliningReason').contains('decliningReason'));
    	System.assert(MEP_ChatterMessageGenerator.createMessage_SpeakerDeclined(null, null, null,'decliningReason')==null);
    }
    static testMethod void createMessage_EventCancelledByRequestor()
    {
    	System.assert(MEP_ChatterMessageGenerator.createMessage_EventCancelledByRequestor('Name', 'Name').contains('Name'));
		System.assert(MEP_ChatterMessageGenerator.createMessage_EventCancelledByRequestor(null, 'decliningReason')==null);
    }
    static testMethod void createMessage_EventSubmittedForApprovals()
    {
    	System.assert(MEP_ChatterMessageGenerator.createMessage_EventSubmittedForApprovals('Name', 'Name').contains('Name'));
    	System.assert(MEP_ChatterMessageGenerator.createMessage_EventSubmittedForApprovals(null, 'decliningReason')==null);
    }
    static testMethod void createMessage_EventApprovedBySystem()
    {
    	System.assert(MEP_ChatterMessageGenerator.createMessage_EventApprovedBySystem('Name').contains('Name'));
    	System.assert(MEP_ChatterMessageGenerator.createMessage_EventApprovedBySystem(null)==null);
    }
    static testMethod void createMessage_EventApprovedByApprover()
    {
    	System.assert(MEP_ChatterMessageGenerator.createMessage_EventApprovedByApprover('Name','Name').contains('Name'));
    	System.assert(MEP_ChatterMessageGenerator.createMessage_EventApprovedByApprover(null,null)==null);
    }
    static testMethod void createMessage_TaskCompleted()
    {
    	System.assert(MEP_ChatterMessageGenerator.createMessage_TaskCompleted('Name','Name').contains('Name'));
    	System.assert(MEP_ChatterMessageGenerator.createMessage_TaskCompleted(null,null)==null);
    }
    static testMethod void createMessage_TaskCancelled()
    {
    	System.assert(MEP_ChatterMessageGenerator.createMessage_TaskCancelled('Name','Name').contains('Name'));
    	System.assert(MEP_ChatterMessageGenerator.createMessage_TaskCancelled(null,null)==null);
    }
    static testMethod void createMessage_EventRejectedByApprover()
    {
    	System.assert(MEP_ChatterMessageGenerator.createMessage_EventRejectedByApprover('Name','Name').contains('Name'));
    	System.assert(MEP_ChatterMessageGenerator.createMessage_EventRejectedByApprover(null,null)==null);
    }
    static testMethod void createMessage_EventCompleted()
    {
    	System.assert(MEP_ChatterMessageGenerator.createMessage_EventCompleted('Name').contains('Name'));
    	System.assert(MEP_ChatterMessageGenerator.createMessage_EventCompleted(null)==null);
    }
    static testMethod void createMessage_EventArchived()
    {
    	System.assert(MEP_ChatterMessageGenerator.createMessage_EventArchived('Name').contains('Name'));
    	System.assert(MEP_ChatterMessageGenerator.createMessage_EventArchived(null)==null);
    }
    
    static testMethod void createMessage_EventPushedBackToRequestor()
    {
    	System.assert(MEP_ChatterMessageGenerator.createMessage_EventPushedBackToRequestor('Name','Name','Name').contains('Name'));
    	System.assert(MEP_ChatterMessageGenerator.createMessage_EventPushedBackToRequestor(null, null, null)==null);
    }
    static testMethod void createMessage_TaskAssigned()
    {
    	System.assert(MEP_ChatterMessageGenerator.createMessage_TaskAssigned('Name','Name',DateTime.now()).contains('Name'));
    	System.assert(MEP_ChatterMessageGenerator.createMessage_TaskAssigned(null, null, null)==null);
    }
    static testMethod void createMessage_TaskReassigned()
    {
    	System.assert(MEP_ChatterMessageGenerator.createMessage_TaskReassigned('Name','Name','Name').contains('Name'));
    	System.assert(MEP_ChatterMessageGenerator.createMessage_TaskReassigned(null, null, null)==null);
    }
    static testMethod void createMessage_TaskForceClosed()
    {
    	System.assert(MEP_ChatterMessageGenerator.createMessage_TaskForceClosed('Name','Name','Name').contains('Name'));
    	System.assert(MEP_ChatterMessageGenerator.createMessage_TaskForceClosed(null, null, null)==null);
    }
    static testMethod void createMessage_RemindAboutReservedDate()
    {
    	MEP_EventDTO eventDTO = new MEP_EventDTO();
    	eventDTO.chatterGroupId = '1';
    	eventDTO.isReservDate = true;
    	eventDTO.startDate = DateTime.Now().addDays(1);
    	System.assert(MEP_ChatterMessageGenerator.createMessage_RemindAboutReservedDate(eventDTO).contains(''+Date.today().daysBetween(eventDTO.startDate.date())));
    	System.assert(MEP_ChatterMessageGenerator.createMessage_RemindAboutReservedDate(null)==null);
    }
    
}