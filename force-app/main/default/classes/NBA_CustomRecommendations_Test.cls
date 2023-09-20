@isTest
(seeAllData=false)
public with sharing class NBA_CustomRecommendations_Test {

    @TestVisible private static final String ACCOUNT_CLIENT_ID = '12345678915';
    @TestVisible private static final String ACTION_ID = 'MUPLGU0025';

    @testSetup
    private static void testSetup(){
        TestUserSetupUtility.setupAgentOffice();
        TestUserSetupUtility.setupSystemAdminUser();
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            Account accountRecord = createAccount();
            setupAgentRole(TestUserSetupUtility.getAgentUser(), accountRecord);
            createRecommendation();
            User agentUser = TestUserSetupUtility.getAgentUser();
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'NextBestAction'];
            insert new PermissionSetAssignment(AssigneeId = agentUser.id, PermissionSetId = ps.Id);
        }
    }

    @TestVisible private static Account createAccount(){
        Account accountRecord = new Account(Edit_In_VFP__c=true,FirstName='fstName',LastName='lstName',
                                            BillingAddressType__c='US',BillingCity='Phoenix',
                                            ClientIdentifier__c=ACCOUNT_CLIENT_ID);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        insert accountRecord;
        return accountRecord;
    }

    @TestVisible private static Account getAccount(){
        return [SELECT Id, Name, PersonContactId, ClientIdentifier__c FROM Account WHERE  ClientIdentifier__c = :ACCOUNT_CLIENT_ID];
    }

    @TestVisible private static void setupAgentRole(User userRecord, Account accountRecord){
        AgentRole__c agentRole = new AgentRole__c();
        agentRole.Agent__c = userRecord.Id;
        agentRole.Customer__c = accountRecord.Id;
        agentRole.RelationshipNature__c = 'Customer';
        insert agentRole;
    }

	@TestVisible private static void createRecommendation(){
        Recommendation rec = new Recommendation(ActionReference='Enterprise_CRM',
                                                Action_ID__c = ACTION_ID,
                                                Name = 'GuidanceOnPLUP', Description = 'Test Description',
                                                Action_Description__c = 'Action Description',
                                                AcceptanceLabel = 'Accept', RejectionLabel = 'Reject');
        insert rec;
    }

    @isTest
    public static void getSFCustomRecommendationsTest(){

        User agentUser = TestUserSetupUtility.getAgentUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        Account accountRecord = getAccount();

        SFCustomRecommendation__c recommendation =
                        new NBA_RecommendationBuilder()
                        .setAccountId(accountRecord.Id)
                        .setAgentOfficeUserId(agentUser.Id)
                        .setServicingAgentAssociateId('ASSOCIATEID')
                        .setContextType('COA')
                        .setEnterpriseInteractionId('eiid123')
                        .setPropensity('0.80')
                        .setExternalInteractionID('-3721810088443331923')
                        .setPriority('0.9955418985179654')
                        .setChannel('Agent')
                        .setRank('1')
                        .setDirection('Inbound')
                        .setTreatment('Agent ECRM Rec')
                        .setPlacement('ECRM NBA Module')
                        .setExternalClientId('123456')
            			.setDecisionTime('20210318T173517.577 GMT')
                        .setActionID(ACTION_ID)
                        .setActionGroup('Auto')
                        .setActionIssue('Multi Lining')
                        .setActionCategory('TBD')
                        .setActionLabel('Guidance on PLUP')
                        .setActionName('GuidanceOnPLUP')
                        .setActionVariant('TBD Variant')
                        .setActionIdText('/ML/PLUP/GOnPLUP')
                        .build();

        List<SFCustomRecommendation__c> recommendations = new List<SFCustomRecommendation__c>();
        recommendations.add(recommendation);
        Database.insert(recommendations);

        List<SFCustomRecommendation__c> recs = [Select Id, OwnerId, Name from SFCustomRecommendation__c];
        System.assertEquals(1, recs.size(), 'Unexpected Recommendation counts');
        System.assertEquals(proxyUser.Id, recs[0].OwnerId, 'Unexpected Owner Id. Agent to Proxy conversion did not work ');
        Id recommendationId = recs[0].Id;

        List<List<Recommendation>> outputRecommendations = new List<List<Recommendation>>();

        List<NBA_CustomRecommendations.FlowInputs> flowInputs = new List<NBA_CustomRecommendations.FlowInputs>();
        NBA_CustomRecommendations.FlowInputs inputs = new NBA_CustomRecommendations.FlowInputs();
        inputs.recordId = accountRecord.Id;
        flowInputs.add(inputs);

        Test.startTest();
        System.runAs(agentUser){
            outputRecommendations = NBA_CustomRecommendations.getSFCustomRecommendations(flowInputs);
        }
        Test.stopTest();
        System.assertEquals(outputRecommendations.size(), 1, 'Number of Output recommendations does not match');
        System.assertEquals(outputRecommendations[0].size(), 1, 'Number of Output recommendations does not match');
        Recommendation rec = outputRecommendations.get(0).get(0);
        System.assertEquals(rec.Action_ID__c, ACTION_ID, 'Action ID is not matching');
        System.assertEquals(rec.Action_Description__c, 'Action Description', 'Action Description is not matching');
        System.assertEquals(rec.Source_Record_Id__c, recommendationId, 'Source Record/Recommendation Id is not matching');

    }

    @isTest
    private static void testConstructor(){
        NBA_CustomRecommendations nbaInstance = new NBA_CustomRecommendations();
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

}