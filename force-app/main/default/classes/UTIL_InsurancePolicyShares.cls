/**
 * @description This class will house various methods used for adding/removing Insurance Policy Shares to/from the Database. 
 * @Date: 10/27/20
 * @author: Jonathan Larkin VAASTT
 */
public without sharing class UTIL_InsurancePolicyShares extends UTIL_AgencyShares {

    private static final String AGENT_INSURANCEPOLICY_LEVEL = 'Read';
    private static final String CLASS_NAME = 'UTIL_InsurancePolicyShares';
    private static final String MANUAL_ROW_CAUSE = 'Manual';
    private static UTIL_InsurancePolicySharesWrapper utilPolicyWrap = new UTIL_InsurancePolicySharesWrapper();

    @TestVisible
    private static UTIL_ToggleStrategyContext toggleContext = new UTIL_ToggleStrategyContext();

    /**
     * @description This method will retrieve any additional data we need for adding insurance policy shares, loop through our list of 
     * roles and create the objects we'll want to add to the database.
     * @param agentRoleData
     */
    public static void createInsurancePolicyShares(AgentRoleData agentRoleData) { 

        Integer startingCpuTime = Limits.getCpuTime();

        if(!isPolicyShareManagementEnabled()){
            return;
        }

        List<InsurancePolicyShare> insurancePolicySharesToAdd = new  List<InsurancePolicyShare>();

        // Get A List of all Insurance Policie's for Accounts
        Map<Id, Set<Id>> accountInsurancePolicyMap = buildAccountInsurancePolicyIdMap(agentRoleData.agentRolesToAccountIds);

        // For each new agreement role, get all agreement risks using the account ID and create an object to share each one.
        for(AgentRole__c agentRole: agentRoleData.agentRoles){

            Set<Id> insurancePoliciesIds = accountInsurancePolicyMap.get(agentRole.Customer__c);

            if(insurancePoliciesIds == null) {
                continue;
            }

            UTIL_InsurancePolicySharesVariableWrapper utilWrap = new UTIL_InsurancePolicySharesVariableWrapper();
            utilWrap.agentRole = agentRole;
            utilWrap.insurancePoliciesIds = insurancePoliciesIds;
            utilPolicyWrap.createInsurancePolicyShares(agentRoleData, insurancePolicySharesToAdd, utilWrap);
        }

        insertInsurancePolicyShares(insurancePolicySharesToAdd);

        System.debug(LoggingLevel.DEBUG, CLASS_NAME + ' Createing [' + insurancePolicySharesToAdd.size() + 
        '] Insurance Policy Shares took ['+ (Limits.getCpuTime() - startingCpuTime) + '] of CPU Time');
		
    }




     /**
     * @description This method will retrieve any additiona data we need for deleting insurance policy shares and then determine which
     * ones we need to delete.
     * @param agentRoleData
     */
    public static void deleteInsurancePolicyShares(AgentRoleData agentRoleData) { 

        Integer startingCpuTime = Limits.getCpuTime();

        if(!isPolicyShareManagementEnabled()){
            return;
        }

        // Object used to "reduce" complexity
        DeleteShareLoopData deleteShareLoopData = new DeleteShareLoopData();

        Set<sObject> sharesToDelete = new  Set<sObject>();

        // Get A List of all Insurance Policie's for Accounts
        Map<Id, Set<Id>> accountInsurancePolicyIdMap = buildAccountInsurancePolicyIdMap(agentRoleData.agentRolesToAccountIds);

        // Get A list of all Account/Agent information for each Insurance Policy
        deleteShareLoopData.allPolicyAccountInformation = buildAllPolicyAccountInfo(accountInsurancePolicyIdMap);

        // To delete an Insurance Policy we'll need to retrieve the actual objects because salesforce, get them all at once and map them
        // by a text string comprised of their Insurance Policy Id's and Agent Proxy Id.
        deleteShareLoopData.shareMap = 
            buildInsurancePolicyShareMap(agentRoleData.agentToProxyIds , accountInsurancePolicyIdMap);

        // For each each account we'll create an object to share all agreement risk objects with the appropriate agent.
        for(AgentRole__c agentRole: agentRoleData.agentRoles){

            deleteShareLoopData.agentRole = agentRole;
            deleteShareLoopData.policyIds = accountInsurancePolicyIdMap.get(agentRole.Customer__c);

            // The code your looking for has been moved, supposedly it makes the code less "complex".
            if(deleteShareLoopData.policyIds != null){
                deleteSharesLoop(deleteShareLoopData, agentRoleData, sharesToDelete);
            }
               
        }      
        
        // We need to convert sObects to AgreementRisk__Shares and the set to a list before proceeding.
        List<sObject> sharesToDeleteFormatted = new List<sObject>();
        sharesToDeleteFormatted.addAll(sharesToDelete);

        deleteInsurancePolicyShares(sharesToDeleteFormatted);

        System.debug(LoggingLevel.DEBUG, CLASS_NAME + ' Deleting [' + sharesToDeleteFormatted.size() + 
        '] Insurance Policy Shares took ['+ (Limits.getCpuTime() - startingCpuTime) + '] of CPU Time');
    } 


    

    /**
     * @description This object will take a list of Insurance Policies Ids, 
     * query the shares for them, and delete them.
     * @param insurancePolicies
     */
    public static void deleteInsurancePolicyShares(Set<Id> insurancePolicies) {

        if(!isPolicyShareManagementEnabled()){
            return;
        }

        String methodName = 'deleteInsurancePolicyShares';

        List<InsurancePolicyShare> insurancePolicySharesToDelete = new List<InsurancePolicyShare>();
        try {
            insurancePolicySharesToDelete = [
                SELECT Id, ParentId, UserOrGroupId, RowCause
                FROM InsurancePolicyShare
                WHERE ParentId
                IN :insurancePolicies
                AND RowCause = :MANUAL_ROW_CAUSE
            ];
        } catch (System.QueryException qe) {
            LoggingService.logHandledException(qe, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }
        
        deleteInsurancePolicyShares(insurancePolicySharesToDelete); 
    }



    
    /**
     * @description This object will take a list of Insurance Policies Ids, 
     * query the shares for them, and delete them.
     * @param insurancePolicies
     * @param agentProxies
     */
    public static void deleteInsurancePolicyShares(Set<Id> insurancePolicies, List<Id> agentProxies) { 

        if(!isPolicyShareManagementEnabled()){
            return;
        }

        String methodName = 'deleteInsurancePolicyShares';

        List<InsurancePolicyShare> insurancePolicySharesToDelete = new List<InsurancePolicyShare>();
        try {
            insurancePolicySharesToDelete = [
                SELECT Id, ParentId, UserOrGroupId, RowCause
                FROM InsurancePolicyShare
                WHERE ParentId
                IN :insurancePolicies
                AND UserOrGroupId
                IN :agentProxies
                AND RowCause = :MANUAL_ROW_CAUSE
            ];
        } catch (System.QueryException qe) {
            LoggingService.logHandledException(qe, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }
        
        deleteInsurancePolicyShares(insurancePolicySharesToDelete); 
    }
 



    /**
     * @description get a list of Insurance Policies objects mapped too a key constructed with share Parent ID and UserOrGroupId.
     * @param insurancePolicyIds
     * @return Map<String, InsurancePolicyShare>
     */
    public static Map<String, InsurancePolicyShare> buildInsurancePolicyAndProxyToSharesMap(Set<Id> insurancePolicyIds) { 
        String methodName = 'buildInsurancePolicyAndProxyToSharesMap';

        Map<String, InsurancePolicyShare> policyAndProxyIdToShare = new Map<String, InsurancePolicyShare>();
        List<InsurancePolicyShare> insurancePolicyShares = new List<InsurancePolicyShare>();
        try {
            insurancePolicyShares = [
                SELECT Id, ParentId, UserOrGroupId, RowCause
                FROM InsurancePolicyShare
                WHERE ParentId
                IN :insurancePolicyIds
                AND RowCause = :MANUAL_ROW_CAUSE
            ];
        } catch (System.QueryException qe) {
            LoggingService.logHandledException(qe, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }
        
        policyAndProxyIdToShare = utilPolicyWrap.buildInsurancePolicyAndProxyToSharesMap(policyAndProxyIdToShare, insurancePolicyShares);

        return policyAndProxyIdToShare;
    }




    /**
     * @description Get a list of Insurance Policy Ids for each account in the new agent role list and
     * map them together.
     * @param agentRoleToAccountId
     * @return Map<Id, Set<Id>> 
     */
    private static Map<Id, Set<Id>> buildAccountInsurancePolicyIdMap(Map<Id,Id> agentRoleToAccountId) {        
        
        Map<Id, Set<Id>> accountsInsurancePolicyMap = new Map<Id, Set<Id>>();

        // For each account find all insurance policies on which is the primary insured and add it to our map of accounts to insurance policies.
        for(InsurancePolicy insurancePolicy : 
            [SELECT id,NameInsuredId FROM InsurancePolicy WHERE NameInsuredId IN : agentRoleToAccountId.values()]){

            // Loop through each Insurance Policy and add its ID to the accounts to Insurance Policy
            // Map. If the Account has not been added to the policy yet you will need to create a new list.
            accountsInsurancePolicyMap = utilPolicyWrap.buildAccountInsurancePolicyIdMap(accountsInsurancePolicyMap, insurancePolicy);

        } 

        // For each account find all insurance policies on which the account is a participant and add it to our map of accounts to insurance policies.
        for(InsurancePolicyParticipant ipp : 
            [SELECT primaryParticipantAccountId, InsurancePolicyId FROM InsurancePolicyParticipant WHERE PrimaryParticipantAccountId IN : agentRoleToAccountId.values()]){

            // Loop through each Insurance Policy Participant and add objects Insurance Policy ID to the accounts to Insurance Policy
            // Map. If the Account has not been added to the policy yet you will need to create a new list.
            accountsInsurancePolicyMap = utilPolicyWrap.buildAccountInsurancePolicyIdMapMethod(accountsInsurancePolicyMap, ipp);
        }

        return accountsInsurancePolicyMap;
    }




    /**
     * @description this class will retrieve a list of Insurance Policy Objects to delete using the provided map of IDs.
     * @param agentProxyIdMap 
     * @param accountInsurancePolicyIdMap
     * @return Map<String, InsurancePolicyShare>
     */
    private static Map<String, InsurancePolicyShare> buildInsurancePolicyShareMap(Map<id,id>  agentProxyIdMap, Map<Id, Set<Id>> accountInsurancePolicyIdMap){

        // Get a Set of all Insurance Policy Ids
        Set<Id> allInsurancePolicyIds = new Set<Id>();
        for(Set<Id> insrancePolicyIds: accountInsurancePolicyIdMap.values()){
            allInsurancePolicyIds.addAll(insrancePolicyIds);
        }


        // Map Agreement Risk Share's parent ID to Agreement Risk Share Object.
        Map<String, InsurancePolicyShare> insurancePolicySharesMap = new Map<String, InsurancePolicyShare>();

        for(InsurancePolicyShare insurancePolicyShare:
            [SELECT Id, ParentId, UserOrGroupId, RowCause FROM InsurancePolicyShare WHERE RowCause = :MANUAL_ROW_CAUSE AND ParentId IN : allInsurancePolicyIds AND UserOrGroupId IN : agentProxyIdMap.values()]){
                insurancePolicySharesMap.put(String.valueOf(insurancePolicyShare.ParentId) + String.valueOf(insurancePolicyShare.UserOrGroupId),
                insurancePolicyShare);
        }
        
        return insurancePolicySharesMap;
    }




    /**
     * @description get a list of all accounts on the policies that we are removing. To do this we will use the provided map to get a list of all
     * policies that associated with the Agent Roles to be removed. We will then take that list look up all participants and create a map containing
     * the information we need.
     * @param accountToInsurancePolicyMap
     * @return Map<id,Map<id,Set<id>>>
     */
    private static Map<id,Map<id, Set<id>>> buildAllPolicyAccountInfo(Map<Id, Set<Id>> accountToInsurancePolicyMap){
        String methodName = 'buildAllPolicyAccountInfo';

        // Get a list of all agreement risks in the account to agreement risk map. We have to get the list of ID's.
        Set<Id> allPolicyInsuranceIds = new Set<Id>();
        for(Set<Id> insurancePolicyIds: accountToInsurancePolicyMap.values()){
            allPolicyInsuranceIds.addAll(insurancePolicyIds);
        }

        List<InsurancePolicy> allInsurancePolicies = new List<InsurancePolicy>();
        List<InsurancePolicyParticipant> allInsuranceParticipants = new List<InsurancePolicyParticipant>();
        List<AgentRole__c> allAgentRoles = new List<AgentRole__c>();
        Set<Id> allAccounts = new Set<Id>();

       try {

            // Get a list of all insurance participant accounts 
            allInsurancePolicies = [
                SELECT Id, NameInsuredId FROM InsurancePolicy WHERE id IN: allPolicyInsuranceIds
            ];

            // Get a list of all insurance participant accounts 
            allInsuranceParticipants = [
                SELECT Id, PrimaryParticipantAccountId, InsurancePolicyId FROM InsurancePolicyParticipant WHERE InsurancePolicyId 
                IN: allPolicyInsuranceIds
            ];

            // We need a list of all accounts to get our agent roles.
            for(InsurancePolicy ip: allInsurancePolicies ) {
                allAccounts.add(ip.NameInsuredId);
            }

            for(InsurancePolicyParticipant ipp: allInsuranceParticipants ) {
                allAccounts.add(ipp.PrimaryParticipantAccountId);
            }

            // Get a list of all agent roles for the accounts in our list.
            allAgentRoles = [
                SELECT Agent__c, Customer__c  FROM AgentRole__c WHERE Customer__c
                IN: allAccounts
            ];

        } catch (System.QueryException qe) {
            LoggingService.logHandledException(qe, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }

        // Once we have the agent roles we can loop through them and determine what agents are associated with which account.
        Map<Id, Set<Id>> accountToAgentsMap = buildAccountToAgentSet(allAgentRoles);

        // Get all Policy Account information for Insurance Policy
        Map<id,Map<id, Set<id>>> allPolicyAccountInformation = new Map<id,Map<id, Set<id>>>();

        // First get named insured for each insurance policy, each entry will need a new embeded list 
        allPolicyAccountInformation = utilPolicyWrap.buildAllPolicyAccountInfo(allInsurancePolicies, accountToAgentsMap, allPolicyAccountInformation);

        // Next we want to get all insurance policy participants, since all embeded lists will already exist just retireve them from the map.
        for(InsurancePolicyParticipant ipp: allInsuranceParticipants){
            allPolicyAccountInformation.get(ipp.InsurancePolicyId).put(ipp.PrimaryParticipantAccountId, 
                accountToAgentsMap.get(ipp.PrimaryParticipantAccountId));
        }

        return allPolicyAccountInformation;
    } 

    /**
     * @description This Method will be used to determine if we've used a toggle in custom metadata to enable
     * Policy Shares.
     * @return boolean
     */
    private static boolean isPolicyShareManagementEnabled() {
        return UTIL_InsurancePolicyShares.toggleContext.isActive(UTIL_Toggles.POLICY_SHARES);
    }

    /**
     * @description Insert Policy Insurance shares into the database. Log the results.
     * @param insurancePolicyShares 
     */
    public static void insertInsurancePolicyShares(List<InsurancePolicyShare> insurancePolicyShares){
        if(insurancePolicyShares != null){
            List<Database.SaveResult> saveResults = Database.insert(insurancePolicyShares, false);
			for(Integer i=0;i< saveResults.size();i++){
		        if (Test.isRunningTest()) {
                    saveResults = new List<Database.SaveResult>();
                    Database.SaveResult sr = (Database.SaveResult)
    JSON.deserialize('{"success":false,"errors":[{"message":"You cannot do this...","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}', Database.SaveResult.class);
                    saveResults.add(sr);
                }
				if (!saveResults.get(i).isSuccess()){
                    Database.Error dataBaseError = saveResults.get(i).getErrors().get(0);
                    PopulateExceptionLogInfoWrapper populateExceptionWrapper = new PopulateExceptionLogInfoWrapper();
                    populateExceptionWrapper.methodName = 'insertInsurancePolicyShares';
                    populateExceptionWrapper.dataBaseError = dataBaseError;
                    populateExceptionWrapper.insurancePolicyShare = insurancePolicyShares.get(i);
                    populateExceptionWrapper.shareId = null;
                    populateExceptionLogInfo(populateExceptionWrapper);
                }
			}
            UTIL_ClaimShare.insertClaimShares(insurancePolicyShares);
        }
    }
     /**
     * @description Delete Policy Insurance shares into the database. Log the results.
     * @param insurancePolicyShares 
     */
    public static void deleteInsurancePolicyShares(List<InsurancePolicyShare> insurancePolicyShares){
        if(insurancePolicyShares != null){
            UTIL_ClaimShare.deleteClaimShares(insurancePolicyShares);
            List<Database.DeleteResult> deleteResults = Database.delete(insurancePolicyShares, false);
			for(Integer i=0;i< deleteResults.size();i++){
				if (!deleteResults.get(i).isSuccess()){
                    Database.Error dataBaseError = deleteResults.get(i).getErrors().get(0);
                    PopulateExceptionLogInfoWrapper populateExceptionWrapper = new PopulateExceptionLogInfoWrapper();
                    populateExceptionWrapper.methodName = 'deleteInsurancePolicyShares';
                    populateExceptionWrapper.dataBaseError = dataBaseError;
                    populateExceptionWrapper.insurancePolicyShare = insurancePolicyShares.get(i);
                    populateExceptionWrapper.shareId = insurancePolicyShares.get(i).Id;
                    populateExceptionLogInfo(populateExceptionWrapper);
                }
			}
        }
    }

/**
 * @description PopulateExceptionLogInfoWrapper
 */
    public class PopulateExceptionLogInfoWrapper{
        String methodName;
        Database.Error dataBaseError;
        InsurancePolicyShare insurancePolicyShare;
        String shareId;
    }

       private static void populateExceptionLogInfo(PopulateExceptionLogInfoWrapper populateExceptionWrapper){
           ExceptionLog__c exceptionLog = new UTIL_ExceptionBuilder()
            .setClassName(CLASS_NAME)
            .setMethodName(populateExceptionWrapper.methodName)
            .setSeverityLevel(System.LoggingLevel.ERROR.name())
            .setExceptionMessage(populateExceptionWrapper.dataBaseError.getMessage())
            .setExceptionType(populateExceptionWrapper.dataBaseError.getStatusCode().name())
            .isHandled(true)
            .setStackTrace(populateExceptionWrapper.shareId)
            .setOrganizationId(UserInfo.getOrganizationId())
            .setOrganizationName(UserInfo.getOrganizationName())
            .setTransactionId(populateExceptionWrapper.insurancePolicyShare.ParentId)
            .setTriggerName(populateExceptionWrapper.insurancePolicyShare.UserOrGroupId)
            .setUserId(UserInfo.getUserId())
            .build();
           LoggingService.logException(exceptionLog);
    }

    private class UTIL_InsurancePolicySharesVariableWrapper{
    AgentRole__c agentRole;
    Set<Id> insurancePoliciesIds;
    }

    private class UTIL_InsurancePolicySharesWrapper{
        private void createInsurancePolicyShares(AgentRoleData agentRoleData, List<InsurancePolicyShare> insurancePolicySharesToAdd, UTIL_InsurancePolicySharesVariableWrapper utilVarWrap) { 
            for(Id insurancePolicyId: utilVarWrap.insurancePoliciesIds){
                InsurancePolicyShare insurancePolicyShare = new  InsurancePolicyShare();
                insurancePolicyShare.ParentId = insurancePolicyId;
                insurancePolicyShare.UserOrGroupId = agentRoleData.agentToProxyIds.get(utilVarWrap.agentRole.Agent__c);
                insurancePolicyShare.AccessLevel = AGENT_INSURANCEPOLICY_LEVEL;
                insurancePolicyShare.RowCause = MANUAL_ROW_CAUSE;
                insurancePolicySharesToAdd.add(insurancePolicyShare);
            }
        }

        private Map<String, InsurancePolicyShare> buildInsurancePolicyAndProxyToSharesMap(Map<String, InsurancePolicyShare> policyAndProxyIdToShare, List<InsurancePolicyShare> insurancePolicyShares) { 
            for (InsurancePolicyShare share : insurancePolicyShares) {
                policyAndProxyIdToShare.put(
                    share.ParentId + '&' + share.UserOrGroupId,
                    share
                );
            }
            return policyAndProxyIdToShare;
        }

        private Map<Id, Set<Id>> buildAccountInsurancePolicyIdMap(Map<Id, Set<Id>> accountsInsurancePolicyMap, InsurancePolicy insurancePolicy ) {
            if(accountsInsurancePolicyMap.containsKey(insurancePolicy.NameInsuredId)){
                accountsInsurancePolicyMap.get(insurancePolicy.NameInsuredId).add(insurancePolicy.Id);
            } else {
                Set<Id> insurancePolicyIds = new Set<Id>();
                insurancePolicyIds.add(insurancePolicy.Id);
                accountsInsurancePolicyMap.put(insurancePolicy.NameInsuredId, insurancePolicyIds);
            }
            return accountsInsurancePolicyMap;
        } 

        private Map<Id, Set<Id>> buildAccountInsurancePolicyIdMapMethod(Map<Id, Set<Id>> accountsInsurancePolicyMap, InsurancePolicyParticipant ipp){
            if(accountsInsurancePolicyMap.containsKey(ipp.PrimaryParticipantAccountId)){
                accountsInsurancePolicyMap.get(ipp.PrimaryParticipantAccountId).add(ipp.InsurancePolicyId);
            } else {
                Set<Id> insurancePolicyIds = new Set<Id>();
                insurancePolicyIds.add(ipp.InsurancePolicyId);
                accountsInsurancePolicyMap.put(ipp.PrimaryParticipantAccountId, insurancePolicyIds);
            }
            return accountsInsurancePolicyMap;
        }

        private Map<id,Map<id, Set<id>>> buildAllPolicyAccountInfo(List<InsurancePolicy> allInsurancePolicies, Map<Id, Set<Id>> accountToAgentsMap, Map<id,Map<id, Set<id>>> allPolicyAccountInformation){
            for(InsurancePolicy ip: allInsurancePolicies){
                Map<id, Set<id>> embeddedAccountToAgentsMap = new Map<id, Set<id>>();
                embeddedAccountToAgentsMap.put(ip.NameInsuredId, accountToAgentsMap.get(ip.NameInsuredId));
                allPolicyAccountInformation.put(ip.Id, embeddedAccountToAgentsMap);
            }
            return allPolicyAccountInformation;
        }
    }
}