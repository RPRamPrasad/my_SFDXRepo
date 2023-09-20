/**
 * @description InsurancePolicyClasses
 */
public with sharing virtual class InsurancePolicyClasses {
    /**
     * @description InsurancePolicyData
     */
    public with sharing class InsurancePolicyData {
        /**
         * @description accountRecordId
         */
        @AuraEnabled
        public Id accountRecordId {get; set;}
        /**
         * @description lob
         */
        @AuraEnabled
        public String lob {get; set;}
        /**
         * @description policyNumber
         */
        @AuraEnabled
        public String policyNumber {get; set;}
        /**
         * @description actionValue
         */
        @AuraEnabled
        public String actionValue {get; set;}
        /**
         * @description agentAssociateId
         */
        @AuraEnabled
        public String agentAssociateId {get; set;}
        /**
         * @description productDescription
         */
        @AuraEnabled
        public String productDescription {get; set;}
        /**
         * @description agreAccessKey
         */
        @AuraEnabled
        public String agreAccessKey {get; set;}
        /**
         * @description agreementIndexId
         */
        @AuraEnabled
        public String agreementIndexId {get; set;}
        /**
         * @description isLegacyPolicy
         */
        @AuraEnabled
        public Boolean isLegacyPolicy {get; set;}
        /**
         * @description isCaseMigrationAction
         */
        @AuraEnabled
        public Boolean isCaseMigrationAction {get; set;}
        /**
         * @description caseTransactionType for SAE App launch
         */
        @AuraEnabled
        public String caseTransactionType {get; set;}
        /**
         * @description sourceSystemCode
         */
        @AuraEnabled
        public String sourceSystemCode {get; set;}

    }
/**
 * @description AccountWrapper
 */
    public with sharing class AccountWrapper {
        @AuraEnabled
        public String recordId;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String firstName;
        @AuraEnabled
        public String gender;
        @AuraEnabled
        public String clientId;
        @AuraEnabled
        public String birthdate;
        @AuraEnabled
        public String driversLicenseState;
        @AuraEnabled
        public String driversLicenseNumber;
    }
}
