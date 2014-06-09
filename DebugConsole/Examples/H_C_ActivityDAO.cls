//
//This class provides access to 'OpenActivity' and 'ActivityHistory' objects
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (5-08-2013)
public class H_C_ActivityDAO
{
	//
    //Variables and constants
    //
    private static String BASIC_FIELDS = 'Id, Subject, ActivityDate, EndDateTime, DurationInMinutes, '
    	+ 'AccountId, Account.Name, WhoId, Who.Name, Who.FirstName, Who.LastName, '
    	+ 'OwnerId, Owner.Name, Owner.FirstName, Owner.LastName, '
    	+ 'IsTask, Status, Priority, LastModifiedDate';
    private static String OPEN_ACTIVITIES_RELATIONSHIP_NAME = 'OpenActivities';
    private static String ACTIVITY_HISTORY_RELATIONSHIP_NAME = 'ActivityHistories';
    //
    
    //
    //Public static methods
    //
    public static OpenActivity[] getOpenActivitiesByAccountId(
    	String accountId, Boolean includeObjectsOfChildAccounts)
    {
    	//initialize and fill query builder for child relationship
    	H_C_SoqlQueryBuilder childRelationshipQueryBuilder = new H_C_SoqlQueryBuilder(
    		BASIC_FIELDS, OPEN_ACTIVITIES_RELATIONSHIP_NAME);
    	
    	//get child objects through 'Account' object
    	return H_C_AccountDAO.getChildObjectsByAccountId(accountId,
    		childRelationshipQueryBuilder, includeObjectsOfChildAccounts);
    }
    
    public static ActivityHistory[] getActivityHistoriesByAccountId(
    	String accountId, Boolean includeObjectsOfChildAccounts)
    {
    	//initialize and fill query builder for child relationship
    	H_C_SoqlQueryBuilder childRelationshipQueryBuilder = new H_C_SoqlQueryBuilder(
    		BASIC_FIELDS, ACTIVITY_HISTORY_RELATIONSHIP_NAME);
    	
    	//get child objects through 'Account' object
    	return H_C_AccountDAO.getChildObjectsByAccountId(accountId,
    		childRelationshipQueryBuilder, includeObjectsOfChildAccounts);
    }
    //
}