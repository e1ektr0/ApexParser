public with sharing class MEP_ClientType {
	public static final String EXIST_CLIENT = 'Existing Client';
	public static final String NEW_CLIENT = 'New Client';
	public static final String CONSULTANTS = 'Consultants';
	public static final String FIDELITY_INTERNAL = 'Fidelity Internal';
	public static final String OTHER = 'Other';
	
	public static final List<Selectoption> CLIENT_TYPES = new Selectoption[] {
		new Selectoption('', '---'),
		new Selectoption(EXIST_CLIENT, EXIST_CLIENT),
		new Selectoption(NEW_CLIENT, NEW_CLIENT),
		new Selectoption(CONSULTANTS, CONSULTANTS),
		new Selectoption(FIDELITY_INTERNAL, FIDELITY_INTERNAL),
		new Selectoption(OTHER, OTHER)
	};
}