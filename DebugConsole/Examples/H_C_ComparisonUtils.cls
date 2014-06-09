//
//This class contains utilities for comparisons
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (8-08-2013)
public class H_C_ComparisonUtils
{
	//
	//Public static methods
	//
	public static Integer compareDateTimeValues(DateTime sourceDateTime, DateTime comparedDateTime)
	{
		return compareDateTimeValues(sourceDateTime, comparedDateTime, null);
	}
	
	public static Integer compareDateTimeValues(DateTime sourceDateTime,
		DateTime comparedDateTime, H_C_SortingUtils.SortingOptions options)
	{
		//quick check
		if (sourceDateTime == comparedDateTime)
		{
			return 0;
		}
		
		//check passed options
		if (options == null)
		{
			options = H_C_SortingUtils.DEFAULT_SORTING_OPTIONS;
		}
		
		//MAIN ALGORITHM
		Integer comparisonState;
		if (sourceDateTime != null && comparedDateTime != null)
        {
        	//this branch is for usual situations when both of values are correct
        	comparisonState = (sourceDateTime > comparedDateTime ? 1 : -1);
        }
        else
        {
        	//this branch is for unusual situations when one of values is null
        	//(we should have this separate branch because comparing with Null always returns FALSE)
        	if (options.blankValuesAtEnd)
        	{
        		comparisonState = (sourceDateTime == null ? 1 : -1);
        	}
        	else
        	{
        		comparisonState = (sourceDateTime == null ? -1 : 1);
        	}
        }
        
        return comparisonState;
	}
	
	public static Integer compareStringValues(String sourceString, String comparedString)
	{
		return compareStringValues(sourceString, comparedString, null);
	}
	
	public static Integer compareStringValues(String sourceString, String comparedString,
		H_C_SortingUtils.SortingOptions options)
	{
		//quick check
		if (sourceString == comparedString)
		{
			return 0;
		}
		
		//check passed options
		if (options == null)
		{
			options = H_C_SortingUtils.DEFAULT_SORTING_OPTIONS;
		}
		
		//MAIN ALGORITHM
		Integer comparisonState;
		if (String.isNotBlank(sourceString) && String.isNotBlank(comparedString))
		{
			if (options.ignoreStringCase)
			{
				comparisonState = sourceString.toUpperCase().compareTo(comparedString.toUpperCase());
			}
			else
			{
				comparisonState = sourceString.compareTo(comparedString);
			}
		}
		else
		{
			//this branch is for unusual situations when one of values is null
        	if (options.blankValuesAtEnd)
        	{
        		comparisonState = (String.isBlank(sourceString) ? 1 : -1);
        	}
        	else
        	{
        		comparisonState = (String.isBlank(sourceString) ? -1 : 1);
        	}
		}
		
		return comparisonState;
	}
	
	public static Integer compareIntegerValues(Integer sourceInteger, Integer comparedInteger)
	{
		return compareIntegerValues(sourceInteger, comparedInteger, null);
	}
	
	public static Integer compareIntegerValues(Integer sourceInteger, Integer comparedInteger,
		H_C_SortingUtils.SortingOptions options)
	{
		//quick check
		if (sourceInteger == comparedInteger)
		{
			return 0;
		}
		//check passed options
		if (options == null)
		{
			options = H_C_SortingUtils.DEFAULT_SORTING_OPTIONS;
		}
		
		//MAIN ALGORITHM
		Integer comparisonState;
		if (sourceInteger != null && comparedInteger != null)
		{
			comparisonState = sourceInteger - comparedInteger;
		}
		else
		{
			//this branch is for unusual situations when one of values is null
			if (options.blankValuesAtEnd)
			{
        		comparisonState = (sourceInteger == null ? 1 : -1);
			}
			else
			{
				comparisonState = (sourceInteger == null ? -1 : 1);
			}
		}
		return comparisonState;
	}
	
	public static Integer compareBooleanValues(Boolean sourceBoolean, Boolean comparedBoolean)
	{
		return compareBooleanValues(sourceBoolean, comparedBoolean, null);
	}
	
	public static Integer compareBooleanValues(Boolean sourceBoolean, Boolean comparedBoolean,
		H_C_SortingUtils.SortingOptions options)
	{
		//quick check
		if (sourceBoolean == comparedBoolean)
		{
			//this branch handles the following pairs: T:T, F:F, N:N (where T-true, F-false, N-null) 
			return 0;
		}
		//check passed options
		if (options == null)
		{
			options = H_C_SortingUtils.DEFAULT_SORTING_OPTIONS;
		}
		
		//MAIN ALGORITHM
		Integer comparisonState;
		if (sourceBoolean != null && comparedBoolean != null)
		{
			//this branch handles the following pairs: T:F=>1, F:T=>-1.
			comparisonState = (sourceBoolean == true ? 1 : -1);
		}
		else
		{
			//this branch handles the following pairs: T:N, F:N, N:T, N:F.
			//Comparison state depends on passed options
			if (options.blankValuesAtEnd)
			{
        		comparisonState = (sourceBoolean == null ? 1 : -1);
			}
			else
			{
				comparisonState = (sourceBoolean == null ? -1 : 1);
			}
		}
		return comparisonState;
	}
	
