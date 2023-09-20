/**
* @author Data Blazers
* @name IntController_Test
* @description Test class for the IntController_Test
*/
@isTest
private class IntController_Test {
    
    @isTest
    static void fetchassociateIdValueTest() {
       
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User u = TestDataFactory_User.generateUser('System Administrator');
        u.Alias = 'adminUsr';
        u.Servicing_Agent_Associate_ID__c = 'CQWH21YS000';
        u.Associate_ID__C = 'CQWH21YS000'; 
        insert u;
        
        System.runAs(u){
           IntController.getAgentType();
        }
        
        User cccUser = TestDataFactory_User.generateUser('3.00 CCC Licensed');
        cccUser.Alias = 'CCCUsr';
        cccUser.Associate_ID__C = 'CQWH21YS000';
        insert cccUser;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccUser);
        System.runAs(cccUser){
           IntController.getAgentType();
        }
        
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c();
        sysAdminUserIdSetting.SFDC_USER_ID__c = u.Id;
        insert sysAdminUserIdSetting;
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        
        Test.startTest();
        Account acc = new Account(ClientIdentifier__c='THDBM8JLSGE',RecordTypeId=accRecordTypeId,LastName='TestLast');
        insert acc; 
        System.assertEquals(acc.ClientIdentifier__c, 'THDBM8JLSGE','The Client Identifier Matched');
        AgentRole__c ar = new AgentRole__c(Agent__c=u.Id, Customer__c=acc.Id);
        insert  ar;
        Test.stopTest();
        
        IntController.fetchAssociateIdValue();
        IntController.isSFConnectInteractionsOff();
        IntController.getDateRange();
        System.runAs(cccUser){
           IntController.fetchassociateIdValue();
        }
        
    }
     
    @isTest
    static void fetchassociateIdValueExpTest() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemAdminUser = TestDataFactory_User.generateUser('System Administrator');
        systemAdminUser.Alias = 'adminUsr';
        systemAdminUser.Servicing_Agent_Associate_ID__c = 'CQWH21YS000';
        systemAdminUser.Associate_ID__C = 'CQWH21YS000';
        systemAdminUser.UserType__c = 'Agent';
        insert systemAdminUser;
        
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c();
        sysAdminUserIdSetting.SFDC_USER_ID__c = systemAdminUser.Id;
        insert sysAdminUserIdSetting;

        Test.startTest();
        system.assertNotEquals(IntController.fetchassociateIdValue(),'THDBM8JLSGE','The Client Identifier Did Not Matched');
        Test.stopTest();        
    }
    
    /**
    * @author Data Blazers
    * @name MockHttpResponseGenerator
    * @description Mock HTTP test class for the IntController_Test
    */
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        /**
        * @description Mock HTTP test class for the IntController_Test
        * @param req
        * @return HTTPResponse
        */
        public HTTPResponse respond(HTTPRequest req) {
        	// Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"token_type":"Bearer","expires_in":3599,"ext_expires_in":3599,"access_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyJ9.eyJhdWQiOiI3ZTM4MmYxNy1kMjAzLTRkYjktYjRkNC0zNTJkZmViMDljOWEiLCJpc3MiOiJodHRwczovL2xvZ2luLm1pY3Jvc29mdG9ubGluZS5jb20vZmEyMzk4MmUtNjY0Ni00YTMzLWE1YzQtMWE4NDhkMDJmY2M0L3YyLjAiLCJpYXQiOjE2MTQyODI1NDYsIm5iZiI6MTYxNDI4MjU0NiwiZXhwIjoxNjE0Mjg2NDQ2LCJhaW8iOiJFMlpnWUZoemxJ"}');
            res.setStatusCode(200);
            return res;    
        }
    }
    @isTest
     static void testRestCallout() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Map<String,Object> inputMap = new Map<String, Object>();
        List<String> inputParameterList = new List<String>();
        inputParameterList.add('TestOne');
        inputParameterList.add('TestTwo');
        inputParameterList.add('TestThree');
        inputParameterList.add('{payload:"value"}');
        inputMap.put('calloutName', 'MockCalloutREST');
        inputMap.put('calloutParams', inputParameterList);

        Continuation_Callout__c mockCalloutRecord = new Continuation_Callout__c (
            Name = 'MockCalloutREST',
            ApiType__c = 'REST',
            BodyTemplate__c = '{3}',
            CachingTTL__c = 500.0,
            EndpointURLTemplate__c = 'https://mock.callout/request/{0}/{1}/{2}',
            IntrospectionClass__c = null,
            RestVerb__c = 'GET',
            SOAPHandlerClass__c = null,
            SR_API_KEY__c = 'SR_API_KEY',
            SR_CATEGORY__c = 'SR_CATEGORY'
        );
        insert mockCalloutRecord;

        insert new Continuation_Callout_Header__c(
            Name = 'MockCalloutREST-Header',
            Continuation_Callout__c = mockCalloutRecord.Id,
            Key__c = 'Test-Header',
            Value__c = 'Test-Value'
        );
		insert new CS_SFScopeStorage__c(
        	Name='DevScope',
            Environment__c = 'Dev',
            Scope__c = 'e3eddddddddddddddddd'
        );
         Test.startTest();
         
         Continuation continuationObject = (Continuation)IntController.getContinuationSFConnect(inputMap);
         Map<String, HttpRequest> continuationRequestMap = continuationObject.getRequests();
         HttpRequest continuationRequestPayload = continuationRequestMap.get((new List<String>(continuationRequestMap.keySet()))[0]);
         System.assertEquals('https://mock.callout/request/TestOne/TestTwo/TestThree',continuationRequestPayload.getEndpoint(), 'Endpoint did not match in continuation request');
         System.assertEquals('{payload:"value"}', continuationRequestPayload.getBody(), 'Request body did not match in continuation request');
         System.assertEquals('Test-Value', continuationRequestPayload.getHeader('Test-Header'), 'Request header did not contain the callout record header');
         
         HttpResponse httpContinuationMockResponse = new HttpResponse();
         httpContinuationMockResponse.setStatusCode(200);
         httpContinuationMockResponse.setBody('Ok');
         
         Test.setContinuationResponse('Label1', httpContinuationMockResponse);
         
         List<String> labels = new List<String>();
         labels.add('Label1');
         
         String hashKeyResponse = IntController.buildHashKey('MockCallout', new List<String>());
         ContinuationCalloutLwcBase.StateInfo state = new ContinuationCalloutLwcBase.StateInfo();
         state.hashKey = hashKeyResponse;
         state.timeToLive = 500;
         
         ContinuationCalloutLwcBase.CalloutResponse continuationCalloutResponse = (ContinuationCalloutLwcBase.CalloutResponse) IntController.processCalloutResponse(labels, state);
         
         System.assertEquals(200, continuationCalloutResponse.statusCode, 'status code did not match expected value');
         System.assertEquals('Ok', continuationCalloutResponse.body, 'Body did not match expected value');
         
         Test.stopTest();
    }
}