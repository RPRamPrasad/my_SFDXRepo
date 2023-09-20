/**
 * @description Main Processor for Service Requests
 * @Owner CATs
 */
public without sharing class SR_Processor {
    
    public Map<SR_Key, Object> srMap = new Map<SR_Key, Object>();
    public boolean hasQueueBeenRun = false;
    //Sync Handler 
    /**
     * @description handleSyncPayloads
     * @param payloads 
     */
    public void handleSyncPayloads(List<SR_Payload> payloads){
        handlePayloads(payloads);
    } 
    /**
     * @description handleAsyncPayloads
     * @param jsonBlob 
     */
    @future //Async Handler
    public static void handleAsyncPayloads(String jsonBlob){
        List<SR_Payload> payloads = (List<SR_Payload>)JSON.deserializeStrict(jsonBlob, List<SR_Payload>.class);
		SR_Processor processor = new SR_Processor();
        processor.handlePayloads(payloads);
    }
    /**
     * @description handlePayloads
     * @param payloads 
     * @return  `List<SR_Payload>`
     * @exception 
     */
    public List<SR_Payload> handlePayloads(List<SR_Payload> payloads){// Main entry into case migration
        setRequestId();
        List<SR_Payload> queueablePayloads = new List<SR_Payload>();
        try {
            setupPayloads(payloads);
            if(srMapHasValidPayloads()){
                handleValidPayloads();
            }else{
                throw new SR_Exception(SR_Exception.EXCEPTION_MESSAGE_NO_VALID_PAYLOADS, payloads);
            }
        }catch(Exception ex){
            this.srMap.put(SR_Key.EXCEPTION_PAYLOADS, payloads);
            this.srMap.put(SR_Key.EXCEPTION_MESSAGE, (ex.getMessage() + '\n' + 'Stack Trace: ' + ex.getStackTraceString()));
        }finally{
            handleExceptions();
            handleResponse(200, 'Success');
            queueablePayloads = handleQueuable();
        }
        return queueablePayloads;
    }
    
    private void setRequestId(){
        this.srMap.put(SR_Key.REQUEST_ID, Request.getCurrent().getRequestId());
    }
    
    @TestVisible
    private void setupPayloads(List<SR_Payload> payloads){
        SR_Setup setup = new SR_Setup(payloads, this.srMap);
        this.srMap = setup.preparePayloadsForProcessing();
    }
    
    @TestVisible
    private void handleValidPayloads(){
        handleMatching();
        upsertRecords();
    }
    
    @TestVisible
    private void handleMatching(){
        SR_Match matching = new SR_Match(this.srMap);
		this.srMap.putAll(matching.getMatchResults());
    }
    
    @TestVisible
    private void upsertRecords(){
        SR_DMLHandler dmlHandler = new SR_DMLHandler(this.srMap);
        this.srMap = dmlHandler.handleUpsert();
    }
    
    private void handleExceptions(){
        SR_ExceptionHandler exceptionHandler = new SR_ExceptionHandler(this.srMap);
        exceptionHandler.handleExceptions();
    }
    
    private void handleResponse(Integer statusCode, String responseBody){
        SR_Response response = new SR_Response(statusCode, responseBody);
        response.handleResponse();
    }
        
    @TestVisible
    private List<SR_Payload> handleQueuable(){ 
        List<SR_Payload> queueablePayloads = new List<SR_Payload>();
        if(srMapHasQueueablePayloads()){
            queueablePayloads.addAll(getQueueablePayloads()); 
        }
        if(!queueablePayloads.isEmpty() && !hasQueueBeenRun && !isQueueTest()){
            System.enqueueJob(new SR_Queueable(queueablePayloads));
        }
        return queueablePayloads;
    }
    
    @TestVisible
    private List<SR_Payload> getValidPayloads(){
        return (List<SR_Payload>)this.srMap.get(SR_Key.VALID_PAYLOADS);
    }
    
    @TestVisible
    private List<SR_Payload> getQueueablePayloads(){
        List<SR_Payload> queueablePayloads = new List<SR_Payload>();
        if(this.srMap.containsKey(SR_Key.QUEUEABLE_PAYLOADS_MAP)){
            Map<String, SR_Payload> queMap = (Map<String, SR_Payload>)this.srMap.get(SR_Key.QUEUEABLE_PAYLOADS_MAP);
            queueablePayloads.addAll(queMap.values());
        }
        if(this.srMap.containsKey(SR_Key.RECORD_LOCK_EXCEPTIONS)){
            List<SR_Payload> recordLockPayloads = (List<SR_Payload>)this.srMap.get(SR_Key.RECORD_LOCK_EXCEPTIONS);
            queueablePayloads.addAll(recordLockPayloads);
        }
        return queueablePayloads;
    }
    
    @TestVisible
    private boolean srMapHasValidPayloads(){
        return this.srMap.containsKey(SR_Key.VALID_PAYLOADS);
    }
    
    @TestVisible
    private boolean srMapHasQueueablePayloads(){
        return (this.srMap.containsKey(SR_Key.QUEUEABLE_PAYLOADS_MAP) || this.srMap.containsKey(SR_Key.RECORD_LOCK_EXCEPTIONS));
    }
    
    private boolean isQueueTest(){
        return Test.isRunningTest() && SR_TestDataUtility.isQueueTest;
    }
}