//
//This class contains configuration parameters for the mechanism which manages
//account related objects.
//Used abbreviations:
// - ARO means 'Account-Related Object'
// - AROM means 'Account-Related Object Management'
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (30-05-2013)
public class H_C_AROM_Configurator
{
    //
    //Variables and constants
    //
    private static Map<String, ARO_Metadata> mapOfMetadata = new Map<String, ARO_Metadata>();
    
    //
    //Private static methods
    //
    private static ARO_Metadata tryCreateMetadata(String realObjectName)
    {
    	ARO_Metadata metadata = null;
    	if (realObjectName == 'Opportunity')
    	{
	        //1) create metadata for Opportunity object
	        metadata = new ARO_Metadata();
	        metadata.realObject = 'Opportunity';
	        metadata.realObject_ReferenceToAccount = 'AccountId';
	        metadata.realObject_RelationshipWithAccount = 'Account';
	        metadata.serviceObject = 'H_C_AccountOpportunity__c';
	        metadata.serviceObject_ReferenceToAccount = 'Account__c';
	        metadata.serviceObject_ReferenceToRealObject = 'Opportunity__c';
	        metadata.serviceObject_RelationshipWithRealObject = 'Opportunity__r';
    	}
        else if (realObjectName == 'Contact')
    	{
	        //2) create metadata for Contact object
	        metadata = new ARO_Metadata();
	        metadata.realObject = 'Contact';
	        metadata.realObject_ReferenceToAccount = 'AccountId';
	        metadata.realObject_RelationshipWithAccount = 'Account';
	        metadata.serviceObject = 'H_C_AccountContact__c';
	        metadata.serviceObject_ReferenceToAccount = 'Account__c';
	        metadata.serviceObject_ReferenceToRealObject = 'Contact__c';
	        metadata.serviceObject_RelationshipWithRealObject = 'Contact__r';
    	}
    	else if (realObjectName == 'Contract')
    	{
	        //4) create metadata for Contract object
	        metadata = new ARO_Metadata();
	        metadata.realObject = 'Contract';
	        metadata.realObject_ReferenceToAccount = 'AccountId';
	        metadata.realObject_RelationshipWithAccount = 'Account';
	        metadata.serviceObject = 'H_C_AccountContract__c';
	        metadata.serviceObject_ReferenceToAccount = 'Account__c';
	        metadata.serviceObject_ReferenceToRealObject = 'Contract__c';
	        metadata.serviceObject_RelationshipWithRealObject = 'Contract__r';
    	}
    	else if (realObjectName == 'Invoice__c')
    	{
	        //5) create metadata for Contact object
	        metadata = new ARO_Metadata();
	        metadata.realObject = 'Invoice__c';
	        metadata.realObject_ReferenceToAccount = 'Bill_To_Customer__c';
	        metadata.realObject_RelationshipWithAccount = 'Bill_To_Customer__к';
	        metadata.serviceObject = 'H_C_AccountInvoice__c';
	        metadata.serviceObject_ReferenceToAccount = 'Account__c';
	        metadata.serviceObject_ReferenceToRealObject = 'Invoice__c';
	        metadata.serviceObject_RelationshipWithRealObject = 'Invoice__r';
    	}
    	else if (realObjectName == 'Account_Plan__c')
    	{
	        //6) create metadata for Contact object
	        metadata = new ARO_Metadata();
	        metadata.realObject = 'Account_Plan__c';
	        metadata.realObject_ReferenceToAccount = 'Account__c';
	        metadata.realObject_RelationshipWithAccount = 'Account__r';
	        metadata.serviceObject = 'H_C_AccountAccountPlan__c';
	        metadata.serviceObject_ReferenceToAccount = 'Account__c';
	        metadata.serviceObject_ReferenceToRealObject = 'AccountPlan__c';
	        metadata.serviceObject_RelationshipWithRealObject = 'AccountPlan__r';
    	}
    	else if (realObjectName == 'Capital_Equipment_Installed_Base__c')
    	{
	        //7) create metadata for Contact object
	        metadata = new ARO_Metadata();
	        metadata.realObject = 'Capital_Equipment_Installed_Base__c';
	        metadata.realObject_ReferenceToAccount = 'Account__c';
	        metadata.realObject_RelationshipWithAccount = 'Account__r';
	        metadata.serviceObject = 'H_C_AccountCapitalEquipmentIB__c';
	        metadata.serviceObject_ReferenceToAccount = 'Account__c';
	        metadata.serviceObject_ReferenceToRealObject = 'CapitalEquipmentInstalledBase__c';
	        metadata.serviceObject_RelationshipWithRealObject = 'CapitalEquipmentInstalledBase__r';
    	}
    	else if (realObjectName == 'ERF__c')
    	{
	        //8) create metadata for Contact object
	        metadata = new ARO_Metadata();
	        metadata.realObject = 'ERF__c';
	        metadata.realObject_ReferenceToAccount = 'Ship_To_Account__c';
	        metadata.realObject_RelationshipWithAccount = 'Ship_To_Account__r';
	        metadata.serviceObject = 'H_C_AccountERF__c';
	        metadata.serviceObject_ReferenceToAccount = 'Account__c';
	        metadata.serviceObject_ReferenceToRealObject = 'ERF__c';
	        metadata.serviceObject_RelationshipWithRealObject = 'ERF__r';
    	}
    	//#WARNING: delete it a bit later (7-08-2013)
    	/*else if (realObjectName == 'Event')
    	{
	        //4) create metadata for Event object
	        metadata = new ARO_Metadata();
	        metadata.realObject = 'Event';
	        metadata.realObject_ReferenceToAccount = 'AccountId';
	        metadata.realObject_RelationshipWithAccount = 'Account';
	        metadata.serviceObject = 'H_C_AccountEvent__c';
	        metadata.serviceObject_ReferenceToAccount = 'Account__c';
	        metadata.serviceObject_ReferenceToRealObject = 'EventId__c';
	        //#WARNING: this property should not be used for this object
	        metadata.serviceObject_RelationshipWithRealObject = '';
    	}
    	else if (realObjectName == 'Task')
    	{
	        //5) create metadata for Task object
	        metadata = new ARO_Metadata();
	        metadata.realObject = 'Task';
	        metadata.realObject_ReferenceToAccount = 'AccountId';
	        metadata.realObject_RelationshipWithAccount = 'Account';
	        metadata.serviceObject = 'H_C_AccountTask__c';
	        metadata.serviceObject_ReferenceToAccount = 'Account__c';
	        metadata.serviceObject_ReferenceToRealObject = 'TaskId__c';
	        //#WARNING: this property should not be used for this object
	        metadata.serviceObject_RelationshipWithRealObject = '';
    	}
        else if (realObjectName == 'Attachment')
        {
	        //6) create metadata for Attachment object
	        metadata = new ARO_Metadata();
	        metadata.realObject = 'Attachment';
	        metadata.realObject_ReferenceToAccount = 'ParentId';
	        //#WARNING: check the using of the property below later (Attachment has
	        //no clear reference to an account)
	        metadata.realObject_RelationshipWithAccount = 'Parent';
	        metadata.serviceObject = 'H_C_AccountAttachment__c';
	        metadata.serviceObject_ReferenceToAccount = 'Account__c';
	        metadata.serviceObject_ReferenceToRealObject = 'AttachmentId__c';
	        //#WARNING: this property should not be used for this object
	        metadata.serviceObject_RelationshipWithRealObject = '';
        }
        else if (realObjectName == 'Note')
        {
	        //7) create metadata for Note object
	        metadata = new ARO_Metadata();
	        metadata.realObject = 'Note';
	        metadata.realObject_ReferenceToAccount = 'ParentId';
	        //#WARNING: check the using of the property below later (Note has
	        //no clear reference to an account)
	        metadata.realObject_RelationshipWithAccount = 'Parent';
	        metadata.serviceObject = 'H_C_AccountNote__c';
	        metadata.serviceObject_ReferenceToAccount = 'Account__c';
	        metadata.serviceObject_ReferenceToRealObject = 'NoteId__c';
	        //#WARNING: this property should not be used for this object
	        metadata.serviceObject_RelationshipWithRealObject = '';
        }*/
        
        return metadata;
    }
    //
    
    //
    //Public static methods
    //
    public static ARO_Metadata getMetadata(String realObjectName)
    {
    	//try to find metadata in the map
    	ARO_Metadata metadata = mapOfMetadata.get(realObjectName);
    	if (metadata == null)
    	{
    		//if metadata was not found in the map, then we try to create and put them into the map
    		metadata = tryCreateMetadata(realObjectName);
    		if (metadata != null)
    		{
		    	//put new metadata into the map
		        mapOfMetadata.put(metadata.realObject, metadata);
    		}
    	}
    	
    	return metadata;
    }
    //
    
    //
    //Data types
    //
    public class ARO_Metadata
    {
        //
        //Properties
        //
        public String realObject;
        public String realObject_ReferenceToAccount;
        public String realObject_RelationshipWithAccount;
        
        public String serviceObject;
        public String serviceObject_ReferenceToAccount;
        public String serviceObject_ReferenceToRealObject;
        public String serviceObject_RelationshipWithRealObject;
        //
    }
    //
}