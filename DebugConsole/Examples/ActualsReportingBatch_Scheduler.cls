/**
    *  Description : This is the scheduler class which executes the batch "ActualsReportingBatch" for recalculating the 
                     Invoice Summary revenue rollups on all the Accounts
    *
    *  @author : Vishal Negandhi <vnegandhi@innoveer.com>
    *
    *  @since   Sept 26, 2012
 */
global class ActualsReportingBatch_Scheduler implements Schedulable
{
    global void execute(SchedulableContext SC) 
    {  
        // execute the Batch "ActualsReportingBatch" with batch size of 1 for Revenue recalculation 
        ActualsReportingBatch callBatch = new ActualsReportingBatch(); 
        Integer batchSize = (Test.isRunningTest() ? 50 : 1);
        Database.executeBatch(callBatch, batchSize);
   }
}