/** 
   A controller for admin page
   Author: Dluzyanov
**/
public with sharing class MEP_AdminController {
        
        ///
    ///methods for check visibility of link
    ///
    private List<MEP_ROLES__c> roles =  MEP_UserRoleDAO.getCurrentUserRoles();
    public Boolean getIsBizadmin()
    {           
        return MEP_RoleUtils.listContainsRole(roles, MEP_RoleKey.BIZADMIN);
    }
    public Boolean getIsSysadmin()
    {
         return MEP_RoleUtils.listContainsRole(roles, MEP_RoleKey.SYSADMIN);
    }
    public Boolean getIsManager()
    {
         return MEP_RoleUtils.listContainsRole(roles, MEP_RoleKey.MANAGER);  
    }    
    public Boolean getIsGateKeeper()
    {
        return MEP_RoleUtils.listContainsRole(roles, MEP_RoleKey.GATEKEEPER);  
    }
    
    public Boolean canViewQuarterlyMeeting {
    	get {
    		return MEP_MepUserDAO.canViewQuarterlyMeetingsForCurrentUser();
    	}
    }
    ///

    
    public String messageText { get; set; }
	
   	public void startEventsArchiveJob() {
		if (isArchiveRunnig() || isBatchJobRunning('MEP_EventArchiveBatch')) {
        	messageText = 'Job is already running. Please wait for some time to complete.';
        	return;
        } else {
        	Database.executeBatch(new MEP_EventArchiveBatch(), 1);
        	messageText = 'Job is queued as a background. It will take some time to complete.';
        }
        /* this job included Nightly Job
	    try {
            System.schedule('MEP_eventsSchedulerNightly', '0 0 12 * * ?', new MEP_EventArchiveBatchSchedule());
        } catch (System.AsyncException log) {
          System.debug(LoggingLevel.WARN,' Could not create schedule ' + log);
        } */
   	}
   
   	///start batch for mapping SF and MEP User
   	public void startBatchForMappingSfAndMepUsers() {
   		if (isBatchJobRunning('MEP_SFUserMembershipMepUserBatch')) {
   			messageText = 'Job is already running. Please wait for some time to complete.';
        	return;
   		} else {
	        try {
	        	Database.executeBatch(new MEP_SFUserMembershipMepUserBatch(), 100);
	        	messageText = 'Job is queued as a background. You will receive an email notification when it is completed.';
	        } catch (Exception e) {
	        	System.debug(LoggingLevel.ERROR, e);
	        	messageText = e.getMessage();
	        }
   		}
   	}
   	
   	///start sheduler for nightly job
    public void startCreateNightlyJobs() {
    	
    	if (isNightlyJobRunning()) {
    		messageText = 'Job is already running. Please wait for some time to complete.';
    	} else {
    		MEP_NightlyJobs.startNightlyJobs();
    		messageText = 'Job is queued as a background. It will take some time to complete.';
    	}
    }  
    
    private Boolean isArchiveRunnig() {
    	 MEP_SYSTEM_SCHEDULE__c meetingJob =  MEP_SYSTEM_SCHEDULE__c.getInstance('MEP_MEETING_JOB');
    	 MEP_SYSTEM_SCHEDULE__c taskJob =  MEP_SYSTEM_SCHEDULE__c.getInstance('MEP_TASK_JOB');
    	 if (meetingJob.jobId__c == null && taskJob.jobId__c == null) {
    	 	return false;
    	 }
    	 return true;
    }
    
    private Boolean isNightlyJobRunning() {
    	MEP_SYSTEM_SCHEDULE__c job =  MEP_SYSTEM_SCHEDULE__c.getInstance('MEP_NIGHTLY_JOB');
    	 if (job.jobId__c == null) {
    	 	return false;
    	 }
    	 return true;
    }
    
    private Boolean isBatchJobRunning(String className) {
    	try {
    		AsyncApexJob[] jobs = [select Id from AsyncApexJob where ApexClass.Name = :className and Status IN ('Queued','Processing','Preparing')];
    		if (jobs != null && jobs.size() > 0) {
    			return true;
    		}
    	} catch (System.Queryexception e) {
    		System.debug('Butch is running, batch name class ' + className);
    	}
    	return false;
    }

}