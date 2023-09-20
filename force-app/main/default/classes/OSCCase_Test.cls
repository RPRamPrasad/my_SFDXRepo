/**
 * @description Test Class for the OSCCase  Class.
 *
 * @author Kiko Ferrer (VAD63S)
 * @version 1.1, 12/15/22
 * @see OSCCase 
 * @since 1.0
*/

@isTest
private class OSCCase_Test {
    private static final String APPLICATION_NAME = 'ECRM';
    private static final String ACCOUNT_NAME = 'State Farm - Internal';
    private static final String ACCOUNT_NUMBER = '0000000000';
    private static final String AGENT_CODE = 'VAD63S';
    private static final String ASSOCIATE_REGISTER_ID = 'associateRegister_Id';
    private static final String FILE_ATTACHMENT = 'test';
    private static final String FILE_EXTENSION = 'png';
    private static final String FILE_NAME = 'pngtest';
    private static final String FILE_ATTACHMENT2 = 'test2';
    private static final String FILE_EXTENSION2 = 'jpg';
    private static final String FILE_NAME2 = 'jpgtest';
    private static final String CONTACT_NAME = 'Ricardo Marrero';
    private static final String CUSTOMER_NAME = 'ILESH PATEL';
    private static final String DESCRIPTION = 'Case Created from OSCCase class';
    private static final String EMAIL_ADDRESS = 'mary@gmail.com';
    private static final String ERROR_DESCRIPTION = 'errorDescription text';
    private static final String FORMATTED_DESCRIPTION = 'formattedDescription html';
    private static final String INTERNAL_COMMENT = 'Internal comment dummy';
    private static final String LINE_OF_BUSINESS = 'Business Lines Auto';
    private static final String LONG_POLICY_NUMBER = '472 5898-C13-25A';
    private static final String ORIGINAL_REQUEST_DATE = '2022-07-22';
    private static final String POLICY_NUMBER = '5000000SFP35';
    private static final String PRODUCT = 'Fleet';
    private static final String SUBJECT = 'Premium Change';
    private static final String TOPIC = 'Premium Change';
    private static final String TYPE = 'Billing';
    private static final String UNIQUE_TRANSACTION_ID = '0001s';
    private static final String USER_ALIAS = 'VAD63S';
    
    /**
     * @description Method that test the External Service callout for the OSCCase.getStatusOfOSCCase() method and the returned status value of it.
     * 
     * @see OSCCase#getStatusOfOSCCase()
     */
    @isTest
    static void getStatusOfOSCCase_withCorrectCaseNum_successStatus() {
        String oscActualCaseStatus;
        Test.setMock(HttpCalloutMock.class, new GetCaseStatusUsingGETCalloutSuccessMock());
        Test.startTest();
        oscActualCaseStatus = OSCCase.getStatusOfOSCCase('00046552');
        Test.stopTest();
        System.assertEquals('Open', oscActualCaseStatus, 'Incorrect OSC Case status');
    }

    /**
     * @description Private helper method that creates a successful callout mock for the getStatusOfOSCCase() method.
     * 
     * @see getStatusOfOSCCase_withCorrectCaseNum_successStatus()
     */
    private class GetCaseStatusUsingGETCalloutSuccessMock implements HttpCalloutMock {
        /**
         * @description respond
         * @param request 
         * @return  `HTTPResponse`
         */
        public HTTPResponse respond(HTTPRequest request) {   
            HttpResponse response = new HttpResponse();
            response.setBody('{"caseNumber": "00046552", ' + 
                '"status": "Open", ' + 
                '"closedDate": ""}');
            response.setStatusCode(200);
            response.setStatus('OK');
            return response;        
        }
    }

