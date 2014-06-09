public with sharing class MEP_AttendeeType
{
	public static final String OTHER = 'Other';
	public static final String GUEST = 'Guest';
	public static final String FUND_ANALYST = 'Fund Analyst';
	public static final String ASSET_MANAGEMENT_EXECUTIVE = 'Asset Management Executive';
	//public static final String PM_ASSISTANT = 'PM Assistant';
	public static final String FUND_ACCOUNTING_MANAGER = 'Fund Accounting Manager';
	public static final String HOST = 'Host';
	public static final String PRODUCT_MANAGER = 'Product Manager';
	
	public static final List<Selectoption> ATTENDEES_TYPES = new Selectoption[]
	{
		new SelectOption(OTHER, OTHER),
		new SelectOption(GUEST, GUEST),
		new SelectOption(FUND_ANALYST, FUND_ANALYST),
		new SelectOption(ASSET_MANAGEMENT_EXECUTIVE, ASSET_MANAGEMENT_EXECUTIVE),
		new SelectOption(PRODUCT_MANAGER, PRODUCT_MANAGER),
		//new SelectOption(PM_ASSISTANT, PM_ASSISTANT),
		new SelectOption(FUND_ACCOUNTING_MANAGER, FUND_ACCOUNTING_MANAGER),
		new SelectOption(HOST, HOST)
	};
}