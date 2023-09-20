/**
  * @name InsightADTHandler
  * @author Team Skynet
  * @createdDate 5/3/2023
  * @description  This class will handle ADT Indicator for Insights
*/
public with sharing class InsightADTHandler {

  private static final String IL = 'IL';
  private static final String IND = 'IN';
  private static final String PA = 'PA';
  private static final String AZ = 'AZ';
  private static final String AR = 'AR';
  private static final String MO = 'MO';
  private static final String OK = 'OK';
  private static final String MS = 'MS';
  private static final String SC = 'SC';
  private static final String TX = 'TX';
  private static final String OH = 'OH';
  private static final String TN = 'TN';
  private static final String NV = 'NV';


   /**
  * @name: isADTEligible
  * @description Method to determine if ADT indicator is visible
  * @param accountList List of Accounts
  * @return Boolean if ADT is eligible
  */
  @AuraEnabled
  public static Boolean isADTEligible(List<Account> accountList) {
    try{
      return checkEligibleAccount(accountList[0]);

    }catch (Exception e){
      throw new AuraHandledException('Aura Exception thrown' + e.getMessage());
    }

  }

  private static Boolean checkEligibleAccount(Account acc ) {
      Boolean isEligibleAccount = false;

      if( acc.PersonDoNotCall == false  && acc.DoNotMail__c == false &&  (acc.HasPermissionToMarketingEmail__c == 'Yes' || String.isblank(acc.HasPermissionToMarketingEmail__c))  &&
      String.isNotEmpty(acc.BillingState) && validateState(acc) ) {
          isEligibleAccount = true;
      }

      return isEligibleAccount;

  }

  private static Boolean validateState(Account acc){

      Set<String> validBillingState = new Set<String>{IND, PA, AZ, MS, IL, OK, TX, AR, MO, SC, OH, TN, NV};

      return ( validateParticipants(acc) && validBillingState.contains(acc.BillingState))? true:false;
  }

  private static Boolean validateParticipants(Account acc){

    boolean validParticipant = false;
    Set<Id> userIdSet = new Set<Id>();

    if(acc.PrimaryParticipants.size() == 0 && acc.RelatedParticipants.size() == 0){
      return false;
    }


    List<User> getuserList = getServicingAgents();
    for(User usr :getuserList ){
      userIdSet.add(usr.ID);
    }

    if(userIdSet.isEmpty()){
        return false;
    }

    for(InsurancePolicyParticipant insurancePolicyPart : acc.PrimaryParticipants ){
      if(userIdSet.contains(insurancePolicyPart.InsurancePolicy.Servicing_Agent__c)){
          return true;
      }
    }

    for(InsurancePolicyParticipant insurancePolicyPart : acc.RelatedParticipants ){
      if(userIdSet.contains(insurancePolicyPart.InsurancePolicy.Servicing_Agent__c)){
        return true;
      }
    }


    return validParticipant;

  }

  private static List<User> getServicingAgents(){
    List<User> currentuser = security.stripInaccessible(AccessType.READABLE,
      [SELECT Id, Servicing_Agent_Associate_ID__c
          FROM User
          WHERE Id=: UserInfo.getUserId()
          WITH SECURITY_ENFORCED
          limit 1])
      .getRecords();
    
      return security.stripInaccessible(AccessType.READABLE,
          [SELECT Id, Servicing_Agent_Associate_ID__c,UserType__c
          FROM User
          WHERE Servicing_Agent_Associate_ID__c=:currentuser[0].Servicing_Agent_Associate_ID__c
          AND UserType__c <> 'Agent Proxy' AND IsActive = true AND FederationIdentifier != ''
          WITH SECURITY_ENFORCED  ])
          .getRecords();
  }



}