    /**
     * @description Method that test the failed External Service callout for the OSCCase.getStatusOfOSCCase() method.
     * 
     * @see OSCCase#getStatusOfOSCCase()
     */
    @isTest
    static void getStatusOfOSCCase_withIncorrectCaseNum_IncorrectStatus() {
        String expectedErrorStatus = 'Error: 404 -> The case number or ID does not exist OR Salesforce Connection issue';
        Test.setMock(HttpCalloutMock.class, new GetCaseStatusUsingGETCalloutFailMock());
        Test.startTest();
        try {
            OSCCase.getStatusOfOSCCase('11111111');
            Assert.fail('CaseStatus callout did not fail');
        } catch(OSCCase.OSCCaseNotFoundException exc) {
            System.assertEquals(expectedErrorStatus, exc.getMessage(), 'Incorrect error message of OSCCaseNotFoundException exception');
            Test.stopTest();
        }  
    }

    /**
     * @description Private helper method that creates an unsuccessful callout mock for the getStatusOfOSCCase() method.
     * 
     * @see getStatusOfOSCCase_withIncorrectCaseNum_IncorrectStatus()
     */
    private class GetCaseStatusUsingGETCalloutFailMock implements HttpCalloutMock {
        /**
         * @description respond
         * @param request 
         * @return  `HTTPResponse`
         */
        public HTTPResponse respond(HTTPRequest request) {   
            HttpResponse response = new HttpResponse();
            response.setBody('{"errorCode": "404", ' + 
                '"message": "The case number or ID does not exist OR Salesforce Connection issue"}');
            response.setStatusCode(200);
            response.setStatus('OK');
            return response;        
        }
    }

    /**
     * @description Method that test the External Service callout for the OSCCase.updateStatusOfOSCCase() method and the returned status value of it.
     * 
     * @see OSCCase#updateStatusOfOSCCase()
     */
    @isTest
    static void updateStatusOfOSCCase_withAllFields_caseCreated() {
        Boolean caseUpdated = true;
        Test.setMock(HttpCalloutMock.class, new UpdateCaseUsingPOSTCalloutSuccessMock());
        Test.startTest();
        caseUpdated = OSCCase.updateStatusOfOSCCase('00046552', 'New comment', 'Premium Change');
        Test.stopTest();
        System.assert(caseUpdated, 'Case not updated');
    }

    /**
     * @description Private helper method that creates a successful callout mock for the updateStatusOfOSCCase() method.
     * 
     * @see updateStatusOfOSCCase_withAllFields_caseCreated()
     */
    private class UpdateCaseUsingPOSTCalloutSuccessMock implements HttpCalloutMock {
        /**
         * @description respond
         * @param request 
         * @return  `HTTPResponse`
         */
        public HTTPResponse respond(HTTPRequest request) {   
            HttpResponse response = new HttpResponse();
            response.setBody('{"id": "5003K000004vJ3mQAE", "caseNumber": "00046552", ' + 
                '"message": "Case is Successfully updated in Salesforce", ' + 
                '"comment": "Case is Successfully updated in Salesforce"}');
            response.setStatusCode(200);
            response.setStatus('OK');
            return response;        
        }
    }

    /**
     * @description Method that test the failed External Service callout for the OSCCase.updateStatusOfOSCCase() method.
     * 
     * @see OSCCase#updateStatusOfOSCCase()
     */
	@isTest
    static void updateStatusOfOSCCase_withAllFields_caseNotCreated() {
        Test.setMock(HttpCalloutMock.class, new UpdateCaseUsingPOSTCalloutFailMock());
        Boolean caseSuccessfullyCreated;
        Test.startTest();
        try {
            caseSuccessfullyCreated = OSCCase.updateStatusOfOSCCase('00046', null, 'Premium Change');
        } catch(OSCCase.OSCUpdateCaseException exc) {
            System.assert(!caseSuccessfullyCreated, 'Case incorrectly created');
            Test.stopTest();
        }   
    }

    /**
     * @description Private helper method that creates an unsuccessful callout mock for the updateStatusOfOSCCase() method.
     * 
     * @see updateStatusOfOSCCase_withAllFields_caseNotCreated()
     */
    private class UpdateCaseUsingPOSTCalloutFailMock implements HttpCalloutMock {
        /**
         * @description respond
         * @param request 
         * @return  `HTTPResponse`
         */
        public HTTPResponse respond(HTTPRequest request) {   
            // Send response test data
            HttpResponse response = new HttpResponse();
            response.setBody('{"errorCode": "400", "message": "00046 No such case number found"}');
            response.setStatusCode(400);
            response.setStatus('Bad Request');
            return response;        
        }
    }


