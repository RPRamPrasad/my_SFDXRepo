/**
 * @Name: LeadCCCHandler_TEST
 * @Author: Golden Spikes Team
 * @description : This class contains unit tests for Lead CCC routing.
 */
@isTest(SeeAllData=false)
private class LeadCCCHandler_TEST {
    private static Map<String, Schema.Recordtypeinfo> leadRecordTypeMap = Schema.Sobjecttype.Lead.getRecordTypeInfosByDeveloperName();
    private static final String EVENT_LEAD_SERVICE_PERM_SET = 'SF_CRM_EventLeadOppMgmt_PermSetPID';

    @TestSetup
    private static void setUpUserData() {
        User agentUser;
        CS001_ByPassTriggerAll__c byPassAllTrigger;
        User adminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'sysemAdmin', 'LdCrAdm' + UTIL_TestUsername_TEST.getTestUsername());
        insert adminUser;
        System.runAs(adminUser) {
            byPassAllTrigger = new CS001_ByPassTriggerAll__c(Override_All__c = true);
            insert byPassAllTrigger;
            UserRole agentUserRole = new UserRole(name = 'AgentRole');
            insert agentUserRole;
            UserRole proxyUserRole = new UserRole(name = 'ProxyRole', parentRoleId = agentUserRole.id);
            insert proxyUserRole;
            User testAgentUser1 = new User(Alias='CrLd',LastName='CrLd1',Username='CrLd' + UTIL_TestUsername_TEST.getTestUsername(),Associate_ID__c='11d11122zzc',UserExternalID__c='11d11122zzc_11d11122zzc',Servicing_Agent_Associate_ID__c='11d11122zzc');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;
            User testProxyUser1 = new User(Alias='LdMt',LastName='LdAgnt',Username='LdPrx' + UTIL_TestUsername_TEST.getTestUsername(),UserExternalID__c='11d11122zzcP',Servicing_Agent_Associate_ID__c='11d11122zzc');
            User proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;
            User procIdUser = UTIL_UserProvisioning_TEST.buildUserAPIDataAdmin('ev1tLd1PrId1Us123@sfa222.test.com');
            insert procIdUser;
            PermissionSet queryPermissionSet = [SELECT id FROM PermissionSet WHERE Name = :EVENT_LEAD_SERVICE_PERM_SET LIMIT 1];
            insert new PermissionSetAssignment(AssigneeId = procIdUser.id, PermissionSetId = queryPermissionSet.id);
            CS001_ByPassTriggerAll__c passTriggerAll = [SELECT Override_All__c FROM CS001_ByPassTriggerAll__c];
            passTriggerAll.Override_All__c = false;
            update passTriggerAll;
            Lead partialLeadRecord = new Lead(AgentAssociateId__c = '190cww22zzc', OwnerId = proxyUser.Id,
                External_Lead_ID__c = 'P1234', LastName = 'TestPartialLead', Status = 'Open', LeadSource = 'Enterprise Facebook Lead',
                DateCaptured__c = System.today(), RecordTypeId = leadRecordTypeMap.get('PartialLead').getRecordTypeId(), SCode__c = '12345');
            insert partialLeadRecord;
        }
    }

    @isTest private static void testIsCCCEligible() {
        User procIdUser = [SELECT id FROM User WHERE username = 'ev1tLd1PrId1Us123@sfa222.test.com' LIMIT 1];
        DateTime currentDateTime = Datetime.now();
        LeadCCCHandler.mockedCurrentDateTime = currentDateTime;
        insert new LeadSetting__c(Type__c = 'Transfer to CCC', Name = 'FB', Active__c = true,
        StartTime__c = (currentDateTime).time(), EndTime__c = currentDateTime.time(), Frequency__c = '1;2;3;4;5;6;7');
        System.runAs(procIdUser) {
            Test.starttest();
            try {
                System.assertEquals(true, LeadCCCHandler.isCCCEligible('FB'), 'Invalid CCC Eligible Flag');
                System.assertEquals(false, LeadCCCHandler.isCCCEligible('FB1'), 'Invalid CCC Eligible Flag');
            } catch (Exception e) {
                System.assert(false, 'Handle Lead Request Failed on Lead and Task Create');
            }
            Test.stoptest();
        }
    }

    @isTest private static void testForSendEmail() {
        User procIdUser = [SELECT id FROM User WHERE username = 'ev1tLd1PrId1Us123@sfa222.test.com' LIMIT 1];
        Lead partialLeadRecord = [SELECT Id, Name, FirstName, LastName, OriginalLeadSource__c, SourcedFromCCC__c, MultiLOB__c,
            Product__c, Description, CreatedById, CreatedDate, AgentAssociateId__c, leadSource, ownerId, DateCaptured__c, Status,
            SCode__c, External_Lead_ID__c, RecordType.DeveloperName FROM Lead WHERE External_Lead_ID__c = 'P1234'];
        insert new CSLeadBatch__c(Name = 'CCC Email Notification', 
            BatchEmailRecipient__c = 'home.ccc-acqu-leads-test.882o08@statefarm.com', SenderDisplayName__c = 'Leads Management');
        System.runAs(procIdUser) {
            Test.starttest();
            LeadCCCHandler.sendEmail(partialLeadRecord);
            Integer emailInvocations = Limits.getEmailInvocations();
            Test.stoptest();
            System.assertEquals(1, emailInvocations, 'Email has not been sent');
        }
    }
}
