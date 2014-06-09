//
//This class is used as a helper for working with 'AccountTeamMember' objects.
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (23-05-2013)
public class H_C_AccountTeamMemberHelper
{
	//
    //Constructor
    //
    private H_C_AccountTeamMemberHelper()
    {
    }
    //
    
    //
    //Variables
    //
    private AccountTeamMember[] databaseObjects;
    //this map stores mappings between Id of an account and its team members  
    private Map<String, AccountTeamMember[]> mapOfAccountTeamMembers;
    //this map stores mappings between User Id and his ATMs
    private Map<String, AccountTeamMember[]> mapOfUserIdAndATMs;
    //map stores mappings between complex key (accountId AND UserId) and team member who
    //corresponds to this accountId and userId
    private Map<String, AccountTeamMember> mapOfAccountAndUserATMs;
    //
    
    //
    //Properties
    //
    public AccountTeamMember[] allTeamMembers
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
    private void setDatabaseObjects(AccountTeamMember[] teamMembers)
    {
        this.clearState();
        
        this.databaseObjects = teamMembers;
        if (this.databaseObjects == null)
        {
            this.databaseObjects = new AccountTeamMember[0];
        }
    }
    
    private void clearState()
    {
        this.mapOfAccountTeamMembers = null;
        this.mapOfUserIdAndATMs = null;
        this.mapOfAccountAndUserATMs = null;
    }
    //
    
    //
    //Private service methods which are used for optimization
    //
    //this method creates and fills the map of mappings between account Id and its team
    //members to optimize the operations which work with account Id
    private void optimizeWorkByAccountId()
    {
        if (this.mapOfAccountTeamMembers == null)
        {
            //initialize the map
            this.mapOfAccountTeamMembers = new Map<String, AccountTeamMember[]>();
            
            //fill the map
            for (AccountTeamMember teamMember : this.databaseObjects)
            {
                List<AccountTeamMember> teamMembers = this.mapOfAccountTeamMembers.get(teamMember.AccountId);
                if (teamMembers == null)
                {
                    teamMembers = new AccountTeamMember[] {teamMember};
                    this.mapOfAccountTeamMembers.put(teamMember.AccountId, teamMembers);
                }
                else
                {
                    teamMembers.add(teamMember);
                }
            }
        }
    }
    
    //this method creates and fills the map of mappings between User (or Group) Id and
    //his ATMs to optimize the operations which work with User Id
    private void optimizeWorkForUserIdAndATMs()
    {
    	if (this.mapOfUserIdAndATMs == null)
    	{
    		this.mapOfUserIdAndATMs = createMapOfUserIdAndATMs(this.databaseObjects);
    	}
    }
    
