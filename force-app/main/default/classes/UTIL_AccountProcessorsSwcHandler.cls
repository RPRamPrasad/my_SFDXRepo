/****************************************************************************************
Name: UTIL_AccountProcessorsSwcHandler
@description : Util class to handle Account Processors Signed Written Consent
Team: ClubCar
=========================================================================================
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Team ClubCar              12/21/2020              Initial Development
******************************************************************************************/
public without sharing class UTIL_AccountProcessorsSwcHandler {
    
    /**
    * @method- Invoked by UTIL_SeparateProcessor           
    * @description  This method will help us to Clear SWC Field Values if there are any on Opportunity
    * @name updateOpportunitySwc
    * @param opptyRecord - Opportunity
    * @return Opportunity
    */
    public static Opportunity updateOpportunitySwc(Opportunity opptyRecord){
        
        opptyRecord.DateCaptured__c = null;
        opptyRecord.OppSignedWrittenConsentStatus__c = null;
        opptyRecord.OppSignedWrittenConsentRequestedDate__c = null;
        opptyRecord.OppSignedWrittenConsentGrantedDate__c = null;
        
        return opptyRecord;
    }
    
    /**
    * @method- Invoked by UTIL_ChangeofAgentProcessor           
    * @description  This method will help us to Update Opportunity SWC Field Values for Change of Agent Processor
    * @name updateOpportunitySwconCoa
    * @param opptyRecord - Opportunity
    * @param winningAgentOpportunityList - Opportunity List of Winning Agent
    * @return Opportunity
    */
    public static Opportunity updateOpportunitySwconCOA(Opportunity opptyRecord, List<Opportunity> winningAgentOpportunityList){
        
        if(winningAgentOpportunityList != null && !winningAgentOpportunityList.isEmpty()){
            return updateLosingAgentOppSwconCoa(opptyRecord,winningAgentOpportunityList);
        }
        else{
            return updateOpportunitySwc(opptyRecord);
        }
    }
    
    /**
    * @method- Invoked by UTIL_ChangeofAgentProcessor           
    * @description  This method will help us to get winning agent opportunity list
    * @name getWinningAgentOpportunityList
    * @param accountId - Account Id
    * @param newAgentProxyId - new agent proxy user Id
    * @return List<Opportunity>
    */
    public static List<Opportunity> getWinningAgentOpportunityList (Id accountId, Id newAgentProxyId){
        
        List<Opportunity> winningAgentOpportunityList = [Select OppSignedWrittenConsentStatus__c,OppSignedWrittenConsentRequestedDate__c                                             
                                                         ,OppSignedWrittenConsentGrantedDate__c,DateCaptured__c FROM opportunity where AccountId=:accountId AND OwnerId =:newAgentProxyId WITH SECURITY_ENFORCED];
        return winningAgentOpportunityList;
    }
    
    /**
    * @method- Invoked by UTIL_CombineProcessor           
    * @description  This method will help us to Update Swc Fields on Losing Account Opportunites, 
    * 				cancel Swc Tasks and update Swc Records				
    * @name processSwcOnCombine
    * @param winningAccount - Winning Account
    * @param losingAccountOpportunityList - Losing Account Opportunity List
    * @param swcUpdateList - Signed Written Consent List
    */
    public static void processSwcOnCombine(Account winningAccount,List<Opportunity>losingAccountOpportunityList,List<SignedWrittenConsent__c> swcUpdateList){
        List<Opportunity> winningAccountOpportunityList = new List<Opportunity>();
        winningAccountOpportunityList.addAll(winningAccount.Opportunities);
        Set<Id> losingAccountOppIdSet = updateLosingAccountOpportunitiesSwc(winningAccountOpportunityList,losingAccountOpportunityList);
        cancelSwcTasks(losingAccountOppIdSet);
        updateSwcRecordsToNotApplicable(swcUpdateList,losingAccountOppIdSet);
    }    
    
    //Helper method to Update Opportunity SWC Field Values if Winning Account Opportunities Office
    //exist in Losing Account Opportunities on Combine Processor
    private static Set<Id> updateLosingAccountOpportunitiesSwc(List<Opportunity> winningAccountOpportunityList, List<Opportunity>losingAccountOpportunityList){
        Map<Id,Opportunity> oppOwnerIdToOpportunityMap = getOwnerIdToOpportunityMap(winningAccountOpportunityList);
        List<Opportunity> opptySwcUpdateList = new List<Opportunity>();
        Set<Id> losingAccountOppIdSet = new Set<Id>();
        for(Opportunity opptyToUpdate : losingAccountOpportunityList){
            if(oppOwnerIdToOpportunityMap.get(opptyToUpdate.OwnerId) != null){
                Opportunity opptyRecord = oppOwnerIdToOpportunityMap.get(opptyToUpdate.OwnerId);
                opptyToUpdate.DateCaptured__c = opptyRecord.DateCaptured__c;
                opptyToUpdate.OppSignedWrittenConsentStatus__c = opptyRecord.OppSignedWrittenConsentStatus__c;
                opptyToUpdate.OppSignedWrittenConsentRequestedDate__c = opptyRecord.OppSignedWrittenConsentRequestedDate__c;
                opptyToUpdate.OppSignedWrittenConsentGrantedDate__c = opptyRecord.OppSignedWrittenConsentGrantedDate__c;
                losingAccountOppIdSet.add(opptyToUpdate.Id);
                opptySwcUpdateList.add(opptyToUpdate);
            }
        }
        UTIL_OpportunityDAO.updateOpportunityForAccount(opptySwcUpdateList);
        
        return losingAccountOppIdSet;
    }
    
    /**
    * @method- Invoked by UTIL_ChangeofAgentProcessor, UTIL_CombineProcessor and UTIL_RemoveFromBookProcessor      
    * @description  This method will help us to update signed written consent records to Not Applicable
    * @name updateSwcRecordsToNotApplicable
    * @param swcUpdateList - SignedWrittenConsent List
    * @param oppIdSet - Opportunity Id Set
    */
    public static void updateSwcRecordsToNotApplicable(List<SignedWrittenConsent__c> swcUpdateList, Set<Id> oppIdSet){
        List<SignedWrittenConsent__c> swcListToUpdate = new List<SignedWrittenConsent__c>();
        for(SignedWrittenConsent__c swcRecord :swcUpdateList){
            if(oppIdSet.contains(swcRecord.InitiatedFromId__c)){            
                swcRecord.Status__c = 'Not Applicable';
                swcListToUpdate.add(swcRecord);
            }
        }
        updateSignedWrittenConsent(swcListToUpdate);       
    }
    
    //Helper method to update opportunity swc values to match winning agent opportunity
    private static Opportunity updateLosingAgentOppSwconCOA(Opportunity opptyRecord, List<Opportunity> winningAgentOpportunityList){
        
        opptyRecord.DateCaptured__c = winningAgentOpportunityList[0].DateCaptured__c;
        opptyRecord.OppSignedWrittenConsentStatus__c = winningAgentOpportunityList[0].OppSignedWrittenConsentStatus__c;
        opptyRecord.OppSignedWrittenConsentRequestedDate__c = winningAgentOpportunityList[0].OppSignedWrittenConsentRequestedDate__c;
        opptyRecord.OppSignedWrittenConsentGrantedDate__c = winningAgentOpportunityList[0].OppSignedWrittenConsentGrantedDate__c;
        
        return opptyRecord;
    }
   
    //Helper method to cancel swc tasks of losing account opportunities
    private static void cancelSwcTasks(Set<Id> losingAccountOppIdSet){
        List<Task> taskToCancelList = new List<Task>();        
        for(Task taskToCancel : [Select Id FROM Task where WhatId IN: losingAccountOppIdSet AND TaskCategory__c = 'SignedWrittenConsent'
                                 AND AppCode__c = 'SFDC_MKTCLD' AND isClosed = false WITH SECURITY_ENFORCED]){
                taskToCancel.Status = 'Cancelled';
                taskToCancelList.add(taskToCancel);
        }
        UTIL_TaskDAO.updateTasks(taskToCancelList);
    }
    
    //Helper method to create a map of opportunity ownerid to opportunity
    private static Map<Id,Opportunity> getOwnerIdToOpportunityMap(List<Opportunity> winningAccountOpportunityList){        
        Map<Id,Opportunity> oppOwnerIdToOpportunityMap = new Map<Id,Opportunity>();
        for(Opportunity opptyRecord : winningAccountOpportunityList){
            oppOwnerIdToOpportunityMap.put(opptyRecord.OwnerId, opptyRecord);
        }        
        return oppOwnerIdToOpportunityMap;
    }
    
    //Helper method to update signed written consent records
    private static void updateSignedWrittenConsent(List<SignedWrittenConsent__c> swcListToUpdate){
        if(!swcListToUpdate.isEmpty() && Schema.sObjectType.SignedWrittenConsent__c.isUpdateable()){
            update swcListToUpdate;
        }
    }
    
}