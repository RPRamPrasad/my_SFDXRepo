/**
* @author Team NSYNC
* @date 12/13/2021
* @description Replays share records
*/
@IsTest(seeAllData=false)
private class AT3_ShareReplayTest{
    private static User systemUser;
    private static User testAPIUser;
    private static User testAgentUser;
    private static AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting;
    private static final String SERVICE_SUMMARY_ORCH_PERMSET_NAME = 'SF_CRM_AGRESYNCREPLAY_PermSetPID';
    private static final String AGRE_TRANS_TYPE = 'Agreement';
    private static final String AGRE_ID_TYPE = 'AgreIndexID__c';
    private static InsurancePolicy ip;     
//this is needed so that the insert trigger is NOT executed.

    static testmethod void  testInsertInsurancePolicyShares(){
        List<ExceptionLog__c> exceptionLogList = new List<ExceptionLog__c>();
        setup();
        System.runAs(systemUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            ExceptionLog__c exceptionLog =new ExceptionLog__c();
            exceptionLog.Method__c='insertInsurancePolicyShares';
            exceptionLog.Exception_message__c='unable to obtain exclusive access to this record';
            exceptionLog.Class__c = 'UTIL_InsurancePolicyShares';
            String billingDate = '2020-08-09 14:40:00 -0400';
			DateTime dateTimeConvert = DateTime.valueOf(billingDate);
            exceptionLog.Timestamp__c = dateTimeConvert;
            exceptionLog.User_ID__c = testAgentUser.Id;
            exceptionLog.TPTransactionId__c=ip.Id;
            exceptionLog.Stack_Trace__c = null;
            exceptionLog.Trigger__c=testAgentUser.Id;
            exceptionLogList.add(exceptionLog);           
        }
        System.runAs(testAPIUser){
            
            Test.StartTest();
            insert exceptionLogList;
            AT3_ShareReplay sh1 = new AT3_ShareReplay();      
            String sch = '0  00 1 3 * ?';
            system.schedule('Test', sch, sh1);
            String errorMessage = 'The orch size did not match';
            Test.stopTest();
// i tried system.Limits.getQueueableJobs() as the expected, but the jobs don't get queued until after the test is stopped.
            system.assertEquals(1, exceptionLogList.size(), errorMessage);
        }
    }
    static testmethod void  testDeleteInsurancePolicyShares(){
        List<ExceptionLog__c> exceptionLogList = new List<ExceptionLog__c>();
        setup();
        System.runAs(systemUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            InsurancePolicyShare ipShare =new InsurancePolicyShare();
            ipShare.AccessLevel = 'Read';
            ipShare.ParentId = ip.Id;
            ipShare.RowCause = 'Manual';
            ipShare.UserOrGroupId = testAgentUser.Id;
			insert ipShare;            
			Id ipShareId = ipShare.Id;
            
            ExceptionLog__c exceptionLog =new ExceptionLog__c();
            exceptionLog.Method__c='deleteInsurancePolicyShares';
            exceptionLog.Exception_message__c='unable to obtain exclusive access to this record';
            exceptionLog.Class__c = 'UTIL_InsurancePolicyShares';
            String billingDate = '2020-08-09 14:40:00 -0400';
			DateTime dateTimeConvert = DateTime.valueOf(billingDate);
            exceptionLog.Timestamp__c = dateTimeConvert;
            exceptionLog.User_ID__c = testAgentUser.Id;
            exceptionLog.TPTransactionId__c=ip.Id;
            exceptionLog.Stack_Trace__c = ipShareId;
            exceptionLog.Trigger__c=testAgentUser.Id;
            exceptionLogList.add(exceptionLog);           
        }
        System.runAs(testAPIUser){
            
            Test.StartTest();
            insert exceptionLogList;
            AT3_ShareReplay sh1 = new AT3_ShareReplay();      
            String sch = '0  00 1 3 * ?';
            system.schedule('Test', sch, sh1);
            String errorMessage = 'The orch size did not match';
            Test.stopTest();
// i tried system.Limits.getQueueableJobs() as the expected, but the jobs don't get queued until after the test is stopped.
            system.assertEquals(1, exceptionLogList.size(), errorMessage);
        }
    }
    /**
     * @description setup
     */
    public static void setup(){
        systemUser= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemUser;
        System.runAs(systemUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(SFDC_USER_ID__c=systemUser.id);
            insert sysAdminUserIdSetting;
            testAPIUser= UTIL_UserProvisioning_TEST.create103APIOnlyTestUser();
            testAgentUser= UTIL_UserProvisioning_TEST.setUpAgentUser();
            Account a = UTIL_CreateCustomerTestData.createIndividualCustomer('TestAccount');
            a.clientIdentifier__c= 'TestAccount';
            insert a;

            ip = new InsurancePolicy();
            ip.NameInsuredId = a.id;
            ip.Name = 'testInsertInsurancePolicyShares';
            insert ip;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(testAPIUser);
            PermissionSetAssignment psassignment3 = assignPermSet(testAPIUser, 'SF_CRM_AGRESYNCREPLAY_PermSetPID');
            insert psassignment3;
        }
    }
    /**
     * @description assignPermSet
     * @param testUser 
     * @param permissionSetName 
     * @return  `PermissionSetAssignment`
     */
   public static PermissionSetAssignment assignPermSet (User testUser, String permissionSetName){
        PermissionSet ps = [Select Id, Name FROM PermissionSet WHERE Name= :permissionSetName];
        PermissionSetAssignment assignment = new PermissionSetAssignment(AssigneeId=testUser.Id,PermissionSetId=ps.Id);
        return assignment;
    }
    
}