@isTest
(seeAllData=false)
public with sharing class NBA_RecommendationService_TEST {
    
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
                                                Name = 'Test Action', Description = 'Test Description',
                                                AcceptanceLabel = 'Accept', RejectionLabel = 'Reject');
        insert rec;
    }
    
    @isTest
    public static void saveRecommendationsTest(){

        User agentUser = TestUserSetupUtility.getAgentUser();
        User proxyUser = TestUserSetupUtility.getProxyUser();
        User sysAdmin = TestUserSetupUtility.getSysAdminUser();
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
        Test.startTest();
        System.runAs(sysAdmin){
            NBA_RecommendationService.saveRecommendations(recommendations);
        }
        Test.stopTest();
        List<SFCustomRecommendation__c> recs = [Select Id, OwnerId, Name from SFCustomRecommendation__c];
        System.assertEquals(1, recs.size(), 'Unexpected Recommendation counts');
        System.assertEquals(proxyUser.Id, recs[0].OwnerId, 'Unexpected Owner Id. Agent to Proxy conversion did not work ');
    }

    
    @isTest
    public static void replaceRecommendationsTest(){

        User proxyUser = TestUserSetupUtility.getProxyUser();
        User sysAdmin = TestUserSetupUtility.getSysAdminUser();
        Account accountRecord = getAccount();

        SFCustomRecommendation__c recommendation = 
                        new NBA_RecommendationBuilder()
                        .setAccountId(accountRecord.Id)
                        .setAgentOfficeUserId(proxyUser.Id)
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
        
        
        SFCustomRecommendation__c newRecommendation = 
                        new NBA_RecommendationBuilder()
                        .setAccountId(accountRecord.Id)
                        .setAgentOfficeUserId(proxyUser.Id)
                        .setServicingAgentAssociateId('ASSOCIATEID')
                        .setContextType('COA')
                        .setEnterpriseInteractionId('eiid1234')
                        .setPropensity('0.80')
                        .setExternalInteractionID('-3721810088443331923')
                        .setPriority('0.9955418985179654')
                        .setChannel('Agent')
                        .setRank('2')
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
        
        List<SFCustomRecommendation__c> newRecommendationsToSave = new List<SFCustomRecommendation__c>();
        newRecommendationsToSave.add(newRecommendation);

        Test.startTest();
        System.runAs(sysAdmin){
            NBA_RecommendationService.saveRecommendations(newRecommendationsToSave);
        }

        Test.stopTest();
        List<SFCustomRecommendation__c> recs = [Select Id, OwnerId, Status__c, EIID__c, Name from SFCustomRecommendation__c];
        System.assertEquals(2, recs.size(), 'Unexpected Recommendation counts');
        List<SFCustomRecommendation__c> replacedRecommendations = [Select Id, OwnerId, Status__c, Name from SFCustomRecommendation__c where Status__c = 'Replaced'];
        System.assertEquals(1, replacedRecommendations.size(), 'Unexpected Recommendation counts');
        System.assertEquals('Replaced', replacedRecommendations[0].Status__c, 'Status is not replaced');
        List<SFCustomRecommendation__c>  newRecommendations = [Select Id, OwnerId, Status__c, Name from SFCustomRecommendation__c where Status__c = 'New'];
        System.assertEquals(1, newRecommendations.size(), 'Unexpected Recommendation counts');
        System.assertEquals('New', newRecommendations[0].Status__c, 'Status is not New');
        
        
    }
    
}