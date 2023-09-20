/**
 * @description Common class to access various CustomerInitiatedCancellations related operations for various Processor util classes.
 */
public without sharing class UTIL_CustomerInitiatedCancellationsDAO {
    /**
    * @description insertCustomerInitiatedCancellations: insert CICs
    * @param customerInitiatedCancellationList list of feedItems for inserting
    */
    public static void insertCustomerInitiatedCancellations(List<CustomerInitiatedCancellations__c> customerInitiatedCancellationList) {
        if(customerInitiatedCancellationList != null && !customerInitiatedCancellationList.isEmpty()) {
            insert customerInitiatedCancellationList;
        } 
    }
    
    /**
    * @description updateCustomerInitiatedCancellations: update CICs
    * @param customerInitiatedCancellationList of CICs to update
    */
    public static void updateCustomerInitiatedCancellations(List<CustomerInitiatedCancellations__c> customerInitiatedCancellationList) {
        if(customerInitiatedCancellationList != null && !customerInitiatedCancellationList.isEmpty()) {
            update customerInitiatedCancellationList;
        }
    }
}