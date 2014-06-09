//
//This class encapsulates the options for the account team roll-down mechanism.
//Used abbreviations:
// - ATRD means 'Account Team Roll-Down'
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (14-10-2013)
public class H_C_ATRD_Options
{
	//
	//Constructors
	//
	public H_C_ATRD_Options(Boolean isProcessEnabled, String stringOfIgnorableTeamRoles)
	{
		this.isProcessEnabled = (isProcessEnabled != null ? isProcessEnabled : false);
		this.processIgnorableTeamRoles(stringOfIgnorableTeamRoles);
	}
	//
	
	//
	//Properties
	//
	public String[] ignorableTeamRoles {get; private set;}
	public Boolean isProcessEnabled {get; private set;}
	//
	
	//
	//Private methods
	//
	private void processIgnorableTeamRoles(String stringOfIgnorableTeamRoles)
	{
		this.ignorableTeamRoles = new List<String>();
		
    	if (!String.isBlank(stringOfIgnorableTeamRoles))
    	{
    		//parse the value and remove blank spaces
    		String[] roleNames = stringOfIgnorableTeamRoles.split(H_C_CustomSettings.SEPARATOR_OF_ROLES);
    		for (String roleName : roleNames)
    		{
    			this.ignorableTeamRoles.add(roleName.trim());
    		}
    	}
	}
	//
}