/**
 * @Name: HLPR_CreateLeadService
 * Author : Golden Spikes Team
 * @description : Test class for HLPR_CreateLeadService apex class.
 */
@isTest(SeeAllData=false)
private class HLPR_CreateLeadService_TEST {
    //Account Constants
    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();
    private static final String STAGE_NAME = 'New';
    private static Map<String, Schema.Recordtypeinfo> leadRecordTypeMap = Schema.Sobjecttype.Lead.getRecordTypeInfosByDeveloperName();
    private static String taskRecordTypeId = Schema.Sobjecttype.Task.getRecordTypeInfosByDeveloperName().get('Task').getRecordTypeId();
    private static final String EVENT_LEAD_SERVICE_PERM_SET = 'SF_CRM_EventLeadOppMgmt_PermSetPID';

    @TestSetup
    private static void setUpUserData() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User agentUserCreate;
        CS001_ByPassTriggerAll__c byPassingAllTrigger;
        User systemAdminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'sysemAdmin', 'LdCrAdm' + UTIL_TestUsername_TEST.getTestUsername());
        insert systemAdminUser;
        System.runAs(systemAdminUser) {
            byPassingAllTrigger = new CS001_ByPassTriggerAll__c(Override_All__c = true);
            insert byPassingAllTrigger;
            User systemUserCreate = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
            insert systemUserCreate;
            AccountOwnerSystemUserCustomSetting__c systemAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUserCreate.Id);
            insert systemAdminUserIdSetting;
            UserRole agentUserRoleCreate = new UserRole(name = 'AgentRole');
            insert agentUserRoleCreate;
            UserRole proxyUserRoleCreate = new UserRole(name = 'ProxyRole', parentRoleId = agentUserRoleCreate.id);
            insert proxyUserRoleCreate;
            User testAgentUser11 = new User(Alias='CdLd',LastName='CdLd7',Username='CdLd' + UTIL_TestUsername_TEST.getTestUsername(),Associate_ID__c='11d11122zzc',UserExternalID__c='11d11122zzc_11d11122zzc',Servicing_Agent_Associate_ID__c='11d11122zzc');
            agentUserCreate = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser11);
            agentUserCreate.userRoleId = agentUserRoleCreate.id;
            insert agentUserCreate;
            User procIdUserCreate = UTIL_UserProvisioning_TEST.buildUserAPIDataAdmin('ev1tLd1PrId1Us123@sfa222.test.com');
            insert procIdUserCreate;
            User testProxyUser11 = new User(Alias='LdMt',LastName='LdAgnt',Username='LdPrx' + UTIL_TestUsername_TEST.getTestUsername(),UserExternalID__c='11d11122zzcP',Servicing_Agent_Associate_ID__c='11d11122zzc'); 
            User proxyUserCreate = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser11);
            proxyUserCreate.userRoleId = proxyUserRoleCreate.id;
            insert proxyUserCreate;
            PermissionSet queryThePermissionSet = [SELECT id FROM PermissionSet WHERE Name = :EVENT_LEAD_SERVICE_PERM_SET LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = procIdUserCreate.id, PermissionSetId = queryThePermissionSet.id);
            CS001_ByPassTriggerAll__c passingTriggerAll = [SELECT Override_All__c FROM CS001_ByPassTriggerAll__c];
            passingTriggerAll.Override_All__c = false;
            update passingTriggerAll;
            User testCCCLicenUserCreate = new User(Alias='LDC1',LastName='LastName',Username='CCC' + UTIL_TestUsername_TEST.getTestUsername(),Associate_ID__c='CCCASSO1234',UserExternalID__c='CCCASSO1234');
            UTIL_UserProvisioning_TEST.buildCCCLicensedUserMethod(testCCCLicenUserCreate);
            createIndividualAccount(agentUserCreate.Id);
            Lead partialLeadRecord = new Lead(AgentAssociateId__c = '190cww22zzc', OwnerId = proxyUserCreate.Id,
                External_Lead_ID__c = 'P1234', LastName = 'TestPartialLead', Status = 'Open', LeadSource = 'Enterprise Facebook Lead', 
                DateCaptured__c = System.today(), RecordTypeId = leadRecordTypeMap.get('PartialLead').getRecordTypeId(), SCode__c = '12345');
            insert partialLeadRecord;
        }
    }

    //method to test the opprortunity request for Partial Lead - Enterprise Facebook Lead
    @isTest private static void testBuildOpportunityForFBPartialLead() {
        User procIdUserCreate = [SELECT id FROM User WHERE username = 'ev1tLd1PrId1Us123@sfa222.test.com' LIMIT 1];
        Account testAccount = [SELECT id, FirstName, LastName, ClientIdentifier__c FROM account WHERE ClientIdentifier__c = 'SFFSP81L8XB' LIMIT 1];
        CMOpportunityMapping__mdt optyMappingMDT = [SELECT Description__c, ExternalLeadSource__c, LeadSource__c, OpportunityOriginator__c,
            MarketingSource__c, MarketingSubSource__c FROM CMOpportunityMapping__mdt WHERE MappingType__c = 'External Lead Service' 
            AND ExternalLeadSource__c = 'FB' LIMIT 1];
        HLPR_CreateLeadRequest.LeadOpportunity opportunity = new HLPR_CreateLeadRequest.LeadOpportunity();
        opportunity.externalLeadSource = 'FB';
        opportunity.name = 'Auto-TestFName TestLName';
        opportunity.lob = 'Auto';
        opportunity.product = 'Private Passenger';
        opportunity.eventCode = 'S17377';
        opportunity.eventName = 'Test Event';
        opportunity.sourceComments = 'Test Comment';
        opportunity.submittedPhone = '2223334444';
        opportunity.submittedEmail = 'agt7@statefarm.com';
        HLPR_CreateLeadService.OpportunityRequest request = new HLPR_CreateLeadService.OpportunityRequest();
        request.ldOpportunity = opportunity;
        request.accountId = testAccount.Id;
        request.agentAssoicateId = '11d11122zzc';
        request.ldSourceMapping = optyMappingMDT;
        Opportunity newOpty;
        System.runAs(procIdUserCreate) {
            Test.starttest();
            newOpty = HLPR_CreateLeadService.buildOpportunity(request);
            Test.stoptest();
            System.assertEquals(testAccount.Id, newOpty.AccountId, 'Opportunity Account is Incorrect');
            System.assertEquals(STAGE_NAME, newOpty.StageName, 'Opportunity StageName is Incorrect.');
            System.assertEquals('Auto-TestFName TestLName', newOpty.Name, 'Opportunity Name is Incorrect.');
            System.assertEquals('Auto', newOpty.LOB__c, 'Account Client Identifier is Incorrect.');
            System.assertEquals('Private Passenger', newOpty.Product__c, 'Opportunity Product is Incorrect.');
            System.assertEquals('S17377', newOpty.EventCode__c, 'Opportunity Event Code is Incorrect.');
            System.assertEquals('Test Event', newOpty.EventName__c, 'Opportunity Event Name is Incorrect.');
            System.assertEquals('Test Comment', newOpty.Source_Comments__c, 'Opportunity Source Comments is Incorrect.');
            System.assertEquals(optyMappingMDT.MarketingSource__c, newOpty.Marketing_Source__c, 'Opportunity Marketing Source is Incorrect.');
            System.assertEquals(optyMappingMDT.MarketingSubSource__c, newOpty.Marketing_Sub_Source__c, 'Opportunity Marketing Sub Source is Incorrect.');
            System.assertEquals(optyMappingMDT.OpportunityOriginator__c, newOpty.Opportunity_Originator__c, 'Opportunity Originator is Incorrect.');
            System.assertEquals('2223334444', newOpty.Phone__c, 'Opportunity Phone is Incorrect.');
            System.assertEquals('agt7@statefarm.com', newOpty.Email__c, 'Opportunity Submitted Email is Incorrect.');
        }
    }

    //method to test the Partial Lead scenario
    @isTest private static void testBuildTaskForFBPartialLead() {
        User procIdUserCreate = [SELECT id FROM User WHERE username = 'ev1tLd1PrId1Us123@sfa222.test.com' LIMIT 1];
        User proxyUserCreate = [SELECT id FROM User WHERE UserExternalId__c = '11d11122zzcP' LIMIT 1];
        Lead partialLeadRecord = [SELECT Id,Description, AgentAssociateId__c, leadSource, ownerId, DateCaptured__c, SCode__c, 
            RecordType.DeveloperName FROM Lead WHERE External_Lead_ID__c = 'P1234'];
        Task insertedTask;
        System.runAs(procIdUserCreate) {
            Test.starttest();
            insertedTask = HLPR_CreateLeadService.buildTask(partialLeadRecord);
            Test.stoptest();
            System.assertEquals('Lead Management', insertedTask.AppCode__c, 'Task App Code is Incorrect.');
            System.assertEquals('New Enterprise Facebook Lead', insertedTask.Subject, 'Task Subject is Incorrect.');
            System.assertEquals('None', insertedTask.Priority, 'Task Priority is Incorrect.');
            System.assertEquals('Not Started', insertedTask.Status, 'Task Status is Incorrect.');
            System.assertEquals('Sales', insertedTask.Task_Type__c, 'Task Type is Incorrect.');
            System.assertEquals('Marketing', insertedTask.TaskCategory__c, 'Task Category is Incorrect.');
            System.assertEquals('Marketing', insertedTask.Source__c, 'Task Source is Incorrect.');
            System.assertEquals(partialLeadRecord.Id, insertedTask.WhoId, 'Task WhoId is Incorrect.');
            System.assertEquals(proxyUserCreate.Id, partialLeadRecord.OwnerId, 'Task OwnerId is Incorrect.');
            System.assertEquals(taskRecordTypeId, insertedTask.RecordTypeId, 'Task Record Type is Incorrect.');
            System.assertEquals(Date.Today(), insertedTask.ActivityDate, 'Task Activity Date is Incorrect.');
        }
    }

    //method to test the Partial Lead - LeadMetrics scenario
    @isTest private static void testBuildLeadMetricsForFBPartialLead() {
        User procIdUserCreate = [SELECT id FROM User WHERE username = 'ev1tLd1PrId1Us123@sfa222.test.com' LIMIT 1];
        Lead partialLeadRecord = [SELECT Id, Name, OriginalLeadSource__c, SourcedFromCCC__c, MultiLOB__c, Product__c, Description, 
            CreatedById, CreatedDate, AgentAssociateId__c, leadSource, ownerId, DateCaptured__c, Status, SCode__c, External_Lead_ID__c, 
            RecordType.DeveloperName, LeadScore__c, LeadTemperature__c, State FROM Lead WHERE External_Lead_ID__c = 'P1234'];
        LeadMetrics__c newLeadMetrics;
        System.runAs(procIdUserCreate) {
            Test.starttest();
            newLeadMetrics = HLPR_CreateLeadService.buildCreateLeadMetrics(partialLeadRecord);
            Test.stoptest();
            System.assertEquals(partialLeadRecord.Id, newLeadMetrics.LeadSfdcId__c, 'Salesforce Lead Id is Incorrect');
            System.assertEquals(partialLeadRecord.External_Lead_ID__c, newLeadMetrics.ExternalLeadId__c, 'External Lead Id is Incorrect');
            System.assertEquals(partialLeadRecord.Name, newLeadMetrics.LeadName__c, 'Lead Name is Incorrect');
            System.assertEquals('Partial Lead', newLeadMetrics.LeadRecordType__c, 'Lead Record Type is Incorrect');
            System.assertEquals('Enterprise Facebook Lead', newLeadMetrics.OriginalLeadSource__c, 'Original Lead Source is Incorrect');
            System.assertEquals(partialLeadRecord.ownerId, newLeadMetrics.OwnerId, 'Lead Metric Owner is Incorrect');
            System.assert(newLeadMetrics.LeadCreatedDate__c != null, 'Lead Metric CreatedDate is Incorrect');
            System.assertEquals(partialLeadRecord.LeadScore__c, newLeadMetrics.LeadScore__c, 'Lead Score is Incorrect');
            System.assertEquals(partialLeadRecord.LeadTemperature__c, newLeadMetrics.LeadTemperature__c, 'Lead Temperature is Incorrect');
        }
    }
/**
 * @description createIndividualAccount
 * @param agentUserId 
 * @return  `Account`
 */
    public static Account createIndividualAccount(String agentUserId) {
        Account act = new Account(ClientIdentifier__c = 'SFFSP81L8XB', FirstName = 'TestFName', LastName = 'TestLName', RecordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId);
        insert act;
        insert new AgentRole__c(RelationshipNature__c = 'Customer', Agent__c = agentUserId, Customer__c = act.Id);
        return act;
    }
}
