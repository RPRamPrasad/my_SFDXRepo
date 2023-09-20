/**
* @author Team Quadcore
* @created 04/20/2021
* @description This is a utility class which is to check the timestamps and verify to nullify TCM new values.
* @version 2.0
*/
public with sharing class AP_OppSalesAttemptTcm {
    private static final List<String> EXCLUDE_STAGE_NAMES = new String[] {'Not Now -  Follow Up','Closed'};
      
   /**
   * @description Method to make the previous timestamps null.
   * @param updatedOpportunity
   */
   public static void resetOpportunitySAFields(Opportunity updatedOpportunity){
      Date today = Date.today();
           if(!((updatedOpportunity.OppNotNowFollowUpDateTime__c != null && updatedOpportunity.OppClosedDateTime__c != null) &&
                (updatedOpportunity.OppNotNowFollowUpDateTime__c.date() != today || updatedOpportunity.OppClosedDateTime__c.date() != today))){
                    updatedOpportunity.Total_New_Calls__c = 0;
                    updatedOpportunity.Total_New_Email__c = 0;
                    updatedOpportunity.Total_New_Text__c = 0;
                    updatedOpportunity.TCM_New__c = 0;
                }
     }
    
   /**
   * @description Method to get the object and field values.
   * @param obj
   * @param fieldName
   * @return Decimal
   */
    private static Decimal getFieldValue(SObject obj, String fieldName) {
        Decimal value = 0 ;
        if(obj.get(fieldName) != null){
            value = (Decimal)obj.get(fieldName);
        }
        return value;
    }
    
    
    /**
   * @description Method to calculate TCM values.
   * @param sc
   * @param salesAttemptMap
   * @param oldOpportunity
   * @return SalesAttempt__c
   */
    public static SalesAttempt__c populateTCMValues(SalesAttempt__c sc,Map<String,List<SalesAttempt__c>> salesAttemptMap, Opportunity oldOpportunity){
            Decimal totalCallsMadeInSAs=0; 
            Decimal  totalEmailsInSAs=0; 
            Decimal totalTextsInSAs=0; 
            Decimal  totalCallsInSAs=0;
            if(salesAttemptMap.containsKey(oldOpportunity.Id)) {
                for(SalesAttempt__c sa : salesAttemptMap.get(oldOpportunity.Id)) {
                    totalCallsMadeInSAs += getFieldValue(sa, 'SA_TCM__c');
                    totalEmailsInSAs += getFieldValue(sa, 'Total_Email__c');
                    totalTextsInSAs += getFieldValue(sa, 'Total_Text__c');
                    totalCallsInSAs += getFieldValue(sa, 'Total_calls__c');
                }
            }
  sc.SA_TCM__c = ((oldOpportunity.Total_Calls_Made__c !=null? oldOpportunity.Total_Calls_Made__c:0) - getFieldValue(oldOpportunity,'TCM_New__c')) - totalCallsMadeInSAs;
            sc.Total_calls__c = ((oldOpportunity.Total_Calls__c!=null ?oldOpportunity.Total_Calls__c:0) - getFieldValue(oldOpportunity,'Total_New_Calls__c')) - totalCallsInSAs;
            sc.Total_Email__c = ((oldOpportunity.Total_Email__c!=null?oldOpportunity.Total_Email__c:0) - getFieldValue(oldOpportunity,'Total_New_Email__c')) - totalEmailsInSAs;
            sc.Total_Text__c = ((oldOpportunity.Total_Text__c!=null?oldOpportunity.Total_Text__c:0) - getFieldValue(oldOpportunity,'Total_New_Text__c')) - totalTextsInSAs;


            return sc;
    }
    
    /**
   * @description Method to calculate the New Tcm field value.
   * @param updatedOpportunity
   * @param oldOpportunity
   * @return Opportunity
   */    
    public static Opportunity updateTCMOnOpportunity(Opportunity updatedOpportunity, Opportunity oldOpportunity) {
           Date today = Date.today();
       if((EXCLUDE_STAGE_NAMES.contains(updatedOpportunity.StageName) || 
          ((updatedOpportunity.OppNotNowFollowUpDateTime__c != null && updatedOpportunity.OppClosedDateTime__c != null) &&
           (updatedOpportunity.OppNotNowFollowUpDateTime__c.date() != today || updatedOpportunity.OppClosedDateTime__c.date() != today)))
          && oldOpportunity.Total_Calls_Made__c != updatedOpportunity.Total_Calls_Made__c) {
            if(updatedOpportunity.TCM_New__c == null) {
                updatedOpportunity.TCM_New__c = 0;
            }
            updatedOpportunity.TCM_New__c += (updatedOpportunity.Total_Calls_Made__c - oldOpportunity.Total_Calls_Made__c);
        }
        return updatedOpportunity;
    }
}
