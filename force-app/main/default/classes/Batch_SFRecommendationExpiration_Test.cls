/**
  * @name Batch_SFRecommendationExpiration_Test
  * @author Team Skynet
  * @createdDate 01/21/2022
  * @description Apex unit testing for Batch_SFRecommendationExpiration Batch class
  */
@isTest(seeAllData = false)
public class Batch_SFRecommendationExpiration_Test {

    private static final String STATUS_NEW = 'New';
    private static final String STATUS_EXPIRED = 'Expired';
    private static Integer daysOlderThan = 0;

    @TestVisible private static final String ACCOUNT_CLIENT_ID = '12345678915';
    @TestVisible private static final String ACTION_ID = 'MUPLGU0025';

    @testSetup
    private static void testSetup(){
        TestUserSetupUtility.setupAgentOffice();
        TestUserSetupUtility.setupSystemAdminUser();
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            Account accountRecord = createAccount();
            setupAgentRole(TestUserSetupUtility.getAgentUser(), accountRecord);
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

    @isTest
    public static void expireRecommendationsTest(){

        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            CS_NBA_Config__c daysUntilExpired = new CS_NBA_Config__c();
            daysUntilExpired.Name = 'DaysUntilExpired';
            daysUntilExpired.Value__c = 0;
            insert daysUntilExpired;
        }

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

        System.assertEquals(true, !recommendations.isEmpty(), 'There should be at least one recommendation in a list');

        System.runAs(sysAdmin){
            NBA_RecommendationService.saveRecommendations(recommendations);
        }
        List<SFCustomRecommendation__c> recs = [Select Id, Status__c, Name from SFCustomRecommendation__c];
        System.assertEquals(true, !recs.isEmpty(), 'Verify that our list has entries in it');

        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(recs[0].Id, yesterday);
        System.assertEquals(STATUS_NEW, recs[0].Status__c, 'Unexpected status, should be New');
        Batch_SFRecommendationExpiration sched = new Batch_SFRecommendationExpiration();

        Test.startTest();
        sched.execute(null, recs);
        Test.stopTest();

        List<SFCustomRecommendation__c> recsAfter = [Select Id, Status__c, Name from SFCustomRecommendation__c];
        System.assertEquals(STATUS_EXPIRED, recsAfter[0].Status__c, 'Unexpected status, should be Expired');
    }


    @isTest
    public static void expireRecommendationsNoConfigTest(){

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

        System.assertEquals(true, !recommendations.isEmpty(), 'There should be at least one recommendation in a list');

        System.runAs(sysAdmin){
            NBA_RecommendationService.saveRecommendations(recommendations);
        }
        List<SFCustomRecommendation__c> recs = [Select Id, Status__c, Name from SFCustomRecommendation__c];
        System.assertEquals(true, !recs.isEmpty(), 'Verify that our list has entries in it');

        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(recs[0].Id, yesterday);
        System.assertEquals(STATUS_NEW, recs[0].Status__c, 'Unexpected status, should be New');
        Batch_SFRecommendationExpiration sched = new Batch_SFRecommendationExpiration();

        Test.startTest();
        sched.execute(null, recs);
        Test.stopTest();

        List<SFCustomRecommendation__c> recsAfter = [Select Id, Status__c, Name from SFCustomRecommendation__c];
        System.assertEquals(STATUS_EXPIRED, recsAfter[0].Status__c, 'Unexpected status, should be Expired');
    }

    @isTest
    private static void scheduleBatchTest(){

        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            CS_NBA_Config__c daysUntilExpired = new CS_NBA_Config__c();
            daysUntilExpired.Name = 'DaysUntilExpired';
            daysUntilExpired.Value__c = 0;
            insert daysUntilExpired;
        }

        Date todaysDate = System.today();
        Batch_SFRecommendationExpiration sched = new Batch_SFRecommendationExpiration();
        Integer nextYear = todaysDate.Year() +1;
        String cronExpr = '0 0 0 15 3 ? ' + nextYear;
        Test.startTest();
        String jobId = System.schedule('Batch_SFRecommendationExpiration', cronExpr, sched);
        sched.execute(null);
        Test.stopTest();
        System.assert(jobId != null, 'Batch Process Id returned null.');
    }

}