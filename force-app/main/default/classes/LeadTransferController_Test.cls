/**
 * Author : Golden Spikes Team
 * Date Created : 10/28/2020
 * @description LeadTransferController_Test : Test class for LeadTransferController.
 */
@isTest(seeAllData=false)
public class LeadTransferController_Test {
    private static User agentUser;
    private static User proxyUser;
    private static User systemUser;
    private static User cccLUser;
    private static User adminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'sysAdm' + UTIL_TestUsername_TEST.getTestUsername());
    private static Map<String, Schema.Recordtypeinfo> leadRecordTypeMap = Schema.Sobjecttype.Lead.getRecordTypeInfosByDeveloperName();
    private static String taskRecordTypeId = Schema.Sobjecttype.Task.getRecordTypeInfosByDeveloperName().get('Task').getRecordTypeId();
    private static final String PARTIAL_LEAD_RECORD_TYPE_DEV_NAME = 'PartialLead';

    @TestSetup
    private static void makeData() {
        User adminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'sysAdTLd' + UTIL_TestUsername_TEST.getTestUsername());
        insert adminUser;
        System.runAs(adminUser) {
            insert new CS001_ByPassTriggerAll__c(Override_All__c = false);
            UserRole agentUserRole = new UserRole(name = 'AgentRole');
            insert agentUserRole;
            UserRole proxyUserRole = new UserRole(name = 'ProxyRole', parentRoleId = agentUserRole.id);
            insert proxyUserRole;
            User testAgentUser1 = new User(Alias='Alia',LastName='prefPrxy',Username='TfPrf' + UTIL_TestUsername_TEST.getTestUsername(),Associate_ID__c='20ccww22zzc',UserExternalID__c='20ccww22zzc_20ccww22zzc',Servicing_Agent_Associate_ID__c='20ccww22zzc');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;

            systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
            systemUser.UserExternalID__c = 'MnLdSys123';
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c actOwnerCs = new AccountOwnerSystemUserCustomSetting__c(Name = UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER, SFDC_USER_ID__c = systemUser.id);
            insert actOwnerCs;

            User cccLUser = UTIL_UserProvisioning_TEST.buildCCCLicensedUser();
            cccLUser.UserExternalID__c = 'ManLdCCC';
            insert cccLUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccLUser);
            User testProxyUser1 = new User(Alias='Prox',LastName='trsfAgnt',Username='trLd' + UTIL_TestUsername_TEST.getTestUsername(),UserExternalID__c='20ccww22zzcP',Servicing_Agent_Associate_ID__c='20ccww22zzc');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            Lead leadRec = buildLeadRecord(systemUser.Id, cccLUser.Id);
            insert leadRec;

            LeadMetrics__c leadMetricRec = new LeadMetrics__c(LeadSfdcId__c = leadRec.Id, AssignedTo__c = cccLUser.Id, OwnerId = systemUser.Id, LeadName__c = 'TestFacebookLead');
            insert leadMetricRec;
        }
    }

    @isTest private static void testUpdateLeadOwner() {
        System.runAs(getCCCUser()) {
            Lead leadRecBeforeTransfer = [SELECT Id, OwnerId, AssignedTo__c FROM Lead WHERE External_Lead_ID__c = 'ManTrf123' LIMIT 1];
            System.assertEquals(getSystemUser().id, leadRecBeforeTransfer.OwnerId, 'Invalid Lead Owner');
            System.assertEquals(UserInfo.getUserId(), leadRecBeforeTransfer.AssignedTo__c, 'Invalid Lead Assigned To');

            LeadTransferController.LeadTransferResponse ldTransferResponse = LeadTransferController.updateLeadOwner(leadRecBeforeTransfer.Id);
            System.assert(ldTransferResponse.isUpdateSuccess, 'Invalid Update Response');
            System.assert(String.isBlank(ldTransferResponse.pgErrorMsg), 'Invalid Page Error Message');

            Lead leadRecAfterTransfer = [SELECT Id, OwnerId, AssignedTo__c FROM Lead WHERE id = :leadRecBeforeTransfer.id LIMIT 1];
            System.assertEquals(getProxyUser().id, leadRecAfterTransfer.OwnerId, 'Invalid Lead Owner');
            System.assert(String.isBlank(leadRecAfterTransfer.AssignedTo__c), 'Invalid Lead Assigned To');

            LeadMetrics__c ldMetricRecAfterTransfer = [SELECT Id, OwnerId, AssignedTo__c, LeadTransferredBy__c FROM LeadMetrics__c WHERE LeadSfdcId__c = :leadRecAfterTransfer.id LIMIT 1];
            System.assertEquals(getProxyUser().id, ldMetricRecAfterTransfer.OwnerId, 'Invalid Lead Owner');
            System.assert(String.isBlank(ldMetricRecAfterTransfer.AssignedTo__c), 'Invalid Lead Assigned To');
            System.assertEquals(UserInfo.getUserId(), ldMetricRecAfterTransfer.LeadTransferredBy__c, 'Invalid Lead Transferred By');

            Task insertedTask = [SELECT AppCode__c, Subject, Priority, Status, Task_Type__c, TaskCategory__c, Source__c, WhoId, 
                OwnerId, RecordTypeId, AgentAssociateId__c, ActivityDate, Description FROM Task LIMIT 1];
            System.assertEquals('Lead Management', insertedTask.AppCode__c, 'Task App Code is Incorrect.');
            System.assertEquals('New Enterprise Facebook Lead', insertedTask.Subject, 'Task Subject is Incorrect.');
            System.assertEquals('None', insertedTask.Priority, 'Task Priority is Incorrect.');
            System.assertEquals('Not Started', insertedTask.Status, 'Task Status is Incorrect.');
            System.assertEquals('Sales', insertedTask.Task_Type__c, 'Task Type is Incorrect.');
            System.assertEquals('Marketing', insertedTask.TaskCategory__c, 'Task Category is Incorrect.');
            System.assertEquals('Marketing', insertedTask.Source__c, 'Task Source is Incorrect.');
            System.assertEquals(leadRecAfterTransfer.Id, insertedTask.WhoId, 'Task WhoId is Incorrect.');
            System.assertEquals(leadRecAfterTransfer.OwnerId, insertedTask.OwnerId, 'Task OwnerId is Incorrect.');
            System.assertEquals(taskRecordTypeId, insertedTask.RecordTypeId, 'Task Record Type is Incorrect.');
            System.assertEquals('20ccww22zzc', insertedTask.AgentAssociateId__c, 'Task Agent Associate Id is Incorrect.');
            System.assertEquals(Date.Today(), insertedTask.ActivityDate, 'Task Activity Date is Incorrect.');
            System.assertEquals('Test Description', insertedTask.Description, 'Task Description is Incorrect.');

            LeadTransferController.LeadTransferResponse ldAlreadyTransferredResp = LeadTransferController.updateLeadOwner(leadRecBeforeTransfer.Id);
            System.assert(!ldAlreadyTransferredResp.isUpdateSuccess, 'Invalid Update Response');
            System.assertEquals('This Lead is already transfered to the agent office. No action required from your end.', ldAlreadyTransferredResp.pgErrorMsg, 'Invalid Page Error Message');
        }
    }

     //method to build lead record with the given parameter value
    private static Lead buildLeadRecord(Id ownerId, String assignedTo) {
        Lead leadRecord = new Lead(Description = 'Test Description', External_Lead_ID__c = 'ManTrf123', LeadSource = 'Enterprise Facebook Lead', 
        AssignedTo__c = assignedTo, AgentAssociateId__c = '20ccww22zzc', SourcedFromCCC__c = true, LastName = 'TestFacebookLead', state = 'IL', 
        DateCaptured__c = System.today(), ownerId = ownerId, recordtypeId = leadRecordTypeMap.get(PARTIAL_LEAD_RECORD_TYPE_DEV_NAME).RecordTypeId);
        return leadRecord;
    }

    private static User getSystemUser() {
        return [SELECT Id FROM User WHERE UserExternalId__c = 'MnLdSys123' LIMIT 1];
    }

    private static User getCCCUser() {
        return [SELECT Id FROM User WHERE UserExternalId__c = 'ManLdCCC' LIMIT 1];
    }

    private static User getProxyUser() {
        return [SELECT Id FROM User WHERE UserExternalId__c = '20ccww22zzcP' LIMIT 1];
    }
}