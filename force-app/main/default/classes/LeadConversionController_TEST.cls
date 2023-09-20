/**
 * @Name: LeadConversionController_TEST
 * @Author: Golden Spikes Team
 * @description : This class contains unit tests for validating the behavior of Lead Conversion and Stage Orchestration
 *
 */
@IsTest(seeAllData=false)
private class LeadConversionController_TEST {
    private static Map<String, Schema.Recordtypeinfo> leadRecordTypeMap = Schema.Sobjecttype.Lead.getRecordTypeInfosByDeveloperName();
    private static Map<String, Schema.Recordtypeinfo> campaignRecordTypeMap = Schema.Sobjecttype.Campaign.getRecordTypeInfosByDeveloperName();

    @TestSetup
    private static void setUpUserData() {
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
            agentUser.SubUserType__c = 'Agent';
            insert agentUser;

            List<Campaign> cmpList = new List<Campaign>();
            Campaign testCamp = new Campaign(OwnerId = proxyUser.Id, Name = 'Lead Campaign', RecordTypeid = campaignRecordTypeMap.get('Lead_Campaign').RecordTypeId, Type = 'Lead');
            Campaign testCamp1 = new Campaign(OwnerId = proxyUser.Id, Name = 'Lead Campaign1', RecordTypeid = campaignRecordTypeMap.get('Lead_Campaign').RecordTypeId, Type = 'Lead');
            cmpList.add(testCamp);
            cmpList.add(testCamp1);
            insert cmpList;

            Lead leadRecord = new Lead(OwnerId = proxyUser.Id, External_Lead_ID__c = '1234', LastName = 'TestLeadByPassAll', Status = 'Open', 
                LeadSource = 'Lead Order', RecordTypeId = leadRecordTypeMap.get('Lead').RecordTypeId);
            insert leadRecord;

            CampaignMember newCampMember = new CampaignMember(CampaignId = cmpList[0].Id, LeadId = leadRecord.Id);
            CampaignMember newCampMember1 = new CampaignMember(CampaignId = cmpList[1].Id, LeadId = leadRecord.Id);
            List<CampaignMember> cmpMemberList = new List<CampaignMember>();
            cmpMemberList.add(newCampMember);
            cmpMemberList.add(newCampMember1);
            insert cmpMemberList;

            User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
            insert systemUser;
            AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(Name = 'State Farm', SFDC_USER_ID__c = systemUser.id);
            insert sysAdminUserIdSetting;

            Account testAccount = new Account(FirstName = 'TestFName', LastName = 'TestLeadByPassAll', BillingAddressType__c = 'US', ClientIdentifier__c = 'SFFSP81L8XB');
            insert testAccount;
            AgentRole__c agentRole = new AgentRole__c(customer__c = testAccount.id, agent__c = agentUser.id);
            insert agentRole;

            Lead partialLeadRecord = new Lead(AgentAssociateId__c = '190cww22zzc', OwnerId = proxyUser.Id,
                External_Lead_ID__c = 'P1234', LastName = 'TestPartialLead', Status = 'Open', VendorId__c = 'L478C9EE-E1A3-4E93-A0CC-83258F82694E',
                LeadSource = 'Enterprise Facebook Lead', MultiLOB__c = 'Fire', DateCaptured__c = System.today(),
                RecordTypeId = leadRecordTypeMap.get('PartialLead').getRecordTypeId(), SCode__c = '12345');
            insert partialLeadRecord;

            LeadMetrics__c ldMetrics = new LeadMetrics__c(LeadName__c = 'TestLeadByPassAll', LeadSfdcId__c = partialLeadRecord.Id, OwnerId = proxyUser.id);
            insert ldMetrics;

            insert new CS_StageOrchestration_Counts__c(Retry_Count__c = 3, Chunk_Size__c = 5);

            User cccLUser = UTIL_UserProvisioning_TEST.buildCCCLicensedUser();
            cccLUser.UserExternalID__c = 'LdConvCCC';
            insert cccLUser;

            insert new PermissionSetAssignment(
                AssigneeId = agentUser.id,
                PermissionSetId = [SELECT id FROM PermissionSet WHERE Name = 'CoreComponents_User_R' LIMIT 1].id);
        }
    }

    @isTest private static void testFetchLeadData() {
        System.runAs(getAgentUser()) {
            Lead leadRecord = [SELECT Id FROM Lead WHERE External_Lead_ID__c = '1234'];
            Test.startTest();
            LeadConversionController.ConvertLeadWrapper fetchLeadData = LeadConversionController.fetchLeadDataWrapper(leadRecord.Id);
            System.assertEquals(leadRecord.Id, fetchLeadData.leadRecord.Id, 'Lead data is not fetched properly');
            System.assert(!fetchLeadData.rtMapByName.isEmpty(), 'Invalid Account Record type map');
            System.assertEquals('Agent', fetchLeadData.subUserType, 'Invalid LoggedInUser Sub User Type');
            System.assertEquals('ECRM 3.0', fetchLeadData.appName, 'Invalid Application Name');
            Test.stopTest();
        }
    }

    //Test method to validate leadConversion and campaignMember removal
    @isTest private static void testConvertLeadCampaignRemoval() {
        System.runAs(getAgentUser()) {
            Account testAccount = [SELECT id, ClientIdentifier__c FROM account WHERE ClientIdentifier__c = 'SFFSP81L8XB' LIMIT 1];
            Lead leadRecord = [SELECT Id FROM Lead WHERE External_Lead_ID__c = '1234'];
            Test.startTest();
            LeadConversionController.convertLead(leadRecord.id, testAccount.id);
            Lead convertedLead = [SELECT IsConverted, ConvertedAccountId, lead.Status FROM Lead WHERE id = :leadRecord.Id LIMIT 1];
            System.assert(convertedLead.IsConverted, 'Failed on Lead Convert');
            System.assertEquals('Converted', convertedLead.Status, 'Invalid Lead Convert Status');
            System.assertEquals(testAccount.id, convertedLead.ConvertedAccountId, 'Invalid Converted Account Id');
            List<CampaignMember> campaignMemberList = [SELECT Id FROM CampaignMember WHERE LeadId = :leadRecord.id];
            System.assertEquals(0, campaignMemberList.size(), 'Campaing Member not removed');
            Test.stopTest();
        }
    }

    @isTest private static void testConvertLeadException() {
        System.runAs(getAgentUser()) {
            Lead leadRecord = [SELECT Id FROM Lead WHERE External_Lead_ID__c = '1234'];
            Test.startTest();
            List<ExceptionLog__c> exceptionLogBefore = [SELECT id FROM ExceptionLog__c WHERE Class__c = 'LeadConversionController'];
            System.assert(exceptionLogBefore.isEmpty(), 'Lead Conversion Exception Occured');
            LeadConversionController.convertLead(leadRecord.Id, null);
            List<ExceptionLog__c> exceptionLogAfter = [SELECT id FROM ExceptionLog__c WHERE Class__c = 'LeadConversionController'];
            System.assert(!exceptionLogAfter.isEmpty(), 'No Lead Conversion Exception Occurred');
            Test.stopTest();
        }
    }

    @isTest private static void testHandleOpportunitiesAsCCC() {
        System.runAs(getCCCUser()) {
            HLPR_OppCreateOnLeadConversion.OpportunityCreateRequest optyCreateRequest = new HLPR_OppCreateOnLeadConversion.OpportunityCreateRequest();
            Lead partialLeadRecord = [SELECT Id, AgentAssociateId__c, leadSource, ownerId, DateCaptured__c, VendorId__c, MultiLOB__c, SCode__c, RecordType.DeveloperName, External_Lead_ID__c
            FROM Lead WHERE External_Lead_ID__c = 'P1234'];
            Account testAccount = [SELECT id, FirstName, LastName, ClientIdentifier__c FROM account WHERE ClientIdentifier__c = 'SFFSP81L8XB' LIMIT 1];
            optyCreateRequest.leadRecord = partialLeadRecord;
            optyCreateRequest.actId = testAccount.Id;
            optyCreateRequest.lobValues ='[{"keyField":"1","selectedLineOfBusiness":"Fire","selectedEffectiveDate":"2022-04-14","selectedProduct":{"productDescription":"Apartment","productSystemName":"APARTMENT"}}]';
            optyCreateRequest.loggedInUserSubUserType = 'CCC Sales';
            optyCreateRequest.campaignId = null;
            optyCreateRequest.stateCode = 'IL/ 17-5678';
            Test.startTest();
            String convertedOpportunityIds = LeadConversionController.handleOpportunities(optyCreateRequest);
            System.assert(String.isNotBlank(convertedOpportunityIds), 'Invalid Converted Opportunity Ids');
            validateOpportunityOnLeadConversion(testAccount, optyCreateRequest, 'Customer Care Center');
            Test.stopTest();
        }
    }

    @isTest private static void testHandleOpportunitiesAsAgent() {
        System.runAs(getAgentUser()) {
            HLPR_OppCreateOnLeadConversion.OpportunityCreateRequest optyCreateRequest = new HLPR_OppCreateOnLeadConversion.OpportunityCreateRequest();
            Lead partialLeadRecord = [SELECT Id, AgentAssociateId__c, leadSource, ownerId, DateCaptured__c, VendorId__c, MultiLOB__c, SCode__c, RecordType.DeveloperName, External_Lead_ID__c
                FROM Lead WHERE External_Lead_ID__c = 'P1234'];
            Account testAccount = [SELECT id, FirstName, LastName, ClientIdentifier__c FROM account WHERE ClientIdentifier__c = 'SFFSP81L8XB' LIMIT 1];
            Campaign campaign = [SELECT id FROM campaign LIMIT 1];
            optyCreateRequest.leadRecord = partialLeadRecord;
            optyCreateRequest.actId = testAccount.Id;
            optyCreateRequest.lobValues ='[{"keyField":"1","selectedLineOfBusiness":"Fire","selectedEffectiveDate":"2022-04-14","selectedProduct":{"productDescription":"Apartment","productSystemName":"APARTMENT"}}]';
            optyCreateRequest.loggedInUserSubUserType = 'Agent';
            optyCreateRequest.campaignId = campaign.id;
            optyCreateRequest.stateCode = 'IL/ 17-5678';
            Test.startTest();
            String convertedOpportunityIds = LeadConversionController.handleOpportunities(optyCreateRequest);
            System.assert(String.isNotBlank(convertedOpportunityIds), 'Invalid Converted Opportunity Ids');
            validateOpportunityOnLeadConversion(testAccount, optyCreateRequest, 'Agent/Team Member');
            Test.stopTest();
        }
    }

    @SuppressWarnings('PMD.ApexUnitTestMethodShouldHaveIsTestAnnotation')
    private static void validateOpportunityOnLeadConversion(Account testAccount, HLPR_OppCreateOnLeadConversion.OpportunityCreateRequest optyCreateRequest, String opportunityOriginator) {
        StageOrchestration__c stgRecord = [SELECT Id, IdentifierValue__c, TransactionType__c, Value__c FROM StageOrchestration__c WHERE IdentifierValue__c = 'SFFSP81L8XB' LIMIT 1];
        System.assertEquals('SFFSP81L8XB', stgRecord.IdentifierValue__c, 'Invalid StageOrc Identifier');
        System.assertEquals('Conversion Lead Details', stgRecord.TransactionType__c, 'Invalid StageOrc TransactionType');
        System.assert(!String.isBlank(stgRecord.Value__c), 'Invalid StageOrc Value');
        CMOpportunityMapping__mdt optyMappingMDT = [SELECT LeadSource__c, OpportunityOriginator__c, MarketingSource__c, MarketingSubSource__c
            FROM CMOpportunityMapping__mdt WHERE MappingType__c = 'Lead Conversion' AND LeadSource__c = 'Enterprise Facebook Lead' LIMIT 1];

        Opportunity convertedOpportunity = [SELECT Id, Recordtype.DeveloperName, OwnerId, StageName, CloseDate,
        AccountId, Name, LOB__c, Product__c, EventCode__c, EventName__c, ExternalILPId__c, LeadSource, Opportunity_Originator__c,
        Marketing_Source__c, Marketing_Sub_Source__c, Assigned_To__c, DateCaptured__c, CampaignId, ExternalID__c, Lead_ID__c,
        Requested_Effective_Date__c, State_Code__c, Product_System_Name__c FROM Opportunity WHERE AccountId = :testAccount.Id];
        System.assertEquals('Opportunity_Management', convertedOpportunity.RecordType.DeveloperName, 'Invalid Opportunity Record Type');
        System.assertEquals('Quoting', convertedOpportunity.StageName, 'Invalid Opportunity Stage Name');
        System.assertEquals(opportunityOriginator, convertedOpportunity.Opportunity_Originator__c, 'Invalid Opty Originator');
        System.assertEquals(optyMappingMDT.MarketingSource__c, convertedOpportunity.Marketing_Source__c, 'Invalid Opty Marketing Source');
        System.assertEquals(optyMappingMDT.MarketingSubSource__c, convertedOpportunity.Marketing_Sub_Source__c, 'Invalid Opty Marketing Sub Source');
        System.assertEquals('Fire', convertedOpportunity.LOB__c, 'Invalid Opty LOB');
        System.assertEquals('Apartment', convertedOpportunity.Product__c, 'Invalid Opty Product');
        System.assertEquals('Fire-' + testAccount.FirstName + ' ' + testAccount.LastName, convertedOpportunity.Name, 'Invalid Opty Name');
        System.assertEquals(Date.today() + 60, convertedOpportunity.CloseDate, 'Invalid Opty CloseDate');
        System.assertEquals(optyCreateRequest.leadRecord.OwnerId, convertedOpportunity.OwnerId, 'Invalid Opty Owner Id');
        System.assertEquals(testAccount.Id, convertedOpportunity.AccountId, 'Invalid Opty Account Id');
        System.assertEquals(optyCreateRequest.leadRecord.SCode__c, convertedOpportunity.EventCode__c, 'Invalid Opty Event Code');
        System.assertEquals(optyCreateRequest.leadRecord.VendorId__c, convertedOpportunity.ExternalILPId__c, 'Invalid Opty External ILP Id');
        System.assertEquals(optyCreateRequest.leadRecord.LeadSource, convertedOpportunity.LeadSource, 'Invalid Opty Lead Source');
        //System.assertEquals(optyCreateRequest.leadRecord.DateCaptured__c, convertedOpportunity.DateCaptured__c, 'Invalid Opty Date Captured');
        System.assertEquals(Date.valueOf('2022-04-14'), convertedOpportunity.Requested_Effective_Date__c, 'Invalid Requested Effective Date');
        System.assertEquals('APARTMENT', convertedOpportunity.Product_System_Name__c, 'Invalid Product System Name');
        System.assertEquals(optyCreateRequest.stateCode, convertedOpportunity.State_Code__c, 'Invalid State Code');

        LeadMetrics__c ldMetricsAfterConversion = [SELECT Id, Status__c, LeadConvertedBy__c, LeadConvertedDate__c, ConvertedAccountId__c,
                ConvertedOpportunityIds__c FROM LeadMetrics__c WHERE LeadSfdcId__c = :optyCreateRequest.leadRecord.Id LIMIT 1];
        System.assertEquals('Converted', ldMetricsAfterConversion.Status__c, 'Invalid Lead Metric Status');
        System.assertEquals(UserInfo.getUserId(), ldMetricsAfterConversion.LeadConvertedBy__c, 'Invalid LdMetrcis Converted By');
        System.assertEquals(testAccount.Id, ldMetricsAfterConversion.ConvertedAccountId__c, 'Invalid LdMetrcis Converted Act Id');
        System.assertEquals(convertedOpportunity.Id, ldMetricsAfterConversion.ConvertedOpportunityIds__c, 'Invalid LdMetrics Converted Opty Id');
        System.assertEquals(optyCreateRequest.campaignId, convertedOpportunity.CampaignId, 'Invalid Opty Campaign ID');
        System.assertEquals(optyCreateRequest.leadRecord.External_Lead_ID__c, convertedOpportunity.ExternalID__c, 'Invalid Opty External Id');
        System.assertEquals(optyCreateRequest.leadRecord.Id, convertedOpportunity.Lead_ID__c, 'Invalid Converted Lead Id');
    }

    private static User getCCCUser() {
        return [SELECT Id FROM User WHERE UserExternalId__c = 'LdConvCCC' LIMIT 1];
    }

    private static User getAgentUser() {
        return [SELECT Id FROM User WHERE UserExternalId__c = '190cww22zzc_190cww22zzc' LIMIT 1];
    }
}