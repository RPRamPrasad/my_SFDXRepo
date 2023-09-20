/**
* @author Team Quadcore
* @created 08/20/2020
* @description This is a Helper class which is verify whether a sales attempt record is created and copying the opportunity values to sales attempt record.This class has been created as part of re-open process feature.
* @version 2.0
*/

public with sharing class HLPR_OppSalesAttempt {
    /**
   * @description Method to insert salesattempt record on reopen process and copy the values.
   * @param oldOpportunity
   * @param salesAttemptMap
   * @return SalesAttempt__c
   */
  public  SalesAttempt__c insertSalesAttempt(Opportunity oldOpportunity, Map<String,List<SalesAttempt__c>> salesAttemptMap) {
        SalesAttempt__c sc = new SalesAttempt__c();
            if( salesAttemptMap.containsKey(oldOpportunity.Id))
            {
                sc = validateIfShellAndGenerateNameValue(sc,oldOpportunity, salesAttemptMap);
            }
            else{
            sc.Name = generateNameValue(oldOpportunity,salesAttemptMap );
            }
            sc.Assigned_To__c = oldOpportunity.Assigned_To__c;
            sc.CurrentInsurerName__c = oldOpportunity.CurrentInsurerName__c;
            sc.CurrentPremium__c = oldOpportunity.CurrentPremium__c;
            sc.Finance_Charge__c = oldOpportunity.Finance_Charge__c;
            sc.Investment_Amount__c = oldOpportunity.Investment_Amount__c;
            sc.LOB__c = oldOpportunity.LOB__c;
            sc.Product__c=oldOpportunity.Product__c;
            sc.Marketing_Source__c =oldOpportunity.Marketing_Source__c; 
            sc.Marketing_Sub_Source__c = oldOpportunity.Marketing_Sub_Source__c;
            sc.Number_of_Units__c= oldOpportunity.Number_of_Units__c ;
            sc.Number_of_Vehicles__c = oldOpportunity.Number_of_Vehicles__c;
            sc.OfficeAssigned__c = oldOpportunity.OfficeAssigned__c;
            sc.Opportunity_Originator__c=oldOpportunity.Opportunity_Originator__c;
            sc.Relationship_to_State_Farm__c = oldOpportunity.Relationship_to_State_Farm__c;
            sc.Source_Comments__c=oldOpportunity.Source_Comments__c;
            sc.Status__c =oldOpportunity.Status__c;
            sc.Sub_Status__c= oldOpportunity.Sub_Status__c;
            sc.Temperature__c=oldOpportunity.Temperature__c;
            sc.Total_Calls_Made__c = oldOpportunity.Total_Calls_Made__c;
            sc.TotalPremium__c = oldOpportunity.Amount;
            sc.total_Quote_attached__c = oldOpportunity.Total_Quote_Attached__c;
            sc.Quote_Received__c = oldOpportunity.Quote_Received__c;
            sc.X_Date__c = oldOpportunity.X_Date__c;
      		sc.OwnerId = oldOpportunity.ownerId;

            sc.OppNewDateTime__c = oldOpportunity.CreatedDate;
            sc.OppAssignedDateTime__c = oldOpportunity.OppAssignedDateTime__c;
            sc.OppContactEstablishedDateTime__c=oldOpportunity.OppContactEstablishedDateTime__c;
            sc.OppQuoteInProgressDateTime__c=oldOpportunity.OppQuoteInProgressDateTime__c; 
            sc.OppQuoteProvidedDateTime__c =oldOpportunity.OppQuoteProvidedDateTime__c;
            sc.OppAppPendingDateTime__c = oldOpportunity.OppAppPendingDateTime__c;	
            sc.OppAppSubmittedDateTime__c= oldOpportunity.OppAppSubmittedDateTime__c;
            sc.OppClosedDateTime__c= oldOpportunity.OppClosedDateTime__c;
            sc.OppRFCGrantedDateTime__c=oldOpportunity.OppRFCGrantedDateTime__c;
            sc.OppRFCNotGrantedDateTime__c =oldOpportunity.OppRFCNotGrantedDateTime__c;
            sc.OppRFCRequestedDateTime__c = oldOpportunity.OppRFCNotGrantedDateTime__c;
            sc.OppClosedWonDateTime__c = oldOpportunity.OppClosedWonDateTime__c;
            sc.OppNotNowFollowUpDateTime__c=oldOpportunity.OppNotNowFollowUpDateTime__c;
            sc.OppReOpenDateTime__c = System.now();
            sc.Opportunity_Name__c = oldOpportunity.Name;
            sc.Opportunity__c = oldOpportunity.Id;

            sc.Sales_Attempts__c = oldOpportunity.Sales_Attempts__c;
            sc.Duration_of_Opportunity__c = oldOpportunity.Duration_of_Opportunity__c;
            sc.isShellRecord__c='No';
      		
            sc = AP_OppSalesAttemptTcm.populateTCMValues( sc, salesAttemptMap, oldOpportunity);
        // New logic for Dormant and sales duration 
        if(sc.OppNotNowFollowUpDateTime__c != null || sc.OppClosedDateTime__c != null) {
            DateTime dateToBeConsidered = (sc.OppNotNowFollowUpDateTime__c != null) ? sc.OppNotNowFollowUpDateTime__c : sc.OppClosedDateTime__c;
            sc.Dormant_Duration__c = dateToBeConsidered.date().daysBetween(sc.OppReOpenDateTime__c.date());
            List<SalesAttempt__c> salesAttempts = salesAttemptMap.containsKey(oldOpportunity.Id) ? salesAttemptMap.get(oldOpportunity.Id) : new List<SalesAttempt__c>();
            Date sdDate1 = ( (salesAttempts.size() == 0 || isShellRecordExists(oldOpportunity,salesAttemptMap)) ? oldOpportunity.CreatedDate : oldOpportunity.OppReOpenDateTime__c).date();
            
            sc.Sales_Duration__c = sdDate1.daysBetween(dateToBeConsidered.date());
        }
        return sc;
    }


   /**
   * @description This method will verify if there is shell record present or not.
   * @param sc
   * @param oldOpportunity
   * @param salesAttemptMap
   * @return Opportuntiy  updatedOpportunity
   */
   private SalesAttempt__c validateIfShellAndGenerateNameValue(SalesAttempt__c sc, Opportunity oldOpportunity, Map<String,List<SalesAttempt__c>> salesAttemptMap){
        List<SalesAttempt__c> sale = salesAttemptMap.get(oldOpportunity.Id);
                if(isShellRecordExists(oldOpportunity, salesAttemptMap))
                {
                    sc.id = sale.get(0).id;
                    sc.Name = sale.get(0).Name;
                }
                else{
                    sc.Name = generateNameValue(oldOpportunity, salesAttemptMap);
                }
        return sc;
    }
    /**
   * @description This method will verify if there is shell record present or not.
   * @param oldOpportunity
   * @param salesAttemptMap
   * @return Opportuntiy  updatedOpportunity
   */
  public Boolean isShellRecordExists(Opportunity oldOpportunity,  Map<String,List<SalesAttempt__c>> salesAttemptMap){
        List<SalesAttempt__c> salesAttemptList = salesAttemptMap.get(oldOpportunity.Id);
        Boolean isShellRecord = false;
        if(salesAttemptList != null){ 
            for(SalesAttempt__c salesAttempt: salesAttemptList){
                if('Yes'.equalsIgnoreCase(salesAttempt.isShellRecord__c)){
                    return (isShellRecord=true);
                }
            }
        }
        return isShellRecord;
    }
     /**
   * @description Method to calculate the size of salesattempt records for the related opportunity.
   * @param oldOpportunity
   * @param salesAttemptMap
   * @return String
   */
    private String generateNameValue(Opportunity oldOpportunity, Map<String,List<SalesAttempt__c>> salesAttemptMap){
        String name = salesAttemptMap.get(oldOpportunity.Id) !=null ? String.valueOf(salesAttemptMap.get(oldOpportunity.Id).size() +1):'1';
        return name;
    }
    
   /**
   * @description Method to Delete the salesattempt records for the related opportunity.
   * @param opportunityList
   */
   public static void deleteSalesAttempt(List<Opportunity> opportunityList) {
        List<SalesAttempt__c> salesAttemptListToBeDeleted = new List<SalesAttempt__c>();
        List<String> opportunityIdList = new List<String>();
        for (Opportunity opty : opportunityList) {
            opportunityIdList.add(opty.Id);
        }
        if (!opportunityIdList.isEmpty()) {
            for (SalesAttempt__c salesAttempt : [SELECT Id FROM SalesAttempt__c WHERE Opportunity__c IN :opportunityIdList WITH SECURITY_ENFORCED]) {
                salesAttemptListToBeDeleted.add(salesAttempt);
            }
            if (!salesAttemptListToBeDeleted.isEmpty() && Schema.sObjectType.SalesAttempt__c.isDeletable()) {
                Database.delete(salesAttemptListToBeDeleted,false);
            }
        }
    }
}