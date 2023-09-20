/**
 * @description This class will process the InsightClaimHandler
 */
public with sharing class InsightClaimHandler {

  /**
   * @description This method will process the getClaimData
   * @param accountList
   * @return  `Map<string,String>`
   */
   @AuraEnabled
   Public static Map<string,String> getClaimData(List<Account> accountList){
      Map<string,String> claimMap = new Map<string,String>();
    try{
      String ClaimLabel = '';
      String ClaimValue = '';
      if(accountList[0].CPAccounts.size() == 1){
        ClaimLabel = accountList[0].CPAccounts[0].Claim.Name + '-' + accountList[0].CPAccounts[0].Claim.ClaimDescription__c;
        ClaimValue = accountList[0].CPAccounts[0].ClaimId;
      }
      else{
        for(Integer i = 0; i < accountList[0].CPAccounts.size(); i++){
          ClaimLabel += accountList[0].CPAccounts[i].Claim.Name + '-' + accountList[0].CPAccounts[i].Claim.ClaimDescription__c + ',';
          ClaimValue += accountList[0].CPAccounts[i].ClaimId + ',';
        }
        ClaimLabel = ClaimLabel.removeEnd(',');
        ClaimValue = ClaimValue.removeEnd(',');
      }
      ClaimLabel = ClaimLabel + ',' + 'Claims Capabilities';
      claimMap.put('ClaimLabel',ClaimLabel);
      claimMap.put('ClaimValue',ClaimValue);
    }catch(Exception e){
      AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.info('InsightClaimHandler', e.getMessage() + System.now());
        logHolder.writeToLogExceptionObject();
    }
      return claimMap;
   }
}