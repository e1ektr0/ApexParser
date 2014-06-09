//
//This class contains utilities and data types for sorting
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (13-08-2013)
public class H_C_SortingUtils
{
	//
	//Data types
	//
	/*//This interface is used to change sorting parameters for an object
	public interface IMutableSorting
	{
		//void setSortingParameter(SortingParameter sortingParameter);
		void setSortingParameters(SortingParameter[] sortingParameters);
	}*/
	
	//This enumeration contains possible sorting directions
	public enum SortingOrder
	{
	    Ascending,
	    Descending
	}
	
	//This class encapsulates data of an atomic sorting parameter
	public class SortingParameter
	{
		//
		//Constructors
		//
		public SortingParameter(String fieldName)
		{
			this(fieldName, H_C_SortingUtils.SortingOrder.Ascending);
		}
		
		public SortingParameter(String fieldName, SortingOrder sortingOrder)
		{
			this.fieldName = fieldName;
			this.sortingOrder = sortingOrder;
			//clone default options
			this.var_options = DEFAULT_SORTING_OPTIONS.clone();
		}
		//
		
		//
		//Variables
		//
		private SortingOptions var_options;
		//
		
		//
		//Public properties
		//
		public String fieldName {get; set;}
		
		public SortingOrder sortingOrder {get; set;}
		public String sortingOrderName
		{
			get
			{
				return String.valueOf(this.sortingOrder);
			}
		}
		
		public SortingOptions options
		{
			get
			{
				return this.var_options;
			}
			set
			{
				if (value != null)
				{
					this.var_options = value;
				}
			}
		}
		//
		
		//
		//Public methods
		//
		//this method clones current instance so many times as a number of new field names
		//and set a new field name for an every clone
		public SortingParameter[] clone(String[] newFieldNames)
		{
			//initialize a list of clones 
			List<SortingParameter> newParameters = new SortingParameter[0];
			
			//main algorithm
			if (newFieldNames != null)
			{
				for (String newFieldName : newFieldNames)
				{
					if (String.isNotBlank(newFieldName))
					{
						//clone this instance
						SortingParameter newParameter = this.clone();
						//set new field name for the clone
						newParameter.fieldName = newFieldName;
						newParameters.add(newParameter);
					}
				}
			}
			
			//if the method was not able to create at least one clone then we should
			//return a copy of this instance 
			if (newParameters.size() == 0)
			{
				newParameters.add(this.clone());
			}
			return newParameters;
		}
		//
	}
	
	public class SortingOptions
	{
		//
		//Properties
		//
		public Boolean ignoreStringCase {get; set;}
		public Boolean blankValuesAtEnd {get; set;}
		//
	}
	//
	
	
	//
	//Variables and constants
	//
	public static final SortingOptions DEFAULT_SORTING_OPTIONS;
	static
	{
		DEFAULT_SORTING_OPTIONS = new SortingOptions();
		//set default parameters
		DEFAULT_SORTING_OPTIONS.ignoreStringCase = true;
		DEFAULT_SORTING_OPTIONS.blankValuesAtEnd = true;
	}
	//
	
	
	//
	//Public static methods
	//
	public static SortingOrder getInverseSortingOrder(SortingOrder sortingOrder)
	{
		if (sortingOrder != null)
		{
			if (sortingOrder == H_C_SortingUtils.SortingOrder.Ascending)
			{
				return H_C_SortingUtils.SortingOrder.Descending;
			}
			else if (sortingOrder == H_C_SortingUtils.SortingOrder.Descending)
			{
				return H_C_SortingUtils.SortingOrder.Ascending;
			}
			else
			{
				//if 'SortingOrder' enum is extended in the future then we will get an exception here 
				throw new H_C_Exception('SortingUtils.getInverseSortingOrder: unknown sorting order: '
					+ sortingOrder);
			}
		}
		else
		{
			return H_C_SortingUtils.SortingOrder.Ascending;
		}
	}
	//
}