 /*
* @Author Team Dream Builders, Loco Motivated & Clubcar
* @Name UTIL_StageOrchestrationProcessor
* @CreateDate 10/11/2016
* @Description This is a utility class that abstracts FrameWork fro SYNC Process
* @11/16 Commented few methods which are not used to increase the code Coverage
* @Version 1.0
*/

/*
* @Author Team Choo Choo
* @Name UTIL_StageOrchestrationProcessor
* @CreateDate 05/1/2018
* @Description This is a utility class that abstracts FrameWork fro SYNC Process
* @05/18 Added methods to accomodate assigned Staff
* @Version 2.0
*/

/*
* @Author Team Targaryen
* @Name UTIL_StageOrchestrationProcessor
* @Description This is a utility class that abstracts FrameWork fro SYNC Process
* @11/11  Updated execute method to accept list of stageorchestration records
* @Version 2.0
*/
/**
 * @description This is a utility class that abstracts FrameWork fro SYNC Process
 */
public without sharing abstract class UTIL_StageOrchestrationProcessor {
    private String executeMethodName='execute';
    /**
     * @description common execute for SYNC process
     * @param stageOrchList
     */
    public abstract void execute(List<StageOrchestration__c> stageOrchList);

    /**
     * @description Common JSONParser for SYNC processors
     * @param json
     * @return AP_StageOrchestrationJSONParser
     */
    public AP_StageOrchestrationJSONParser parseJSON(String json){
        if(String.isNotBlank(json)){
            return AP_StageOrchestrationJSONParser.parse(json);
        } else {
            throw new InvalidInputException(UTIL_StageOrchestrationConstants.EMPTY_JSON_EXCEPTION_MESSAGE);
        }
    }

    /**
     * @description UTIL_OrchestrationJSONtoAccountconverter: Json to Account convertSetOfIDSAsString
     * @param parseAgentJSON
     * @return List<Account>
     */
    public List<Account> jsontoAccountConverter(AP_StageOrchestrationJSONParser parseAgentJSON){
        return UTIL_OrchestrationJSONtoAccountconverter.jsontoAccountConverter(parseAgentJSON);
    }

    /**
     * @description UTIL_OrchestrationJSONtoAgentRole: Json to Agent Role convertSetOfIDSAsString
     * @param parseAgentJSON
     * @return List<AgentRole__c>
     */
    public List<AgentRole__c> jsonAgentRoleConverter(AP_StageOrchestrationJSONParser parseAgentJSON){
         return UTIL_OrchestrationJSONtoAgentRole.jsonAgentRoleConverter(parseAgentJSON);
    }

    /**
     * @description UTIL_OrchestrationJSONtoAgentAssocIds: Json to Agent Role convertSetOfIDSAsString
     * @param parseAgentJSON
     * @return Set<String>
     */
    public Set<String> jsonToAgentAssocIdConverter(AP_StageOrchestrationJSONParser parseAgentJSON){
         return UTIL_OrchestrationJSONtoAgentRole.processAgentAssocIdsFromJson(parseAgentJSON);
    }

    /**
     * @description UTIL_OrchestrationJSONtoAgentRole: Json to Agent Role convertSetOfIDSAsString
     * @param parseAgentJSON
     * @return UTIL_OrchestrationJSONtoGroupDetails
     */
    public UTIL_OrchestrationJSONtoGroupDetails.HLPR_GroupAndGroupMemberWrapper jsonGroupDetailsConverter(AP_StageOrchestrationJSONParser parseAgentJSON){
         return UTIL_OrchestrationJSONtoGroupDetails.jsonGroupDetailsConverter(parseAgentJSON);
    }

    /**
     * @description UTIL_OrchestrationJSONtoC2C: Json to Relationship convertSetOfIDSAsString
     * @param parseAgentJSON
     * @return List<Relationship__c>
     */
    public List<Relationship__c> jsontoC2CConverter(AP_StageOrchestrationJSONParser parseAgentJSON){
        return UTIL_OrchestrationJSONtoC2CConverter.jsontoCustomerRelationshipConverter(parseAgentJSON);
    }

    /**
     * @description UTIL_AgentRoleDAO
     * @param agentroles
     */
    public void upsertUserAgentRoles(List<AgentRole__c> agentroles) {
        UTIL_AgentRoleDAO.upsertUserAgentRoles(agentroles);
    }

    /**
     * @description UTIL_AgentRoleDAO
     * @param agentroles
     */
    public void upsertUserAgentRole(AgentRole__c agentroles) {
        UTIL_AgentRoleDAO.upsertUserAgentRole(agentroles);
    }

    /**
     * @description UTIL_AgentRoleDAO
     * @param agentRoleList
     */
    public void deleteAgentRoles(List<AgentRole__c> agentRoleList) {
        UTIL_AgentRoleDAO.deleteAgentRoles(agentRoleList);
    }

    /**
     * @description UTIL_AgentRoleDAO
     * @param agentRole
     */
    public void deleteAgentRole(AgentRole__c agentRole) {
        try{
            UTIL_AgentRoleDAO.deleteAgentRole(agentRole);
        }catch(Exception exp){
            if (exp.getmessage().contains(UTIL_StageOrchestrationConstants.ENTITY_IS_DELETED)){
                throw new DataNotFoundException(UTIL_StageOrchestrationConstants.ENTITY_IS_DELETED_WARNING_MSG + exp);
            }else{
                throw exp;
            }
        }
    }

    /**
     * @description UTIL_AccountDAO
     * @param account
     */
    public void insertAccount(Account account) {
        UTIL_AccountDAO.insertAccount(account);
    }

    /**
     * @description UTIL_AccountDAO
     * @param account
     */
    public void upsertAccount(Account account) {
        UTIL_AccountDAO.upsertAccount(account);
    }

    /**
     * @description upsert accounts by client identifier
     * @param listOfAccounts
     */
    public void upsertAccountsByClientIdentifier(List<Account> listOfAccounts){
        UTIL_AccountDAO.upsertAccountsByClientIdentifier(listOfAccounts);
    }

    /**
     * @description UTIL_AccountDAO
     * @param account
     */
    public void updateAccount(Account account) {
        UTIL_AccountDAO.updateAccount(account);
    }

    /**@description UTIL_AccountDAO
     * @param accountList
     */
    public void insertAccounts(List<Account> accountList) {
        UTIL_AccountDAO.insertAccounts(accountList);
    }

    /**
     * @description AccountMessage DateOfContact__c
     * @param accountMessageList
     */
    public void updateAccountMessages(List<AccountMessage__c> accountMessageList) {
        UTIL_AccountMessageDAO.updateAccountMessages(accountMessageList);
    }

    /**
     * @description UTIL_AccountMessageDAO
     * @param accountMessageList
     */
    public void deleteAccountMessages(List<AccountMessage__c> accountMessageList){
        UTIL_AccountMessageDAO.deleteAccountMessages(accountMessageList);
    }

    /**
     * @description UTIL_AssignedStaffDAO
     * @param assignedStaffList
     * @return assignedStaffList
     */
    public Database.SaveResult[] updateAssignedStaff(List<AssignedStaff__c> assignedStaffList){
        return UTIL_AssignedStaffDAO.updateAssignedStaffWithResponse(assignedStaffList);
    }

    /**
     * @description UTIL_AssignedStaffDAO
     * @param assignedStaffList
     */
    public void deleteAssignedStaff(List<AssignedStaff__c> assignedStaffList){
        UTIL_AssignedStaffDAO.deleteAssignedStaff(assignedStaffList);
    }

    /**
     * @description UTIL_LeadConversionDetailDAO
     * @param leadConversionDetailList
     */
    public void deleteLeadConversionDetails(List<LeadConversionDetail__c> leadConversionDetailList) {
        UTIL_LeadConversionDetailDAO.deleteLeadConversionDetails(leadConversionDetailList);
    }

    /**
     * @description UTIL_FeedItemDAO
     * @param feedItemList
     */
    public void insertFeedItems(List<FeedItem> feedItemList) {
        UTIL_FeedItemDAO.insertFeedItems(feedItemList);
    }

    /**
     * @description UTIL_OpportunityDAO
     * @param oppList
     */
    public void insertOpportunityForAccount(List<Opportunity> oppList) {
        UTIL_OpportunityDAO.insertOpportunityForAccount(oppList);
    }

    /**
     * @description UTIL_TaskDAO
     * @param taskList
     */
    public void insertTasks(List<Task> taskList) {
        UTIL_TaskDAO.insertTasks(taskList);
    }

    /**
     * @description UTIL_TaskRelationDAO
     * @param taskRelationList
     */
    public void insertTaskRelations(List<TaskRelation> taskRelationList) {
        UTIL_TaskRelationDAO.insertTaskRelations(taskRelationList);
    }

    /**
     * @description UTIL_TaskDAO
     * @param taskList
     * @param systemuserId
     */
    public void updateandDisaasociateTask(List<Task> taskList, id systemuserId) {
       UTIL_TaskDAO.completeTasksAndUpdateOwnerToSystemUser(taskList,systemuserId);
    }

    /**
     * @description UTIL_OpportunityDAO
     * @param opptyList
     * @param systemuserId
     */
    public void updateandDisaasociateOpportunites(List<Opportunity> opptyList,id systemuserId) {
        UTIL_OpportunityDAO.closeOpportunitiesAndUpdateOwnerToSystemUser(opptyList,systemuserId);
    }

    /**
     * @description UTIL_PlanningConversationLogDAO
     * @param planningConversationLogList
     */
    public void updatePlanningConversationLog(List<PlanningConversationLog__c> planningConversationLogList) {
        UTIL_PlanningConversationLogDAO.updatePlanningConversationLog(planningConversationLogList);
    }

    /**
     * @description UTIL_SimpleConversationDAO
     * @param simpleConversationList
     */
    public void updateSimpleConversation(List<SimpleConversation__c> simpleConversationList) {
        UTIL_SimpleConversationDAO.updateSimpleConversation(simpleConversationList);
    }

    /**
     * @description UTIL_CustomerInitiatedCancellationsDAO
     * @param customerInitiatedCancellationList
     */
    public void insertCustomerInitiatedCancellation(List<CustomerInitiatedCancellations__c> customerInitiatedCancellationList) {
        UTIL_CustomerInitiatedCancellationsDAO.insertCustomerInitiatedCancellations(customerInitiatedCancellationList);
    }

    /**
     * @description UTIL_CustomerInitiatedCancellationsDAO
     * @param customerInitiatedCancellationList
     */
    public void updateCustomerInitiatedCancellation(List<CustomerInitiatedCancellations__c> customerInitiatedCancellationList) {
        UTIL_CustomerInitiatedCancellationsDAO.updateCustomerInitiatedCancellations(customerInitiatedCancellationList);
    }

    /**
     * @description UTIL_C2CRelationshipDAO: Handles inserting Customer Relationships
     * @param relationship
     */
    public void insertRelationship(Relationship__c relationship) {
        UTIL_C2CRelationshipDAO.insertRelationship(relationship);
    }

    /**
     * @description UTIL_C2CRelationshipDAO: Handles inserting List of Customer Relationships
     * @param relationshipLstToInsert
     * @param isFailSafe
     */
    public void insertC2CRelationships(List<Relationship__c> relationshipLstToInsert,boolean isFailSafe) {
        if(!isFailSafe){
        UTIL_C2CRelationshipDAO.insertC2CRelationships(relationshipLstToInsert);
        }else{
            UTIL_C2CRelationshipDAO.insertC2CRelationshipsFailSafe(relationshipLstToInsert);
        }

    }

    /**
     * @description UTIL_C2CRelationshipDAO: Handles updating Customer Relationships
     * @param relationship
     */
    public void updateRelationship(Relationship__c relationship) {
        UTIL_C2CRelationshipDAO.updateRelationship(relationship);
    }

    /**
     * @description UTIL_C2CRelationshipDAO: Handles deleting Customer Relationships
     * @param deletedClientRelationshiplst
     */
    public void deleteRelationship(List<Relationship__c> deletedClientRelationshiplst) {
        UTIL_C2CRelationshipDAO.deleteCustomerRelationships(deletedClientRelationshiplst);
    }

    /**
     * @description UTIL_CampaignMemberDAO
     * @param campaignMemberList
     */
    public void deleteCampaignMembers(List<CampaignMember> campaignMemberList) {
        UTIL_CampaignMemberDAO.deleteCampaignMembers(campaignMemberList);
    }

    /**
     * @description UTIL_GroupDAO
     * @param groupListToUpsert
     */
    public void upsertCustomerHouseholdGroup(List<CustomerGroup__c> groupListToUpsert) {
        UTIL_CustomerGroupDAO.upsertCustomerGroupList(groupListToUpsert);
    }

    /**
     * @description UTIL_GroupMemberDAO
     * @param groupMemberListToUpsert
     */
    public void upsertCustomerHouseholdGroupMember(List<CustomerGroupMember__c> groupMemberListToUpsert) {
        UTIL_CustomerGroupMemberDAO.upsertCustomerGroupMemberList(groupMemberListToUpsert);
    }

    /**
     * @description UTIL_GroupMemberDAO
     * @param groupMemberListToDelete
     */
    public void deleteCustomerHouseholdGroupMember(List<CustomerGroupMember__c> groupMemberListToDelete) {
        UTIL_CustomerGroupMemberDAO.deleteHouseholdCustomerGroupMemberList(groupMemberListToDelete);
    }

    /**
     * @description UTIL_GroupMemberDAO
     * @param productsServicedByMeList
     */
    public void deleteProductsServicedByMe(List<ProductsServicedByMe__c> productsServicedByMeList) {
        UTIL_ProductsServicedByMeDAO.deleteProductsServicedByMe(productsServicedByMeList);
    }

    /**
    * @description returns the system userId which is stored on Custom Settings. If not available throws RecordOwnerException
    * @Name : getSystemRecordOwnerId
    * @return : Id
    */
    public Id getSystemRecordOwnerId(){
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = AccountOwnerSystemUserCustomSetting__c.getInstance();

        if(sysAdminUserIdSetting != null && !String.isBlank(sysAdminUserIdSetting.SFDC_User_ID__c)) {
            return sysAdminUserIdSetting.SFDC_User_ID__c;
        }
        else {
            throw new RecordOwnerException(System.Label.CL_SystemUserNotFound);
        }
    }

    /**
     * @description reassinging the opportunities to system user SYSTEM_USER_REC_OWNER
     * @param oppty
     * @param assignedToId
     * @param ownerId
     * @return  `Opportunity`
     */
    public Opportunity closeOpportunitiesAndUpdateOwnerToSystemUser(Opportunity oppty, Id assignedToId, Id ownerId){
        // reassinging the opportunities to system user SYSTEM_USER_REC_OWNER
        if(oppty!= null){
            if(oppty.StageName != UTIL_StageOrchestrationConstants.OPPORTUNITY_CLOSED_STAGE_NAME){
                oppty.StageName = UTIL_StageOrchestrationConstants.OPPORTUNITY_CLOSED_STAGE_NAME;
                oppty.Closed_Reason__c = UTIL_StageOrchestrationConstants.OPPORTUNITY_TASK_CLOSED_REASON;
                oppty.Description = UTIL_OpportunityDAO.descriptionToCloseForOpportunities(oppty.Description);
            }
            oppty.Assigned_To__c = assignedToId;//assigning proxy user to all the task for future purpose
            oppty.ownerid=ownerId;//assigning statefarm user
        }
        return oppty;
    }

  /**
    * @description Takes the list of sObjects and delete list associated with Account in and Associated with particular Agent in SFDC
    * @Name : deletesObjectList
    * @param sObjectListToDelete
    * @param className
    * @param methodName
    */
    public void deletesObjectList(List<sObject> sObjectListToDelete,string className, string methodName){
        if(sObjectListToDelete != null && !sObjectListToDelete.isEmpty()) {
            List<Database.DeleteResult> deleteResultList = Database.delete(sObjectListToDelete, false);
            String alreadyDeletedIds=UTIL_Constants.NO_SPACE;
            for (Database.DeleteResult delreslt : deleteResultList) {
                if(!delreslt.isSuccess()){
                    alreadyDeletedIds=alreadyDeletedIds+validateFailures(delreslt);
                }
            }
            if(String.isNotBlank(alreadyDeletedIds)){
                alreadyDeletedIds = alreadyDeletedIds.removeEnd(UTIL_StageOrchestrationConstants.COMMA);
                LoggingService.logHandledException(new EntityDeletedException(UTIL_StageOrchestrationConstants.DELETED_WARNING_MSG+UTIL_Constants.COLON_SYMBOL+
                                                                              UTIL_Constants.SPACE_SYMBOL+alreadyDeletedIds),className, methodName,
                                                                              LoggingLevel.WARN);
            }
        }
    }



  /**
    * @description Takes the deleted result of GroupMember
    * @Name : validateFailures
    * @param delreslt
    * @return : String
    */
    private String validateFailures(Database.DeleteResult delreslt){
        Database.Error[] errors=delreslt.getErrors();
        for(Database.Error error:errors){
            if(!StatusCode.ENTITY_IS_DELETED.equals(error.getStatusCode())){
                throw new DmlException(error.getMessage());
            }
        }
        return delreslt.getId()+UTIL_StageOrchestrationConstants.COMMA;
    }

    /**
    * @description Handles Processors Exception
    * @Name : handleException
    * @param exp
    * @param className
    * @param sp
    */
    public void handleException(Exception exp, String className, Savepoint sp){
        if(exp.getCause() instanceof DataNotFoundException && exp.getMessage().contains(UTIL_StageOrchestrationConstants.ENTITY_IS_DELETED_WARNING_MSG)){
            LoggingService.logHandledException(exp, className, executeMethodName, LoggingLevel.WARN);
        }
        else{
            Database.rollback(sp);
            throw new StageProcessorException(exp.getmessage(),exp);
        }
    }
}