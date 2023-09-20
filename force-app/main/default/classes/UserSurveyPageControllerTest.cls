@isTest
(seeAllData=false)
public with sharing class UserSurveyPageControllerTest {
    @testSetup
    private static void testSetup() {
        TestUserSetupUtility.setupSystemAdminUser();
        TestUserSetupUtility.setupAgentOffice();
    }

    @isTest
    private static void testSuccessfulHandleResponses() {
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        User_Survey__c testSurvey;
        User_Survey_Question__c testQuestion;

        System.runAs(sysAdminUser) {
            testSurvey = new User_Survey__c(
                Title__c = 'AgentSurvey',
                Description__c = 'Test survey.',
                Targeted_User_Groups__c = 'Agent',
                OwnerId = sysAdminUser.Id
            );
            insert testSurvey;

            testQuestion = new User_Survey_Question__c(
                Title__c = 'This is a test question',
                OwnerId = sysAdminUser.Id,
                QuestionType__c = 'Star Rating',
                UserSurvey__c = testSurvey.Id
            );
            insert testQuestion;
        }

        // Create response and question responses for the wrapper.
        User_Survey_Response__c surveyResponse = new User_Survey_Response__c(
            UserSurvey__c = testSurvey.Id,
            OwnerId = testSurvey.OwnerId
        );

        List<User_Survey_Question_Response__c> questionResponses = new List<User_Survey_Question_Response__c>();
        questionResponses.add(new User_Survey_Question_Response__c(
            UserSurveyQuestion__c = testQuestion.Id,
            NumericResponse__c = 5,
            OwnerId = testSurvey.OwnerId
        ));

        UserSurveyWrapper wrapper = new UserSurveyWrapper();
        wrapper.surveyQuestionResponses = questionResponses;
        wrapper.surveyResponse = surveyResponse;

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ECRM_FeedbackManagement_Submitter'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = sysAdminUser.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;

        System.runAs(sysAdminUser) {
            Test.startTest();
            String result = UserSurveyPageController.handleResponses(wrapper);
            System.assertEquals(result, 'Survey Response Saved Successfully', 'Output is not as expected for successful insert.');
            Test.stopTest();
        }
    }

    @isTest
    private static void testPartialHandleResponses() {
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        User_Survey__c testSurvey;
        User_Survey_Question__c testQuestion;

        UserSurveyWrapper wrapper = new UserSurveyWrapper();
        wrapper.surveyQuestionResponses = null;
        wrapper.surveyResponse = null;

        System.runAs(sysAdminUser) {
            Test.startTest();
            String result = UserSurveyPageController.handleResponses(wrapper);
            System.assertEquals(result, 'There were no responses submitted.', 'Output is not as expected for successful insert.');
            Test.stopTest();
        }
    }

    @isTest
    private static void testFailOnSurveyResponse() {
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        User_Survey__c testSurvey;
        User_Survey_Question__c testQuestion;

        System.runAs(sysAdminUser) {
            testSurvey = new User_Survey__c(
                Title__c = 'AgentSurvey',
                Description__c = 'Test survey.',
                Targeted_User_Groups__c = 'Agent',
                OwnerId = sysAdminUser.Id
            );
            insert testSurvey;

            testQuestion = new User_Survey_Question__c(
                Title__c = 'This is a test question',
                OwnerId = sysAdminUser.Id,
                QuestionType__c = 'Star Rating',
                UserSurvey__c = testSurvey.Id
            );
            insert testQuestion;
        }

        // Create response and question responses for the wrapper.
        User_Survey_Response__c surveyResponse = new User_Survey_Response__c();

        List<User_Survey_Question_Response__c> questionResponses = new List<User_Survey_Question_Response__c>();
        questionResponses.add(new User_Survey_Question_Response__c(
            UserSurveyQuestion__c = testQuestion.Id,
            NumericResponse__c = 5,
            OwnerId = testSurvey.OwnerId
        ));

        UserSurveyWrapper wrapper = new UserSurveyWrapper();
        wrapper.surveyQuestionResponses = questionResponses;
        wrapper.surveyResponse = surveyResponse;

        System.runAs(sysAdminUser) {
            Test.startTest();
            Boolean exceptionOccurred = false;
            try {
                UserSurveyPageController.handleResponses(wrapper);
            } catch (Exception ex) {
                exceptionOccurred = true;
            }
            System.assertEquals(exceptionOccurred, true, 'Expected error for missing fields when handling responses.');
            Test.stopTest();
        }
    }

    @isTest
    private static void testFailOnSurveyQuestionResponses() {
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        User_Survey__c testSurvey;
        User_Survey_Question__c testQuestion;

        System.runAs(sysAdminUser) {
            testSurvey = new User_Survey__c(
                Title__c = 'AgentSurvey',
                Description__c = 'Test survey.',
                Targeted_User_Groups__c = 'Agent',
                OwnerId = sysAdminUser.Id
            );
            insert testSurvey;

            testQuestion = new User_Survey_Question__c(
                Title__c = 'This is a test question',
                OwnerId = sysAdminUser.Id,
                QuestionType__c = 'Star Rating',
                UserSurvey__c = testSurvey.Id
            );
            insert testQuestion;
        }

        // Create response and question responses for the wrapper.
        User_Survey_Response__c surveyResponse = new User_Survey_Response__c(
            UserSurvey__c = testSurvey.Id,
            OwnerId = testSurvey.OwnerId
        );

        List<User_Survey_Question_Response__c> questionResponses = new List<User_Survey_Question_Response__c>();
        questionResponses.add(new User_Survey_Question_Response__c(
            NumericResponse__c = 5
        ));

        UserSurveyWrapper wrapper = new UserSurveyWrapper();
        wrapper.surveyQuestionResponses = questionResponses;
        wrapper.surveyResponse = surveyResponse;

        System.runAs(sysAdminUser) {
            Test.startTest();
            Boolean exceptionOccurred = false;
            try {
                UserSurveyPageController.handleResponses(wrapper);
            } catch (Exception ex) {
                exceptionOccurred = true;
            }
            System.assertEquals(exceptionOccurred, true, 'Expected error for missing fields when handling responses.');
            Test.stopTest();
        }
    }
}