/**
* @author Team Kraken
* @name UTIL_BillingSetting
* @description Common class to access Billing setting custom metadata.
* @version 2.0
*/
public with sharing class UTIL_BillingSetting {

    private static final String BILLING_ACTION_ELIGIBLE_USER = 'Billing_Action_Eligible_User';
    private static final String BILLING_LOB_ACCESS = 'Billing_LOB_View';
    private UTIL_BillingSetting(){
        AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.info('UTIL_BillingSetting', 'start time of execution: ' + System.now());
        logHolder.writeToLogExceptionObject();
    }
    
    /**
     * @description Invoked by BillingActionsController
     * @name isPayBillEnabled
     * @return Boolean
     */
    public static Boolean isPayBillEnabled() {
        return FeatureManagement.checkPermission(BILLING_ACTION_ELIGIBLE_USER);
    }

    /**
     * @description isLOBEnabled
     * @return  `Boolean`
     */
    public static Boolean isLOBEnabled() {
        return FeatureManagement.checkPermission(BILLING_LOB_ACCESS);
    }
}
