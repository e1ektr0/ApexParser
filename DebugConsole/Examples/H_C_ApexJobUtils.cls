//
//This class provides utilities to work with APEX jobs
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (24-05-2013)
public with sharing class H_C_ApexJobUtils
{
    //
    //Constants
    //
    //these 3 constants are used as unique codes of all supported APEX jobs
    public static final Integer JOB_UPDATE_ACCOUNT_HIERARCHY = 1;
    public static final Integer JOB_ROLL_UP_ACCOUNT_TEAMS = 2;
    public static final Integer JOB_ROLL_DOWN_ACCOUNT_TEAMS = 3;
    public static final Integer JOB_ROLLUP_ACCOUNT_RELATED_LISTS = 4;
    public static final Integer JOB_COMPUTE_ACCOUNT_CHILDREN_COUNT = 5;
    //
    
    public static final Integer[] ALL_JOBS = new Integer[]
    {
        JOB_UPDATE_ACCOUNT_HIERARCHY,
        JOB_ROLL_UP_ACCOUNT_TEAMS,
        JOB_ROLL_DOWN_ACCOUNT_TEAMS,
        JOB_ROLLUP_ACCOUNT_RELATED_LISTS,
        JOB_COMPUTE_ACCOUNT_CHILDREN_COUNT
    };
    
    //default scope that can be used for unknown jobs
    public static final Integer DEFAULT_JOB_SCOPE = 200;
    
    //fill the map which stores lengths of scope for an every known job
    private static final Map<Integer, Integer> mapOfDefaultScopeLengths;
    static
    {
        mapOfDefaultScopeLengths = new Map<Integer, Integer>();
        mapOfDefaultScopeLengths.put(JOB_UPDATE_ACCOUNT_HIERARCHY, 500);
        mapOfDefaultScopeLengths.put(JOB_ROLL_UP_ACCOUNT_TEAMS, 200);
        mapOfDefaultScopeLengths.put(JOB_ROLL_DOWN_ACCOUNT_TEAMS, 200);
        mapOfDefaultScopeLengths.put(JOB_ROLLUP_ACCOUNT_RELATED_LISTS, 50);
        mapOfDefaultScopeLengths.put(JOB_COMPUTE_ACCOUNT_CHILDREN_COUNT, 500);
    }
    
    public static final String JOB_NOT_FOUND_MESSAGE = 'Job was not found';
    //
    
    //
    //Private static methods
    //
    private static Integer getScopeLength(Integer jobCode)
    {
    	Integer scope = null;
    	//try to get scope length from custom settings for an every job
    	if (jobCode == JOB_UPDATE_ACCOUNT_HIERARCHY)
    	{
    		scope = H_C_CustomSettings.getIntegerValueByName(
    			H_C_CustomSettings.SCOPE_FOR_ACCOUNT_HIERARCHY_MANAGER);
    	}
    	else if (jobCode == JOB_ROLL_UP_ACCOUNT_TEAMS)
    	{
    		scope = H_C_CustomSettings.getIntegerValueByName(
    			H_C_CustomSettings.SCOPE_FOR_ATRU_MANAGER);
    	}
    	else if (jobCode == JOB_ROLL_DOWN_ACCOUNT_TEAMS)
    	{
    		scope = H_C_CustomSettings.getIntegerValueByName(
    			H_C_CustomSettings.SCOPE_FOR_ATRD_MANAGER);
    	}
    	else if (jobCode == JOB_ROLLUP_ACCOUNT_RELATED_LISTS)
    	{
    		scope = H_C_CustomSettings.getIntegerValueByName(
    			H_C_CustomSettings.SCOPE_FOR_ACCOUNT_RELATED_LISTS_MANAGER);
    	}
    	else if (jobCode == JOB_COMPUTE_ACCOUNT_CHILDREN_COUNT)
    	{
    		scope = H_C_CustomSettings.getIntegerValueByName(
    			H_C_CustomSettings.SCOPE_FOR_COMPUTE_ACCOUNT_CHILD);
    	}
    	else
    	{
    		scope = DEFAULT_JOB_SCOPE;
    	}
    	
    	//if scope could not be read from custom settings then the system uses default values
    	return (scope > 0 ? scope : mapOfDefaultScopeLengths.get(jobCode));
    }
    //
    
    //
    //Public static methods
    //
    public static String getJobStatusMessage(String jobId)
    {
    	//initialize query builder
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(
            'Id, Status, TotalJobItems, JobItemsProcessed, NumberOfErrors', 'AsyncApexJob');
        queryBuilder.condition = 'Id = \'' + jobId + '\'';
       	//read data from DB 
        AsyncApexJob apexJob = (AsyncApexJob)H_C_SoqlUtils.performSingleResultQuery(queryBuilder);
        if (apexJob != null)
        {
        	//generate information
            String statusMessage = 'APEX job info : Status = ' + apexJob.Status;
            
            //if job is in processing already then we show more information 
            if (apexJob.TotalJobItems != 0)
            {
                statusMessage += '; Total Job Items = ' + apexJob.TotalJobItems
                    + '; Job Items Processed = ' + apexJob.JobItemsProcessed
                    + '; Number Of Errors = ' + apexJob.NumberOfErrors;
                
                //calculate completion status in percentage
                Double completionStatus = Math.round(
                    (double)apexJob.JobItemsProcessed / apexJob.TotalJobItems * 100);
                statusMessage += ' (Completed : ' + completionStatus + ' %)';
            }
            return statusMessage;
        }
        else
        {
            return JOB_NOT_FOUND_MESSAGE;
        }
    }
    
    public static StartResults startJob(PreStartInfo preStartJobInfo)
    {
    	if (preStartJobInfo == null || preStartJobInfo.jobManager == null)
    	{
    		return new StartResults(false);
    	}
    	return startJob(preStartJobInfo.jobManager, null, preStartJobInfo.jobCode);
    }
    
    public static StartResults startJob(Database.Batchable<sObject> jobManager, Integer jobCode)
    {
    	return startJob(jobManager, null, jobCode);
    }
    
    public static StartResults startJob(Database.Batchable<sObject> jobManager,
    	Integer scopeLength, Integer jobCode)
    {
    	StartResults results = new StartResults();
        try
        {
        	//if correct length of a scope is passed in the method, then we use it,
        	//else we get it internally
        	scopeLength = (scopeLength > 0 ? scopeLength : getScopeLength(jobCode));
        	
            //start the job 
            String jobId = Database.executeBatch(jobManager, scopeLength);
            
            //fill the results of successful start
            results.jobId = jobId;
            results.isStartSuccessful = true;
        }
        catch (Exception e)
        {
        	//fill the results of incorrect start
        	results.errorMessage = e.getMessage();
        	results.isStartSuccessful = false;
        }
        return results;
    }
    //
    
    
    //
    //Data types
    //
    public class StartResults
    {
    	//
    	//Constructors
    	//
    	public StartResults()
    	{
    	}
    	
    	public StartResults(Boolean isStartSuccessful)
    	{
    		this.isStartSuccessful = isStartSuccessful;
    	}
    	//
    	
    	//
    	//Public properties
    	//
    	public Boolean isStartSuccessful {get; set;}
    	public String jobId {get; set;}
    	public String errorMessage {get; set;}
    	//
    }
    
    public class PreStartInfo
    {
    	//
    	//Constructors
    	//
    	public PreStartInfo()
    	{
    	}
    	
    	public PreStartInfo(Database.Batchable<sObject> jobManager, Integer jobCode)
    	{
    		this.jobManager = jobManager;
    		this.jobCode = jobCode;
    	}
    	//
    	
    	//
    	//Public properties
    	//
    	public Database.Batchable<sObject> jobManager {get; set;}
    	public Integer jobCode {get; set;}
    	//
    }
    //
    
    
    
    
    
    //
    //Private Unit tests (I wanted to use @TestVisible annotation for private methods and
    //test them in a separate class, but this annotation is still not supported by IDE
    //and breaks Outline window)
    //
    @IsTest
    private static void testApexJobUtils_getScopeLength()
    {
    	//test private method to be sure that all jobs have correct default scope
    	for (Integer jobCode : ALL_JOBS)
    	{
    		System.assert(getScopeLength(jobCode) > 0);
    	}
    }
    //
}