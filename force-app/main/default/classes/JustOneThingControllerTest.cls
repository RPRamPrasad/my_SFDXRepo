@isTest(seeAllData=false)
private class JustOneThingControllerTest {

    @testSetup
    private static void testSetup() {
        TestUserSetupUtility.setupAgentOffice();
        TestUserSetupUtility.setupSystemAdminUser();
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=true);
            insert passTriggerAll;
        }
    }

    @isTest
    private static void testGetParentRecordDataForAccount() {
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            Account accountRecord = insertAccount();
            accountRecord = [SELECT Id, Name, PersonContactId, ClientIdentifier__c FROM Account WHERE ClientIdentifier__c =: accountRecord.ClientIdentifier__c];

            Test.startTest();
            Map<String, Object> data = (Map<String, Object>) JustOneThingController.getParentRecordData(accountRecord.Id).get('data');
            System.assertEquals(accountRecord.PersonContactId, data.get('WhoId'), 'ASSERT_FAILED: WhoId does not match expected value');
            System.assertEquals(sysAdminUser.Id, data.get('OwnerId'), 'ASSERT_FAILED: OwnerId does not match expected value');
            System.assertEquals(sysAdminUser.Id, data.get('AssignedTo__c'), 'ASSERT_FAILED: AssignedTo__c does not match expected value');
            System.assertEquals(accountRecord.Name, data.get('Name'), 'ASSERT_FAILED: Name does not match expected value');
            Test.stopTest();
        }
    }

    @isTest
    private static void testGetParentRecordDataForBillingAccount() {
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            Account accountRecord = insertAccount();
            accountRecord = [SELECT Id, Name, PersonContactId, ClientIdentifier__c FROM Account WHERE ClientIdentifier__c =: accountRecord.ClientIdentifier__c];
            User proxyUser = TestUserSetupUtility.getProxyUser();
            Billing_Account__c billingAccountRecord = insertBillingAccount(proxyUser);
            insertBillingParticipant(accountRecord, billingAccountRecord);

            Test.startTest();
            Map<String, Object> data = (Map<String, Object>) JustOneThingController.getParentRecordData(billingAccountRecord.Id).get('data');
            System.assertEquals(accountRecord.PersonContactId, data.get('WhoId'), 'ASSERT_FAILED: WhoId does not match expected value');
            System.assertEquals(sysAdminUser.Id, data.get('OwnerId'), 'ASSERT_FAILED: OwnerId does not match expected value');
            System.assertEquals(sysAdminUser.Id, data.get('AssignedTo__c'), 'ASSERT_FAILED: AssignedTo__c does not match expected value');
            System.assertEquals(accountRecord.Name, data.get('Name'), 'ASSERT_FAILED: Name does not match expected value');
            System.assertEquals(billingAccountRecord.Name, data.get('BillingAccountNumber'), 'ASSERT_FAILED: BillingAccountNumber does not match expected value');
            System.assertEquals(billingAccountRecord.SourceSystem__c, data.get('BillingAccountSourceSystem'), 'ASSERT_FAILED: BillingAccountSourceSystem does not match expected value');
            Test.stopTest();
        }
    }

    @isTest
    private static void testGetParentRecordDataForCase() {
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            Account accountRecord = insertAccount();
            accountRecord = [SELECT Id, Name, PersonContactId, ClientIdentifier__c FROM Account WHERE ClientIdentifier__c =: accountRecord.ClientIdentifier__c];
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
            agent = TestDataFactory_User.insertUser(agent);
            Case caseRecord = insertCase(accountRecord, agent);

            Test.startTest();
            Map<String, Object> data = (Map<String, Object>) JustOneThingController.getParentRecordData(caseRecord.Id).get('data');
            System.assertEquals(caseRecord.Account.PersonContactId, data.get('WhoId'), 'ASSERT_FAILED: WhoId does not match expected value');
            System.assertEquals(sysAdminUser.Id, data.get('OwnerId'), 'ASSERT_FAILED: OwnerId does not match expected value');
            System.assertEquals(sysAdminUser.Id, data.get('AssignedTo__c'), 'ASSERT_FAILED: AssignedTo__c does not match expected value');
            System.assertEquals(caseRecord.CaseNumber, data.get('CaseNumber'), 'ASSERT_FAILED: CaseNumber does not match expected value');
            System.assertEquals(caseRecord.OwnerId, data.get('CaseOwnerId'), 'ASSERT_FAILED: CaseOwnerId does not match expected value');
            System.assertEquals(accountRecord.Name, data.get('Name'), 'ASSERT_FAILED: Name does not match expected value');
            Test.stopTest();
        }
    }

    @isTest
    private static void testGetParentRecordDataForInsurancePolicy() {
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            Account accountRecord = insertAccount();
            accountRecord = [SELECT Id, Name, PersonContactId, ClientIdentifier__c FROM Account WHERE ClientIdentifier__c =: accountRecord.ClientIdentifier__c];
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
            agent = TestDataFactory_User.insertUser(agent);
            InsurancePolicy policyRecord = insertInsurancePolicy(accountRecord, agent);

            Test.startTest();

            Map<String, Object> data = (Map<String, Object>) JustOneThingController.getParentRecordData(policyRecord.Id).get('data');

            System.assertEquals(policyRecord.NameInsured.PersonContactId, data.get('WhoId'), 'ASSERT_FAILED: WhoId does not match expected value');
            System.assertEquals(sysAdminUser.Id, data.get('OwnerId'), 'ASSERT_FAILED: OwnerId does not match expected value');
            System.assertEquals(sysAdminUser.Id, data.get('AssignedTo__c'), 'ASSERT_FAILED: AssignedTo__c does not match expected value');
            System.assertEquals(policyRecord.AgreDisplayPartyName__c, data.get('PolicyPartyName'), 'ASSERT_FAILED: PolicyPartyName does not match expected value');
            System.assertEquals(policyRecord.PolicyDescription, data.get('PolicyDescription'), 'ASSERT_FAILED: PolicyDescription does not match expected value');
            System.assertEquals(policyRecord.OwnerId, data.get('PolicyOwnerId'), 'ASSERT_FAILED: PolicyOwnerId does not match expected value');

            Test.stopTest();
        }
    }

    @isTest
    private static void testGetParentRecordDataForClaim() {
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            Account accountRecord = insertAccount();
            accountRecord = [SELECT Id, Name, PersonContactId, ClientIdentifier__c FROM Account WHERE ClientIdentifier__c =: accountRecord.ClientIdentifier__c];
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
            agent = TestDataFactory_User.insertUser(agent);
            Claim claimRecord = insertClaim();

            Test.startTest();

            Map<String, Object> data = (Map<String, Object>) JustOneThingController.getParentRecordData(claimRecord.Id).get('data');

            System.assertEquals(claimRecord.Account.PersonContactId, data.get('WhoId'), 'ASSERT_FAILED: WhoId does not match expected value');
            System.assertEquals(sysAdminUser.Id, data.get('OwnerId'), 'ASSERT_FAILED: OwnerId does not match expected value');
            System.assertEquals(sysAdminUser.Id, data.get('AssignedTo__c'), 'ASSERT_FAILED: AssignedTo__c does not match expected value');
            System.assertEquals(claimRecord.ClaimDescription__c, data.get('ClaimDescription'), 'ASSERT_FAILED: ClaimDescription does not match expected value');
            System.assertEquals(claimRecord.OwnerId, data.get('OwnerId'), 'ASSERT_FAILED: ClaimOwnerId does not match expected value');

            Test.stopTest();
        }
    }

    @isTest
    private static void testGetParentRecordDataForOpp() {
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        System.runAs(sysAdminUser) {
            Account accountRecord = insertAccount();
            accountRecord = [SELECT Id, Name, PersonContactId, ClientIdentifier__c FROM Account WHERE ClientIdentifier__c =: accountRecord.ClientIdentifier__c];
            User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
            agent = TestDataFactory_User.insertUser(agent);
            Opportunity opportunityRecord = insertOpportunity(accountRecord, agent);

            Test.startTest();
            Map<String, Object> data = (Map<String, Object>) JustOneThingController.getParentRecordData(opportunityRecord.Id).get('data');
            System.assertEquals(opportunityRecord.Account.PersonContactId, data.get('WhoId'), 'ASSERT_FAILED: WhoId does not match expected value');
            System.assertEquals(sysAdminUser.Id, data.get('OwnerId'), 'ASSERT_FAILED: OwnerId does not match expected value');
            System.assertEquals(sysAdminUser.Id, data.get('AssignedTo__c'), 'ASSERT_FAILED: AssignedTo__c does not match expected value');
            System.assertEquals(opportunityRecord.LOB__c, data.get('LOB'), 'ASSERT_FAILED: WhoId does not match expected value');
            System.assertEquals(opportunityRecord.Account.Name, data.get('Name'), 'ASSERT_FAILED: Name does not match expected value');
            System.assertEquals(opportunityRecord.OwnerId, data.get('OppOwnerId'), 'ASSERT_FAILED: OppOwnerId does not match expected value');
            System.assertEquals(opportunityRecord.Assigned_To__c, data.get('OppAssignedTo'), 'ASSERT_FAILED: OppAssignedTo does not match expected value');
            Test.stopTest();
        }
    }

    @isTest
    private static void testGetParentRecordDataFailureWithNullObject() {
        User sysAdminUser = TestUserSetupUtility.getSysAdminUser();
        AuraHandledException error = null;

        System.runAs(sysAdminUser) {
            Test.startTest();

            try {
                JustOneThingController.getParentRecordData(null).get('data');
            } catch(AuraHandledException e) {
                error = e;
            }

            Test.stopTest();

            System.assert(error != null, 'ASSERT_FAILED: Expected error to not be null');
            System.assertEquals(error.getmessage(), 'Failed to retrieve parent record data', 'ASSERT_FAILED: Expected error message does not match expected value');
        }
    }

    @isTest
    private static void testGetStartEndDateTimes() {
        Test.startTest();
        Map<String, DateTime> result = JustOneThingController.getStartEndDateTimes();
        System.assert(result.containsKey('startDateTime'), 'ASSERT_FAILED: Result does not contain a start date time');
        System.assert(result.containsKey('endDateTime'), 'ASSERT_FAILED: Result does not contain an end date time');
        Test.stopTest();
    }

    private static Account insertAccount() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        Account accountRecord = new Account(FirstName = 'FirstName', LastName = 'LastName', BillingAddressType__c = 'US', ClientIdentifier__c = '12345678909', PersonEmail = 'TEST@EMAIL.COM');
        insert accountRecord;
        return accountRecord;
    }

    private static Billing_Account__c insertBillingAccount(User proxyUser) {
        Billing_Account__c billingAccountRecord = new Billing_Account__c(AccountNumber__c = '1234567890', Name = '1234567890', OwnerId = proxyUser.Id, SourceSystem__c = 'SFPP', SourceSystemIdentifier__c = '1234567890~01');
        insert billingAccountRecord;
        return billingAccountRecord;
    }

    private static void insertBillingParticipant(Account accountRecord, Billing_Account__c billingAccountRecord) {
        Billing_Participant__c billingParticipantRecord = new Billing_Participant__c(BillingAccountID__c = billingAccountRecord.Id, ParticipantAccountId__c = accountRecord.Id, SourceSystemIdentifier__c = '1234567890~01~ABCDEFGHI000');
        insert billingParticipantRecord;
    }

    private static Case insertCase(Account accountRecord, User agent) {
        Case caseRecord = new Case(AccountId = accountRecord.Id, Assigned_To__c = agent.Id, ContactId = accountRecord.PersonContactId, Description = 'Cases Received', Case_Originator__c = 'Agent Office');
        insert caseRecord;
        caseRecord = [SELECT Id, Assigned_To__c, Account.PersonContactId, Account.Name, CaseNumber, OwnerId FROM Case WHERE Id =: caseRecord.Id];
        return caseRecord;
    }

    private static InsurancePolicy insertInsurancePolicy(Account accountRecord, User agent) {
        InsurancePolicy policyRecord = new InsurancePolicy(NameInsured = accountRecord, NameInsuredId = accountRecord.Id, PolicyDescription = 'Test Policy Description', AgreDisplayPartyName__c = 'Test Party Name', OwnerId = agent.Id, Name='TestPolicyName');

        insert policyRecord;

        return [SELECT Id, NameInsured.PersonContactId, NameInsured.Name, PolicyDescription, AgreDisplayPartyName__c, OwnerId FROM InsurancePolicy WHERE Id =: policyRecord.Id];
    }

    private static Claim insertClaim() {
        Claim claimRecord = new Claim(ClaimType = 'Auto', ClaimDescription__c = 'Test Claim Description', Name='TestClaimOwner');

        insert claimRecord;

        return [SELECT Id, ClaimType, Name, ClaimName__c, ClaimDescription__c, Account.Name, Account.PersonContactId, OwnerId FROM Claim WHERE Id =: claimRecord.Id];
    }

    private static Opportunity insertOpportunity(Account accountRecord, User agent) {
        Opportunity opportunityRecord = new Opportunity(AccountId = accountRecord.Id, Assigned_To__c = agent.Id, LOB__c = 'A', Name = 'TEST OPPORTUNITY', StageName = 'Closed', CloseDate = Date.valueOf('2022-06-17'));
        insert opportunityRecord;
        opportunityRecord = [SELECT Id, Assigned_To__c, LOB__c, OwnerId, Account.Name, Account.PersonContactId FROM Opportunity WHERE Id =: opportunityRecord.Id];
        return opportunityRecord;
    }
}