/**
 * Author : Golden Spikes Team
 * Date Created : 10/27/2020
 * Description : Test class for Batch_TransferLead/HLPR_TransferLead.
 * @description Batch_TransferLead_Test
 */
@isTest(seeAllData=false)
public class Batch_TransferLead_Test {
    private static User agentUser;
    private static User proxyUser;
    private static User systemUser;
    private static User batchProcIdUser;
    private static User cccLUser;
    private static Map<String, Schema.Recordtypeinfo> leadRecordTypeMap = Schema.Sobjecttype.Lead.getRecordTypeInfosByDeveloperName();
    private static String taskRecordTypeId = Schema.Sobjecttype.Task.getRecordTypeInfosByDeveloperName().get('Task').getRecordTypeId();
    private static final String PARTIAL_LEAD_RECORD_TYPE_DEV_NAME = 'PartialLead';

    @TestSetup private static void makeData() {
        User adminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'sysAdTLd' + UTIL_TestUsername_TEST.getTestUsername());
        insert adminUser;
        User transferLeadProcIdUser;
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
            systemUser.UserExternalID__c = 'TrLdSys123';
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c actOwnerCs = new AccountOwnerSystemUserCustomSetting__c(
                Name = UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER, SFDC_USER_ID__c = systemUser.id);
            insert actOwnerCs;

            User cccLUser = UTIL_UserProvisioning_TEST.buildCCCLicensedUser();
            cccLUser.UserExternalID__c = 'trLdCCC';
            insert cccLUser;

            CSLeadBatch__c leadBatchCs = new CSLeadBatch__c(
                Name = 'Transfer_Lead_Batch', BatchEmailRecipient__c = 'home.et-fb-daily-batch-test.047j01@statefarm.com',
                BatchSize__c = 30, QuerySize__c = 1000000, SenderDisplayName__c = 'Leads Management Transfer Lead Summary',
                QueryFilterStartDay__c = 0);
            insert leadBatchCs;
            User testProxyUser1 = new User(Alias='Prox',LastName='trsfAgnt',Username='trLd' + UTIL_TestUsername_TEST.getTestUsername(),UserExternalID__c='20ccww22zzcP',Servicing_Agent_Associate_ID__c='20ccww22zzc');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            transferLeadProcIdUser = UTIL_UserProvisioning_TEST.buildUserAPIDataAdmin('apiTLd' + UTIL_TestUsername_TEST.getTestUsername());
            transferLeadProcIdUser.UserExternalID__c = 'TrLdBatch1';
            insert transferLeadProcIdUser;

            insert new PermissionSetAssignment(
                AssigneeId = transferLeadProcIdUser.id,
                PermissionSetId = [SELECT id FROM PermissionSet WHERE Name = 'SF_CRM_EventLeadOppMgmt_PermSetPID' LIMIT 1].id);

            Lead leadRec = buildLeadRecord(systemUser.Id, cccLUser.Id);
            insert leadRec;

