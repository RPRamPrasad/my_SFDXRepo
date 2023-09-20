/**
* Author : Golden Spikes Team
* Date Created : 05/07/2018
* @description : Test class for the UTIL_PlanningConversationLogDAO apex class.
*/
@isTest (seeAllData=false)
public class UTIL_PlanningConversationLogDAO_Test {

    private static String agentProfileId = getProfileId(UTIL_Constants.AGENT_PROFILE_NAME);
    private static String proxyProfileId = getProfileId(UTIL_Constants.PROXY_PROFILE_NAME);
    private static String adminProfileId = getProfileId(UTIL_Constants.SYSTEM_ADMIN_PROFILE_NAME);
    private static String noAccessProfileId = getProfileId(UTIL_Constants.NO_ACCESS_PROFILE_NAME);
    private static final String SECONDS_FORMAT= 'ssSSS';
    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();

    //method to bypass Trigger
    private static void byPassTrigger() {
        CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c();
        objectBasedByPassTrigger.Override_All__c = true;
        insert objectBasedByPassTrigger;
    }

    //method to get the ProfileId for the given Profile Name
    private static String getProfileId(String profileName) {
        return [SELECT Id FROM Profile WHERE name = :profileName LIMIT 1].Id;
        
    }

    //method to build user with the given parameter value
    private static User buildUser(UserWrapperList userParameterWrapper) {
	String param_UserName = userParameterWrapper.param_UserName;
	String param_profileId = userParameterWrapper.param_profileId;
	String param_associateId = userParameterWrapper.param_associateId;
	String param_servicingAgentAssociateId = userParameterWrapper.param_servicingAgentAssociateId;
	String param_externalId = userParameterWrapper.param_externalId;
        return new User (alias = '12345', email = 'testUser@statefarm.com.bad', emailencodingkey='UTF-8', lastname='TestUserLastName',
            languagelocalekey='en_US',localesidkey='en_US', timezonesidkey='America/Chicago',
            username= param_UserName, profileId = param_profileId,
            Associate_ID__c = param_associateId, Servicing_Agent_Associate_ID__c = param_servicingAgentAssociateId,
            UserExternalID__c = param_externalId
        );
        
    }

    private class UserWrapperList{
		private String param_UserName;
		private String param_profileId;
		private String param_associateId;
		private String param_servicingAgentAssociateId;
		private String param_externalId;
	}

    //method to build userrole with parentRole with the given parameter value
    private static UserRole buildRoleWithParentRole(String roleName, String parentrole) {
        return new UserRole(name = roleName, parentRoleId = parentrole);
        
    }

    //method to build userrole with the given parameter value
    private static UserRole buildRole(String roleName) {
        return new UserRole(name = roleName);
        
    }

    //method to build Account Owner custom setting record with the given parameter value
    private static AccountOwnerSystemUserCustomSetting__c buildCustomSettingRecord(String userId) {
        return new AccountOwnerSystemUserCustomSetting__c(Name = UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER, SFDC_USER_ID__c = userId);
        
    }

    //method to build Account record with the given parameter value
    private static Account buildAccountRecord(String param_clientIdentifier) {
        return new Account(FirstName = 'rrrrr', LastName = 'tttttttt',
        RecordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId, ClientIdentifier__c = param_clientIdentifier,Edit_In_VFP__c = true);
        
    }

    //method to build Agent Role record with the given parameter value
    private static AgentRole__c buildAgentRoleRecord(String param_accountId) {
        return new AgentRole__c (RelationshipNature__c = 'Customer',
                       Agent__c = userInfo.getUserId(), Customer__c = param_accountId);
        
    }

    //method to build Planning Conversation Log record with the given parameter value
    private static PlanningConversationLog__c buildPlanningConversationLogRecord(PlanningConversationWrapperList conversationRecordWrapper) {
	String param_accountId = conversationRecordWrapper.param_accountId;
	String param_Comments = conversationRecordWrapper.param_Comments;
	String param_AgentId = conversationRecordWrapper.param_AgentId;
	String param_simpleConv = conversationRecordWrapper.param_simpleConv;
	String param_OwnerId = conversationRecordWrapper.param_OwnerId;
        return new PlanningConversationLog__c (Account__c = param_accountId,
                            Comments__c = param_Comments, Agent__c = param_AgentId, SimpleConversation__c = param_simpleConv, ownerId = param_OwnerId);
        
    }

