/**
* Author : Team Kraken
* Date Created : 4/20/2020
* @description : Used by policySupportActions and policyClientSupportActions LWCs to give 1.07 users support actions on Insurance Policy
* Version : 1.2
*/
public virtual with sharing class AR_TechSupportActionsController {
    /**
     * @description getUserAccessForPolicySync
     * @return  `boolean`
     */
	@AuraEnabled
    public static boolean getUserAccessForPolicySync() {
        try {
            return AT_ProfileAccess.hasPolicySyncAccess();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @description getAgreementIndexId
     * @param recordId 
     * @return  `String`
     */
    @AuraEnabled
    public static String getAgreementIndexId(Id recordId){
        try {
            String objectName = recordId.getSObjectType().getDescribe().getName();
            String agreementId;
            
            if (objectName.equalsIgnoreCase('InsurancePolicy')) {
                InsurancePolicy insurancePolicy = [SELECT SourceSystemIdentifier, Id FROM InsurancePolicy WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];
                agreementId = insurancePolicy.SourceSystemIdentifier;
            }
            
            return agreementId;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
/**
 * @description syncSharesForAgreement
 * @param recordId 
 */
    @AuraEnabled
    public static void syncSharesForAgreement(Id recordId){
        try {
            String objectName = recordId.getSObjectType().getDescribe().getName();

            if (objectName.equalsIgnoreCase('InsurancePolicy')) {
                InsurancePolicy insurancePolicy = [SELECT SourceSystemIdentifier, Id, NameInsuredId FROM InsurancePolicy WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];

                Map<Id, InsurancePolicy> previousPolicies = new Map<Id, InsurancePolicy>();
                Map<Id, InsurancePolicy> currentPolicies = new Map<Id, InsurancePolicy>();
                previousPolicies.put(insurancePolicy.Id, insurancePolicy);
                currentPolicies.put(insurancePolicy.Id, insurancePolicy);

                IP_SharesTriggerHandler handler = new IP_SharesTriggerHandler();
                handler.handleBeforeUpdate(previousPolicies, currentPolicies, true); 
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
/**
 * @description getPolicyShares
 * @param recordId 
 * @return  `List<ReturnObject>`
 */
    @AuraEnabled
    public static List<ReturnObject> getPolicyShares(String recordId){
        try {
            List<InsurancePolicyShare> shares = Security.stripInaccessible(AccessType.READABLE, [
                SELECT UserOrGroup.Name
                FROM InsurancePolicyShare 
                WHERE RowCause = 'Manual' 
                AND ParentId = :recordId
            ]).getRecords();

            List<ReturnObject> sharesResponse = new List<ReturnObject>();
            for (InsurancePolicyShare share : shares) {
                sharesResponse.add(new ReturnObject(share.UserOrGroup.Name));
            }

            sharesResponse.sort();
            return sharesResponse;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
/**
 * @description getClientAgentRoles
 * @param policyId 
 * @return  `List<ReturnObject>`
 */
    @AuraEnabled
    public static List<ReturnObject> getClientAgentRoles(String policyId){
        try {
            List<InsurancePolicy> policies = Security.stripInaccessible(AccessType.READABLE, [
                SELECT 
                    NameInsuredId,
                    (SELECT PrimaryParticipantAccountId FROM InsurancePolicyParticipants)
                FROM InsurancePolicy
                WHERE Id = :policyId
            ]).getRecords();

            List<String> customerIds = new List<String>();
            
            if (policies.size() == 1 && String.isNotBlank(policies.get(0).NameInsuredId)) {
                InsurancePolicy policy = policies.get(0);

                customerIds.add(policy.NameInsuredId);

                for (InsurancePolicyParticipant participant : policy.InsurancePolicyParticipants) {
                    customerIds.add(participant.PrimaryParticipantAccountId);
                }
            }

            List<AgentRole__c> roles = new List<AgentRole__c>();

            if (!customerIds.isEmpty()) {
                roles = Security.stripInaccessible(AccessType.READABLE, [
                    SELECT Agent__r.Proxy_External_ID__c
                    FROM AgentRole__c
                    WHERE Customer__c IN :customerIds
                ]).getRecords();
            }
            
            return getRoles(roles);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description getRoles
     * @param roles 
     * @return  `List<ReturnObject>`
     */
    public static List<ReturnObject> getRoles(List<AgentRole__c> roles) {
        Set<String> proxySet = new Set<String>();
        for (AgentRole__c role : roles) {
            proxySet.add(role.Agent__r.Proxy_External_ID__c);
        }
        
        List<User> proxies = new List<User>();
        if (!proxySet.isEmpty()) {
            proxies = Security.stripInaccessible(AccessType.READABLE, [
                SELECT Name
                FROM User
                WHERE UserExternalId__c IN :proxySet
            ]).getRecords();
        }
        
        //dedup agent roles
        Set<String> rolesSet = new Set<String>();
        for (User proxy : proxies) {
            rolesSet.add(proxy.Name);
        }

        List<ReturnObject> rolesResponse = new List<ReturnObject>();
        for (String role : rolesSet) {
            rolesResponse.add(new ReturnObject(role));
        }

        rolesResponse.sort();
        return rolesResponse;
    }

/**
 * @description ReturnObject
 */
    public with sharing class ReturnObject implements Comparable {
        @AuraEnabled
        public String name;

        ReturnObject(String name) {
            this.name = name;
        }
/**
 * @description compareTo
 * @param compareTo 
 * @return  `Integer`
 */
        public Integer compareTo(Object compareTo) {
            ReturnObject compareToObject = (ReturnObject)compareTo;
            Integer returnValue = 0;
            if (this.name > compareToObject.name) {
                returnValue = 1;
            }
           	else if (this.name < compareToObject.name) {
            returnValue = -1;
            }    
            return returnValue;
        }
    }
}