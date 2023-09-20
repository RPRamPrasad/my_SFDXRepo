@isTest
(seeAllData=false)
public class UserSurveyControllerTest {
    @testSetup
    private static void testSetup() {
        TestUserSetupUtility.setupSystemAdminUser();
        TestUserSetupUtility.setupAgentOffice();
    }

    private static void setupFeatureAccess() {
        FeatureAccess__c agentEntry = new FeatureAccess__c(
            Feature_Name__c = 'FeedbackManagement',
            Managed_By_Team__c = 'SimpliFi',
            Permission__c = '{ "Agent": true }',
            UserFieldName__c ='SubUserType__c',
            UserFieldValue__c = 'Agent'
        );
        FeatureAccess__c atmEntry = new FeatureAccess__c(
            Feature_Name__c = 'FeedbackManagement',
            Managed_By_Team__c = 'SimpliFi',
            Permission__c = '{ "ATM": true }',
            UserFieldName__c ='SubUserType__c',
            UserFieldValue__c = 'ATM'
        );
        FeatureAccess__c pilotAEntry = new FeatureAccess__c(
            Feature_Name__c = 'FeedbackManagement',
            Managed_By_Team__c = 'SimpliFi',
            Permission__c = '{ "PilotGroupA": true }',
            UserFieldName__c ='UserCriteriaList__c',
            UserFieldValue__c = 'FeedbackManagement_PilotGroupA'
        );
        FeatureAccess__c pilotBEntry = new FeatureAccess__c(
            Feature_Name__c = 'FeedbackManagement',
            Managed_By_Team__c = 'SimpliFi',
            Permission__c = '{ "PilotGroupB": true }',
            UserFieldName__c ='UserCriteriaList__c',
            UserFieldValue__c = 'FeedbackManagement_PilotGroupB'
        );

        insert agentEntry;
        insert atmEntry;
        insert pilotAEntry;
        insert pilotBEntry;
    }

    private static void createTestSurveys(Id ownerId) {
        User_Survey__c agentSurvey;
        User_Survey_Question__c agentSurveyQuestion;
        User_Survey__c pilotSurvey;
        User_Survey_Question__c pilotSurveyQuestion;

        agentSurvey = new User_Survey__c(
            Title__c = 'AgentSurvey',
            Description__c = 'Test survey.',
            Targeted_User_Groups__c = 'Agent',
            OwnerId = ownerId,
            IsActive__c = true,
            Feature__c = 'E-654321'
        );
        insert agentSurvey;
        pilotSurvey = new User_Survey__c(
            Title__c = 'ATMSurvey',
            Description__c = 'Test survey.',
            Targeted_User_Groups__c = 'PilotGroupA',
            OwnerId = ownerId,
            IsActive__c = true,
            Feature__c = 'E-Idontexist'
        );
        insert pilotSurvey;

        agentSurveyQuestion = new User_Survey_Question__c(
            Title__c = 'This is an Agent test question',
            OwnerId = ownerId,
            QuestionType__c = 'Star Rating',
            UserSurvey__c = agentSurvey.Id
        );
        insert agentSurveyQuestion;

        pilotSurveyQuestion = new User_Survey_Question__c(
            Title__c = 'This is a PilotGroupA test question',
            OwnerId = ownerId,
            QuestionType__c = 'Star Rating',
            UserSurvey__c = pilotSurvey.Id
        );
        insert pilotSurveyQuestion;
    }

    @isTest
    private static void testGetSurveysForAgent() {
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        User agentUser = TestUserSetupUtility.getAgentUser();
        agentUser.UserType__c = 'Agency';
        agentUser.SubUserType__c = 'Agent';
        agentUser.UserCriteriaList__c = 'Agent';
        update agentUser;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ECRM_FeedbackManagement_Admin'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = agentUser.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;

        // Setup test data.
        System.runAs(sysAdminUser) {
            setupFeatureAccess();
            createTestSurveys(sysAdminUser.Id);
        }
        //
        System.runAs(agentUser) {
            Test.startTest();
            Map<Id, User_Survey__c> surveys = new Map<Id, User_Survey__c>(UserSurveyController.getSurveys());
            System.assertEquals(1, surveys.size(), 'Expected one survey (one for Agent) for this case received: ' + surveys.size());
            Test.stopTest();
        }
    }

