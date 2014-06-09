//
//This class encapsulates pagination parameters
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (11-09-2013)
public class H_C_PaginationParameters
{
	//
	//Constructors
	//
	public H_C_PaginationParameters()
	{
		this(0, 0, 0);
	}
	
	public H_C_PaginationParameters(Integer totalRecordsNumber,
		Integer numberOfRecordsPerPage, Integer currentPageNumber)
	{
		this.var_totalRecordsNumber = (totalRecordsNumber != null ? totalRecordsNumber : 0);
		this.var_numberOfRecordsPerPage = (numberOfRecordsPerPage != null ? numberOfRecordsPerPage : 0);
		this.var_currentPageNumber = (currentPageNumber != null ? currentPageNumber : 0);
		
		//check and recalculate internal state
		this.checkAndCalculateInternalState(true);
	}
	//
	
	//
	//Variables
	//
	private Integer var_totalRecordsNumber;
	private Integer var_numberOfRecordsPerPage;
	private Integer var_currentPageNumber;
	//
	
	//
	//Constants
	//
	public static final Integer DEFAULT_NUMBER_OF_RECORDS_PER_PAGE = 10;
	//

	//
	//Properties
	//
	public Integer totalRecordsNumber
	{
		get
		{
			return this.var_totalRecordsNumber;
		}
		set
		{
			//fill the variable by a passed value if it's not null, else set the variable to 0
			this.var_totalRecordsNumber = (value != null ? value : 0);
			
			//check and recalculate internal state (quantity of pages depends on this parameter)
			this.checkAndCalculateInternalState(true);
		}
	}
	
	public Integer numberOfRecordsPerPage
	{
		get
		{
			return this.var_numberOfRecordsPerPage;
		}
		set
		{
			//fill the variable by a passed value if it's not null, else set the variable to 0
			this.var_numberOfRecordsPerPage = (value > 0 ? value : DEFAULT_NUMBER_OF_RECORDS_PER_PAGE);
			
			//check and recalculate internal state (quantity of pages depends on this parameter)
			this.checkAndCalculateInternalState(true);
		}
	}
	
	public Integer currentPageNumber
	{
		get
		{
			return this.var_currentPageNumber;
		}
		set
		{
			//fill the variable by a passed value if it's not null, else set the variable to 0
			this.var_currentPageNumber = (value != null ? value : 0);
			//check and recalculate internal state (quantity of pages doesn't
			//depend on this parameter)
			this.checkAndCalculateInternalState(false);
		}
	}
	
	public Boolean hasPreviousPage
    {
    	get
    	{
    		return (this.currentPageNumber > 1);
    	}
    }
    
    public Boolean hasNextPage
    {
    	get
    	{
    		return (this.currentPageNumber < this.quantityOfPages);
    	}
    }
	
	public Integer firstRecordOffset {get; private set;}
	public Integer quantityOfPages {get; private set;}
	//
	
	//
	//Private methods
	//
	private void checkAndCalculateInternalState(Boolean calculateQuantityOfPages)
	{
		//in some cases we don't need to recalculate quantity of pages 
		if (calculateQuantityOfPages)
		{
			this.calculate_quantityOfPages();
		}
		
		//the current page number depends on all parameters and it should be rechecked
		//each time after one of them is changed
		this.checkCurrentPageNumber();
		//first record offset depends on the current page number and should be recalculated
		//after the current page number is changed
		this.calculate_firstRecordOffset();
	}
	
	//<<<<
	private void calculate_firstRecordOffset()
	{
		if (this.var_currentPageNumber > 0)
		{
			this.firstRecordOffset = (this.var_numberOfRecordsPerPage * (this.var_currentPageNumber - 1));
		}
		else
		{
			this.firstRecordOffset = 0;
		}
	}
	
	private void calculate_quantityOfPages()
	{
		if (this.var_numberOfRecordsPerPage > 0)
        {
        	Double doubleValue = (Double)this.var_totalRecordsNumber / this.var_numberOfRecordsPerPage;
            this.quantityOfPages = (Integer)Math.ceil(doubleValue);
        }
        else
        {
        	this.quantityOfPages = 0;
        }
	}
	
	private void checkCurrentPageNumber()
	{
		if (this.quantityOfPages != 0)
		{
			if (this.var_currentPageNumber > this.quantityOfPages)
			{
				//the current page number should not be greater than the amount of pages
				this.var_currentPageNumber = this.quantityOfPages;
			}
			else if (this.var_currentPageNumber < 1)
			{
				//if all data are correct then the current page number should be greater than 0
				this.var_currentPageNumber = 1;
			}
		}
		else
		{
			//this branch is for the state when the current page can't be determined
			this.var_currentPageNumber = 0;
		}
	}
	//
}