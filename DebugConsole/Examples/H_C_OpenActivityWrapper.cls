//
//This class works as a wrapper for 'OpenActivity' object
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (7-08-2013)
public with sharing class H_C_OpenActivityWrapper extends H_C_sObjectControllerWrapper
	implements H_C_IDynamicObjectWrapper, Comparable
{
	//
	//Constructors
	//
	public H_C_OpenActivityWrapper(OpenActivity openActivity, Map<String, String> commonUrlParameters)
	{
		//super class uses standard controller which can't work with 'OpenActivity' object
		//that's why we should create a real object: Event or Task
		super(getRealObject(openActivity), commonUrlParameters);
		this.info = openActivity;
	}
	//
	
	//
	//Static variables and constants
	//
	private static final String START_DATE_TIME_FIELD_NAME = 'StartDateTime';
	
	//declare and initialize the array of sorting parameters which are used for this class by default
	private static final H_C_SortingUtils.SortingParameter[] DEFAULT_SORTING_PARAMETERS =
		new H_C_SortingUtils.SortingParameter[]
	{
		new H_C_SortingUtils.SortingParameter('StartDateTime', H_C_SortingUtils.SortingOrder.Ascending),
		new H_C_SortingUtils.SortingParameter('LastModifiedDate', H_C_SortingUtils.SortingOrder.Descending),
		new H_C_SortingUtils.SortingParameter('Subject', H_C_SortingUtils.SortingOrder.Ascending)
	};
	
	//this array stores sorting parameters which are currently set for this class
	private static H_C_SortingUtils.SortingParameter[] sortingParameters = DEFAULT_SORTING_PARAMETERS;
	//
	
	//
	//Properties
	//
	public OpenActivity info {get; private set;}
	
	//'OpenActivity' object doesn't contain StartDateTime field. So, we have to calculate
	//it in the code. ActivityDate field stores only start date of an activity
	public DateTime startDateTime
	{
		get
		{
			if (this.info.IsTask)
			{
				return this.info.ActivityDate;
			}
			else
			{
				//calculate StartDateTime (note that EndDateTime and DurationInMinutes are required
				//fields for 'Event' object - they can't be null)
				return (this.info.EndDateTime.addMinutes((-1) * this.info.DurationInMinutes));
			}
		}
	}
	
	public PageReference getLinkToCloseTask()
	{
		if (this.info.IsTask)
		{
			PageReference link = super.getLinkToEdit();
			//add specific parameter to close a task
			link.getParameters().put(H_C_RequestParameters.CLOSE_TASK, '1');
			return link;
		}
		return null;
	}
	//
	
	//
	//Private methods
	//
	private static sObject getRealObject(OpenActivity openActivity)
	{
		//initialize real object and fill its Id
		sObject realObject;
		if (openActivity.IsTask)
		{
			realObject = new Task();
		}
		else
		{
			realObject = new Event();
		}
		realObject.Id = openActivity.Id;
		return realObject;
	}
	//
	
	//
	//Implementation of 'H_C_IDynamicObjectWrapper' interface
	//
	public Object getFieldValue(String fieldName)
	{
		if (fieldName == START_DATE_TIME_FIELD_NAME)
		{
			return this.startDateTime;
		}
		else
		{
			//we consider that it can be necessary to return a value of a complex field
			return H_C_sObjectUtils.getComplexFieldValue(this.info, fieldName);
		}
	}
	//
	
	//
	//Implementation of 'Comparable' interface
	//
    public Integer compareTo(Object comparedObject)
    {
    	//convert object to H_C_OpenActivityWrapper
        H_C_OpenActivityWrapper comparedWrapper = (H_C_OpenActivityWrapper)comparedObject;
        //compare 2 objects by using current sorting parameters and default options
    	return H_C_ComparisonUtils.compareObjects(this, comparedWrapper, sortingParameters);
    }
    //
    
    
    //
	//Public static methods
	//
	//this method is used to update sorting parameters which are global for this data type
	public static void setSortingParameters(H_C_SortingUtils.SortingParameter[] newSortingParameters)
	{
		if (newSortingParameters != null)
		{
			sortingParameters = newSortingParameters;
		}
		else
		{
			sortingParameters = DEFAULT_SORTING_PARAMETERS;
		}
	}
	//
    
}