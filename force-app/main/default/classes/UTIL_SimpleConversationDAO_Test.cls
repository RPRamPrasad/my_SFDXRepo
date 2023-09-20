/**
* Author : Golden Spikes Team
* Date Created : 08/10/2018
* @description : Test class for the UTIL_SimpleConversationDAO apex class.
*/
@isTest (seeAllData=false)
public class UTIL_SimpleConversationDAO_Test {

    private static String agentProfileId = getProfileId(UTIL_Constants.AGENT_PROFILE_NAME);
    private static String proxyProfileId = getProfileId(UTIL_Constants.PROXY_PROFILE_NAME);
    private static String adminProfileId = getProfileId(UTIL_Constants.SYSTEM_ADMIN_PROFILE_NAME);
    private static String noAccessProfileId = getProfileId(UTIL_Constants.NO_ACCESS_PROFILE_NAME);
    private static String apiProfileId = getProfileId(UTIL_Constants.API_DATA_USER_ADMIN);
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
    private static User buildUser(BuildUserWrapperList userValueWrapper) {
	String param_UserName = userValueWrapper.param_UserName;
	String param_profileId = userValueWrapper.param_profileId;
	String param_associateId = userValueWrapper.param_associateId;
	String param_servicingAgentAssociateId = userValueWrapper.param_servicingAgentAssociateId;
	String param_externalId = userValueWrapper.param_externalId;
        return new User (alias = '12345', email = 'testUser@statefarm.com.bad', emailencodingkey='UTF-8', lastname='TestUserLastName',
            languagelocalekey='en_US',localesidkey='en_US', timezonesidkey='America/Chicago',
            username= param_UserName, profileId = param_profileId,
            Associate_ID__c = param_associateId, Servicing_Agent_Associate_ID__c = param_servicingAgentAssociateId,
            UserExternalID__c = param_externalId
        );
        
    }

    private class BuildUserWrapperList{
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

    //method to build Simple Conversation record with the given parameter value
    private static SimpleConversation__c buildSimpleConversationRecord(SimpleConversationRecordWrapperList conversationParameterRecord) {
	String param_accountId = conversationParameterRecord.param_accountId;
	String param_conductedBy = conversationParameterRecord.param_conductedBy;
	String param_AgentId = conversationParameterRecord.param_AgentId;
	String param_OwnerId = conversationParameterRecord.param_OwnerId;
        return new SimpleConversation__c (Account__c = param_accountId,
                                                                            SimpleConversationType__c = 'Simple Conversation',
                            Status__c = 'New', ConductedBy__c = param_conductedBy, SimpleConversationName__c = 'Test Simple Conv',
                            Agent__c = param_AgentId, ownerId = param_OwnerId);
        
    }

    private class SimpleConversationRecordWrapperList{
		private String param_accountId;
		private String param_conductedBy;
		private String param_AgentId;
		private String param_OwnerId;
	}

