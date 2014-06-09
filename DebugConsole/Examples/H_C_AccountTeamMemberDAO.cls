//
//This class provides access to 'AccountTeamMember' object
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (13-05-2013)
public class H_C_AccountTeamMemberDAO
{
    //
    //Variables and constants
    //
    private static String BASIC_FIELDS = 'Id, AccountId, UserId, TeamMemberRole';
    private static String OBJECT_NAME = 'AccountTeamMember';
    //
    
    //
    //Private static methods
    //
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
    	if (!String.isBlank(stringOfAccountsIds))
    	{
    		listOfConditions.add('AccountId IN (' + stringOfAccountsIds + ')');
    	}
    	
    	//2) add a condition for account record types
    	//convert record type names into a list of Ids
        String[] accountRecordTypesIds =
        	H_C_AccountRecordType.getRecordTypeIdsByNames(filter.accountRecordTypes);
        //join Ids and check the string
        String stringOfAccountRecordTypesIds =
        	H_C_SoqlUtils.joinStringsForINSection(accountRecordTypesIds);
    	if (!String.isBlank(stringOfAccountRecordTypesIds))
    	{
    		listOfConditions.add('Account.RecordTypeId IN (' + stringOfAccountRecordTypesIds + ')');
    	}
    	
    	//3) add a condition for parent accounts Ids
    	String stringOfParentAccountsIds =
    		H_C_SoqlUtils.joinStringsForINSection(filter.parentAccountsIds);
    	if (!String.isBlank(stringOfParentAccountsIds))
    	{
    		listOfConditions.add('Account.ParentId IN (' + stringOfParentAccountsIds + ')');
    	}
    	
    	//4) add a condition for record types of parent accounts
    	//convert record type names into a list of Ids
        String[] parentAccountRecordTypesIds =
        	H_C_AccountRecordType.getRecordTypeIdsByNames(filter.parentAccountRecordTypes);
        //join Ids and check the string
        String stringOfParentAccountRecordTypesIds =
        	H_C_SoqlUtils.joinStringsForINSection(parentAccountRecordTypesIds);
    	if (!String.isBlank(stringOfParentAccountRecordTypesIds))
    	{
    		listOfConditions.add('Account.Parent.RecordTypeId IN (' + stringOfParentAccountRecordTypesIds + ')');
    	}
    	
    	//5) add a service condition to ignore team members who belong to accounts without parents
    	if (filter.ignoreAccountsWithoutParent != null && filter.ignoreAccountsWithoutParent)
    	{
    		listOfConditions.add('Account.ParentId != null');
    	}
    	
    	//6) add a condition for team member roles
    	String stringOfIgnorableTeamRoles =
    		H_C_SoqlUtils.joinStringsForINSection(filter.ignorableTeamRoles);
    	if (!String.isBlank(stringOfIgnorableTeamRoles))
    	{
    		listOfConditions.add('TeamMemberRole NOT IN (' + stringOfIgnorableTeamRoles + ')');
    	}
    	
    	//7) add a condition for start of last modified date
    	if (filter.startModifiedDateTime != null)
    	{
    		listOfConditions.add('LastModifiedDate >= '
    			+ H_C_SoqlUtils.formatDateTime(filter.startModifiedDateTime));
    	}
    	
    	//8) add a condition to ignore team members for inactive users
    	if (filter.ignoreInactiveUsers != null && filter.ignoreInactiveUsers)
    	{
    		listOfConditions.add('User.IsActive = true');
    	}
    	
    	//join all the conditions by AND operator
    	return H_C_SoqlUtils.joinConditions(listOfConditions, H_C_SoqlUtils.LogicOperator.AND_Operator);
    }
    //
    
    //
    //Public static methods
    //
    public static AccountTeamMember[] getATMsByFilter(Filter filter)
    {
    	String query = createQueryByFilter(filter);
        if (String.isBlank(query))
        {
            return null;
        }
        return H_C_SoqlUtils.performQuery(query);
    }
    
    public static String[] getParentAccountsIdsByFilter(Filter filter)
    {
    	String condition = createConditionByFilter(filter);
        if (String.isBlank(condition))
        {
        	//if the system can't create a real condition by the filter then it considers that
        	//filter is incorrect, and nothing should be returned
        	return null;
        }
        
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder('Account.ParentId', OBJECT_NAME);
    	queryBuilder.condition = condition;
    	queryBuilder.groupByFields = 'Account.ParentId';
        AggregateResult[] results = H_C_SoqlUtils.performQuery(queryBuilder);
        
        List<String> parentAccountsIds = new List<String>();
        if (results != null)
        {
	        for (AggregateResult result : results)
	        {
	        	parentAccountsIds.add((String)result.get('ParentId'));
	        }
        }
        return parentAccountsIds;
    }
    
    public static String[] getAccountsIdsByFilter(Filter filter)
    {
    	String condition = createConditionByFilter(filter);
        if (String.isBlank(condition))
        {
        	//if the system can't create a real condition by the filter then it considers that
        	//filter is incorrect, and nothing should be returned
        	return null;
        }
        
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder('AccountId', OBJECT_NAME);
    	queryBuilder.condition = condition;
    	queryBuilder.groupByFields = 'AccountId';
        AggregateResult[] results = H_C_SoqlUtils.performQuery(queryBuilder);
        
        List<String> accountsIds = new List<String>();
        if (results != null)
        {
	        for (AggregateResult result : results)
	        {
	        	accountsIds.add((String)result.get('AccountId'));
	        }
        }
        return accountsIds;
    }
    
    public static AccountTeamMember[] getATMsByAccountsIds(String[] accountsIds)
    {
    	//join Ids and check the string
        String stringOfIds = H_C_SoqlUtils.joinStringsForINSection(accountsIds);
        if (String.isBlank(stringOfIds))
        {
            return null;
        }
        
        //initialize query builder and perform the query
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        queryBuilder.condition = 'AccountId IN (' + stringOfIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
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
        
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
    	queryBuilder.condition = condition;
        return queryBuilder.buildQuery();
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
    	public String[] accountRecordTypes {get; set;}
    	
    	public String[] parentAccountsIds {get; set;}
    	public String[] parentAccountRecordTypes {get; set;}
    	public Boolean ignoreAccountsWithoutParent {get; set;}
    	
    	public String[] ignorableTeamRoles {get; set;}
    	
    	public DateTime startModifiedDateTime {get; set;}
    	
    	public Boolean ignoreInactiveUsers {get; set;}
    	//
    }
    //
}