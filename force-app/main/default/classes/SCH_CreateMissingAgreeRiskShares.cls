/**
  * @name SCH_CreateMissingAgreeRiskShares
  * @author NSYNC
  * @description Scheduler class for scheduling batch to create missing insurance policy shares 
  */
public with sharing class SCH_CreateMissingAgreeRiskShares implements Schedulable{
     /**
    * @description execute    
    * @param schCon : Database.SchedulableContext setting batches to 50
    */
    public void execute(SchedulableContext schCon){
        Database.executeBatch(new Batch_CreateMissingAgreeRiskShares(), 50);   
    }  
}