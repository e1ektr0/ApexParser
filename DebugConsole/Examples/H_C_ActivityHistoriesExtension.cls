//
//This class is used as an extension for a page which shows activity histories of an account.
//#INFO: Class is specially declared as 'without sharing', because there are too many
//restrictions for working with activities for non-admin users. 'Without sharing' permission
//gives us the possibility to read all data that we want.
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (8-08-2013)
public without sharing class H_C_ActivityHistoriesExtension extends H_C_AccountExtension
{
	//
	//Constructors
	//
	public H_C_ActivityHistoriesExtension(Apexpages.StandardController controller)
	{
		super(controller, Page.H_C_ActivityHistories);
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
	public H_C_ActivityHistoryWrapper[] activityHistoryWrappers {get; private set;}
	//
	
	//
	//Private methods
	//
	private void initialize()
	{
		//STEP #1: get the data
		//get activities from account and its child accounts
		List<ActivityHistory> activities =
			H_C_ActivityDAO.getActivityHistoriesByAccountId(this.accountId, true);
		//create wrappers for all found activities
		this.activityHistoryWrappers = createWrappers(activities);
		
		//STEP #2: if page is not inline then we should initialize and apply special sorting parameters,
		//else we will use default sorting and should simply apply it.
		if (!this.isPageInline)
		{
			//set 'StartDateTime' as a sorting column
			this.currentSortingParameter = new H_C_SortingUtils.SortingParameter(
    			'StartDateTime', H_C_SortingUtils.SortingOrder.Descending);
    		//on this page we should show blank values at first
    		currentSortingParameter.options.blankValuesAtEnd = false;
		}
		this.applyCurrentSorting();
	}
	
	private H_C_ActivityHistoryWrapper[] createWrappers(ActivityHistory[] activities)
	{
		List<H_C_ActivityHistoryWrapper> wrappers = new List<H_C_ActivityHistoryWrapper>();
		if (activities != null)
		{
			//initialize specific URL parameters for links on the page  
			Map<String, String> commonUrlParameters = createParametersForOutgoingLinks();
			//create wrappers
			for (ActivityHistory activity : activities)
			{
				wrappers.add(new H_C_ActivityHistoryWrapper(activity, commonUrlParameters));
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
		//if page is inline then we do not use custom sorting, else we should apply custom parameter
		if (!this.isPageInline)
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
			
			//set parameters of a current sorting on 'H_C_ActivityHistoryWrapper' level
			H_C_ActivityHistoryWrapper.setSortingParameters(parameters);
		}
		//sort current wrappers
		this.activityHistoryWrappers.sort();
	}
	
	private H_C_PaginationParameters getDefaultPaginationParameters()
	{
		return new H_C_PaginationParameters(this.activityHistoryWrappers.size(),
			H_C_PaginationParameters.DEFAULT_NUMBER_OF_RECORDS_PER_PAGE, 1);
	}
	//
}