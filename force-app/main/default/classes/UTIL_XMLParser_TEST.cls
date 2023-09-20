/**
@author Team STARK
@name UTIL_XMLParser_TEST 
@createDate 03/12/20120
@description Common class to access XML Conversion processes
@version 1.0
*/
@isTest(seeAllData = false)
private class UTIL_XMLParser_TEST {
   
   @isTest
    static void testxmltoJSONConversion() {
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;
        String jsonOutput;
        String xmlString = '<?xml version="1.0" encoding="UTF-8"?>'
			+'<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sa1="http://standardizedaddressw0090207.location.domain.statefarm" xmlns:sa2="http://to.standardizedaddressifacew0090207.location.domain.statefarm" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
   			+'<soap:Body><sa2:standardizedAddress><sa2:firmName /><sa2:city>Bloomington</sa2:city><sa2:postalCode>617048501</sa2:postalCode></sa2:standardizedAddress><sa2:statusCode>04</sa2:statusCode>'
    		+'<sa2:messages><sa2:clientInfo>AddressStandardizationWebService</sa2:clientInfo><sa2:machineId>DataPower</sa2:machineId><sa2:messageCode>S1G198</sa2:messageCode><sa2:messageText>City name changed to match Postal Service Directory.</sa2:messageText></sa2:messages>'
    		+'<sa2:messages><sa2:clientInfo>AddressStandardizationWebService</sa2:clientInfo><sa2:machineId>DataPower</sa2:machineId><sa2:messageCode>SOT411</sa2:messageCode><sa2:messageText>Entered apartment/suite number not found. Verify address is correct.</sa2:messageText></sa2:messages>'
            +'<sa2:success>true</sa2:success></soap:Body></soap:Envelope>';
        String jsonString ='{"Envelope": {"Body": {"standardizedAddress": {"city": "Bloomington", "postalCode": "617048501"}, '
            +'"statusCode": "04", "messages": [{"clientInfo": "AddressStandardizationWebService", "machineId": "DataPower", "messageCode": "S1G198", '
            +'"messageText": "City name changed to match Postal Service Directory."}, {"clientInfo": "AddressStandardizationWebService", "machineId": "DataPower", "messageCode": "SOT411", '
            +'"messageText": "Entered apartment/suite number not found. Verify address is correct."}], "success": "true"}}}';

        Test.StartTest();
        	System.runAs(systemUser) {
            	jsonOutput = UTIL_XMLParser.xmlToJson(xmlString);
        	}
        Test.StopTest();
        System.assertEquals(jsonOutput,jsonString,'Success');
    }
}