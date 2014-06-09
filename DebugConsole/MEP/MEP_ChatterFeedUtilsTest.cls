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
private class MEP_ChatterFeedUtilsTest {
	
	private static final String testTextFeed = 'test text';
	private static final String testTextFeedWithSegment = 'test text @[test user name] test text';
	
    static testMethod void testCreateSimpleMepFeed() {
    	MEP_FeedDTO testFeed = MEP_ChatterFeedUtils.createMepFeed(testTextFeed);
    	System.assert(testFeed != null);
    	System.assertEquals('Text', testFeed.type);
    	System.assertEquals(testTextFeed, testFeed.Body);
    }
    
    static testMethod void testCreateMepFeedWithSegments() {
    	MEP_FeedDTO testFeed = MEP_ChatterFeedUtils.createMepFeed(testTextFeedWithSegment);
    	System.assert(testFeed != null);
    	System.assert(testFeed.messageSegment != null);
    	
		MEP_MessageSegmentDTO[] testSegments = testFeed.messageSegment;
    	System.assert(testSegments.size() == 3);
    	
    	
		System.assertEquals(testTextFeed, testSegments[0].text.trim());
		System.assertEquals('text', testSegments[0].type);
		
		System.assertEquals('@[test user name]', testSegments[1].text.trim());
		System.assertEquals('text', testSegments[1].type);
		
		System.assertEquals(testTextFeed, testSegments[2].text.trim());
		System.assertEquals('text', testSegments[2].type);

    }
}