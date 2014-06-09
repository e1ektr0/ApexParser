global class ActualsReportingBatch implements Database.Batchable<sobject>
{
    String invQuery; // for storing the query on Invoices
    Set<Id> setAccountIds; // to store all the Account Id's that are to be updated
    
    Map<Id, Decimal> AccountThisMTD;  // stores each Account Id with it's relevant Sales_This_MTD__c value
    Map<Id, Decimal> AccountLastMTD;  // stores each Account Id with it's relevant Sales_Last_MTD__c value
    Map<Id, Decimal> AccountThisQTD;  // stores each Account Id with it's relevant Sales_This_QTD__c value
    Map<Id, Decimal> AccountLastQTD;  // stores each Account Id with it's relevant Sales_Last_QTD__c value
    Map<Id, Decimal> AccountThisFYTD; // stores each Account Id with it's relevant Sales_This_TTD__c value
    Map<Id, Decimal> AccountLastFYTD; // stores each Account Id with it's relevant Sales_Last_YTD__c value
    Map<String, double> currencymap;  // stored the ISO and its conversion rate
    
    FiscalYearSettings currentFYS;  // stores current FY's settings
    FiscalYearSettings lastFYS;     // stores previous FY's settings
     
    Period currentMonth;    // stores Current fiscal Month
    Period lastMonth;   // stores previous fiscal month
    
    Period currentPeriod;   // stores current Quarter values
    Period lastYearPeriod;  // stores current Quarter values for previous year
    
    
    global ActualsReportingBatch()
    {
        //Edited on 15/01/2013 by Vpandea (Innoveer)
        //Get current Fiscal Year start, end date and previous Fiscal Year's 
        currentFYS = [SELECT StartDate, EndDate, Id FROM FiscalYearSettings WHERE YearType = 'Custom' AND EndDate = THIS_FISCAL_YEAR];
        lastFYS = [SELECT StartDate, EndDate FROM FiscalYearSettings WHERE YearType = 'Custom' AND EndDate  = LAST_FISCAL_YEAR];
                
        //Edited on 10/01/2013 by ABaneka (Innoveer) - find previous FY's start and end date
        list<FiscalYearSettings> fyslst= [Select id,name,EndDate from FiscalYearSettings where YearType =: 'Custom' ORDER BY EndDate asc];
        integer lastFiscalYearIndex; // get last year's fiscal year index to use in query
        
        //Get the index for previous FY
        for(integer i = 0; i <fyslst.size();i++){
            if(currentFYS.Id == fyslst[i].id ){
                lastFiscalYearIndex = i - 1;    
            }
        }
        
        // Get current and previous fiscal months
        currentMonth = [SELECT Type, StartDate, Number, EndDate ,FiscalYearSettingsId 
                        FROM Period WHERE StartDate <= TODAY AND EndDate > TODAY AND Type = 'Month' LIMIT 1];        
        lastMonth = [SELECT Number,Type,FiscalYearSettingsiD,StartDate, EndDate FROM Period 
                     WHERE Type = 'Month' AND FiscalYearSettingsid =: fyslst[lastFiscalYearIndex].id 
                     AND Number=:currentMonth.Number LIMIT 1];
            
        //Edited on 11/1/2013 by Abhijeet Baneka (Innoveer Solutions)
        //Change of Logic to get the quarter period in last fiscal year.
        currentPeriod = [SELECT Number,StartDate,FiscalYearSettingsid, EndDate FROM Period 
                         WHERE Type = 'Quarter' AND EndDate = THIS_FISCAL_QUARTER];
        lastYearPeriod = [SELECT Number,Type,FiscalYearSettingsiD,StartDate,EndDate FROM Period 
                          WHERE Type = 'Quarter' AND FiscalYearSettingsid =: fyslst[lastFiscalYearIndex].id 
                          AND Number=:currentPeriod.Number LIMIT 1];
        
        //Retrieve all invoices belonging to this FY and last FY
        invQuery = 'Select Ship_To_Site__c, CurrencyIsoCode, Local_Amount__c, GL_Date__c From Invoice__c' + 
                + ' Where GL_Date__c != NULL AND Ship_To_Site__c != NULL AND Local_Amount__c != NULL' + 
                + ' AND (GL_Date__c = LAST_FISCAL_YEAR OR GL_Date__c = THIS_FISCAL_YEAR)' ;
                
        //Start - Initializing all the class variables    
        setAccountIds = new set<Id>();
        AccountThisMTD = new Map<Id, Decimal>();
        AccountLastMTD = new Map<Id, Decimal>(); 
        AccountThisQTD = new Map<Id, Decimal>(); 
        AccountLastQTD = new Map<Id, Decimal>(); 
        AccountThisFYTD = new Map<Id, Decimal>();
        AccountLastFYTD = new Map<Id, Decimal>();
        currencymap  = new map<String,double>();

        //Edited on 14/1/2013 by ABaneka(Innoveer) - get the ISO and Currency map from the currencytype table.
        for(CurrencyType conrate : [SELECT IsoCode,ConversionRate FROM CurrencyType]){
            currencymap.put(conrate.isocode,conrate.ConversionRate);
        } 
        //End - Initializing all the class variables  
    }

    global Database.Querylocator Start(Database.BatchableContext BC)
    {
        // returns a list of invoices 
        return Database.getQueryLocator(invQuery);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        Savepoint sp = Database.setSavepoint(); // storing a database savepoint to roll back in case of any exceptions
        LIST<EmailAddress__c> ea = EmailAddress__c.getall().values();

        try
        {
            List<Invoice__c> AllInvoices = new List<Invoice__c>((List<Invoice__c>)scope); // typecasting list<sobject> to list<invoice__c>
            List<Account> lstAccountsToUpdate = new List<Account>();    // stores all the Accounts that are to be updated
            //
            // Here we iterate through the entire list of invoices that are passed to the batch, we calculate the values for
            // each of the individual fields on related Transactional Accounts and store them in their respective maps 
            //
            for(Invoice__c i: AllInvoices)
            {
                // storing each transactional Account Id with it's SALES THIS MTD
                if(i.GL_Date__c >= currentMonth.StartDate && i.GL_Date__c <= date.today())
                {
                    setAccountIds.add(i.Ship_To_Site__c);

                    if(!AccountThisMTD.containsKey(i.Ship_To_Site__c))
                        AccountThisMTD.put(i.Ship_To_Site__c, getUSDAmount(i.Local_Amount__c,i.CurrencyIsoCode));
                    else
                        AccountThisMTD.put(i.Ship_To_Site__c, AccountThisMTD.get(i.Ship_To_Site__c) + getUSDAmount(i.Local_Amount__c,i.CurrencyIsoCode));
                }

                // Storing each transactional Account Id with it's SALES LAST MTD
                // Edited By : Veronica Pandea (Innoveer Solutions)on 11/01/2013
                // Replacing lastEndDate with lastMonth.EndDate
                // if(i.GL_Date__c >= lastMonth.StartDate && i.GL_Date__c <= lastEndDate)
                if(i.GL_Date__c >= lastMonth.StartDate && i.GL_Date__c <= lastMonth.EndDate)
                {
                    setAccountIds.add(i.Ship_To_Site__c);

                    if(!AccountLastMTD.containsKey(i.Ship_To_Site__c))
                        AccountLastMTD.put(i.Ship_To_Site__c, getUSDAmount(i.Local_Amount__c,i.CurrencyIsoCode));
                    else
                        AccountLastMTD.put(i.Ship_To_Site__c, AccountLastMTD.get(i.Ship_To_Site__c) + getUSDAmount(i.Local_Amount__c,i.CurrencyIsoCode));
                }

                // storing each transactional Account Id with it's SALES THIS QTD
                if(i.GL_Date__c >= currentPeriod.StartDate && i.GL_Date__c <= date.today())
                {
                    setAccountIds.add(i.Ship_To_Site__c);

                    if(!AccountThisQTD.containsKey(i.Ship_To_Site__c))
                        AccountThisQTD.put(i.Ship_To_Site__c, getUSDAmount(i.Local_Amount__c,i.CurrencyIsoCode));
                    else
                        AccountThisQTD.put(i.Ship_To_Site__c, AccountThisQTD.get(i.Ship_To_Site__c) + getUSDAmount(i.Local_Amount__c,i.CurrencyIsoCode));
                }

                // storing each transactional Account Id with it's SALES LAST QTD
                // Edited By : Veronica Pandea (Innoveer Solutions)on 11/01/2013
                // Replacing lastEndDate with lastYearPeriod.EndDate
                // if(i.GL_Date__c >= lastYearPeriod.StartDate && i.GL_Date__c <= lastEndDate)
                if(i.GL_Date__c >= lastYearPeriod.StartDate && i.GL_Date__c <= lastMonth.EndDate)
                {
                    setAccountIds.add(i.Ship_To_Site__c);

                    if(!AccountLastQTD.containsKey(i.Ship_To_Site__c))
                        AccountLastQTD.put(i.Ship_To_Site__c, getUSDAmount(i.Local_Amount__c,i.CurrencyIsoCode));
                    else
                        AccountLastQTD.put(i.Ship_To_Site__c, AccountLastQTD.get(i.Ship_To_Site__c) + getUSDAmount(i.Local_Amount__c,i.CurrencyIsoCode));
                }

                // storing each transactional Account Id with it's SALES THIS FYTD
                if(i.GL_Date__c >= currentFYS.StartDate && i.GL_Date__c <= date.today())
                {
                    setAccountIds.add(i.Ship_To_Site__c);

                    if(!AccountThisFYTD.containsKey(i.Ship_To_Site__c))
                        AccountThisFYTD.put(i.Ship_To_Site__c, getUSDAmount(i.Local_Amount__c,i.CurrencyIsoCode));
                    else
                        AccountThisFYTD.put(i.Ship_To_Site__c, AccountThisFYTD.get(i.Ship_To_Site__c) + getUSDAmount(i.Local_Amount__c,i.CurrencyIsoCode));
                }

                // storing each transactional Account Id with it's SALES LAST FYTD
                // Edited By : Veronica Pandea (Innoveer Solutions)on 11/01/2013
                // Replacing lastEndDate with lastMonth.EndDate
                // if(i.GL_Date__c >= lastFYS.StartDate && i.GL_Date__c <= lastEndDate)
                if(i.GL_Date__c >= lastFYS.StartDate && i.GL_Date__c <= lastMonth.EndDate)
                {
                    setAccountIds.add(i.Ship_To_Site__c);

                    if(!AccountLastFYTD.containsKey(i.Ship_To_Site__c))
                        AccountLastFYTD.put(i.Ship_To_Site__c, getUSDAmount(i.Local_Amount__c,i.CurrencyIsoCode)); 
                    else
                        AccountLastFYTD.put(i.Ship_To_Site__c, AccountLastFYTD.get(i.Ship_To_Site__c) + getUSDAmount(i.Local_Amount__c,i.CurrencyIsoCode));
                }
            }
            //
            // Once we have collected the revenues for each transactional account, we rollup it up to Parent accounts using 
            // this recursive function
            //
            updateAccounts(setAccountIds);

            // Queries all the Accounts that are to be updated
            lstAccountsToUpdate = [SELECT Sales_Last_MTD_Last_Batch_Update__c, Sales_Last_QTD_Last_Batch_Update__c, 
                                   Sales_This_YTD_Last_Batch_Update__c, Sales_Last_YTD_Last_Batch_Update__c, 
                                   Sales_This_QTD_Last_Batch_Update__c, Sales_This_MTD_Last_Batch_Update__c, Sales_This_YTD__c, 
                                   Sales_This_QTD__c, Sales_This_MTD__c, Sales_Last_YTD__c, Sales_Last_QTD__c, Sales_Last_MTD__c 
                                   FROM Account WHERE Id IN :setAccountIds];    

            //
            // Assigning values to each of the six fields on all the Accounts
            // The logic here is to update the date field for each of the related Rollup fields on Account to today's date, 
            // if the account is updated. We can have invoices related to one account come in different batches, so this date field
            // is used to do calculations on Account. 
            //
            for(Account a: lstAccountsToUpdate)
            {
                // Roll up calculation for This MTD
                if(AccountThisMTD.containsKey(a.Id))
                {
                    a.Sales_This_MTD__c = ((a.Sales_This_MTD_Last_Batch_Update__c == date.today()) ? a.Sales_This_MTD__c + AccountThisMTD.get(a.Id) : AccountThisMTD.get(a.Id));
                    a.Sales_This_MTD_Last_Batch_Update__c = date.today();
                }
                else if(!AccountThisMTD.containsKey(a.Id) && a.Sales_This_MTD_Last_Batch_Update__c != date.today())
                {
                    a.Sales_This_MTD__c = 0;
                    a.Sales_This_MTD_Last_Batch_Update__c = date.today();
                }

                // Roll up calculation for This QTD
                if(AccountThisQTD.containsKey(a.Id))
                {
                    a.Sales_This_QTD__c = ((a.Sales_This_QTD_Last_Batch_Update__c == date.today()) ? a.Sales_This_QTD__c + AccountThisQTD.get(a.Id) : AccountThisQTD.get(a.Id));
                    a.Sales_This_QTD_Last_Batch_Update__c = date.today();
                }
                else if(!AccountThisQTD.containsKey(a.Id) && a.Sales_This_QTD_Last_Batch_Update__c != date.today())
                {
                    a.Sales_This_QTD__c = 0;
                    a.Sales_This_QTD_Last_Batch_Update__c = date.today();
                }

                // Roll up calculation for This YTD
                if(AccountThisFYTD.containsKey(a.Id))
                {
                    a.Sales_This_YTD__c = ((a.Sales_This_YTD_Last_Batch_Update__c == date.today()) ? a.Sales_This_YTD__c + AccountThisFYTD.get(a.Id) : AccountThisFYTD.get(a.Id));
                    a.Sales_This_YTD_Last_Batch_Update__c = date.today();
                }   
                else if(!AccountThisFYTD.containsKey(a.Id) && a.Sales_This_YTD_Last_Batch_Update__c != date.today())
                {
                    a.Sales_This_YTD__c = 0;
                    a.Sales_This_YTD_Last_Batch_Update__c = date.today();
                }               

                // Roll up calculation for Last YTD
                if(AccountLastFYTD.containsKey(a.Id))
                {
                    a.Sales_Last_YTD__c = ((a.Sales_Last_YTD_Last_Batch_Update__c == date.today()) ? a.Sales_Last_YTD__c + AccountLastFYTD.get(a.Id) : AccountLastFYTD.get(a.Id));
                    a.Sales_Last_YTD_Last_Batch_Update__c = date.today();
                }   
                else if(!AccountLastFYTD.containsKey(a.Id) && a.Sales_Last_YTD_Last_Batch_Update__c != date.today())
                {
                    a.Sales_Last_YTD__c = 0;
                    a.Sales_Last_YTD_Last_Batch_Update__c = date.today();
                }

                // Roll up calculation for Last QTD
                if(AccountLastQTD.containsKey(a.Id))
                {
                    a.Sales_Last_QTD__c = ((a.Sales_Last_QTD_Last_Batch_Update__c == date.today()) ? a.Sales_Last_QTD__c + AccountLastQTD.get(a.Id) : AccountLastQTD.get(a.Id));
                    a.Sales_Last_QTD_Last_Batch_Update__c = date.today();
                }
                else if(!AccountLastQTD.containsKey(a.Id) && a.Sales_Last_QTD_Last_Batch_Update__c != date.today())
                {
                    a.Sales_Last_QTD__c = 0;
                    a.Sales_Last_QTD_Last_Batch_Update__c = date.today();
                }

                // Roll up calculation for Last MTD
                if(AccountLastMTD.containsKey(a.Id))
                {
                    a.Sales_Last_MTD__c = ((a.Sales_Last_MTD_Last_Batch_Update__c == date.today()) ? a.Sales_Last_MTD__c + AccountLastMTD.get(a.Id) : AccountLastMTD.get(a.Id));
                    a.Sales_Last_MTD_Last_Batch_Update__c = date.today();
                }
                else if(!AccountLastMTD.containsKey(a.Id) && a.Sales_Last_MTD_Last_Batch_Update__c != date.today())
                {
                    a.Sales_Last_MTD__c = 0;
                    a.Sales_Last_MTD_Last_Batch_Update__c = date.today();
                }
            }

            // update the list of Accounts  
            if(lstAccountsToUpdate.size() > 0)
                update lstAccountsToUpdate;
        }
        catch(exception e)
        {
            Database.rollback(sp); // rollback the database to the savepoint captured above if there is an exception
            // TO notify the developer of the exception caught through email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {ea[0].name};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Account Invoice Revenue Rollup Batch Exception: ');
            mail.setPlainTextBody('Exception occured : '  + e.getMessage());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

    //
    // Method - updateAccounts
    // Description - This is a recursive function which first queries Parent accounts for the set of account id's passed to it
    //               and keeps on rolling up the calculated values till it reaches the highest level in the hierarchy
    //
    private void updateAccounts(Set<Id> setIds)
    {
        List<Account> parentAccounts = new List<Account>(); // list to store the queried parent accounts
        Set<Id> tempIds = new Set<Id>(); // set to store the parent account id's, to be passed back to this function as parameter

        parentAccounts = [SELECT ParentId From Account WHERE Id IN :setIds AND ParentId != NULL];

        if(parentAccounts.size() > 0)
        {
            // Iterate through parent Accounts and rollup the calculations using the maps for each field
            for(Account p : parentAccounts)
            {
                // For rollup of SALES THIS FYTD
                if(!AccountThisFYTD.containsKey(p.ParentId) && AccountThisFYTD.containsKey(p.Id) && AccountThisFYTD.get(p.Id) != null)
                    AccountThisFYTD.put(p.ParentId, AccountThisFYTD.get(p.Id));
                else if(AccountThisFYTD.containsKey(p.ParentId) && AccountThisFYTD.containsKey(p.Id))
                    AccountThisFYTD.put(p.ParentId, AccountThisFYTD.get(p.ParentId) + AccountThisFYTD.get(p.Id));

                // For rollup of SALES THIS MTD
                if(!AccountThisMTD.containsKey(p.ParentId) && AccountThisMTD.containsKey(p.Id) && AccountThisMTD.get(p.Id) != null)
                    AccountThisMTD.put(p.ParentId, AccountThisMTD.get(p.Id));
                else if(AccountThisMTD.containsKey(p.ParentId) && AccountThisMTD.containsKey(p.Id))
                    AccountThisMTD.put(p.ParentId, AccountThisMTD.get(p.ParentId) + AccountThisMTD.get(p.Id));

                // For rollup of SALES THIS QTD
                if(!AccountThisQTD.containsKey(p.ParentId) && AccountThisQTD.containsKey(p.Id) && AccountThisQTD.get(p.Id) != null)
                    AccountThisQTD.put(p.ParentId, AccountThisQTD.get(p.Id));
                else if(AccountThisQTD.containsKey(p.ParentId) && AccountThisQTD.containsKey(p.Id))
                    AccountThisQTD.put(p.ParentId, AccountThisQTD.get(p.ParentId) + AccountThisQTD.get(p.Id));


                // For rollup of SALES LAST MTD
                if(!AccountLastMTD.containsKey(p.ParentId) && AccountLastMTD.containsKey(p.Id) && AccountLastMTD.get(p.Id) != null)
                    AccountLastMTD.put(p.ParentId, AccountLastMTD.get(p.Id));
                else if(AccountLastMTD.containsKey(p.ParentId) && AccountLastMTD.containsKey(p.Id))
                    AccountLastMTD.put(p.ParentId, AccountLastMTD.get(p.ParentId) + AccountLastMTD.get(p.Id));

                // For rollup of SALES LAST QTD
                if(!AccountLastQTD.containsKey(p.ParentId) && AccountLastQTD.containsKey(p.Id) && AccountLastQTD.get(p.Id) != null)
                    AccountLastQTD.put(p.ParentId, AccountLastQTD.get(p.Id));
                else if(AccountLastQTD.containsKey(p.ParentId) && AccountLastQTD.containsKey(p.Id))
                    AccountLastQTD.put(p.ParentId, AccountLastQTD.get(p.ParentId) + AccountLastQTD.get(p.Id));

                // For rollup of SALES LAST FYTD
                if(!AccountLastFYTD.containsKey(p.ParentId) && AccountLastFYTD.containsKey(p.Id) && AccountLastFYTD.get(p.Id) != null)
                    AccountLastFYTD.put(p.ParentId, AccountLastFYTD.get(p.Id));
                else if(AccountLastFYTD.containsKey(p.ParentId) && AccountLastFYTD.containsKey(p.Id))
                    AccountLastFYTD.put(p.ParentId, AccountLastFYTD.get(p.ParentId) + AccountLastFYTD.get(p.Id));

                tempIds.add(p.ParentId);
                setAccountIds.add(p.ParentId);
            }
            updateAccounts(tempIds); // call the same function till it reaches the Highest level in the hierarchy
        }
    }

    //
    // Method - getUSDAmount
    // Description - This will give you the currency field converted to USD provided by the amount and the ISO code for the amount. 
    // Added By - ABaneka<innoveer> 14/1/2013
    //
    private Decimal getUSDAmount(Decimal amt, String ISOCode){
        Decimal convertedValue = 0;
        if(currencymap.get(ISOCode) != null && currencymap.get(ISOCode) != 0 && !currencymap.isEmpty() && amt!=null && amt != 0){
            convertedValue = (1 / currencymap.get(ISOCode)) * amt;   
        }
        return convertedValue;
    }

    global void finish(Database.BatchableContext BC)
    {
        // Get the ID of the AsyncApexJob representing this batch job from Database.BatchableContext. 
        // Query the AsyncApexJob object to retrieve the current job's information. 
        LIST<EmailAddress__c> ea = EmailAddress__c.getall().values();

        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
                          FROM AsyncApexJob WHERE Id = :BC.getJobId()];

        // Send an email to the Apex job's submitter notifying of job completion. 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {ea[0].name};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Account Invoice Revenue Rollup Batch status: ' + a.Status);
        mail.setPlainTextBody
        ('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}