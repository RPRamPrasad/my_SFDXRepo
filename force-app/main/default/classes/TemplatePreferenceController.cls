/**
 * Author : Golden Spikes Team
 * Date Created : 08/10/2020
 * @description : This Apex Class is used to get and save template preference data.
 */
public with sharing class TemplatePreferenceController {
    private static final String CLASS_NAME = 'TemplatePreferenceController';
    private static final String GET_TEMPLATE_METHOD_NAME = 'getLoggedInUserTemplates';
    private static final String GET_PREFERENCE_METHOD_NAME = 'getLoggedInUserPreferences';
    private static final String SAVE_PREFERENCE_METHOD_NAME = 'handleSavePreferences';
    private static final String PREFERENCE_NAME = 'Templates';
    private static final String PREFERENCE_LEVEL = 'Agent Office';
    private static final String AGENT_OFFICE_RECORD_TYPE_DEV_NAME = 'Agent_Office';
    private static final Map<String, String> OBJECT_WORKFLOW_MAP = new Map<String, String>{
        'Campaign' => 'Sales Follow-Up',
        'Opportunity' => 'Sales Follow-Up',
        'Case' => 'New Customer Onboarding'
    };
    private static Map<String, Schema.Recordtypeinfo> templateRecordTypeMap = Schema.Sobjecttype.Template__c.getRecordTypeInfosByDeveloperName();

    private with sharing class TemplateQueryResponse {
        private List<Template__c> templateList = new List<Template__c>();
        private String agentProxySfdcId = '';
        private Boolean isTemplateCreateAllowed = false;
        private String errorMessage = '';
    }

    private with sharing class PreferenceQueryResponse {
        private Preference__c userPreference = null;
        private String errorMessage = '';
    }

    private with sharing class PreferenceSaveResponse {
        private String preferenceId = '';
        private String errorMessage = '';
    }
/**
 * @description getLoggedInUserTemplates
 * @param preferenceObject 
 * @return  `String`
 */
    @AuraEnabled
    public static String getLoggedInUserTemplates(String preferenceObject) {
        TemplateQueryResponse templateResponse = new TemplateQueryResponse();
        try {
            templateResponse.isTemplateCreateAllowed = Template__c.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isCreateable();
            templateResponse.agentProxySfdcId = getLoggedInUserAgentProxy();
            String validatedObjectName = new UTIL_ParameterValidator_SObjectName().validateParameter('ObjectName', preferenceObject);
            templateResponse.templateList = [SELECT Id, Name, Type__c, Workflow__c FROM Template__c 
                WHERE OwnerId = :templateResponse.agentProxySfdcId 
                AND RecordTypeId = :templateRecordTypeMap.get(AGENT_OFFICE_RECORD_TYPE_DEV_NAME).RecordTypeId 
                AND Workflow__c = :OBJECT_WORKFLOW_MAP.get(validatedObjectName) WITH SECURITY_ENFORCED ORDER BY LASTMODIFIEDDATE DESC
            ];
        } catch (Exception queryException) {
            templateResponse.errorMessage = System.Label.CL_EXCEPTION_ERROR_MSG;
            LoggingService.logHandledException(queryException, CLASS_NAME, GET_TEMPLATE_METHOD_NAME, System.LoggingLevel.ERROR);
        }
        return JSON.serialize(templateResponse);
    }

    private static String getLoggedInUserAgentProxy() {
        User loggedInUserInfo = [SELECT Servicing_Agent_Associate_Id__c FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED LIMIT 1];
        User loggedInUserProxyInfo = [SELECT Id FROM User WHERE UserExternalID__c = :loggedInUserInfo.Servicing_Agent_Associate_Id__c + 'P' WITH SECURITY_ENFORCED LIMIT 1];
        return loggedInUserProxyInfo.Id;
    }
/**
 * @description getLoggedInUserPreferences
 * @param agentProxySfdcId 
 * @param preferenceObject 
 * @return  `String`
 */
    @AuraEnabled
    public static String getLoggedInUserPreferences(String agentProxySfdcId, String preferenceObject) {
        PreferenceQueryResponse preferenceResponse = new PreferenceQueryResponse();
        try {
            UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', agentProxySfdcId, User.class);
            String validatedObjectName = new UTIL_ParameterValidator_SObjectName().validateParameter('ObjectName', preferenceObject);
            for (Preference__c pref : [SELECT Id, TemplateIds__c FROM Preference__c
                WHERE PreferenceUser__c = :agentProxySfdcId AND OwnerId = :agentProxySfdcId AND PreferenceName__c = :PREFERENCE_NAME 
                AND PreferenceObject__c = :validatedObjectName WITH SECURITY_ENFORCED LIMIT 1
            ]) {
                preferenceResponse.userPreference = pref;
            }
        } catch (Exception queryException) {
            preferenceResponse.errorMessage = System.Label.CL_EXCEPTION_ERROR_MSG;
            LoggingService.logHandledException(queryException, CLASS_NAME, GET_PREFERENCE_METHOD_NAME, System.LoggingLevel.ERROR);
        }
        return JSON.serialize(preferenceResponse);
    }
/**
 * @description handleSavePreferences
 * @param preferenceSaveRequest 
 * @return  `String`
 */
    @AuraEnabled
    public static String handleSavePreferences(String preferenceSaveRequest) {
        PreferenceSaveResponse preferenceResponse = new PreferenceSaveResponse();
        try {
            Map<String, Object> saveRequest = (Map<String, Object>) JSON.deserializeUntyped(preferenceSaveRequest);
            String preferenceId = (String) saveRequest.get('preferenceId');
            if (String.isNotBlank(preferenceId)) {
                preferenceResponse.preferenceId = preferenceId;
                Preference__c updatePreference = new Preference__c(
                    Id = preferenceId,
                    TemplateIds__c = (String) saveRequest.get('selectedTemplate')
                );
                update Security.stripInaccessible(AccessType.UPDATABLE, new List<Preference__c>{ updatePreference }).getRecords();
            } else {
                Preference__c createPreference = new Preference__c(
                    PreferenceName__c = PREFERENCE_NAME,
                    PreferenceValue__c = AGENT_OFFICE_RECORD_TYPE_DEV_NAME,
                    PreferenceObject__c = (String) saveRequest.get('preferenceObject'),
                    TemplateIds__c = (String) saveRequest.get('selectedTemplate'),
                    PreferenceLevel__c = PREFERENCE_LEVEL,
                    PreferenceUser__c = (String) saveRequest.get('agentProxySfdcId'),
                    OwnerId = (String) saveRequest.get('agentProxySfdcId')
                );
                List<Database.SaveResult> preferenceSaveResultList = Database.insert(Security.stripInaccessible(AccessType.CREATABLE, new List<Preference__c>{ createPreference }).getRecords(), true);
                preferenceResponse.preferenceId = preferenceSaveResultList.get(0).Id;
            }
        } catch (Exception saveException) {
            preferenceResponse.errorMessage = System.Label.CL_EXCEPTION_ERROR_MSG;
            LoggingService.logHandledException(saveException, CLASS_NAME, SAVE_PREFERENCE_METHOD_NAME, System.LoggingLevel.ERROR);
        }
        return JSON.serialize(preferenceResponse);
    }
}