//
//This class is used as a controller for 'MEP_Paginator' component
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (11-09-2013)
public class H_C_PaginatorController
{
	//
	//Constructors
	//
	public H_C_PaginatorController()
	{
		this.initialize();
	}
	//
	
	//
	//Variables and constants
	//
	private static final Integer[] POSSIBLE_NUMBERS_OF_RECORDS_PER_PAGE =
		new Integer[] {10, 25, 50, 100, 200};
	
	private String var_selectedPageNumberInString;
	private H_C_PaginatorBinder binder;
	//
	
	//
	//Properties
	//
	//this property is for attribute
	public H_C_PaginatorBinder binderAttribute
	{
		get;
		set
		{
			this.binder = value;
			this.setParametersFromBinder();
		}
	}
	
	public String selectedPageNumberInString
    {
    	get
    	{
    		return String.valueOf(this.parameters.currentPageNumber);
    	}
    	set
    	{
    		this.var_selectedPageNumberInString = value;
    	}
    }
	
	public H_C_PaginationParameters parameters {get; private set;}
	
	public List<SelectOption> optionsForRecordsPerPage {get; private set;}
    //
    
    //
    //Private methods
    //
    private void initialize()
    {
    	//initialize default parameters
		this.parameters = new H_C_PaginationParameters(0,
			H_C_PaginationParameters.DEFAULT_NUMBER_OF_RECORDS_PER_PAGE, 1);
    	
    	//initialize options for numbers of records per a page
    	this.optionsForRecordsPerPage = new SelectOption[0];
    	for (Integer possibleNumber : POSSIBLE_NUMBERS_OF_RECORDS_PER_PAGE)
    	{
    		SelectOption option = new SelectOption(String.valueOf(possibleNumber),
    			String.valueOf(possibleNumber));
    		this.optionsForRecordsPerPage.add(option);
    	}
    }
    
    private void setParametersFromBinder()
    {
    	if (this.binder != null)
    	{
    		//read parameters from the binder
    		H_C_PaginationParameters parametersFromBinder = this.binder.getPaginationParameters();
    		if (parametersFromBinder != null)
	    	{
	    		//replace the current parameters by parameters from the binder
	    		this.parameters = parametersFromBinder;
	    	}
    	}
    }
    
    private void generateEvent()
    {
    	if (this.binder != null)
    	{
    		this.binder.setPaginationParameters(this.parameters);
    	}
    }
    //
    
    //
    //Public methods
    //
    public void tryGoToSelectedPage()
    {
    	try
    	{
    		//convert a value which has been typed by a user to an Integer
    		Integer selectedPageNumber = Integer.valueOf(this.var_selectedPageNumberInString);
    		//if conversion was successful then we change the current page number
    		this.parameters.currentPageNumber = selectedPageNumber;
    		//generate an event
    		this.generateEvent();
    	}
    	catch (Exception error)
    	{
    		//do nothing if conversion failed
    	}
    }
	    
    public void goToPage()
    {
    	//read page number from URL-parameters
        Integer pageNumber = Integer.valueOf(ApexPages.currentPage().getParameters().get(
        	H_C_RequestParameters.PAGE_NUMBER));
        
        //update the current parameters and generate an event
        this.parameters.currentPageNumber = pageNumber;
        this.generateEvent();
    }
    
    public void goToNextPage()
    {
        if (this.parameters.currentPageNumber < this.parameters.quantityOfPages)
        {
        	//update the current parameters and generate an event 
            this.parameters.currentPageNumber++;
            this.generateEvent();
        }
    }
    
    public void goToPreviousPage()
    {
        if (this.parameters.currentPageNumber > 1)
        {
        	//update the current parameters and generate an event
            this.parameters.currentPageNumber--;
            this.generateEvent();
        }
    }
    
    public void applyNumberOfRecordsPerPage()
    {
    	//numberOfRecordsPerPage is automatically saved into the current parameters,
    	//but, as an additional action, we should reset the current page number to 1
    	this.parameters.currentPageNumber = 1;
    	//generate an event
    	this.generateEvent();
    }
    //
}