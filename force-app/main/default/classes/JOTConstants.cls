/**
* Author : Team Astro
* Date Created : 07/19/2023
* @description : Constants used for queries in JOT
* Version : 1.0
*/
public with sharing class JOTConstants {
    public static final String ACCOUNT_FIELDS = 'SELECT Id, Name ';
    public static final String ACCOUNT_FROM_OBJECT = 'FROM Account';

    public static final String ACCOUNT_ID_WHERE = ' WHERE AccountId =: accountId ';
    public static final String ACCOUNT_WHERE = ' WHERE Id =: accountId ';
    
    public static final String BILLING_ACCOUNT_FIELDS = 'SELECT Id, Status__c, Name, SourceSystem__c';
    public static final String BILLING_ACCOUNT_FROM_OBJECT = ' FROM Billing_Account__c';
    public static final String BILLING_ACCOUNT_WHERE = ' WHERE Id IN (SELECT BillingAccountID__c FROM Billing_Participant__c WHERE ParticipantAccountId__c =: accountId)';
    public static final String BILLING_HOUSEHOLD_WHERE = ' WHERE Id IN (SELECT BillingAccountID__c FROM Billing_Participant__c WHERE Primary_Household__c =: householdId)';
    
    public static final String CASE_FIELDS = 'SELECT Id, Subject, Status, CaseNumber, isClosed ';
    public static final String CASE_FROM_OBJECT = ' FROM Case ';

    public static final String CLAIM_FIELDS = 'SELECT Id, Name, AccountId, Account.Name, CreatedDate, LastModifiedDate, LastModifiedBy.Name, Status, Summary, ClaimDescription__c, Owner.Name, isClosed ';
    public static final String CLAIM_FROM_OBJECT = ' FROM Claim';

    public static final String FINANCIAL_ACCOUNT_ROLE_FIELDS = 'SELECT Id,FinancialAccountId__c,FinancialAccountId__r.Name,FinancialAccountId__r.ProdDescText__c,FinancialAccountId__r.ProdLineCd__c,FinancialAccountId__r.AgreeStatusText__c,FinancialAccountId__r.AgreInceptionDate__c,FinancialAccountId__r.AgreEndDate__c,FinancialAccountId__r.AgreDisplayPartyName__c,FinancialAccountId__r.SourceSystemIdentifier__c,FinancialAccountId__r.ServicingAgent__r.Name,FinancialAccountId__r.ServicingAgent__r.Associate_ID__c';
    public static final String FINANCIAL_ACCOUNT_ROLE_FROM_OBJECT = ' FROM FinancialAccountRole__c ';
    public static final String FINANCIAL_ACCOUNT_ROLE_WHERE = ' WHERE AccountId__c = :accountId';
    public static final String FINANCIAL_ACCOUNT_ROLE_HOUSEHOLD_WHERE = ' WHERE AccountId__r.primary_household__pc = :accountId';

    public static final String FINANCIAL_ACCOUNT_FIELDS = 'SELECT Id, FinServ__Description__c, FinServ__Status__c, Name, FinServ__FinancialAccountType__c';
    public static final String FINANCIAL_ACCOUNT_FROM_OBJECT = ' FROM FinServ__FinancialAccount__c ';
    public static final String FINANCIAL_ACCOUNT_WHERE = ' WHERE FinServ__PrimaryOwner__c = :accountId';

    public static final String FINSERV_HOUSEHOLD_WHERE = ' WHERE FinServ__Household__c =: householdId ';

    public static final String INSURANCE_POLICY_FIELDS = 'SELECT Id, AgreDisplayPartyName__c, PolicyType, PolicyName, Name, Status, PolicyDescription, IsActive ';
    public static final String INSURANCE_POLICY_FROM_OBJECT = ' FROM InsurancePolicy';


    public static final String NAMED_INSURED_WHERE = ' WHERE NameInsuredId =: accountId';

    public static final String ORDER_BY_ACCOUNT_ID = ' ORDER BY AccountId ';

    public static final String OPPORTUNITY_FIELDS = 'SELECT Id, Name, Status__c, isClosed ';
    public static final String OPPORTUNITY_FROM_OBJECT = ' FROM Opportunity ';


    public static final String PRIMARY_HOUSEHOLD_WHERE = ' WHERE Primary_Household__pc =: householdId ';
}