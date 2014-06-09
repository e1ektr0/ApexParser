//
//This class provides encapsulates the results of 'Account Team Rollup' process
//Used abbreviations:
// - ATR means 'Account Team Rolling (both directions: up and down)'
// - ATM means 'Account Team Member'
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (2-09-2013)
public class H_C_ATR_Results
{
	//
	//Constructors
	//
	public H_C_ATR_Results()
	{
		this.teamMembers = new AccountTeamMember[0];
		this.accountShares = new AccountShare[0];
		this.updatedAccounts = new Account[0];
	}
	//
	
	//
	//Properties
	//
	public List<AccountTeamMember> teamMembers {get; private set;}
	public List<AccountShare> accountShares {get; private set;}
	public List<Account> updatedAccounts {get; private set;}
	
	public Boolean isNotEmpty
	{
		get
		{
			return this.teamMembers.size() > 0;
		}
	}
	//
	
	//
	//Public methods
	//
	public void add(AccountTeamMember teamMember)
	{
		if (teamMember != null)
		{
			this.teamMembers.add(teamMember);
		}
	}
	
	public void add(AccountShare accountShare)
	{
		if (accountShare != null)
		{
			this.accountShares.add(accountShare);
		}
	}
	
	public void addUpdatedAccount(Account updatedAccount)
	{
		if (updatedAccount != null)
		{
			this.updatedAccounts.add(updatedAccount);
		}
	}
	
	public void joinResults(H_C_ATR_Results newResults)
	{
		if (newResults != null && newResults.isNotEmpty)
		{
			this.teamMembers.addAll(newResults.teamMembers);
			this.accountShares.addAll(newResults.accountShares);
			this.updatedAccounts.addAll(newResults.updatedAccounts);
		}
	}
	
	public void insertObjectsInDB()
	{
		//perform 1 DML operation to insert all team members in DB
		if (this.teamMembers.size() > 0)
		{
	    	Boolean teamMembersInserted = H_C_SoqlUtils.tryPerformDmlOperation(
	    		H_C_SoqlUtils.DmlOperation.Inserting, this.teamMembers);
	    	
	    	//perform 1 DML operation to insert all shares for team members in DB
	        if (teamMembersInserted && this.accountShares.size() > 0)
	        {
	        	Database.DMLOptions dmlOptions = new Database.DMLOptions();
	        	//sometimes DML exception can occur because of SF rules and rules of an
	        	//organization (for example, when we try to restrict access to an object for an owner
	        	//of this object). In this case, we should simply ignore such moments and insert
	        	//only those permissions which are allowed. That's why we use 'optAllOrNone' flag here
	        	dmlOptions.optAllOrNone = false;
	        	H_C_SoqlUtils.performDmlOperation(H_C_SoqlUtils.DmlOperation.Inserting,
	        		this.accountShares, dmlOptions);
		        /*H_C_SoqlUtils.tryPerformDmlOperation(
		        	H_C_SoqlUtils.DmlOperation.Inserting, this.accountShares);*/
	        }
		}
	}
	//
}