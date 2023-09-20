/**
* @author: Targaryen
* @owner Targaryen
* @name: AP_AccountContactRelationHandler
* @createdDate 10/12/2020
* @description The class will perform all backend activities to ACR record updates.
* @version 1.0
*/
public without sharing class AP_AccountContactRelationHandler {
    /** @description variable is used by Account Trigger to check for Create Household flow*/
    public static Boolean isCreateHousehold = false;
    AP_AccountContactRelationshipTrigger acrTrigger = new AP_AccountContactRelationshipTrigger();
    private static Map<id, String> contactIdClientIdMap = new Map<id, String>();
    private static Map<Id, String> accountIdSourceSystemIdMap = new Map<Id, String>();
    HLPR_AccountContactRelationshipTrigger acrHelper = new HLPR_AccountContactRelationshipTrigger();
    private static final String HOUSEHOLD_RECORD_TYPE = 'IndustriesHousehold';
    private static final String CLASS_NAME = 'AP_AccountContactRelationHandler';

    /**
      * @description This method is to update external sync time for acr record
      * @param newACRList
      */
    public void updateExternalSyncTime(List<AccountContactRelation> newACRList){
        for(AccountContactRelation singleACR : newACRList){
            singleACR.ExternalSourceSyncTime__c = System.now();
        }
    }
    
    /**
      * @description This method processes Add member request to FSC household
      * @param newACRList
      */
    public void processAddMemberRequest(List<AccountContactRelation> newACRList){
        Map<Id,Id> mapOfContactIdAndHouseholdId = new Map<Id,Id>();
        for(AccountContactRelation singleACR : newACRList){
            mapOfContactIdAndHouseholdId.put(singleACR.ContactId,singleACR.AccountId);
        }
        if(!acrTrigger.isSyncUser(UserInfo.getName())){
            accountIdSourceSystemIdMap = acrHelper.populateAccountIdSourceSystemIdMap(mapOfContactIdAndHouseholdId.values());
            populateContactIdClientIdMap(mapOfContactIdAndHouseholdId.keySet());
            AP_FSCHHSyncServiceRequest hHSyncServiceRequest = HLPR_FSCHHSyncService.populateFSCHHAddMemberRequest(newACRList, contactIdClientIdMap, accountIdSourceSystemIdMap);
            String hHSyncServiceRequestBody = JSON.serialize(hHSyncServiceRequest);
            FSCAcrHHSyncCallout.acrSyncServiceCallout(hHSyncServiceRequestBody);
        }
    }
    
     /**
      * @description This method processes remove member request to FSC household
      * @param newACRList
      * @param mapOfContactIdAndHouseholdId
      */
    public void processRemoveMemberRequest(List<AccountContactRelation> newACRList, Map<Id,Id> mapOfContactIdAndHouseholdId){        
        accountIdSourceSystemIdMap = acrHelper.populateAccountIdSourceSystemIdMap(mapOfContactIdAndHouseholdId.values());
        populateContactIdClientIdMap(mapOfContactIdAndHouseholdId.keySet());
        AP_FSCHHSyncServiceRequest hHSyncServiceRequest = HLPR_FSCHHSyncService.populateFSCHHRemoveMemberRequest(newACRList, contactIdClientIdMap, accountIdSourceSystemIdMap);
        String hHSyncServiceRequestBody = JSON.serialize(hHSyncServiceRequest);
        FSCAcrHHSyncCallout.acrSyncServiceCallout(hHSyncServiceRequestBody); 
    }
    
    /**
    * @description This method processes soft remove member request to FSC household
    * @param newACRList
    */
    public void processSoftRemoveMemberRequest(List<AccountContactRelation> newACRList){        
        AP_FSCHHSyncServiceRequest hHSyncServiceRequest = HLPR_FSCHHSyncService.populateFSCHHRemoveMemberRequest(newACRList, contactIdClientIdMap, accountIdSourceSystemIdMap);
        String hHSyncServiceRequestBody = JSON.serialize(hHSyncServiceRequest);
        FSCAcrHHSyncCallout.acrSyncServiceCallout(hHSyncServiceRequestBody); 
         
    }
    
    /**
    * @description This method processes soft add member request to FSC household
    * @param newACRList
    */
    public void processSoftAddMemberRequest(List<AccountContactRelation> newACRList){        
        AP_FSCHHSyncServiceRequest hHSyncServiceRequest = HLPR_FSCHHSyncService.populateFSCHHSoftAddMemberRequest(newACRList, contactIdClientIdMap, accountIdSourceSystemIdMap);
        String hHSyncServiceRequestBody = JSON.serialize(hHSyncServiceRequest);
        FSCAcrHHSyncCallout.acrSyncServiceCallout(hHSyncServiceRequestBody); 
         
    }
    
        
    /**
      * @description This method populates contactid and clientid Map
      * @param contactIdList
      */
    private void populateContactIdClientIdMap(Set<Id> contactIdList){
        List<Account> listofAccountRecord = [ SELECT Id, PersonContactId, clientIdentifier__c 
                                              FROM Account 
                                              WHERE PersonContactId IN:contactIdList
                                            ];
        for (Account accountRecord : listofAccountRecord){
            contactIdClientIdMap.put(accountRecord.PersonContactId, accountRecord.clientIdentifier__c);
        }
    }
    
    /**
    * @description This method calls from AccountContactRelation update and process add or remove member flow
    * @param oldAcrMap
    * @param newAcrList
    */
    public void processAccountContactRelationshipUpdates(Map<Id, AccountContactRelation> oldAcrMap,List<AccountContactRelation> newAcrList ){
        Map<Id,Id> mapOfContactIdAndHouseholdId = new Map<Id,Id>();
        List<AccountContactRelation> inactiveAcrList = new List<AccountContactRelation>();
        List<AccountContactRelation> activeAcrList = new List<AccountContactRelation>();
        for(AccountContactRelation singleAcr : newAcrList){
            mapOfContactIdAndHouseholdId.put(singleACR.ContactId,singleACR.AccountId);
        }
        accountIdSourceSystemIdMap = acrHelper.populateAccountIdSourceSystemIdMap(mapOfContactIdAndHouseholdId.values());
        for(AccountContactRelation singleAcr : newAcrList){
        	populateContactIdClientIdMap(mapOfContactIdAndHouseholdId.keySet());
            if(oldAcrMap.get(singleAcr.Id).IsActive && !singleAcr.IsActive){
                inactiveAcrList.add(singleAcr);
            }
            if(!oldAcrMap.get(singleAcr.Id).IsActive && singleAcr.IsActive){
                activeAcrList.add(singleAcr);
            }
        }
        handleInactiveACRList(inactiveAcrList);
        handleActiveACRList(activeAcrList);
    }

    private void handleInactiveACRList(List<AccountContactRelation> inactiveAcrList){
        if(!inactiveAcrList.isempty()){
            acrTrigger.updateChildObjectsForDeleteAcr(inactiveAcrList);
            if(!acrTrigger.isSyncUser(UserInfo.getName())){
                processSoftRemoveMemberRequest(inactiveAcrList);
            }
        }
    }
    
    private void handleActiveACRList(List<AccountContactRelation> activeAcrList){
        if(!activeAcrList.isEmpty()){
            acrTrigger.updateAccountContactRelationship(activeAcrList);
            if(!acrTrigger.isSyncUser(UserInfo.getName())){
                processSoftAddMemberRequest(activeAcrList);
            }
        }
    }

    /**
    * @description This method is used to household shares when using Create Household button
    * change of ownership
    * @param newAcrList
    */
    public void handleHouseholdOwnershipAndShare(List<AccountContactRelation> newAcrList){
        
        String methodName = 'handleHouseholdOwnershipAndShare';
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = AccountOwnerSystemUserCustomSetting__c.getInstance();
        String householdRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId();
        try{
            if(isCreateHousehold && newAcrList.size() == 1 ) {
                Account household = [ SELECT Id, OwnerId 
                    				  FROM Account 
                                      WHERE Id =: newAcrList.get(0).AccountId AND RecordTypeId =: householdRecTypeId
                                    ];
                if(household.OwnerId != sysAdminUserIdSetting.SFDC_User_ID__c) {
                    household.OwnerId = sysAdminUserIdSetting.SFDC_User_ID__c;
                    update household;
                    List<AgentRole__c> agentRolelist = [ SELECT Id, Primary_Household__c, Customer__c, Agent__c 
                                                         FROM AgentRole__c
                                                         WHERE Primary_Household__c =: newAcrList.get(0).AccountId
                                                        ];
                    AP_NewAgentRoleTrigger.insertHousholdSharesFromACR(agentRolelist);
                }
            }
        } catch(Exception e) {
            LoggingService.logHandledException(e,CLASS_NAME,methodName,System.LoggingLevel.ERROR);
        }  
    }

}