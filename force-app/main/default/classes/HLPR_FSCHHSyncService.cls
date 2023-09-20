/**
  * @author: Targaryen
  * @owner: Targaryen
  * @name: HLPR_FSCHHSyncService
  * @createdDate: 10/16/2020
  * @description The class is a helper class to populate request to FSCHHSyncService.
  * @version 1.0
  */
 public without sharing class HLPR_FSCHHSyncService {
  private static final String OPERATION_ADD_MEM = 'add mem';
  private static final String OPERATION_REMOVE_MEM = 'remove mem';
  private static final String OPERATION_REMOVE_SOFT = 'remove mem-soft';
  private static final String OPERATION_ADD_SOFT = 'add mem-soft';
  private static final String ASSOCIATE_ID = 'ASSOCIATE ID';
  private static final String FSC_HH_MEM = 'FSC HH Mem';
  private static final String ECRM = 'ECRM';
  private static User loggedInUser = new User();
  private static Map<id, String> contactIdClientIdMap = new Map<id, String>();
  private static Map<Id, String> accountIdSourceSystemIdMap = new Map<id, String>();
  
  /**
    * @description This method populates FSC household add member request
    * @param newACRList
    * @param contactClientIdMap    
    * @param accountSourceSystemIdMap
    * @return AP_FSCHHSyncServiceRequest
    */
  public static AP_FSCHHSyncServiceRequest populateFSCHHAddMemberRequest(List<AccountContactRelation> newACRList, Map<id, String> contactClientIdMap,Map<Id, String> accountSourceSystemIdMap){
      contactIdClientIdMap = contactClientIdMap;
      accountIdSourceSystemIdMap = accountSourceSystemIdMap;
      getLoggedInUser();
      AP_FSCHHSyncServiceRequest request = new AP_FSCHHSyncServiceRequest();
      request.data = getFSCHHSyncDataForAddMember(newACRList);
      request.meta = getMetaInformation();
      return request;
  }
  
  /**
   * @description Populate FSCHH Remove Member Request
   * @param newACRList 
   * @param contactClientIdMap 
   * @param accountSourceSystemIdMap
   * @return AP_FSCHHSyncServiceRequest
   */
  public static AP_FSCHHSyncServiceRequest populateFSCHHRemoveMemberRequest(List<AccountContactRelation> newACRList, Map<id, String> contactClientIdMap,Map<Id, String> accountSourceSystemIdMap){
      contactIdClientIdMap = contactClientIdMap;
      accountIdSourceSystemIdMap = accountSourceSystemIdMap;
      getLoggedInUser();
      AP_FSCHHSyncServiceRequest request = new AP_FSCHHSyncServiceRequest();
      request.data = getFSCHHSyncDataForRemoveMember(newACRList);
      request.meta = getMetaInformation();
      return request;
      
  }
  
  /**
   * @description Populate FSCHH Soft Remove Member Request
   * @param newACRList
   * @param contactClientIdMap
   * @param accountSourceSystemIdMap
   * @return AP_FSCHHSyncServiceRequest
   */
  public static AP_FSCHHSyncServiceRequest populateFSCHHSoftRemoveMemberRequest(List<AccountContactRelation> newACRList, Map<id, String> contactClientIdMap,Map<Id, String> accountSourceSystemIdMap){
      contactIdClientIdMap = contactClientIdMap;
      accountIdSourceSystemIdMap = accountSourceSystemIdMap;
      getLoggedInUser();
      AP_FSCHHSyncServiceRequest request = new AP_FSCHHSyncServiceRequest();
      request.data = getFSCHHSyncDataForSoftRemoveMember(newACRList);
      request.meta = getMetaInformation();
      return request;
      
  }
  
  /**
   * @description Populate FSCHH Soft Add Member Request
   * @param newACRList
   * @param contactClientIdMap
   * @param accountSourceSystemIdMap
   * @return AP_FSCHHSyncServiceRequest
   */
  public static AP_FSCHHSyncServiceRequest populateFSCHHSoftAddMemberRequest(List<AccountContactRelation> newACRList, Map<id, String> contactClientIdMap,Map<Id, String> accountSourceSystemIdMap){
      contactIdClientIdMap = contactClientIdMap;
      accountIdSourceSystemIdMap = accountSourceSystemIdMap;
      getLoggedInUser();
      AP_FSCHHSyncServiceRequest request = new AP_FSCHHSyncServiceRequest();
      request.data = getFSCHHSyncDataForSoftAddMember(newACRList);
      request.meta = getMetaInformation();
      return request;
      
  }
  
  /**
    * @description This method populates FSC household sync data
    * @param newACRList
    * @return AP_FSCHHSyncServiceRequest.FSCHHSyncData
    */
  private static AP_FSCHHSyncServiceRequest.FSCHHSyncData getFSCHHSyncDataForAddMember(List<AccountContactRelation> newACRList){
      AP_FSCHHSyncServiceRequest.FSCHHSyncData data = new AP_FSCHHSyncServiceRequest.FSCHHSyncData();
      data.operation = OPERATION_ADD_MEM;
      data.transactionTimestamp = System.now();
      data.groupInfo = getGroupInformationForAddMember(newACRList);
      return data;
  }
  
  /**
    * @description This method populates FSC household sync data
    * @param newACRList
    * @return AP_FSCHHSyncServiceRequest.FSCHHSyncData
    */
  private static AP_FSCHHSyncServiceRequest.FSCHHSyncData getFSCHHSyncDataForRemoveMember(List<AccountContactRelation> newACRList){
      AP_FSCHHSyncServiceRequest.FSCHHSyncData data = new AP_FSCHHSyncServiceRequest.FSCHHSyncData();
      data.operation = OPERATION_REMOVE_MEM;
      data.transactionTimestamp = System.now();
      data.groupInfo = getGroupInformationForRemoveMember(newACRList);
      return data;
  }
  
  private static AP_FSCHHSyncServiceRequest.FSCHHSyncData getFSCHHSyncDataForSoftRemoveMember(List<AccountContactRelation> newACRList){
      AP_FSCHHSyncServiceRequest.FSCHHSyncData data = new AP_FSCHHSyncServiceRequest.FSCHHSyncData();
      data.operation = OPERATION_REMOVE_SOFT;
      data.transactionTimestamp = System.now();
      data.groupInfo = getGroupInformationForSoftRemoveMember(newACRList);
      return data;
  }
  
  private static AP_FSCHHSyncServiceRequest.FSCHHSyncData getFSCHHSyncDataForSoftAddMember(List<AccountContactRelation> newACRList){
      AP_FSCHHSyncServiceRequest.FSCHHSyncData data = new AP_FSCHHSyncServiceRequest.FSCHHSyncData();
      data.operation = OPERATION_ADD_SOFT;
      data.transactionTimestamp = System.now();
      data.groupInfo = getGroupInformationForSoftAddMember(newACRList);
      return data;
  }
  /**
    * @description This method populates logged in user information
    */
  private static void getLoggedInUser(){
      List<User> loggedInUserInfo = Security.stripInaccessible(
          AccessType.READABLE,[SELECT Associate_Id__c,Servicing_Agent_Associate_ID__c from User where Id = :UserInfo.getUserId() limit 1]).getRecords();
      loggedInUser = loggedInUserInfo.get(0);
  }
  
  /**
    * @description This method populates FSC household meta information
    * @return AP_FSCHHSyncServiceRequest.FSCHHSyncMeta
    */
  private static AP_FSCHHSyncServiceRequest.FSCHHSyncMeta getMetaInformation(){
      AP_FSCHHSyncServiceRequest.FSCHHSyncMeta meta = new AP_FSCHHSyncServiceRequest.FSCHHSyncMeta();
      AP_FSCHHSyncServiceRequest.Requester requestor = new AP_FSCHHSyncServiceRequest.Requester();
      requestor.requesterReferenceId =  loggedInUser.Associate_Id__c;
      requestor.requesterReferenceType = ASSOCIATE_ID;
      meta.callingApplication = FSC_HH_MEM;
      meta.callingArea = ECRM;
      meta.requester = requestor;
      return meta;
  }
  
  /**
    * @description This method populates FSC household group information for list of acr records
    * @param newACRList
    * @return List<AP_FSCHHSyncServiceRequest.GroupInfo>
    */
  private static List<AP_FSCHHSyncServiceRequest.GroupInfo> getGroupInformationForAddMember(List<AccountContactRelation> newACRList){
      
      Map<Id,List<String>> householdIdClientIdMap = populateHouseholdIdClientIdMap(accountIdSourceSystemIdMap);
      List<AP_FSCHHSyncServiceRequest.GroupInfo> groupInfoList = new List<AP_FSCHHSyncServiceRequest.GroupInfo>();
      for(AccountContactRelation singleACR :newACRList){
        AP_FSCHHSyncServiceRequest.GroupInfo groupInfo = populateGroupInfo(singleACR, householdIdClientIdMap);
        groupInfo.isActive = true;
        groupInfo.EndDate = null;
        groupInfoList.add(groupInfo);
      }
      return groupInfoList;
  }
  
  private static List<AP_FSCHHSyncServiceRequest.GroupInfo> getGroupInformationForRemoveMember(List<AccountContactRelation> newACRList){
      Map<Id,List<String>> householdIdClientIdMap = populateHouseholdIdClientIdMap(accountIdSourceSystemIdMap);
      List<AP_FSCHHSyncServiceRequest.GroupInfo> groupInfoList = new List<AP_FSCHHSyncServiceRequest.GroupInfo>();
      for(AccountContactRelation singleACR :newACRList){
        AP_FSCHHSyncServiceRequest.GroupInfo groupInfo = populateGroupInfo(singleACR, householdIdClientIdMap);
        groupInfo.isActive = false;
        groupInfo.EndDate = null;
        groupInfoList.add(groupInfo);
      }
      return groupInfoList;
  }
  
  private static List<AP_FSCHHSyncServiceRequest.GroupInfo> getGroupInformationForSoftRemoveMember(List<AccountContactRelation> newACRList){
      Map<Id,List<String>> householdIdClientIdMap = populateHouseholdIdClientIdMap(accountIdSourceSystemIdMap);
      List<AP_FSCHHSyncServiceRequest.GroupInfo> groupInfoList = new List<AP_FSCHHSyncServiceRequest.GroupInfo>();
      for(AccountContactRelation singleACR :newACRList){
          AP_FSCHHSyncServiceRequest.GroupInfo groupInfo = populateGroupInfo(singleACR, householdIdClientIdMap);
          groupInfo.isActive = false;
          groupInfo.EndDate = System.today();
          groupInfoList.add(groupInfo);
      }
      return groupInfoList;
  }
  
  private static List<AP_FSCHHSyncServiceRequest.GroupInfo> getGroupInformationForSoftAddMember(List<AccountContactRelation> newACRList){
      Map<Id,List<String>> householdIdClientIdMap = populateHouseholdIdClientIdMap(accountIdSourceSystemIdMap);
      List<AP_FSCHHSyncServiceRequest.GroupInfo> groupInfoList = new List<AP_FSCHHSyncServiceRequest.GroupInfo>();
      for(AccountContactRelation singleACR :newACRList){
          AP_FSCHHSyncServiceRequest.GroupInfo groupInfo = populateGroupInfo(singleACR, householdIdClientIdMap);
          groupInfo.isActive = true;
          groupInfo.EndDate = null;
          groupInfoList.add(groupInfo);
      }
      return groupInfoList;
  }
  
  private static AP_FSCHHSyncServiceRequest.GroupInfo populateGroupInfo(AccountContactRelation acrRecord, Map<Id,List<String>> householdIdClientIdMap){
       AP_FSCHHSyncServiceRequest.GroupInfo groupInfo = new AP_FSCHHSyncServiceRequest.GroupInfo();
       groupInfo.groupIdRemovedIndicator = false;
       groupInfo.associateId = loggedInUser.Servicing_Agent_Associate_ID__c;
       groupInfo.fscExternalGroupIdImpacted =  accountIdSourceSystemIdMap.get(acrRecord.AccountId);
       groupInfo.hhMember = contactIdClientIdMap.get(acrRecord.contactId);
       if(!householdIdClientIdMap.isEmpty() && householdIdClientIdMap.containsKey(acrRecord.AccountId)){
          List<String> clientIdsList = householdIdClientIdMap.get(acrRecord.AccountId);
           for(Integer i=0; i<clientIdsList.size(); i++){
               if(contactIdClientIdMap.get(acrRecord.contactId).equals(clientIdsList[i])){
                   clientIdsList.remove(i);
               }
           }
          groupInfo.impactedCustomers = String.join(clientIdsList,',');
          
       }
         
      return groupInfo;
  }
  
  /**
    * @description This method populates householdId and clientId map
    * @param accountIdSourceSystemIdMap
    * @return Map<Id,List<String>>
    */
  private static Map<Id,List<String>> populateHouseholdIdClientIdMap(Map<Id, String> accountIdSourceSystemIdMap){
      Map<Id,List<String>> householdIdClientIdListMap = new Map<Id,List<String>>();
      List<AccountContactRelation> acrList = Security.stripInaccessible(
          AccessType.READABLE,[SELECT AccountId, contact.ClientIdentifier__c from AccountContactRelation where AccountId = :accountIdSourceSystemIdMap.keySet() and isActive = true]).getRecords();
      for(AccountContactRelation singleACR : acrList){
          if(householdIdClientIdListMap.get(singleACR.AccountId) == null) {
              householdIdClientIdListMap.put(singleACR.AccountId, new List<String>{singleACR.contact.ClientIdentifier__c});
          }else {
              List<String> clientIdsList = householdIdClientIdListMap.get(singleACR.AccountId);
              clientIdsList.add(singleACR.contact.ClientIdentifier__c);
              householdIdClientIdListMap.put(singleACR.AccountId, clientIdsList);
          }
      }
      return householdIdClientIdListMap;
  }
}