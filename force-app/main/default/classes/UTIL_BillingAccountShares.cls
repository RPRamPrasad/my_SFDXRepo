/**
 * @description This class will be used as the primary controller for Billing Account Shares
 * @Date: 10/25/21
 * @author: Stephen White YCDB, Jonathan Larkin VAASTT
 */
public without sharing class UTIL_BillingAccountShares extends UTIL_AgencyShares{
    private static final String CLASSNAME = 'UTIL_BillingAccountShares';

    private static final String ACCESS_LEVEL = 'Read';
    private static final String MANUAL_ROW_CAUSE = 'Manual';
    private static UTIL_BillingAccountSharesWrapper utilWrap = new UTIL_BillingAccountSharesWrapper();

    @TestVisible
    private static UTIL_ToggleStrategyContext toggleContext = new UTIL_ToggleStrategyContext();

    private UTIL_BillingAccountShares(){
        AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.info(CLASSNAME, 'start time of execution: ' + System.now());
        logHolder.writeToLogExceptionObject();
    }

    /**
     * @name createBillingAccountSharesFromAgentRoleData
     * @param agentRoleData
     * @description Given an Agent Role Data Object, create Billing Shares
     */
    public static void createBillingAccountSharesFromAgentRoleData(AgentRoleData agentRoleData) {
        if(isBillingSharesEnabled()){
            try {
                UTIL_BillingAccountSharesAdd.createBillingAccountShares(agentRoleData);
            } catch (Exception ex) { // we want to catch all exceptions to prevent issues in the trigger handler
                LoggingService.logHandledException(ex, CLASSNAME, 'createBillingAccountSharesFromAgentRoleData', System.LoggingLevel.ERROR);
            }
        }
    }

    /**
     * @name deleteBillingAccountSharesFromAgentRoleData
     * @param agentRoleData
     * @description Given an Agent Role Data Object, delete Billing Shares
     */
    public static void deleteBillingAccountSharesFromAgentRoleData(AgentRoleData agentRoleData) {
        if(isBillingSharesEnabled()){
            try {
                UTIL_BillingAccountSharesDelete.deleteBillingAccountShares(agentRoleData);
            } catch (Exception ex) { // we want to catch all exceptions to prevent issues in the trigger handler
                LoggingService.logHandledException(ex, CLASSNAME, 'deleteBillingAccountSharesFromAgentRoleData', System.LoggingLevel.ERROR);
            }
        }
    }

    /**
     * @description This method will be used to determine if the Billing Shares Toggle is enabled.
     * @return a boolean inidicating whether or not Billing Shares are enabled
     */
    public static boolean isBillingSharesEnabled() {
        return UTIL_BillingAccountShares.toggleContext.isActive(UTIL_Toggles.BILLING_SHARES);
    }

    /**
     * @description shared method used to get all billing accounts for a list of customer accounts.
     * @param accountIds
     * @param customerAccountToBillingAccountIdsMap
     */
    @TestVisible
    public static void getBillingAccountsFromBillingParticipants(List<Id> accountIds, 
        Map<Id, Set<Id>> customerAccountToBillingAccountIdsMap){

        // For each account find all associated Billing Accounts and add them to the map
        for(Billing_Participant__c billingParticipant : 
            (List<Billing_Participant__c>)Security.stripInaccessible(AccessType.READABLE,[SELECT BillingAccountID__c,ParticipantAccountId__c FROM Billing_Participant__c WHERE ParticipantAccountId__c IN :accountIds]).getRecords()){

            // Add Billing Accounts to customerAccountToBillingAccountIdsMap. If No entries exist for the customer, create a new one. 
            // If an Entry does exist add it to the existing set.
            utilWrap.getBillingAccountsFromBillingParticipants(customerAccountToBillingAccountIdsMap, billingParticipant);
        }
    }

    /**
     * @description Retrieves the Billing Account shares from a given set of Billing Accounts IDs.
     * @param billingAccountIds
     * @return billingAccountShares
     */
    public static List<Billing_Account__Share> getBillingAccountShares(Set<Id> billingAccountIds) {

        return Security.stripInaccessible(AccessType.READABLE,[SELECT Id, ParentId, UserOrGroupId, RowCause
            FROM Billing_Account__Share
            WHERE ParentId IN :billingAccountIds
            AND RowCause = :MANUAL_ROW_CAUSE]).getRecords();
    }

    /**
     * @description Retrieves the Billing Policy records for  a given set of Billing Accounts IDs.
     * @param billingAccountIds
     * @return billingPolicies
     */
    public static List<Billing_Policy__c> getAllBillingPolicies(Set<Id> billingAccountIds) {
        return Security.stripInaccessible(AccessType.READABLE,[SELECT InsurancePolicyId__c, BillingAccountID__c
            FROM Billing_Policy__c
            WHERE BillingAccountID__c IN :billingAccountIds]).getRecords();                                                   
    }

    /**
     * @description Retrieves the Billing Participant records for a given set of Billing Bccounts IDs.
     * @param billingAccountIds
     * @return billingParticipants
     */
    public static List<Billing_Participant__c> getAllBillingParticipants(Set<Id> billingAccountIds) {
        return Security.stripInaccessible(AccessType.READABLE,[SELECT Id, ParticipantAccountId__c, BillingAccountID__c
            FROM Billing_Participant__c
            WHERE BillingAccountID__c IN :billingAccountIds]).getRecords();
    }

    /**
     * @description Retrieves the Billing Account shares for a list of Billing Policies.
     * @param billingPolicies
     * @return billingShares
     */
    public static Set<Billing_Account__Share> getBillingAccountSharesForBillingPolicies(List<Billing_Policy__c> billingPolicies){

        Set<Billing_Account__Share> billingShares = new Set<Billing_Account__Share>();
        Map<Id, Id> insurancePolicyToBillingAccountMap = new Map<Id, Id>();
        Set<Id> insurancePolicyIds = new Set<Id>();
       

        for(Billing_Policy__c billingPolicy : billingPolicies){
            insurancePolicyIds.add(billingPolicy.InsurancePolicyId__c);
            insurancePolicyToBillingAccountMap.put(billingPolicy.InsurancePolicyId__c, billingPolicy.BillingAccountID__c);
        }

        List<InsurancePolicyShare> insurancePolicyShares = getInsurancePolicySharesForInsert(insurancePolicyIds);
         

        for (InsurancePolicyShare insurancePolicyShare : insurancePolicyShares){
            Id billingAccountId = insurancePolicyToBillingAccountMap.get(insurancePolicyShare.ParentId);
            Billing_Account__Share billingShare = new Billing_Account__Share();
            billingShare.ParentId = billingAccountId;
            billingShare.UserOrGroupId = insurancePolicyShare.UserOrGroupId;
            billingShare.AccessLevel = ACCESS_LEVEL;
            billingShare.RowCause = MANUAL_ROW_CAUSE;
            billingShares.add(billingShare);
        }

        return billingShares;
    }

    /**
     * @description Retrieves the Billing Account shares for a list of Billing Participants.
     * @param billingParticipants
     * @return billingSharesForCustomerAccount
     */
    public static Set<Billing_Account__Share> getBillingAccountSharesForBillingParticipants(List<Billing_Participant__c> billingParticipants){

        Set<Billing_Account__Share> billingSharesForCustomerAccount = new Set<Billing_Account__Share>();
        Map<Id, Id> customerAccountToBillingAccountMap = new Map<Id, Id>();
        List<Id> participantAccountIds = new List<Id>();

        for(Billing_Participant__c billingParticipant : billingParticipants){
            participantAccountIds.add(billingParticipant.ParticipantAccountId__c);
            customerAccountToBillingAccountMap.put(billingParticipant.ParticipantAccountId__c, billingParticipant.BillingAccountID__c);
        }


        List<AccountShare> customerAccountShares = getAccountSharesForInsert(participantAccountIds);
        

        for (AccountShare customerAccountShare : customerAccountShares){
           Id billingAccountId = customerAccountToBillingAccountMap.get(customerAccountShare.AccountId);
           Billing_Account__Share billingShare = new Billing_Account__Share();
           billingShare.ParentId = billingAccountId;
           billingShare.UserOrGroupId = customerAccountShare.UserOrGroupId;
           billingShare.AccessLevel = ACCESS_LEVEL;
           billingShare.RowCause = MANUAL_ROW_CAUSE;
           billingSharesForCustomerAccount.add(billingShare);

        }

        return billingSharesForCustomerAccount;
    }

    /**
     * @description Retrieves the Insurance Policy shares from a set of Insurance Policy IDs.
     * @param insurancePolicyIds
     * @return insurancePolicyShares
     */
    public static List<InsurancePolicyShare> getInsurancePolicySharesForInsert(Set<Id> insurancePolicyIds) {
        return Security.stripInaccessible(AccessType.READABLE,[SELECT Id, ParentId, UserOrGroupId, RowCause
            FROM InsurancePolicyShare
            WHERE ParentId IN :insurancePolicyIds
            AND RowCause = :MANUAL_ROW_CAUSE]).getRecords();
     
    }

    /**
     * @description Retrieves the Account sharesshares from a list of Account Ids.
     * @param participantAccountIds
     * @return accountShares
     */
    public static List<AccountShare> getAccountSharesForInsert(List<Id> participantAccountIds) {
      
        return Security.stripInaccessible(AccessType.READABLE,[SELECT Id, AccountId, UserOrGroupId, RowCause
            FROM AccountShare
            WHERE AccountId IN :participantAccountIds
            AND RowCause = :MANUAL_ROW_CAUSE]).getRecords();
      
    }

    /**
     * @description Combines Billing Account shares from Insurance Policy and Account.
     * @param billingSharesFromInsurancePolicy
     * @param billingSharesFromCustomerAccount
     * @return billingShares
     */
    public static Set<Billing_Account__Share> mergeIpSharesAndAccountShares( Set<Billing_Account__Share> billingSharesFromInsurancePolicy, Set<Billing_Account__Share> billingSharesFromCustomerAccount ){

        Set<Billing_Account__Share> billingShares = new Set<Billing_Account__Share>(billingSharesFromInsurancePolicy);
        billingShares.addAll(billingSharesFromCustomerAccount);

        return billingShares;
    }
/**
 * @description refreshBillingSharesForBillingPolicies
 * @param billingPolicyIds 
 * @return  `List<Database.SaveResult>`
 */
    public static List<Database.SaveResult> refreshBillingSharesForBillingPolicies(Set<Id> billingPolicyIds) {
        List<Billing_Policy__c> billingPolicies = (List<Billing_Policy__c>)Security.stripInaccessible(AccessType.READABLE,[SELECT Id, BillingAccountID__r.Id
                                                    FROM Billing_Policy__c
                                                    WHERE Id IN :billingPolicyIds]).getRecords();

        Set<Id> billingAccountIds = new Set<Id>();
        for (Billing_Policy__c billingPolicy : billingPolicies) {
            billingAccountIds.add(billingPolicy.BillingAccountID__c);
        }
        
        return refreshBillingShares(billingAccountIds);
    }
/**
 * @description refreshBillingSharesFromPolicies
 * @param policyIds 
 * @return  `List<Database.SaveResult>`
 */
    public static List<Database.SaveResult> refreshBillingSharesFromPolicies(Set<Id> policyIds) {
            List<Billing_Policy__c> billingPolicies = Security.stripInaccessible(AccessType.READABLE,[SELECT InsurancePolicyId__c, BillingAccountID__r.Id
                                                    FROM Billing_Policy__c
                                                    WHERE InsurancePolicyId__c IN :policyIds]).getRecords();

        Set<Id> billingAccountIds = new Set<Id>();

        for(Billing_Policy__c billingPolicy : billingPolicies){
            billingAccountIds.add(billingPolicy.BillingAccountID__c);
        }

        return refreshBillingShares(billingAccountIds);
    }
/**
 * @description refreshBillingSharesForBillingParticipants
 * @param billingParticipantIds 
 * @return  `List<Database.SaveResult>`
 */
    public static List<Database.SaveResult> refreshBillingSharesForBillingParticipants(Set<Id> billingParticipantIds) {
        List<Billing_Participant__c> billingParticipants = (List<Billing_Participant__c>)Security.stripInaccessible(AccessType.READABLE,[SELECT ParticipantAccountId__c, BillingAccountID__r.Id
                                                    FROM Billing_Participant__c
                                                    WHERE Id IN :billingParticipantIds]).getRecords();

        Set<Id> billingAccountIds = new Set<Id>();
        for (Billing_Participant__c billingParticipant : billingParticipants) {
            billingAccountIds.add(billingParticipant.BillingAccountID__c);
        }
        
        return refreshBillingShares(billingAccountIds);
    }
/**
 * @description refreshBillingShares
 * @param billingAccountIds 
 * @return  `List<Database.SaveResult>`
 */
    public static List<Database.SaveResult> refreshBillingShares(Set<Id> billingAccountIds) {
        Set<Billing_Account__Share> sharesForDelete = new Set<Billing_Account__Share>();
        Set<Billing_Account__Share> sharesForInsert = new Set<Billing_Account__Share>();

        // retrieve the existing shares for the given billing accounts
        List<Billing_Account__Share> existingSharesList = UTIL_BillingAccountShares.getBillingAccountShares(billingAccountIds);

        // store the existing shares in a map with a key comprised of the ParentId and UserOrGroupId
        Map<String,Billing_Account__Share> existingShares = new Map<String,Billing_Account__Share>();
        for (Billing_Account__Share existingShare : existingSharesList) {
            existingShares.put(generateBillingShareKey(existingShare), existingShare);
        }

        // generate the shares that should be persisted
        List<Billing_Policy__c> billingPolicies = UTIL_BillingAccountShares.getAllBillingPolicies(billingAccountIds);
        Set<Billing_Account__Share> billingSharesFromInsurancePolicy = UTIL_BillingAccountShares.getBillingAccountSharesForBillingPolicies(billingPolicies);
        List<Billing_Participant__c> billingParticipants = UTIL_BillingAccountShares.getAllBillingParticipants(billingAccountIds);
        Set<Billing_Account__Share> billingSharesFromCustomerAccount = UTIL_BillingAccountShares.getBillingAccountSharesForBillingParticipants(billingParticipants);
        Set<Billing_Account__Share> generatedSharesSet = UTIL_BillingAccountShares.mergeIpSharesAndAccountShares(billingSharesFromInsurancePolicy, billingSharesFromCustomerAccount);
        Map<String,Billing_Account__Share> generatedShares = new Map<String,Billing_Account__Share>();
        for (Billing_Account__Share generatedShare : generatedSharesSet) {
            generatedShares.put(generateBillingShareKey(generatedShare), generatedShare);
        }


        // find the shares that should be removed
        for (String key : existingShares.keySet()) {
            if (!generatedShares.containsKey(key)) {
                sharesForDelete.add(existingShares.get(key));
            }
        }

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
        List<Database.SaveResult> savedResults = new List<Database.SaveResult>();
        savedResults = refreshBillingSharesMethod(sharesForInsert);
        return savedResults;
    }

    private static List<Database.SaveResult> refreshBillingSharesMethod(Set<Billing_Account__Share> sharesForInsert){
        List<Database.SaveResult> savedResults = new List<Database.SaveResult>();
        if (!sharesForInsert.isEmpty()) {
            savedResults = UTIL_BillingAccountSharesAdd.insertBillingAccountShares(sharesForInsert);
        }
        return savedResults;
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

    private class UTIL_BillingAccountSharesWrapper{
        private void getBillingAccountsFromBillingParticipants(Map<Id, Set<Id>> customerAccountToBillingAccountIdsMap, Billing_Participant__c billingParticipant){
            if(customerAccountToBillingAccountIdsMap.containsKey(billingParticipant.ParticipantAccountId__c)){
                customerAccountToBillingAccountIdsMap.get(billingParticipant.ParticipantAccountId__c).add(billingParticipant.BillingAccountID__c);
            } else {
                customerAccountToBillingAccountIdsMap.put(billingParticipant.ParticipantAccountId__c, new Set<Id>{billingParticipant.BillingAccountID__c});
            }
        }
    }

}