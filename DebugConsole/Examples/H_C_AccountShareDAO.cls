//
//This class provides access to 'AccountShare' object
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (16-10-2013)
public class H_C_AccountShareDAO
{
    //
    //Variables and constants
    //
    private static String BASIC_FIELDS = 'Id, AccountId, UserOrGroupId, RowCause, '
    	+ 'AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel, ContactAccessLevel';
    private static String OBJECT_NAME = 'AccountShare';
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
    	
    	//STEP #1: add a condition for team members
    	if (filter.teamMembers != null && filter.teamMembers.size() > 0)
    	{
    		List<String> teamMembersConditions = new List<String>();
    		for (AccountTeamMember teamMember : filter.teamMembers)
    		{
    			teamMembersConditions.add('AccountId = \'' + teamMember.AccountId
    				+ '\' AND UserOrGroupId = \'' + teamMember.UserId + '\'');
    		}
    		listOfConditions.add(H_C_SoqlUtils.joinConditions(teamMembersConditions,
    			H_C_SoqlUtils.LogicOperator.OR_Operator));
    	}
    	
    	//STEP #2: add a condition for accounts
        //join accounts Ids and check the string
        String stringOfAccountsIds = H_C_SoqlUtils.joinStringsForINSection(filter.accountsIds);
    	if (!String.isBlank(stringOfAccountsIds))
    	{
    		listOfConditions.add('AccountId IN (' + stringOfAccountsIds + ')');
    	}
    	
    	//STEP #3: add a condition for users or groups Ids
    	String stringOfUserOrGroupsIds = H_C_SoqlUtils.joinStringsForINSection(filter.usersOrGroupsIds);
    	if (!String.isBlank(stringOfUserOrGroupsIds))
    	{
    		listOfConditions.add('UserOrGroupId IN (' + stringOfUserOrGroupsIds + ')');
    	}
    	
    	//STEP #4: add a condition for row causes
    	String stringOfRowCauses = H_C_SoqlUtils.joinStringsForINSection(filter.rowCauses);
    	if (!String.isBlank(stringOfRowCauses))
    	{
    		listOfConditions.add('RowCause IN (' + stringOfRowCauses + ')');
    	}
    	
    	//join all the conditions by AND operator
    	return H_C_SoqlUtils.joinConditions(listOfConditions, H_C_SoqlUtils.LogicOperator.AND_Operator);
    }
    //
    
    //
    //Public static methods
    //
    public static AccountShare[] getAccountSharesByFilter(Filter filter)
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
        return H_C_SoqlUtils.performQuery(queryBuilder);
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
    	public AccountTeamMember[] teamMembers {get; set;}
    	public String[] accountsIds {get; set;}
    	public String[] usersOrGroupsIds {get; set;}
    	public String[] rowCauses {get; set;}
    	//
    }
    //
}