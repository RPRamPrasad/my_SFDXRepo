/**
* Author : Team Astro
* Date Created : 06/01/2022
* @description : Constants used for queries in AO 2.0
* Version : 1.0
*/
public with sharing class HHNConstants {
    public static final String ACCOUNT_FIELDS = 'SELECT Id, Name, CreatedDate, LastModifiedDate, LastModifiedBy.Name ';
    public static final String ACCOUNT_FROM_OBJECT = 'FROM Account ';

    public static final String ACCOUNT_NOTE_FIELDS = ' SELECT Id, CreatedDate, LastModifiedDate, LastModifiedBy.Name, Name, Account__c, Account__r.Name, Comments__c ';
    public static final String ACCOUNT_NOTE_FROM_REF_OBJECT = ' FROM Account_Notes__r ';

    public static final String ACCOUNT_ID_WHERE = ' WHERE AccountId =: accountId ';
    public static final String ACCOUNT_WHERE = ' WHERE Id =: accountId ';

    public static final String BILLING_ACCOUNT_FIELDS = 'SELECT Id, LastModifiedDate, LastModifiedBy.Name, CreatedDate,  Status__c, Name, SourceSystem__c  ';
    public static final String BILLING_ACCOUNT_FROM_OBJECT = ' FROM Billing_Account__c';
    public static final String BILLING_ACCOUNT_WHERE = ' WHERE Id IN (SELECT BillingAccountID__c FROM Billing_Participant__c WHERE ParticipantAccountId__c =: accountId)';
    public static final String BILLING_HOUSEHOLD_WHERE = ' WHERE Id IN (SELECT BillingAccountID__c FROM Billing_Participant__c WHERE Primary_Household__c =: householdId)';

    public static final String CASE_FIELDS = 'SELECT Id, AccountId, Account.Name, Subject, Status, Description, CaseNumber, Follow_up_Date__c, CreatedDate, LastModifiedDate, LastModifiedBy.Name, Assigned_To__r.Name, isClosed ';
    public static final String CASE_FROM_OBJECT = ' FROM Case ';

    public static final String CASE_NOTE_FIELDS = ' SELECT Id, CreatedDate, LastModifiedDate, LastModifiedBy.Name, Name, Alert__c, Case__r.AccountId, Comments__c ';
    public static final String CASE_NOTE_FROM_REF_OBJECT = ' FROM Case_Notes__r ';

    public static final String CLAIM_FIELDS = 'SELECT Id, Name, AccountId, Account.Name, CreatedDate, LastModifiedDate, LastModifiedBy.Name, Status, Summary, ClaimDescription__c, Owner.Name, isClosed ';
    public static final String CLAIM_FROM_OBJECT = ' FROM Claim';

    public static final String EVENT_ACCOUNT_WHERE = ' WHERE Id IN (SELECT EventId FROM EventRelation WHERE AccountId =: parentRecordId OR Event.WhoId =: parentRecordId OR Event.What.Id =: parentRecordId) ';
    public static final String EVENT_FIELDS = ' SELECT Id, AccountId, CreatedDate, LastModifiedDate, LastModifiedBy.Name,  AssignedTo__r.Name, Subject, LineofBusiness__c, WhoId, Who.Name, What.Id, What.Name, Description, StartDateTime, IsAllDayEvent, ActivityDate ';
    public static final String EVENT_FROM_OBJECT = ' FROM Event ';
    public static final String EVENT_FROM_REF_OBJECT = ' FROM Events ';
    public static final String EVENT_HOUSEHOLD_WHERE = ' WHERE Id IN (SELECT EventId FROM EventRelation WHERE Account.Primary_Household__pc =: householdId) ';
    public static final String EVENT_RELATION_FIELDS = ' SELECT EventId, AccountId, Account.Name ';
    public static final String EVENT_RELATION_FROM_OBJECT = ' FROM EventRelations ';

    public static final String FINANCIAL_ACCOUNT_ROLE_FIELDS = 'SELECT Id,FinancialAccountId__c,FinancialAccountId__r.Name,FinancialAccountId__r.ProdDescText__c,FinancialAccountId__r.ProdLineCd__c,FinancialAccountId__r.AgreeStatusText__c,FinancialAccountId__r.AgreInceptionDate__c,FinancialAccountId__r.AgreEndDate__c,FinancialAccountId__r.AgreDisplayPartyName__c,FinancialAccountId__r.SourceSystemIdentifier__c,FinancialAccountId__r.ServicingAgent__r.Name,FinancialAccountId__r.ServicingAgent__r.Associate_ID__c';
    public static final String FINANCIAL_ACCOUNT_ROLE_FROM_OBJECT = ' FROM FinancialAccountRole__c ';
    public static final String FINANCIAL_ACCOUNT_ROLE_WHERE = ' WHERE AccountId__c = :accountId';
    public static final String FINANCIAL_ACCOUNT_ROLE_HOUSEHOLD_WHERE = ' WHERE AccountId__r.primary_household__pc = :accountId';

    public static final String FINANCIAL_ACCOUNT_FIELDS = 'SELECT Id, FinServ__Description__c, FinServ__Status__c, CreatedDate, LastModifiedDate, LastModifiedById, Name, FinServ__FinancialAccountType__c';
    public static final String FINANCIAL_ACCOUNT_FROM_OBJECT = ' FROM FinServ__FinancialAccount__c ';
    public static final String FINANCIAL_ACCOUNT_WHERE = ' WHERE FinServ__PrimaryOwner__c = :accountId';

    public static final String FINSERV_HOUSEHOLD_WHERE = ' WHERE FinServ__Household__c =: householdId ';

    public static final String INSURANCE_POLICY_FIELDS = 'SELECT Id, AgreDisplayPartyName__c, PolicyType, PolicyName, Name, CreatedDate, LastModifiedDate, LastModifiedBy.Name, NameInsuredId, Status, PolicyDescription, Owner.Name, IsActive';
    public static final String INSURANCE_POLICY_FROM_OBJECT = ' FROM InsurancePolicy';

    public static final String INTERACTIONS_FIELDS = ' Select Id, createdDate, Customer__c, name, contact_method_name__c, display_start_timestamp__c, display_end_timestamp__c, enterprise_interaction_identifier__c,  LastModifiedDate, LastModifiedBy.Name ';
    public static final String INTERACTIONS_FROM_REF_OBJECT = ' FROM InteractionSummarys__r ';

    public static final String NAMED_INSURED_WHERE = ' WHERE NameInsuredId =: accountId';

    public static final String ORDER_BY_ACCOUNT_ID = ' ORDER BY AccountId ';

    public static final String OPPORTUNITY_FIELDS = 'SELECT Id, AccountId, Account.Name, Name, Assigned_To__r.Name, StageName, Status__c, Total_Calls_Made__c, Monthly_Premium__c, CreatedDate, LastModifiedDate, LastModifiedBy.Name, isClosed ';
    public static final String OPPORTUNITY_FROM_OBJECT = ' FROM Opportunity ';

    public static final String OPPORTUNITY_NOTE_FIELDS = ' SELECT Id, CreatedDate, LastModifiedDate, LastModifiedBy.Name, Name, Alert__c, Opportunity__r.AccountId, Comments__c ';
    public static final String OPPORTUNITY_NOTE_FROM_REF_OBJECT = ' FROM Opportunity_Notes__r ';

    public static final String PRIMARY_HOUSEHOLD_WHERE = ' WHERE Primary_Household__pc =: householdId ';

    public static final String TASK_ACCOUNT_WHERE = ' WHERE Id IN (SELECT TaskId FROM TaskRelation WHERE AccountId =: parentRecordId OR Task.WhoId =: parentRecordId OR Task.What.Id =: parentRecordId) AND IsRecurrence = false';
    public static final String TASK_FIELDS = ' SELECT Id, AccountId, CreatedDate, RecordTypeId, LastModifiedDate, LastModifiedBy.Name, AssignedTo__r.Name, Subject, Status, LineofBusiness__c, WhoId, Who.Name, What.Id, What.Name, Description, IsHighPriority, ActivityDate, isClosed, CompletedDateTime, TaskSubtype, CreatedById';
    public static final String TASK_FROM_OBJECT = ' FROM Task ';
    public static final String TASK_FROM_REF_OBJECT = ' FROM Tasks ';
    public static final String TASK_WHERE = ' WHERE IsRecurrence = false ';
    public static final String TASK_HOUSEHOLD_WHERE = ' WHERE Id IN (SELECT TaskId FROM TaskRelation WHERE Account.Primary_Household__pc =: householdId) AND IsRecurrence = false';
    public static final String TASK_LOG_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Log_Call').getRecordTypeId();
    public static final String TASK_RELATION_FIELDS = ' SELECT TaskId, AccountId, Account.Name ';
    public static final String TASK_RELATION_FROM_OBJECT = ' FROM TaskRelations ';

    public static final String VIRTUAL_MEETING_P_FIELDS = ' SELECT Id, Virtual_Meeting__r.Id, Virtual_Meeting__r.AccountId__c, Virtual_Meeting__r.Assigned_To__r.Name, Virtual_Meeting__r.CreatedDate, Virtual_Meeting__r.LastModifiedDate, '+
        													'Virtual_Meeting__r.LastModifiedBy.Name, Virtual_Meeting__r.Name, Virtual_Meeting__r.Start_Time__c, Virtual_Meeting__r.End_Time__c, Virtual_Meeting__r.Status__c ';
    public static final String VIRTUAL_MEETING_P_FROM_REF_OBJECT = ' FROM Virtual_Meeting_Participants__r  ';
}
