/**
  * @author: Targaryen
  * @owner Targaryen
  * @name: HLPR_AccountContactRelationshipTrigger
  * @createdDate 12/08/2020
  * @description The class is helper class for ACR trigger implementation
  * @version 1.0
  */
  public without sharing class HLPR_AccountContactRelationshipTrigger {
  private static final string TILT_SYMBOL = '~';
  
  /**
  * @description The method will remove Household Ids from all related records
  * @author: Targaryen.SFDoc | 5/15/2020 
  * @param childsObjectRecords
  **/
  public static void getRemoveHHIdFromChildSObjectsRecords(List<sObject> childsObjectRecords){
      List<sObject> sObjectRecordToUpdate = new List<sObject>();
      if(childsObjectRecords!= null && !childsObjectRecords.isEmpty()){
          for(sObject singleChildRecord : childsObjectRecords){
              singleChildRecord.Put('Primary_Household__c',NULL);
              sObjectRecordToUpdate.add(singleChildRecord);
          }
      }
      
      if(sObjectRecordToUpdate != null && !sObjectRecordToUpdate.isEmpty()){
        if(sObjectRecordToUpdate.get(0).getSObjectType() == Schema.AgentRole__c.getSObjectType()){  
            //This is used to set variable isDeleteFromACR to initiate delete household share through Agent Role After Update
            AP_NewAgentRoleTrigger.isDeleteFromACR = true;
        }
        update sObjectRecordToUpdate; 
          //Database.update(Security.stripInaccessible(AccessType.UPDATABLE, sObjectRecordToUpdate).getRecords());            
      }
  }
  
  /**
    * @description This method is used to update SourceSystemId on acr record
    * @param newACRList
    * @param householdIds
    * @param contactIdClientIdMap
    */
  public void updateSourceSystemId(List<AccountContactRelation> newACRList, List<Id> householdIds, Map<id, String> contactIdClientIdMap){
      List<Account> householdAccountsList = [ SELECT Id, FinServ__SourceSystemId__c 
                                              FROM Account 
                                              WHERE Id in :householdIds 
                                            ];
      Map<Id, String> accountIdSourceSystemIdMap = new Map<Id, String>();
      for (Account householdAccount : householdAccountsList){
          accountIdSourceSystemIdMap.put(householdAccount.Id, householdAccount.FinServ__SourceSystemId__c);
      }
      for(AccountContactRelation singleACR : newACRList){
          if(accountIdSourceSystemIdMap.get(singleACR.AccountId)!=null && !String.isEmpty(accountIdSourceSystemIdMap.get(singleACR.AccountId))){
              singleACR.FinServ__SourceSystemId__c = accountIdSourceSystemIdMap.get(singleACR.AccountId)+TILT_SYMBOL+contactIdClientIdMap.get(singleACR.ContactId);
          }
      }
  }

  /**
  * @description The method will provide list of Account Ids involved in ACR Trigger and Remove Household Ids from Accounts
  * @author: Targaryen.SFDoc | 5/15/2020
  * @param contactIds
  * @return Set<Id>
  **/
  public static Set<Id> getAccountIdsAndRemoveHHIdFromAccounts(List<Id> contactIds){
      Set<Id> accountIdsWithACR = new Set<Id>();
      List<Account> listofAccountRecord = new List<Account>();
      List<Account> listofAccountRecordToUpdate = new List<Account>();
      listofAccountRecord = [ SELECT Id 
                              FROM Account 
                              WHERE PersonContactId IN:contactIds
                            ];
      
      for (Account singleAccountRecord : listofAccountRecord){
          accountIdsWithACR.add(singleAccountRecord.Id);
          singleAccountRecord.Primary_Household__pc = NULL;
          listofAccountRecordToUpdate.add(singleAccountRecord);
      }

      if(listofAccountRecordToUpdate != null && !listofAccountRecordToUpdate.isEmpty()){
            update listofAccountRecordToUpdate;
          //Database.update(Security.stripInaccessible(AccessType.UPDATABLE, listofAccountRecordToUpdate).getRecords());
      }
      return accountIdsWithACR;
  }
  
  /**
    * @description This method populates householdId and SourceSystemId Map
    * @param householdIds
    * @return Map<Id, String>
    */
    public Map<Id, String> populateAccountIdSourceSystemIdMap(List<Id> householdIds){
      Map<Id, String> accountIdSourceSystemIdMap = new Map<Id, String>();
      List<Account> householdAccountsList = [ SELECT Id, FinServ__SourceSystemId__c 
                                              FROM Account 
                                              WHERE Id in :householdIds
                                            ];
      for (Account householdAccount : householdAccountsList){
          accountIdSourceSystemIdMap.put(householdAccount.Id, householdAccount.FinServ__SourceSystemId__c);
      }
      return accountIdSourceSystemIdMap;
  }

}