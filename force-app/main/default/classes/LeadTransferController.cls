/**
 * Author : Golden Spikes Team
 * Date Created : 09/30/2020
 * @description : This Apex Class is used to transfer the lead from CCC to Agency users.
 */
public with sharing class LeadTransferController {
    private static final String CLASS_NAME = 'LeadTransferController';
    private static final String UPDATE_LEAD_OWNER_METHOD_NAME = 'updateLeadOwner';
    private static final String ALREADY_TRANSFERED_MSG =  'This Lead is already transfered to the agent office. No action required from your end.';
/**
 * @description LeadTransferResponse
 */
    public with sharing class LeadTransferResponse {
        @AuraEnabled public Boolean isUpdateSuccess = false;
        @AuraEnabled public String pgErrorMsg = '';
    }
/**
 * @description updateLeadOwner
 * @param leadId 
 * @return  `LeadTransferResponse`
 */
    @AuraEnabled
    public static LeadTransferResponse updateLeadOwner(String leadId) {
        LeadTransferResponse ldTransferResponse = new LeadTransferResponse();
        Boolean isUpdateSuccess = false;
        try {
            UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('leadId', leadId, Lead.Class);
            Lead updateLd = [SELECT Id, AgentAssociateId__c, Description, OwnerId, LeadSource FROM Lead WHERE id = :leadId WITH SECURITY_ENFORCED LIMIT 1];
            if((AccountOwnerSystemUserCustomSetting__c.getInstance()).SFDC_User_ID__c.equals(updateLd.ownerId)) {
                String agentAssociateID = updateLd.AgentAssociateId__c;
                if (String.isNotBlank(agentAssociateID)) {
                    User proxyUser = [SELECT Id FROM User WHERE UserExternalID__c = :agentAssociateID + 'P' WITH SECURITY_ENFORCED LIMIT 1];                
                    updateLd.ownerId = proxyUser.Id;
                    updateLd.AssignedTo__c = null;
                    List<Lead> updateLeadList = new List<Lead> {updateLd};
                    update Security.stripInaccessible(AccessType.UPDATABLE, updateLeadList).getRecords();
                    handleLeadNotification(updateLeadList[0]);
                    handleUpdateLeadMetrics(updateLeadList[0]);
                }
                ldTransferResponse.isUpdateSuccess = true;
            } else {
                ldTransferResponse.pgErrorMsg = ALREADY_TRANSFERED_MSG;
            }
        } catch (Exception updateLeadException) {
            ldTransferResponse.pgErrorMsg = System.Label.CL_EXCEPTION_ERROR_MSG;
            LoggingService.logHandledException(updateLeadException, CLASS_NAME, UPDATE_LEAD_OWNER_METHOD_NAME, System.LoggingLevel.ERROR);
            throw new AuraHandledException(System.Label.CL_EXCEPTION_ERROR_MSG);
        }
        return ldTransferResponse;
    }

    private static void handleLeadNotification(Lead updateLd) {
        Task newtsk = HLPR_CreateLeadService.buildTask(updateLd);
        UTIL_TaskDAO.insertTasks(new List<Task>{ newtsk });
    }

    private static void handleUpdateLeadMetrics(Lead updateLd) {
        List<LeadMetrics__c> updateLeadMetricsList = new List<LeadMetrics__c>();
        for(LeadMetrics__c ldMetrics : [SELECT Id, LeadTransferredBy__c  FROM LeadMetrics__c WHERE LeadSfdcId__c = :updateLd.Id WITH SECURITY_ENFORCED LIMIT 1]) {
            updateLeadMetricsList.add(new LeadMetrics__c(Id = ldMetrics.Id, LeadTransferredBy__c = UserInfo.getUserId(), OwnerId = updateLd.OwnerId));
        }
        if(!updateLeadMetricsList.isEmpty()) {
            update Security.stripInaccessible(AccessType.UPDATABLE, updateLeadMetricsList).getRecords();
        }
    }
}