//
//This class implements the logic of the rollup mechanism for a single account
//Used abbreviations:
// - ATRU means 'Account Team Roll-Up'
// - ATM means 'Account Team Member'
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (2-09-2013)
public class H_C_ATRU_ATMsCreator
{
	//
	//Constructors
	//
	public H_C_ATRU_ATMsCreator(Account parentAccount, Account[] childAccounts,
		H_C_AccountTeamMemberHelper atmsHelper)
	{
		this.parentAccount = parentAccount;
		this.childAccounts = childAccounts;
		this.atmsHelper = atmsHelper;
		
		this.initialize();
	}
	//
	
	//
	//Variables
	//
	private Account parentAccount;
	private Account[] childAccounts;
	private H_C_AccountTeamMemberHelper atmsHelper;
	
	private H_C_ATRU_Options options;
	//
	
	//
	//Private methods
	//
	private void initialize()
	{
		this.options = getOptionsForAccount(this.parentAccount);
	}
	
	private AccountTeamMember constructATMForParentAccount(String userId, String atmRole)
	{
		AccountTeamMember atm = new AccountTeamMember();
		atm.AccountId = this.parentAccount.Id;
		atm.UserId = userId;
		atm.TeamMemberRole = atmRole;
		
		return atm;
	}
	
	private AccountShare constructAccountShareForATM(AccountTeamMember atm)
	{
		AccountShare share = this.options.permissionsForNewATM.clone();
		share.AccountId = atm.AccountId;
		share.UserOrGroupId = atm.UserId;
		
		return share;
	}
	
	private String findRoleNameForNewATM(Participant participant)
	{
		String selectedRoleName = null;
		
		//STEP #1: try to find a role with highest priority in the passed ATMs 
		//get service map from the options
		Map<String, Integer> mapOfRolesPriorities = this.options.mapOfRolesPriorities;
		final Integer highestRolePriority = this.options.rolesForNewATMs.size();
		
		Integer selectedRolePriority = -1;
		for (AccountTeamMember atm : participant.atms)
		{
			//get priority of a role of the current ATM
			Integer currentRolePriority = mapOfRolesPriorities.get(atm.TeamMemberRole);
			//if the current role has higher priority than the previous selected one
			//then we should select the current role
			if (currentRolePriority != null)
			{
				if (currentRolePriority > selectedRolePriority)
				{
					selectedRoleName = atm.TeamMemberRole;
					selectedRolePriority = currentRolePriority;
				}
				//if a role with highest priority has been already found in ATMs list then
				//we don't need to look through other ATMs
				if (selectedRolePriority == highestRolePriority)
				{
					break;
				}
			}
		}
		
		//STEP #2: if a role has not been found at the previous step and any role
		//can be selected then we select a role of the 1st ATM in the list
		if (selectedRoleName == null && this.options.isAnyRoleAllowed)
		{
			selectedRoleName = participant.atms[0].TeamMemberRole;
		}
		
		return selectedRoleName;
	}
	
	private Participant[] extractAllParticipants()
	{
		//STEP #1: prepare service data
		//extract all ATMs of child accounts
		AccountTeamMember[] atmsOfChildAccounts = this.atmsHelper.getATMsByAccountsIds(
			H_C_AccountHelper.extractAccountsIds(this.childAccounts));
		//intialize a helper for all ATMs of child accounts
		H_C_AccountTeamMemberHelper childATMsHelper =
			H_C_AccountTeamMemberHelper.createHelperByATMsList(atmsOfChildAccounts);
		
		//extract Ids of all participants into a set
		Set<String> allParticipantsIds = new Set<String>();
		allParticipantsIds.addAll(childATMsHelper.extractUsersIds());
		
		//STEP #2: extract participants
		List<Participant> allParticipants = new Participant[0];
		for (String participantId : allParticipantsIds)
		{
			//find ATMs for a concrete user
			AccountTeamMember[] atms = childATMsHelper.getATMsByUserId(participantId);
			//create a new participant and add him into the list
			allParticipants.add(new Participant(participantId, atms));
		}
		
		return allParticipants;
	}
	
	private Participant[] applyParticipationRule(Participant[] participants)
	{
		List<Participant> filteredParticipants = new Participant[0];
		for (Participant participant : participants)
		{
			//if participation share of a current user is equal or more than the limit
			//then we take him
			Double userParticipationShare = (double)participant.atms.size() / this.childAccounts.size();
			if (userParticipationShare >= this.options.minimalParticipation)
			{
				filteredParticipants.add(participant);
			}
		}
		
		return filteredParticipants;
	}
	
	private void createNewATMsFromChildATMs(H_C_ATR_Results results)
	{
		//check that the process is possible
		if (!this.options.isProcessEnabled)
		{
			return;
		}
		
		//STEP #1: extract all participants from child accounts
		Participant[] allParticipants = extractAllParticipants();
		
		//STEP #2: apply the rule of minimal participation to filter participants
		Participant[] selectedParticipants = applyParticipationRule(allParticipants);
		
		//STEP #3: create new ATMs and their permissions
		for (Participant selectedParticipant : selectedParticipants)
		{
			String roleNameForNewATM = findRoleNameForNewATM(selectedParticipant);
			//if a role has not been found then we should not create a new ATM in
			//a parent account for the current participant
			if (String.isNotBlank(roleNameForNewATM))
			{
				AccountTeamMember newATM = constructATMForParentAccount(
					selectedParticipant.userId, roleNameForNewATM);
				results.add(newATM);
				results.add(constructAccountShareForATM(newATM));
			}
		}
	}
	//
	
	//
	//Private static methods
	//
	//the methods returns options by record type name and fills the map
	private static H_C_ATRU_Options getOptionsForAccount(Account parentAccount)
	{
		/*//get record type name by RecordTypeId of the account (we do not use
		//RecordType.Name directly, because it may be not selected from DB)
		String targetAccountRecordType = H_C_AccountRecordType.mapOfIdsAndNames.get(
			parentAccount.RecordTypeId);*/
		String targetAccountRecordType = parentAccount.RecordType.Name;
		return H_C_CustomSettings.getATRU_Options(targetAccountRecordType);
	}
	//
	
	//
	//Public methods
	//
	public H_C_ATR_Results createNewATMs()
	{
		H_C_ATR_Results results = new H_C_ATR_Results();
		this.createNewATMsFromChildATMs(results);
		if (results.isNotEmpty)
		{
			results.addUpdatedAccount(this.parentAccount);
		}
		
		return results;
	}
	//
	
	
	
	
	//
	//Data Types
	//
	private class Participant
	{
		//
		//Constructors
		//
		public Participant(String userId, AccountTeamMember[] atms)
		{
			this.userId = userId;
			this.atms = (atms != null ? atms : new AccountTeamMember[0]);
		}
		//
		
		//
		//Properties
		//
		public String userId {get; private set;}
		public AccountTeamMember[] atms {get; private set;}
		//
	}
	//
}