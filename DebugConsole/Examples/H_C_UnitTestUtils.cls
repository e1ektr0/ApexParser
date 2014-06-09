//
//This class provides utilities for Unit tests
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (13-05-2013)
@IsTest
public class H_C_UnitTestUtils
{
    private static final Integer FIRST_NAME_MAX_LENGTH = 40;
    //
    //Private static methods
    //
    private static User getSfUser(String userName, String alias)
    {
        User[] users = [Select Id, Username, FirstName, LastName, Email, Alias, CommunityNickname,
            ProfileId, LanguageLocaleKey, EmailEncodingKey, TimeZoneSidKey, IsActive
            from User where Username = :userName OR Alias =:alias limit 1];
        if (users != null && users.size() > 0)
        {
            return users[0];
        }
        return null;
    }
    
    private static User createSfUser(String userName, String email, String alias)
    {
        User sfUser = new User();
        //sfUser.External_Id__c = String.valueOf(Math.round(2000000000 * Math.random()));
        sfUser.Employee_ID__c = String.valueOf(Math.round(2000000000 * Math.random()));
        sfUser.Business_Unit__c = 'Admin';
        sfUser.IsActive = true;
        sfUser.Username = userName;
        sfUser.FirstName = userName;
        sfUser.LastName = userName;
        sfUser.Email = email;
        sfUser.Alias = alias;
        sfUser.CommunityNickname = email;
        //profile Id is required
        sfUser.ProfileId = [select Id from Profile Where Name = 'System Administrator' limit 1].Id;
        sfUser.LocaleSidKey = 'en_US';
        sfUser.LanguageLocaleKey = 'en_US';
        sfUser.EmailEncodingKey = 'ISO-8859-1';
        sfUser.TimeZoneSidKey = 'America/New_York';
        Boolean isInsertSuccessful = H_C_SoqlUtils.tryPerformDmlOperation(
            H_C_SoqlUtils.DmlOperation.Inserting, sfUser);
        if (!isInsertSuccessful)
        {
            sfUser = null;
        }
        return sfUser;
    }
    //
    
    //
    //Public static methods
    //
    public static Account createAccount()
    {
        return createAccount('Test Account ' + DateTime.now());
    }
    
    public static Account createAccount(String accountName)
    {
        return createAccount(accountName, null);
    }
    
    public static Account createAccount(String accountName, Id parentAccountId)
    {
        Account newAccount = constructAccount(accountName, parentAccountId);
        insert newAccount;
        return newAccount;
    }
    
    public static Account constructAccount(String accountName)
    {
        return constructAccount(accountName, null);
    }
    
    public static Account constructAccount(String accountName, Id parentAccountId)
    {
        Account newAccount = new Account();
        newAccount.Name = accountName;
        newAccount.ParentId = parentAccountId;
        newAccount.BillingCountry = 'Account Billing Country';
        return newAccount;
    }
    
    public static AccountTeamMember constructAccountTeamMember(String accountId,
        String userId, String teamMemberRole)
    {
        AccountTeamMember teamMember = new AccountTeamMember();
        teamMember.AccountId = accountId;
        teamMember.UserId = userId;
        teamMember.TeamMemberRole = teamMemberRole;
        return teamMember;
    }
    
    /*public static AccountShare constructAccountShare(String accountId, String userOrGroupId)
    {
        AccountShare accountShare = new AccountShare();
        accountShare.AccountId = accountId;
        accountShare.UserOrGroupId = userOrGroupId;
        return accountShare;
    }*/
    
    public static AccountShare constructAccountShare(String accountId, String userId,
        String accountAccessLevel, String opportunityAccessLevel, String caseAccessLevel)
    {
        AccountShare share = new AccountShare();
        share.AccountId = accountId;
        share.UserOrGroupId = userId;
        share.AccountAccessLevel = accountAccessLevel;
        share.OpportunityAccessLevel = opportunityAccessLevel;
        share.CaseAccessLevel = caseAccessLevel;
        return share;
    }
    
    public static Opportunity createOpportunity(String opportunityName, String accountId)
    {
        Opportunity newOpportunity = constructOpportunity(opportunityName, accountId);
        insert newOpportunity;
        return newOpportunity;
    }
    
    public static Opportunity constructOpportunity(String opportunityName, String accountId)
    {
        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Name = (String.isBlank(opportunityName)
            ? 'new Opportunity ' + DateTime.now() : opportunityName);
        newOpportunity.StageName = 'Prospecting';
        newOpportunity.CloseDate = Date.today().addMonths(1);
        newOpportunity.AccountId = accountId;
        
        return newOpportunity;
    }
    
    public static H_C_AccountOpportunity__c createAccountOpportunityMapping(Account account,
        Opportunity opportunity)
    {
        H_C_AccountOpportunity__c newMapping = new H_C_AccountOpportunity__c();
        newMapping.Account__c = account.Id;
        newMapping.Opportunity__c = opportunity.Id;
        newMapping.Name = opportunity.Name;
        
        insert newMapping;
        return newMapping;
    }
    
    
    public static Contact createContact(String lastName, String accountId)
    {
        Contact newContact = new Contact();
        newContact.LastName = lastName;
        newContact.AccountId = accountId;
        
        insert newContact;
        return newContact;
    }
    
