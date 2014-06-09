@isTest
private class MEP_AdminControllerTests {

   @IsTest
   private static void test_getIsByBIZADMIN()
   {
        MEP_TestUtils.Autorize(MEP_RoleKey.BIZADMIN);
        MEP_AdminController controller = new MEP_AdminController();
        System.assert(controller.getIsBizadmin());
        System.assert(!controller.getIsManager());
        System.assert(!controller.getIsGateKeeper());
        System.assert(!controller.getIsSysadmin());
       
   }
   @IsTest
   private static void test_getIsByMANAGER()
   {
        MEP_TestUtils.Autorize(MEP_RoleKey.MANAGER);
        MEP_AdminController controller = new MEP_AdminController();        
        System.assert(!controller.getIsBizadmin());
        System.assert(controller.getIsManager());
        System.assert(!controller.getIsGateKeeper());    
        System.assert(!controller.getIsSysadmin());
   }
   @IsTest
   private static void test_getIsByGATEKEEPER()
   {
        MEP_TestUtils.Autorize(MEP_RoleKey.GATEKEEPER);
        MEP_AdminController controller = new MEP_AdminController();
       
        System.assert(!controller.getIsBizadmin());
        System.assert(!controller.getIsManager());
        System.assert(controller.getIsGateKeeper());
        System.assert(!controller.getIsSysadmin());
   }
   /*@IsTest
   private static void test_startCreateNightlyJobs()
   {
   		MEP_AdminController controller = new MEP_AdminController();
   		Test.startTest();
   		controller.startCreateNightlyJobs();
   		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger];
   		Test.stopTest();
   		System.assert(ct.id!=null);
   }
   @IsTest
   private static void test_startEventsArchiveJob()
   {
   		Datetime sysTime = System.now();
   	 	sysTime = sysTime.addDays(-61);
   	  	MEP_EVENTS__c event = MEP_TestUtils.createTestEvent();
   	  	event.EVENT_STATE__c = MEP_EventState.PASSED ;
   	  	event.ROLLUP_EVENT_END_DATE__c = sysTime;
   	  	MEP_SoqlUtils.performDmlOperation(MEP_DmlOperation.Updating,  event);
   	  	Integer eventPassedAfter = 30; // cast to days
   	  	String query = 'Select Count() From MEP_EVENTS__c m WHERE (m.INT_ROW_IS_ARCHIVED__c = false AND m.ROLLUP_EVENT_END_DATE__c < LAST_N_DAYS:' + eventPassedAfter + ' AND m.EVENT_STATE__c = \'Passed\') OR (m.INT_ROW_IS_ARCHIVED__c = false AND m.LastModifiedDate < LAST_N_DAYS:' + eventPassedAfter+ ' AND m.EVENT_STATE__c in (\'Draft\', \'Cancelled\', \'Channel Denied\'))';
   	  	Integer countArhive =  Database.countQuery(query);
   	  	System.debug('Count arhive:'+countArhive);
   	  	for(Integer i = 0;i<countArhive;i++)
   	  	{
	   		MEP_HttpUtils.testResponsesCollection.add(MEP_TestUtils.createAutorizeResponse());
   	  	}
   	  
   	  	Test.StartTest();
   		MEP_AdminController controller = new MEP_AdminController();   		
   		controller.startEventsArchiveJob();
   		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger];
   		Test.stopTest();
   		System.assert(ct.id!=null);   		
   		System.assert(MEP_EventDAO.getEventById(event.Id).INT_ROW_IS_ARCHIVED__c);
   }
   @IsTest
   private static void test_startBatchForMappingSfAndMepUsers()
   {
   		//SALESFORCE_CHATTER_USER_REFERENCE__c
   		MEP_USERS__c adminMepUser =  MEP_TestUtils.Autorize();
   		User adminSfUser =  MEP_TestUtils.createTestUserSalecforce();   
   		adminMepUser.SALESFORCE_CHATTER_USER_REFERENCE__c=adminSfUser.id;
   		update adminMepUser;		
   		User sfUser =  MEP_TestUtils.createTestUserSalecforce();
   		sfUser.EmployeeNumber = 'testNumber';
   		MEP_USERS__c mepUser=  MEP_TestUtils.createTestUser();
   		mepUser.CORPORATE_ID__c = sfUser.EmployeeNumber;
   		mepUser.SALESFORCE_CHATTER_USER_REFERENCE__c = null;
   		update sfUser;
   		update mepUser;
   		Test.StartTest();
   		MEP_AdminController controller = new MEP_AdminController();   		
   		controller.startBatchForMappingSfAndMepUsers();   		
   		Test.stopTest();
   		System.assert(MEP_MepUserDAO.getMepUserById(mepUser.id).SALESFORCE_CHATTER_USER_REFERENCE__c!=null);
   }*/
}