public with sharing class MEP_ChatterCommentsControllerTest
{
	@isTest
	private static void test_MEP_ChatterCommentsController()
	{
		MEP_ChatterCommentsController controller = new MEP_ChatterCommentsController();
		MEP_USERS__c tmp = MEP_TestUtils.createTestUser();
		controller.chatterUser = new MEP_UserConverter().convertToDTO(tmp);
		MEP_FeedDTO mf = new MEP_FeedDTO();
		
		controller.mepFeed = mf;
		System.debug(controller.mepFeed);
		System.debug(controller.errorMessage);
		System.debug(controller.chatterUser);
		System.debug(controller.feedId);
		System.debug(controller.currentInstance);
		
		new MEP_ChatterCommentsController().createComment();
		//new MEP_ChatterCommentsController().showAllComments();
		//new MEP_ChatterCommentsController().likeFeed();
		//new MEP_ChatterCommentsController().unlikeFeed();
	}
	/*
 	static testMethod void MEP_ChatterMessagesListControllert_test_createComment()
    {
    	MEP_TestUtils.Autorize();    	
    	MEP_TestUtils.inicializeTokenAndInstanceUrl();
        MEP_ChatterCommentsController controller = new MEP_ChatterCommentsController();
        ApexPages.currentPage().getParameters().put('commentText','Text');
        controller.mepFeed = new MEP_FeedDTO();
        controller.mepFeed.comments  = new List<MEP_FeedDTO>();
        controller.createComment();
        System.assertEquals(controller.mepFeed.commentsCount,1);
        System.assertEquals(controller.mepFeed.comments.size(),1);
    }*/
}