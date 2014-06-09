//
//This class works as a wrapper for 'NoteAndAttachment' object
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (9-08-2013)
public with sharing class H_C_NoteAndAttachmentWrapper extends H_C_sObjectControllerWrapper
	implements H_C_IDynamicObjectWrapper, Comparable
{
	//
	//Constructors
	//
	public H_C_NoteAndAttachmentWrapper(NoteAndAttachment noteAndAttachment,
		Map<String, String> commonUrlParameters)
	{
		//super class uses standard controller which can't work with 'NoteAndAttachment' object
		//that's why we should create a real object: Event or Task
		super(getRealObject(noteAndAttachment), commonUrlParameters);
		this.info = noteAndAttachment;
	}
	//
	
	//
	//Static variables and constants
	//
	//declare and initialize the array of sorting parameters which are used for this class by default
	private static final H_C_SortingUtils.SortingParameter[] DEFAULT_SORTING_PARAMETERS =
		new H_C_SortingUtils.SortingParameter[]
	{
		new H_C_SortingUtils.SortingParameter('Title', H_C_SortingUtils.SortingOrder.Ascending),
		new H_C_SortingUtils.SortingParameter('LastModifiedDate', H_C_SortingUtils.SortingOrder.Descending)
	};
	
	//this array stores sorting parameters which are currently set for this class
	private static H_C_SortingUtils.SortingParameter[] sortingParameters = DEFAULT_SORTING_PARAMETERS;
	//
	
	//
	//Properties
	//
	public NoteAndAttachment info {get; private set;}
	//
	
	//
	//Private methods
	//
	private static sObject getRealObject(NoteAndAttachment noteAndAttachment)
	{
		//initialize real object and fill its Id
		sObject realObject;
		if (noteAndAttachment.IsNote)
		{
			realObject = new Note();
		}
		else
		{
			realObject = new Attachment();
		}
		realObject.Id = noteAndAttachment.Id;
		return realObject;
	}
	//
	
    //
	//Implementation of 'H_C_IDynamicObjectWrapper' interface
	//
	public Object getFieldValue(String fieldName)
	{
		//we consider that it can be necessary to return a value of a complex field
		return H_C_sObjectUtils.getComplexFieldValue(this.info, fieldName);
	}
	//
	
	//
	//Implementation of 'Comparable' interface
	//
    public Integer compareTo(Object comparedObject)
    {
    	//convert object to H_C_NoteAndAttachmentWrapper
        H_C_NoteAndAttachmentWrapper comparedWrapper = (H_C_NoteAndAttachmentWrapper)comparedObject;
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