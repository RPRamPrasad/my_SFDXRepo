/** @description Test class for the CustomerInitiatedCancellationBeforeInsert apex class */
@isTest (seeAllData=false)
public class AP_CICNoteTrigger_Test {
    
    //method to bypass Trigger
    private static void byPassTrigger() {
        CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c();
        objectBasedByPassTrigger.Override_All__c = true;
        insert objectBasedByPassTrigger;
    }

    /** @description method to set up the users referenced in the test */
    @testsetup
    public static void testUsersSetup() {  
        TestUserSetupUtility.setupAgentOffice();
        TestUserSetupUtility.setupSystemAdminUser();
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            CaseTestDataUtility.createAccount();
            CaseTestDataUtility.setupAgentRole(TestUserSetupUtility.getAgentUser(), CaseTestDataUtility.getAccount());
        }
    }
    
    //method to build Customer Initiated Cancellation record with the given parameter values
    private static CustomerInitiatedCancellations__c buildCustomerInitiatedCancellationRecord(String param_accountId, String param_policynum) {
        CustomerInitiatedCancellations__c cicNoteRecord = new CustomerInitiatedCancellations__c (Customer__c = param_accountId, 
                                                                                                 AssociatedPolicyNumber__c = param_policynum,
                                                                                                 CancellationReason__c = 'I lost the thing I had a policy for',
                                                                                                 DateOfContact__c = Date.today(),
                                                                                                 EffectiveDateOfCancellation__c = Date.today(),
                                                                                                 LineOfBusiness__c = 'Fire',
                                                                                                 MethodOfContact__c = 'Phone',
                                                                                                 PersonRequestingCancellationName__c = 'Jane Smith',
                                                                                                 PolicyDescription__c = 'myTestPolicy');
        return cicNoteRecord;
    }
    
    //test method to insert and update Customer Initiated Cancellation record as an Agent.
    @isTest
    private static void testCustomerInitiatedCancellationRecordInsertUpdateAsAgent() {
        User agentUser = TestUserSetupUtility.getAgentUser();
        Id testAccntId = CaseTestDataUtility.getAccount().Id;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        UTIL_OverrideSystemUser_TEST.doOverride();
        
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            byPassTrigger();
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            CS001_ByPassTriggerAll__c objectBasedByPassTrigger = [Select id from CS001_ByPassTriggerAll__c limit 1];
            objectBasedByPassTrigger.Override_All__c = false;
            update objectBasedByPassTrigger;
            
            Test.startTest();
            CustomerInitiatedCancellations__c cicNoteRecord = buildCustomerInitiatedCancellationRecord(testAccntId,'46-13-2345-9');
            insert cicNoteRecord;
            
            List<CustomerInitiatedCancellations__c> cicNoteList = [Select Id, Customer__c, AssociatedPolicyNumber__c, OwnerId from CustomerInitiatedCancellations__c limit 1];
            System.assert(!cicNoteList.isEmpty(), 'The CIC Note was not inserted or retrieved correctly');
            System.assertEquals(testAccntId, cicNoteList[0].Customer__c, 'The CIC Note was not properly associated to the correct Account');
            System.assertEquals('46-13-2345-9', cicNoteList[0].AssociatedPolicyNumber__c, 'The CIC Note policy number was not set properly');
            
            //Update Record to test BeforeUpdate trigger
            cicNoteRecord.PolicyDescription__c = 'UpdatedTestPolicyDescription';
            
            update cicNoteRecord;
            List<CustomerInitiatedCancellations__c> cicNoteUpdateList = [Select Id, Customer__c, AssociatedPolicyNumber__c, OwnerId, PolicyDescription__c from CustomerInitiatedCancellations__c limit 1];
            System.assert(!cicNoteUpdateList .isEmpty(), 'The CIC Note was not retrieved correctly; at this point in the test, the record has already been inserted properly');
            System.assertEquals('UpdatedTestPolicyDescription', cicNoteUpdateList [0].PolicyDescription__c, 'The CIC Note policy description was not updated properly');
            
            Test.stopTest();
        }
    }
}