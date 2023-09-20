/**
 * @name ClaimRepairController_Test
 * @author Moneyball
 * @description Test the ClaimRepairController class.
 */
@isTest
public with sharing class ClaimRepairController_Test {
    private static final String CALLOUT_NAME = 'ClaimRepairCallout';

    /**
     * @name testGetRepairAssignments
     * @description test getting the repair assignments
     */
    @isTest 
    static void testGetRepairAssignments() {
        HttpRequestCalloutHelper_Test.insertContinuationRecord(CALLOUT_NAME, 'https://mock.callout/request/{0}/{1}', '');
        Test.setMock(HttpCalloutMock.class, new HttpRequestCalloutResponseMockGenerator(200, '{"data":"repair assignments"}'));

        Test.startTest();
        HttpRequestCalloutHelper.HttpCalloutResponse response = ClaimRepairController.getRepairAssignments(HttpRequestCalloutHelper_Test.generateCalloutInput(CALLOUT_NAME));
        Test.stopTest();
        System.assertNotEquals(null, response, 'not null');
        System.assertEquals(200, response.statusCode, 'Status code 200 is expected');
        System.assertEquals('{"data":"repair assignments"}', response.body, 'repair assignments payload does not match');
    }

    /**
     * @name testGetRepairAssignmentsException
     * @description test testGetRepairAssignments when call throws an exception
     */
    @isTest 
    static void testGetRepairAssignmentsException() {
        Test.startTest();
        try {
            ClaimRepairController.getRepairAssignments(HttpRequestCalloutHelper_Test.generateCalloutInput(CALLOUT_NAME));
        } catch (Exception e) {
            System.assertEquals(System.AuraHandledException.class.getName(), e.getTypeName(), 'AuraHandledException is expected');
        }
        Test.stopTest();
    }

     /**
     * @name testRepairEligibilityCallout
     * @description verifies the getRepairEligibleCallout method
     */
    @isTest 
    static void testRepairEligibilityCallout() {
        insertContinuationRecord(CALLOUT_NAME, 'https://mock.callout/request/{0}', '{1}');
        Test.setMock(HttpCalloutMock.class, new HttpRequestCalloutResponseMockGenerator(200, '{"data":"value"}'));
        Map<String, Object> input = generateCalloutInput(CALLOUT_NAME);

        Test.startTest();
        ClaimRepairController.HttpCalloutResponse response = ClaimRepairController.getRepairEligibleCallout(input);
        Test.stopTest();

        System.assertNotEquals(null, response, 'not null');
        System.assertEquals(200, response.statusCode, 'Status code 200 is expected');
    }

    /**
     * @name testDoCalloutException
     * @description test doCallout when request throws an exception
     */
    @isTest 
    static void testDoCalloutException() {
        insertContinuationRecord(CALLOUT_NAME, 'https://mock.callout/request/{0}/error', '{1}');
        Test.setMock(HttpCalloutMock.class, new HttpRequestCalloutResponseMockError());
        Map<String, Object> input = generateCalloutInput(CALLOUT_NAME);

        Test.startTest();
        try {
            ClaimRepairController.HttpCalloutResponse response = ClaimRepairController.getRepairEligibleCallout(input);
        } catch (Exception e) {
            System.assertEquals(System.AuraHandledException.class.getName(), e.getTypeName(), 'AuraHandledException is expected');
        }
        Test.stopTest();
    }

    /**
     * @name generateCalloutInput
     * @description generate a map to make a callout
     * @param calloutName callout name
     */
    public static Map<String, Object> generateCalloutInput(String calloutName) {
        List<String> params = new List<String>();
        params.add('first');
        params.add('{payload:"value"}');
        return generateCalloutInput(calloutName, params);
    }

    /**
     * @name generateCalloutInput
     * @description generate a map to make a callout
     * @param calloutName callout name
     * @param params list of parameters for callout
     */
    public static Map<String, Object> generateCalloutInput(String calloutName, List<String> params) {
        Map<String, Object> input = new Map<String, Object>();
        input.put(ClaimRepairController.CALLOUT_NAME_KEY, calloutName);
        input.put(ClaimRepairController.CALLOUT_PARAMS_KEY, params);
        return input;
    }

    /**
     * @name insertContinuationRecord
     * @description inserts a continuation record for testing
     * @param calloutName the callout name for the record
     * @param urlTemplate the URL template for the record
     * @param bodyTemplate http post body template for the record
     */
    public static void insertContinuationRecord(String calloutName, String urlTemplate, String bodyTemplate) {
        Continuation_Callout__c calloutRecord = new Continuation_Callout__c (
            Name = calloutName,
            ApiType__c = 'REST',
            EndpointURLTemplate__c = urlTemplate,
            RestVerb__c = 'GET'
        );

        if (String.isNotBlank(bodyTemplate)) {
            calloutRecord.BodyTemplate__c = bodyTemplate;
        }

        insert calloutRecord;
    }
}
