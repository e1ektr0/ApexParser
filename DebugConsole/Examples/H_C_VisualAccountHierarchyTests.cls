@isTest(SeeAllData=true)
public class H_C_VisualAccountHierarchyTests {
    
    public static testMethod void generalTest() {
        Account contractAccount = new Account(Name = 'Contract');
        insert contractAccount;
        Account keyAccount = new Account(Name = 'key', ParentId = contractAccount.Id);
        insert keyAccount;
        Account transactionAccount = new Account(Name = 'transaction', ParentId = keyAccount.Id);
        insert transactionAccount;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(transactionAccount);
        H_C_VisualAccountHierarchyController controller = new H_C_VisualAccountHierarchyController (sc);
        
        Account root = controller.getRoot();
        Account account = controller.getAccount();
        List<Account> keyAccounts = controller.getKeyAccounts();
        List<Account> tranAccounts = controller.getTransactionAccounts();
    }
    
    public static testMethod void testAccountWithNoParent() {
        Account transactionAccount = new Account(Name = 'transaction');
        insert transactionAccount;
        ApexPages.StandardController sc = new ApexPages.StandardController(transactionAccount);
        H_C_VisualAccountHierarchyController  controller = new H_C_VisualAccountHierarchyController (sc);
        
        Account root = controller.getRoot();
        Account account = controller.getAccount();
        List<Account> keyAccounts = controller.getKeyAccounts();
        List<Account> tranAccounts = controller.getTransactionAccounts();
    }
}