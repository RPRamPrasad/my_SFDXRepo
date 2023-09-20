/**
* Author : Golden Spikes Team
* Date Created : 08/10/2020
* @description : Test Class for TemplatePreferenceController Class.
*/
@isTest(seeAllData =  false)
public class TemplatePreferenceController_TEST {

    private static final String PREFERENCE_NAME = 'Templates';
    private static final String PREFERENCE_LEVEL = 'Agent Office';
    private static final String AGENT_OFFICE_RECORD_TYPE_DEV_NAME = 'Agent_Office';
    private static Map<String, Schema.Recordtypeinfo> templateRecordTypeMap = Schema.Sobjecttype.Template__c.getRecordTypeInfosByDeveloperName();

    @TestSetup
    private static void setUpUserData() {
        insert new CS001_ByPassTriggerAll__c(Override_All__c= false);

        User sysAdminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'sysAdm'+UTIL_TestUsername_TEST.getTestUsername());
        insert sysAdminUser;

        System.runAs(sysAdminUser) {
            UserRole agentUserRole = new UserRole(name = 'AgentRole');                    
            insert agentUserRole;

            UserRole  proxyUserRole = new UserRole(name='ProxyRole', parentRoleId = agentUserRole.id);
            insert proxyUserRole;
            User testProxyUser1 = new User(Alias='Prox',LastName='prefAgnt',Username='PrxPrf'+UTIL_TestUsername_TEST.getTestUsername(),UserExternalID__c='10ccww22zzcP',Servicing_Agent_Associate_ID__c='10ccww22zzc');
            User proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;
            User testAgentUser1 = new User(Alias='Alia',LastName='prefPrxy',Username='AgtPrf'+UTIL_TestUsername_TEST.getTestUsername(),Associate_ID__c='10ccww22zzc',UserExternalID__c='10ccww22zzc_10ccww22zzc',Servicing_Agent_Associate_ID__c='10ccww22zzc');
            User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
            agentUser.userRoleId= agentUserRole.id;
            insert agentUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser, proxyUser});
            
            Template__c template = new Template__c(Name='TstTemplate', Type__c ='Sales', Workflow__c = 'Sales Follow-Up', 
            RecordTypeId = templateRecordTypeMap.get(AGENT_OFFICE_RECORD_TYPE_DEV_NAME).RecordTypeId, OwnerId = proxyUser.Id);
            insert template;
            
            Preference__c preference = new Preference__c(PreferenceName__c = 'Templates', PreferenceObject__c = 'Campaign', ownerId = proxyUser.Id,
            PreferenceUser__c = proxyUser.Id, TemplateIds__c = template.Id, PreferenceValue__c = 'Agent_Office');
            insert preference;
        }
    }

    @isTest private static void testGetLoggedInUserTemplates() {
        System.runAs(getAgentUser()) {
            Test.startTest();
            String loggedInUserTemplates = TemplatePreferenceController.getLoggedInUserTemplates('Campaign');
            Test.stopTest();

            Map<String, Object> templateObject = (Map<String, Object>) JSON.deserializeUntyped(loggedInUserTemplates);
            System.assertEquals(getAgentProxyUser().Id, templateObject.get('agentProxySfdcId'), 'Invalid Agent Proxy Id');
            System.assertEquals(true, templateObject.get('isTemplateCreateAllowed'), 'Invalid Object Permission');
            System.assert(String.isBlank((String) templateObject.get('errorMessage')), 'Invalid Error Message');
            List<Object> objectList = (List<Object>) templateObject.get('templateList');
            for(Object template: objectList) {
                Map<String, Object> templateData = (Map<String, Object>)template;
                System.assertEquals('Sales', templateData.get('Type__c'), 'Invalid Template Type');
                System.assertEquals('Sales Follow-Up', templateData.get('Workflow__c'), 'Invalid Template Workflow');
                System.assertEquals('TstTemplate', templateData.get('Name'), 'Invalid Template Name');
            }
        }
    }

    @isTest private static void testGetLoggedInUserPreferences() {
        System.runAs(getAgentUser()) {
            User agntProxyUser = getAgentProxyUser();

            Test.startTest();
            String loggedInUserPreferences = TemplatePreferenceController.getLoggedInUserPreferences(agntProxyUser.Id, 'Campaign');
            Test.stopTest();

            Map<String, Object> preferenceObject = (Map<String, Object>) JSON.deserializeUntyped(loggedInUserPreferences);
            Object preferenceObj = (Object) preferenceObject.get('userPreference');
            Map<String, Object> preferenceData = (Map<String, Object>)preferenceObj;
            String preferenceId = (String) preferenceData.get('Id');
            String templateIds = (String) preferenceData.get('TemplateIds__c');
            System.assert(String.isNotBlank(preferenceId), 'Invalid Preference ID');
            System.assert(String.isNotBlank(templateIds), 'Invalid Template IDS');
        }
    }

    @isTest private static void testGetLoggedInUserPreferencesForException() {
        System.runAs(getAgentProxyUser()) {
            Test.startTest();
            String loggedInUserPreferences = TemplatePreferenceController.getLoggedInUserPreferences('01pW0000000t0Wl', 'Campaign');
            Test.stopTest();

            Map<String, Object> preferenceObject = (Map<String, Object>) JSON.deserializeUntyped(loggedInUserPreferences);
            System.assertEquals(System.Label.CL_EXCEPTION_ERROR_MSG, preferenceObject.get('errorMessage'), 'Invalid Exception Error Msg');
        }
    }

    @isTest private static void testhandleSavePreferenceForInsert() {
        System.runAs(getAgentUser()) {
            User agntProxyUser = getAgentProxyUser();
            String templateIds = 'id1;id2';
            String preferenceSaveRequest = '{"preferenceId":"","agentProxySfdcId":"'+agntProxyUser.Id+'","preferenceObject":"Opportunity","selectedTemplate":"'+templateIds+'"}';
            List<Preference__c> preferenceBeforeSave = [Select Id, PreferenceName__c, PreferenceValue__c, PreferenceObject__c, TemplateIds__c, PreferenceLevel__c, PreferenceUser__c, OwnerId 
            from Preference__c Where OwnerId =: agntProxyUser.Id and PreferenceObject__c = 'Opportunity' Limit 1];
            System.assert(preferenceBeforeSave.isEmpty(), 'Invalid Preference Id');

            Test.startTest();
            String savedPreferences = TemplatePreferenceController.handleSavePreferences(preferenceSaveRequest);
            Test.stopTest();

            Map<String, Object> savedPreferenceObject = (Map<String, Object>) JSON.deserializeUntyped(savedPreferences);
            Preference__c preferenceAfterSave = [Select Id, PreferenceName__c, PreferenceValue__c, PreferenceObject__c, TemplateIds__c, PreferenceLevel__c, PreferenceUser__c, OwnerId 
            from Preference__c Where OwnerId =: agntProxyUser.Id and PreferenceObject__c = 'Opportunity' Limit 1];
            System.assertEquals(PREFERENCE_NAME, preferenceAfterSave.PreferenceName__c, 'Invalid Preference Name');
            System.assertEquals(AGENT_OFFICE_RECORD_TYPE_DEV_NAME, preferenceAfterSave.PreferenceValue__c, 'Invalid Preference Value');
            System.assertEquals('Opportunity', preferenceAfterSave.PreferenceObject__c, 'Invalid Preference Object');
            System.assertEquals('id1;id2', preferenceAfterSave.TemplateIds__c, 'Invalid Template IDS');
            System.assertEquals(PREFERENCE_LEVEL, preferenceAfterSave.PreferenceLevel__c, 'Invalid Preference Level');
            System.assertEquals(agntProxyUser.Id, preferenceAfterSave.PreferenceUser__c, 'Invalid Preference User');
            System.assertEquals(agntProxyUser.Id, preferenceAfterSave.OwnerId, 'Invalid Preference OwnerId');
            System.assertEquals(preferenceAfterSave.Id, savedPreferenceObject.get('preferenceId'), 'Invalid Preference Id');
            System.assert(String.isBlank((String) savedPreferenceObject.get('errorMessage')), 'Invalid Error Message');
        }
    }

    @isTest private static void testhandleSavePreferenceForUpdate() {
        System.runAs(getAgentUser()) {
            User agntProxyUser = getAgentProxyUser();
            Preference__c preference = [Select id from Preference__c Where OwnerId =: agntProxyUser.Id Limit 1];
            String templateIds = 'id1;id2';
            String preferenceSaveRequest = '{"preferenceId":"'+preference.Id+'","agentProxySfdcId":"'+agntProxyUser.Id+'","preferenceObject":"Campaign","selectedTemplate":"'+templateIds+'"}';

            Test.startTest();
            String savedPreferences = TemplatePreferenceController.handleSavePreferences(preferenceSaveRequest);
            Test.stopTest();

            Map<String, Object> savedPreferenceObject = (Map<String, Object>) JSON.deserializeUntyped(savedPreferences);
            Preference__c preferenceAfterSave = [Select Id, TemplateIds__c from Preference__c Where OwnerId =: agntProxyUser.Id and PreferenceObject__c = 'Campaign' Limit 1];
            System.assertEquals('id1;id2', preferenceAfterSave.TemplateIds__c, 'Invalid Template IDS');
            System.assert(String.isBlank((String) savedPreferenceObject.get('errorMessage')), 'Invalid Error Message');
        }
    }

    @isTest private static void testhandleSavePreferenceForException() {
        System.runAs(getAgentUser()) {
            User agntProxyUser = getAgentProxyUser();
            String templateIds = 'id1;id2';
            String preferenceSaveRequest = '{"preferenceId":'+',"agentProxySfdcId":"'+agntProxyUser.Id+'","preferenceObject":"Campaign","selectedTemplate":"'+templateIds+'"}';

            Test.startTest();
            String savedPreferences = TemplatePreferenceController.handleSavePreferences(preferenceSaveRequest);
            Test.stopTest();

            Map<String, Object> savedPreferenceObject = (Map<String, Object>) JSON.deserializeUntyped(savedPreferences);
            System.assertEquals(System.Label.CL_EXCEPTION_ERROR_MSG, savedPreferenceObject.get('errorMessage'), 'Invalid Exception Error Msg');
        }
    }

    private static User getAgentUser() {
        return [Select Id from User where UserExternalId__c = '10ccww22zzc_10ccww22zzc' LIMIT 1];
    }

    private static User getAgentProxyUser() {
        return [Select Id from User where UserExternalId__c = '10ccww22zzcP' LIMIT 1];
    }

}