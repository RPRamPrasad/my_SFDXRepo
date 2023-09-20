/**  
@Author Loco Motivated  
@Name AP_OrchestrationManager
@CreateDate 17/09/2016 
@description This class contains all the logic to perform asynchronus jobs
@Version 1.0

@Author Targaryen 
@Name AP_OrchestrationManager
@ModifiedDate 08/05/2019 [MM/DD/YYYY]
@Description: Refactor the code for Bulkification
@Version 2.0
*/


public with sharing class AP_OrchestrationManager implements Queueable {
    
    public List<StageOrchestration__c> stageOrchestrationList;
    private List<CM_StageOrchestration_Mapping__mdt> mappingForTransactionTypeToProcessor;
    private String className='AP_OrchestrationManager'; 
    private String executeMethodName='execute';
    private integer maxErrorFieldLength=255;
    private String unableToLockRow='UNABLE_TO_LOCK_ROW';
    private String duplicateValue='DUPLICATE_VALUE';
    private String excpForStageOrchestration='Processor Map is not identified';

    /**
     * @description AP Orchestration Manager
     */    
    public AP_OrchestrationManager(){
        mappingForTransactionTypeToProcessor=AP_StageOrchestrationTrigger.mappingForTransactionTypeToProcessorValue;
    }  
  /**
    * @description execute: Execute method for handling the retries and updating the stageOrchestration
    * @param context
    * @throws :Failure 
    */ 
    
    public void execute(QueueableContext context) { 
        
        List<StageOrchestration__c> updateRecordList = new List<StageOrchestration__c>();
            for(StageOrchestration__c record : stageOrchestrationList){
                StageOrchWrapper orchWrap = processStageOrchestrationRecord(record);
                if(orchWrap == null){
                    return;
                }
                StageOrchestration__c updatetoRecord = new StageOrchestration__c(id=record.id);
                updatetoRecord.Status__c = orchWrap.status;
                updatetoRecord.transactionSpan__c = orchWrap.txTimeSpan;
                updatetoRecord.Error__c = orchWrap.errorMessage.left(maxErrorFieldLength);
                updateRecordList.add(updatetoRecord);
            }
            if(!updateRecordList.isEmpty()){
                update updateRecordList;
            }
        
    }

    /**
     * @description demo
     * @param record
     * @return StageOrchWrapper
     */
    public StageOrchWrapper processStageOrchestrationRecord(StageOrchestration__c record){

        String status=UTIL_StageOrchestrationConstants.SUCCESS_STATUS;
        String errorMessage='';
        integer executionCount = 1;
        Long txTimeSpan = 0;

        while (executionCount <=CS_StageOrchestration_Counts__c.getInstance().Retry_Count__c) {
            try{
                if(record.TransactionType__c.equalsIgnoreCase(UTIL_StageOrchestrationConstants.CUSTOMER_SYNC_TRANSACTION)){
                    UTIL_CustomerSyncProcessor processor=new UTIL_CustomerSyncProcessor();
                    processor.execute(stageOrchestrationList);
                    return null;
                }
                //while (executionCount <=CS_StageOrchestration_Counts__c.getInstance().Retry_Count__c) {
                txTimeSpan = callAppropriateProcessor(record);
                break;
            }catch(StageProcessorException e){
                executionCount++;
                if( ((!e.getmessage().contains(unableToLockRow) && !e.getmessage().contains(duplicateValue)) || executionCount>CS_StageOrchestration_Counts__c.getInstance().Retry_Count__c)) {   
                    status = evaluateStageOrchStatus(e, status);
                    errorMessage=e.getMessage();
                    e.setMessage(UTIL_StageOrchestrationConstants.STAGEORCHESTRATION_ID_FOR_EXCEPTION+record.id+UTIL_StageOrchestrationConstants.EMPTY_STRING+errorMessage); 
                    LoggingService.logHandledException(e,className, executeMethodName , LoggingLevel.WARN);
                    break;
                }
            }
        }

        StageOrchWrapper orchWrap = new StageOrchWrapper();
        orchWrap.status = status;
        orchWrap.errorMessage = errorMessage;
        orchWrap.txTimeSpan = txTimeSpan;

        return orchWrap;
    }

    /**
     * @description Evaluate StageOrchestration Status
     * @param e
     * @param status
     * @return String
     */
    public String evaluateStageOrchStatus(StageProcessorException e, String status){

        if(e.getmessage()==UTIL_StageOrchestrationConstants.INVALID_USER_NOT_FOUND){
            status=UTIL_StageOrchestrationConstants.FAILED_USER_NOT_FOUND;
        }
        else{
        status=UTIL_StageOrchestrationConstants.FAILURE_STATUS;
        }

        return status;
    }

  /**
    * @method callAppropriateProcessor: callAppropriateProcessor method for calling specific process with Transaction Type as a key
    * @description Call Appropriate Processor
    * @param record
    * @return : void
    * @throws : StageProcessorException 
    */ 
    
    private Long callAppropriateProcessor(StageOrchestration__c record){
        Long txTimeSpan = null;
        //When ever you have a new processor please add the Transaction Type to Processor Mapping on 
        //CM_StageOrchestration_Mapping__mdt with Mapping_Type__c as TRANSACTION_TYPE_TO_PROCESSOR_MAPPING
        
        String processorName='';
        
        //get appropriate processor name for given Transaction type
        for(CM_StageOrchestration_Mapping__mdt transactionToProcessor:mappingForTransactionTypeToProcessor){
            if(transactionToProcessor.Source_Field__c.equalsIgnoreCase(record.TransactionType__c)){
                processorName=transactionToProcessor.Target_Field__c;
            }
        }
        
        //If the mapping on custom metadata is not created or we get invalid transaction type
        if(String.isBlank(processorName)){
            throw new StageProcessorException(excpForStageOrchestration);
        }
        
        //dynamicly creating Object of processor type
        System.Type objType = Type.forName(processorName);
        Object obj = objType.newInstance();        
        UTIL_StageOrchestrationProcessor processor=(UTIL_StageOrchestrationProcessor) obj;
        Long startTime = System.Datetime.now().getTime();
        processor.execute(new List<StageOrchestration__C>{record});
        txTimeSpan = System.Datetime.now().getTime() - startTime;
        return txTimeSpan;        
    }

    /**
     * @description Variables required for updating StageOrchestration
     */
    class StageOrchWrapper{
        String status;
        String errorMessage;
        Long txTimeSpan;
    }    
}