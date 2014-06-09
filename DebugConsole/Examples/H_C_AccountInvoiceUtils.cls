//
//This class provides utilities for working with 'H_C_AccountInvoice__c' object 
//
//Author: CERVELLO INC - Anil Tumati / Sergey Trusov (27-02-2014)
public without sharing class H_C_AccountInvoiceUtils
{
    //
    //Private static methods
    //
    private static H_C_AccountInvoice__c constructMapping(
        Invoice__c invoice, String accountId)
    {
        H_C_AccountInvoice__c newMapping = new H_C_AccountInvoice__c();
        newMapping.Account__c = accountId;
        newMapping.Invoice__c = invoice.Id;
        newMapping.Name = invoice.Name;
        return newMapping;
    }

    private static H_C_AccountInvoice__c[] constructMappings(Invoice__c invoice)
    {
        List<H_C_AccountInvoice__c> newObjects = new List<H_C_AccountInvoice__c>();
        //create account-invoice mapping for the current account
        if (String.isNotBlank(invoice.Bill_To_Customer__c))
        {
            newObjects.add(constructMapping(invoice, invoice.Bill_To_Customer__c));
        }
        
        //create account-invoice mapping for a parent of the current account
        if (String.isNotBlank(invoice.Bill_To_Customer__r.ParentId))
        {
            newObjects.add(constructMapping(invoice, invoice.Bill_To_Customer__r.ParentId));
        }
        
        //create account-invoice mapping for a parent of a parent of the current account
        if (String.isNotBlank(invoice.Bill_To_Customer__r.Parent.ParentId))
        {
            newObjects.add(constructMapping(invoice, invoice.Bill_To_Customer__r.Parent.ParentId));
        }
        return newObjects;
    }
    
    private static H_C_OperationResults createNewMappings(Invoice__c[] invoices)
    {
    	//if there are no passed objects that nothing can be created
    	if (invoices == null || invoices.size() == 0)
    	{
    		//in this case we consider that the method executed successfully, because
    		//there were no any internal errors
    		return new H_C_OperationResults(true);
    	}
    	
    	//construct new mappings
        List<H_C_AccountInvoice__c> newMappings = new List<H_C_AccountInvoice__c>();
        for (Invoice__c invoice : invoices)
        {
            newMappings.addAll(constructMappings(invoice));
        }
        //insert new mappings (perform 1 DML operation to insert all new mappings)
        return H_C_SoqlUtils.performSafeDmlOperation(H_C_SoqlUtils.DmlOperation.Inserting, newMappings);
    }
    
    private static void processInvoices_onUpdateAccountLinks(
    	Map<Id, Invoice__c> oldInvoices, Invoice__c[] updatedInvoices)
    {
        //STEP #1: analyze updated invoices and select only those invoices
        //which 'AccountId' reference has been changed
        List<String> selectedInvoicesIds = new List<String>();
        for (Invoice__c updatedInvoice : updatedInvoices)
        {
            Invoice__c oldInvoice = oldInvoices.get(updatedinvoice.Id);
            if (updatedinvoice.Bill_To_Customer__c != oldinvoice.Bill_To_Customer__c)
            {
                selectedInvoicesIds.add(updatedinvoice.Id);
            }
        }
        //if there are no invoices which are interesting for this method then we stop it
        if (selectedInvoicesIds.size() == 0)
        {
        	return;
        }
        
        //STEP #2: manage existing mappings
        //we should get and delete all existing mappings for updated invoices,
        //because they are not actual now
        H_C_AccountInvoice__c[] existingMappings =
        	H_C_AccountInvoiceUtils.getObjectsByInvoicesIds(selectedInvoicesIds);
        //perform 1 DML operation to delete all new mappings
        H_C_SoqlUtils.tryPerformDmlOperation(H_C_SoqlUtils.DmlOperation.Deleting, existingMappings);
        
        //STEP #3: manage new mappings
        //reread the selected invoices to include all necessary fields
        Invoice__c[] selectedInvoices = getInvoicesByIds(selectedInvoicesIds);
        //generate and insert new mappings
        createNewMappings(selectedInvoices);
    }
    //
    
    //
    //Public static methods
    //
    public static H_C_OperationResults manageMappingsForAccounts(String[] accountsIds)
    {
    	//we make an assumption that the method will be executed successfully, and if any errors
    	//occur then the method will update this results    	
    	H_C_OperationResults results = new H_C_OperationResults(true);
    	
        //if there are no accounts for this method then we can do nothing
        if (accountsIds != null && accountsIds.size() > 0)
        {
            //get all existing mappings for invoices of source accounts and delete them
            H_C_AccountInvoice__c[] existingMappings =
                H_C_AccountInvoiceUtils.getObjectsByInvoiceAccountsIds(accountsIds);
            //try to safely delete existing mappings and save intermediate results
            //into the final results
            results = H_C_SoqlUtils.performSafeDmlOperation(
            	H_C_SoqlUtils.DmlOperation.Deleting, existingMappings);
            
            //we can continue only if there were no errors during the previous steps 
            if (results.isOperationSuccessful)
            {
	            //get all invoices for source accounts and create new mappings for them
	            Invoice__c[] accountInvoices = getInvoicesByAccountsIds(accountsIds);
	            //try to generate and insert new mappings, and update the final results
	            results = createNewMappings(accountInvoices);
            }
        }
        
        return results;
    }
    
    public static void manageMappings_onAccountsUpdated(
        Map<Id, Account> oldAccounts, Account[] updatedAccounts)
    {
        //check input parameters
        if (oldAccounts == null || updatedAccounts == null)
        {
            return;
        }
        
        //STEP #1: analyze updated accounts and select only those accounts which
        //parent reference has been changed
        List<String> selectedAccountsIds = new List<String>();
        for (Account updatedAccount : updatedAccounts)
        {
            Account oldAccount = oldAccounts.get(updatedAccount.Id);
            if (updatedAccount.ParentId != oldAccount.ParentId)
            {
                selectedAccountsIds.add(updatedAccount.Id);
            }
        }
        
        //STEP #2: change existing or create new mappings 
        manageMappingsForAccounts(selectedAccountsIds);
    }
    
    public static void manageMappings_onInvoicesInserted(Invoice__c[] insertedInvoices)
    {
        //check the input parameter
        if (insertedInvoices == null || insertedInvoices.size() == 0)
        {
            return;
        }
        
        //STEP #1: reread the invoices to include all necessary fields
        String[] insertedInvoicesIds = extractInvoicesIds(insertedInvoices);
        insertedInvoices = getInvoicesByIds(insertedInvoicesIds);
        
        //STEP #2: create and insert new mappings
        createNewMappings(insertedInvoices);
    }
    
    public static void manageMappings_onInvoicesUpdated(
    	Map<Id, Invoice__c> oldInvoices, Map<Id, Invoice__c> updatedInvoices)
    {
        //check input parameters
        if (oldInvoices == null || updatedInvoices == null)
        {
            return;
        }
        
        //STEP #1: manage mappings for invoices which 'Account' references have been changed
        processInvoices_onUpdateAccountLinks(oldInvoices, updatedInvoices.values());
        
        //#WARNING: this call should be parameterized, because some objects have 'auto number' Name
        //which can't be changed (like, Invoice__c). In this case, it's useless to check changes
        //in name
        //STEP #2 (the name of 'Invoice__c' object can't be changed):
        //manage mappings for invoices which names have been changed
        //processInvoices_onUpdateNames(oldInvoices, updatedInvoices);
    }
    //
    
    
    //
	//This code is used to provide access to 'H_C_AccountInvoice__c' object
	//(it has been implemented in a separate class, but was moved here to simplify
	//the procedure of creation of new mappings)
    //
    //Variables and constants
    //
    private static String BASIC_FIELDS = 'Id, Name, Account__c, invoice__c';
    private static String OBJECT_NAME = 'H_C_AccountInvoice__c';
    //
    
    //
    //Public static methods
    //
    private static H_C_AccountInvoice__c[] getObjectsByIds(String[] objectsIds)
    {
        //join Ids and check the string
        String stringOfIds = H_C_SoqlUtils.joinStringsForINSection(objectsIds);
        if (String.isBlank(stringOfIds))
        {
            return null;
        }
        
        //initialize query builder and perform the query
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        queryBuilder.condition = 'Id IN (' + stringOfIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    
    private static H_C_AccountInvoice__c[] getObjectsByAccountsIds(String[] accountsIds)
    {
        //join Ids and check the string
        String stringOfAccountsIds = H_C_SoqlUtils.joinStringsForINSection(accountsIds);
        if (String.isBlank(stringOfAccountsIds))
        {
            return null;
        }
        
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        queryBuilder.condition = 'Account__c IN (' + stringOfAccountsIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    
    //this method returns all mappings which contain invoice that belong to the passed accounts
    //(for example, if we pass only one account Id, then this method returns all mappings which
    //contain invoices of that account)
    private static H_C_AccountInvoice__c[] getObjectsByInvoiceAccountsIds(String[] accountsIds)
    {
        String stringOfAccountsIds = H_C_SoqlUtils.joinStringsForINSection(accountsIds);
        if (String.isBlank(stringOfAccountsIds))
        {
            return null;
        }
        
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        queryBuilder.condition = 'Invoice__r.Account__c IN (' + stringOfAccountsIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    
    private static H_C_AccountInvoice__c[] getObjectsByInvoicesIds(String[] invoicesIds)
    {
        //join Ids and check the string
        String stringOfInvoicesIds = H_C_SoqlUtils.joinStringsForINSection(invoicesIds);
        if (String.isBlank(stringOfInvoicesIds))
        {
            return null;
        }
        
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS, OBJECT_NAME);
        queryBuilder.condition = 'Invoice__c IN (' + stringOfInvoicesIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    //


	//InvoiceDAO Section
	//
	//This Section provides access to 'Invoice__c' object
	//
	//Author: CERVELLO INC - Anil Tumati / Sergey Trusov (27-02-2014)

    //
    //Variables and constants
    //
    private static String BASIC_FIELDS_2 = 'Id, Name, Bill_To_Customer__c, '
    	+ 'Bill_To_Customer__r.ParentId, Bill_To_Customer__r.Parent.ParentId';
    private static String OBJECT_NAME_2 = 'Invoice__c';
    //
    
    //
    //Public static methods
    //
    private static Invoice__c[] getInvoicesByIds(String[] invoicesIds)
    {
        //join Ids and check the string
        String stringOfIds = H_C_SoqlUtils.joinStringsForINSection(invoicesIds);
        if (String.isBlank(stringOfIds))
        {
            return null;
        }
        
        //initialize query builder and perform the query
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS_2, OBJECT_NAME_2);
        queryBuilder.condition = 'Id IN (' + stringOfIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    
    private static Invoice__c[] getInvoicesByAccountsIds(String[] accountsIds)
    {
        String stringOfAccountsIds = H_C_SoqlUtils.joinStringsForINSection(accountsIds);
        if (String.isBlank(stringOfAccountsIds))
        {
            return null;
        }
        
        H_C_SoqlQueryBuilder queryBuilder = new H_C_SoqlQueryBuilder(BASIC_FIELDS_2, OBJECT_NAME_2);
        queryBuilder.condition = 'Bill_To_Customer__c IN (' + stringOfAccountsIds + ')';
        return H_C_SoqlUtils.performQuery(queryBuilder);
    }
    
    private static String[] extractInvoicesIds(Invoice__c[] invoices)
    {
        if (invoices == null)
        {
            return null;
        }
        
        Set<String> setOfinvoicesIds = new Set<String>();
        for (Invoice__c invoice : invoices)
        {
            if (String.isNotBlank(invoice.Id))
            {
                setOfinvoicesIds.add(invoice.Id);
            }
        }
        
        List<String> listOfinvoicesIds = new List<String>();
        listOfinvoicesIds.addAll(setOfinvoicesIds);
        return listOfinvoicesIds;
    }
    //
}