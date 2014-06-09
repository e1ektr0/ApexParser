///
///Controller class for MEP_CreateChatterGroup.page
///On this page user can create chatter group for event 
///
///Author: Maxim Feofilov
public with sharing class MEP_CreateChatterGroupController   implements MEP_RemoteActionClient {
    public String eventId{get;set;}
    public MEP_EventDTO event{get;private set;}
    public String defaultEventName{get;set;}
    public Boolean renameIsVisibility{get;private set;}
    private MEP_AdminUtils adminUtil;
    public void updateEvent()
    {
    	
        if(!MEP_StringUtils.isNullOrEmpty(eventId))
        {
            event= new MEP_EventConverter().convertToDTO(MEP_EventDAO.getEventById(eventId));
            newEventName= event.name;
            adminUtil = new MEP_AdminUtils();
        }
        else
        event = null;
    }
    public String newEventName{get;set;}
    ///try create chatter group for event
    public void create()
    {       
        //MEP_ChatterGroupEventManagerImpl chatteGroupEventMannager = new MEP_ChatterGroupEventManagerImpl();
        //chatteGroupEventMannager.createGroup(mepEvent);
        MEP_EVENTS__c mepEvent = MEP_EventDAO.getEventById(eventId);
        mepEvent.Event_Name__c = newEventName;
        String newNameOfChatterGroup ;
      	if(mepEvent.Event_Name__c.length()>40)//max length of chatter name = 40 symbols
           newNameOfChatterGroup=mepEvent.Event_Name__c.substring(0,40);
        else
           newNameOfChatterGroup= mepEvent.Event_Name__c;
       
        if(MEP_ChatterDAO.isGroupNameExist(newNameOfChatterGroup))
        {   
            renameIsVisibility = true;
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Chatter group with this name alredy exist!'));
            return;
        }
        CollaborationGroup newGroup = new CollaborationGroup();
        newGroup.CollaborationType = 'Private';
       	newGroup.Name = newNameOfChatterGroup; 
        if (MEP_UserDAO.getCurrentChatterUserId() != null) {
            newGroup.OwnerId = MEP_UserDAO.getCurrentChatterUserId();
        }
        if (mepEvent.REQUESTED_BY_USER__c != null) {
            User chatterUser = MEP_UserDAO.getUserByMepUserId(mepEvent.REQUESTED_BY_USER__c);
            if (chatterUser != null) {
                newGroup.OwnerId = chatterUser.Id;
            }
        }
        String resultJSON = adminUtil.createChatterGroup(newGroup);
        String groupId = MEP_JSONUtils.getTextByTokenName(resultJSON, 'id'); 
        if (groupId == null) {
            renameIsVisibility=true;
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,resultJSON));
            return;
        }
        mepEvent.SALESFORCE_CHATTER_GROUP_REFERENCE__c = groupId;
        mepEvent.Event_Name__c=newEventName;
        MEP_SoqlUtils.performDmlOperation(MEP_DMLOperation.Updating, mepEvent);
        eventId = null;
        defaultEventName = null;
        updateEvent();
    }
}