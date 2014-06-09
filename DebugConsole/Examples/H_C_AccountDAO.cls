//
//This class provides access to 'Account' object
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (13-05-2013)
public class H_C_AccountDAO
{
    //
    //Variables and constants
    //
    private static String BASIC_FIELDS = 'Id, Name, OwnerId, '
    	+ 'RecordTypeId, RecordType.Name, '
        + 'ParentId, Parent.ParentId, '
        + 'Site_Use_ID_SFDC__c, CUST_NUMBER_OP_UNIT_SFDC__c, KEY_ACCOUNT_NUMBER_SFDC__c, NoOfChildren__c';
    private static String OBJECT_NAME = 'Account';
    
    //this map store mappings between record type names and fields where external Id is stored
    private static Map<String, String> mapOfFieldsForExternalIds;
    //this map store mappings between record type names and fields where external parent Id is stored
    private static Map<String, String> mapOfFieldsForExternalParentIds;
    //
    
    //
    //Private static methods 
    //
    private static sObject[] extractChildObjects(Account[] accounts,
    	String childRelationshipName)
    {
    	//check passed parameters
    	if (accounts == null)
    	{
    		return null;
    	}
    	
    	//extract necessary child objects
    	List<sObject> extractedChildObjects = new List<sObject>();
    	for (Account account : accounts)
    	{
    		//extract child objects from the account
    		sObject[] childObjects = H_C_sObjectUtils.getChildObjects(account, childRelationshipName);
    		//we can get a situation when child objects don't exist for a current account.
    		//In this case, the method should not add null-array into the result list
    		if (childObjects != null)
    		{
    			extractedChildObjects.addAll(childObjects);
    		}
    	}
    	return extractedChildObjects;
    }
    
    private static String createConditionByFilter(Filter filter)
    {
    	//check the filter
    	if (filter == null)
    	{
    		return null;
    	}
    	
    	List<String> listOfConditions = new List<String>();
    	
    	//1) add a condition for accounts Ids
    	String stringOfAccountsIds = H_C_SoqlUtils.joinStringsForINSection(filter.accountsIds);
    	if (String.isNotBlank(stringOfAccountsIds))
    	{
    		listOfConditions.add('Id IN (' + stringOfAccountsIds + ')');
    	}
    	
    	//2) add a condition for ignorable accounts Ids
    	String stringOfIgnorableAccountsIds =
    		H_C_SoqlUtils.joinStringsForINSection(filter.ignorableAccountsIds);
    	if (String.isNotBlank(stringOfIgnorableAccountsIds))
    	{
    		listOfConditions.add('Id NOT IN (' + stringOfIgnorableAccountsIds + ')');
    	}
    	
    	//3) add a condition for parent accounts Ids
    	String stringOfParentAccountsIds =
    		H_C_SoqlUtils.joinStringsForINSection(filter.parentAccountsIds);
    	if (String.isNotBlank(stringOfParentAccountsIds))
    	{
    		listOfConditions.add('ParentId IN (' + stringOfParentAccountsIds + ')');
    	}
    	
    	//4) add a condition for account record types
    	String stringOfAccountRecordTypes = 
    		H_C_SoqlUtils.joinStringsForINSection(filter.accountRecordTypes);
    	if (String.isNotBlank(stringOfAccountRecordTypes))
    	{
    		listOfConditions.add('RecordType.Name IN (' + stringOfAccountRecordTypes + ')');
    	}
    	
    	//5) add a condition to ignore accounts without a parent
    	if (filter.ignoreAccountsWithoutParent != null && filter.ignoreAccountsWithoutParent)
    	{
    		listOfConditions.add('ParentId != null');
    	}
    	
    	//join all the conditions by AND operator
    	return H_C_SoqlUtils.joinConditions(listOfConditions, H_C_SoqlUtils.LogicOperator.AND_Operator);
    }
    //
    
    //
    //Public static methods
    //
    public static Map<String, String> getMapOfFieldsForExternalParentIds()
    {
        if (mapOfFieldsForExternalParentIds == null)
        {
            mapOfFieldsForExternalParentIds = new Map<String, String>();
            mapOfFieldsForExternalParentIds.put(
                H_C_AccountRecordType.KEY_REGION_ACCOUNT, 'CUST_NUMBER_OP_UNIT_SFDC__c');
            mapOfFieldsForExternalParentIds.put(
                H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT, 'KEY_ACCOUNT_NUMBER_SFDC__c');
        }
        return mapOfFieldsForExternalParentIds;
    }
    
