/**
@author Team Skynet
@name RAO_RecordAlertHandler
@createDate 08/26/2022
@description Handles any record alert event and implements business logic by indicator type
*/
public with sharing class RAO_RecordAlertHandler {

    private static final String CLASS_NAME = 'RAO_RecordAlertHandler';
    private static final String CS_RECORDALERTCATEGORY_SIMPLECONVERSATION = 'SimpleConversation';
    private static final CS_RecordAlert_Config__c RECORDALERTCATEGORYID_SIMPLECONVERSATION = CS_RecordAlert_Config__c.getValues(CS_RECORDALERTCATEGORY_SIMPLECONVERSATION);
    private static final String SC_SUBJECT = 'Simple Conversation';

    /**
     * @description This method handles requests for SimpleConversation CREATE/UPDATE flows
     * @method simpleConversationHandler: handles business logic for creating RecordAlerts based on SimpleConversation
     * @param newPlatformEvent Record_Alert__e is the new platform event coming in
     * @param existingRecordAlerts Map<String,List<RecordAlert>> is the map of existing RecordAlerts based on their ParentId
     * @return RecordAlert to be upserted by the calling class
     */
    public static RecordAlert simpleConversationHandler(Record_Alert__e newPlatformEvent, Map<String,List<RecordAlert>> existingRecordAlerts) {
        String method_Name = 'simpleConversationHandler';
        //If we are getting a CREATE/UPDATE, we need to compare against any existing RecordAlert
        try {
            RecordAlert existingRecordAlert = findExistingSimpleConvo(existingRecordAlerts.get(newPlatformEvent.ParentId__c));
            Datetime existingDate = existingRecordAlert.ValidUntilDate;
            Datetime newDate = Datetime.valueOf(newPlatformEvent.ValidUntilDate__c).addYears(1);
            if(existingDate < newDate || newPlatformEvent.WhatId__c == existingRecordAlert.WhatId) {
                //build RecordAlert with the new data
                /*RecordAlert thisRecordAlert = new RecordAlert(
                    Id = existingRecordAlert.Id,
                    ValidUntilDate=newDate,
                    EffectiveDate=newPlatformEvent.CreatedDate,
                    ParentId = existingRecordAlert.ParentId,
                    OwnerId = existingRecordAlert.OwnerId,
                    SnoozeUntilDate=null,
                    SourceSystemIdentifier= 'SimpleConversationTriggerEvent-'+newPlatformEvent.Action__c,
                    WhatId=newPlatformEvent.WhatId__c
                    );*/

                return new RecordAlert(
                    Id = existingRecordAlert.Id,
                    ValidUntilDate=newDate,
                    EffectiveDate=newPlatformEvent.CreatedDate,
                    ParentId = existingRecordAlert.ParentId,
                    OwnerId = existingRecordAlert.OwnerId,
                    SnoozeUntilDate=null,
                    SourceSystemIdentifier= 'SimpleConversationTriggerEvent-'+newPlatformEvent.Action__c,
                    WhatId=newPlatformEvent.WhatId__c
                    );

            } else {
                //Log that the new SimpleConvo is not more recent than the existing record
                throw new RAOException(CLASS_NAME + '-'+method_Name+' Existing Record Alert ['+existingRecordAlert.Id+'] has a newer Simple Conversation. newDate['+newDate+'] oldDate['+existingDate+']');
            }
        } catch(RAOMatchNotFoundException ex_matchNotFound){
            return createSimpleConvoRecordAlert(newPlatformEvent);
        }
    }

    /**
     * @description This method handles requests for SimpleConversation DELETE flows
     * @method simpleConversationDeleteHandler: handles business logic for deleting RecordAlerts based on WhatId being deleted
     * @param newPlatformEvent Record_Alert__e is the new platform event coming in
     * @param existingRecordAlerts Map<String,List<RecordAlert>> is the map of existing RecordAlerts based on their ParentId
     * @return RecordAlert to be deleted by the calling class
     */
    public static RecordAlert simpleConversationDeleteHandler(Record_Alert__e newPlatformEvent, Map<String,List<RecordAlert>> existingRecordAlerts) {
        RecordAlert ra_delete;
        for(RecordAlert ra : existingRecordAlerts.get(newPlatformEvent.ParentId__c)) {
            if(newPlatformEvent.WhatId__c == ra.WhatId){
                ra_delete = ra;
            }
        }
        if(ra_delete == null){
            throw new RAOMatchNotFoundException('Could not find a matching RecordAlert for the WhatId: '+newPlatformEvent.WhatId__c);
        }
        return ra_delete;
    }

    /**
     * @description This method determines which RecordAlert in the list is for SimpleConversations
     * @method findExistingSimpleConvo: finds an existing SimpleConversation RecordAlert (since there should only be 1) in the given list
     * @param recordAlertList List<RecordAlert> is the list of RecordAlerts to search through
     * @return RecordAlert that is related to a SimpleConversation
     */
    public static RecordAlert findExistingSimpleConvo(List<RecordAlert> recordAlertList) {
        RecordAlert theRecordAlert;
        if(recordAlertList == null || recordAlertList.isEmpty()){
            throw new RAOMatchNotFoundException('findExistingSimpleConvo: Empty List of RecordAlerts passed in. Nothing to match against.');
        } else {
            for(RecordAlert ra : recordAlertList) {
                if(ra.RecordAlertCategoryId == (Id)RECORDALERTCATEGORYID_SIMPLECONVERSATION.Value__c){
                    theRecordAlert = ra;
                }
            }
            if(theRecordAlert == null) {
                throw new RAOMatchNotFoundException('No Existing SimpleConversation in Existing Record Alerts');
            }
        }
        return theRecordAlert;
    }

    /**
     * @description This method determines which RecordAlert in the list is for SimpleConversations
     * @method createSimpleConvoRecordAlert: Creates a new RecordAlert for a SimpleConversation based on the Record_Alert__e platform event provided
     * @param newPlatformEvent Record_Alert__e is the Record_Alert__e platform event to base the RecordAlert on
     * @return RecordAlert that is related to a SimpleConversation based on the Record_Alert__e
     */
    public static RecordAlert createSimpleConvoRecordAlert(Record_Alert__e newPlatformEvent){
        /*RecordAlert thisRecordAlert = new RecordAlert(
            IsActive=true,
            Subject=SC_SUBJECT,
            RecordAlertCategoryId = (Id)RECORDALERTCATEGORYID_SIMPLECONVERSATION.Value__c,
            ParentId=newPlatformEvent.ParentId__c,
            OwnerId=newPlatformEvent.CreatedById,
            ValidUntilDate=newPlatformEvent.ValidUntilDate__c,
            EffectiveDate=newPlatformEvent.CreatedDate,
            WhatId=newPlatformEvent.WhatId__c,
            Household__c=newPlatformEvent.Household__c);*/

        return new RecordAlert(
            IsActive=true,
            Subject=SC_SUBJECT,
            RecordAlertCategoryId = (Id)RECORDALERTCATEGORYID_SIMPLECONVERSATION.Value__c,
            ParentId=newPlatformEvent.ParentId__c,
            OwnerId=newPlatformEvent.CreatedById,
            ValidUntilDate=newPlatformEvent.ValidUntilDate__c,
            EffectiveDate=newPlatformEvent.CreatedDate,
            WhatId=newPlatformEvent.WhatId__c,
            Household__c=newPlatformEvent.Household__c);
    }

    /**
     * @author Team Skynet
     * @name RAOException
     * @createDate 08/26/2022
     * @description RAOException: Custom Exception for any Unknown/BadData scenarios
     */
    public with sharing class RAOException extends Exception {}

    /**
     * @author Team Skynet
     * @name RAOMatchNotFoundException
     * @createDate 08/26/2022
     * @description RAOMatchNotFoundException: Custom Exception for Match Not Found so that we can still move forward with CREATE process
     */
    public with sharing class RAOMatchNotFoundException extends Exception {}
}