@isTest(seeAllData=false)
public with sharing class TaskCreationDAO_TEST {
    private static User agentUser;
    private static User proxyUser;
    private static User adminUser;
    private static User atmUser;

    @TestSetup
    static void makeData() {
        TestDataFactory_Campaign.TestDataFactory_CampaignWrapper wrap = new TestDataFactory_Campaign.TestDataFactory_CampaignWrapper();
        wrap.param_UserName = UTIL_TestUsername_TEST.getTestUsername();
        wrap.param_profileId = TestDataFactory_Campaign.adminProfileId;
        wrap.param_associateId = '';
        wrap.param_servicingAgentAssociateId = '';
        wrap.param_externalId = '';
        adminUser = TestDataFactory_Campaign.buildUser(wrap);
        System.runAs(adminUser) {
            UTIL_UserProvisioning_TEST.setUpAgentUser(1);
            User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
            insert systemUser;
            AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
            insert sysAdminUserIdSetting;
        }
    }
    @isTest    
    public static void getCustomTemplatesByTemplateTypeTest() {
        agentUser = UTIL_UserProvisioning_TEST.getAgentUser(1);
        List<Custom_Template__c> customTemplates = createCustomTemplates(5, 'Onboarding');
        insert customTemplates;
        List<Custom_Template__c> results;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
            results = TaskCreationDAO.getCustomTemplatesByTemplateType('Onboarding');
        }
        System.assertEquals(5, results.size(), 'results is not 5');
        System.assertEquals(0, results.get(0).Due_Date_Number_of_Days_from_Today__c, 'Due_Date_Number_of_Days_from_Today__c is not 0');
        System.assertEquals(4, results.get(4).Due_Date_Number_of_Days_from_Today__c, 'Due_Date_Number_of_Days_from_Today__c is not 4');
    }
    private static List<Custom_Template__c> createCustomTemplates(Integer amount, String templateType){
        List<Custom_Template__c> customTemplates = new List<Custom_Template__c>();
        for(Integer i = 0; i < amount; i++){
            customTemplates.add(createCustomTemplate('description' + i, templateType, i));
        }
        return customTemplates;
    }
    private static Custom_Template__c createCustomTemplate(String description, String templateType, Integer dueDay){
        Custom_Template__c customTemplate = new Custom_Template__c();
        customTemplate.Task_Description__c = description;
        customTemplate.Template_Type__c = templateType;
        customTemplate.Due_Date_Number_of_Days_from_Today__c = dueDay;
        return customTemplate;
    }
}