    public static H_C_AccountContact__c createAccountContactMapping(Account account, Contact contact)
    {
        H_C_AccountContact__c newMapping = new H_C_AccountContact__c();
        newMapping.Account__c = account.Id;
        newMapping.Contact__c = contact.Id;
        newMapping.Name = contact.Name;
        
        insert newMapping;
        return newMapping;
    }
    
    public static ERF__c createERF(String erfName, String accountId, String contactAccountId)
    {
        ERF__c erf = constructERF(erfName, accountId, contactAccountId);
        insert erf;
        return erf;
    }
    
    public static ERF__c constructERF(String erfName, String accountId, String contactAccountId)
    {
        Contact testContact = createContact('Test Contact Name', contactAccountId);
        ERF__c newErf = new ERF__c();
        newErf.Ship_To_Account__c = accountId;
        newErf.Ship_To_Contact__c = testContact.Id;
        newErf.Ship_From_Account__c = accountId;
        newErf.Ship_From_Contact__c = testContact.Id;
        
        return newErf;
    }
    
    public static H_C_AccountERF__c createErfMapping(Account account,
        ERF__c erf)
    {
        H_C_AccountERF__c newMapping = new H_C_AccountERF__c();
        newMapping.Account__c = account.Id;
        newMapping.ERF__c = erf.Id;
        newMapping.Name = erf.Name;
        
        insert newMapping;
        return newMapping;
    }
    
    
    /*public static Event createEvent(String eventName, String accountId,
        DateTime activityDateTime, Integer durationInMinutes)
    {
        Event event = constructEvent(eventName, accountId, activityDateTime, durationInMinutes);
        insert event;
        return event;
    }*/
    
    public static Event constructEvent(String eventName, String accountId,
        DateTime activityDateTime, Integer durationInMinutes)
    {
        Event event = new Event();
        event.Subject = eventName;
        event.ActivityDateTime = activityDateTime;
        event.DurationInMinutes = durationInMinutes;
        event.WhatId = accountId;
        
        return event;
    }
    
    public static Task createTask(String taskName, Date activityDate, String accountId)
    {
        Task task = constructTask(taskName, activityDate, accountId);
        insert task;
        return task;
    }
    
    public static Task constructTask(String taskName, Date activityDate, String accountId)
    {
        Task task = new Task();
        task.Subject = taskName;
        task.WhatId = accountId;
        task.ActivityDate = activityDate;
        return task;
    }
    
    public static Note createNote(String noteTitle, String parentId, String body)
    {
        Note note = constructNote(noteTitle, parentId, body);
        insert note;
        return note;
    }
    
    public static Note constructNote(String noteTitle, String parentId, String body)
    {
        Note note = new Note();
        note.Title = noteTitle;
        note.Body = body;
        note.ParentId = parentId;
        return note;
    }
    
    public static Attachment createAttachment(String attachmentName, String parentId, Blob body)
    {
        Attachment attachment = constructAttachment(attachmentName, parentId, body);
        insert attachment;
        return attachment;
    }
    
    public static Attachment constructAttachment(String attachmentName, String parentId, Blob body)
    {
        Attachment attachment = new Attachment();
        attachment.Name = attachmentName;
        attachment.ParentId = parentId;
        attachment.Body = body;
        return attachment;
    }
    
    
    
    public static User createSfUser(String nickName)
    {
        String userName = nickName + '@' + Url.getSalesforceBaseUrl().getHost();
        if(userName.length() > FIRST_NAME_MAX_LENGTH) {
            userName = userName.substring(0, FIRST_NAME_MAX_LENGTH - 1);
        }
        String alias = userName.substring(0, 8);
        String email = userName;
        User sfUser = getSfUser(userName, alias);
        if (sfUser == null)
        {
            sfUser = createSfUser(userName, email, alias);
            //we can get the following error in the previous method, because some Unit tests
            //can try to create test user at the same time:
            //System.DmlException: Insert failed. First exception on row 0; first error:
            //UNABLE_TO_LOCK_ROW, unable to obtain exclusive access to this record: [].
            //So, that's why if the insertion failed then we try reread data from the DB again.
            if (sfUser == null)
            {
                sfUser = getSfUser(userName, alias);
            }
        }
        return sfUser;
    }
    
    public static H_C_Settings__c createSetting(String settingName, String settingValue)
    {
        H_C_Settings__c setting  = new H_C_Settings__c();
        setting.Name = settingName;
        setting.Value__c = settingValue;
        insert setting;
        return setting;
    }
    //
    
    
    
    //
    //Unit tests to cover some rare cases which can't be reproduced in Unit tests exactly
    //(for example, UNABLE_TO_LOCK_ROW)
    //
    @IsTest
    private static void test_workWithSfUser()
    {
        String userName = 'h_c_tester@hc.unittest.com';
        String email = userName;
        String alias = 'h_c_test';
        
        //read -> create -> read a user
        User sfUser = getSfUser(userName, alias);
        if (sfUser == null)
        {
            User newUser = createSfUser(userName, email, alias);
            if (newUser != null)
            {
                System.assertEquals(newUser.Id, getSfUser(userName, alias).Id);
            }
        }
        
        //try to create a user with wrong parameters (1)
        System.assertEquals(null, createSfUser(null, null, null));
        
        //try to create a user with wrong parameters (2)
        System.assertEquals(null, H_C_UnitTestUtils.createSfUser(''));
    }
    //
}