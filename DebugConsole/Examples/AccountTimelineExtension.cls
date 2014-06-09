public with sharing class AccountTimelineExtension {
    
    private List<TimeLineEvent> mTimeLineEvents;  
    public List<TimeLineEvent> timeLineEvents{
        get {
            if (mTimeLineEvents == null) {
                mTimeLineEvents = new List<TimeLineEvent>();
                for (event e : [select id,  startDateTime, endDateTime, description, subject from event where whatid=:a.id]) {          
                    mTimeLineEvents.add(new TimeLineEvent(e));       
                }
                for (Opportunity o : [select id, RecordType.name, name, createddate, description, closedate from opportunity where accountid=:a.id]) {
                    mTimeLineEvents.add(new TimeLineEvent(o));                    
                }
            }
            return mTimeLineEvents;
        }
    }
    
    Account a;
    public AccountTimelineExtension(ApexPages.StandardController controller) {
       a = (account) controller.getRecord();
    }
    
    
    
    /**
 	*  Description : This is a test class for AccountTimelineExtension Controller. 
 	*
 	*  @author : Avinash Bari <abari@innoveer.com>
 	*
 	*  @since   Aug 23, 2012
 	
    static testMethod void testAccountTimelineExtension() {
    	
    	//Getting the Record Type of Accounts Dynamically
    	Schema.DescribeSObjectResult dacc = Schema.SObjectType.Account;
        Map<String,Schema.RecordTypeInfo> accrtMapByName = dacc.getRecordTypeInfosByName();
        
        //Inserting the Account Record
    	Account acc = new Account(Name='Test Account',RecordTypeID = accrtMapByName.get('Prospect Account').getRecordTypeId(), Division__c='Donar',BillingCountry='US');
    	
    	insert acc;
    	
    	//Inserting the Event Record
    	Event eve = new Event(StartDateTime = Datetime.now(), EndDateTime = Datetime.now().addDays(5), Subject='Demo',WhatId=acc.Id);
    	
    	insert eve;
    	
    	//Inserting the Opportunity Record
    	Opportunity opp = new Opportunity(Name='Test Opportunity Record', Stagename='Targeting',Business_Type__c='New Business', Closedate=system.today(), accountid=acc.Id);
    	
    	insert opp;
    	
    	Event eve1=[select id, whatid from Event where id=:eve.id];
        Opportunity opp1=[select id, accountid from Opportunity where id=:opp.id];
    	
    	//Initializing the Constructor				
		AccountTimelineExtension accext = new AccountTimelineExtension(new ApexPages.Standardcontroller(acc));
		system.debug(accext.timeLineEvents);
		
		system.assertEquals(opp1.accountid, eve1.WhatId);  
		system.assertEquals(acc.RecordTypeID, accrtMapByName.get('Prospect Account').getRecordTypeId());
					
    }
	*/
}