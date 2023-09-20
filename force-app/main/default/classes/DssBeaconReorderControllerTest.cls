@isTest
(seeAllData=false)
public class DssBeaconReorderControllerTest {
	private static final String CASE_NUMBER = '98761234';
    private static final String REQUEST_ERROR_MESSAGE = 'Oops something went wrong with the request';
    
    @isTest
    private static void testSuccessCallout() {
        Test.setMock(HttpCalloutMock.class, new DssCalloutMock());
        DssBeaconReorderController.DssLwcParams requestParams = new DssBeaconReorderController.DssLwcParams();
        requestParams.policyNumber = '123MOCK';
        String caseNumber = DssBeaconReorderController.createSupportCase(requestParams);
        System.assertEquals(CASE_NUMBER, caseNumber, 'Case Number did not match expected result');
    }
    
    @isTest
    private static void testFailedCallout() {
        Test.setMock(HttpCalloutMock.class, new DssCalloutMock());
        DssBeaconReorderController.DssLwcParams requestParams = new DssBeaconReorderController.DssLwcParams();
        requestParams.policyNumber = '789MOCK';
        String caseNumber = DssBeaconReorderController.createSupportCase(requestParams);
        System.assertEquals('', caseNumber, 'Case Number returned a value unexpectedly');
    }
    
    public class DssCalloutMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        System.assertEquals('callout:ACMTCaseCreation/createCases', req.getEndpoint(), 'Endpoint was not configured to call ACMT');
        System.assertEquals('POST', req.getMethod(), 'Post method was not used');
        System.assertEquals('application/json', req.getHeader('Content-Type'), 'Content type header was not json');
        System.assertEquals('ECRM', req.getHeader('applicationName'), 'ECRM was not application name in request');
        
        HttpResponse res = new HttpResponse();
        String reqBody = req.getBody();
        DssBeaconReorderController.DssRequestParams parsedBody = (DssBeaconReorderController.DssRequestParams)Json.deserialize(reqBody, DssBeaconReorderController.DssRequestParams.class);
        if(parsedBody.longPolicyNumber == '123MOCK') {
            res.setStatusCode(200);
            res.setBody('{"id":"5003K000003e1MOCKZ","caseNumber":"' + CASE_NUMBER + '","message":"Case is Successfully created in Salesforce","comments":"Agent code or Alias is Updated.","attachment":"Failed to insert the attachment"}');
        } else {
            res.setStatusCode(400);
            res.setBody('{"message":"' + REQUEST_ERROR_MESSAGE + '"}');
        }
        return res;
    }
}

@isTest
private static void testMRSFCallout() {
    Test.setMock(HttpCalloutMock.class, new MrsfCalloutMock());  
    String strResp = DssBeaconReorderController.mrsfServiceCall(null,null);
    System.assertEquals(null, strResp , 'service call is fail'); 
}
public class MrsfCalloutMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req) {
        System.assertEquals('callout:AWSBeaconService/orderStatus', req.getEndpoint(), 'Endpoint was not configured to call MRSF');
        System.assertEquals('POST', req.getMethod(), 'Post method was not used');
        System.assertEquals('application/json', req.getHeader('Content-Type'), 'Content type header was not json');
        System.assertEquals('ECRM', req.getHeader('applicationName'), 'ECRM was not application name in request');
        
        HttpResponse res = new HttpResponse();       
        res.setHeader('Content-Type', 'application/json');     
        req.setBody('{"TCID":234567,"EnrollmentID":null,"LastOrderId":827282,"LastOrderDate":"2022-10-13T15:55:21.33","LastShipDate":null,"LastCancelDate":null,"LastDeliveryDate":null,"LastReturnDate":null,"LastExportDate":null,"LastTrackingNumber":null,"LastOrderStatus":"Order Submitted","Orders":[{"OrderId":827282,"ClientID":"ENV515311","FirstName":"ENV5153711","LastName":"TESTLASTNAME","Address1":"1711 MAIN ST","Address2":"APT 710","City":"TOLEDO","State":"OH","PostalCode":"417113432","ItemModelNumber":"Bluetooth Device","OrderReason":"C-No Blue Light","TempAddress":true,"OrderDate":"2022-10-13T15:55:21.33","ExportDate":null,"ShipDate":null,"DeliveryDate":null,"ReturnDate":null,"ReturnReason":null,"CancelDate":null,"CancelReason":null,"TrackingNumber":null,"ImportFile":null,"OrderStatus":"Order Submitted"}]}'); 
        res.setStatusCode(200);
        return res;       
    }
}

@isTest
private static void testshipmentAPISuccessCallout() {
        Test.setMock(HttpCalloutMock.class, new ShipmentCalloutMock());
        String strReq = '{"clientId":"00xikfhnepc","firstName":"Fake","lastName":"Jake","address1":null,"postalState":null,"postalCode":null,"postalCity":null,"tempAddressIndicator":false,"addSourceIdentifier":"ECRM","itemModelNumber":"Bluetooth Device","tc_id":6447848}';  
        String strResp = DssBeaconReorderController.shipmentServiceCall(strReq);
        System.assertEquals('Success', strResp , 'shipment order service call is Success'); 
    }

@isTest
private static void testshipmentAPIFailedCallout() {
        Test.setMock(HttpCalloutMock.class, new ShipmentCalloutMock());  
        String strResp = DssBeaconReorderController.shipmentServiceCall(null);
        System.assertEquals('Error', strResp , 'shipment order service call is fail'); 
    }
public class ShipmentCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            System.assertEquals('callout:AWSBeaconService/shipmentOrder', req.getEndpoint(), 'Endpoint was not configured to call Shipment Order');
            System.assertEquals('POST', req.getMethod(), 'Post method was not used');
            System.assertEquals('application/json', req.getHeader('Content-Type'), 'Content type header was not json');
            System.assertEquals('ECRM', req.getHeader('applicationName'), 'ECRM was not application name in request');
            
            HttpResponse res = new HttpResponse();       
            res.setHeader('Content-Type', 'application/json');     
            res.setStatusCode(200);
            return res;       
        }
    }


}