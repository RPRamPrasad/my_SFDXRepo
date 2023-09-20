/**
  * @description Used for gathering data and requesting for credit via LWC's launchRFCQuickAction and requestForCreditModal
  * @author Team Opptimizers
  **/
  public with sharing class UTIL_RequestForCredit {

    private static final String CLASS_NAME = 'UTIL_RequestForCredit';
    private static final String EXCEPTION_EXTERNAL_ILP_ID = 'ExternalILPId=';
    private static final String EXCEPTION_VENDOR_ID = 'VendorId=';
    private static final String RFC_SR_API_KEY = 'Request_For_Credit_SR_API_Key';
    private static final String SR_API_KEY = 'SR_API_KEY';
    private static final String VENDOR_ID = 'VENDOR_ID';
    private static final String OK = 'OK';
    private static final String SPACE = ' ';

    /**
     * @description Queries metadata reason descriptions to be selected from in the LWC RequestForCreditModal
     * @param opp
     * @return List of string reason descriptions
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getReasonDescriptions(Opportunity opp) { 
        List<NewRFCReasonCodes__mdt> rfcReasonDescriptions = new List<NewRFCReasonCodes__mdt>();
        String vendorFilter= '%'+opp.Vendor_ID__c+'%';

        rfcReasonDescriptions = Security.stripInaccessible(AccessType.READABLE, 
        [SELECT RFCReasonDescription__c FROM NewRFCReasonCodes__mdt WHERE AcceptingVendors__c LIKE :vendorFilter AND DisplaysWarmTransfer__c = FALSE]).getRecords();

        if(opp.LeadType__c.contains('LT')){
            List<NewRFCReasonCodes__mdt> warmTransferReason = new List<NewRFCReasonCodes__mdt>();
            warmTransferReason = Security.stripInaccessible(AccessType.READABLE, 
            [SELECT RFCReasonDescription__c FROM NewRFCReasonCodes__mdt WHERE AcceptingVendors__c LIKE :vendorFilter AND DisplaysWarmTransfer__c = TRUE]).getRecords();
            
            rfcReasonDescriptions.addAll(warmTransferReason);
        }

        List<String> options = new List<String>();
        for(NewRFCReasonCodes__mdt rfcreason : rfcReasonDescriptions) { 
            options.add(rfcreason.RFCReasonDescription__c);    
        }
        return options;
    } 

    /**
     * @description Gets the reason code for the request reason, based on ILP vendor and reason
     * @param reasonDescription The selected reason description from the RFC modal
     * @return String reason code that relates to the reason description
     */
    @AuraEnabled(cacheable=true)
    public static String getReasonCode(String reasonDescription) {
       
        List<NewRFCReasonCodes__mdt> reasonCodeQueryData = Security.stripInaccessible(AccessType.READABLE, 
            [SELECT RFCReasonCode__c FROM NewRFCReasonCodes__mdt WHERE RFCReasonDescription__c = :reasonDescription]).getRecords();
        return reasonCodeQueryData[0].RFCReasonCode__c;
    }

    /**      
        @description Validates whether the vendor day request window is expired
        @param opp The Opportunity that 
        @return Boolean whether the request window is within limit or not
    */
    @AuraEnabled(cacheable=true)
    public static Boolean isRequestWindowOpen(Opportunity opp) {
        
        Boolean isWithinLimit = false;
        List<RFCSubmissionLimit__mdt> dayLimitData = Security.stripInaccessible(AccessType.READABLE,
        [SELECT DaysToSubmit__c FROM RFCSubmissionLimit__mdt WHERE VendorID__c =:opp.Vendor_ID__c]).getRecords();
        
        Date expirationDate = opp.Lead_Validation_Date__c.addDays(dayLimitData[0].DaysToSubmit__c.intValue() - 1);
        if(expirationDate >= system.today())  {
            isWithinLimit = true;    
        } 
        return isWithinLimit;
    }

    /**
     * @description Calls spi service class to check for free form text spi
     * @param comments Free form text from requestForCreditModal LWC
     * @param textAreaLabel The markup component label for a more customized error message back
     * @return String error message, populated means spi flagged, empty means no spi found
     */
    @AuraEnabled
    public static String scrubForSPI(String comments, String textAreaLabel) {
        String spiMessage = '';
        AP_SPISecurityValidator spiValidator = new AP_SPISecurityValidator();
        spiMessage = spiValidator.handle(comments, textAreaLabel);
        return spiMessage;
    }

    /**
     * @description Invokes a web service callout to ILP vendor
     * Could fail due to an exception or via error with vendor response
     * @param opp
     * @return Boolean for if the routing was successful or not
     */
    @AuraEnabled
    public static Boolean routeRequestForCredit(Opportunity opp) {
        Boolean isSuccessful = true;
        SendRequestForCredit.RequestForCreditSoapBinding router = new SendRequestForCredit.RequestForCreditSoapBinding();
        if (router.inputHttpHeaders_x == null) {
            router.inputHttpHeaders_x = new Map<String, String>();
        }
        CS_EnvironmentURLCustomSetting__c srApiKey = CS_EnvironmentURLCustomSetting__c.getValues(RFC_SR_API_KEY);
        router.inputHttpHeaders_x.put(VENDOR_ID, opp.Vendor_ID__c);
        router.inputHttpHeaders_x.put(SR_API_KEY, srApiKey.Value__c);
        
        try {
            String agentEmail = getAgentEmail(opp);
            String response = router.sendRequestForCredit(opp, agentEmail); 
            if (!OK.equalsIgnoreCase(response)) {
                isSuccessful = false; 
                LoggingService.logHandledException(createException(new System.CalloutException(System.Label.CL_RFC_SERVICE_UNAVAILABLE), opp), CLASS_NAME , 'routeRequestForCredit', System.LoggingLevel.ERROR);
            }
        } catch (System.Exception e) { 
            isSuccessful = false;
            LoggingService.logHandledException(createException(e, opp), CLASS_NAME , 'routeRequestForCredit', System.LoggingLevel.ERROR);
        }
        return isSuccessful;
    }

    /**
     * @description 
     * @param opp The Opportunity with which one wants to request for credit on
     * @return String of the agent's email
     */
    private static String getAgentEmail(Opportunity opp) { 
        String agentEmail = '';
        List<User> oppOwnerQueryData = Security.stripInaccessible(AccessType.READABLE,
            [SELECT Servicing_Agent_Associate_ID__c FROM User WHERE id=:opp.OwnerId]).getRecords();  

        String agentExternalId = oppOwnerQueryData[0].Servicing_Agent_Associate_ID__c + '_' + oppOwnerQueryData[0].Servicing_Agent_Associate_ID__c;  
        
        List<User> oppAgentQueryData = Security.stripInaccessible(AccessType.READABLE,
            [SELECT Email FROM User WHERE UserExternalID__c=:agentExternalId LIMIT 1]).getRecords();
        
        agentEmail = oppAgentQueryData[0].Email;
        return agentEmail;
    }

    /**
     * @description Encapsulates the exception thrown from ILR service into a custom RequestForCredit exception
     * @param e The exception, for the message building
     * @param opp The opportunity with which a RFC error occured on
     * @return HLPR_RequestForCreditException 
     **/
    private static HLPR_RequestForCreditException createException(Exception e, Opportunity opp) {
        String exceptionMessage = 
            EXCEPTION_VENDOR_ID + opp.Vendor_ID__c + SPACE + EXCEPTION_EXTERNAL_ILP_ID +
            opp.ExternalILPId__c + SPACE + e.getMessage();
        return new HLPR_RequestForCreditException(exceptionMessage);
    }
}