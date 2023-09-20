/**
 * @description Account Toast Display
 */
public with sharing class AccountToastDisplay {

    /**
     * @description Check CCPA Cache
     * @param acctId
     * @return Boolean
     */
    @AuraEnabled
    public static Boolean checkCcpaCache(String acctId){
        Cache.SessionPartition sessionPartition;
        try{

            if(Cache.Session.contains('local.CCPAToast.'+acctId)){
                return false;
            }
            else{
                sessionPartition = Cache.Session.getPartition('local.CCPAToast');
                sessionPartition.put(acctId,'ToastDisplayed' );
                return true;
            }
        }
        catch(Exception exp){
            return true;
        }
    }

    /**
     * @description Clear Cache
     * @param acctId
     */
    @AuraEnabled
    public static void clearCache(String acctId){
        try {
            if(Cache.Session.contains('local.CCPAToast.'+acctId)){
                Cache.Session.remove('local.CCPAToast.'+acctId);
            }
            
        } catch(Exception exp){
            LoggingService.logHandledException(exp, 'AccountToastDisplay','clearCache', System.LoggingLevel.ERROR);
        }
    }
}