//
//This class provides utilities for working with hierarchy of accounts 
//
//Author: CERVELLO INC - Anil Tumati / Gennadiy Pervukhin (14-05-2013)
public without sharing class H_C_AccountHierarchyCreationUtils
{
    //
    //Private static methods
    //
    //the method simply clones accounts and returns a new array with cloned accounts
    private static Account[] cloneAccounts(Account[] sourceAccounts)
    {
        List<Account> clonedAccounts = new List<Account>();
        //iterate through all accounts
        for (Account sourceAccount : sourceAccounts)
        {
            //create deep copy of the current account
            clonedAccounts.add(sourceAccount.clone(true, true, true, true));
        }
        //return a new array with cloned accounts 
        return clonedAccounts;
    }
    
    
    //it's supposed that updatedAccounts have the same record type 
    private static Account[] selectAccountsWithUpdatedExternalParentId(Account[] updatedAccounts,
        Map<Id, Account> oldAccounts, String recordTypeName)
    {
        //get field name where external parent Id is stored for the current record type
        String selectedFieldName =
        	H_C_AccountDAO.getMapOfFieldsForExternalParentIds().get(recordTypeName);
        //if it's impossible to get such field then nothing can be selected
        if (selectedFieldName == null)
        {
        	//return empty array
            return new Account[0];
        }
        
        //extract external parent Ids of accounts with a particular record type 
        List<Account> selectedAccounts = new List<Account>();
        //iterate through all updated accounts
        for (Account updatedAccount : updatedAccounts)
        {
        	//get old version for the current account  
            Account oldAccount = oldAccounts.get(updatedAccount.Id);
            if (oldAccount != null)
            {
                //extract parental reference from new version of the account
                String newExternalParentId = String.valueOf(
                	H_C_sObjectUtils.getFieldValue(updatedAccount, selectedFieldName));
                //extract parental reference from old version of the account
                String oldExternalParentId = String.valueOf(
                	H_C_sObjectUtils.getFieldValue(oldAccount, selectedFieldName));
                //compare 2 values
                if (newExternalParentId != oldExternalParentId)
                {
                	//if reference to an external parent is changed then select the account 
                    selectedAccounts.add(updatedAccount);
                }
            }
        }
        
        //return selected accounts
        return selectedAccounts;
    }
    
    //it's supposed that this method gets accounts with the same record type 
    private static String[] extractExternalParentIds(Account[] accounts, String recordTypeName)
    {
        //get field name where external parent Id is stored for the current record type
        String selectedFieldName =
        	H_C_AccountDAO.getMapOfFieldsForExternalParentIds().get(recordTypeName);
        //if it's impossible to get such field then nothing can be extracted
        if (selectedFieldName == null)
        {
        	//return empty array
            return new String[0];
        }
        
        //extract external parent Ids of accounts with a particular record type 
        Set<String> setOfExternalParentIds = new Set<String>();
        //iterate through all accounts
        for (Account account : accounts)
        {
            //extract reference to an external parent and put it into the result set
            String externalParentId = String.valueOf(
                H_C_sObjectUtils.getFieldValue(account, selectedFieldName));
            if (externalParentId != null)
            {
                setOfExternalParentIds.add(externalParentId);
            }
        }
        
        //convert the result set into the list
        List<String> listOfExternalParentIds = new List<String>();
        listOfExternalParentIds.addAll(setOfExternalParentIds);
        //return list of external parent Ids
        return listOfExternalParentIds;
    }
    
    //it's supposed that this method gets accounts with the same record type.
    //This method fills standard salesforce field with a reference to a parent account 
    private static void setSfParents(Account[] accounts, H_C_AccountHelper parentAccountsHelper,
        String recordTypeName, Account[] ref_updatedAccounts)
    {
        //get field name where external parent Id is stored for the current record type
        String selectedFieldName =
        	H_C_AccountDAO.getMapOfFieldsForExternalParentIds().get(recordTypeName);
        //if it's impossible to get such field then nothing can be done
        if (selectedFieldName == null)
        {
        	//stop the method
            return;
        }
        
        //iterate through all accounts
        for (Account account : accounts)
        {
        	 System.Debug('setSfParents:Account=' + account.Name);
            //get external parent Id from the current account
            String externalParentId = String.valueOf(
                H_C_sObjectUtils.getFieldValue(account, selectedFieldName));
            //try to get parent account by external Id
            Account parentAccount = parentAccountsHelper.getAccountByExternalId(externalParentId);
            
            //if parent account doesn't exist then we clear the reference to a parent
            //account.ParentId = (parentAccount != null ? parentAccount.Id : null);
            if (parentAccount != null) {
            	account.ParentId = parentAccount.Id;
            	System.Debug('setSfParents:Parent=' + parentAccount.Id);
            }
            else
            {
            	System.Debug('setSfParents:Parent = null');
            	account.ParentId = null;
            }
            //add updated account into the list of updated accounts
            ref_updatedAccounts.add(account);
        }
    }
    
    //it's supposed that this method gets accounts with the same record type.
    //This method finds and sets correct parents for source accounts
    private static void updateHierarchyForGroupedAccounts(Account[] sourceAccounts,
        String recordTypeName, Account[] ref_updatedAccounts)
    {
        //try to get a name of a parent record type for the operated record type
        String parentRecordTypeName =
            H_C_AccountRecordType.mapOfParentRecordTypes.get(recordTypeName);
        //if input parameters are incorrect or a parent record type can't be found then stop the method
        if (sourceAccounts == null || sourceAccounts.size() == 0 || String.isBlank(parentRecordTypeName))
        {
        	//stop the method
            return;
        }
        
        //extract external parent Ids for source accounts 
        List<String> externalParentIdsForSourceAccounts =
            extractExternalParentIds(sourceAccounts, recordTypeName);
        
        //get parent accounts for source accounts from DB
        Account[] parentsForSourceAccounts = H_C_AccountDAO.getAccountsByExternalIds(
            externalParentIdsForSourceAccounts, parentRecordTypeName);
        //initialize helper for parent accounts
        H_C_AccountHelper parentAccountsHelper =
            H_C_AccountHelper.createHelperByAccountsList(parentsForSourceAccounts);
        
        //call the method which updates references to real salesforce parents and puts
        //the results into ref_updatedAccounts array
        setSfParents(sourceAccounts, parentAccountsHelper, recordTypeName, ref_updatedAccounts);
    }
    //
    
    
    //
    //Public static methods
    //
    public static void updateHierarchy(Account[] sourceAccounts, Boolean commitChanges)
    {
        //if input parameters are incorrect then we stop the method
        if (sourceAccounts == null || sourceAccounts.size() == 0)
        {
        	//stop the method
            return;
        }
        
        //STEP #1: extract necessary accounts from the source accounts
        //initialize helper for the source accounts
        H_C_AccountHelper sourceAccountsHelper =
            H_C_AccountHelper.createHelperByAccountsList(sourceAccounts);
        //extract key region and transactional accounts only, because all other accounts
        //should not have parents
        Account[] keyAccounts = sourceAccountsHelper.getAccountsByRecordTypeName(
            H_C_AccountRecordType.KEY_REGION_ACCOUNT);
        Account[] transactionalAccounts = sourceAccountsHelper.getAccountsByRecordTypeName(
            H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT);
        //if there are no key region accounts and transactional accounts then we can stop the method
        if (keyAccounts.size() == 0 && transactionalAccounts.size() == 0)
        {
        	//stop the method
            return;
        }
        
        //STEP #2: update groups of accounts which were selected at the 1st step (the results
        //will be put in ref_updatedAccounts)
        List<Account> ref_updatedAccounts = new List<Account>();
        updateHierarchyForGroupedAccounts(keyAccounts,
            H_C_AccountRecordType.KEY_REGION_ACCOUNT, ref_updatedAccounts);
        updateHierarchyForGroupedAccounts(transactionalAccounts,
            H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT, ref_updatedAccounts);
        
        //commit the changes if it's needed
        if (commitChanges)
        {
            H_C_SoqlUtils.tryPerformDmlOperation(
                H_C_SoqlUtils.DmlOperation.Updating, ref_updatedAccounts);
        }
    }
    
    public static void updateHierarchy_onAccountsInserted(Account[] insertedAccounts)
    {
        //if input parameters are incorrect then we stop the method
        if (insertedAccounts == null)
        {
        	//stop the method
            return;
        }
        
        //it's supposed that this method is called from 'after insert' trigger. We can't use
        //'before insert' trigger, because it's possible to insert a child account and its parent
        //account at one time (in this case, the code can't find such parent in DB, because data
        //are still not inserted). If we use 'after insert' trigger then the code can find such
        //parent in DB, but such trigger do not allow to edit the objects (they
        //are read only). That's why the code makes deep copy of all inserted accounts and works
        //with these copies.
        List<Account> clonesOfInsertedAccounts = cloneAccounts(insertedAccounts);
        
        //call the method to try to update hierarchy for all inserted accounts
        updateHierarchy(clonesOfInsertedAccounts, true);
    }
    
    public static void updateHierarchy_onAccountsUpdated(
        Map<Id, Account> oldAccounts, Account[] updatedAccounts)
    {
        //if input parameters are incorrect then we stop the method
        if (oldAccounts == null || updatedAccounts == null)
        {
        	//stop the method
            return;
        }
        
        //it's supposed that this method is called from 'after update' trigger. We can't use
        //'before update' trigger, because it's possible to update child account and its parent
        //account at one time (in this case, the code can't find such parent in DB, because data
        //are still not updated). If we use 'after update' trigger then the code can find such
        //parent in DB, but such trigger do not allow to edit the objects (they
        //are read only). That's why the code makes deep copy of all updated accounts and works
        //with these copies.
        updatedAccounts = cloneAccounts(updatedAccounts);
        
        //STEP #1: extract necessary accounts from the updated accounts
        //initialize helper for the source accounts
        H_C_AccountHelper sourceAccountsHelper =
            H_C_AccountHelper.createHelperByAccountsList(updatedAccounts);
        //extract key region and transactional accounts only, because all other accounts
        //should not have parents
        Account[] keyAccounts = sourceAccountsHelper.getAccountsByRecordTypeName(
            H_C_AccountRecordType.KEY_REGION_ACCOUNT);
        Account[] transactionalAccounts = sourceAccountsHelper.getAccountsByRecordTypeName(
            H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT);
        //if there are no key region accounts and transactional accounts then we can stop the method
        if (keyAccounts.size() == 0 && transactionalAccounts.size() == 0)
        {
        	//stop the method
            return;
        }
        
        //STEP #2: analyze updated accounts (select accounts with updated external parent id)
        Account[] updatedKeyAccounts = selectAccountsWithUpdatedExternalParentId(
            keyAccounts, oldAccounts, H_C_AccountRecordType.KEY_REGION_ACCOUNT);
        Account[] updatedTransactionalAccounts = selectAccountsWithUpdatedExternalParentId(
            transactionalAccounts, oldAccounts, H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT);
        
        //STEP #3: update hierarchy for selected accounts and commit the changes
        List<Account> ref_updatedAccounts = new List<Account>();
        updateHierarchyForGroupedAccounts(updatedKeyAccounts,
            H_C_AccountRecordType.KEY_REGION_ACCOUNT, ref_updatedAccounts);
        updateHierarchyForGroupedAccounts(updatedTransactionalAccounts,
            H_C_AccountRecordType.TRANSACTIONAL_ACCOUNT, ref_updatedAccounts);
        
        //perform 1 DML operation to commit the changes
        H_C_SoqlUtils.tryPerformDmlOperation(
            H_C_SoqlUtils.DmlOperation.Updating, ref_updatedAccounts);
    }
    //
    
    
    
    
    
    //
    //Unit tests
    //
    @IsTest
    private static void test_privateMethods()
    {
        //this method tests unusual cases in private methods
        System.assertEquals(0, selectAccountsWithUpdatedExternalParentId(null, null, 'unknown record type').size());
        System.assertEquals(0, extractExternalParentIds(null, 'unknown record type').size());
        setSfParents(null, null, 'unknown record type', null);
        updateHierarchyForGroupedAccounts(null, null, null);
    }
    //
}