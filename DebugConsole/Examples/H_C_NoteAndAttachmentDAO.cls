//
//This class provides access to 'NoteAndAttachment' object
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (9-08-2013)
public class H_C_NoteAndAttachmentDAO
{
	//
    //Variables and constants
    //
    private static String BASIC_FIELDS = 'Id, Title, IsNote, CreatedDate, LastModifiedDate, '
    	+ 'ParentId, Parent.Name, OwnerId, Owner.Name, Owner.FirstName, Owner.LastName, '
    	+ 'CreatedById, CreatedBy.Name';
    private static String NOTES_AND_ATTACHMENTS_RELATIONSHIP_NAME = 'NotesAndAttachments';
    //
    
    //
    //Public static methods
    //
    public static NoteAndAttachment[] getNotesAndAttachmentsByAccountId(
    	String accountId, Boolean includeObjectsOfChildAccounts)
    {
    	//initialize and fill query builder for child relationship
    	H_C_SoqlQueryBuilder childRelationshipQueryBuilder = new H_C_SoqlQueryBuilder(
    		BASIC_FIELDS, NOTES_AND_ATTACHMENTS_RELATIONSHIP_NAME);
    	
    	//get child objects through 'Account' object
    	return H_C_AccountDAO.getChildObjectsByAccountId(accountId,
    		childRelationshipQueryBuilder, includeObjectsOfChildAccounts);
    }
    //
}