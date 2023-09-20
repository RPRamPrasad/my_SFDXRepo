/**
@Author Team Club Car
@Name UTIL_LeadConversionDetailDAO
@CreateDate 11/07/2016
@description Common class to access DML operations on LeadConversionDetails for various Processor.
@Version 1.0
*/
public without sharing class UTIL_LeadConversionDetailDAO {
    
    /**
    * Takes the List of LeadConversionDetails and deletes them
    * @description : deleteLeadConversionDetails
    * @param leadConversionDetailList : List<LeadConversionDetails>
    */
    
    public static void deleteLeadConversionDetails(List<LeadConversionDetail__c> leadConversionDetailList) {
        if(leadConversionDetailList != null && !leadConversionDetailList.isEmpty()) {
            delete leadConversionDetailList;
        } 
    }

    // method to delete list of leads
    /**
     * @description deleteLead
     * @param leadList 
     */
    public static void deleteLead(List<Lead> leadList) {
        if(leadList!= null && !leadList.isEmpty()) {
            delete leadList;
        }
    }
}