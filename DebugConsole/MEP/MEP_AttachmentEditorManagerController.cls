//
//This class is used as controller for the component which manages the processes
//of start and finish of attachment editor
//
//Author: Gennadiy Pervukhin
public with sharing class MEP_AttachmentEditorManagerController
{
	//
	//Constructors
	//
	public MEP_AttachmentEditorManagerController()
	{
		//#WARNING: Delete test code : Gennadiy Pervukhin
		//this.attachmentId = '00Pd0000002CkJJ';
		//this.parentId = 'a0Md0000002oRf4EAE';
	}
	//
	
	//
	//Properties
	//
	//properties for attributes
	//this property is for attribute and is used in creation mode
	public String parentId
	{
		get;
		set;
	}
	
	//this property is for attribute and is used in editing mode
	public String attachmentId
	{
		get;
		set;
	}
	
	//this property is for component 
	public PageReference getLinkForEditor()
	{
		PageReference reference = Page.MEP_AttachmentEditor;
		reference.getParameters().put(MEP_RequestParameters.ATTACHMENT_ID, attachmentId);
		reference.getParameters().put(MEP_RequestParameters.ATTACHMENT_PARENT_ID, parentId);
		reference.getParameters().put('core.apexpages.devmode.url', '1');
		return reference;
	}
}