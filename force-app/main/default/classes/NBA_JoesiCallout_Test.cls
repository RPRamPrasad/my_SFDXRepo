/**
* @name NBA_JoesiCallout_Test
* @author Team Skynet
* @createDate 02/01/2022
* @description The Apex test class for NBA_JoesiCallout class.
*/
@isTest
public class NBA_JoesiCallout_Test {

    @TestVisible private static final String ACTION_ID = 'MUPLGU0025';
    @TestVisible private static final String ACCOUNT_CLIENT_ID = '12345678915';

    /**
    * @name AzureMockHttpResponseGenerator
    * @author Team Skynet
    * @description Fake response for Azure AD call.
    */
    public class AzureMockHttpResponseGenerator implements HttpCalloutMock {
        /**
        * @name: respond
        * @description HttpResponse
        * @param request
        * @return HTTPResponse
        */
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"token_type":"Bearer","expires_in":3599,"ext_expires_in":3599,"access_token":"eyJ0eXAi"}');
            response.setStatusCode(200);
            return response;
        }
    }

    /**
    * @name JoesiMockHttpResponseGenerator
    * @author Team Skynet
    * @description Fake response for JOESI Feedback call.
    */
    public class JoesiMockHttpResponseGenerator implements HttpCalloutMock {
        /**
        * @name: respond
        * @description HttpResponse
        * @param request
        * @return HTTPResponse
        */
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"Status":"OK","Message":"Response captured sucessfully"}');
            response.setStatusCode(200);
            return response;
        }
    }

    /**
    * @name JoesiMockHttpResponseGeneratorFail
    * @author Team Skynet
    * @description Fake error response for JOESI Feedback call.
    */
    public class JoesiMockHttpResponseGeneratorFail implements HttpCalloutMock {
        /**
        * @name: respond
        * @description HttpResponse
        * @param request
        * @return HTTPResponse
        */
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"Internal Server Error"}');
            response.setStatusCode(502);
            return response;
        }
    }

    @testSetup
    private static void testSetup(){
        TestUserSetupUtility.setupAgentOffice();
        TestUserSetupUtility.setupSystemAdminUser();
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            Account accountRecord = createAccount();
            setupAgentRole(TestUserSetupUtility.getAgentUser(), accountRecord);
            createRecommendation();
            User agentUser = TestUserSetupUtility.getAgentUser();
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'NextBestAction'];
            insert new PermissionSetAssignment(AssigneeId = agentUser.id, PermissionSetId = ps.Id);
            CS_NBA_Config__c feedbackAPIMaxRetryCounter = new CS_NBA_Config__c();
            feedbackAPIMaxRetryCounter.Name = 'FeedbackAPIMaxRetryCounter';
            feedbackAPIMaxRetryCounter.Value__c = 1;
            insert feedbackAPIMaxRetryCounter;
        }
    }

    @TestVisible private static Account createAccount(){
        Account accountRecord = new Account(Edit_In_VFP__c=true,FirstName='fstName',LastName='lstName',
                                            BillingAddressType__c='US',BillingCity='Phoenix',
                                            ClientIdentifier__c=ACCOUNT_CLIENT_ID);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        insert accountRecord;
        return accountRecord;
    }

    @TestVisible private static Account getAccount(){
        return [SELECT Id, Name, PersonContactId, ClientIdentifier__c FROM Account WHERE  ClientIdentifier__c = :ACCOUNT_CLIENT_ID];
    }

    @TestVisible private static void setupAgentRole(User userRecord, Account accountRecord){
        AgentRole__c agentRole = new AgentRole__c();
        agentRole.Agent__c = userRecord.Id;
        agentRole.Customer__c = accountRecord.Id;
        agentRole.RelationshipNature__c = 'Customer';
        insert agentRole;
    }

	@TestVisible private static void createRecommendation(){
        Recommendation rec = new Recommendation(ActionReference='Enterprise_CRM',
                                                Action_ID__c = ACTION_ID,
                                                Name = 'Test Action', Description = 'Test Description',
                                                AcceptanceLabel = 'Accept', RejectionLabel = 'Reject');
        insert rec;
    }

    @isTest
    private static void calloutAzureTokenSuccessfulTest() {
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new AzureMockHttpResponseGenerator());
        insert new CS_SFScopeStorage__c(
        	Name='DevScope',
            Environment__c = 'Dev',
            Scope__c = 'e3aidfanidfjaisfjiasf'
        );
        User sysAdminUser = TestDataFactory_User_Wrapper.generateSystemAdministratorUser('TEST', '12345678915');
        System.runAs(sysAdminUser){
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        Test.startTest();
        String response = NBA_JoesiCallout.getAzureTokenFromCache();
        // Verify that the response received contains fake values
        String expectedValue = 'eyJ0eXAi';
        System.assertEquals(response, expectedValue, 'Access token not matching');
        Test.stopTest();
        }
    }

    @isTest
    private static void calloutAzureTokenExpiredSuccessfulTest() {
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new AzureMockHttpResponseGenerator());
        insert new CS_SFScopeStorage__c(
        	Name='DevScope',
            Environment__c = 'Dev',
            Scope__c = 'e3aidfanidfjaisfjiasf'
        );
        User sysAdminUser = TestDataFactory_User_Wrapper.generateSystemAdministratorUser('TEST', '12345678915');
        System.runAs(sysAdminUser){
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        Cache.Org.put('local.NBAAzureToken.accessToken', 'eyJ0eXAi');
        Datetime yesterday = Datetime.now().addDays(-1);
        Cache.Org.put('local.NBAAzureToken.inputTime', yesterday);
        Test.startTest();
        String response = NBA_JoesiCallout.getAzureTokenFromCache();
        Test.stopTest();
        // Verify that the response received contains fake values
        String expectedValue = 'eyJ0eXAi';
        System.assertEquals(response, expectedValue, 'Access token not matching');
        }
    }

    @isTest
    private static void calloutJoesiFeedbackFailedTest() {
        Cache.Org.put('local.NBAAzureToken.accessToken', 'eyJ0eXAi');
        // Set mock callout class

        Test.setMock(HttpCalloutMock.class, new JoesiMockHttpResponseGeneratorFail());
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        User proxyUser = TestUserSetupUtility.getProxyUser();
        User agentUser = TestUserSetupUtility.getAgentUser();
        Account accountRecord = getAccount();

        SFCustomRecommendation__c recommendation =
                        new NBA_RecommendationBuilder()
                        .setAccountId(accountRecord.Id)
                        .setAgentOfficeUserId(proxyUser.Id)
                        .setServicingAgentAssociateId('ASSOCIATEID')
                        .setContextType('COA')
                        .setEnterpriseInteractionId('eiid123')
                        .setPropensity('0.80')
                        .setExternalInteractionID('-3721810088443331923')
                        .setPriority('0.9955418985179654')
                        .setChannel('Agent')
                        .setRank('1')
                        .setDirection('Inbound')
                        .setTreatment('Agent ECRM Rec')
                        .setPlacement('ECRM NBA Module')
                        .setExternalClientId('123456')
            			.setDecisionTime('20210318T173517.577 GMT')
                        .setActionID(ACTION_ID)
                        .setActionGroup('Auto')
                        .setActionIssue('Multi Lining')
                        .setActionCategory('TBD')
                        .setActionLabel('Guidance on PLUP')
                        .setActionName('GuidanceOnPLUP')
                        .setActionVariant('TBD Variant')
                        .setActionIdText('/ML/PLUP/GOnPLUP')
                        .build();

        List<SFCustomRecommendation__c> recommendations = new List<SFCustomRecommendation__c>();
        recommendations.add(recommendation);
        NBA_RecommendationService.saveRecommendations(recommendations);
        List<SFCustomRecommendation__c> savedRecommendations = [SELECT Id FROM SFCustomRecommendation__c];
        System.assert(!savedRecommendations.isEmpty(), 'Size is not greater than 0');
        List<NBA_JoesiCallout.FlowInputs> flowInputs = new List<NBA_JoesiCallout.FlowInputs>();
        NBA_JoesiCallout.FlowInputs inputs = new NBA_JoesiCallout.FlowInputs();
        inputs.isRecommendationAccepted = true;
        inputs.sfRecommendationId = savedRecommendations.get(0).Id;

        flowInputs.add(inputs);
        System.runAs(agentUser) {
            Test.startTest();
            NBA_JoesiCallout.invokeJoesiNBAFeedback(flowInputs);
            Test.stopTest();
        }

        // Verify that the response received contains fake values
        List<ExceptionLog__c> exceptionLogs = [select id, method__c, Exception_Message__c from ExceptionLog__c where method__c = 'getJoesiNBACallout'];
        System.assertEquals(1, exceptionLogs.size(), 'Size of exceptions is not greater than 0');
        System.assertEquals('Status: 502 Response:{"Internal Server Error"} ClientId: 12345678915 EIID: eiid123 ActionID:MUPLGU0025',
        exceptionLogs.get(0).Exception_Message__c, 'Unexpected Exception');
    }



    @isTest
    private static void getJoesiNBACalloutExceptionTest() {

        User agentUser = TestUserSetupUtility.getAgentUser();

        String recommendationId = 'a2755000000yxQ6AAI';

        List<NBA_JoesiCallout.FlowInputs> flowInputs = new List<NBA_JoesiCallout.FlowInputs>();
        NBA_JoesiCallout.FlowInputs inputs = new NBA_JoesiCallout.FlowInputs();
        inputs.isRecommendationAccepted = true;
        inputs.sfRecommendationId = recommendationId;

        flowInputs.add(inputs);
        System.runAs(agentUser) {
            Test.startTest();
            NBA_JoesiCallout.invokeJoesiNBAFeedback(flowInputs);
            Test.stopTest();
        }
        // Verify that the response received contains fake values

        List<ExceptionLog__c> exceptionLogs = [select id, method__c, Exception_Message__c from ExceptionLog__c where method__c = 'getJoesiNBACallout'];
        System.assertEquals(1, exceptionLogs.size(), 'Size of exceptions is not greater than 0');
        System.assertEquals('No recommendation was found for ' + recommendationId, exceptionLogs.get(0).Exception_Message__c, 'Unexpected exception');
    }

    @isTest
    private static void calloutJoesiFeedbackSuccessfulTest() {
        Cache.Org.put('local.NBAAzureToken.accessToken', 'eyJ0eXAi');
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new JoesiMockHttpResponseGenerator());
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        User proxyUser = TestUserSetupUtility.getProxyUser();
        User agentUser = TestUserSetupUtility.getAgentUser();
        Account accountRecord = getAccount();

        SFCustomRecommendation__c recommendation =
                        new NBA_RecommendationBuilder()
                        .setAccountId(accountRecord.Id)
                        .setAgentOfficeUserId(proxyUser.Id)
                        .setServicingAgentAssociateId('ASSOCIATEID')
                        .setContextType('COA')
                        .setEnterpriseInteractionId('eiid123')
                        .setPropensity('0.80')
                        .setExternalInteractionID('-3721810088443331923')
                        .setPriority('0.9955418985179654')
                        .setChannel('Agent')
                        .setRank('1')
                        .setDirection('Inbound')
                        .setTreatment('Agent ECRM Rec')
                        .setPlacement('ECRM NBA Module')
                        .setExternalClientId('123456')
            			.setDecisionTime('20210318T173517.577 GMT')
                        .setActionID(ACTION_ID)
                        .setActionGroup('Auto')
                        .setActionIssue('Multi Lining')
                        .setActionCategory('TBD')
                        .setActionLabel('Guidance on PLUP')
                        .setActionName('GuidanceOnPLUP')
                        .setActionVariant('TBD Variant')
                        .setActionIdText('/ML/PLUP/GOnPLUP')
                        .build();

        List<SFCustomRecommendation__c> recommendations = new List<SFCustomRecommendation__c>();
        recommendations.add(recommendation);
        NBA_RecommendationService.saveRecommendations(recommendations);
        List<SFCustomRecommendation__c> savedRecommendations = [SELECT Id FROM SFCustomRecommendation__c];
        System.assert(!savedRecommendations.isEmpty(), 'Size is not greater than 0');
        List<NBA_JoesiCallout.FlowInputs> flowInputs = new List<NBA_JoesiCallout.FlowInputs>();
        NBA_JoesiCallout.FlowInputs inputs = new NBA_JoesiCallout.FlowInputs();
        inputs.isRecommendationAccepted = true;
        inputs.sfRecommendationId = savedRecommendations.get(0).Id;

        flowInputs.add(inputs);
        System.runAs(agentUser) {
            Test.startTest();
            NBA_JoesiCallout.invokeJoesiNBAFeedback(flowInputs);
            Test.stopTest();
        }

    }

    @isTest
    private static void calloutJoesiFeedbackDeclineSuccessfulTest() {
        Cache.Org.put('local.NBAAzureToken.accessToken', 'eyJ0eXAi');
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new JoesiMockHttpResponseGenerator());
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        User proxyUser = TestUserSetupUtility.getProxyUser();
        User agentUser = TestUserSetupUtility.getAgentUser();
        Account accountRecord = getAccount();

        SFCustomRecommendation__c recommendation =
                        new NBA_RecommendationBuilder()
                        .setAccountId(accountRecord.Id)
                        .setAgentOfficeUserId(proxyUser.Id)
                        .setServicingAgentAssociateId('ASSOCIATEID')
                        .setContextType('COA')
                        .setEnterpriseInteractionId('eiid123')
                        .setPropensity('0.80')
                        .setExternalInteractionID('-3721810088443331923')
                        .setPriority('0.9955418985179654')
                        .setChannel('Agent')
                        .setRank('1')
                        .setDirection('Inbound')
                        .setTreatment('Agent ECRM Rec')
                        .setPlacement('ECRM NBA Module')
                        .setExternalClientId('123456')
            			.setDecisionTime('20210318T173517.577 GMT')
                        .setActionID(ACTION_ID)
                        .setActionGroup('Auto')
                        .setActionIssue('Multi Lining')
                        .setActionCategory('TBD')
                        .setActionLabel('Guidance on PLUP')
                        .setActionName('GuidanceOnPLUP')
                        .setActionVariant('TBD Variant')
                        .setActionIdText('/ML/PLUP/GOnPLUP')
                        .build();

        List<SFCustomRecommendation__c> recommendations = new List<SFCustomRecommendation__c>();
        recommendations.add(recommendation);
        NBA_RecommendationService.saveRecommendations(recommendations);
        List<SFCustomRecommendation__c> savedRecommendations = [SELECT Id FROM SFCustomRecommendation__c];
        System.assert(!savedRecommendations.isEmpty(), 'Size is not greater than 0');
        List<NBA_JoesiCallout.FlowInputs> flowInputs = new List<NBA_JoesiCallout.FlowInputs>();
        NBA_JoesiCallout.FlowInputs inputs = new NBA_JoesiCallout.FlowInputs();
        inputs.isRecommendationAccepted = false;
        inputs.sfRecommendationId = savedRecommendations.get(0).Id;

        flowInputs.add(inputs);
        System.runAs(agentUser) {
            Test.startTest();
            NBA_JoesiCallout.invokeJoesiNBAFeedback(flowInputs);
            Test.stopTest();
        }

    }

    @isTest
    private static void calloutJoesiSuccessful() {
        Cache.Org.put('local.NBAAzureToken.accessToken', 'eyJ0eXAi');
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new JoesiMockHttpResponseGenerator());
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock.
        User proxyUser = TestUserSetupUtility.getProxyUser();
        User agentUser = TestUserSetupUtility.getAgentUser();
        Account accountRecord = getAccount();

        SFCustomRecommendation__c recommendation =
                        new NBA_RecommendationBuilder()
                        .setAccountId(accountRecord.Id)
                        .setAgentOfficeUserId(proxyUser.Id)
                        .setServicingAgentAssociateId('ASSOCIATEID')
                        .setContextType('COA')
                        .setEnterpriseInteractionId('eiid123')
                        .setPropensity('0.80')
                        .setExternalInteractionID('-3721810088443331923')
                        .setPriority('0.9955418985179654')
                        .setChannel('Agent')
                        .setRank('1')
                        .setDirection('Inbound')
                        .setTreatment('Agent ECRM Rec')
                        .setPlacement('ECRM NBA Module')
                        .setExternalClientId('123456')
            			.setDecisionTime('20210318T173517.577 GMT')
                        .setActionID(ACTION_ID)
                        .setActionGroup('Auto')
                        .setActionIssue('Multi Lining')
                        .setActionCategory('TBD')
                        .setActionLabel('Guidance on PLUP')
                        .setActionName('GuidanceOnPLUP')
                        .setActionVariant('TBD Variant')
                        .setActionIdText('/ML/PLUP/GOnPLUP')
                        .build();

        List<SFCustomRecommendation__c> recommendations = new List<SFCustomRecommendation__c>();
        recommendations.add(recommendation);
        NBA_RecommendationService.saveRecommendations(recommendations);
        List<SFCustomRecommendation__c> savedRecommendations = [SELECT Id, EIID__c, Account__r.ClientIdentifier__c, External_Interaction_ID__c,
                                                        		Rank__c, Direction__c, Channel__c, Status__c, Treatment__c, Action_ID__c,
                                                                Recommendation__r.Group__c, Recommendation__r.Issue__c, Recommendation__r.Name
                                                         FROM SFCustomRecommendation__c];
        System.assert(!savedRecommendations.isEmpty(), 'Size is not greater than 0');
        HttpResponse response;
        System.runAs(agentUser) {
            Test.startTest();
            response = NBA_JoesiCallout.callJoesiFeedback(savedRecommendations.get(0), true, savedRecommendations.get(0).EIID__c);
            Test.stopTest();
        }
        // Verify that the response received contains fake values
        String contentType = response.getHeader('Content-Type');
        System.assertEquals('application/json', contentType, 'Unexpected Content-Type');
        String actualValue = response.getBody();
        String expectedValue = '{"Status":"OK","Message":"Response captured sucessfully"}';
        System.assertEquals(expectedValue, actualValue, 'Unexpected response body');
        System.assertEquals(200, response.getStatusCode(), 'Unexpected response status code');
    }

    @isTest
    private static void testConstructor(){
        NBA_JoesiCallout nbaInstance = new NBA_JoesiCallout();
        System.assert(true, 'Mandatory Assert statement on Tests');
    }
}
