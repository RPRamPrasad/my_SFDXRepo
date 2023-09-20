/**
* Author : Octonauts
* Date Created : 12/24/2020
* @description : Test class for the HLPR_SimpleConversationTrigger_TEST class.
Copyright © StateFarm
*/

@isTest(seeAllData = false)
public class HLPR_SimpleConversationTrigger_TEST {

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
    private static User buildUser(SimpleConversationUserDataWrapperList userParameterValueWrapper) {
        String param_UserName = userParameterValueWrapper.param_UserName;
        String param_profileId = userParameterValueWrapper.param_profileId;
        String param_associateId = userParameterValueWrapper.param_associateId;
        String param_servicingAgentAssociateId = userParameterValueWrapper.param_servicingAgentAssociateId;
        String param_externalId = userParameterValueWrapper.param_externalId;
        return new User (alias = '12345', email = 'testUser@statefarm.com.bad', emailencodingkey='UTF-8', lastname='TestUserLastName',
            languagelocalekey='en_US',localesidkey='en_US', timezonesidkey='America/Chicago',
            username= param_UserName, profileId = param_profileId,
            Associate_ID__c = param_associateId, Servicing_Agent_Associate_ID__c = param_servicingAgentAssociateId,
            UserExternalID__c = param_externalId
        );
        
    }

    private class SimpleConversationUserDataWrapperList{
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
    UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        return new Account(Edit_In_VFP__c=true,FirstName = 'rrrrr', LastName = 'tttttttt',
        RecordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId, ClientIdentifier__c = param_clientIdentifier);
        
    }

    //method to build Agent Role record with the given parameter value
    private static AgentRole__c buildAgentRoleRecord(String param_accountId) {
        return new AgentRole__c (RelationshipNature__c = 'Customer',
                       Agent__c = userInfo.getUserId(), Customer__c = param_accountId);
        
    }

    //method to build Simple Conversation record with the given parameter value
    private static SimpleConversation__c buildSimpleConversationRecord(String param_accountId, String param_conductedBy) {
        return new SimpleConversation__c (Account__c = param_accountId,
                                                                            SimpleConversationType__c = 'Simple Conversation',
                            Status__c = 'New', ConductedBy__c = param_conductedBy, SimpleConversationName__c = 'Test Simple Conv', IsSendToOutlook__c = true, AppointmentStartDateTime__c = System.now().addHours(4),AppointmentEndDateTime__c  = System.now().addHours(4));
        
    }

