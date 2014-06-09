//
//This class encapsulates the options for the account team rollup mechanism
//Used abbreviations:
// - ATRU means 'Account Team Roll-Up'
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (26-08-2013)
public class H_C_ATRU_Options
{
	//
	//Constructors
	//
	public H_C_ATRU_Options(Double minimalParticipationInPercent, AccountShare permitsForNewATM,
		String stringOfRolesForNewATMs)
	{
		if (minimalParticipationInPercent != null)
		{
			//convert a percent value into a double number (for example, 50% into 0.5)
			this.minimalParticipation = minimalParticipationInPercent / 100;
		}
		
		this.processPermissionsForNewATM(permitsForNewATM);
		this.processRolesForNewATMs(stringOfRolesForNewATMs);
		
		this.initializeServiceInfo();
	}
	//
	
	//
	//Properties
	//
	public Double minimalParticipation {get; private set;}
	public AccountShare permissionsForNewATM {get; private set;}
	
	public String[] rolesForNewATMs {get; private set;}
	//map stores mappings between role name and its priority (0 means lowest priority)
	public Map<String, Integer> mapOfRolesPriorities {get; private set;}
	public Boolean isAnyRoleAllowed {get; private set;}
	
	public Boolean isProcessEnabled {get; private set;}
	//
	
	//
	//Private methods
	//
	private void processRolesForNewATMs(String stringOfRolesForNewATMs)
	{
		//make an assumprion that any role is not allowed for new ATMs
		this.isAnyRoleAllowed = false;
		
		//STEP #1: create a list of roles from the passed string
		this.rolesForNewATMs = new List<String>();
		if (String.isNotBlank(stringOfRolesForNewATMs))
		{
			//break the string into parts
    		String[] roles = stringOfRolesForNewATMs.split(H_C_CustomSettings.SEPARATOR_OF_ROLES);
    		for (String role : roles)
    		{
    			if (String.isNotBlank(role))
    			{
    				//trim the current role
    				role = role.trim();
    				//if role is not equal to ANY role designation then we add it in the list
    				//else we set the flag and stop the loop, because all other roles after ANY role
    				//designation are replaced by this designation 
    				if (role != H_C_CustomSettings.ANY_ROLE_NAME)
    				{
    					//add a new role in the list
    					this.rolesForNewATMs.add(role);
    				}
    				else
    				{
    					//reject initial assumption about 'isAnyRoleAllowed' flag
    					this.isAnyRoleAllowed = true;
    					break;
    				}
    			}
    		}
		}
		
		//STEP #2: create a map from the list
		this.mapOfRolesPriorities = new Map<String, Integer>();
		for (Integer indexOfRole = 0; indexOfRole < this.rolesForNewATMs.size(); indexOfRole++)
		{
			String role = this.rolesForNewATMs[indexOfRole];
			//put the role in the map
			this.mapOfRolesPriorities.put(role, this.rolesForNewATMs.size() - indexOfRole);
		}
	}
	
	private void processPermissionsForNewATM(AccountShare permitsForNewATM)
	{
		if (permitsForNewATM != null)
		{
			//initialize permissionsForNewATM and fill necessary properties only
			this.permissionsForNewATM = new AccountShare();
			this.permissionsForNewATM.AccountAccessLevel = permitsForNewATM.AccountAccessLevel;
			//it's supposed that ContactAccessLevel is controlled by parent.
			//In this case we can't set it directly via API.
			//this.permissionsForNewATM.ContactAccessLevel = permitsForNewATM.ContactAccessLevel;
			this.permissionsForNewATM.OpportunityAccessLevel = permitsForNewATM.OpportunityAccessLevel;
			this.permissionsForNewATM.CaseAccessLevel = permitsForNewATM.CaseAccessLevel;
		}
	}
	
	private void initializeServiceInfo()
	{
		this.isProcessEnabled = (this.minimalParticipation != null && this.minimalParticipation > 0
			&& this.permissionsForNewATM != null
			&& (this.rolesForNewATMs.size() > 0 || this.isAnyRoleAllowed));
	}
	//
}