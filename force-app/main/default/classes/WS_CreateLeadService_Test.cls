/**
 * Author : Golden Spikes Team
 * Date Created : 04/16/2019
 * @description : Test class for WS_CreateLeadService apex class.
 */
@isTest(SeeAllData=false)
private class WS_CreateLeadService_Test {
    //Account Constants
    private static String actIndividualRecordTypeId = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    private static final String INVALID_CLIENT_ID_ERROR = '11 character Client ID is expected';

    //Opportunity Constants
    private static String optySFCOMClaimedRecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunity_Management').getRecordTypeId();
    private static final String STAGE_NAME = 'New';

    //Opportunity Note Constants
    private static final String SPACE_SYMBOL = ' ';
    private static final String OPPORTUNITY_NOTE_SUBJECT_PREFIX = 'New';
    private static final String OPPORTUNITY_NOTE_CATEGORY = 'System Generated';
    private static final String OPPORTUNITY_NOTE_COMMENTS_TARGET_LOB_STRING = '{LOB}';
    private static String opportunityNoteGenericComments = System.Label.CL_OPPORTUNITYNOTECOMMENTSFORFACEBOOKLEAD;

    //Lead Constants
    private static String leadPartialRecordTypeId = Schema.Sobjecttype.Lead.getRecordTypeInfosByDeveloperName().get('PartialLead').getRecordTypeId();
    private static final String LEAD_SOURCE_MAPPING_TYPE = 'External Lead Service';
    private static final String INVALID_PROXY_ERROR = 'Proxy User not found with given Associate Id: ';

    //Task Constants
    private static String taskRecordTypeId = Schema.Sobjecttype.Task.getRecordTypeInfosByDeveloperName().get('Task').getRecordTypeId();

    private static final String EVENT_LEAD_SERVICE_PERM_SET = 'SF_CRM_EventLeadOppMgmt_PermSetPID';

