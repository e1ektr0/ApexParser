//
//This class is used as a controller for 'MEP_AttachmentsManager' component.
//
//Author: Gennadiy Pervukhin
public with sharing class MEP_AttachmentsManagerController
{
	//
	//Constructors
	//
	public MEP_AttachmentsManagerController()
	{
		//#WARNING : Delete test code
		//this.parentId = 'a0Md0000002oRf4EAE';
		
		//set default values
		this.isEditorActivated = false;
		this.isManagerActivated = false;
		this.attachments = new MEP_AttachmentDTO[0];
	}
	//
	
	//
	//Variables
	//
	private MEP_AttachmentDTO[] attachments;
	private String var_parentId; 
	//
	
	//
	//Properties
	//
	//1 property is for input atribute
	public String parentId
	{
		get
		{
			return this.var_parentId;
		}
		set
		{
			String previousParentId = this.var_parentId;
			this.var_parentId = value;
			if (value != previousParentId)
			{
				this.loadAttachmentsList();
			}
		}
	}
	
	//4 properties are for component
	public Boolean isManagerActivated {get; private set;}
	
	public Boolean isEditorActivated {get; private set;}
	public String editedAttachmentId {get; private set;}
	
	public MEP_AttachmentDTO[] getAttachments()
	{
		return this.attachments;
	}
	//
	
	//
	//Private methods
	//
	private void loadAttachmentsList()
	{
		//we needn't to store attachments Bodies in the view state, and we don't get it to avoid
		//problems with the limit for maximal size of a view state
		String fieldsList = MEP_AttachmentDAO.BASIC_FIELDS_WITHOUT_BODY;
		this.attachments = (new MEP_AttachmentConverter()).convertToDTO(
			MEP_AttachmentDAO.getAttachmentsByParentId(fieldsList, this.var_parentId));
		
		if (this.attachments != null)
		{
			this.isManagerActivated = true;
		}
		else
		{
			this.attachments = new MEP_AttachmentDTO[0];
		}
	}
	//
	
	//
	//Public methods
	//
	public void editAttachment()
	{
		this.editedAttachmentId = Apexpages.currentPage().getParameters().get(
			MEP_RequestParameters.ATTACHMENT_ID);
		this.isEditorActivated = true;
	}
	
	public void addAttachment()
	{
		this.editedAttachmentId = null;
		this.isEditorActivated = true;
	}
	
	public void deleteAttachment()
	{
		String deletedAttachmentId = Apexpages.currentPage().getParameters().get(
			MEP_RequestParameters.ATTACHMENT_ID);
		Attachment deletedAttachment = MEP_AttachmentDAO.getAttachmentById(deletedAttachmentId);
		MEP_SoqlUtils.tryPerformDmlOperation(MEP_DmlOperation.Deleting, deletedAttachment);
		
		this.loadAttachmentsList();
	}
	
	public void updateViewer()
	{
		this.loadAttachmentsList();
	}
	//
	
}