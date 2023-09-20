/**
 * @description Used to generate data for CCV - All Objects
 * Account, Case, Opportunity, InsurancePolicy, BillingAccount, claim
 * FinancialAccount, SimpleConversation
 * @Date 12/24/2022
 * @author Team Altas
 */

@isTest
public with sharing class CCV_TestDataFactoryAllObjects {
    private static final String HOUSEHOLD_RECORD_TYPE = 'IndustriesHousehold';
    public static final String ACCOUNT_ONE_CLIENT_ID = 'ATLSP81000X';
    public static final String ACCOUNT_ONE_FIRST_NAME = 'IND FNAME ONE';
    public static final String ACCOUNT_ONE_LAST_NAME = 'AccountOne';

    public static final String ACCOUNT_TWO_CLIENT_ID = 'ATLSP82000Y';
    public static final String ACCOUNT_TWO_FIRST_NAME = 'IND FNAME TWO';
    public static final String ACCOUNT_TWO_LAST_NAME = 'AccountTWO';

    public static final String POLICY_PRIVATE_PASSENGER_SRC_SYS_ID = 'ATLSAUTOPP1';

    /**
     *  @description Inserts account with a household for test.
     *  @return List<Account>
     */
    public static List<Account> insertAccountWithHousehold() {
        User systemUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('Alias', 'SystemSA', 'systemUser@statefarm.com');
        insert systemUser;
        List<Account> accountList = new List<Account>();
        System.runAs(systemUser) {
            CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c = true);
            insert passTriggerAll;
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();

            // Get household record type
            Id householdRTId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName()
                .get(HOUSEHOLD_RECORD_TYPE)
                .getRecordTypeId();

            // Create Accounts
            Account household = new Account(Name = 'Household', RecordTypeId = householdRTId, AllowHousehold__c = true);

            insert household;

            Account account1 = new Account(
                FirstName = ACCOUNT_ONE_FIRST_NAME,
                LastName = ACCOUNT_ONE_LAST_NAME,
                ClientIdentifier__c = ACCOUNT_ONE_CLIENT_ID,
                Primary_Household__pc = household.Id
            );
            insert account1;
            accountList.add(account1);
            insertAccountNoteRecord(account1.Id);

            Contact contact1 = [SELECT id FROM Contact WHERE AccountId = :account1.Id];

            Account account2 = new Account(
                FirstName = ACCOUNT_TWO_FIRST_NAME,
                LastName = ACCOUNT_TWO_LAST_NAME,
                ClientIdentifier__c = ACCOUNT_TWO_CLIENT_ID,
                Primary_Household__pc = household.Id
            );
            insert account2;
            accountList.add(account2);
            insertAccountNoteRecord(account2.Id);

            Contact contact2 = [SELECT id FROM Contact WHERE AccountId = :account2.Id];

            // Create ACRs for Household Rollup
            List<AccountContactRelation> acctContactRels = new List<AccountContactRelation>{
                new AccountContactRelation(
                    AccountId = household.Id,
                    ContactId = contact1.Id,
                    FinServ__PrimaryGroup__c = true,
                    FinServ__Primary__c = true,
                    FinServ__RollUps__c = 'All'
                ),
                new AccountContactRelation(
                    AccountId = household.Id,
                    ContactId = contact2.Id,
                    FinServ__PrimaryGroup__c = true,
                    FinServ__RollUps__c = 'All'
                )
            };

            insert acctContactRels;
        }

        return accountList;
    }
    /**
     *  @description Insert insurance policy for test.
     *  @param account
     *  @param agent
     *  @return InsurancePolicy
     */
    public static InsurancePolicy insertInsurancePolicy(Account account, User agent) {
        User syncUser = UTIL_UserProvisioning_TEST.buildUserWith103APIProfile();
        insert syncUser;
        PermissionSet psFSC = [SELECT Id, Name FROM PermissionSet WHERE Name = 'FSCInsurance'];
        PermissionSet psSync = [SELECT Id, Name FROM PermissionSet WHERE Name = 'SF_CRM_FSCPolicySync1_PermSet'];
        List<PermissionSetAssignment> psAssignments = new List<PermissionSetAssignment>{
            new PermissionSetAssignment(AssigneeId = syncUser.Id, PermissionSetId = psFSC.Id),
            new PermissionSetAssignment(AssigneeId = syncUser.Id, PermissionSetId = psSync.Id)
        };
        insert psAssignments;
        InsurancePolicy ip = new InsurancePolicy(
            PolicyName = 'PRIVATE PASSENGER',
            Name = 'G06KRKN-A28-13M',
            SourceSystemIdentifier = POLICY_PRIVATE_PASSENGER_SRC_SYS_ID,
            PolicyType = 'Auto',
            NameInsuredId = account.Id,
            Status = 'Terminated'
        );

        ip.CancellationDate = DateTime.valueOf('2016-06-28 12:00:00.000Z');
        ip.EffectiveDate = DateTime.valueOf('1997-01-27 12:00:00.000Z');
        ip.RenewalDate = DateTime.valueOf('2017-01-27 12:00:00.000Z');

        if (account.Primary_Household__pc != null) {
            ip.FinServ__Household__c = account.Primary_Household__pc;
        }
        ip.ProdLineCd__c = 'A';
        System.runAs(syncUser) {
            insert ip;
        }
        return ip;
    }
    /**
     *  @description Inserts case and related activities for test.
     *  @param account
     *  @param agent
     *  @param policy
     *  @return Case
     */
    public static Case insertCase(Account account, User agent, InsurancePolicy policy) {
        Case caseRecord = new Case();
        caseRecord.AccountId = account.Id;
        caseRecord.ContactId = account.PersonContactId;
        caseRecord.FinServ__Household__c = account.Primary_Household__pc;

        if (policy != null) {
            caseRecord.Insurance_Policy__c = policy.Id;
            caseRecord.SourceId = policy.Id;
        }

        if (account.Primary_Household__pc != null) {
            caseRecord.FinServ__Household__c = account.Primary_Household__pc;
        }
        insert caseRecord;

        insertTaskRecord(caseRecord.Id, account.PersonContactId, agent.Id);
        insertCaseNoteRecord(caseRecord.Id);

        return caseRecord;
    }

    /**
     *  @description Inserts opportunity and related activities for test.
     *  @param account
     *  @param agent
     *  @return Opportunity
     */
    public static Opportunity insertOpportunity(Account account, User agent) {
        Opportunity oppRecord = new Opportunity();
        oppRecord.AccountId = account.Id;
        oppRecord.LOB__c = 'A';
        oppRecord.Name = 'TEST OPPORTUNITY';
        oppRecord.StageName = 'Closed';
        oppRecord.CloseDate = Date.valueOf('2022-06-17');

        if (account.Primary_Household__pc != null) {
            oppRecord.FinServ__Household__c = account.Primary_Household__pc;
        }
        insert oppRecord;

        insertTaskRecord(oppRecord.Id, account.PersonContactId, agent.Id);
        insertOpportunityNoteRecord(oppRecord.Id);

        return oppRecord;
    }

    /**
     *  @description Inserts billing accounts, billing participants, and related activities for test.
     *  @param account
     *  @param agent
     *  @param policy
     *  @return Billing_Account__c
     */
    public static Billing_Account__c insertBillingAccounts(Account account, User agent, InsurancePolicy policy) {
        Billing_Account__c billingAccountRecord = new Billing_Account__c(
            AccountNumber__c = '1234567890',
            SourceSystem__c = 'NONE',
            SourceSystemIdentifier__c = '1234567890~01'
        );
        insert billingAccountRecord;

        Billing_Participant__c billingParticipant = new Billing_Participant__c(
            BillingAccountID__c = billingAccountRecord.Id,
            ParticipantAccountId__c = account.Id,
            SourceSystemIdentifier__c = '1234567890~01~ABCDEFGHI000'
        );

        if (account.Primary_Household__pc != null) {
            billingParticipant.Primary_Household__c = account.Primary_Household__pc;
        }
        insert billingParticipant;

        insertTaskRecord(billingAccountRecord.Id, account.PersonContactId, agent.Id);

        return billingAccountRecord;
    }

    /**
     *  @description Insert claim and related activities for test.
     *  @param account
     *  @param agent
     *  @param policy
     *  @return Claim
     */
    public static Claim insertClaim(Account account, User agent, InsurancePolicy policy) {
        Claim claimRecord = new Claim();
        claimRecord.AccountId = account.Id;
        claimRecord.Name = 'TEST CLAIM';

        if (policy != null) {
            claimRecord.PolicyNumberId = policy.Id;
        }

        if (account.Primary_Household__pc != null) {
            claimRecord.FinServ__Household__c = account.Primary_Household__pc;
        }
        insert claimRecord;

        insertTaskRecord(claimRecord.Id, account.PersonContactId, agent.Id);

        return claimRecord;
    }

    /**
     *  @description Insert financial account for test.
     *  @param acct
     *  @return FinancialAccount__c
     */
    public static FinancialAccount__c insertFinancialAccount(Account acct) {
        FinancialAccount__c faRecord = new FinancialAccount__c(
            Name = 'First Last',
            ProdDescText__c = 'Checking',
            ProdLineCd__c = 'B',
            AgreeStatusText__c = 'In Force',
            AgreInceptionDate__c = Date.newInstance(2014, 8, 13),
            AgreEndDate__c = Date.newInstance(2015, 12, 31),
            AgreDisplayPartyName__c = 'Party Name 1',
            SourceSystemIdentifier__c = 'FA00000001'
        );
        insert faRecord;

        FinancialAccountRole__c faRole = new FinancialAccountRole__c(
            FinancialAccountId__c = faRecord.Id,
            SourceSystemIdentifier__c = faRecord.SourceSystemIdentifier__c + '~' + acct.ClientIdentifier__c + '~22',
            AccountId__c = acct.Id,
            RoleName__c = 'Owner',
            RoleNameCd__c = '22'
        );
        insert faRole;

        return faRecord;
    }

    /**
     *  @description Insert account note for test.
     *  @param accountId
     */
    private static void insertAccountNoteRecord(Id accountId) {
        Account_Note__c accountNoteRecord = new Account_Note__c();
        accountNoteRecord.Account__c = accountId;
        accountNoteRecord.Comments__c = 'Mock Account Note Comments';
        accountNoteRecord.Alert__c = true;
        insert accountNoteRecord;
    }

    /**
     *  @description Insert case note for test.
     *  @param caseId
     */
    private static void insertCaseNoteRecord(Id caseId) {
        Case_Note__c caseNoteRecord = new Case_Note__c();
        caseNoteRecord.Case__c = caseId;
        caseNoteRecord.Comments__c = 'Mock Case Note Comments';
        caseNoteRecord.Alert__c = true;
        insert caseNoteRecord;
    }

    /**
     *  @description Insert opportunity note for test.
     *  @param opportunityId
     */
    private static void insertOpportunityNoteRecord(Id opportunityId) {
        Opportunity_Note__c opportunityNoteRecord = new Opportunity_Note__c();
        opportunityNoteRecord.Opportunity__c = opportunityId;
        opportunityNoteRecord.Comments__c = 'Mock Opportunity Note Comments';
        opportunityNoteRecord.Alert__c = true;
        insert opportunityNoteRecord;
    }

    /**
     *  @description Insert task for test.
     * @param whatId
     * @param whoId
     * @param ownerId
     */
    private static void insertTaskRecord(Id whatId, Id whoId, Id ownerId) {
        Task taskRecord = new Task();
        taskRecord.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
            .get('Task')
            .getRecordTypeId();
        taskRecord.Status = 'Not Started';
        taskRecord.WhoId = whoId;
        taskRecord.Subject = 'Mock Subject';
        taskRecord.WhatId = whatId;
        taskRecord.description = 'Mock Description';
        taskRecord.OwnerId = ownerId;
        taskRecord.Alert__c = true;
        insert taskRecord;
    }
}
