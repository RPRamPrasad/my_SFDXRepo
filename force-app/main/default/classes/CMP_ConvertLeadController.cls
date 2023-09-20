/**
* Author : Golden Spikes Team
* Date Created : 05/29/2019
* Description : This Apex Class is used by CMP_ConvertLead lightning component.
* @description CMP_ConvertLeadController
*/
public with sharing class CMP_ConvertLeadController {

    private static final String CLASS_NAME = 'CMP_ConvertLeadController';
    private static final String FETCH_METHOD_NAME = 'fetchConvertInfo';
    private static final String CCC_METHOD_NAME = 'fetchAgentContextForCCCUser';
    private static final String SUB_USER_TYPE_CCC = 'CCC Sales';
    private static final String PROXY_CONCAT = '_';
    public static final String LEAD_ID_PARAMETER = 'leadRecordId';

    //class to store the picklist response.
    /**
     * @description ConvertLeadWrapper
     */
    public with sharing class ConvertLeadWrapper {
        @AuraEnabled
        public Lead leadRecordInfo;
        @AuraEnabled
        public Boolean isSuccessOnFetchValues;
        @AuraEnabled
        public String agentContextInfo;
    }

    //entry point method to fetch the Lead Record Info
    /**
     * @description fetchConvertInfo
     * @param leadRecordId 
     * @return  `ConvertLeadWrapper`
     */
    @AuraEnabled
    public static ConvertLeadWrapper fetchConvertInfo(String leadRecordId) {
        ConvertLeadWrapper wrpResponse = new ConvertLeadWrapper();
        wrpResponse.isSuccessOnFetchValues = false;
        try {
            if(String.isNotBlank(leadRecordId)) {
                UTIL_ParameterValidator_SalesforceId.isValidSalesforceId(LEAD_ID_PARAMETER, leadRecordId, Lead.class);
            }
            Lead leadRecord = [Select Id, AgentAssociateId__c, Name, MultiLOB__c, Product__c, IsConverted From Lead Where Id =: leadRecordId WITH SECURITY_ENFORCED limit 1];
            wrpResponse.leadRecordInfo = leadRecord;
            wrpResponse.agentContextInfo = fetchAgentContextForCCCUser(leadRecord.AgentAssociateId__c);
            wrpResponse.isSuccessOnFetchValues = true;
        } catch(Exception ex) {
            LoggingService.logHandledException(ex, CLASS_NAME, FETCH_METHOD_NAME, System.LoggingLevel.ERROR);
        }
        return wrpResponse;
    }

    //Method to fetch the Agent Context Info for CCC Lead Conversion Flow
    /**
     * @description fetchAgentContextForCCCUser
     * @param agentAssociateID 
     * @return  `agentContextValue`
     */
    @AuraEnabled
    public static String fetchAgentContextForCCCUser(String agentAssociateID) {
        String loggedInUserSubUserInfoType = [Select SubUserType__c from User Where Id=: UserInfo.getUserId() WITH SECURITY_ENFORCED Limit 1]?.SubUserType__c;
        String agentContextValue = '';
        try {
            if(SUB_USER_TYPE_CCC.equals(loggedInUserSubUserInfoType)) {
                User agentContextId = [Select Id from User where UserExternalID__c =: agentAssociateID + PROXY_CONCAT + agentAssociateID WITH SECURITY_ENFORCED];
                agentContextValue = agentContextId.Id;
            }
        } catch (Exception ex) {
            LoggingService.logHandledException(ex, CLASS_NAME, CCC_METHOD_NAME, System.LoggingLevel.ERROR);
        }
        return agentContextValue;
    }
}