public with sharing class AccountPlanTimelineExtension {
    
    private List<TimeLineEvent> mTimeLineEvents;  
    public List<TimeLineEvent> timeLineEvents{
        get {
            if (mTimeLineEvents == null) {
                mTimeLineEvents = new List<TimeLineEvent>();
                for (event e : [select id,whatid,  startDateTime, endDateTime, description, subject from event where whatid=:ap.id]) {          
                    mTimeLineEvents.add(new TimeLineEvent(e));       
                }
                for (Opportunity o : [select id, RecordType.name, name,Account_Plan__c, createddate, description, closedate from opportunity where Account_Plan__c=:ap.id]) {
                   // if (o.id=='006Q00000077u1eIAA') {
                    mTimeLineEvents.add(new TimeLineEvent(o));
                 //   }
                    
                }
            }
            return mTimeLineEvents;
        }
    }
    
    Account_Plan__c ap;
    public AccountPlanTimelineExtension (ApexPages.StandardController controller) {
       ap = (Account_Plan__c) controller.getRecord();
    }
    
    
    /**
 	*  Description : This is a test class for AccountPlanTimelineExtension Controller. 
 	*
 	*  @author : Avinash Bari <abari@innoveer.com>
 	*
 	*  @since   Aug 23, 2012
 	
    static testMethod void testAccountPlanTimelineExtension() {
        
        //Getting the Record Type of Accounts Dynamically
        Schema.DescribeSObjectResult dacc = Schema.SObjectType.Account;
        Map<String,Schema.RecordTypeInfo> accrtMapByName = dacc.getRecordTypeInfosByName();
        
        //Inserting the Account Record
        Account acc = new Account(Name='Test Account',RecordTypeID = accrtMapByName.get('Prospect Account').getRecordTypeId(), Division__c='Donar',BillingCountry='US');
        
        insert acc;
        
        //Inserting the Account Plan Record
        Account_Plan__c accplan =new Account_Plan__c(Name='Test Account plan Record',Account__c=acc.id,Status__c='Active' );
        
        insert accplan;
        
        //Inserting the Event Record
        Event eve = new Event(StartDateTime = system.now(), EndDateTime = Datetime.now().addDays(5), Subject='Demo', WhatId=accplan.Id);
        
        insert eve;
        
        //Inserting the Opportunity Record
        Opportunity opp = new Opportunity(Name='Test Opportunity Record', Stagename='Targeting',Business_Type__c='New Business', Closedate=system.today(),Account_Plan__c=accplan.Id);
        
        insert opp;
        
        
        Account_Plan__c accplan1=[select id, account__c from Account_Plan__c where id=:accplan.id];
        Opportunity opp1=[select id, Account_Plan__c from Opportunity where id=:opp.id];
        
        //Initializing the Constructor  
        AccountPlanTimelineExtension accext = new AccountPlanTimelineExtension(new ApexPages.Standardcontroller(accplan));
        accext.mTimeLineEvents=Null;
        system.debug(accext.timeLineEvents);
        
        system.assertEquals(opp1.Account_Plan__c, accplan1.id);
        system.assertEquals(acc.RecordTypeID, accrtMapByName.get('Prospect Account').getRecordTypeId());
                
    }
	*/
}