    private class PlanningConversationWrapperList{
		private String param_accountId;
		private String param_Comments;
		private String param_AgentId;
		private String param_simpleConv;
		private String param_OwnerId;
	}

    //test method to Update Planning Conversation Log record as an Agent.
    @isTest
    private static void testPlanningConversationLogRecordUpdateAsAgent() {
        User agentUser1;
        User agentUser2;
        User proxyUser1;
        User proxyUser2;
        User systemUser;
        Account act;
        UserWrapperList recordUpdateAsAgentUserWrap = new UserWrapperList();
        recordUpdateAsAgentUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest3_Plan3ConvLogUpdateDAO3Admn3' + '@sfa333.test.com';
        recordUpdateAsAgentUserWrap.param_profileId = adminProfileId;
        recordUpdateAsAgentUserWrap.param_associateId = '';
        recordUpdateAsAgentUserWrap.param_servicingAgentAssociateId = '';
        recordUpdateAsAgentUserWrap.param_externalId = '';
		User adminUser = buildUser(recordUpdateAsAgentUserWrap);
        List<PlanningConversationLog__c> planConvLogRecords = new List<PlanningConversationLog__c>();

        System.runAs(adminUser) {
            byPassTrigger();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            UserWrapperList recordUpdateAsAgentUser1Wrap = new UserWrapperList();
			recordUpdateAsAgentUser1Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'Test1_Plan1ConvLogUpdateDAO1Agnt11' + '@sfa111.test.com';
			recordUpdateAsAgentUser1Wrap.param_profileId = agentProfileId;
			recordUpdateAsAgentUser1Wrap.param_associateId = 'zzppww11ttc';
			recordUpdateAsAgentUser1Wrap.param_servicingAgentAssociateId = 'zzppww11ttc';
			recordUpdateAsAgentUser1Wrap.param_externalId = 'zzppww11ttc';
			agentUser1 = buildUser(recordUpdateAsAgentUser1Wrap);
            agentUser1.userRoleId = agentUserRole.id;
            insert agentUser1;

            UserWrapperList recordUpdateAsAgentUser2Wrap = new UserWrapperList();
			recordUpdateAsAgentUser2Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'Test1_Plan1ConvLogUpdateDAO1Agnt21' + '@sfa111.test.com';
			recordUpdateAsAgentUser2Wrap.param_profileId = agentProfileId;
			recordUpdateAsAgentUser2Wrap.param_associateId = 'zzhhww11ttc';
			recordUpdateAsAgentUser2Wrap.param_servicingAgentAssociateId = 'zzhhww11ttc';
			recordUpdateAsAgentUser2Wrap.param_externalId = 'zzhhww11ttc';
			agentUser2 = buildUser(recordUpdateAsAgentUser2Wrap);
            agentUser2.userRoleId = agentUserRole.id;
            insert agentUser2;

            UserWrapperList recordUpdateAsProxyUser1Wrap = new UserWrapperList();
			recordUpdateAsProxyUser1Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'Test1_Plan1ConvLogUpdateDAO1Prox1' + '@sfa111.test.com';
			recordUpdateAsProxyUser1Wrap.param_profileId = proxyProfileId;
			recordUpdateAsProxyUser1Wrap.param_associateId = '';
			recordUpdateAsProxyUser1Wrap.param_servicingAgentAssociateId = 'zzppww11ttc';
			recordUpdateAsProxyUser1Wrap.param_externalId = 'zzppww11ttcP';
			proxyUser1 = buildUser(recordUpdateAsProxyUser1Wrap);
            proxyUser1.userRoleId = proxyUserRole.id;
            insert proxyUser1;

            UserWrapperList recordUpdateAsProxyUser2Wrap = new UserWrapperList();
			recordUpdateAsProxyUser2Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'Test1_Plan1ConvLogUpdateDAO1Prox1' + '@sfa111.test.com';
			recordUpdateAsProxyUser2Wrap.param_profileId = proxyProfileId;
			recordUpdateAsProxyUser2Wrap.param_associateId = '';
			recordUpdateAsProxyUser2Wrap.param_servicingAgentAssociateId = 'zzhhww11ttc';
			recordUpdateAsProxyUser2Wrap.param_externalId = 'zzhhww11ttcP';
			proxyUser2 = buildUser(recordUpdateAsProxyUser2Wrap);
            proxyUser2.userRoleId = proxyUserRole.id;
            insert proxyUser2;

            UserWrapperList recordUpdateAsSystemUserWrap = new UserWrapperList();
			recordUpdateAsSystemUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'Test1_Plan1ConvLogUpdateDAO1Syst1' + '@sfa111.test.com';
			recordUpdateAsSystemUserWrap.param_profileId = noAccessProfileId;
			recordUpdateAsSystemUserWrap.param_associateId = '';
			recordUpdateAsSystemUserWrap.param_servicingAgentAssociateId = '';
			recordUpdateAsSystemUserWrap.param_externalId = '';
			systemUser = buildUser(recordUpdateAsSystemUserWrap);
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        }

        System.runAs(adminUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            act = buildAccountRecord('8101011');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            agentRole.Agent__c = agentUser1.id;
            insert agentRole;

            AgentRole__c agentRole1 = buildAgentRoleRecord(act.id);
            agentRole1.Agent__c = agentUser2.id;
            insert agentRole1;

            SimpleConversation__c simpleConv1 = new SimpleConversation__c (SimpleConversationName__c = 'testSimple1', Account__c = act.id, Agent__c = agentUser1.id, ownerId = proxyUser1.id, SimpleConversationType__c = 'Simple Conversation', Status__c = 'New');
            insert simpleConv1;
            SimpleConversation__c simpleConv2 = new SimpleConversation__c (SimpleConversationName__c = 'testSimple2', Account__c = act.id, Agent__c = agentUser2.id, ownerId = proxyUser2.id, SimpleConversationType__c = 'Simple Conversation', Status__c = 'New');
            insert simpleConv2;

            PlanningConversationWrapperList testPlanConRecords1Wrap = new PlanningConversationWrapperList();
			testPlanConRecords1Wrap.param_accountId = act.id;
			testPlanConRecords1Wrap.param_Comments = 'Testing Planning Conversation Log Comments';
			testPlanConRecords1Wrap.param_AgentId = agentUser1.id;
			testPlanConRecords1Wrap.param_simpleConv = simpleConv1.id;
			testPlanConRecords1Wrap.param_OwnerId = proxyUser1.id;
			planConvLogRecords.add(buildPlanningConversationLogRecord(testPlanConRecords1Wrap));
            PlanningConversationWrapperList testPlanConRecords2Wrap = new PlanningConversationWrapperList();
			testPlanConRecords2Wrap.param_accountId = act.id;
			testPlanConRecords2Wrap.param_Comments = 'Testing Planning Conversation Log Comments';
			testPlanConRecords2Wrap.param_AgentId = agentUser2.id;
			testPlanConRecords2Wrap.param_simpleConv = simpleConv2.id;
			testPlanConRecords2Wrap.param_OwnerId = proxyUser2.id;
			planConvLogRecords.add(buildPlanningConversationLogRecord(testPlanConRecords2Wrap));
            insert planConvLogRecords;

            Test.startTest();
            List<PlanningConversationLog__c> listToUpdate = new List<PlanningConversationLog__c>();
            for(PlanningConversationLog__c planConvLog : planConvLogRecords) {
                planConvLog.ownerId = systemUser.Id;
                listToUpdate.add(planConvLog);
            }
            UTIL_PlanningConversationLogDAO.updatePlanningConversationLog(listToUpdate);

            List<PlanningConversationLog__c> planConverLogs = [Select Id, OwnerId from PlanningConversationLog__c];
            System.assertEquals(2, planConverLogs.size(), 'List Planning conversation log size should be equal to 2');
            for(PlanningConversationLog__c planConvLog: planConverLogs) {
               system.assertEquals(systemUser.id, planConvLog.ownerId, 'Planning conversation log owner id is equal to system user id');
            }
            Test.stopTest();
        }
    }

