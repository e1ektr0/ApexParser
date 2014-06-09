/**
 *  Name : InvoiceTrigger_Test
 *
 *  Description : This is a test class for InvoiceTrigger trigger. 
 *
 *  @author : Avinash Bari <abari@innoveer.com>
 *
 *  @since   Sept 4, 2012
 */
@isTest(seealldata = true)
private class InvoiceTrigger_Test {
    static testMethod void InvoiceTrigger_method() {
        //Getting the Record Type of Accounts Dynamically
        Schema.DescribeSObjectResult dacc = Schema.SObjectType.Account;
        Map<String,Schema.RecordTypeInfo> accrtMapByName = dacc.getRecordTypeInfosByName();
        List<Account> acclist = new List<Account>();
        List<Account> acclist1 = new List<Account>();
        List<Invoice__c> invlist = new List<Invoice__c>();
        List<User> ulist = new List<User>();
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        for(integer i=0;i<10;i++){
            User u = new User(Alias = 'stdu', Email = 'standarduser@testuser.com', EmailEncodingKey = 'UTF-8', LastName = 
                            'Test', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = p.Id, TimeZoneSidKey =
                            'America/Los_Angeles', UserName = 'stndusr@test.com'+i, Business_Unit__c='100 - Donor Division');
            ulist.add(u);
        }
   
        insert ulist;
        
        //insert AOP__c
        Aop__c aop = new Aop__c(Business_Unit__c = 'test');
        insert aop;
        //Inserting the Account Record
        Account acc1 = new Account(Name='Parent Account',RecordTypeID = accrtMapByName.get('Prospect Account').getRecordTypeId(), Division__c='Donar',BillingCountry='US');
        
        insert acc1;
        
        for(integer i=0;i<10;i++){
            Account acc = new Account(Name='Ship to site'+i,parentid=acc1.id,RecordTypeID = accrtMapByName.get('Prospect Account').getRecordTypeId(), Division__c='Donar',BillingCountry='US');
        
            acclist.add(acc);
        }
    
        insert acclist;
       
         for(integer i=0;i<10;i++){
            Account acc = new Account(Name='Bill to site'+i,parentid=acc1.id,RecordTypeID = accrtMapByName.get('Prospect Account').getRecordTypeId(), Division__c='Donar',BillingCountry='US');
        
            acclist1.add(acc);
        }
    
        insert acclist1;
        
        for(integer i=0;i<10;i++){
            Invoice__c inv = new Invoice__c(Aop__c = aop.id ,Ship_To_Site__c=acclist[i].id, Customer_Trax_Line_ID__c='test11'+i,Bill_To_Customer__c=acclist[i].id, Territory_Rep_1__c=ulist[0].id,Territory_Rep_2__c=ulist[1].id,Territory_Rep_3__c=ulist[2].id,Territory_Rep_4__c=ulist[3].id,Territory_Rep_5__c=ulist[4].id,Territory_Rep_6__c=ulist[5].id,Territory_Rep_7__c=ulist[6].id,Territory_Rep_8__c=ulist[7].id ,Territory_Rep_9__c=ulist[8].id,Territory_Rep_10__c=ulist[9].id);
            invlist.add(inv);
        }
        
        insert invlist;
        
        test.startTest();
        update invlist;
        test.stopTest();
        
        system.assertEquals(invlist[0].Ship_To_Site__c, acclist[0].id);
        system.assertEquals(invlist[0].Bill_To_Customer__c,acclist[0].id);
        system.assertEquals(invlist[0].Territory_Rep_4__c,ulist[3].id);
        
    }
     
     
     /* @TestMethod  : InvoiceTrigger_sortRepTestforAllRep
     *  @Description : This test method is to check Territoty Reps on Invoice record are sorted based upon Sales Org Id and the Owner of that Invoice
     *                 should be the first rep. 
     *  @CreatedDate : 22 March, 2013
     *  @createdBy   : Bhushan Adhikari <bhushan.adhikari@cloudsherpas.com>
     */
     static testmethod void InvoiceTrigger_sortRepTestforAllRep(){
        //Getting the Record Type of Accounts Dynamically
        Schema.DescribeSObjectResult dacc = Schema.SObjectType.Account;
        Map<String,Schema.RecordTypeInfo> accrtMapByName = dacc.getRecordTypeInfosByName();
        List<Account> acclist = new List<Account>();
        List<Invoice__c> invlist = new List<Invoice__c>();
        List<User> ulist = new List<User>();
        
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        //Inserting Users with their sales org Id
        for(integer i=1;i<=10;i++){
            User usr = new User(Alias = 'stdu', Email = 'standarduser@testuser.com', EmailEncodingKey = 'UTF-8', LastName = 
                            'Test', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = profile.Id, TimeZoneSidKey =
                            'America/Los_Angeles', UserName = 'stndusr@test.com'+i, Business_Unit__c='100 - Donor Division',salesRep_Org_Id__c=string.valueOf(i) );
            ulist.add(usr);
        }
        insert ulist;
        
        //Inserting the Parent Account Record
        Account acc1 = new Account(Name='Parent Account',RecordTypeID = accrtMapByName.get('Prospect Account').getRecordTypeId(), Division__c='Donar',BillingCountry='US');
        insert acc1;
        
        //Inserting Test Accounts
        for(integer i=0;i<1;i++){
            Account acc = new Account(Name='Ship to site'+i,parentid=acc1.id,RecordTypeID = accrtMapByName.get('Prospect Account').getRecordTypeId(), Division__c='Donar',BillingCountry='US');
            acclist.add(acc);
        }
        
        // Inserting Invoices that will have All Territory Rep fields populated with Users such that Territory Rep 1 will have user with highest Org
        // id Territory Rep 2 will have second highest an so on.
        for(integer i=0;i<200;i++){
            Invoice__c inv = new Invoice__c(Ship_To_Site__c=acclist[0].id, Customer_Trax_Line_ID__c='test11'+i,
                                            Bill_To_Customer__c=acclist[0].id,
                                            Territory_Rep_1__c = ulist[9].id,
                                            Territory_Rep_2__c = ulist[8].id,
                                            Territory_Rep_3__c = ulist[7].id,
                                            Territory_Rep_4__c = ulist[6].id,
                                            Territory_Rep_5__c = ulist[5].id,
                                            Territory_Rep_6__c = ulist[4].id,
                                            Territory_Rep_7__c = ulist[3].id,
                                            Territory_Rep_8__c = ulist[2].id,
                                            Territory_Rep_9__c = ulist[1].id,
                                            Territory_Rep_10__c = ulist[0].id);
            invlist.add(inv);
        }
        test.startTest();
            insert invlist;
        test.stopTest();
        
        List<Invoice__c> invoices = [SELECT Id, Territory_Rep_1__c,
                                            Territory_Rep_2__c,
                                            Territory_Rep_3__c,
                                            Territory_Rep_4__c,
                                            Territory_Rep_5__c,
                                            Territory_Rep_6__c,
                                            Territory_Rep_7__c,
                                            Territory_Rep_8__c,
                                            Territory_Rep_9__c,
                                            Territory_Rep_10__c, OwnerId FROM Invoice__c WHERE Id IN: invlist];
       
                                         
        //Checking that the Territory Reps are sorted in asscending order of Sales org Id of the User. 
        //Also checking that the Owner of invoice is set to the lowest Rep i.e Territory Rep 1
        for(Invoice__c inv : invoices ){
          system.assertEquals( ulist[0].id,inv.Territory_Rep_1__c);
          system.assertEquals( ulist[1].id,inv.Territory_Rep_2__c);
          system.assertEquals( ulist[2].id,inv.Territory_Rep_3__c);
          system.assertEquals( ulist[3].id,inv.Territory_Rep_4__c);
          system.assertEquals( ulist[4].id,inv.Territory_Rep_5__c);
          system.assertEquals( ulist[5].id,inv.Territory_Rep_6__c);
          system.assertEquals( ulist[6].id,inv.Territory_Rep_7__c);
          system.assertEquals( ulist[7].id,inv.Territory_Rep_8__c);
          system.assertEquals( ulist[8].id,inv.Territory_Rep_9__c);
          system.assertEquals( ulist[9].id,inv.Territory_Rep_10__c);
          system.assertEquals(inv.Territory_Rep_1__c,inv.OwnerId);
        } 
    }
    
