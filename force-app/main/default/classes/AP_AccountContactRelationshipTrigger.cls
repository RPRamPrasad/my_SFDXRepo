/**
  * @author: Targaryen
  * @owner Targaryen
  * @name: AP_AccountContactRelationshipTrigger
  * @createdDate 04/04/2020
  * @description The class will perform all backend activities related to ACR records insert or delete.
  * @version 1.0
  */
 public without sharing class AP_AccountContactRelationshipTrigger {
  public static List<CM_SubQuery_Object_Settings__mdt> sObjectConfigItems;
  private static final string CLASS_NAME = 'AP_AccountContactRelationshipTrigger';
  private static final string INSERT_METHOD_NAME = 'processAccountContactRelationship';
  private static final string DELETE_METHOD_NAME = 'removeAccountContactRelationship';
  private static Map<id, String> contactIdClientIdMap = new Map<id, String>();
  HLPR_AccountContactRelationshipTrigger acrHelper = new HLPR_AccountContactRelationshipTrigger();

  /**
  * @description The method will execute while ACR Insert Trigger will invoked
  * @author: Targaryen.SFDoc | 5/15/2020 
  * @param newACRList
  **/
  public void processAccountContactRelationship(List<AccountContactRelation> newACRList){
      Set<Id> accountIdsAccociateWithACR = new Set<Id>();
      Map<Id,Id> mapOfContactIdAndHouseholdId = new Map<Id,Id>();
      Map<Id,Id> mapOfAccountIdAndHouseholdId = new Map<Id,Id>();
      List<sObject> accountRecordsWithChildRecord = new  List<sObject>();
      
      try{
          fetchConfiguredItemsFromCustomMetaData();
          for(AccountContactRelation singleACR : newACRList){
              singleACR.ExternalSourceSyncTime__c = System.now();
              mapOfContactIdAndHouseholdId.put(singleACR.ContactId,singleACR.AccountId);
          }
          
          mapOfAccountIdAndHouseholdId = getAccountIdHouseholdIdMapAndUpdateAccountWithHHID(mapOfContactIdAndHouseholdId);
          
          accountIdsAccociateWithACR = mapOfAccountIdAndHouseholdId.keySet();
          
          accountRecordsWithChildRecord = UTIL_QueryBuilderForACR.getListofAccountRecordsWithChild(sObjectConfigItems,accountIdsAccociateWithACR);
          if(!isSyncUser(UserInfo.getName())){
              acrHelper.updateSourceSystemId(newACRList, mapOfContactIdAndHouseholdId.values(),contactIdClientIdMap);
          }
          
           updateChildRecords(mapOfAccountIdAndHouseholdId, accountRecordsWithChildRecord);
      }catch(Exception fscHHException){
          UTIL_AgentProxySelection.tagAllErrors(newACRList, fscHHException.getMessage());
          LoggingService.logHandledException(fscHHException, CLASS_NAME, INSERT_METHOD_NAME, LoggingLevel.ERROR); 
      }     
  }
  
   /**
  * @description The method will execute while ACR Insert Trigger will invoked
  * @author: Targaryen.SFDoc | 5/15/2020 
  * @param updateACRList
  **/
  public void updateAccountContactRelationship(List<AccountContactRelation> updateACRList){
      Set<Id> accountIdsAccociateWithACR = new Set<Id>();
      Map<Id,Id> mapOfContactIdAndHouseholdId = new Map<Id,Id>();
      Map<Id,Id> mapOfAccountIdAndHouseholdId = new Map<Id,Id>();
      List<sObject> accountRecordsWithChildRecord = new  List<sObject>();
      fetchConfiguredItemsFromCustomMetaData();
          for(AccountContactRelation singleACR : updateACRList){
              mapOfContactIdAndHouseholdId.put(singleACR.ContactId,singleACR.AccountId);
          }
      mapOfAccountIdAndHouseholdId = getAccountIdHouseholdIdMapAndUpdateAccountWithHHID(mapOfContactIdAndHouseholdId);
          
      accountIdsAccociateWithACR = mapOfAccountIdAndHouseholdId.keySet();
          
      accountRecordsWithChildRecord = UTIL_QueryBuilderForACR.getListofAccountRecordsWithChild(sObjectConfigItems,accountIdsAccociateWithACR);
      updateChildRecords(mapOfAccountIdAndHouseholdId, accountRecordsWithChildRecord);
  }
  
  private void updateChildRecords( Map<Id,Id> mapOfAccountIdAndHouseholdId, List<sObject> accountRecordsWithChildRecord){
      for (CM_SubQuery_Object_Settings__mdt singleConfigItem : sObjectConfigItems){    
              Map<Id,List<sObject>> accountIdAndsObjectMap = new Map<Id,List<sObject>>();
              for (sObject singlesObject : accountRecordsWithChildRecord){
                  accountIdAndsObjectMap.put(singlesObject.Id,singlesObject.getSObjects(singleConfigItem.SObject_Plural_Name__c));
              }
              getUpdateChildSObjectsRecordsWithHHid(accountIdAndsObjectMap,mapOfAccountIdAndHouseholdId,accountRecordsWithChildRecord);
          } 
  }
  
  /**
    * @description This method is to determine if the user is sync API user
    * @param username
    * @return boolean
    */
  public boolean isSyncUser(String username){
      return username.equals(CS_ACRTriggerCheckForSyncId__c.getInstance().Username__c);
  }
  
  /**
  * @description The method will map with AccountId and HouseholdId and update all Accounts with Household Ids
  * @author: Targaryen.SFDoc | 5/15/2020 
  * @param contactIdAndhouseholdId 
  * @return Map<Id, Id> 
  **/
  private static Map<Id,Id> getAccountIdHouseholdIdMapAndUpdateAccountWithHHID(Map<Id,Id> contactIdAndhouseholdId){
      List<Account> listofAccountRecord = new List<Account>();
      List<Account> listofAccountRecordToUpdate = new List<Account>();
      Map<Id,Id> mapOfAccountIdAndHouseholdIdFromContacts = new Map<Id,Id>();
      
      listofAccountRecord = [ SELECT Id, PersonContactId, Primary_Household__pc, clientIdentifier__c 
                              FROM Account 
                              WHERE PersonContactId IN:contactIdAndhouseholdId.KeySet()
                            ];
      
      for(Account singleAccount : listofAccountRecord){
          if(contactIdAndhouseholdId.containsKey(singleAccount.PersonContactId)){
              singleAccount.Primary_Household__pc = contactIdAndhouseholdId.get(singleAccount.PersonContactId);
              listofAccountRecordToUpdate.add(singleAccount);
              mapOfAccountIdAndHouseholdIdFromContacts.put(singleAccount.Id,contactIdAndhouseholdId.get(singleAccount.PersonContactId));
              contactIdClientIdMap.put(singleAccount.personContactId, singleAccount.clientIdentifier__c);
          }
      }

      if(listofAccountRecordToUpdate != null && !listofAccountRecordToUpdate.isEmpty()){
          update listofAccountRecordToUpdate;
         // Database.update(Security.stripInaccessible(AccessType.UPDATABLE, listofAccountRecordToUpdate).getRecords());
      }
      return mapOfAccountIdAndHouseholdIdFromContacts;
  }
    
  /**
  * @description The method will update all child records Household Id field with appropriate Household Id 
  * @author: Targaryen.SFDoc | 5/15/2020  
  * @param mapOfAccountIdAndSObjectRecords 
  * @param mapOfAccoountIdHouseholdId 
  * @param listofAccountRecords
  **/
  private static void getUpdateChildSObjectsRecordsWithHHid(Map<Id,List<sObject>> mapOfAccountIdAndSObjectRecords, Map<Id,Id> mapOfAccoountIdHouseholdId, List<sObject> listofAccountRecords){
      List<sObject> sObjectRecordToUpdate = new List<sObject>();
      for (sObject singleAccountRecord : listofAccountRecords){
          List<sObject> childsObjectRecords = mapOfAccountIdAndSObjectRecords.get(singleAccountRecord.Id);
          if(childsObjectRecords!= null && !childsObjectRecords.isEmpty()){
              for(sObject singleChildRecord : childsObjectRecords){
                  singleChildRecord.Put('Primary_Household__c',mapOfAccoountIdHouseholdId.get(singleAccountRecord.Id));
                  sObjectRecordToUpdate.add(singleChildRecord);
              } 
          }
      }
       
      if(sObjectRecordToUpdate != null && !sObjectRecordToUpdate.isEmpty()){
          update sObjectRecordToUpdate; 
         // Database.update(Security.stripInaccessible(AccessType.UPDATABLE, sObjectRecordToUpdate).getRecords());
        if(sObjectRecordToUpdate.get(0).getSObjectType() == Schema.AgentRole__c.getSObjectType()) {
            //This is used to call insert household shares after update Agent Role records 
            AP_NewAgentRoleTrigger.insertHousholdSharesFromACR(sObjectRecordToUpdate);
        }
      }
  }
    
  /**
  * @description The method will executed while ACR Delete Trigger invoked
  * @author: Targaryen.SFDoc | 5/15/2020 
  * @param removeACRList
  **/
  public void removeAccountContactRelationship(List<AccountContactRelation> removeACRList){
      Map<Id,Id> mapOfContactIdAndHouseholdId = new Map<Id,Id>();
      try{
           mapOfContactIdAndHouseholdId = updateChildObjectsForDeleteAcr(removeACRList);
       if(!isSyncUser(UserInfo.getName())){
        new AP_AccountContactRelationHandler().processRemoveMemberRequest(removeACRList, mapOfContactIdAndHouseholdId);
      }
      }catch(Exception fscHHException){
         UTIL_AgentProxySelection.tagAllErrors(removeACRList, fscHHException.getMessage());
         LoggingService.logHandledException(fscHHException, CLASS_NAME, DELETE_METHOD_NAME, LoggingLevel.ERROR);  
      }
  }
  
  /**
  * @description The method will execute while ACR Insert Trigger will invoked
  * @author: Targaryen.SFDoc | 5/15/2020 
  * @param removeACRList
  * @return Map<Id,Id>
  **/
  public Map<Id,Id> updateChildObjectsForDeleteAcr(List<AccountContactRelation> removeACRList){
      List<Id> listofContactIds = new List<Id>();
      Set<Id> setofAccountIds = new Set<Id>();
      Map<Id,Id> mapOfContactIdAndHouseholdId = new Map<Id,Id>();
      List<sObject> accountRecordsWithChildRecord = new List<sObject>();
     
      fetchConfiguredItemsFromCustomMetaData();
      for(AccountContactRelation singleACRrecord : removeACRList){
          listofContactIds.add(singleACRrecord.ContactId);
          mapOfContactIdAndHouseholdId.put(singleACRrecord.ContactId,singleACRrecord.AccountId);
      }
      setofAccountIds = HLPR_AccountContactRelationshipTrigger.getAccountIdsAndRemoveHHIdFromAccounts(listofContactIds);
      
      accountRecordsWithChildRecord = UTIL_QueryBuilderForACR.getListofAccountRecordsWithChild(sObjectConfigItems, setofAccountIds);
      for (CM_SubQuery_Object_Settings__mdt singleConfigItem : sObjectConfigItems){ 
          List<sObject> sObjectRecords = new List<sObject>();
          for (sObject singlesObject : accountRecordsWithChildRecord){
              if(singlesObject.getSObjects(singleConfigItem.SObject_Plural_Name__c)!=null && !singlesObject.getSObjects(singleConfigItem.SObject_Plural_Name__c).isEmpty()){
                  sObjectRecords.addAll(singlesObject.getSObjects(singleConfigItem.SObject_Plural_Name__c));
              }
          }
          HLPR_AccountContactRelationshipTrigger.getRemoveHHIdFromChildSObjectsRecords(sObjectRecords);
      }
          return mapOfContactIdAndHouseholdId;
  }

  /**
  * @description The method will fetch configuration items from Custom MetaData Types 
  * @author: Targaryen.SFDoc | 5/15/2020
  **/
  private static void fetchConfiguredItemsFromCustomMetaData () {
      sObjectConfigItems = [SELECT SObject_API_Name__c, SObject_Plural_Name__c, SObject_Field_Name__c 
                            FROM CM_SubQuery_Object_Settings__mdt WHERE IsActive__c = True LIMIT 50];
  }

}