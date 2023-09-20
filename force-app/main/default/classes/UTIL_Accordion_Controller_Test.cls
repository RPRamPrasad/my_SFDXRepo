@isTest
public with sharing class UTIL_Accordion_Controller_Test {
    
    //method to bypass trigger
    /**
     * @description setup
     */
    public static void setup(){
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=true);
        insert passTriggerAll;
    }
    
    //method to set up the users referenced in the test
    /**
     * @description testUsersSetup
     */
    @testsetup
    public static void testUsersSetup() {  
        TestUserSetupUtility.setupAgentOffice();
        TestUserSetupUtility.setupSystemAdminUser();
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            CaseTestDataUtility.createAccount();
            CaseTestDataUtility.setupAgentRole(TestUserSetupUtility.getAgentUser(), CaseTestDataUtility.getAccount());
        }
    }
    @isTest
    private static void testGetAcctId() {
        User agentUser = TestUserSetupUtility.getAgentUser();
        Id testAccntId = CaseTestDataUtility.getAccount().Id;
        setup();
        
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);    
        System.runas(agentUser){            
            Case caseWithAccount = new Case();
            caseWithAccount.AccountId = testAccntId;
            insert caseWithAccount;
            
            String accountId = UTIL_Accordion_Controller.getAcctId(caseWithAccount.Id);
            System.assert(accountId == testAccntId,'FirstAccountID should be equal to testAccountID');
        }
        Test.stopTest();
    }
    @isTest
    private static void testGetDisplayInformation() {
        User agentUser = TestUserSetupUtility.getAgentUser();
        Id testAccntId = CaseTestDataUtility.getAccount().Id;
        setup();
        
        Test.startTest();    
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runas(agentUser){
            Case caseWithAccount = new Case();
            caseWithAccount.AccountId = testAccntId;
            insert caseWithAccount;
            
            List<Account> accountId = UTIL_Accordion_Controller.getAccountInformation(caseWithAccount.Id);	
            Account firstAcct = accountId[0];
            System.assert(firstAcct.Id == testAccntId,'FirstAccountID should be equal to testAccountID');
            
            List<Account> accountId2 = UTIL_Accordion_Controller.getAccountInformation(testAccntId);	
            Account firstAcct2 = accountId2[0];
            System.assert(firstAcct2.Id == testAccntId,'FirstAccountID should be equal to testAccountID');
        }
        Test.stopTest();
    }
}