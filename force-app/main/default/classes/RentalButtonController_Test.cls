/**
* @name RentalButtonController_Test
* @author Team Moneyball
* @createDate 02/01/2023
* @description The Apex test class for RentalButtonController class.
*/
@isTest
public with sharing class RentalButtonController_Test {
    /**
     * @description setup
     */
    @TestSetup
    public static void setup() {
        HttpRequestCalloutHelper_Test.insertContinuationRecord('MockREST', 'https://mock.callout/request/{0}', '');
    }

    @isTest
    public static void getTestInfoFailedTest() {
        Map<String,Object> input =inputParameters();
        Test.setMock(HttpCalloutMock.class, new HttpRequestCalloutResponseMockGenerator(200,'{payload:"value"}' ));

        Test.startTest();
        HttpRequestCalloutHelper.HttpCalloutResponse response  = RentalButtonController.getClaimInvestigation(input);
        HttpRequestCalloutHelper.HttpCalloutResponse response2 = RentalButtonController.getClaimCoverage(input);
        HttpRequestCalloutHelper.HttpCalloutResponse response3 = RentalButtonController.getRepairAssignment(input);
        HttpRequestCalloutHelper.HttpCalloutResponse response4;
        response4 = RentalButtonController.getRentalAssignment(input);
        HttpRequestCalloutHelper.HttpCalloutResponse response5;
        response5 = RentalButtonController.getClaimProvider(input);

        Test.stopTest();
        System.assertNotEquals(null, response,  'not null');
        System.assertNotEquals(null, response2, 'not null');
        System.assertNotEquals(null, response3, 'not null');
    }

    @isTest
    public static void getClaimInvestigationFailedTest() {
        try {
            Test.startTest();
            HttpRequestCalloutHelper.HttpCalloutResponse response;
            response = RentalButtonController.getClaimInvestigation(inputParameters());
            Test.stopTest();
        } catch (Exception e) {
            System.assertEquals(System.AuraHandledException.class.getName(), e.getTypeName(), 'AuraHandledException is expected');
        }
    }

    @isTest
    public static void getClaimCoverageFailedTest() {
        try {
            Test.startTest();
            HttpRequestCalloutHelper.HttpCalloutResponse response3;
            response3 = RentalButtonController.getClaimCoverage(inputParameters());
            Test.stopTest();
        } catch (Exception e) {
            System.assertEquals(System.AuraHandledException.class.getName(), e.getTypeName(), 'AuraHandledException is expected');
        }
    }

    @isTest
    public static void getRepairAssignmentFailedTest() {
        try {
            Test.startTest();
            HttpRequestCalloutHelper.HttpCalloutResponse response;
            response = RentalButtonController.getRepairAssignment(inputParameters());
            Test.stopTest();
        } catch (Exception e) {
            System.assertEquals(System.AuraHandledException.class.getName(), e.getTypeName(), 'AuraHandledException is expected');
        }
    }
    
    @isTest
    public static void getRentalAssignmentFailedTest() {
        try {
            Test.startTest();
            HttpRequestCalloutHelper.HttpCalloutResponse response;
            response = RentalButtonController.getRentalAssignment(inputParameters());
            Test.stopTest();
        } catch (Exception e) {
            System.assertEquals(System.AuraHandledException.class.getName(), e.getTypeName(), 'AuraHandledException is expected');
        }
    }

    @isTest
    public static void getClaimProviderFailedTest() {
        try {
            Test.startTest();
            HttpRequestCalloutHelper.HttpCalloutResponse response;
            response = RentalButtonController.getClaimProvider(inputParameters());
            Test.stopTest();
        } catch (Exception e) {
            System.assertEquals(System.AuraHandledException.class.getName(), e.getTypeName(), 'AuraHandledException is expected');
        }
    }

    private static Map<String,Object> inputParameters(){
            Map<String,Object> input = new Map<String, Object>();
            List<String> params = new List<String>();
            params.add('one');
            params.add('{payload:"value"}');
            input.put('calloutName', 'MockREST');
            input.put('calloutParams', params);
            return input;
    }
    
    @isTest
    public static void getRentalEligibilityTest() {
        try {
            String externalClaimId = 'externalClaimId';
            String externalParticipantId = 'externalParticipantId';
            Test.setMock(HttpCalloutMock.class, new HttpRequestCalloutResponseMockGenerator(200, '{"data":"value"}'));
            Test.startTest();
            HttpRequestCalloutHelper.HttpCalloutResponse response = RentalButtonController.getRentalEligibleCallout(externalClaimId, externalParticipantId);
            Test.stopTest();
        } catch (Exception e) {
            System.assertEquals(System.AuraHandledException.class.getName(), e.getTypeName(), 'AuraHandledException is expected');
        }
    }
}