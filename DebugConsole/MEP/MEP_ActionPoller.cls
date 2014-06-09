public with sharing class MEP_ActionPoller {
        
    public Boolean isProduction {get; set;}
    
    public MEP_ActionPoller() {
        isProduction = MEP_ApplicationMode__c.getInstance().isProduction__c;
    }
}