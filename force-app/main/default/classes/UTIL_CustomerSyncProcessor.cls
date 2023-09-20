/**
@Author: Team Loco Motivated
@name: UTIL_CustomerSyncProcessor
@Description: This class is responsible for maintaining the sync between MPD database and SFDC. It takes the JSON input
and accordingly inserts/updates the Account and Agent Role Objects
*/
/**
 * @description This class is responsible for maintaining the sync between MPD database and SFDC
 */
public without sharing class UTIL_CustomerSyncProcessor extends UTIL_StageOrchestrationProcessor {

    @TestVisible private static UTIL_ToggleStrategyContext toggleContext = new UTIL_ToggleStrategyContext();
    List<Id> accountInsertStageOrchIdList = new List<Id>();
    List<Id> accountUpdateStageOrchIdList = new List<Id>();
    List<Id> agentroleStageOrchIds = new List<Id>();
    Set<StageOrchestration__c> failedstageOrchSet = new Set<StageOrchestration__c> ();
    List<Id> failedStageOrchIdSet = new List<Id>();
    private integer maxErrorFieldLength=255;
    private UTIL_CustomerSyncProcessorWrapper procWrap = new UTIL_CustomerSyncProcessorWrapper();

  /**
    * @description It takes StageOrchestration__c object and synchronizes the customer information and relationship information
    * @param stageOrchList
    * @throws StageProcessorException
    */
    public override void execute(List<StageOrchestration__c> stageOrchList) {
        Long startTime = System.Datetime.now().getTime();
        List<StageOrchestration__c> stageOrchListToBeUpdated = new List<StageOrchestration__c>();
        Map<Id,AP_StageOrchestrationJSONParser> stageOrchIdJSONMap = new Map<Id,AP_StageOrchestrationJSONParser>();
        Map<String,Account> clientIdAccountMap = new Map<String,Account>();
        Map<String,Id> clientIdToStageOrchMap = new Map<String,Id>();
        //populateClientIdAccountMap(stageOrchList,clientIdToStageOrchMap,clientIdAccountMap,stageOrchIdJSONMap);
        ClientIdAccountMapWrapperList clientIdWrap = new ClientIdAccountMapWrapperList();
			clientIdWrap.stageOrchList = stageOrchList;
			clientIdWrap.clientIdToStageOrchMap = clientIdToStageOrchMap;
			clientIdWrap.clientIdAccountMap = clientIdAccountMap;
			clientIdWrap.stageOrchIdJSONMap = stageOrchIdJSONMap;
		populateClientIdAccountMap(clientIdWrap);
        handleAccountAgentRoleandGroupOperations(clientIdToStageOrchMap,clientIdAccountMap,stageOrchIdJSONMap);
        List<StageOrchestration__c> successStageOrchList = getStageOrchSuccessRecords(stageOrchList);
		stageOrchListToBeUpdated.addAll(successStageOrchList);
        stageOrchListToBeUpdated.addALL(failedstageOrchSet);
        Decimal txTimeSpan = (System.Datetime.now().getTime() - startTime)/(stageOrchList.size());
		update removeStageOrchDuplicates(stageOrchListToBeUpdated, txTimeSpan).values();
    }
    private Map<Id, StageOrchestration__c> removeStageOrchDuplicates(List<StageOrchestration__c> stageOrchList, Decimal timeSpan){
        Map<Id, StageOrchestration__c> stageOrchMapToBeUpdated = new Map<Id, StageOrchestration__c>();
        for(StageOrchestration__c stageOrch : stageOrchList){
            stageOrch.transactionSpan__c = timeSpan;
                stageOrchMapToBeUpdated.put(stageOrch.id, stageOrch);
        }
        return stageOrchMapToBeUpdated;
    }

    private void populateClientIdAccountMap(ClientIdAccountMapWrapperList accountMapWrapper){
		List<StageOrchestration__c> stageOrchList = accountMapWrapper.stageOrchList;
		Map<String,Id> clientIdToStageOrchMap = accountMapWrapper.clientIdToStageOrchMap;
		Map<String,Account> clientIdAccountMap = accountMapWrapper.clientIdAccountMap;
		Map<Id,AP_StageOrchestrationJSONParser> stageOrchIdJSONMap = accountMapWrapper.stageOrchIdJSONMap;

      List<Id> stageOrchIdList = new List<Id>();
      List<String> clientIdsList = new List<String>();
        for(StageOrchestration__c stageOrch : stageOrchList){
           try{
           stageOrchIdList.add(stageOrch.Id);
           final AP_StageOrchestrationJSONParser jsonObject = parseJSON(stageOrch.Value__c);
           List<Account> accountList =jsontoAccountConverter(jsonObject);
           clientIdToStageOrchMap.put(accountList.get(0).clientIdentifier__c,stageOrch.Id);
           clientIdsList.add(accountList.get(0).clientIdentifier__c);
           clientIdAccountMap.put(accountList.get(0).clientIdentifier__c,accountList.get(0));
           stageOrchIdJSONMap.put(stageOrch.Id,jsonObject);
           }catch(Exception exp){
               updateStageOrchFailedStatus(stageOrch.id, exp);
           }
        }
    }

    private class ClientIdAccountMapWrapperList{
        private List<StageOrchestration__c> stageOrchList;
        private Map<String,Id> clientIdToStageOrchMap;
        private Map<String,Account> clientIdAccountMap;
		private Map<Id,AP_StageOrchestrationJSONParser> stageOrchIdJSONMap;
    }

  /**
    * @description This method handles the the account data updates or inserts based on availability and the latest and greatest
    * @param clientIdStageOrchList
    * @param clientIdAccountMap
    * @param stageOrchIdJSONMap
    */
    private void handleAccountAgentRoleandGroupOperations(Map<String,Id> clientIdStageOrchList,Map<String,Account> clientIdAccountMap,Map<Id,AP_StageOrchestrationJSONParser> stageOrchIdJSONMap) {
        List<Account> sfdcAcctlist = [SELECT Id, RecordTypeId, ExternalSourceSyncTime__c, ClientIdentifier__c, Primary_Household__pc FROM Account
                                      WHERE ClientIdentifier__c =:clientIdStageOrchList.keySet()];
        Map<String,Account> existingclientIdAccountMap = new Map<String,Account>();
        if(!sfdcAcctlist.isEmpty()){
        for(Account singleAccount : sfdcAcctlist){
            existingclientIdAccountMap.put(singleAccount.clientIdentifier__c, singleAccount);
        }
        }
        List<Account> accountsToBeInserted = new List<Account>();
        List<Account> accountsToBeUpdated = new List<Account>();
        //populateAccountsToBeInsertedAndUpdated(clientIdStageOrchList,clientIdAccountMap,existingclientIdAccountMap, accountsToBeInserted,accountsToBeUpdated);
        AccountsToBeInsertedAndUpdatedWrapperList accountsInsertedAndUpdatedWrap = new AccountsToBeInsertedAndUpdatedWrapperList();
			accountsInsertedAndUpdatedWrap.clientIdStageOrchList = clientIdStageOrchList;
			accountsInsertedAndUpdatedWrap.clientIdAccountMap = clientIdAccountMap;
			accountsInsertedAndUpdatedWrap.existingclientIdAccountMap = existingclientIdAccountMap;
			accountsInsertedAndUpdatedWrap.accountsToBeInserted = accountsToBeInserted;
			accountsInsertedAndUpdatedWrap.accountsToBeUpdated = accountsToBeUpdated;
		populateAccountsToBeInsertedAndUpdated(accountsInsertedAndUpdatedWrap);
        if(!accountsToBeInserted.isEmpty()){
            List<Database.SaveResult> accountsInsertedResult = UTIL_AccountDAO.insertAccountResult(accountsToBeInserted);
            parseSaveResult(accountsInsertedResult, accountInsertStageOrchIdList);
        }
        if(!accountsToBeUpdated.isEmpty()){
            List<Database.SaveResult> accountsUpdatedResult = UTIL_AccountDAO.updatedAccountResult(accountsToBeUpdated);
            parseSaveResult(accountsUpdatedResult, accountUpdateStageOrchIdList);
        }
        handleAgentRoleandGroupOperations(stageOrchIdJSONMap);
    }

    private void populateAccountsToBeInsertedAndUpdated(AccountsToBeInsertedAndUpdatedWrapperList accountToBeInsertedAndUpdatedWrapper){
		Map<String,Id> clientIdStageOrchList = accountToBeInsertedAndUpdatedWrapper.clientIdStageOrchList;
		Map<String,Account> clientIdAccountMap = accountToBeInsertedAndUpdatedWrapper.clientIdAccountMap;
		Map<String,Account> existingclientIdAccountMap = accountToBeInsertedAndUpdatedWrapper.existingclientIdAccountMap;
		List<Account> accountsToBeInserted = accountToBeInsertedAndUpdatedWrapper.accountsToBeInserted;
		List<Account> accountsToBeUpdated = accountToBeInsertedAndUpdatedWrapper.accountsToBeUpdated;
        for(String clientId : clientIdAccountMap.keySet()){
            if(!existingclientIdAccountMap.keySet().contains(clientId)){
               accountsToBeInserted.add(clientIdAccountMap.get(clientId));
               accountInsertStageOrchIdList.add(clientIdStageOrchList.get(clientId));

            }
            else{
                Account accObject = clientIdAccountMap.get(ClientId);
                if(existingclientIdAccountMap.get(ClientId).ExternalSourceSyncTime__c<=accObject.ExternalSourceSyncTime__c || String.isBlank(String.valueOf(existingclientIdAccountMap.get(ClientId).ExternalSourceSyncTime__c))){
                    verifyRecordTypeIdChangeBeforeUpdate(accObject.RecordTypeId, existingclientIdAccountMap.get(ClientId).RecordTypeId);
                    accObject.id=existingclientIdAccountMap.get(ClientId).id;
                    accountsToBeUpdated.add(accObject);
                    accountUpdateStageOrchIdList.add(clientIdStageOrchList.get(clientId));

                }
            }
        }
    }

    private class AccountsToBeInsertedAndUpdatedWrapperList{
        private Map<String,Id> clientIdStageOrchList;
        private Map<String,Account> clientIdAccountMap;
        private Map<String,Account> existingclientIdAccountMap;
		private List<Account> accountsToBeInserted;
		private List<Account> accountsToBeUpdated;
    }

    private void parseSaveResult(List<Database.SaveResult> accountsSaveResult, List<Id> stageOrchIdsList){

            for(Integer i=0;i<accountsSaveResult.size();i++){
                if(!accountsSaveResult.get(i).isSuccess() && !failedStageOrchIdSet.contains(stageOrchIdsList.get(i))){
                    StageOrchestration__c failedstageOrch = new StageOrchestration__c(id = stageOrchIdsList.get(i));
                    failedStageOrchIdSet.add(stageOrchIdsList.get(i));
                    failedstageOrch.Status__c=UTIL_StageOrchestrationConstants.FAILURE_STATUS;
                    failedstageOrch.Error__c=accountsSaveResult.get(i).getErrors().get(0).getMessage().left(maxErrorFieldLength);
                    failedstageOrchSet.add(failedstageOrch);
                }
            }
    }

    private void handleAgentRoleandGroupOperations(final Map<Id,AP_StageOrchestrationJSONParser> stageOrchIdJSONMap) {
        List<AgentRole__c> agentRoleToCreateOrUpdate = new List<AgentRole__c>();
        List<CustomerGroup__c> groupListToUpsert = new List<CustomerGroup__c>();
        List<CustomerGroupMember__c> groupMemberListToUpsert = new List<CustomerGroupMember__c>();
        List<CustomerGroup__c> customergroupList = new List<CustomerGroup__c>();
        List<CustomerGroupMember__c> groupMemberList = new List<CustomerGroupMember__c>();
        for(Id stageOrchId :stageOrchIdJSONMap.keySet()){
            try{
            List<AgentRole__c> agentroles = jsonAgentRoleConverter(stageOrchIdJSONMap.get(stageOrchId));
            if(!agentroles.isEmpty()){
                UTIL_OrchestrationJSONtoGroupDetails.HLPR_GroupAndGroupMemberWrapper groupDetails=UTIL_OrchestrationJSONtoGroupDetails.jsonGroupDetailsConverter(stageOrchIdJSONMap.get(stageOrchId));
                customergroupList.addAll(groupDetails.groupList);
                groupMemberList.addALL(groupDetails.groupMemberList);
                agentRoleToCreateOrUpdate.addALL(agentroles);
                agentroleStageOrchIds.add(stageOrchId);
            }
            }catch(DataNotFoundException nf){
                updateStageOrchFailedwithUserNotfoundStatus(stageOrchId,nf);
            }catch(Exception exp){
                updateStageOrchFailedStatus(stageOrchId,exp);

            }
        }
        Map<String, List<Id>> groupStageOrchIdMap = populateGroupStageOrchIdMap(customergroupList, groupListToUpsert);
        List<String> groupMmeberIdList = new List<String>();
        for(CustomerGroupMember__c customerGroupmember: groupMemberList){
            if(groupMmeberIdList.isEmpty() ||!groupMmeberIdList.contains(customerGroupmember.GroupMemberId__c)){
                groupMemberListToUpsert.add(customerGroupmember);
                groupMmeberIdList.add(customerGroupmember.GroupMemberId__c);
            }
        }
         if (!agentRoleToCreateOrUpdate.isEmpty()){
            List<Database.UpsertResult> agentrolesUpdatedResult = UTIL_AgentRoleDAO.upsertedAgentRolesResult(agentRoleToCreateOrUpdate);
            parseUpsertResultSet(agentrolesUpdatedResult);
            List<Database.UpsertResult> groupUpsertedResult = UTIL_CustomerGroupDAO.upsertedGroupResult(groupListToUpsert);
            parseUpsertResultSetForGroup(groupUpsertedResult,groupListToUpsert,groupStageOrchIdMap);
            List<Database.UpsertResult> groupMemberUpsertedResult = UTIL_CustomerGroupMemberDAO.upsertedGroupMemberResult(groupMemberListToUpsert);
            parseUpsertResultSet(groupMemberUpsertedResult);
         }
    }

    private Map<String, List<Id>> populateGroupStageOrchIdMap(List<CustomerGroup__c> customergroupList, List<CustomerGroup__c> groupListToUpsert){
        return procWrap.populateGroupStageOrchIdMap(customergroupList, groupListToUpsert, agentroleStageOrchIds);
    }

    private void updateStageOrchFailedStatus(Id stageOrchId, Exception ex){
        if(!failedStageOrchIdSet.contains(stageOrchId)){
                    failedStageOrchIdSet.add(stageOrchId);
                    StageOrchestration__c stageOrch = new StageOrchestration__c(id = stageOrchId);
                    stageOrch.Status__c=UTIL_StageOrchestrationConstants.FAILURE_STATUS;
                    stageOrch.Error__c=ex.getmessage().left(maxErrorFieldLength);
                    failedstageOrchSet.add(stageOrch);
                 }
    }

    private void updateStageOrchFailedwithUserNotfoundStatus(Id stageOrchId, Exception ex){
        CustomerSyncProcessorVariableWrapper varWrap = new CustomerSyncProcessorVariableWrapper();
        varWrap.stageOrchId = stageOrchId;
        varWrap.ex = ex;
        varWrap.failedStageOrchIdSet = failedStageOrchIdSet;
        varWrap.failedstageOrchSet = failedstageOrchSet;
        varWrap.maxErrorFieldLength = maxErrorFieldLength;
        
        procWrap.updateStageOrchFailedwithUserNotfoundStatus(varWrap);
    }

    private void parseUpsertResultSet(List<Database.UpsertResult> upsertedResult){
        CustomerSyncProcessorVariableWrapper varWrap = new CustomerSyncProcessorVariableWrapper();
        varWrap.upsertedResult = upsertedResult;
        varWrap.failedStageOrchIdSet = failedStageOrchIdSet;
        varWrap.agentroleStageOrchIds = agentroleStageOrchIds;
        varWrap.maxErrorFieldLength = maxErrorFieldLength;
        varWrap.failedstageOrchSet = failedstageOrchSet;
        
        procWrap.parseUpsertResultSet(varWrap);
    }

    private void parseUpsertResultSetForGroup(List<Database.UpsertResult> upsertedResult, List<CustomerGroup__c> groupListToUpsert, Map<String, List<Id>> groupStageOrchIdMap){
        CustomerSyncProcessorVariableWrapper varWrap = new CustomerSyncProcessorVariableWrapper();
        varWrap.upsertedResult = upsertedResult;
        varWrap.groupListToUpsert = groupListToUpsert;
        varWrap.groupStageOrchIdMap = groupStageOrchIdMap;
        varWrap.failedstageOrchSet = failedstageOrchSet;
        varWrap.failedStageOrchIdSet = failedStageOrchIdSet;
        varWrap.maxErrorFieldLength = maxErrorFieldLength;
        
        procWrap.parseUpsertResultSetForGroup(varWrap);
    }

  /**
    * @description This method throws exception while JSON string having wrong RecordTypeId for specific ClientId
    * @param jsonRecordId
    * @param sfdcRecordId
    */
    private void verifyRecordTypeIdChangeBeforeUpdate(String jsonRecordId, String sfdcRecordId) {
        procWrap.verifyRecordTypeIdChangeBeforeUpdate(jsonRecordId, sfdcRecordId);
    }

    private List<StageOrchestration__c> getStageOrchSuccessRecords(List<StageOrchestration__c> allstageOrchList){
        return procWrap.getStageOrchSuccessRecords(allstageOrchList, failedStageOrchIdSet);
    }

    private class UTIL_CustomerSyncProcessorWrapper{
        
        private List<StageOrchestration__c> getStageOrchSuccessRecords(List<StageOrchestration__c> allstageOrchList, List<Id> failedStageOrchIdSet){
            List<StageOrchestration__c> successStageOrchList = new List<StageOrchestration__c>();
            for(StageOrchestration__c stageOrch : allstageOrchList){
                if(!failedStageOrchIdSet.contains(stageOrch.Id)){
                    StageOrchestration__c successStageOrch = new StageOrchestration__C(id = stageOrch.Id);
                    successStageOrch.Status__C = UTIL_StageOrchestrationConstants.SUCCESS_STATUS;
                    successStageOrchList.add(successStageOrch);
                }
            }
            return successStageOrchList;
        }

        private void verifyRecordTypeIdChangeBeforeUpdate(String jsonRecordId, String sfdcRecordId) {
            if(!sfdcRecordId.substring(0,15).Equals(jsonRecordId.substring(0,15))){
                throw new InvalidInputException(UTIL_StageOrchestrationConstants.RECORD_TYPE_CHANGE_EXCEPTION_MESSAGE);
            }
        }

        private void parseUpsertResultSetForGroup(CustomerSyncProcessorVariableWrapper varWrap){
            List<Database.UpsertResult> upsertedResult = varWrap.upsertedResult;
            List<CustomerGroup__c> groupListToUpsert = varWrap.groupListToUpsert;
            Map<String, List<Id>> groupStageOrchIdMap = varWrap.groupStageOrchIdMap;
            
            Set<StageOrchestration__c> failedstageOrchSet = varWrap.failedstageOrchSet;
        	List<Id> failedStageOrchIdSet = varWrap.failedStageOrchIdSet;
        	integer maxErrorFieldLength = varWrap.maxErrorFieldLength;
            
            for(Integer i=0;i<upsertedResult.size();i++){
                if(!upsertedResult.get(i).isSuccess()){
                   String groupId = groupListToUpsert.get(i).sfGroupIdentifier__c;
                   List<Id> failedsStageOrchIdList = groupStageOrchIdMap.get(groupId);
                   for(Id stageOrchId :failedsStageOrchIdList){
                       if(!failedStageOrchIdSet.contains(stageOrchId)){
                            StageOrchestration__c failedstageOrch = new StageOrchestration__c(id = stageOrchId);
                            failedStageOrchIdSet.add(stageOrchId);
                               failedstageOrch.Status__c=UTIL_StageOrchestrationConstants.FAILURE_STATUS;
                            failedstageOrch.Error__c=upsertedResult.get(i).getErrors().get(0).getMessage().left(maxErrorFieldLength);
                            failedstageOrchSet.add(failedstageOrch);
                       }
                    }
                }
            }
        }

        private void parseUpsertResultSet(CustomerSyncProcessorVariableWrapper varWrap){
            
            List<Database.UpsertResult> upsertedResult = varWrap.upsertedResult;
            List<Id> failedStageOrchIdSet = varWrap.failedStageOrchIdSet;
            List<Id> agentroleStageOrchIds = varWrap.agentroleStageOrchIds;
            integer maxErrorFieldLength = varWrap.maxErrorFieldLength;
            Set<StageOrchestration__c> failedstageOrchSet = varWrap.failedstageOrchSet;
                
            for(Integer i=0;i<upsertedResult.size();i++){
                if(!upsertedResult.get(i).isSuccess() && !failedStageOrchIdSet.contains(agentroleStageOrchIds.get(i))){
                    StageOrchestration__c failedstageOrch = new StageOrchestration__c(id = agentroleStageOrchIds.get(i));
                    failedStageOrchIdSet.add(agentroleStageOrchIds.get(i));
                    failedstageOrch.Status__c=UTIL_StageOrchestrationConstants.FAILURE_STATUS;
                    failedstageOrch.Error__c=upsertedResult.get(i).getErrors().get(0).getMessage().left(maxErrorFieldLength);
                    failedstageOrchSet.add(failedstageOrch);
                }
            }
        }

        private void updateStageOrchFailedwithUserNotfoundStatus(CustomerSyncProcessorVariableWrapper varWrap){
            Id stageOrchId = varWrap.stageOrchId;
            Exception ex = varWrap.ex;
            Set<StageOrchestration__c> failedstageOrchSet = varWrap.failedstageOrchSet;
        	List<Id> failedStageOrchIdSet = varWrap.failedStageOrchIdSet;
        	integer maxErrorFieldLength = varWrap.maxErrorFieldLength;
            
            
            if(!failedStageOrchIdSet.contains(stageOrchId)){
                failedStageOrchIdSet.add(stageOrchId);
                StageOrchestration__c stageOrch = new StageOrchestration__c(id = stageOrchId);
                stageOrch.Status__c=UTIL_StageOrchestrationConstants.FAILED_USER_NOT_FOUND;
                stageOrch.Error__c=ex.getmessage().left(maxErrorFieldLength);
                failedstageOrchSet.add(stageOrch);
            }
        }

        private Map<String, List<Id>> populateGroupStageOrchIdMap(List<CustomerGroup__c> customergroupList, List<CustomerGroup__c> groupListToUpsert, List<Id> agentroleStageOrchIds){
            List<String> sfGroupIdentifierList = new List<String>();
            Map<String, List<Id>> groupIdStageOrchIdMap = new Map<String, List<Id>>();
    
            for(Integer i=0;i<customergroupList.size(); i++){
               if(groupIdStageOrchIdMap.get(customergroupList.get(i).SFGroupIdentifier__C) == null){
                        groupIdStageOrchIdMap.put(customergroupList.get(i).SFGroupIdentifier__C, new List<Id>{agentroleStageOrchIds.get(i)});
                    }else{
                        List<Id> stageOrchIdsListforGroup = groupIdStageOrchIdMap.get(customergroupList.get(i).SFGroupIdentifier__C);
                        stageOrchIdsListforGroup.add(agentroleStageOrchIds.get(i));
                       groupIdStageOrchIdMap.put(customergroupList.get(i).SFGroupIdentifier__C, stageOrchIdsListforGroup);
                    }
                if(sfGroupIdentifierList.isEmpty() ||!sfGroupIdentifierList.contains(customergroupList.get(i).SFGroupIdentifier__C)){
                    groupListToUpsert.add(customergroupList.get(i));
                    sfGroupIdentifierList.add(customergroupList.get(i).SFGroupIdentifier__C);
                }
            }
            return groupIdStageOrchIdMap;
        }
    }
    
    private class CustomerSyncProcessorVariableWrapper{
        private Set<StageOrchestration__c> failedstageOrchSet;
        private List<Id> failedStageOrchIdSet;
        private integer maxErrorFieldLength;
        private List<Id> agentroleStageOrchIds;
        private Id stageOrchId;
		private Exception ex;
        
        private List<Database.UpsertResult> upsertedResult;
        private List<CustomerGroup__c> groupListToUpsert;
        private Map<String, List<Id>> groupStageOrchIdMap;
    }
}