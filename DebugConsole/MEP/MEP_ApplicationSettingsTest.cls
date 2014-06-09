/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class MEP_ApplicationSettingsTest {
	
	private static final String ENABLE_TRIGGERS_SETTING = 'ENABLE_TRIGGERS';
	private static final String WRONG_VALUE = '123';
	
    static testMethod void enableTriggersTest() {
    	//for null
    	System.assert(MEP_ApplicationSettings.isEnableTriggers(), 'Setting is null');
    	
    	try {
	    	MEP_ApplicationSettings__c newSetting = MEP_TestUtils.createApplicationSetting(ENABLE_TRIGGERS_SETTING, 'true');
	    	
	    	MEP_ApplicationSettings__c settings = MEP_ApplicationSettings__c.getValues(ENABLE_TRIGGERS_SETTING);
	    	try {
	    		//for true
        		String value = settings.value__c;
				System.assertEquals(Boolean.valueOf(value), MEP_ApplicationSettings.isEnableTriggers());
				
				//for false
				newSetting.value__c = 'false';
				update newSetting;
				settings = MEP_ApplicationSettings__c.getValues(ENABLE_TRIGGERS_SETTING);
				value = settings.value__c;
				System.assertEquals(Boolean.valueOf(value), MEP_ApplicationSettings.isEnableTriggers());
				
				//type exception
				newSetting.value__c = WRONG_VALUE;
				update newSetting;
				System.assertEquals(false, MEP_ApplicationSettings.isEnableTriggers());
				
        	} catch (System.Typeexception e) {
    			System.debug(LoggingLevel.WARN, e);
        		
        		//System.assert(false, e);
        	} catch (System.Nullpointerexception e1) {
        		System.debug(LoggingLevel.ERROR, e1);
        		System.assert(false, e1);
        	}
	    	
    	} catch (System.Dmlexception e2) {
    		System.debug(LoggingLevel.ERROR, e2);
    		System.assert(false, e2);
    	}
    }
}