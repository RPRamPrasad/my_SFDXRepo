/**
  * @name Batch_CampaignAssignUpdate
  * @author Team Incognito
  * @createdDate 07/10/2022
  * @description Batch class to update the related "assigned" fields on Campaign when an "assigned" user is no longer associated with the agent's office.
*/

public with sharing class Batch_CampaignAssignUpdate  implements Database.Batchable<sObject> {
  private static final String BATCH_CLASS_NAME = 'Batch_CampaignAssignUpdate';
  private static final String BATCH_EXECUTE_METHOD = 'execute';

  /**
   * @description start
   * @param bc 
   * @return  `Database.QueryLocator`
  */

  public Database.QueryLocator start(Database.BatchableContext bc){
    String queryString = 'SELECT Id FROM Campaign WHERE CampaignMemberAssignmentChanged__c = true';
    return Database.getQueryLocator(queryString);
  }

  /**
   * @description execute 
   * @param bc 
   * @param campaignList 
  */

  public void execute (Database.BatchableContext bc, List<Campaign> campaignList){
      
      List<Campaign> campaignForUpdateList = new List<Campaign>();
      
      try {
        for(Campaign campaign : campaignList){
          List<AggregateResult> campaignMemberAssignedToCounts = CampaignAssignToDataAccess.retrieveCampaignMemberAssignedToCounts(campaign.Id);
          List<AssignToController.UserRecordCount> userRecordCountList = buildUserRecordCountList(campaignMemberAssignedToCounts);
          Campaign campaignToUpdate = buildCampaignUpdates(campaign, userRecordCountList);
          campaignForUpdateList.add(campaignToUpdate);
        }

        update campaignForUpdateList;

      } catch (Exception batchException) {
          LoggingService.logHandledException(batchException, BATCH_CLASS_NAME, BATCH_EXECUTE_METHOD, System.LoggingLevel.ERROR); 

        }
}
  
  /**
   * @description finish
   * @param bc
  */
  @SuppressWarnings('PMD.EmptyStatementBlock')
  public void finish (Database.BatchableContext bc){
    
  }

  // helper method to create a list of user assigned record counts
  private List<AssignToController.UserRecordCount> buildUserRecordCountList(List<AggregateResult> campaignMemberAssignedToCounts) {
    
    List<AssignToController.UserRecordCount> userRecordCountList = new List<AssignToController.UserRecordCount>();
    
    for(AggregateResult assignedtoCount: campaignMemberAssignedToCounts) {
      if(assignedtoCount.Id != null) {
        AssignToController.UserRecordCount user = new AssignToController.UserRecordCount();
        user.userId = (ID) assignedtoCount.get('Id');
        user.userFullName = (String) assignedtoCount.get('Name');
        user.numberOfRecordsToAssign = (Integer) assignedtoCount.get('RecordCount');
        userRecordCountList.add(user);
      }
    }
    return userRecordCountList;
  }

  // helper method to build updated values for each campaign
  private Campaign buildCampaignUpdates(Campaign campaign, List<AssignToController.UserRecordCount> userRecordCountList) {
    Campaign campaignToUpdate = new Campaign();
    String userIdList;
    String userFullNameList;

    if (userRecordCountList.size() > 0) {
      userIdList = userRecordCountList.get(0).userId;
      userFullNameList = userRecordCountList.get(0).userFullName;
      for(Integer i = 1; i < userRecordCountList.size(); i++){
          userIdList += '|' + userRecordCountList.get(i).userId;
          userFullNameList += ' | ' + userRecordCountList.get(i).userFullName;
      }
    }

    campaignToUpdate.Id = campaign.Id;
    campaignToUpdate.CampaignMemberAssignmentChanged__c = false; //reset flag
    campaignToUpdate.CampaignMembersAssignedToList__c = userIdList;
    campaignToUpdate.Assigned_to_Campaign__c = userFullNameList;
    return campaignToUpdate;
    
  }

}