/**
 *  Name : ActualsReportingBatch_Scheduler_Test
 *
 *  Description : This is a test class for ActualsReportingBatch_Scheduler Batch class. 
 *
 *  @author : Vishal Negandhi <vnegandhi@innoveer.com>
 *
 *  @since   Sept 26, 2012
 *  @Modified :Bhushan Adhikari<bhushan.adhikari@cloudsherpas.com> add test user and  Territory_Rep_2__c  field for test Invoices.
 */
@isTest
private class ActualsReportingBatch_Scheduler_Test {

    static testMethod void myUnitTest() 
    {
       // List<RecordType> prospectRT = [Select Name, Id From RecordType Where SObjectType = 'Account' AND Name = 'Prospect Account'];
       // List<RecordType> transactionalRT = [Select Name, Id From RecordType Where SObjectType = 'Account' AND Name = 'Transactional Account'];
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
       //Adding user with no Sales Org Id
        User usr = new User(Alias = 'stdu', Email = 'standarduser@testuser.com', EmailEncodingKey = 'UTF-8', LastName = 
                            'Test', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = profile.Id, TimeZoneSidKey =
                            'America/Los_Angeles', UserName = 'stndusr@test.com', Business_Unit__c='100 - Donor Division',salesRep_Org_Id__c='10000' );
                   
        insert usr;
       
       EmailAddress__c em= new EmailAddress__c(name = 'abaneka@innoveer.com');
       insert em;
       
        Schema.DescribeSObjectResult dacc = Schema.SObjectType.Account;
        Map<String,Schema.RecordTypeInfo> accrtMapByName = dacc.getRecordTypeInfosByName();
        String prospectRT = accrtMapByName.get('Prospect Account').getRecordTypeId();
        String transactionalRT = accrtMapByName.get('Transactional Account').getRecordTypeId();
        
        Date lastYrDate = Date.newInstance( Date.today().year() - 1, Date.today().month(), 5);
        
        // creating data
        //insert AOP__c
        Aop__c aop = new Aop__c(Business_Unit__c = 'test');
        insert aop;
        
        Account acc = new Account(Name = 'Test 1', BillingCountry = 'US', Sales_This_MTD__c = 0, Sales_This_QTD__c = 0, 
                                   Sales_This_YTD__c = 0, Sales_Last_YTD__c = 0, Sales_Last_QTD__c = 0, Sales_Last_MTD__c = 0);
        if(prospectRT != null)
            acc.RecordTypeId = prospectRT;
        insert acc;
        
        Account acc1 = new Account(Name = 'Test 2', BillingCountry = 'US', Sales_This_MTD__c = 0, Sales_This_QTD__c = 0, 
                                   Sales_This_YTD__c = 0, Sales_Last_YTD__c = 0, Sales_Last_QTD__c = 0, Sales_Last_MTD__c = 0, ParentId = acc.Id);
        if(transactionalRT!= null)
            acc1.RecordTypeId = transactionalRt;
        insert acc1;
        
        Account acc2 = new Account(Name = 'Test 3', BillingCountry = 'US', Sales_This_MTD__c = 0, Sales_This_QTD__c = 0, 
                                   Sales_This_YTD__c = 0, Sales_Last_YTD__c = 0, Sales_Last_QTD__c = 0, Sales_Last_MTD__c = 0, ParentId = acc.Id);
        if(transactionalRT != null)
            acc2.RecordTypeId = transactionalRT ;
        insert acc2;
        
        
        Invoice__c inv1 = new Invoice__c(Aop__c = aop.id ,Ship_To_Site__c = acc1.Id, Customer_Trax_Line_Id__c = 'xxx1', GL_Date__c = date.today(), Bill_To_Customer__c = acc1.Id, Local_Amount__c = 150 , Territory_Rep_2__c = usr.Id);
        insert inv1;
        
        Invoice__c inv2 = new Invoice__c(Aop__c = aop.id ,Ship_To_Site__c = acc1.Id, Customer_Trax_Line_Id__c = 'xxx2', GL_Date__c = date.today(), Bill_To_Customer__c = acc1.Id, Local_Amount__c = 150, Territory_Rep_2__c = usr.Id);
        insert inv2;
        
        Invoice__c inv3 = new Invoice__c(Aop__c = aop.id ,Ship_To_Site__c = acc1.Id, Customer_Trax_Line_Id__c = 'xxx3', GL_Date__c = lastYrDate, Bill_To_Customer__c = acc1.Id, Local_Amount__c = 150 , Territory_Rep_2__c = usr.Id);
        insert inv3;
        
        Invoice__c inv4 = new Invoice__c(Aop__c = aop.id ,Ship_To_Site__c = acc1.Id, Customer_Trax_Line_Id__c = 'xxx4', GL_Date__c = lastYrDate, Bill_To_Customer__c = acc1.Id, Local_Amount__c = 150 , Territory_Rep_2__c = usr.Id);
        insert inv4;
        
        Invoice__c inv5 = new Invoice__c(Aop__c = aop.id ,Ship_To_Site__c = acc2.Id, Customer_Trax_Line_Id__c = 'xxx5', GL_Date__c = date.today(), Bill_To_Customer__c = acc2.Id, Local_Amount__c = 150 , Territory_Rep_2__c = usr.Id);
        insert inv5;
        
        Invoice__c inv6 = new Invoice__c(Aop__c = aop.id ,Ship_To_Site__c = acc2.Id, Customer_Trax_Line_Id__c = 'xxx6', GL_Date__c = date.today(), Bill_To_Customer__c = acc2.Id, Local_Amount__c = 150 , Territory_Rep_2__c = usr.Id);
        insert inv6;
        
        Invoice__c inv7 = new Invoice__c(Aop__c = aop.id ,Ship_To_Site__c = acc2.Id, Customer_Trax_Line_Id__c = 'xxx7', GL_Date__c = lastYrDate, Bill_To_Customer__c = acc2.Id, Local_Amount__c = 150 , Territory_Rep_2__c = usr.Id);
        insert inv7;
        
        //Invoice__c inv8 = new Invoice__c(Aop__c = aop.id ,Ship_To_Site__c = acc2.Id, Customer_Trax_Line_Id__c = 'xxx8', GL_Date__c = lastYrDate, Bill_To_Customer__c = acc2.Id, Local_Amount__c = 150 , Territory_Rep_2__c = usr.Id);
        //insert inv8;
        
        test.startTest();
        String sch = '0 0 0 3 9 ? 2042';
        String jobId = System.schedule('testActualsReportingScheduled',sch, new ActualsReportingBatch_Scheduler());
        test.stopTest();
    }
}