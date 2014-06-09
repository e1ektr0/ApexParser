//
//This class is used as a helper for working with 'Account' objects.
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (13-05-2013)
public class H_C_AccountHelper
{
    //
    //Constructor
    //
    private H_C_AccountHelper()
    {
    }
    //
    
    //
    //Variables
    //
    private Account[] databaseObjects;
    //map stores mappings between account ID and account
    private Map<String, Account> mapOfAccounts;
    //map stores mappings between Id of an account and its children  
    private Map<String, Account[]> mapOfChildAccounts;
    //map stores mappings between external account ID and account
    private Map<String, Account> mapOfExternalAccounts;
    //map stores mappings between record type name and accounts which have this record type
    private Map<String, Account[]> mapOfRecordTypeNamesAndAccounts;
    //map stores mappings between OwnerId and his accounts
    private Map<String, Account[]> mapOfOwnerIdAndAccounts;
    //
    
    //
    //Properties
    //
    public Account[] allAccounts
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
    private void setDatabaseObjects(Account[] accounts)
    {
        this.clearState();
        
        this.databaseObjects = accounts;
        if (this.databaseObjects == null)
        {
            this.databaseObjects = new Account[0];
        }
    }
    
    private void clearState()
    {
        this.mapOfAccounts = null;
        this.mapOfChildAccounts = null;
        this.mapOfExternalAccounts = null;
        this.mapOfRecordTypeNamesAndAccounts = null;
        this.mapOfOwnerIdAndAccounts = null;
    }
    //
    
    
    //
    //Private service methods which are used for optimization
    //
    //this method creates and fills the map of accounts to optimize the operations which
    //work with account Id  
    private void optimizeWorkByAccountId()
    {
        if (this.mapOfAccounts == null)
        {
            //initialize and fill the map
            this.mapOfAccounts = new Map<String, Account>(this.databaseObjects);
        }
    }
    
    //this method creates and fills the map of mappings between parent account and its children
    //to optimize the operations which work with parent Id
    private void optimizeWorkByParentId()
    {
        if (this.mapOfChildAccounts == null)
        {
            //initialize the map
            this.mapOfChildAccounts = new Map<String, Account[]>();
            
            //fill the map
            for (Account account : this.databaseObjects)
            {
                List<Account> childAccounts = this.mapOfChildAccounts.get(account.ParentId);
                if (childAccounts == null)
                {
                    childAccounts = new Account[] {account};
                    this.mapOfChildAccounts.put(account.ParentId, childAccounts);
                }
                else
                {
                    childAccounts.add(account);
                }
            }
        }
    }
    
    //this method creates and fills the map of mappings between external Ids and accounts
    //to optimize the operations which work with external account Id  
    private void optimizeWorkByExternalAccountId()
    {
        if (this.mapOfExternalAccounts == null)
        {
            Map<String, String> mapOfFieldsForExternalIds =
                H_C_AccountDAO.getMapOfFieldsForExternalIds();
            
            //initialize and fill the map
            this.mapOfExternalAccounts = new Map<String, Account>();
            for (Account account : this.databaseObjects)
            {
                //get name of a record type for the current account
                String recordTypeName = H_C_AccountRecordType.mapOfIdsAndNames.get(account.RecordTypeId);
                //get name of a field where the system stores external Id of the current account
                String fieldNameOfExternalId = mapOfFieldsForExternalIds.get(recordTypeName);
                //get external Id and add a record in the map
                String externalId = String.valueOf(
                    H_C_sObjectUtils.getFieldValue(account, fieldNameOfExternalId));
                if (String.isNotBlank(externalId))
                {
                    this.mapOfExternalAccounts.put(externalId.trim(), account);
                }
            }
        }
    }
    
    //this method creates and fills the map of mappings between record type name and accounts
    //to optimize the operations which work with record type name
    private void optimizeWorkByRecordTypeName()
    {
        if (this.mapOfRecordTypeNamesAndAccounts == null)
        {
            //initialize and fill temp map which stores mappings between record type Id and accounts
            Map<String, Account[]> mapOfRecordTypeIdsAndAccounts = new Map<String, Account[]>();
            for (Account account : this.databaseObjects)
            {
                if (String.isNotBlank(account.RecordTypeId))
                {
                    //get list of accounts with the same type as the current account has 
                    List<Account> accounts = mapOfRecordTypeIdsAndAccounts.get(account.RecordTypeId);
                    if (accounts == null)
                    {
                        accounts = new Account[] {account};
                        mapOfRecordTypeIdsAndAccounts.put(account.RecordTypeId, accounts);
                    }
                    else
                    {
                        accounts.add(account);
                    }
                }
            }
            
            //initialize and fill the result map
            this.mapOfRecordTypeNamesAndAccounts = new Map<String, Account[]>();
            for (String recordTypeId : mapOfRecordTypeIdsAndAccounts.keySet())
            {
                String recordTypeName = H_C_AccountRecordType.mapOfIdsAndNames.get(recordTypeId);
                this.mapOfRecordTypeNamesAndAccounts.put(
                    recordTypeName, mapOfRecordTypeIdsAndAccounts.get(recordTypeId));
            }
        }
    }
    
