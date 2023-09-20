/**
 * @Name: HLPR_OppCreateOnLeadConversion_TEST
 * @Author: Golden Spikes Team
 * @description : This class contains unit tests for validating Opportunity Creation on Lead Conversion
 *
 */
@IsTest(seeAllData=false)
private class HLPR_OppCreateOnLeadConversion_TEST {
    private static Map<String, Schema.Recordtypeinfo> leadRecordTypeMap = Schema.Sobjecttype.Lead.getRecordTypeInfosByDeveloperName();
    private static final String INTERNET_LEAD_PROVIDER_QUOTE_WIZARD_SOURCE = 'Internet Lead Provider - QuoteWizard';

    @TestSetup private static void setUpUserData() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User sysAdminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'OppAdm' + UTIL_TestUsername_TEST.getTestUsername());
        insert sysAdminUser;
        System.runAs(sysAdminUser) {
            insert new CS001_ByPassTriggerAll__c(Override_All__c = false);
            UserRole agentUserRole = new UserRole(name = 'AgentRole');
            insert agentUserRole;
            UserRole proxyUserRole = new UserRole(name = 'ProxyRole', parentRoleId = agentUserRole.id);
            insert proxyUserRole;
            User testProxyUser1 = new User(Alias='Prox',LastName='prefAgnt',Username='OppPrx' + UTIL_TestUsername_TEST.getTestUsername(),UserExternalID__c='190cww22zzcP',Servicing_Agent_Associate_ID__c='190cww22zzc');
            User proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;
            User testAgentUser1 = new User(Alias='OpMt',LastName='prefPrxy',Username='OppAgt' + UTIL_TestUsername_TEST.getTestUsername(),Associate_ID__c='190cww22zzc',UserExternalID__c='190cww22zzc_190cww22zzc',Servicing_Agent_Associate_ID__c='190cww22zzc');
            User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;

            User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
            insert systemUser;
            AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(Name = 'State Farm', SFDC_USER_ID__c = systemUser.id );
            insert sysAdminUserIdSetting;
            Account testAccount = new Account(FirstName = 'TestFName', LastName = 'TestLeadByPassAll', BillingAddressType__c = 'US', ClientIdentifier__c = 'SFFSP81L8XB');
            insert testAccount;
            AgentRole__c agentRole = new AgentRole__c(customer__c = testAccount.id, agent__c = agentUser.id);
            insert agentRole;

            Lead partialLeadRecord = new Lead(AgentAssociateId__c = '190cww22zzc', OwnerId = proxyUser.Id, External_Lead_ID__c = 'P1234', LastName = 'TestPartialLead', Status = 'Open',
                LeadSource = 'Enterprise Facebook Lead', MultiLOB__c = 'Auto', DateCaptured__c = System.today(), RecordTypeId = leadRecordTypeMap.get('PartialLead').getRecordTypeId(), SCode__c = '12345');
            insert partialLeadRecord;

            Lead ilpPartialLeadRecord = new Lead(AgentAssociateId__c = '190cww22zzc', OwnerId = proxyUser.Id, External_Lead_ID__c = 'P1235', LastName = 'TestPartialLead', Status = 'Open', VendorId__c = '5A59AB5E-9033-4E70-9795-E11C240B2EE7',
                LeadSource = INTERNET_LEAD_PROVIDER_QUOTE_WIZARD_SOURCE, MultiLOB__c = 'Auto', DateCaptured__c = System.today(), RecordTypeId = leadRecordTypeMap.get('PartialLead').getRecordTypeId(), SCode__c = '12345');
            insert ilpPartialLeadRecord;

            insert new CS_StageOrchestration_Counts__c(Retry_Count__c = 3, Chunk_Size__c = 5);

            User cccLUser = UTIL_UserProvisioning_TEST.buildCCCLicensedUser();
            cccLUser.UserExternalID__c = 'OpCretCCC';
            insert cccLUser;
        }
    }

    @isTest private static void testHandleOpportunitiesAsCCCUserForILP() {
        System.runAs(getCCCUser()) {
            HLPR_OppCreateOnLeadConversion.OpportunityCreateRequest opportunityCreateRequest = new HLPR_OppCreateOnLeadConversion.OpportunityCreateRequest();
            Lead partialLeadRecord = [SELECT Id, AgentAssociateId__c, leadSource, ownerId, DateCaptured__c, VendorId__c, MultiLOB__c, SCode__c, RecordType.DeveloperName, External_Lead_ID__c FROM Lead WHERE External_Lead_ID__c = 'P1235'];
            Account testAccount = [SELECT id, FirstName, LastName, ClientIdentifier__c FROM account WHERE ClientIdentifier__c = 'SFFSP81L8XB' LIMIT 1];                       
            opportunityCreateRequest.leadRecord = partialLeadRecord;
            opportunityCreateRequest.actId = testAccount.Id;
            opportunityCreateRequest.lobValues = '[{"keyField":"1","selectedLineOfBusiness":"Auto","selectedEffectiveDate":"2022-06-15","selectedProduct":{"productDescription":"Motorcycle","productSystemName":"MOTORCYCLE"}}]';
            opportunityCreateRequest.campaignId = null;
            opportunityCreateRequest.loggedInUserSubUserType = 'CCC Sales';
            opportunityCreateRequest.stateCode = 'IL/ 17-2345';
            Test.startTest();
            List<Opportunity> convertedOpportunityIdsList = HLPR_OppCreateOnLeadConversion.createOpportunities(opportunityCreateRequest, testAccount);
            System.assertEquals(1, convertedOpportunityIdsList.size(), 'Invalid convertedOpportunityIdsList');
            validateCreatedOpportunityOnLeadConversion(testAccount, opportunityCreateRequest, 'Customer Care Center');
            Test.stopTest();
        }
    }

    @isTest private static void testHandleOpportunitiesAsCCCUser() {
        System.runAs(getCCCUser()) {
            HLPR_OppCreateOnLeadConversion.OpportunityCreateRequest opportunityCreateRequest = new HLPR_OppCreateOnLeadConversion.OpportunityCreateRequest();
            Lead partialLeadRecord = [SELECT Id, AgentAssociateId__c, leadSource, ownerId, DateCaptured__c, VendorId__c, MultiLOB__c, SCode__c, RecordType.DeveloperName, External_Lead_ID__c FROM Lead WHERE External_Lead_ID__c = 'P1234'];
            Account testAccount = [SELECT id, FirstName, LastName, ClientIdentifier__c FROM account WHERE ClientIdentifier__c = 'SFFSP81L8XB' LIMIT 1];
            opportunityCreateRequest.leadRecord = partialLeadRecord;
            opportunityCreateRequest.actId = testAccount.Id;
            opportunityCreateRequest.lobValues = '[{"keyField":"1","selectedLineOfBusiness":"Auto","selectedEffectiveDate":"2022-06-15","selectedProduct":{"productDescription":"Motorcycle","productSystemName":"MOTORCYCLE"}}]';
            opportunityCreateRequest.loggedInUserSubUserType = 'CCC Sales';
            opportunityCreateRequest.campaignId = null;
            opportunityCreateRequest.stateCode = 'IL/ 17-2345';
            Test.startTest();
            List<Opportunity> convertedOpportunityIdsList = HLPR_OppCreateOnLeadConversion.createOpportunities(opportunityCreateRequest, testAccount);
            System.assertEquals(1, convertedOpportunityIdsList.size(), 'Invalid convertedOpportunityIdsList');
            validateCreatedOpportunityOnLeadConversion(testAccount, opportunityCreateRequest, 'Customer Care Center');
            Test.stopTest();
        }
    }

    @isTest private static void testHandleOpportunitiesAsAgentUser() {
        System.runAs(getAgentUser()) {
            HLPR_OppCreateOnLeadConversion.OpportunityCreateRequest opportunityCreateRequest = new HLPR_OppCreateOnLeadConversion.OpportunityCreateRequest();
            Lead partialLeadRecord = [SELECT Id, AgentAssociateId__c, leadSource, ownerId, DateCaptured__c, VendorId__c, MultiLOB__c, SCode__c, RecordType.DeveloperName, External_Lead_ID__c FROM Lead WHERE External_Lead_ID__c = 'P1234'];
            Account testAccount = [SELECT id, FirstName, LastName, ClientIdentifier__c FROM account WHERE ClientIdentifier__c = 'SFFSP81L8XB' LIMIT 1];
            opportunityCreateRequest.leadRecord = partialLeadRecord;
            opportunityCreateRequest.actId = testAccount.Id;
            opportunityCreateRequest.lobValues = '[{"keyField":"1","selectedLineOfBusiness":"Auto","selectedEffectiveDate":"2022-06-15","selectedProduct":{"productDescription":"Motorcycle","productSystemName":"MOTORCYCLE"}}]';
            opportunityCreateRequest.loggedInUserSubUserType = 'Agent';
            opportunityCreateRequest.campaignId = null;
            opportunityCreateRequest.stateCode = 'IL/ 17-2345';
            Test.startTest();
            List<Opportunity> convertedOpportunityIdsList = HLPR_OppCreateOnLeadConversion.createOpportunities(opportunityCreateRequest, testAccount);
            System.assertEquals(1, convertedOpportunityIdsList.size(), 'Invalid convertedOpportunityIdsList');
            validateCreatedOpportunityOnLeadConversion(testAccount, opportunityCreateRequest, 'Agent/Team Member');
            Test.stopTest();
        }
    }

    @SuppressWarnings('PMD.ApexUnitTestMethodShouldHaveIsTestAnnotation')
    private static void validateCreatedOpportunityOnLeadConversion(Account testAccount, HLPR_OppCreateOnLeadConversion.OpportunityCreateRequest opportunityCreateRequest, String opportunityOriginator) {
        CMOpportunityMapping__mdt optyMappingMetaData = [SELECT LeadSource__c, OpportunityOriginator__c, MarketingSource__c, MarketingSubSource__c
            FROM CMOpportunityMapping__mdt WHERE MappingType__c = 'Lead Conversion' AND LeadSource__c = : opportunityCreateRequest.leadRecord.LeadSource LIMIT 1];
        Opportunity convertedOptyRecord = [SELECT Id, Recordtype.DeveloperName, OwnerId, CloseDate, StageName,
                AccountId, Name, LOB__c, Product__c, EventCode__c, EventName__c, LeadType__c, Vendor_ID__c, ExternalILPId__c, LeadSource,
                Opportunity_Originator__c, Marketing_Source__c, DateCaptured__c, Marketing_Sub_Source__c, Assigned_To__c, ExternalID__c, CampaignId,
                Lead_ID__c, State_Code__c, Requested_Effective_Date__c, Product_System_Name__c FROM Opportunity WHERE AccountId = :testAccount.Id];
        System.assertEquals('Opportunity_Management', convertedOptyRecord.RecordType.DeveloperName, 'Invalid Opportunity Record Type');
        System.assertEquals(opportunityOriginator, convertedOptyRecord.Opportunity_Originator__c, 'Invalid Opportunity Originator');
        System.assertEquals(optyMappingMetaData.MarketingSource__c, convertedOptyRecord.Marketing_Source__c, 'Invalid Opportunity Marketing Source');
        System.assertEquals(optyMappingMetaData.MarketingSubSource__c, convertedOptyRecord.Marketing_Sub_Source__c, 'Invalid Opportunity Marketing Sub Source');
        System.assertEquals('Auto', convertedOptyRecord.LOB__c, 'Invalid Opportunity LOB');
        System.assertEquals('Motorcycle', convertedOptyRecord.Product__c, 'Invalid Opportunity Product');
        System.assertEquals('Quoting', convertedOptyRecord.StageName, 'Invalid Opportunity Stage Name');
        System.assertEquals('Auto-' + testAccount.FirstName + ' ' + testAccount.LastName, convertedOptyRecord.Name, 'Invalid Opportunity Name');
        System.assertEquals('MOTORCYCLE', convertedOptyRecord.Product_System_Name__c, 'Invalid Product System Name');
        System.assertEquals(Date.today() + 60, convertedOptyRecord.CloseDate, 'Invalid Opportunity CloseDate');
        System.assertEquals(testAccount.Id, convertedOptyRecord.AccountId, 'Invalid Opportunity Account Id');
        System.assertEquals(opportunityCreateRequest.leadRecord.SCode__c, convertedOptyRecord.EventCode__c, 'Invalid Opportunity Event Code');
        System.assertEquals(opportunityCreateRequest.leadRecord.VendorId__c, convertedOptyRecord.ExternalILPId__c, 'Invalid Opportunity External ILP Id');
        System.assertEquals(opportunityCreateRequest.leadRecord.LeadSource, convertedOptyRecord.LeadSource, 'Invalid Opportunity Lead Source');
        //System.assertEquals(opportunityCreateRequest.leadRecord.DateCaptured__c, convertedOptyRecord.DateCaptured__c, 'Invalid Opportunity Date Captured');
        System.assertEquals(Date.valueOf('2022-06-15'), convertedOptyRecord.Requested_Effective_Date__c, 'Invalid Requested Effective Date');
        System.assertEquals(opportunityCreateRequest.stateCode, convertedOptyRecord.State_Code__c, 'Invalid State Agent Code');
        if(INTERNET_LEAD_PROVIDER_QUOTE_WIZARD_SOURCE.equals(opportunityCreateRequest.leadRecord.LeadSource)) {
            System.assertEquals('AUTOSTDUSL', convertedOptyRecord.LeadType__c, 'Invalid Opportunity Lead Type');
            System.assertEquals('ILP1', convertedOptyRecord.Vendor_ID__c, 'Invalid Opportunity Vendor Id');    
        }
        System.assertEquals(opportunityCreateRequest.leadRecord.External_Lead_ID__c, convertedOptyRecord.ExternalID__c, 'Invalid Opportunity External Id');
        System.assertEquals(opportunityCreateRequest.leadRecord.Id, convertedOptyRecord.Lead_ID__c, 'Invalid Converted Lead Id');
        System.assertEquals(opportunityCreateRequest.leadRecord.OwnerId, convertedOptyRecord.OwnerId, 'Invalid Opportunity Owner Id');
    }

    private static User getCCCUser() {
        return [SELECT Id FROM User WHERE UserExternalId__c = 'OpCretCCC' LIMIT 1];
    }

    private static User getAgentUser() {
        return [SELECT Id FROM User WHERE UserExternalId__c = '190cww22zzc_190cww22zzc' LIMIT 1];
    }
}
