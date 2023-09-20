@isTest(SeeAllData = false)
private class UTIL_RequestForCredit_TEST {
   	private static Account acc;
    private static User systemAdmin;
    private static User agent;
    private static User officeProxy;
    
    /**
     * @description Setting up system user as well as account info
     */
    @testSetup
    public static void testSetupData() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();		
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;
        
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
        insert sysAdminUserIdSetting;  
    }

    @isTest
    private static void getAllReasonDescriptions() {
        acc = new Account(FirstName = 'testUtilAccDAOFName', LastName = 'testUtilAccDAOLName', ClientIdentifier__c='test');
        systemAdmin = setupRunAsUser();
        agent = setupAgentUser();
        officeProxy = setupOfficeProxy();
        System.runAs(systemAdmin) {
            OppNotificationPreferenceRetriever_TEST.byPassTrigger();
            UTIL_AccountDAO.insertAccounts(new List<Account>{acc});
            insert agent;
            insert officeProxy;
        }     
        Opportunity opp = buildAnILPOpportunity(); 
        insert opp;
        opp.LeadType__c =  'AUTOLT';
        opp.Vendor_ID__c = 'ILP4';
        update opp;
          
        List<String> expectedRetVal = new List<String>();
        NewRFCReasonCodes__mdt[] queriedOrgReasons = [SELECT RFCReasonDescription__c FROM NewRFCReasonCodes__mdt]; 
        
        for(NewRFCReasonCodes__mdt rfcreason : queriedOrgReasons) { 
            expectedRetVal.add(rfcreason.RFCReasonDescription__c);    
        }
        String[] actualRetVal = new String[]{};
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agent);

        System.runAs(agent) {
            Test.startTest();
            actualRetVal = UTIL_RequestForCredit.getReasonDescriptions(opp);
            Test.stopTest();
        }
        System.assertEquals(expectedRetVal.size(), actualRetVal.size(),'The expected and actual output lists should be of the same length');
    } 

    @isTest
    private static void getReasonCodeHappyPath() {
        systemAdmin = setupRunAsUser();
        agent = setupAgentUser();
        System.runAs(systemAdmin) {
            insert agent;
        }      
                
        NewRFCReasonCodes__mdt[] reasonQueryData = [SELECT RFCReasonDescription__c FROM NewRFCReasonCodes__mdt LIMIT 1];
        String rfcReason = reasonQueryData[0].RFCReasonDescription__c;
        NewRFCReasonCodes__mdt[] reasonCodeQueryData = [SELECT RFCReasonCode__c FROM NewRFCReasonCodes__mdt WHERE RFCReasonDescription__c =:rfcReason LIMIT 1];
        String expectedRetVal = reasonCodeQueryData[0].RFCReasonCode__c;

        String actualRetVal = '';
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agent);

        System.runAs(agent){
            Test.startTest();
            actualRetVal = UTIL_RequestForCredit.getReasonCode(rfcReason);
            Test.stopTest();
        }
        System.assertEquals(expectedRetVal, actualRetVal,'The expected and actual output lists should be of the same length');
    } 

    @isTest
    private static void isRequestWindowOpenTrueBasedOnLeadValDate() {
        acc = new Account(FirstName = 'testUtilAccDAOFName', LastName = 'testUtilAccDAOLName', ClientIdentifier__c='test');
        systemAdmin = setupRunAsUser();
        agent = setupAgentUser();
        officeProxy = setupOfficeProxy();
        System.runAs(systemAdmin) {
            OppNotificationPreferenceRetriever_TEST.byPassTrigger();
            UTIL_AccountDAO.insertAccounts(new List<Account>{acc});
            insert agent;
            insert officeProxy;
        }      
        Opportunity opp = buildAnILPOpportunity(); // the Lead_Validation_Date__c is today, meaning the request window is still open
        insert opp;

        Boolean expectedRetVal = true;
        Boolean actualRetVal;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agent);

        System.runAs(agent) {
            Test.startTest();
            actualRetVal = UTIL_RequestForCredit.isRequestWindowOpen(opp);
            Test.stopTest();
        }
        System.assertEquals(expectedRetVal, actualRetVal,'isRequestWindowOpen() returns true as the opp Lead_Validation_Date__c is today');
    }

    @isTest
    private static void isRequestWindowFalse() {
        acc = new Account(FirstName = 'testUtilAccDAOFName', LastName = 'testUtilAccDAOLName', ClientIdentifier__c='test');
        systemAdmin = setupRunAsUser();
        agent = setupAgentUser();
        officeProxy = setupOfficeProxy();
        System.runAs(systemAdmin) {
            OppNotificationPreferenceRetriever_TEST.byPassTrigger();
            insert acc;
            insert agent;
            insert officeProxy;
        }      
        Opportunity opp = buildAnILPOpportunity(); 
        insert opp;
        opp.Lead_Validation_Date__c -=  150; // set a Lead_Validation_Date__c value that is far beyond the day limit of any vendor which is typically 15 days after opp creation
        update opp;

        Boolean expectedRetVal = false;
        Boolean actualRetVal;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agent);

        System.runAs(agent) {
            Test.startTest();
            actualRetVal = UTIL_RequestForCredit.isRequestWindowOpen(opp);
            Test.stopTest();
        }
        System.assertEquals(expectedRetVal, actualRetVal,'isRequestWindowOpen() returns true as the opp Lead_Validation_Date__c is today');
    }

    @isTest
    private static void scrubForSPIGivesErrorMsgWithSSNGiven() {     
        User nonAPIUser = UTIL_UserProvisioning_TEST.createNonAPITestUser();
        String commentInput = '078-05-1120 This is an invalid pocketbook SSN. Wallets used to be sold with fake SSN cards inside. This was a common number on those cards.'; // not a real SSN, a pocketbook SSN from back in the day
        
        String actualRetVal;
        System.runAs(nonAPIUser) {
            Test.startTest();
            try {
                actualRetVal = UTIL_RequestForCredit.scrubForSPI(commentInput, 'comments');
            } catch(Exception e){
                System.assert(e.getMessage().contains('comments'),'Exception message should contains \'comments\'');
            }
            Test.stopTest();
        }
    }

    @isTest
    private static void scrubForSPIGivesNoErrorMsgWithValidInput() {     
        User nonAPIUser = UTIL_UserProvisioning_TEST.createNonAPITestUser();
        String commentInput = 'No SPI here, but a fun fact for you. The alligator is my favorite animal. Will ask Steve Blunier for his on the next unit test.';
        
        String actualRetVal;
        System.runAs(nonAPIUser) {
            Test.startTest();
            try {
                actualRetVal = UTIL_RequestForCredit.scrubForSPI(commentInput, 'comments');
            } catch(Exception e){
                System.assertEquals('', e.getMessage(), 'SPI controller gives no message as its input contains no SPI');
            }
            Test.stopTest();
        }
    }

    @isTest
    private static void routeRequestForCreditHappyPath() {
        acc = new Account(FirstName = 'testUtilAccDAOFName', LastName = 'testUtilAccDAOLName', ClientIdentifier__c='test');
        systemAdmin = setupRunAsUser();
        agent = setupAgentUser();
        officeProxy = setupOfficeProxy();
        CS_EnvironmentURLCustomSetting__c csEnvUrl = new CS_EnvironmentURLCustomSetting__c(Name='Request_For_Credit_SR_API_Key', Value__c='test');

        System.runAs(systemAdmin) {
            OppNotificationPreferenceRetriever_TEST.byPassTrigger();
            insert csEnvUrl;
            insert acc;
            insert agent;
            insert officeProxy;
        }      
        Opportunity opp = buildAnILPOpportunity(); 
        opp.Assigned_To__c = agent.id;
        opp.RFCReasonDescription__c = 'Invalid Email';
        opp.RFCComments__c = 'Bad email given. Special characters used';
        insert opp;

        Boolean expectedRetVal = true;
        Boolean actualRetVal;
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agent);

        System.runAs(agent) {
            Test.startTest();
            actualRetVal = UTIL_RequestForCredit.routeRequestForCredit(opp);
            Test.stopTest();
        } 
        System.assertEquals(expectedRetVal, actualRetVal,'routeRequestForCredit() returns true as the opp returns true with valid Opp data');
    }

    @isTest
    private static void routeRequestForCreditFailureResponse() {
        acc = new Account(FirstName = 'testUtilAccDAOFName', LastName = 'testUtilAccDAOLName', ClientIdentifier__c='test');
        systemAdmin = setupRunAsUser();
        agent = setupAgentUser();
        officeProxy = setupOfficeProxy();
        CS_EnvironmentURLCustomSetting__c csEnvUrl = new CS_EnvironmentURLCustomSetting__c(Name='Request_For_Credit_SR_API_Key', Value__c='test');

        System.runAs(systemAdmin) {
            OppNotificationPreferenceRetriever_TEST.byPassTrigger();
            insert csEnvUrl;
            insert acc;
            insert agent;
            insert officeProxy;
        }      
        Opportunity opp = buildAnILPOpportunity(); 
        opp.Assigned_To__c = agent.id;
        opp.RFCReasonDescription__c = 'Invalid Email';
        opp.RFCComments__c = 'Bad email given. Special characters used';
        insert opp;

        Boolean expectedRetVal = false;
        Boolean actualRetVal;
        Test.setMock(WebServiceMock.class, new WebServiceFailureMockImpl());
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agent);

        System.runAs(agent) {
            Test.startTest();
            actualRetVal = UTIL_RequestForCredit.routeRequestForCredit(opp);
            Test.stopTest();
        } 
        System.assertEquals(expectedRetVal, actualRetVal,'routeRequestForCredit() returns false as the web service callout gives a FAILURE http response');
    }

    private static User setupRunAsUser() {
        return UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
    }
    
    private static User setupAgentUser() {
        User testAgentUser1 = new User(Alias='alias',LastName='agentUser',Username='agentUserTest@statefarm.com',Associate_ID__c='agent200',UserExternalID__c='agent200_agent200',Servicing_Agent_Associate_ID__c='agent200');
        return UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
    }
    
    private static User setupOfficeProxy() {
        User testProxyUser1 = new User(Alias='alias',LastName='officeProxy',Username='officeProxyTest@statefarm.com',UserExternalID__c='agent200p',Servicing_Agent_Associate_ID__c='agent200');
        return UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
    }

    private static Opportunity buildAnILPOpportunity() {
        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Name='Auto-TEST';
        newOpportunity.AccountId=acc.Id;
        newOpportunity.Lead_Validation_Date__c = system.Today();
        newOpportunity.Vendor_Id__c='ILP5';
        newOpportunity.StageName='New';
        newOpportunity.LOB__c='Auto';
        newOpportunity.CloseDate=system.today();
        newOpportunity.ExternalILPId__c='sdxch';
        newOpportunity.Transaction_ID__c='wsghbyy';
        newOpportunity.OwnerId = officeProxy.Id;
        return newOpportunity;
    }
    
    private class WebServiceMockImpl implements WebServiceMock {
        /**
         * @description doInvoke
         * @param stub
         * @param request
         * @param response
         * @param endpoint
         * @param soapAction
         * @param requestName
         * @param responseNS
         * @param responseName
         * @param responseType
         */
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
            if(request instanceof  SendRequestForCredit.sendRequestForCreditRequest_element) {
                SendRequestForCredit.sendRequestForCreditResponse_element response_x = new SendRequestForCredit.sendRequestForCreditResponse_element();
            	response_x.Status = 'OK';
                response.put('response_x',response_x);
        	}
            return;
        }
   }
   
   /**
    * @description Mock class for a failure response from web server, not the same as 
    * a runtime exception 
    */
   private class WebServiceFailureMockImpl implements WebServiceMock {
    /**
         * @description doInvoke
         * @param stub
         * @param request
         * @param response
         * @param endpoint
         * @param soapAction
         * @param requestName
         * @param responseNS
         * @param responseName
         * @param responseType
         */
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType)
        {
            if(request instanceof  SendRequestForCredit.sendRequestForCreditRequest_element) {
                SendRequestForCredit.sendRequestForCreditResponse_element response_x = new SendRequestForCredit.sendRequestForCreditResponse_element();
            	response_x.Status = 'FAILURE';
                response.put('response_x',response_x);
        	}
            return;
        }
   }
}