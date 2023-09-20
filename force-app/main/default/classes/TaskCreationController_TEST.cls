@isTest(seeAllData=false)
public with sharing class TaskCreationController_TEST {
    private static User agentUser;
    private static User proxyUser;
    private static User adminUser;
    private static User atmUser;
    private static Campaign customerProsectCampaign;

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
            proxyUser = UTIL_UserProvisioning_TEST.getAgentProxyUser(1);
            insert systemUser;
            AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
            insert sysAdminUserIdSetting;
            customerProsectCampaign = TestDataFactory_Campaign.setUpCustomerProspectCampaign(proxyUser);
        }
    }

    @isTest    
    public static void getCustomTemplatesByTemplateTypeTest() {
        agentUser = UTIL_UserProvisioning_TEST.getAgentUser(1);
        List<Custom_Template__c> customTemplates = createCustomTemplates(5, 'Campaign');
        insert customTemplates;
        List<Custom_Template__c> results;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
            results = TaskCreationController.getCustomTemplatesByTemplateType('Campaign');
        }
        System.assertEquals(5, results.size(),'Size of Results should be 5');
    }
    @isTest 
    public static void getTemplatesForPreference() {
        agentUser = UTIL_UserProvisioning_TEST.getAgentUser(1);
        proxyUser = UTIL_UserProvisioning_TEST.getAgentProxyUser(1);
        Template__c template = createTemplate('Sales Follow-Up','Sales');
        insert template;
        List<Task_Step__c> taskSteps = createTaskStep(5, template.Id);
        insert taskSteps;

        Preference__c preference = createPreference(template.id);
        insert preference;

        List<Task_Step__c> results;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
            results = TaskCreationController.getPreferenceTemplates('Opportunity', proxyUser.id);
        }
        System.assertEquals(5, results.size(),'Size of Results should be 5');
    }
    @isTest
    public static void getLoggedInUserPreferenceTemplates() {
        agentUser = UTIL_UserProvisioning_TEST.getAgentUser(1);
        proxyUser = UTIL_UserProvisioning_TEST.getAgentProxyUser(1);
        Template__c template = createTemplate('Sales Follow-Up','Sales');
        insert template;
        List<Task_Step__c> taskSteps = createTaskStep(5, template.Id);
        insert taskSteps;

        Preference__c preference = createPreference(template.id);
        insert preference;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        List<Task_Step__c> results;
        System.runAs(agentUser){
            results = TaskCreationController.getLoggedInUserPreferenceTemplates('Opportunity');
        }
        System.assertEquals(5, results.size(),'Size of Results should be 5');
    }
    @isTest    
    public static void createTasksTwoUsers() {
        agentUser = UTIL_UserProvisioning_TEST.getAgentUser(1);
        atmUser = UTIL_UserProvisioning_TEST.getAgentTeamMemberUser(1);
        proxyUser = UTIL_UserProvisioning_TEST.getAgentProxyUser(1);
        customerProsectCampaign = TestDataFactory_Campaign.retrieveCustomerProspectCampaign();
        List<String> userIds = new List<String>();
        TaskCreationController.TaskCreationResponse response;
        userIds.add(agentUser.id);
        userIds.add(atmUser.id);

        Template__c template = createTemplate('Sales Follow-Up','Sales');
        insert template;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        TaskCreationController.TaskCreationRequest request = buildTaskCreationRequest('cat', userIds,template.Id);
        System.runAs(agentUser){
            response = TaskCreationController.createTasks(request);
        }

        List<Task> results = queryTasks();

        System.assertEquals(10, results.size(),'Size of Results should be 10');
        System.assertEquals(true, response.success,'Expected Success is true, but actual value is'+response.success);
        for(Integer i = 0; i < 10; i++){
            System.assertEquals('Sales Follow-Up',results.get(i).TaskCategory__c,'Expected Task Category is Sales Follow-Up, but actual value is'+results.get(i).TaskCategory__c);
            System.assertEquals(null,results.get(i).Description,'Expected Description should be null, but actual value is'+results.get(i).Description);
            System.assertEquals('prioritycat'+Math.mod(i, 5),results.get(i).priority,'Expected Priority is'+'prioritycat'+Math.mod(i, 5)+'but actual value is'+results.get(i).priority);
            System.assertEquals('subCategorycat'+Math.mod(i, 5),results.get(i).TaskSubCategory__c,'Expected Task Sub Category is'+'subCategorycat'+Math.mod(i, 5)+'but actual value is'+results.get(i).TaskSubCategory__c);
            System.assertEquals('Phone : logTitle',results.get(i).Subject,'Expected Subject is Phone : logTitle, but actual value is'+results.get(i).Subject);
            System.assertEquals('Sales',results.get(i).Task_Type__c,'Expected Task Type is Sales, but actual value is'+results.get(i).Task_Type__c);
            // System.assertEquals(template.id,results.get(i).Custom_Template_Id__c);
            System.assertEquals(true,results.get(i).CreatedFromTemplate__c,'Expected Template is true, but actual value is'+results.get(i).CreatedFromTemplate__c);
            System.assertEquals(customerProsectCampaign.Id, results.get(i).WhatId,'Expected What Id is'+customerProsectCampaign.Id+'but actual value is'+results.get(i).WhatId);
            System.assertEquals('Phone', results.get(i).Contact_Type__c,'Expected Contact Type should be Phone, but actual value is'+results.get(i).Contact_Type__c);
            System.assertEquals('Completed', results.get(i).Status,'Expected Status is Completed, but actual value is'+results.get(i).Status);
            System.assertEquals('Agent Office', results.get(i).Source__c,'Expected Source is Agent Office, but actual value is'+results.get(i).Source__c);
            System.assertEquals(true, results.get(i).Pivoted__c,'Expected Pivoted is true, but actual value is'+results.get(i).Pivoted__c);
            System.assertEquals('Log Call',results.get(i).recordType.name,'Expected Name is Log Call, but actual value is'+results.get(i).recordType.name);
        }
        System.assertEquals(results.get(0).AssignedTo__c,agentUser.id,'Expected Agent User Id is'+results.get(0).AssignedTo__c+'but actual value is'+agentUser.id);
        System.assertEquals(results.get(0).ownerId,proxyUser.id,'Expected Proxy User Id is'+results.get(0).ownerId+'but actual value is'+proxyUser.id);
    }
    private static Preference__c createPreference(String templateId) {
        Preference__c preference = new Preference__c();
        preference.TemplateIds__c = templateId;
        preference.PreferenceUser__c = proxyUser.id;
        preference.OwnerId = proxyUser.id;
        preference.PreferenceName__c = 'Templates';
        preference.PreferenceObject__c = 'Opportunity';
        preference.PreferenceValue__c = 'Agent_Office';
        return preference;
    }
    private static List<Task> queryTasks(){
        return [SELECT id,Status, TaskCategory__c, Description, ActivityDate, priority,source__c
        , TaskSubCategory__c, Subject,WhatId, Task_Type__c, AssignedTo__c
        , ownerId,Custom_Template_Id__c,CreatedFromTemplate__c,recordtype.name, Contact_Type__c, Pivoted__c FROM Task ORDER BY createdDate limit 100];
    }
    private static List<Custom_Template__c> createCustomTemplates(Integer amount, String templateType){
        List<Custom_Template__c> customTemplates = new List<Custom_Template__c>();
        for(Integer i = 0; i < amount; i++){
            customTemplates.add(createCustomTemplate('description' + i, templateType));
        }
        return customTemplates;
    }
    private static Custom_Template__c createCustomTemplate(String description, String templateType){
        Custom_Template__c customTemplate = new Custom_Template__c();
        Id recordTypeId = [SELECT id from RecordType where developername = 'CampaignTaskTemplate' limit 1].id;
        customTemplate.Task_Description__c = description;
        customTemplate.Template_Type__c = templateType;
        customTemplate.recordTypeId = recordTypeId;
        return customTemplate;
    }
    private static Template__c createTemplate(String workflow, String tempType) {
        Id recordTypeId = [SELECT Id FROM RecordType where DeveloperName = 'Agent_Office' LIMIT 1].id;
        Template__c template = new Template__c();
        template.Workflow__c = workflow;
        template.Type__c = tempType;
        template.RecordTypeId =  recordTypeId;
        template.OwnerId = agentUser.Id;
        return template;
    }
    private static List<Task_Step__c> createTaskStep(Integer amount, String templateId) {
        List<Task_Step__c> taskSteps = new List<Task_Step__c>();
        for(Integer i = 0; i < amount; i++){
            taskSteps.add(createTaskStep('description' + i, templateId, i));
        }
        return taskSteps;
    }

    private static Task_Step__c createTaskStep(String description, String templateId, Integer dueDay) {
        Task_Step__c taskStep = new Task_Step__c();
        taskStep.Task_Description__c = description;
        taskStep.Template__c = templateId;
        taskStep.Due_Date_Number_of_Days_from_Start__c = dueDay;
        taskStep.Task_Category__c = 'Sales Follow-Up';
        return taskStep;
    }
    private static TaskCreationController.TaskCreationRequest buildTaskCreationRequest(String identifier, List<String> userIds, String templateId){
        TaskCreationController.TaskCreationRequest request = new TaskCreationController.TaskCreationRequest();
        customerProsectCampaign = TestDataFactory_Campaign.retrieveCustomerProspectCampaign();
        request.taskBasicDetails = createTaskBasicDetails('cat',5, templateId);
        request.relationId = customerProsectCampaign.id;
        request.userIdsToAssign = userIds;
        request.relationFieldName = 'Campaign__c';

        return request;
    }
    private static List<Map<String,String>> createTaskBasicDetails(String identifier, Integer count, String templateId){
        List<Map<String,String>> details = new List<Map<String,String>>();

        for(Integer i = 0; i < count; i++){
            details.add(createTaskBasicDetail(identifier + i,templateId));
        }
        return details;
    }
    private static Map<String,String> createTaskBasicDetail(String identifier, String templateId){
        Map<String,String>  taskBasicDetails = new Map<String,String>();
        
        taskBasicDetails.put('category', 'Sales Follow-Up');
        taskBasicDetails.put('numberOfDaysUntilDue','5');
        taskBasicDetails.put('priority','priority'+identifier);
        taskBasicDetails.put('subCategory', 'subCategory'+identifier);
        taskBasicDetails.put('subject', 'subject'+ identifier);
        taskBasicDetails.put('type', 'Sales');
        taskBasicDetails.put('templateId', templateId);
        taskBasicDetails.put('contactType','Phone');
        taskBasicDetails.put('pivoted', 'true');
        taskBasicDetails.put('status', 'Completed');
        taskBasicDetails.put('source' , 'Agent Office');
        taskBasicDetails.put('isLog' , 'true');
        taskBasicDetails.put('logTitle' , 'logTitle');
        return taskBasicDetails;
    }
}