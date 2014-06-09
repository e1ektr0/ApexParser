//
//This class is used as DTO for 'Attachment' object
//
//Author: Gennadiy Pervukhin
public with sharing class MEP_AttachmentDTO extends MEP_BaseDTO
{
	//
	//Properties
	//
	public String parentId {get; set;}
	public Blob body {get; set;}
	public String description {get; set;}
	
	public Integer size {get; set;}
	public String formattedSize
	{
		get
		{
			return MEP_AttachmentUtils.formatFileSize(this.size);
		}
	}
	
	public String type {get; set;}
	//
}