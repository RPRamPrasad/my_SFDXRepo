/**
 * @description This class will process the InsightHandler
 */
public with sharing class InsightHandler {

  /**
   * @description This method will process the getInsightData
   * @param accountId
   * @return  `InsightWrapper`
   */
 @AuraEnabled
 public static InsightWrapper getInsightData(Id accountId){

try{
   InsightWrapper indWrap = new InsightWrapper();
   List<Insight_Indicator__mdt> mdtVal = new List<Insight_Indicator__mdt>();
   List<Account> accountList = security.stripInaccessible(AccessType.READABLE,[SELECT Id,PersonDoNotCall,DoNotMail__c,HasPermissionToMarketingEmail__c, BillingState,
  // DO NOT DELETE until further notice
  // (SELECT  DaysSinceLastConversation__c,AppointmentEndDateTime__c,AppointmentStartDateTime__c,CreatedDate FROM
  //Simple_Conversations__r WHERE SimpleConversationType__c = 'Simple Conversation' ORDER BY CreatedDate DESC LIMIT 1),
    (SELECT  BillingAccountID__r.PastDueIndicator__c,BillingAccountID__r.Name,BillingAccountID__r.ID FROM BillingParticipants__r),
    (SELECT PRPNS_LEVL_CD__c FROM Propensities__r WHERE PRPNS_LEVL_CD__c = 'H'),
      (SELECT ClaimId,Claim.Name,Claim.ClaimDescription__c FROM CPAccounts WHERE roleCd__c='NI' and Claim.ClaimStatusCd__c in ('N','O','R') and Claim.ClaimType = 'Auto' and Claim.TotalLossIndicator__c = true),
      (SELECT Id,InsurancePolicy.Servicing_Agent__c FROM PrimaryParticipants WHERE Policy_Description__c ='Homeowners Policy' and  Status__c = 'In Force' and InsurancePolicy.Servicing_Agent__c != null),
      (SELECT Id,InsurancePolicy.Servicing_Agent__c FROM RelatedParticipants WHERE Policy_Description__c ='Homeowners Policy' and  Status__c = 'In Force' and InsurancePolicy.Servicing_Agent__c != null)
         FROM Account WHERE Id=: accountId LIMIT 1]).getRecords()
      ;


   if(accountList[0].BillingParticipants__r.size() > 0 ){
    showPastDueBillIndicator(indWrap, accountList, mdtVal);
   }
  // DO NOT DELETE until further notice
  //  if(accountList[0].Simple_Conversations__r != null){
  //    if(accountList[0].Simple_Conversations__r.size() > 0){
  //      validation = InsightSimpleConvoHandler.getSCData(accountList);
  //      mdtVal.add(Insight_Indicator__mdt.getInstance(validation));
  //    }
  //    else {
  //      mdtVal.add(Insight_Indicator__mdt.getInstance('Error_SC'));
  //    }
  //  }
   if(accountList[0].Propensities__r.size() > 0 ){
      showPropensityIndicator(mdtVal);
   }

   if(accountList[0].CPAccounts.size() > 0){
    showTotalLossIndicator(indWrap, accountList, mdtVal);
   }

    // Use the Feature Access record for ADT Indicator to get the permissions
    Boolean isVisible = FeatureManagement.checkPermission('ADT_User');
    if (isVisible ) {
      showADTIndicator(mdtVal, accountList);
    }

   indWrap.insightList = mdtVal;

   return indWrap;
  }
  catch (Exception e){
    throw new AuraHandledException('Aura Exception thrown' + e.getMessage());
  }
 }
/**
 * @description This method will process the showPropensityIndicator
 * @param mdtVal
 */
@AuraEnabled
 public static void showPropensityIndicator(List<Insight_Indicator__mdt> mdtVal){
  try{
    mdtVal.add(Insight_Indicator__mdt.getInstance('Error_AP'));
  }catch(Exception e){
    AP_LogHolder logHolder = new AP_LogHolder();
      logHolder.info('InsightHandler', e.getMessage() + System.now());
      logHolder.writeToLogExceptionObject();
  }
 }
/**
 * @description This method will process the showTotalLossIndicator
 * @param indWrap
 * @param accountList
 * @param mdtVal
 */
@AuraEnabled
 public static void showTotalLossIndicator(InsightWrapper indWrap, List<Account> accountList,List<Insight_Indicator__mdt> mdtVal){
  Map<string,String> claimMap = new Map<string,String>();
  try{
  claimMap = InsightClaimHandler.getClaimData(accountList);
  mdtVal.add(Insight_Indicator__mdt.getInstance('Error_TL'));
  indWrap.claimMapList = claimMap;
  }catch(Exception e){
    AP_LogHolder logHolder = new AP_LogHolder();
    logHolder.info('InsightHandler', e.getMessage() + System.now());
    logHolder.writeToLogExceptionObject();
  }
 }
/**
 * @description This method will process the showPastDueBillIndicator
 * @param indWrap
 * @param accountList
 * @param mdtVal
 */
@AuraEnabled
 public static void showPastDueBillIndicator(InsightWrapper indWrap, List<Account> accountList,List<Insight_Indicator__mdt> mdtVal){
  String pastDueNumber = '';
  String pastDueBillID = '';
  Map<string,String> pastDueMap = new Map<string,String>();
  String validation = '';
try{
  for(Integer i = 0; i < accountList[0].BillingParticipants__r.size(); i++){
    if(accountList[0].BillingParticipants__r[i].BillingAccountID__r.PastDueIndicator__c)
    {
      pastDueNumber += 'Past Due - ' + accountList[0].BillingParticipants__r[i].BillingAccountID__r.Name + ',';
      pastDueBillID += accountList[0].BillingParticipants__r[i].BillingAccountID__r.ID + ',';
    }
  }
  if(pastDueNumber != null){
    pastDueNumber = pastDueNumber.removeEnd(',');
    pastDueBillID = pastDueBillID.removeEnd(',');
    pastDueMap.put('BillingNumber',pastDueNumber);
    pastDueMap.put('BillingID',pastDueBillID);
  }
  validation = InsightPastDueHandler.getPastDueData(accountList);
  mdtVal.add(Insight_Indicator__mdt.getInstance(validation));
  indWrap.pastDueMapList = pastDueMap;
}catch(Exception e){
  AP_LogHolder logHolder = new AP_LogHolder();
    logHolder.info('InsightHandler', e.getMessage() + System.now());
    logHolder.writeToLogExceptionObject();
  }
 }
   /**
    * @name: showADTIndicator
    * @description Method to determine if ADT indicator should be added to Insights Metadata Type
    * @param mdtVal Insight_Indicator Metadata type
    * @param accountList List of Accounts
    */
  public static void showADTIndicator(List<Insight_Indicator__mdt> mdtVal, List<Account> accountList) {
    if (InsightADTHandler.isADTEligible(accountList)) {
      mdtVal.add(Insight_Indicator__mdt.getInstance('ADT_Available'));
    }
 }


}