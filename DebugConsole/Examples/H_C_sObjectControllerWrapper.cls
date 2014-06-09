//
//This class works as a wrapper for a standard controller of sObject
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (7-08-2013)
public virtual with sharing class H_C_sObjectControllerWrapper
{
	//
	//Constructors
	//
	public H_C_sObjectControllerWrapper(sObject dbObject)
	{
		this(dbObject, null);
	}
	
	public H_C_sObjectControllerWrapper(sObject dbObject, Map<String, String> commonUrlParameters)
	{
		if (dbObject == null)
		{
			//Null object should not be passed to a wrapper
			throw new H_C_Exception('H_C_sObjectControllerWrapper cannot be initialized for Null-object');
		}
		this.commonUrlParameters = commonUrlParameters;
		this.initialize(dbObject);
	}
	//
	
	//
	//Variables
	//
	protected ApexPages.StandardController controller;
	protected Map<String, String> commonUrlParameters;
	//
	
	//
	//Properties
	//
	public PageReference getLinkToView()
	{
		PageReference link = this.controller.view();
		addCommonUrlParameters(link);
		return link;
	}
	
	public PageReference getLinkToEdit()
	{
		PageReference link = this.controller.edit();
		addCommonUrlParameters(link);
		return link;
	}
	
	public PageReference getLinkToDelete()
	{
		PageReference link = this.controller.delete();
		addCommonUrlParameters(link);
		return link;
	}
	//
	
	//
	//Private methods
	//
	private void initialize(sObject dbObject)
	{
		//initialize controller
		this.controller = new ApexPages.StandardController(dbObject);
	}
	
	private void addCommonUrlParameters(PageReference pageLink)
	{
		if (this.commonUrlParameters != null)
		{
			pageLink.getParameters().putAll(this.commonUrlParameters);
		}
	}
	//
}