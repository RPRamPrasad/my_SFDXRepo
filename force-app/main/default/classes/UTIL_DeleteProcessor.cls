/**
* @Name UTIL_DeleteProcessor
* @Description This is a utility class that implements Delete Account and all related Opportunities,
* @CampaignMembers and closing all Tasks associated with Account due to Sync with StateFarm DB MPD.
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0            Loco Motivated           10/05/2016              Initial Development
2.0            Club Car                 05/25/2016              added logic for Case object
3.0            Golden Spikes            05/16/2018              Updated to delete the planning conversation log records on Account delete
4.0            Golden Spikes            08/16/2018              Updated to delete the simple conversation records on Account delete
5.0            Golden Spikes            10/15/2019              Updated to delete the lead records on Account delete
6.0            Quadcore                 01/27/2021              Update to delete the Salesattempt records related to the Opportunity
******************************************************************************************/
/**
 * @description This is a utility class that implements Delete Account and all related Opportunities
 */
public without sharing class UTIL_DeleteProcessor extends UTIL_StageOrchestrationProcessor {

    @TestVisible private static UTIL_ToggleStrategyContext toggleContext = new UTIL_ToggleStrategyContext();
    private static final String METHOD_NAME = 'deleteProcessor';
    private static final String CLASS_NAME = 'UTIL_DeleteProcessor';

    /**
     * @description deleteProcessor: Execute method for delete Account, Opportunities, Campaign Members and Closed Tasks, Cases and disassociated with Account in SFDC
     * @param stageOrchestrationList
     */
    public override void execute(List<StageOrchestration__c> stageOrchestrationList){
        StageOrchestration__c stageOrchestration = stageOrchestrationList.get(0);
           Savepoint sp = Database.setSavepoint();
        try {
            AP_StageOrchestrationJSONParser objParser = parseJSON(stageOrchestration.Value__c);
            String clientId = objParser.OrchestrationInfo.OrchestrationEventName.OrchestrationEventDetail.OrchestrationEventValues.clientId;

            List<Account> accRecordList = [
                SELECT Id,PersonContactId,
                                       (Select Id, status FROM Tasks where isRecurrence=false),
                                       (Select Id, status FROM Cases),
                                       (Select Id FROM Opportunities),
                                       (Select Id FROM LeadConversionDetails__r),
                                       (Select Id From Leads__r),
                                       (Select Id From Relationships__r),
                                       (Select Id From Relationships1__r),
                                       (Select Id From Customer_Groupings__r),
                                       (Select Id From AgentContexts__r),
                                       (select Id From AssignedStaff__r),
                                       (Select Id From Planning_Conversation_Logs__r),
                                       (Select Id From Simple_Conversations__r),
                                       (Select Id From LeadMetrics__r)
                FROM Account WHERE ClientIdentifier__c=:clientId LIMIT 1];

            if (!accRecordList.isEmpty()) {
                deleteProcessor(accRecordList.get(0));
            }
        } catch(Exception ex) {
            Database.rollback(sp);
            throw new StageProcessorException(ex.getmessage(),ex) ;
        }
    }

    /**
     * @description deleteProcessor: deleteProcessor method used for delete Account, Opportunities, Campaign Members and Closed Tasks, Cases and disassociated with Account in SFDC
     * @param accRecord
     */
    private void deleteProcessor(Account accRecord) {
        id systemuserId = getSystemRecordOwnerId();
        UTIL_TaskDAO.closeTasksAndDisassociateWithParent(accRecord.Tasks);
        UTIL_CaseDAO.closeTasksRelatedToCasesForDelete(accRecord.Cases);
        UTIL_CaseDAO.closeCasesAndDisassociateWithParent(accRecord.Cases, systemuserId, 'deleteProcessor - the account was deleted');
        HLPR_OppSalesAttempt.deleteSalesAttempt(accRecord.Opportunities);
        UTIL_OpportunityDAO.deleteOpportunities(accRecord.Opportunities);
        UTIL_LeadConversionDetailDAO.deleteLead(accRecord.Leads__r);
        UTIL_PlanningConversationLogDAO.deletePlanningConversationLog(accRecord.Planning_Conversation_Logs__r);
        UTIL_SimpleConversationDAO.deleteSimpleConversation(accRecord.Simple_Conversations__r);
        UTIL_CampaignMemberDAO.deleteCampaignMembers([SELECT Id FROM CampaignMember WHERE ContactId=: accRecord.PersonContactId]);
        UTIL_LeadConversionDetailDAO.deleteLeadConversionDetails(accRecord.LeadConversionDetails__r);
        List<Relationship__c> deletedClientRelationshiplst = new List<Relationship__c>();
        deletedClientRelationshiplst.addAll(accRecord.Relationships__r);
        deletedClientRelationshiplst.addAll(accRecord.Relationships1__r);
        UTIL_C2CRelationshipDAO.deleteCustomerRelationships(deletedClientRelationshiplst);
        //Deleting AgentContext records for given client
        deletesObjectList(accRecord.AgentContexts__r,CLASS_NAME, METHOD_NAME);
        //Group member delete
        //checkin weather Grouping feature is Enable to transform
        boolean isGroupingFeatureEnabled=toggleContext.isActive(UTIL_Toggles.CUSTOMERGROUPINGS);
        if(isGroupingFeatureEnabled) {
            deleteCustomerHouseholdGroupMember(accRecord.customer_groupings__r);
        }
        //Deleting all assigned staff related to the account before deleting.
        deleteAssignedStaff(accRecord.AssignedStaff__r);
        UTIL_AccountDAO.deleteAccount(accRecord);
        //Update Leadmetric for a particular Account
        UTIL_LeadMetricsProcessor.updateLeadMetrics(accRecord.LeadMetrics__r);
    }
}