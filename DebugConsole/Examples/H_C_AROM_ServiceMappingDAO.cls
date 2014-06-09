//
//This class is used to provide access to any service mapping object which exists for a real
//account releated object. It should be parameterized by the object with metadata.
//Used abbreviations:
// - ARO means 'Account-Related Object'
// - AROM means 'Account-Related Object Management'
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (30-05-2013)
public class H_C_AROM_ServiceMappingDAO
{
	//
	//Constructors
	//
	public H_C_AROM_ServiceMappingDAO(H_C_AROM_Configurator.ARO_Metadata metadata)
	{
		if (metadata == null)
		{
			throw new H_C_Exception('H_C_AROM_ServiceMappingDAO was initialized via incorrect metadata');
		}
		this.metadata = metadata;
		this.initialize();
	}
	//
	
	//
    //Variables and constants
    //
    private H_C_AROM_Configurator.ARO_Metadata metadata;
    
    private String BASIC_FIELDS;
    private String OBJECT_NAME;
    //
    
    //
    //Private methods
    //
    private void initialize()
    {
    	//generate and set value for BASIC_FIELDS variable
    	this.BASIC_FIELDS = 'Id, Name, ' + this.metadata.serviceObject_ReferenceToAccount + ', '
    		+ this.metadata.serviceObject_ReferenceToRealObject;
    	//generate and set value for OBJECT_NAME variable
    	this.OBJECT_NAME = this.metadata.serviceObject;
    }
    //
    
    //
    //Public methods
    //
    public sObject getMappingById(String objectId)
    {
    	//checl the input parameters
        if (String.isBlank(objectId))
        {
            return null;
        }
        
        //initialize query builder and perform the query
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        queryBuilder.condition = 'Id = \'' + objectId + '\'';
        return H_C_SoqlUtils.performSingleResultQuery(queryBuilder);
    }
    
    public sObject[] getMappingsByIds(String[] objectsIds)
    {
        //join Ids and check the string
        String stringOfIds = H_C_SoqlUtils.joinStringsForINSection(objectsIds);
        if (String.isBlank(stringOfIds))
        {
            return null;
        }
        
        //initialize query builder and perform the query
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        queryBuilder.condition = 'Id IN (' + stringOfIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    
    public sObject[] getMappingsByAccountsIds(String[] accountsIds)
    {
        //join Ids and check the string
        String stringOfAccountsIds = H_C_SoqlUtils.joinStringsForINSection(accountsIds);
        if (String.isBlank(stringOfAccountsIds))
        {
            return null;
        }
        
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        queryBuilder.condition = this.metadata.serviceObject_ReferenceToAccount
        	+ ' IN (' + stringOfAccountsIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    
    //this method returns all mappings which refer to real objects that belong to the passed accounts
    //(for example, if we pass only one account Id, then this method returns all mappings which
    //refer to real objects of the account). So, the differencies between 2 last methods are:
    //- getMappingsByAccountsIds returns all mappings which refer to passed ACCOUNTS
    //- getMappingsByAccountLinksOfRealObjects returns all mappings which refer to REAL OBJECTS of
    //passed accounts
    public sObject[] getMappingsByAccountLinksOfRealObjects(String[] accountsIds)
    {
        String stringOfAccountsIds = H_C_SoqlUtils.joinStringsForINSection(accountsIds);
        if (String.isBlank(stringOfAccountsIds))
        {
            return null;
        }
        
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        String accountLinkInRealObject = this.metadata.serviceObject_RelationshipWithRealObject
        	+ '.' + this.metadata.realObject_ReferenceToAccount;
        queryBuilder.condition = accountLinkInRealObject + ' IN (' + stringOfAccountsIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    
    public sObject[] getMappingsByRealObjectsIds(String[] realObjectsIds)
    {
        //join Ids and check the string
        String stringOfRealObjectsIds = H_C_SoqlUtils.joinStringsForINSection(realObjectsIds);
        if (String.isBlank(stringOfRealObjectsIds))
        {
            return null;
        }
        
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        queryBuilder.condition = this.metadata.serviceObject_ReferenceToRealObject + ' IN ('
        	+ stringOfRealObjectsIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    //
}