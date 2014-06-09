/*
*	Author: SLegostaev
*	The class for work with custom settings
*/
public with sharing class MEP_ApplicationSettings
{
	//
	//Constants
	//
	public static final String DEFAULT_MEETING_ATTENDEES = 'DEFAULT_MEETING_ATTENDEES';
	//
	
	//get string value from MEP_ApplicationSettings__c by setting name
	public static String getStringValue(String settingName) {
		try {
			MEP_ApplicationSettings__c appSetting = MEP_ApplicationSettings__c.getValues(settingName);
			return appSetting.value__c;
		} catch (Exception ex) {
			System.debug(LoggingLevel.WARN, ex);
		}
		return '';
	}
	
	//get integer value from MEP_ApplicationSettings__c by setting name
	public static Integer getIntegerValue(String settingName) {
		try {
			return Integer.valueOf(getStringValue(settingName));
		} catch (System.Typeexception e) {
			System.debug(LoggingLevel.WARN, e);
		}
		return 0;
	}
	
	//check that trigger is enable
	public static Boolean isEnableTriggers() {
		String enableTriggers = getStringValue('ENABLE_TRIGGERS');
		if (enableTriggers != '') {
			return Boolean.valueOf(enableTriggers);
		}
		return true;
	}
	
	
	//check that the site deployed on production
	public static Boolean isProduction()
	{
		try
		{
			return MEP_ApplicationMode__c.getInstance().isProduction__c;
		}
		catch (Exception ex)
		{
			System.debug(LoggingLevel.WARN, ex);
		}
		return false;
	}
	
	
	//check that the site deployed on Fidelity instance
	public static Boolean isFidelityEnvironment() {
		try {
			return MEP_ApplicationMode__c.getInstance().IsFidelityEnvironment__c;
		} catch (Exception ex) {
			System.debug(LoggingLevel.WARN, ex);
		}
		return false;
	}
	
	//get user with admin profile
	public static MEP_Admin_User__c getApplicationAdmin() {
		try {
			return MEP_Admin_User__c.getInstance();
		} catch (Exception ex) {
			System.debug(LoggingLevel.WARN, ex);
		}
		return null;
	}
	///
	///try take default org wide email address
	///
	public static OrgWideEmailAddress getDefultOrganizationEmail()
	{
		return getOrganizationEmailByStringValue('MEP_DEFAULT');
	}	
	///
	///emailName - sitting name in MEP_NOTIFICATION_EMAIL__c 
	///Take MEP_NOTIFICATION_EMAIL__c using emailName 
	///and then check OrgWideEmailAddress for existing this email 
	///if this email exist = then return, else return null
	///
	///IMPORTANT: OrgWideEmailAddress can not be filter by validate. If you try using not valid OrgWideEmailAddress you get exception.
	///	
	public static OrgWideEmailAddress getOrganizationEmailByStringValue(String emailName)
	{
		MEP_NOTIFICATION_EMAIL__c email = MEP_NOTIFICATION_EMAIL__c.getValues(emailName);
		if (email != null) {
			String queryOrgEmailId = 'Select id, Address From OrgWideEmailAddress WHERE address = \''+email.email__c+'\' limit 1';
	
			try {
				return ((OrgWideEmailAddress)MEP_SoqlUtils.performSingleResultQuery(queryOrgEmailId));
			} catch(Exception ex) {
				System.debug(LoggingLevel.WARN, ex);
			}
		} else {
			System.debug('Can not found email by ' + emailName);
		}
		return null;
	}
	///
	///Return template from MEP_ApplicationTemplates__c
	///
	/*
	public static String getTemplate(String nameTeamplate)
	{
		try {
			return MEP_ApplicationTemplates__c.getValues(nameTeamplate).Teamplate__c;
		} catch (Exception ex) {
			System.debug(LoggingLevel.WARN, ex);
		}
		return null;
	}*/
	
	//This method moved to another class 'MEP_NotificationEmailDAO': Gennadiy Pervukhin 
	/*public static String getNotificationEmail(String keyOfEmail)
	{
		String notificationEmail = null;
		try
		{
			notificationEmail = MEP_NOTIFICATION_EMAIL__c.getValues(keyOfEmail).email__c;
		}
		catch (Exception e)
		{
			System.debug(LoggingLevel.WARN, e);
		}
		return notificationEmail;
	}*/
}