@isTest
(seeAllData=false)
public class HHNUtilitiesTest {
    @testSetup
    private static void testSetup() {
        TestDataFactory_InsurancePolicy.createHouseholdWithPolicies();
    }

    @isTest
    private static void testGetAccountAndHouseholdId() {
        InsurancePolicy policy = [SELECT Id, NameInsuredId, FinServ__Household__c FROM InsurancePolicy].get(0);
        Account account = [SELECT Id, Primary_Household__pc, PersonContactId FROM Account WHERE Id =: policy.NameInsuredId];
        User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
        agent = TestDataFactory_User.insertUser(agent);
        Opportunity opportunityRecord = HHNOpportunityControllerTest.insertOpportunity(account, agent, policy);
        Case caseRecord = HHNCaseControllerTest.insertCase(account, agent, policy);
        Claim claimRecord = HHNClaimControllerTest.insertClaim(account, agent, policy);
        HHNBillingControllerTest.insertBillingAccounts(account, agent, policy);
        Billing_Account__c billingAccount = [SELECT Id FROM Billing_Account__c].get(0);
        Billing_Participant__c billingParticipant = [SELECT Id, Primary_Household__c FROM Billing_Participant__c WHERE BillingAccountID__c =: billingAccount.Id].get(0);

        Test.startTest();
        List<String> opportunityResults = HHNUtilities.getAccountAndHouseholdId(opportunityRecord.Id, 'Opportunity');
        List<String> caseResults = HHNUtilities.getAccountAndHouseholdId(caseRecord.Id, 'Case');
        List<String> accountResults = HHNUtilities.getAccountAndHouseholdId(account.Id, 'Account');
        List<String> billingAccountResults = HHNUtilities.getAccountAndHouseholdId(billingAccount.Id, 'Billing_Account__c');
        List<String> claimResults = HHNUtilities.getAccountAndHouseholdId(claimRecord.Id, 'Claim');
        List<String> insurancePolicyResults = HHNUtilities.getAccountAndHouseholdId(policy.Id, 'InsurancePolicy');
        System.assertEquals(new List<String>{account.Id, opportunityRecord.FinServ__Household__c}, opportunityResults, 'Expected account and household id to equal values for opportunity.');
        System.assertEquals(new List<String>{account.Id, caseRecord.FinServ__Household__c}, caseResults, 'Expected account and household id to equal values for case.');
        System.assertEquals(new List<String>{account.Id, account.Primary_Household__pc}, accountResults, 'Expected account and household id to equal values for account.');
        System.assertEquals(new List<String>{account.Id, billingParticipant.Primary_Household__c}, billingAccountResults, 'Expected account and household id to equal values for billing account.');
        System.assertEquals(new List<String>{account.Id, claimRecord.FinServ__Household__c}, claimResults, 'Expected account and household id to equal values for claim.');
        System.assertEquals(new List<String>{account.Id, policy.FinServ__Household__c}, insurancePolicyResults, 'Expected account and household id to equal values for insurance policy.');
        Test.stopTest();
    }

