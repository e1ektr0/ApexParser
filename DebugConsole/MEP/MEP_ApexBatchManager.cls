//
//This class is a wrapper for all APEX batches. We can use it for all operations.
//(So it is necessary only to create class which implements 'MEP_Operation' interface
//and then use it to parametrize the current class)  
//
//Author: Gennadiy Pervukhin
global with sharing class MEP_ApexBatchManager
	implements Database.Batchable<MEP_Operation>, Database.AllowsCallouts
{
	//
	//Constructors
	//
	public MEP_ApexBatchManager(String name, List<MEP_Operation> operations,MEP_Operation start, MEP_Operation finish)
	{
		this.name = name;
		this.operations = operations;
		this.start = start;
		this.finish = finish;	
	}
	
	
	public MEP_ApexBatchManager(String name, List<MEP_Operation> operations)
	{
		this.name = name;
		this.operations = operations;
	}
	
	public MEP_ApexBatchManager(List<MEP_Operation> operations)
	{
		this.name = 'Unknown batch';
		this.operations = operations;
	}
	//
	
	//
	//Variables
	//
	private List<MEP_Operation> operations;
	private MEP_Operation start;
	private MEP_Operation finish;
	
	//
	
	//
	//Properties
	//
	public String name
	{
		get;
		set;
	}
	//
	
	//
	//Global methods (implementation of 'Database.Batchable' interface)
	//
	global Iterable<MEP_Operation> start(Database.BatchableContext BC)
	{
		if(start!=null)start.execute();
		System.debug('\'' + this.name + '\' has been started on ' + DateTime.now());
		return this.operations;
	}
	
	global void execute(Database.BatchableContext BC, List<MEP_Operation> scope)
	{
		MEP_OperationUtils.executeOperations(scope);
	}
	
	global void finish(Database.BatchableContext BC)
	{
		if(finish!=null)finish.execute();
		System.debug('\'' + this.name + '\' has been finished on ' + DateTime.now());
	}
	//
}