/**
* @author: Stephen White YCDB, Jonathan Larkin VAASTT
* @description : Used to generate Insurance Policy Test Data for Billing Shares
* @version 1.0
* @dateCreated 10/26/2021
*/
@isTest
public with sharing class TestDataFactory_BillingSharesPolicy extends UTIL_AgencyShares{
    public static final String INDIVIDUAL_RECORD_TYPE = 'Individual';
    public static final String INSURANCE_POLICY_ONE_NAME = 'BillingSharesPolicy1';
    public static final String INSURANCE_POLICY_TWO_NAME = 'BillingSharesPolicy2';

    /**
     * @description  Generate All Data for Billing Testing.
     */
    public static void generateBillingShareInsurancePolicyTestData(){

        UTIL_UserProvisioning_TEST.buildSystemAdmin('1701B','systemUserTest2','systemUserTest2@statefarm.com'); 
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
 
        generateInsurancePolicies();
        generateInsurancePolicyParticipants();
        generateBillingPolicies();
    }


    private static void generateInsurancePolicies() {
        Id accountId4 = TestDataFactory_BillingShares.getAccount4().Id;
        TestDataFactory_AgencyShares.insertPolicy(INSURANCE_POLICY_ONE_NAME, accountId4);
        TestDataFactory_AgencyShares.insertPolicy(INSURANCE_POLICY_TWO_NAME, accountId4);
    }

    private static void generateInsurancePolicyParticipants() {
        Id accountId3 = TestDataFactory_BillingShares.getAccount3().Id;
        TestDataFactory_AgencyShares.insertParticipant(accountId3, getInsurancePolicy1().Id);
        TestDataFactory_AgencyShares.insertParticipant(accountId3, getInsurancePolicy2().Id);
    }

    private static void generateBillingPolicies() {
        // Mock data for creating external id, will be unique in prod, but can be fake in our tests
        String roCode = '00';
        Id insurancePolicyId1 = getInsurancePolicy1().Id;
        Id insurancePolicyId2 = getInsurancePolicy2().Id;
        Id billingAccountId1 = TestDataFactory_BillingShares.getBillingAccount1().Id;
        Id billingAccountId2 = TestDataFactory_BillingShares.getBillingAccount2().Id;

        Billing_Policy__c billingPolicy1 = new Billing_Policy__c();
        billingPolicy1.InsurancePolicyId__c = getInsurancePolicy1().Id;
        billingPolicy1.SourceSystemIdentifier__c = billingAccountId1 + '~' + roCode + '~' + insurancePolicyId1;
        billingPolicy1.BillingAccountID__c = billingAccountId1;

        Billing_Policy__c billingPolicy2 = new Billing_Policy__c();
        billingPolicy2.InsurancePolicyId__c = getInsurancePolicy1().Id;
        billingPolicy2.SourceSystemIdentifier__c = billingAccountId2 + '~' + roCode + '~' + insurancePolicyId2;
        billingPolicy2.BillingAccountID__c = billingAccountId2;
        
        insert billingPolicy1;
        insert billingPolicy2;
    }

    /**
     * @name - getInsurancePolicy1
     * @description - Returns the first insurance policy.
     * @return InsurancePolicy
     */
    public static InsurancePolicy getInsurancePolicy1() {
       return [SELECT Id, Name, NameInsuredId FROM InsurancePolicy WHERE Name = :INSURANCE_POLICY_ONE_NAME];

    }

    /**
     * @name - getInsurancePolicy2
     * @description - Returns the second insurance policy.
     * @return InsurancePolicy
     */
    public static InsurancePolicy getInsurancePolicy2() {
        return [SELECT Id, Name, NameInsuredId FROM InsurancePolicy WHERE Name = :INSURANCE_POLICY_TWO_NAME];
    }

    /**
     * @name - getInsurancePolicyParticipant1
     * @description - Returns the insurance policy participant for the first insurance policy.
     * @return InsurancePolicyParticipant
     */
    public static InsurancePolicyParticipant getInsurancePolicyParticipant1() {
        Id accountId3 = TestDataFactory_BillingShares.getAccount3().Id;
        Id insurancePolicy1Id = getInsurancePolicy1().Id;
        return [
           SELECT Id, PrimaryParticipantAccountId, InsurancePolicyId 
           FROM InsurancePolicyParticipant 
           WHERE PrimaryParticipantAccountId = :accountId3 AND InsurancePolicyId = :insurancePolicy1Id
        ];    
    }

    /**
     * @name - getInsurancePolicyParticipant2
     * @description - Returns the insurance policy participant for the second insurance policy.
     * @return InsurancePolicyParticipant
     */
    public static InsurancePolicyParticipant getInsurancePolicyParticipant2() {
        Id accountId3 = TestDataFactory_BillingShares.getAccount3().Id;
        Id insurancePolicy2Id = getInsurancePolicy2().Id;
        return [
           SELECT Id, PrimaryParticipantAccountId, InsurancePolicyId 
           FROM InsurancePolicyParticipant 
           WHERE PrimaryParticipantAccountId = :accountId3 AND InsurancePolicyId = :insurancePolicy2Id
        ];    
    }

    /**
     * @name - getBillingPolicy1
     * @description - Returns the billing policy related to the first insurance policy.
     * @return InsurancePolicyParticipant
     */
    public static Billing_Policy__c getBillingPolicy1() {
        Id insurancePolicy1Id = getInsurancePolicy1().Id;
        Id billingAccountId1 = TestDataFactory_BillingShares.getBillingAccount1().Id;
        return [
            SELECT Id, SourceSystemIdentifier__c, InsurancePolicyId__c, BillingAccountID__c 
            FROM Billing_Policy__c 
            WHERE InsurancePolicyId__c = :insurancePolicy1Id AND BillingAccountID__c = :billingAccountId1
        ];   
    }

    /**
     * @name - getBillingPolicy2
     * @description - Returns the billing policy related to the second insurance policy.
     * @return InsurancePolicyParticipant
     */
    public static Billing_Policy__c getBillingPolicy2() {
        Id insurancePolicy2Id = getInsurancePolicy2().Id;
        Id billingAccountId2 = TestDataFactory_BillingShares.getBillingAccount2().Id;
        return [
            SELECT Id, SourceSystemIdentifier__c, InsurancePolicyId__c, BillingAccountID__c 
            FROM Billing_Policy__c 
            WHERE InsurancePolicyId__c = :insurancePolicy2Id AND BillingAccountID__c = :billingAccountId2
        ]; 
    }
}
