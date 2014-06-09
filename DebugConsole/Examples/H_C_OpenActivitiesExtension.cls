//
//This class is used as an extension for a page which shows open activities of an account
//#INFO: Class is specially declared as 'without sharing', because there are too many
//restrictions for working with activities for non-admin users. 'Without sharing' permission
//gives us the possibility to read all data that we want.
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (5-08-2013)
public without sharing class H_C_OpenActivitiesExtension extends H_C_AccountExtension
{
	//
	//Constructors
	//
	public H_C_OpenActivitiesExtension(Apexpages.StandardController controller)
	{
		super(controller, Page.H_C_OpenActivities);
		this.initialize();
	}
	//
	
	//
	//Variables and constants
	//
	private static final String ASSIGNED_TO_COLUMN_KEY = 'Owner.FullName';
	private static final String CONTACT_FULL_NAME_COLUMN_KEY = 'Who.FullName';
	//
	
	//
	//Properties
	//
	public H_C_OpenActivityWrapper[] openActivityWrappers {get; private set;}
	//
	
	//
	//Private methods
	//
	private void initialize()
	{
		//STEP #1: get the data
		//get activities from account and its child accounts
		List<OpenActivity> openActivities =
			H_C_ActivityDAO.getOpenActivitiesByAccountId(this.accountId, true);
		//create wrappers for all found activities
		this.openActivityWrappers = createWrappers(openActivities);
		
		//STEP #2: if page is inline then we use default sorting and should simply apply it,
		//else we should initialize and apply special sorting parameters
		if (this.isPageInline)
		{
			this.applyCurrentSorting();
		}
		else
		{
			this.setNewSorting('StartDateTime');
		}
	}
	
	private H_C_OpenActivityWrapper[] createWrappers(OpenActivity[] openActivities)
	{
		List<H_C_OpenActivityWrapper> wrappers = new List<H_C_OpenActivityWrapper>();
		if (openActivities != null)
		{
			//initialize specific URL parameters for links on the page  
			Map<String, String> commonUrlParameters = createParametersForOutgoingLinks();
			//create wrappers
			for (OpenActivity openActivity : openActivities)
			{
				wrappers.add(new H_C_OpenActivityWrapper(openActivity, commonUrlParameters));
			}
		}
		return wrappers;
	}
	
	private void setNewSorting(String sortingColumnName)
	{
		if (String.isNotBlank(sortingColumnName))
		{
			//if a user selects a column which is not currently used for a sorting then we should change
	    	//a sorting field and use default order, else we should change a sorting order only
	    	if (this.currentSortingParameter == null
	    		|| this.currentSortingParameter.fieldName != sortingColumnName)
	    	{
	    		//change current sorting parameter to a new field
	    		this.currentSortingParameter = new H_C_SortingUtils.SortingParameter(
	    			sortingColumnName, H_C_SortingUtils.SortingOrder.Ascending);
	    		//on this page we should show blank values at first
	    		currentSortingParameter.options.blankValuesAtEnd = false;
	    	}
	    	else
	    	{
	    		//change sorting order to an inverse order
	    		this.currentSortingParameter.sortingOrder = H_C_SortingUtils.getInverseSortingOrder(
	    			this.currentSortingParameter.sortingOrder);
	    	}
	    	this.applyCurrentSorting();
		}
	}
	
	private void applyCurrentSorting()
	{
		//if page is inline then we do not use custom sorting, else we should apply custom parameters
		if (!this.isPageInline && this.currentSortingParameter != null)
		{
			List<H_C_SortingUtils.SortingParameter> parameters;
			if (this.currentSortingParameter.fieldName == ASSIGNED_TO_COLUMN_KEY)
			{
				//break current sorting parameter into 2 real parameters
				parameters = currentSortingParameter.clone(new String[] {'Owner.LastName', 'Owner.FirstName'});
			}
			else if (this.currentSortingParameter.fieldName == CONTACT_FULL_NAME_COLUMN_KEY)
			{
				//break current sorting parameter into 2 real parameters
				parameters = currentSortingParameter.clone(new String[] {'Who.LastName', 'Who.FirstName'});
			}
			else
			{
				parameters = new H_C_SortingUtils.SortingParameter[] {this.currentSortingParameter};
			}
			
			//set parameters of a current sorting on 'H_C_OpenActivityWrapper' level
			H_C_OpenActivityWrapper.setSortingParameters(parameters);
		}
		//sort current wrappers
		this.openActivityWrappers.sort();
	}
	
	private H_C_PaginationParameters getDefaultPaginationParameters()
	{
		return new H_C_PaginationParameters(this.openActivityWrappers.size(),
			H_C_PaginationParameters.DEFAULT_NUMBER_OF_RECORDS_PER_PAGE, 1);
	}
	//
}