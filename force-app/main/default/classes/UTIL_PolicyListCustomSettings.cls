/**
 * @description class for Policy List Custom Settings
 * @author
 * @since
 */
public with sharing class UTIL_PolicyListCustomSettings {

    /**
     * @description Method to get policy list custom settings
     * @return  `CS_PolicyListPrint__c`
     */
    @AuraEnabled
    public static CS_PolicyListPrint__c getPolicyListCustomSettings() {

        CS_PolicyListPrint__c policyListPrintData = CS_PolicyListPrint__c.getValues('PolicyListPrint_DataSet');
        return policyListPrintData;

    }
}