    @isTest
    private static void testGetSurveysForPilotAgent() {
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        User agentUser = TestUserSetupUtility.getAgentUser();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        agentUser.UserType__c = 'Agency';
        agentUser.SubUserType__c = 'Agent';
        agentUser.UserCriteriaList__c = 'Agent,FeedbackManagement_PilotGroupA';
        update agentUser;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ECRM_FeedbackManagement_Admin'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = agentUser.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;

        // Setup test data.
        System.runAs(sysAdminUser) {
            setupFeatureAccess();
            createTestSurveys(sysAdminUser.Id);
        }
        //
        System.runAs(agentUser) {
            Test.startTest();
            Map<Id, User_Survey__c> surveys = new Map<Id, User_Survey__c>(UserSurveyController.getSurveys());
            System.assertEquals(2, surveys.size(), 'Expected two surveys (one for Agent another for Pilot Group A) for this case received: ' + surveys.size());
            Test.stopTest();
        }
    }

    @isTest
    private static void testGetSurveyByNameForAgent() {
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        User agentUser = TestUserSetupUtility.getAgentUser();
        agentUser.UserType__c = 'Agency';
        agentUser.SubUserType__c = 'Agent';
        agentUser.UserCriteriaList__c = 'Agent,FeedbackManagement_PilotGroupA';
        update agentUser;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ECRM_FeedbackManagement_Admin'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = agentUser.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;

        // Setup test data.
        System.runAs(sysAdminUser) {
            setupFeatureAccess();
            createTestSurveys(sysAdminUser.Id);
        }
        //
        System.runAs(agentUser) {
            Test.startTest();
            User_Survey__c survey = UserSurveyController.getSurveyByName('AgentSurvey');
            System.assertEquals('AgentSurvey', survey.Title__c, 'Expected AgentSurvey but received: ' + survey.Title__c);
            Test.stopTest();
        }
    }

    @isTest
    private static void testGetSurveyByFeatureForAgent() {
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        User agentUser = TestUserSetupUtility.getAgentUser();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        agentUser.UserType__c = 'Agency';
        agentUser.SubUserType__c = 'Agent';
        agentUser.UserCriteriaList__c = 'Agent,FeedbackManagement_PilotGroupA';
        update agentUser;
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ECRM_FeedbackManagement_Admin'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = agentUser.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;

        // Setup test data.
        System.runAs(sysAdminUser) {
            setupFeatureAccess();
            createTestSurveys(sysAdminUser.Id);
        }
        //
        System.runAs(agentUser) {
            Test.startTest();
            User_Survey__c survey = UserSurveyController.getSurveyByFeature('E-Idontexist');
            System.assertEquals('ATMSurvey', survey.Title__c, 'Expected ATMSurvey but received: ' + survey.Title__c);
            Test.stopTest();
        }
    }

    @isTest
    private static void testFailedGetSurveyByNameForAgent() {
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        User agentUser = TestUserSetupUtility.getAgentUser();
        agentUser.UserType__c = 'Agency';
        agentUser.SubUserType__c = 'Agent';
        agentUser.UserCriteriaList__c = 'Agent,FeedbackManagement_PilotGroupA';
        update agentUser;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ECRM_FeedbackManagement_Admin'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = agentUser.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;

        // Setup test data.
        System.runAs(sysAdminUser) {
            setupFeatureAccess();
            createTestSurveys(sysAdminUser.Id);
        }
        //
        System.runAs(agentUser) {
            Test.startTest();
            Boolean error = false;
            try {
                User_Survey__c survey = UserSurveyController.getSurveyByName('I am not a survey that exists out there.');
            }
            catch( Exception ex) {
                error = true;
            }
            System.assertEquals(true, error, 'Expected error since survey should not exist but executed normally.');
            Test.stopTest();
        }
    }

    @isTest
    private static void testFailedGetSurveyByFeatureForAgent() {
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        User agentUser = TestUserSetupUtility.getAgentUser();
        agentUser.UserType__c = 'Agency';
        agentUser.SubUserType__c = 'Agent';
        agentUser.UserCriteriaList__c = 'Agent,FeedbackManagement_PilotGroupA';
        update agentUser;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ECRM_FeedbackManagement_Admin'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = agentUser.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;

        // Setup test data.
        System.runAs(sysAdminUser) {
            setupFeatureAccess();
            createTestSurveys(sysAdminUser.Id);
        }
        //

        System.runAs(agentUser) {
            Test.startTest();
            Boolean error = false;
            try {
                User_Survey__c survey = UserSurveyController.getSurveyByFeature('123451');
            }
            catch( Exception ex) {
                error = true;
            }
            System.assertEquals(true, error, 'Expected error since survey should not exist but executed normally.');
            Test.stopTest();
        }
    }
}