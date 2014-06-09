/*
   Group manager that is specific for chatter groups and events
*/ 
public with sharing class MEP_ChatterGroupEventManagerImpl implements MEP_GroupManager<MEP_EVENTS__c> {
	
	//TODO: 
	private final String EMAIL_BODY = 'The event with this name already exist, event name - ';
	private final String EMAIL_SUBJECT = 'The event already exist';
	
	private MEP_OAuthHolder holder;
	private MEP_AdminUtils adminUtil;
	
	public MEP_ChatterGroupEventManagerImpl() {
		adminUtil = new MEP_AdminUtils();
	}
	
	public MEP_ChatterGroupEventManagerImpl(MEP_OAuthHolder holder) {
		this.holder = holder;
		adminUtil = new MEP_AdminUtils(holder);
	}
	
	/*
		Ceate a group for specific event: the group name is equal to event name;
		Should be used administrator only!
	*/ 
	public String createGroup(MEP_EVENTS__c mepEvent) {
		if (MEP_ChatterDAO.isGroupNameExist(mepEvent.EVENT_NAME__c)) {
			String email = null;
			if (MEP_ApplicationSettings.isProduction()) {
				MEP_Admin_User__c admin = MEP_ApplicationSettings.getApplicationAdmin();
				if (admin != null) {
					User adminUser = MEP_UserDAO.getUserByUserName(admin.login__c);
					if (adminUser != null) {
						email = adminUser.Email;
					}
				}
			} else {
				email = MEP_ApplicationSettings.getStringValue('TEST_USER_EMAIL');
			}
			
			if (email != null) {
				MEP_EmailUtils.sendEmail(email, EMAIL_SUBJECT, EMAIL_BODY + mepEvent.EVENT_NAME__c);
			}
			
			return null;
		}
		
		CollaborationGroup newGroup = new CollaborationGroup();
		newGroup.CollaborationType = 'Private';
		//newGroup.Name = mepEvent.EVENT_NAME__c;
		newGroup.Name = MEP_ChatterUtils.generateChatterGroupName(mepEvent.EVENT_NAME__c);
		if (MEP_UserDAO.getCurrentChatterUserId() != null) {
			newGroup.OwnerId = MEP_UserDAO.getCurrentChatterUserId();
		}
		
		
		if (mepEvent.REQUESTED_BY_USER__c != null) {
			User chatterUser = MEP_UserDAO.getUserByMepUserId(mepEvent.REQUESTED_BY_USER__c);
			if (chatterUser != null) {
				newGroup.OwnerId = chatterUser.Id;
			}
		}
		//newGroup.Description = mepEvent.Meeting_Purpose__c;

		String resultJSON = adminUtil.createChatterGroup(newGroup);
		String groupId = MEP_JSONUtils.getTextByTokenName(resultJSON, 'id'); 
		if (groupId != null) {
			return groupId;
		}
		
		return null;
	}
	
	/*
		Delete a group.
		Should be used administrator only!
		
		Important!
		the param archiveContentType must be application/msword, text/plain or pdf 
	*/
	public void deleteGroup(String groupId, String archiveContentType) {
		if (groupId != null) {
			Blob archive = null;
			if (archiveContentType != null) {
				
				MEP_ChatterGroupArchiveManagerImpl am = null;
				if (holder != null) {
					am = new MEP_ChatterGroupArchiveManagerImpl(groupId, holder);
				} else {
					am = new MEP_ChatterGroupArchiveManagerImpl(groupId);
				}
				
				if (archiveContentType.contains('pdf')) {
					archive = am.createArchiveInPDF();
				} else {
					archive = am.createArchive();
				}
				
			}
			//Dluzyanov todo DAO
			//CollaborationGroup chatterGroup = Database.query('SELECT g.id FROM CollaborationGroup g WHERE g.id = ' + groupId);
			try {
				CollaborationGroup chatterGroup = [select Id from CollaborationGroup where Id = :groupId];
				MEP_SoqlUtils.performDmlOperation(MEP_DmlOperation.Deleting, chatterGroup);
				insertAttachment(groupId, archive, archiveContentType);
			} catch (System.Queryexception e) {
				//if event don't have chatter group.
			}

		}
	}
	
	public String assignPerson(String groupId, String userId) {
		//return MEP_ChatterDAO.addChatterUserToGroup(groupId, userId);
		return adminUtil.addChatterUserToGroup(groupId, userId);
	}
	
	public String assignPerson(CollaborationGroupMember member) {
		return adminUtil.addChatterUserToGroup(member);
	}
	
	public String unassignPerson(String groupId, String userId) {
		//return MEP_ChatterDAO.removeUserFromChatterGroup(groupId, userId);
		return adminUtil.removeUserFromChatterGroup(groupId, userId);
	}
	
	public String updateGroup(CollaborationGroup chatterGroup) {
		return adminUtil.updateChatterGroup(chatterGroup);
	}
	
	private void insertAttachment(String groupId, Blob body, String archiveContentType) {
		MEP_EVENTS__c event = MEP_EventDAO.getEventByChatterGroupId(groupId);
		if (event != null && body != null) {
			
			Attachment attach = new Attachment();
			attach.Body = body;
			attach.Name = event.EVENT_NAME__c;
			if (archiveContentType.contains('pdf')) {
				attach.ContentType = 'application/pdf';
			} else {
				attach.ContentType = archiveContentType;
			}
			
			attach.ParentId = event.Id;
			MEP_SoqlUtils.performDmlOperation(MEP_DmlOperation.Inserting,attach);
			event.SALESFORCE_CHATTER_GROUP_REFERENCE__c = null;
			MEP_EventDAO.updateEvent(event);
		}
	}

}