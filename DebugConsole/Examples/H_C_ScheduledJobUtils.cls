//
//This class provides utilities to work with scheduled jobs
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (13-05-2013)
public with sharing class H_C_ScheduledJobUtils
{
	//
    //Constants
    //
    private static final String DEFAULT_CRON_EXPRESSION = '0 0 * * * ?';
    
    //these constants store unique codes of scheduled jobs
    public static final Integer JOB_SCHEDULED_ACCOUNTS_MANAGER = 1;
    public static final Integer[] ALL_JOBS = new Integer[]
    {
        JOB_SCHEDULED_ACCOUNTS_MANAGER
    };
    //
    
    //fill the map which stores names of an every known scheduled job
    private static Map<Integer, String> mapOfJobNames;
    static
    {
    	//fill  the map by real job names
    	mapOfJobNames = new Map<Integer, String>();
    	mapOfJobNames.put(JOB_SCHEDULED_ACCOUNTS_MANAGER, 'H_C_SCHEDULED_ACCOUNTS_MANAGER');
    	
    	if (Test.isRunningTest())
    	{
    		//we should generate unique names of jobs for Unit tests
	    	Map<Integer, String> correctedMapOfJobNames = new Map<Integer, String>();
	    	String suffixForNames = String.valueOf(DateTime.now().getTime());
	    	for (Integer jobCode : ALL_JOBS)
	    	{
	    		correctedMapOfJobNames.put(jobCode, jobCode + '_' + suffixForNames);
	    	}
	    	H_C_ScheduledJobUtils.mapOfJobNames = correctedMapOfJobNames;
	    	//
    	}
    }
    //
    
    //
    //Private static methods
    //
    private static Schedulable createJob(Integer jobCode)
    {
        if (jobCode == JOB_SCHEDULED_ACCOUNTS_MANAGER)
        {
            return new H_C_ScheduledAccountsManager();
        }
        return null;
    }
    
    private static String getCronExpression(Integer jobCode)
    {
    	String cronExpression = null;
    	//try to read cron expression from custom settings
    	Boolean isKnownJob = false;
    	if (jobCode == JOB_SCHEDULED_ACCOUNTS_MANAGER)
        {
        	cronExpression = H_C_CustomSettings.getStringValueByName(
        		H_C_CustomSettings.CRON_EXPR_FOR_SCHEDULED_ACCOUNTS_MNGR);
        	isKnownJob = true;
        }
        
        //if jobCode is correct, but there is no cron expression for this job in custom settings
        //then we should use default expression
        if (isKnownJob && String.isBlank(cronExpression))
        {
        	cronExpression = DEFAULT_CRON_EXPRESSION;
        }
        return cronExpression;
    }
    //
    
    //
    //Public static methods
    //
    public static StartResults startJob(Integer jobCode)
    {
    	StartResults results = new StartResults();
        try
        {
            //create the scheduled job
            Schedulable scheduledJob = createJob(jobCode);
            //start the scheduled job 
            System.schedule(mapOfJobNames.get(jobCode), getCronExpression(jobCode), scheduledJob);
            
            //fill the results of successful start
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
    	//Public properties
    	//
    	public Boolean isStartSuccessful {get; set;}
    	public String errorMessage {get; set;}
    	//
    }
    //
    
    
    
    
    
    //
    //Private Unit tests (I wanted to use @TestVisible annotation for private methods and
    //test them in a separate class, but this annotation is still not supported by IDE
    //and breaks Outline window)
    //
    @IsTest
    private static void testScheduledJobUtils_getCronExpression()
    {
    	System.assertEquals(DEFAULT_CRON_EXPRESSION,
    		getCronExpression(JOB_SCHEDULED_ACCOUNTS_MANAGER));
    	
    	String newCronExpression = '0 0 0 1 JAN ?';
    	H_C_UnitTestUtils.createSetting(H_C_CustomSettings.CRON_EXPR_FOR_SCHEDULED_ACCOUNTS_MNGR,
    		newCronExpression);
    	System.assertEquals(newCronExpression, getCronExpression(JOB_SCHEDULED_ACCOUNTS_MANAGER));
    }
    
    @IsTest
    private static void testScheduledJobUtils_createJobForAccounts()
    {
    	System.assertNotEquals(null, createJob(JOB_SCHEDULED_ACCOUNTS_MANAGER));
    	System.assertEquals(null, createJob(null));
    }
}