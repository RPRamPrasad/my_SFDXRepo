/**
* @name SCH_HouseholdCleanup
* @author Targaryen
* @description This batch will remove all Orphan Households and Single Member Households including Household Memebrs, those are created / updated on CurrentDate -2 days (two days 
* less than todays date, it won't remove last two days Household records from current date)
*/


public without sharing class SCH_HouseholdCleanup implements Schedulable {
    CS_HouseholdBatch__c customSettingsHouseholdBatch = CS_HouseholdBatch__c.getValues('EmailAndBatchDetails');

    /**
     * @description Execute
     * @param ctx 
     */    
   public void execute(SchedulableContext ctx){       
       Database.executeBatch(new Batch_CleanupHouseholdRecord(true),(Integer)customSettingsHouseholdBatch.Batch_Size__c);
   }
}