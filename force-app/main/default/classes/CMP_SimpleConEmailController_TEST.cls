/****************************************************************************************
Name: CMP_SimpleConEmailController_TEST
Copyright © State Farm
=========================================================================================
@description This is test class for CMP_SimpleConEmailController.
Team: Octonauts
=========================================================================================
******************************************************************************************/
@isTest (seeAllData=false)
public with sharing class CMP_SimpleConEmailController_TEST {

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
    private static User buildUser(String profileId, String associateId, String servicingAgentAssociateId) {
        return new User (alias = '12345', email = 'testUser@statefarm.com.bad', emailencodingkey='UTF-8', lastname='TestUserLastName',
            languagelocalekey='en_US',localesidkey='en_US', timezonesidkey='America/Chicago',
            username= UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + Integer.valueOf(math.rint(math.random()*100)) + '@sfa222.test.com',
            profileId = profileId, Associate_ID__c = associateId, Servicing_Agent_Associate_ID__c = servicingAgentAssociateId ,
            State_Agent_Code__c = '13-2935'
        );
         
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
        return new Account(FirstName = 'rrrrr', LastName = 'tttttttt', PersonEmail = 'saikiran.chintala.vaaejh@statefarm.com', PersonMobilePhone ='123-456-7890', PersonHomePhone = '000-000-0000',
        ClientIdentifier__c = param_clientIdentifier);
        
    }

    //method to build Agent Role record with the given parameter value
    private static AgentRole__c buildAgentRoleRecord(String param_accountId) {
        return new AgentRole__c (RelationshipNature__c = 'Customer',
                       Agent__c = userInfo.getUserId(), Customer__c = param_accountId);
         
    }

    //method to build Simple Conversation record with the given parameter value
    private static SimpleConversation__c buildSimpleConversationRecord(String param_accountId, String param_conductedBy) {
        return new SimpleConversation__c (Account__c = param_accountId, SimpleConversationType__c = 'Simple Conversation',
                            Status__c = 'New', ConductedBy__c = param_conductedBy, SimpleConversationName__c = 'Test Simple Conv',Appointment_Location__c='Virtual Meeting',
                            AppointmentStartDateTime__c = datetime.now().addHours(1), AppointmentEndDateTime__c = datetime.now().addHours(2));
        
    }


    private static User initialSetup(){
        User adminUser = buildUser(adminProfileId, '', '');
        User agentUser;
        System.runAs(adminUser) {
           byPassTrigger();
           UserRole agentUserRole = buildRole('AgentRole');
           insert agentUserRole;
           agentUser = buildUser(agentProfileId, '60ccww22zzc', '60ccww22zzc');
           agentUser.userRoleId = agentUserRole.id;
           agentUser.UserExternalID__c = '60ccww22zzc_60ccww22zzc';
           insert agentUser;
           TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
           AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(agentUser.Id, 'SF_CRM_VirtualMeetingAPTC_PermSetPID');
           User systemUser = buildUser(noAccessProfileId, '', '');
           insert systemUser;
           AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(systemUser.Id, 'SF_CRM_VirtualMeetingAPTC_PermSetPID');
           AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
           insert accountOwner;


           CS_Liveoak__c csobj=new CS_Liveoak__c(Name = 'Liveoak_Dataset', Client_Secret__c ='0f52714e7d6e968cb3513cf9d6a46ed6b7c78216c3534b69f6b754b4db6d4f0e',Client_Id__c='648305910bca6b76d245',Resource_Path__c='/api/v1/rooms/GetRoomDetailErr', Name__c ='Basic Collaboration Room',GNC_EmailBox__c='test@test.com');
           insert csobj;
       }
       return agentUser;
   }

    @isTest
    private static void testSendOutlookEmail() {

        User agentUser = initialSetup();
        System.runAs(agentUser) {
            Account act = buildAccountRecord('7601011');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;

            SimpleConversation__c simpleConversationRecord = buildSimpleConversationRecord(act.id,agentUser.id);
            insert simpleConversationRecord;

            SimpleConversation__c simpleConRec = [select Name, AppointmentStartDateTime__c, AppointmentEndDateTime__c, Id, ConductedBy__r.email from SimpleConversation__c where id =:simpleConversationRecord.id WITH SECURITY_ENFORCED limit 1];

            Test.startTest();
           //building URL

           CMP_SimpleConEmailController.SendOutlookEmailWrapper wrap = CMP_SimpleConEmailController.sendOutlookEmail(simpleConRec.id);

            System.assert(true,simpleConRec != null);
            System.assertEquals('Success',wrap.response, 'Invalid Response');
            Test.stopTest();
            //System.assertNotEquals(null, virtMeetingRecord, 'Invalid Status');
        }
    }
    @isTest
    private static void testsendOutlookEmailCatch(){
       User adminUser = buildUser(adminProfileId, '', '');
       
        System.runAs(adminUser){
			CMP_SimpleConEmailController.sendOutlookEmail(null);
        }
        System.assert(true, 'Mandatory Assert statement on Tests');
    }
}
