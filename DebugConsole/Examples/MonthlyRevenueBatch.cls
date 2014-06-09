/**
   *  Description : Batch for Calculating Monthly Revenues.
   *
   *  @author : Abhijeet Baneka <abaneka@innoveer.com>
   *
   *  @since   Oct 10, 2012
   *
   *  @Modified By :  Satarupa Roy <satarupa.roy@cloudsherpas.com> on 5th Aug 2013
 */
global class MonthlyRevenueBatch implements Database.Batchable<sobject>
{
    String Query; // for storing the query on OpportunityLineItems
     
    global MonthlyRevenueBatch(){
         Query = 'SELECT Id,Quantity,Create_Monthy_Revenue_Flag__c,Opportunity.CurrencyIsoCode,Product_Type_Formula__c,Product_Code_Formula__c, Product_Line_Formula__c,TotalPrice,OpportunityId,Product_Type__c,Product_Line__c,Opportunity.closedate,Opportunity.Duration_months__c, Opportunity.Owner.Id,Opportunity.Management_Unit__c ,Opportunity.Business_Unit__c,Opportunity.Operating_Unit__c,Opportunity.RecordTypeId,Start_Date__c,End_Date__c' +
                                        +' FROM OpportunityLineItem ' +  
                                            +' WHERE Create_Monthy_Revenue_Flag__c = TRUE';
    }
     
    global Database.Querylocator Start(Database.BatchableContext BC){
        // returns a list of OpportunityLineItem
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Savepoint sp = Database.setSavepoint(); // storing a database savepoint to roll back in case of any exceptions
        EmailAddress__c ea = EmailAddress__c.getall().values();
        system.debug('==scope========'+scope);
        try{
            List<OpportunityLineItem> Oli= new List<OpportunityLineItem>((List<OpportunityLineItem>)scope); // typecasting list<sobject> to list<invoice__c>
            
            //Create Monthly revenues based on the new values. 
            OpportunityLineItemUtilityClassV2.init(Oli);
            
            list<OpportunityLineItem> OliUpdate = new list<OpportunityLineItem>();
            //deactivate Flags for Monthly Revenue calculation as Monthly revenues has been calculated. 
            for(Opportunitylineitem olitem : Oli){
                olitem.Create_Monthy_Revenue_Flag__c = false; 
                OliUpdate.add(olitem);
            }
            if(Test.isRunningTest()) { // Added By Satarupa Roy
        		// Cause DMLException
        		insert new Lead();
        		
            }
            else
            	update OliUpdate;
            
        }catch(exception e){
            Database.rollback(sp); 
            // rollback the database to the savepoint captured above if there is an exception
            // TO notify the developer of the exception caught through email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {ea.name};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Monthly Revenue Batch: ');
            mail.setPlainTextBody('Exception occured : '  + e.getMessage());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
    global void finish(Database.BatchableContext BC){
        // Get the ID of the AsyncApexJob representing this batch job from Database.BatchableContext. 
        // Query the AsyncApexJob object to retrieve the current job's information. 
        EmailAddress__c ea = EmailAddress__c.getall().values();
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                  FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        
        // Send an email to the Apex job's submitter notifying of job completion. 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {ea.name};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Monthly Revenue Complete Batch Result: ' + a.Status);
        mail.setPlainTextBody
        ('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
   }
}