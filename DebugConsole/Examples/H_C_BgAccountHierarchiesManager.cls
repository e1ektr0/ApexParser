//
//This class implements batch process which is used to update hierarchy of accounts 
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (16-05-2013)
public class H_C_BgAccountHierarchiesManager extends H_C_ExtendedApexJob
	implements Database.Stateful
{
	//
	//Constructors
	//
	public H_C_BgAccountHierarchiesManager(String queryString)
	{
		this.queryString = queryString;
		this.apexJobName = APEX_JOB_NAME;
	}
	//
	
	//
	//Variables and constants
	//
	private static final String APEX_JOB_NAME = 'APEX Batch process which is used to connect '
		+ 'existing accounts between each other';
	
	private String queryString;
	//
	
    //
    //Public methods (implementation of 'Database.Batchable' interface)
    //
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
    	//write information in the log
        System.debug(LoggingLevel.INFO, '\'' + this.apexJobName + '\' has been started on ' + DateTime.now());
        
        //create a query locator by the passed query string
        return H_C_SoqlUtils.createQueryLocator(this.queryString);
    }
    
    public void execute(Database.BatchableContext BC, Account[] scope)
    {
    	//disable the triggers for the current request, because we don't need
    	//to fire them from this job
    	H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
    	//update hierarchy
        H_C_AccountHierarchyCreationUtils.updateHierarchy(scope, true);
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