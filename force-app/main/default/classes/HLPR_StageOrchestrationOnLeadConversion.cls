/**
* @Name LeadConversionController 
* @Author Golden Spikes Team
* @Description This is a helper class to create StageOrcherstartion record on Lead Conversion.
* @description HLPR_StageOrchestrationOnLeadConversion
*/
public with sharing class HLPR_StageOrchestrationOnLeadConversion {
    private static final String CLASS_NAME = 'HLPR_StageOrchestrationOnLeadConversion';
    private static final String STAGEORCHESTRATION_RECORD_METHOD_NAME = 'createstageOrchestrationRecord';
    private static final String LEAD_ID = 'Lead ID: ';
    private static final String ACC_ID = 'Account ID: ';

    //entry method for creating stageOrchestration record
    /**
     * @description createstageOrchestrationRecord
     * @param leadId 
     * @param act 
     */
    public static void createstageOrchestrationRecord(id leadId, Account act) {
        StageOrchestration__c stOrc = new StageOrchestration__c();
        stOrc.TransactionType__c = UTIL_StageOrchestrationConstants.LEAD_CONVERSION_TRANSACTION;
        stOrc.VersionNumber__c = UTIL_StageOrchestrationConstants.JSON_VERSION_NUMBER;
        stOrc.IdentifierType__c = UTIL_StageOrchestrationConstants.CLIENT_IDENTIFIER;
        stOrc.IdentifierValue__c = act.ClientIdentifier__c;
        stOrc.CallingApplication__c = UTIL_StageOrchestrationConstants.SALESFORCE_COM;
        stOrc.Value__c = jsonStringForValue(leadId, act.Id);
        try {
            Database.insert(stOrc); //Creating StageOrchestration record with TransactionType as Conversion Lead Details.
        } catch (DMlException insertionError) {
            insertionError.setMessage(LEAD_ID + leadId + ACC_ID + act.Id + ' ' + insertionError.getMessage());
            LoggingService.logHandledException(insertionError, CLASS_NAME, STAGEORCHESTRATION_RECORD_METHOD_NAME, LoggingLevel.ERROR);
        }
    }

    //method for creating a json for stageOrchestration record
    private static string jsonStringForValue(id leadId, id accId) {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.WriteStartObject();
        gen.writeFieldName(UTIL_StageOrchestrationConstants.ORCHESTRATION_INFO);
        gen.WriteStartObject();
        gen.writeNumberField(UTIL_StageOrchestrationConstants.JSON_VERSION, UTIL_StageOrchestrationConstants.JSON_VERSION_NUMBER);
        gen.writeFieldName(UTIL_StageOrchestrationConstants.ORCHESTRATION_EVENT_NAME);
        gen.WriteStartObject();
        gen.writeStringField(UTIL_StageOrchestrationConstants.ORCHESTRATION_EVENT_TYPE, UTIL_StageOrchestrationConstants.LEAD_CONVERSION_TRANSACTION);
        gen.writeFieldName(UTIL_StageOrchestrationConstants.ORCHESTRATION_EVENT_DETAIL);
        gen.WriteStartObject();
        gen.writeFieldName(UTIL_StageOrchestrationConstants.ORCHESTRATION_EVENT_VALUES);
        gen.WriteStartObject();
        gen.WriteStringField(UTIL_StageOrchestrationConstants.ACCOUNT_ID, accId);
        gen.WriteStringField(UTIL_StageOrchestrationConstants.LEAD_ID, leadId);
        gen.WriteEndObject();
        gen.WriteEndObject();
        return gen.getAsString();
    }
}