    //test method to Update Simple Conversation record as an Admin user.
    @isTest
    private static void testSimpleConversationRecordUpdateAsAdminUser() {
        User agentUser1;
        User agentUser2;
        User proxyUser1;
        User proxyUser2;
        User systemUser;
        User apiUser;
        Account act;
        BuildUserWrapperList recordUpdateAsAdminUserWrap = new BuildUserWrapperList();
			recordUpdateAsAdminUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvUpdateDAO1Admn1' + '@sfa111.test.com';
			recordUpdateAsAdminUserWrap.param_profileId = adminProfileId;
			recordUpdateAsAdminUserWrap.param_associateId = '';
			recordUpdateAsAdminUserWrap.param_servicingAgentAssociateId = '';
			recordUpdateAsAdminUserWrap.param_externalId = '';
		User adminUser = buildUser(recordUpdateAsAdminUserWrap);
        List<SimpleConversation__c> simpleConvRecords = new List<SimpleConversation__c>();

        System.runAs(adminUser) {
            byPassTrigger();
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            BuildUserWrapperList recordAsAgentUser1Wrap = new BuildUserWrapperList();
			recordAsAgentUser1Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'Test1_Simple1ConvUpdateDAO1Agnt11' + '@sfa111.test.com';
			recordAsAgentUser1Wrap.param_profileId = agentProfileId;
			recordAsAgentUser1Wrap.param_associateId = 'kkppww11ttc';
			recordAsAgentUser1Wrap.param_servicingAgentAssociateId = 'kkppww11ttc';
			recordAsAgentUser1Wrap.param_externalId = 'kkppww11ttc';
			agentUser1 = buildUser(recordAsAgentUser1Wrap);
            agentUser1.userRoleId = agentUserRole.id;
            insert agentUser1;

            BuildUserWrapperList recordAsAgentUser2Wrap = new BuildUserWrapperList();
			recordAsAgentUser2Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'Test1_Simple1ConvUpdateDAO1Agnt21' + '@sfa111.test.com';
			recordAsAgentUser2Wrap.param_profileId = agentProfileId;
			recordAsAgentUser2Wrap.param_associateId = 'mmhhww11ttc';
			recordAsAgentUser2Wrap.param_servicingAgentAssociateId = 'mmhhww11ttc';
			recordAsAgentUser2Wrap.param_externalId = 'mmhhww11ttc';
			agentUser2 = buildUser(recordAsAgentUser2Wrap);
            agentUser2.userRoleId = agentUserRole.id;
            insert agentUser2;

            BuildUserWrapperList recordAsProxyUser1Wrap = new BuildUserWrapperList();
			recordAsProxyUser1Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'Test1_Simple1ConvUpdateDAO1Prox1' + '@sfa111.test.com';
			recordAsProxyUser1Wrap.param_profileId = proxyProfileId;
			recordAsProxyUser1Wrap.param_associateId = '';
			recordAsProxyUser1Wrap.param_servicingAgentAssociateId = 'kkppww11ttc';
			recordAsProxyUser1Wrap.param_externalId = 'kkppww11ttcP';
			proxyUser1 = buildUser(recordAsProxyUser1Wrap);
            proxyUser1.userRoleId = proxyUserRole.id;
            insert proxyUser1;

            BuildUserWrapperList recordAsProxyUser2Wrap = new BuildUserWrapperList();
			recordAsProxyUser2Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'Test1_Simple1ConvUpdateDAO1Prox1' + '@sfa111.test.com';
			recordAsProxyUser2Wrap.param_profileId = proxyProfileId;
			recordAsProxyUser2Wrap.param_associateId = '';
			recordAsProxyUser2Wrap.param_servicingAgentAssociateId = 'mmhhww11ttc';
			recordAsProxyUser2Wrap.param_externalId = 'mmhhww11ttcP';
			proxyUser2 = buildUser(recordAsProxyUser2Wrap);
            proxyUser2.userRoleId = proxyUserRole.id;
            insert proxyUser2;

            BuildUserWrapperList recordAsSystemUserWrap = new BuildUserWrapperList();
			recordAsSystemUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'Test1_Simple1ConvUpdateDAO1Syst1' + '@sfa111.test.com';
			recordAsSystemUserWrap.param_profileId = noAccessProfileId;
			recordAsSystemUserWrap.param_associateId = '';
			recordAsSystemUserWrap.param_servicingAgentAssociateId = '';
			recordAsSystemUserWrap.param_externalId = '';
			systemUser = buildUser(recordAsSystemUserWrap);
            insert systemUser;

            BuildUserWrapperList recordAsAPIUserWrap = new BuildUserWrapperList();
			recordAsAPIUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'Test1_Simple1ConvUpdateDAO1ApIUr1' + '@sfa111.test.com';
			recordAsAPIUserWrap.param_profileId = apiProfileId;
			recordAsAPIUserWrap.param_associateId = '';
			recordAsAPIUserWrap.param_servicingAgentAssociateId = '';
			recordAsAPIUserWrap.param_externalId = '';
			apiUser = buildUser(recordAsAPIUserWrap);
            insert apiUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;

            act = buildAccountRecord('8101011');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            agentRole.Agent__c = agentUser1.id;
            insert agentRole;

            AgentRole__c agentRole1 = buildAgentRoleRecord(act.id);
            agentRole1.Agent__c = agentUser2.id;
            insert agentRole1;

            SimpleConversationRecordWrapperList addSimpleConvRecords1Wrap = new SimpleConversationRecordWrapperList();
			addSimpleConvRecords1Wrap.param_accountId = act.id;
			addSimpleConvRecords1Wrap.param_conductedBy = agentUser1.id;
			addSimpleConvRecords1Wrap.param_AgentId = agentUser1.id;
			addSimpleConvRecords1Wrap.param_OwnerId = proxyUser1.id;
			simpleConvRecords.add(buildSimpleConversationRecord(addSimpleConvRecords1Wrap));
            SimpleConversationRecordWrapperList addSimpleConvRecords2Wrap = new SimpleConversationRecordWrapperList();
			addSimpleConvRecords2Wrap.param_accountId = act.id;
			addSimpleConvRecords2Wrap.param_conductedBy = agentUser2.id;
			addSimpleConvRecords2Wrap.param_AgentId = agentUser2.id;
			addSimpleConvRecords2Wrap.param_OwnerId = proxyUser2.id;
			simpleConvRecords.add(buildSimpleConversationRecord(addSimpleConvRecords2Wrap));
            insert simpleConvRecords;
        }

        Test.startTest();
        System.runAs(apiUser) {
            List<SimpleConversation__c> listToUpdate = new List<SimpleConversation__c>();
            for(SimpleConversation__c simpleConv : simpleConvRecords) {
                simpleConv.ownerId = systemUser.Id;
                listToUpdate.add(simpleConv);
            }
            UTIL_SimpleConversationDAO.updateSimpleConversation(listToUpdate);
        }
        List<SimpleConversation__c> simpleConverList = [Select Id, OwnerId from SimpleConversation__c];
        System.assertEquals(2, simpleConverList.size(), 'List of simple conversation size is equal to 2');
        for(SimpleConversation__c simpleConv : simpleConverList) {
           system.assertEquals(systemUser.id, simpleConv.ownerId, 'simple conversation owner id is equal to system user id');
        }
        Test.stopTest();
    }

