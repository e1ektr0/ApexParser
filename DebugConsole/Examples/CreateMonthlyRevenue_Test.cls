/**
 *  Name : CreateMonthlyRevenue_Test
 *
 *  Description : This Test Class is used to test coverage for CreateMonthlyRevenueV2(trigger),
 *				  OpportunityLineItemUtilityClassV2(Apex Class)
 *				  MonthlyRevenueBatch(Batch Class)
 *
 *  @author : Avinash Bari <abari@innoveer.com>
 *  
 *  Since : Aug 31, 2012
 *  
 *  Last Modified : Aug 5,2013 by Satarupa Roy <satarupa.roy@cloudsherpas.com>
 *  
 */
@isTest (SeeAllData=true)
private class CreateMonthlyRevenue_Test {

    static testMethod void CreateMonthlyRevenue_method() {
        
        //Getting the Record Type of Accounts Dynamically
        Schema.DescribeSObjectResult dacc = Schema.SObjectType.Account;
        Map<String,Schema.RecordTypeInfo> accrtMapByName = dacc.getRecordTypeInfosByName();
        
        Schema.DescribeSObjectResult dopp = Schema.SObjectType.Opportunity;
        Map<String,Schema.RecordTypeInfo> opprtMapByName = dopp.getRecordTypeInfosByName();
        String PIPELINERECORDTYPEID= opprtMapByName.get('Pipeline').getRecordTypeId();
        String EXISTINGRECORDTYPEID= opprtMapByName.get('Existing').getRecordTypeId();
            
        Date closeDateOpp = date.newInstance(2012, 4, 17);
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        //Create User to set owner for Opportunity.
        User u = new User(Alias = 'stdu', Email = 'standarduser@testuser.com', EmailEncodingKey = 'UTF-8', LastName = 
                            'Test', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = sysAdminProfile.Id, TimeZoneSidKey =
                            'America/Los_Angeles', UserName = 'stndusr@test.com', Business_Unit__c='320 - Patient',Management_Unit__c='2040 - Italy', Operating_Unit__c ='Haemonetics Italia S.r.l. IT OU' );
        insert u;
     
        
        //Get the standart Pricebook.
        Pricebook2 objpb =[Select Name, IsStandard From Pricebook2 where IsStandard =true Limit 1];
        
        //Insert Disposable Products in the Pricebook.
        list<Product2> prdDisp = new list<Product2>();
        for(integer i =0; i < 200 ; i++){
            Product2 objprod = new Product2 (name='test product',Family='CA', Product_Type__c='Disposable');
            prdDisp.add(objprod);
        }
        insert prdDisp;
        
        //insert Price book entries for dispossable products.
        list<PricebookEntry> PBElistDisp = new list<PricebookEntry>();
        for(integer i=0; i<prdDisp.size() ; i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = objpb.Id, Product2Id = prdDisp[i].Id, UnitPrice = 10000, IsActive = true,UseStandardPrice = false);
            PBElistDisp.add(pbe);
        }
        insert PBElistDisp;

        
        //Insert Equipment Products in the Pricebook.
        list<Product2> prdEquip = new list<product2>();
        for(integer i =0; i < 200 ; i++){
            product2 objprod = new product2 (name='test product', Family='CA', Product_Type__c='Equipment');       
            prdEquip.add(objprod);
        }
        insert prdEquip;
        
