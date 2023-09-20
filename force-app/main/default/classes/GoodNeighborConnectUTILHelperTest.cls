/*
VERSION         AUTHOR                  DATE                DETAIL
2.0            Team Incognito          09/06/2022           Team Incognito - Remove duplicate code /Refactor*/

@isTest
public class GoodNeighborConnectUTILHelperTest {
	//All for testing creatingVirtualMeeting method
    //Just took the test code from UTIL_CoodNeighborConnect_Test file
    private static String agentProfileId = TestDataFactory_Journey.getProfileId(UTIL_Constants.AGENT_PROFILE_NAME);
    private static String proxyProfileId = TestDataFactory_Journey.getProfileId(UTIL_Constants.PROXY_PROFILE_NAME);
    private static String adminProfileId = TestDataFactory_Journey.getProfileId(UTIL_Constants.SYSTEM_ADMIN_PROFILE_NAME);
    private static String noAccessProfileId = TestDataFactory_Journey.getProfileId(UTIL_Constants.NO_ACCESS_PROFILE_NAME);
    private static final String SECONDS_FORMAT= 'ssSSS';
    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();
    String roleName;
    String parentrole;
    UserRole getBuildRoleWithParentRole = TestDataFactory_Journey.buildRoleWithParentRole( roleName, parentrole);
    String profileId;
    String associateId;
    String servicingAgentAssociateIdileName;
    User getBuildUser = TestDataFactory_Journey.buildUser(profileId,associateId,servicingAgentAssociateIdileName);
    String profileName;
    String getProfileName = TestDataFactory_Journey.getProfileId(profileName);
    GoodNeighborConnectUTILHelperTestWrapper goodWrap = new GoodNeighborConnectUTILHelperTestWrapper();
     
    //method to bypass Trigger
    private static void byPassTrigger() {
        CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c();
        objectBasedByPassTrigger.Override_All__c = true;
        insert objectBasedByPassTrigger;
    }

    //method to get the ProfileId for the given Profile Name
    /*private static String getProfileId(String profileName) {
        String profileId = TestDataFactory_Helper_ProfileLookup.lookupProfileID(profileName);
        return profileId;
    }*/

    //method to build user with the given parameter value
    /*private static User buildUser(String profileId, String associateId, String servicingAgentAssociateId) {
        User testUser = new User (alias = '12345', email = 'testUser@statefarm.com.bad', emailencodingkey='UTF-8', lastname='TestUserLastName',
            languagelocalekey='en_US',localesidkey='en_US', timezonesidkey='America/Chicago',
            username= UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + Integer.valueOf(math.rint(math.random()*100)) + '@sfa222.test.com', 
            profileId = profileId, Associate_ID__c = associateId, Servicing_Agent_Associate_ID__c = servicingAgentAssociateId ,
            State_Agent_Code__c = '13-2935'
        );
        return testUser;
    }*/

    //method to build userrole with parentRole with the given parameter value
    /*private static UserRole buildRoleWithParentRole(String roleName, String parentrole) {
        UserRole role = new UserRole(name = roleName, parentRoleId = parentrole);
        return role;
    }*/

    //method to build Account Owner custom setting record with the given parameter value
    /*private static AccountOwnerSystemUserCustomSetting__c buildCustomSettingRecord(String userId) {
        AccountOwnerSystemUserCustomSetting__c actOwnerCs = new AccountOwnerSystemUserCustomSetting__c(Name = UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER, SFDC_USER_ID__c = userId);
        return actOwnerCs;
    }*/

    //method to build Account record with the given parameter value
   private static Account buildAccountRecord(String param_clientIdentifier) {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        Account act = new Account(FirstName = 'rrrrr', LastName = 'tttttttt', PersonEmail = 'abc@test.com', PersonMobilePhone ='123-456-7890', PersonHomePhone = '000-000-0000',
        ClientIdentifier__c = param_clientIdentifier);
        return act;
    }

    //method to build Agent Role record with the given parameter value
    private static AgentRole__c buildAgentRoleRecord(String param_accountId) {
        AgentRole__c agentRole = new AgentRole__c (RelationshipNature__c = 'Customer',
                       Agent__c = userInfo.getUserId(), Customer__c = param_accountId);
        return agentRole;
    }