    //test method to insert simple Conversation record as an Agent.
    @isTest
    private static void testSimpleConversationRecordInsertAsAgent() {
        User agentUser;
        User proxyUser;
        SimpleConversationUserDataWrapperList testRecordInsertAsAdminWrap = new SimpleConversationUserDataWrapperList();
			testRecordInsertAsAdminWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvInsert1Admn1' + '@sfa111.test.com';
			testRecordInsertAsAdminWrap.param_profileId = adminProfileId;
			testRecordInsertAsAdminWrap.param_associateId = '';
			testRecordInsertAsAdminWrap.param_servicingAgentAssociateId = '';
			testRecordInsertAsAdminWrap.param_externalId = '';
		User adminUser = buildUser(testRecordInsertAsAdminWrap);

        System.runAs(adminUser) {
           byPassTrigger();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            SimpleConversationUserDataWrapperList testRecordInsertAsAgentWrap = new SimpleConversationUserDataWrapperList();
			testRecordInsertAsAgentWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvInsert1Agnt1' + '@sfa111.test.com';
			testRecordInsertAsAgentWrap.param_profileId = agentProfileId;
			testRecordInsertAsAgentWrap.param_associateId = 'ppccpp11ttc';
			testRecordInsertAsAgentWrap.param_servicingAgentAssociateId = 'ppccpp11ttc';
			testRecordInsertAsAgentWrap.param_externalId = 'ppccpp11ttc_ppccpp11ttc';
            agentUser = buildUser(testRecordInsertAsAgentWrap);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            insert new PermissionSetAssignment(AssigneeId = agentUser.id,
                PermissionSetId = [SELECT id FROM PermissionSet WHERE Name = 'SF_CRM_VirtualMeetingAPTC_PermSetPID' LIMIT 1].id);

            SimpleConversationUserDataWrapperList testRecordInsertAsProxyWrap = new SimpleConversationUserDataWrapperList();
			testRecordInsertAsProxyWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvInsert1Prox1' + '@sfa111.test.com';
			testRecordInsertAsProxyWrap.param_profileId = proxyProfileId;
			testRecordInsertAsProxyWrap.param_associateId = '';
			testRecordInsertAsProxyWrap.param_servicingAgentAssociateId = 'ppccpp11ttc';
			testRecordInsertAsProxyWrap.param_externalId = 'ppccpp11ttcP';
			proxyUser = buildUser(testRecordInsertAsProxyWrap);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            SimpleConversationUserDataWrapperList testRecordInsertAsSystemWrap = new SimpleConversationUserDataWrapperList();
			testRecordInsertAsSystemWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvInsert1Syst1' + '@sfa111.test.com';
			testRecordInsertAsSystemWrap.param_profileId = noAccessProfileId;
			testRecordInsertAsSystemWrap.param_associateId = '';
			testRecordInsertAsSystemWrap.param_servicingAgentAssociateId = '';
			testRecordInsertAsSystemWrap.param_externalId = '';
			User systemUser = buildUser(testRecordInsertAsSystemWrap);
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        }

        System.runAs(agentUser) {
            Account act = buildAccountRecord('7601011');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;
            Test.startTest();
            SimpleConversation__c simpleConversationRecord = buildSimpleConversationRecord(act.id, agentUser.id);
            insert simpleConversationRecord;
            Test.stopTest();
            List<SimpleConversation__c> simpleConverLog = [Select Id, Agent__c, ConductedBy__c, OwnerId from SimpleConversation__c limit 1];
            System.assert(!simpleConverLog.isEmpty(), 'simpleconversationlog should not be null');
        }
    }

    //test method to insert simple Conversation record as an Agent with Appointment Location Virtual Meeting.
    @isTest
    private static void testSimpleConversationRecordWithVirtualMeetingAppointLoc() {
        User agentUser;
        User proxyUser;
        SimpleConversationUserDataWrapperList testRecordWithVirtualMeetingAppointLocAdminWrap = new SimpleConversationUserDataWrapperList();
			testRecordWithVirtualMeetingAppointLocAdminWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvInsert1Admn1' + '@sfa111.test.com';
			testRecordWithVirtualMeetingAppointLocAdminWrap.param_profileId = adminProfileId;
			testRecordWithVirtualMeetingAppointLocAdminWrap.param_associateId = '';
			testRecordWithVirtualMeetingAppointLocAdminWrap.param_servicingAgentAssociateId = '';
			testRecordWithVirtualMeetingAppointLocAdminWrap.param_externalId = '';
		User adminUser = buildUser(testRecordWithVirtualMeetingAppointLocAdminWrap);

        System.runAs(adminUser) {
           byPassTrigger();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            SimpleConversationUserDataWrapperList testRecordWithVirtualMeetingAppointLocAgentWrap = new SimpleConversationUserDataWrapperList();
			testRecordWithVirtualMeetingAppointLocAgentWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvInsert1Agnt1' + '@sfa111.test.com';
			testRecordWithVirtualMeetingAppointLocAgentWrap.param_profileId = agentProfileId;
			testRecordWithVirtualMeetingAppointLocAgentWrap.param_associateId = 'ppccpp11ttc';
			testRecordWithVirtualMeetingAppointLocAgentWrap.param_servicingAgentAssociateId = 'ppccpp11ttc';
			testRecordWithVirtualMeetingAppointLocAgentWrap.param_externalId = 'ppccpp11ttc_ppccpp11ttc';
			agentUser = buildUser(testRecordWithVirtualMeetingAppointLocAgentWrap);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;

            SimpleConversationUserDataWrapperList testRecordWithVirtualMeetingAppointLocProxyWrap = new SimpleConversationUserDataWrapperList();
			testRecordWithVirtualMeetingAppointLocProxyWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvInsert1Prox1' + '@sfa111.test.com';
			testRecordWithVirtualMeetingAppointLocProxyWrap.param_profileId = proxyProfileId;
			testRecordWithVirtualMeetingAppointLocProxyWrap.param_associateId = '';
			testRecordWithVirtualMeetingAppointLocProxyWrap.param_servicingAgentAssociateId = 'ppccpp11ttc';
			testRecordWithVirtualMeetingAppointLocProxyWrap.param_externalId = 'ppccpp11ttcP';
			proxyUser = buildUser(testRecordWithVirtualMeetingAppointLocProxyWrap);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            SimpleConversationUserDataWrapperList testRecordWithVirtualMeetingAppointLocSystemWrap = new SimpleConversationUserDataWrapperList();
			testRecordWithVirtualMeetingAppointLocSystemWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvInsert1Syst1' + '@sfa111.test.com';
			testRecordWithVirtualMeetingAppointLocSystemWrap.param_profileId = noAccessProfileId;
			testRecordWithVirtualMeetingAppointLocSystemWrap.param_associateId = '';
			testRecordWithVirtualMeetingAppointLocSystemWrap.param_servicingAgentAssociateId = '';
			testRecordWithVirtualMeetingAppointLocSystemWrap.param_externalId = '';
			User systemUser = buildUser(testRecordWithVirtualMeetingAppointLocSystemWrap);
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            Account act = buildAccountRecord('7601011');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;
            Test.startTest();
            SimpleConversation__c simpleConversationRecord = buildSimpleConversationRecord(act.id, agentUser.id);
            simpleConversationRecord.Appointment_Location__c = 'Virtual Meeting';
            insert simpleConversationRecord;
            Test.stopTest();
            List<EmailMessage> emailMsgList = [SELECT Id FROM EmailMessage ORDER BY Createddate LIMIT 2];
            System.assert(emailMsgList.size() == 0 ,'Email Size is not as expected');
        }
    }

