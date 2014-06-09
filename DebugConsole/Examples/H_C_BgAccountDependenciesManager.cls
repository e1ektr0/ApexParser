//
//This class implements batch process which is used to manage 'H_C_AccountOpportunity__c'
//objects for all accounts 
//
//Author: CERVELLO INC - CERVELLO INC - Gennadiy Pervukhin (16-05-2013)
public class H_C_BgAccountDependenciesManager
	implements Database.Batchable<sObject>, Database.Stateful
{
	//
	//Constructors
	//
	public H_C_BgAccountDependenciesManager(String queryString)
	{
		this.queryString = queryString;
		this.isRestartForFailedAccountsEnabled = true;
	}
	//
	
	//
	//Variables and constants
	//
	private static final String APEX_JOB_NAME = 'APEX Batch process which is used to manage '
		+ 'account-related objects';
	
	//variable stores query which is used to initialize query locator
	private String queryString;
	
	//this list stores Ids of all accounts which were not correctly processed in this job
	private List<String> allFailedAccountsIds = new List<String>();
	//
	
	//
	//Properties
	//
	//property determines whether the batch can start a new APEX job for failed accounts, or it can't
	public Boolean isRestartForFailedAccountsEnabled {get; set;}
	//
	
	
	//
	//Private methods
	//
	private void startNewJobForFailedAccounts()
	{
		//if restart is possible and there are failed accounts then we start a new job for them
		if (this.isRestartForFailedAccountsEnabled && this.allFailedAccountsIds.size() > 0)
		{
			//generate query string
			String queryString = H_C_AccountDAO.createQueryByAccountsIds(this.allFailedAccountsIds);
			//create job manager and forbid it to start new job for new failed accounts
			H_C_BgAccountDependenciesManager jobManager =
				new H_C_BgAccountDependenciesManager(queryString);
			jobManager.isRestartForFailedAccountsEnabled = false;
			//start APEX job and set scope size to 1
			H_C_ApexJobUtils.StartResults results = H_C_ApexJobUtils.startJob(
				jobManager, 1, H_C_ApexJobUtils.JOB_ROLLUP_ACCOUNT_RELATED_LISTS);
		
			if (results.isStartSuccessful)
			{
				System.debug(LoggingLevel.INFO, 'APEX job has started a new APEX job which'
					+ ' manages related lists. New APEX Job Id = ' + results.jobId);
			}
			else
			{
				System.debug(LoggingLevel.INFO, 'APEX job has not started a new APEX job which'
					+ ' manages related lists. Error Message : ' + results.errorMessage);
			}
		}
	}
	//
	
	
	//
	//Public methods (implementation of 'Database.Batchable' interface)
	//
	public Database.QueryLocator start(Database.BatchableContext BC)
	{
		System.debug(LoggingLevel.INFO, APEX_JOB_NAME + ' has been started on ' + DateTime.now());
		
		return H_C_SoqlUtils.createQueryLocator(this.queryString);
	}
    
	public void execute(Database.BatchableContext BC, Account[] scopeOfAccounts)
	{
		//1) PREPARE MANAGEMENT
		//extract Ids of accounts
		String[] accountsIds = H_C_AccountHelper.extractAccountsIds(scopeOfAccounts);
		
		//disable the triggers for the current request, because we don't need
		//to fire them from this job
		H_C_CustomSettings.setTriggersSettingForCurrentRequest(false);
		
		//2) START MANAGEMENT
		H_C_OperationResults results;
		//2.1 - perform the 1st operation and get the results
		results = H_C_AccountOpportunityUtils.manageMappingsForAccounts(accountsIds);
		//2.2 - if the previous operation was successful then perform the new one, else ignore it
		if (results.isOperationSuccessful)
		{
			results = H_C_AccountContactUtils.manageMappingsForAccounts(accountsIds);
		}
		//2.4 - if the previous operation was successful then perform the new one, else ignore it
		if (results.isOperationSuccessful)
		{
			results = H_C_AccountInvoiceUtils.manageMappingsForAccounts(accountsIds);
		}
		//2.5 - if the previous operation was successful then perform the new one, else ignore it
		if (results.isOperationSuccessful)
		{
			results = H_C_AccountContractUtils.manageMappingsForAccounts(accountsIds);
		}
		//2.6 - if the previous operation was successful then perform the new one, else ignore it
		if (results.isOperationSuccessful)
		{
			results = H_C_AccountAccountPlanUtils.manageMappingsForAccounts(accountsIds);
		}
		//2.7 - if the previous operation was successful then perform the new one, else ignore it
		if (results.isOperationSuccessful)
		{
			results = H_C_AccountCapitalEquipmentIBUtils.manageMappingsForAccounts(accountsIds);
		}
		//2.8 - if the previous operation was successful then perform the new one, else ignore it
		if (results.isOperationSuccessful)
		{
			results = H_C_AccountERFUtils.manageMappingsForAccounts(accountsIds);
		}
		//3) PROCESS THE RESULTS OF ALL OPERATIONS
		//if there were any errors during the above operations then we add Ids of current accounts
		//into the list of failed accounts
		if (!results.isOperationSuccessful)
		{
			this.allFailedAccountsIds.addAll(accountsIds);
		}
	}
	
	public void finish(Database.BatchableContext BC)
	{
		//start new job for failed accounts if it's possible and needed
		this.startNewJobForFailedAccounts();
		
		System.debug(LoggingLevel.INFO, APEX_JOB_NAME + ' has been finished on ' + DateTime.now());
	}
	//
	
	
	
	
	
	//
    //Private Unit tests (I wanted to use @TestVisible annotation for private
    //'allFailedAccountsIds' variable and test this class in a separate class,
    //but this annotation is still not supported by IDE and breaks Outline window)
    //
	@IsTest
	private static void test_batchMethods()
	{
		//the test simply covers the methods of the class 
		H_C_BgAccountDependenciesManager manager = new H_C_BgAccountDependenciesManager(null);
		manager.start(null);
		manager.execute(null, new Account[0]);
		Account testAccount1 = H_C_UnitTestUtils.createAccount('Account1');
		manager.allFailedAccountsIds = new String[] {testAccount1.Id};
		manager.finish(null);
	}
	//
}