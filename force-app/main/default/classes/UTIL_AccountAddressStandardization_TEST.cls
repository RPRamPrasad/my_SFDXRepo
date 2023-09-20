/**
* @author Team Stark
* @owner Team Stark
* @name UTIL_AccountAddressStandardization_TEST
* @createDate 06/19/2020
* @description Common class to access various Account related Address Standarization operations TEST.
* @version 1.0
*/
@isTest(seeAllData=false)
private with sharing class UTIL_AccountAddressStandardization_TEST {

    private static DAOMock_AccountCreateEditHelper daoMockHelperInstance = new DAOMock_AccountCreateEditHelper();
    private Static String addressMailingJSON = '{ "address1":"1204 Test Street","address2":"APT 7","city":"Bloomington","state":"IL",'
        +'"zip":"61704"}';
    
    private Static String addressResidenceJSON = '{"addressLabel":"Residence","adType":"US",'
        +'"address1":"1204 Test Street","address2":"APT 7","city":"Bloomington","state":"IL",'
        +'"zip":"61704","country":"US"}';
    
    @TestSetup
    static void makeData() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;
        
        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false,SystemUser);
        insert passTriggerAll;
        
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemUser);
        objectBasedByPassTrigger.Override_AgentRoleAfterInsert__c = false;
        objectBasedByPassTrigger.Override_AgentRoleBeforeDelete__c = false;
        
        insert objectBasedByPassTrigger;
        
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
        insert sysAdminUserIdSetting; 

        insertTechnicalPlatformDetails();
    }

    private static User setupRunAsUser() {
        return UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
    }
    
    @isTest private static void testValidateAddress() {
        
        Test.startTest();
        	UTIL_AccountCreateEdit.helperDAOInstance = daoMockHelperInstance;
        	HttpRequest testMockReq = new HttpRequest();
            testMockReq.setMethod(UTIL_CreateCustomerConstants.POST);
            testMockReq.setHeader('Content-Type', 'application/soap+xml');
        	Continuation cont = (Continuation)UTIL_AccountAddressStandardization.validateAddress(addressMailingJSON);
        	Map<String, HttpRequest> requests = cont.getRequests();
            List<object> objectList = new List<object>();
            object mockRequest = daoMockHelperInstance.getContinuationState(cont,testMockReq);
            objectList.add(mockRequest);
            System.assertEquals(1, requests.size(),'request size equals to 1');
        
        	HttpResponse mockResponse = new HttpResponse();
        	String responseString = '{"success":true,"statusCode":"04","standardizedAddress":{"streets":null,"stateProvince":null,"postalCode":"617048501","city":"Bloomington"},'
            +'"parsedAddress":null,"messages":[{"messageText":"City name changed to match Postal Service Directory.","messageSource":null,"messageCode":"S1G198","machineId":"DataPower","clientInfo":"AddressStandardizationWebService"},'
        	+ '{"messageText":"Entered apartment/suite number not found. Verify address is correct.","messageSource":null,"messageCode":"SOT411","machineId":"DataPower","clientInfo":"AddressStandardizationWebService"}]}';
            mockResponse.setBody(responseString);
            mockResponse.setStatusCode(200);
            List<String> labels = new List<String>{responseString};
            UTIL_AccountCreateEditHelper.mockResponse = mockResponse;
            daoMockHelperInstance.mockResponse = mockResponse;
            Object result = UTIL_AccountAddressStandardization.processAddrStdResponse(labels,mockResponse);
        	System.assertEquals(responseString, result,'result verified');
        Test.stopTest();
        
    }

    @isTest private static void testValidateAddressExceptionStatus400() {
        
        Test.startTest();
            UTIL_AccountCreateEdit.helperDAOInstance = daoMockHelperInstance;
            HttpRequest testMockReq = new HttpRequest();
            testMockReq.setMethod(UTIL_CreateCustomerConstants.POST);
            testMockReq.setHeader('Content-Type', 'application/soap+xml');

            Continuation cont = (Continuation)UTIL_AccountAddressStandardization.validateAddress(addressMailingJSON);
            Map<String, HttpRequest> requests = cont.getRequests();
            List<object> objectList = new List<object>();
            object mockRequest = daoMockHelperInstance.getContinuationState(cont,testMockReq);
            objectList.add(mockRequest);
            System.assertEquals(1, requests.size(),'request size equals to 1');

            HttpResponse mockResponse = new HttpResponse();
            String responseString = '{"success":true,"statusCode":"04","standardizedAddress":{"streets":null,"stateProvince":null,"postalCode":"617048501","city":"Bloomington"},'
            +'"parsedAddress":null,"messages":[{"messageText":"City name changed to match Postal Service Directory.","messageSource":null,"messageCode":"S1G198","machineId":"DataPower","clientInfo":"AddressStandardizationWebService"},'
        	+ '{"messageText":"Entered apartment/suite number not found. Verify address is correct.","messageSource":null,"messageCode":"SOT411","machineId":"DataPower","clientInfo":"AddressStandardizationWebService"}]}';
            mockResponse.setBody(responseString);
            mockResponse.setStatusCode(400);
        	List<String> labels = new List<String>{responseString};
        	UTIL_AccountCreateEditHelper.mockResponse = mockResponse;
            daoMockHelperInstance.mockResponse = mockResponse;
            try {
                Object result = UTIL_AccountAddressStandardization.processAddrStdResponse(labels,mockResponse);
                System.assertEquals('General Exception: The address standardization cannot be verified at this time. You may continue saving without verification.', result,'Error result');
            } catch (Exception e) {
              System.assertNotEquals('', e.getMessage(),'Error message blank');
            }
        Test.stopTest();
    }

    @isTest private static void testValidateAddressStatus2004() {
        
        Test.startTest();
            UTIL_AccountCreateEdit.helperDAOInstance = daoMockHelperInstance;
            HttpRequest testMockReq = new HttpRequest();
            testMockReq.setMethod(UTIL_CreateCustomerConstants.POST);
            testMockReq.setHeader('Content-Type', 'application/soap+xml');

            Continuation cont = (Continuation)UTIL_AccountAddressStandardization.validateAddress(addressMailingJSON);
            Map<String, HttpRequest> requests = cont.getRequests();
            List<object> objectList = new List<object>();
            object mockRequest = daoMockHelperInstance.getContinuationState(cont,testMockReq);
            objectList.add(mockRequest);
            System.assertEquals(1, requests.size(),'request size equals to 1');

            HttpResponse mockResponse = new HttpResponse();
            String responseString = '{"success":true,"statusCode":"04","standardizedAddress":{"streets":null,"stateProvince":null,"postalCode":"617048501","city":"Bloomington"},'
            +'"parsedAddress":null,"messages":[{"messageText":"City name changed to match Postal Service Directory.","messageSource":null,"messageCode":"S1G198","machineId":"DataPower","clientInfo":"AddressStandardizationWebService"},'
        	+ '{"messageText":"Entered apartment/suite number not found. Verify address is correct.","messageSource":null,"messageCode":"SOT411","machineId":"DataPower","clientInfo":"AddressStandardizationWebService"}]}';
            mockResponse.setBody(responseString);
            mockResponse.setStatusCode(2004);
        	List<String> labels = new List<String>{responseString};
        	UTIL_AccountCreateEditHelper.mockResponse = mockResponse;
            daoMockHelperInstance.mockResponse = mockResponse;
            try {
                Object result = UTIL_AccountAddressStandardization.processAddrStdResponse(labels,mockResponse);
                System.assertEquals('Callout Exception: The address standardization cannot be verified at this time. You may continue saving without verification.', result,'Error result');
            } catch (Exception e) {
              System.assertNotEquals('', e.getMessage(),'Error message blank');
            }
        Test.stopTest();
    }

    @isTest private static void testValidateAddressStatus500() {
        
        Test.startTest();
            UTIL_AccountCreateEdit.helperDAOInstance = daoMockHelperInstance;
            HttpRequest testMockReq = new HttpRequest();
            testMockReq.setMethod(UTIL_CreateCustomerConstants.POST);
            testMockReq.setHeader('Content-Type', 'application/soap+xml');

            Continuation cont = (Continuation)UTIL_AccountAddressStandardization.validateAddress(addressMailingJSON);
            Map<String, HttpRequest> requests = cont.getRequests();
            List<object> objectList = new List<object>();
            object mockRequest = daoMockHelperInstance.getContinuationState(cont,testMockReq);
            objectList.add(mockRequest);
            System.assertEquals(1, requests.size(),'request size equals to 1');

            HttpResponse mockResponse = new HttpResponse();
            String responseString = '{"success":true,"statusCode":"04","standardizedAddress":{"streets":null,"stateProvince":null,"postalCode":"617048501","city":"Bloomington"},'
            +'"parsedAddress":null,"messages":[{"messageText":"City name changed to match Postal Service Directory.","messageSource":null,"messageCode":"S1G198","machineId":"DataPower","clientInfo":"AddressStandardizationWebService"},'
        	+ '{"messageText":"Entered apartment/suite number not found. Verify address is correct.","messageSource":null,"messageCode":"SOT411","machineId":"DataPower","clientInfo":"AddressStandardizationWebService"}]}';
            mockResponse.setBody(responseString);
            mockResponse.setStatusCode(500);
        	List<String> labels = new List<String>{responseString};
        	UTIL_AccountCreateEditHelper.mockResponse = mockResponse;
            daoMockHelperInstance.mockResponse = mockResponse;
            try {
                Object result = UTIL_AccountAddressStandardization.processAddrStdResponse(labels,mockResponse);
                System.assertEquals('Service Exception: The address standardization cannot be verified at this time. You may continue saving without verification.', result,'Error result');
            } catch (Exception e) {
              System.assertNotEquals('', e.getMessage(),'Error message blank');
            }
        Test.stopTest();
    }

    @isTest private static void testCreateTaskOnAddressChanged() {
        RecordType recType = [Select Id From RecordType Where DeveloperName = 'Individual' AND SobjectType = 'Account'];
        Account acct = createIndividualWithMatchValues();
        acct.ClientIdentifier__c = 'SGGSP81L8XB';
        acct.RecordTypeId = recType.Id;
        system.runAs(setupRunAsUser()) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert acct;
        }
        daoMockHelperInstance.acct = acct;
        String oldAccountJSON = '{"BillingStreet":"1028 GOLDFINCH WAY","BillingCity":"BLOOMINGTON","BillingState":"IL",'
            +'"BillingPostalCode":"61710","BillingCountry":"US","ShippingStreet":"","ShippingCity":"Bloomington",'
            +'"ShippingState":"IL","ShippingPostalCode":"61710","ShippingCountry":"US","MailingInCareOf__c":"Test CO"}';

        Test.startTest();
        	daoMockHelperInstance.acct = daoMockHelperInstance.getAccountDetails(acct.Id);
            UTIL_AccountCreateEditHelper.mockAccount = acct;
        	UTIL_AccountAddressStandardization.createTaskOnAddressChanged(oldAccountJSON,acct.id);
        Test.stopTest();
        List<Account> accList = [SELECT Id from Account where id=:acct.id];
        System.assert(accList.size()>0, 'Account list is not empty');
    }

    private static  void insertTechnicalPlatformDetails() {
        CS_TechnicalPlatform__c srKey = new CS_TechnicalPlatform__c();
        srKey.Name = 'SR_API_KEY';
        srKey.Value__c = 'Test Key';
        
        CS_TechnicalPlatform__c srCategory = new CS_TechnicalPlatform__c();
        srCategory.Name = 'SR_CATEGORY';
        srCategory.Value__c = 'a';
        insert new List<CS_TechnicalPlatform__c>{srKey, srCategory};

        CS_EnvironmentURLCustomSetting__c envURL = new CS_EnvironmentURLCustomSetting__c(Name = 'S1BaseUrl', Value__c = 'TestURL');
        insert envURL;
    }

    private static Account createIndividualWithMatchValues(){
        Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('Doe');
        acc.FirstName = 'John';
        acc.BillingAddressType__c = 'US';
        acc.BillingStreet = '1 Statefarm Plz';
        acc.BillingCity = 'Bloomington';
        acc.BillingState = 'IL';
        acc.BillingPostalCode = '61710';
        acc.BillingCountry = 'US';
        acc.ShippingStreet = '1 Statefarm Plz';
        acc.ShippingCity = 'Bloomington';
        acc.ShippingState = 'IL';
        acc.ShippingPostalCode = '61710';
        acc.ShippingCountry = 'US';
        return acc;
    }

}