    //test method to delete Simple Conversation record as an Admin User.
    @isTest
    private static void testSimpleConversationRecordDeleteAsAdminUser() {
        User agentUser1;
        User agentUser2;
        User proxyUser1;
        User proxyUser2;
        Account act;
        BuildUserWrapperList recordDeletAsAdminUserWrap = new BuildUserWrapperList();
			recordDeletAsAdminUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'Test2_Simple2ConvDeleteDAO2Admn2' + '@sfa222.test.com';
			recordDeletAsAdminUserWrap.param_profileId = adminProfileId;
			recordDeletAsAdminUserWrap.param_associateId = '';
			recordDeletAsAdminUserWrap.param_servicingAgentAssociateId = '';
			recordDeletAsAdminUserWrap.param_externalId = '';
		User adminUser = buildUser(recordDeletAsAdminUserWrap);
        List<SimpleConversation__c> simpleConvRecords = new List<SimpleConversation__c>();

        System.runAs(adminUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            byPassTrigger();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            BuildUserWrapperList recordDeletAsAgentUser1Wrap = new BuildUserWrapperList();
			recordDeletAsAgentUser1Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'Test2_Simple2ConvDeleteDAO2Agnt21' + '@sfa222.test.com';
			recordDeletAsAgentUser1Wrap.param_profileId = agentProfileId;
			recordDeletAsAgentUser1Wrap.param_associateId = 'kkppww22ttc';
			recordDeletAsAgentUser1Wrap.param_servicingAgentAssociateId = 'kkppww22ttc';
			recordDeletAsAgentUser1Wrap.param_externalId = 'kkppww22ttc';
			agentUser1 = buildUser(recordDeletAsAgentUser1Wrap);
            agentUser1.userRoleId = agentUserRole.id;
            insert agentUser1;

            BuildUserWrapperList recordDeletAsAgentUser2Wrap = new BuildUserWrapperList();
			recordDeletAsAgentUser2Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'Test2_Simple2ConvDeleteDAO2Agnt22' + '@sfa222.test.com';
			recordDeletAsAgentUser2Wrap.param_profileId = agentProfileId;
			recordDeletAsAgentUser2Wrap.param_associateId = 'mmhhww22ttc';
			recordDeletAsAgentUser2Wrap.param_servicingAgentAssociateId = 'mmhhww22ttc';
			recordDeletAsAgentUser2Wrap.param_externalId = 'mmhhww22ttc';
			agentUser2 = buildUser(recordDeletAsAgentUser2Wrap);
            agentUser2.userRoleId = agentUserRole.id;
            insert agentUser2;

            BuildUserWrapperList recordDeletAsProxyUser1Wrap = new BuildUserWrapperList();
			recordDeletAsProxyUser1Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'Test2_Simple2ConvUpdateDAO2Prox2' + '@sfa222.test.com';
			recordDeletAsProxyUser1Wrap.param_profileId = proxyProfileId;
			recordDeletAsProxyUser1Wrap.param_associateId = '';
			recordDeletAsProxyUser1Wrap.param_servicingAgentAssociateId = 'kkppww22ttc';
			recordDeletAsProxyUser1Wrap.param_externalId = 'kkppww22ttcP';
			proxyUser1 = buildUser(recordDeletAsProxyUser1Wrap);
            proxyUser1.userRoleId = proxyUserRole.id;
            insert proxyUser1;

            BuildUserWrapperList recordDeletAsProxyUser2Wrap = new BuildUserWrapperList();
			recordDeletAsProxyUser2Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'Test2_Simple2ConvUpdateDAO2Prox2' + '@sfa222.test.com';
			recordDeletAsProxyUser2Wrap.param_profileId = proxyProfileId;
			recordDeletAsProxyUser2Wrap.param_associateId = '';
			recordDeletAsProxyUser2Wrap.param_servicingAgentAssociateId = 'mmhhww22ttc';
			recordDeletAsProxyUser2Wrap.param_externalId = 'mmhhww22ttcP';
			proxyUser2 = buildUser(recordDeletAsProxyUser2Wrap);
            proxyUser2.userRoleId = proxyUserRole.id;
            insert proxyUser2;
        }

        System.runAs(adminUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            act = buildAccountRecord('8202022');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            agentRole.Agent__c = agentUser1.id;
            insert agentRole;

            AgentRole__c agentRole1 = buildAgentRoleRecord(act.id);
            agentRole1.Agent__c = agentUser2.id;
            insert agentRole1;

            SimpleConversationRecordWrapperList simpleConvRecords1Wrap = new SimpleConversationRecordWrapperList();
			simpleConvRecords1Wrap.param_accountId = act.id;
			simpleConvRecords1Wrap.param_conductedBy = agentUser1.id;
			simpleConvRecords1Wrap.param_AgentId = agentUser1.id;
			simpleConvRecords1Wrap.param_OwnerId = proxyUser1.id;
			simpleConvRecords.add(buildSimpleConversationRecord(simpleConvRecords1Wrap));
            SimpleConversationRecordWrapperList simpleConvRecords2Wrap = new SimpleConversationRecordWrapperList();
			simpleConvRecords2Wrap.param_accountId = act.id;
			simpleConvRecords2Wrap.param_conductedBy = agentUser2.id;
			simpleConvRecords2Wrap.param_AgentId = agentUser2.id;
			simpleConvRecords2Wrap.param_OwnerId = proxyUser2.id;
			simpleConvRecords.add(buildSimpleConversationRecord(simpleConvRecords2Wrap));
            insert simpleConvRecords;
            Test.startTest();
            List<SimpleConversation__c> simpleConverBefore = [Select Id, OwnerId from SimpleConversation__c];
            System.assertEquals(2, simpleConverBefore.size(), 'List of simple conversation size equal to 2');

            UTIL_SimpleConversationDAO.deleteSimpleConversation(simpleConvRecords);

            List<SimpleConversation__c> simpleConverAfter = [Select Id, OwnerId from SimpleConversation__c];
            System.assertEquals(0, simpleConverAfter.size(), 'List of simple conversation size is equal to 0');
            Test.stopTest();
        }
    }
}