    //this method creates and fills 'mapOfAccountAndUserATMs' map of mappings
    //to optimize operations which work with a pair: accountId-userId
    private void optimizeWorkByAccountIdAndUserId()
    {
        if (this.mapOfAccountAndUserATMs == null)
        {
            //initialize the map
            this.mapOfAccountAndUserATMs = new Map<String, AccountTeamMember>();
            //fill the map
            for (AccountTeamMember teamMember : this.databaseObjects)
            {
            	String complexKey = createKeyByAccountIdAndUserId(teamMember.AccountId,
            		teamMember.UserId);
                mapOfAccountAndUserATMs.put(complexKey, teamMember);
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
    public AccountTeamMember[] getATMsByAccountId(String accountId)
    {
    	//check passed parameters
        if (String.isBlank(accountId))
        {
            return null;
        }
        
        //the method automatically optimizes its work
        if (this.mapOfAccountTeamMembers == null)
        {
            this.optimizeWorkByAccountId();
        }
        AccountTeamMember[] accountTeamMembers = this.mapOfAccountTeamMembers.get(accountId);
        return (accountTeamMembers != null ? accountTeamMembers : new AccountTeamMember[0]);
    }
    
    public AccountTeamMember[] getATMsByAccountsIds(String[] accountsIds)
    {
    	//check passed parameters
        if (accountsIds == null)
        {
            return null;
        }
         
        //the method automatically optimizes its work
        if (this.mapOfAccountTeamMembers == null)
        {
            this.optimizeWorkByAccountId();
        }
        //select ATMs for passed accounts
        List<AccountTeamMember> selectedATMs = new List<AccountTeamMember>();
        for (String accountId : accountsIds)
        {
        	AccountTeamMember[] accountATMs = this.mapOfAccountTeamMembers.get(accountId);
        	if (accountATMs != null)
        	{
        		selectedATMs.addAll(accountATMs);
        	}
        }
        return selectedATMs;
    }
    
    public AccountTeamMember[] getATMsByUserId(String userId)
    {
    	//check passed parameters
        if (String.isBlank(userId))
        {
            return null;
        }
        
        //the method automatically optimizes its work
        if (this.mapOfUserIdAndATMs == null)
        {
            this.optimizeWorkForUserIdAndATMs();
        }
        AccountTeamMember[] accountTeamMembers = this.mapOfUserIdAndATMs.get(userId);
        return (accountTeamMembers != null ? accountTeamMembers : new AccountTeamMember[0]);
    }
    
    public AccountTeamMember getATMByAccountIdAndUserId(String accountId, String userId)
    {
        if (String.isBlank(accountId) || String.isBlank(userId))
        {
            return null;
        }
        
        //the method automatically optimize its work
        if (this.mapOfAccountAndUserATMs == null)
        {
            this.optimizeWorkByAccountIdAndUserId();
        }
        //create complex key
        String complexKey = createKeyByAccountIdAndUserId(accountId, userId);
        //return the result
        return this.mapOfAccountAndUserATMs.get(complexKey);
    }
    
    public Set<String> extractUsersIds()
    {
        //the method automatically optimizes its work
        if (this.mapOfUserIdAndATMs == null)
        {
            this.optimizeWorkForUserIdAndATMs();
        }
        return this.mapOfUserIdAndATMs.keySet();
    }
    //
    
    
    //
    //Public static factory methods
    //
    public static H_C_AccountTeamMemberHelper createHelperByATMsList(
    	AccountTeamMember[] teamMembers)
    {
        H_C_AccountTeamMemberHelper helper = new H_C_AccountTeamMemberHelper();
        helper.setDatabaseObjects(teamMembers);
        return helper;
    }
    
    public static H_C_AccountTeamMemberHelper createHelperByFilter(
    	H_C_AccountTeamMemberDAO.Filter filter)
    {
        H_C_AccountTeamMemberHelper helper = new H_C_AccountTeamMemberHelper();
        helper.setDatabaseObjects(H_C_AccountTeamMemberDAO.getATMsByFilter(filter));
        return helper;
    }
    //
    
    //
    //Public static service methods
    //
    public static Map<String, AccountTeamMember[]> createMapOfUserIdAndATMs(
    	AccountTeamMember[] teamMembers)
    {
    	Map<String, AccountTeamMember[]> mapOfUserIdAndATMs = null;
    	if (teamMembers != null)
    	{
    		//initialize the map
    		mapOfUserIdAndATMs = new Map<String, AccountTeamMember[]>();
    		//fill the map
    		for (AccountTeamMember atm : teamMembers)
    		{
    			List<AccountTeamMember> atmsForUser = mapOfUserIdAndATMs.get(atm.UserId);
    			if (atmsForUser == null)
    			{
    				atmsForUser = new AccountTeamMember[] {atm};
    				mapOfUserIdAndATMs.put(atm.UserId, atmsForUser);
    			}
    			else
    			{
    				atmsForUser.add(atm);
    			}
    		}
    	}
    	return mapOfUserIdAndATMs;
    }
    
    /*#INFO: the methods are not used and can be deleted later
    public static String[] extractUsersIds(AccountTeamMember[] teamMembers)
    {
        if (teamMembers == null)
        {
            return null;
        }
        
        Set<String> setOfUsersIds = new Set<String>();
        for (AccountTeamMember teamMember : teamMembers)
        {
            setOfUsersIds.add(teamMember.UserId);
        }
        
        List<String> listOfUsersIds = new List<String>();
        listOfUsersIds.addAll(setOfUsersIds);
        return listOfUsersIds;
    }
    
    public static String[] extractAccountsIds(AccountTeamMember[] teamMembers)
    {
        if (teamMembers == null)
        {
            return null;
        }
        
        Set<String> setOfAccountsIds = new Set<String>();
        for (AccountTeamMember teamMember : teamMembers)
        {
            setOfAccountsIds.add(teamMember.AccountId);
        }
        
        List<String> listOfAccountsIds = new List<String>();
        listOfAccountsIds.addAll(setOfAccountsIds);
        return listOfAccountsIds;
    }*/
    //
}