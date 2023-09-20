/**
  * @name Batch_CampaignMemberAssignUpdate
  * @author Team Incognito
  * @createdDate 06/19/2022
  * @description Batch class to update the AssignedTo__c field on Campaign Member records where the Assigned User is no longer associated with the agent's office.
*/

public with sharing class Batch_CampaignMemberAssignUpdate implements Database.Batchable<sObject>, Database.StateFul {
  private static final String BATCH_CLASS_NAME = 'Batch_CampaignMemberAssignUpdate';
  private static final String BATCH_EXECUTE_METHOD = 'execute';
  private static final String BATCH_FINISH_METHOD = 'finish';
  private List<CampaignMember> campaignMembersUpdated = new List<CampaignMember>();

  /**
   * @description start
   * @param bc 
   * @return  `Database.QueryLocator`
  */

  public Database.QueryLocator start(Database.BatchableContext bc){
    String queryString = 'Select Id, AssignedTo__c, CampaignId' + ' from CampaignMember ' + 
                          ' where AssignedTo__c != \'\'' + ' and AssignedTo__r.FederationIdentifier = \'\' ';
    return Database.getQueryLocator(queryString);
  }

  /**
   * @description execute 
   * @param bc 
   * @param campaignMemberList 
  */

  public void execute (Database.BatchableContext bc, List<CampaignMember> campaignMemberList){
      
      List<CampaignMember> campaignMembersForUpdateList = new List<CampaignMember>();
      
      for(CampaignMember campaignMember : campaignMemberList){
          campaignMember.AssignedTo__c = null;
          campaignMembersForUpdateList.add(campaignMember);
      }

      try {
        
        if (!campaignMembersForUpdateList.isEmpty()) {
          Database.SaveResult[] updateCampaignMemberResults = Database.update(campaignMembersForUpdateList, false);
          for (Integer i = 0; i < campaignMembersForUpdateList.size(); i++) {
            if(updateCampaignMemberResults[i].isSuccess()){
              campaignMembersUpdated.add(campaignMembersForUpdateList[i]);
            } 
          }
          LoggingService.logDatabaseResult(updateCampaignMemberResults, campaignMembersForUpdateList, BATCH_CLASS_NAME, BATCH_EXECUTE_METHOD, System.LoggingLevel.ERROR);
        }

      } catch(DMLException e){
          LoggingService.logHandledException(e, BATCH_CLASS_NAME, BATCH_EXECUTE_METHOD, System.LoggingLevel.ERROR);
      }
}
  
  /**
   * @description finish
   * @param bc
  */

  public void finish (Database.BatchableContext bc){
    
    Map<String, Campaign> campaignForUpdateMap = new Map<String, Campaign>();

    for(CampaignMember cm : campaignMembersUpdated) {
      String key = cm.CampaignId;
      if(!campaignForUpdateMap.containsKey(key)){
        Campaign campaignForUpdate = new Campaign();
        campaignForUpdate.Id = cm.CampaignId;
        campaignForUpdate.CampaignMemberAssignmentChanged__c = true;
        campaignForUpdateMap.put(key,campaignForUpdate);
      }
    }
    
    try {
      if (!campaignForUpdateMap.isEmpty()){
        Database.SaveResult[] updateCampaignResults = Database.update(campaignForUpdateMap.values(), false);
        LoggingService.logDatabaseResult(updateCampaignResults, campaignForUpdateMap.values(), BATCH_CLASS_NAME, BATCH_FINISH_METHOD, System.LoggingLevel.ERROR);
      }

    } catch(DMLException e){
        LoggingService.logHandledException(e, BATCH_CLASS_NAME, BATCH_FINISH_METHOD, System.LoggingLevel.ERROR);
    }

    Batch_CampaignAssignUpdate campaignAssignUpdate = new Batch_CampaignAssignUpdate ();
    Database.executebatch(campaignAssignUpdate,200);
  }

}