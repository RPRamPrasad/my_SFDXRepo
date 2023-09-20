/**********************************************************************************************************
Name: AP_JourneyTracker
Copyright © State Farm
===========================================================================================================
* @description : AP_JourneyTracker class to track Campaign and Opportunity Journeys
Team:ClubCar
===========================================================================================================
History
-------
VERSION         AUTHOR                      DATE                    DETAIL
1.0             Murali Sunkara(QPJH)        02/14/2018              Initial Development
1.1             Joel Borcherding(W9JC)      03/19/2018              Added methods for case journey tracking
1.2             ClubCar                     04/22/2019              Added logic in Opp Trigger to execute this class only once
1.3             ClubCar                     02/25/2020              Updated class from without sharing to wid sharing
***********************************************************************************************************/

public with sharing class AP_JourneyTracker {
    
    private static final String CLASS_NAME = 'AP_JourneyTracker';
    private static final String METHOD_CASEJOURNEYTRACK = 'trackCaseJourney';
    private static final String METHOD_OPPJOURNEYTRACK = 'trackOpportunityJourney';
    private static final String METHOD_CAMPJOURNEYTRACK = 'trackCampaignJourney';
    private static final String OWNER_ID = 'ownerId';
    public static Boolean afterUpdateTriggerFirstRun = true;
      
    /**
    * @method - trackCampaignJourney 
    * @description - Entry level method to track start/stop journey actions on a Campaign by inserting Campaign Journey Tracking record
    * @param actionType - Type of Journey action on the selected Campaign record: 'Journey Started' or 'Journey Stopped'
    * @param campaigns - Selected Campaign record
    */
    public static void trackCampaignJourney(String actionType, List<Campaign> campaigns){
        Map<ID,ID> ownerIdByAgentIDMap = getAgentIdMap(getOwnerIds(campaigns));        
        List<Campaign_Journey_Tracking__c> campaignJourneyTrackingList = new List<Campaign_Journey_Tracking__c>();
        for(Campaign campaign : campaigns) {
            AP_JourneyTrackerWrap wrap = new AP_JourneyTrackerWrap();
            wrap.actionType = actionType;
            wrap.campaign = campaign;
            wrap.campaignJourneyTrackingList = campaignJourneyTrackingList;
            wrap.agentId = ownerIdByAgentIDMap.get(campaign.OwnerId);
            addCampaignJourneyTracking(wrap);
        } 
        insertCampaignJourneyTrackingList(campaignJourneyTrackingList);
    }
    
    /**
    * @method - trackOpportunityJourney 
    * @description - Entry level method to track start/stop journey actions on an Opportuntiy by inserting Opportunity Journey Tracking record
    * @param actionType - Type of Journey action on the selected Opportunity record: 'Journey Started' or 'Journey Stopped'
    * @param opportunities - Selected Opportunity record
    */
    public static void trackOpportunityJourney(String actionType, List<Opportunity> opportunities) {
        String accountName;
        Map<ID,ID> ownerIdByAgentIDMap = getAgentIdMap(getOwnerIds(opportunities));
        List<Opportunity_Journey_Tracking__c> opportunityJourneyTrackingList = new List<Opportunity_Journey_Tracking__c>();
        for(Opportunity opportunity : opportunities) {
            if(opportunity.AccountId != null) {
                accountName = String.valueOf(opportunity.Account.Name);
                AP_JourneyTrackerWrapperClass wrap = new AP_JourneyTrackerWrapperClass();
                wrap.actionType = actionType;
                wrap.opportunity = opportunity;
                wrap.accountName = accountName;
                wrap.opportunityJourneyTrackingList = opportunityJourneyTrackingList;
                wrap.agentId = ownerIdByAgentIDMap.get(opportunity.OwnerId);
				addOpportunityJourneyTracking(wrap);                 
            }           
        }
        insertOpportunityJourneyTrackingList(opportunityJourneyTrackingList);
    }
    
    /**
    * @method - trackOppportunityJourneyFromTrigger 
    * @description - Entry level method to track start/stop journey actions on an RFC type Opportuntiy by inserting Opportunity Stop Journey Tracking record
    * @param actionType - Type of Journey action on the selected Opportunity record: 'Journey Stopped'
    * @param opportunities - List of opportunities
    */
    public static void trackOppportunityJourneyFromTrigger(String actionType, List<Opportunity> opportunities) {
        String accountName;
        Map<ID,ID> ownerIdByAgentIDMap = getAgentIdMap(getOwnerIds(opportunities));
        List<Opportunity_Journey_Tracking__c> opportunityJourneyTrackingList = new List<Opportunity_Journey_Tracking__c>();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([select Id, AccountId, Account.Name from Opportunity where ID IN: opportunities]);
        for(Opportunity opportunity : opportunities) {          
            if(oppMap.get(opportunity.Id).AccountId != null) {
                accountName = String.valueOf(oppMap.get(opportunity.Id).Account.Name);
                AP_JourneyTrackerWrapperClass wrap = new AP_JourneyTrackerWrapperClass();
                wrap.actionType = actionType;
                wrap.opportunity = opportunity;
                wrap.accountName = accountName;
                wrap.opportunityJourneyTrackingList = opportunityJourneyTrackingList;
                wrap.agentId = ownerIdByAgentIDMap.get(opportunity.OwnerId);
                addOpportunityJourneyTracking(wrap);
            }
        }
        insertOpportunityJourneyTrackingList(opportunityJourneyTrackingList);
    }
    
    /**
     * @method - trackCaseJourney
     * @description - Entry method to track start/stop journey actions on Case by inserting CaseJourneyTracking records
     * @param actionType - 'Journey Stopped' or 'Journey Started'
     * @param cases - List of cases
     */
    public static void trackCaseJourney(String actionType, List<Case> cases) {
        String accountName;
        String agentId;
        Map<ID,ID> ownerIdToAgentIdMap = getAgentIdMap(getOwnerIds(cases));
        List<CaseJourneyTracking__c> caseJourneyTrackingList = new List<CaseJourneyTracking__c>();
        for(Case currentCase : cases) {
            accountName = currentCase.Account.Name;
            agentId = ownerIdToAgentIdMap.get(currentCase.OwnerId);
            AP_JourneyTrackerWrapper wrapper = new AP_JourneyTrackerWrapper();
            wrapper.actionType = actionType;
            wrapper.aCase = currentCase;
            wrapper.accountName = accountName;
            wrapper.caseJourneyTrackingList = caseJourneyTrackingList;
            wrapper.agentId = agentId;
            addCaseJourneyTracking(wrapper);
        }
        insertCaseJourneyTrackingList(caseJourneyTrackingList);
    }
    private class AP_JourneyTrackerWrap{
        String actionType;
        Campaign campaign;
        List<Campaign_Journey_Tracking__c> campaignJourneyTrackingList;
        String agentId;
    }
    private static void addCampaignJourneyTracking(AP_JourneyTrackerWrap wrap) {
        Campaign_Journey_Tracking__c campaignJourneyTracking = new Campaign_Journey_Tracking__c();
        campaignJourneyTracking.Name = wrap.campaign.Journey_Name__c;   
        campaignJourneyTracking.ActionType__c = wrap.actionType;
        campaignJourneyTracking.Campaign__c = wrap.campaign.Id;
        campaignJourneyTracking.Agent__c = wrap.agentId;
        campaignJourneyTracking.OwnerId = wrap.campaign.OwnerId;
        campaignJourneyTracking.CampaignName__c = wrap.campaign.Name;
        campaignJourneyTracking.ExternalCampaignID__c = wrap.campaign.External_Campaign_ID__c;
        campaignJourneyTracking.JourneyExternalID__c = wrap.campaign.Journey_ID__c;
        wrap.campaignJourneyTrackingList.add(campaignJourneyTracking);
    }
    
    private class AP_JourneyTrackerWrapperClass{
        String actionType;
        Opportunity opportunity;
        String accountName;
        List<Opportunity_Journey_Tracking__c> opportunityJourneyTrackingList;
        String agentId;
    }

    private static void addOpportunityJourneyTracking(AP_JourneyTrackerWrapperClass wrapper) {
        Opportunity_Journey_Tracking__c opportunityJourneyTracking = new Opportunity_Journey_Tracking__c();
        opportunityJourneyTracking.Name = wrapper.opportunity.Journey_Name__c;
        opportunityJourneyTracking.AccountName__c = wrapper.accountName;
        opportunityJourneyTracking.ActionType__c = wrapper.actionType;
        opportunityJourneyTracking.Agent__c = wrapper.agentId; 
        opportunityJourneyTracking.EventCode__c = wrapper.opportunity.EventCode__c;
        opportunityJourneyTracking.JourneyExternalID__c = wrapper.opportunity.Journey_ID__c;        
        opportunityJourneyTracking.LOB__c = wrapper.opportunity.LOB__c;
        opportunityJourneyTracking.OwnerId = wrapper.opportunity.OwnerId;
        opportunityJourneyTracking.Opportunity__c = wrapper.opportunity.Id;
        opportunityJourneyTracking.OpportunityName__c = wrapper.opportunity.Name;    
        wrapper.opportunityJourneyTrackingList.add(opportunityJourneyTracking);
    }
    
    private class AP_JourneyTrackerWrapper{
        String actionType;
        Case aCase;
        String accountName;
        List<CaseJourneyTracking__c> caseJourneyTrackingList;
        String agentId;
    }

    private static void addCaseJourneyTracking(AP_JourneyTrackerWrapper wrap) {
        CaseJourneyTracking__c caseJourneyTracking = new CaseJourneyTracking__c();
        caseJourneyTracking.Name = wrap.aCase.JourneyName__c;
        caseJourneyTracking.OwnerId = wrap.aCase.OwnerId;
        caseJourneyTracking.AccountName__c = wrap.accountName;
        caseJourneyTracking.ActionType__c = wrap.actionType;
        caseJourneyTracking.Agent__c = wrap.agentId;
        caseJourneyTracking.Case__c = wrap.aCase.Id;
        caseJourneyTracking.JourneyExternalID__c = wrap.aCase.JourneyID__c;
        caseJourneyTracking.LOB__c = wrap.aCase.LOB__c;
        wrap.caseJourneyTrackingList.add(caseJourneyTracking);
    }

    private static void insertCampaignJourneyTrackingList(List<Campaign_Journey_Tracking__c> campaignJourneyTrackingList) {
        try {
            if(Schema.sObjectType.Campaign_Journey_Tracking__c.isCreateable()){                
                insert campaignJourneyTrackingList;
            }
        } catch (DMLException e) {
            LoggingService.logHandledException(e, CLASS_NAME, METHOD_CAMPJOURNEYTRACK, System.LoggingLevel.ERROR); 
            throw e;
        }      
    }
    
    private static void insertOpportunityJourneyTrackingList(List<Opportunity_Journey_Tracking__c> opportunityJourneyTrackingList) {
        try {
            if(Schema.sObjectType.Opportunity_Journey_Tracking__c.isCreateable()){
                insert opportunityJourneyTrackingList;

            }
        } catch (DMLException e) {           
            LoggingService.logHandledException(e, CLASS_NAME, METHOD_OPPJOURNEYTRACK, System.LoggingLevel.ERROR);  
            throw e;
        }
    }
    
    private static void insertCaseJourneyTrackingList(List<CaseJourneyTracking__c> caseJourneyTrackingList) {
        try {
            if(Schema.sObjectType.CaseJourneyTracking__c.isCreateable()){
                insert caseJourneyTrackingList;
            }
        } catch(DMLException e) {
            LoggingService.logHandledException(e, CLASS_NAME, METHOD_CASEJOURNEYTRACK, System.LoggingLevel.ERROR);
            throw e;
        }
    }
    
    /**
    * @method - getAgentIdMap
    * @description - Helper method to obtain Agent Id given the Agent Proxy Id owning the opportunity or campaign
    * @param ownerIds - List of Salesforce Ids of the office a.k.a agent proxy owning the opportunities or campaigns
    * @return Map<ID,ID> - Map of proxy user id to agent user id
    */
    private static Map<ID,ID> getAgentIdMap(List<Id> ownerIds) {
        Id agentId;
        List<User> agentProxyUsers = new List<User>();
        List<String> servicingAgentIds = new List<String>();
        
        Map<Id,String> ownerIdByAgentIDMap = new Map<Id,String>();
        Map<String,Id> proxyUserByAgentIdMap = new Map<String, Id>();
        
        //Collect the Users and also servicing agent Ids
        for(User agentProxyUser :  [SELECT Id, Servicing_Agent_External_ID__c FROM User WHERE Id IN :ownerIds WITH SECURITY_ENFORCED]){
            servicingAgentIds.add(agentProxyUser.Servicing_Agent_External_ID__c);
            agentProxyUsers.add(agentProxyUser);
        }
        
        //Get the agent Users by querying on User External ID field 
        for(User agentUser : [SELECT Id, UserExternalID__c  FROM User WHERE UserExternalID__c IN: servicingAgentIds 
                                                            AND SubUserType__c = :UTIL_Constants.SUB_USER_TYPE_AGENT_LIST WITH SECURITY_ENFORCED]){            
             proxyUserByAgentIdMap.put(agentUser.UserExternalID__c, agentUser.Id);
        }
        
        //Iterate over the Users and get the corresponding agents
        for(User agentProxyUser : agentProxyUsers){
            if (agentProxyUser != null && agentProxyUser.Servicing_Agent_External_ID__c != null) {
                agentId = proxyUserByAgentIdMap.get(agentProxyUser.Servicing_Agent_External_ID__c);
                ownerIdByAgentIDMap.put(agentProxyUser.Id, agentId);
            }
        }
        return ownerIdByAgentIDMap;
    }
    
    //method to collect owner Ids in a List
    private static List<Id> getOwnerIds(List<sObject> records){
        List<Id> ownerIds = new List<Id>();
        for(sObject rec : records){
            Id ownerId = (ID) rec.get(OWNER_ID);
            ownerIds.add(ownerId);
        }
        return ownerIds;
    }
}