    @isTest
    private static void testSimpleConversationOutlookEmailQuickAction() {
        User agentUser;
        User proxyUser;
        SimpleConversationUserDataWrapperList testOutlookEmailQuickActionAdminWrap = new SimpleConversationUserDataWrapperList();
			testOutlookEmailQuickActionAdminWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvInsert1Admn1' + '@sfa111.test.com';
			testOutlookEmailQuickActionAdminWrap.param_profileId = adminProfileId;
			testOutlookEmailQuickActionAdminWrap.param_associateId = '';
			testOutlookEmailQuickActionAdminWrap.param_servicingAgentAssociateId = '';
			testOutlookEmailQuickActionAdminWrap.param_externalId = '';
		User adminUser = buildUser(testOutlookEmailQuickActionAdminWrap);

        System.runAs(adminUser) {
            byPassTrigger();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            SimpleConversationUserDataWrapperList testOutlookEmailQuickActionAgentWrap = new SimpleConversationUserDataWrapperList();
			testOutlookEmailQuickActionAgentWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvInsert1Agnt1' + '@sfa111.test.com';
			testOutlookEmailQuickActionAgentWrap.param_profileId = agentProfileId;
			testOutlookEmailQuickActionAgentWrap.param_associateId = 'ppccpp11ttc';
			testOutlookEmailQuickActionAgentWrap.param_servicingAgentAssociateId = 'ppccpp11ttc';
			testOutlookEmailQuickActionAgentWrap.param_externalId = 'ppccpp11ttc_ppccpp11ttc';
			agentUser = buildUser(testOutlookEmailQuickActionAgentWrap);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            insert new PermissionSetAssignment(AssigneeId = agentUser.id,
                PermissionSetId = [SELECT id FROM PermissionSet WHERE Name = 'SF_CRM_VirtualMeetingAPTC_PermSetPID' LIMIT 1].id);

            SimpleConversationUserDataWrapperList testOutlookEmailQuickActionProxyWrap = new SimpleConversationUserDataWrapperList();
			testOutlookEmailQuickActionProxyWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvInsert1Prox1' + '@sfa111.test.com';
			testOutlookEmailQuickActionProxyWrap.param_profileId = proxyProfileId;
			testOutlookEmailQuickActionProxyWrap.param_associateId = '';
			testOutlookEmailQuickActionProxyWrap.param_servicingAgentAssociateId = 'ppccpp11ttc';
			testOutlookEmailQuickActionProxyWrap.param_externalId = 'ppccpp11ttcP';
			proxyUser = buildUser(testOutlookEmailQuickActionProxyWrap);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            SimpleConversationUserDataWrapperList testOutlookEmailQuickActionSystemWrap = new SimpleConversationUserDataWrapperList();
			testOutlookEmailQuickActionSystemWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvInsert1Syst1' + '@sfa111.test.com';
			testOutlookEmailQuickActionSystemWrap.param_profileId = noAccessProfileId;
			testOutlookEmailQuickActionSystemWrap.param_associateId = '';
			testOutlookEmailQuickActionSystemWrap.param_servicingAgentAssociateId = '';
			testOutlookEmailQuickActionSystemWrap.param_externalId = '';
			User systemUser = buildUser(testOutlookEmailQuickActionSystemWrap);
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        }

        System.runAs(agentUser) {
            Account act = buildAccountRecord('7601011');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;

            CS001_ByPassTriggerAll__c objectBasedByPassTrigger = [Select id from CS001_ByPassTriggerAll__c limit 1];
            objectBasedByPassTrigger.Override_All__c = false;
            update objectBasedByPassTrigger;

            Test.startTest();
            SimpleConversation__c simpleConversationRecord = buildSimpleConversationRecord(act.id, agentUser.id);
            simpleConversationRecord.Appointment_Location__c = 'Agent Office';
            insert simpleConversationRecord;

            List<SimpleConversation__c> simpleConvEmailRecords = new List<SimpleConversation__c>();
            simpleConvEmailRecords.add(simpleConversationRecord);
            HLPR_SimpleConversationTrigger.sendCalendarEmailQuickAction(simpleConvEmailRecords);

            Test.stopTest();

            List<SimpleConversation__c> simpleConverLog = [Select Id, Agent__c, ConductedBy__c, OwnerId from SimpleConversation__c limit 1];
            System.assert(!simpleConverLog.isEmpty(), 'simpleconversationlog should not be empty');
            System.assertEquals(agentUser.id, simpleConverLog[0].Agent__c, 'Agent object have agent user Id');
        }
    }