     /**
     * @description Method that test the External Service callout for the OSCCase.createOSCCase() method and the returned status value of it.
     * 
     * @see OSCCase#createOSCCase()
     */
    @isTest
    static void createOSCCase_withRequiredFields_caseSuccessfullyCreated() {
        Boolean caseSuccessfullyCreated;
        Test.setMock(HttpCalloutMock.class, new CreateCaseUsingPOSTCalloutSuccessMock());
        
        Test.startTest();

        OSCCase.OSCCaseWrapper oscWrapper = new OSCCase.OSCCaseWrapper();
        oscWrapper.appName = APPLICATION_NAME;
        oscWrapper.description = DESCRIPTION;
        oscWrapper.topic = TOPIC;
        oscWrapper.type = TYPE;
        OSCCase oscCase = new OSCCase(oscWrapper);
        caseSuccessfullyCreated = oscCase.createOSCCase();
        Test.stopTest();
        System.assert(caseSuccessfullyCreated, 'Case was not created in OSC');
        System.assertEquals('5003K000004wKrQQAU', oscCase.oscCaseId, 'The OSC case id returned is not correct');
        System.assertEquals('00047142', oscCase.oscCaseNumber, 'The OSC case number returned is not correct');
        
    }
    
     /**
     * @description Private helper method that creates an successful callout mock for the createOSCCase() method.
     * 
     * @see createOSCCase_withRequiredFields_caseSuccessfullyCreated()
     */
    private class CreateCaseUsingPOSTCalloutSuccessMock implements HttpCalloutMock {
        /**
         * @description respond
         * @param request 
         * @return  `HTTPResponse`
         */
        public HTTPResponse respond(HTTPRequest request) {   
            HttpResponse response = new HttpResponse();
            response.setBody('{"id":"5003K000004wKrQQAU","caseNumber":"00047142","message":"Case is Successfully created in Salesforce","comments":"Agent code or Alias does not exist.","attachment":"Failed to insert the attachment"}');
            response.setStatusCode(201);
            response.setStatus('Created');
            return response;        
        }
    }

     /**
     * @description Method that test the failed External Service callout for the OSCCase.createOSCCase() method.
     * 
     * @see OSCCase#createOSCCase()
     */
    @isTest
    static void createOSCCase_withRequiredFields_caseUnsuccessfullyCreated() {
        Test.setMock(HttpCalloutMock.class, new CreateCaseUsingPOSTCalloutFailMock());
        Boolean caseSuccessfullyCreated;
        Test.startTest();
        try {
            // Create instance of OSCCase calling the main constructor and passing required parameters
            OSCCase.OSCCaseWrapper oscWrapper = new OSCCase.OSCCaseWrapper();
            oscWrapper.appName = null;
            oscWrapper.description = DESCRIPTION;
            oscWrapper.topic = TOPIC;
            oscWrapper.type = TYPE;
            OSCCase oscCase = new OSCCase(oscWrapper);
            caseSuccessfullyCreated = oscCase.createOSCCase();
        } catch(Exception exc) {
            System.assert(!caseSuccessfullyCreated, 'Case was incorrectly created');
            Test.stopTest();
        }
        
    }

     /**
     * @description Private helper method that creates an unsuccessful callout mock for the createOSCCase() method.
     * 
     * @see createOSCCase_withRequiredFields_caseUnsuccessfullyCreated()
     */
    private class CreateCaseUsingPOSTCalloutFailMock implements HttpCalloutMock {
        /**
         * @description respond
         * @param request 
         * @return  `HTTPResponse`
         */
        public HTTPResponse respond(HTTPRequest request) {   
            HttpResponse response = new HttpResponse();
            response.setBody('{"timestamp":"2022-12-15T19:32:11.137","code":"400","message":"Header is missing in request.","description":["Required request header \'applicationName\' for method parameter type String is not present"]}');
            response.setStatusCode(400);
            response.setStatus('Bad Request');
            return response;        
        }
    }

