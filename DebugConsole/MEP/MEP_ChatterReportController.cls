public with sharing class MEP_ChatterReportController {

    public String generateResult { get; set; }
    public String password { get; set; }
    public String username { get; set; }
	public Boolean hasAccess { get; set; }
    public String usersList { get; set; }
	public String toDate { get; set; }
	public String fromDate { get; set; }
	
	
	private final String clientId = MEP_Client_Security__c.getInstance().client_id__c;
	private final String clientSecret = MEP_Client_Security__c.getInstance().client_secret__c;
	private final String tokenUrl = MEP_OAuth__c.getInstance().token_url__c;
    private Map<String, MEP_FeedItemWrapper> feedsMap = new Map<String, MEP_FeedItemWrapper>();
     
    public MEP_ChatterReportController() {
        hasAccess = false;
    }
    
    

    public void login() {
    	//if (username == null || username.length() == 0 || password == null || password.length() == 0) {
    	//	Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'username or password is empty.'));
    	//	System.debug(LoggingLevel.INFO, 'username or password is empty.');
    	//} else {
	    	if (clientId != null && clientSecret != null && tokenUrl != null) {
	    		Httprequest req = new Httprequest();
		    	req.setMethod('POST');
		    	String params = 'grant_type=password&client_id='+clientId+'&client_secret='
		    		+clientSecret+'&username='+username+'&password='+password+'&format=json';	
		    	req.setBody(params);
		    	req.setEndpoint(tokenUrl);
		    	try {
			    	Http h = new Http();
			    	Httpresponse resp = h.send(req);
					if (resp != null) {
						if (resp.getStatusCode() == 200 && isAdmin(username)) {
							hasAccess = true;
							initChatterUsersFilter();
						} else {
							Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, resp.getBody()));
							System.debug(LoggingLevel.INFO, resp.getBody());
						}
					}
		    	} catch (Exception e) {
		    		System.debug(LoggingLevel.ERROR, e);
		    		Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.getMessage()));
		    	}
	    	} else {
	    		Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Some custom setting is null.'));
	    		System.debug(LoggingLevel.ERROR, 'Some custom setting is null: clientId = ' + clientId + ', clientSecret = ' 
	    			+ clientSecret + ', tokenUrl = ' + tokenUrl);
	    	}
    	//}
    }

	public void generateReport() {
		if (toDate == null || toDate.length() == 0) {
			toDate = Datetime.now().formatGmt('MM/dd/yyyy');	
		}
		String[] numbers = usersList.split(',');
		if (numbers == null || numbers.size() == 0) {
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Users filter is empty'));
			return;
		}
		try {
			User[] mepUsers = [select Id from User where EmployeeNumber IN :numbers];
			List<String> ids = new List<String>();
			
			for (User mepUser : mepUsers) {
				ids.add(mepUser.id);
			}
			
			Date fromDateConverted = parseDate(fromDate);
			Date toDateConverted = parseDate(toDate);
			if (fromDateConverted != null && toDateConverted != null && ids.size() != 0) {
			
				FeedItem[] feedItems = [select Id, Body, ContentFileName, InsertedBy.Name, CreatedDate From FeedItem where Type IN ('TextPost', 'Content Post') 
										AND DAY_ONLY(CreatedDate) >= :fromDateConverted AND DAY_ONLY(CreatedDate) <= :toDateConverted
											AND InsertedById IN :ids];
				System.debug(feedItems);
				
				List<String> feedsIds = new List<String>();
				for (FeedItem feedItem : feedItems) {
					feedsMap.put(feedItem.Id, new MEP_FeedItemWrapper(feedItem));
					feedsIds.add(feedItem.Id);
				}
				
				FeedComment[] feedsComments = [Select Id, FeedItemId, CommentType, CommentBody, InsertedBy.Name, CreatedDate From FeedComment where FeedItemId IN :feedsIds];
				
				for (FeedComment comment : feedsComments) {
					MEP_FeedItemWrapper wrapper = feedsMap.get(comment.FeedItemId);
					if (wrapper != null) {
						wrapper.addComment(comment);
					}
				}
				
				System.debug(feedsMap);
				
			}
			
										//
			//generateResult = 'result size ' + feedItems.size();
		} catch (Exception e) {
			System.debug(LoggingLevel.ERROR, e);
			
		}
		//generateResult = ' ' + feedItems;
    }
    
	private Boolean isAdmin(String username) {
		try {
			User u = [select Profile.Name from User where Username = :username];
			if (u.Profile.Name == 'System Administrator') {
				return true;
			}
		} catch (System.Queryexception e) {
			System.debug(LoggingLevel.WARN, e);
		}
		return false;
	}
	
	private void initChatterUsersFilter() {
		User[] users = [select Id, EmployeeNumber From User where EmployeeNumber != null];
		for (Integer i = 0; i < users.size(); i++) {
			if (i == 0) {
				usersList = users[i].EmployeeNumber;
			} else {
				usersList += ',' + users[i].EmployeeNumber;
			}
		}
	}
	
	private Date parseDate(String simpleDate) {
        String[] mdy = simpleDate.split('/');
        if (mdy.size() == 3) {
            return Date.newInstance(Integer.valueOf(mdy[2].length() == 2 ? '20' + mdy[2] : mdy[2]),
                Integer.valueOf(mdy[0]), Integer.valueOf(mdy[1]));
        }
        return null;
    }
    
    class MEP_FeedItemWrapper{
    	private FeedItem feedItem;
    	private FeedComment[] comments = new List<FeedComment>();
    	
    	public MEP_FeedItemWrapper(FeedItem feedItem) {
    		this.feedItem = feedItem;
    	}
    	
    	public void addComment(FeedComment commet) {
    		comments.add(commet);
    	}
    }
}