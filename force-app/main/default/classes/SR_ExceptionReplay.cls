/**
 * @description Apex Batch class to Auto Replay SR_Flow failures
 * @Owner CATs
 */
public without sharing class SR_ExceptionReplay implements Schedulable, Database.Batchable<SObject>{

    @TestVisible private List<SR_Payload> payloadList = new List<SR_Payload>();
    @TestVisible private List<Service_Request_Exception__c> payloadExceptions = new List<Service_Request_Exception__c>();
    @TestVisible CS_SR_Config__c srConfig = CS_SR_Config__c.getInstance();
    @TestVisible private Integer batchSize = (srConfig.Exception_Replay_Batch_Size__c == null) ? 500 : Integer.valueOf(srConfig.Exception_Replay_Batch_Size__c);
    @TestVisible private Set<SR_Payload> payloadSet = new Set<SR_Payload>();
    private static final String EXCEPTION_RECORD_TYPE_AUTO_RETRY = SR_Constants.EXCEPTION_RECORD_TYPE_AUTO_RETRY;
    private ApexValidation validation = new ApexValidation();
    
    /**
     * @description execute
     * @param context 
     */
    public void execute(SchedulableContext context) {
        SR_ExceptionReplay replayBatch = new SR_ExceptionReplay();
        Database.executeBatch(replayBatch, this.batchSize);
    }
    /**
     * @description start
     * @param context 
     * @return  `Database.QueryLocator`
     */
    public Database.QueryLocator start(Database.BatchableContext context){
        String query = '';
        try{
            
            query = 'SELECT Id, Payload__c, Retry_Count__c, isSuccessfullyReplayed__c ' +
                          'FROM Service_Request_Exception__c ' +
                          'WHERE RecordTypeId =:EXCEPTION_RECORD_TYPE_AUTO_RETRY ' +
                          'AND Retry_Count__c <= 5 ' +
                          'AND isSuccessfullyReplayed__c = false ';
        }catch(Exception ex){
            LoggingService.logHandledException(ex, 'SR_ExceptionReplay', 'START', System.LoggingLevel.ERROR);
            
        }
        return Database.getQueryLocator(query);
    }
    /**
     * @description execute
     * @param context 
     * @param exceptions 
     */
    public void execute(Database.BatchableContext context, List<Service_Request_Exception__c> exceptions){
        try{
            if(validation.isValidObject(exceptions)){
                handleReplays(exceptions);
            }
        }catch(Exception ex){
            LoggingService.logHandledException(ex, 'SR_ExceptionReplay', 'EXECUTE', System.LoggingLevel.ERROR);
        }
    }
    
    /* No code for Finish Method*/
    /**
     * @description finish
     * @param context 
     */
    public void finish(Database.BatchableContext context){
        // this is enforced method. But need to do nothing. 
        AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.info('SR_ExceptionReplay', 'start time of execution: ' + System.now());
        logHolder.writeToLogExceptionObject();
    }
	
    @TestVisible
    private void handleReplays(List<Service_Request_Exception__c> exceptions){
        for(Service_Request_Exception__c ex : exceptions){
            handleSRPayload(ex);
        }
        handleSRPayloadRetry();
    }
    
    @TestVisible
    private void handleSRPayload(Service_Request_Exception__c ex){
        SR_Payload payload = (SR_Payload)JSON.deserializeStrict(ex.Payload__c, SR_Payload.class);
        this.payloadSet.add(payload);
        this.payloadExceptions.add(ex);
    }

    @TestVisible
    private void handleSRPayloadRetry(){
        if(validation.isValidObject(this.payloadSet)){
            updatePayloadExceptions();
            replayPayloads();
        }
    }
    
    @TestVisible
    private void replayPayloads(){
        this.payloadList.addAll(this.payloadSet);
        if(!Test.isRunningTest()){
            SR_Processor processor = new SR_Processor();
            processor.handlePayloads(this.payloadList);
        }
    }
    
    @TestVisible
    private void updatePayloadExceptions(){
        if(validation.isValidObject(this.payloadExceptions)){
            List<Service_Request_Exception__c> updatedExceptions = new List<Service_Request_Exception__c>();
            for(Service_Request_Exception__c exc : this.payloadExceptions){
                exc.Retry_Count__c = exc.Retry_Count__c + 1;
                exc.isSuccessfullyReplayed__c = true;
                updatedExceptions.add(exc);
            }
            upsertException(updatedExceptions);
        }
    }
    
    @TestVisible
    private void upsertException(List<Service_Request_Exception__c> updatedExceptions){
        if(validation.isValidObject(updatedExceptions)){
            upsert Security.stripInaccessible(AccessType.UPSERTABLE, updatedExceptions, true).getRecords();
        }
    }
}