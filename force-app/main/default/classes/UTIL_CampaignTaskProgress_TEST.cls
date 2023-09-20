@isTest(seeAllData=false)
public with sharing class UTIL_CampaignTaskProgress_TEST {
    private static User agentUser;
    private static User proxyUser;
    private static User adminUser;

    private static Campaign customerProsectCampaign;
    private static Campaign uploadLeadIndividualCampaign;
    
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
            turnOnCampaignTaskProgress();
            UTIL_UserProvisioning_TEST.setUpAgentUser(1);
    
            agentUser = UTIL_UserProvisioning_TEST.getAgentUser(1);
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            proxyUser = UTIL_UserProvisioning_TEST.getAgentProxyUser(1);

            uploadLeadIndividualCampaign =  TestDataFactory_Campaign.setUpUploadLeadIndividualCampaign(proxyUser);
            customerProsectCampaign = TestDataFactory_Campaign.setUpCustomerProspectCampaign(proxyUser);
        }
    }
    private static void setEnvironment(){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            TestDataFactory_Campaign.byPassTrigger();
    }
    @isTest
    private static void updateCampaignTaskCompletionNoTasks(){
        setEnvironment();
        agentUser = UTIL_UserProvisioning_TEST.getAgentUser(1);
        customerProsectCampaign = TestDataFactory_Campaign.retrieveCustomerProspectCampaign();
        List<Task> tasks = makeTasks('Not Started',5,null);
        System.runAs(agentUser){
            UTIL_CampaignTaskProgress.updateCampaignTaskCompletion(tasks);
        }
        customerProsectCampaign = TestDataFactory_Campaign.retrieveCustomerProspectCampaign();
        System.assertEquals(0, customerProsectCampaign.TaskProgress__c,'Task Progress of customer Prospect Campaign should be empty');
        System.assertEquals('new', customerProsectCampaign.CurrentPathStep__c,'Expected Current Path Step is new, but actual value is'+customerProsectCampaign.CurrentPathStep__c);
    }
     @isTest
    private static void updateCampaignTaskCompletionNoTasksCompleted(){
        setEnvironment();
        agentUser = UTIL_UserProvisioning_TEST.getAgentUser(1);
        customerProsectCampaign = TestDataFactory_Campaign.retrieveCustomerProspectCampaign();
        List<Task> tasks = makeTasks('Not Started',5,customerProsectCampaign.id);
        System.runAs(agentUser){
            UTIL_CampaignTaskProgress.updateCampaignTaskCompletion(tasks);
        }
        customerProsectCampaign = TestDataFactory_Campaign.retrieveCustomerProspectCampaign();
        System.assertEquals(0, customerProsectCampaign.TaskProgress__c,'Task Progress of customer Prospect Campaign should be empty');
        System.assertEquals('new', customerProsectCampaign.CurrentPathStep__c,'Expected Current Path Step is new, but actual value is'+customerProsectCampaign.CurrentPathStep__c);
    }
     @isTest
    private static void updateCampaignTaskCompletionSomeTasksCompleted(){
        setEnvironment();
        agentUser = UTIL_UserProvisioning_TEST.getAgentUser(1);
        customerProsectCampaign = TestDataFactory_Campaign.retrieveCustomerProspectCampaign();
        List<Task> tasks = makeTasks('Not Started',5,customerProsectCampaign.id);
        tasks.addAll(makeTasks('Completed',3,customerProsectCampaign.id));
        tasks.addAll(makeTasks('Cancelled',2,customerProsectCampaign.id));
        System.runAs(agentUser){
            UTIL_CampaignTaskProgress.updateCampaignTaskCompletion(tasks);
        }
        customerProsectCampaign = TestDataFactory_Campaign.retrieveCustomerProspectCampaign();
        System.assertEquals(50, customerProsectCampaign.TaskProgress__c,'Task Progress of customer Prospect Campaign should be 50');
        System.assertEquals('inProgress', customerProsectCampaign.CurrentPathStep__c,'Expected Current Path Step is inProgress, but actual value is'+customerProsectCampaign.CurrentPathStep__c);
    }
  
     @isTest
    private static void updateCampaignTaskCompletionAllTasksCompleted(){
        setEnvironment();
        agentUser = UTIL_UserProvisioning_TEST.getAgentUser(1);
        customerProsectCampaign = TestDataFactory_Campaign.retrieveCustomerProspectCampaign();
        List<Task> tasks = makeTasks('Cancelled',4,customerProsectCampaign.id);
        System.runAs(agentUser){
            UTIL_CampaignTaskProgress.updateCampaignTaskCompletion(tasks);
        }
        customerProsectCampaign = TestDataFactory_Campaign.retrieveCustomerProspectCampaign();
        System.assertEquals(100, customerProsectCampaign.TaskProgress__c,'Task Progress of customer Prospect Campaign should be 100');
        System.assertEquals('tasksCompleted', customerProsectCampaign.CurrentPathStep__c,'Expected Current Path Step is tasksCompleted, but actual value is'+customerProsectCampaign.CurrentPathStep__c);
    }
     @isTest
    private static void updateCampaignTaskCompletionAllTasksCompletedUpdateTrigger(){
        agentUser = UTIL_UserProvisioning_TEST.getAgentUser(1);
        customerProsectCampaign = TestDataFactory_Campaign.retrieveCustomerProspectCampaign();
        List<Task> tasks = makeTasks('Cancelled',4,customerProsectCampaign.id);
        tasks.get(0).Status = 'In Progress';
        System.runAs(agentUser){
            update tasks;
        }
        customerProsectCampaign = TestDataFactory_Campaign.retrieveCustomerProspectCampaign();
        System.assertEquals(75, customerProsectCampaign.TaskProgress__c,'Task Progress of customer Prospect Campaign should be 75');
        System.assertEquals('inProgress', customerProsectCampaign.CurrentPathStep__c,'Expected Current Path Step is inProgress, but actual value is'+customerProsectCampaign.CurrentPathStep__c);
    }
     @isTest
    private static void updateCampaignTaskCompletionAllTasksCompletedInsert(){
        agentUser = UTIL_UserProvisioning_TEST.getAgentUser(1);
        customerProsectCampaign = TestDataFactory_Campaign.retrieveCustomerProspectCampaign();
        makeTasks('Cancelled',4,customerProsectCampaign.id);

        customerProsectCampaign = TestDataFactory_Campaign.retrieveCustomerProspectCampaign();
        System.assertEquals(100, customerProsectCampaign.TaskProgress__c,'Task Progress of customer Prospect Campaign should be 100');
        System.assertEquals('tasksCompleted', customerProsectCampaign.CurrentPathStep__c,'Expected Current Path Step is tasksCompleted, but actual value is'+customerProsectCampaign.CurrentPathStep__c);
    }
    @isTest
    private static void updateCampaignTaskCompletionTasksInProgress(){
        setEnvironment();
        agentUser = UTIL_UserProvisioning_TEST.getAgentUser(1);
        customerProsectCampaign = TestDataFactory_Campaign.retrieveCustomerProspectCampaign();
        List<Task> tasks = makeTasks('In Progress',3,customerProsectCampaign.id);
        System.runAs(agentUser){
            UTIL_CampaignTaskProgress.updateCampaignTaskCompletion(tasks);
        }
        customerProsectCampaign = TestDataFactory_Campaign.retrieveCustomerProspectCampaign();
        System.assertEquals(0, customerProsectCampaign.TaskProgress__c,'Task Progress of customer Prospect Campaign should be empty');
        System.assertEquals('inProgress', customerProsectCampaign.CurrentPathStep__c,'Expected Current Path Step is inProgress, but actual value is'+customerProsectCampaign.CurrentPathStep__c);
    }
    @isTest
    private static void updateCampaignTaskCompletionSomeTasksInProgressUpdateTrigger(){
        agentUser = UTIL_UserProvisioning_TEST.getAgentUser(1);
        customerProsectCampaign = TestDataFactory_Campaign.retrieveCustomerProspectCampaign();
        List<Task> tasks = makeTasks('Not Started',4,customerProsectCampaign.id);
        tasks.get(0).Status = 'In Progress';
        System.runAs(agentUser){
            update tasks;
        }
        customerProsectCampaign = TestDataFactory_Campaign.retrieveCustomerProspectCampaign();
        System.assertEquals(0, customerProsectCampaign.TaskProgress__c,'Task Progress of customer Prospect Campaign should be empty');
        System.assertEquals('inProgress', customerProsectCampaign.CurrentPathStep__c,'Expected Current Path Step is inProgress, but actual value is'+customerProsectCampaign.CurrentPathStep__c);
    }
    private static List<Task> makeTasks(String status, Integer amount,String campaignId){
        List<Task> tasks = new List<Task>();
        proxyUser = UTIL_UserProvisioning_TEST.getAgentProxyUser(1);
        agentUser = UTIL_UserProvisioning_TEST.getAgentUser(1);
        for(Integer i = 0; i < amount; i++){
            tasks.add(new Task(Status = status,OwnerId=proxyUser.id, whatId=campaignId,assignedto__c = agentUser.id, Campaign__c=campaignId));
        }
        insert tasks;
        return tasks;
    }
    /**
     * @description turnOnCampaignTaskProgress
     */
    
    public static void turnOnCampaignTaskProgress() {
        CS_FeatureToggle__c campaignTaskProgress = new CS_FeatureToggle__c();
        campaignTaskProgress.CampaignTaskProgress__c = true;
        insert campaignTaskProgress;
    }
}
