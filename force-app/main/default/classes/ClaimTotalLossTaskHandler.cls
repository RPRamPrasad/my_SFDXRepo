/**
 * @name ClaimTotalLossTaskHandler
 * @description handle the creation of total loss tasks 
*/
public with sharing class ClaimTotalLossTaskHandler {
    private static final String CLASS_NAME = 'ClaimTotalLossTaskHandler';
    private static final String METHOD_NAME = 'determineTotalLossClaims';

    /**
     * @name taskInsertForTotalLoss
     * @description to insert a new Task for every TotalLoss Claim 
     * @param claimSet
     * @param triggerType 
     */
    public static void determineTotalLossClaims(Set<Claim> claimSet, String triggerType){
        try{
            Set<Id> policyIds = new Set<Id>();
            Set<Claim> preapprovedClaims = new Set<Claim>();
            Map<Id, Set<ClaimTaskWrapper>> policyToWrapperMap = new Map<Id, Set<ClaimTaskWrapper>>();

            switch on triggerType{
                when 'insert'{
                    preapprovedClaims = claimSet;
                }
                when else{
                    Set<Id> claimIds = new Set<Id>();
                    for(Claim claimRecord : claimSet){
                        claimIds.add(claimRecord.id);
                    }
                    preapprovedClaims = getClaimsWithoutTasks(claimIds, claimSet);
                }
            }

            for(Claim totalLossClaim : preapprovedClaims){
                policyIds.add(totalLossClaim.PolicyNumberId);
                ClaimTaskWrapper claimTaskWrapItem = new ClaimTaskWrapper();
                claimTaskWrapItem.claimId = totalLossClaim.id;
                claimTaskWrapItem.claimNumber = totalLossClaim.Name;
                claimTaskWrapItem.policyId = totalLossClaim.PolicyNumberId;
                claimTaskWrapItem.productDescription = totalLossClaim.ClaimDescription__c;
                if(isPolicyAlreadyMapped(policyToWrapperMap, totalLossClaim)){
                    Set<ClaimTaskWrapper> existingWrapper = policyToWrapperMap.get(totalLossClaim.PolicyNumberId);
                    existingWrapper.add(claimTaskWrapItem);
                    policyToWrapperMap.put(totalLossClaim.PolicyNumberId, existingWrapper);
                }else{
                    Set<ClaimTaskWrapper> claimTaskWrapSet = new Set<ClaimTaskWrapper>();
                    claimTaskWrapSet.add(claimTaskWrapItem);
                    policyToWrapperMap.put(totalLossClaim.PolicyNumberId, claimTaskWrapSet);
                }
            }

            if(policyToWrapperMap != null && !policyToWrapperMap.isEmpty()){
                buildTasks(policyIds, policyToWrapperMap);
            }
        }
        catch(Exception e){
            LoggingService.logHandledException(e, CLASS_NAME, METHOD_NAME, System.LoggingLevel.ERROR);
        }
    }

    /**
     * @name getClaimsWithoutTasks
     * @description find claims that do not have tasks 
     * @param claimIds
     * @param totalLossClaims
     * @return Set<Claim>
     */
    private static Set<Claim> getClaimsWithoutTasks(Set<Id> claimIds, Set<Claim> totalLossClaims){
        List<Task> taskFromClaim = Security.stripInaccessible(AccessType.READABLE,[Select id, WhatId from Task where WhatId in :claimIds AND Source__c = 'Claims']).getRecords();
        Set<Id> claimsWithTasks = new Set<Id>();
        Set<Claim> claimsWithoutTasks = new Set<Claim>();

        for(Task tsk : taskFromClaim){
            claimsWithTasks.add(tsk.WhatId);
        }

        for(Claim claimRecord : totalLossClaims){
            if(!claimsWithTasks.contains(claimRecord.Id)){
                claimsWithoutTasks.add(claimRecord);
            }
        }
        
        return claimsWithoutTasks;
    }

    /**
     * @name buildTasks
     * @description to build and insert a new Tasks 
     * @param policyIds
     * @param policyToWrapperMap
     */
    public static void buildTasks(Set<Id> policyIds, Map<Id, Set<ClaimTaskWrapper>> policyToWrapperMap){
        List<ClaimTaskWrapper> claimTaskWrapList = new List<ClaimTaskWrapper>();
        List<Task> totalLossTasks = new List<Task>();
        
        List<InsurancePolicy> policyList = Security.stripInaccessible(AccessType.READABLE,[Select Id, Name, NameInsuredId, NameInsured.PersonContactId, Servicing_Agent__c from InsurancePolicy where id in :policyIds]).getRecords();
        for(InsurancePolicy insPlcy : policyList){
            Set<ClaimTaskWrapper> claimTaskWrapSet = policyToWrapperMap.get(insPlcy.Id);
            for(ClaimTaskWrapper claimTaskWrapItem : claimTaskWrapSet){
                claimTaskWrapItem.accountId = insPlcy.NameInsuredId;
                claimTaskWrapItem.servicingAgent = insPlcy.Servicing_Agent__c;
                claimTaskWrapItem.insPolicyName = insPlcy.Name;
                claimTaskWrapItem.personContactId = insPlcy.NameInsured.PersonContactId;
                claimTaskWrapList.add(claimTaskWrapItem);
            }
        }

        for(ClaimTaskWrapper claimTaskWrapItem : claimTaskWrapList){
            Task newTask = new Task();
            newTask.subject = 'Total Loss Claim '+ claimTaskWrapItem.claimNumber +' - Action Required - Submit Policy Transaction'; 
            newTask.whatId = claimTaskWrapItem.claimId;
            newTask.whoId = claimTaskWrapItem.personContactId;
            newTask.status = 'Not Started';
            newTask.Priority = 'High';
            newTask.LineofBusiness__c = 'Auto';
            newTask.Task_Type__c = 'Service';
            newTask.Source__c = 'Claims';
            newTask.TaskCategory__c = 'Claim';
            newTask.Action_Required__c = 'Submit Policy Transaction';
            newTask.ProductDescription__c = claimTaskWrapItem.productDescription;
            newTask.PolicyNumber__c = claimTaskWrapItem.insPolicyName;
            newTask.OwnerId = claimTaskWrapItem.servicingAgent;
            newTask.description = 'A total loss has occurred on this policy.\nThis task requires a policy change to replace or suspend or owner retain this vehicle. For more information on the Total Loss Task, please review the "How to Manage Claim Capabilities in ECRM" resource on ABS > Services > Claims, in the Agency Claims Guide under Training or contact the Support Center and reference KI330348.';
            newTask.ActivityDate = system.Today();
            totalLossTasks.add(newTask);
        }
        
        if(totalLossTasks.size() > 0){
            List<Database.SaveResult> insertResults = Database.insert(totalLossTasks,false);
            logFailedRecords(insertResults, totalLossTasks);
        }
    }

    /**
     * @name isPolicyAlreadyMapped
     * @description Answers if the policy number has already been mapped for future Task insertion 
     * @param policyToWrapperMap
     * @param totalLossClaim
     * @return true if running as the Claim Sync user
     * @return boolean
     */
    @TestVisible
    private static Boolean isPolicyAlreadyMapped(Map<Id, Set<ClaimTaskWrapper>> policyToWrapperMap, Claim totalLossClaim){
        Boolean mapAlreadyFilled = false;
        
        Set<ClaimTaskWrapper> existingWrapper = policyToWrapperMap.get(totalLossClaim.PolicyNumberId);
        if(existingWrapper != null){
            mapAlreadyFilled = true;
        }
        return mapAlreadyFilled;
    }

    /**
     * @name logFailedRecords
     * @description Create the Exception Logs for the failed task inserts
     * @param insertResults
     * @param totalLossTasks
     */
    private static void logFailedRecords(List<Database.SaveResult> insertResults, List<Task> totalLossTasks){
        List<Database.SaveResult> failedRecords = new List<Database.SaveResult>();
        Set<String> failedAgentsSet = new Set<String>();
        List<Task> failedTasks = new List<Task>();
        
        for(Database.SaveResult singleResult : insertResults){
            getFailedRecordResults(singleResult, failedRecords, failedAgentsSet);
        }

        if(!failedAgentsSet.isEmpty()){
            sortFailedTaskOwnerErrorMessages(totalLossTasks, failedTasks, failedAgentsSet);
        }
        
        if(!failedTasks.isEmpty()){
            LoggingService.logDatabaseResult(failedRecords, failedTasks, CLASS_NAME, 'buildTasks', System.LoggingLevel.ERROR);
        }
    }

    /**
     * @name getFailedRecordResults
     * @description sort out the failed records from the successful records
     * @param singleResult
     * @param failedRecords
     * @param failedAgentsSet
     */
    private static void getFailedRecordResults(Database.SaveResult singleResult, List<Database.SaveResult> failedRecords, Set<String> failedAgentsSet){
        if(!singleResult.isSuccess()){
            failedRecords.add(singleResult);
            for(Database.Error err : singleResult.getErrors()) {                  
                if(err.getMessage().startsWith('operation performed with inactive user [')){
                    String ownerId = err.getMessage().substringAfter('[').substringBefore(']');
                    failedAgentsSet.add(ownerId);
                }
            }
        }
    }

    /**
     * @name sortFailedTaskOwnerErrorMessages
     * @description sort out the types of failed records
     * @param totalLossTasks
     * @param failedTasks
     * @param failedAgentsSet
     */
    private static void sortFailedTaskOwnerErrorMessages(List<Task> totalLossTasks, List<Task> failedTasks, Set<String> failedAgentsSet){
        for(Task singleTask : totalLossTasks){
            if(String.isBlank(singleTask.OwnerId)){
                failedTasks.add(singleTask);
            }else{
                for(String singleAgent : failedAgentsSet){
                    String idString = String.valueOf(singleTask.OwnerId);
                    if(idString.startsWith(singleAgent)){
                        failedTasks.add(singleTask);
                    }
                }
            }
        }
    }

    /**
     * @name ClaimTaskWrapper
     * @description wrapper class for each total loss task
     */
    public without sharing class ClaimTaskWrapper {
        public Id claimId;
        public String claimNumber;
        public Id policyId;
        public Id accountId;
        public Id servicingAgent;
        public String insPolicyName;
        public Id personContactId;
        public String productDescription;
    }
}