/** @Name AP_HistoricalOpportunityCampaign
  * Date Created :06/10/2019
  * @Author ITIC
  * @description This is Batch_HistoricalOpportunityCampaign utility class process the Opportunity, calls 
  * the respective utility and create Campaign and Campaign Member
  */
  public with sharing class AP_HistoricalOpportunityCampaign {
    private static final String CLASS_NAME = 'AP_HistoricalOpportunityCampaign';
    private static final String PROXY_USER_TYPE = 'Agent Proxy';
    private AP_LogHolder logHolder =  new AP_LogHolder();
    private AP_CampaignBuilder campaignBuilder = new AP_CampaignBuilder();
    private AP_CampaignMemberBuilder campaignMemberBuilder = new AP_CampaignMemberBuilder();
    private AP_HistoricalOpportunityCampaignWrapper apHistOppWrap = new AP_HistoricalOpportunityCampaignWrapper();
    
    /**
     * @description this method receives input from the batch, creates the Campaign and Campaign Members
     * @param opportunityList 
     * @param request
     */                                                                     
    public void processOpportunityCampaign(List<Opportunity> opportunityList, AP_BatchReportRequest request) {
        Map<Id,String> userMap = new Map<Id,String>();
    	Map<Id,Set<Id>> userToContactIdsMap = new Map<Id,Set<Id>>();  
        Set<Id> customerId = queryCustomerRelationship(validateOpportunityCampaignWithActivity(opportunityList,request));
        for(Opportunity opportunity: opportunityList){
           if (verifyAgencyUser(opportunity)){
            userMap.put(opportunity.OwnerId, opportunity.Owner.Alias);
                if((!opportunity.Account.IsDeathNotificationReceived__pc && !customerId.contains(opportunity.AccountId))){
                    userToContactIdsMap.put(opportunity.OwnerId, collectUserContactData(opportunity,userToContactIdsMap));
                }
            }
        }                                                                     
        List<Campaign> campaignList = createCampaign (userToContactIdsMap, userMap, request);
        createCampaignMember (userToContactIdsMap, campaignList, request);
    }

    private List<Opportunity> validateOpportunityCampaignWithActivity(List<Opportunity> opportunityList, AP_BatchReportRequest request) {
        if(request.getActivityCheck()){
            // logic to filter eligible opportunity with activity due
            List<Opportunity> eligibleOpportunityList = populateEligibleOpportunity(opportunityList);
            return eligibleOpportunityList;
        }
       return opportunityList; 
    }

    private List<Opportunity> populateEligibleOpportunity(List<Opportunity> opportunityList){
        Set<Id> opportunityId = new Set<Id>();
        Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();
        for(Opportunity opportunityRecord: opportunityList){
            if(verifyAgencyUser(opportunityRecord)){
                opportunityId.add(opportunityRecord.Id);
                opportunityMap.put(opportunityRecord.Id,opportunityRecord);
            }                      
        }
        return queryAllTasksForOpportunity(opportunityId,opportunityMap);
    }

    private List<Opportunity> queryAllTasksForOpportunity(Set<Id> opportunityId, Map<Id,Opportunity> opportunityMap){
        List<Opportunity> eligibleOpportunityList = new List<Opportunity>();
        for(Opportunity opportunityRecord: [Select id,(Select id,WhatId,ActivityDate,isClosed from tasks) from Opportunity where Id=:opportunityId WITH SECURITY_ENFORCED]){
            if(CollectionUtils.isNullorEmptyList(opportunityRecord.Tasks) || verifyActivityDue(opportunityRecord.Tasks)){
                eligibleOpportunityList.add(opportunityMap.get(opportunityRecord.Id));        
            }
        }
        return eligibleOpportunityList;
    }

    private boolean verifyActivityDue(List<Task> taskList){
        for (Task taskRecord: taskList){
            if(taskRecord.ActivityDate< System.today() && !taskRecord.isClosed){
                return true;
            }
        }
        return false;
    }

    private boolean verifyAgencyUser(Opportunity opportunityRecord){
        String[] sub_User_Type_List = new String[]{'Agent','SFO','PSO','ATM','Agent Intern','ESP'};
        if (PROXY_USER_TYPE.equals(opportunityRecord.Owner.UserType__c) || sub_User_Type_List.contains(opportunityRecord.Owner.SubUserType__c)) {
            return true; 
        }
        return false;
    }

    private List<Campaign> createCampaign(Map<Id,Set<Id>> usersToAccountIdsMap, Map<Id,String> userMap, AP_BatchReportRequest request){
        List<Campaign> campaignList =  campaignBuilder.buildCampaignsForHistoricalOpportunitiesReport(usersToAccountIdsMap, userMap, request);
        return upsertCampaign (campaignList);
    }

    private void createCampaignMember(Map<Id,Set<Id>> usersToAccountIdsMap, List<Campaign> campaignList, AP_BatchReportRequest request) {
        List<CampaignMember> campaignMemberList = campaignMemberBuilder.buildContactCampaignMembersFromCampaignOwner(usersToAccountIdsMap, campaignList);
        insertCampaignMember (campaignMemberList, request);
    }

    private Set<Id> queryCustomerRelationship(List<Opportunity> opportunityList) {
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> customerIdSet = new Set<Id>();
        customerIdSet = apHistOppWrap.queryCustomerRelationship(opportunityList, accountIdSet, customerIdSet);
        for(AgentRole__c agentRole:[SELECT Customer__c from AgentRole__c WHERE Customer__c IN :accountIdSet AND RelationshipNature__c ='Customer' WITH SECURITY_ENFORCED]){
            customerIdSet.add(agentRole.Customer__c);
        }
        return customerIdSet;
    }

    private Set<Id> collectUserContactData(Opportunity opportunity, Map<Id,Set<Id>> userToContactIdsMap){
        Set<Id> contactSet = new Set<Id>(); 
        return apHistOppWrap.collectUserContactData(opportunity, userToContactIdsMap, contactSet);
    } 

    private List<Campaign> upsertCampaign (List<Campaign> newCampaignList) {
        Savepoint commitSavePoint = Database.setSavepoint();
        List<Campaign> campaignSuccessList = new List<Campaign>(); 
        AP_HistoricalOpportunityWrapper apHistWrap = new AP_HistoricalOpportunityWrapper();
        apHistWrap.log_Holder = logHolder;
        apHistWrap.commitSavePoint = commitSavePoint;
        return apHistOppWrap.upsertCampaign(newCampaignList, campaignSuccessList, apHistWrap); 
    }
    /**
     * @description this method performs the DML update operation
     * @param updateCampaignList 
     */
    public void updateCampaign (List<Campaign> updateCampaignList) {
        Savepoint commitSavePoint = Database.setSavepoint();
        List<Campaign> campaignSuccessList = new List<Campaign>();
        try {
            List<Database.Saveresult> upsertCampaignResultList = Database.update(updateCampaignList, false);
            for (Integer i = 0; i < updateCampaignList.size(); i++) {
                if(!upsertCampaignResultList[i].isSuccess()) {
                    String errorMessage = updateCampaignList[i].Id + UTIL_Constants.COLON_SYMBOL+upsertCampaignResultList[i].getErrors();
                    logHolder.error(CLASS_NAME, errorMessage.substring(0, Math.min(errorMessage.length(), 254))); 
                } else{
                    campaignSuccessList.add(updateCampaignList[i]);
                }
            }
            if (logHolder!=null){
                logHolder.writeToLogExceptionObject();
            } 
        } catch(Exception e){
            Database.rollback(commitSavePoint);
            throw e;
        }  
    }

    private void insertCampaignMember (List<CampaignMember> newCampaignMemberList, AP_BatchReportRequest request) {
        Savepoint commitSavePoint = Database.setSavepoint();
        try {
            List<Database.UpsertResult> insertCampaignMemberResultList = Database.upsert(newCampaignMemberList, false); 
            for (Integer i = 0; i < newCampaignMemberList.size(); i++) {
                if(!insertCampaignMemberResultList[i].isSuccess()) {
                    String errorMessage = insertCampaignMemberResultList[i].Id + UTIL_Constants.COLON_SYMBOL+insertCampaignMemberResultList[i].getErrors();
                    logHolder.error(request.getBatchName(), errorMessage.substring(0, Math.min(errorMessage.length(), 254))); 
                } 
            }
            if (logHolder!=null){
                logHolder.writeToLogExceptionObject();
            }
        } catch(Exception e){
            Database.rollback(commitSavePoint);
            throw e;
        }  
    }

private class AP_HistoricalOpportunityWrapper{
    private AP_LogHolder log_Holder;
    Savepoint commitSavePoint;
}
    private with sharing class AP_HistoricalOpportunityCampaignWrapper{
        private List<Campaign> upsertCampaign (List<Campaign> newCampaignList, List<Campaign> campaignSuccessList, AP_HistoricalOpportunityWrapper apWrap) {
        try {
            List<Database.UpsertResult> upsertCampaignResultList = Database.upsert(newCampaignList, Campaign.Name, false); 
            for (Integer i = 0; i < newCampaignList.size(); i++) {
                if(!upsertCampaignResultList[i].isSuccess()) {
                    String errorMessage = newCampaignList[i].Id + UTIL_Constants.COLON_SYMBOL+upsertCampaignResultList[i].getErrors();
                    apWrap.log_Holder.error(CLASS_NAME, errorMessage.substring(0, Math.min(errorMessage.length(), 254))); 
                } else{
                    campaignSuccessList.add(newCampaignList[i]);
                }
            }
            if (apWrap.log_Holder!=null){
                apWrap.log_Holder.writeToLogExceptionObject();
            } 
            return campaignSuccessList;
        } catch(Exception e){
            Database.rollback(apWrap.commitSavePoint);
            throw e;
        }  
    }

        private Set<Id> queryCustomerRelationship(List<Opportunity> opportunityList, Set<Id> accountIdSet, Set<Id> customerIdSet){
            for (Opportunity opportunity: opportunityList){
                if(!opportunity.Account.IsDeathNotificationReceived__pc){
                    accountIdSet.add(opportunity.accountId);
                }
            }
            return customerIdSet;
        }
        
		private Set<Id> collectUserContactData(Opportunity opportunity, Map<Id,Set<Id>> userToContactIdsMap, Set<Id> contactSet ){
        Set<Id> contact_Set = contactSet;
        if(userToContactIdsMap.isEmpty() || !userToContactIdsMap.containsKey(Opportunity.OwnerId)){
            contact_Set.add(opportunity.Account.PersonContactId);
            return contact_Set;
        } else {
            contact_Set = userToContactIdsMap.get(Opportunity.OwnerId); 
            contact_Set.add(opportunity.Account.PersonContactId);
            return contact_Set;
        }
        }
    }
}
