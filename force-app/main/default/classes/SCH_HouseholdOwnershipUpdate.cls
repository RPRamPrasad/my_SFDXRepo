/**
* @name SCH_HouseholdOwnershipUpdate
* @author Team Targaryen
* @description this is a scheduler class for Batch_HouseholdOwnershipUpdate 
*/
public with sharing class SCH_HouseholdOwnershipUpdate implements Schedulable {
    
/**
* @description executes the schedulable
* @name  execute
* @param scheduleContext
*/   
    public void execute(SchedulableContext scheduleContext) {
        Batch_HouseholdOwnershipUpdate hhOwnerUpdate = new Batch_HouseholdOwnershipUpdate();
        Database.executebatch(hhOwnerUpdate);
    }
}