        //insert Price book entries for Equipment products.
        list<PricebookEntry> PBElistEquip = new list<PricebookEntry>();
        for(integer i=0; i<prdEquip.size() ; i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = objpb.Id, Product2Id = prdEquip[i].Id, UnitPrice = 10000, IsActive = true,UseStandardPrice = false);
            PBElistEquip.add(pbe);
        }
        insert PBElistEquip ;
       
        //Insert Account Record
        Account acc = new Account(Name='Test Account',RecordTypeID = accrtMapByName.get('Prospect Account').getRecordTypeId(), Division__c='Donar',BillingCountry='US');
        insert acc;
        
        //SETUP AOPS
        list<Aop__c> aops = new list<Aop__c>();
        AOP__c ap0= new AOP__c(Sales_Rep__c=u.id, Product_Line__c='CA', Product_Type__c='Disposable', 
                              Business_Unit__c='320 - Patient',   Management_Unit__c='2040 - Italy', 
                              Operating_Unit__c ='Haemonetics Italia S.r.l. IT OU', Fiscal_Year__c = 2013, Fiscal_Month__c = 'Apr'
                              );
        aops.add(ap0);  
          
        AOP__c ap1= new AOP__c(Sales_Rep__c=u.id, Product_Line__c='CA', Product_Type__c='Disposable', 
                              Business_Unit__c='320 - Patient',   Management_Unit__c='2040 - Italy', 
                              Operating_Unit__c ='Haemonetics Italia S.r.l. IT OU', Fiscal_Year__c = 2013, Fiscal_Month__c = 'May'
                              );
        aops.add(ap1);   
        AOP__c ap2= new AOP__c(Sales_Rep__c=u.id, Product_Line__c='CA', Product_Type__c='Disposable', 
                              Business_Unit__c='320 - Patient',   Management_Unit__c='2040 - Italy', 
                              Operating_Unit__c ='Haemonetics Italia S.r.l. IT OU', Fiscal_Year__c = 2013, Fiscal_Month__c = 'Jun'
                              );
        aops.add(ap2); 
        AOP__c ap3= new AOP__c(Sales_Rep__c=u.id, Product_Line__c='CA', Product_Type__c='Disposable', 
                              Business_Unit__c='320 - Patient',   Management_Unit__c='2040 - Italy', 
                              Operating_Unit__c ='Haemonetics Italia S.r.l. IT OU', Fiscal_Year__c = 2013, Fiscal_Month__c = 'Jul'
                              );
        aops.add(ap3); 
        AOP__c ap4= new AOP__c(Sales_Rep__c=u.id, Product_Line__c='CA', Product_Type__c='Disposable', 
                              Business_Unit__c='320 - Patient',   Management_Unit__c='2040 - Italy', 
                              Operating_Unit__c ='Haemonetics Italia S.r.l. IT OU', Fiscal_Year__c = 2013, Fiscal_Month__c = 'Aug'
                              );
        aops.add(ap4); 
        AOP__c ap5= new AOP__c(Sales_Rep__c=u.id, Product_Line__c='CA', Product_Type__c='Disposable', 
                              Business_Unit__c='320 - Patient',   Management_Unit__c='2040 - Italy', 
                              Operating_Unit__c ='Haemonetics Italia S.r.l. IT OU', Fiscal_Year__c = 2013, Fiscal_Month__c = 'Sep'
                              );
        aops.add(ap5); 
        AOP__c ap6= new AOP__c(Sales_Rep__c=u.id, Product_Line__c='CA', Product_Type__c='Disposable', 
                              Business_Unit__c='320 - Patient',   Management_Unit__c='2040 - Italy', 
                              Operating_Unit__c ='Haemonetics Italia S.r.l. IT OU', Fiscal_Year__c = 2013, Fiscal_Month__c = 'Oct'
                              );
        aops.add(ap6); 
        AOP__c ap7= new AOP__c(Sales_Rep__c=u.id, Product_Line__c='CA', Product_Type__c='Disposable', 
                              Business_Unit__c='320 - Patient',   Management_Unit__c='2040 - Italy', 
                              Operating_Unit__c ='Haemonetics Italia S.r.l. IT OU', Fiscal_Year__c = 2013, Fiscal_Month__c = 'Nov'
                              );
        aops.add(ap7); 
        AOP__c ap8= new AOP__c(Sales_Rep__c=u.id, Product_Line__c='CA', Product_Type__c='Disposable', 
                              Business_Unit__c='320 - Patient',   Management_Unit__c='2040 - Italy', 
                              Operating_Unit__c ='Haemonetics Italia S.r.l. IT OU', Fiscal_Year__c = 2013, Fiscal_Month__c = 'Dec'
                              );
        aops.add(ap8); 
        AOP__c ap9= new AOP__c(Sales_Rep__c=u.id, Product_Line__c='CA', Product_Type__c='Disposable', 
                              Business_Unit__c='320 - Patient',   Management_Unit__c='2040 - Italy', 
                              Operating_Unit__c ='Haemonetics Italia S.r.l. IT OU', Fiscal_Year__c = 2013, Fiscal_Month__c = 'Jan'
                              );
        aops.add(ap9); 
        AOP__c ap10= new AOP__c(Sales_Rep__c=u.id, Product_Line__c='CA', Product_Type__c='Disposable', 
                              Business_Unit__c='320 - Patient',   Management_Unit__c='2040 - Italy', 
                              Operating_Unit__c ='Haemonetics Italia S.r.l. IT OU', Fiscal_Year__c = 2013, Fiscal_Month__c = 'Feb'
                              );
        aops.add(ap10); 
        AOP__c ap11= new AOP__c(Sales_Rep__c=u.id, Product_Line__c='CA', Product_Type__c='Disposable', 
                              Business_Unit__c='320 - Patient',   Management_Unit__c='2040 - Italy', 
                              Operating_Unit__c ='Haemonetics Italia S.r.l. IT OU', Fiscal_Year__c = 2013, Fiscal_Month__c = 'Mar'
                              );
        aops.add(ap11);                 
        insert aops ;
        
        list<Aop__c> AopEqiup = new list<Aop__c>();
        AOP__c AopEqp1= new AOP__c(Sales_Rep__c=u.id, Product_Line__c='CA', Product_Type__c='Equipment', 
                            Business_Unit__c='320 - Patient', Management_Unit__c='2040 - Italy', 
                              Operating_Unit__c ='Haemonetics Italia S.r.l. IT OU', Fiscal_Year__c = 2013, Fiscal_Month__c = 'Apr' );
        AopEqiup.add(AopEqp1);
       
        AOP__c AopEqp2= new AOP__c(Sales_Rep__c=u.id, Product_Line__c='CA', Product_Type__c='Equipment', 
                              Business_Unit__c='321 - Patient', Management_Unit__c='2041 - Italy', 
                              Operating_Unit__c ='Haemonetics Italia S.r.l. IT OU', Fiscal_Year__c = 2013, Fiscal_Month__c = 'Apr' );
        
        AopEqiup.add(AopEqp2);
        
        insert AopEqiup;
        
        Opportunity oppFail = new Opportunity(Name='Test Opportunity Record',ownerid=u.id, Stagename='Baseline',Recordtypeid = PIPELINERECORDTYPEID,
                                          Business_Type__c='New Business', Closedate=date.today() , pricebook2id=objpb.id, Business_Unit__c='320 - Patient',
                                          Management_Unit__c='2040 - Italy', Operating_Unit__c ='Haemonetics Italia S.r.l. IT OU',Duration_months__c=11);
        insert oppFail;
        
        
        Opportunity opp = new Opportunity(Name='Test Opportunity Record',ownerid=u.id, Stagename='Baseline',Recordtypeid = PIPELINERECORDTYPEID,
                                          Business_Type__c='New Business', Closedate=closeDateOpp , pricebook2id=objpb.id, Business_Unit__c='320 - Patient',
                                          Management_Unit__c='2040 - Italy', Operating_Unit__c ='Haemonetics Italia S.r.l. IT OU',Duration_months__c=11);
        insert opp;
        
        Opportunity opp1 = new Opportunity(Name='Test Opportunity Record',ownerid=u.id, Stagename='Baseline',Recordtypeid = EXISTINGRECORDTYPEID,
                                          Business_Type__c='New Business', Closedate=closeDateOpp , pricebook2id=objpb.id, Business_Unit__c='320 - Patient',Management_Unit__c='2040 - Italy', Operating_Unit__c ='Haemonetics Italia S.r.l. IT OU',Duration_months__c=11);
        
        insert opp1;
        
        Test.startTest();
        
             
        //Inserting the Opportunity Record
        
        
        OpportunityLineItem oliFail = new OpportunityLineItem (Quantity=5,Opportunityid=oppFail.id,UnitPrice=65,Product_Type__c='Disposable',
        												   pricebookentryid=PBElistDisp[0].id);
        insert oliFail;
        
        list<OpportunityLineItem> oliForFailList = [SELECT Id,Opportunity.CurrencyIsoCode,Quantity,Create_Monthy_Revenue_Flag__c,Product_Type_Formula__c,Product_Code_Formula__c, Product_Line_Formula__c,TotalPrice,OpportunityId,Product_Type__c,Product_Line__c,Opportunity.closedate,Opportunity.Duration_months__c, Opportunity.Owner.Id,Opportunity.Management_Unit__c ,Opportunity.Business_Unit__c,Opportunity.Operating_Unit__c,Opportunity.RecordTypeId,Start_Date__c,End_Date__c
                                   FROM OpportunityLineItem  
                                   WHERE Create_Monthy_Revenue_Flag__c = false AND Id =:oliFail.id];
                                  
        OpportunityLineItemUtilityClassV2.init(oliForFailList);
        
        //PIPELINE AND DISPOSABLE PRODUCT
        
        
        
        OpportunityLineItem oli = new OpportunityLineItem (Quantity=5,Opportunityid=opp.id,UnitPrice=65,Product_Type__c='Disposable',
        												   pricebookentryid=PBElistDisp[0].id);
        insert oli;
        
        list<OpportunityLineItem> oliForClass = [SELECT Id,Opportunity.CurrencyIsoCode,Quantity,Create_Monthy_Revenue_Flag__c,Product_Type_Formula__c,Product_Code_Formula__c, Product_Line_Formula__c,TotalPrice,OpportunityId,Product_Type__c,Product_Line__c,Opportunity.closedate,Opportunity.Duration_months__c, Opportunity.Owner.Id,Opportunity.Management_Unit__c ,Opportunity.Business_Unit__c,Opportunity.Operating_Unit__c,Opportunity.RecordTypeId,Start_Date__c,End_Date__c
                                   FROM OpportunityLineItem  
                                   WHERE Create_Monthy_Revenue_Flag__c = false AND Id =:oli.id];
        
                                  
        OpportunityLineItemUtilityClassV2.init(oliForClass);
        
        //PIPELINE AND EQUIPMENT PRODUCT
        OpportunityLineItem olipipEquip = new OpportunityLineItem (Quantity=5,Opportunityid=opp.id,UnitPrice=65,Product_Type__c='Equipment',
        														   pricebookentryid=PBElistEquip[0].id);
        insert olipipEquip;
        
        list<OpportunityLineItem> oliForClasspipEquip = [SELECT Id,Opportunity.CurrencyIsoCode,Quantity,Create_Monthy_Revenue_Flag__c,Product_Type_Formula__c,Product_Code_Formula__c, Product_Line_Formula__c,TotalPrice,OpportunityId,Product_Type__c,Product_Line__c,Opportunity.closedate,Opportunity.Duration_months__c, Opportunity.Owner.Id,Opportunity.Management_Unit__c ,Opportunity.Business_Unit__c,Opportunity.Operating_Unit__c,Opportunity.RecordTypeId,Start_Date__c,End_Date__c
                                   FROM OpportunityLineItem  
                                   WHERE Create_Monthy_Revenue_Flag__c = false AND Id =:olipipEquip.id];
                                 
        OpportunityLineItemUtilityClassV2.init(oliForClasspipEquip );

        //Existing  AND DISPOSABLE PRODUCT
        
        
        OpportunityLineItem oliExistDisp = new OpportunityLineItem (Quantity=5,Opportunityid=opp1.id,UnitPrice=65,Product_Type__c='Disposable',pricebookentryid=PBElistDisp[0].id,Start_Date__c=date.newinstance(2012, 4, 17) , End_Date__c = date.newinstance(2012, 12, 25));
        insert oliExistDisp;
        
        OpportunityLineItem oliExistDisp1 = new OpportunityLineItem (Quantity=5,Opportunityid=opp1.id,UnitPrice=65,Product_Type__c='Disposable',pricebookentryid=PBElistDisp[0].id,Start_Date__c=date.newinstance(2012, 4, 17) , End_Date__c = date.newinstance(2012, 12, 25));
        insert oliExistDisp1;
        
        
        list<OpportunityLineItem> oliForClassExistDisp = [SELECT Id,Quantity,Opportunity.CurrencyIsoCode,Create_Monthy_Revenue_Flag__c,Product_Type_Formula__c,Product_Code_Formula__c, Product_Line_Formula__c,TotalPrice,OpportunityId,Product_Type__c,Product_Line__c,Opportunity.closedate,Opportunity.Duration_months__c, Opportunity.Owner.Id,Opportunity.Management_Unit__c ,Opportunity.Business_Unit__c,Opportunity.Operating_Unit__c,Opportunity.RecordTypeId,Start_Date__c,End_Date__c
                                   FROM OpportunityLineItem  
                                   WHERE Create_Monthy_Revenue_Flag__c = false AND Id =:oliExistDisp.id];
                                   
        
        OpportunityLineItemUtilityClassV2.init(oliForClassExistDisp );
       
        //Existing  AND EQUIPMENT PRODUCT
        OpportunityLineItem oliExistEquip = new OpportunityLineItem (Quantity=5,Opportunityid=opp1.id,UnitPrice=65,Product_Type__c='Equipment',pricebookentryid=PBElistEquip[0].id,Start_Date__c=date.newinstance(2012, 4, 17) , End_Date__c = date.newinstance(2012, 12, 25));
        insert oliExistEquip ;
        
        list<OpportunityLineItem> oliForClassExistEquip = [SELECT Id,Quantity,Opportunity.CurrencyIsoCode,Create_Monthy_Revenue_Flag__c,Product_Type_Formula__c,Product_Code_Formula__c, Product_Line_Formula__c,TotalPrice,OpportunityId,Product_Type__c,Product_Line__c,Opportunity.closedate,Opportunity.Duration_months__c, Opportunity.Owner.Id,Opportunity.Management_Unit__c ,Opportunity.Business_Unit__c,Opportunity.Operating_Unit__c,Opportunity.RecordTypeId,Start_Date__c,End_Date__c
                                   FROM OpportunityLineItem  
                                   WHERE Create_Monthy_Revenue_Flag__c = TRUE AND Id =:oliExistEquip.id];
         
                                 
        OpportunityLineItemUtilityClassV2.init(oliForClassExistEquip);
        
         //Added by Satarupa Roy on 3rd Aug 2013
         List<OpportunityLineItem> listToUpdate = new List<OpportunityLineItem>();
         oliExistDisp.UnitPrice=0;         
         listToUpdate.add(oliExistDisp);
         olipipEquip.UnitPrice = 50;
         listToUpdate.add(olipipEquip);
         oli.UnitPrice = 40;
         listToUpdate.add(oli);
         oliExistEquip.Quantity = 10;         
         listToUpdate.add(oliExistEquip);
         oliFail.UnitPrice = 10;
         listToUpdate.add(oliFail);
         //update oliExistDisp;   
         update listToUpdate;
         
         MonthlyRevenueBatch callBatch = new MonthlyRevenueBatch();
         //ID batchprocessid = Database.executeBatch(callBatch, 1);
        
        delete oliForClassExistEquip;
        oliForClassExistDisp.add(oliExistDisp1);
        delete oliForClassExistDisp;
        Test.stopTest();
     
    }
}