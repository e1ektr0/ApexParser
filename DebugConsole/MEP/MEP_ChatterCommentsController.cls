global with sharing class MEP_ChatterCommentsController {
        
    public MEP_FeedDTO mepFeed {get;set;}
    public String errorMessage {get; set;}
    public MEP_UserDTO chatterUser {get;set;}

    public String feedId {get;set;}
    public String commentId {get;set;}
        
    public String currentInstance {get;set;}
    public String oauthToken {get; private set;}
    public String chatterGroupId {get;set;}
        
    public MEP_ChatterCommentsController() {
        oauthToken = MEP_CookieManager.getCookieData(MEP_CookieManager.ACCESS_TOKEN);
        currentInstance = MEP_CookieManager.getCookieData(MEP_CookieManager.INSTANCE_URL);
        chatterUser = MEP_ChatterDAO.getChatterUser();
    }

    public void createComment() {
        String commentText = ApexPages.currentPage().getParameters().get('commentText');
        errorMessage = 'CreateComment method ';
        if (commentText != null && commentText.length() != 0) {
            MEP_FeedDTO commentFeed = new MEP_FeedDTO(commentText, 'Text');
            commentFeed.actor = chatterUser;
            String result = MEP_ChatterDAO.addNewCommentToFeed(commentFeed, feedId);
            commentFeed.id = MEP_JSONUtils.getTextByTokenNameFromRoot(result, 'id');
            commentFeed.body = commentFeed.body.replaceAll('\n', '<br/>');
            mepFeed.comments.add(commentFeed);
            mepFeed.commentsCount += 1;
            //showAllComments();
        }
    }
       
    public void showAllComments() {
        mepFeed.comments = MEP_ChatterDAO.getAllCommentsForFeedById(mepFeed.id);
        mepFeed.commentsCount = mepFeed.comments.size();
    }
        
        
    public void likeFeed() {
        String res = MEP_ChatterDAO.setLikeToFeed(mepFeed.id);
        mepFeed.myLikeId = MEP_JSONUtils.getTextByTokenNameFromRoot(res, 'id');
        mepFeed.totalLikes += 1;
        //mepFeed.likes = MEP_ChatterDAO.getLikesUsersForFeed(mepFeed.id);
    }
        
    public void unlikeFeed() {
        MEP_ChatterDAO.setUnlikeToFeed(mepFeed.myLikeId);
        mepFeed.myLikeId = null;
        if (mepFeed.totalLikes > 0) {
            mepFeed.totalLikes -= 1;
        }
        //mepFeed.likes = MEP_ChatterDAO.getLikesUsersForFeed(mepFeed.id);
    }
        
    public Pagereference openEventDetails() {
        if (!MEP_StringUtils.isNullOrEmpty(chatterGroupId)) {
            MEP_EVENTS__c event = MEP_EventDAO.getEventByChatterGroupId(chatterGroupId);
            if (event != null) {
                Pagereference eventDetailsPage = Page.mep_eventdetails;
                eventDetailsPage.getParameters().put('eventId', event.Id);
                return eventDetailsPage;
            }
        }
        return null;
    }
    
    public void deleteFeedItem() {
    	MEP_ChatterDAO.deleteFeedItem(feedId);
    }
    
    public void deleteComment() {
    	MEP_ChatterDAO.deleteComment(commentId);
    	for (Integer i = 0; i < mepFeed.comments.size(); i++) {
    		if (mepFeed.comments[i].id == commentId) {
    			mepFeed.comments.remove(i);
    			mepFeed.commentsCount -= 1;
    			break;
    		}
    	}
    }

}