/**
* @author GrumpyCats
* @name ABS_ActivityManagementCallout_TEST
* @date Created 02/26/2020
* @description This class unit tests for ABS_ActivityManagementCallout Apex Class.
*/
@isTest(SeeAllData=false)
public class ABS_ActivityManagementCallout_TEST {

    public static testmethod void testCallActivityMoveServiceSuccess() {
        ABS_ActivityMoveHttpResponseMock_TEST mockResponse= new ABS_ActivityMoveHttpResponseMock_TEST(200);
        Test.setMock(HttpCalloutMock.class, mockResponse);
        Map<String, String> response = ABS_ActivityManagementCallout.callActivityMoveService('abc'); 
        System.assertEquals('200', response.get('status'), 'Status code should be 200'); 
    }
    
    public static testmethod void testCallActivityMoveServiceError() {
        ABS_ActivityMoveHttpResponseMock_TEST mockResponse= new ABS_ActivityMoveHttpResponseMock_TEST(500);
        Test.setMock(HttpCalloutMock.class, mockResponse);
        Map<String, String> response = ABS_ActivityManagementCallout.callActivityMoveService('abc');
        System.assertEquals('500', response.get('status'), 'Status code should be 500'); 
    }
    
    public static testmethod void testCallActivityMoveServiceException() {
        ABS_ActivityMoveHttpResponseMock_TEST mockResponse= new ABS_ActivityMoveHttpResponseMock_TEST(500);
        Test.setMock(HttpCalloutMock.class, mockResponse);
        Map<String, String> response = ABS_ActivityManagementCallout.callActivityMoveService(null);
        System.assertEquals('Argument 1 cannot be null', response.get('responseBody'), 'responseBody should be null Exception'); 
    }
}