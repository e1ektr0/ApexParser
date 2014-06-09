/**
    *  Description : This is the scheduler class which executes the batch "MonthlyRevenueBatch" for recalculating the 
                     Invoice Summary revenue rollups on all the Accounts
    *
    *  @author :Abhijeet Baneka <abaneka@innoveer.com>
    *
    *  @since   Oct 4, 2012
 */
global class MonthlyRevenue_Scheduler implements Schedulable
{
    global void execute(SchedulableContext SC) 
    {  
        // execute the Batch "MonthlyRevenueBatch" with batch size of 1 for Revenue recalculation 
        MonthlyRevenueBatch callBatch = new MonthlyRevenueBatch(); 
        Integer batchSize = (Test.isRunningTest() ? 50 : 1);
        Database.executeBatch(callBatch, batchSize);
   }
}