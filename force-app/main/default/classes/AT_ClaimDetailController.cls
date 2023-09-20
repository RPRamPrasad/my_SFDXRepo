/**
 * @name AT_ClaimDetailController
 * @author Hydra
 * @description Apex Controller Class used to retrieve external OData Objects from ECRMClaimsFacade and handle logic for Auto/Fire Claim Detail Page. 
 */
public with sharing class AT_ClaimDetailController {
    
    @TestVisible 
    private static UTIL_ToggleStrategyContext toggleContext = new UTIL_ToggleStrategyContext();
    
    @TestVisible 
    private static Boolean isErrorTest = false;
    
    public static final String CLAIMS_CHAT_ELIGIBLE_USER = 'Claims_Chat_Eligible_User';


    /**
     * @name: isOriginalDocumentUploadVisible
     * @description determines visibility of document upload
     * @return Boolean 
     */
    @AuraEnabled
    public static Boolean isOriginalDocumentUploadVisible(){
        try {
            if(Test.isRunningTest() && isErrorTest ) {
                throw new ApplicationException('');
            }

            return toggleContext.isActive(UTIL_Toggles.DISPLAY_ORIGINAL_DOCUMENT_UPLOAD);
        } catch (Exception ex){
            throw new AuraHandledException('Error on isOriginalDocumentUploadVisible ' + ex.getMessage());
        }
    }

    /**
     * @name: isUserEligibleForClaimsChat
     * @description determines if user is eligible for claims chat.
     * @return Boolean 
     */
    @AuraEnabled(cacheable=true)
    public static Boolean isUserEligibleForClaimsChat() {
        try {
            if(Test.isRunningTest() && isErrorTest ) {
                throw new ApplicationException('');
            }

            return FeatureManagement.checkPermission(CLAIMS_CHAT_ELIGIBLE_USER);
        } catch (Exception ex){
            throw new AuraHandledException('Error on isUserEligibleForClaimsChat ' + ex.getMessage());
        }
    }

    /**
     * @name: getClaimEstimates
     * @description method deserializes a payload string into a list of objects.
     * @param payload
     * @return List of Objects 
     */
    @AuraEnabled
    @TestVisible
    public static List<Object> getClaimEstimates(string payload){
        try {
            if(Test.isRunningTest() && isErrorTest ) {
                throw new ApplicationException('');
            }

            if(String.isEmpty(payload)) {
                return new List<Object>();
            }
            
            Map<String, Object> payloadMap = (Map<String,Object>)JSON.deserializeUntyped(payload);
            
            return (List<Object>) payloadMap.get('payload');
        } catch (Exception ex){
            throw new AuraHandledException('Error on getClaimEstimates ' + ex.getMessage());
        }
    }
    
    /**
     * @name: logPromiseRejection
     * @description method logs a string/error using System.debug
     * @param error
     */  
    @AuraEnabled
    @TestVisible
    public static void logPromiseRejection(String error){
        System.debug(LoggingLevel.INFO, error);
    }


    /**
     * @name: getFolAcronymList
     * @description method queries claims abbreviations from the CM_Auto_FOL_Acronym__mdt object.
     * @return List of CM_Auto_FOL_Acronym__mdt
     */
    @AuraEnabled
    @TestVisible
    public static List<CM_Auto_FOL_Acronym__mdt> getFolAcronymList() {
        try {
            if(Test.isRunningTest() && isErrorTest ) {
                throw new ApplicationException('');
            }

            return Security.stripInaccessible(
                AccessType.READABLE,
                [SELECT Acronym__c, Translation__c  
                FROM  CM_Auto_FOL_Acronym__mdt
                WHERE Acronym__c != null ])
                .getRecords();
        } catch (Exception ex){
            throw new AuraHandledException('Error on getFolAcronymList ' + ex.getMessage());
        }
    }

    /**
     * @name: getFireFolAcronymList
     * @description method queries claims abbreviations from the CM_Fire_FOL_Acronym__mdt object.
     * @return List of CM_Fire_FOL_Acronym__mdt
     */
    @AuraEnabled
    @TestVisible
    public static List<CM_Fire_FOL_Acronym__mdt> getFireFolAcronymList() {
        try {
            if(Test.isRunningTest() && isErrorTest ) {
                throw new ApplicationException('');
            }

            return Security.stripInaccessible(
                AccessType.READABLE,
                [SELECT Acronym__c, Translation__c  
                FROM  CM_Fire_FOL_Acronym__mdt
                WHERE Acronym__c != null ])
                .getRecords();
        } catch (Exception ex){
            throw new AuraHandledException('Error on getFireFolAcronymList ' + ex.getMessage());
        }
    }

     /**
     * @name isClaimDocumentUploadIframe
     * @description returns true if the toggle is on for iframing the claim document upload application
     * @return Boolean
     */
    @AuraEnabled(cacheable=true)
    public static boolean isClaimDocumentUploadIframe() {
        try {
            if(Test.isRunningTest() && isErrorTest ) {
                throw new ApplicationException('');
            }

            return AT_ClaimDetailController.toggleContext.isActive(UTIL_Toggles.CLAIM_DOCUMENT_UPLOAD_IFRAME);
        } catch (Exception ex){
            throw new AuraHandledException('Error on isClaimDocumentUploadIframe ' + ex.getMessage());
        }
    }

    /**
     * @name isSandboxEnvironment
     * @description Determines if claim is being loaded in sandbox or production environment  
     * @return Boolean
     */
    @AuraEnabled(cacheable=true)
    @TestVisible
    public static boolean isSandboxEnvironment() {
        try {
            if(Test.isRunningTest() && isErrorTest ) {
                throw new ApplicationException('');
            }

            return UserInfo.getUserName().substringAfterLast('@').countMatches('.') == 2; //Sandbox usernames have two periods after @
        } catch (Exception ex){
            throw new AuraHandledException('Error on isSandboxEnvironment ' + ex.getMessage());
        }
    }

    /**
     * @name getBillingAddressInfo
     * @description Retrieves the billing city and state from the account, used in rental flow  
     * @param clientId
     * @return List<Object>
     */
    @AuraEnabled(cacheable=true)
    @TestVisible
    public static List<Object> getBillingAddressInfo(String clientId) {
        try {
            if(Test.isRunningTest() && isErrorTest ) {
                throw new ApplicationException('');
            }
            
            return [Select BillingCity, BillingState from Account Where ClientIdentifier__c = :clientId WITH SECURITY_ENFORCED];
        } catch (Exception ex){
            throw new AuraHandledException('Error on getBillingAddressInfo with clientId' + clientId + ': ' + ex.getMessage());
        }
    }
    /**
     * @name ApplicationException
     * @createDate 01/20/2023
     * @description ApplicationException: Custom Exception for any Unknown scenarios
     */ 
    public class ApplicationException extends Exception {}
}