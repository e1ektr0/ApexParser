//
//This class provides utility methods for support Chatter in triggers.
//(We have no access to cookies when the code is performed in trigger, so this class can be used
//to pack up necessary data in static variables before trigger fires. Then the code from trigger
//can create MEP_OAuthHolder which is used for Chatter integration)
//
//Author: Gennadiy Pervukhin
public with sharing class MEP_ChatterInTriggersHelper
{
	//
	//Variables
	//
	private static String token;
    private static String instanceUrl;
    //
    
    //
    //Public static methods
    //
    public static void initialize()
    {
    	token = MEP_CookieManager.getCookieData(MEP_CookieManager.ACCESS_TOKEN);
    	instanceUrl = MEP_CookieManager.getCookieData(MEP_CookieManager.INSTANCE_URL);
    }
    
    public static MEP_OAuthHolder createAuthHolder()
    {
    	return (new MEP_OAuthHolder(instanceUrl, token));
    }
    //
}