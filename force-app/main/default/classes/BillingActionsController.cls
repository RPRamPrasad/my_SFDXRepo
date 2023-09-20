/**
* Author : Team Nsync
* @description : Serves as the controller for the billing LWCs
*/
public with sharing class BillingActionsController {

    /**
     * @name - isPayBillEnabled
     * @description - answers if the Pay Bill button should be enabled
     * @return Boolean
     */
    @AuraEnabled(cacheable=true)
    public static Boolean isPayBillEnabled() {
        return UTIL_BillingSetting.isPayBillEnabled();

    }

    /**
     * @description isLOBEnabled
     * @return  `Boolean` 
     */
    @AuraEnabled(cacheable=true)
    public static Boolean isLOBEnabled() {
        return UTIL_BillingSetting.isLOBEnabled();

    }

    /**
     * @name - getRecordIdsForCustomerGrouping
     * @description - returns accounts for a given Customer Grouping record ID
     * @param recordId
     * @return Map<Id, Account>
     */
    @AuraEnabled(cacheable=false)
    public static Map<Id, Account> getRecordIdsForCustomerGrouping(String recordId) {
        try {
            return UTIL_CustomerGroupData.getRecordIdsForGroup(recordId);
        } catch (Exception ex) {
            throw new AuraHandledException('Error on getRecordIdsForCustomerGrouping: ' 
            + ex.getMessage());
        }
    }

    /**
     * @name - getRecordIdsForHousehold
     * @description - returns accounts for a given household record ID
     * @param recordId
     * @return Map<Id, Account>
     */
    @AuraEnabled(cacheable=false)
    public static Map<Id, Account> getRecordIdsForHousehold(String recordId) {
        try {
            return UTIL_CustomerGroupData_FSC.getRecordIdsForGroup(recordId);
        } catch(Exception ex) {
            throw new AuraHandledException('Error on getRecordIdsForHousehold: ' + ex.getMessage());
        }
    }
}
