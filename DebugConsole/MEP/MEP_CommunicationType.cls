public with sharing class MEP_CommunicationType {
	public static final String IN_PERSON = 'In Person';
	public static final String WEBINAR = 'Webinar';
	public static final String CONFERENCE_CALL = 'Conference Call';
	public static final String VIDEO_CONFERENCE = 'Video Conference';
	
	public static final List<Selectoption> COMMUNICATION_TYPES = new Selectoption[] {
		new Selectoption(IN_PERSON, IN_PERSON),
		new Selectoption(CONFERENCE_CALL, CONFERENCE_CALL),
		new Selectoption(WEBINAR, WEBINAR),
		new Selectoption(VIDEO_CONFERENCE, VIDEO_CONFERENCE)
	};
}