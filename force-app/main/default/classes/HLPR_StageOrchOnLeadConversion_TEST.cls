/**
 * @Name: HLPR_StageOrchOnLeadConversion_TEST
 * @Author: Golden Spikes Team
 * @description : This class contains unit tests for validating the Stage Orchestration on Lead Conversion
 *
 */
@IsTest(seeAllData=false)
private class HLPR_StageOrchOnLeadConversion_TEST {
    private static Map<String, Schema.Recordtypeinfo> leadRecordTypeMap = Schema.Sobjecttype.Lead.getRecordTypeInfosByDeveloperName();

    @TestSetup private static void setUpUserData() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User sysAdminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'sysAdm' + UTIL_TestUsername_TEST.getTestUsername());
        insert sysAdminUser;

        System.runAs(sysAdminUser) {
            insert new CS001_ByPassTriggerAll__c(Override_All__c = false);
            UserRole agentUserRole = new UserRole(name = 'AgentRole');
            insert agentUserRole;
            UserRole proxyUserRole = new UserRole(name = 'ProxyRole', parentRoleId = agentUserRole.id);
            insert proxyUserRole;
            User testProxyUser1 = new User(Alias='Prox',LastName='prefAgnt',Username='PrxCon' + UTIL_TestUsername_TEST.getTestUsername(),UserExternalID__c='190cww22zzcP',Servicing_Agent_Associate_ID__c='190cww22zzc');
            User proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;
            User testAgentUser1 = new User(Alias='Alia',LastName='prefPrxy',Username='AgtCon' + UTIL_TestUsername_TEST.getTestUsername(),Associate_ID__c='190cww22zzc',UserExternalID__c='190cww22zzc_190cww22zzc',Servicing_Agent_Associate_ID__c='190cww22zzc');
            User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(Name = 'State Farm', SFDC_USER_ID__c = systemUser.id);
            insert sysAdminUserIdSetting;

            Account testAccount = new Account(FirstName = 'TestFName', LastName = 'TestLeadByPassAll', BillingAddressType__c = 'US', ClientIdentifier__c = 'SFFSP81L8XB');
            insert testAccount;
            AgentRole__c agentRole = new AgentRole__c(customer__c = testAccount.id, agent__c = agentUser.id);
            insert agentRole;

            Lead partialLeadRecord = new Lead(AgentAssociateId__c = '190cww22zzc', OwnerId = proxyUser.Id, External_Lead_ID__c = 'P1234',
                LastName = 'TestPartialLead', Status = 'Open', LeadSource = 'Enterprise Facebook Lead', DateCaptured__c = System.today(),
                RecordTypeId = leadRecordTypeMap.get('PartialLead').getRecordTypeId(), SCode__c = '12345');
            insert partialLeadRecord;
            insert new CS_StageOrchestration_Counts__c(Retry_Count__c = 3, Chunk_Size__c = 5);
        }
    }

    @isTest private static void testCreateStageOrchestrationAsAgent() {
        System.runAs(getAgentUser()) {
            Lead partialLeadRecord = [SELECT Id, AgentAssociateId__c, leadSource, ownerId, DateCaptured__c, SCode__c, RecordType.DeveloperName FROM Lead WHERE External_Lead_ID__c = 'P1234'];
            Account testAccount = [SELECT Id, FirstName, LastName, ClientIdentifier__c FROM account WHERE ClientIdentifier__c = 'SFFSP81L8XB' LIMIT 1];
            Test.startTest();
            List<StageOrchestration__c> stageOrchestrationListBefore = [SELECT id FROM StageOrchestration__c WHERE TransactionType__c = 'Conversion Lead Details'];
            System.assertEquals(0, stageOrchestrationListBefore.size(), 'StageOrchestration did not return correct size');
            HLPR_StageOrchestrationOnLeadConversion.createstageOrchestrationRecord(partialLeadRecord.Id, testAccount);
            List<StageOrchestration__c> stageOrchestrationListAfter = [SELECT Id, TransactionType__c, VersionNumber__c, IdentifierType__c, 
                IdentifierValue__c, CallingApplication__c, Value__c FROM StageOrchestration__c WHERE TransactionType__c = 'Conversion Lead Details'];
            System.assertEquals(1, stageOrchestrationListAfter.size(), 'StageOrchestration did not return correct size');
            System.assertEquals('Conversion Lead Details', stageOrchestrationListAfter.get(0).TransactionType__c, 'Invalid Stage Orchestration Transaction Type');
            System.assertEquals(1.0, stageOrchestrationListAfter.get(0).VersionNumber__c, 'Invalid Stage Orchestration Version Number');
            System.assertEquals('Client Identifier', stageOrchestrationListAfter.get(0).IdentifierType__c, 'Invalid Stage Orchestration Identifier Type');
            System.assertEquals(testAccount.ClientIdentifier__c, stageOrchestrationListAfter.get(0).IdentifierValue__c, 'Invalid Stage Orchestration Client Identifier');
            System.assertEquals('Salesforce.com', stageOrchestrationListAfter.get(0).CallingApplication__c, 'Invalid Stage Orchestration Calling Application');
            System.assert(String.isNotBlank(stageOrchestrationListAfter.get(0).Value__c), 'Invalid Stage Orchestration Value');
            Test.stopTest();
        }
    }

    private static User getAgentUser() {
        return [SELECT Id FROM User WHERE UserExternalId__c = '190cww22zzc_190cww22zzc' LIMIT 1];
    }
}
