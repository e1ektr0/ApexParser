public with sharing class MEP_CookieManager {
	
	public static final String INSTANCE_URL = 'instance_url';
	public static final String ACCESS_TOKEN = 'access_token';
	public static final String USER_ID = 'user_id';
	//old
	//public static final String USER_NAME = 'user_name';
	public static final String MEP_USER_ROLE = 'mep_user_roles';
	public static final String MEP_USER_ID = 'mep_user_id';
	
	public static void addCookieData(String cookieName, String cookieValue) {
		Cookie cookie = ApexPages.currentPage().getCookies().get(cookieName);
		cookie = new Cookie(cookieName, cookieValue, null, -1, true);
		ApexPages.currentPage().setCookies(new Cookie[]{cookie});
	}
	
	public static String getCookieData(String cookieName)
	{
		/*
		This code has been changed by Gennadiy Pervukhin on 22-08-2012. I found the problem with this
		method when we try to call it from triggers (for example, MEP_MepUserDAO.getCurrentMepUserId())
		// DLuzyanov: for debugging only (e.g. using from development console)
		if (ApexPages.currentPage() == null) {
			return null;
		}
		Cookie cookie = ApexPages.currentPage().getCookies().get(cookieName);
		if (cookie != null) {
			return cookie.getValue();
		}
		return null;
		*/
		String cookieData = null;
		try
		{
			// DLuzyanov: for debugging only (e.g. using from development console)
			if (ApexPages.currentPage() != null)
			{
				Cookie cookie = ApexPages.currentPage().getCookies().get(cookieName);
				if (cookie != null)
				{
					cookieData = cookie.getValue();
				}
			}
		}
		catch (System.VisualforceException e)
		{
			System.debug(LoggingLevel.WARN, e);
		}
		catch (Exception e)
		{
			System.debug(LoggingLevel.WARN, e);
		}
		return cookieData;
	}
	
	public static void updateCookieData(String cookieName, String cookieValue) {
		Cookie cookie = ApexPages.currentPage().getCookies().get(cookieName);
		if (cookie != null && cookie.getName().equals('mep_user_role')) {
			cookieValue += ',' + cookie.getValue();
		} 
		addCookieData(cookieName, cookieValue);	
	}
	
	public static void clearCookie() {
		ApexPages.currentPage().getCookies().remove(INSTANCE_URL);
		ApexPages.currentPage().getCookies().remove(ACCESS_TOKEN);
	 	ApexPages.currentPage().getCookies().remove(USER_ID);
	 	//old
	 	//ApexPages.currentPage().getCookies().remove(USER_NAME);
	 	ApexPages.currentPage().getCookies().remove(MEP_USER_ROLE);
	 	ApexPages.currentPage().getCookies().remove(MEP_USER_ID);
	}
	
	@isTest(SeeAllData=true)
	private static void testCookieManager() {
		String testCookie = 'mep_user_role';
		String testValue1 = 'testValue1';
		String testValue2 = 'testValue2';
		
		addCookieData(testCookie, testValue1);
		System.assertEquals(testValue1, getCookieData(testCookie));
		
		updateCookieData(testCookie, testValue2);
		System.assertEquals(testValue2 + ',' + testValue1, getCookieData(testCookie));
	}
}