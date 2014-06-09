///
///Class for work with Attachment
///
///
///Author: Maxim Feofilov
public with sharing class MEP_AttachmentDAO
{
	//
	//Constants
	//
	private static final String ATTACHMENT_TABLE = 'Attachment';
	public static final String BASIC_FIELDS = 'Id, ParentId, Name, IsPrivate, Description, '
		+ 'ContentType, BodyLength, Body';
	public static final String BASIC_FIELDS_WITHOUT_BODY = 'Id, ParentId, Name, IsPrivate, Description, '
		+ 'ContentType, BodyLength';
	///
	///Create new attachment with unique parentId and Name
	///if attachment with parentId and Name alredy exist,  
	///update body and content type and then return this attachment
	///
	public static Attachment createAttachment(String parentID, String name, Blob body, String contenType)
	{
		Attachment attach;
	 	List<Attachment> attachs =[SELECT Id,parentID,Name,ContentType FROM Attachment WHERE ParentId=:parentID AND name=:name limit 1];
	 	if(attachs!=null&&attachs.size()>0)
	 		attach = attachs[0];
	 	else
	 	{
	 		attach = new Attachment();
			attach.ParentId = parentID;
			attach.Name = name;
		}
		attach.ContentType = contenType;
		attach.Body = body;
		MEP_SoqlUtils.performDmlOperation(MEP_DmlOperation.Upserting, attach);
		return attach;
	}
	
	public static Attachment getAttachmentById(String fieldsList, String attachmentId)
	{
		if (MEP_StringUtils.isNullOrEmpty(fieldsList) || MEP_StringUtils.isNullOrEmpty(attachmentId))
		{
			return null;
		}
		
		MEP_SoqlQueryBuilder queryBuilder = new MEP_SoqlQueryBuilder(fieldsList, ATTACHMENT_TABLE);
		queryBuilder.condition = 'Id = \'' + attachmentId + '\'';
		return (Attachment)MEP_SoqlUtils.performSingleResultQuery(queryBuilder);
	}
	
	public static Attachment getAttachmentById(String attachmentId)
	{
		return getAttachmentById(BASIC_FIELDS, attachmentId);
	}
	
	public static Attachment[] getAttachmentsByParentId(String fieldsList, String parentId)
	{
		if (MEP_StringUtils.isNullOrEmpty(parentId))
		{
			return null;
		}
		
		MEP_SoqlQueryBuilder queryBuilder = new MEP_SoqlQueryBuilder(fieldsList, ATTACHMENT_TABLE);
		queryBuilder.condition = 'ParentId = \'' + parentId + '\'';
		queryBuilder.setOrderByBlock('Name', MEP_SortingOrder.Ascending);
		return MEP_SoqlUtils.performQuery(queryBuilder);
	}
	
	public static Attachment[] getAttachmentsByParentId(String parentId)
	{
		return getAttachmentsByParentId(BASIC_FIELDS, parentId);
	}
	
	public static void addStringToBody(String attachId, String value)
	{
		Attachment attach = MEP_AttachmentDAO.getAttachmentById(attachId);
   		attach.Body = Blob.valueOf(attach.Body.toString()+value);
   		MEP_SoqlUtils.performDmlOperation(MEP_DmlOperation.Updating, attach);
	}
}