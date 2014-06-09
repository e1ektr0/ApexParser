//
//This class implements the logic of the rollup mechanism for a single account
//Used abbreviations:
// - ATRD means 'Account Team Roll-Down'
// - ATM means 'Account Team Member'
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (16-10-2013)
public without sharing class H_C_ATRD_ATMsCreator
{
	//
	//Constructors
	//
	public H_C_ATRD_ATMsCreator(AccountTeamMember[] parentAccountATMs,
		H_C_AccountShareHelper parentAccountsSharesHelper,
		Account[] childAccounts, H_C_AccountTeamMemberHelper childAccountsATMsHelper)
	{
		this.parentAccountATMs = parentAccountATMs;
		this.parentAccountsSharesHelper = parentAccountsSharesHelper;
		
		this.childAccounts = childAccounts;
		this.childAccountsATMsHelper = childAccountsATMsHelper;
	}
	//
	
	//
	//Variables
	//
	private AccountTeamMember[] parentAccountATMs;
	private H_C_AccountShareHelper parentAccountsSharesHelper;
	private Account[] childAccounts;
	private H_C_AccountTeamMemberHelper childAccountsATMsHelper;
	//
	
	//
	//Private methods
	//
	private void createNewATMsFromParentATMs(H_C_ATR_Results results)
	{
		//the method looks through all ATMs of a parent account. So, it takes a concrete
		//parent ATM and then looks through all child accounts to identify those of them which
		//doesn't have a team member for the same user as a parent ATM belong to. If the code
		//finds that child account doesn't have ATM for this user then it creates a new ATM
		//for a child account and a new set of permissions for a new ATM.
		
		Map<String, Account> updatedChildAccounts = new Map<String, Account>();
		
		for (AccountTeamMember parentATM : this.parentAccountATMs)
		{
			for (Account childAccount : this.childAccounts)
			{
				//try to find ATM for the same user in the current child account
				AccountTeamMember existingChildATM = childAccountsATMsHelper.getATMByAccountIdAndUserId(
					childAccount.Id, parentATM.UserId);
				//the code creates a new ATM only if he doesn't yet exist
				if (existingChildATM == null)
				{
					//1) create a new ATM for the current child account and add him into the results
					AccountTeamMember newChildATM = cloneATMForAccount(parentATM, childAccount);
					results.add(newChildATM);
					
					//2) try to find account share for parentATM and recreate the same share
					//for a new child ATM
					AccountShare shareOfParentATM = this.parentAccountsSharesHelper
						.getShareByAccountIdAndUserId(parentATM.AccountId, parentATM.UserId);
					if (shareOfParentATM != null)
					{
						results.add(cloneAccountShareForATM(shareOfParentATM, newChildATM));
					}
					
					//3) mark the current child account as an updated account
					updatedChildAccounts.put(childAccount.Id, childAccount);
				}
			}
		}
		
		//add the list of updated account into the results
		results.updatedAccounts.addAll(updatedChildAccounts.values());
	}
	//
	
	//
	//Private static methods
	//
	private static AccountTeamMember cloneATMForAccount(AccountTeamMember sourceAtm,
		Account targetAccount)
	{
		AccountTeamMember newATM = sourceAtm.clone(false);
		newATM.AccountId = targetAccount.Id;
		return newATM;
	}
	
	private static AccountShare cloneAccountShareForATM(AccountShare sourceShare,
		AccountTeamMember targetATM)
	{
		AccountShare newShare = sourceShare.clone(false);
		newShare.AccountId = targetATM.AccountId;
		newShare.UserOrGroupId = targetATM.UserId;
		return newShare;
	}
	//
	
	//
	//Public methods
	//
	public H_C_ATR_Results createNewATMs()
	{
		H_C_ATR_Results results = new H_C_ATR_Results();
		this.createNewATMsFromParentATMs(results);
		
		return results;
	}
	//
}