    //method to build Simple Conversation record with the given parameter value
    /*private static SimpleConversation__c buildSimpleConversationRecord(String param_accountId, String param_conductedBy) {
        SimpleConversation__c simpleConvRecord = new SimpleConversation__c (Account__c = param_accountId,
                            Status__c = 'New', ConductedBy__c = param_conductedBy, SimpleConversationName__c = 'Test Simple Conv',Appointment_Location__c='Virtual Meeting',
                            AppointmentStartDateTime__c = datetime.now().addHours(1), AppointmentEndDateTime__c = datetime.now().addHours(2));
        return simpleConvRecord;
    }*/

    
    //method to build Virtual Meeting record with the given parameter value
    private static Virtual_Meeting__c buildVirtualMeetingRecord(String param_assignedBy, String param_SimpleConversation) {
        Virtual_Meeting__c virtMeetingRecord = new Virtual_Meeting__c ( Assigned_To__c = param_assignedBy,Start_Time__c = datetime.now().addHours(1),End_Time__c = datetime.now().addHours(2),Name='Simple Conversation', Simple_Conversation__c = param_SimpleConversation);
        return virtMeetingRecord;
    }
    private static User initialSetup(){
        User adminUser = TestDataFactory_Journey.buildUser(adminProfileId, '', '');
        User agentUser;
        System.runAs(adminUser) {
           byPassTrigger();
           UserRole agentUserRole = TestDataFactory_Campaign.buildUserRole('AgentRole');
           insert agentUserRole;
           agentUser = TestDataFactory_Journey.buildUser(agentProfileId, '60ccww22zzc', '60ccww22zzc');
           agentUser.userRoleId = agentUserRole.id;
           agentUser.UserExternalID__c = '60ccww22zzc_60ccww22zzc';
           insert agentUser;
           TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);

           AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(agentUser.Id, 'SF_CRM_VirtualMeetingAPTC_PermSetPID');

           User systemUser = TestDataFactory_Journey.buildUser(noAccessProfileId, '', '');
           insert systemUser;
           AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(systemUser.Id, 'SF_CRM_VirtualMeetingAPTC_PermSetPID');
           AccountOwnerSystemUserCustomSetting__c accountOwner = TestDataFactory_Journey.buildCustomSettingRecord(systemUser.id);
           insert accountOwner;
       }    
       return agentUser;
   }
    
    @isTest
   	static void testMeetNow() {
       User agentUser = initialSetup();          
       System.runAs(agentUser) {
           Account act = buildAccountRecord('7601011');
           insert act;

           AgentRole__c agentRole = buildAgentRoleRecord(act.id);
           insert agentRole;

    	   CS_Liveoak__c csobj=new CS_Liveoak__c(Name = 'Liveoak_Dataset', Client_Secret__c ='0f52714e7d6e968cb3513cf9d6a46ed6b7c78216c3534b69f6b754b4db6d4f0e',Client_Id__c='648305910bca6b76d245',Resource_Path__c='/api/v1/rooms', Name__c ='Basic Collaboration Room');
		   insert csobj;
     
           Test.startTest();
           Test.setMock(HttpCalloutMock.class, new HLPR_LiveOakCalloutMock_Test());
           List<String> gncParams = new List<String>();
          
           gncParams.add(agentUser.id);
           gncParams.add('Test Virtual Meeting');
           gncParams.add('2030-08-13T16:35:19.000Z');
           gncParams.add('2030-08-13T16:55:19.000Z');

           CS001_ByPassTriggerAll__c objectBasedByPassTrigger = [Select id from CS001_ByPassTriggerAll__c limit 1];
           objectBasedByPassTrigger.Override_All__c = false;
           update objectBasedByPassTrigger;

           GoodNeighborConnectUTILHelper.createVirtualMeetingRecord(gncParams,act.id);
           
           Test.stopTest();
          
           System.assertEquals('Meeting created successfully','Meeting created successfully','Invalid Status');
       }
   }
    
    @isTest
   	static void testFailure() {
       User agentUser = initialSetup();          
       System.runAs(agentUser) {
           Account act = buildAccountRecord('7601011');
           insert act;

           AgentRole__c agentRole = buildAgentRoleRecord(act.id);
           insert agentRole;

    	   CS_Liveoak__c csobj=new CS_Liveoak__c(Name = 'Liveoak_Dataset', Client_Secret__c ='0f52714e7d6e968cb3513cf9d6a46ed6b7c78216c3534b69f6b754b4db6d4f0e',Client_Id__c='648305910bca6b76d245',Resource_Path__c='/api/v1/rooms', Name__c ='Basic Collaboration Room');
		   insert csobj;
     
           Test.startTest();
           Test.setMock(HttpCalloutMock.class, new HLPR_LiveOakCalloutMock_Test());
           List<String> gncParams = new List<String>();
          
           gncParams.add(agentUser.id);
           gncParams.add('1');
           gncParams.add('2');
           gncParams.add('3');

           CS001_ByPassTriggerAll__c objectBasedByPassTrigger = [Select id from CS001_ByPassTriggerAll__c limit 1];
           objectBasedByPassTrigger.Override_All__c = false;
           update objectBasedByPassTrigger;
           
            try{
                GoodNeighborConnectUTILHelper.createVirtualMeetingRecord(gncParams,act.id);
            }
            catch (InvalidParameterValueException ex) {
                System.assertEquals('servicingAgentExternalId failed Servicing Agent External Id validation', ex.getMessage(), 'Unexpected Exception Message');
            }
           
           Test.stopTest();
       }
	}

    private class GoodNeighborConnectUTILHelperTestWrapper{
        String param_accountId;
        String param_conductedBy;
        SimpleConversation__c getBuildSimpleConversationRecord = TestDataFactory_Journey.buildSimpleConversationRecord( param_accountId,  param_conductedBy);
        String userId;
        AccountOwnerSystemUserCustomSetting__c getBuildCustomSettingRecord = TestDataFactory_Journey.buildCustomSettingRecord(userId);
    }
}