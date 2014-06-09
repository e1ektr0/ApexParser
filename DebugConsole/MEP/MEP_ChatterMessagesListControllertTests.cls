@isTest
private class MEP_ChatterMessagesListControllertTests {
   /* static testMethod void  MEP_ChatterMessagesListControllertTests_baseFunctionsTests() {
	 	MEP_TestUtils.Autorize();    	
    	MEP_TestUtils.inicializeTokenAndInstanceUrl();
        MEP_ChatterMessagesListController controller = new MEP_ChatterMessagesListController();
        ApexPages.currentPage().getParameters().put('commentText','Text');
        MEP_FeedDTO testFeed = new MEP_FeedDTO();
        testFeed.id = 'Test';
        testFeed.comments = new List<MEP_FeedDTO>();
        controller.feeds = new List<MEP_FeedDTO>();
        controller.feeds.add(testFeed);
        ApexPages.currentPage().getParameters().put('feedIndex', '0');
        controller.createComment();
        System.assert(testFeed.comments.size()>0);
        MEP_HttpUtils.testResponsesCollection.add(MEP_TestUtils.createTestResponse(MEP_TestUtils.createTestCommentsXML()));
        controller.showAllComments();
        System.assert(controller.feeds[0].comments.size()>0);
        Integer countLike = controller.feeds[0].totalLikes;
        MEP_HttpUtils.testResponsesCollection.add(MEP_TestUtils.createTestResponse(MEP_TestUtils.createTestConversationMessagesXML()));
        controller.likeFeed();
        System.assert(controller.feeds[0].totalLikes==countLike+1);
        MEP_HttpUtils.testResponsesCollection.add(MEP_TestUtils.createTestResponse(MEP_TestUtils.createTestConversationMessagesXML()));
        controller.unlikeFeed();     
        System.assert(controller.feeds[0].totalLikes==countLike);  
    }
    static testMethod void MEP_ChatterMessagesListControllert_test_createComment()
    {
    	MEP_TestUtils.Autorize();    	
    	MEP_TestUtils.inicializeTokenAndInstanceUrl();
        MEP_ChatterMessagesListController controller = new MEP_ChatterMessagesListController();
        ApexPages.currentPage().getParameters().put('commentText','Text');
        MEP_FeedDTO testFeed = new MEP_FeedDTO();
        testFeed.id = 'Test';
        testFeed.comments = new List<MEP_FeedDTO>();
        controller.feeds = new List<MEP_FeedDTO>();
        controller.feeds.add(testFeed);
        ApexPages.currentPage().getParameters().put('feedIndex', '0');
        controller.createComment();
        System.assertEquals(testFeed.comments.size(),1);
    }*/
}