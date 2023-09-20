/**
 * @description SR_EventIdHandler
 */
public without sharing class SR_EventIdHandler {

    @TestVisible private SR_Payload payload = new SR_Payload();
    @TestVisible private String eventId;
    /**
     * @description SR_EventIdHandler
     * @param payload 
     * @param indexNumber 
     * @param requestId 
     */ 
    public SR_EventIdHandler(SR_Payload payload, Integer indexNumber, String requestId){
        this.payload = payload;
        this.eventId = (String.isEmpty(payload.eventId)) ? requestId + '_' + indexNumber : payload.eventId;
    }
    /**
     * @description setEventIds
     * @return  `SR_Payload`
     */
    public SR_Payload setEventIds(){
        this.payload.eventId = this.eventId;
        setCaseIndexNumber();
        setTaskIndexNumber();
        setLogIndexNumber();
        if(hasDefaultSobjects()){
            setDefaultCaseIndexNumber();
            setDefaultTaskIndexNumber();
            setDefaultLogIndexNumber();
        }
        return this.payload;
    }
    
    @TestVisible
    private void setCaseIndexNumber(){
        if(this.payload.caseRecord != null){
            this.payload.caseRecord.Event_Id__c = this.eventId;
        }
    }
    
    @TestVisible
    private void setTaskIndexNumber(){
        if(this.payload.taskRecord != null){
            this.payload.taskRecord.Event_Id__c = this.eventId;
        }
    }
    
    @TestVisible
    private void setLogIndexNumber(){
        if(this.payload.logRecord != null){
            this.payload.logRecord.Event_Id__c = this.eventId;
        }
    }
    
    @TestVisible
    private void setDefaultCaseIndexNumber(){
        if(this.payload.defaults.caseRecord != null){
            this.payload.defaults.caseRecord.Event_Id__c = this.eventId;
        }
    }
    
    @TestVisible
    private void setDefaultTaskIndexNumber(){
        if(this.payload.defaults.taskRecord != null){
            this.payload.defaults.taskRecord.Event_Id__c = this.eventId;
        }
    }
    
    @TestVisible
    private void setDefaultLogIndexNumber(){
        if(this.payload.defaults.logRecord != null){
            this.payload.defaults.logRecord.Event_Id__c = this.eventId;
        }
    }
    
    @TestVisible
    private boolean hasDefaultSobjects(){
        return this.payload.defaults != null;
    }
    
}