public with sharing class MEP_ChatterMessagesListController {
        

    public String currentInstance {get; set;}
    public String errorMessage {get; set;}
    
    public List<MEP_ChatterGroupDTO> chatterGroups {get; set;}
    public MEP_ChatterGroupDTO chatterGroup {
        get; //{
            //if (chatterGroupId != null && chatterGroupId != 'all') {
            //    return MEP_ChatterDAO.getChatterGroupById(chatterGroupId);
            //}
            //return null;
        //}
        
        private set {
                
                if (chatterGroup == null && chatterGroupId != null && chatterGroupId != 'all') {
                        chatterGroup = MEP_ChatterDAO.getChatterGroupById(chatterGroupId);
                }
        }
    }

    public String feedText {get; set;}
    public String searchText {get;set;}
    public String chatterGroupId {
        get;
        set {
            if (value != null && value.length() != 0) {
                chatterGroupId = value;
            } else {
                chatterGroupId = null;
            }
        }
    }
        public Boolean toMeMode {get;set;}
    public String sortBy {get;set;}
    
    public List<MEP_FeedDTO> feeds {get; set;}

    private MEP_FeedsDataProviderImpl dp;
    
    public String oauthToken {get; private set;}
    public MEP_UserDTO chatterUser {get;set;}
    public Boolean isCurrentGroupMember {get; private set;}
    
    public MEP_ChatterMessagesListController() {
        currentInstance = MEP_CookieManager.getCookieData(MEP_CookieManager.INSTANCE_URL);
        if (chatterGroups == null) {
            chatterGroups = MEP_ChatterDAO.getCurrentUserChatterGroups();
        }

        dp = new MEP_FeedsDataProviderImpl();
        oauthToken = MEP_CookieManager.getCookieData(MEP_CookieManager.ACCESS_TOKEN);
        chatterUser = MEP_ChatterDAO.getChatterUser();
        initMembershipOfCurrentUser();
        feeds = new List<MEP_FeedDTO>();
    }
    
    public Pagereference share() {
        if (chatterGroupId != null && chatterGroupId != 'all') {
            MEP_ChatterDAO.createNewFeedForGroup(chatterGroupId, MEP_ChatterFeedUtils.createMepFeed(feedText));
            dp.chatterGroupId = chatterGroupId;
        } else {
            MEP_ChatterDAO.createNewFeed(MEP_ChatterFeedUtils.createMepFeed(feedText));
        }
        dp.filter.initPageSize();
        feedText = null;
        searchText = null;
        feeds.clear();
        updateFeeds();
        return null;
    }
        
    public Pagereference lazyLoadFeeds() {
        dp.filter.nextPage = feeds.get(feeds.size() - 1).nextPage;
        //temp solution
        try {
            feeds.addAll(dp.getDataList());
         } catch (System.Nullpointerexception e) {
            System.debug(e);
        }
        return null;
    }
    
    public PageReference sortingFeeds() {
        dp.filter.initPageSize();
        if (sortBy != null) {
            dp.filter.sortBy = sortBy;
        }
        updateFeeds();
        return null;
    }
    
    public PageReference searchFeeds() {
        try {
            dp.filter.searchText = searchText;
            updateFeeds();
        } catch (System.Nullpointerexception e) {
            System.debug(e);
            feeds = null;
            errorMessage = 'Feeds not found by searchText: ' + searchText;
        }
        
        return null;
    }
    
    public PageReference updateFeedsList() {
        dp.filter.searchText = null;
                dp.toMeMode = toMeMode;
        dp.chatterGroupId = chatterGroupId;
        dp.filter.initPageSize();
        if (sortBy != null) {
            dp.filter.sortBy = sortBy;
        }
        
        updateFeeds();
        return null;
    }
    
     
    private void updateFeeds() {
        try {
            feeds = dp.getDataList();
         } catch (System.Nullpointerexception e) {
            System.debug(e);
        }
    }
    
    private void initMembershipOfCurrentUser() {
        if (chatterGroups != null) {
            for (MEP_ChatterGroupDTO chatterGroup : chatterGroups) {
                if (chatterGroup.id == chatterGroupId) {
                    isCurrentGroupMember = true;
                    return;
                }
            }
        } else {
            isCurrentGroupMember = false;
        }
    }
    
   
    @RemoteAction
    public static List<MEP_UserDTO> getUsersByName(String partialName) {
        return new MEP_UserConverter().convertToDTO(MEP_MepUserDAO.getMepUsersByPartialNameForChatter(partialName));
    }
    
   
   
}