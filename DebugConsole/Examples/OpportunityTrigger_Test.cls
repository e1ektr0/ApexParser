/**
 *  Name : OpportunityTrigger_Test
 *
 *  Description : This is a test class for OpportunityTrigger trigger. 
 *
 *  @author : Avinash Bari <abari@innoveer.com>
 *
 *  @since   Aug 23, 2012
 */
//@istest(SeeAllData=true)
@istest (SeeAllData=true)
public class OpportunityTrigger_Test{
    static testmethod void testOpportunityTriggermethod(){
		//Inserting the Opportunity Stage 	
        list<Opportunity_Stage__c> opstage = new list<Opportunity_Stage__c>();
        Opportunity_Stage__c opstage1 = new Opportunity_Stage__c(Name='Targeting', Stage_Number__c=2);
        Opportunity_Stage__c opstage2 = new Opportunity_Stage__c(Name='Qualification', Stage_Number__c=3);
        Opportunity_Stage__c opstage3 = new Opportunity_Stage__c(Name='Baseline', Stage_Number__c=4);
        Opportunity_Stage__c opstage4 = new Opportunity_Stage__c(Name='Precontract', Stage_Number__c=5);
        Opportunity_Stage__c opstage5 = new Opportunity_Stage__c(Name='Contract', Stage_Number__c=6);
        opstage.add(opstage1);
        opstage.add(opstage2);
        opstage.add(opstage3);
        opstage.add(opstage4);
        opstage.add(opstage5);
        insert opstage;
        
        
        //Getting the Record Type of Accounts Dynamically
        Schema.DescribeSObjectResult dacc = Schema.SObjectType.Account;
        Map<String,Schema.RecordTypeInfo> accrtMapByName = dacc.getRecordTypeInfosByName();
        Map<Id, Opportunity> omap = new Map<Id, Opportunity>();
        Map<Id, Opportunity> nmap = new Map<Id, Opportunity>();
        //Inserting the Account Record
        Account acc = new Account(Name='Test Account',Customer_No__c='12345',Review_Stage__c='Created In Oracle',RecordTypeID = accrtMapByName.get('Prospect Account').getRecordTypeId(), Division__c='Donar',BillingCountry='US');
        
        insert acc;
                
        Stage_Objective__c stageobj = new Stage_Objective__c(Name='Baseline', order__c=22,Opportunity_stage__c=opstage[1].id, Advancement_Criteria__c=true);
        insert stageobj;
        
        Stage_Objective__c s = [select id,Opportunity_stage__r.Name,Advancement_Criteria__c, name from Stage_Objective__c where id =: stageobj.id];
        system.debug('***ssssss**'+s.Opportunity_stage__r.Name);
        
        Objective_Action__c objact= new Objective_Action__c(Name='Test Action', Stage_Objective__c=s.id, order__c=225);
        insert objact;
        system.debug('TTTTTTTTTT'+objact.Stage_Name__c);
        
        //Inserting the Opportunity Record
        Opportunity opp = new Opportunity(Name='Test Opportunity Record', Stagename='Qualification',Business_Type__c='New Business', Closedate=system.today(),Accountid=acc.id);
        
        insert opp;
                        
        Opportunity opp1 = [select id, ownerid from opportunity where id =: opp.id];
        omap.put(opp1.id,opp1);
        
        
        Task tsk =[select id,whatid, status from task where whatid =: opp1.id ];
        tsk.status='Completed'; 
        update tsk;
        
        

        opp.Name='Test record';
        opp.stagename='Baseline';
        update opp;

        delete opp;
        
        
        system.assertEquals(opp.stagename, 'Baseline');
        system.assertEquals(acc.RecordTypeID, accrtMapByName.get('Prospect Account').getRecordTypeId());
        
        }
        
        static testmethod void testOpportunityTriggermethod1(){
		//Inserting the Opportunity Stage 	
        list<Opportunity_Stage__c> opstage = new list<Opportunity_Stage__c>();
        Opportunity_Stage__c opstage1 = new Opportunity_Stage__c(Name='Targeting', Stage_Number__c=2);
        Opportunity_Stage__c opstage2 = new Opportunity_Stage__c(Name='Qualification', Stage_Number__c=7);
        Opportunity_Stage__c opstage3 = new Opportunity_Stage__c(Name='Baseline', Stage_Number__c=4);
        Opportunity_Stage__c opstage4 = new Opportunity_Stage__c(Name='Precontract', Stage_Number__c=5);
        Opportunity_Stage__c opstage5 = new Opportunity_Stage__c(Name='Contract', Stage_Number__c=6);
        opstage.add(opstage1);
        opstage.add(opstage2);
        opstage.add(opstage3);
        opstage.add(opstage4);
        opstage.add(opstage5);
        insert opstage;
        
        
        //Getting the Record Type of Accounts Dynamically
        Schema.DescribeSObjectResult dacc = Schema.SObjectType.Account;
        Map<String,Schema.RecordTypeInfo> accrtMapByName = dacc.getRecordTypeInfosByName();
        Map<Id, Opportunity> omap = new Map<Id, Opportunity>();
        Map<Id, Opportunity> nmap = new Map<Id, Opportunity>();
        //Inserting the Account Record
        Account acc = new Account(Name='Test Account',Customer_No__c='12345',Review_Stage__c='Created In Oracle',RecordTypeID = accrtMapByName.get('Prospect Account').getRecordTypeId(), Division__c='Donar',BillingCountry='US');
        
        insert acc;
        
        
        Stage_Objective__c stageobj = new Stage_Objective__c(Name='Baseline', order__c=22,Opportunity_stage__c=opstage[1].id, Advancement_Criteria__c=false);
        insert stageobj;
        
        Stage_Objective__c s = [select id,Opportunity_stage__r.Name,Advancement_Criteria__c, name from Stage_Objective__c where id =: stageobj.id];
        system.debug('***ssssss**'+s.Opportunity_stage__r.Name);
        
 
        Objective_Action__c objact= new Objective_Action__c(Name='Test Action', Stage_Objective__c=s.id, order__c=225);
        insert objact;
        system.debug('TTTTTTTTTT'+objact.Stage_Name__c);
        
         //Inserting the Opportunity Record
        Opportunity opp = new Opportunity(Name='Test Opportunity Record', Stagename='Qualification',Business_Type__c='New Business', Closedate=system.today(),Accountid=acc.id);
        
        insert opp;
        
        Opportunity opp1 = [select id, ownerid from opportunity where id =: opp.id];
        omap.put(opp1.id,opp1);
        
        opp.Name='Test record';
        opp.stagename='Baseline';
        update opp;

        delete opp;
        
        
        system.assertEquals(opp.stagename, 'Baseline');
        system.assertEquals(acc.RecordTypeID, accrtMapByName.get('Prospect Account').getRecordTypeId());
        
        }
              
        }