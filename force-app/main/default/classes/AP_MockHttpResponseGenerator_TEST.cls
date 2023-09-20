/**
  * @name AP_MockHttpResponseGenerator_TEST
  * @author ITIC
  * @description Test class for AP_ChatterMonitoringService
  * sends a mock response for a specific endpoint
  */
@isTest(SeeAllData=false)
public class AP_MockHttpResponseGenerator_TEST implements HttpCalloutMock {
	Protected Integer code;
    Protected String status;

    //Constructors
    /**
     * @description test method to Mock Http response generator
     * @param code
     * @param status
     */
    public AP_MockHttpResponseGenerator_TEST(Integer code, String status) {
    	this.code = code;
        this.status = status;
    }

    /**
     * @description test method to request a response
     * @param req
     * @return  `HTTPResponse`
     */
    public HTTPResponse respond(HTTPRequest req) {
    	System.assertEquals('callout:ChatterMonitoringNamedCredential/12345', req.getEndpoint(), 'Call out request for to get the End point');
        System.assertEquals('GET', req.getMethod(), 'Request for the Get method');
        HttpResponse res = new HttpResponse();
        res.setHeader('SR_API_KEY', 'ac3fa473-d302-4fc6-9eee-912cf9a96fe3');
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }
}