/**
* Author : Golden Spikes Team
* Date Created : 07/06/2018
* @description Test class for the AP_SimpleConversationTrigger apex class.
*/
@isTest (seeAllData=false)
public class AP_SimpleConversationTrigger_TEST {

    private static String agentProfileId = getProfileId(UTIL_Constants.AGENT_PROFILE_NAME);
    private static String proxyProfileId = getProfileId(UTIL_Constants.PROXY_PROFILE_NAME);
    private static String adminProfileId = getProfileId(UTIL_Constants.SYSTEM_ADMIN_PROFILE_NAME);
    private static String techSupportProfileId = getProfileId(UTIL_Constants.TECHNICAL_SUPPORT_PROFILE_NAME);
    private static String planningServicesProfileId = getProfileId('5.03 Investment Planning Services - Create');
    private static String holdingCodeProfileId = getProfileId(UTIL_Constants.HOLDINGCODE_PROFILE_NAME);
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
    private static User buildUser(APSimpleConversationUserWrapperList parameterValueWrapper) {
        String param_UserName = parameterValueWrapper.param_UserName;
        String param_profileId = parameterValueWrapper.param_profileId;
        String param_associateId = parameterValueWrapper.param_associateId;
        String param_servicingAgentAssociateId = parameterValueWrapper.param_servicingAgentAssociateId;
        String param_externalId = parameterValueWrapper.param_externalId;
        return new User (alias = '12345', email = 'testUser@statefarm.com.bad', emailencodingkey='UTF-8', lastname='TestUserLastName',
            languagelocalekey='en_US',localesidkey='en_US', timezonesidkey='America/Chicago',
            username= param_UserName, profileId = param_profileId,
            Associate_ID__c = param_associateId, Servicing_Agent_Associate_ID__c = param_servicingAgentAssociateId,
            UserExternalID__c = param_externalId
        );
         
    }

