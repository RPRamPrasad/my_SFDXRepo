/**
* @description RecordAlertBuilder will help build RecordAlert objects.
*/
public with sharing class RecordAlertBuilder {
    private String householdId;
    private String jsonData;
    private String parentId;
    private String whatId;
    private String sourceSystemIdentifier;
    private Boolean isActive = true;
    private String subject;
    private String severity;
    private String id;
    private String recordAlertCategoryId;
    private String ownerId;
    private DateTime validUntilDate;
    private DateTime createdDate;
    private DateTime snoozeUntilDate;
    private static final String ERR_MISSING_FIELDS = 'Missing the following fields: ';
    private static final String CLASS_NAME = 'RecordAlertBuilder';

    /**
     * @description build RecordAlert object record
     * @return RecordAlert
     */
    public RecordAlert build(){
        List<String> errorList = validateRequiredFields();

        if(errorList.isEmpty() == false){
            // this block runs if required fields are missing.
            throw new RecordAlertBuilderException(CLASS_NAME + ' ' + ERR_MISSING_FIELDS + string.join(errorList,','));
        }else {
            // create new recordAlert
            // creates the record alert & assigns default values to optional fields if any are missing
            RecordAlert recAlert = new RecordAlert(
                RecordAlertCategoryId = this.recordAlertCategoryId, // required
                ParentId= this.parentId, // required
                OwnerId= this.ownerId, // required
                ValidUntilDate= Datetime.valueOf(this.validUntilDate), // required
                EffectiveDate= Datetime.valueOf(this.createdDate), // required
                WhatId= this.whatId // required
            );
            recAlert = addOptionalFields(recAlert);
            return recAlert;
        }

    }
    /**
     * @description add Optional Fields
     * @param recAlert
     * @return RecordAlert
     */
    public RecordAlert addOptionalFields(RecordAlert recAlert){
        if(!String.isBlank(this.householdId)){
            recAlert.Household__c= this.householdId;
        }
        if(!String.isBlank(this.sourceSystemIdentifier)){
            recAlert.SourceSystemIdentifier= this.sourceSystemIdentifier;
        }
        if(!String.isBlank(this.id)){
            recAlert.Id= this.id;
        }
        if(!String.isBlank(this.severity)){
            recAlert.Severity= this.severity;
        }
        if(!String.isBlank(this.subject)){
            recAlert.Subject= this.subject;
        }
        if(this.snoozeUntilDate != null){
            recAlert.SnoozeUntilDate = this.snoozeUntilDate;
        }
        if(this.isActive != null){
            recAlert.IsActive= this.isActive;
        }
        return recAlert;
    }

    /**
     * @description validate Required Fields
     * @return List<String>
     */
    public List<String> validateRequiredFields(){
        List<String> errorList = new List<String>();
         // check for required fields
         if(String.isBlank(this.recordAlertCategoryId)){
            errorList.add('recordAlertCategoryId');
        }

        if(String.isBlank(this.parentId)){
            errorList.add('parentId');
        }

        if(String.isBlank(this.ownerId)){
            errorList.add('ownerId');
        }

        if(this.validUntilDate == null){
            errorList.add('validUntilDate');
        }

        if(this.createdDate == null){
            errorList.add('createdDate');
        }

        if(String.isBlank(this.whatId)){
            errorList.add('whatId');
        }
        return errorList;
    }

    /**
     * @description set householdId
     * @param householdId
     * @return RecordAlertBuilder
     */
    public RecordAlertBuilder setHousehold(String householdId){
        this.householdId = householdId;
        return this;
    }

    /**
     * @description set id
     * @param id
     * @return RecordAlertBuilder
     */
    public RecordAlertBuilder setId(String id){
        this.id = id;
        return this;
    }

    /**
     * @description set newJSONData
     * @param newJSONData
     * @return RecordAlertBuilder
     */
    public RecordAlertBuilder setJsonData(String newJSONData){
        this.jsonData = newJSONData;
        return this;
    }

    /**
     * @description set SnoozeUntilDateData
     * @param snoozeUntilDate
     * @return RecordAlertBuilder
     */
    public RecordAlertBuilder setSnoozeUntilDate(DateTime snoozeUntilDate){
        this.snoozeUntilDate = snoozeUntilDate;
        return this;
    }

    /**
     * @description set SourceSystemIdentifier
     * @param sourceSystemIdentifier
     * @return RecordAlertBuilder
     */
    public RecordAlertBuilder setSourceSystemIdentifier(String sourceSystemIdentifier){
        this.sourceSystemIdentifier = sourceSystemIdentifier;
        return this;
    }

    /**
     * @description set parentId
     * @param parentId
     * @return RecordAlertBuilder
     */
    public RecordAlertBuilder setParentId(String parentId){
        this.parentId = parentId;
        return this;
    }

    /**
     * @description set whatId
     * @param whatId
     * @return RecordAlertBuilder
     */
    public RecordAlertBuilder setWhatId(String whatId){
        this.whatId = whatId;
        return this;
    }

    /**
     * @description set isActive
     * @param isActive
     * @return RecordAlertBuilder
     */
    public RecordAlertBuilder setisActive(Boolean isActive){
        this.isActive = isActive;
        return this;
    }

    /**
     * @description set subject
     * @param subject
     * @return RecordAlertBuilder
     */
    public RecordAlertBuilder setSubject(String subject){
        this.subject = subject;
        return this;
    }

    /**
     * @description set severity
     * @param severity
     * @return RecordAlertBuilder
     */
    public RecordAlertBuilder setSeverity(String severity){
        this.severity = severity;
        return this;
    }

    /**
     * @description set recordAlertCategoryId
     * @param recordAlertCategoryId
     * @return RecordAlertBuilder
     */
    public RecordAlertBuilder setRecordAlertCategoryId(String recordAlertCategoryId){
        this.recordAlertCategoryId = recordAlertCategoryId;
        return this;
    }

    /**
     * @description set ownerId
     * @param ownerId
     * @return RecordAlertBuilder
     */
    public RecordAlertBuilder setOwnerId(String ownerId){
        this.ownerId = ownerId;
        return this;
    }

    /**
     * @description set validUntilDate
     * @param validUntilDate
     * @return RecordAlertBuilder
     */
    public RecordAlertBuilder setValidUntilDate(DateTime validUntilDate){
        this.validUntilDate = validUntilDate;
        return this;
    }

    /**
     * @description set createdDate
     * @param createdDate
     * @return RecordAlertBuilder
     */
    public RecordAlertBuilder setCreatedDate(DateTime createdDate){
        this.createdDate = createdDate;
        return this;
    }

    /**
     * @author Team Skynet
     * @name RecordAlertBuilderException
     * @createDate 09/13/2022
     * @description RecordAlertBuilderException: Custom Exception for any Unknown/BadData scenarios when building a Record Alert
     */
    public with sharing class RecordAlertBuilderException extends Exception{}
}
