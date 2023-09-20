/**
 * @description SR_ExceptionHandler
 */
public without sharing class SR_ExceptionHandler {
    
    private SR_Util utility = new SR_Util();
    private List<Service_Request_Exception__c> exceptions = new List<Service_Request_Exception__c>();
    private List<SR_Payload> invalidPayloads = new List<SR_Payload>();
    private List<SR_Payload> exceptionPayloads = new List<SR_Payload>();
    private List<SR_Payload> invalidClientIdPayloads = new List<SR_Payload>();
    private Map<String, Service_Request_Exception__c> exceptionsMap = new Map<String, Service_Request_Exception__c>();
    private String exceptionMessage;
    /**
     * @description SR_ExceptionHandler
     * @param srMap 
     */
    public SR_ExceptionHandler(Map<SR_Key, Object> srMap){
        this.exceptions = (srMap.containsKey(SR_Key.SERVICE_REQUEST_EXCEPTIONS)) ? (List<Service_Request_Exception__c>)srMap.get(SR_Key.SERVICE_REQUEST_EXCEPTIONS) : new List<Service_Request_Exception__c>();
        this.invalidPayloads = (srMap.containsKey(SR_Key.INVALID_PAYLOADS)) ? (List<SR_Payload>)srMap.get(SR_Key.INVALID_PAYLOADS) : new List<SR_Payload>();
        this.exceptionPayloads = (srMap.containsKey(SR_Key.EXCEPTION_PAYLOADS)) ? (List<SR_Payload>)srMap.get(SR_Key.EXCEPTION_PAYLOADS) : new List<SR_Payload>();
        this.exceptionMessage = (srMap.containsKey(SR_Key.EXCEPTION_MESSAGE)) ? (String)srMap.get(SR_Key.EXCEPTION_MESSAGE) : 'No exception message provided';
        this.invalidClientIdPayloads = (srMap.containsKey(SR_Key.INVALID_CLIENT_ID_PAYLOADS)) ? (List<SR_Payload>)srMap.get(SR_Key.INVALID_CLIENT_ID_PAYLOADS) : new List<SR_Payload>();
    }
    /**
     * @description handleExceptions
     */
    public void handleExceptions(){
        handleInvalidPayloads();
        handleExceptionPayloads();
        handleInvalidClientIdPayloads();
        if(!this.exceptions.isEmpty()){
            addExceptionsToMap();
            Database.upsert(this.exceptionsMap.values(), Service_Request_Exception__c.Event_Id__c, false);
        }
    }
    
    private void handleExceptionPayloads(){
        if(!this.exceptionPayloads.isEmpty()){
            this.exceptions.addAll(utility.buildExceptionsList(this.exceptionPayloads, this.exceptionMessage));
        }
    }
    
    private void handleInvalidPayloads(){
        if(!this.invalidPayloads.isEmpty()){
            this.exceptions.addAll(utility.buildExceptionsList(this.invalidPayloads, 'Invalid Service Requests Payloads'));
        }
    }

    private void handleInvalidClientIdPayloads(){
        if(!this.invalidClientIdPayloads.isEmpty()){
            this.exceptions.addAll(utility.buildExceptionsList(this.invalidClientIdPayloads, 'The client identifier provided was not found'));
        }
    }
    
    private void addExceptionsToMap(){
        for(Service_Request_Exception__c ex : this.exceptions){
            this.exceptionsMap.put(ex.Event_Id__c, ex);
        }
    }
}