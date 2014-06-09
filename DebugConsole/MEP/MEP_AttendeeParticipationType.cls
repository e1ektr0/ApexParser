//
//This class simulates enumeration
//
//Author: Gennadiy Pervukhin
public with sharing class MEP_AttendeeParticipationType
{
	//
	//Constants
	//
	public static final String IN_PERSON = 'In Person';
	public static final String CONFERENCE_CALL = 'Conference Call';
	//
	
	public static final String[] ALL_TYPES;
	
	static
	{
		ALL_TYPES = new String[]
		{
			IN_PERSON,
			CONFERENCE_CALL
		};
	}
}