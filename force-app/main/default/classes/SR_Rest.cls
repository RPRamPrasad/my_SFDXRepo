/**
 * @description Apex Web Service that Handle Service Request from the SF side. It will insert and update sobjects
 * @Owner CATs
 */
@RestResource(urlMapping='/ServiceRequestRest/*')
global without sharing class SR_Rest {
    
    /**
     * @description handleRequest
     * @param payloads 
     * @param isSync 
     * @exception 
     */
    @HttpPost
    global static void handleRequest(List<SR_Payload> payloads, boolean isSync) {
        try{
            if(isNotEmpty(payloads)){
                handlePost(payloads, isSync); 
            }else{
                throw new SR_Exception(SR_Exception.EXCEPTION_MESSAGE_EMPTY_PAYLOAD_LIST);
            }
        }catch(SR_Exception ex){
            if(ex.getMessage() != SR_Exception.EXCEPTION_MESSAGE_EMPTY_PAYLOAD_LIST){
				handleExceptions(getSRMap(ex, payloads));
            } 
            handleResponse(400, ex.getMessage());
            LoggingService.logHandledException(ex, 'SR_Rest', 'handleRequest', System.LoggingLevel.ERROR);
        }
    }
    /**
     * @description handlePost
     * @param payloads 
     * @param isSync 
     */ 
    @TestVisible
    public static void handlePost(List<SR_Payload> payloads, boolean isSync){
        SR_Processor processor = new SR_Processor();
        if(isSync){
            processor.handleSyncPayloads(payloads);
        }else{
            String jsonBlob = JSON.serialize(payloads, true);
            SR_Processor.handleAsyncPayloads(jsonBlob);
        }
    }
    
    private static Map<SR_Key, Object> getSRMap(Exception ex, List<SR_Payload> payloads){
        Map<SR_Key, Object> srMap = new Map<SR_Key, Object>();
        srMap.put(SR_Key.EXCEPTION_PAYLOADS, payloads);
        srMap.put(SR_Key.EXCEPTION_MESSAGE, (ex.getMessage() + '\n' + 'Stack Trace: ' + ex.getStackTraceString()));
        return srMap;
    }
    
    private static void handleExceptions(Map<SR_Key, Object> srMap){
        SR_ExceptionHandler handler = new SR_ExceptionHandler(srMap);
        handler.handleExceptions();
    }
    
    private static void handleResponse(Integer statusCode, String errorMessage){
        SR_Response response = new SR_Response(statusCode, errorMessage);
        response.handleResponse();
    }
    
    @TestVisible
    private static boolean isNotEmpty(List<SR_Payload> payloads){
        return (payloads != null && !payloads.isEmpty());
    }
    
}