    @isTest
    private static void testSimpleConversationCancelOutlookEmailQuickAction() {
        User agentUser;
        User proxyUser;
        SimpleConversationUserDataWrapperList testCancelOutlookEmailQuickActionAdminWrap = new SimpleConversationUserDataWrapperList();
			testCancelOutlookEmailQuickActionAdminWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvInsert1Admn1' + '@sfa111.test.com';
			testCancelOutlookEmailQuickActionAdminWrap.param_profileId = adminProfileId;
			testCancelOutlookEmailQuickActionAdminWrap.param_associateId = '';
			testCancelOutlookEmailQuickActionAdminWrap.param_servicingAgentAssociateId = '';
			testCancelOutlookEmailQuickActionAdminWrap.param_externalId = '';
		User adminUser = buildUser(testCancelOutlookEmailQuickActionAdminWrap);

        System.runAs(adminUser) {
            byPassTrigger();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            SimpleConversationUserDataWrapperList testCancelOutlookEmailQuickActionAgentWrap = new SimpleConversationUserDataWrapperList();
			testCancelOutlookEmailQuickActionAgentWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvInsert1Agnt1' + '@sfa111.test.com';
			testCancelOutlookEmailQuickActionAgentWrap.param_profileId = agentProfileId;
			testCancelOutlookEmailQuickActionAgentWrap.param_associateId = 'ppccpp11ttc';
			testCancelOutlookEmailQuickActionAgentWrap.param_servicingAgentAssociateId = 'ppccpp11ttc';
			testCancelOutlookEmailQuickActionAgentWrap.param_externalId = 'ppccpp11ttc_ppccpp11ttc';
			agentUser = buildUser(testCancelOutlookEmailQuickActionAgentWrap);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            insert new PermissionSetAssignment(AssigneeId = agentUser.id,
                PermissionSetId = [SELECT id FROM PermissionSet WHERE Name = 'SF_CRM_VirtualMeetingAPTC_PermSetPID' LIMIT 1].id);

            SimpleConversationUserDataWrapperList testCancelOutlookEmailQuickActionProxyWrap = new SimpleConversationUserDataWrapperList();
			testCancelOutlookEmailQuickActionProxyWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvInsert1Prox1' + '@sfa111.test.com';
			testCancelOutlookEmailQuickActionProxyWrap.param_profileId = proxyProfileId;
			testCancelOutlookEmailQuickActionProxyWrap.param_associateId = '';
			testCancelOutlookEmailQuickActionProxyWrap.param_servicingAgentAssociateId = 'ppccpp11ttc';
			testCancelOutlookEmailQuickActionProxyWrap.param_externalId = 'ppccpp11ttcP';
			proxyUser = buildUser(testCancelOutlookEmailQuickActionProxyWrap);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            SimpleConversationUserDataWrapperList testCancelOutlookEmailQuickActionSystemWrap = new SimpleConversationUserDataWrapperList();
			testCancelOutlookEmailQuickActionSystemWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvInsert1Syst1' + '@sfa111.test.com';
			testCancelOutlookEmailQuickActionSystemWrap.param_profileId = noAccessProfileId;
			testCancelOutlookEmailQuickActionSystemWrap.param_associateId = '';
			testCancelOutlookEmailQuickActionSystemWrap.param_servicingAgentAssociateId = '';
			testCancelOutlookEmailQuickActionSystemWrap.param_externalId = '';
			User systemUser = buildUser(testCancelOutlookEmailQuickActionSystemWrap);
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        }

        System.runAs(agentUser) {
            Account act = buildAccountRecord('7601011');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;

            CS001_ByPassTriggerAll__c objectBasedByPassTrigger = [Select id from CS001_ByPassTriggerAll__c limit 1];
            objectBasedByPassTrigger.Override_All__c = false;
            update objectBasedByPassTrigger;

            Test.startTest();
            SimpleConversation__c simpleConversationRecord = buildSimpleConversationRecord(act.id, agentUser.id);
            simpleConversationRecord.Appointment_Location__c = 'Agent Office';
            simpleConversationRecord.Status__c = 'Customer Cancelled';
            insert simpleConversationRecord;

            List<SimpleConversation__c> simpleConvEmailRecords = new List<SimpleConversation__c>();
            simpleConvEmailRecords.add(simpleConversationRecord);
            HLPR_SimpleConversationTrigger.sendCalendarEmailQuickAction(simpleConvEmailRecords);

            Test.stopTest();

            List<SimpleConversation__c> simpleConverLog = [Select Id, Agent__c, ConductedBy__c, OwnerId from SimpleConversation__c limit 1];
            System.assert(!simpleConverLog.isEmpty(), 'simpleconversationlog should not be empty');
            System.assertEquals(agentUser.id, simpleConverLog[0].Agent__c, 'agent object have the agent user Id');
        }
    }
    //method to Bypass trigger
    @isTest
    private static void insertSimpleConversationAfterTriggerBypass(){
        User agentUser;
        User proxyUser;
        SimpleConversationUserDataWrapperList testAfterTriggerBypassAdminWrap = new SimpleConversationUserDataWrapperList();
			testAfterTriggerBypassAdminWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvInsert1Admn1' + '@sfa111.test.com';
			testAfterTriggerBypassAdminWrap.param_profileId = adminProfileId;
			testAfterTriggerBypassAdminWrap.param_associateId = '';
			testAfterTriggerBypassAdminWrap.param_servicingAgentAssociateId = '';
			testAfterTriggerBypassAdminWrap.param_externalId = '';
		User adminUser = buildUser(testAfterTriggerBypassAdminWrap);

        System.runAs(adminUser) {
            byPassTrigger();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            SimpleConversationUserDataWrapperList testAfterTriggerBypassAgentWrap = new SimpleConversationUserDataWrapperList();
			testAfterTriggerBypassAgentWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvInsert1Agnt1' + '@sfa111.test.com';
			testAfterTriggerBypassAgentWrap.param_profileId = agentProfileId;
			testAfterTriggerBypassAgentWrap.param_associateId = 'ppccpp11ttc';
			testAfterTriggerBypassAgentWrap.param_servicingAgentAssociateId = 'ppccpp11ttc';
			testAfterTriggerBypassAgentWrap.param_externalId = 'ppccpp11ttc_ppccpp11ttc';
			agentUser = buildUser(testAfterTriggerBypassAgentWrap);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;

            SimpleConversationUserDataWrapperList testAfterTriggerBypassProxyWrap = new SimpleConversationUserDataWrapperList();
			testAfterTriggerBypassProxyWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvInsert1Prox1' + '@sfa111.test.com';
			testAfterTriggerBypassProxyWrap.param_profileId = proxyProfileId;
			testAfterTriggerBypassProxyWrap.param_associateId = '';
			testAfterTriggerBypassProxyWrap.param_servicingAgentAssociateId = 'ppccpp11ttc';
			testAfterTriggerBypassProxyWrap.param_externalId = 'ppccpp11ttcP';
			proxyUser = buildUser(testAfterTriggerBypassProxyWrap);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            SimpleConversationUserDataWrapperList testAfterTriggerBypassSystemWrap = new SimpleConversationUserDataWrapperList();
			testAfterTriggerBypassSystemWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvInsert1Syst1' + '@sfa111.test.com';
			testAfterTriggerBypassSystemWrap.param_profileId = noAccessProfileId;
			testAfterTriggerBypassSystemWrap.param_associateId = '';
			testAfterTriggerBypassSystemWrap.param_servicingAgentAssociateId = '';
			testAfterTriggerBypassSystemWrap.param_externalId = '';
			User systemUser = buildUser(testAfterTriggerBypassSystemWrap);
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {

            Account act = buildAccountRecord('7601011');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;
            Test.startTest();
            SimpleConversation__c simpleConversationRecord = buildSimpleConversationRecord(act.id, agentUser.id);
            insert simpleConversationRecord;
            Test.stopTest();
            List<EmailMessage> emailMsgList = [SELECT Id,FromName,Status,TextBody,Subject,ToAddress,HtmlBody,CcAddress FROM EmailMessage ORDER BY Createddate LIMIT 2];
            System.assertEquals(0, emailMsgList.size(),'Email Size is not as expected');
        }
    }

    //test method to test exception
    @isTest
    private static void testSimpleConversationException(){
        Test.startTest();
        HLPR_SimpleConversationTrigger.sendCalendarEmail(null);
        Test.stopTest();
        List<ExceptionLog__c> exLog = [SELECT Id,class__c from ExceptionLog__c class__c where class__c = 'HLPR_SimpleConversationTrigger'];
        system.assert(exLog.size() != null, 'Unexpected exceptionLogSize');
    }

    @isTest
    private static void testSimpleConversationExceptionQuickAction(){
        Test.startTest();
        HLPR_SimpleConversationTrigger.sendCalendarEmailQuickAction(null);
        Test.stopTest();
        List<ExceptionLog__c> exLog = [SELECT Id,class__c from ExceptionLog__c class__c where class__c = 'HLPR_SimpleConversationTrigger'];
        system.assert(exLog.size() != null, 'Unexpected exceptionLogSize');
    }

    //test method to test exception
    @isTest
    private static void testSimpleConversationAfterInsertException(){
        Test.startTest();
        HLPR_SimpleConversationTrigger.createVirtualMeeting(null);
        Test.stopTest();
        List<ExceptionLog__c> exLog = [SELECT Id,class__c from ExceptionLog__c class__c where class__c = 'HLPR_SimpleConversationTrigger'];
        system.assert(exLog.size() != null, 'Unexpected exceptionLogSize');
    }
}