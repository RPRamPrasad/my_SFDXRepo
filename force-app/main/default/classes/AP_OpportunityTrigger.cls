/**
* @Author         : ITIC
* @description    : AP_OpportunityTrigger - Trigger handler class for Opportunity Object.
* @Last Updated   : Akita - 3/26/19 (Added functionality to auto-populate opportunity type and RelationshipToStateFarm field)
*/

public without sharing class AP_OpportunityTrigger {

    //variable to prevent recursive firing of logic on trigger
    @TestVisible private static boolean runOnce = true;
    @TestVisible private static boolean isButtonExecuted = true;
    public static final String CUSTOMER_RELATIONSHIP = 'Customer';
    public static final String EX_CUSTOMER_RELATIONSHIP = 'Ex-Customer';
    public static final String PROSPECT_RELATIONSHIP = 'Prospect';
    public static final String OPP_TYPE_WIN_BACK = 'Win-Back';
    public static final String OPP_TYPE_EXISTING_BUSINESS = 'Existing Business';
    public static final String OPP_TYPE_NEW_BUSINESS = 'New Business';
    public static final String OPPORTUNITY_PRODUCT_FIELDS ='SELECT  Lob_Cd__c, Lob_Name__c, Product_Description__c, Product_System_Name__c, Product_Start_Date__c, Product_End_Date__c, Product_Postal_State__c';
	public static final String OPPORTUNITY_PRODUCT_FROM_OBJECT = ' FROM OpportunityProduct__c';
    private static AP_OpportunityTrigger_Wrapper opTrigWrap = new AP_OpportunityTrigger_Wrapper();

    /**
* @description EntryPoint method to set the opportunity owner to Proxy User
* @param opportunityList List<Opportunity> Opprortunity List passed from the Trigger
*/
    public static void updateOwnerWithAgentProxy(List<Opportunity> opportunityList) {

        Set<Id> accountIdSet = new Set<Id>();
        for(Opportunity opportunityObj : opportunityList) {
            accountIdSet.add(opportunityObj.AccountId);
        }

        try {
            Map<Id, Map<String, AgentRole__c>> accountAgentRolesMap = new Map<Id, Map<String, AgentRole__c>>();
            accountAgentRolesMap = assignToAccountAgentRolesMap(accountIdSet, accountAgentRolesMap);
            setAgentRelationshipBasedFields(opportunityList, accountAgentRolesMap);
            Id loggedInUserId = UserInfo.getUserId();
            Id loggedInProfileId = UserInfo.getProfileId();

            if(loggedInProfileId!=null) {
                Profile loggedInUserProfile = [Select Name from Profile where Id=:loggedInProfileId];
                if(loggedInUserProfile!=null && UTIL_Constants.AGENT_PROFILE_NAME.equals(loggedInUserProfile.Name) || UTIL_Constants.ATM_PROFILE_NAME.equals(loggedInUserProfile.Name)) {

                    User agentProxy = UTIL_AgentProxySelection.retrieveProxyForLoggedInAgentOrATM(loggedInUserId);

                    if(agentProxy !=null) {
                        OpportunityOwnerForAgentAtm agentAtm = new OpportunityOwnerForAgentAtm();
                        agentAtm.agentId = loggedInUserId;
                        agentAtm.agentProxy = agentProxy;
                        agentAtm.opportunityList = opportunityList; 
                        agentAtm.accountAgentRolesMap = accountAgentRolesMap;
                        setOpportunityOwnerForAgentAtm(agentAtm);
                    }else {
                        UTIL_AgentProxySelection.tagAllErrors(opportunityList, System.Label.CL_PROXY_NOT_FOUND_ERROR);
                    }
                }
            }

        }catch(Exception exceptionObj) {
            UTIL_AgentProxySelection.tagAllErrors(opportunityList, exceptionObj.getMessage());
        }
    }//method

    /**
     * @description assignToAccountAgentRolesMap
     * @param accountIdSet 
     * @param accountAgentRolesMap 
     * @return  `Map<Id, Map<String, AgentRole__c>>`
     */
    private static Map<Id, Map<String, AgentRole__c>> assignToAccountAgentRolesMap(Set<Id> accountIdSet,  Map<Id, Map<String, AgentRole__c>> accountAgentRolesMap){
        return opTrigWrap.assignToAccountAgentRolesMap(accountIdSet, accountAgentRolesMap);
    }

    /*
* Helper method to check the Agent role relationship and set the Proxy Owner
* @param Id Salesforce Id of the Agent record
* @param User Agent Proxu Yser
* @param List<Opportunity> the input opportunities to be updated
* @param Map<Id, Map<Id, AgentRole__c> helper collection containing AccountId and the Agent role map for that account
* @return void
*/
    private static void setOpportunityOwnerForAgentAtm(OpportunityOwnerForAgentAtm agentAtm) {                
        opTrigWrap.setOpportunityOwnerForAgentAtm(agentAtm);
    }//set Opportunity Owner
    /**
     * @description setOriginalOwner
     * @param opportunityList 
     */
    public static void setOriginalOwner(List<Opportunity> opportunityList) {
        opTrigWrap.setOriginalOwner(opportunityList);
    }
    /*
* Helper method to set the Opportunity Type and RelationshipToStateFarm fields
* @param Map<Id, Map<String, AgentRole__c>> map of account ids to agent role maps
* @param List<Opportunity> the input opportunities to be updated
* @return void
*/
    private static void setAgentRelationshipBasedFields(List<Opportunity> opportunityList, Map<Id, Map<String, AgentRole__c>> accountAgentRolesMap){
        //value mapping of relationship nature & relationship to state farm
        Map<String,String> relationshipNatureToStateFarmMapping = new Map<String,String>{EX_CUSTOMER_RELATIONSHIP => OPP_TYPE_WIN_BACK,
            CUSTOMER_RELATIONSHIP => OPP_TYPE_EXISTING_BUSINESS, PROSPECT_RELATIONSHIP => OPP_TYPE_NEW_BUSINESS};
        Map<Id,String> oppOwnerToAgentMap = mapOpportunityOwnerIdsToAgentExternalIds(opportunityList);

        if(!accountAgentRolesMap.isEmpty()) {
            for (Opportunity opp : opportunityList) {
                Map<String, AgentRole__c> agentRolesMap = accountAgentRolesMap.get(opp.AccountId);
                List<String> relationshipNatures = new List<String>();
                if (!agentRolesMap.isEmpty()) {
                    for (AgentRole__c agentRole : agentRolesMap.values()) {
                        relationshipNatures.add(agentRole.RelationshipNature__c);
                    }
                CheckRelationshipNaturesIsEmptyWrapper relationshipWrapper = new CheckRelationshipNaturesIsEmptyWrapper();
                relationshipWrapper.opp = opp;
                relationshipWrapper.oppOwnerToAgentMap = oppOwnerToAgentMap;
                relationshipWrapper.agentRolesMap = agentRolesMap;
                relationshipWrapper.relationshipNatureToStateFarmMapping = relationshipNatureToStateFarmMapping;
                checkRelationshipNaturesIsEmpty(relationshipNatures, opportunityList, relationshipWrapper);
            	} else {
                	setFieldsWhenOnlyRelationshipIsNew(opportunityList);
                }
        }
    } else {
            setFieldsWhenOnlyRelationshipIsNew(opportunityList);
    }
}

/**
 * @description CheckRelationshipNaturesIsEmptyWrapper
 */
class CheckRelationshipNaturesIsEmptyWrapper{
    Opportunity opp; 
    Map<Id,String> oppOwnerToAgentMap;
    Map<String, AgentRole__c> agentRolesMap;
    Map<String,String> relationshipNatureToStateFarmMapping;
}

private static void checkRelationshipNaturesIsEmpty(List<String> relationshipNatures, List<Opportunity> opportunityList, CheckRelationshipNaturesIsEmptyWrapper relationWrapper){
    if(!relationshipNatures.isEmpty()) {
        relationshipNatures.sort();
        if (null != relationshipNatures.get(0)){
            relationWrapper.opp.Relationship_to_State_Farm__c = relationshipNatures.get(0);
            if (relationWrapper.oppOwnerToAgentMap.containsKey(relationWrapper.opp.OwnerId) && (null != relationWrapper.agentRolesMap.get(relationWrapper.oppOwnerToAgentMap.get(relationWrapper.opp.OwnerId)))) {
                String relationshipNature = relationWrapper.agentRolesMap.get(relationWrapper.oppOwnerToAgentMap.get(relationWrapper.opp.OwnerId)).RelationshipNature__c;
                relationWrapper.opp.Type = relationWrapper.relationshipNatureToStateFarmMapping.get(relationshipNature);
            } else {
                relationWrapper.opp.Type = OPP_TYPE_NEW_BUSINESS;
            }
        } else {
            setFieldsWhenOnlyRelationshipIsNew(opportunityList);
        }
    } else {
        setFieldsWhenOnlyRelationshipIsNew(opportunityList);
    }
}

    /*
* Helper method to map opportunity owner Ids to their corresponding agent external Ids
* @param List<Opportunity> list of opportunities from which to obtain owner Id
* @return Map<Id,String> returns populated map
*/
    private static Map<Id,String> mapOpportunityOwnerIdsToAgentExternalIds(List<Opportunity> opportunityList) {
        return opTrigWrap.mapOpportunityOwnerIdsToAgentExternalIds(opportunityList);
    }

     /** 
* @description Helper method to map Update Product_System_Name__c based on Requested_Effective_Date__c
* @param updatedOpportunity
* @param oldOpportunity
* @return Opportunity
*/
    public static Opportunity updateOpportunityPSPBasedOnEffectivedate(Opportunity updatedOpportunity, Opportunity oldOpportunity) {
        String oppLOB;
        String oppPROD;
        Date oppREDATE;
        List<OpportunityProduct__c> objOpportunityProduct = new List<OpportunityProduct__c>();
        oppLOB = updatedOpportunity.LOB__c;
        oppPROD = updatedOpportunity.Product__c;
        oppREDATE = updatedOpportunity.Requested_Effective_Date__c;

		String whereCondition = ' where Lob_name__c = :oppLOB AND Product_Description__c = :oppPROD AND' +
                                    ' Product_Start_Date__c <=  :oppREDATE AND' +
                                    ' Product_End_Date__c >= :oppREDATE AND' +
                                    ' Product_Postal_State__c =  :stateCode LIMIT 1';
        String stateCode;
        if(updatedOpportunity.Requested_Effective_Date__c != null && updatedOpportunity.Requested_Effective_Date__c != oldOpportunity.Requested_Effective_Date__c && updatedOpportunity.State_Code__c != null) {
            stateCode = updatedOpportunity.State_Code__c;
           if (updatedOpportunity.State_Code__c.length() > 2) {
            stateCode = updatedOpportunity.State_Code__c.substring(0,2);
           }
           String queryToExecute = OPPORTUNITY_PRODUCT_FIELDS + OPPORTUNITY_PRODUCT_FROM_OBJECT + whereCondition;
		    objOpportunityProduct = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute))).getRecords();
        }
        if(!objOpportunityProduct.isEmpty()) {
            updatedOpportunity.Product_System_Name__c = objOpportunityProduct[0].Product_System_Name__c;
        }
        return updatedOpportunity;
     }
