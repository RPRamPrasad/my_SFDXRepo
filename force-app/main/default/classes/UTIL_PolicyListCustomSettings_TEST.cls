
@isTest (seeAllData=false)
public with sharing class UTIL_PolicyListCustomSettings_TEST {

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
           AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(agentUser.Id, 'SF_CRM_VirtualMeetingAPTC_PermSetPID');
           
       }
       return agentUser;
   }

    @isTest
    private static void testPolicyListCustomSettings() {
        Test.startTest();
        CS_PolicyListPrint__c policyListCustomSetting=new CS_PolicyListPrint__c(Name='PolicyListPrint_DataSet',PolicyListPrint_URL__c = 'https://simpleconversation-env3.app-71a.opr.test.statefarm.org/PolicyListPrint-ui/v1/clientid/');
        insert policyListCustomSetting;
        CS_PolicyListPrint__c policyListPrintData = UTIL_PolicyListCustomSettings.getPolicyListCustomSettings(); 
        Test.stopTest();
        System.assertEquals('https://simpleconversation-env3.app-71a.opr.test.statefarm.org/PolicyListPrint-ui/v1/clientid/',policyListPrintData.PolicyListPrint_URL__c,'Invalid URL');
    }
    }
