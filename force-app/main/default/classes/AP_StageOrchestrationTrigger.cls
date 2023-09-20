/**
* @Author Team Loco-Motivated
* @Name AP_StageOrchestrationTrigger
* @Description This a Trigger helper class which will be called by trigger.
*/

/**
* @Author Team Targaryen
* @Name AP_StageOrchestrationTrigger
* @ModifiedDate 11/11/2019 [MM/DD/YYYY]
* @description Refactor the code for Bulkification.
* @Version 2.0
*/
public with sharing class AP_StageOrchestrationTrigger {
    
   /**
    * This method take trigger.new list and chunk it into multiple Queueable jobs for processing
    * @Name : processTheBatch
    * @Param : List<StageOrchestration__c>
    * @return : void
    */
    public static List<CM_StageOrchestration_Mapping__mdt> mappingForTransactionTypeToProcessorValue;
    
    /**
     * @description Process The Batch
     * @param newStageOrchestrationList
     */
    public void processTheBatch(List<StageOrchestration__c> newStageOrchestrationList) {
        
        mappingForTransactionTypeToProcessorValue=[SELECT Mapping_Type__c,Source_Field__c,Target_Field__c 
                                              FROM CM_StageOrchestration_Mapping__mdt
                                              WHERE Mapping_Type__c=:UTIL_StageOrchestrationConstants.TRANSACTION_TYPE_TO_PROCESSOR_MAPPING];
        
        List<StageOrchestration__c> customerSyncRecordsList = new List<StageOrchestration__c>();
        List<StageOrchestration__c> otherStageOrchRecordsList = new List<StageOrchestration__c>();
            if(!newStageOrchestrationList.isEmpty()){
                for(StageOrchestration__c stageOrhcestrationrecord : newStageOrchestrationList){
                    if(stageOrhcestrationrecord.TransactionType__c.equalsIgnoreCase(UTIL_StageOrchestrationConstants.CUSTOMER_SYNC_TRANSACTION)){
                        customerSyncRecordsList.add(stageOrhcestrationrecord);
                    }
                    else{
                        otherStageOrchRecordsList.add(stageOrhcestrationrecord);
                    }
                }
                jobCreation(otherStageOrchRecordsList,CS_StageOrchestration_Counts__c.getInstance().Chunk_Size__c);
                jobCreation(customerSyncRecordsList,CS_StageOrchestration_Counts__c.getInstance().CustomerSync_Chunksize__c);
            }
            
    }

    private void jobcreation(List<StageOrchestration__c> recordList, Decimal batchSize){
        List<StageOrchestration__c> chunkList = new StageOrchestration__c[]{}; 
        if(!recordList.isEmpty()){
            integer recordPointer=0;
            while(recordPointer<recordList.size()){
                integer counter=0;
                while (counter<batchSize && recordPointer<recordList.size()){
                    chunkList.add(recordList[recordPointer++]);
                    counter++;
                }  
                AP_OrchestrationManager ashynchronousJob=new AP_OrchestrationManager();
                ashynchronousJob.stageOrchestrationList=chunkList;                
                createJob(ashynchronousJob);
                chunkList.clear();
            }
        }
    }

    void createJob(AP_OrchestrationManager ashynchronousJob){
        System.enqueueJob(ashynchronousJob);
    }
}