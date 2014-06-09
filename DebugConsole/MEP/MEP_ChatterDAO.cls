public with sharing class MEP_ChatterDAO {
    
    private static String token = MEP_CookieManager.getCookieData(MEP_CookieManager.ACCESS_TOKEN);
    private static String instanceUrl = MEP_CookieManager.getCookieData(MEP_CookieManager.INSTANCE_URL);
    
    private static String httpExecuteJSON(String command, String params, String method) {
        try {
            return httpExecute(command, params, method, 'json').getBody();
        } catch (System.Nullpointerexception e) {
            System.debug(e);
        }
        return null;
    }
    
    private static Dom.Document httpExecuteXML(String command, String params, String method) {
        try {
            return httpExecute(command, params, method, 'xml').getBodyDocument();
        } catch (System.Nullpointerexception e) {
            System.debug(e);
        }
        return null;
    }
    
    private static HttpResponse httpExecute(String command, String params, String method, String contentType) {
    	System.debug('http execute ' + params);
        Httprequest req = new Httprequest();
        method = method.toUpperCase();
        req.setMethod(method == null ? 'POST' : method);
        
        //String token = MEP_CookieManager.getCookieData(MEP_CookieManager.ACCESS_TOKEN);
        //String instanceUrl = MEP_CookieManager.getCookieData(MEP_CookieManager.INSTANCE_URL);
        
        if (token == null || instanceUrl == null) {
            System.debug('The token or the instanceUrl is null!');
            throw new Nullpointerexception();
        }
        
        req.setHeader('Authorization', 'OAuth ' + token);
        req.setHeader('X-Chatter-Entity-Encoding', 'false');
        if (method.equals('GET')) {
            if (contentType != null 
                    && contentType == 'xml') {
                //req.setHeader('Content-Type', 'application/xml');
                command = command + '.xml';
            }
            if (params != null) {
                command = command + '?' + params;
            }
            req.setEndpoint(instanceUrl + '/services/data/v24.0' + command);
        } else {
            if (contentType != null && contentType == 'json') {
                req.setHeader('Content-Type', 'application/json');
            }
            req.setEndpoint(instanceUrl + '/services/data/v24.0' + command + '/');
            if (params != null) {
                req.setBody(params);
            }

        }
        Httpresponse resp = MEP_HttpUtils.getResponse(req);
        if (resp != null) {
            if (resp.getStatusCode() == 200 || resp.getStatusCode() == 201) {
                return resp;
            } else {
                System.debug('MEP_ChatterDAO http error' + resp.getBody());
                return resp;
            }
        }
        return null;
    }
    
    private static void fillStateFromAuthHolder(MEP_OAuthHolder authHolder)
    {
    	if (authHolder != null)
    	{
            token = authHolder.oAuthToken;
            instanceUrl = authHolder.instanceUrl;
        }
    }
    //
    
    //
    public static MEP_UserDTO getChatterUser() {
        String currentUserId = MEP_MepUserDAO.getCurrentMepUserId();
        if (currentUserId != null) {
            return new MEP_UserConverter().convertToDTO(MEP_UserDAO.getUserByMepUserId(currentUserId));
        }
        return null;
    }
    
    public static String createNewFeed(MEP_FeedDTO mepFeed) {
        //System.debug(mepFeed.toJSON());
        return httpExecuteJSON('/chatter/feeds/news/me/feed-items', mepFeed.toJSON(), 'POST');
    }
    
    public static void deleteFeedItem(String feedId) {
    	httpExecuteJSON('/chatter/feed-items/' + feedId, null, 'DELETE');
    }
    
    public static void deleteComment(String commentId) {
    	httpExecuteJSON('/chatter/comments/' + commentId, null, 'DELETE');
    }
    
    public static String createNewFeedForGroup(String groupId, MEP_FeedDTO mepFeed)
    {
    	if (!MEP_StringUtils.isNullOrEmpty(groupId))
    	{
        	return httpExecuteJSON('/chatter/feeds/record/' + groupId + '/feed-items', mepFeed.toJSON(), 'POST');
    	}
    	return null;
    }
    
    public static String createNewFeedForGroup(String groupId, MEP_FeedDTO mepFeed, MEP_OAuthHolder authHolder)
    {
    	fillStateFromAuthHolder(authHolder);
    	return createNewFeedForGroup(groupId, mepFeed);
    }
    
    public static String addNewCommentToFeed(MEP_FeedDTO comment, String feedId) {
        String url = '/chatter/feed-items/' + feedId + '/comments';
        System.debug(comment.toJSON());
        return httpExecuteJSON(url, comment.toJSON(), 'POST');
    }
    
    public static List<MEP_ChatterGroupDTO> getCurrentUserChatterGroups() {
        String uId = MEP_CookieManager.getCookieData(MEP_CookieManager.USER_ID);
        if (uId != null) {
            return getChatterUserGroups(uId);
            //return groups;
        }
        return null;
    }
    
    public static List<MEP_ChatterGroupDTO> getChatterUserGroups(String userId) {
        List<CollaborationGroupMember> groupMembers = [Select c.CollaborationGroup.Name, c.CollaborationGroup.Id, 
                c.CollaborationGroup.OwnerId From CollaborationGroupMember c where MemberId = :userId order by c.CollaborationGroup.Name asc];
        List<CollaborationGroup> groups = new List<CollaborationGroup>();
        for (CollaborationGroupMember member : groupMembers) {
            groups.add(member.CollaborationGroup);
        }
        return new MEP_ChatterGroupConverter().convertToDTO(groups);
        //return groups;
    }
    
    public static MEP_ChatterGroupDTO getChatterGroupById(String id) {
        try {
			CollaborationGroupMember groupMember = [Select c.CollaborationGroup.Name, c.CollaborationGroup.Id, 
				c.CollaborationGroup.OwnerId From CollaborationGroupMember c where c.CollaborationGroup.Id = :id limit 1];
			return new MEP_ChatterGroupConverter().convertToDTO(groupMember.CollaborationGroup);
        } catch (System.Queryexception e) {
            System.debug(e);
        }
        return null;
        //return groupMember.CollaborationGroup;
    }
    
    public static Boolean isMemberOfChatterGroup(String groupId, String chatterUserId) {
    	try {
			CollaborationGroupMember groupMember = [Select Id From CollaborationGroupMember where CollaborationGroupId = :groupId and MemberId = :chatterUserId];
			return true;
        } catch (System.Queryexception e) {
            System.debug(e);
        }
        return false;
    }
    
    public static CollaborationGroup getCollaborationGroupById(String id) {
    	try {
			CollaborationGroupMember groupMember = [Select c.CollaborationGroup.Name, c.CollaborationGroup.Id, 
				c.CollaborationGroup.OwnerId From CollaborationGroupMember c where c.CollaborationGroup.Id = :id limit 1];
			return groupMember.CollaborationGroup;
        } catch (System.Queryexception e) {
            System.debug(e);
        }
        return null;
    }
    
    public static List<User> getGroupMembers(String groupId) {
        return [select Id, Name, FirstName, LastName, Email, UserName, SmallPhotoUrl, CurrentStatus from User
            where Id IN (select MemberId from CollaborationGroupMember 
                where CollaborationGroupId = :groupId) 
                    AND Id IN (select SALESFORCE_CHATTER_USER_REFERENCE__c from MEP_USERS__c)];
        //return new MEP_UserConverter().convertToDTO(users);
        //return users;
    }
    public static List<User> getGroupMembers(List<String> idGroups)
    {
    	return [select Id, Name, FirstName, LastName, Email, UserName, SmallPhotoUrl, CurrentStatus from User
            where Id IN (select MemberId from CollaborationGroupMember 
                where CollaborationGroupId in :idGroups) 
                    AND Id IN (select SALESFORCE_CHATTER_USER_REFERENCE__c from MEP_USERS__c)]; 
    }
    
    /*not use
    //received all feed items for loggined user
    public static List<MEP_FeedDTO> getAllFeedItems() {
        Dom.Document doc = httpExecuteXML('/chatter/feeds/news/me/feed-items', null, 'GET');
        //System.debug('FEEDS +++++' + doc.toXmlString());
        return new MEP_FeedConverter().convertToDTOFromXML(doc);
    }*/
    
    //received feed items for loggined user by filter
    public static List<MEP_FeedDTO> getFeedItems(MEP_ChatterFilter filter) {
        Dom.Document doc = httpExecuteXML('/chatter/feeds/news/me/feed-items', filter.getParametersString(), 'GET');
        //System.debug('FEEDS +++++' + doc.toXmlString());
        return new MEP_FeedConverter().convertToDTOFromXML(doc);
    }
    
    //received all feed items for user groups
    public static List<MEP_FeedDTO> getGroupsFeedItems(MEP_ChatterFilter filter) {
        Dom.Document doc = httpExecuteXML('/chatter/feeds/groups/me/feed-items', filter.getParametersString(), 'GET');
        //System.debug('FEEDS +++++' + doc.toXmlString());
        return new MEP_FeedConverter().convertToDTOFromXML(doc);
    }
    
    //Get feed items for selected group by filter
    public static List<MEP_FeedDTO> getFeedItemsForGroup(String groupId, MEP_ChatterFilter filter) {
        Dom.Document doc = httpExecuteXML('/chatter/feeds/record/' + groupId + '/feed-items', filter.getParametersString(), 'GET');
        //System.debug('FEEDS FOR  GROUP +++++' + doc.toXmlString());
        //System.debug('Dom.Document doc ' + doc);
        return new MEP_FeedConverter().convertToDTOFromXML(doc);
    }
    
    //get comments for feed by feed id
    public static List<MEP_FeedDTO> getAllCommentsForFeedById(String feedId) {
        Dom.Document doc = httpExecuteXML('/chatter/feed-items/' + feedId + '/comments', null, 'GET');
        return new MEP_FeedConverter().getCommentsListFromXml(doc);
    }
    
    public static List<MEP_UserDTO> getLikesUsersForFeed(String feedId) {
        Dom.Document doc = httpExecuteXML('/chatter/feed-items/' + feedId + '/likes', null, 'GET');
        return new MEP_FeedConverter().getLikesUsersFromXml(doc);
    }
    
    
    public static String setLikeToFeed(String feedId) {
        return httpExecuteJSON('/chatter/feed-items/' + feedId + '/likes', null, 'POST');
    }
    
    public static String setUnlikeToFeed(String likeId) {
        return httpExecuteJSON('/chatter/likes/' + likeId, null, 'DELETE');
    }
    
    public static List<MEP_FeedDTO> searchFeeds(MEP_ChatterFilter filter) {
        Dom.Document doc = httpExecuteXML('/chatter/feed-items', filter.getParametersString(), 'GET');
        return new MEP_FeedConverter().convertToDTOFromXML(doc);
    }
    
    public static List<MEP_PrivateMessageDTO> getAllPrivateMessages() {
        Dom.Document doc = httpExecuteXML('/chatter/users/me/messages', null, 'GET');
        return new MEP_PrivateMessageConverter().convertToDTOFromXML(doc);
    }
    
    public static List<MEP_ConversationDTO> getAllConversations() {
    	Dom.Document doc = httpExecuteXML('/chatter/users/me/conversations', null, 'GET');
    	return new MEP_ConversationConverter().convertToDTOFromXML(doc);
    }
    
    public static void readConversationMessage(String conversationId) {
    	httpExecute('/chatter/users/me/conversations/' + conversationId + '/mark-read', 'read=true', 'POST', null);
    }
	
	public static String createConversationMessage(String newMessage) {
		return httpExecuteJSON('/chatter/users/me/messages', newMessage, 'POST');
	}    
	
	public static List<MEP_PrivateMessageDTO> searchConversationMessages(String searchString) {
		if (searchString.contains(' ')) {
			searchString = searchString.replaceAll(' ', '%20');
		}
		Dom.Document doc = httpExecuteXML('/chatter/users/me/messages', 'q=' + searchString, 'GET');
		return new MEP_PrivateMessageConverter().convertToDTOFromXML(doc);
	}

    public static List<MEP_PrivateMessageDTO> getMessageByConversationId(String conversationId) {
    	Dom.Document doc = httpExecuteXML('/chatter/users/me/conversations/' + conversationId, null, 'GET');
    	return new MEP_PrivateMessageConverter().parseConversationMessages(doc);
    }
    
    public static Integer getUnreadConversationsCount() {
        Dom.Document doc = httpExecuteXML('/chatter/users/me/conversations/unread-count', null, 'GET');
        return new MEP_PrivateMessageConverter().parseUnreadConversationCountFromXML(doc);
    }
    
    public static Integer getUnreadConversationsCount(MEP_OAuthHolder authHolder) {
        fillStateFromAuthHolder(authHolder);
        return getUnreadConversationsCount();
    }
    
    public static String removeUserFromChatterGroup(String groupId, String userId) {
        CollaborationGroupMember membership = [select Id from CollaborationGroupMember 
            where MemberId = :userId and CollaborationGroupId = :groupId];
        return httpExecuteJSON('/chatter/group-memberships/' + membership.Id, null, 'DELETE');
    }
    
    public static String addChatterUserToGroup(String groupId, String userId) {
        return httpExecute('/chatter/groups/' + groupId +  '/members', 'userId=' + userId, 'POST', null).getBody();
    }
    
    
    
    public static List<MEP_UserDTO> getAllChatterUsers() {
        Dom.Document doc = httpExecuteXML('/chatter/users', null, 'GET');
        return new MEP_UserConverter().convertToDTOFromXML(doc);
    }
    
    public static Boolean isGroupNameExist(String groupName) {
    	try {
    		CollaborationGroupMember chatterGroup = [Select c.CollaborationGroup.Name, c.CollaborationGroup.Id, 
				c.CollaborationGroup.OwnerId From CollaborationGroupMember c where c.CollaborationGroup.Name = :groupName limit 1];
			return true;
    	} catch (System.QueryException e) {
			return false;
		}
    }
    
    public static List<MEP_FeedDTO> getToMeFeeds(MEP_ChatterFilter filter) {
    	Dom.Document doc = httpExecuteXML('/chatter/feeds/to/me/feed-items', filter.getParametersString(), 'GET');
        //System.debug('FEEDS +++++' + doc.toXmlString());
        return new MEP_FeedConverter().convertToDTOFromXML(doc);
    }
    
}