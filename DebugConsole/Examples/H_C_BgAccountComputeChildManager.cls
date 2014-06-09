//
//This class implements batch process which is used to compute account children 
//
//Author: CERVELLO INC - Anil Tumati / Sergey Trusov (07-02-2014)
public class H_C_BgAccountComputeChildManager extends H_C_ExtendedApexJob
	implements Database.Stateful
{
	//
	//Constructors
	//
	public H_C_BgAccountComputeChildManager(String queryString)
	{
		this.queryString = queryString;
		this.apexJobName = APEX_JOB_NAME;
	}
	//
	
	//
	//Variables and constants
	//
	private static final String APEX_JOB_NAME = 'APEX Batch process which is used to compute '
		+ 'existing accounts children';
	
	private String queryString;
	
	private List<Account> accounts;
	//
	
    //
    //Public methods (implementation of 'Database.Batchable' interface)
    //
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
    	//write information in the log
        System.debug(LoggingLevel.INFO, '\'' + this.apexJobName + '\' has been started on ' + DateTime.now());
        
        accounts = new List<Account>();
        
        //create a query locator by the passed query string
        return H_C_SoqlUtils.createQueryLocator(this.queryString);
    }
    
    public void execute(Database.BatchableContext BC, Account[] scope)
    {
    	//disable the triggers for the current request, because we don't need
    	//to fire them from this job
    	H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
    	
    	//Collect all Accounts in one list
    	accounts.addAll(scope);
    }
    
    public void finish(Database.BatchableContext BC)
    {
    	// Compute Accounts Children and save the changes
		H_C_AccountUtils.computeAllAccountsChildren(accounts);
        
    	//write information in the log
        System.debug(LoggingLevel.INFO, '\'' + this.apexJobName + '\' has been finished on ' + DateTime.now());
        
        //at the end of the current job we try to start the next job if it has been set before
        this.tryStartNextJob();
    }
    //
}