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
private class MEP_ChatterUtilsTest {
	
	private static final String testEventNameMore40Symbols = 'PWI Investment Services Fidelity Real Estate Income Annual Due Diligence Meeting';
	private static final String testEventNameMore40Symbols2 = 'PWIInvestmentServicesFidelityRealEstateIncomeAnnualDueDiligenceMeeting';
	private static final String testEventNameLess40Symbols = 'PWI Investment Services Fidelity Real';

	static testMethod void testGenerateChatterGroupName() {
    	//test for event name that more then 40 symbols
        String result1 = MEP_ChatterUtils.generateChatterGroupName(testEventNameMore40Symbols);
        System.debug(result1.length() <= 40);
        
        //test for event name without spaces
        String result2 = MEP_ChatterUtils.generateChatterGroupName(testEventNameMore40Symbols2);
        System.debug(result2.length() == 40);
        
        //test for event name that less then 40 symbols
        String result3 = MEP_ChatterUtils.generateChatterGroupName(testEventNameLess40Symbols);
        System.debug(result3.length() <= 40);
        System.assertEquals(testEventNameLess40Symbols, result3);
    }

}