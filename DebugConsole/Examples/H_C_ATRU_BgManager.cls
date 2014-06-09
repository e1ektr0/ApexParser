//
//This class implements batch process which is used to roll up teams for accounts
//Used abbreviations:
// - ATRU means 'Account Team Roll-Up'
// - ATM means 'Account Team Member'
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (18-10-2013)
public class H_C_ATRU_BgManager extends H_C_ExtendedApexJob
	implements Database.Stateful
{
	//
	//Constructors
	//
	public H_C_ATRU_BgManager(String queryString, H_C_ATRU_Manager.Options managerOptions)
	{
		if (String.isBlank(queryString) || managerOptions == null)
		{
			throw new H_C_Exception('H_C_ATRU_BgManager was initialized by incorrect parameters');
		}
		
		this.queryString = queryString;
		this.managerOptions = managerOptions;
		this.apexJobName = APEX_JOB_NAME;
	}
	
	public H_C_ATRU_BgManager(H_C_SoqlUtils.IQueryCreator queryCreator,
		H_C_ATRU_Manager.Options managerOptions)
	{
		if (queryCreator == null || managerOptions == null)
		{
			throw new H_C_Exception('H_C_ATRU_BgManager was initialized by incorrect parameters');
		}
		
		this.queryCreator = queryCreator;
		this.managerOptions = managerOptions;
		this.apexJobName = APEX_JOB_NAME;
	}
	//
	
	//
	//Variables and constants
	//
	private static final String APEX_JOB_NAME = 'APEX Batch process which is used to roll up '
		+ 'teams for existing accounts';
	
	private String queryString;
	private H_C_SoqlUtils.IQueryCreator queryCreator;
	private H_C_ATRU_Manager.Options managerOptions;
	//
	
    //
    //Public methods (implementation of 'Database.Batchable' interface)
    //
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
    	//write information in the log
        System.debug(LoggingLevel.INFO, '\'' + this.apexJobName + '\' has been started on ' + DateTime.now());
        
        if (this.queryCreator != null)
        {
        	//update queryString
        	this.queryString = this.queryCreator.createQuery();
        	//we don't longer need to have the query creator
        	this.queryCreator = null;
        }
        
        //create a query locator by the query string
        Database.QueryLocator queryLocator = H_C_SoqlUtils.createQueryLocator(this.queryString);
        if (queryLocator == null)
        {
        	//if it's not possible to create a correct query locator then we use an empty locator
        	queryLocator = H_C_SoqlUtils.createEmptyQueryLocator();
        }
        return queryLocator;
    }
    
    public void execute(Database.BatchableContext BC, Account[] scopeOfAccounts)
    {
    	//initialize ATRU manager and start the process
    	H_C_ATRU_Manager manager = new H_C_ATRU_Manager(scopeOfAccounts, this.managerOptions);
    	manager.updateTeams();
    }
    
    public void finish(Database.BatchableContext BC)
    {
        //write information in the log
        System.debug(LoggingLevel.INFO, '\'' + this.apexJobName + '\' has been finished on ' + DateTime.now());
        
        //at the end of the current job we try to start the next job if it has been set before
        this.tryStartNextJob();
    }
    //
}