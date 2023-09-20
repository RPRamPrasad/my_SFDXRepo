/**
* @author GrumpyCats
* @name ABS_ActivityMoveHttpResponseMock_TEST
* @date Created 02/26/2020
* @description This class implement the HttpCalloutMock interface 
*			   Reference: https://developer.salesforce.com/blogs/developer-relations/2013/03/testing-apex-callouts-using-httpcalloutmock.html
*/
@isTest(SeeAllData=false)
public class ABS_ActivityMoveHttpResponseMock_TEST implements HttpCalloutMock {
    Protected Integer code;

    public ABS_ActivityMoveHttpResponseMock_TEST(Integer code) {
    	this.code = code;
    }
    
    public HTTPResponse respond(HTTPRequest requeest) {
    	System.assertEquals('callout:ActivityMoveCallout', requeest.getEndpoint());
        System.assertEquals('POST', requeest.getMethod());
        HttpResponse response = new HttpResponse(); 
        response.setStatusCode(this.code);
        return response; 
    }
}