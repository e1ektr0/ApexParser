//
//This class is used as a controller for 'H_C_SearchAccounts' page
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (13-05-2013)
public with sharing class H_C_SearchAccountsController
{
	//
	//Constructors
	//
	public H_C_SearchAccountsController()
	{
		this.initialize();
	}
	//
	
	//
	//Variables
	//
	private static final String SEARCH_RESULTS_PATH = '/_ui/search/ui/UnifiedSearchResults';
	private static final String ACCOUNT_OBJECT_ID = '001';
	private static final String KEY_ACCOUNT_RECORD_TYPE = 'ACCOUNT.RECORDTYPEAccount';
	private static final String KEY_ACCOUNT_NAME = 'ACCOUNT.NAMEAccount';
	private static final String KEY_ACCOUNT_SHIPPING_CITY = 'ACCOUNT.ADDRESS2_CITYAccount';
	
	private static final Set<String> ACCOUNT_RECORD_TYPES_WITHOUT_SHIPPING = new Set<String>
	{
		H_C_AccountRecordType.CONTRACT_ACCOUNT,
		H_C_AccountRecordType.KEY_REGION_ACCOUNT
	};
	//
	
	//
	//Public properties
	//
	public List<SelectOption> accountRecordTypes {get; private set;}
	public String serializedARTNsWithoutShipping
	{
		get
		{
			return Json.serialize(ACCOUNT_RECORD_TYPES_WITHOUT_SHIPPING);
		}
	}
	
	public String selectedAccountRecordType {get; set;}
	public String accountName {get; set;}
	public String shippingCity {get; set;}
	//
	
	//
	//Private methods
	//
	private void initialize()
	{
		//1) initialize the list of options for account record types
		this.accountRecordTypes = new List<SelectOption>();
		this.accountRecordTypes.add(new SelectOption('', '--None--'));
		for (String accountRecordType : H_C_AccountRecordType.ALL_KNOWN_RECORD_TYPES)
		{
			this.accountRecordTypes.add(new SelectOption(accountRecordType, accountRecordType));
		}
		
		//2) set key account as an option which is selected by default
		this.selectedAccountRecordType = H_C_AccountRecordType.KEY_REGION_ACCOUNT;
	}
	
	private String createSearchPattern()
	{
		return (this.accountName != null ? this.accountName + '*' : 'account*');
	}
	
	private String combineStrings(String destinationString, String newPart, String separator)
	{
		return (String.isBlank(destinationString) ? newPart : destinationString + separator + newPart);
	}
	//
	
	//
	//Public methods
	//
	public PageReference searchAccounts()
    {
    	String searchPageUrl = Url.getSalesforceBaseUrl().toExternalForm() + SEARCH_RESULTS_PATH;
    	
    	//construct reference to SF standard search page
        PageReference page = new PageReference(searchPageUrl);
        page.setRedirect(true);
        Map<String, String> pageParameters = page.getParameters();
        pageParameters.put('fen', ACCOUNT_OBJECT_ID);
        pageParameters.put('str', createSearchPattern());
        
        String selectedFilterFields = '';
        //add parameter for account record type
        if (String.isNotBlank(this.selectedAccountRecordType))
        {
        	pageParameters.put(KEY_ACCOUNT_RECORD_TYPE, this.selectedAccountRecordType);
        	selectedFilterFields += KEY_ACCOUNT_RECORD_TYPE;
        }
        
        //add parameter for account name
        if (String.isNotBlank(this.accountName))
        {
        	pageParameters.put('ACCOUNT.NAMEAccount', this.accountName);
        	selectedFilterFields = combineStrings(selectedFilterFields, KEY_ACCOUNT_NAME, ',');
        }
        
        //add parameter for account shipping city
        if (String.isNotBlank(this.shippingCity)
        	&& !ACCOUNT_RECORD_TYPES_WITHOUT_SHIPPING.contains(this.selectedAccountRecordType))
        {
        	pageParameters.put(KEY_ACCOUNT_SHIPPING_CITY, this.shippingCity);
        	selectedFilterFields = combineStrings(selectedFilterFields, KEY_ACCOUNT_SHIPPING_CITY, ',');
        }
        
        //add parameter for selected filter fields
        if (String.isNotBlank(selectedFilterFields))
        {
        	pageParameters.put('sFltrFields', selectedFilterFields);
        }
        pageParameters.put('initialViewMode', 'detail');
        
        //return the result reference
        return page;
    }
	//
}