	//it's strongly supposed that
	// - both objects have same data type
	// - the method supports only particular data types: String, Integer, DateTime
	//(extend this method if you need to have one more comparable type)
	public static Integer compareObjects(Object sourceObject, Object comparedObject,
		H_C_SortingUtils.SortingOptions options)
	{
		//quick check
		if (sourceObject == null && comparedObject == null)
		{
			return 0;
		}
		
		//find not null object
		Object notNullObject = (sourceObject == null ? comparedObject : sourceObject);
		
		//call a concrete method according to data type of passed objects
		if (notNullObject instanceOf String)
		{
			return compareStringValues((String)sourceObject, (String)comparedObject, options);
		}
		else if (notNullObject instanceOf DateTime)
		{
			return compareDateTimeValues((DateTime)sourceObject, (DateTime)comparedObject, options);
		}
		else if (notNullObject instanceOf Integer)
		{
			return compareIntegerValues((Integer)sourceObject, (Integer)comparedObject, options);
		}
		else if (notNullObject instanceOf Boolean)
		{
			return compareBooleanValues((Boolean)sourceObject, (Boolean)comparedObject, options);
		}
		else
		{
			throw new H_C_Exception('H_C_ComparisonUtils.compareObjects: objects belongs to data type'
				+ ' which is not known by this method. You should extend this method to support new data type'); 
		}
	}
    
    public static Integer compareObjects(H_C_IDynamicObjectWrapper sourceObject,
		H_C_IDynamicObjectWrapper comparedObject,
		H_C_SortingUtils.SortingParameter[] sortingParameters)
    {
    	//check passed parameters
    	if (sortingParameters == null || sortingParameters.size() == 0)
    	{
    		return 0;
    	}
    	
    	//BRANCH FOR NULL VALUES: we have special branch to handle null objects
    	if (sourceObject == null || comparedObject == null)
    	{
    		if (sourceObject == comparedObject)
    		{
    			return 0;
    		}
    		
    		//for this branch we look at default sorting parameters
    		if (H_C_SortingUtils.DEFAULT_SORTING_OPTIONS.blankValuesAtEnd)
    		{
    			return (sourceObject == null ? 1 : -1);
    		}
    		else
    		{
    			return (sourceObject == null ? -1 : 1);
    		}
    	}
        
        //MAIN ALGORITHM
        Integer comparisonState;
        for (H_C_SortingUtils.SortingParameter parameter : sortingParameters)
        {
        	//extract a field value from a source object 
        	Object sourceValue = sourceObject.getFieldValue(parameter.fieldName);
        	//extract a field value from a compared object
        	Object comparedValue = comparedObject.getFieldValue(parameter.fieldName);
        	//compare field values (use options which are specific for the current parameter)
        	comparisonState = compareObjects(sourceValue, comparedValue, parameter.options);
        	
        	//if comparisonState is not 0 then we don't need to compare other parameters,
        	//else we will check the next parameter in a next iteration
        	if (comparisonState != 0)
        	{
        		//if descending order is required then we should inverse comparisonState
        		if (parameter.sortingOrder == H_C_SortingUtils.SortingOrder.Descending)
        		{
        			comparisonState *= -1;
        		}
        		break;
        	}
        }
        
        return comparisonState;
    }
    
    public static Object getMaximalElement(Comparable[] elements)
    {
    	//check passed parameters
    	if (elements == null || elements.size() == 0)
    	{
    		return null;
    	}
    	
    	//assume that 1st element is a maximal element
    	Object maximalElement = elements[0];
    	for (Integer indexOfElement = 1; indexOfElement < elements.size(); indexOfElement++)
    	{
    		Comparable currentObject = elements[indexOfElement];
    		if (currentObject.compareTo(maximalElement) > 0)
    		{
    			maximalElement = currentObject;
    		}
    	}
    	return maximalElement;
    }
    
    public static Object getMinimalElement(Comparable[] elements)
    {
    	//check passed parameters
    	if (elements == null || elements.size() == 0)
    	{
    		return null;
    	}
    	
    	//assume that 1st element is a minimal element
    	Object minimalElement = elements[0];
    	for (Integer indexOfElement = 1; indexOfElement < elements.size(); indexOfElement++)
    	{
    		Comparable currentObject = elements[indexOfElement];
    		if (currentObject.compareTo(minimalElement) < 0)
    		{
    			minimalElement = currentObject;
    		}
    	}
    	return minimalElement;
    }
	//
}