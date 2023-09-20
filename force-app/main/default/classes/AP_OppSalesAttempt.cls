/**
* @author Team Quadcore
* @created 08/20/2020
* @description This is a utility class which is used to create a record on the Sales Attemp Object.This class has been created as part of re-open process feature.
* @version 2.0
*/
public with sharing class AP_OppSalesAttempt {
  private static final List<String> INCLUDE_STAGE_NAMES = new String[] {'New', 'Assigned', 'Quoting','App Submitted'};
  private static final List<String> EXCLUDE_STAGE_NAMES = new String[] {'Not Now -  Follow Up','Closed'};
  public static Map<String,List<SalesAttempt__c>> salesAttemptMap = new Map<String,List<SalesAttempt__c>>();
  HLPR_OppSalesAttempt hlprOppSalesAttempt = new HLPR_OppSalesAttempt();
 /**
   * @description Method to insert salesattempt record on reopen process and copy the values.
   * @param oldOpportunity
   * @return SalesAttempt__c
   */
  public  SalesAttempt__c insertSalesAttempt(Opportunity oldOpportunity) {
      
        return hlprOppSalesAttempt.insertSalesAttempt(oldOpportunity,salesAttemptMap);
 }


  /**
   * @description Method to map opportunity andrelated sales attempt records.
   * @param opportunityList
   */
  public void getSalesAttemptCountMap(List<Opportunity> opportunityList){
      for(SalesAttempt__c sa : [select id,name,OppNewDateTime__c,isShellRecord__c, OppAssignedDateTime__c, OppAppSubmittedDateTime__c, 
                                OppClosedDateTime__c, OppNotNowFollowUpDateTime__c,OppReOpenDateTime__c,  CreatedDate, Opportunity__c,SA_TCM__c,Total_calls__c,Total_Email__c,Total_Text__c
                                from SalesAttempt__c where Opportunity__c in :opportunityList ORDER BY CreatedDate DESC ]) {
          if(!salesAttemptMap.containsKey(sa.Opportunity__c)) {
              salesAttemptMap.put(sa.Opportunity__c, new List<SalesAttempt__c>());
          }
          salesAttemptMap.get(sa.Opportunity__c).add(sa);
      }
 }


 /**
   * @description Method to make the previous timestamps null.
   * @param updatedOpportunity
   * @param salesAttempt
   * @return Opportunity
   */
  public Opportunity getUpdatedOpportunity(Opportunity updatedOpportunity, SalesAttempt__c salesAttempt){
                         updatedOpportunity.OppContactEstablishedDateTime__c = null;
                         updatedOpportunity.OppQuoteInProgressDateTime__c = null;
                           updatedOpportunity.OppQuoteProvidedDateTime__C = null;
                           updatedOpportunity.OppAppPendingDateTime__C = null;
                           updatedOpportunity.OppAppSubmittedDateTime__c = null;
                           updatedOpportunity.OppNotNowFollowUpDateTime__c = null;
                           updatedOpportunity.OppClosedDateTime__c = null;
                           updatedOpportunity.Quote_Received__c = null;
                           updatedOpportunity.Quote_Discussed_Date__c = null;
      					           updatedOpportunity.OppQuote_Discussed_Timestamp__c = null;
                         updatedOpportunity.OppReOpenDateTime__c = salesAttempt.OppReOpenDateTime__c;
                         updatedOpportunity.OppClosedWonDateTime__c = null;
         return updatedOpportunity;
 }
  
  /**
   * @description Method to calculate number of sales attempts done.
   * @param updatedOpportunity
   * @param salesAttemptList
   * @param oldOpportunity
   * @return Opportunity
   */
  public Opportunity getSalesAttempts(Opportunity updatedOpportunity,List<salesAttempt__c> salesAttemptList, Opportunity oldOpportunity){
      if(!isStgCngdFrmClosedWon(updatedOpportunity,oldOpportunity) && !isStgCngdFrmClosedToNNFP(updatedOpportunity,oldOpportunity)){ 
           if(hlprOppSalesAttempt.isShellRecordExists(oldOpportunity,salesAttemptMap)){ 
              return salesAttemptIfShellRecordExists(updatedOpportunity,oldOpportunity,salesAttemptList);
          }
          else{
              return salesAttemptIfShellRecordNotExists(updatedOpportunity,oldOpportunity,salesAttemptList);
          }
      }
      return updatedOpportunity;
  }
   /**
   * @description This method will check if the old opportunity stage is NNFP/Closed and updated opportunity is Closed/NNFP
   * then it returns true. This eventually should not update the sales attempt value.
   * @param updatedOpportunity
   * @param oldOpportunity
   * @return Boolean value
   */
  public Boolean isStgCngdFrmClosedToNNFP(Opportunity updatedOpportunity,Opportunity oldOpportunity){
      return(('Not Now -  Follow Up'.equalsIgnoreCase(oldOpportunity.StageName) && 'Closed'.equalsIgnoreCase(updatedOpportunity.StageName))
        || ('Closed'.equalsIgnoreCase(oldOpportunity.StageName) && ('Not Now -  Follow Up'.equalsIgnoreCase(updatedOpportunity.StageName))
         ));
  }
   /**
   * @description This method will check if the old opportunity stage is Closed Won. 
   * This eventually should not update the sales attempt value.
   * @param updatedOpportunity
   * @param oldOpportunity
   * @return Boolean value
   */
  public Boolean isStgCngdFrmClosedWon(Opportunity updatedOpportunity,Opportunity oldOpportunity){
     return('Closed Won'.equalsIgnoreCase(oldOpportunity.StageName));
  }
  /**
   * @description This method will check if the old opportunity stage is NNFP/Closed and updated opportunity value 
   * value is 'AppSubmitted,new, Quoting, Assiged.'. 
   * This eventually should update the sales attempt value.
   * @param updatedOpportunity
   * @param oldOpportunity
   * @return Boolean value
   */
  public Boolean isStgCngdFrmNNFPToOtherThanClosedWonAndClosed(Opportunity updatedOpportunity,Opportunity oldOpportunity){
      return(('Not Now -  Follow Up'.equalsIgnoreCase(oldOpportunity.StageName) && INCLUDE_STAGE_NAMES.contains(updatedOpportunity.StageName))
        || ('Closed'.equalsIgnoreCase(oldOpportunity.StageName) && INCLUDE_STAGE_NAMES.contains(updatedOpportunity.StageName))
         );
  }
  /**
   * @description This method will check if the old opportunity stage is NNFP/Closed and updated opportunity value 
   * value is 'AppSubmitted,new, Quoting, Assiged.'. 
   * This eventually should update the sales attempt value.
   * @param updatedOpportunity
   * @param oldOpportunity
   * @return Boolean value
   */
  public Boolean isStageCheck(Opportunity updatedOpportunity,Opportunity oldOpportunity){
  return(('Not Now -  Follow Up'.equalsIgnoreCase(oldOpportunity.StageName) && 'Closed Won'.equalsIgnoreCase(updatedOpportunity.StageName)) || 
         ('Closed'.equalsIgnoreCase(oldOpportunity.StageName) && 'Closed Won'.equalsIgnoreCase(updatedOpportunity.StageName))
              );
  }
  /**
   * @description This method will check if the old opportunity stage is NNFP/Closed and updated opportunity value 
   * value is 'AppSubmitted,new, Quoting, Assiged.'. 
   * This eventually should update the sales attempt value.
   * @param updatedOpportunity
   * @param oldOpportunity
   * @return Boolean value
   */
  public Boolean isStageChangedFromNNFPToNotClosedAndCW(Opportunity updatedOpportunity,Opportunity oldOpportunity){
      return(('Not Now -  Follow Up'.equalsIgnoreCase(oldOpportunity.StageName) && INCLUDE_STAGE_NAMES.contains(updatedOpportunity.StageName)) || 
         ('Closed'.equalsIgnoreCase(oldOpportunity.StageName) && INCLUDE_STAGE_NAMES.contains(updatedOpportunity.StageName))
              );
  }
  /**
   * @description If shell Record is present This method will get the old opportunity and new updated opportunity
   * THis method checks if there is shell record or not if available then it checks various conditions to update
   * sales ateempts
   * @param updatedOpportunity
   * @param oldOpportunity
   * @param salesAttemptList
   * @return Opportuntiy  updatedOpportunity
   */
  public Opportunity salesAttemptIfShellRecordExists(Opportunity updatedOpportunity, Opportunity oldOpportunity,List<salesAttempt__c> salesAttemptList){
              if(isStageCheck(updatedOpportunity,oldOpportunity)){
                  //updatedOpportunity.Sales_Attempts__c = updatedOpportunity.Sales_Attempts__c + 1;
                    updatedOpportunity.Sales_Attempts__c = (updatedOpportunity.Sales_Attempts__c != null) ? updatedOpportunity.Sales_Attempts__c +1 : 1;
              }
              else if(isStgCngdFrmNNFPToOtherThanClosedWonAndClosed(updatedOpportunity,oldOpportunity)){
                  //updatedOpportunity.Sales_Attempts__c = updatedOpportunity.Sales_Attempts__c + 1;
                    updatedOpportunity.Sales_Attempts__c = (updatedOpportunity.Sales_Attempts__c != null) ? updatedOpportunity.Sales_Attempts__c +1 : 1;
              }
              else{
               //updatedOpportunity.Sales_Attempts__c = (updatedOpportunity.Sales_Attempts__c != null && !EXCLUDE_STAGE_NAMES.contains(updatedOpportunity.StageName)) ?updatedOpportunity.Sales_Attempts__c +1 : 1;
                  updatedOpportunity.Sales_Attempts__c = 1;
              }
      return updatedOpportunity;
  }
  /**
   * @description If shell record is not present this method will get the old opportunity and new updated opportunity
   * THis method checks if there is shell record or not if available then it checks various conditions to update
   * sales ateempts
   * @param updatedOpportunity
   * @param oldOpportunity
   * @param salesAttemptList
   * @return Opportuntiy  updatedOpportunity
   */
  public Opportunity salesAttemptIfShellRecordNotExists(Opportunity updatedOpportunity, Opportunity oldOpportunity,List<salesAttempt__c> salesAttemptList){
         
              if(isStgCngdFrmNNFPToOtherThanClosedWonAndClosed(updatedOpportunity,oldOpportunity)){
                  
                  updatedOpportunity.Sales_Attempts__c = salesAttemptList.size() + 1 + (salesAttemptMap.containsKey(updatedOpportunity.Id) ? salesAttemptMap.get(updatedOpportunity.Id).size() :0);
              }
              else if(isStageCheck(updatedOpportunity,oldOpportunity)){
                updatedOpportunity.Sales_Attempts__c = (updatedOpportunity.Sales_Attempts__c != null) ? updatedOpportunity.Sales_Attempts__c +1 : 1;
              }
      return updatedOpportunity;
  }
}
