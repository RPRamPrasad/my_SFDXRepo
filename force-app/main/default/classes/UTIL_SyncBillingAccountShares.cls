/**
 * @description This class will be used by Billing Details Component to give 1.07 users support actions on Billing Shares
 * @Date: 03/22/22
 * @author: Team Nsync
 */
public with sharing class UTIL_SyncBillingAccountShares extends UTIL_AgencyShares {
    private static final String MANUAL_ROW_CAUSE = 'Manual';
    private UTIL_SyncBillingAccountShares(){
        AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.info('UTIL_SyncBillingAccountShares', 'start time of execution: ' + System.now());
        logHolder.writeToLogExceptionObject();
    }
        /**
         * @description inserts missing billing shares. 
         * @param billingAccountId
         * @return billing shares
         */
        @AuraEnabled(cacheable=false)
        @TestVisible
        public static List<Billing_Account__Share> resyncBillingShares(String billingAccountId) {
            try{
                List<Billing_Account__Share> billingAccountSharesToInsertList = new List<Billing_Account__Share>();
    
                Set<Billing_Account__Share> sharesForDelete = new Set<Billing_Account__Share>();
                Set<Billing_Account__Share> sharesForInsert = new Set<Billing_Account__Share>();
        
                // retrieve the existing shares for the given billing accounts
                List<Billing_Account__Share> existingSharesList = UTIL_SyncBillingAccountShares.getBillingAccountShares(billingAccountId);
        
                // store the existing shares in a map with a key comprised of the ParentId and UserOrGroupId
                Map<String,Billing_Account__Share> existingShares = createMapOfExistingShares(existingSharesList);
        
                // generate the shares that should be persisted
                List<Billing_Policy__c> billingPolicies = UTIL_SyncBillingAccountShares.getAllBillingPolicies(billingAccountId);
                Set<Billing_Account__Share> billingSharesFromInsurancePolicy = UTIL_BillingAccountShares.getBillingAccountSharesForBillingPolicies(billingPolicies);
                List<Billing_Participant__c> billingParticipants = UTIL_SyncBillingAccountShares.getAllBillingParticipants(billingAccountId);
                Set<Billing_Account__Share> billingSharesFromCustomerAccount = UTIL_BillingAccountShares.getBillingAccountSharesForBillingParticipants(billingParticipants);
                Set<Billing_Account__Share> generatedSharesSet = UTIL_BillingAccountShares.mergeIpSharesAndAccountShares(billingSharesFromInsurancePolicy, billingSharesFromCustomerAccount);
                Map<String,Billing_Account__Share> generatedShares = new Map<String,Billing_Account__Share>();
                for (Billing_Account__Share generatedShare : generatedSharesSet) {
                    generatedShares.put(generateBillingShareKey(generatedShare), generatedShare);
                }
    
                // find the shares that should be removed
                ResyncBillingSharesMethodWrapper resyncWrapper = new ResyncBillingSharesMethodWrapper();
                resyncWrapper.existingShares = existingShares;
                resyncWrapper.generatedShares = generatedShares;
                billingAccountSharesToInsertList = resyncBillingSharesMethod(resyncWrapper, sharesForDelete, billingAccountSharesToInsertList);
        
                // find the shares that need to be created
                for (String key : generatedShares.keySet()) {
                    if (!existingShares.containsKey(key)) {
                        sharesForInsert.add(generatedShares.get(key));
                    }
                }
        
                // delete shares that should no longer exist
                if (!sharesForDelete.isEmpty()) {
                    UTIL_BillingAccountSharesDelete.performBillingAccountSharesDelete(sharesForDelete);       
                }
        
                // insert the shares that should exist
                
                if (!sharesForInsert.isEmpty()) {
                    UTIL_BillingAccountSharesAdd.insertBillingAccountShares(sharesForInsert);
                }
            
                billingAccountSharesToInsertList = new List<Billing_Account__Share>(sharesForInsert);
                return billingAccountSharesToInsertList;
            }catch(Exception ex){
                throw new AuraHandledException(ex.getMessage());
            }
        }

        private class ResyncBillingSharesMethodWrapper{
            Map<String,Billing_Account__Share> existingShares;
            Map<String,Billing_Account__Share> generatedShares;
        }

        private static List<Billing_Account__Share> resyncBillingSharesMethod(ResyncBillingSharesMethodWrapper resyncWrap, Set<Billing_Account__Share> sharesForDelete, List<Billing_Account__Share> billingAccountSharesToInsertList){
            for (String key : resyncWrap.existingShares.keySet()) {
                if (!resyncWrap.generatedShares.containsKey(key)) {
                    sharesForDelete.add(resyncWrap.existingShares.get(key));
                }
            }    
                return billingAccountSharesToInsertList;
        }

        /**
         * @description store the existing shares in a map with a key comprised of the ParentId and UserOrGroupId
         * @param existingSharesList
         * @return Map<String,Billing_Account__Share>
         */
        public static Map<String,Billing_Account__Share> createMapOfExistingShares(List<Billing_Account__Share> existingSharesList) {
            Map<String,Billing_Account__Share> returnExistingShares = new Map<String,Billing_Account__Share>();
            for (Billing_Account__Share existingShare : existingSharesList) {
                returnExistingShares.put(generateBillingShareKey(existingShare), existingShare);
            }

            return returnExistingShares;
        }

         /**
         * @description Retrieves the current Billing Account shares for a given Billing Account Id.
         * @param billingAccountId
         * @return List<ReturnObject>
         */
        @TestVisible
        @AuraEnabled
        public static List<ReturnObject> getCurrentBillingSharesForQuery(String billingAccountId) {
            try{
                List<Billing_Account__Share> billingAccountShares = Security.stripInaccessible(AccessType.READABLE, [SELECT UserOrGroup.Name
                FROM Billing_Account__Share
                WHERE ParentId = :billingAccountId
                AND RowCause = :MANUAL_ROW_CAUSE]).getRecords();

            List<ReturnObject> sharesResponse = new List<ReturnObject>();
                for (Billing_Account__Share share : billingAccountShares) 
                    {
                        sharesResponse.add(new ReturnObject(share.UserOrGroup.Name));
                    }
                                                                
                                                                       
                sharesResponse.sort();
            return sharesResponse;
            }catch(Exception ex){
                throw new AuraHandledException(ex.getMessage());
            }                                                 
           
        }

         /**
         * @description Retrieves the expected Billing Account shares for a given Billing Account Id.
         * @param billingAccountId
         * @return List<ReturnObject>
         */
        @TestVisible
        @AuraEnabled
        public static List<ReturnObject> getExpectedBillingSharesForQuery(String billingAccountId) {           
            try{
                List<Billing_Policy__c> billingPolicies = UTIL_SyncBillingAccountShares.getAllBillingPolicies(billingAccountId);
                Set<Billing_Account__Share> billingSharesFromInsurancePolicy = UTIL_BillingAccountShares.getBillingAccountSharesForBillingPolicies(billingPolicies);
                List<Billing_Participant__c> billingParticipants = UTIL_SyncBillingAccountShares.getAllBillingParticipants(billingAccountId);
                Set<Billing_Account__Share> billingSharesFromCustomerAccount = UTIL_BillingAccountShares.getBillingAccountSharesForBillingParticipants(billingParticipants);
                Set<Billing_Account__Share> generatedSharesSet = UTIL_BillingAccountShares.mergeIpSharesAndAccountShares(billingSharesFromInsurancePolicy, billingSharesFromCustomerAccount);
                
                Set<Id> userOrGroupIds = new Set<Id>();
                for (Billing_Account__Share billingShare : generatedSharesSet){
                    userOrGroupIds.add(billingShare.UserOrGroupId);
                }

                List<User> userList = Security.stripInaccessible(AccessType.READABLE, [SELECT Name
                    FROM User
                    WHERE Id IN :userOrGroupIds
                    ]).getRecords();

                List<ReturnObject> sharesResponse = new List<ReturnObject>();
                
                    for (User user : userList) 
                        {
                           sharesResponse.add(new ReturnObject(user.Name));
                        }
                        sharesResponse.sort();
                return sharesResponse;
            }catch(Exception ex){
                throw new AuraHandledException(ex.getMessage());
            }                                               
           
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
    
      

        /**
         * @name generateBillingShareKey
         * @description generates a unique key from a Billing_Account__Share comprised of its ParentId and UserOrGroupId fields.
         * @param billingShare
         * @return String
         */
        private static String generateBillingShareKey(Billing_Account__Share billingShare) {
            return billingShare.ParentId + '-' + billingShare.UserOrGroupId;
        }

        /**
         * @description Retrieves the Billing Account shares for a given Billing Account Id.
         * @param billingAccountId
         * @return billingAccountShares
         */
        @TestVisible
        private static List<Billing_Account__Share> getBillingAccountShares(String billingAccountId) {

            return [SELECT Id, ParentId, UserOrGroupId,RowCause
                    FROM Billing_Account__Share
                    WHERE ParentId = :billingAccountId
                    AND RowCause = :MANUAL_ROW_CAUSE WITH SECURITY_ENFORCED];
           
        }
        /**
         * @description Retrieves the Billing Policy records for  a given Billing Accounts Id.
         * @param billingAccountId
         * @return billingPolicies
         */
        @TestVisible
        private static List<Billing_Policy__c> getAllBillingPolicies(String billingAccountId) {

            return [SELECT InsurancePolicyId__c, BillingAccountID__c
                    FROM Billing_Policy__c
                    WHERE BillingAccountID__c = :billingAccountId WITH SECURITY_ENFORCED];                                                    

            
        }

        /**
         * @description Retrieves the Billing Participant records for a given Billing Account Id.
         * @param billingAccountId
         * @return billingParticipants
         */
        @TestVisible
        private static List<Billing_Participant__c> getAllBillingParticipants(String billingAccountId) {
        
            return [SELECT Id, ParticipantAccountId__c, BillingAccountID__c
                    FROM Billing_Participant__c
                    WHERE BillingAccountID__c = :billingAccountId WITH SECURITY_ENFORCED];

            
        }
}

