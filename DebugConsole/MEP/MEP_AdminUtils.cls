/*
	the class for work with objects when no access to objects for a quest user.
*/
public with sharing class MEP_AdminUtils {
	
	private String adminName;
	private String adminPassword;
	
	private String token;
	private String instanceURL;
	private final String newUserProfileName;
	//private Httprequest req = new Httprequest();
	
	public MEP_AdminUtils(MEP_OAuthHolder holder) {
		if (holder != null) {
			token = holder.oAuthToken;
			instanceURL = holder.instanceUrl;
		}
 	}
	//
	public MEP_AdminUtils() {
		//getting data for connect to server for guest 
		MEP_Admin_User__c adminData = MEP_Admin_User__c.getInstance();
    	if (adminData != null) {
    		adminName = adminData.login__c;
    		if(adminData.isPasswordCrypt__c) {
    			adminPassword= EncodingUtil.base64Decode(adminData.password__c).toString();
    		} else {
				adminPassword = adminData.password__c;
    		}
    	} else {
    		throw new MEP_AuthException('Information about admin login in MEP_Admin_User__c(Custom Settings) not found!');
    	}
    	
		MEP_LoginResult res = MEP_OAuthLogin.adminLogin(adminName, adminPassword);
		System.debug(res);
		if (res != null && res.status) {
			token = MEP_JSONUtils.getTextByTokenName(res.message, 'access_token');
			instanceURL = MEP_JSONUtils.getTextByTokenName(res.message, 'instance_url');
		} else {
			throw new MEP_AuthException(res.message);
		}
	}
	
	private String httpExecute(String command, String params, String method) {
		return httpExecuteInternal('/services/data/v25.0/', command, params, method, null);
	}
	
	private String httpExecuteJSON(String command, String params, String method) {
		return httpExecuteInternal('/services/data/v25.0/', command, params, method, 'json');
	}
	
	private String httpExecuteInternal(String prefix, String command, String params, String method, String contentType) {
		//if (Test.isRunningTest()) {
		//	return 'callout from test';
		//}
		
		Httprequest req = new Httprequest();
		req.setMethod(method == null ? 'POST' : method);
		req.setHeader('Authorization', 'OAuth ' + token);
		if (MEP_CookieManager.getCookieData(MEP_CookieManager.INSTANCE_URL) != null 
			&& MEP_CookieManager.getCookieData(MEP_CookieManager.ACCESS_TOKEN) != null
				&& MEP_CookieManager.getCookieData(MEP_CookieManager.MEP_USER_ID) != null) {
			req.setHeader(MEP_CookieManager.INSTANCE_URL, MEP_CookieManager.getCookieData(MEP_CookieManager.INSTANCE_URL));
			req.setHeader(MEP_CookieManager.ACCESS_TOKEN, MEP_CookieManager.getCookieData(MEP_CookieManager.ACCESS_TOKEN));
			req.setHeader(MEP_CookieManager.MEP_USER_ID, MEP_CookieManager.getCookieData(MEP_CookieManager.MEP_USER_ID));	
		}
		
		if (method.toLowerCase().equals('get')) {
			if (params != null) {
			  req.setEndpoint(instanceUrl + prefix + command + '/' + params);
			} else {
			   req.setEndpoint(instanceUrl + prefix + command);	
			}
		} else {
			String endPoint = instanceUrl + prefix + command;
			if (command.endsWith('PATCH')) {
				req.setEndpoint(endPoint);
			} else {
				req.setEndpoint(endPoint + '/');
			}
			
			if (params != null) {
				req.setBody(params);
			}
		}
		
		if (contentType != null && contentType.equals('json')) {
			req.setHeader('Content-Type', 'application/json');
		}
		
		Httpresponse resp = MEP_HttpUtils.getResponse(req);
		if (resp != null) {
			return resp.getBody();
		}
		return 'Callout exception, see the log file';
	}
	
	public String executeQueryREST(String query) {
		return httpExecute('query' , '?q=' + convertQuery(query), 'GET');
	}
	
	//getting 
	public String getSObjectREST(String sObjectType, String sObjectId) {
		return httpExecute('sobjects/' + sObjectType, sObjectId, 'GET');
	}
	
	public String createChatterUserREST(MEP_USERS__c mepUser) {
		String result = httpExecuteJSON('sobjects/user', Json.serialize(MEP_UserDAO.createUser(mepUser)), 'POST');
		System.debug(result);
		return result;
	}
	
	/*
	private User createUser(MEP_USERS__c mepUser) {
		
		User u = new User();
		u.DigestFrequency = 'D';
		u.IsActive = true;
		if (MEP_ApplicationSettings.isFidelityEnvironment()) {
			u.Username = mepUser.CORP_EMAIL__c;
		} else {
			u.Username = Math.random() + '_' + mepUser.CORP_EMAIL__c;
		}
		u.FirstName = mepUser.FIRST_NAME__c;
		u.LastName = mepUser.LAST_NAME__c;
		u.Email = mepUser.EMAIL__c;
		//u.Alias = mepUser.SAMACCOUNTNAME__c.length() > 8 ? mepUser.SAMACCOUNTNAME__c.substring(0, 8) : mepUser.SAMACCOUNTNAME__c;
		u.Alias = mepUser.CORPORATE_ID__c;
		u.CommunityNickname = mepUser.CORPORATE_ID__c;
		if (!Test.isRunningTest())//#important - how create new profile in tests?
			u.ProfileId = getProfileByName(MEP_ApplicationSettings.getStringValue('DEFAULT_NEW_USER_PROFILE_NAME')).Id;
		u.LocaleSidKey = 'en_US';
		u.LanguageLocaleKey = 'en_US';
		u.EmailEncodingKey = 'ISO-8859-1';
		u.TimeZoneSidKey = 'America/New_York';
		u.EmployeeNumber = mepUser.CORPORATE_ID__c;
		return u;
	}*/
	
		
	public String archiveGroupForEvent(Id eventId) {
	  String result =  httpExecuteInternal('/services/apexrest/', 'eventarchival/' + eventId, null, 'GET', null);
	  System.debug('Group is ' + result);
	  return result;	  
	}
	
	private String convertQuery(String query) {
		return query.replaceAll(' ', '+').replaceAll('\'', '%27');
	}
	
	public String createChatterGroup(CollaborationGroup chatterGroup) {
		return httpExecuteJSON('sobjects/CollaborationGroup', Json.serialize(chatterGroup), 'POST');
	}
	
	public void deleteChatterGroup(String groupId) {
		httpExecute('sobjects/CollaborationGroup/' + groupId, null, 'DELETE');
	}
	
	public String addChatterUserToGroup(String groupId, String userId) {
		CollaborationGroupMember member = new CollaborationGroupMember();
		member.CollaborationGroupId = groupId;
		member.MemberId = userId;
		return addChatterUserToGroup(member);
		//return httpExecute('chatter/groups/' + groupId +  '/members', 'userId=' + userId, 'POST');
	}
	
	public String addChatterUserToGroup(CollaborationGroupMember member) {
		String result = httpExecuteJSON('sobjects/CollaborationGroupMember', Json.serialize(member), 'POST');
		return result;
	}
	
	public String removeUserFromChatterGroup(String groupId, String userId) {
		try {
			CollaborationGroupMember membership = [select Id from CollaborationGroupMember 
				where MemberId = :userId and CollaborationGroupId = :groupId];
			return httpExecuteJSON('chatter/group-memberships/' + membership.Id, null, 'DELETE');
		} catch (System.Queryexception e) {
			//member not found in chatter group	
		}
		return 'OK';
	}
	
	/*
	private Profile getProfileByName(String profileName) {
		try {
			return [select Id from Profile where Name = :profileName limit 1];
		} catch (System.Queryexception e) {
			System.debug(e);
		}
		return null;
	}*/
	
	public String updateChatterGroup(CollaborationGroup chatterGroup) {
		return httpExecuteJSON('sobjects/CollaborationGroup/' + chatterGroup.Id + '?_HttpMethod=PATCH', '{"Name" : "' + chatterGroup.Name + '"}', 'POST');
	}

}