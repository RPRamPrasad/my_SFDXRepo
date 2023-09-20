/**
 * @Name SCH_ChatterMonitoringProcess
 * @Author ITIC
 * @description Scheduler class for BATCH_ChatterMonitoring process
 *
 */
global with sharing class SCH_ChatterMonitoringProcess implements Schedulable {
	public static final String CHATTER_MONITORING_PROCESS = 'ChatterMonitoringProcess';
/**
 * @description execute
 * @param sC
 */
	global void execute(SchedulableContext sC) {
		CS_ApexBatchSize__c chatterMonitorCS = CS_ApexBatchSize__c.getInstance(CHATTER_MONITORING_PROCESS);
		Integer batchSize= Integer.valueOf(chatterMonitorCS.BatchSize__c);
        BATCH_ChatterMonitoring monitoringProcess = new BATCH_ChatterMonitoring ();
        Database.executebatch(monitoringProcess,batchSize);
	}
}