     /**
     * @description Method that test the External Service callout for the OSCCase.createOSCCase() method and the returned status value of it.
     * 
     * @see OSCCase#createOSCCase()
     */
    @isTest
    static void createOSCCase_withAllFields_caseSuccessfullyCreated() {
        Boolean caseSuccessfullyCreated;
        Test.setMock(HttpCalloutMock.class, new CreateCaseUsingPOSTAllFieldsCalloutSuccessMock());
        
        Test.startTest();
        // Create instance of OSCCase calling the main constructor and passing required parameters
        OSCCase.OSCCaseWrapper oscWrapper = new OSCCase.OSCCaseWrapper();
        oscWrapper.appName = APPLICATION_NAME;
        oscWrapper.description = DESCRIPTION;
        oscWrapper.topic = TOPIC;
        oscWrapper.type = TYPE;
        OSCCase oscCase = new OSCCase(oscWrapper);
        // Fill all the oscCase member variables, which are used in the OSC API request body
        oscCase.accountName = ACCOUNT_NAME;
        oscCase.accountNumber = ACCOUNT_NUMBER;
        oscCase.agentCode = AGENT_CODE;
        oscCase.associateRegisterId = ASSOCIATE_REGISTER_ID;
        oscCase.contactName = CONTACT_NAME;
        oscCase.customerName = CUSTOMER_NAME;
        oscCase.emailAddress = EMAIL_ADDRESS;
        oscCase.errorDescription = ERROR_DESCRIPTION;
        oscCase.formattedDescription = FORMATTED_DESCRIPTION;
        oscCase.internalComment = INTERNAL_COMMENT;
        oscCase.lineOfBusiness = LINE_OF_BUSINESS;
        oscCase.longPolicyNumber = LONG_POLICY_NUMBER;
        oscCase.originalRequestDate = ORIGINAL_REQUEST_DATE;
        oscCase.policyNumber = POLICY_NUMBER;
        oscCase.product = PRODUCT;
        oscCase.subject = SUBJECT;
        oscCase.uniqueTransactionID = UNIQUE_TRANSACTION_ID;
        oscCase.userAlias = USER_ALIAS;

        // Add Case Attachments
        oscCase.addCaseAttachment(FILE_ATTACHMENT, FILE_EXTENSION, FILE_NAME);
        oscCase.addCaseAttachment(FILE_ATTACHMENT2, FILE_EXTENSION2, FILE_NAME2);
        // Create Case
        caseSuccessfullyCreated = oscCase.createOSCCase();
        Test.stopTest();
        // Assertions
        System.assert(caseSuccessfullyCreated, 'Case was not created in OSC');
        System.assertEquals('5003K000004wL5yQAE', oscCase.oscCaseId, 'The OSC case id returned is not correct');
        System.assertEquals('00047145', oscCase.oscCaseNumber, 'The OSC case number returned is not correct');

    }
    
     /**
     * @description Private helper method that creates an successful callout mock for the createOSCCase() method.
     * 
     * @see createOSCCase_withAllFields_caseSuccessfullyCreated()
     */
    private class CreateCaseUsingPOSTAllFieldsCalloutSuccessMock implements HttpCalloutMock {
        /**
         * @description respond
         * @param request 
         * @return  `HTTPResponse`
         */
        public HTTPResponse respond(HTTPRequest request) {   
            HttpResponse response = new HttpResponse();
            response.setBody('{"id":"5003K000004wL5yQAE","caseNumber":"00047145","message":"Case is Successfully created in Salesforce","comments":"Agent code or Alias does not exist.","attachment":"Successfully inserted the attachment"}');
            response.setStatusCode(201);
            response.setStatus('Created');
            return response;        
        }
    }
}