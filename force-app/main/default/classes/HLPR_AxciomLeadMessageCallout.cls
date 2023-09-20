/**  
@Author Loco Motivated  
@Name HLPR_AxciomLeadMessageCallout
@CreateDate 06/29/2017 
@description This is a Helper class which will get a response from Axciom for Lead Messages
@Version 1.0
*/ 
public with sharing class HLPR_AxciomLeadMessageCallout {
    
    private static final String LEAD_MAILING_NAMED_CREDENTIALS = 'callout:Lead_Mailing_History_Provider_Process_Id';
    private static final string SFDC_LEAD_ID_REQ_PARAM='?salesforceLeadId=';
    private static final string AGENT_ASSOCIATE_ID_REQ_PARAM='&agentAssociateId=';
    private static final String CLASS_NAME='HLPR_AxciomLeadMessageCallout';
    private static final String METHOD_NAME='callAxciomLeadMailingHistoryService';
    private static final String COMMA=', ';
    private static final String LEAD_ID = 'leadId:';
    private static final String AGENT_ASSOC_ID = 'agentAssocId:';
    private static final String MESSAGE = 'Message';
    private static final String LEAD_MESSAGES = 'LeadMessages';
    
    /**
    * @description getAxciomLeadMailingHistoryService: Callout to Axioum vendor to get all LeadMessages which are of SENT and FAILED
    * @param salesforceLeadId ID : Lead ID
    * @param agentAssociateId ID : AgentAssociate ID
    * @param accId ID : Account ID
    */
    @future(callout=true)
    public static void callAxciomLeadMailingHistoryService(Id salesforceLeadId, string agentAssociateId, string accId){
        
        HttpRequest req = TechnicalPlatformDetails.buildHttpRequestForTP();
       	req.setEndpoint(LEAD_MAILING_NAMED_CREDENTIALS+SFDC_LEAD_ID_REQ_PARAM+ salesforceLeadId+AGENT_ASSOCIATE_ID_REQ_PARAM+ agentAssociateId);
        req.setMethod(TechnicalPlatformDetails.POST);
        req.setHeader(TechnicalPlatformDetails.CONTENT_TYPE, TechnicalPlatformDetails.JSON_TYPE);
        
        try{
            HttpResponse res = new Http().send(req);
            Map<string, Object> jsonMapRecords = (Map<string, Object>) JSON.deserializeUntyped(res.getBody());
            if(String.isNotBlank(res.getBody()) && res.getStatusCode()==200){
                parseResponseAndInsertAccountMessages(jsonMapRecords, accId);
            }else {
                LoggingService.logHandledException(new callOutException(LEAD_ID+salesforceLeadId+COMMA+AGENT_ASSOC_ID+agentAssociateId+COMMA+jsonMapRecords.get(MESSAGE)),
                                                   CLASS_NAME, METHOD_NAME , LoggingLevel.WARN);
            }
        }catch(exception exp){
            //Logging Exception Record for callout and trransforming LM2AM data
            LoggingService.logHandledException(exp, CLASS_NAME, METHOD_NAME , LoggingLevel.WARN);          
        }
    }
    
    /**
    * @description parseResponseAndInsertAccountMessages: Parsing the Response and insert Account Messages 
    * @param jsonMapRecords ID : Map<string, Object> 
    * @param accId ID : Account ID
    */
    public static void parseResponseAndInsertAccountMessages(Map<string, Object> jsonMapRecords, string accId){
        List<AccountMessage__c> accountMessagesListToInsert = new List<AccountMessage__c>(); 
        List<Object> leadMessageList = (List<Object>)jsonMapRecords.get(LEAD_MESSAGES);
        if(leadMessageList !=null && !leadMessageList.isEmpty()){
            for(Object leadMessage : leadMessageList){
                AccountMessage__c accMessage = mapJsonToAccountMessageFields(leadMessage);
                accMessage.Account__c = accId;
                accountMessagesListToInsert.add(accMessage);
            }       
            UTIL_AccountMessageDAO.insertAccountMessages(accountMessagesListToInsert);  
        }       
    }
    
    /**
    * @description mapJsonToAccountMessageFields: Inserting leadMessage Object to Account Message Fileds
    * @param leadMessage ID : Object 
    * @return : AccountMessage__c record with leadMessage Object
    */
    private static AccountMessage__c mapJsonToAccountMessageFields(Object leadMessage){
        AccountMessage__c accMessage=new AccountMessage__c();
        Map<string, Object> jsonRecordsMap = (Map<string, Object>) JSON.deserializeUntyped(JSON.serialize(leadMessage));
        jsonrecordsMap = jsonToAccountMessageTransformation(jsonrecordsMap); //Transforming Strings to Integers, Booleans,Doubles and Date Fields
        List<CM_StageOrchestration_Mapping__mdt> mappingForLeadMessagetoAccountMessage  = [SELECT Source_Field__c,Target_Field__c FROM CM_StageOrchestration_Mapping__mdt
                                                                                           WHERE Mapping_Type__c=:UTIL_StageOrchestrationConstants.LEAD_MESSAGE_TO_ACCOUNT_MESSAGE WITH SECURITY_ENFORCED];
        
        for(CM_StageOrchestration_Mapping__mdt mappingLoopForList : mappingForLeadMessagetoAccountMessage){
            if(jsonRecordsMap.containsKey(mappingLoopForList.Source_Field__c) ){
                accMessage.put(mappingLoopForList.Target_Field__c, jsonRecordsMap.get(mappingLoopForList.Source_Field__c));
            }
        }                                                          
        return accMessage;
    }
    
    /**
    * @description jsonToAccountMessageTransformation: Transforming Json Values to Respective Data Type
    * @param jsonRecordsMap ID : Map<string, Object> 
    * @return : Map<string, Object> with transformed Account Message values
    */
    private static Map<string, Object> jsonToAccountMessageTransformation(Map<string, Object> jsonRecordsMap){
        
        for(String key : jsonrecordsMap.keySet()) {
            Object value = jsonrecordsMap.get(key);
            String valueForConversion = String.valueOf(value);
            if((UTIL_StageOrchestrationConstants.JSON_TO_CHECKBOX_SET).contains(key)){
                value = UTIL_OrchestrationDataTransformation.jsonToCheckbox(valueForConversion);//checkbox transformation
            }else if((UTIL_StageOrchestrationConstants.JSON_TO_DATE_SET).contains(key)){
                value =  UTIL_OrchestrationDataTransformation.jsonToDate(valueForConversion);//Date Transformations
            }else if((UTIL_StageOrchestrationConstants.JSON_TO_INTEGER_SET).contains(key)){
                value=UTIL_OrchestrationDataTransformation.jsonStringToInteger(valueForConversion);//Integers Transformations
            }else if((UTIL_StageOrchestrationConstants.JSON_TO_DOUBLE_SET).contains(key)){
                value=UTIL_OrchestrationDataTransformation.jsonStringToDouble(valueForConversion);//Double transformation
            }
            jsonRecordsMap.put(key, value);
        }
        return jsonRecordsMap;
    }
}