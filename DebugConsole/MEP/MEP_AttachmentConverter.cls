public with sharing class MEP_AttachmentConverter
	implements MEP_Converter<MEP_AttachmentDTO, Attachment>, MEP_ConverterDTOtoEntity<Attachment, MEP_AttachmentDTO>
{
	//
	//Public methods
	//
	//implementation of 'MEP_Converter' interface
	public MEP_AttachmentDTO convertToDTO(Attachment dbAttachment)
	{
		if (dbAttachment == null)
		{
			return null;
		}
		
		MEP_AttachmentDTO attachmentDTO = new MEP_AttachmentDTO();
		attachmentDTO.id = dbAttachment.Id;
		attachmentDTO.name = dbAttachment.Name;
		attachmentDTO.parentId = dbAttachment.ParentId;
		attachmentDTO.size = dbAttachment.BodyLength;
		attachmentDTO.description = dbAttachment.Description;
		attachmentDTO.type = MEP_AttachmentUtils.getFileType(dbAttachment.Name);
		
		try
		{
			attachmentDTO.body = dbAttachment.Body;
		}
		catch (System.SObjectException e)
		{
			attachmentDTO.body = null;
		}
		
		return attachmentDTO;
	}
	 
	public List<MEP_AttachmentDTO> convertToDTO(List<Attachment> dbAttachments)
	{
		if (dbAttachments == null)
		{
			return null;
		}
		
		List<MEP_AttachmentDTO> attachments = new List<MEP_AttachmentDTO>();
		for (Attachment dbAttachment : dbAttachments)
		{
			attachments.add(convertToDTO(dbAttachment));
		}
		return attachments;
	}
	
	//implementation of 'MEP_ConverterDTOtoEntity' interface
	public Attachment convertDTOtoEntity(MEP_AttachmentDTO attachmentDto)
	{
		if (attachmentDto == null)
		{
			return null;
		}
		
		Attachment dbAttachment = new Attachment();
		//dbAttachment.Id = attachmentDto.id;
		dbAttachment.Name = attachmentDto.name;
		dbAttachment.ParentId = attachmentDto.parentId;
		dbAttachment.Description = attachmentDto.description;
		dbAttachment.Body = attachmentDto.body;
		
		return dbAttachment;
	}
	
	public List<Attachment> convertDTOtoEntity(List<MEP_AttachmentDTO> listOfDto)
	{
		if (listOfDto == null)
		{
			return null;
		}
		
		List<Attachment> databaseAttachments = new List<Attachment>();
		for (MEP_AttachmentDTO attachmentDto : listOfDto)
		{
			databaseAttachments.add(convertDTOtoEntity(attachmentDto));
		}
		
		return databaseAttachments;
	}
}