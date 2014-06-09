@isTest
public with sharing class MEP_ActionPollerTest 
{
	static testMethod void test_MEP_ActionPollerProductionMode()
	{
		MEP_ApplicationMode__c appMode=  MEP_ApplicationMode__c.getInstance();
     	appMode.isProduction__c= true;
     	insert appMode;
		MEP_ActionPoller rollerTest = new MEP_ActionPoller();
		System.assertEquals(rollerTest.isProduction, true);
	}
	static testMethod void test_MEP_ActionPollerNotProductionMode()
	{
		MEP_ApplicationMode__c appMode=  MEP_ApplicationMode__c.getInstance();
     	appMode.isProduction__c= false;
     	insert appMode;
		MEP_ActionPoller rollerTest = new MEP_ActionPoller();
		System.assertEquals(rollerTest.isProduction, false);
	}
}