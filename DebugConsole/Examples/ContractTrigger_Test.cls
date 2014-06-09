@isTest(seealldata = true)
private class ContractTrigger_Test {
    @isTest static void ContractTrigger_Test(){
    
        //Getting the Record Type of Accounts Dynamically
        Schema.DescribeSObjectResult dacc = Schema.SObjectType.Account;
        Map<String,Schema.RecordTypeInfo> accrtMapByName = dacc.getRecordTypeInfosByName();
       
        
        //Inserting the Account Record
        Account acc1 = new Account(Name='Parent Account',RecordTypeID = accrtMapByName.get('Prospect Account').getRecordTypeId(), Division__c='Donar',BillingCountry='US');       
        insert acc1;

        //Inserting the Contract Record
        Contract myContract=new Contract(Contract_Type__c='BP Contract', Status='Draft', CurrencyIsoCode='USD', Annual_Value__c=1000, ContractTerm=10, Accountid=acc1.id );
        insert myContract;
        
        
        //Testing update Contract

      
        //No start date and accepted date
        myContract.StartDate=null;
        myContract.Contract_Accepted_Date__c=null;
        myContract.status='Activated';
        try{    
            update myContract;      
            System.assert(false);
        }catch (Exception err){
            System.assert((err.getTypeName())=='System.DmlException');
        }
       
      
        //No accepted date
        myContract.StartDate=Date.newinstance(2013,12,12);
        myContract.Contract_Accepted_Date__c=null;
        myContract.status='Activated';
        try{    
            update myContract;      
            System.assert(false);
        }catch (Exception err){
            System.assert((err.getTypeName())=='System.DmlException');
        }
      
        //No start date
        myContract.StartDate=null;
        myContract.Contract_Accepted_Date__c=Date.newinstance(2013,12,12);
        myContract.status='Activated';
        try{    
            update myContract;      
            System.assert(false);
        }catch (Exception err){
            System.assert((err.getTypeName())=='System.DmlException');
        }
       
        //With start date and accepted date
        myContract.StartDate=Date.newinstance(2013,12,12);
        myContract.Contract_Accepted_Date__c=Date.newinstance(2013,12,12);
        myContract.status='Activated';
      
        update myContract;                           
    }
}