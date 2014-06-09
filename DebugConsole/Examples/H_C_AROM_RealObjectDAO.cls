//
//This class is used to provide access to any real account-related object. It should be
//parameterized by the object with metadata.
//Used abbreviations:
// - ARO means 'Account-Related Object'
// - AROM means 'Account-Related Object Management'
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (3-06-2013)
public class H_C_AROM_RealObjectDAO
{
	//
	//Constructors
	//
	public H_C_AROM_RealObjectDAO(H_C_AROM_Configurator.ARO_Metadata metadata)
	{
		if (metadata == null)
		{
			throw new H_C_Exception('H_C_AROM_RealObjectDAO was initialized via incorrect metadata');
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
    	this.BASIC_FIELDS = 'Id, Name, ' + this.metadata.realObject_ReferenceToAccount + ', '
    		+ metadata.realObject_RelationshipWithAccount + '.' + 'ParentId' + ', '
    		+ metadata.realObject_RelationshipWithAccount + '.' + 'Parent.ParentId';
    	//generate and set value for OBJECT_NAME variable
    	this.OBJECT_NAME = this.metadata.realObject;
    }
    //
    
    
    //
    //Public methods
    //
    public sObject[] getObjectsByIds(String[] objectsIds)
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
    
    public sObject[] getObjectsByAccountsIds(String[] accountsIds)
    {
        String stringOfAccountsIds = H_C_SoqlUtils.joinStringsForINSection(accountsIds);
        if (String.isBlank(stringOfAccountsIds))
        {
            return null;
        }
        
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        queryBuilder.condition = this.metadata.realObject_ReferenceToAccount + ' IN ('
        	+ stringOfAccountsIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    //
}