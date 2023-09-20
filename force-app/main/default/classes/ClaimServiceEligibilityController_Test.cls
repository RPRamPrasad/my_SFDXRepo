/**
 * @name ClaimServiceEligibilityController_Test
 * @author Moneyball
 * @description Test the ClaimServiceEligibilityController class.
 */
@isTest
public with sharing class ClaimServiceEligibilityController_Test {
    private static final String CALLOUT_NAME = 'ClaimServiceCallout';

    /**
     * @name testGetNamedInsuredParticipants
     * @description test getting the named insured participants
     */
    @isTest 
    static void testGetNamedInsuredParticipants() {
        HttpRequestCalloutHelper_Test.insertContinuationRecord(CALLOUT_NAME, 'https://mock.callout/request/{0}/{1}', '');
        Test.setMock(HttpCalloutMock.class, new HttpRequestCalloutResponseMockGenerator(200, '{"data":"named insured participants"}'));

        Test.startTest();
        HttpRequestCalloutHelper.HttpCalloutResponse response = ClaimServiceEligibilityController.getNamedInsuredParticipants(HttpRequestCalloutHelper_Test.generateCalloutInput(CALLOUT_NAME));
        Test.stopTest();
        System.assertNotEquals(null, response, 'not null');
        System.assertEquals(200, response.statusCode, 'Status code 200 is expected');
        System.assertEquals('{"data":"named insured participants"}', response.body, 'named insured participants payload does not match');
    }

    /**
     * @name testGetNamedInsuredParticipantsException
     * @description test getNamedInsuredParticipants when call throws an exception
     */
    @isTest 
    static void testGetNamedInsuredParticipantsException() {
        Test.startTest();
        try {
            ClaimServiceEligibilityController.getNamedInsuredParticipants(HttpRequestCalloutHelper_Test.generateCalloutInput(CALLOUT_NAME));
        } catch (Exception e) {
            System.assertEquals(System.AuraHandledException.class.getName(), e.getTypeName(), 'AuraHandledException is expected');
        }
        Test.stopTest();
    }
}
