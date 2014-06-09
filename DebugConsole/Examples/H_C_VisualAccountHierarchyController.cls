public class H_C_VisualAccountHierarchyController{
    
    private final Account account;
    private final Account rootAccount;
    private final List<Account> keyAccounts;
    private final List<Account> transactionAccounts;
    
    private String rootAccountLevel;
    private String secondAccontLevel;
    private String thirdAccontLevel;
    
    public H_C_VisualAccountHierarchyController(ApexPages.StandardController standardController) {
        account = (Account)standardController.getRecord();
        rootAccount = getRoot(account.Id);
        rootAccountLevel = [SELECT Id, Name FROM RecordType WHERE Id = :rootAccount.RecordTypeId LIMIT 1].Name;
        if (rootAccountLevel == 'Contract Account') {
            secondAccontLevel = 'Key Account';
            thirdAccontLevel = 'Transactional Account';
        } else if (rootAccountLevel == 'Key Account') {
            secondAccontLevel = 'Transactional Account';
            thirdAccontLevel = '';
        } else {
            secondAccontLevel = '';
            thirdAccontLevel = '';
        }
        keyAccounts = [SELECT Id, Name, ParentId, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, RecordTypeId FROM Account WHERE ParentId = :rootAccount.Id];
        transactionAccounts = [SELECT Id, Name, ParentId, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, RecordTypeId  FROM Account WHERE ParentId IN :keyAccounts];
    }
    
    private Account getRoot(Id id) {
        Account acct = [SELECT Id, Name, ParentId, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, RecordTypeId FROM Account WHERE Id = :id LIMIT 1];
        if (acct.ParentId == null) {
            return acct;
        }
        else {
            return getRoot(acct.ParentId);
        }
    }
    
    public Account getRoot() {
        return rootAccount;
    }
    public Account getAccount() {
        return account;
    }
    public List<Account> getKeyAccounts() {
        return keyAccounts;
    }
    public List<Account> getTransactionAccounts() {
        return transactionAccounts;
    }
    public String getRootAccountLevel() {
        return rootAccountLevel;
    }
    public String getSecondaryAccountLevel() {
        return secondAccontLevel;
    }
    public String getThirdAccountLevel() {
        return thirdAccontLevel;
    }
}