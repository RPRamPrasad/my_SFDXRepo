/**
  * @name SCH_CampaignMemberAssignUpdate
  * @author Incognito
  * @description Scheduler class for Batch_CampaignMemberAssignUpdate
  * @date 6-6-22
  */

public with sharing class SCH_CampaignMemberAssignUpdate implements Schedulable {
  public static final String CAMPMEMB_ASSIGN_UPDATE = 'CampaignMemberAssignUpdate';
  /**
   * @description execute    
   * @param scheduleContext Database.SchedulableContext 
   * */    
    public void execute(SchedulableContext scheduleContext) {
      CS_ApexBatchSize__c campMembAssignUpdateCS = CS_ApexBatchSize__c.getInstance(CAMPMEMB_ASSIGN_UPDATE);
      Integer batchSize = Integer.valueOf(campMembAssignUpdateCS.BatchSize__c);
      Batch_CampaignMemberAssignUpdate campMembAssignUpdate = new Batch_CampaignMemberAssignUpdate ();
      Database.executebatch(campMembAssignUpdate,batchSize);
    }
}
