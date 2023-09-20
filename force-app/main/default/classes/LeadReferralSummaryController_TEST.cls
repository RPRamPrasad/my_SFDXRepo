/**
 * Author : Golden Spikes Team
 * Date Created : 04/15/2020
 * @description : Test Class for LeadReferralSummaryController Apex Class and to validate the leadReferralSummary dataTable data.
 */
@isTest(seeAllData=false)
public class LeadReferralSummaryController_TEST {
    private static final String LEAD_REFERRAL_RECORD_TYPE_DEV_NAME = 'SF_Referral';
    private static String referralRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(LEAD_REFERRAL_RECORD_TYPE_DEV_NAME).getRecordTypeId();
    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();
    private static String optyRecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunity_Management').getRecordTypeId();

    @TestSetup private static void setUpUserData() {
        User adminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'lRfAdm' + UTIL_TestUsername_TEST.getTestUsername());
        insert adminUser;
        User agentUser;
        CS001_ByPassTriggerAll__c byPassAllTrigger;
        System.runAs(adminUser) {
            byPassAllTrigger = new CS001_ByPassTriggerAll__c(Override_All__c = true);
            insert byPassAllTrigger;

            UserRole agentUserRole = new UserRole(name = 'AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = new UserRole(name = 'ProxyRole', parentRoleId = agentUserRole.id);
            insert proxyUserRole;
            User testProxyUser1 = new User(Alias='Ref2',LastName='RfAgnt1',Username='RfPrx1' + UTIL_TestUsername_TEST.getTestUsername(),UserExternalID__c='60ccww22zzcP',Servicing_Agent_Associate_ID__c='60ccww22zzc');
            User proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;
            User testAgentUser1 = new User(Alias='Ref2',LastName='RfAgn1',Username='RefAgt' + UTIL_TestUsername_TEST.getTestUsername(),Associate_ID__c='60ccww22zzc',UserExternalID__c='60ccww22zzc_60ccww22zzc',Servicing_Agent_Associate_ID__c='60ccww22zzc');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);

            User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.Id);
            insert sysAdminUserIdSetting;
        }
    }

    private static Account createIndividualAccount(String agentUserId, String clientIdentifier) {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        Account act = new Account(ClientIdentifier__c = clientIdentifier, FirstName = 'FirstName', LastName = 'testLastName', RecordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId);
        insert act;
        insert new AgentRole__c(RelationshipNature__c = 'Customer', Agent__c = agentUserId, Customer__c = act.Id);
        return act;
    }

    private static Opportunity createOpportunity(String paramAccountId, String paramStageName, String proxyId) {
        Opportunity opty = new Opportunity(Name = 'Tst Opty', AccountId = paramAccountId, ownerId = proxyId, CloseDate = Date.today() + 1, LOB__c = 'Auto', StageName = paramStageName, RecordTypeId = optyRecordTypeId);
        insert opty;
        return opty;
    }

    private static void createTestDataForReferralMetricsOnAllStages() {
        Account convertedAct1;
        Account convertedAct2;
        Account convertedAct3;
        Account convertedAct4;
        Account convertedAct5;
        Opportunity convertedOpty1;
        Opportunity convertedOpty2;
        Opportunity convertedOpty3;
        Opportunity convertedOpty4;
        Opportunity convertedOpty5;
        User agentUser = [SELECT Id FROM User WHERE UserExternalId__c = '60ccww22zzc_60ccww22zzc' LIMIT 1];
        Account act;
        System.runAs(agentUser) {
            User proxyUser = [SELECT Id FROM User WHERE UserExternalId__c = '60ccww22zzcP' LIMIT 1];
            act = createIndividualAccount(agentUser.Id, '12345');
            convertedAct1 = createIndividualAccount(agentUser.Id, '2123456');
            convertedOpty1 = createOpportunity(convertedAct1.Id, 'New', proxyUser.Id);
            convertedAct2 = createIndividualAccount(agentUser.Id, '2123457');
            convertedOpty2 = createOpportunity(convertedAct2.Id, 'Closed Won', proxyUser.Id);
            convertedAct3 = createIndividualAccount(agentUser.Id, '2123458');
            convertedOpty3 = createOpportunity(convertedAct3.Id, 'Closed', proxyUser.Id);
            convertedAct4 = createIndividualAccount(agentUser.Id, '2123459');
            convertedOpty4 = createOpportunity(convertedAct4.Id, 'Closed', proxyUser.Id);
            convertedOpty5 = createOpportunity(convertedAct4.Id, 'Closed', proxyUser.Id);
            convertedAct5 = createIndividualAccount(agentUser.Id, '2123450');
        }
        User adminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'lRfAdm' + UTIL_TestUsername_TEST.getTestUsername());
        System.runAs(adminUser) {
            User proxyUser = [SELECT Id FROM User WHERE UserExternalId__c = '60ccww22zzcP' LIMIT 1];
            insert new List<LeadMetrics__c>{
                new LeadMetrics__c(LeadName__c = 'TestLead1', RelationshiptoReferrer__c = 'Friend', OriginalLeadSource__c = 'Customer Referral', LeadSfdcId__c = '00Q123456789100', CustomerReferrer__c = act.Id, Status__c = 'New', ownerId = proxyUser.Id),
                new LeadMetrics__c(LeadName__c = 'TestLead2', OriginalLeadSource__c = 'Customer Referral', LeadSfdcId__c = '00Q123456789101', ConvertedAccountId__c = convertedAct1.Id, ConvertedOpportunityIds__c = convertedOpty1.id, CustomerReferrer__c = act.Id, Status__c = 'Converted', ownerId = proxyUser.Id),
                new LeadMetrics__c(LeadName__c = 'TestLead3', OriginalLeadSource__c = 'Customer Referral', LeadSfdcId__c = '00Q123456789102', ConvertedAccountId__c = convertedAct2.Id, ConvertedOpportunityIds__c = convertedOpty2.id, CustomerReferrer__c = act.Id, Status__c = 'Converted', ownerId = proxyUser.Id),
                new LeadMetrics__c(LeadName__c = 'TestLead4', OriginalLeadSource__c = 'Customer Referral', LeadSfdcId__c = '00Q123456789103', ConvertedAccountId__c = convertedAct3.Id, ConvertedOpportunityIds__c = convertedOpty3.id, CustomerReferrer__c = act.Id, Status__c = 'Converted', ownerId = proxyUser.Id),
                new LeadMetrics__c(LeadName__c = 'TestLead5', OriginalLeadSource__c = 'Customer Referral', LeadSfdcId__c = '00Q123456789104', ConvertedAccountId__c = convertedAct4.Id, ConvertedOpportunityIds__c = convertedOpty4.id + '-' + convertedOpty5.id, CustomerReferrer__c = act.Id, Status__c = 'Converted', ownerId = proxyUser.Id),
                new LeadMetrics__c(LeadName__c = 'TestLead6', OriginalLeadSource__c = 'Customer Referral', LeadSfdcId__c = '00Q123456789105', ConvertedAccountId__c = convertedAct5.Id,ConvertedOpportunityIds__c = '123456789123456', CustomerReferrer__c = act.Id, Status__c = 'Converted', ownerId = proxyUser.Id),
                new LeadMetrics__c(LeadName__c = 'TestLead7', RelationshiptoReferrer__c = 'Friend', OriginalLeadSource__c = 'Customer Referral', LeadSfdcId__c = '00Q123456789106', CustomerReferrer__c = act.Id, Status__c = 'Deleted', ownerId = proxyUser.Id)
            };
        }
    }

    //test method to verify the converted Lead(Open, Closed Won, Closed Lost) and Lead open status.
    @isTest private static void testReferralSummaryForAllOpportunityStages() {
        User agentUser = [SELECT Id FROM User WHERE UserExternalId__c = '60ccww22zzc_60ccww22zzc' LIMIT 1];
        createTestDataForReferralMetricsOnAllStages();
        System.runAs(agentUser) {
            List<LeadMetrics__c> ldMetricsList = [SELECT id, LeadName__c, Status__c, RelationshiptoReferrer__c, LeadSfdcId__c, ConvertedAccountId__c, ConvertedOpportunityIds__c FROM LeadMetrics__c];
            Test.startTest();
            LeadReferralSummaryController.LeadReferralSummaryResponse ldRefSumamryResponse = LeadReferralSummaryController.getReferralSummary(ldMetricsList);
            Test.stopTest();
            System.assertEquals(7, ldRefSumamryResponse.leadReferralList.size(), 'LeadReferral Summary is Incorrect');

            System.assertEquals('Open', ldRefSumamryResponse.leadReferralList.get(0).referralStatus, 'New Referral Status is Incorrect');
            System.assertEquals('TestLead1', ldRefSumamryResponse.leadReferralList.get(0).referralName, 'New Referral Name is Incorrect');
            System.assert((ldRefSumamryResponse.leadReferralList.get(0).hyperLinkId).startsWith('00Q'), 'New - Hyperlink Id is Incorrect');
            System.assert(String.isNotBlank(ldRefSumamryResponse.leadReferralList.get(0).relationshipToReferrer), 'New - Relationship to Referrer is Incorrect');

            System.assertEquals('Converted - Open', ldRefSumamryResponse.leadReferralList.get(1).referralStatus, 'Converted - Open Referral Status is Incorrect');
            System.assertEquals('FirstName testLastName', ldRefSumamryResponse.leadReferralList.get(1).referralName, 'Converted - Open Referral Name is Incorrect');
            System.assert((ldRefSumamryResponse.leadReferralList.get(1).hyperLinkId).startsWith('001'), 'Converted - Open - Hyperlink Id is Incorrect');
            System.assert(String.isBlank(ldRefSumamryResponse.leadReferralList.get(1).relationshipToReferrer), 'Converted - Open - Relationship to Referrer is Incorrect');

            System.assertEquals('Converted - Closed Won', ldRefSumamryResponse.leadReferralList.get(2).referralStatus, 'Converted - Closed Won Referral Status is Incorrect');
            System.assertEquals('FirstName testLastName', ldRefSumamryResponse.leadReferralList.get(2).referralName, 'Converted - Closed Won Referral Name is Incorrect');
            System.assert((ldRefSumamryResponse.leadReferralList.get(2).hyperLinkId).startsWith('001'), 'Converted - Closed Won - Hyperlink Id is Incorrect');
            System.assert(String.isBlank(ldRefSumamryResponse.leadReferralList.get(2).relationshipToReferrer), 'Converted - Relationship to Referrer is Incorrect');

            System.assertEquals('Converted - Closed Lost', ldRefSumamryResponse.leadReferralList.get(3).referralStatus, 'Converted - Closed Lost Referral Status is Incorrect');
            System.assertEquals('FirstName testLastName', ldRefSumamryResponse.leadReferralList.get(3).referralName, 'Converted - Closed Lost Referral Name is Incorrect');
            System.assert(String.isBlank(ldRefSumamryResponse.leadReferralList.get(3).hyperLinkId), 'Converted - Closed Lost - Hyperlink Id is Incorrect');
            System.assert(String.isBlank(ldRefSumamryResponse.leadReferralList.get(3).relationshipToReferrer), 'Converted - Closed Lost - Relationship to Referrer is Incorrect');

            System.assertEquals('Converted - Closed Lost', ldRefSumamryResponse.leadReferralList.get(4).referralStatus, 'Converted - Closed Lost Referral Status is Incorrect');
            System.assertEquals('FirstName testLastName', ldRefSumamryResponse.leadReferralList.get(4).referralName, 'Converted - Closed Lost Referral Name is Incorrect');
            System.assert(String.isBlank(ldRefSumamryResponse.leadReferralList.get(4).hyperLinkId), 'Converted - Closed Lost - Hyperlink Id is Incorrect');
            System.assert(String.isBlank(ldRefSumamryResponse.leadReferralList.get(4).relationshipToReferrer), 'Converted - Closed Lost- Relationship to Referrer is Incorrect');

            System.assertEquals('Converted', ldRefSumamryResponse.leadReferralList.get(5).referralStatus, 'Converted Referral Status is Incorrect');
            System.assertEquals('FirstName testLastName', ldRefSumamryResponse.leadReferralList.get(5).referralName, 'Converted Referral Name is Incorrect');
            System.assert(String.isNotBlank(ldRefSumamryResponse.leadReferralList.get(5).hyperLinkId), 'Converted - Hyperlink Id is Incorrect');
            System.assert(String.isBlank(ldRefSumamryResponse.leadReferralList.get(5).relationshipToReferrer), 'Converted - Relationship to Referrer is Incorrect');

            System.assertEquals('Deleted', ldRefSumamryResponse.leadReferralList.get(6).referralStatus, 'Deleted Referral Status is Incorrect');
            System.assertEquals('TestLead7', ldRefSumamryResponse.leadReferralList.get(6).referralName, 'Deleted Referral Name is Incorrect');
            System.assert(String.isBlank(ldRefSumamryResponse.leadReferralList.get(6).hyperLinkId), 'Deleted - Hyperlink Id is Incorrect');
            System.assert(String.isNotBlank(ldRefSumamryResponse.leadReferralList.get(6).relationshipToReferrer), 'Deleted - Relationship to Referrer is Incorrect');

            System.assert(String.isBlank(ldRefSumamryResponse.referralSummaryPgErrorMessage), 'Page Error Message is Incorrect');
        }
    }

    private static void createTestDataForNoAccessOnConvertedAccount() {
        User adminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'lRfAdm' + UTIL_TestUsername_TEST.getTestUsername());
        Account act;
        User agentUser = [SELECT Id FROM User WHERE UserExternalId__c = '60ccww22zzc_60ccww22zzc' LIMIT 1];
        System.runAs(agentUser) {
            act = createIndividualAccount(agentUser.Id, '72345');
        }
        System.runAs(adminUser) {
            User proxyUser = [SELECT Id FROM User WHERE UserExternalId__c = '60ccww22zzcP' LIMIT 1];
            insert new List<LeadMetrics__c>{
                new LeadMetrics__c(LeadName__c = 'TestLead1', RelationshiptoReferrer__c = 'Friend', LeadSfdcId__c = '00Q123456789103', OriginalLeadSource__c = 'Customer Referral',
                ConvertedAccountId__c = '123456789123456', ConvertedOpportunityIds__c = '123456789123456', CustomerReferrer__c = act.Id, Status__c = 'Converted', ownerId = proxyUser.Id)
            };
        }
    }

    //test method to verify the converted Lead on No Book of Business
    @isTest private static void testReferralSummaryForRemovedBookOfBusiness() {
        User agentUser = [SELECT Id FROM User WHERE UserExternalId__c = '60ccww22zzc_60ccww22zzc' LIMIT 1];
        createTestDataForNoAccessOnConvertedAccount();
        System.runAs(agentUser) {
            List<LeadMetrics__c> ldMetricsList = [SELECT id, LeadName__c, Status__c, RelationshiptoReferrer__c, LeadSfdcId__c, ConvertedAccountId__c, ConvertedOpportunityIds__c FROM LeadMetrics__c];
            Test.startTest();
            LeadReferralSummaryController.LeadReferralSummaryResponse ldRefSumamryResponse = LeadReferralSummaryController.getReferralSummary(ldMetricsList);
            Test.stopTest();
            System.assertEquals(1, ldRefSumamryResponse.leadReferralList.size(), 'LeadReferral Summary is Incorrect');

            System.assertEquals('Converted', ldRefSumamryResponse.leadReferralList.get(0).referralStatus, 'Converted Referral Status is Incorrect');
            System.assertEquals('TestLead1', ldRefSumamryResponse.leadReferralList.get(0).referralName, 'Converted Referral Name is Incorrect');
            System.assert(String.isBlank(ldRefSumamryResponse.leadReferralList.get(0).hyperLinkId), 'Converted - Hyperlink Id is Incorrect');
            System.assertEquals('Friend', (ldRefSumamryResponse.leadReferralList.get(0).relationshipToReferrer), 'Converted - Relationship to Referrer is Incorrect');

            System.assert(String.isBlank(ldRefSumamryResponse.referralSummaryPgErrorMessage), 'Page Error Message is Incorrect');
        }
    }
}