    @isTest
    private static void testErrorGetAccountIdFromEmail() {
        insertAccount();
        Test.startTest();
        try{
            Id testId = HHNUtilities.getAccountIdFromEmail('BadTEST@EMAIL.COM');
        }catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Expected exception to match.');
        }
        Test.stopTest();
    }

    @isTest
    private static void testValidGetAccountIdFromEmail() {
        insertAccount();
        Account account = [SELECT Id FROM Account WHERE personEmail = 'TEST@EMAIL.COM'];
        Test.startTest();
        Id testId = HHNUtilities.getAccountIdFromEmail('TEST@EMAIL.COM');
        System.assertEquals(String.valueOf(testId), String.valueOf(account.Id), 'Expected accountId to be found.');
        Test.stopTest();
    }

    @isTest
    private static void testErrorGetAccountsFromEmails() {
        insertAccounts();

        Test.startTest();

        try {
            HHNUtilities.getAccountsFromEmails(null);
        } catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Expected exception to match.');
        }
        Test.stopTest();
    }

    @isTest
    private static void testValidGetAccountsFromEmails() {
        insertAccounts();
        List<String> emails = new List<String>{'TEST1@EMAIL.COM','TEST2@EMAIL.COM','TEST3@EMAIL.COM'};

        Test.startTest();

        List<Account> accountsResult = HHNUtilities.getAccountsFromEmails(emails);
        System.assertEquals(accountsResult.size(), emails.size(), 'Expected accounts to be found.');

        Test.stopTest();
    }

    /**
     *  @description Inserts accounts for test.
     *  @return Accounts
     */
    public static List<Account> insertAccounts() {
        Account account1 = new Account(FirstName = 'FirstName', LastName = 'LastName', BillingAddressType__c = 'US', ClientIdentifier__c = '12345678909', PersonEmail = 'TEST1@EMAIL.COM');
        Account account2 = new Account(FirstName = 'FirstName', LastName = 'LastName', BillingAddressType__c = 'US', ClientIdentifier__c = '12345678908', PersonEmail = 'TEST2@EMAIL.COM');
        Account account3 = new Account(FirstName = 'FirstName', LastName = 'LastName', BillingAddressType__c = 'US', ClientIdentifier__c = '12345678907', PersonEmail = 'TEST3@EMAIL.COM');

        insert account1;
        insert account2;
        insert account3;

        return new List<Account>{account1, account2, account3};
    }

    /**
     *  @description Inserts account for test.
     *  @return Account
     */
    public static Account insertAccount() {
        Account account = new Account(FirstName = 'FirstName', LastName = 'LastName', BillingAddressType__c = 'US', ClientIdentifier__c = '12345678909', PersonEmail = 'TEST@EMAIL.COM');
        insert account;
        return account;
    }

    /**
     *  @description Inserts household account for test.
     *  @return Account
     */
    public static Account insertHousehold() {
       Id hhRecordtype = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName()
           .get('IndustriesHousehold')
           .getRecordTypeId();
       Account household = new Account(Name = 'Household', recordTypeId = hhRecordtype, AllowHousehold__c = true);
       insert household;
       return household;
    }

    /**
     *  @description Inserts account note for test.
     *  @param accountId - The record id of the Account to attach to.
     */
    public static void insertAccountNoteRecord(Id accountId) {
        Account_Note__c accountNoteRecord = new Account_Note__c();
        accountNoteRecord.Account__c = accountId;
        accountNoteRecord.Comments__c = 'Mock Account Note Comments';
        insert accountNoteRecord;
    }

    /**
     *  @description Inserts case note for test.
     *  @param caseId - The record id of the Case to attach to.
     */
    public static void insertCaseNoteRecord(Id caseId) {
        Case_Note__c caseNoteRecord = new Case_Note__c();
        caseNoteRecord.Case__c = caseId;
        caseNoteRecord.Comments__c = 'Mock Case Note Comments';
        insert caseNoteRecord;
    }

    /**
     *  @description Inserts event for test.
     *  @param whatId - The id of the object record this Event should be related to (Related To Field).
     *  @param whoId - The id of Contact/Lead record this Event should be related to (Name Field).
     *  @param ownerId - The id of the user record who owns this Event.
     */
    public static void insertEventRecord(Id whatId, Id whoId, Id ownerId) {
        Event eventRecord = new Event();
        eventRecord.WhoId = whoId;
        eventRecord.Subject = 'Mock Subject';
        eventRecord.IsAllDayEvent = true;
        eventRecord.ActivityDate = Date.today();
        eventRecord.WhatId = whatId;
        eventRecord.description = 'Mock Event Description';
        eventRecord.OwnerId = ownerId;
       	insert eventRecord;
    }

    /**
     *  @description Inserts interaction summary for test.
     *  @param accountId - The id of the Account record to attach to.
     */
    public static void insertInteractionSummaryRecord(Id accountId) {
        InteractionSummary__c intRecord = new InteractionSummary__c();
        intRecord.Customer__c = accountId;
        intRecord.display_end_timestamp__c = Date.valueOf('2021-10-06 15:12:50');
        intRecord.enterprise_interaction_identifier__c = 'SF Connect';
        intRecord.display_start_timestamp__c = Date.valueOf('2021-10-06 15:12:53');
        insert intRecord;
    }

    /**
     *  @description Inserts opportunity note for test.
     *  @param opportunityId - The id of the Opportunity record to attach to.
     */
    public static void insertOpportunityNoteRecord(Id opportunityId) {
        Opportunity_Note__c opportunityNoteRecord = new Opportunity_Note__c();
        opportunityNoteRecord.Opportunity__c = opportunityId;
        opportunityNoteRecord.Comments__c = 'Mock Opportunity Note Comments';
        insert opportunityNoteRecord;
    }

    /**
     *  @description Inserts task for test.
     *  @param whatId - The id of the object record this Task should be related to (Related To Field).
     *  @param whoId - The id of Contact/Lead record this Task should be related to (Name Field).
     *  @param ownerId - The id of the user record who owns this Task.
     */
    public static void insertTaskRecord(Id whatId, Id whoId, Id ownerId) {
        Task taskRecord = new Task();
        taskRecord.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Task').getRecordTypeId();
        taskRecord.Status = 'Not Started';
        taskRecord.WhoId = whoId;
        taskRecord.Subject = 'Mock Subject';
        taskRecord.WhatId = whatId;
        taskRecord.description = 'Mock Description';
        taskRecord.OwnerId = ownerId;
        insert taskRecord;
    }

    /**
     *  @description Inserts a recurring task for test.
     *  @param whatId - The id of the object record this Task should be related to (Related To Field).
     *  @param whoId - The id of Contact/Lead record this Task should be related to (Name Field).
     *  @param ownerId - The id of the user record who owns this Task.
     */
    public static void insertRecurringTaskRecord(Id whatId, Id whoId, Id ownerId) {
        Task taskRecord = new Task();

        Date startTime = Date.today();
        Date endTime = startTime;

        taskRecord.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Task').getRecordTypeId();
        taskRecord.Status = 'Not Started';
        taskRecord.WhoId = whoId;
        taskRecord.Subject = 'Mock Recurring Subject';
        taskRecord.WhatId = whatId;
        taskRecord.OwnerId = ownerId;
        taskRecord.IsRecurrence = true;
        taskRecord.RecurrenceStartDateOnly = startTime;
        taskRecord.RecurrenceEndDateOnly = endTime;
        taskRecord.RecurrenceType = 'RecursDaily';
        taskRecord.RecurrenceInterval = 1;

        insert taskRecord;
    }

    /**
     *  @description Inserts virtual meeting and virtual meeting participants for test.
     *  @param accountId - The Account Id of the Virtual Meeting participant
     */
    public static void insertVirtualMeetingRecord(Id accountId) {
        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=true);
        insert passTriggerAll;

        DateTime startTime = (Date.today()).addDays(5);
        DateTime endTime = startTime.addHours(2);
        Virtual_Meeting__c virtualMeeting = new Virtual_Meeting__c();
        virtualMeeting.Status__c = 'Not Started';
        virtualMeeting.Start_Time__c = startTime;
        virtualMeeting.End_Time__c = endTime;
        virtualMeeting.IsCancelled__c = false;
        insert virtualMeeting;

        Virtual_Meeting_Participant__c virtualMeetingParticipant = new Virtual_Meeting_Participant__c();
        virtualMeetingParticipant.Virtual_Meeting__c = virtualMeeting.Id;
        virtualMeetingParticipant.Account__c = accountId;
        insert virtualMeetingParticipant;
    }
}