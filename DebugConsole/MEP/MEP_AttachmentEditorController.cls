//
//This class is used as a controller for 'MEP_AttachmentEditor' component which can
//be used in 2 different modes: editing and creation of any attachment
//
//Author: Gennadiy Pervukhin
public with sharing class MEP_AttachmentEditorController
{
	//
	//Constructors
	//
	public MEP_AttachmentEditorController()
	{
		this.loadRequestParameters();
		this.loadData();
		this.editorState = INITIAL_STATE;
	}
	//
	
	//
	//Variables
	//
	private static final MEP_AttachmentConverter attachmentConverter = new MEP_AttachmentConverter();
	private String parentId;
	private String attachmentId;
	
	private static final String INITIAL_STATE = 'initialState';
	private static final String ATTACHMENT_UPDATED = 'attachmentUpdated';
	private static final String ATTACHMENT_CREATED = 'attachmentCreated';
	private static final String OPERATION_FAILED = 'operationFailed';
	//
	
	//
	//Properties
	//
	public MEP_AttachmentDTO currentAttachment
	{
		get;
		private set;
	}
	
	public Boolean isEditingModeActive
	{
		get;
		private set;
	}
	
	public String editorState
	{
		get;
		private set;
	}
	//
	
	//
	//Private methods
	//
	private void loadRequestParameters()
    {
    	this.attachmentId = Apexpages.currentPage().getParameters().get(MEP_RequestParameters.ATTACHMENT_ID);
    	this.parentId = Apexpages.currentPage().getParameters().get(MEP_RequestParameters.ATTACHMENT_PARENT_ID);
    }
    
    private void loadData()
    {
    	if (!MEP_StringUtils.isNullOrEmpty(this.attachmentId))
		{
			//we needn't to store attachment Body in the view state, and we don't get it to avoid
			//problems with the limit for maximal size of a view state
			this.currentAttachment = attachmentConverter.convertToDTO(MEP_AttachmentDAO.getAttachmentById(
				MEP_AttachmentDAO.BASIC_FIELDS_WITHOUT_BODY, this.attachmentId));
			this.isEditingModeActive = true;
		}
    	else if (!MEP_StringUtils.isNullOrEmpty(this.parentId))
		{
			this.currentAttachment = new MEP_AttachmentDTO();
			this.currentAttachment.parentId = this.parentId;
			this.isEditingModeActive = false;
		}
    }
	
	private Boolean tryUpdateAttachment()
	{
		Boolean isUpdatingSuccessful = false;
		if (MEP_Validators.validateUpdatedAttachment(this.currentAttachment))
		{
			Attachment updatedAttachment = MEP_AttachmentDAO.getAttachmentById(this.attachmentId);
			updatedAttachment.Name = this.currentAttachment.name;
			updatedAttachment.Description = this.currentAttachment.description;
			
			isUpdatingSuccessful = MEP_SoqlUtils.tryPerformDmlOperation(
				MEP_DmlOperation.Updating, updatedAttachment);
		}
		
		if (isUpdatingSuccessful)
		{
			this.editorState = ATTACHMENT_UPDATED;
		}
		else
		{
			this.editorState = OPERATION_FAILED;
		}
		return isUpdatingSuccessful;
	}
	
	private Boolean tryAddAttachment()
	{
		Boolean isAdditionSuccessful = false;
		if (MEP_Validators.validateNewAttachment(this.currentAttachment))
		{		
			Attachment newAttachment = attachmentConverter.convertDTOtoEntity(this.currentAttachment);
			isAdditionSuccessful = MEP_SoqlUtils.tryPerformDmlOperation(
				MEP_DmlOperation.Inserting, newAttachment);
		}
		
		if (isAdditionSuccessful)
		{
			this.editorState = ATTACHMENT_CREATED;
		}
		else
		{
			this.editorState = OPERATION_FAILED;
		}
		return false;
	}
	//
	
	//
	//Public methods
	//
	public void applyChanges()
	{
		//perform operation
		if (this.isEditingModeActive)
		{
			this.tryUpdateAttachment();
		}
		else
		{
			this.tryAddAttachment();
		}
		
		//we should clear the Body of the current attachment in the local variable, because we can
		//go out of the limit for maximal size of view state
		this.currentAttachment.body = null;
	}
	//
}