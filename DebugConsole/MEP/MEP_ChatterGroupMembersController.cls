public with sharing class MEP_ChatterGroupMembersController {
   
    public String chatterGroupId {
        get; 
        set {
                chatterGroupId = value;
                //init();
        } 
    }
    
    public String currentInstance {get; private set;}
    public String oauthToken {get; private set;}
    public MEP_MepUsersFilter filter {get; private set;}
    public List<MEP_GroupMember> members {get; private set;}
    public MEP_ChatterGroupDTO currentGroup {get; private set;}
    private MEP_ChatterGroupEventManagerImpl groupManager;

        public String mepUserId {get;set;}
    public String chatterUserId {get;set;}
    
   // public Boolean isEveryone {get; set;}
    
    public MEP_ChatterGroupMembersController() {
        oauthToken = MEP_CookieManager.getCookieData(MEP_CookieManager.ACCESS_TOKEN);
        currentInstance = MEP_CookieManager.getCookieData(MEP_CookieManager.INSTANCE_URL);
        
        members = new List<MEP_GroupMember>();
        filter = new MEP_MepUsersFilter(true);
        
                //groupManager =  new MEP_ChatterGroupEventManagerImpl();


        //isEveryone = false;
    }
    
    

    public void init() {
        if (groupManager == null) {
               groupManager =  new MEP_ChatterGroupEventManagerImpl();
        }
        //get chatter group
        updateCurrentGroupInfo();
        //get group memebers
        initMembers();
    }
    
    
    
    public void assignMember() {
        if (mepUserId != null && mepUserId.length() != 0 
                && chatterUserId != null && chatterUserId.length() != 0
                        && chatterGroupId != null && chatterGroupId.length() != 0) {
            String result = groupManager.assignPerson(chatterGroupId, chatterUserId);
            if (MEP_JSONUtils.getTextByTokenName(result, 'errorCode') == null) {
                filter.excludeIDs.add(mepUserId);
                addMember();
            } else {
                MEP_MessagesManager.addInfoMessage(MEP_JSONUtils.getTextByTokenName(result, 'message'));
            }
        }
    }
    
    public void unassignMember() {
        if (mepUserId != null && mepUserId.length() != 0 
                && chatterUserId != null && chatterUserId.length() != 0
                        && chatterGroupId != null && chatterGroupId.length() != 0) {
            String result = groupManager.unassignPerson(chatterGroupId, chatterUserId);
            System.debug('unassing:' + result);
            if (MEP_JSONUtils.getTextByTokenName(result, 'errorCode') == null) {
                filter.excludeIDs.remove(mepUserId);
                removeMember();
            } else {
                MEP_MessagesManager.addInfoMessage(MEP_JSONUtils.getTextByTokenName(result, 'message'));
            }
        }
    }
    
    private void addMember() {
        if (mepUserId != null && mepUserId.length() != 0) {
                MEP_UserDTO userDTO = new MEP_UserConverter().convertToDTO(MEP_MepUserDAO.getMepUserById(mepUserId));
                members.add(new MEP_GroupMember(userDTO, MEP_UserRoleDAO.getMEPUserRoles(userDTO.Id), false));
        }
    }
    
    private void removeMember() {
        for (Integer i = 0; i < members.size(); i++) {
                if (members.get(i).user.id == mepUserId) {
                        members.remove(i);
                        break;
                }
        }
    }
    
    private void initMembers() {
        if (chatterGroupId != null && members.size() == 0 && currentGroup != null) {
                
                        //get all users that members of chatter group 
            List<MEP_UserDTO> usersDTO = new MEP_UserConverter().convertToDTO(MEP_MepUserDAO.getChatterGroupMembers(chatterGroupId));
            
                        //add user to wrapper, get user roles and check that user is the group owner                    
            for (MEP_UserDTO u : usersDTO) {
                Boolean isOwner = false;
                if (currentGroup.OwnerId == u.chatterId) {
                    isOwner = true;
                }
                members.add(new MEP_GroupMember(u, MEP_UserRoleDAO.getMEPUserRoles(u.Id), isOwner));
                filter.excludeIDs.add(u.Id);
            }
        }
    }
    
        
    private void updateCurrentGroupInfo() {
        if (chatterGroupId != null) {
            if (currentGroup == null) {
                currentGroup = MEP_ChatterDAO.getChatterGroupById(chatterGroupId);
            }
        }
        
    }
        
        public List<MEP_UserDTO> getEveryone() {
        return new MEP_UserConverter().convertToDTO(MEP_MepUserDAO.searchMepUsers(filter));
    }

}