    /*  @TestMethod  : InvoiceTrigger_sortRepTestforRepWithNoOrgId
     *  @Description : This test method is to check Territoty Reps on Invoice record are sorted based upon Sales Org Id , if any rep has 
     *                 no sales rep org id the it is defaulted to 99999 and the Owner of that Invoice is the first rep. 
     *  @CreatedDate : 22 March, 2013
     *  @createdBy   : Bhushan Adhikari <bhushan.adhikari@cloudsherpas.com>
     */
     static testmethod void InvoiceTrigger_sortRepTestforRepWithNoOrgId(){
        //Getting the Record Type of Accounts Dynamically
        Schema.DescribeSObjectResult dacc = Schema.SObjectType.Account;
        Map<String,Schema.RecordTypeInfo> accrtMapByName = dacc.getRecordTypeInfosByName();
        List<Account> acclist = new List<Account>();
        List<Invoice__c> invlist = new List<Invoice__c>();
        List<User> ulist = new List<User>();
        
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        //Inserting Users with their sales org Id
        for(integer i=1;i<=5;i++){
            User user = new User(Alias = 'stdu', Email = 'standarduser@testuser.com', EmailEncodingKey = 'UTF-8', LastName = 
                            'Test', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = profile.Id, TimeZoneSidKey =
                            'America/Los_Angeles', UserName = 'stndusr@test.com'+i, Business_Unit__c='100 - Donor Division',salesRep_Org_Id__c=string.valueOf(i) );
            ulist.add(user);
        }
        insert ulist;
        //Adding user with no Sales Org Id
        User usr = new User(Alias = 'stdu', Email = 'standarduser@testuser.com', EmailEncodingKey = 'UTF-8', LastName = 
                            'Test', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = profile.Id, TimeZoneSidKey =
                            'America/Los_Angeles', UserName = 'stndusr@test.com', Business_Unit__c='100 - Donor Division',salesRep_Org_Id__c='' );
                   
        insert usr;
        
        //Inserting the Parent Account Record
        Account acc1 = new Account(Name='Parent Account',RecordTypeID = accrtMapByName.get('Prospect Account').getRecordTypeId(), Division__c='Donar',BillingCountry='US');
        insert acc1;
        
        //Inserting Test Accounts
        for(integer i=0;i<1;i++){
            Account acc = new Account(Name='Ship to site'+i,parentid=acc1.id,RecordTypeID = accrtMapByName.get('Prospect Account').getRecordTypeId(), Division__c='Donar',BillingCountry='US');
            acclist.add(acc);
        }
        
        // Inserting Invoices that will have All Territory Rep fields populated with Users such that Territory Rep 1 will have user with highest Org
        // id Territory Rep 2 will have second highest an so on.
        for(integer i=0;i<200;i++){
            Invoice__c inv = new Invoice__c(Ship_To_Site__c=acclist[0].id, Customer_Trax_Line_ID__c='test11'+i,
                                            Bill_To_Customer__c=acclist[0].id,
                                            Territory_Rep_1__c = usr.id,     //User without Sales Org Id
                                            Territory_Rep_2__c = ulist[4].id,
                                            Territory_Rep_3__c = ulist[3].id,
                                            Territory_Rep_4__c = ulist[2].id,
                                            Territory_Rep_5__c = ulist[1].id,
                                            Territory_Rep_6__c = ulist[0].id,
                                            Territory_Rep_7__c = null,
                                            Territory_Rep_8__c = null,
                                            Territory_Rep_9__c = null,
                                            Territory_Rep_10__c = null);
            invlist.add(inv);
        }
        test.startTest();
            insert invlist;
        test.stopTest();
        
        List<Invoice__c> invoices = [SELECT Id, Territory_Rep_1__c,
                                            Territory_Rep_2__c,
                                            Territory_Rep_3__c,
                                            Territory_Rep_4__c,
                                            Territory_Rep_5__c,
                                            Territory_Rep_6__c,
                                            Territory_Rep_7__c,
                                            Territory_Rep_8__c,
                                            Territory_Rep_9__c,
                                            Territory_Rep_10__c, OwnerId FROM Invoice__c WHERE Id IN: invlist];
       
                                         
        //Checking that the Territory Reps are sorted in asscending order of Sales org Id of the User. 
        //Also checking that the Owner of invoice is set to the lowest Rep i.e Territory Rep 1
        for(Invoice__c inv : invoices ){
          system.assertEquals( ulist[0].id,inv.Territory_Rep_1__c);
          system.assertEquals( ulist[1].id,inv.Territory_Rep_2__c);
          system.assertEquals( ulist[2].id,inv.Territory_Rep_3__c);
          system.assertEquals( ulist[3].id,inv.Territory_Rep_4__c);
          system.assertEquals( ulist[4].id,inv.Territory_Rep_5__c);
          system.assertEquals( usr.id,inv.Territory_Rep_6__c);
          system.assertEquals(inv.Territory_Rep_1__c,inv.OwnerId);
        } 
    }
}