    private class APSimpleConversationUserWrapperList{
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
                            Status__c = 'New', ConductedBy__c = param_conductedBy, SimpleConversationName__c = 'Test Simple Conv', SimpleConversationType__c = 'Simple Conversation', Appointment_Location__c='Virtual Meeting',
                            AppointmentStartDateTime__c = datetime.now().addHours(1), AppointmentEndDateTime__c = datetime.now().addHours(2));
        
    }

     //method to build Virtual Meeting record with the given parameter value
    private static Virtual_Meeting__c buildVirtualMeetingRecord(String param_assignedBy, String param_SimpleConversation) {
        return new Virtual_Meeting__c ( Assigned_To__c = param_assignedBy,Start_Time__c = datetime.now().addHours(1),End_Time__c = datetime.now().addHours(2),Name='Simple Conversation', Simple_Conversation__c = param_SimpleConversation);
         
    }


    //test method to insert simple Conversation record as an Agent.
    @isTest
    private static void testSimpleConversationRecordInsertAsAgent() {
        User agentUser;
        User proxyUser;
        APSimpleConversationUserWrapperList testInsertRecordAsAdminUserWrap = new APSimpleConversationUserWrapperList();
			testInsertRecordAsAdminUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvInsert1Admn1' + '@sfa111.test.com';
			testInsertRecordAsAdminUserWrap.param_profileId = adminProfileId;
			testInsertRecordAsAdminUserWrap.param_associateId = '';
			testInsertRecordAsAdminUserWrap.param_servicingAgentAssociateId = '';
			testInsertRecordAsAdminUserWrap.param_externalId = '';
		User adminUser = buildUser(testInsertRecordAsAdminUserWrap);

        System.runAs(adminUser) {
            byPassTrigger();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            APSimpleConversationUserWrapperList testInsertRecordAsAgentUserWrap = new APSimpleConversationUserWrapperList();
			testInsertRecordAsAgentUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvInsert1Agnt1' + '@sfa111.test.com';
			testInsertRecordAsAgentUserWrap.param_profileId = agentProfileId;
			testInsertRecordAsAgentUserWrap.param_associateId = 'ppccpp11ttc';
			testInsertRecordAsAgentUserWrap.param_servicingAgentAssociateId = 'ppccpp11ttc';
			testInsertRecordAsAgentUserWrap.param_externalId = 'ppccpp11ttc_ppccpp11ttc';
			agentUser = buildUser(testInsertRecordAsAgentUserWrap);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
             AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(agentUser.Id, 'SF_CRM_VirtualMeetingAPTC_PermSetPID');

            APSimpleConversationUserWrapperList testInsertRecordAsProxytUserWrap = new APSimpleConversationUserWrapperList();
			testInsertRecordAsProxytUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvInsert1Prox1' + '@sfa111.test.com';
			testInsertRecordAsProxytUserWrap.param_profileId = proxyProfileId;
			testInsertRecordAsProxytUserWrap.param_associateId = '';
			testInsertRecordAsProxytUserWrap.param_servicingAgentAssociateId = 'ppccpp11ttc';
			testInsertRecordAsProxytUserWrap.param_externalId = 'ppccpp11ttcP';
			proxyUser = buildUser(testInsertRecordAsProxytUserWrap);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            APSimpleConversationUserWrapperList testInsertRecordAsSystemUserWrap = new APSimpleConversationUserWrapperList();
			testInsertRecordAsSystemUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvInsert1Syst1' + '@sfa111.test.com';
			testInsertRecordAsSystemUserWrap.param_profileId = noAccessProfileId;
			testInsertRecordAsSystemUserWrap.param_associateId = '';
			testInsertRecordAsSystemUserWrap.param_servicingAgentAssociateId = '';
			testInsertRecordAsSystemUserWrap.param_externalId = '';
			User systemUser = buildUser(testInsertRecordAsSystemUserWrap);
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

            UTIL_GoodNeighborConnect.VirtualMeetingAttributes attr = new  UTIL_GoodNeighborConnect.VirtualMeetingAttributes();
           attr.meetingHost = simpleConversationRecord.ConductedBy__c;
           attr.meetingPurpose = simpleConversationRecord.SimpleConversationName__c;
           attr.startDateTime = simpleConversationRecord.AppointmentStartDateTime__c;
           attr.endDateTime = simpleConversationRecord.AppointmentEndDateTime__c;
            UTIL_GoodNeighborConnect.createVirtualMeeting(attr,simpleConversationRecord.id);
            //  Virtual_Meeting__c virtMeetingRecord;
            	//virtMeetingRecord.Id=simpleConversationRecord.Id;
                //virtMeetingRecord.Assigned_To__c = simpleConversationRecord.ConductedBy__c;
                //virtMeetingRecord.start_time__c = simpleConversationRecord.AppointmentStartDateTime__c;
                //virtMeetingRecord.end_time__c = simpleConversationRecord.AppointmentEndDateTime__c;
                //virtMeetingRecord.Name = simpleConversationRecord.SimpleConversationName__c;
          //  insert virtMeetingRecord;
            List<SimpleConversation__c> simpleConverLog = [Select Id, Agent__c, OwnerId from SimpleConversation__c limit 1];
            System.assert(!simpleConverLog.isEmpty(), 'Simple conversatoin log should not be empty');
            //System.assertEquals(agentUser.id, simpleConverLog[0].Agent__c);
            //System.assertEquals(proxyUser.id, simpleConverLog[0].OwnerId);

        }
    }

    //test method to insert Simple Conversation record as an "5.03 Investment Planning Services - Create" User.
    @isTest
    private static void testSimpleConversationRecordInsertAsInvestmentPlanningServicesUser() {
        User agentUser1;
        User proxyUser1;
        User agentUser2;
        User proxyUser2;
        User planningServicesUser;
        Account act;
        APSimpleConversationUserWrapperList insertAsInvestmentPlanningServicesAdminUserWrap = new APSimpleConversationUserWrapperList();
			insertAsInvestmentPlanningServicesAdminUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest2_Simple2ConvInsert2Admn2' + '@sfa222.test.com';
			insertAsInvestmentPlanningServicesAdminUserWrap.param_profileId = adminProfileId;
			insertAsInvestmentPlanningServicesAdminUserWrap.param_associateId = '';
			insertAsInvestmentPlanningServicesAdminUserWrap.param_servicingAgentAssociateId = '';
			insertAsInvestmentPlanningServicesAdminUserWrap.param_externalId = '';
		User adminUser = buildUser(insertAsInvestmentPlanningServicesAdminUserWrap);

        System.runAs(adminUser) {
            byPassTrigger();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            APSimpleConversationUserWrapperList insertAsInvestmentPlanningServicesAgentUser1Wrap = new APSimpleConversationUserWrapperList();
			insertAsInvestmentPlanningServicesAgentUser1Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest2_Simple2ConvInsert2Agnt21' + '@sfa222.test.com';
			insertAsInvestmentPlanningServicesAgentUser1Wrap.param_profileId = agentProfileId;
			insertAsInvestmentPlanningServicesAgentUser1Wrap.param_associateId = 'ppccpp22ttc';
			insertAsInvestmentPlanningServicesAgentUser1Wrap.param_servicingAgentAssociateId = 'ppccpp22ttc';
			insertAsInvestmentPlanningServicesAgentUser1Wrap.param_externalId = 'ppccpp22ttc_ppccpp22ttc';
			agentUser1 = buildUser(insertAsInvestmentPlanningServicesAgentUser1Wrap);
            agentUser1.userRoleId = agentUserRole.id;
            insert agentUser1;

            APSimpleConversationUserWrapperList insertAsInvestmentPlanningServicesProxyUser1Wrap = new APSimpleConversationUserWrapperList();
			insertAsInvestmentPlanningServicesProxyUser1Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest2_Simple2ConvInsert2Prox21' + '@sfa222.test.com';
			insertAsInvestmentPlanningServicesProxyUser1Wrap.param_profileId = proxyProfileId;
			insertAsInvestmentPlanningServicesProxyUser1Wrap.param_associateId = '';
			insertAsInvestmentPlanningServicesProxyUser1Wrap.param_servicingAgentAssociateId = 'ppccpp22ttc';
			insertAsInvestmentPlanningServicesProxyUser1Wrap.param_externalId = 'ppccpp22ttcP';
			proxyUser1 = buildUser(insertAsInvestmentPlanningServicesProxyUser1Wrap);
            proxyUser1.userRoleId = proxyUserRole.id;
            insert proxyUser1;

            APSimpleConversationUserWrapperList insertAsInvestmentPlanningServicesAgentUser2Wrap = new APSimpleConversationUserWrapperList();
			insertAsInvestmentPlanningServicesAgentUser2Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest2_Simple2ConvInsert2Agnt22' + '@sfa222.test.com';
			insertAsInvestmentPlanningServicesAgentUser2Wrap.param_profileId = agentProfileId;
			insertAsInvestmentPlanningServicesAgentUser2Wrap.param_associateId = 'kkccpp22ttc';
			insertAsInvestmentPlanningServicesAgentUser2Wrap.param_servicingAgentAssociateId = 'kkccpp22ttc';
			insertAsInvestmentPlanningServicesAgentUser2Wrap.param_externalId = 'kkccpp22ttc_kkccpp22ttc';
			agentUser2 = buildUser(insertAsInvestmentPlanningServicesAgentUser2Wrap);
            agentUser2.userRoleId = agentUserRole.id;
            insert agentUser2;

            APSimpleConversationUserWrapperList insertAsInvestmentPlanningServicesProxyUser2Wrap = new APSimpleConversationUserWrapperList();
			insertAsInvestmentPlanningServicesProxyUser2Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest2_Simple2ConvInsert2Prox22' + '@sfa222.test.com';
			insertAsInvestmentPlanningServicesProxyUser2Wrap.param_profileId = proxyProfileId;
			insertAsInvestmentPlanningServicesProxyUser2Wrap.param_associateId = '';
			insertAsInvestmentPlanningServicesProxyUser2Wrap.param_servicingAgentAssociateId = 'kkccpp22ttc';
			insertAsInvestmentPlanningServicesProxyUser2Wrap.param_externalId = 'kkccpp22ttcP';
			proxyUser2 = buildUser(insertAsInvestmentPlanningServicesProxyUser2Wrap);
            proxyUser2.userRoleId = proxyUserRole.id;
            insert proxyUser2;

            APSimpleConversationUserWrapperList insertAsInvestmentPlanningServicesUserWrap = new APSimpleConversationUserWrapperList();
			insertAsInvestmentPlanningServicesUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest2_Simple2ConvInsert2Prox2' + '@sfa222.test.com';
			insertAsInvestmentPlanningServicesUserWrap.param_profileId = planningServicesProfileId;
			insertAsInvestmentPlanningServicesUserWrap.param_associateId = '';
			insertAsInvestmentPlanningServicesUserWrap.param_servicingAgentAssociateId = '';
			insertAsInvestmentPlanningServicesUserWrap.param_externalId = '';
			planningServicesUser = buildUser(insertAsInvestmentPlanningServicesUserWrap);
            insert planningServicesUser;

            APSimpleConversationUserWrapperList insertAsInvestmentPlanningServicesSystemUserWrap = new APSimpleConversationUserWrapperList();
			insertAsInvestmentPlanningServicesSystemUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest2_Simple2ConvInsert2Syst2' + '@sfa222.test.com';
			insertAsInvestmentPlanningServicesSystemUserWrap.param_profileId = noAccessProfileId;
			insertAsInvestmentPlanningServicesSystemUserWrap.param_associateId = '';
			insertAsInvestmentPlanningServicesSystemUserWrap.param_servicingAgentAssociateId = '';
			insertAsInvestmentPlanningServicesSystemUserWrap.param_externalId = '';
			User systemUser = buildUser(insertAsInvestmentPlanningServicesSystemUserWrap);
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser1,planningServicesUser});
        System.runAs(agentUser1) {
            act = buildAccountRecord('7702022');
            insert act;

            AgentRole__c agentRole1 = buildAgentRoleRecord(act.id);
            insert agentRole1;

            AgentRole__c agentRole2 = buildAgentRoleRecord(act.id);
            agentRole2.Agent__c = agentUser2.id;
            insert agentRole2;
            //added explicit share to Service user to get around salesforce limitation on Sharing rules in Apex.
            insert new accountshare(accountid=act.id,userorgroupid=planningservicesUser.id,AccountAccessLevel='Read',OpportunityAccessLevel='None',CaseAccessLevel='None',rowcause='manual');
        }

        System.runAs(planningServicesUser) {
            Test.startTest();
            SimpleConversation__c simpleConversationRecord = buildSimpleConversationRecord(act.id, planningServicesUser.id);
            simpleConversationRecord.Agent__c = agentUser1.id;
            insert simpleConversationRecord;

            List<SimpleConversation__c> simpleConverLog = [Select Id, Agent__c, ConductedBy__c, OwnerId from SimpleConversation__c limit 1];
            System.assert(!simpleConverLog.isEmpty(), 'Simple conversation log should not be empty');
            System.assertEquals(agentUser1.id, simpleConverLog[0].Agent__c, 'Agent object contains agent user1 Id');
            //System.assertEquals(proxyUser1.id, simpleConverLog[0].OwnerId);
            System.assertEquals(planningServicesUser.id, simpleConverLog[0].ConductedBy__c, 'conducted by object have the planning services user Id');
            Test.stopTest();
        }
    }

    //test method to validate Simple Conversation record while Agent selection as Planning services User.
    @isTest
    private static void testSimpleConversationRecordInsertWhileAgentSelectionAsPlanningServicesUser() {
        User agentUser1;
        User agentUser2;
        User proxyUser1;
        User proxyUser2;
        User planningServicesUser;
        Account act;
        APSimpleConversationUserWrapperList insertWhileAgentSelectionAsPlanningServicesAdminUserWrap = new APSimpleConversationUserWrapperList();
			insertWhileAgentSelectionAsPlanningServicesAdminUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest3_Simple3ConvInsert3Admn3' + '@sfa333.test.com';
			insertWhileAgentSelectionAsPlanningServicesAdminUserWrap.param_profileId = adminProfileId;
			insertWhileAgentSelectionAsPlanningServicesAdminUserWrap.param_associateId = '';
			insertWhileAgentSelectionAsPlanningServicesAdminUserWrap.param_servicingAgentAssociateId = '';
			insertWhileAgentSelectionAsPlanningServicesAdminUserWrap.param_externalId = '';
		User adminUser = buildUser(insertWhileAgentSelectionAsPlanningServicesAdminUserWrap);

        System.runAs(adminUser) {
            byPassTrigger();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            APSimpleConversationUserWrapperList insertWhileAgentSelectionAsPlanningServicesAgentUser1Wrap = new APSimpleConversationUserWrapperList();
			insertWhileAgentSelectionAsPlanningServicesAgentUser1Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest3_Simple3ConvInsert3Agnt13' + '@sfa333.test.com';
			insertWhileAgentSelectionAsPlanningServicesAgentUser1Wrap.param_profileId = agentProfileId;
			insertWhileAgentSelectionAsPlanningServicesAgentUser1Wrap.param_associateId = 'ppccpp33ttc';
			insertWhileAgentSelectionAsPlanningServicesAgentUser1Wrap.param_servicingAgentAssociateId = 'ppccpp33ttc';
			insertWhileAgentSelectionAsPlanningServicesAgentUser1Wrap.param_externalId = 'ppccpp33ttc_ppccpp33ttc';
			agentUser1 = buildUser(insertWhileAgentSelectionAsPlanningServicesAgentUser1Wrap);
            agentUser1.userRoleId = agentUserRole.id;
            insert agentUser1;

            APSimpleConversationUserWrapperList insertWhileAgentSelectionAsPlanningServicesAgentUser2Wrap = new APSimpleConversationUserWrapperList();
			insertWhileAgentSelectionAsPlanningServicesAgentUser2Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest3_Simple3ConvInsert3Agnt23' + '@sfa333.test.com';
			insertWhileAgentSelectionAsPlanningServicesAgentUser2Wrap.param_profileId = agentProfileId;
			insertWhileAgentSelectionAsPlanningServicesAgentUser2Wrap.param_associateId = 'kkccpp33ttc';
			insertWhileAgentSelectionAsPlanningServicesAgentUser2Wrap.param_servicingAgentAssociateId = 'kkccpp33ttc';
			insertWhileAgentSelectionAsPlanningServicesAgentUser2Wrap.param_externalId = 'kkccpp33ttc_kkccpp33ttc';
			agentUser2 = buildUser(insertWhileAgentSelectionAsPlanningServicesAgentUser2Wrap);
            agentUser2.userRoleId = agentUserRole.id;
            insert agentUser2;

            APSimpleConversationUserWrapperList insertWhileAgentSelectionAsPlanningServicesProxyUser1Wrap = new APSimpleConversationUserWrapperList();
			insertWhileAgentSelectionAsPlanningServicesProxyUser1Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest3_Simple3ConvInsert3Prox3' + '@sfa333.test.com';
			insertWhileAgentSelectionAsPlanningServicesProxyUser1Wrap.param_profileId = proxyProfileId;
			insertWhileAgentSelectionAsPlanningServicesProxyUser1Wrap.param_associateId = '';
			insertWhileAgentSelectionAsPlanningServicesProxyUser1Wrap.param_servicingAgentAssociateId = 'ppccpp33ttc';
			insertWhileAgentSelectionAsPlanningServicesProxyUser1Wrap.param_externalId = 'ppccpp33ttcP';
			proxyUser1 = buildUser(insertWhileAgentSelectionAsPlanningServicesProxyUser1Wrap);
            proxyUser1.userRoleId = proxyUserRole.id;
            insert proxyUser1;

            APSimpleConversationUserWrapperList insertWhileAgentSelectionAsPlanningServicesProxyUser2Wrap = new APSimpleConversationUserWrapperList();
			insertWhileAgentSelectionAsPlanningServicesProxyUser2Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest3_Simple3ConvInsert3Prox3' + '@sfa333.test.com';
			insertWhileAgentSelectionAsPlanningServicesProxyUser2Wrap.param_profileId = proxyProfileId;
			insertWhileAgentSelectionAsPlanningServicesProxyUser2Wrap.param_associateId = '';
			insertWhileAgentSelectionAsPlanningServicesProxyUser2Wrap.param_servicingAgentAssociateId = 'kkccpp33ttc';
			insertWhileAgentSelectionAsPlanningServicesProxyUser2Wrap.param_externalId = 'kkccpp33ttcP';
			proxyUser2 = buildUser(insertWhileAgentSelectionAsPlanningServicesProxyUser2Wrap);
            proxyUser2.userRoleId = proxyUserRole.id;
            insert proxyUser2;

            APSimpleConversationUserWrapperList insertWhileAgentSelectionAsPlanningServicesWrap = new APSimpleConversationUserWrapperList();
			insertWhileAgentSelectionAsPlanningServicesWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest3_Simple3ConvInsert3Tech3' + '@sfa333.test.com';
			insertWhileAgentSelectionAsPlanningServicesWrap.param_profileId = planningServicesProfileId;
			insertWhileAgentSelectionAsPlanningServicesWrap.param_associateId = '';
			insertWhileAgentSelectionAsPlanningServicesWrap.param_servicingAgentAssociateId = '';
			insertWhileAgentSelectionAsPlanningServicesWrap.param_externalId = '';
			planningServicesUser = buildUser(insertWhileAgentSelectionAsPlanningServicesWrap);
            insert planningServicesUser;

            APSimpleConversationUserWrapperList insertWhileAgentSelectionAsPlanningServicesSystemUserWrap = new APSimpleConversationUserWrapperList();
			insertWhileAgentSelectionAsPlanningServicesSystemUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest3_Simple3ConvInsert3Syst3' + '@sfa333.test.com';
			insertWhileAgentSelectionAsPlanningServicesSystemUserWrap.param_profileId = noAccessProfileId;
			insertWhileAgentSelectionAsPlanningServicesSystemUserWrap.param_associateId = '';
			insertWhileAgentSelectionAsPlanningServicesSystemUserWrap.param_servicingAgentAssociateId = '';
			insertWhileAgentSelectionAsPlanningServicesSystemUserWrap.param_externalId = '';
			User systemUser = buildUser(insertWhileAgentSelectionAsPlanningServicesSystemUserWrap);
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser1,planningServicesUser});
        System.runAs(agentUser1) {
            act = buildAccountRecord('7703033');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;

            CS001_ByPassTriggerAll__c objectBasedByPassTrigger = [Select id from CS001_ByPassTriggerAll__c limit 1];
            objectBasedByPassTrigger.Override_All__c = false;
            update objectBasedByPassTrigger;
        }

        System.runAs(planningServicesUser) {
            Test.startTest();
            try {
                SimpleConversation__c simpleConversationRecord = buildSimpleConversationRecord(act.id, planningServicesUser.id);
                simpleConversationRecord.Agent__c = agentUser2.id;
                insert simpleConversationRecord;
            } catch(Exception e) {
                System.assert(e.getMessage().contains(Label.CL_AGENT_NOT_FOUND_IN_BOOK_OF_BUSINESS), 'Exception message contains from Label.CL_AGENT_NOT_FOUND_IN_BOOK_OF_BUSINESS');
            }
            List<SimpleConversation__c> simpleConverLog = [Select Id from SimpleConversation__c limit 1];
            System.assert(simpleConverLog.isEmpty(), 'Simple conversation log is empty');
            Test.stopTest();
        }
    }

    //test method to validate Simple Conversation record for invalid Agent proxy office.
    @isTest
    private static void testSimpleConversationRecordInsertForInvalidOfficeAsAgent() {
        User agentUser;
        User proxyUser;
        Account act;
        APSimpleConversationUserWrapperList insertForInvalidOfficeAsAdminUserWrap = new APSimpleConversationUserWrapperList();
			insertForInvalidOfficeAsAdminUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest4_Simple4ConvInsert4Admn4' + '@sfa444.test.com';
			insertForInvalidOfficeAsAdminUserWrap.param_profileId = adminProfileId;
			insertForInvalidOfficeAsAdminUserWrap.param_associateId = '';
			insertForInvalidOfficeAsAdminUserWrap.param_servicingAgentAssociateId = '';
			insertForInvalidOfficeAsAdminUserWrap.param_externalId = '';
		User adminUser = buildUser(insertForInvalidOfficeAsAdminUserWrap);

        System.runAs(adminUser) {
            byPassTrigger();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            APSimpleConversationUserWrapperList insertForInvalidOfficeAsAgentUserWrap = new APSimpleConversationUserWrapperList();
			insertForInvalidOfficeAsAgentUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest4_Simple4ConvInsert4Agnt4' + '@sfa444.test.com';
			insertForInvalidOfficeAsAgentUserWrap.param_profileId = agentProfileId;
			insertForInvalidOfficeAsAgentUserWrap.param_associateId = 'ppccpp44ttc';
			insertForInvalidOfficeAsAgentUserWrap.param_servicingAgentAssociateId = 'ppccpp44ttc';
			insertForInvalidOfficeAsAgentUserWrap.param_externalId = 'ppccpp44ttc_ppccpp44ttc';
			agentUser = buildUser(insertForInvalidOfficeAsAgentUserWrap);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;

            APSimpleConversationUserWrapperList insertForInvalidOfficeAsProxyUserWrap = new APSimpleConversationUserWrapperList();
			insertForInvalidOfficeAsProxyUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest4_Simple4ConvInsert4Prox4' + '@sfa444.test.com';
			insertForInvalidOfficeAsProxyUserWrap.param_profileId = proxyProfileId;
			insertForInvalidOfficeAsProxyUserWrap.param_associateId = '';
			insertForInvalidOfficeAsProxyUserWrap.param_servicingAgentAssociateId = '';
			insertForInvalidOfficeAsProxyUserWrap.param_externalId = '';
			proxyUser = buildUser(insertForInvalidOfficeAsProxyUserWrap);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            APSimpleConversationUserWrapperList insertForInvalidOfficeAsSystemUserWrap = new APSimpleConversationUserWrapperList();
			insertForInvalidOfficeAsSystemUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest4_Simple4ConvInsert4Syst4' + '@sfa444.test.com';
			insertForInvalidOfficeAsSystemUserWrap.param_profileId = noAccessProfileId;
			insertForInvalidOfficeAsSystemUserWrap.param_associateId = '';
			insertForInvalidOfficeAsSystemUserWrap.param_servicingAgentAssociateId = '';
			insertForInvalidOfficeAsSystemUserWrap.param_externalId = '';
			User systemUser = buildUser(insertForInvalidOfficeAsSystemUserWrap);
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            act = buildAccountRecord('7704044');
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
            } catch(Exception e) {
                System.assert(e.getMessage().contains(Label.CL_PROXY_NOT_FOUND), 'Exception message contains from Label.CL_PROXY_NOT_FOUND');
            }
            List<SimpleConversation__c> simpleConverLog = [Select Id from SimpleConversation__c limit 1];
            System.assert(simpleConverLog.isEmpty(), 'simple conversation log is empty');
            Test.stopTest();
        }
    }

    //test method to Validate Simple Conversation record insert upon Holding Code selection as Planning Services User.
    @isTest
    private static void testSimpleConversationRecordInsertWhileHoldingCodeSelectionAsPlanningServicesUser() {
        User holdingCodeUser;
        User agentUser;
        User proxyUser1;
        User proxyUser2;
        User planningServicesUser;
        APSimpleConversationUserWrapperList insertWhileHoldingCodeSelectionAsAdminUserWrap = new APSimpleConversationUserWrapperList();
			insertWhileHoldingCodeSelectionAsAdminUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest5_Simple5ConvInsert5Admn5' + '@sfa555.test.com';
			insertWhileHoldingCodeSelectionAsAdminUserWrap.param_profileId = adminProfileId;
			insertWhileHoldingCodeSelectionAsAdminUserWrap.param_associateId = '';
			insertWhileHoldingCodeSelectionAsAdminUserWrap.param_servicingAgentAssociateId = '';
			insertWhileHoldingCodeSelectionAsAdminUserWrap.param_externalId = '';
		User adminUser = buildUser(insertWhileHoldingCodeSelectionAsAdminUserWrap);
        Account act;

        System.runAs(adminUser) {
            byPassTrigger();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            APSimpleConversationUserWrapperList insertWhileHoldingCodeUserWrap = new APSimpleConversationUserWrapperList();
			insertWhileHoldingCodeUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest5_Simple5ConvInsert5Hold5' + '@sfa555.test.com';
			insertWhileHoldingCodeUserWrap.param_profileId = holdingCodeProfileId;
			insertWhileHoldingCodeUserWrap.param_associateId = 'kkppww55ttc';
			insertWhileHoldingCodeUserWrap.param_servicingAgentAssociateId = 'kkppww55ttc';
			insertWhileHoldingCodeUserWrap.param_externalId = 'kkppww55ttc_kkppww55ttc';
			holdingCodeUser = buildUser(insertWhileHoldingCodeUserWrap);
            holdingCodeUser.userRoleId = agentUserRole.id;
            insert holdingCodeUser;

            APSimpleConversationUserWrapperList insertWhileHoldingCodeSelectionAsAgentUserWrap = new APSimpleConversationUserWrapperList();
			insertWhileHoldingCodeSelectionAsAgentUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest5_Simple5ConvInsert5Agnt5' + '@sfa555.test.com';
			insertWhileHoldingCodeSelectionAsAgentUserWrap.param_profileId = agentProfileId;
			insertWhileHoldingCodeSelectionAsAgentUserWrap.param_associateId = 'ppccpp55ttc';
			insertWhileHoldingCodeSelectionAsAgentUserWrap.param_servicingAgentAssociateId = 'ppccpp55ttc';
			insertWhileHoldingCodeSelectionAsAgentUserWrap.param_externalId = 'ppccpp55ttc_ppccpp55ttc';
			agentUser = buildUser(insertWhileHoldingCodeSelectionAsAgentUserWrap);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;

            APSimpleConversationUserWrapperList insertWhileHoldingCodeSelectionAsProxyUser1Wrap = new APSimpleConversationUserWrapperList();
			insertWhileHoldingCodeSelectionAsProxyUser1Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest5_Simple5ConvInsert5Prox15' + '@sfa555.test.com';
			insertWhileHoldingCodeSelectionAsProxyUser1Wrap.param_profileId = proxyProfileId;
			insertWhileHoldingCodeSelectionAsProxyUser1Wrap.param_associateId = '';
			insertWhileHoldingCodeSelectionAsProxyUser1Wrap.param_servicingAgentAssociateId = 'ppccpp55ttc';
			insertWhileHoldingCodeSelectionAsProxyUser1Wrap.param_externalId = 'ppccpp55ttcP';
			proxyUser1 = buildUser(insertWhileHoldingCodeSelectionAsProxyUser1Wrap);
            proxyUser1.userRoleId = proxyUserRole.id;
            insert proxyUser1;

            APSimpleConversationUserWrapperList insertWhileHoldingCodeSelectionAsProxyUser2Wrap = new APSimpleConversationUserWrapperList();
			insertWhileHoldingCodeSelectionAsProxyUser2Wrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest5_Simple5ConvInsert5Prox25' + '@sfa555.test.com';
			insertWhileHoldingCodeSelectionAsProxyUser2Wrap.param_profileId = proxyProfileId;
			insertWhileHoldingCodeSelectionAsProxyUser2Wrap.param_associateId = '';
			insertWhileHoldingCodeSelectionAsProxyUser2Wrap.param_servicingAgentAssociateId = 'kkppww55ttc';
			insertWhileHoldingCodeSelectionAsProxyUser2Wrap.param_externalId = 'kkppww55ttcP';
			proxyUser2 = buildUser(insertWhileHoldingCodeSelectionAsProxyUser2Wrap);
            proxyUser2.userRoleId = proxyUserRole.id;
            insert proxyUser2;

            APSimpleConversationUserWrapperList insertWhileHoldingCodeSelectionAsPlanningServicesUserWrap = new APSimpleConversationUserWrapperList();
			insertWhileHoldingCodeSelectionAsPlanningServicesUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest5_Simple5ConvInsert5Plan5' + '@sfa555.test.com';
			insertWhileHoldingCodeSelectionAsPlanningServicesUserWrap.param_profileId = planningServicesProfileId;
			insertWhileHoldingCodeSelectionAsPlanningServicesUserWrap.param_associateId = '';
			insertWhileHoldingCodeSelectionAsPlanningServicesUserWrap.param_servicingAgentAssociateId = '';
			insertWhileHoldingCodeSelectionAsPlanningServicesUserWrap.param_externalId = '';
			planningServicesUser = buildUser(insertWhileHoldingCodeSelectionAsPlanningServicesUserWrap);
            insert planningServicesUser;

            APSimpleConversationUserWrapperList insertWhileHoldingCodeSelectionAsSystemUserWrap = new APSimpleConversationUserWrapperList();
			insertWhileHoldingCodeSelectionAsSystemUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest5_Simple5ConvInsert5Syst5' + '@sfa555.test.com';
			insertWhileHoldingCodeSelectionAsSystemUserWrap.param_profileId = noAccessProfileId;
			insertWhileHoldingCodeSelectionAsSystemUserWrap.param_associateId = '';
			insertWhileHoldingCodeSelectionAsSystemUserWrap.param_servicingAgentAssociateId = '';
			insertWhileHoldingCodeSelectionAsSystemUserWrap.param_externalId = '';
			User systemUser = buildUser(insertWhileHoldingCodeSelectionAsSystemUserWrap);
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser,planningServicesUser});
        System.runAs(agentUser) {
            act = buildAccountRecord('8705055');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            agentRole.Agent__c = holdingCodeUser.id;
            insert agentRole;
            //added explicit share to Service user to get around salesforce limitation on Sharing rules in Apex.
            insert new accountshare(accountid=act.id,userorgroupid=planningservicesUser.id,AccountAccessLevel='Read',OpportunityAccessLevel='None',CaseAccessLevel='None',rowcause='manual');
        }

        System.runAs(planningServicesUser) {
            Test.startTest();
            SimpleConversation__c simpleConversationRecordToInsert = buildSimpleConversationRecord(act.id, planningServicesUser.id);
            simpleConversationRecordToInsert.Agent__c = holdingCodeUser.id;
            insert simpleConversationRecordToInsert;

            List<SimpleConversation__c> simpleConverLog = [Select Id, Agent__c, OwnerId from SimpleConversation__c limit 1];
            System.assert(!simpleConverLog.isEmpty(), 'simple conversation log should not be empty');
            System.assertEquals(holdingCodeUser.id, simpleConverLog[0].Agent__c, 'agent object contains holding code user Id');
            //System.assertEquals(proxyUser2.id, simpleConverLog[0].OwnerId);
            Test.stopTest();
        }
    }

    //test method to validate Exception on Simple Conversation record insert as a Technical Support User.
    @isTest
    private static void testExceptionOnSimpleConversationRecordInsertAsTechnicalSupportUser() {
        User techsupportUser;
        APSimpleConversationUserWrapperList insertRecordAsTechnicalSupportAdminUserWrap = new APSimpleConversationUserWrapperList();
			insertRecordAsTechnicalSupportAdminUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest6_Simple6ConvInsert6Admn6' + '@sfa666.test.com';
			insertRecordAsTechnicalSupportAdminUserWrap.param_profileId = adminProfileId;
			insertRecordAsTechnicalSupportAdminUserWrap.param_associateId = '';
			insertRecordAsTechnicalSupportAdminUserWrap.param_servicingAgentAssociateId = '';
			insertRecordAsTechnicalSupportAdminUserWrap.param_externalId = '';
		User adminUser = buildUser(insertRecordAsTechnicalSupportAdminUserWrap);

        System.runAs(adminUser) {
            byPassTrigger();

            APSimpleConversationUserWrapperList insertRecordAsTechSupporUserWrap = new APSimpleConversationUserWrapperList();
			insertRecordAsTechSupporUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest6_Simple6ConvInsert6Prox6' + '@sfa666.test.com';
			insertRecordAsTechSupporUserWrap.param_profileId = techSupportProfileId;
			insertRecordAsTechSupporUserWrap.param_associateId = '';
			insertRecordAsTechSupporUserWrap.param_servicingAgentAssociateId = '';
			insertRecordAsTechSupporUserWrap.param_externalId = '';
			techsupportUser = buildUser(insertRecordAsTechSupporUserWrap);
            insert techsupportUser;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(techsupportUser);
        System.runAs(techsupportUser) {
            Test.startTest();
            List<SimpleConversation__c> simpleConversationRecord;
            try {
                AP_SimpleConversationTrigger simpleConvLog = new AP_SimpleConversationTrigger();
                simpleConvLog.processSimpleConversationOnBeforeInsert(simpleConversationRecord);
            } catch(Exception ex) {
                System.assert(!String.isBlank(ex.getMessage()), 'Exception message should not be Empty string');
            }
            List<SimpleConversation__c> simpleConverLog = [Select Id from SimpleConversation__c limit 1];
            System.assert(simpleConverLog.isEmpty(), 'simple conversation log is empty');
            Test.stopTest();
        }
    }

    //test method to verify SimpleConversationBeforeInsert trigger on bypass logic - Not to Fire.
    @isTest
    private static void testBypassProxyUpdateOnSimpleConversationLogInsertAsAgent() {
        User agentUser;
        User proxyUser;
        APSimpleConversationUserWrapperList proxyUpdateLogInsertAsAdminUserWrap = new APSimpleConversationUserWrapperList();
			proxyUpdateLogInsertAsAdminUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest7_Simple7ConvInsert7Admn7' + '@sfa777.test.com';
			proxyUpdateLogInsertAsAdminUserWrap.param_profileId = adminProfileId;
			proxyUpdateLogInsertAsAdminUserWrap.param_associateId = '';
			proxyUpdateLogInsertAsAdminUserWrap.param_servicingAgentAssociateId = '';
			proxyUpdateLogInsertAsAdminUserWrap.param_externalId = '';
		User adminUser = buildUser(proxyUpdateLogInsertAsAdminUserWrap);

        System.runAs(adminUser) {
            byPassTrigger();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;
            APSimpleConversationUserWrapperList proxyUpdateLogInsertAsAgentUserWrap = new APSimpleConversationUserWrapperList();
			proxyUpdateLogInsertAsAgentUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest7_Simple7ConvInsert7Agnt7' + '@sfa777.test.com';
			proxyUpdateLogInsertAsAgentUserWrap.param_profileId = agentProfileId;
			proxyUpdateLogInsertAsAgentUserWrap.param_associateId = 'ppccpp77ttc';
			proxyUpdateLogInsertAsAgentUserWrap.param_servicingAgentAssociateId = 'ppccpp77ttc';
			proxyUpdateLogInsertAsAgentUserWrap.param_externalId = 'ppccpp77ttc_ppccpp77ttc';
			agentUser = buildUser(proxyUpdateLogInsertAsAgentUserWrap);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;

            APSimpleConversationUserWrapperList proxyUpdateLogInsertAsProxyUserWrap = new APSimpleConversationUserWrapperList();
			proxyUpdateLogInsertAsProxyUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest7_Simple7ConvInsert7Prox7' + '@sfa777.test.com';
			proxyUpdateLogInsertAsProxyUserWrap.param_profileId = proxyProfileId;
			proxyUpdateLogInsertAsProxyUserWrap.param_associateId = '';
			proxyUpdateLogInsertAsProxyUserWrap.param_servicingAgentAssociateId = 'ppccpp77ttc';
			proxyUpdateLogInsertAsProxyUserWrap.param_externalId = 'ppccpp77ttcP';
			proxyUser = buildUser(proxyUpdateLogInsertAsProxyUserWrap);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            APSimpleConversationUserWrapperList proxyUpdateLogInsertAsSystemUserWrap = new APSimpleConversationUserWrapperList();
			proxyUpdateLogInsertAsSystemUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest7_Simple7ConvInsert7Syst7' + '@sfa777.test.com';
			proxyUpdateLogInsertAsSystemUserWrap.param_profileId = noAccessProfileId;
			proxyUpdateLogInsertAsSystemUserWrap.param_associateId = '';
			proxyUpdateLogInsertAsSystemUserWrap.param_servicingAgentAssociateId = '';
			proxyUpdateLogInsertAsSystemUserWrap.param_externalId = '';
			User systemUser = buildUser(proxyUpdateLogInsertAsSystemUserWrap);
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            Account act = buildAccountRecord('7703077');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;

            Test.startTest();
            SimpleConversation__c simpleConversationRecord = buildSimpleConversationRecord(act.id, agentUser.id);
            insert simpleConversationRecord;
            List<SimpleConversation__c> simpleConverLog = [Select Id, Agent__c, OwnerId from SimpleConversation__c limit 1];
            System.assert(!simpleConverLog.isEmpty(), 'simple conversation log should not be empty');
            System.assert(string.isBlank(simpleConverLog[0].Agent__c), 'agent object string is blank');
            System.assertEquals(agentUser.id, simpleConverLog[0].OwnerId, 'owner Id contains agent user Id');
            Test.stopTest();
        }
    }

    //test method to validate deletion of Simple Conversation record as an Technical Support User.
    @isTest
    private static void testSimpleConversationRecordDeleteAsTechSupport() {
        User agentUser;
        User proxyUser;
        User techSupportUser;
        Account act;
        APSimpleConversationUserWrapperList recordDeleteAsAdminWrap = new APSimpleConversationUserWrapperList();
			recordDeleteAsAdminWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvDelete1Admn1' + '@sfa111.test.com';
			recordDeleteAsAdminWrap.param_profileId = adminProfileId;
			recordDeleteAsAdminWrap.param_associateId = '';
			recordDeleteAsAdminWrap.param_servicingAgentAssociateId = '';
			recordDeleteAsAdminWrap.param_externalId = '';
		User adminUser = buildUser(recordDeleteAsAdminWrap);

        System.runAs(adminUser) {
            byPassTrigger();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            APSimpleConversationUserWrapperList recordDeleteAsAgentWrap = new APSimpleConversationUserWrapperList();
			recordDeleteAsAgentWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvDelete1Agnt1' + '@sfa111.test.com';
			recordDeleteAsAgentWrap.param_profileId = agentProfileId;
			recordDeleteAsAgentWrap.param_associateId = 'zzccww11ttc';
			recordDeleteAsAgentWrap.param_servicingAgentAssociateId = 'zzccww11ttc';
			recordDeleteAsAgentWrap.param_externalId = 'zzccww11ttc_zzccww11ttc';
			agentUser = buildUser(recordDeleteAsAgentWrap);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;

            APSimpleConversationUserWrapperList recordDeleteAsProxyWrap = new APSimpleConversationUserWrapperList();
			recordDeleteAsProxyWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvDelete1Prox1' + '@sfa111.test.com';
			recordDeleteAsProxyWrap.param_profileId = proxyProfileId;
			recordDeleteAsProxyWrap.param_associateId = '';
			recordDeleteAsProxyWrap.param_servicingAgentAssociateId = 'zzccww11ttc';
			recordDeleteAsProxyWrap.param_externalId = 'zzccww11ttcP';
			proxyUser = buildUser(recordDeleteAsProxyWrap);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            APSimpleConversationUserWrapperList recordDeleteAsTechSupportWrap = new APSimpleConversationUserWrapperList();
			recordDeleteAsTechSupportWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvDelete1Tech1' + '@sfa111.test.com';
			recordDeleteAsTechSupportWrap.param_profileId = techSupportProfileId;
			recordDeleteAsTechSupportWrap.param_associateId = '';
			recordDeleteAsTechSupportWrap.param_servicingAgentAssociateId = '';
			recordDeleteAsTechSupportWrap.param_externalId = '';
			techsupportUser = buildUser(recordDeleteAsTechSupportWrap);
            insert techSupportUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser,techSupportUser});
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'CoreComponents_User_R');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'CustomerView_Support_ViewAll');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'CustomerView_ApexAura_Enabled');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'SPI_User');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techsupportUser.Id, 'SF_CRM_VirtualMeetingAPTC_PermSetPID');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techsupportUser.Id, 'SimpleConversation_Support_W');

            APSimpleConversationUserWrapperList recordDeleteAsTechSystemWrap = new APSimpleConversationUserWrapperList();
			recordDeleteAsTechSystemWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvDelete1Syst1' + '@sfa111.test.com';
			recordDeleteAsTechSystemWrap.param_profileId = noAccessProfileId;
			recordDeleteAsTechSystemWrap.param_associateId = '';
			recordDeleteAsTechSystemWrap.param_servicingAgentAssociateId = '';
			recordDeleteAsTechSystemWrap.param_externalId = '';
			User systemUser = buildUser(recordDeleteAsTechSystemWrap);
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        }

        System.runAs(agentUser) {
            act = buildAccountRecord('7201011');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;
        }

        System.runAs(techSupportUser) {
            Test.startTest();
            SimpleConversation__c simpleConversationRecord = buildSimpleConversationRecord(act.id, agentUser.id);
            //simpleConversationRecord.Agent__c = agentUser.id;
            insert simpleConversationRecord;
            try {
                delete simpleConversationRecord;
            } catch(Exception e) {
                System.assert(e.getMessage().contains(Label.CL_SimpleConversationPreventDeleteMsg), 'Exception message contains from Label.CL_SimpleConversationPreventDeleteMsg');
            }
            List<SimpleConversation__c> simpleConverLog = [Select Id from SimpleConversation__c limit 1];
            System.assert(simpleConverLog.isEmpty(), 'simple conversation log is empty');
            Test.stopTest();
        }
    }

    //test method to verify SimpleConversationBeforeDelete trigger on bypass logic - Not to Fire.
    @isTest
    private static void testBypassOnSimpleConversationDeleteAsTechSupport() {
        User agentUser;
        User proxyUser;
        User techSupportUser;
        APSimpleConversationUserWrapperList beforeDeleteTriggerOnBypassLogicDeleteAsAdminWrap = new APSimpleConversationUserWrapperList();
			beforeDeleteTriggerOnBypassLogicDeleteAsAdminWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest2_Simple2ConvDelete2Admn2' + '@sfa222.test.com';
			beforeDeleteTriggerOnBypassLogicDeleteAsAdminWrap.param_profileId = adminProfileId;
			beforeDeleteTriggerOnBypassLogicDeleteAsAdminWrap.param_associateId = '';
			beforeDeleteTriggerOnBypassLogicDeleteAsAdminWrap.param_servicingAgentAssociateId = '';
			beforeDeleteTriggerOnBypassLogicDeleteAsAdminWrap.param_externalId = '';
		User adminUser = buildUser(beforeDeleteTriggerOnBypassLogicDeleteAsAdminWrap);
        Account act;

        System.runAs(adminUser) {
            byPassTrigger();
            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            APSimpleConversationUserWrapperList beforeDeleteTriggerOnBypassLogicDeleteAsAgentWrap = new APSimpleConversationUserWrapperList();
			beforeDeleteTriggerOnBypassLogicDeleteAsAgentWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest2_Simple2ConvDelete2Agnt2' + '@sfa222.test.com';
			beforeDeleteTriggerOnBypassLogicDeleteAsAgentWrap.param_profileId = agentProfileId;
			beforeDeleteTriggerOnBypassLogicDeleteAsAgentWrap.param_associateId = 'zzccww22ttc';
			beforeDeleteTriggerOnBypassLogicDeleteAsAgentWrap.param_servicingAgentAssociateId = 'zzccww22ttc';
			beforeDeleteTriggerOnBypassLogicDeleteAsAgentWrap.param_externalId = 'zzccww22ttc_zzccww22ttc';
			agentUser = buildUser(beforeDeleteTriggerOnBypassLogicDeleteAsAgentWrap);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;

            APSimpleConversationUserWrapperList beforeDeleteTriggerOnBypassLogicDeleteAsProxyWrap = new APSimpleConversationUserWrapperList();
			beforeDeleteTriggerOnBypassLogicDeleteAsProxyWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest2_Simple2ConvDelete2Prox2' + '@sfa222.test.com';
			beforeDeleteTriggerOnBypassLogicDeleteAsProxyWrap.param_profileId = proxyProfileId;
			beforeDeleteTriggerOnBypassLogicDeleteAsProxyWrap.param_associateId = '';
			beforeDeleteTriggerOnBypassLogicDeleteAsProxyWrap.param_servicingAgentAssociateId = 'zzccww22ttc';
			beforeDeleteTriggerOnBypassLogicDeleteAsProxyWrap.param_externalId = 'zzccww22ttcP';
			proxyUser = buildUser(beforeDeleteTriggerOnBypassLogicDeleteAsProxyWrap);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            APSimpleConversationUserWrapperList beforeDeleteTriggerOnBypassLogicDeleteAsTechSupportWrap = new APSimpleConversationUserWrapperList();
			beforeDeleteTriggerOnBypassLogicDeleteAsTechSupportWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest2_Simple2ConvDelete2Tech2' + '@sfa222.test.com';
			beforeDeleteTriggerOnBypassLogicDeleteAsTechSupportWrap.param_profileId = techSupportProfileId;
			beforeDeleteTriggerOnBypassLogicDeleteAsTechSupportWrap.param_associateId = '';
			beforeDeleteTriggerOnBypassLogicDeleteAsTechSupportWrap.param_servicingAgentAssociateId = '';
			beforeDeleteTriggerOnBypassLogicDeleteAsTechSupportWrap.param_externalId = '';
			techsupportUser = buildUser(beforeDeleteTriggerOnBypassLogicDeleteAsTechSupportWrap);
            insert techSupportUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser,techSupportUser});
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'CoreComponents_User_R');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'CustomerView_Support_ViewAll');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'CustomerView_ApexAura_Enabled');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'SPI_User');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techsupportUser.Id, 'SF_CRM_VirtualMeetingAPTC_PermSetPID');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techsupportUser.Id, 'SimpleConversation_Support_W');

            APSimpleConversationUserWrapperList beforeDeleteTriggerOnBypassLogicDeleteAsSystemWrap = new APSimpleConversationUserWrapperList();
			beforeDeleteTriggerOnBypassLogicDeleteAsSystemWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest2_Simple2ConvDelete2Syst2' + '@sfa222.test.com';
			beforeDeleteTriggerOnBypassLogicDeleteAsSystemWrap.param_profileId = noAccessProfileId;
			beforeDeleteTriggerOnBypassLogicDeleteAsSystemWrap.param_associateId = '';
			beforeDeleteTriggerOnBypassLogicDeleteAsSystemWrap.param_servicingAgentAssociateId = '';
			beforeDeleteTriggerOnBypassLogicDeleteAsSystemWrap.param_externalId = '';
			User systemUser = buildUser(beforeDeleteTriggerOnBypassLogicDeleteAsSystemWrap);
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        }

        System.runAs(agentUser) {
            act = buildAccountRecord('7702022');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;
        }

        System.runAs(techSupportUser) {
            Test.startTest();
            SimpleConversation__c simpleConvToBeInserted = buildSimpleConversationRecord(act.id, agentUser.id);
            simpleConvToBeInserted.Agent__c = agentUser.id;
            simpleConvToBeInserted.ownerId = proxyUser.id;
            insert simpleConvToBeInserted;

            List<SimpleConversation__c> simpleConverBefore = [Select Id from SimpleConversation__c limit 1];
            System.assert(!simpleConverBefore.isEmpty(), 'Simple conversation before should not be empty');

            delete simpleConvToBeInserted;
            List<SimpleConversation__c> simpleConverAfter = [Select Id from SimpleConversation__c limit 1];
            System.assert(simpleConverAfter.isEmpty(), 'Simple conversation after is empty');
            Test.stopTest();
        }
    }

    //test method to Update Simple Conversation record as a Planning Services User.
    @isTest
    private static void testSimpleConversationRecordUpdateAsTechnicalSupportUser() {
        User agentUser;
        User proxyUser;
        User techSupportUser;
        Account act;
        APSimpleConversationUserWrapperList testRecordUpdateAsAdminUserWrap = new APSimpleConversationUserWrapperList();
			testRecordUpdateAsAdminUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvUpdate1Admn1' + '@sfa111.test.com';
			testRecordUpdateAsAdminUserWrap.param_profileId = adminProfileId;
			testRecordUpdateAsAdminUserWrap.param_associateId = '';
			testRecordUpdateAsAdminUserWrap.param_servicingAgentAssociateId = '';
			testRecordUpdateAsAdminUserWrap.param_externalId = '';
		User adminUser = buildUser(testRecordUpdateAsAdminUserWrap);

        System.runAs(adminUser) {
            byPassTrigger();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            APSimpleConversationUserWrapperList testRecordUpdateAsAgentUserWrap = new APSimpleConversationUserWrapperList();
			testRecordUpdateAsAgentUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvUpdate1Agnt11' + '@sfa111.test.com';
			testRecordUpdateAsAgentUserWrap.param_profileId = agentProfileId;
			testRecordUpdateAsAgentUserWrap.param_associateId = 'kkccww11ttc';
			testRecordUpdateAsAgentUserWrap.param_servicingAgentAssociateId = 'kkccww11ttc';
			testRecordUpdateAsAgentUserWrap.param_externalId = 'kkccww11ttc_kkccww11ttc';
			agentUser = buildUser(testRecordUpdateAsAgentUserWrap);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;

            APSimpleConversationUserWrapperList testRecordUpdateAsProxyUserWrap = new APSimpleConversationUserWrapperList();
			testRecordUpdateAsProxyUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvUpdate1Prox11' + '@sfa111.test.com';
			testRecordUpdateAsProxyUserWrap.param_profileId = proxyProfileId;
			testRecordUpdateAsProxyUserWrap.param_associateId = '';
			testRecordUpdateAsProxyUserWrap.param_servicingAgentAssociateId = 'kkccww11ttc';
			testRecordUpdateAsProxyUserWrap.param_externalId = 'kkccww11ttcP';
			proxyUser = buildUser(testRecordUpdateAsProxyUserWrap);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            APSimpleConversationUserWrapperList testRecordUpdateAsTechSupportUserWrap = new APSimpleConversationUserWrapperList();
			testRecordUpdateAsTechSupportUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvUpdate1Tech1' + '@sfa111.test.com';
			testRecordUpdateAsTechSupportUserWrap.param_profileId = techSupportProfileId;
			testRecordUpdateAsTechSupportUserWrap.param_associateId = '';
			testRecordUpdateAsTechSupportUserWrap.param_servicingAgentAssociateId = '';
			testRecordUpdateAsTechSupportUserWrap.param_externalId = '';
			techSupportUser = buildUser(testRecordUpdateAsTechSupportUserWrap);
            insert techSupportUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser,techSupportUser});
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'CoreComponents_User_R');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'CustomerView_Support_ViewAll');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'CustomerView_ApexAura_Enabled');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'SPI_User');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'SF_CRM_VirtualMeetingAPTC_PermSetPID');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'SimpleConversation_Support_W');

            APSimpleConversationUserWrapperList testRecordUpdateAsSystemUserWrap = new APSimpleConversationUserWrapperList();
			testRecordUpdateAsSystemUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvUpdate1Syst1' + '@sfa111.test.com';
			testRecordUpdateAsSystemUserWrap.param_profileId = noAccessProfileId;
			testRecordUpdateAsSystemUserWrap.param_associateId = '';
			testRecordUpdateAsSystemUserWrap.param_servicingAgentAssociateId = '';
			testRecordUpdateAsSystemUserWrap.param_externalId = '';
			User systemUser = buildUser(testRecordUpdateAsSystemUserWrap);
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        }

        System.runAs(agentUser) {
            act = buildAccountRecord('8705055');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;
        }

        System.runAs(techSupportUser) {
            Test.startTest();
            SimpleConversation__c simpleConversationRecord = buildSimpleConversationRecord(act.id, agentUser.id);
            simpleConversationRecord.Agent__c = agentUser.id;
            simpleConversationRecord.AppointmentStartDateTime__c = datetime.now();
            insert simpleConversationRecord;

            List<SimpleConversation__c> simpleConverBefore = [Select Id, Agent__c, OwnerId, RescheduleCount__c from SimpleConversation__c limit 1];
            System.assert(!simpleConverBefore.isEmpty(), 'Simple conversation before should not be empty');
            System.assertEquals(agentUser.id, simpleConverBefore[0].Agent__c, 'agent object have the agent user Id');
            //System.assertEquals(proxyUser.id, simpleConverBefore[0].OwnerId);
            System.assert(simpleConverBefore[0].RescheduleCount__c == null, 'RescheduleCount object is equal to Null');

            SimpleConversation__c simpleConversationRecordToUpdate = new SimpleConversation__c(id = simpleConversationRecord.id, AppointmentStartDateTime__c = datetime.now().addHours(1));
            update simpleConversationRecordToUpdate;

            List<SimpleConversation__c> simpleConverAfter;
            simpleConverAfter = [Select Id, RescheduleCount__c from SimpleConversation__c limit 1];
            //System.assertEquals(1, simpleConverAfter[0].RescheduleCount__c);
            Test.stopTest();
        }
    }

    //test method to verify SimpleConversationBeforeUpdate trigger on bypass logic - Not to Fire.
    @isTest
    private static void testBypassOnSimpleConversationBeforeUpdateAsTechSupport() {
        User agentUser;
        User proxyUser;
        User techSupportUser;
        Account act;
        APSimpleConversationUserWrapperList testBeforeUpdateAsAdminUserWrap = new APSimpleConversationUserWrapperList();
			testBeforeUpdateAsAdminUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest2_Simple2ConvUpdate2Admn2' + '@sfa222.test.com';
			testBeforeUpdateAsAdminUserWrap.param_profileId = adminProfileId;
			testBeforeUpdateAsAdminUserWrap.param_associateId = '';
			testBeforeUpdateAsAdminUserWrap.param_servicingAgentAssociateId = '';
			testBeforeUpdateAsAdminUserWrap.param_externalId = '';
		User adminUser = buildUser(testBeforeUpdateAsAdminUserWrap);

        System.runAs(adminUser) {
            byPassTrigger();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            APSimpleConversationUserWrapperList testBeforeUpdateAsAgentUserWrap = new APSimpleConversationUserWrapperList();
			testBeforeUpdateAsAgentUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest2_Simple2ConvUpdate2Agnt12' + '@sfa222.test.com';
			testBeforeUpdateAsAgentUserWrap.param_profileId = agentProfileId;
			testBeforeUpdateAsAgentUserWrap.param_associateId = 'kkccww22ttc';
			testBeforeUpdateAsAgentUserWrap.param_servicingAgentAssociateId = 'kkccww22ttc';
			testBeforeUpdateAsAgentUserWrap.param_externalId = 'kkccww22ttc_kkccww22ttc';
			agentUser = buildUser(testBeforeUpdateAsAgentUserWrap);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;

            APSimpleConversationUserWrapperList testBeforeUpdateAsProxyUserWrap = new APSimpleConversationUserWrapperList();
			testBeforeUpdateAsProxyUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest2_Simple2ConvUpdate2Prox12' + '@sfa222.test.com';
			testBeforeUpdateAsProxyUserWrap.param_profileId = proxyProfileId;
			testBeforeUpdateAsProxyUserWrap.param_associateId = '';
			testBeforeUpdateAsProxyUserWrap.param_servicingAgentAssociateId = 'kkccww22ttc';
			testBeforeUpdateAsProxyUserWrap.param_externalId = 'kkccww22ttcP';
			proxyUser = buildUser(testBeforeUpdateAsProxyUserWrap);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            APSimpleConversationUserWrapperList testBeforeUpdateAsTechSupportUserWrap = new APSimpleConversationUserWrapperList();
			testBeforeUpdateAsTechSupportUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest2_Simple2ConvUpdate2Tech2' + '@sfa222.test.com';
			testBeforeUpdateAsTechSupportUserWrap.param_profileId = techSupportProfileId;
			testBeforeUpdateAsTechSupportUserWrap.param_associateId = '';
			testBeforeUpdateAsTechSupportUserWrap.param_servicingAgentAssociateId = '';
			testBeforeUpdateAsTechSupportUserWrap.param_externalId = '';
			techSupportUser = buildUser(testBeforeUpdateAsTechSupportUserWrap);
            insert techSupportUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser,techSupportUser});
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'CoreComponents_User_R');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'CustomerView_Support_ViewAll');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'CustomerView_ApexAura_Enabled');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'SPI_User');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'SF_CRM_VirtualMeetingAPTC_PermSetPID');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(techSupportUser.Id, 'SimpleConversation_Support_W');

            APSimpleConversationUserWrapperList testBeforeUpdateAsSystemUserWrap = new APSimpleConversationUserWrapperList();
			testBeforeUpdateAsSystemUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest2_Simple2ConvUpdate2Syst2' + '@sfa222.test.com';
			testBeforeUpdateAsSystemUserWrap.param_profileId = noAccessProfileId;
			testBeforeUpdateAsSystemUserWrap.param_associateId = '';
			testBeforeUpdateAsSystemUserWrap.param_servicingAgentAssociateId = '';
			testBeforeUpdateAsSystemUserWrap.param_externalId = '';
			User systemUser = buildUser(testBeforeUpdateAsSystemUserWrap);
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        }

        System.runAs(agentUser) {
            act = buildAccountRecord('8705055');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;
        }

        System.runAs(techSupportUser) {
            Test.startTest();
            SimpleConversation__c simpleConversationRecord = buildSimpleConversationRecord(act.id, agentUser.id);
            simpleConversationRecord.Agent__c = agentUser.id;
            simpleConversationRecord.AppointmentStartDateTime__c = datetime.now();
            simpleConversationRecord.ownerId = proxyUser.id;
            insert simpleConversationRecord;

            List<SimpleConversation__c> simpleConverBefore = [Select Id, RescheduleCount__c from SimpleConversation__c limit 1];
            System.assert(!simpleConverBefore.isEmpty(), 'Simple Conversation Before should not be empty');
            System.assert(simpleConverBefore[0].RescheduleCount__c == null, 'RescheduleCount object is equal to Null');

            SimpleConversation__c simpleConversationRecordToUpdate = new SimpleConversation__c(id = simpleConversationRecord.id, AppointmentStartDateTime__c = datetime.now().addHours(1));
            update simpleConversationRecordToUpdate;

            List<SimpleConversation__c> simpleConverAfter = [Select Id, RescheduleCount__c from SimpleConversation__c limit 1];
            System.assert(simpleConverAfter[0].RescheduleCount__c == null, 'RescheduleCount object is equal to Null');
            Test.stopTest();
        }
    }

    //test method to validate Exception on Simple Conversation record update as a Technical Support User.
    @isTest
    private static void testExceptionOnSimpleConversationRecordUpdateAsTechnicalSupportUser() {
        User techsupportUser;
        APSimpleConversationUserWrapperList testExceptionOnRecordUpdateAsAdminUserWrap = new APSimpleConversationUserWrapperList();
			testExceptionOnRecordUpdateAsAdminUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest3_Simple3ConvInsert3Admn3' + '@sfa333.test.com';
			testExceptionOnRecordUpdateAsAdminUserWrap.param_profileId = adminProfileId;
			testExceptionOnRecordUpdateAsAdminUserWrap.param_associateId = '';
			testExceptionOnRecordUpdateAsAdminUserWrap.param_servicingAgentAssociateId = '';
			testExceptionOnRecordUpdateAsAdminUserWrap.param_externalId = '';
		User adminUser = buildUser(testExceptionOnRecordUpdateAsAdminUserWrap);

        System.runAs(adminUser) {
            byPassTrigger();

            APSimpleConversationUserWrapperList testExceptionOnRecordUpdateAsTechSupportUserWrap = new APSimpleConversationUserWrapperList();
			testExceptionOnRecordUpdateAsTechSupportUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest3_Simple3ConvUpdate3Prox3' + '@sfa333.test.com';
			testExceptionOnRecordUpdateAsTechSupportUserWrap.param_profileId = techSupportProfileId;
			testExceptionOnRecordUpdateAsTechSupportUserWrap.param_associateId = '';
			testExceptionOnRecordUpdateAsTechSupportUserWrap.param_servicingAgentAssociateId = '';
			testExceptionOnRecordUpdateAsTechSupportUserWrap.param_externalId = '';
			techsupportUser = buildUser(testExceptionOnRecordUpdateAsTechSupportUserWrap);
            insert techsupportUser;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(techsupportUser);
        System.runAs(techsupportUser) {
            Test.startTest();
            List<SimpleConversation__c> simpleConversationRecord;
            Map<Id, SimpleConversation__c> simpleConversationMap;
            try {
                AP_SimpleConversationTrigger simpleConvLog = new AP_SimpleConversationTrigger();
                simpleConvLog.processSimpleConversationOnBeforeUpdate(simpleConversationRecord, simpleConversationMap);
            } catch(Exception ex) {
                System.assert(!String.isBlank(ex.getMessage()), 'Exception message string should not be blank');
            }
            Test.stopTest();
        }
    }

    //test method to Update Simple Conversation record as a agent User.
    @isTest
    private static void testSimpleConversationRecordUpdateAsAgentUser() {
        User agentUser;
        User proxyUser;
        Account act;
        APSimpleConversationUserWrapperList scRecordUpdateAsAdminUserWrap = new APSimpleConversationUserWrapperList();
			scRecordUpdateAsAdminUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest4_Simple4ConvUpdate4Admn4' + '@sfa444.test.com';
			scRecordUpdateAsAdminUserWrap.param_profileId = adminProfileId;
			scRecordUpdateAsAdminUserWrap.param_associateId = '';
			scRecordUpdateAsAdminUserWrap.param_servicingAgentAssociateId = '';
			scRecordUpdateAsAdminUserWrap.param_externalId = '';
		User adminUser = buildUser(scRecordUpdateAsAdminUserWrap);

        System.runAs(adminUser) {
            byPassTrigger();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            APSimpleConversationUserWrapperList scRecordUpdateAsAgentUserWrap = new APSimpleConversationUserWrapperList();
			scRecordUpdateAsAgentUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest4_Simple4ConvUpdate4Agnt4' + '@sfa444.test.com';
			scRecordUpdateAsAgentUserWrap.param_profileId = agentProfileId;
			scRecordUpdateAsAgentUserWrap.param_associateId = 'kkccww44ttc';
			scRecordUpdateAsAgentUserWrap.param_servicingAgentAssociateId = 'kkccww44ttc';
			scRecordUpdateAsAgentUserWrap.param_externalId = 'kkccww44ttc_kkccww44ttc';
			agentUser = buildUser(scRecordUpdateAsAgentUserWrap);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;

            APSimpleConversationUserWrapperList scRecordUpdateAsProxyUserWrap = new APSimpleConversationUserWrapperList();
			scRecordUpdateAsProxyUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest4_Simple4ConvUpdate4Prox4' + '@sfa444.test.com';
			scRecordUpdateAsProxyUserWrap.param_profileId = proxyProfileId;
			scRecordUpdateAsProxyUserWrap.param_associateId = '';
			scRecordUpdateAsProxyUserWrap.param_servicingAgentAssociateId = 'kkccww44ttc';
			scRecordUpdateAsProxyUserWrap.param_externalId = 'kkccww44ttcP';
			proxyUser = buildUser(scRecordUpdateAsProxyUserWrap);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            APSimpleConversationUserWrapperList scRecordUpdateAsSystemUserWrap = new APSimpleConversationUserWrapperList();
			scRecordUpdateAsSystemUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest4_Simple1ConvUpdate4Syst4' + '@sfa444.test.com';
			scRecordUpdateAsSystemUserWrap.param_profileId = noAccessProfileId;
			scRecordUpdateAsSystemUserWrap.param_associateId = '';
			scRecordUpdateAsSystemUserWrap.param_servicingAgentAssociateId = '';
			scRecordUpdateAsSystemUserWrap.param_externalId = '';
			User systemUser = buildUser(scRecordUpdateAsSystemUserWrap);
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            act = buildAccountRecord('8705044');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;
        }

        System.runAs(agentUser) {
            Test.startTest();
            SimpleConversation__c simpleConversationRecord = buildSimpleConversationRecord(act.id, agentUser.id);
            simpleConversationRecord.AppointmentStartDateTime__c = datetime.now();
            simpleConversationRecord.RescheduleCount__c = 1;
            insert simpleConversationRecord;

            List<SimpleConversation__c> simpleConverBefore = [Select Id, RescheduleCount__c from SimpleConversation__c limit 1];
            System.assert(!simpleConverBefore.isEmpty(), 'Simple conversation Before should not be empty');
            System.assertEquals(1, simpleConverBefore[0].RescheduleCount__c, 'List of RescheduleCount object counts contains 1');

            SimpleConversation__c simpleConversationRecordToUpdate = new SimpleConversation__c(id = simpleConversationRecord.id, AppointmentStartDateTime__c = datetime.now().addHours(1));
            update simpleConversationRecordToUpdate;

            List<SimpleConversation__c> simpleConverAfter;
            simpleConverAfter = [Select Id, RescheduleCount__c from SimpleConversation__c limit 1];
            //System.assertEquals(2, simpleConverAfter[0].RescheduleCount__c);
            Test.stopTest();
        }
    }

    //test method to populate Last conversation date on simple Conversation record before insert as an Agent.
    @isTest
    private static void testPopulateLastConversationDateOnSimpleConversationRecordInsertAsAgent() {
        User agentUser;
        User proxyUser;
        APSimpleConversationUserWrapperList populateLastConversationDateOnSCRecordInsertAsAdminUserWrap = new APSimpleConversationUserWrapperList();
			populateLastConversationDateOnSCRecordInsertAsAdminUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvBeforeInsert1Admn1' + '@sfa111.test.com';
			populateLastConversationDateOnSCRecordInsertAsAdminUserWrap.param_profileId = adminProfileId;
			populateLastConversationDateOnSCRecordInsertAsAdminUserWrap.param_associateId = '';
			populateLastConversationDateOnSCRecordInsertAsAdminUserWrap.param_servicingAgentAssociateId = '';
			populateLastConversationDateOnSCRecordInsertAsAdminUserWrap.param_externalId = '';
		User adminUser = buildUser(populateLastConversationDateOnSCRecordInsertAsAdminUserWrap);

        System.runAs(adminUser) {
            byPassTrigger();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            APSimpleConversationUserWrapperList populateLastConversationDateOnSCRecordInsertAsAgentUserWrap = new APSimpleConversationUserWrapperList();
			populateLastConversationDateOnSCRecordInsertAsAgentUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvBeforeInsert1Agnt1' + '@sfa111.test.com';
			populateLastConversationDateOnSCRecordInsertAsAgentUserWrap.param_profileId = agentProfileId;
			populateLastConversationDateOnSCRecordInsertAsAgentUserWrap.param_associateId = 'mmccpp11ttc';
			populateLastConversationDateOnSCRecordInsertAsAgentUserWrap.param_servicingAgentAssociateId = 'mmccpp11ttc';
			populateLastConversationDateOnSCRecordInsertAsAgentUserWrap.param_externalId = 'mmccpp11ttc_mmccpp11ttc';
			agentUser = buildUser(populateLastConversationDateOnSCRecordInsertAsAgentUserWrap);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;

            APSimpleConversationUserWrapperList populateLastConversationDateOnSCRecordInsertAsProxyUserWrap = new APSimpleConversationUserWrapperList();
			populateLastConversationDateOnSCRecordInsertAsProxyUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvBeforeInsert1Prox1' + '@sfa111.test.com';
			populateLastConversationDateOnSCRecordInsertAsProxyUserWrap.param_profileId = proxyProfileId;
			populateLastConversationDateOnSCRecordInsertAsProxyUserWrap.param_associateId = '';
			populateLastConversationDateOnSCRecordInsertAsProxyUserWrap.param_servicingAgentAssociateId = 'mmccpp11ttc';
			populateLastConversationDateOnSCRecordInsertAsProxyUserWrap.param_externalId = 'mmccpp11ttcP';
			proxyUser = buildUser(populateLastConversationDateOnSCRecordInsertAsProxyUserWrap);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            APSimpleConversationUserWrapperList populateLastConversationDateOnSCRecordInsertAsSystemUserWrap = new APSimpleConversationUserWrapperList();
			populateLastConversationDateOnSCRecordInsertAsSystemUserWrap.param_UserName = UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'trigTest1_Simple1ConvBeforeInsert1Syst1' + '@sfa111.test.com';
			populateLastConversationDateOnSCRecordInsertAsSystemUserWrap.param_profileId = noAccessProfileId;
			populateLastConversationDateOnSCRecordInsertAsSystemUserWrap.param_associateId = '';
			populateLastConversationDateOnSCRecordInsertAsSystemUserWrap.param_servicingAgentAssociateId = '';
			populateLastConversationDateOnSCRecordInsertAsSystemUserWrap.param_externalId = '';
			User systemUser = buildUser(populateLastConversationDateOnSCRecordInsertAsSystemUserWrap);
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            Account act = buildAccountRecord('7501011');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;

            SimpleConversation__c simpleConversationRecord = buildSimpleConversationRecord(act.id, agentUser.id);
            insert simpleConversationRecord;

            Virtual_Meeting__c virtMeetingRecord = buildVirtualMeetingRecord(agentUser.id, simpleConversationRecord.id);
            insert virtMeetingRecord;

            Test.startTest();
            //simpleConversationRecord.AppointmentStartDateTime__c = datetime.now();
            SimpleConversation__c  simpleConversationRecordToUpdate = new SimpleConversation__c (id = simpleConversationRecord.id, AppointmentStartDateTime__c = datetime.now(), Status__c = 'Completed',
                                                                            AppointmentEndDateTime__c = datetime.now());
            update simpleConversationRecordToUpdate;
            List<SimpleConversation__c> simpleConverLogPrevious = [Select Id, AppointmentEndDateTime__c, LastConversationDate__c, OwnerId from SimpleConversation__c limit 1];
            System.assert(!simpleConverLogPrevious.isEmpty(), 'Simple conversation log previous should not be Empty');
            System.assertEquals(null, simpleConverLogPrevious[0].LastConversationDate__c, 'List of last conversation date object is Null');

            SimpleConversation__c simpleConversationRecord1 = buildSimpleConversationRecord(act.id, agentUser.id);
            insert simpleConversationRecord1;
            List<SimpleConversation__c> simpleConverLogNew = [Select Id, LastConversationDate__c from SimpleConversation__c where id = :simpleConversationRecord1.id];
            System.assert(!simpleConverLogNew.isEmpty(), 'simple conversation log new should not be empty');
            //System.assertEquals(simpleConverLogPrevious[0].AppointmentEndDateTime__c.date(), simpleConverLogNew[0].LastConversationDate__c);
            Test.stopTest();
        }
    }

}