            LeadMetrics__c leadMetricRec = new LeadMetrics__c(LeadSfdcId__c = leadRec.Id, AssignedTo__c = cccLUser.Id, OwnerId = systemUser.Id, LeadName__c = 'TestFacebookLead');
            insert leadMetricRec;
        }
    }

    //method to build dynamic soql query for lead transfer
    private static String buildLeadTransferQuery() {
        return 'SELECT Id, AgentAssociateId__c, LeadSource, Description, OwnerId, AssignedTo__c FROM Lead WHERE ' +
            'RecordTypeId =: recordTypeId AND CreatedDate >=: todaysDate AND OwnerId =: systemRecordOwnerSfdcId AND ' +
            'SourcedFromCCC__c = TRUE and isConverted = FALSE WITH SECURITY_ENFORCED LIMIT : batchQueryLimit';
    }

    //method to build lead record with the given parameter value
    private static Lead buildLeadRecord(Id ownerId, String assignedTo) {
        Lead leadRecord = new Lead(Description = 'Test Description', LeadSource = 'Enterprise Facebook Lead', AssignedTo__c = assignedTo, 
        AgentAssociateId__c = '20ccww22zzc', SourcedFromCCC__c = true, LastName = 'TestFacebookLead', state = 'IL', DateCaptured__c = System.today(), 
        ownerId = ownerId, recordtypeId = leadRecordTypeMap.get(PARTIAL_LEAD_RECORD_TYPE_DEV_NAME).RecordTypeId
        );
        return leadRecord;
    }

    //method to fetch Users
    private static void getUsers() {
        for (User usrobj : [SELECT Id, UserExternalID__c FROM User WHERE UserExternalID__c IN ('trLdCCC', 'TrLdSys123', '20ccww22zzcP', 'TrLdBatch1')]) {
            if (usrobj.UserExternalID__c == '20ccww22zzcP') {
                proxyUser = usrobj;
            } else if (usrobj.UserExternalID__c == 'TrLdBatch1') {
                batchProcIdUser = usrobj;
            } else if (usrobj.UserExternalID__c == 'trLdCCC') {
                cccLUser = usrobj;
            } else {
                systemUser = usrobj;
            }
        }
    }

    @isTest private static void testProcessTransferLeadUpdate() {
        getUsers();
        Map<String, CSLeadBatch__c> leadCSBatchRecordMap = CSLeadBatch__c.getAll();
        CSLeadBatch__c leadTransferCustomSettingRecord = leadCSBatchRecordMap.get('Transfer_Lead_Batch');

        Lead leadRecBeforeTransfer = [SELECT Id, OwnerId, AssignedTo__c FROM Lead LIMIT 1];
        System.assertEquals(systemUser.id, leadRecBeforeTransfer.OwnerId,'Expected value is'+systemUser.id+', but actual value is'+leadRecBeforeTransfer.OwnerId);
        System.assertEquals(cccLUser.id, leadRecBeforeTransfer.AssignedTo__c,'Expected value is'+cccLUser.id+', but actual value is'+leadRecBeforeTransfer.AssignedTo__c);

        LeadMetrics__c ldMetricRecBeforeTransfer = [SELECT Id, OwnerId, AssignedTo__c, LeadTransferredBy__c FROM LeadMetrics__c WHERE LeadSfdcId__c = :leadRecBeforeTransfer.id LIMIT 1];
        System.assertEquals(systemUser.id, ldMetricRecBeforeTransfer.OwnerId,'Expected value is'+systemUser.id+', but actual value is'+ldMetricRecBeforeTransfer.OwnerId);
        System.assertEquals(cccLUser.id, ldMetricRecBeforeTransfer.AssignedTo__c,'Expected value is'+cccLUser.id+', but actual value is'+ldMetricRecBeforeTransfer.AssignedTo__c);
        System.assert(String.isBlank(ldMetricRecBeforeTransfer.LeadTransferredBy__c),'Expected Lead Transferred By should be blank');

        System.runAs(batchProcIdUser) {
            Test.StartTest();
            Database.executeBatch(new Batch_TransferLead(buildLeadTransferQuery(), leadTransferCustomSettingRecord), 30);
            Test.stopTest();
        }

        Lead leadRecAfterUpdate = [SELECT Id, OwnerId, AssignedTo__c FROM Lead WHERE id = :leadRecBeforeTransfer.id LIMIT 1];
        System.assertEquals(proxyUser.id, leadRecAfterUpdate.OwnerId,'Expected OwnerId value is'+proxyUser.id+', but actual value is'+leadRecAfterUpdate.OwnerId);
        System.assert(String.isBlank(leadRecAfterUpdate.AssignedTo__c),'Assigned To should be blank');

        LeadMetrics__c ldMetricRecAfterTransfer = [SELECT Id, OwnerId, AssignedTo__c, LeadTransferredBy__c FROM LeadMetrics__c WHERE LeadSfdcId__c = :leadRecBeforeTransfer.id LIMIT 1];
        System.assertEquals(proxyUser.id, ldMetricRecAfterTransfer.OwnerId,'Expected OwnerId value is'+proxyUser.id+', but actual value is'+ldMetricRecAfterTransfer.OwnerId);
        System.assert(String.isBlank(ldMetricRecAfterTransfer.AssignedTo__c),'Assigned To should be blank');
        System.assertEquals(batchProcIdUser.Id, ldMetricRecAfterTransfer.LeadTransferredBy__c,'Expected value is'+batchProcIdUser.Id+', but actual value is'+ldMetricRecAfterTransfer.LeadTransferredBy__c);

        Task insertedTask = [SELECT AppCode__c, Subject, Priority, Status, Task_Type__c, TaskCategory__c, Source__c, WhoId, OwnerId, RecordTypeId, 
                            AgentAssociateId__c, ActivityDate, Description FROM Task LIMIT 1 ];
        System.assertEquals('Lead Management', insertedTask.AppCode__c, 'Task App Code is Incorrect.');
        System.assertEquals('New Enterprise Facebook Lead', insertedTask.Subject, 'Task Subject is Incorrect.');
        System.assertEquals('None', insertedTask.Priority, 'Task Priority is Incorrect.');
        System.assertEquals('Not Started', insertedTask.Status, 'Task Status is Incorrect.');
        System.assertEquals('Sales', insertedTask.Task_Type__c, 'Task Type is Incorrect.');
        System.assertEquals('Marketing', insertedTask.TaskCategory__c, 'Task Category is Incorrect.');
        System.assertEquals('Marketing', insertedTask.Source__c, 'Task Source is Incorrect.');
        System.assertEquals(leadRecAfterUpdate.Id, insertedTask.WhoId, 'Task WhoId is Incorrect.');
        System.assertEquals(ldMetricRecAfterTransfer.OwnerId, insertedTask.OwnerId, 'Task OwnerId is Incorrect.');
        System.assertEquals(taskRecordTypeId, insertedTask.RecordTypeId, 'Task Record Type is Incorrect.');
        System.assertEquals('20ccww22zzc', insertedTask.AgentAssociateId__c, 'Task Agent Associate Id is Incorrect.');
        System.assertEquals(Date.Today(), insertedTask.ActivityDate, 'Task Activity Date is Incorrect.');
        System.assertEquals('Test Description', insertedTask.Description, 'Task Description is Incorrect.');
    }
}