/*
*	Author: SLegostaev
*/
public with sharing class MEP_CreateEventFromTaskController {
    
    private String taskId;
    private Task task;
    public Boolean hasError {get; private set;}
    
    public MEP_CreateEventFromTaskController() {
        taskId = Apexpages.currentPage().getParameters().get('taskId');
        hasError = false;
        if (taskId == null) {
            hasError = true;
            MEP_MessagesManager.addInfoMessage('The parameter taskId is empty!');
        } else {
            task = getTask();
        }
    }
    
    public void createEvent() {
        if (!hasError) {
        	try {
        		MEP_CreateEventFromTask.createEventFromTask(task);
				update task;
				MEP_MessagesManager.addInfoMessage('Congratulation! MEP event has been created!');
        	} catch (MEP_Exception mepEx) {
        		hasError = true;
        		MEP_MessagesManager.addInfoMessage(mepEx.getMessage());
            } catch (System.Dmlexception e) {
            	hasError = true;
            	System.debug(LoggingLevel.ERROR, e);
            }
        }
    }
    
    private Task getTask() {
        try {
            task = [select Id, Subject, Description, Meeting_Time__c, ActivityDate, Meeting_End_Time__c, MEP_Event_Id__c, 
                Discussion_Topics__c, time_zone__c, AccountId, Account.Name, Account.PGA_Account_Type__c, Account.Total_Client_IM_Assets__c, 
                    City__c, Country__c, States__c, Meeting_Location__c, Fidelity_PM_Attendees__c, 
                    	Fidelity_IPM_Attendees__c, Fidelity_Attendees__c From Task where Id = :taskId];
            return task;
        } catch (System.Queryexception e) {
            hasError = true;
            System.debug(LoggingLevel.ERROR, e);
            MEP_MessagesManager.addInfoMessage(e.getMessage());
        }
        return null;
    }
    
}