    @TestSetup private static void setUpUserData() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User agentUser;
        CS001_ByPassTriggerAll__c byPassAllTrigger;
        User adminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'sysemAdmin', 'LdCrAdm' + UTIL_TestUsername_TEST.getTestUsername());
        insert adminUser;
        System.runAs(adminUser) {
            byPassAllTrigger = new CS001_ByPassTriggerAll__c(Override_All__c = true);
            insert byPassAllTrigger;
            User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
            insert systemUser;
            AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.Id);
            insert sysAdminUserIdSetting;
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
            User testCCCLicenUser = new User(Alias='LDC1',LastName='LastName',Username='CCC' + UTIL_TestUsername_TEST.getTestUsername(),Associate_ID__c='CCCASSO1234',UserExternalID__c='CCCASSO1234');
            UTIL_UserProvisioning_TEST.buildCCCLicensedUserMethod(testCCCLicenUser);
        }
    }

    //method to test opprortunity request for Partial Lead - Enterprise Facebook Lead
    @isTest private static void testHandleOpportunityRequestForPartialLead() {
        HLPR_CreateLeadRequest request = new HLPR_CreateLeadRequest();
        request.LeadAccount = Util_CreateLeadService_Test.buildLeadAccount('11122233344');
        request.leadAgentRole = Util_CreateLeadService_Test.buildLeadAgentRole('11d11122zzc');
        request.leadOpportunities = Util_CreateLeadService_Test.buildLeadOpportunity('FB');
        User agentUser = [SELECT id FROM User WHERE UserExternalId__c = '11d11122zzc_11d11122zzc' LIMIT 1];
        User procIdUser = [SELECT id FROM User WHERE username = 'ev1tLd1PrId1Us123@sfa222.test.com' LIMIT 1];
        User proxyUser = [SELECT id FROM User WHERE UserExternalId__c = '11d11122zzcP' LIMIT 1];
        System.runAs(procIdUser) {
            Test.starttest();
            try {
                WS_CreateLeadService.handleOpportunityRequest(request.LeadAccount, request.LeadAgentRole, request.leadOpportunities);
            } catch (Exception e) {
                System.assert(false, 'Handle Opportunity Request Failed');
            }
            Test.stoptest();
        }
        Account insertedAccount = [SELECT FirstName, LastName, ClientIdentifier__c, RecordTypeId FROM Account LIMIT 1];
        AgentRole__c insertedAgentRole = [SELECT Agent__c, AgentRoleIdentifier__c, Customer__c FROM AgentRole__c LIMIT 1];
        Opportunity insertedOpportunity = [SELECT RecordTypeId, StageName, CloseDate, Name, AccountId, LOB__c, Source_Comments__c, Product__c, Marketing_Source__c,
            Marketing_Sub_Source__c, Opportunity_Originator__c, OwnerId, EventCode__c, EventName__c, Phone__c, Email__c FROM Opportunity LIMIT 1];
        Opportunity_Note__c insertedOpportunityNote = [SELECT Name, Category__c, Comments__c, Opportunity__c FROM Opportunity_Note__c LIMIT 1];
        CMOpportunityMapping__mdt ldSourceMapping = [SELECT Description__c, ExternalLeadSource__c, LeadSource__c, MappingType__c, MarketingSource__c, MarketingSubSource__c,
            OpportunityOriginator__c FROM CMOpportunityMapping__mdt WHERE MappingType__c = :LEAD_SOURCE_MAPPING_TYPE AND ExternalLeadSource__c = 'FB' LIMIT 1];

        System.assertEquals('TestFName', insertedAccount.FirstName, 'Account First Name is Incorrect.');
        System.assertEquals('TestLName', insertedAccount.LastName, 'Account Last Name is Incorrect.');
        System.assertEquals('11122233344', insertedAccount.ClientIdentifier__c, 'Account Client Identifier is Incorrect.');
        System.assertEquals(actIndividualRecordTypeId, insertedAccount.RecordTypeId, 'Account Record Type is Incorrect.');

        System.assertEquals(agentUser.Id, insertedAgentRole.Agent__c, 'Agent Role Agent is Incorrect');
        System.assertEquals('11d11122zzc~11122233344', insertedAgentRole.AgentRoleIdentifier__c, 'Agent Role Agent Identifier is Incorrect');
        System.assertEquals(insertedAccount.Id, insertedAgentRole.Customer__c, 'Agent Role Customer is Incorrect');

        System.assertEquals(optySFCOMClaimedRecordTypeId, insertedOpportunity.RecordTypeId, 'Opportunity recordtypeId is Incorrect.');
        System.assertEquals(proxyUser.Id, insertedOpportunity.OwnerId, 'Opportunity Owner is Incorrect.');
        System.assertEquals(STAGE_NAME, insertedOpportunity.StageName, 'Opportunity StageName is Incorrect.');
        System.assertEquals(Date.today() + 60, insertedOpportunity.CloseDate, 'Opportunity CloseDate is Incorrect.');
        System.assertEquals(insertedAccount.Id, insertedOpportunity.AccountId, 'Opportunity Account is Incorrect');
        System.assertEquals('Auto-TestFName TestLName', insertedOpportunity.Name, 'Opportunity Name is Incorrect.');
        System.assertEquals('Auto', insertedOpportunity.LOB__c, 'Opportunity LOB is Incorrect.');
        System.assertEquals('Private Passenger', insertedOpportunity.Product__c, 'Opportunity Product is Incorrect.');
        System.assertEquals('S17377', insertedOpportunity.EventCode__c, 'Opportunity Event Code is Incorrect.');
        System.assertEquals('Test Event', insertedOpportunity.EventName__c, 'Opportunity Event Name is Incorrect.');
        System.assertEquals('Test Comment', insertedOpportunity.Source_Comments__c, 'Opportunity Source Comments is Incorrect.');
        System.assertEquals(ldSourceMapping.MarketingSource__c, insertedOpportunity.Marketing_Source__c, 'Opportunity Marketing Source is Incorrect.');
        System.assertEquals(ldSourceMapping.MarketingSubSource__c, insertedOpportunity.Marketing_Sub_Source__c, 'Opportunity Marketing Sub Source is Incorrect.');
        System.assertEquals(ldSourceMapping.OpportunityOriginator__c, insertedOpportunity.Opportunity_Originator__c, 'Opportunity Originator is Incorrect.');
        System.assertEquals('2223334444', insertedOpportunity.Phone__c, 'Opportunity Phone is Incorrect.');
        System.assertEquals('agt7@statefarm.com', insertedOpportunity.Email__c, 'Opportunity Submitted Email is Incorrect.');

        System.assertEquals(OPPORTUNITY_NOTE_SUBJECT_PREFIX + SPACE_SYMBOL + 'Enterprise Facebook Lead', insertedOpportunityNote.Name, 'Opportunity Note Name is Incorrect.');
        System.assertEquals(OPPORTUNITY_NOTE_CATEGORY, insertedOpportunityNote.Category__c, 'Opportunity Note Category is Incorrect.');
        System.assertEquals(opportunityNoteGenericComments.replace(OPPORTUNITY_NOTE_COMMENTS_TARGET_LOB_STRING, 'Auto'), insertedOpportunityNote.Comments__c, 'Opportunity Note Comments is Incorrect.');
        System.assertEquals(insertedOpportunity.Id, insertedOpportunityNote.Opportunity__c, 'Opportunity Note Opportunity is Incorrect.');
    }

    //method to test opprortunity request for Empty Client Id
    @isTest private static void testHandleOpportunityRequestForEmptyClientId() {
        HLPR_CreateLeadRequest request = new HLPR_CreateLeadRequest();
        request.LeadAccount = Util_CreateLeadService_Test.buildLeadAccount('');
        User procIdUser = [SELECT id FROM User WHERE username = 'ev1tLd1PrId1Us123@sfa222.test.com' LIMIT 1];
        System.runAs(procIdUser) {
            Test.starttest();
            try {
                WS_CreateLeadService.handleOpportunityRequest(request.LeadAccount, request.LeadAgentRole, request.leadOpportunities);
                System.assert(false, 'Handle Opportunity Request Failed for Empty Client Id Check');
            } catch (Exception e) {
                System.assertEquals(INVALID_CLIENT_ID_ERROR, e.getMessage(), 'Handle Opportunity Request Failed for Empty Client Id Check');
            }
            Test.stoptest();
        }
    }

    //method to test opprortunity request for Invalid Client Id
    @isTest private static void testHandleOpportunityRequestForInvalidClientId() {
        HLPR_CreateLeadRequest request = new HLPR_CreateLeadRequest();
        request.LeadAccount = Util_CreateLeadService_Test.buildLeadAccount('yyyyzzzzxxxx');
        User procIdUser = [SELECT id FROM User WHERE username = 'ev1tLd1PrId1Us123@sfa222.test.com' LIMIT 1];
        System.runAs(procIdUser) {
            Test.starttest();
            try {
                WS_CreateLeadService.handleOpportunityRequest(request.LeadAccount, request.LeadAgentRole, request.leadOpportunities);
                System.assert(false, 'Handle Opportunity Request Failed for Invalid Client Id Check');
            } catch (Exception e) {
                System.assertEquals(INVALID_CLIENT_ID_ERROR, e.getMessage(), 'Handle Opportunity Request Failed for Invalid Client Id Check');
            }
            Test.stoptest();
        }
    }

    //method to test opprortunity request for Invalid Agent Id
    @isTest private static void testHandleOpportunityRequestForInvalidAgent() {
        HLPR_CreateLeadRequest request = new HLPR_CreateLeadRequest();
        request.LeadAccount = Util_CreateLeadService_Test.buildLeadAccount('15122233344');
        request.leadAgentRole = Util_CreateLeadService_Test.buildLeadAgentRole('xxxxyyyyzzz');
        User procIdUser = [SELECT id FROM User WHERE username = 'ev1tLd1PrId1Us123@sfa222.test.com' LIMIT 1];
        System.runAs(procIdUser) {
            Test.starttest();
            try {
                WS_CreateLeadService.handleOpportunityRequest(request.LeadAccount, request.LeadAgentRole, request.leadOpportunities);
                System.assert(false, 'Handle Opportunity Request Failed for Invalid Agent Id Check');
            } catch (Exception e) {
                System.assertNotEquals(null, e.getMessage(), 'Handle Opportunity Request Failed for Invalid Agent Id Check');
            }
            Test.stoptest();
        }
    }

    //method to test Account Exception on Opportunity request
    @isTest private static void testHandleOpportunityRequestForAccountException() {
        User procIdUser = [SELECT id FROM User WHERE username = 'ev1tLd1PrId1Us123@sfa222.test.com' LIMIT 1];
        HLPR_CreateLeadRequest request = new HLPR_CreateLeadRequest();
        request.LeadAccount = Util_CreateLeadService_Test.buildLeadAccount('16122233344');
        System.runAs(procIdUser) {
            Test.starttest();
            try {
                WS_CreateLeadService.handleOpportunityRequest(request.LeadAccount, request.LeadAgentRole, request.leadOpportunities);
                System.assert(false, 'Handle Opportunity Request Failed for Account Exception Check');
            } catch (Exception e) {
                System.assertNotEquals(null, e.getMessage(), 'Handle Opportunity Request Failed for Account Exception Check');
            }
            Test.stoptest();
        }
    }

    //method to test opprortunity request for Opportunity Exception
    @isTest private static void testHandleOpportunityRequestForOpportunityException() {
        HLPR_CreateLeadRequest request = new HLPR_CreateLeadRequest();
        request.LeadAccount = Util_CreateLeadService_Test.buildLeadAccount('11122233344');
        request.leadAgentRole = Util_CreateLeadService_Test.buildLeadAgentRole('11d11122zzc');
        List<HLPR_CreateLeadRequest.LeadOpportunity> optyList = Util_CreateLeadService_Test.buildLeadOpportunity('Event Leads');
        optyList.get(0).name = '';
        request.leadOpportunities = optyList;
        User procIdUser = [SELECT id FROM User WHERE username = 'ev1tLd1PrId1Us123@sfa222.test.com' LIMIT 1];
        System.runAs(procIdUser) {
            Test.starttest();
            try {
                WS_CreateLeadService.handleOpportunityRequest(request.LeadAccount, request.LeadAgentRole, request.leadOpportunities);
                System.assert(false, 'Handle Opportunity Request Failed for Opportunity Exception Check');
            } catch (Exception e) {
                System.assertNotEquals(null, e.getMessage(), 'Handle Opportunity Request Failed for Opportunity Exception Check');
            }
            Test.stoptest();
        }
    }

    //method to test Lead request and task
    @isTest private static void testHandleLeadRequest() {
        HLPR_CreateLeadRequest.LeadInformation ldInfo = Util_CreateLeadService_Test.createLeadInformationRequest('1112223333', 'FB', '11d11122zzc');
        ldInfo.addressInfo.state = 'il';
        Lead ld = testHandleLeadRequest(ldInfo);
        User procIdUser = [SELECT id FROM User WHERE username = 'ev1tLd1PrId1Us123@sfa222.test.com' LIMIT 1];
        System.runAs(procIdUser) {
        System.assertEquals('IL', ld.State, 'Lead State is Incorrect.');
        }
    }

    @isTest private static void testHandleLeadRequestNullState() {
        HLPR_CreateLeadRequest.LeadInformation ldInfo = Util_CreateLeadService_Test.createLeadInformationRequest('1112223333', 'FB', '11d11122zzc');
        ldInfo.addressInfo.state = null;
        Lead ld = testHandleLeadRequest(ldInfo);
        User procIdUser = [SELECT id FROM User WHERE username = 'ev1tLd1PrId1Us123@sfa222.test.com' LIMIT 1];
        System.runAs(procIdUser) {
        System.assertEquals(null, ld.State, 'Lead State is Incorrect.');
        }
    }

    @SuppressWarnings('PMD.ApexUnitTestMethodShouldHaveIsTestAnnotation')
    private static Lead testHandleLeadRequest(HLPR_CreateLeadRequest.LeadInformation ldInfo) {
        HLPR_CreateLeadRequest request = new HLPR_CreateLeadRequest();
        List<HLPR_CreateLeadRequest.LineOfBusinessDetails> leadLobList = new List<HLPR_CreateLeadRequest.LineOfBusinessDetails>();
        HLPR_CreateLeadRequest.LineOfBusinessDetails leadsLobDetails1 = new HLPR_CreateLeadRequest.LineOfBusinessDetails();
        leadsLobDetails1.lob = 'Auto';
        leadsLobDetails1.product = 'Private Passenger';
        HLPR_CreateLeadRequest.LineOfBusinessDetails leadsLobDetails2 = new HLPR_CreateLeadRequest.LineOfBusinessDetails();
        leadsLobDetails2.lob = 'Fire';
        leadsLobDetails2.product = '';
        leadLobList.add(leadsLobDetails1);
        leadLobList.add(leadsLobDetails2);
        request.LeadInformation = ldInfo;
        request.LeadInformation.lobDetails = leadLobList;
        User procIdUser = [SELECT id FROM User WHERE username = 'ev1tLd1PrId1Us123@sfa222.test.com' LIMIT 1];
        User proxyUser = [SELECT id FROM User WHERE UserExternalId__c = '11d11122zzcP' LIMIT 1];
        System.runAs(procIdUser) {
            Test.starttest();
            try {
                WS_CreateLeadService.handleLeadRequest(request.LeadInformation);
            } catch (Exception e) {
                System.assert(false, 'Handle Lead Request Failed on Lead and Task Create');
            }
            Test.stoptest();
        }
        Lead insertedLead = [SELECT FirstName, LastName, Name, RecordTypeId, OwnerId, Country, Description, State, PostalCode,
        Email, DoNotEmail__c, SubmittedMobilePhoneNumber__c, SubmittedMobileDoNotCall__c, External_Lead_ID__c, LeadSource,
        DateCaptured__c, SCode__c, AgentAssociateId__c, MultiLOB__c, Product__c, Street, City, Submitted_Phone_Number__c, VendorId__c, 
        LeadScore__c, LeadTemperature__c, BusinessType__c, WorkLocation__c FROM Lead LIMIT 1];
        Task insertedTask = [SELECT AppCode__c, Subject, Priority, Status, Task_Type__c, TaskCategory__c, Source__c,
            WhoId, OwnerId, RecordTypeId, AgentAssociateId__c, ActivityDate, Description FROM Task LIMIT 1];
        validateLeadCreation(insertedLead, proxyUser, ldInfo);
        validateTaskCreation(insertedLead, proxyUser, insertedTask);
        validateLeadMetricsCreation(insertedLead, procIdUser);
        return insertedLead;
    }

    @SuppressWarnings('PMD.ApexUnitTestMethodShouldHaveIsTestAnnotation')
    private static void validateLeadCreation(Lead insertedLead, User proxyUser, HLPR_CreateLeadRequest.LeadInformation ldInfo) {
        CMOpportunityMapping__mdt ldSourceMapping = [SELECT Description__c, ExternalLeadSource__c, LeadSource__c, MappingType__c, 
        MarketingSource__c, MarketingSubSource__c, OpportunityOriginator__c FROM CMOpportunityMapping__mdt WHERE MappingType__c = :LEAD_SOURCE_MAPPING_TYPE AND ExternalLeadSource__c = 'FB' LIMIT 1];
        System.assertEquals('TestFName', insertedLead.FirstName, 'Lead First Name is Incorrect.');
        System.assertEquals('TestLName', insertedLead.LastName, 'Lead Last Name is Incorrect.');
        System.assertEquals(leadPartialRecordTypeId, insertedLead.RecordTypeId, 'Lead Record Type is Incorrect.');
        System.assertEquals(proxyUser.Id, insertedLead.OwnerId, 'Lead Owner Id is Incorrect.');
        System.assertEquals('US', insertedLead.Country, 'Lead Country is Incorrect.');
        System.assertEquals('61704', insertedLead.PostalCode, 'Lead Postal Code is Incorrect.');
        System.assertEquals('agt8@statefarm.com', insertedLead.Email, 'Lead Email is Incorrect.');
        System.assertEquals(Datetime.newInstance(2019, 4, 16, 0, 0, 0), insertedLead.DateCaptured__c, 'Lead Date Captured is Incorrect.');
        System.assertEquals('11d11122zzc', insertedLead.AgentAssociateId__c, 'Lead Agent Associate Id is Incorrect.');
        System.assert((insertedLead.Description).contains('Auto-Private Passenger / Fire'), 'Lead Description is Incorrect.');
        System.assertEquals('Auto;Fire', insertedLead.MultiLOB__c, 'Lead Multi LOB is Incorrect.');
        System.assertEquals('Private Passenger;', insertedLead.Product__c, 'Lead Product is Incorrect.');
        System.assertEquals(ldSourceMapping.LeadSource__c, insertedLead.LeadSource, 'Lead Lead Source is Incorrect.');
        System.assertEquals('1234 Main St.', insertedLead.Street, 'Lead Street is Incorrect.');
        System.assertEquals('Bloomington', insertedLead.City, 'Lead City is Incorrect.');
        System.assertEquals(ldInfo.externalLeadId, insertedLead.External_Lead_ID__c, 'Lead External Lead Id is Incorrect.');
        System.assertEquals(ldInfo.mobilePhone, insertedLead.SubmittedMobilePhoneNumber__c, 'Lead Mobile Phone is Incorrect.');
        System.assertEquals(ldInfo.phone, insertedLead.Submitted_Phone_Number__c, 'Lead Phone is Incorrect.');        
        System.assertEquals(ldInfo.vendorID, insertedLead.VendorId__c, 'Lead Vendor Id is Incorrect.');
        System.assertEquals(ldInfo.leadScore, insertedLead.LeadScore__c, 'Lead Score is Incorrect.');
        System.assertEquals('Yogurt Shop', insertedLead.BusinessType__c, 'Business Type is Incorrect.');
        System.assertEquals('I lease my space.', insertedLead.WorkLocation__c, 'Work Location is Incorrect.');
    }

    @SuppressWarnings('PMD.ApexUnitTestMethodShouldHaveIsTestAnnotation')
    private static void validateTaskCreation(Lead insertedLead, User proxyUser, Task insertedTask) {
        System.assertEquals('Lead Management', insertedTask.AppCode__c, 'Task App Code is Incorrect.');
        System.assertEquals('New Enterprise Facebook Lead', insertedTask.Subject, 'Task Subject is Incorrect.');
        System.assertEquals('None', insertedTask.Priority, 'Task Priority is Incorrect.');
        System.assertEquals('Not Started', insertedTask.Status, 'Task Status is Incorrect.');
        System.assertEquals('Sales', insertedTask.Task_Type__c, 'Task Type is Incorrect.');
        System.assertEquals('Marketing', insertedTask.TaskCategory__c, 'Task Category is Incorrect.');
        System.assertEquals('Marketing', insertedTask.Source__c, 'Task Source is Incorrect.');
        System.assertEquals(insertedLead.Id, insertedTask.WhoId, 'Task WhoId is Incorrect.');
        System.assertEquals(proxyUser.Id, insertedLead.OwnerId, 'Task OwnerId is Incorrect.');
        System.assertEquals(taskRecordTypeId, insertedTask.RecordTypeId, 'Task Record Type is Incorrect.');
        System.assertEquals('11d11122zzc', insertedTask.AgentAssociateId__c, 'Task Agent Associate Id is Incorrect.');
        System.assertEquals(Date.Today(), insertedTask.ActivityDate, 'Task Activity Date is Incorrect.');
        System.assert((insertedTask.Description).contains('Auto-Private Passenger / Fire'), 'Task Description is Incorrect.');
    }

    @SuppressWarnings('PMD.ApexUnitTestMethodShouldHaveIsTestAnnotation')
    private static void validateLeadMetricsCreation(Lead insertedLead, User procIdUser) {
        LeadMetrics__c ldMetricRecord = [SELECT Id, OwnerId, LeadName__c, LeadCreatedBy__c, LeadCreatedDate__c, LeadRecordType__c, LeadSfdcId__c,
        ExternalLeadId__c, Status__c, CustomerReferrer__c, NonCustomerReferrer__c, RelationshiptoReferrer__c, OriginalLeadSource__c,
        AssignedTo__c, LeadScore__c, LeadTemperature__c FROM LeadMetrics__c WHERE LeadSfdcId__c = :insertedLead.id LIMIT 1];
        System.assertEquals(insertedLead.Id, ldMetricRecord.LeadSfdcId__c, 'Salesforce Lead Id is Incorrect');
        System.assertEquals(insertedLead.External_Lead_ID__c, ldMetricRecord.ExternalLeadId__c, 'External Lead Id is Incorrect');
        System.assertEquals(insertedLead.Name, ldMetricRecord.LeadName__c, 'Lead Name is Incorrect');
        System.assertEquals('Partial Lead', ldMetricRecord.LeadRecordType__c, 'Lead Record Type is Incorrect');
        System.assertEquals('New', ldMetricRecord.Status__c, 'Status is Incorrect');
        System.assertEquals('Enterprise Facebook Lead', ldMetricRecord.OriginalLeadSource__c, 'Original Lead Source is Incorrect');
        System.assertEquals(insertedLead.ownerId, ldMetricRecord.OwnerId, 'Lead Metric Owner is Incorrect');
        System.assertEquals(procIdUser.Id, ldMetricRecord.LeadCreatedBy__c, 'Lead Metric CreatedBy is Incorrect');
        System.assert(ldMetricRecord.LeadCreatedDate__c != null, 'Lead Metric CreatedDate is Incorrect');
        System.assertEquals(insertedLead.LeadScore__c, ldMetricRecord.LeadScore__c, 'Lead Score is Incorrect');
        System.assertEquals(insertedLead.LeadTemperature__c, ldMetricRecord.LeadTemperature__c, 'Lead Temperature is Incorrect');
    }

    //method to test opprortunity request for Invalid Agent Id
    @isTest private static void testHandleLeadRequestForProxyUserNotFound() {
        User procIdUser = [SELECT id FROM User WHERE username = 'ev1tLd1PrId1Us123@sfa222.test.com' LIMIT 1];
        HLPR_CreateLeadRequest request = new HLPR_CreateLeadRequest();
        request.LeadInformation = Util_CreateLeadService_Test.createLeadInformationRequest('8888888881', 'FB', '19d11122zzc');
        System.runAs(procIdUser) {
            Test.starttest();
            try {
                WS_CreateLeadService.handleLeadRequest(request.LeadInformation);
                System.assert(false, 'Handle Lead Request Failed for Invalid Agent Id Check');
            } catch (Exception e) {
                System.assertEquals(INVALID_PROXY_ERROR + request.LeadInformation.agentAssociateID, e.getMessage(), 'Handle Lead Request Failed for Invalid Agent Id Check');
            }
            Test.stoptest();
        }
    }

    //method to test lead request for Exception
    @isTest private static void testHandleLeadRequestForException() {
        User procIdUser = [SELECT id FROM User WHERE username = 'ev1tLd1PrId1Us123@sfa222.test.com' LIMIT 1];
        HLPR_CreateLeadRequest request = new HLPR_CreateLeadRequest();
        request.LeadInformation = Util_CreateLeadService_Test.createLeadInformationRequest('9999999991', 'FB', '19d11122zzc');
        request.LeadInformation.lastName = '';
        System.runAs(procIDUser) {
            Test.starttest();
            try {
                WS_CreateLeadService.handleLeadRequest(request.LeadInformation);
                System.assert(false, 'Handle Lead Request Failed for Lead Exception Check');
            } catch (Exception e) {
                System.assertNotEquals(null, e.getMessage(), 'Handle Lead Request Failed for Lead Exception Check');
            }
            Test.stoptest();
        }
    }

    //method to test Lead request and task for CCC User
    @isTest private static void testHandleLeadRequestForCCCRouting() {
        DateTime currentDateTime = Datetime.now();
        LeadCCCHandler.mockedCurrentDateTime = currentDateTime;
        insert new LeadSetting__c(Type__c = 'Transfer to CCC', Name = 'FB', Active__c = true, StartTime__c = (currentDateTime).time(),
            EndTime__c = currentDateTime.time(), Frequency__c = '1;2;3;4;5;6;7');
        insert new CSLeadBatch__c(Name = 'CCC Email Notification', BatchEmailRecipient__c = 'home.ccc-acqu-leads-test.882o08@statefarm.com',
            SenderDisplayName__c = 'Leads Management');
        HLPR_CreateLeadRequest.LeadInformation ldInfo = Util_CreateLeadService_Test.createLeadInformationRequest('1112223333', 'FB', '11d11122zzc');
        ldInfo.addressInfo.state = 'il';
        ldInfo.vendorID = 'ILP1';
        ldInfo.leadScore = 8.77;
        User procIdUser = [SELECT id FROM User WHERE username = 'ev1tLd1PrId1Us123@sfa222.test.com' LIMIT 1];
        System.runAs(procIdUser) {
        Test.starttest();
        Lead ld = testHandleLeadRequestWithOrWithoutCCCAssignment(ldInfo);
        System.assertEquals(true, ld.SourcedFromCCC__c, 'Invalid CCC Lead Source');

        ldInfo.mobilePhone = null;
        ldInfo.phone = null;
        ldInfo.externalLeadId = '1112223334';
        Lead ld1 = testHandleLeadRequestWithOrWithoutCCCAssignment(ldInfo);
        System.assertEquals(false, ld1.SourcedFromCCC__c, 'Invalid CCC Lead Source');

        ldInfo.mobilePhone = '2223334444';
        ldInfo.phone = null;
        ldInfo.externalLeadId = '1112223335';
        Lead ld2 = testHandleLeadRequestWithOrWithoutCCCAssignment(ldInfo);
        System.assertEquals(true, ld2.SourcedFromCCC__c, 'Invalid CCC Lead Source');

        ldInfo.mobilePhone = null;
        ldInfo.phone = '2223334444';
        ldInfo.externalLeadId = '1112223336';
        Lead ld3 = testHandleLeadRequestWithOrWithoutCCCAssignment(ldInfo);
        System.assertEquals(true, ld3.SourcedFromCCC__c, 'Invalid CCC Lead Source');

        ldInfo.sCode = 'S30154'; // Life SCode
        ldInfo.externalLeadId = '1112223337';
        Lead ld4 = testHandleLeadRequestWithOrWithoutCCCAssignment(ldInfo);
        System.assertEquals(false, ld4.SourcedFromCCC__c, 'Invalid CCC Lead Source');
        Test.stoptest();
        }
    }

    @SuppressWarnings('PMD.ApexUnitTestMethodShouldHaveIsTestAnnotation')
    private static Lead testHandleLeadRequestWithOrWithoutCCCAssignment(HLPR_CreateLeadRequest.LeadInformation ldInfo) {
        HLPR_CreateLeadRequest request = new HLPR_CreateLeadRequest();
        List<HLPR_CreateLeadRequest.LineOfBusinessDetails> leadLobList = new List<HLPR_CreateLeadRequest.LineOfBusinessDetails>();
        HLPR_CreateLeadRequest.LineOfBusinessDetails leadsLobDetails1 = new HLPR_CreateLeadRequest.LineOfBusinessDetails();
        leadsLobDetails1.lob = 'Auto';
        leadsLobDetails1.product = 'Private Passenger';
        HLPR_CreateLeadRequest.LineOfBusinessDetails leadsLobDetails2 = new HLPR_CreateLeadRequest.LineOfBusinessDetails();
        leadsLobDetails2.lob = 'Fire';
        leadsLobDetails2.product = '';
        leadLobList.add(leadsLobDetails1);
        leadLobList.add(leadsLobDetails2);
        request.LeadInformation = ldInfo;
        request.LeadInformation.lobDetails = leadLobList;
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = AccountOwnerSystemUserCustomSetting__c.getInstance();
        User procIdUser = [SELECT id FROM User WHERE username = 'ev1tLd1PrId1Us123@sfa222.test.com' LIMIT 1];
        User systemUser = [SELECT id FROM User WHERE Id = :sysAdminUserIdSetting.SFDC_User_ID__c LIMIT 1];
        User proxyUser = [SELECT id FROM User WHERE UserExternalId__c = '11d11122zzcP' LIMIT 1];
        System.runAs(procIdUser) {
            try {
                WS_CreateLeadService.handleLeadRequest(request.LeadInformation);
            } catch (Exception e) {
                System.assert(false, 'Handle Lead Request Failed on Lead and Task Create');
            }
        }

        Lead insertedLead = [SELECT FirstName, LastName, Name, RecordTypeId, OwnerId, Country, Description, State, PostalCode,
                Email, DoNotEmail__c, SubmittedMobilePhoneNumber__c, SubmittedMobileDoNotCall__c, External_Lead_ID__c, LeadSource,
                DateCaptured__c, SCode__c, AgentAssociateId__c, MultiLOB__c, Product__c, Street, City, Submitted_Phone_Number__c, SourcedFromCCC__c, VendorId__c, 
                LeadScore__c, LeadTemperature__c, BusinessType__c, WorkLocation__c FROM Lead WHERE External_Lead_ID__c = :ldInfo.externalLeadId LIMIT 1];        
        if(!('S30154').contains(insertedLead.SCode__c) && (String.isNotBlank(insertedLead.SubmittedMobilePhoneNumber__c) || String.isNotBlank(insertedLead.Submitted_Phone_Number__c))) {
            validateLeadCreation(insertedLead, systemUser, ldInfo);
        } else {
            System.assertEquals(false, insertedLead.SourcedFromCCC__c, 'Invalid CCC Lead Source');
            validateLeadCreation(insertedLead, proxyUser, ldInfo);
        }
        return insertedLead;
    }

    @isTest private static void testIsCCCEligible() {
        User procIdUser = [SELECT id FROM User WHERE username = 'ev1tLd1PrId1Us123@sfa222.test.com' LIMIT 1];
        DateTime currentDateTime = Datetime.now();
        LeadCCCHandler.mockedCurrentDateTime = currentDateTime;
        insert new LeadSetting__c(Type__c = 'Transfer to CCC', Name = 'FB', Active__c = true, StartTime__c = (currentDateTime).time(),
            EndTime__c = currentDateTime.time(), Frequency__c = '1;2;3;4;5;6;7');
        System.runAs(procIdUser) {
            Test.starttest();
            try {
                System.assertEquals(true, WS_CreateLeadService.isCCCEligible('FB'), 'Invalid CCC Eligible Flag');
                System.assertEquals(false, WS_CreateLeadService.isCCCEligible('FB1'), 'Invalid CCC Eligible Flag');
            } catch (Exception e) {
                System.assert(false, 'Handle Lead Request Failed on Lead and Task Create');
            }
            Test.stoptest();
        }
    }
}