    //test method to delete Planning Conversation Log record as an 1.03 API User.
    @isTest
    private static void testPlanningConversationLogRecordDeleteAsAPIUser() {
        User agentUser;
        User proxyUser;
        Account act;
        UserWrapperList recordDeleteAsAPIUserWrap = new UserWrapperList();
        recordDeleteAsAPIUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'Test2_Plan2ConvLogDeleteDAO2Admn2' + '@sfa222.test.com';
        recordDeleteAsAPIUserWrap.param_profileId = adminProfileId;
        recordDeleteAsAPIUserWrap.param_associateId = '';
        recordDeleteAsAPIUserWrap.param_servicingAgentAssociateId = '';
        recordDeleteAsAPIUserWrap.param_externalId = '';
		User adminUser = buildUser(recordDeleteAsAPIUserWrap);
        List<PlanningConversationLog__c> planConvLogRecords = new List<PlanningConversationLog__c>();

        System.runAs(adminUser) {
            byPassTrigger();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            UserWrapperList recordDeleteAsAgentUserWrap = new UserWrapperList();
			recordDeleteAsAgentUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'Test2_Plan1ConvLogDeleteDAO2Agnt2' + '@sfa222.test.com';
			recordDeleteAsAgentUserWrap.param_profileId = agentProfileId;
			recordDeleteAsAgentUserWrap.param_associateId = 'zzppww22ttc';
			recordDeleteAsAgentUserWrap.param_servicingAgentAssociateId = 'zzppww22ttc';
			recordDeleteAsAgentUserWrap.param_externalId = 'zzppww22ttc';
			agentUser = buildUser(recordDeleteAsAgentUserWrap);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;

            UserWrapperList recordDeleteAsProxyUserWrap = new UserWrapperList();
			recordDeleteAsProxyUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'Test2_Plan2ConvLogDeleteDAO2Prox2' + '@sfa222.test.com';
			recordDeleteAsProxyUserWrap.param_profileId = proxyProfileId;
			recordDeleteAsProxyUserWrap.param_associateId = '';
			recordDeleteAsProxyUserWrap.param_servicingAgentAssociateId = 'zzppww22ttc';
			recordDeleteAsProxyUserWrap.param_externalId = 'zzppww22ttcP';
			proxyUser = buildUser(recordDeleteAsProxyUserWrap);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;
        }

        System.runAs(adminUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            act = buildAccountRecord('8202022');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            agentRole.Agent__c = agentUser.id;
            insert agentRole;

            SimpleConversation__c simpleConv = new SimpleConversation__c (SimpleConversationName__c = 'testSimple1', Account__c = act.id, Agent__c = agentUser.id, ownerId = proxyUser.id, SimpleConversationType__c = 'Simple Conversation', Status__c = 'New');
            insert simpleConv;
            PlanningConversationWrapperList testPlanConRecordsWrap = new PlanningConversationWrapperList();
			testPlanConRecordsWrap.param_accountId = act.id;
			testPlanConRecordsWrap.param_Comments = 'Testing Planning Conversation Log Comments1';
			testPlanConRecordsWrap.param_AgentId = agentUser.id;
			testPlanConRecordsWrap.param_simpleConv = simpleConv.id;
			testPlanConRecordsWrap.param_OwnerId = proxyUser.id;
			planConvLogRecords.add(buildPlanningConversationLogRecord(testPlanConRecordsWrap));
            PlanningConversationWrapperList planConRecordsWrap = new PlanningConversationWrapperList();
			planConRecordsWrap.param_accountId = act.id;
			planConRecordsWrap.param_Comments = 'Testing Planning Conversation Log Comments2';
			planConRecordsWrap.param_AgentId = agentUser.id;
			planConRecordsWrap.param_simpleConv = simpleConv.id;
			planConRecordsWrap.param_OwnerId = proxyUser.id;
			planConvLogRecords.add(buildPlanningConversationLogRecord(planConRecordsWrap));
            insert planConvLogRecords;
            Test.startTest();
            List<PlanningConversationLog__c> planConverLogsBefore = [Select Id, OwnerId from PlanningConversationLog__c];
            System.assertEquals(2, planConverLogsBefore.size(), 'List of planning conversation log size is equal to 2');

            UTIL_PlanningConversationLogDAO.deletePlanningConversationLog(planConvLogRecords);

            List<PlanningConversationLog__c> planConverLogsAfter = [Select Id, OwnerId from PlanningConversationLog__c];
            System.assertEquals(0, planConverLogsAfter.size(), 'List of planning conversation log size is equal to 0');
            Test.stopTest();
        }
    }
}