@isTest
(seeAllData=false)
private class SR_ResponseTest {
    
    private static String testString = 'response body';
    private static Integer statusCode = 200;
    
    @isTest 
    private static void testhandleResponse() {
        Test.startTest(); 
        SR_Response srResponse = new SR_Response(statusCode, testString);
        srResponse.handleResponse();
        System.assertEquals(Blob.valueOf(testString), srResponse.responseBody, 'Response Body Check');
        System.assertEquals(statusCode, srResponse.statusCode, 'Status Code Check');
        Test.stopTest();
    }
   
}