    public static Map<String, String> getMapOfFieldsForExternalIds()
    {
        if (mapOfFieldsForExternalIds == null)
        {
            mapOfFieldsForExternalIds = new Map<String, String>();
            mapOfFieldsForExternalIds.put(
                H_C_AccountRecordType.CONTRACT_ACCOUNT, 'CUST_NUMBER_OP_UNIT_SFDC__c');
            mapOfFieldsForExternalIds.put(
                H_C_AccountRecordType.KEY_REGION_ACCOUNT, 'KEY_ACCOUNT_NUMBER_SFDC__c');
            mapOfFieldsForExternalIds.put(
                H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT, 'Site_Use_ID_SFDC__c');
        }
        return mapOfFieldsForExternalIds;
    }
    
    public static Account[] getAccountsByFilter(Filter filter)
    {
    	String query = createQueryByFilter(filter);
        if (String.isBlank(query))
        {
            return null;
        }
        return H_C_SoqlUtils.performQuery(query);
    }
    
    public static Account[] getAccountsByIds(String[] accountsIds)
    {
        String query = createQueryByAccountsIds(accountsIds);
        if (String.isBlank(query))
        {
            return null;
        }
        return H_C_SoqlUtils.performQuery(query);
    }
    
    public static Account[] getAccountsByParentsIds(String[] parentsIds)
    {
        //join Ids and check the string
        String stringOfParentsIds = H_C_SoqlUtils.joinStringsForINSection(parentsIds);
        if (String.isBlank(stringOfParentsIds))
        {
            return null;
        }
        
        //initialize query builder and perform the query
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        queryBuilder.condition = 'ParentId IN (' + stringOfParentsIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    
    public static Account[] getAccountsByExternalIds(String[] externalIds, String recordTypeName)
    {
        //join Ids and check the string
        String stringOfExternalIds = H_C_SoqlUtils.joinStringsForINSection(externalIds);
        String filteringFieldName = getMapOfFieldsForExternalIds().get(recordTypeName);
        if (String.isBlank(stringOfExternalIds) || filteringFieldName == null)
        {
            return null;
        }
        
        //initialize query builder and perform the query
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        List<String> listOfConditions = new List<String>();
        listOfConditions.add(filteringFieldName + ' IN (' + stringOfExternalIds + ')');
        listOfConditions.add('RecordType.Name = \'' + recordTypeName + '\'');
        queryBuilder.condition = H_C_SoqlUtils.joinConditions(
            listOfConditions, H_C_SoqlUtils.LogicOperator.AND_Operator);
        
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    
    public static Account[] getAccountsByRecordTypeNames(String[] recordTypeNames)
    {
        String query = createQueryByRecordTypeNames(recordTypeNames);
        if (String.isBlank(query))
        {
            return null;
        }
        return H_C_SoqlUtils.performQuery(query);
    }
    
    public static sObject[] getChildObjectsByAccountId(String accountId,
    	H_C_SoqlQueryBuilder childRelationshipQueryBuilder, Boolean includeObjectsOfChildAccounts)
    {
    	//check passed parameters
    	if (String.isBlank(accountId) || childRelationshipQueryBuilder == null)
    	{
    		return null;
    	}
    	
    	//STEP #1: generate a subquery
    	String childRelationshipSubQuery = childRelationshipQueryBuilder.buildQuery();
    	
    	//STEP #2: initialize and fill a builder for an entire query (childRelationshipSubQuery
    	//will be included into a main query)
    	H_C_SoqlQueryBuilder queryBuilder =
    		new H_C_SoqlQueryBuilder('Id, (' + childRelationshipSubQuery + ')', 'Account');
    	//generate condition
    	queryBuilder.condition = createConditionByAccountId(accountId, includeObjectsOfChildAccounts);
    	
    	//STEP #3: get accounts and extract child objects from them
    	Account[] accountsWithChildObjects = H_C_SoqlUtils.performQuery(queryBuilder);
    	return extractChildObjects(accountsWithChildObjects, childRelationshipQueryBuilder.objectName);
    }
    
    public static String createQueryByFilter(Filter filter)
    {
    	String condition = createConditionByFilter(filter);
        if (String.isBlank(condition))
        {
        	//if the system can't create a real condition by the filter then it considers that the
        	//filter is incorrect, and nothing should be returned
        	return null;
        }
        
        //initialize query builder and build the query
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
    	queryBuilder.condition = condition;
        return queryBuilder.buildQuery();
    }
    
    public static String createQueryByAccountsIds(String[] accountsIds)
    {
        //join Ids and check the string
        String stringOfIds = H_C_SoqlUtils.joinStringsForINSection(accountsIds);
        if (String.isBlank(stringOfIds))
        {
            return null;
        }
        
        //initialize query builder and build the query
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        queryBuilder.condition = 'Id IN (' + stringOfIds + ')';
        return queryBuilder.buildQuery();
    }
    
    public static String createQueryForGetAllAccounts()
    {
        //initialize query builder and build the query
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        return queryBuilder.buildQuery();
    }
    
    public static String createQueryByRecordTypeNames(String[] recordTypeNames)
    {
        //convert record type names into a list of Ids
        String[] recordTypeIds = H_C_AccountRecordType.getRecordTypeIdsByNames(recordTypeNames);
        //join Ids and check the string
        String stringOfRecordTypeIds = H_C_SoqlUtils.joinStringsForINSection(recordTypeIds);
        if (String.isBlank(stringOfRecordTypeIds))
        {
            return null;
        }
        
        //initialize query builder and build the query
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        queryBuilder.condition = 'RecordTypeId IN (' + stringOfRecordTypeIds + ')';
        return queryBuilder.buildQuery();
    }
    
    public static String createQueryForAccountsWithoutProperParents(String[] selectedRTNs)
    {
    	//check input parameters
    	if (selectedRTNs == null)
    	{
    		return null;
    	}
    	
    	//STEP #1: generate conditions for all passed record types
    	Map<String, String> fieldsForExternalParentIds = getMapOfFieldsForExternalParentIds();
    	List<String> listOfOrConditions = new List<String>();
    	for (String recordTypeName : selectedRTNs)
    	{
    		//get field where we keep external parent Id for the current record type
    		String fieldOfExternalParentId = fieldsForExternalParentIds.get(recordTypeName);
    		if (String.isNotBlank(fieldOfExternalParentId))
    		{
    			listOfOrConditions.add(fieldOfExternalParentId + ' != null AND RecordType.Name = \''
    				+ recordTypeName + '\'');
    		}
    	}
    	
    	//join conditions into partial condition by OR-operator
    	String partialCondition = H_C_SoqlUtils.joinConditions(
    		listOfOrConditions, H_C_SoqlUtils.LogicOperator.OR_Operator);
    	//if the method can't create partial condition from the passed parameters
    	//then we should stop it
    	if (String.isBlank(partialCondition))
    	{
    		return null;
    	}
    	
    	//STEP #2: build a final condition
    	//initialize query builder and build the query
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        
        //build final condition
        List<String> listOfFinalConditions = new List<String>();
    	listOfFinalConditions.add('ParentId = null');
    	listOfFinalConditions.add(partialCondition);
        queryBuilder.condition = H_C_SoqlUtils.joinConditions(
    		listOfFinalConditions, H_C_SoqlUtils.LogicOperator.AND_Operator);
    	
        return queryBuilder.buildQuery();
    }
    
    public static String createConditionByAccountId(String accountId, Boolean includeChildAccounts)
    {
    	//check passed parameters
    	if (String.isBlank(accountId))
    	{
    		return null;
    	}
    	
    	//generate condition
    	List<String> listOfConditions = new List<String>();
    	listOfConditions.add('Id = \'' + accountId + '\'');
    	if (includeChildAccounts)
    	{
    		//the 1st child level
    		listOfConditions.add('ParentId = \'' + accountId + '\'');
    		//the 2nd child level (maximal depth)
    		listOfConditions.add('Parent.ParentId = \'' + accountId + '\'');
    	}
    	return H_C_SoqlUtils.joinConditions(listOfConditions, H_C_SoqlUtils.LogicOperator.OR_Operator);
    }
    //
    
    
    //
    //Data types
    //
    public class Filter
    {
    	//
    	//Properties
    	//
    	public String[] accountsIds {get; set;}
    	public String[] ignorableAccountsIds {get; set;}
    	
    	public String[] accountRecordTypes {get; set;}
    	
    	public String[] parentAccountsIds {get; set;}
    	public Boolean ignoreAccountsWithoutParent {get; set;}
    	//
    }
    //
}