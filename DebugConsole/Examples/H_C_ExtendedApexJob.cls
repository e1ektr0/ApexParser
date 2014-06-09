//
//This abstract class extends functionality of a standard 'Database.Batchable' interface.
//Note that default implementation of 'Database.Batchable' interface is not provided and
//an every child non-abstract class must implement them. 
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (18-10-2013)
public abstract class H_C_ExtendedApexJob implements Database.Batchable<sObject>
{
	//
	//Variables
	//
	private String var_apexJobName = 'Unknown Apex Job';
	//
	
	//
	//Properties
	//
	public H_C_ApexJobUtils.PreStartInfo nextApexJob {get; set;}
	public String apexJobName
	{
		get
		{
			return this.var_apexJobName;
		}
		set
		{
			if (String.isNotBlank(value))
			{
				this.var_apexJobName = value;
			}
		}
	}
	//
	
	//
	//Protected methods
	//
	protected void tryStartNextJob()
	{
		if (this.nextApexJob != null)
		{
			//try to start the next job
			H_C_ApexJobUtils.StartResults startResults = H_C_ApexJobUtils.startJob(this.nextApexJob);
			
			//write information about the start in the log
        	if (startResults.isStartSuccessful)
			{
				System.debug(LoggingLevel.INFO, '\'' + this.apexJobName
					+ '\' has started a new APEX job. New APEX Job Id = ' + startResults.jobId);
			}
			else
			{
				System.debug(LoggingLevel.INFO, '\'' + this.apexJobName
					+ '\' has tried to start a new APEX job, but error has occured: '
					+ startResults.errorMessage);
			}
		}
	}
	//
}