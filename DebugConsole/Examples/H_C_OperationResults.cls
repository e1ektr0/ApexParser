//
//This class encapsulates the results of any operation
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (31-05-2013)
public class H_C_OperationResults
{
	//
	//Constructors
	//
	public H_C_OperationResults(Boolean isOperationSuccessful)
	{
		this.isOperationSuccessful = isOperationSuccessful;
		this.errors = new List<ErrorType>();
		this.exceptions = new List<Exception>();
		this.var_results = new List<Object>();
	}
	//
	
	//
	//Variables
	//
	private List<Object> var_results;
	//
	
	//
	//Properties
	//
	public Boolean isOperationSuccessful {get; set;}
	public List<ErrorType> errors {get; private set;}
	public List<Exception> exceptions {get; private set;}
	public List<Object> results
	{
		get
		{
			return this.var_results;
		}
		set
		{
			if (value != null)
			{
				this.var_results = value;
			}
		}
	}
	//
	
	//
	//Data types
	//
	public enum ErrorType
	{
		DMLRowsLimitExceeded,
		DMLStatementsLimitExceeded
	}
	//
}