    private void optimizeWorkByOwnerId()
    {
    	if (this.mapOfOwnerIdAndAccounts == null)
    	{
    		//initialize the map
    		this.mapOfOwnerIdAndAccounts = new Map<String, Account[]>();
    		
    		//fill the map
	    	for (Account account : this.databaseObjects)
	    	{
	    		List<Account> currentAccounts = this.mapOfOwnerIdAndAccounts.get(account.OwnerId);
	    		if (currentAccounts == null)
	    		{
	    			currentAccounts = new Account[] {account};
	    			this.mapOfOwnerIdAndAccounts.put(account.OwnerId, currentAccounts);
	    		}
	    		else
	    		{
	    			currentAccounts.add(account);
	    		}
	    	}
    	}
    }
    //
    
    
    //
    //Public methods
    //
    public Account getAccountById(String accountId)
    {
        if (String.isBlank(accountId))
        {
            return null;
        }
        
        //the method automatically optimizes its work
        if (this.mapOfAccounts == null)
        {
        	this.optimizeWorkByAccountId();
        }
        return this.mapOfAccounts.get(accountId);
    }
    
    public Account getAccountByExternalId(String externalId)
    {
        if (String.isBlank(externalId))
        {
            return null;
        }
        
        //the method automatically optimizes its work
        if (this.mapOfAccounts == null)
        {
            this.optimizeWorkByExternalAccountId();
        }
        return this.mapOfExternalAccounts.get(externalId);
    }
    
    public Account[] getAccountsByParentId(String parentId)
    {
        if (String.isBlank(parentId))
        {
            return null;
        }
        
        //the method automatically optimizes its work
        if (this.mapOfChildAccounts == null)
        {
            this.optimizeWorkByParentId();
        }
        Account[] resultAccounts = this.mapOfChildAccounts.get(parentId);
        return (resultAccounts != null ? resultAccounts : new Account[0]);
    }
    
    public Account[] getAccountsByRecordTypeName(String recordTypeName)
    {
        if (String.isBlank(recordTypeName))
        {
            return null;
        }
        
        //the method automatically optimizes its work
        if (this.mapOfRecordTypeNamesAndAccounts == null)
        {
            this.optimizeWorkByRecordTypeName();
        }
        Account[] resultAccounts = this.mapOfRecordTypeNamesAndAccounts.get(recordTypeName);
        return (resultAccounts != null ? resultAccounts : new Account[0]);
    }
    
    public Account[] getAccountsByOwnerId(String ownerId)
    {
        if (String.isBlank(ownerId))
        {
            return null;
        }
        
        //the method automatically optimizes its work
        if (this.mapOfOwnerIdAndAccounts == null)
        {
            this.optimizeWorkByOwnerId();
        }
        Account[] resultAccounts = this.mapOfOwnerIdAndAccounts.get(ownerId);
        return (resultAccounts != null ? resultAccounts : new Account[0]);
    }
    
    public String[] extractAccountsIds()
    {
        //the method automatically optimizes its work
        if (this.mapOfAccounts == null)
        {
        	this.optimizeWorkByAccountId();
        }
        
        Set<String> setOfAccountsIds = this.mapOfAccounts.keySet();
        //remove null-value from a set if it exists
        setOfAccountsIds.remove(null); 
        return (new List<String>(setOfAccountsIds));
    }
    
    public String[] extractParentAccountsIds()
    {
        //the method automatically optimizes its work
        if (this.mapOfChildAccounts == null)
        {
            this.optimizeWorkByParentId();
        }
        
        Set<String> setOfParentAccountsIds = this.mapOfChildAccounts.keySet();
        //remove null-value from a set if it exists
        setOfParentAccountsIds.remove(null); 
        return (new List<String>(setOfParentAccountsIds));
    }
    //
    
    
    //
    //Public static factory methods
    //
    public static H_C_AccountHelper createHelperByAccountsList(Account[] accounts)
    {
        H_C_AccountHelper helper = new H_C_AccountHelper();
        helper.setDatabaseObjects(accounts);
        return helper;
    }
    
    public static H_C_AccountHelper createHelperByIds(String[] accountsIds)
    {
        H_C_AccountHelper helper = new H_C_AccountHelper();
        helper.setDatabaseObjects(H_C_AccountDAO.getAccountsByIds(accountsIds));
        return helper;
    }
    
    public static H_C_AccountHelper createHelperByParentsIds(String[] parentsIds)
    {
        H_C_AccountHelper helper = new H_C_AccountHelper();
        helper.setDatabaseObjects(H_C_AccountDAO.getAccountsByParentsIds(parentsIds));
        return helper;
    }
    //
    
    //
    //Public static service methods
    //
    public static String[] extractAccountsIds(Account[] accounts)
    {
        if (accounts == null)
        {
            return null;
        }
        
        //initialize map of accounts
        Map<String, Account> mapOfAccounts = new Map<String, Account>(accounts);
        //extract a set of keys
        Set<String> setOfAccountsIds = mapOfAccounts.keySet();
        //remove null-value from a set if it exists
        setOfAccountsIds.remove(null);
        //convert a set of Ids into a list of Ids and return the result
        return (new List<String>(setOfAccountsIds));
    }
    
    public static String[] extractParentAccountsIds(Account[] accounts)
    {
        if (accounts == null)
        {
            return null;
        }
        
        //initialize a set of Ids
        Set<String> setOfParentAccountsIds = new Set<String>();
        for (Account account : accounts)
        {
        	setOfParentAccountsIds.add(account.ParentId);
        }
        //remove a null-value, because it doesn't have business meaning
        setOfParentAccountsIds.remove(null);
        
        //convert a set of Ids into a list of Ids
        return (new List<String>(setOfParentAccountsIds));
    }
    //
}