//
//This class works as a wrapper for 'ActivityHistory' object
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (8-08-2013)
public with sharing class H_C_ActivityHistoryWrapper extends H_C_sObjectControllerWrapper
	implements H_C_IDynamicObjectWrapper, Comparable
{
	//
	//Constructors
	//
	public H_C_ActivityHistoryWrapper(ActivityHistory activity, Map<String, String> commonUrlParameters)
	{
		//super class uses standard controller which can't work with 'ActivityHistory' object
		//that's why we should create a real object: Event or Task
		super(getRealObject(activity), commonUrlParameters);
		
		this.info = activity;
	}
	//
	
	//
	//Static variables and constants
	//
	private static final String START_DATE_TIME_FIELD_NAME = 'StartDateTime';
	
	//declare and initialize the array of sorting parameters which are used for this class by default
	private static final List<H_C_SortingUtils.SortingParameter> DEFAULT_SORTING_PARAMETERS =
		new H_C_SortingUtils.SortingParameter[0];
	static
	{
		H_C_SortingUtils.SortingParameter parameter;
		parameter = new H_C_SortingUtils.SortingParameter('StartDateTime', H_C_SortingUtils.SortingOrder.Descending);
		//by default we want to have descending order for this parameter, but we still want to have
		//null values at the end
		parameter.options.blankValuesAtEnd = false;
		DEFAULT_SORTING_PARAMETERS.add(parameter);
		
		parameter = new H_C_SortingUtils.SortingParameter('LastModifiedDate', H_C_SortingUtils.SortingOrder.Descending);
		DEFAULT_SORTING_PARAMETERS.add(parameter);
		
		parameter = new H_C_SortingUtils.SortingParameter('Subject', H_C_SortingUtils.SortingOrder.Ascending);
		DEFAULT_SORTING_PARAMETERS.add(parameter);
	}
	
	//this array stores sorting parameters which are currently set for this class
	private static H_C_SortingUtils.SortingParameter[] sortingParameters = DEFAULT_SORTING_PARAMETERS;
	//
	
	//
	//Properties
	//
	public ActivityHistory info {get; private set;}
	
	//'ActivityHistory' object doesn't contain StartDateTime field. So, we have to calculate
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
	//
	
	//
	//Private methods
	//
	private static sObject getRealObject(ActivityHistory activity)
	{
		//initialize real object and fill its Id
		sObject realObject;
		if (activity.IsTask)
		{
			realObject = new Task();
		}
		else
		{
			realObject = new Event();
		}
		realObject.Id = activity.Id;
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
    	//convert object to H_C_ActivityHistoryWrapper
        H_C_ActivityHistoryWrapper comparedWrapper = (H_C_ActivityHistoryWrapper)comparedObject;
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