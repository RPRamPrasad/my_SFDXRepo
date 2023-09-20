/**
 * @description This class will house various methods used for adding Billing Account Shares to the Database. 
 * @Date: 10/25/21
 * @author: Stephen White YCDB, Jonathan Larkin VAASTT
 */
public without sharing class UTIL_BillingAccountSharesAdd extends UTIL_AgencyShares {

    private static final String ACCESS_LEVEL = 'Read';
    private static final String CLASSNAME = 'UTIL_BillingAccountSharesAdd';
    private static final String MANUAL_ROW_CAUSE = 'Manual';
    private UTIL_BillingAccountSharesAdd(){
        AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.info(CLASSNAME, 'start time of execution: ' + System.now());
        logHolder.writeToLogExceptionObject();
    }


    /**
     * @name - createBillingAccountShares
     * @description - Inserts Billing_Account__Share records from given agent role information.
     * @param agentRoleData
     */
    public static void createBillingAccountShares(AgentRoleData agentRoleData){


        // Map to track customer accounts and the billing accounts we must create.
        // Map<AccountId, Set<BillingAccountId>>
        Map<Id, Set<Id>> customerAccountToBillingAccountIdsMap = new Map<Id, Set<Id>>();

        getBillingAccountsFromPrimaryInsured(agentRoleData, customerAccountToBillingAccountIdsMap);
        UTIL_BillingAccountShares.getBillingAccountsFromBillingParticipants(agentRoleData.agentRolesToAccountIds.values(), customerAccountToBillingAccountIdsMap);

        // Create Shares to those Billing Accounts
        createBillingSharesFromCustomerAccountToBillingAccountIdsMap(agentRoleData, customerAccountToBillingAccountIdsMap);


    } 

    @TestVisible
    private static void getBillingAccountsFromPrimaryInsured(AgentRoleData agentRoleData, Map<Id, Set<Id>> customerAccountToBillingAccountIdsMap){

        Map<Id, Set<id>> customerAccountsToPoliciesMap = new Map<Id, Set<id>>(); 
        Map<Id, Set<id>> policiesToBillingAccountsMap = new Map<Id, Set<id>>(); 
        Set<Id> insurancePolicyIds = new Set<Id>();

        updateMapWithInsurancePolicyData(agentRoleData, customerAccountsToPoliciesMap, insurancePolicyIds);
        updateMapWithInsurancePolicyParticipantData(agentRoleData, customerAccountsToPoliciesMap, insurancePolicyIds);
        updateMapWithBillingPolicyData(policiesToBillingAccountsMap, insurancePolicyIds);
        updateBillingAccountToPolicyMap(customerAccountToBillingAccountIdsMap, customerAccountsToPoliciesMap, policiesToBillingAccountsMap);

    }

    @TestVisible
    private static void updateMapWithInsurancePolicyData(AgentRoleData agentRoleData, Map<Id, Set<id>> customerAccountsToPoliciesMap, Set<Id> insurancePolicyIds) {
        for( InsurancePolicy policy:
         (List<InsurancePolicy>)Security.stripInaccessible(AccessType.READABLE,[SELECT id,NameInsuredId FROM InsurancePolicy WHERE NameInsuredId IN :agentRoleData.agentRolesToAccountIds.values()]).getRecords()){
             
            insurancePolicyIds.add(policy.id);

            if(customerAccountsToPoliciesMap.containsKey(policy.NameInsuredId)){
                customerAccountsToPoliciesMap.get(policy.NameInsuredId).add(policy.Id);
            } else {
                customerAccountsToPoliciesMap.put(policy.NameInsuredId, new Set<Id>{policy.Id});
            }
         }
    }

    @TestVisible
    private static void updateMapWithInsurancePolicyParticipantData(AgentRoleData agentRoleData, Map<Id, Set<id>> customerAccountsToPoliciesMap, Set<Id> insurancePolicyIds) {
        for( InsurancePolicyParticipant policyParticipant:
         (List<InsurancePolicyParticipant>)Security.stripInaccessible(AccessType.READABLE,[SELECT PrimaryParticipantAccountId, InsurancePolicyId FROM InsurancePolicyParticipant WHERE PrimaryParticipantAccountId IN :agentRoleData.agentRolesToAccountIds.values()]).getRecords()){
        
            insurancePolicyIds.add(policyParticipant.InsurancePolicyId);

            if(customerAccountsToPoliciesMap.containsKey(policyParticipant.PrimaryParticipantAccountId)){
                customerAccountsToPoliciesMap.get(policyParticipant.PrimaryParticipantAccountId).add(policyParticipant.InsurancePolicyId);
            } else {
                customerAccountsToPoliciesMap.put(policyParticipant.PrimaryParticipantAccountId, new Set<Id>{policyParticipant.InsurancePolicyId});
            }
         }
    }

    @TestVisible
    private static void updateMapWithBillingPolicyData(Map<Id, Set<id>> policiesToBillingAccountsMap, Set<Id> insurancePolicyIds) {
        // Get a list of billing account Ids based on our set of InsurancePolicyIds 
        for(Billing_Policy__c billingPolicy : (List<Billing_Policy__c>)Security.stripInaccessible(AccessType.READABLE,[SELECT BillingAccountID__c, InsurancePolicyId__c FROM Billing_Policy__c WHERE InsurancePolicyId__c IN :insurancePolicyIds]).getRecords()){
            
            if(policiesToBillingAccountsMap.containsKey(billingPolicy.InsurancePolicyId__c)) {
                policiesToBillingAccountsMap.get(billingPolicy.InsurancePolicyId__c).add(billingPolicy.BillingAccountID__c);
            } else {
                policiesToBillingAccountsMap.put(billingPolicy.InsurancePolicyId__c, new Set<Id>{billingPolicy.BillingAccountID__c});
            }
        }
    }

    private static void updateBillingAccountToPolicyMap(Map<Id, Set<Id>> customerAccountToBillingAccountIdsMap, 
            Map<Id, Set<id>> customerAccountsToPoliciesMap, Map<Id, Set<id>> policiesToBillingAccountsMap) {
        // Use both maps to determine what Billing Account is Associated with What Policy        
        for (Id customerAccountId : customerAccountsToPoliciesMap.keySet()) {
            for (Id policyId : customerAccountsToPoliciesMap.get(customerAccountId)) {
                if(policiesToBillingAccountsMap.get(policyId) != null) {
                    customerAccountToBillingAccountIdsMap.put(customerAccountId, policiesToBillingAccountsMap.get(policyId));
                } 
            }
        }
    }

    @TestVisible
    private static Integer createBillingSharesFromCustomerAccountToBillingAccountIdsMap(AgentRoleData agentRoleData, Map<Id, Set<Id>> customerAccountToBillingAccountIdsMap){
        Set<Billing_Account__Share> billingAccountSharesToAddSet = new Set<Billing_Account__Share>();

        for(AgentRole__c agentRole: agentRoleData.agentRoles){

            Set<Id> billingAccountIds = customerAccountToBillingAccountIdsMap.get(agentRole.Customer__c);

            if(billingAccountIds == null) {
                continue;
            }

            for(Id billingAccountId: billingAccountIds){
                Billing_Account__Share billingAccountShare = new  Billing_Account__Share();
                billingAccountShare.ParentId = billingAccountId;
                billingAccountShare.UserOrGroupId = agentRoleData.agentToProxyIds.get(agentRole.Agent__c);
                billingAccountShare.AccessLevel = ACCESS_LEVEL;
                billingAccountShare.RowCause = MANUAL_ROW_CAUSE;
                billingAccountSharesToAddSet.add(billingAccountShare);
            }
        }

        insertBillingAccountShares(billingAccountSharesToAddSet);     

        return billingAccountSharesToAddSet.size();
    }

    /**
     * @description Insert Billing Account shares into the database. Log the results.
     * @param billingAccountSharesToAdd
     * @return List<Database.SaveResult> 
     */
    public static List<Database.SaveResult> insertBillingAccountShares(Set<Billing_Account__Share> billingAccountSharesToAdd){
        if(billingAccountSharesToAdd != null){
            List<Billing_Account__Share> billingAccountSharesToSaveList = new List<Billing_Account__Share>(billingAccountSharesToAdd);
            List<Database.SaveResult> saveResults = Database.insert(Security.stripInaccessible(AccessType.READABLE, billingAccountSharesToSaveList, true).getRecords(), false);
            LoggingService.logDatabaseResult(saveResults, billingAccountSharesToSaveList, CLASSNAME, 'insertBillingAccountShares', System.LoggingLevel.ERROR);
            return saveResults;
        }
        return new List<Database.SaveResult>();
    }
}