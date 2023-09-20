/**
 * Author : Team Moneyball
 * Date Created : 06/21/2023
 * @description : class ClaimLossHistoryController
 * Version : 1.0
 */

 public with sharing class ClaimLossHistoryController {
    private static final String CLASS_NAME = 'ClaimLossHistoryController';

    /**
     * @name getLossHistoryByClientId
     * @description This method is calling aggregator api by clientId.
     * @param input map with the callout name and parameters
     * @return HttpCalloutResponse Wrapped response with status code and body
     */
    @AuraEnabled(cacheable=true)
    public static HttpRequestCalloutHelper.HttpCalloutResponse getLossHistoryByClientId(Map<String, Object> input) {
        try {
            return HttpRequestCalloutHelper.doCallout(input);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @name getLossHistoryByAgreementId
     * @description This method is calling aggregator api by agreementId.
     * @param input map with the callout name and parameters
     * @return HttpCalloutResponse Wrapped response with status code and body
     */
    @AuraEnabled(cacheable=true)
    public static HttpRequestCalloutHelper.HttpCalloutResponse getLossHistoryByAgreementId(Map<String, Object> input) {
        try {
            return HttpRequestCalloutHelper.doCallout(input);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @name   getLossHistoryParameters
     * @description This method get related clientids for given accountId.
     * @param input recordId
     * @return  LossHistoryWrapper which contain list of clientIds
     */
    @AuraEnabled(cacheable=true)
    public static LossHistoryWrapper getLossHistoryParameters(Id recordId) {
        Set<String> clientIds = new Set<String>();
        Set<Id> accountIds = new Set<Id>();
        List<Account> listAccounts = new List<Account>();
        Set<String> agreementIds = new Set<String>();
        LossHistoryWrapper lossHistoryWrap = new LossHistoryWrapper();

        try {
            Account accntDetails = getHouseholdId(recordId);
            if (String.valueOf(accntDetails.Primary_Household__pc) != null) {
                listAccounts = getHouseholdMemberIds(accntDetails.Primary_Household__pc);
                for (Account accnt : listAccounts) {
                    accountIds.add(accnt.Id);
                    clientIds.add(accnt.ClientIdentifier__c);
                }
                agreementIds = getRelatedAgreementIds(accountIds);
                lossHistoryWrap.clientIds = clientIds;
                lossHistoryWrap.agreementIds = agreementIds;
            } else {
                String recordTypeName = getRecordTypeNameById(accntDetails.RecordTypeId);
                if (recordTypeName == 'IndustriesHousehold') {
                    listAccounts = getHouseholdMemberIds(accntDetails.Id);
                    for (Account accnt : listAccounts) {
                        accountIds.add(accnt.Id);
                        clientIds.add(accnt.ClientIdentifier__c);
                    }
                    agreementIds = getRelatedAgreementIds(accountIds);
                    lossHistoryWrap.clientIds = clientIds;
                    lossHistoryWrap.agreementIds = agreementIds;
                } else {
                    lossHistoryWrap.clientIds = new Set<String>{ accntDetails.ClientIdentifier__c };
                }
            }
        } catch (Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, 'getLosshistoryParameters', System.LoggingLevel.ERROR);
            throw new AuraHandledException('QUERY ERROR');
        }
        return lossHistoryWrap;
    }

    /**
     * @name   getHouseholdMemberIds
     * @description This method get accountId in household.
     * @param input accountid
     * @return list of accountIds
     */
    private static List<Account> getHouseholdMemberIds(Id accountId) {
        List<Account> listAccounts = new List<Account>();
        listAccounts = Security.stripInaccessible(
                AccessType.READABLE,
                [SELECT ClientIdentifier__c, Name, ID FROM Account WHERE Primary_Household__pc = :accountId]
            )
            .getRecords();
        return listAccounts;
    }

    /**
     * @name   getHouseholdId
     * @description This method get householdId for given accountId.
     * @param input accountid
     * @return householdId
     */
    private static Account getHouseholdId(Id recordId) {
        List<Account> listaccnt = new List<Account>();
        listaccnt = Security.stripInaccessible(
                AccessType.READABLE,
                [SELECT Id, Primary_Household__pc, ClientIdentifier__c, recordtypeId FROM Account WHERE Id = :recordId]
            )
            .getRecords();
        return listaccnt.get(0);
    }

    /**
     * @name   getRelatedAgreementIds
     * @description This method get  agreementId via policy for given accountIds.
     * @param input accountid
     * @return list of agreementIds
     */
    private static Set<String> getRelatedAgreementIds(Set<Id> accountIds) {
        Set<String> agreementIds = new Set<String>();
        List<InsurancePolicy> listPolicies = new List<InsurancePolicy>();
        try {
            listPolicies = Security.stripInaccessible(
                    AccessType.READABLE,
                    [
                        SELECT SourceSystemIdentifier
                        FROM InsurancePolicy
                        WHERE
                            Id IN (
                                SELECT InsurancePolicyId
                                FROM InsurancePolicyParticipant
                                WHERE PrimaryParticipantAccountId IN :accountIds
                            )
                    ]
                )
                .getRecords();
            for (InsurancePolicy policy : listPolicies) {
                agreementIds.add(policy.SourceSystemIdentifier);
            }
        } catch (Exception e) {
            LoggingService.logHandledException(e, 'ClaimLossHistoryController', 'getRelatedAgreementIds', System.LoggingLevel.ERROR);
            throw new AuraHandledException('QUERY ERROR');
        }
        return agreementIds;
    }

    /**
     * @name   getPolicyDetails
     * @description This method get policy details from InsurancePolicy object
     * @param input agreementId
     * @return policy details like description
     */
    @AuraEnabled(cacheable=true)
    public static InsurancePolicy getPolicyDetails(String agreementId) {
        List<InsurancePolicy> listPolicies = new List<InsurancePolicy>();
        try {
            listPolicies =  Security.stripInaccessible(
                AccessType.READABLE,
                [SELECT PolicyName FROM InsurancePolicy WHERE SourceSystemIdentifier =: agreementId LIMIT 1]
            )
            .getRecords();
            if (listPolicies.isEmpty()) {
                throw new AuraHandledException('No insurance policy record found.');
            }
        }
        catch (Exception e) {
            LoggingService.logHandledException(e, 'ClaimLossHistoryController', 'getPolicyDetails', System.LoggingLevel.ERROR);
            throw new AuraHandledException('QUERY ERROR');
        }
        return listPolicies[0];
    }

    /**
     * @name   getRecordTypeNameById
     * @description This method get record type name for given recordtypeid
     * @param input recordTypeId
     * @return recordTypeName
     */
    private static String getRecordTypeNameById(Id recordTypeId) {
        return Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosById().get(recordTypeId).getDeveloperName();
    }

    /**
     * @description a wrapper for the LossHistory return parameter
     */
    public with sharing class LossHistoryWrapper {
        /**
         * @description gets/sets clientIds
         */
        @AuraEnabled
        public Set<String> clientIds { get; set; }

        /**
         * @description gets/sets agreementIds
         */
        @AuraEnabled
        public Set<String> agreementIds { get; set; }
    }
}

