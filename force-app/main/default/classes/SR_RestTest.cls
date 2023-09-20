@isTest
(seeAllData=false)
private class SR_RestTest {


    @testSetup
    private static void testSetUp(){
        TestUserSetupUtility.setupAllUsers();
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            SR_TestDataUtility.insertCustomSetting();
            SR_TestDataUtility.createAccount();
            SR_TestDataUtility.createSecondaryAccount();
            SR_TestDataUtility.addUserToSOEDelegatePermSet(TestUserSetupUtility.getApiOnlyUser());
            SR_TestDataUtility.addUserToFSCInsurancePermSet(TestUserSetupUtility.getApiOnlyUser());
            SR_TestDataUtility.setupAgentRole(TestUserSetupUtility.getAgentUser(), SR_TestDataUtility.getAccount());
            SR_TestDataUtility.setupAgentRole(TestUserSetupUtility.getSecondaryAgentUser(), SR_TestDataUtility.getSecondaryAccount());
        }
    }
    
    @isTest 
    private static void testSync() {
        User proxyUser = TestUserSetupUtility.getProxyUser();
        User proxyUser2 = TestUserSetupUtility.getSecondaryProxyUser();
        User soeDelegate = TestUserSetupUtility.getApiOnlyUser();
        Account acct = SR_TestDataUtility.getAccount();
        Account acct2 = SR_TestDataUtility.getSecondaryAccount();
        
        SR_TestDataUtility.SR_TestDataUtilityWrapper param1 = new SR_TestDataUtility.SR_TestDataUtilityWrapper();
        param1.owner = proxyUser;
        param1.acct = acct;
        param1.tierLevel = 2;
        param1.recordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE;
        param1.hasTask = false;

        Test.startTest();
        Case exisitingTier2Case;
        exisitingTier2Case = SR_TestDataUtility.createExistingCase(param1);
        List<SR_Payload> payloads = new List<SR_Payload>();
        SR_Payload tier2Payload = SR_TestDataUtility.getTier3Payload(acct.ClientIdentifier__c, proxyUser.UserExternalId__c, 'Policy_Change');
        SR_Payload tier4Payload = SR_TestDataUtility.getTier5Payload(acct2.ClientIdentifier__c, proxyUser2.UserExternalId__c, 'Policy_Change');
        payloads.add(tier2Payload);
        payloads.add(tier4Payload);
        System.runAs(soeDelegate){
           SR_Rest.handleRequest(payloads, true);
           
        }
        
        Case updatedCase = [SELECT Id, Owner_User_External_Id__c, OwnerId, AccountId FROM Case WHERE AccountId =: acct.Id];
        Case insertedCase = [SELECT Id, Owner_User_External_Id__c, OwnerId, AccountId FROM Case WHERE AccountId =: acct2.Id];
        System.assert(insertedCase.OwnerId == proxyUser2.Id, 'unexpected case owner = ' + insertedCase.OwnerId);
        System.assert(insertedCase.AccountId == acct2.Id, 'unexpected account id = ' + insertedCase.AccountId);
        System.assert(updatedCase.OwnerId == proxyUser.Id, 'unexpected case owner = ' + updatedCase.OwnerId);
        System.assert(updatedCase.AccountId == acct.Id, 'unexpected AccountId = ' + updatedCase.AccountId);
        Test.stopTest();
    }
    
    @isTest 
    private static void testAsyncPolicyChange() {
        User proxyUser = TestUserSetupUtility.getProxyUser();
        User proxyUser2 = TestUserSetupUtility.getSecondaryProxyUser();
        User soeDelegate = TestUserSetupUtility.getApiOnlyUser();
        Account acct = SR_TestDataUtility.getAccount();
        Account acct2 = SR_TestDataUtility.getSecondaryAccount();
        
        SR_TestDataUtility.SR_TestDataUtilityWrapper param1 = new SR_TestDataUtility.SR_TestDataUtilityWrapper();
        param1.owner = proxyUser;
        param1.acct = acct;
        param1.tierLevel = 2;
        param1.recordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE;
        param1.hasTask = false;
        Test.startTest();
        Case exisitingTier2Case;
        exisitingTier2Case = SR_TestDataUtility.createExistingCase(param1);

        List<SR_Payload> payloads = new List<SR_Payload>();
        SR_Payload tier2Payload = SR_TestDataUtility.getTier3Payload(acct.ClientIdentifier__c, proxyUser.UserExternalId__c,'Policy_Change');
        SR_Payload tier4Payload = SR_TestDataUtility.getTier5Payload(acct2.ClientIdentifier__c, proxyUser2.UserExternalId__c,'Policy_Change');
        payloads.add(tier2Payload);
        payloads.add(tier4Payload);
        System.runAs(soeDelegate){
           SR_Rest.handleRequest(payloads, false);
           
        }
        
        System.assert(Limits.getFutureCalls() == 1, 'async was not called');
        Test.stopTest();
        Case updatedCase = [SELECT Id, Owner_User_External_Id__c, OwnerId, AccountId FROM Case WHERE AccountId =: acct.Id];
        Case insertedCase = [SELECT Id, Owner_User_External_Id__c, OwnerId, AccountId FROM Case WHERE AccountId =: acct2.Id];
        System.assert(insertedCase.OwnerId == proxyUser2.Id, 'unexpected case owner = ' + insertedCase.OwnerId);
        System.assert(insertedCase.AccountId == acct2.Id, 'unexpected account id = ' + insertedCase.AccountId);
        System.assert(updatedCase.OwnerId == proxyUser.Id, 'unexpected case owner = ' + updatedCase.OwnerId);
        System.assert(updatedCase.AccountId == acct.Id, 'unexpected AccountId = ' + updatedCase.AccountId);
    }

    @isTest 
    private static void testAsyncPolicyChangeClosureWithOpenTask() {
        User proxyUser = TestUserSetupUtility.getProxyUser();
        User soeDelegate = TestUserSetupUtility.getApiOnlyUser();
        Account acct = SR_TestDataUtility.getAccount();

        SR_TestDataUtility.SR_TestDataUtilityWrapper param2 = new SR_TestDataUtility.SR_TestDataUtilityWrapper();
        param2.owner = proxyUser;
        param2.acct = acct;
        param2.tierLevel = 2;
        param2.recordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE;
        param2.hasTask = true; 

        Test.startTest();
        Case exisitingTier2Case;
        exisitingTier2Case = SR_TestDataUtility.createExistingCase(param2);
        List<SR_Payload> payloads = new List<SR_Payload>();
        SR_Payload tier2Payload = SR_TestDataUtility.getClosedStatusPayload(acct.ClientIdentifier__c, proxyUser.UserExternalId__c,'Policy_Change');
        payloads.add(tier2Payload);
        System.runAs(soeDelegate){
           SR_Rest.handleRequest(payloads, false);
           
        }
        
        System.assert(Limits.getFutureCalls() == 1, 'async was not called');
        Test.stopTest();
        Case updatedCase = [SELECT Id, Owner_User_External_Id__c, OwnerId, AccountId, Status FROM Case WHERE AccountId =: acct.Id];
        System.assert(updatedCase.OwnerId == proxyUser.Id, 'unexpected case owner = ' + updatedCase.OwnerId);
        System.assert(updatedCase.AccountId == acct.Id, 'unexpected AccountId = ' + updatedCase.AccountId);
        System.assert(updatedCase.Status == 'Agent Review', 'case was not left open with Closure event and follow up date');
    }


    @isTest 
    private static void testAsyncPolicyChangeClosure() {
        User proxyUser = TestUserSetupUtility.getProxyUser();
        User soeDelegate = TestUserSetupUtility.getApiOnlyUser();
        Account acct = SR_TestDataUtility.getAccount();
        SR_TestDataUtility.SR_TestDataUtilityWrapper param1 = new SR_TestDataUtility.SR_TestDataUtilityWrapper();
        param1.owner = proxyUser;
        param1.acct = acct;
        param1.tierLevel = 2;
        param1.recordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE;
        param1.hasTask = false;
        Test.startTest();
        Case exisitingTier2Case;
        exisitingTier2Case = SR_TestDataUtility.createExistingCase(param1);

        List<SR_Payload> payloads = new List<SR_Payload>();
        SR_Payload tier2Payload = SR_TestDataUtility.getClosedStatusPayload(acct.ClientIdentifier__c, proxyUser.UserExternalId__c,'Policy_Change');
        payloads.add(tier2Payload);
        System.runAs(soeDelegate){
           SR_Rest.handleRequest(payloads, false);
           
        }
        
        System.assert(Limits.getFutureCalls() == 1, 'async was not called');
        Test.stopTest();

        Case updatedCase = [SELECT Id, Owner_User_External_Id__c, OwnerId, AccountId, Status FROM Case WHERE AccountId =: acct.Id];
        System.assert(updatedCase.OwnerId == proxyUser.Id, 'unexpected case owner = ' + updatedCase.OwnerId);
        System.assert(updatedCase.AccountId == acct.Id, 'unexpected AccountId = ' + updatedCase.AccountId);
        System.assert(updatedCase.Status == 'Closed', 'case was left open with Closure event');
    }

    @isTest 
    private static void testAsyncEnrollmentClosureWithOpenTask() {
        User proxyUser = TestUserSetupUtility.getProxyUser();
        User soeDelegate = TestUserSetupUtility.getApiOnlyUser();
        Account acct = SR_TestDataUtility.getAccount();
        
        SR_TestDataUtility.SR_TestDataUtilityWrapper param2 = new SR_TestDataUtility.SR_TestDataUtilityWrapper();
        param2.owner = proxyUser;
        param2.acct = acct;
        param2.tierLevel = 2;
        param2.recordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_ENROLLMENT_CASE;
        param2.hasTask = true; 

        Test.startTest();
        Case exisitingTier2Case;
        exisitingTier2Case = SR_TestDataUtility.createExistingCase(param2);
        List<SR_Payload> payloads = new List<SR_Payload>();
        SR_Payload tier2Payload = SR_TestDataUtility.getClosedStatusPayload(acct.ClientIdentifier__c, proxyUser.UserExternalId__c,'Enrollment_Case');
        payloads.add(tier2Payload);
        System.runAs(soeDelegate){
           SR_Rest.handleRequest(payloads, false);
           
        }
        
        System.assert(Limits.getFutureCalls() == 1, 'async was not called');
        Test.stopTest();
        Case updatedCase = [SELECT Id, Owner_User_External_Id__c, OwnerId, AccountId, Status FROM Case WHERE AccountId =: acct.Id];
        System.assert(updatedCase.OwnerId == proxyUser.Id, 'unexpected case owner = ' + updatedCase.OwnerId);
        System.assert(updatedCase.AccountId == acct.Id, 'unexpected AccountId = ' + updatedCase.AccountId);
        System.assert(updatedCase.Status == 'Setup', 'case was not left open with Closure event and follow up date');
    }

    @isTest 
    private static void testAsyncPolicyChangeWithSameEventId() {
        User proxyUser = TestUserSetupUtility.getProxyUser();
        User proxyUser2;
        proxyUser2 = TestUserSetupUtility.getSecondaryProxyUser();
        User soeDelegate = TestUserSetupUtility.getApiOnlyUser();
        Account acct = SR_TestDataUtility.getAccount();
        Account acct2;
        acct2 = SR_TestDataUtility.getSecondaryAccount();
        SR_TestDataUtility.SR_TestDataUtilityWrapper param1 = new SR_TestDataUtility.SR_TestDataUtilityWrapper();
        param1.owner = proxyUser;
        param1.acct = acct;
        param1.tierLevel = 2;
        param1.recordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE;
        param1.hasTask = false;
        Test.startTest();
        Case exisitingTier2Case;
        exisitingTier2Case = SR_TestDataUtility.createExistingCase(param1);
        List<SR_Payload> payloads = new List<SR_Payload>();
        SR_Payload tier2Payload = SR_TestDataUtility.getTier3Payload(acct.ClientIdentifier__c, proxyUser.UserExternalId__c,'Policy_Change');
        tier2Payload.eventId = 'MOCK_EVENT_ID';
        payloads.add(tier2Payload);
        System.runAs(soeDelegate){
           SR_Rest.handleRequest(payloads, false);
           
        }
        
        System.assert(Limits.getFutureCalls() == 1, 'async was not called');
        Test.stopTest();
        Case updatedCase = [SELECT Id, Owner_User_External_Id__c, OwnerId, AccountId, Status FROM Case WHERE AccountId =: acct.Id];
        System.assert(updatedCase.OwnerId == proxyUser.Id, 'unexpected case owner = ' + updatedCase.OwnerId);
        System.assert(updatedCase.AccountId == acct.Id, 'unexpected AccountId = ' + updatedCase.AccountId);
        System.assert(updatedCase.Status == 'New Request', 'case status was updated unexpectedly: '+updatedCase.Status);
    }
    
    @isTest 
    private static void testAsyncBilling() {
        User proxyUser = TestUserSetupUtility.getProxyUser();
        User proxyUser2 = TestUserSetupUtility.getSecondaryProxyUser();
        User soeDelegate = TestUserSetupUtility.getApiOnlyUser();
        Account acct = SR_TestDataUtility.getAccount();
        Account acct2 = SR_TestDataUtility.getSecondaryAccount();
        SR_TestDataUtility.SR_TestDataUtilityWrapper param1 = new SR_TestDataUtility.SR_TestDataUtilityWrapper();
        param1.owner = proxyUser;
        param1.acct = acct;
        param1.tierLevel = 2;
        param1.recordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_BILLING;
        param1.hasTask = false;
        Test.startTest();
        Case existingBilTier2Case;
        existingBilTier2Case = SR_TestDataUtility.createExistingCase(param1);
        List<SR_Payload> payloads = new List<SR_Payload>();
        SR_Payload bilTier2Payload = SR_TestDataUtility.getTier3Payload(acct.ClientIdentifier__c, proxyUser.UserExternalId__c,'Billing');
        SR_Payload bilTier4Payload = SR_TestDataUtility.getTier5Payload(acct2.ClientIdentifier__c, proxyUser2.UserExternalId__c,'Billing');
        payloads.add(bilTier2Payload);
        payloads.add(bilTier4Payload);
        System.runAs(soeDelegate){
           SR_Rest.handleRequest(payloads, false);
           
        }
        
        System.assert(Limits.getFutureCalls() == 1, 'async was not called');
        Test.stopTest();
        Case updatedBilCase = [SELECT Id, Owner_User_External_Id__c, OwnerId, AccountId FROM Case 
                              WHERE AccountId =: acct.Id and RecordTypeId = :CaseHandlerConstants.CASE_RECORDTYPE_ID_BILLING];
        Case insertedBilCase = [SELECT Id, Owner_User_External_Id__c, OwnerId, AccountId FROM Case 
                               WHERE AccountId =: acct2.Id and RecordTypeId = :CaseHandlerConstants.CASE_RECORDTYPE_ID_BILLING];
        System.assert(insertedBilCase.OwnerId == proxyUser2.Id, 'unexpected case owner = ' + insertedBilCase.OwnerId);
        System.assert(insertedBilCase.AccountId == acct2.Id, 'unexpected account id = ' + insertedBilCase.AccountId);
        System.assert(updatedBilCase.OwnerId == proxyUser.Id, 'unexpected case owner = ' + updatedBilCase.OwnerId);
        System.assert(updatedBilCase.AccountId == acct.Id, 'unexpected AccountId = ' + updatedBilCase.AccountId);
    }

    @isTest
    private static void testSetFollowUpDate() {
        User proxyUser = TestUserSetupUtility.getProxyUser();
        User soeDelegate = TestUserSetupUtility.getApiOnlyUser();
        Account acct = SR_TestDataUtility.getAccount();
        SR_TestDataUtility.SR_TestDataUtilityWrapper param1 = new SR_TestDataUtility.SR_TestDataUtilityWrapper();
        param1.owner = proxyUser;
        param1.acct = acct;
        param1.tierLevel = 2;
        param1.recordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE;
        param1.hasTask = false;
        Test.startTest();
        Case existingCase;
        existingCase = SR_TestDataUtility.createExistingCase(param1);

        List<SR_Payload> payloads = new List<SR_Payload>();
        SR_Payload tier2Payload = SR_TestDataUtility.getTier3Payload(acct.ClientIdentifier__c, proxyUser.UserExternalId__c, 'Policy_Change');

        Task taskRecord = SR_TestDataUtility.buildDefaultTask();
        Date followUpDate = Date.today().addDays(3);
        taskRecord.ActivityDate = followUpDate;
        tier2Payload.taskRecord = taskRecord;
        
        payloads.add(tier2Payload);
        System.runAs(soeDelegate){
           SR_Rest.handleRequest(payloads, false);
        }
        
        System.assert(Limits.getFutureCalls() == 1, 'async was not called');
        Test.stopTest();

        Case updatedCase = [SELECT Id, Follow_Up_Date__c FROM Case 
                              WHERE AccountId =: acct.Id and RecordTypeId = :CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE];
        System.assert(updatedCase.Follow_Up_Date__c == taskRecord.ActivityDate, 'unexpected follow up date = ' + updatedCase.Follow_Up_Date__c);
    }
    
    @isTest
    private static void testSetFollowUpDateWithNoMatchDefaultCase() {
        User proxyUser = TestUserSetupUtility.getProxyUser();
        User soeDelegate = TestUserSetupUtility.getApiOnlyUser();
        Account acct = SR_TestDataUtility.getAccount();
        
        Test.startTest();
        //Case existingCase = SR_TestDataUtility.createExistingCase(proxyUser, acct, 2, CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE, false);
        
        List<SR_Payload> payloads = new List<SR_Payload>();
        SR_Payload tier2Payload = SR_TestDataUtility.getTier3Payload(acct.ClientIdentifier__c, proxyUser.UserExternalId__c, 'Policy_Change');

        Task taskRecord = SR_TestDataUtility.buildDefaultTask();
        Date followUpDate = Date.today().addDays(3);
        taskRecord.ActivityDate = followUpDate;
        tier2Payload.taskRecord = taskRecord;
		SR_Defaults defaults = new SR_Defaults();
		defaults.caseRecord = SR_TestDataUtility.buildDefaultCase();
        tier2Payload.defaults = defaults;
        
        payloads.add(tier2Payload);
        System.runAs(soeDelegate){
           SR_Rest.handleRequest(payloads, false);
        }
        
        System.assert(Limits.getFutureCalls() == 1, 'async was not called');
        Test.stopTest();

        Case updatedCase = [SELECT Id, Follow_Up_Date__c FROM Case 
                              WHERE AccountId =: acct.Id and RecordTypeId = :CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE];
        System.assert(updatedCase.Follow_Up_Date__c == taskRecord.ActivityDate, 'unexpected follow up date = ' + updatedCase.Follow_Up_Date__c);
    }
    
    @isTest 
    private static void testPNISyncWithOnePayload() {
        List<SR_Payload> payloads = new List<SR_Payload>();
        User soeDelegate = TestUserSetupUtility.getApiOnlyUser();
        User agentUser = TestUserSetupUtility.getAgentUser();
        System.runAs(TestUserSetupUtility.getSysAdminUser()){  
        	SR_TestDataUtility.setupPNITestData(agentUser);
        	SR_Payload payload = SR_TestDataUtility.getPNIPayload(agentUser, SR_Constants.CASE_APP_CODE_AUTO_CHANGE_AND_SERVICE, 'Auto');
            payloads.add(payload);
        }

        Test.startTest();
        System.runAs(soeDelegate){
           SR_Rest.handleRequest(payloads, true); 
        }
        
        Case newPolicyCase = [SELECT Id, Subject, Owner_User_External_Id__c, OwnerId, AccountId, Account.ClientIdentifier__c , ContactId, Contact.ClientIdentifier__c FROM Case WHERE Policy_Identifier__c =:SR_TestDataUtility.POLICY_ID];
        System.assertEquals(SR_TestDataUtility.PNI_PRIMARY_ACCOUNT_CLIENT_ID, newPolicyCase.Account.ClientIdentifier__c, 'Case Account field should return Primary PNI Client Identifier');
        System.assertEquals(SR_TestDataUtility.PNI_SECONDARY_ACCOUNT_CLIENT_ID, newPolicyCase.Contact.ClientIdentifier__c, 'Case Contact field should return Secondary PNI Client Identifier');
    	Test.stopTest();
    }
    
    @isTest 
	private static void testPNISyncWithPVCAppCode() {
        List<SR_Payload> payloads = new List<SR_Payload>();
        User soeDelegate = TestUserSetupUtility.getApiOnlyUser();
        User agentUser = TestUserSetupUtility.getAgentUser();
        System.runAs(TestUserSetupUtility.getSysAdminUser()){  
        	SR_TestDataUtility.setupPNITestData(agentUser);
        	SR_Payload payload = SR_TestDataUtility.getPNIPayload(agentUser, SR_Constants.CASE_APP_CODE_AUTO_PVC, 'Auto');
            payloads.add(payload);
        }

        Test.startTest();
        System.runAs(soeDelegate){
           SR_Rest.handleRequest(payloads, true); 
        }
        
        Case newPolicyCase = [SELECT Id, Subject, Owner_User_External_Id__c, OwnerId, AccountId, Account.ClientIdentifier__c , ContactId, Contact.ClientIdentifier__c FROM Case WHERE Policy_Identifier__c =:SR_TestDataUtility.POLICY_ID];
        System.assertEquals(SR_TestDataUtility.PNI_PRIMARY_ACCOUNT_CLIENT_ID, newPolicyCase.Account.ClientIdentifier__c, 'Case Account field should return Primary PNI Client Identifier');
        System.assertEquals(SR_TestDataUtility.PNI_SECONDARY_ACCOUNT_CLIENT_ID, newPolicyCase.Contact.ClientIdentifier__c, 'Case Contact field should return Secondary PNI Client Identifier');
    	Test.stopTest();
    }

   	@isTest 
    private static void testNoMatchPayloadWithDefaultTaskAndLog() {
        User proxyUser = TestUserSetupUtility.getProxyUser();
        User proxyUser2 = TestUserSetupUtility.getSecondaryProxyUser();
        User soeDelegate = TestUserSetupUtility.getApiOnlyUser();
        Account acct = SR_TestDataUtility.getAccount();
        Account acct2 = SR_TestDataUtility.getSecondaryAccount();
        
        Test.startTest();

        List<SR_Payload> payloads = new List<SR_Payload>();
        
        SR_Payload tier4Payload = SR_TestDataUtility.getTier5Payload(acct.ClientIdentifier__c, proxyUser.UserExternalId__c,'Policy_Change');
        SR_Defaults defaults = new SR_Defaults();
        defaults.taskRecord = SR_TestDataUtility.buildDefaultTask();
        tier4Payload.defaults = defaults;
        
        SR_Payload tier4Payload2 = SR_TestDataUtility.getTier5Payload(acct2.ClientIdentifier__c, proxyUser2.UserExternalId__c,'Policy_Change');
        SR_Defaults defaults2 = new SR_Defaults();
        defaults2.logRecord = SR_TestDataUtility.buildDefaultTask();
        tier4Payload2.defaults = defaults2;

        payloads.add(tier4Payload);
        payloads.add(tier4Payload2);
        System.runAs(soeDelegate){
           SR_Rest.handleRequest(payloads, true);
           
        }
        
        List<Case> insertedCases = [SELECT Id, Owner_User_External_Id__c, OwnerId, AccountId FROM Case WHERE AccountId =: acct.Id];
        System.assertEquals(0, insertedCases.size(), 'Case should not have been created');
        List<Task> insertedLogs = [SELECT Id, OwnerId, AccountId FROM Task WHERE AccountId =: acct.Id];
        System.assertEquals(1, insertedLogs.size(), 'Default Task should have been created');
        System.assert(insertedLogs.get(0).OwnerId == proxyUser.Id, 'unexpected Task owner = ' + insertedLogs.get(0).OwnerId);
        System.assert(insertedLogs.get(0).AccountId == acct.Id, 'unexpected Task account id = ' + insertedLogs.get(0).AccountId);
        
        List<Case> insertedCases2 = [SELECT Id, Owner_User_External_Id__c, OwnerId, AccountId FROM Case WHERE AccountId =: acct2.Id];
        System.assertEquals(0, insertedCases2.size(), 'Case should not have been created');
        List<Task> insertedTasks2 = [SELECT Id, OwnerId, AccountId FROM Task WHERE AccountId =: acct2.Id and RecordTypeId =: TaskHandlerConstants.TASK_LOG_CALL_RECORD_TYPE_ID];
        System.assertEquals(1, insertedTasks2.size(), 'Default Task should have been created');
        System.assert(insertedTasks2.get(0).OwnerId == proxyUser2.Id, 'unexpected Task owner = ' + insertedTasks2.get(0).OwnerId);
        System.assert(insertedTasks2.get(0).AccountId == acct2.Id, 'unexpected Task account id = ' + insertedTasks2.get(0).AccountId);
        Test.stopTest();
    }

    @isTest 
    private static void testNoMatchPayloadWithDefaultCase() {
        User proxyUser = TestUserSetupUtility.getProxyUser();
        User proxyUser2;
        proxyUser2 = TestUserSetupUtility.getSecondaryProxyUser();
        User soeDelegate = TestUserSetupUtility.getApiOnlyUser();
        Account acct = SR_TestDataUtility.getAccount();
        Account acct2;
        acct2 = SR_TestDataUtility.getSecondaryAccount();
        
        Test.startTest();

        List<SR_Payload> payloads = new List<SR_Payload>();
        SR_Payload tier4Payload = SR_TestDataUtility.getTier5Payload(acct.ClientIdentifier__c, proxyUser.UserExternalId__c,'Policy_Change');
        SR_Defaults defaults = new SR_Defaults();
        defaults.caseRecord = SR_TestDataUtility.buildDefaultCase();
        tier4Payload.defaults = defaults;
        payloads.add(tier4Payload);

        System.runAs(soeDelegate){
           SR_Rest.handleRequest(payloads, true);
        }
        
        List<Case> insertedCases = [SELECT Id, Owner_User_External_Id__c, OwnerId, AccountId, ProductDescription__c, PolicyNumber__c FROM Case WHERE AccountId =: acct.Id];
        System.assertEquals(1, insertedCases.size(), 'One Case should have been created');
        System.assert(insertedCases.get(0).OwnerId == proxyUser.Id, 'unexpected case owner = ' + insertedCases.get(0).OwnerId);
        System.assert(insertedCases.get(0).AccountId == acct.Id, 'unexpected AccountId = ' + insertedCases.get(0).AccountId);
        System.assert(insertedCases.get(0).ProductDescription__c != null, 'Product Description should have been got from Default Case');
        System.assert(insertedCases.get(0).PolicyNumber__c != null, 'Policy Number should have been got from Default Case');

        Test.stopTest();
    }
    
    @isTest 
    private static void testSyncAllInvalid() {
        User proxyUser = TestUserSetupUtility.getProxyUser();
        User proxyUser2 = TestUserSetupUtility.getSecondaryProxyUser();
        User soeDelegate = TestUserSetupUtility.getApiOnlyUser();
        Account acct = SR_TestDataUtility.getAccount();
        Account acct2 = SR_TestDataUtility.getSecondaryAccount();
        String errorMessage ='';
        Test.startTest();

        SR_TestDataUtility.SR_TestDataUtilityWrapper param1 = new SR_TestDataUtility.SR_TestDataUtilityWrapper();
        param1.owner = proxyUser;
        param1.acct = acct;
        param1.tierLevel = 2;
        param1.recordTypeId = CaseHandlerConstants.CASE_RECORDTYPE_ID_POLICY_CHANGE;
        param1.hasTask = false;
        Case exisitingTier2Case;
        exisitingTier2Case = SR_TestDataUtility.createExistingCase(param1);

        List<SR_Payload> payloads = new List<SR_Payload>();
        SR_Payload tier2Payload = SR_TestDataUtility.getTier3Payload(acct.ClientIdentifier__c, proxyUser.UserExternalId__c,'Policy_Change');
        tier2Payload.matchParams.clientId = '';
        SR_Payload tier4Payload = SR_TestDataUtility.getTier5Payload(acct2.ClientIdentifier__c, proxyUser2.UserExternalId__c,'Policy_Change');
        tier4Payload.matchParams.ownerAssociateId = '';
        payloads.add(tier2Payload);
        payloads.add(tier4Payload);
        System.runAs(soeDelegate){
            try{
                SR_Rest.handleRequest(payloads, true); 
            }catch(SR_Exception ex){
                errorMessage = ex.getMessage();
            } 
        }
        List<Service_Request_Exception__c> exceptions = [SELECT Id, ErrorMessage__c, SObject_Type__c FROM Service_Request_Exception__c WHERE CreatedById =: soeDelegate.Id];
        System.assertEquals(2, exceptions.size(), 'exceptions were not created');
        Test.stopTest();
    }
    
    @isTest 
    private static void testSyncInvalidClientId() {
        User proxyUser = TestUserSetupUtility.getProxyUser();
        User soeDelegate = TestUserSetupUtility.getApiOnlyUser();
        Account acct = SR_TestDataUtility.getAccount();
        Test.startTest();
        List<SR_Payload> payloads = new List<SR_Payload>();
        SR_Payload tier2Payload = SR_TestDataUtility.getTier3Payload(acct.ClientIdentifier__c, proxyUser.UserExternalId__c,'Policy_Change');
        tier2Payload.matchParams.clientId = 'FAKE90DF000';
        payloads.add(tier2Payload);
        System.runAs(soeDelegate){
        	SR_Rest.handleRequest(payloads, true);
        }
        List<Service_Request_Exception__c> exceptions = [SELECT Id, ErrorMessage__c, SObject_Type__c FROM Service_Request_Exception__c WHERE CreatedById =: soeDelegate.Id];
        String exErrMessage = exceptions.get(0).ErrorMessage__c;
        System.assertEquals(1, exceptions.size(), 'Expected value is 1, but actual value is '+exceptions.size());
        System.assert(exErrMessage.startsWith('There were no Account found with the provided Client Ids'), 'Unexpected error message: ' + exErrMessage);
    }
    
    @isTest 
    private static void testException() {
        User soeDelegate = TestUserSetupUtility.getApiOnlyUser();
        String errorMessage ='';
        List<SR_Payload> payloads = new List<SR_Payload>();
        Test.startTest();
        System.runAs(soeDelegate){
            try{
                SR_Rest.handleRequest(payloads, true);
            }catch(SR_Exception ex){
                errorMessage = ex.getMessage();
            }
        }
        System.assert(Limits.getQueries() == 1, 'an unexpected number of Queries: Actual = ' + Limits.getQueries());
        Test.stopTest();
    }
}