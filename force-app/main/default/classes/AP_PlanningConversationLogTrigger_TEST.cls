/**
* Author : Golden Spikes Team
* Date Created : 05/03/2018
* @description Test class for the AP_PlanningConversationLogTrigger_TEST apex class.
*/
@isTest (seeAllData=false)
public class AP_PlanningConversationLogTrigger_TEST {

    private static String agentProfileId = getProfileId(UTIL_Constants.AGENT_PROFILE_NAME);
    private static String proxyProfileId = getProfileId(UTIL_Constants.PROXY_PROFILE_NAME);
    private static String adminProfileId = getProfileId(UTIL_Constants.SYSTEM_ADMIN_PROFILE_NAME);
    private static String techSupportProfileId = getProfileId(UTIL_Constants.TECHNICAL_SUPPORT_PROFILE_NAME);
    private static String planningServicesProfileId = getProfileId('5.03 Investment Planning Services - Create');
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
    private static User buildUser(PlanningConversationUserDataWrapperList testUserValueWrapper) {
	String param_UserName = testUserValueWrapper.param_UserName;
	String param_profileId = testUserValueWrapper.param_profileId;
	String param_associateId = testUserValueWrapper.param_associateId;
	String param_servicingAgentAssociateId = testUserValueWrapper.param_servicingAgentAssociateId;
	String param_externalId = testUserValueWrapper.param_externalId;
        return new User (alias = '12345', email = 'testUser@statefarm.com.bad', emailencodingkey='UTF-8', lastname='TestUserLastName',
            languagelocalekey='en_US',localesidkey='en_US', timezonesidkey='America/Chicago',
            username= param_UserName, profileId = param_profileId,
            Associate_ID__c = param_associateId, Servicing_Agent_Associate_ID__c = param_servicingAgentAssociateId,
            UserExternalID__c = param_externalId
        );
        
    }

