/*
*	Author: SLegostaev
*	This is filter class for storing some data for getting of attendees from MEP_Users__c
*/
public with sharing class MEP_AttendeesFilter extends MEP_UserFilter {
	
	//id of user role from MEP_ROLES__c  
	public String roleId {get; set;}
}