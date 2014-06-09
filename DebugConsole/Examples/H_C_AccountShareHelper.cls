//
//This class is used as a helper for working with 'AccountShare' objects.
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (16-10-2013)
public class H_C_AccountShareHelper
{
	//
    //Constructor
    //
    private H_C_AccountShareHelper()
    {
    }
    //
    
    //
    //Variables
    //
    private AccountShare[] databaseObjects;
    //map stores mappings between complex key (accountId AND userOrGroupId) and share which
    //corresponds to this accountId and userOrGroupId
    private Map<String, AccountShare> mapOfAccountAndUserShares;
    //
    
    //
    //Properties
    //
    public AccountShare[] allAccountShares
    {
        get
        {
            return this.databaseObjects;
        }
    }
    //
    
    //
    //Private methods 
    //
    private void setDatabaseObjects(AccountShare[] accountShares)
    {
        this.clearState();
        
        this.databaseObjects = accountShares;
        if (this.databaseObjects == null)
        {
            this.databaseObjects = new AccountShare[0];
        }
    }
    
    private void clearState()
    {
        this.mapOfAccountAndUserShares = null;
    }
    //
    
    //
    //Private service methods which are used for optimization
    //
    //this method creates and fills 'mapOfAccountAndUserShares' map of mappings
    //to optimize operations which work with a pair: accountId-userOrGroupId
    private void optimizeWorkByAccountIdAndUserId()
    {
        if (this.mapOfAccountAndUserShares == null)
        {
            //initialize the map
            this.mapOfAccountAndUserShares = new Map<String, AccountShare>();
            //fill the map
            for (AccountShare share : this.databaseObjects)
            {
            	String complexKey = createKeyByAccountIdAndUserId(share.AccountId, share.UserOrGroupId);
                mapOfAccountAndUserShares.put(complexKey, share);
            }
        }
    }
    //
    
    //
    //Private static service methods
    //
    private static String createKeyByAccountIdAndUserId(String accountId, String userId)
    {
    	return (accountId + userId);
    }
    //
    
    //
    //Public methods
    //
    public AccountShare getShareByAccountIdAndUserId(String accountId, String userOrGroupId)
    {
        if (String.isBlank(accountId) || String.isBlank(userOrGroupId))
        {
            return null;
        }
        
        //the method automatically optimize its work
        if (this.mapOfAccountAndUserShares == null)
        {
            this.optimizeWorkByAccountIdAndUserId();
        }
        //create complex key
        String complexKey = createKeyByAccountIdAndUserId(accountId, userOrGroupId);
        //return the result
        return this.mapOfAccountAndUserShares.get(complexKey);
    }
    //
    
    
    //
    //Public static factory methods
    //
    public static H_C_AccountShareHelper createHelperBySharesList(AccountShare[] accountShares)
    {
        H_C_AccountShareHelper helper = new H_C_AccountShareHelper();
        helper.setDatabaseObjects(accountShares);
        return helper;
    }
    
    public static H_C_AccountShareHelper createHelperByFilter(H_C_AccountShareDAO.Filter filter)
    {
        H_C_AccountShareHelper helper = new H_C_AccountShareHelper();
        helper.setDatabaseObjects(H_C_AccountShareDAO.getAccountSharesByFilter(filter));
        return helper;
    }
    //
}