/**
 * @description SR_Setup
 */
public without sharing class SR_Setup {
    
    @TestVisible private List<SR_Payload> payloads = new List<SR_Payload>();
    @TestVisible private List<SR_Payload> invalidPayloads = new List<SR_Payload>();
    @TestVisible private List<SR_Payload> validPayloads = new List<SR_Payload>();
    @TestVisible private Map<String, SR_Payload> queueablePayloadsMap = new Map<String, SR_Payload>();
    @TestVisible private Map<String, SR_Payload> originalPayloadsMap = new Map<String, SR_Payload>();
    @TestVisible private Map<SR_Key, Object> srMap = new Map<SR_Key, Object>();
    @TestVisible private Map<String, SR_Payload> clientToPayloadMap = new Map<String, SR_Payload>();
    @TestVisible private String recordTypeName = null;
    private Set<Id> tier1CaseIds = new Set<Id>();
    private String requestId;
    
    /**
     * @description SR_Setup
     * @param payloads 
     * @param srMap 
     */
    public SR_Setup(List<SR_Payload> payloads, Map<SR_Key, Object> srMap){
        this.payloads = payloads;
        this.srMap = srMap;
        this.requestId = (String)this.srMap.get(SR_Key.REQUEST_ID);
    }
    /**
     * @description preparePayloadsForProcessing
     * @return  `Map<SR_Key, Object>`
     */
    public Map<SR_Key, Object> preparePayloadsForProcessing(){
        if(!this.payloads.isEmpty()){
            SR_PNI pni = new SR_PNI(this.payloads);
            this.payloads = pni.handlePNI();
            preprocessPayloads();
        }
        return this.srMap;
    }
    
    @TestVisible
    private void preprocessPayloads(){
        for(SR_Payload payload : this.payloads){
            Integer indexNumber = this.payloads.indexOf(payload);
            SR_EventIdHandler eventHandler = new SR_EventIdHandler(payload, indexNumber, this.requestId);
            payload = eventHandler.setEventIds();
            this.originalPayloadsMap.put(payload.eventId, payload);
            if(validatePayload(payload)){
                setupPayloadsToProcess(payload);
            } 
        }
        setupResultMap();
    }
    
    @TestVisible
    private boolean validatePayload(SR_Payload payload){
        SR_Validation validation = new SR_Validation(payload);
        boolean isValidPayload = false;
        if(validation.isValidPayload()){
            isValidPayload = true;
        }else{
            this.invalidPayloads.add(payload);
        }
        return isValidPayload;
    }
    
    @TestVisible
    private void setupPayloadsToProcess(SR_Payload payload){
        String payloadRecordType = payload.matchParams.recordTypeName;
        if(this.recordTypeName == null || (this.recordTypeName != null && payloadRecordType.equals(recordTypeName))){
            this.recordTypeName = payloadRecordType;
            this.validPayloads.add(payload);
           	addToClientMap(payload);
            addCaseIdToSet(payload);
        }else{
            this.queueablePayloadsMap.put(payload.eventId, payload);
        }
    }
    
    private void addCaseIdToSet(SR_Payload payload){
        if(String.isNotEmpty(payload.matchParams.caseId)){
            this.tier1CaseIds.add(payload.matchParams.caseId);
        }
    }
    
    @TestVisible
    private void addToClientMap(SR_Payload payload){
        String clientId = payload.matchParams.clientId;
        if(this.clientToPayloadMap.containsKey(clientId)){
            this.queueablePayloadsMap.put(payload.eventId, payload);
        }else{
            this.clientToPayloadMap.put(clientId, payload);
        }
    }

    @TestVisible
    private void setupResultMap(){
        setOriginalPayloadsMap();
        setValidPayloads();
        setInvalidPayloads(); 
        setQueueablePayloads();
        setClientToPayloadMap();
        setTier1CaseIds();
    }
    
    
    @TestVisible
    private void setClientToPayloadMap(){
        if(!this.clientToPayloadMap.isEmpty()){
            this.srMap.put(SR_Key.CLIENT_TO_PAYLOAD_MAP, this.clientToPayloadMap);
        }
    }
    
    @TestVisible
    private void setValidPayloads(){
        if(!this.validPayloads.isEmpty()){
            populateMap(SR_Key.VALID_PAYLOADS, this.validPayloads);
            populateMap(SR_Key.RECORD_TYPE_NAME, this.recordTypeName);
        }   
    }
    
    @TestVisible
    private void setInvalidPayloads(){
        if(!this.invalidPayloads.isEmpty()){
            populateMap(SR_Key.INVALID_PAYLOADS, this.invalidPayloads);
        }
    }
    
    @TestVisible
    private void setOriginalPayloadsMap(){
        if(!this.originalPayloadsMap.isEmpty()){
            this.srMap.put(SR_Key.ORIGINAL_PAYLOADS_MAP, this.originalPayloadsMap);
        }
    }
    
  	@TestVisible
    private void setQueueablePayloads(){
        if(!this.queueablePayloadsMap.isEmpty()){
            populateMap(SR_Key.QUEUEABLE_PAYLOADS_MAP, this.queueablePayloadsMap);
        }
    }
    
    private void setTier1CaseIds(){
        if(!this.tier1CaseIds.isEmpty()){
            populateMap(SR_Key.TIER_1_CASE_IDS, this.tier1CaseIds);
        }
    }
    
    @TestVisible
    private void populateMap(SR_Key result, Object obj){
        this.srMap.put(result, obj);
    }
}