/**
 *  Name - InvoiceTriggerHelper
 *
 *  Description - This triggerHelperClass adds a Account team Member and set the accesibilty on Account and Opportunity.
 *
 *  @author  Abhijeet Baneka <abaneka@innoveer.com>
 *  @since   Sep 3, 2012
 */
 
public without sharing class InvoiceTriggerHelper { 

    // These constants are public so they can be used in the test class
    public final static String USER_ROLE_SUFFIX = ' Sales Rep'; // For assigning account team roles
    public final static String ACCT_ACCESS_LEVEL = 'Edit'; // Account access level for account team members
    public final static String OPPY_ACCESS_LEVEL = 'Read'; // Opportunity access level for account team members
    
    public final static Integer DEFAULT_ORGID = 99999; // Org id value for users with null org id 
    // Updates/inserts the account teams associated with the "Ship To" accounts associated with
    // updated/inserted Invoices
    public static void addAccountTeam(Map<Id, Invoice__c> triggerOldMap,
                                      Map<Id, Invoice__c> triggerNewMap) {
        if(!stopRecursion.hasAlreadyExecuted()){
        List<AccountTeamMember> listAccountTeamsToUpsert = new List<AccountTeamMember>();
        List<AccountShare> listAccountSharesToUpdate = new List<AccountShare>();
        Set<Id> setUserIdsInAccountTeams = new Set<Id>(); 
        Set<Id> setAccountIdsInAccountTeams = new Set<Id>();
        // For identifying account shares
        // First ID is an account ID, second ID is a user ID
        Map<Id, Map<Id, AccountTeamMember>> mapAccountTeams = new Map<Id, Map<Id, AccountTeamMember>>();
        Map<Id, User> mapUsersAndBusinessUnits; // For getting users' business units

        // Start building account teams
        // Note that once this loop is finished, we won't yet have assigned roles on the account teams
        // because the assignment depends on the Business Unit field on the User object, which we will
        // query for afterward
        for(Invoice__c inv : [Select id ,  Ship_To_Site__r.ParentId ,Bill_To_Customer__r.ParentId ,Ship_To_Site__c,Territory_Rep_1__c,Territory_Rep_2__c,Territory_Rep_3__c,Territory_Rep_4__c,Territory_Rep_5__c,Territory_Rep_6__c,Territory_Rep_7__c, Territory_Rep_8__c,Territory_Rep_9__c ,Territory_Rep_10__c  From Invoice__c WHERE id IN: triggerNewMap.values()]) {

            AccountTeamMember atm;
            AccountTeamMember patm1;
            AccountTeamMember patm2;

            // Compare the old trigger map vs. the new trigger map
            // If there's been a change, or if the old map doesn't exist (implying a invoice record insertion),
            // add the users to the account team
            
            
            //START: 10/01/2013 ABaneka (Innoveer)
            //Description : Ship to Site Changed from master detail to lookup, adding the condition to check null condition
            if(inv.Ship_To_Site__c !=null){            
                // We add the "ship to" account to a set so we can query against it later
                // We do the same thing with setUserIdsInAccountTeams for each territory rep, below
                setAccountIdsInAccountTeams.add(inv.Ship_To_Site__c);
            }
            //END: 10/01/2013 ABaneka (Innoveer)
                 
            //As Parent Id Is not a required field checking for null conditon to avois null pointer exception
            //Get Ship to Account Site parent. 
            if(inv.Ship_To_Site__r.ParentId  != null){
                setAccountIdsInAccountTeams.add(inv.Ship_To_Site__r.ParentId );
            }
                        
            //As Parent Id Is not a required field checking for null conditon to avois null pointer exception
            //Get Bill to Account Site parent Customer Account.
            if(inv.Bill_To_Customer__r.ParentId != null){   
                setAccountIdsInAccountTeams.add(inv.Bill_To_Customer__r.ParentId );
            }

            // Build the mapAccountTeams map; we will use this later to find related AccountShare records
            // so we can modify account team permissions
            if(mapAccountTeams.get(inv.Ship_To_Site__c) == null) {
                mapAccountTeams.put(inv.Ship_To_Site__c, new Map<Id, AccountTeamMember>());
            }
            
            //adding parent accounts as well. 
            if(inv.Ship_To_Site__r.ParentId  != null){
                if(mapAccountTeams.get(inv.Ship_To_Site__r.ParentId) == null) {
                    mapAccountTeams.put(inv.Ship_To_Site__r.ParentId, new Map<Id, AccountTeamMember>());
                }
            }
            if(inv.Bill_To_Customer__r.ParentId != null){
                if(mapAccountTeams.get(inv.Bill_To_Customer__r.ParentId ) == null) {
                    mapAccountTeams.put(inv.Bill_To_Customer__r.ParentId , new Map<Id, AccountTeamMember>());
                }
            }
            
            //For all Territory reps we create the AccountTeamMember for Ship to Site ACCOUNT and also create
            // them for parent accounts of Bill to Customer and Ship to Customer. 
            
            // Territory Rep 1
            if(inv.Territory_Rep_1__c != null) {
                setUserIdsInAccountTeams.add(inv.Territory_Rep_1__c);
                
                //START: 10/01/2013 VPandea (Innoveer): Added checks for shipTo 
                if(inv.Ship_To_Site__c != null){
                    atm = new AccountTeamMember(AccountId = inv.Ship_To_Site__c, UserId = inv.Territory_Rep_1__c);
                    listAccountTeamsToUpsert.add(atm);
                    mapAccountTeams.get(inv.Ship_To_Site__c).put(inv.Territory_Rep_1__c, atm);
                }
                //END                
                if(inv.Ship_To_Site__r.ParentId !=null){
                    patm1 = new AccountTeamMember(AccountId = inv.Ship_To_Site__r.ParentId, UserId = inv.Territory_Rep_1__c);
                    listAccountTeamsToUpsert.add(patm1);
                    mapAccountTeams.get(inv.Ship_To_Site__r.ParentId).put(inv.Territory_Rep_1__c, patm1);
                }
                if(inv.Bill_To_Customer__r.ParentId!= null){
                    patm2 = new AccountTeamMember(AccountId = inv.Bill_To_Customer__r.ParentId, UserId = inv.Territory_Rep_1__c);
                    listAccountTeamsToUpsert.add(patm2);
                    mapAccountTeams.get(inv.Bill_To_Customer__r.ParentId).put(inv.Territory_Rep_1__c, patm2);
                }
            }

            // Territory Rep 2
            if(inv.Territory_Rep_2__c != null) {
                setUserIdsInAccountTeams.add(inv.Territory_Rep_2__c);
                
                //START: 10/01/2013 VPandea (Innoveer): Added checks for shipTo 
                if(inv.Ship_To_Site__c != null){
                    atm = new AccountTeamMember(AccountId = inv.Ship_To_Site__c, UserId = inv.Territory_Rep_2__c);
                    listAccountTeamsToUpsert.add(atm);
                    mapAccountTeams.get(inv.Ship_To_Site__c).put(inv.Territory_Rep_2__c, atm);
                }
                //END                
                if(inv.Ship_To_Site__r.ParentId !=null){
                    patm1 = new AccountTeamMember(AccountId = inv.Ship_To_Site__r.ParentId, UserId = inv.Territory_Rep_2__c);
                    listAccountTeamsToUpsert.add(patm1);
                    mapAccountTeams.get(inv.Ship_To_Site__r.ParentId).put(inv.Territory_Rep_2__c, patm1);
                }
                if(inv.Bill_To_Customer__r.ParentId!= null){
                    patm2 = new AccountTeamMember(AccountId = inv.Bill_To_Customer__r.ParentId, UserId = inv.Territory_Rep_2__c);
                    listAccountTeamsToUpsert.add(patm2);
                    mapAccountTeams.get(inv.Bill_To_Customer__r.ParentId).put(inv.Territory_Rep_2__c, patm2);
                }
            }

            // Territory Rep 3
            if(inv.Territory_Rep_3__c != null) {
                setUserIdsInAccountTeams.add(inv.Territory_Rep_3__c);
                
                //START: 10/01/2013 VPandea (Innoveer): Added checks for shipTo 
                if(inv.Ship_To_Site__c != null){
                    atm = new AccountTeamMember(AccountId = inv.Ship_To_Site__c, UserId = inv.Territory_Rep_3__c);
                    listAccountTeamsToUpsert.add(atm);
                    mapAccountTeams.get(inv.Ship_To_Site__c).put(inv.Territory_Rep_3__c, atm);
                }
                //END                
                if(inv.Ship_To_Site__r.ParentId !=null){
                    patm1 = new AccountTeamMember(AccountId = inv.Ship_To_Site__r.ParentId, UserId = inv.Territory_Rep_3__c);
                    listAccountTeamsToUpsert.add(patm1);
                    mapAccountTeams.get(inv.Ship_To_Site__r.ParentId).put(inv.Territory_Rep_3__c, patm1);
                }
                if(inv.Bill_To_Customer__r.ParentId!= null){
                    patm2 = new AccountTeamMember(AccountId = inv.Bill_To_Customer__r.ParentId, UserId = inv.Territory_Rep_3__c);
                    listAccountTeamsToUpsert.add(patm2);
                    mapAccountTeams.get(inv.Bill_To_Customer__r.ParentId).put(inv.Territory_Rep_3__c, patm2);
                }
            }

            // Territory Rep 4
            if(inv.Territory_Rep_4__c != null) {
                setUserIdsInAccountTeams.add(inv.Territory_Rep_4__c);
                
                //START: 10/01/2013 VPandea (Innoveer): Added checks for shipTo 
                if(inv.Ship_To_Site__c != null){
                    atm = new AccountTeamMember(AccountId = inv.Ship_To_Site__c, UserId = inv.Territory_Rep_4__c);
                    listAccountTeamsToUpsert.add(atm);
                    mapAccountTeams.get(inv.Ship_To_Site__c).put(inv.Territory_Rep_4__c, atm);
                }
                //END                
                if(inv.Ship_To_Site__r.ParentId !=null){
                    patm1 = new AccountTeamMember(AccountId = inv.Ship_To_Site__r.ParentId, UserId = inv.Territory_Rep_4__c);
                    listAccountTeamsToUpsert.add(patm1);
                    mapAccountTeams.get(inv.Ship_To_Site__r.ParentId).put(inv.Territory_Rep_4__c, patm1);
                }
                if(inv.Bill_To_Customer__r.ParentId!= null){
                    patm2 = new AccountTeamMember(AccountId = inv.Bill_To_Customer__r.ParentId, UserId = inv.Territory_Rep_4__c);
                    listAccountTeamsToUpsert.add(patm2);
                    mapAccountTeams.get(inv.Bill_To_Customer__r.ParentId).put(inv.Territory_Rep_4__c, patm2);
                }
            }

            // Territory Rep 5
            if(inv.Territory_Rep_5__c != null) {
                setUserIdsInAccountTeams.add(inv.Territory_Rep_5__c);
                
                //START: 10/01/2013 VPandea (Innoveer): Added checks for shipTo 
                if(inv.Ship_To_Site__c != null){
                    atm = new AccountTeamMember(AccountId = inv.Ship_To_Site__c, UserId = inv.Territory_Rep_5__c);
                    listAccountTeamsToUpsert.add(atm);
                    mapAccountTeams.get(inv.Ship_To_Site__c).put(inv.Territory_Rep_5__c, atm);
                }
                //END                
                if(inv.Ship_To_Site__r.ParentId !=null){
                    patm1 = new AccountTeamMember(AccountId = inv.Ship_To_Site__r.ParentId, UserId = inv.Territory_Rep_5__c);
                    listAccountTeamsToUpsert.add(patm1);
                    mapAccountTeams.get(inv.Ship_To_Site__r.ParentId).put(inv.Territory_Rep_5__c, patm1);
                }
                if(inv.Bill_To_Customer__r.ParentId!= null){
                    patm2 = new AccountTeamMember(AccountId = inv.Bill_To_Customer__r.ParentId, UserId = inv.Territory_Rep_5__c);
                    listAccountTeamsToUpsert.add(patm2);
                    mapAccountTeams.get(inv.Bill_To_Customer__r.ParentId).put(inv.Territory_Rep_5__c, patm2);
                }
            }

            // Territory Rep 6
            if(inv.Territory_Rep_6__c != null) {
                setUserIdsInAccountTeams.add(inv.Territory_Rep_6__c);
                
                //START: 10/01/2013 VPandea (Innoveer): Added checks for shipTo 
                if(inv.Ship_To_Site__c != null){
                    atm = new AccountTeamMember(AccountId = inv.Ship_To_Site__c, UserId = inv.Territory_Rep_6__c);
                    listAccountTeamsToUpsert.add(atm);
                    mapAccountTeams.get(inv.Ship_To_Site__c).put(inv.Territory_Rep_6__c, atm);
                }
                //END                
                if(inv.Ship_To_Site__r.ParentId !=null){
                    patm1 = new AccountTeamMember(AccountId = inv.Ship_To_Site__r.ParentId, UserId = inv.Territory_Rep_6__c);
                    listAccountTeamsToUpsert.add(patm1);
                    mapAccountTeams.get(inv.Ship_To_Site__r.ParentId).put(inv.Territory_Rep_6__c, patm1);
                }
                if(inv.Bill_To_Customer__r.ParentId!= null){
                    patm2 = new AccountTeamMember(AccountId = inv.Bill_To_Customer__r.ParentId, UserId = inv.Territory_Rep_6__c);
                    listAccountTeamsToUpsert.add(patm2);
                    mapAccountTeams.get(inv.Bill_To_Customer__r.ParentId).put(inv.Territory_Rep_6__c, patm2);
                }
            }

            // Territory Rep 7
            if(inv.Territory_Rep_7__c != null) {
                setUserIdsInAccountTeams.add(inv.Territory_Rep_7__c);
                
                //START: 10/01/2013 VPandea (Innoveer): Added checks for shipTo 
                if(inv.Ship_To_Site__c != null){
                    atm = new AccountTeamMember(AccountId = inv.Ship_To_Site__c, UserId = inv.Territory_Rep_7__c);
                    listAccountTeamsToUpsert.add(atm);
                    mapAccountTeams.get(inv.Ship_To_Site__c).put(inv.Territory_Rep_7__c, atm);
                }
                //END                
                if(inv.Ship_To_Site__r.ParentId !=null){
                    patm1 = new AccountTeamMember(AccountId = inv.Ship_To_Site__r.ParentId, UserId = inv.Territory_Rep_7__c);
                    listAccountTeamsToUpsert.add(patm1);
                    mapAccountTeams.get(inv.Ship_To_Site__r.ParentId).put(inv.Territory_Rep_7__c, patm1);
                }
                if(inv.Bill_To_Customer__r.ParentId!= null){
                    patm2 = new AccountTeamMember(AccountId = inv.Bill_To_Customer__r.ParentId, UserId = inv.Territory_Rep_7__c);
                    listAccountTeamsToUpsert.add(patm2);
                    mapAccountTeams.get(inv.Bill_To_Customer__r.ParentId).put(inv.Territory_Rep_7__c, patm2);
                }
            }

            // Territory Rep 8
            if(inv.Territory_Rep_8__c != null) {
                setUserIdsInAccountTeams.add(inv.Territory_Rep_8__c);
                
                //START: 10/01/2013 VPandea (Innoveer): Added checks for shipTo 
                if(inv.Ship_To_Site__c != null){
                    atm = new AccountTeamMember(AccountId = inv.Ship_To_Site__c, UserId = inv.Territory_Rep_8__c);
                    listAccountTeamsToUpsert.add(atm);
                    mapAccountTeams.get(inv.Ship_To_Site__c).put(inv.Territory_Rep_8__c, atm);
                }
                //END                
                if(inv.Ship_To_Site__r.ParentId !=null){
                    patm1 = new AccountTeamMember(AccountId = inv.Ship_To_Site__r.ParentId, UserId = inv.Territory_Rep_8__c);
                    listAccountTeamsToUpsert.add(patm1);
                    mapAccountTeams.get(inv.Ship_To_Site__r.ParentId).put(inv.Territory_Rep_8__c, patm1);
                }
                if(inv.Bill_To_Customer__r.ParentId!= null){
                    patm2 = new AccountTeamMember(AccountId = inv.Bill_To_Customer__r.ParentId, UserId = inv.Territory_Rep_8__c);
                    listAccountTeamsToUpsert.add(patm2);
                    mapAccountTeams.get(inv.Bill_To_Customer__r.ParentId).put(inv.Territory_Rep_8__c, patm2);
                }
            }
            
            // START: 10/01/2013 ABaneka Innoveer Solutions
            // Adding Territory Rep 9 and 10
            // Territory Rep 9
            if(inv.Territory_Rep_9__c != null) {
                setUserIdsInAccountTeams.add(inv.Territory_Rep_9__c);
                
                //START: 10/01/2013 VPandea (Innoveer): Added checks for shipTo 
                if(inv.Ship_To_Site__c != null){
                    atm = new AccountTeamMember(AccountId = inv.Ship_To_Site__c, UserId = inv.Territory_Rep_9__c);
                    listAccountTeamsToUpsert.add(atm);
                    mapAccountTeams.get(inv.Ship_To_Site__c).put(inv.Territory_Rep_9__c, atm);
                }
                //END                
                if(inv.Ship_To_Site__r.ParentId !=null){
                    patm1 = new AccountTeamMember(AccountId = inv.Ship_To_Site__r.ParentId, UserId = inv.Territory_Rep_9__c);
                    listAccountTeamsToUpsert.add(patm1);
                    mapAccountTeams.get(inv.Ship_To_Site__r.ParentId).put(inv.Territory_Rep_9__c, patm1);
                }
                if(inv.Bill_To_Customer__r.ParentId!= null){
                    patm2 = new AccountTeamMember(AccountId = inv.Bill_To_Customer__r.ParentId, UserId = inv.Territory_Rep_9__c);
                    listAccountTeamsToUpsert.add(patm2);
                    mapAccountTeams.get(inv.Bill_To_Customer__r.ParentId).put(inv.Territory_Rep_9__c, patm2);
                }
            }
            
            // Territory Rep 10
            if(inv.Territory_Rep_10__c != null) {
                setUserIdsInAccountTeams.add(inv.Territory_Rep_10__c);
                
                //START: 10/01/2013 VPandea (Innoveer): Added checks for shipTo 
                if(inv.Ship_To_Site__c != null){
                    atm = new AccountTeamMember(AccountId = inv.Ship_To_Site__c, UserId = inv.Territory_Rep_10__c);
                    listAccountTeamsToUpsert.add(atm);
                    mapAccountTeams.get(inv.Ship_To_Site__c).put(inv.Territory_Rep_10__c, atm);
                }
                //END                
                if(inv.Ship_To_Site__r.ParentId !=null){
                    patm1 = new AccountTeamMember(AccountId = inv.Ship_To_Site__r.ParentId, UserId = inv.Territory_Rep_10__c);
                    listAccountTeamsToUpsert.add(patm1);
                    mapAccountTeams.get(inv.Ship_To_Site__r.ParentId).put(inv.Territory_Rep_10__c, patm1);
                }
                if(inv.Bill_To_Customer__r.ParentId!= null){
                    patm2 = new AccountTeamMember(AccountId = inv.Bill_To_Customer__r.ParentId, UserId = inv.Territory_Rep_10__c);
                    listAccountTeamsToUpsert.add(patm2);
                    mapAccountTeams.get(inv.Bill_To_Customer__r.ParentId).put(inv.Territory_Rep_10__c, patm2);
                }
            }
            // END: 10/01/2013 ABaneka (Innoveer)
        }

        // Build a map of the business units of the users just added to the account teams
        // Do this so that in the next step, we can use that information to add roles to account team members
        mapUsersAndBusinessUnits = new Map<Id, User>([SELECT Id, Business_Unit__c
                                                      FROM User
                                                      WHERE Id IN :setUserIdsInAccountTeams]);

        // Add roles to the account teams
        for(AccountTeamMember atm : listAccountTeamsToUpsert) {
            if(mapUsersandBusinessUnits.get(atm.UserId).Business_Unit__c !=null){
                atm.TeamMemberRole = mapUsersandBusinessUnits.get(atm.UserId).Business_Unit__c + USER_ROLE_SUFFIX;
            } else {
                atm.TeamMemberRole = USER_ROLE_SUFFIX;
            }
        }
        
        upsert listAccountTeamsToUpsert;

        // Now that the account teams are in the database, we need to modify the account sharing table
        // so the account team members have the appropriate access to associated accounts and opportunities

        // Find the AccountShare records that match account team members
        for(AccountShare a : [SELECT Id, AccountId, UserOrGroupId
                              FROM AccountShare
                              WHERE RowCause = 'Team' AND AccountId IN :setAccountIdsInAccountTeams AND
                                    UserOrGroupId IN :setUserIdsInAccountTeams]) {

            // If we find an account share that matches an account team member, modify account and
            // opportunity access
            if(mapAccountTeams.get(a.AccountId).containsKey(a.UserOrGroupId)) {
                a.AccountAccessLevel = ACCT_ACCESS_LEVEL;
                a.OpportunityAccessLevel = OPPY_ACCESS_LEVEL;
                listAccountSharesToUpdate.add(a);
            }
        }
        update listAccountSharesToUpdate;
        }
    }
    
    /* @Method Name : sortReps
     * @Description : This method is used for sorting the Territory Reps in Ascending order depending upon the OrgId stored on a user record of the Reps. 
     *                If an Invoice does not contain any Territory rep then it assigns a default owner to that invoice.
     * @Author      : Bhushan Adhikari <bhushan.adhikari@cloudsherpas.com>
     * @Date Added  : March 21 , 2013
     */
    public static void sortReps(List<Invoice__c> inv)
    {   
        if(!stopRecursion.hasAlreadyExecuted())
        {
            
            // Map to store all Invoices along with their Territorry Reps
            Map<Integer,List<InvoiceWrapper>> orgidWrappermap =  new Map<Integer,List<InvoiceWrapper>>(); 
            
            //List for upsert of Invoices 
            List<Invoice__c> invoiceListUpsert = new List<Invoice__c>();
            
            //List of Invoice Wrapper
            List<InvoiceWrapper> invoiceWrapperList = new List<InvoiceWrapper>();
            
            //looping through all invoice records
            for(Invoice__c invoice :[SELECT Id, 
                                        Dist_Region_1__c,Dist_Region_2__c,
                                        Dist_Region_3__c,Dist_Region_4__c,
                                        Dist_Region_5__c,Dist_Region_6__c,
                                        Dist_Region_7__c,Dist_Region_8__c,
                                        Dist_Region_9__c,Dist_Region_10__c,
                                        Territory_Rep_1__r.salesRep_Org_Id__c,
                                        Territory_Rep_2__r.salesRep_Org_Id__c,
                                        Territory_Rep_3__r.salesRep_Org_Id__c,
                                        Territory_Rep_4__r.salesRep_Org_Id__c,
                                        Territory_Rep_5__r.salesRep_Org_Id__c,
                                        Territory_Rep_6__r.salesRep_Org_Id__c,
                                        Territory_Rep_7__r.salesRep_Org_Id__c,
                                        Territory_Rep_8__r.salesRep_Org_Id__c,
                                        Territory_Rep_9__r.salesRep_Org_Id__c,
                                        Territory_Rep_10__r.salesRep_Org_Id__c, 
                                        Territory_Rep_1_Role__c,Territory_Rep_1__c,
                                        Territory_Rep_2_Role__c,Territory_Rep_2__c,
                                        Territory_Rep_3_Role__c,Territory_Rep_3__c,
                                        Territory_Rep_4_Role__c,Territory_Rep_4__c,
                                        Territory_Rep_5_Role__c,Territory_Rep_5__c,
                                        Territory_Rep_6_Role__c,Territory_Rep_6__c,
                                        Territory_Rep_7_Role__c,Territory_Rep_7__c,
                                        Territory_Rep_8_Role__c,Territory_Rep_8__c,
                                        Territory_Rep_9_Role__c,Territory_Rep_9__c,
                                        Territory_Rep_10_Role__c,Territory_Rep_10__c        
                                 FROM Invoice__c
                                 WHERE id IN : inv ])
            {   
                // Checking whether all Territory Rep fields are blank , if they all are blank the set the owner of the Invoice 
                // to the default owner that is specified in the Custome Setting.
                if(invoice.Territory_Rep_1__c == NULL && invoice.Territory_Rep_2__c == NULL && invoice.Territory_Rep_3__c == NULL
                                        && invoice.Territory_Rep_4__c == NULL && invoice.Territory_Rep_5__c == NULL && invoice.Territory_Rep_6__c  == NULL 
                                        && invoice.Territory_Rep_7__c == NULL && invoice.Territory_Rep_8__c == NULL && invoice.Territory_Rep_9__c == NULL 
                                        && invoice.Territory_Rep_10__c == NULL) 
                
                 {  
                    //Getting the Default Owner Id from the Custom Setting
                    List<Default_Invoice_Owner__c> defaultOwner = Default_Invoice_Owner__c.getall().values();
                    
                    // Setting the default owner
                    invoice.OwnerId = defaultOwner[0].DefaultOwnerId__c; 
                    invoiceListUpsert.add(invoice);
                 }
                 
                // Check for each of the Territory Rep fields ; if any of the Territory Rep is populated then get them along with their Role
                // and Region for sorting.
                else 
                { 
                    // Territory Rep 1
                    if(invoice.Territory_Rep_1__c != null)
                    {
                        //Saving the Territory Rep's Id, Region and Role in a wrapper 
                        InvoiceWrapper invWrapper = new InvoiceWrapper(invoice.Territory_Rep_1__c,invoice.id ,invoice.Dist_Region_1__c,invoice.Territory_Rep_1_Role__c);
                        invoiceWrapperList.add(invWrapper);
                        
                        // If Territory rep's salesRep_Org_Id__c is null or blank then we assign that rep a default salesRep_Org_Id__c value i.e 99999
                        // and filling a Map that will contain OrgId as key and the List of wrapper. This map will be used to pull ot the rep info for a 
                        // invoice depending on its org id.
                        if(invoice.Territory_Rep_1__r.salesRep_Org_Id__c == NULL){
                            if(orgidWrappermap.ContainsKey(DEFAULT_ORGID)){
                                orgidWrappermap.get(DEFAULT_ORGID).add(invWrapper);
                            }
                            else
                            {
                                orgidWrappermap.put(DEFAULT_ORGID,new List<InvoiceWrapper> {invWrapper});
                            }
                        }
                        else {
                            if(orgidWrappermap.ContainsKey(Integer.valueOf(invoice.Territory_Rep_1__r.salesRep_Org_Id__c))){
                                orgidWrappermap.get(Integer.valueOf(invoice.Territory_Rep_1__r.salesRep_Org_Id__c)).add(invWrapper);
                            }
                            else
                            {
                                orgidWrappermap.put(Integer.valueOf(invoice.Territory_Rep_1__r.salesRep_Org_Id__c),new List<InvoiceWrapper>{invWrapper});
                            }
                            
                        }
                        
                    }
                    // Territory Rep 2
                    if(invoice.Territory_Rep_2__c != null )
                    {
                        //Saving the Territory Rep's Id, Region and Role in a wrapper 
                        InvoiceWrapper invWrapper = new InvoiceWrapper(invoice.Territory_Rep_2__c,invoice.id ,invoice.Dist_Region_2__c,invoice.Territory_Rep_2_Role__c);
                        invoiceWrapperList.add(invWrapper);
                        
                        // If Territory rep's salesRep_Org_Id__c is null or blank then we assign that rep a default salesRep_Org_Id__c value i.e 99999
                        // and filling a Map that will contain OrgId as key and the List of wrapper. This map will be used to pull ot the rep info for a 
                        // invoice depending on its org id.
                        if(invoice.Territory_Rep_2__r.salesRep_Org_Id__c == NULL){
                            if(orgidWrappermap.ContainsKey(DEFAULT_ORGID)){
                                orgidWrappermap.get(DEFAULT_ORGID).add(invWrapper);
                            }
                            else
                            {
                                orgidWrappermap.put(DEFAULT_ORGID,new List<InvoiceWrapper> {invWrapper});
                            }
                        }
                        else {
                            if(orgidWrappermap.ContainsKey(Integer.valueOf(invoice.Territory_Rep_2__r.salesRep_Org_Id__c))){
                                orgidWrappermap.get(Integer.valueOf(invoice.Territory_Rep_2__r.salesRep_Org_Id__c)).add(invWrapper);
                            }
                            else
                            {
                                orgidWrappermap.put(Integer.valueOf(invoice.Territory_Rep_2__r.salesRep_Org_Id__c),new List<InvoiceWrapper>{invWrapper});
                            }
                            
                        }
                    }
                    // Territory Rep 3
                    if(invoice.get('Territory_Rep_3__c') != null)
                    {
                        //Saving the Territory Rep's Id, Region and Role in a wrapper 
                        InvoiceWrapper invWrapper = new InvoiceWrapper(invoice.Territory_Rep_3__c,invoice.id ,invoice.Dist_Region_3__c,invoice.Territory_Rep_3_Role__c);
                        invoiceWrapperList.add(invWrapper);
                        
                        // If Territory rep's salesRep_Org_Id__c is null or blank then we assign that rep a default salesRep_Org_Id__c value i.e 99999
                        // and filling a Map that will contain OrgId as key and the List of wrapper. This map will be used to pull ot the rep info for a 
                        // invoice depending on its org id.
                        if(invoice.Territory_Rep_3__r.salesRep_Org_Id__c == NULL){
                            if(orgidWrappermap.ContainsKey(DEFAULT_ORGID)){
                                orgidWrappermap.get(DEFAULT_ORGID).add(invWrapper);
                            }
                            else
                            {
                                orgidWrappermap.put(DEFAULT_ORGID,new List<InvoiceWrapper> {invWrapper});
                            }
                        }
                        else {
                            if(orgidWrappermap.ContainsKey(Integer.valueOf(invoice.Territory_Rep_3__r.salesRep_Org_Id__c))){
                                orgidWrappermap.get(Integer.valueOf(invoice.Territory_Rep_3__r.salesRep_Org_Id__c)).add(invWrapper);
                            }
                            else
                            {
                                orgidWrappermap.put(Integer.valueOf(invoice.Territory_Rep_3__r.salesRep_Org_Id__c),new List<InvoiceWrapper>{invWrapper});
                            }
                            
                        }
                    }
                    
                    //Territory Rep 4
                    if(invoice.Territory_Rep_4__c != null )
                    {
                        //Saving the Territory Rep's Id, Region and Role in a wrapper 
                        InvoiceWrapper invWrapper = new InvoiceWrapper(invoice.Territory_Rep_4__c,invoice.id ,invoice.Dist_Region_4__c,invoice.Territory_Rep_4_Role__c);
                        invoiceWrapperList.add(invWrapper);
                        
                        // If Territory rep's salesRep_Org_Id__c is null or blank then we assign that rep a default salesRep_Org_Id__c value i.e 99999
                        // and filling a Map that will contain OrgId as key and the List of wrapper. This map will be used to pull ot the rep info for a 
                        // invoice depending on its org id.
                        if(invoice.Territory_Rep_4__r.salesRep_Org_Id__c == NULL){
                            if(orgidWrappermap.ContainsKey(DEFAULT_ORGID)){
                                orgidWrappermap.get(DEFAULT_ORGID).add(invWrapper);
                            }
                            else
                            {
                                orgidWrappermap.put(DEFAULT_ORGID,new List<InvoiceWrapper> {invWrapper});
                            }
                        }
                        else {
                            if(orgidWrappermap.ContainsKey(Integer.valueOf(invoice.Territory_Rep_4__r.salesRep_Org_Id__c))){
                                orgidWrappermap.get(Integer.valueOf(invoice.Territory_Rep_4__r.salesRep_Org_Id__c)).add(invWrapper);
                            }
                            else
                            {
                                orgidWrappermap.put(Integer.valueOf(invoice.Territory_Rep_4__r.salesRep_Org_Id__c),new List<InvoiceWrapper>{invWrapper});
                            }
                            
                        }
                    }
                    
                    // Territory Rep 5
                    if(invoice.Territory_Rep_5__c != null )
                    {
                        //Saving the Territory Rep's Id, Region and Role in a wrapper 
                        InvoiceWrapper invWrapper = new InvoiceWrapper(invoice.Territory_Rep_5__c,invoice.id ,invoice.Dist_Region_5__c,invoice.Territory_Rep_5_Role__c);
                        invoiceWrapperList.add(invWrapper);
                        
                        // If Territory rep's salesRep_Org_Id__c is null or blank then we assign that rep a default salesRep_Org_Id__c value i.e 99999
                        // and filling a Map that will contain OrgId as key and the List of wrapper. This map will be used to pull ot the rep info for a 
                        // invoice depending on its org id.
                        if(invoice.Territory_Rep_5__r.salesRep_Org_Id__c == NULL){
                            if(orgidWrappermap.ContainsKey(DEFAULT_ORGID)){
                                orgidWrappermap.get(DEFAULT_ORGID).add(invWrapper);
                            }
                            else
                            {
                                orgidWrappermap.put(DEFAULT_ORGID,new List<InvoiceWrapper> {invWrapper});
                            }
                        }
                        else {
                            if(orgidWrappermap.ContainsKey(Integer.valueOf(invoice.Territory_Rep_5__r.salesRep_Org_Id__c))){
                                orgidWrappermap.get(Integer.valueOf(invoice.Territory_Rep_5__r.salesRep_Org_Id__c)).add(invWrapper);
                            }
                            else
                            {
                                orgidWrappermap.put(Integer.valueOf(invoice.Territory_Rep_5__r.salesRep_Org_Id__c),new List<InvoiceWrapper>{invWrapper});
                            }
                            
                        }
                    }
                    
                    // Territory Rep 6
                    if(invoice.Territory_Rep_6__c != null )
                    {
                        //Saving the Territory Rep's Id, Region and Role in a wrapper 
                        InvoiceWrapper invWrapper = new InvoiceWrapper(invoice.Territory_Rep_6__c,invoice.id ,invoice.Dist_Region_6__c,invoice.Territory_Rep_6_Role__c);
                        invoiceWrapperList.add(invWrapper);
                        
                        // If Territory rep's salesRep_Org_Id__c is null or blank then we assign that rep a default salesRep_Org_Id__c value i.e 99999
                        // and filling a Map that will contain OrgId as key and the List of wrapper. This map will be used to pull ot the rep info for a 
                        // invoice depending on its org id.
                        if(invoice.Territory_Rep_6__r.salesRep_Org_Id__c == NULL){
                            if(orgidWrappermap.ContainsKey(DEFAULT_ORGID)){
                                orgidWrappermap.get(DEFAULT_ORGID).add(invWrapper);
                            }
                            else
                            {
                                orgidWrappermap.put(DEFAULT_ORGID,new List<InvoiceWrapper> {invWrapper});
                            }
                        }
                        else {
                            if(orgidWrappermap.ContainsKey(Integer.valueOf(invoice.Territory_Rep_6__r.salesRep_Org_Id__c))){
                                orgidWrappermap.get(Integer.valueOf(invoice.Territory_Rep_6__r.salesRep_Org_Id__c)).add(invWrapper);
                            }
                            else
                            {
                                orgidWrappermap.put(Integer.valueOf(invoice.Territory_Rep_6__r.salesRep_Org_Id__c),new List<InvoiceWrapper>{invWrapper});
                            }
                            
                        }
                    }
                    
                    // Territory Rep 7
                    if(invoice.Territory_Rep_7__c != null )
                    {
                        //Saving the Territory Rep's Id, Region and Role in a wrapper 
                        InvoiceWrapper invWrapper = new InvoiceWrapper(invoice.Territory_Rep_7__c,invoice.id ,invoice.Dist_Region_7__c,invoice.Territory_Rep_7_Role__c);                    
                        invoiceWrapperList.add(invWrapper);
                        
                        // If Territory rep's salesRep_Org_Id__c is null or blank then we assign that rep a default salesRep_Org_Id__c value i.e 99999
                        // and filling a Map that will contain OrgId as key and the List of wrapper. This map will be used to pull ot the rep info for a 
                        // invoice depending on its org id.
                        if(invoice.Territory_Rep_7__r.salesRep_Org_Id__c == NULL){
                            if(orgidWrappermap.ContainsKey(DEFAULT_ORGID)){
                                orgidWrappermap.get(DEFAULT_ORGID).add(invWrapper);
                            }
                            else
                            {
                                orgidWrappermap.put(DEFAULT_ORGID,new List<InvoiceWrapper> {invWrapper});
                            }
                        }
                        else {
                            if(orgidWrappermap.ContainsKey(Integer.valueOf(invoice.Territory_Rep_7__r.salesRep_Org_Id__c))){
                                orgidWrappermap.get(Integer.valueOf(invoice.Territory_Rep_7__r.salesRep_Org_Id__c)).add(invWrapper);
                            }
                            else
                            {
                                orgidWrappermap.put(Integer.valueOf(invoice.Territory_Rep_7__r.salesRep_Org_Id__c),new List<InvoiceWrapper>{invWrapper});
                            }
                            
                        }
                    }
                    
                    // Territory Rep 8
                    if(invoice.Territory_Rep_8__c != null )
                    {
                        //Saving the Territory Rep's Id, Region and Role in a wrapper 
                        InvoiceWrapper invWrapper = new InvoiceWrapper(invoice.Territory_Rep_8__c,invoice.id ,invoice.Dist_Region_8__c,invoice.Territory_Rep_8_Role__c);
                        invoiceWrapperList.add(invWrapper);
                        
                        // If Territory rep's salesRep_Org_Id__c is null or blank then we assign that rep a default salesRep_Org_Id__c value i.e 99999
                        // and filling a Map that will contain OrgId as key and the List of wrapper. This map will be used to pull ot the rep info for a 
                        // invoice depending on its org id.
                        if(invoice.Territory_Rep_8__r.salesRep_Org_Id__c == NULL){
                            if(orgidWrappermap.ContainsKey(DEFAULT_ORGID)){
                                orgidWrappermap.get(DEFAULT_ORGID).add(invWrapper);
                            }
                            else
                            {
                                orgidWrappermap.put(DEFAULT_ORGID,new List<InvoiceWrapper> {invWrapper});
                            }
                        }
                        else {
                            if(orgidWrappermap.ContainsKey(Integer.valueOf(invoice.Territory_Rep_8__r.salesRep_Org_Id__c))){
                                orgidWrappermap.get(Integer.valueOf(invoice.Territory_Rep_8__r.salesRep_Org_Id__c)).add(invWrapper);
                            }
                            else
                            {
                                orgidWrappermap.put(Integer.valueOf(invoice.Territory_Rep_8__r.salesRep_Org_Id__c),new List<InvoiceWrapper>{invWrapper});
                            }
                            
                        }
                    }
                    
                    // Territory Rep 9
                    if(invoice.Territory_Rep_9__c != null )
                    {
                        //Saving the Territory Rep's Id, Region and Role in a wrapper 
                        InvoiceWrapper invWrapper = new InvoiceWrapper(invoice.Territory_Rep_9__c,invoice.id ,invoice.Dist_Region_9__c,invoice.Territory_Rep_9_Role__c);
                        invoiceWrapperList.add(invWrapper);
                        
                        // If Territory rep's salesRep_Org_Id__c is null or blank then we assign that rep a default salesRep_Org_Id__c value i.e 99999
                        // and filling a Map that will contain OrgId as key and the List of wrapper. This map will be used to pull ot the rep info for a 
                        // invoice depending on its org id.
                        if(invoice.Territory_Rep_9__r.salesRep_Org_Id__c == NULL){
                            if(orgidWrappermap.ContainsKey(DEFAULT_ORGID)){
                                orgidWrappermap.get(DEFAULT_ORGID).add(invWrapper);
                            }
                            else
                            {
                                orgidWrappermap.put(DEFAULT_ORGID,new List<InvoiceWrapper> {invWrapper});
                            }
                        }
                        else {
                            if(orgidWrappermap.ContainsKey(Integer.valueOf(invoice.Territory_Rep_9__r.salesRep_Org_Id__c))){
                                orgidWrappermap.get(Integer.valueOf(invoice.Territory_Rep_9__r.salesRep_Org_Id__c)).add(invWrapper);
                            }
                            else
                            {
                                orgidWrappermap.put(Integer.valueOf(invoice.Territory_Rep_9__r.salesRep_Org_Id__c),new List<InvoiceWrapper>{invWrapper});
                            }
                            
                        }
                    }
                    
                    // Territory Rep 10
                    if(invoice.Territory_Rep_10__c != null )
                    {
                        //Saving the Territory Rep's Id, Region and Role in a wrapper 
                        InvoiceWrapper invWrapper = new InvoiceWrapper(invoice.Territory_Rep_10__c,invoice.id ,invoice.Dist_Region_10__c,invoice.Territory_Rep_10_Role__c);
                        invoiceWrapperList.add(invWrapper);
                        
                        // If Territory rep's salesRep_Org_Id__c is null or blank then we assign that rep a default salesRep_Org_Id__c value i.e 99999
                        // and filling a Map that will contain OrgId as key and the List of wrapper. This map will be used to pull ot the rep info for a 
                        // invoice depending on its org id.
                        if(invoice.Territory_Rep_10__r.salesRep_Org_Id__c == NULL){
                            if(orgidWrappermap.ContainsKey(DEFAULT_ORGID)){
                                orgidWrappermap.get(DEFAULT_ORGID).add(invWrapper);
                            }
                            else
                            {
                                orgidWrappermap.put(DEFAULT_ORGID,new List<InvoiceWrapper> {invWrapper});
                            }
                        }
                        else {
                            if(orgidWrappermap.ContainsKey(Integer.valueOf(invoice.Territory_Rep_10__r.salesRep_Org_Id__c))){
                                orgidWrappermap.get(Integer.valueOf(invoice.Territory_Rep_10__r.salesRep_Org_Id__c)).add(invWrapper);
                            }
                            else
                            {
                                orgidWrappermap.put(Integer.valueOf(invoice.Territory_Rep_10__r.salesRep_Org_Id__c),new List<InvoiceWrapper>{invWrapper});
                            }
                            
                        }
                    } 
                    
                    // Creating a list for sorting orgIdList
                    List<Integer> orgIdList = new List<Integer>();
                    // As we have a Map that contains Org Id as keys with reps as values, we get th key set from the map
                    // add that to a List and do s sort on that list
                    orgIdList.addAll(orgidWrappermap.keySet());
                    // Sorting th org ids
                    orgIdList.sort();
                    
                    //Clearing out the existing vlaues as we will be writing the reordering
                                    invoice.Dist_Region_1__c = null;
                                    invoice.Territory_Rep_1_Role__c = null;
                                    invoice.Territory_Rep_1__c = null;
                                    
                                    invoice.Dist_Region_2__c = null;
                                    invoice.Territory_Rep_2_Role__c = null;
                                    invoice.Territory_Rep_2__c = null;
                                    
                                    invoice.Dist_Region_3__c = null;
                                    invoice.Territory_Rep_3_Role__c = null;
                                    invoice.Territory_Rep_3__c = null;
                                    
                                    invoice.Dist_Region_4__c = null;
                                    invoice.Territory_Rep_4_Role__c = null;
                                    invoice.Territory_Rep_4__c = null;
                                    
                                    invoice.Dist_Region_5__c = null;
                                    invoice.Territory_Rep_5_Role__c = null;
                                    invoice.Territory_Rep_5__c = null;
                                    
                                    invoice.Dist_Region_6__c = null;
                                    invoice.Territory_Rep_6_Role__c = null;
                                    invoice.Territory_Rep_6__c = null;
                                    
                                    invoice.Dist_Region_7__c = null;
                                    invoice.Territory_Rep_7_Role__c = null;
                                    invoice.Territory_Rep_7__c = null;
                                    
                                    invoice.Dist_Region_8__c = null;
                                    invoice.Territory_Rep_8_Role__c = null;
                                    invoice.Territory_Rep_8__c = null;
                                    
                                    invoice.Dist_Region_9__c = null;
                                    invoice.Territory_Rep_9_Role__c = null;
                                    invoice.Territory_Rep_9__c = null;
                                    
                                    invoice.Dist_Region_10__c = null;
                                    invoice.Territory_Rep_10_Role__c = null;
                                    invoice.Territory_Rep_10__c = null;
                    
                    // A masterWrapper List that will hold the info of  the rep in the sorted order
                    List<InvoiceWrapper> masterWrapperList = new List<InvoiceWrapper>();
                    
                    // Looping through the sorted Ogr ids and getting the Rep and his info from the orgidWrappermap to fill masterWrapper List      
                    for(integer j: orgIdList){              
                         masterWrapperList.addAll(orgidWrappermap.get(j));  
                        
                    }
                                      
                    //Looping through the masterWrapper list and populating the Territory Rep fields starting with first field
                        for(integer k=0; k<masterWrapperList.size(); k++){
                            if(k==0){
                                invoice.Dist_Region_1__c = masterWrapperList.get(0).territoryRepReg;
                                invoice.Territory_Rep_1_Role__c = masterWrapperList.get(0).territoryRepRole;
                                invoice.Territory_Rep_1__c = masterWrapperList.get(0).territoryRepid;
                            }
                            else if(k==1)
                            {
                                invoice.Dist_Region_2__c = masterWrapperList.get(1).territoryRepReg;
                                invoice.Territory_Rep_2_Role__c = masterWrapperList.get(1).territoryRepRole;
                                invoice.Territory_Rep_2__c = masterWrapperList.get(1).territoryRepid;
                            }
                            else if(k==2)
                            {
                                invoice.Dist_Region_3__c = masterWrapperList.get(2).territoryRepReg;
                                invoice.Territory_Rep_3_Role__c = masterWrapperList.get(2).territoryRepRole;
                                invoice.Territory_Rep_3__c = masterWrapperList.get(2).territoryRepid;
                            }
                            else if(k==3){
                                invoice.Dist_Region_4__c = masterWrapperList.get(3).territoryRepReg;
                                invoice.Territory_Rep_4_Role__c = masterWrapperList.get(3).territoryRepRole;
                                invoice.Territory_Rep_4__c = masterWrapperList.get(3).territoryRepid;
                            }
                            else if(k==4)
                            {
                                invoice.Dist_Region_5__c = masterWrapperList.get(4).territoryRepReg;
                                invoice.Territory_Rep_5_Role__c = masterWrapperList.get(4).territoryRepRole;
                                invoice.Territory_Rep_5__c = masterWrapperList.get(4).territoryRepid;
                            }
                            else if(k==5)
                            {
                                invoice.Dist_Region_6__c = masterWrapperList.get(5).territoryRepReg;
                                invoice.Territory_Rep_6_Role__c = masterWrapperList.get(5).territoryRepRole;
                                invoice.Territory_Rep_6__c = masterWrapperList.get(5).territoryRepid;
                            }
                            else if(k==6){
                                invoice.Dist_Region_7__c = masterWrapperList.get(6).territoryRepReg;
                                invoice.Territory_Rep_7_Role__c = masterWrapperList.get(6).territoryRepRole;
                                invoice.Territory_Rep_7__c = masterWrapperList.get(6).territoryRepid;
                            }
                            else if(k==7)
                            {
                                invoice.Dist_Region_8__c = masterWrapperList.get(7).territoryRepReg;
                                invoice.Territory_Rep_8_Role__c = masterWrapperList.get(7).territoryRepRole;
                                invoice.Territory_Rep_8__c = masterWrapperList.get(7).territoryRepid;
                            }
                            else if(k==8)
                            {
                                invoice.Dist_Region_9__c = masterWrapperList.get(8).territoryRepReg;
                                invoice.Territory_Rep_9_Role__c = masterWrapperList.get(8).territoryRepRole;
                                invoice.Territory_Rep_9__c = masterWrapperList.get(8).territoryRepid;
                            }
                            else if(k==9)
                            {
                                invoice.Dist_Region_10__c = masterWrapperList.get(9).territoryRepReg;
                                invoice.Territory_Rep_10_Role__c = masterWrapperList.get(9).territoryRepRole;
                                invoice.Territory_Rep_10__c = masterWrapperList.get(9).territoryRepid;
                            }
                        }//end of for
                        
                    // This will set the first rep as the owner of the current. 
                    invoice.OwnerId = masterWrapperList.get(0).territoryRepid;
                                        
                    // Adding the Invoice with all the sorted Reps to a list that we will update at the end 
                    invoiceListUpsert.add(invoice);
                    
                    //Clearing out the masterWrapperList and orgidWrappermap to process the next Invoice
                    masterWrapperList.clear();
                    orgidWrappermap.clear();
                }//Close of Else
                
            } //Close of Outer For loop 
           
            if(!invoiceListUpsert.isEmpty())
            {
                stopRecursion.setAlreadyExecutedFlag();//Setting the flag to avoid recurssion
                try{
                	update invoiceListUpsert; //To DO: put try catch after thorough testing
                }
                catch(Exception e){
                	system.debug('****Exception****'+ e);
                }
                stopRecursion.alreadyexecuted = false; //resetting the resursion flag
            }
        }// Close Flag check
    }//Close of sortRep method
}