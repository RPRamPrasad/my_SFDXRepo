/**
* Author : Golden Spikes Team
* Date Created : 01/24/2019
* Description : This Apex Class is used for "DoNotSolicitPreference" lightning component.
* @description CMP_DoNotSolicitController
*/

public with sharing class CMP_DoNotSolicitController {

    private static final String CLASS_NAME = 'CMP_DoNotSolicitController';
    private static final String DELETE_METHOD_NAME = 'handleDelete';
    private static final String INSERT_METHOD_NAME = 'createCampaignActionRecord';
    private static final String CAMPAIGN_OBJECT_NAME = 'Campaign';
    private static final String CAMPAIGNMEMBER_OBJECT_NAME = 'CampaignMember';
/**
 * @description isLeadDeleteAllowed
 * @return  `Boolean`
 */
    @AuraEnabled
    public static Boolean isLeadDeleteAllowed() {
        return Lead.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isDeletable();
    }

    //Entry point method for DeleteLead
    /**
     * @description handleDelete
     * @param recordId 
     * @param selectedPreferenceValue 
     * @param objectName 
     * @return  `Boolean`
     */
    @AuraEnabled
    public static Boolean handleDelete(String recordId, String selectedPreferenceValue, String objectName) {
        Boolean isDMLSuccess = false;
        Savepoint deleteLeadSavePoint = Database.setSavepoint();
        try {
            if (objectName.equals('Campaign Member')){
                return handleCampaignMemberDelete(recordId,selectedPreferenceValue);
            }
            update Security.stripInaccessible(AccessType.UPDATABLE, new List<Lead>{new Lead(Id = recordId, SetDoNotSolicit__c = selectedPreferenceValue)}).getRecords();
            UTIL_LeadDAO.deleteLead(new List<Lead>{new Lead(Id = recordId)});
            isDMLSuccess = true;
        } catch(Exception deleteLeadException) {
            Database.rollback(deleteLeadSavePoint);
            LoggingService.logHandledException(deleteLeadException, CLASS_NAME, DELETE_METHOD_NAME, System.LoggingLevel.ERROR);
        }
        return isDMLSuccess;
    }
/**
 * @description handleCampaignMemberDelete
 * @param recordId 
 * @param selectedPreferenceValue 
 * @return  `Boolean`
 */
    @AuraEnabled
    public static Boolean handleCampaignMemberDelete(String recordId, String selectedPreferenceValue) {
        boolean isCampaignMemberDMLSuccess = false;
        boolean isCampaignDMLSuccess = false;
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('campaignMemberId', recordId, CampaignMember.Class);
        List<CampaignMember> campaignMember = [SELECT Id, leadid, CampaignId, Campaign.OwnerId FROM CampaignMember WHERE id = :recordId WITH SECURITY_ENFORCED limit 1];

        isCampaignMemberDMLSuccess = UTIL_CampaignMember.updateCampaignMember(new List<CampaignMember>{new CampaignMember(Id = recordId, SetDoNotSolicit__c = selectedPreferenceValue, Removed__c = true)});
        isCampaignDMLSuccess = incrementRemovedCmpMembCountOnCampaign(campaignMember[0].CampaignId, 1);
        createCampaignActionRecord(campaignMember[0]);
        if (!isCampaignMemberDMLSuccess || !isCampaignDMLSuccess) {
            return null;
        }
        return isCampaignMemberDMLSuccess && isCampaignDMLSuccess;
    }

    private static void createCampaignActionRecord(campaignMember campaignMemberRecord){
        try{
            List<CampaignAction__c> campaignActionList = new List<CampaignAction__c>();
            CampaignAction__c record = new CampaignAction__c(Action__c = 'People Removed', CampaignId__c = campaignMemberRecord.CampaignId, Description__c='Remove Lead',
            LeadIdentifier__c=campaignMemberRecord.leadId, OwnerId=campaignMemberRecord.Campaign.OwnerId);
             
            if (record.getSObjectType().getDescribe().isCreateable()) {
                campaignActionList.add(record);
                Database.insert(campaignActionList,true);
            }
        } catch(Exception e){
            LoggingService.logHandledException(e, CLASS_NAME, INSERT_METHOD_NAME, System.LoggingLevel.ERROR);
        }
    }

    private static Boolean incrementRemovedCmpMembCountOnCampaign(String campaignId, Integer incrementAmount) {
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('campaignId', campaignId, Campaign.Class);
        List<Campaign> campaignList = [SELECT Id, CampaignMembersRemovedManual__c FROM Campaign WHERE id = :campaignId WITH SECURITY_ENFORCED limit 1];
        Campaign campaign = campaignList.get(0);
        if(campaign.CampaignMembersRemovedManual__c == null) {
            campaign.CampaignMembersRemovedManual__c = 1;
        }else {
            campaign.CampaignMembersRemovedManual__c = campaign.CampaignMembersRemovedManual__c +  incrementAmount;
        }
        Database.SaveResult saveResult = Database.update(campaign);
        return saveResult.success;
    }
}