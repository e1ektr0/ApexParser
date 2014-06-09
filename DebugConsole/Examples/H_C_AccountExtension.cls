//
//This class is a parent class for concrete extensions of Account.
//IMPORTANT: Class is specially not declared as either with or without sharing,
//because child classes should take care about it
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (14-08-2013)
public abstract class H_C_AccountExtension implements H_C_PaginatorBinder
{
	//
	//Constructors
	//
	public H_C_AccountExtension(Apexpages.StandardController controller,
		PageReference linkToIndependentListPage)
	{
		if (controller == null)
		{
			//Null controller should not be passed to an extension
			throw new H_C_Exception('H_C_AccountExtension cannot be initialized by Null-controller');
		}
		
		//set variables
		this.accountId = controller.getId();
		this.linkToIndependentListPage = linkToIndependentListPage;
		
		//initialize parameters of this class (parent class) 
		this.initializeParent();
	}
	//
	
	//
	//Variables
	//
	private H_C_PaginationParameters paginationParameters;
	//
	
	//
	//Properties
	//
	public String accountId {get; private set;}
	
	public Boolean isPageInline {get; private set;}
	
	public PageReference linkToIndependentListPage {get; protected set;}
	
	public H_C_SortingUtils.SortingParameter currentSortingParameter {get; set;}
	//
	
	//
	//Private and protected methods
	//
	private void initializeParent()
	{
		//STEP #1: initialize 'isPageInline' parameter
		this.isPageInline = isPageInline(ApexPages.currentPage());
		
		//STEP #2: set correct parameters for 'linkToIndependentListPage'
		if (this.linkToIndependentListPage != null)
		{
			this.linkToIndependentListPage.setRedirect(true);
			//set parameters
			Map<String, String> mapOfParameters = this.linkToIndependentListPage.getParameters();
			mapOfParameters.put(H_C_RequestParameters.ID, this.accountId);
		}
	}
	
	protected Map<String, String> createParametersForOutgoingLinks()
	{
		//initialize specific URL parameters for links on the page  
		Map<String, String> commonUrlParameters = new Map<String, String>();
		if (this.isPageInline)
		{
			//add return URL to return back to Account layout (not to the custom page)
			commonUrlParameters.put(H_C_RequestParameters.RETURN_URL, '/' + this.accountId);
		}
		else
		{
			//add return URL to return back to the current page
			commonUrlParameters.put(H_C_RequestParameters.RETURN_URL, ApexPages.currentPage().getUrl());
		}
		return commonUrlParameters;
	}
	
	//#INFO: this method should be overriden in child classes to implement specific reactions
	//on concrete column names 
	private abstract void setNewSorting(String sortingColumnName);
	
	//#INFO: this method should be overriden in child classes to return specific default
	//pagination parameters
	private abstract H_C_PaginationParameters getDefaultPaginationParameters();
	//
	
	
	//
	//Private static methods
	//
	private static Boolean isPageInline(PageReference page)
	{
		String parameterValue = null;
		if (page != null)
		{
			//try to find necessary parameter and convert its value to boolean type
			parameterValue = page.getParameters().get(H_C_RequestParameters.IS_PAGE_INLINE);
		}
		return (String.isBlank(parameterValue) ? false : true);
	}
	//
	
	//
	//Implementation of 'H_C_PaginatorBinder' interface + returning of the binder
	//
	public H_C_PaginationParameters getPaginationParameters()
	{
		if (this.paginationParameters == null)
		{
			//initialize pagination parameters by default
			this.paginationParameters = this.getDefaultPaginationParameters();
		}
		return this.paginationParameters;
	}
	
	public void setPaginationParameters(H_C_PaginationParameters parameters)
	{
		this.paginationParameters = parameters;
	}
	
	public H_C_PaginatorBinder getPaginationBinder()
	{
		return this;
	}
	//
	
	//
	//Public methods
	//
	public void onNewSortingSelected()
	{
		//extract sorting column name from parameters 
		String sortingColumnName = ApexPages.currentPage().getParameters().get(
			H_C_RequestParameters.SORTING_COLUMN);
		if (String.isBlank(sortingColumnName))
		{
			return;
		}
		
		//set new sorting
    	this.setNewSorting(sortingColumnName);
	}
	//
}