/*
* Helper method to set opportunity type and relationship to State Farm fields when customer to agent relationship is new
* @param List<Opportunity> list of opportunities from which to obtain owner Id
* @return Map<Id,String> returns populated map
*/
    private static void setFieldsWhenOnlyRelationshipIsNew(List<Opportunity> opportunityList) {
        for (Opportunity opp: opportunityList) {
            opp.Relationship_to_State_Farm__c = PROSPECT_RELATIONSHIP;
            opp.Type = OPP_TYPE_NEW_BUSINESS;
        }
    }

    /**
     * @description checkRecursive
     * @return  `boolean`
     */
    public static boolean checkRecursive(){
        if(runOnce){
            runOnce=false;
            return true;
        }else{
            return runOnce;
        }
    }

    /**
     * @description doNotExecuteReOpenProcess
     * @return  `boolean`
     */
    public static boolean doNotExecuteReOpenProcess(){
        if(isButtonExecuted){
            isButtonExecuted=false;
            return true;
        }else{
            return isButtonExecuted;
        }
    }

    private with sharing class AP_OpportunityTrigger_Wrapper{
        private Map<Id, Map<String, AgentRole__c>> assignToAccountAgentRolesMap(Set<Id> accountIdSet,  Map<Id, Map<String, AgentRole__c>> accountAgentRolesMap){
            for(AgentRole__c agentRole : [select Id, Agent__r.UserExternalID__c, RelationshipNature__c, Customer__c from AgentRole__c where Customer__c in :accountIdSet]) {
                Map<String, AgentRole__c> agentRolesMap = accountAgentRolesMap.get(agentRole.customer__c);
                if(agentRolesMap==null) {
                    agentRolesMap = new Map<String, AgentRole__c>();
                }
                if (!String.isBlank(agentRole.Agent__r.UserExternalID__c)) {
                    agentRolesMap.put(agentRole.Agent__r.UserExternalID__c, agentRole);
                }
                accountAgentRolesMap.put(agentRole.customer__c, agentRolesMap);
            }
            return accountAgentRolesMap;
        }
        
        private void setOpportunityOwnerForAgentAtm(OpportunityOwnerForAgentAtm agentAtm) {
            User agentProxy = agentAtm.agentProxy;
            List<Opportunity> opportunityList = agentAtm.opportunityList; 
            Map<Id, Map<String,AgentRole__c>> accountAgentRolesMap = agentAtm.accountAgentRolesMap;

            for(Opportunity opp: opportunityList) {
                Map<String, AgentRole__c> agentsForThisCustomer = accountAgentRolesMap.get(opp.accountId);
                if(agentsForThisCustomer!=null ) {
                    opp.ownerId = agentProxy.id;
                }else {
                    opp.addError(System.Label.CL_AGENT_ROLE_NOT_FOUND_ERROR);
                }
            }  //for loop
        }//set Opportunity Owner
        
        private void setOriginalOwner(List<Opportunity> opportunityList) {
            for(Opportunity opportunityObj : opportunityList) {
                opportunityObj.OriginalOwner__c = opportunityObj.ownerId;
            }
        }
        
        private Map<Id,String> mapOpportunityOwnerIdsToAgentExternalIds(List<Opportunity> opportunityList) {
            Map<Id,String> oppOwnerToAgentMap = new Map<Id,String>();
            List<Id> opportunityOwnerIds = new List<Id>();
            for (Opportunity opp: opportunityList) {
                opportunityOwnerIds.add(opp.OwnerId);
            }
            List<User> proxyUsers = [SELECT Id, Servicing_Agent_External_ID__c FROM User WHERE Id IN :opportunityOwnerIds];
            for (User proxyUser : proxyUsers) {
                if (!String.isBlank(proxyUser.Servicing_Agent_External_ID__c)) {
                    oppOwnerToAgentMap.put(proxyUser.Id, proxyUser.Servicing_Agent_External_ID__c);
                }
            }
            return oppOwnerToAgentMap;
        }
    }

    private class OpportunityOwnerForAgentAtm{
        private Id agentId;
        private User agentProxy;
        private List<Opportunity> opportunityList; 
        private Map<Id, Map<String,AgentRole__c>> accountAgentRolesMap;
    }
}//class