    private class PlanningConversationUserDataWrapperList{
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
                            Status__c = 'New', ConductedBy__c = param_conductedBy, SimpleConversationName__c = 'Test Simple Conv');
         
    }

    //method to build Planning Conversation Log record with the given parameter value
    private static PlanningConversationLog__c buildPlanningConversationLogRecord(String param_simpleConvId, String param_Comments) {
        return new PlanningConversationLog__c (SimpleConversation__c = param_simpleConvId,
                            Comments__c = param_Comments);
         
    }

    //test method to insert Planning Conversation Log record as an Agent.
    @isTest
    private static void testPlanningConversationLogRecordInsertAsAgent() {
        User agentUser;
        User proxyUser;
        PlanningConversationUserDataWrapperList recordInsertAsAgentDataWrap = new PlanningConversationUserDataWrapperList();
			recordInsertAsAgentDataWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Plan1ConvLogInsert1Admn1' + '@sfa111.test.com';
			recordInsertAsAgentDataWrap.param_profileId = adminProfileId;
			recordInsertAsAgentDataWrap.param_associateId = '';
			recordInsertAsAgentDataWrap.param_servicingAgentAssociateId = '';
			recordInsertAsAgentDataWrap.param_externalId = '';
		User adminUser = buildUser(recordInsertAsAgentDataWrap);
        
        System.runAs(adminUser) {
            byPassTrigger();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            PlanningConversationUserDataWrapperList recordInsertAsAgentUserWrap = new PlanningConversationUserDataWrapperList();
			recordInsertAsAgentUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Plan1ConvLogInsert1Agnt1' + '@sfa111.test.com';
			recordInsertAsAgentUserWrap.param_profileId = agentProfileId;
			recordInsertAsAgentUserWrap.param_associateId = 'zzccww11ttc';
			recordInsertAsAgentUserWrap.param_servicingAgentAssociateId = 'zzccww11ttc';
			recordInsertAsAgentUserWrap.param_externalId = 'zzccww11ttc_zzccww11ttc';
			agentUser = buildUser(recordInsertAsAgentUserWrap);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(agentUser.Id, 'SF_CRM_VirtualMeetingAPTC_PermSetPID');

            PlanningConversationUserDataWrapperList recordInsertAsProxyUserWrap = new PlanningConversationUserDataWrapperList();
			recordInsertAsProxyUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Plan1PlanConvLogInsert1Prox1' + '@sfa111.test.com';
			recordInsertAsProxyUserWrap.param_profileId = proxyProfileId;
			recordInsertAsProxyUserWrap.param_associateId = '';
			recordInsertAsProxyUserWrap.param_servicingAgentAssociateId = 'zzccww11ttc';
			recordInsertAsProxyUserWrap.param_externalId = 'zzccww11ttcP';
			proxyUser = buildUser(recordInsertAsProxyUserWrap);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            PlanningConversationUserDataWrapperList recordInsertAsSystemUserWrap = new PlanningConversationUserDataWrapperList();
			recordInsertAsSystemUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Plan1PlanConvLogInsert1Syst1' + '@sfa111.test.com';
			recordInsertAsSystemUserWrap.param_profileId = noAccessProfileId;
			recordInsertAsSystemUserWrap.param_associateId = '';
			recordInsertAsSystemUserWrap.param_servicingAgentAssociateId = '';
			recordInsertAsSystemUserWrap.param_externalId = '';
			User systemUser = buildUser(recordInsertAsSystemUserWrap);
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        	UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        }

        System.runAs(agentUser) {
            Account act = buildAccountRecord('8701011');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;

            CS001_ByPassTriggerAll__c objectBasedByPassTrigger = [Select id from CS001_ByPassTriggerAll__c limit 1];
            objectBasedByPassTrigger.Override_All__c = false;
            update objectBasedByPassTrigger;

            Test.startTest();
            SimpleConversation__c simpleConversationRecord = buildSimpleConversationRecord(act.id, agentUser.id);
            insert simpleConversationRecord;

            PlanningConversationLog__c planConversationLogRecord = buildPlanningConversationLogRecord(simpleConversationRecord.id, 'Test Comments');
            insert planConversationLogRecord;

            List<PlanningConversationLog__c> planConverLog = [Select Id, Account__c, Agent__c, Comments__c, OwnerId from PlanningConversationLog__c limit 1];
            System.assert(!planConverLog.isEmpty(), 'Plan coverlog should not be empty');
            System.assertEquals(act.id, planConverLog[0].Account__c, 'Plan converlog Account object will have the Account Id');
            System.assertEquals(agentUser.id, planConverLog[0].Agent__c, 'Plan converlog Agent object will have the Agent User Id');
            System.assertEquals(proxyUser.id, planConverLog[0].OwnerId, 'Plan converlog OwnerId will have proxyUser Id');
            System.assertEquals('Test Comments', planConverLog[0].Comments__c, 'Plan converlog comments object will have the Test commnets');
            Test.stopTest();
        }
    }

    //test method to insert Planning Conversation Log record as 5.03 Planning Services-Create User.
    @isTest
    private static void testPlanningConversationLogRecordInsertAsPlanningServiceUser() {
        User agentUser;
        User proxyUser;
        User planningservicesUser;
        Account act;
        PlanningConversationUserDataWrapperList recordInsertAsPlanningAdminUserWrap = new PlanningConversationUserDataWrapperList();
			recordInsertAsPlanningAdminUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest2_Plan2ConvLogInsert2Admn2' + '@sfa222.test.com';
			recordInsertAsPlanningAdminUserWrap.param_profileId = adminProfileId;
			recordInsertAsPlanningAdminUserWrap.param_associateId = '';
			recordInsertAsPlanningAdminUserWrap.param_servicingAgentAssociateId = '';
			recordInsertAsPlanningAdminUserWrap.param_externalId = '';
		User adminUser = buildUser(recordInsertAsPlanningAdminUserWrap);

        System.runAs(adminUser) {
            byPassTrigger();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            PlanningConversationUserDataWrapperList recordInsertAsPlanningAgentUserWrap = new PlanningConversationUserDataWrapperList();
			recordInsertAsPlanningAgentUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest2_Plan2ConvLogInsert2Agnt2' + '@sfa222.test.com';
			recordInsertAsPlanningAgentUserWrap.param_profileId = agentProfileId;
			recordInsertAsPlanningAgentUserWrap.param_associateId = 'zzccww22ttc';
			recordInsertAsPlanningAgentUserWrap.param_servicingAgentAssociateId = 'zzccww22ttc';
			recordInsertAsPlanningAgentUserWrap.param_externalId = 'zzccww22ttc_zzccww22ttc';
			agentUser = buildUser(recordInsertAsPlanningAgentUserWrap);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;

            PlanningConversationUserDataWrapperList recordInsertAsPlanningProxyUserWrap = new PlanningConversationUserDataWrapperList();
			recordInsertAsPlanningProxyUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest2_Plan2ConvLogInsert2Prox2' + '@sfa222.test.com';
			recordInsertAsPlanningProxyUserWrap.param_profileId = proxyProfileId;
			recordInsertAsPlanningProxyUserWrap.param_associateId = '';
			recordInsertAsPlanningProxyUserWrap.param_servicingAgentAssociateId = 'zzccww22ttc';
			recordInsertAsPlanningProxyUserWrap.param_externalId = 'zzccww22ttcP';
			proxyUser = buildUser(recordInsertAsPlanningProxyUserWrap);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            PlanningConversationUserDataWrapperList recordInsertAsPlanningServiceUserWrap = new PlanningConversationUserDataWrapperList();
			recordInsertAsPlanningServiceUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest2_Plan2ConvLog2Tech2' + '@sfa222.test.com';
			recordInsertAsPlanningServiceUserWrap.param_profileId = planningServicesProfileId;
			recordInsertAsPlanningServiceUserWrap.param_associateId = '';
			recordInsertAsPlanningServiceUserWrap.param_servicingAgentAssociateId = '';
			recordInsertAsPlanningServiceUserWrap.param_externalId = '';
			planningservicesUser = buildUser(recordInsertAsPlanningServiceUserWrap);
            insert planningservicesUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser,planningservicesUser});
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(planningservicesUser.Id, 'SF_CRM_VirtualMeetingAPTC_PermSetPID');


            PlanningConversationUserDataWrapperList recordInsertAsPlanningSystemUserWrap = new PlanningConversationUserDataWrapperList();
			recordInsertAsPlanningSystemUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest2_Plan2ConvLogInsert2Syst2' + '@sfa222.test.com';
			recordInsertAsPlanningSystemUserWrap.param_profileId = noAccessProfileId;
			recordInsertAsPlanningSystemUserWrap.param_associateId = '';
			recordInsertAsPlanningSystemUserWrap.param_servicingAgentAssociateId = '';
			recordInsertAsPlanningSystemUserWrap.param_externalId = '';
			User systemUser = buildUser(recordInsertAsPlanningSystemUserWrap);
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        	UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        }
        
        System.runAs(agentUser) {
            act = buildAccountRecord('8702022');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;

            CS001_ByPassTriggerAll__c objectBasedByPassTrigger = [Select id from CS001_ByPassTriggerAll__c limit 1];
            objectBasedByPassTrigger.Override_All__c = false;
            update objectBasedByPassTrigger;
            //added explicit share to Service user to get around salesforce limitation on Sharing rules in Apex.
            insert new accountshare(accountid=act.id,userorgroupid=planningservicesUser.id,AccountAccessLevel='Read',OpportunityAccessLevel='None',CaseAccessLevel='None',rowcause='manual');
        }
        
        System.runAs(planningservicesUser) {
            Test.startTest();
            SimpleConversation__c simpleConversationRecord = buildSimpleConversationRecord(act.id, planningservicesUser.id);
            simpleConversationRecord.Agent__c = agentUser.id;
            insert simpleConversationRecord;
            PlanningConversationLog__c planConversationLogRecord = buildPlanningConversationLogRecord(simpleConversationRecord.id, 'Test Comments');
            insert planConversationLogRecord;

            List<PlanningConversationLog__c> planConverLog = [Select Id, Account__c, Agent__c, Comments__c, OwnerId from PlanningConversationLog__c limit 1];
            System.assert(!planConverLog.isEmpty(), 'Plan coverlog should not be empty');
            System.assertEquals(act.id, planConverLog[0].Account__c, 'Plan converlog Account object will have the Account Id');
            System.assertEquals(agentUser.id, planConverLog[0].Agent__c, 'Plan converlog Agent object will have the Agent User Id');
            System.assertEquals(proxyUser.id, planConverLog[0].OwnerId, 'Plan converlog OwnerId will have proxyUser Id');
            System.assertEquals('Test Comments', planConverLog[0].Comments__c, 'Plan converlog comments object will have the Test commnets');
            Test.stopTest();
        }
    }

    //test method to validate Exception on  Planning Conversation Log record insert as a Technical Support User.
    @isTest
    private static void testExceptionOnPlanningConversationLogRecordInsertAsTechnicalSupportUser() {
        User techsupportUser;
        PlanningConversationUserDataWrapperList recordInsertAsTechnicalSupportAdminUserWrap = new PlanningConversationUserDataWrapperList();
			recordInsertAsTechnicalSupportAdminUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest3_Plan3ConvLogInsert3Admn3' + '@sfa333.test.com';
			recordInsertAsTechnicalSupportAdminUserWrap.param_profileId = adminProfileId;
			recordInsertAsTechnicalSupportAdminUserWrap.param_associateId = '';
			recordInsertAsTechnicalSupportAdminUserWrap.param_servicingAgentAssociateId = '';
			recordInsertAsTechnicalSupportAdminUserWrap.param_externalId = '';
		User adminUser = buildUser(recordInsertAsTechnicalSupportAdminUserWrap);

        System.runAs(adminUser) {
            byPassTrigger();
            PlanningConversationUserDataWrapperList recordInsertAsTechnicalSupportUserWrap = new PlanningConversationUserDataWrapperList();
			recordInsertAsTechnicalSupportUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest3_Plan3ConvLog3Tech3' + '@sfa333.test.com';
			recordInsertAsTechnicalSupportUserWrap.param_profileId = techSupportProfileId;
			recordInsertAsTechnicalSupportUserWrap.param_associateId = '';
			recordInsertAsTechnicalSupportUserWrap.param_servicingAgentAssociateId = '';
			recordInsertAsTechnicalSupportUserWrap.param_externalId = '';
			techsupportUser = buildUser(recordInsertAsTechnicalSupportUserWrap);
            insert techsupportUser;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(techsupportUser);
        System.runAs(techsupportUser) {
            Test.startTest();
            List<PlanningConversationLog__c> planConversationLogRecord;
            try {
                AP_PlanningConversationLogTrigger planConvLog = new AP_PlanningConversationLogTrigger();
                planConvLog.processPlanningConversationLogOnAfterInsert(planConversationLogRecord);
            } catch(Exception ex) {
                System.assert(!String.isBlank(ex.getMessage()), 'Exception message string should not be blank');
            }
            List<PlanningConversationLog__c> planConverLog = [Select Id from PlanningConversationLog__c limit 1];
            System.assert(planConverLog.isEmpty(), 'Planning conversation log object is empty');
            Test.stopTest();
        }
    }

    //test method to Validate SPI Prevention on "Comments" field on insert as an Agent for Planning Conversation Log record.
    @isTest
    private static void testSPIPreventionOnPlanningConversationLogInsertAsAgent() {
        User agentUser;
        User proxyUser;
        PlanningConversationUserDataWrapperList logInsertAsAdminUserWrap = new PlanningConversationUserDataWrapperList();
			logInsertAsAdminUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'spi1_test1PlanConvLog1Admn1' + '@sfa111.test.com';
			logInsertAsAdminUserWrap.param_profileId = adminProfileId;
			logInsertAsAdminUserWrap.param_associateId = '';
			logInsertAsAdminUserWrap.param_servicingAgentAssociateId = '';
			logInsertAsAdminUserWrap.param_externalId = '';
		User adminUser = buildUser(logInsertAsAdminUserWrap);

        System.runAs(adminUser) {
            byPassTrigger();
            UTIL_SPITestDataCreation_TEST.createSPIDataPreventionFieldsForPlanningConversationLog();
            UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
            UTIL_SPITestDataCreation_TEST.createSPIChunkSize();
            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            PlanningConversationUserDataWrapperList logInsertAsAgentUserWrap = new PlanningConversationUserDataWrapperList();
			logInsertAsAgentUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'spi1_test1PlanConvLog1Agnt1' + '@sfa111.test.com';
			logInsertAsAgentUserWrap.param_profileId = agentProfileId;
			logInsertAsAgentUserWrap.param_associateId = 'ppccww11ttc';
			logInsertAsAgentUserWrap.param_servicingAgentAssociateId = 'ppccww11ttc';
			logInsertAsAgentUserWrap.param_externalId = 'ppccww11ttc_ppccww11ttc';
			agentUser = buildUser(logInsertAsAgentUserWrap);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(agentUser.Id, 'SF_CRM_VirtualMeetingAPTC_PermSetPID');


            PlanningConversationUserDataWrapperList logInsertAsProxyUserWrap = new PlanningConversationUserDataWrapperList();
			logInsertAsProxyUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'spi1_test1PlanConvLog1Prox1' + '@sfa111.test.com';
			logInsertAsProxyUserWrap.param_profileId = proxyProfileId;
			logInsertAsProxyUserWrap.param_associateId = '';
			logInsertAsProxyUserWrap.param_servicingAgentAssociateId = 'ppccww11ttc';
			logInsertAsProxyUserWrap.param_externalId = 'ppccww11ttcP';
			proxyUser = buildUser(logInsertAsProxyUserWrap);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            PlanningConversationUserDataWrapperList logInsertAsSystemUserWrap = new PlanningConversationUserDataWrapperList();
			logInsertAsSystemUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'spi1_test1PlanConvLog1Syst1' + '@sfa111.test.com';
			logInsertAsSystemUserWrap.param_profileId = noAccessProfileId;
			logInsertAsSystemUserWrap.param_associateId = '';
			logInsertAsSystemUserWrap.param_servicingAgentAssociateId = '';
			logInsertAsSystemUserWrap.param_externalId = '';
			User systemUser = buildUser(logInsertAsSystemUserWrap);
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        	UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        }
        
        System.runAs(agentUser) {
            Account act = buildAccountRecord('9701011');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;

            CS001_ByPassTriggerAll__c objectBasedByPassTrigger = [Select id from CS001_ByPassTriggerAll__c limit 1];
            objectBasedByPassTrigger.Override_All__c = false;
            update objectBasedByPassTrigger;

            Test.startTest();
            try {
                SimpleConversation__c simpleConversationRecord = buildSimpleConversationRecord(act.id, agentUser.id);
                insert simpleConversationRecord;

                PlanningConversationLog__c planConversationLogRecord = buildPlanningConversationLogRecord(simpleConversationRecord.id, '123-45-6789');
                insert planConversationLogRecord;
            } catch(Exception e) {
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.PLANNINGCONVERSLOG_COMMENTS_ON_BREACH_ERROR_MSG), 'Exception message should contain UTIL_SPITestConstants.PLANNINGCONVERSLOG_COMMENTS_ON_BREACH_ERROR_MSG');
            }
            List<PlanningConversationLog__c> planConverLog = [Select Id from PlanningConversationLog__c limit 1];
            System.assert(planConverLog.isEmpty(), 'Planning conversation log is empty');
            Test.stopTest();
        }
    }

    //test method to verify PlanningConversationLogBeforeInsert trigger on bypass logic - Not to Fire.
    @isTest
    private static void testBypassSPIPreventionOnPlanningConversationLogInsertAsAgent() {
        User agentUser;
        User proxyUser;
        PlanningConversationUserDataWrapperList testLogInsertAsAdminUserWrap = new PlanningConversationUserDataWrapperList();
			testLogInsertAsAdminUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'spi3_test3PlanConvLog3Admn3' + '@sfa333.test.com';
			testLogInsertAsAdminUserWrap.param_profileId = adminProfileId;
			testLogInsertAsAdminUserWrap.param_associateId = '';
			testLogInsertAsAdminUserWrap.param_servicingAgentAssociateId = '';
			testLogInsertAsAdminUserWrap.param_externalId = '';
		User adminUser = buildUser(testLogInsertAsAdminUserWrap);

        System.runAs(adminUser) {
            byPassTrigger();
            UTIL_SPITestDataCreation_TEST.createSPIDataPreventionFieldsForPlanningConversationLog();
            UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
            UTIL_SPITestDataCreation_TEST.createSPIChunkSize();
            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            PlanningConversationUserDataWrapperList testLogInsertAsAgentUserWrap = new PlanningConversationUserDataWrapperList();
			testLogInsertAsAgentUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'spi3_test3PlanConvLog3Agnt3' + '@sfa333.test.com';
			testLogInsertAsAgentUserWrap.param_profileId = agentProfileId;
			testLogInsertAsAgentUserWrap.param_associateId = 'ppccww33ttc';
			testLogInsertAsAgentUserWrap.param_servicingAgentAssociateId = 'ppccww33ttc';
			testLogInsertAsAgentUserWrap.param_externalId = 'ppccww33ttc_ppccww33ttc';
			agentUser = buildUser(testLogInsertAsAgentUserWrap);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;

            PlanningConversationUserDataWrapperList testLogInsertAsProxyUserWrap = new PlanningConversationUserDataWrapperList();
			testLogInsertAsProxyUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'spi3_test3PlanConvLog3Prox3' + '@sfa333.test.com';
			testLogInsertAsProxyUserWrap.param_profileId = proxyProfileId;
			testLogInsertAsProxyUserWrap.param_associateId = '';
			testLogInsertAsProxyUserWrap.param_servicingAgentAssociateId = 'ppccww33ttc';
			testLogInsertAsProxyUserWrap.param_externalId = 'ppccww33ttcP';
			proxyUser = buildUser(testLogInsertAsProxyUserWrap);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            PlanningConversationUserDataWrapperList testLogInsertAsSystemUserWrap = new PlanningConversationUserDataWrapperList();
			testLogInsertAsSystemUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'spi3_test3PlanConvLog3Syst3' + '@sfa333.test.com';
			testLogInsertAsSystemUserWrap.param_profileId = noAccessProfileId;
			testLogInsertAsSystemUserWrap.param_associateId = '';
			testLogInsertAsSystemUserWrap.param_servicingAgentAssociateId = '';
			testLogInsertAsSystemUserWrap.param_externalId = '';
			User systemUser = buildUser(testLogInsertAsSystemUserWrap);
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        	UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            Account act = buildAccountRecord('9703033');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;

            Test.startTest();
            SimpleConversation__c simpleConversationRecord = buildSimpleConversationRecord(act.id, agentUser.id);
            insert simpleConversationRecord;

            PlanningConversationLog__c planConversationLogRecord = buildPlanningConversationLogRecord(simpleConversationRecord.id, '123-45-6789');
            insert planConversationLogRecord;

            List<PlanningConversationLog__c> planConverLog = [Select Id, Account__c, Agent__c, Comments__c, OwnerId from PlanningConversationLog__c where id =: planConversationLogRecord.id];
            System.assert(!planConverLog.isEmpty(), 'Plan converlog should not be empty');
            System.assert(String.isblank(planConverLog[0].Account__c), 'Plan converlog Account object is true if the string is Blank');
            System.assert(String.isblank(planConverLog[0].Agent__c), 'Plan converlog Agent object is true if the string is Blank');
            System.assertEquals(agentUser.id, planConverLog[0].OwnerId, 'Plan converlog OwnerId will have the AgentUser Id');
            System.assertEquals('123-45-6789', planConverLog[0].Comments__c, 'Plan converlog comments object will have the Test commnets');
            Test.stopTest();
        }
    }

    //test method to verify PlanningConversationLogBeforeUpdate trigger on bypass logic - Not to Fire.
    @isTest
    private static void testBypassPopulateAgentOfficeOnPlanningConversationLogUpdateAsTechSupport() {
        User agentUser1;
        User agentUser2;
        User proxyUser1;
        User proxyUser2;
        User techSupportUser;
        PlanningConversationUserDataWrapperList testLogUpdateAsTechSupportAdminUserWrap = new PlanningConversationUserDataWrapperList();
			testLogUpdateAsTechSupportAdminUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'AgtUp4_test4PlanConvLog4Admn4' + '@sfa444.test.com';
			testLogUpdateAsTechSupportAdminUserWrap.param_profileId = adminProfileId;
			testLogUpdateAsTechSupportAdminUserWrap.param_associateId = '';
			testLogUpdateAsTechSupportAdminUserWrap.param_servicingAgentAssociateId = '';
			testLogUpdateAsTechSupportAdminUserWrap.param_externalId = '';
		User adminUser = buildUser(testLogUpdateAsTechSupportAdminUserWrap);
        Account act;

        System.runAs(adminUser) {
            byPassTrigger();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            PlanningConversationUserDataWrapperList testLogUpdateAsTechSupportAgentUser1Wrap = new PlanningConversationUserDataWrapperList();
			testLogUpdateAsTechSupportAgentUser1Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'AgtUp4_test4PlanConvLog4Agnt4' + '@sfa444.test.com';
			testLogUpdateAsTechSupportAgentUser1Wrap.param_profileId = agentProfileId;
			testLogUpdateAsTechSupportAgentUser1Wrap.param_associateId = 'ppccww44ttc';
			testLogUpdateAsTechSupportAgentUser1Wrap.param_servicingAgentAssociateId = 'ppccww44ttc';
			testLogUpdateAsTechSupportAgentUser1Wrap.param_externalId = 'ppccww44ttc_ppccww44ttc';
			agentUser1 = buildUser(testLogUpdateAsTechSupportAgentUser1Wrap);
            agentUser1.userRoleId = agentUserRole.id;
            insert agentUser1;

            PlanningConversationUserDataWrapperList testLogUpdateAsTechSupportAgentUser2Wrap = new PlanningConversationUserDataWrapperList();
			testLogUpdateAsTechSupportAgentUser2Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'AgtUp4_teat4ConvLogUpdate4Agnt4' + '@sfa444.test.com';
			testLogUpdateAsTechSupportAgentUser2Wrap.param_profileId = agentProfileId;
			testLogUpdateAsTechSupportAgentUser2Wrap.param_associateId = 'kkccww44ttc';
			testLogUpdateAsTechSupportAgentUser2Wrap.param_servicingAgentAssociateId = 'kkccww44ttc';
			testLogUpdateAsTechSupportAgentUser2Wrap.param_externalId = 'kkccww44ttc_kkccww44ttc';
			agentUser2 = buildUser(testLogUpdateAsTechSupportAgentUser2Wrap);
            agentUser2.userRoleId = agentUserRole.id;
            insert agentUser2;

            PlanningConversationUserDataWrapperList testLogUpdateAsTechSupportProxyUser1Wrap = new PlanningConversationUserDataWrapperList();
			testLogUpdateAsTechSupportProxyUser1Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'AgtUp4_test4PlanConvLog4Prox4' + '@sfa444.test.com';
			testLogUpdateAsTechSupportProxyUser1Wrap.param_profileId = proxyProfileId;
			testLogUpdateAsTechSupportProxyUser1Wrap.param_associateId = '';
			testLogUpdateAsTechSupportProxyUser1Wrap.param_servicingAgentAssociateId = 'ppccww44ttc';
			testLogUpdateAsTechSupportProxyUser1Wrap.param_externalId = 'ppccww44ttcP';
			proxyUser1 = buildUser(testLogUpdateAsTechSupportProxyUser1Wrap);
            proxyUser1.userRoleId = proxyUserRole.id;
            insert proxyUser1;

            PlanningConversationUserDataWrapperList testLogUpdateAsTechSupportProxyUser2Wrap = new PlanningConversationUserDataWrapperList();
			testLogUpdateAsTechSupportProxyUser2Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'AgtUp4_test4PlanConvLog4Prox4' + '@sfa444.test.com';
			testLogUpdateAsTechSupportProxyUser2Wrap.param_profileId = proxyProfileId;
			testLogUpdateAsTechSupportProxyUser2Wrap.param_associateId = '';
			testLogUpdateAsTechSupportProxyUser2Wrap.param_servicingAgentAssociateId = 'kkccww44ttc';
			testLogUpdateAsTechSupportProxyUser2Wrap.param_externalId = 'kkccww44ttcP';
			proxyUser2 = buildUser(testLogUpdateAsTechSupportProxyUser2Wrap);
            proxyUser2.userRoleId = proxyUserRole.id;
            insert proxyUser2;

            PlanningConversationUserDataWrapperList testLogUpdateAsTechSupportUserWrap = new PlanningConversationUserDataWrapperList();
			testLogUpdateAsTechSupportUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'AgtUp4_test4PlanConvLog4Tech4' + '@sfa444.test.com';
			testLogUpdateAsTechSupportUserWrap.param_profileId = techSupportProfileId;
			testLogUpdateAsTechSupportUserWrap.param_associateId = '';
			testLogUpdateAsTechSupportUserWrap.param_servicingAgentAssociateId = '';
			testLogUpdateAsTechSupportUserWrap.param_externalId = '';
			techsupportUser = buildUser(testLogUpdateAsTechSupportUserWrap);
            insert techSupportUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser1,techSupportUser});
            permissionSetPlanningConversationTechSupportUser(techSupportUser);

            PlanningConversationUserDataWrapperList testLogUpdateAsTechSupportSystemUserWrap = new PlanningConversationUserDataWrapperList();
			testLogUpdateAsTechSupportSystemUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'AgtUp4_test4PlanConvLog4Syst4' + '@sfa444.test.com';
			testLogUpdateAsTechSupportSystemUserWrap.param_profileId = noAccessProfileId;
			testLogUpdateAsTechSupportSystemUserWrap.param_associateId = '';
			testLogUpdateAsTechSupportSystemUserWrap.param_servicingAgentAssociateId = '';
			testLogUpdateAsTechSupportSystemUserWrap.param_externalId = '';
			User systemUser = buildUser(testLogUpdateAsTechSupportSystemUserWrap);
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        	UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        }
        
        System.runAs(agentUser1) {

            act = buildAccountRecord('9704044');
            insert act;

            AgentRole__c agentRole1 = buildAgentRoleRecord(act.id);
            insert agentRole1;

            AgentRole__c agentRole2 = buildAgentRoleRecord(act.id);
            agentRole2.Agent__c = agentUser2.id;
            insert agentRole2;

            CS001_ByPassTriggerAll__c objectBasedByPassTrigger = [Select id from CS001_ByPassTriggerAll__c limit 1];
            objectBasedByPassTrigger.Override_All__c = false;
            update objectBasedByPassTrigger;
        }
        
        System.runAs(techSupportUser) {
            Test.startTest();
            SimpleConversation__c simpleConversationRecord1 = buildSimpleConversationRecord(act.id, agentUser1.id);
            simpleConversationRecord1.Agent__c = agentUser1.id;
            insert simpleConversationRecord1;
            SimpleConversation__c simpleConversationRecord2 = buildSimpleConversationRecord(act.id, agentUser2.id);
            simpleConversationRecord2.Agent__c = agentUser2.id;
            insert simpleConversationRecord2;

            PlanningConversationLog__c planConvLogToBeInserted = buildPlanningConversationLogRecord(simpleConversationRecord1.id, 'Testing Planning Conversation Log Comments');
            insert planConvLogToBeInserted;
            PlanConvRecordWrapperList convLogBeforeWrap = new PlanConvRecordWrapperList();
			convLogBeforeWrap.planConvLogToBeInserted = planConvLogToBeInserted;
			convLogBeforeWrap.proxyUser1 = proxyUser1;
			convLogBeforeWrap.agentUser1 = agentUser1;
			convLogBeforeWrap.act = act;
			planningConversationLogRecord(convLogBeforeWrap);

            CS001_ByPassTriggerAll__c objectBasedByPassTrigger = [Select id from CS001_ByPassTriggerAll__c limit 1];
            objectBasedByPassTrigger.Override_All__c = true;
            update objectBasedByPassTrigger;

            PlanningConversationLog__c planConvLogToBeUpdated = new PlanningConversationLog__c (id = planConvLogToBeInserted.id, SimpleConversation__c  = simpleConversationRecord2.id);
            update planConvLogToBeUpdated;

            PlanningConversationLog__c planConverLogAfter = [Select id, Account__c, Agent__c, ownerId from PlanningConversationLog__c where id =: planConvLogToBeInserted.id];
            System.assertEquals(proxyUser1.id, planConverLogAfter.ownerId, 'Plan converlog After owner Id have the proxyUser1 Id');
            System.assertEquals(agentUser1.id, planConverLogAfter.Agent__c, 'Plan converlog After Agent object have the agentUser1 Id');
            System.assertEquals(act.id, planConverLogAfter.Account__c, 'Plan converlog After Account object have account Id');
            Test.stopTest();
        }
    }

    private static void permissionSetPlanningConversationTechSupportUser(User techSupportUser){
        AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'CoreComponents_User_R');
        AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'CustomerView_Support_ViewAll');
        AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'CustomerView_ApexAura_Enabled');
        AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'SPI_User');
        AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techsupportUser.Id, 'SF_CRM_VirtualMeetingAPTC_PermSetPID');
        AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techsupportUser.Id, 'SimpleConversation_Support_W');
    }

    private static void planningConversationLogRecord(PlanConvRecordWrapperList conversationRecordWrapper){
        PlanningConversationLog__c planConvLogToBeInserted = conversationRecordWrapper.planConvLogToBeInserted;
        User proxyUser1 = conversationRecordWrapper.proxyUser1;
        User agentUser1 = conversationRecordWrapper.agentUser1;
        Account act = conversationRecordWrapper.act;
        PlanningConversationLog__c planConverLogBefore = [Select id, Account__c, Agent__c, ownerId from PlanningConversationLog__c where id =: planConvLogToBeInserted.id];
        System.assertEquals(proxyUser1.id, planConverLogBefore.ownerId, 'Plan converlog Before owner Id have the proxyUser1 Id');
        System.assertEquals(agentUser1.id, planConverLogBefore.Agent__c, 'Plan converlog Before Agent object have the agentUser1 Id');
        System.assertEquals(act.id, planConverLogBefore.Account__c, 'Plan converlog Before Account object have account Id');
    }

    private class PlanConvRecordWrapperList{
		private PlanningConversationLog__c planConvLogToBeInserted;
		private User proxyUser1;
		private User agentUser1;
		private Account act;
    }

    //test method to update planning conversation log record as technical support user
    @isTest
    private static void testPopulateAgentOfficeOnPlanningConversationLogUpdateAsTechSupport() {
        User agentUser1;
        User agentUser2;
        User proxyUser1;
        User proxyUser2;
        User techSupportUser;
        PlanningConversationUserDataWrapperList logUpdateAsTechAdminUserWrap = new PlanningConversationUserDataWrapperList();
			logUpdateAsTechAdminUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'AgtUp5_test5PlanConvLog5Admn5' + '@sfa555.test.com';
			logUpdateAsTechAdminUserWrap.param_profileId = adminProfileId;
			logUpdateAsTechAdminUserWrap.param_associateId = '';
			logUpdateAsTechAdminUserWrap.param_servicingAgentAssociateId = '';
			logUpdateAsTechAdminUserWrap.param_externalId = '';
		User adminUser = buildUser(logUpdateAsTechAdminUserWrap);
        Account act;

        System.runAs(adminUser) {
            byPassTrigger();
            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            PlanningConversationUserDataWrapperList logUpdateAsTechAgentUser1Wrap = new PlanningConversationUserDataWrapperList();
			logUpdateAsTechAgentUser1Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'AgtUp5_test5PlanConvLog5Agnt5' + '@sfa555.test.com';
			logUpdateAsTechAgentUser1Wrap.param_profileId = agentProfileId;
			logUpdateAsTechAgentUser1Wrap.param_associateId = 'ppccww55ttc';
			logUpdateAsTechAgentUser1Wrap.param_servicingAgentAssociateId = 'ppccww55ttc';
			logUpdateAsTechAgentUser1Wrap.param_externalId = 'ppccww55ttc_ppccww55ttc';
			agentUser1 = buildUser(logUpdateAsTechAgentUser1Wrap);
            agentUser1.userRoleId = agentUserRole.id;
            insert agentUser1;

            PlanningConversationUserDataWrapperList logUpdateAsTechAgentUser2Wrap = new PlanningConversationUserDataWrapperList();
			logUpdateAsTechAgentUser2Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'AgtUp5_teat5ConvLogUpdate5Agnt5' + '@sfa555.test.com';
			logUpdateAsTechAgentUser2Wrap.param_profileId = agentProfileId;
			logUpdateAsTechAgentUser2Wrap.param_associateId = 'kkccww55ttc';
			logUpdateAsTechAgentUser2Wrap.param_servicingAgentAssociateId = 'kkccww55ttc';
			logUpdateAsTechAgentUser2Wrap.param_externalId = 'kkccww55ttc_kkccww55ttc';
			agentUser2 = buildUser(logUpdateAsTechAgentUser2Wrap);
            agentUser2.userRoleId = agentUserRole.id;
            insert agentUser2;

            PlanningConversationUserDataWrapperList logUpdateAsTechProxyUser1Wrap = new PlanningConversationUserDataWrapperList();
			logUpdateAsTechProxyUser1Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'AgtUp5_test5PlanConvLog5Prox5' + '@sfa555.test.com';
			logUpdateAsTechProxyUser1Wrap.param_profileId = proxyProfileId;
			logUpdateAsTechProxyUser1Wrap.param_associateId = '';
			logUpdateAsTechProxyUser1Wrap.param_servicingAgentAssociateId = 'ppccww55ttc';
			logUpdateAsTechProxyUser1Wrap.param_externalId = 'ppccww55ttcP';
			proxyUser1 = buildUser(logUpdateAsTechProxyUser1Wrap);
            proxyUser1.userRoleId = proxyUserRole.id;
            insert proxyUser1;

            PlanningConversationUserDataWrapperList logUpdateAsTechProxyUser2Wrap = new PlanningConversationUserDataWrapperList();
			logUpdateAsTechProxyUser2Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'AgtUp5_test5PlanConvLog5Prox5' + '@sfa555.test.com';
			logUpdateAsTechProxyUser2Wrap.param_profileId = proxyProfileId;
			logUpdateAsTechProxyUser2Wrap.param_associateId = '';
			logUpdateAsTechProxyUser2Wrap.param_servicingAgentAssociateId = 'kkccww55ttc';
			logUpdateAsTechProxyUser2Wrap.param_externalId = 'kkccww55ttcP';
			proxyUser2 = buildUser(logUpdateAsTechProxyUser2Wrap);
            proxyUser2.userRoleId = proxyUserRole.id;
            insert proxyUser2;

            PlanningConversationUserDataWrapperList logUpdateAsTechSupportUser2Wrap = new PlanningConversationUserDataWrapperList();
			logUpdateAsTechSupportUser2Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'AgtUp5_test5PlanConvLog5Tech5' + '@sfa555.test.com';
			logUpdateAsTechSupportUser2Wrap.param_profileId = techSupportProfileId;
			logUpdateAsTechSupportUser2Wrap.param_associateId = '';
			logUpdateAsTechSupportUser2Wrap.param_servicingAgentAssociateId = '';
			logUpdateAsTechSupportUser2Wrap.param_externalId = '';
			techsupportUser = buildUser(logUpdateAsTechSupportUser2Wrap);
            insert techSupportUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser1,techSupportUser});
            permSetTechSupportUser(techSupportUser);

            PlanningConversationUserDataWrapperList logUpdateAsTechSupportSystemUser2Wrap = new PlanningConversationUserDataWrapperList();
			logUpdateAsTechSupportSystemUser2Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'AgtUp5_test5PlanConvLog5Syst5' + '@sfa555.test.com';
			logUpdateAsTechSupportSystemUser2Wrap.param_profileId = noAccessProfileId;
			logUpdateAsTechSupportSystemUser2Wrap.param_associateId = '';
			logUpdateAsTechSupportSystemUser2Wrap.param_servicingAgentAssociateId = '';
			logUpdateAsTechSupportSystemUser2Wrap.param_externalId = '';
			User systemUser = buildUser(logUpdateAsTechSupportSystemUser2Wrap);
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        	UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        }
        
        System.runAs(agentUser1) {
            act = buildAccountRecord('9705055');
            insert act;

            AgentRole__c agentRole1 = buildAgentRoleRecord(act.id);
            insert agentRole1;

            AgentRole__c agentRole2 = buildAgentRoleRecord(act.id);
            agentRole2.Agent__c = agentUser2.id;
            insert agentRole2;

            CS001_ByPassTriggerAll__c objectBasedByPassTrigger = [Select id from CS001_ByPassTriggerAll__c limit 1];
            objectBasedByPassTrigger.Override_All__c = false;
            update objectBasedByPassTrigger;
        }
        
        System.runAs(techSupportUser) {
            Test.startTest();
            SimpleConversation__c simpleConversationRecord1 = buildSimpleConversationRecord(act.id, agentUser1.id);
            simpleConversationRecord1.Agent__c = agentUser1.id;
            insert simpleConversationRecord1;
            SimpleConversation__c simpleConversationRecord2 = buildSimpleConversationRecord(act.id, agentUser2.id);
            simpleConversationRecord2.Agent__c = agentUser2.id;
            insert simpleConversationRecord2;

            PlanningConversationLog__c planConvLogToBeInserted = buildPlanningConversationLogRecord(simpleConversationRecord1.id, 'Testing Planning Conversation Log Comments');
            insert planConvLogToBeInserted;
            PlanConvUserRecordWrapperList convUserLogBeforeWrap = new PlanConvUserRecordWrapperList();
			convUserLogBeforeWrap.planConvLogToBeInserted = planConvLogToBeInserted;
			convUserLogBeforeWrap.proxyUser1 = proxyUser1;
			convUserLogBeforeWrap.agentUser1 = agentUser1;
			convUserLogBeforeWrap.act = act;
	        planningConversationLogUserRecord(convUserLogBeforeWrap);

            PlanningConversationLog__c planConvLogToBeUpdated = new PlanningConversationLog__c (id = planConvLogToBeInserted.id, SimpleConversation__c  = simpleConversationRecord2.id);
            update planConvLogToBeUpdated;

            PlanningConversationLog__c planConverLogAfter = [Select id, Account__c, Agent__c, ownerId from PlanningConversationLog__c where id =: planConvLogToBeInserted.id];
            System.assertEquals(proxyUser2.id, planConverLogAfter.ownerId, 'Plan converlog After owner Id have the proxyUser1 Id');
            System.assertEquals(agentUser2.id, planConverLogAfter.Agent__c, 'Plan converlog After Agent object have the agentUser1 Id');
            System.assertEquals(act.id, planConverLogAfter.Account__c, 'Plan converlog After Account object have account Id');
            Test.stopTest();
        }
    }

    private static void permSetTechSupportUser(User techSupportUser){
        AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'CoreComponents_User_R');
        //AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'CoreComponents_AllUsers');
        AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'CustomerView_Support_ViewAll');
        AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'CustomerView_ApexAura_Enabled');
        AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'SPI_User');
        AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techsupportUser.Id, 'SF_CRM_VirtualMeetingAPTC_PermSetPID');
        AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techsupportUser.Id, 'SimpleConversation_Support_W');
    }

    private static void planningConversationLogUserRecord(PlanConvUserRecordWrapperList conversationUserRecordWrapper){
        PlanningConversationLog__c planConvLogToBeInserted = conversationUserRecordWrapper.planConvLogToBeInserted;
        User proxyUser1 = conversationUserRecordWrapper.proxyUser1;
        User agentUser1 = conversationUserRecordWrapper.agentUser1;
        Account act = conversationUserRecordWrapper.act;
        PlanningConversationLog__c planConverLogBefore = [Select id, Account__c, Agent__c, ownerId from PlanningConversationLog__c where id =: planConvLogToBeInserted.id];
        System.assertEquals(proxyUser1.id, planConverLogBefore.ownerId, 'Plan converlog Before owner Id have the proxyUser1 Id');
        System.assertEquals(agentUser1.id, planConverLogBefore.Agent__c, 'Plan converlog Before Agent object have the agentUser1 Id');
        System.assertEquals(act.id, planConverLogBefore.Account__c, 'Plan converlog Before Account object have account Id');
    }

    private class PlanConvUserRecordWrapperList{
		private PlanningConversationLog__c planConvLogToBeInserted;
		private User proxyUser1;
		private User agentUser1;
		private Account act;
	}

    //test method to validate Exception on  Planning Conversation Log record update as a Technical Support User.
    @isTest
    private static void testExceptionOnPlanningConversationLogRecordUpdateAsTechnicalSupportUser() {
        User techsupportUser;
        PlanningConversationUserDataWrapperList testValidateExceptionAsAdminUserWrap = new PlanningConversationUserDataWrapperList();
			testValidateExceptionAsAdminUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest6_Plan6ConvLogUpdate6Admn3' + '@sfa666.test.com';
			testValidateExceptionAsAdminUserWrap.param_profileId = adminProfileId;
			testValidateExceptionAsAdminUserWrap.param_associateId = '';
			testValidateExceptionAsAdminUserWrap.param_servicingAgentAssociateId = '';
			testValidateExceptionAsAdminUserWrap.param_externalId = '';
		User adminUser = buildUser(testValidateExceptionAsAdminUserWrap);

        System.runAs(adminUser) {
            byPassTrigger();

            PlanningConversationUserDataWrapperList testValidateExceptionAsTechSupportUserWrap = new PlanningConversationUserDataWrapperList();
			testValidateExceptionAsTechSupportUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest6_Plan6ConvLog6Tech6' + '@sfa666.test.com';
			testValidateExceptionAsTechSupportUserWrap.param_profileId = techSupportProfileId;
			testValidateExceptionAsTechSupportUserWrap.param_associateId = '';
			testValidateExceptionAsTechSupportUserWrap.param_servicingAgentAssociateId = '';
			testValidateExceptionAsTechSupportUserWrap.param_externalId = '';
			techsupportUser = buildUser(testValidateExceptionAsTechSupportUserWrap);
            insert techsupportUser;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(techsupportUser);
        System.runAs(techsupportUser) {
            Test.startTest();
            List<PlanningConversationLog__c> planConversationLogRecord;
            Map<Id, PlanningConversationLog__c> planningConversationMap;
            try {
                AP_PlanningConversationLogTrigger planConvLog = new AP_PlanningConversationLogTrigger();
                planConvLog.processPlanningConversationLogOnBeforeUpdate(planConversationLogRecord, planningConversationMap);
            } catch(Exception ex) {
                System.assert(!String.isBlank(ex.getMessage()), 'Exception message string should not be blank');
            }
            Test.stopTest();
        }
    }

    //test method to validate deletion of Planning Conversation Log record as an Technical Support User.
    @isTest
    private static void testPlanningConversationLogRecordDeleteAsTechSupport() {
        User agentUser;
        User proxyUser;
        User techSupportUser;
        Account act;
        PlanningConversationUserDataWrapperList testValidateDeletionAsAdminUserWrap = new PlanningConversationUserDataWrapperList();
			testValidateDeletionAsAdminUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Plan1ConvLogDelete1Admn1' + '@sfa111.test.com';
			testValidateDeletionAsAdminUserWrap.param_profileId = adminProfileId;
			testValidateDeletionAsAdminUserWrap.param_associateId = '';
			testValidateDeletionAsAdminUserWrap.param_servicingAgentAssociateId = '';
			testValidateDeletionAsAdminUserWrap.param_externalId = '';
		User adminUser = buildUser(testValidateDeletionAsAdminUserWrap);

        System.runAs(adminUser) {
            byPassTrigger();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            PlanningConversationUserDataWrapperList testValidateDeletionAsAgentUserWrap = new PlanningConversationUserDataWrapperList();
			testValidateDeletionAsAgentUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Plan1ConvLogDelete1Agnt1' + '@sfa111.test.com';
			testValidateDeletionAsAgentUserWrap.param_profileId = agentProfileId;
			testValidateDeletionAsAgentUserWrap.param_associateId = 'kkccww11ttc';
			testValidateDeletionAsAgentUserWrap.param_servicingAgentAssociateId = 'kkccww11ttc';
			testValidateDeletionAsAgentUserWrap.param_externalId = 'kkccww11ttc_kkccww11ttc';
			agentUser = buildUser(testValidateDeletionAsAgentUserWrap);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;

            PlanningConversationUserDataWrapperList testValidateDeletionAsProxyUserWrap = new PlanningConversationUserDataWrapperList();
			testValidateDeletionAsProxyUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Plan1PlanConvLogDelete1Prox1' + '@sfa111.test.com';
			testValidateDeletionAsProxyUserWrap.param_profileId = proxyProfileId;
			testValidateDeletionAsProxyUserWrap.param_associateId = '';
			testValidateDeletionAsProxyUserWrap.param_servicingAgentAssociateId = 'kkccww11ttc';
			testValidateDeletionAsProxyUserWrap.param_externalId = 'kkccww11ttcP';
			proxyUser = buildUser(testValidateDeletionAsProxyUserWrap);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            PlanningConversationUserDataWrapperList testValidateDeletionAsTechSupportUserWrap = new PlanningConversationUserDataWrapperList();
			testValidateDeletionAsTechSupportUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Plan1ConvLogDelete1Tech1' + '@sfa111.test.com';
			testValidateDeletionAsTechSupportUserWrap.param_profileId = techSupportProfileId;
			testValidateDeletionAsTechSupportUserWrap.param_associateId = '';
			testValidateDeletionAsTechSupportUserWrap.param_servicingAgentAssociateId = '';
			testValidateDeletionAsTechSupportUserWrap.param_externalId = '';
			techsupportUser = buildUser(testValidateDeletionAsTechSupportUserWrap);
            insert techSupportUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser,techSupportUser});
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'CoreComponents_User_R');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'CustomerView_Support_ViewAll');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'CustomerView_ApexAura_Enabled');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'SPI_User');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techsupportUser.Id, 'SF_CRM_VirtualMeetingAPTC_PermSetPID');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techsupportUser.Id, 'SimpleConversation_Support_W');

            PlanningConversationUserDataWrapperList testValidateDeletionAsSystemUserWrap = new PlanningConversationUserDataWrapperList();
			testValidateDeletionAsSystemUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Plan1PlanConvLogDelete1Syst1' + '@sfa111.test.com';
			testValidateDeletionAsSystemUserWrap.param_profileId = noAccessProfileId;
			testValidateDeletionAsSystemUserWrap.param_associateId = '';
			testValidateDeletionAsSystemUserWrap.param_servicingAgentAssociateId = '';
			testValidateDeletionAsSystemUserWrap.param_externalId = '';
			User systemUser = buildUser(testValidateDeletionAsSystemUserWrap);
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        	UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        }
        
        System.runAs(agentUser) {
            act = buildAccountRecord('7701011');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;

            CS001_ByPassTriggerAll__c objectBasedByPassTrigger = [Select id from CS001_ByPassTriggerAll__c limit 1];
            objectBasedByPassTrigger.Override_All__c = false;
            update objectBasedByPassTrigger;
        }
        
        System.runAs(techSupportUser) {
            Test.startTest();
            SimpleConversation__c simpleConversationRecord = buildSimpleConversationRecord(act.id, agentUser.id);
            simpleConversationRecord.Agent__c = agentUser.id;
            insert simpleConversationRecord;

            PlanningConversationLog__c planConversationLogRecord = buildPlanningConversationLogRecord(simpleConversationRecord.id, 'Test Comments');
            insert planConversationLogRecord;
            try {
                delete planConversationLogRecord;
            } catch(Exception e) {
                System.assert(e.getMessage().contains(Label.CL_PlanningConversationLogPreventDeleteMsg), 'Exception Message should contain Label.CL_PlanningConversationLogPreventDeleteMsg');
            }
            List<PlanningConversationLog__c> planConverLog = [Select Id from PlanningConversationLog__c limit 1];
            System.assert(!planConverLog.isEmpty(), 'Planning conversation log should not be empty');
            Test.stopTest();
        }
    }

    //test method to verify PlanningConversationLogBeforeDelete trigger on bypass logic - Not to Fire.
    @isTest
    private static void testBypassOnPlanningConversationLogDeleteAsTechSupport() {
        User agentUser;
        User proxyUser;
        User techSupportUser;
        PlanningConversationUserDataWrapperList testVerifyAdminUserWrap = new PlanningConversationUserDataWrapperList();
			testVerifyAdminUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest2_Plan2ConvLogDelete2Admn2' + '@sfa222.test.com';
			testVerifyAdminUserWrap.param_profileId = adminProfileId;
			testVerifyAdminUserWrap.param_associateId = '';
			testVerifyAdminUserWrap.param_servicingAgentAssociateId = '';
			testVerifyAdminUserWrap.param_externalId = '';
		User adminUser = buildUser(testVerifyAdminUserWrap);
        Account act;

        System.runAs(adminUser) {
            byPassTrigger();
            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            PlanningConversationUserDataWrapperList testVerifyAgentUserWrap = new PlanningConversationUserDataWrapperList();
			testVerifyAgentUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest2_Plan2ConvLogDelete2Agnt2' + '@sfa222.test.com';
			testVerifyAgentUserWrap.param_profileId = agentProfileId;
			testVerifyAgentUserWrap.param_associateId = 'kkccww22ttc';
			testVerifyAgentUserWrap.param_servicingAgentAssociateId = 'kkccww22ttc';
			testVerifyAgentUserWrap.param_externalId = 'kkccww22ttc_kkccww22ttc';
			agentUser = buildUser(testVerifyAgentUserWrap);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;

            PlanningConversationUserDataWrapperList testVerifyProxyUserWrap = new PlanningConversationUserDataWrapperList();
			testVerifyProxyUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest2_Plan2ConvLogDelete2Prox2' + '@sfa222.test.com';
			testVerifyProxyUserWrap.param_profileId = proxyProfileId;
			testVerifyProxyUserWrap.param_associateId = '';
			testVerifyProxyUserWrap.param_servicingAgentAssociateId = 'kkccww22ttc';
			testVerifyProxyUserWrap.param_externalId = 'kkccww22ttcP';
			proxyUser = buildUser(testVerifyProxyUserWrap);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            PlanningConversationUserDataWrapperList testVerifyTechSupportUserWrap = new PlanningConversationUserDataWrapperList();
			testVerifyTechSupportUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest2_Plan2ConvLogDelete2Tech2' + '@sfa222.test.com';
			testVerifyTechSupportUserWrap.param_profileId = techSupportProfileId;
			testVerifyTechSupportUserWrap.param_associateId = '';
			testVerifyTechSupportUserWrap.param_servicingAgentAssociateId = '';
			testVerifyTechSupportUserWrap.param_externalId = '';
			techsupportUser = buildUser(testVerifyTechSupportUserWrap);
            insert techSupportUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser,techSupportUser});
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'CoreComponents_User_R');
            //AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'CoreComponents_AllUsers');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'CustomerView_Support_ViewAll');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'CustomerView_ApexAura_Enabled');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'SPI_User');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techsupportUser.Id, 'SF_CRM_VirtualMeetingAPTC_PermSetPID');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techsupportUser.Id, 'SimpleConversation_Support_W');

            PlanningConversationUserDataWrapperList testVerifySystemUserWrap = new PlanningConversationUserDataWrapperList();
			testVerifySystemUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest2_Plan2ConvLogDelete2Syst2' + '@sfa222.test.com';
			testVerifySystemUserWrap.param_profileId = noAccessProfileId;
			testVerifySystemUserWrap.param_associateId = '';
			testVerifySystemUserWrap.param_servicingAgentAssociateId = '';
			testVerifySystemUserWrap.param_externalId = '';
			User systemUser = buildUser(testVerifySystemUserWrap);
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        	UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        }
        
        System.runAs(agentUser) {
            act = buildAccountRecord('7702022');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;
        }
    
        System.runAs(techSupportUser) {
            Test.startTest();
            SimpleConversation__c simpleConversationRecord = buildSimpleConversationRecord(act.id, agentUser.id);
            insert simpleConversationRecord;

            PlanningConversationLog__c planConversationLogRecord = buildPlanningConversationLogRecord(simpleConversationRecord.id, 'Testing Planning Conversation Log Comments');
            insert planConversationLogRecord;

            List<PlanningConversationLog__c> planConverLogBefore = [Select Id from PlanningConversationLog__c limit 1];
            System.assert(!planConverLogBefore.isEmpty(), 'List of Planning conversation log Before should not be empty');

            delete planConversationLogRecord;
            List<PlanningConversationLog__c> planConverLogAfter = [Select Id from PlanningConversationLog__c limit 1];
            System.assert(planConverLogAfter.isEmpty(), 'List of Planning conversation log After should be empty');
            Test.stopTest();
        }
    }
}