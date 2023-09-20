/****************************************************************************************
Name: SignedWrittenConsentCustAggrSync
=========================================================================================
@description : This class will make HTTP callout to Customer Aggregator webservice on TP
			   to update phone numbers based on the request
Team: ClubCar
=========================================================================================
VERSION         AUTHOR                    DATE                   DETAIL
1.0             ClubCar                  03/15/2021              Initial Development
******************************************************************************************/
public with sharing class SignedWrittenConsentCustAggrSync {
    
    private static final String CLASS_NAME='SignedWrittenConsentCustAggrSync';
    private static final String MAIN_METHOD_NAME='processMpdSyncRecords';
    private static final String CALLOUT_METHOD_NAME='performCalloutToCustomerAggregator';
    private static final String CUST_AGGT_NAMED_CREDENTIALS = 'callout:Customer_Aggregator_Process_Id';
    private static final String SR_API_KEY = 'SR_API_KEY';
    private static final String SR_CATEGORY = 'SR_CATEGORY';
    private static final String CONTENT_TYPE = 'Content-Type';
    private static final String JSON_TYPE = 'application/json';
    private static final String REQUEST_BODY_TEXT = 'Request Body';
    private static final String CALLINGAPP_JOURNEYMGMT = 'ECRM-JOURNEYMGMT';
    private static Boolean accountNeedsUpdate = false;

	/**
    * @method : processMpdSyncRecords
    * @description  : This method will be invoked by MpdSyncAfterInsert Trigger
    * @param mpdSyncRecordsList : Mpd Sync Records List    
    */
    public static void processMpdSyncRecords(List<MPDSync__c> mpdSyncRecordsList) {
        try{
            MPDSync__c mpdSycRecord = mpdSyncrecordsList[0];            
            Account accountDetailsFromDb = retrieveAccount(mpdSycRecord.Account__c);
            if(accountDetailsFromDb.Recordtype.Name.equals('Individual')){
                verifyRequestAndPerformCalloutIfRequired(mpdSycRecord,accountDetailsFromDb);                
            }
        }
        catch(Exception exp){                
            LoggingService.logHandledException(exp, CLASS_NAME, MAIN_METHOD_NAME, LoggingLevel.ERROR);
        }
    }
		
    /**
    * @method : performCalloutToCustomerAggregator
    * @description : This method will make callout to Customer Aggregator service to update
	*	             phone numbers based on the request
    * @param requestBody : request body in JSON format
    * @param mpdSyncRecordId : Mpd Sync RecordId
    */
    @future(callout=true)
    public static void performCalloutToCustomerAggregator(String requestBody, Id mpdSyncRecordId){
        String srApiKeyCS = TechnicalPlatformDetails.getApiKey();
        String srCategoryCS = TechnicalPlatformDetails.getSubcategory();
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setMethod(UTIL_CreateCustomerConstants.PATCH);
            
            CM_Customer_Aggregator_Resource__mdt customerResource = UTIL_AccountCreateEditHelper.getCustomerResource();
            request.setEndpoint(CUST_AGGT_NAMED_CREDENTIALS+customerResource.Resource_Path__c); 
            request.setHeader(CONTENT_TYPE, JSON_TYPE);
            
            if(String.isNotBlank(srApiKeyCS)) {
                request.setHeader(SR_API_KEY, srApiKeyCS);
            }
            if(String.isNotBlank(srCategoryCS)) {
                request.setHeader(SR_CATEGORY, srCategoryCS);
            }
            
            request.setBody(requestBody);
            HttpResponse response = http.send(request);
            AP_CustAggtRes custAggtRes = AP_CustAggtRes.parse(response.getBody());
            AP_CustAggtRes.cls_errors[] errors = custAggtRes.errors;            
            if(errors != null && !errors.isEmpty()){
                addErrorDetailsToExceptionLog(mpdSyncRecordId, errors[0].detail);
            }
            else{
                updateMpdSyncRecord(mpdSyncRecordId);
            }
        }
        catch(Exception calloutToTPException){
            String exceptionMessage = calloutToTPException.getMessage();
            calloutToTPException.setMessage(exceptionMessage + UTIL_Constants.NEW_LINE + REQUEST_BODY_TEXT + requestBody);
            LoggingService.logHandledException(calloutToTPException, CLASS_NAME, CALLOUT_METHOD_NAME, LoggingLevel.ERROR);
        }
    }

    //Helper method to verify request and call the method to perform callout if required    
    private static void verifyRequestAndPerformCalloutIfRequired(MPDSync__c mpdSycRecord, Account accountDetailsFromDb){
        String jsonToUpdate = mpdSycRecord.UpdateFieldsJSON__c;
        Account passedAccount = (Account)JSON.deserialize(jsonToUpdate, Account.class);
        Account updatedAccountForMpd = accountDetailsFromDb.clone();
        updatedAccountForMpd = setChangedFields(updatedAccountForMpd, accountDetailsFromDb, passedAccount);       
        String requestBody = prepareRequestForAggregator(accountDetailsFromDb, updatedAccountForMpd, retrieveAssociateId(mpdSycRecord.InitiatingProcessRecordId__c));
        if(accountNeedsUpdate){
            performCalloutToCustomerAggregator(requestBody,mpdSycRecord.Id);
        }
    }
    
    //Helper method to retrieve associate id
    private static String retrieveAssociateId(Id swcRecordId){
        
        List<SignedWrittenConsent__c> swcList = Security.stripInaccessible(AccessType.READABLE, [Select InitiatedFromId__c FROM SignedWrittenConsent__c
                                                                                                 WHERE Id = :swcRecordId]).getRecords();       
        
        List<Opportunity> oppList =  Security.stripInaccessible(AccessType.READABLE, [Select Owner.Servicing_Agent_Associate_ID__c FROM Opportunity
                                                                                      WHERE Id = :swcList[0].InitiatedFromId__c]).getRecords();
        
        return oppList[0].Owner.Servicing_Agent_Associate_ID__c;
    }
    
    //Helper method to prepare request for aggregator
    private static string prepareRequestForAggregator (Account accountDetailsFromDb, Account updatedAccountForMpd, String associateId) {
        
        HLPR_CustAggtReqWrapper wrapper = new HLPR_CustAggtReqWrapper();
        wrapper.oldCustomer = accountDetailsFromDb;
        wrapper.customer = updatedAccountForMpd;
        wrapper.billingStreet1 = '';
        wrapper.billingStreet2 = '';
        wrapper.billingStreet3= '';
        wrapper.shippingStreet1 = '';
        wrapper.shippingStreet2 = '';
        wrapper.shippingStreet3 = '';
        wrapper.billingAddStdCode = '';
        wrapper.shippingAddStdCode = '';
        wrapper.isMailingUpdated = false;
        wrapper.isResidenceUpdated = false;
        wrapper.isUpdateAfterSearch = false;
        wrapper.isEmailValidationChanged = false;
        wrapper.isIndividual = true;  
        wrapper.isAgentContextSetForCCCUser = false;
        wrapper.associateId = associateId;
        wrapper.isJoesiCallNeeded = false;
        wrapper.joesiContext = '';
        wrapper.callingApp = CALLINGAPP_JOURNEYMGMT;
        return HLPR_CustAggt.getCustPatchReq(wrapper);
    }
    
    //Helper method to set the changed fields in account to pass it to aggregator for update
    private static Account setChangedFields(Account updatedAccountForMpd, Account accountDetailsFromDb, Account passedAccount) {
        Set<String> accountFieldNameSet = new Set<String> {'personHomePhone', 'personMobilePhone'};
            for (String fieldName : accountFieldNameSet){                
                String accountPhoneField = String.valueof(passedAccount.get(fieldName));
                
                if(String.isBlank(accountPhoneField)) {
                    passedAccount.put(fieldName, null);
                }                
                if (accountDetailsFromDb.get(fieldName) != passedAccount.get(fieldName)) {
                    updatedAccountForMpd.put(fieldName, passedAccount.get(fieldName));
                    accountNeedsUpdate = true;
                }
            }
        return updatedAccountForMpd;
    } 
    
    //Helper method to retrieve account
    private static Account retrieveAccount(Id accountRecordId) {
        List<Account> returnedAccount = Security.stripInaccessible(AccessType.READABLE, [
            SELECT Id, Recordtype.Name,RecordTypeId, Name, Salutation, FirstName, MiddleName, LastName, Suffix, PreferredFirstName__c, Designation__pc, PersonBirthdate, Gender__pc, MaritalStatus__pc, EmployerName__pc,  
            DriversLicenseNumber__c, DriversLicenseStateProvince__c, Type, MailingAttention__c, MailingInCareOf__c, BillingStreet, ShippingStreet, BillingCity, ShippingCity, isPersonAccount,   
            BillingState, ShippingState, BillingPostalCode, ShippingPostalCode, BillingCountry, ShippingCountry, PersonHomePhone, Phone, PersonMobilePhone, TDDPhone__c, Fax, PersonEmail, IsSubjecttoCASL__c,  
            ClientIdentifier__c, BillingAddressType__c, ShippingAddressType__c, IsNotShareable__pc, IsPrivacyOptionsShared__c, HasPermissionToServiceText__c, WorkPhoneExtension__c, HasConfirmedNoEmail__c,
            Citizenship__pc, DeathDate__pc, IsDeathNotificationReceived__pc, HasPermissionToServiceEmail__c, HasPermissionToClaimEmail__c, HasPermissionToClaimText__c, HasPermissionToMarketingEmail__c,
            IsHearingImpaired__pc, PreferredSpokenLanguage__pc, SSN__pc, TIN__c, OccupationCategory__pc, OccupationStatus__pc, OccupationStartDate__pc, Occupation__pc, PersonEmailBouncedReason__c,
            Billing_Statements__c,Policy_Notices_Email__c, NumberOfEmployees, LivingArrangements__c, LivingArrangementsOtherDescription__c, Industry, AnnualRevenue,
            BusinessOwnerIndicator__c, SFPPBillRemindersEmail__c, PolicyDocuments__c, BillAlertText__c, Policy_Notices_Text__c
            FROM Account
            WHERE Id = :accountRecordId
        ]).getRecords();
        
        return returnedAccount.get(0);
    }
    
    //Helper method to insert exception log records with requestbody and error responsebody
    private static void addErrorDetailsToExceptionLog(Id mpdSyncRecordId, String errorDetail) {
        String errorDetails = 'MPDSync Id:'+ mpdSyncRecordId + UTIL_Constants.NEW_LINE + errorDetail;
        AP_LogHolder logHolder =  new AP_LogHolder();
        logHolder.error(CLASS_NAME, errorDetails);
        if (logHolder!=null){
            logHolder.writeToLogExceptionObject();
        }
    }
    
    //Helper method to update Mpd Sync Record
    private static void updateMpdSyncRecord(Id mpdSyncRecordId){
        MpdSync__c mpdSyncRecord = new MpdSync__c();
        mpdSyncRecord.Id = mpdSyncRecordId;
        mpdSyncRecord.IsProcessed__c = true;
        mpdSyncRecord.DateProcessed__c = System.Today();
        if(Schema.sObjectType.MPDSync__c.isUpdateable()){
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, new List<MpdSync__c>{mpdSyncRecord});
            Database.update(securityDecision.getRecords());
        }
    }   
    
}