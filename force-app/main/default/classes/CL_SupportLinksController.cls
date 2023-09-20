/**
 * @description CL_SupportLinksController
 */
public with sharing class CL_SupportLinksController {

    @TestVisible public static List<Account> mockedAccount;
/**
 * @description launchCFFDLink
 * @param recordId 
 * @return  `String`
 */
    @AuraEnabled
    public static String launchCFFDLink(String recordId){
        String clientId = UTIL_ReturnClientId.getAccountClientId(recordId);
        return '/c/ExternalLinkApp.app?linkId=90&clientId=' + clientId;
        
    }
    /**
     * @description launchAPARLink
     * @param recordId 
     * @return  `String`
     */
    @AuraEnabled
    public static String launchAPARLink(String recordId){
        String clientId = UTIL_ReturnClientId.getAccountClientId(recordId);
        return '/c/ExternalLinkApp.app?linkId=91&clientId=' + clientId;
    }
}