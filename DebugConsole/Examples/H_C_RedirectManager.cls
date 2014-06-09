//
//This class is used as an extension for pages which override standard view/edit/delete
//actions of service mapping objects 
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (3-06-2013)
public with sharing class H_C_RedirectManager
{
	//
	//Constructors
	//
    public H_C_RedirectManager(ApexPages.StandardController controller)
    {
    	this.sourceController = controller;
    	this.initialize();
    }
    //
    
    //
    //Variables and constants
    //
    private static final String VIEW_PAGE_SUFFIX = '_View';
    private static final String EDIT_PAGE_SUFFIX = '_Edit';
    private static final String DELETE_PAGE_SUFFIX = '_Delete';
    
    //source controller is a standard controller which works with service mapping objects
    //(for example, H_C_AccountOpportunity__c, H_C_AccountContact__c, H_C_AccountShipment__c)
    private ApexPages.StandardController sourceController;
    //destination controller is a standard controller which returns links for view/edit/delete
    //actions of a real object (for example, Opportunity, Contact) 
    private ApexPages.StandardController destinationController;
    //service suffix of the current page 
    private String currentPageSuffix;
    //
    
    //
    //Private methods
    //
    private void initialize()
    {
    	this.initializeDestinationController();
    	this.analyzePageName();
    }
    
    //this methods initializes the destination controller
    private void initializeDestinationController()
    {
    	sObject serviceObject = this.sourceController.getRecord();
    	if (this.sourceController != null && serviceObject != null)
    	{
    		String serviceObjectType = String.valueOf(serviceObject.getSObjectType());
    		
    		//initialize and fill a real object according to the service object 
    		sObject realObject;
    		if (serviceObjectType == 'H_C_AccountOpportunity__c')
    		{
    			//reread the service object from DB to include necessary fields
    			H_C_AROM_ServiceMappingDAO dao = new H_C_AROM_ServiceMappingDAO(
    				H_C_AROM_Configurator.getMetadata('Opportunity'));
    			serviceObject = dao.getMappingById(sourceController.getId());
    			if (serviceObject != null)
    			{
    				//initialize a real object
    				realObject = new Opportunity();
    				realObject.Id = ((H_C_AccountOpportunity__c)serviceObject).Opportunity__c;
    			}
    		}
    		else if (serviceObjectType == 'H_C_AccountContact__c')
    		{
    			//reread the service object from DB to include necessary fields
    			H_C_AROM_ServiceMappingDAO dao = new H_C_AROM_ServiceMappingDAO(
    				H_C_AROM_Configurator.getMetadata('Contact'));
    			serviceObject = dao.getMappingById(sourceController.getId());
    			if (serviceObject != null)
    			{
    				//initialize a real object
    				realObject = new Contact();
    				realObject.Id = ((H_C_AccountContact__c)serviceObject).Contact__c;
    			}
    		}
    		else if (serviceObjectType == 'H_C_AccountContract__c')
    		{
    			//reread the service object from DB to include necessary fields 
    			H_C_AROM_ServiceMappingDAO dao = new H_C_AROM_ServiceMappingDAO(
    				H_C_AROM_Configurator.getMetadata('Contract'));
    			serviceObject = dao.getMappingById(sourceController.getId());
    			if (serviceObject != null)
    			{
    				//initialize a real object
    				realObject = new Contract();
    				realObject.Id = ((H_C_AccountContract__c)serviceObject).Contract__c;
    			}
    		}
    		else if (serviceObjectType == 'H_C_AccountInvoice__c')
    		{
    			//reread the service object from DB to include necessary fields 
    			H_C_AROM_ServiceMappingDAO dao = new H_C_AROM_ServiceMappingDAO(
    				H_C_AROM_Configurator.getMetadata('Invoice__c'));
    			serviceObject = dao.getMappingById(sourceController.getId());
    			if (serviceObject != null)
    			{
    				//initialize a real object
    				realObject = new Invoice__c();
    				realObject.Id = ((H_C_AccountInvoice__c)serviceObject).Invoice__c;
    			}
    		}
    		else if (serviceObjectType == 'H_C_AccountAccountPlan__c')
    		{
    			//reread the service object from DB to include necessary fields 
    			H_C_AROM_ServiceMappingDAO dao = new H_C_AROM_ServiceMappingDAO(
    				H_C_AROM_Configurator.getMetadata('Account_Plan__c'));
    			serviceObject = dao.getMappingById(sourceController.getId());
    			if (serviceObject != null)
    			{
    				//initialize a real object
    				realObject = new Account_Plan__c();
    				realObject.Id = ((H_C_AccountAccountPlan__c)serviceObject).AccountPlan__c;
    			}
    		}
    		else if (serviceObjectType == 'H_C_AccountCapitalEquipmentIB__c')
    		{
    			//reread the service object from DB to include necessary fields 
    			H_C_AROM_ServiceMappingDAO dao = new H_C_AROM_ServiceMappingDAO(
    				H_C_AROM_Configurator.getMetadata('Capital_Equipment_Installed_Base__c'));
    			serviceObject = dao.getMappingById(sourceController.getId());
    			if (serviceObject != null)
    			{
    				//initialize a real object
    				realObject = new Capital_Equipment_Installed_Base__c();
    				realObject.Id = ((H_C_AccountCapitalEquipmentIB__c)serviceObject).CapitalEquipmentInstalledBase__c;
    			}
    		}
    		else if (serviceObjectType == 'H_C_AccountERF__c')
    		{
    			//reread the service object from DB to include necessary fields 
    			H_C_AROM_ServiceMappingDAO dao = new H_C_AROM_ServiceMappingDAO(
    				H_C_AROM_Configurator.getMetadata('ERF__c'));
    			serviceObject = dao.getMappingById(sourceController.getId());
    			if (serviceObject != null)
    			{
    				//initialize a real object
    				realObject = new ERF__c();
    				realObject.Id = ((H_C_AccountERF__c)serviceObject).ERF__c;
    			}
    		}
    		
    		//create a destination controller from the real object if it was created
    		//and filled corectly
    		if (realObject != null && String.isNotBlank(realObject.Id))
    		{
    			this.destinationController = new ApexPages.StandardController(realObject);
    		}
    	}
    }
    
    //the method analyzes the current page name and extract service suffix which
    //determines action type: view/edit/delete  
    private void analyzePageName()
    {
    	//get URL of the current pgae 
    	String currentUrl = ApexPages.currentPage().getUrl();
    	//extract service suffix of the page from its URL
    	if (currentUrl.containsIgnoreCase(VIEW_PAGE_SUFFIX))
    	{
    		//suffix for view action
    		this.currentPageSuffix = VIEW_PAGE_SUFFIX;
    	}
    	else if (currentUrl.containsIgnoreCase(EDIT_PAGE_SUFFIX))
    	{
    		//suffix for edit action
    		this.currentPageSuffix = EDIT_PAGE_SUFFIX;
    	}
    	else if (currentUrl.containsIgnoreCase(DELETE_PAGE_SUFFIX))
    	{
    		//suffix for delete action
    		this.currentPageSuffix = DELETE_PAGE_SUFFIX;
    	}
    }
    //
    
    //
    //Public methods
    //
    public PageReference redirect()
    {
    	PageReference finalPage = null;
    	//if destination controller is correct and service suffix is correctly determined
    	//then we can return correct link to an action, else we return null which means
    	//redirect to the current page 
    	if (this.destinationController != null && this.currentPageSuffix != null)
    	{
    		if (this.currentPageSuffix == VIEW_PAGE_SUFFIX)
    		{
    			//final page is a view page of a real object
    			finalPage = this.destinationController.view();
    		}
    		else if (this.currentPageSuffix == EDIT_PAGE_SUFFIX)
    		{
    			//final page is a edit page of a real object
    			finalPage = this.destinationController.edit();
    		}
    		else if (this.currentPageSuffix == DELETE_PAGE_SUFFIX)
    		{
    			//final page is a delete page of a real object
    			finalPage = this.destinationController.delete();
    		}
    		
    		//if final page is known then we should set necessary URL parameters
    		if (finalPage != null)
    		{
    			//get URL parameters of the current page
    			Map<String, String> currentPageParameters = ApexPages.currentPage().getParameters();
    			if (currentPageParameters != null)
    			{
    				//get URL parameters of the destination page
	    			Map<String, String> finalPageParameters = finalPage.getParameters();
	    			/*for (String key : currentPageParameters.keySet())
	    			{
	    				finalPageParameters.put(key, currentPageParameters.get(key));
	    			}*/
	    			//take retURL parameters from the current page and put it into the destination
	    			//page. This parameters is used by SF for redirect from a page back to a source
	    			//page (for example, after a user clicks on 'Save' button on edit page SF redirects
	    			//him to a page from which he opened editing)
	    			finalPageParameters.put('retURL', currentPageParameters.get('retURL'));
    			}
    		}
    	}
    	return finalPage;
    }
    //
}