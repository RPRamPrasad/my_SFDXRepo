/**
 * @description SCH_UpdateOppStageManagement
 */
global without sharing class SCH_UpdateOppStageManagement implements Schedulable{
	CS_AutoCloseBatch__c autoCloseThc = CS_AutoCloseBatch__c.getInstance();
    /**
     * @description execute
     * @param ctx 
     */
 	global void execute(SchedulableContext ctx){
        Database.executeBatch(new Batch_UpdateOppStagemanagement(),(Integer)autoCloseThc.NumberOfThreads__c);
    }
}