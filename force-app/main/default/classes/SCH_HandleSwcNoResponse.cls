/**
Author Team ClubCar
Name - Batch_HandleSwcNoResponse
@description - Scheduler class for Batch_HandleSwcNoResponse class
===========================================================================================
VERSION         AUTHOR                      DATE                    DETAIL
1.0            Team ClubCar                10/12/2020              Initial Development
*******************************************************************************************/
public with sharing class SCH_HandleSwcNoResponse implements Schedulable {
	private static final String HANDLESWC_NORESPONSE = 'HandleSwcNoResponse';    
    /**
     * @description execute 
     * @param ctx 
     */
    public void execute(SchedulableContext ctx) {
        CS_ApexBatchSize__c batchSizeCS = CS_ApexBatchSize__c.getInstance(HANDLESWC_NORESPONSE);
        Integer batchSize= Integer.valueOf(batchSizeCS.BatchSize__c);
        Database.executebatch(new Batch_HandleSwcNoResponse() ,batchSize);
    }
}