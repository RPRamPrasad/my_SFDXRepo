/**
* Author : Golden Spikes Team
* Date Created : 08/14/2018
* @description : Test class for the VFC_UserOfficeInformationController apex class.
*/

@isTest(seeAllData=false)
private class VFC_UserOfficeInformationController_Test {
     private static final String SECONDS_FORMAT= 'ssSSS';
     private static String adminProfileId = getProfileId(UTIL_Constants.SYSTEM_ADMIN_PROFILE_NAME);
     private static String agentProfileId = getProfileId(UTIL_Constants.AGENT_PROFILE_NAME);
     private static String agentTeamMemberProfileId = getProfileId(UTIL_Constants.ATM_PROFILE_NAME);
     private static String salesLeaderProfileId = getProfileId(UTIL_Constants.SALESLEADER_PROFILE_NAME);
     private static User agentUser;
     private static User atmUser;
     private static User salesLeaderUser;
     private static string sandboxName=UTIL_UserBatchProcess.getSandboxName();
     private static User buildUserRec = new User(username =UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'tst1_Query1LoggedInUserInfo1Admn1' + '@sfa111.test.com',profileId = adminProfileId,Associate_ID__c = '',Servicing_Agent_Associate_ID__c = '',Servicing_Agent_Associate_ID_List__c = '',UserExternalID__c = '');
    //To use mock common admin User
    private static final User ADMINUSER = buildUser(buildUserRec);
    
    //method to bypass Trigger
    private static void byPassTrigger() {
        CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c();
        objectBasedByPassTrigger.Override_All__c = true;
        insert objectBasedByPassTrigger;
    }

    //method to get the ProfileId for the given Profile Name
    private static String getProfileId(String profileName) {
        String profileId = [SELECT Id FROM Profile WHERE name =: profileName LIMIT 1].Id;
        return profileId;
    }

    //method to build user with the given parameter value
    private static User buildUser(User paramUser) {
        User testUser = new User (alias = '12345', email = 'testUser@statefarm.com.bad', emailencodingkey='UTF-8', lastname='TestUserLastName',
            languagelocalekey='en_US',localesidkey='en_US', timezonesidkey='America/Chicago', 
            username= paramUser.username, profileId = paramUser.profileId,
            Associate_ID__c = paramUser.Associate_ID__c, Servicing_Agent_Associate_ID__c = paramUser.Servicing_Agent_Associate_ID__c,
            Servicing_Agent_Associate_ID_List__c = paramUser.Servicing_Agent_Associate_ID_List__c, UserExternalID__c = paramUser.UserExternalID__c
        );
        return testUser;
    }

    //method to build userrole with the given parameter value
    private static UserRole buildUserRole(String roleName) {
        UserRole role = new UserRole(name = roleName);
        return role;
    }

    //method to build userrole with parentRole with the given parameter value
    private static UserRole buildUserRoleWithParent(String roleName, String parentRole) {
        UserRole role = new UserRole(name = roleName, parentRoleId = parentRole);
        return role;
    }    

    @TestSetup
    static void makeData(){
        System.runAs(ADMINUSER){
            byPassTrigger();
        }
        UserRole salesLeaderRole = buildUserRole('SalesLeaderRole');
        insert salesLeaderRole;

        UserRole agentUserRole = buildUserRoleWithParent('AgentRole',salesLeaderRole.id);
        insert agentUserRole;
        
        UserRole atmUserRole = buildUserRoleWithParent('ATMRole', agentUserRole.id);
        insert atmUserRole;
        
        User buildUserRec = new User(username =UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'LoggedInUserInfo1Agnt1' + '@sfa111.test.com',profileId = agentProfileId,Associate_ID__c = 'mmccww11ttc',Servicing_Agent_Associate_ID__c = 'mmccww11ttc',Servicing_Agent_Associate_ID_List__c = 'mmccww11ttc',UserExternalID__c = 'mmccww11ttc_mmccww11ttc');
        agentUser = buildUser(buildUserRec);
        agentUser.userRoleId = agentUserRole.id;
        agentUser.firstName = 'TestFirst';
        agentUser.lastName = 'Agt1 rrrr 13-2536';
        
        buildUserRec = new User(username =UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'LoggedInUserInfo2ATM1' + '@sfa222.test.com',profileId = agentTeamMemberProfileId,Associate_ID__c = 'zzccww11ttc',Servicing_Agent_Associate_ID__c = 'mmccww11ttc',Servicing_Agent_Associate_ID_List__c = 'mmccww11ttc',UserExternalID__c = 'zzccww11ttc_mmccww11ttc');
        atmUser = buildUser(buildUserRec);
        atmUser.userRoleId = atmUserRole.id;
        atmUser.lastName = 'ATM1 r1xy 13-2536';

        buildUserRec = new User(username =UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'LoggedInUserInfo3salesL3' + '@sfa333.test.com',profileId = salesLeaderProfileId,Associate_ID__c = '',Servicing_Agent_Associate_ID__c = '',Servicing_Agent_Associate_ID_List__c = '',UserExternalID__c = 'yyccww11ttc_mmccww11ttc');
        salesLeaderUser = buildUser(buildUserRec);
        salesLeaderUser.userRoleId = salesLeaderRole.id;

        insert new List<User>{agentUser,atmUser,salesLeaderUser};
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser,atmUser,salesLeaderUser});

    }
    //get Agent 
    private static void getUsers(){
        List<User> userlist = [SELECT Id, Username, Associate_ID__c, 
        Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, 
        Servicing_Agent_External_ID__c, UserExternalID__c, 
        Agent_Name_Alias__c, UserType__c FROM User where 
        UserExternalID__c in ('mmccww11ttc_mmccww11ttc','zzccww11ttc_mmccww11ttc',
        'yyccww11ttc_mmccww11ttc') order by UserExternalID__c];
        agentUser = userlist.get(0);
        atmUser = userlist.get(2);
        salesLeaderUser = userlist.get(1);

    }
    //method to test loggedIn As user information for Single Atm user.
    @isTest
    private static void testLoggedInAsUserInfoAsSingleAtmUser() {
        getUsers();
        Test.StartTest();
        System.runas(atmUser) {
            VFC_UserOfficeInformationController controller = new VFC_UserOfficeInformationController();
            controller.queryOfficeInformation();
            system.assertEquals(controller.officeName, Label.CL_USER_LOGGED_IN_OFFICE + ' TestFirst Agt1 rrrr 13-2536', 'Expected label value is'+controller.officeName+', but actual value is'+Label.CL_USER_LOGGED_IN_OFFICE + ' TestFirst Agt1 rrrr 13-2536');
        }
        Test.StopTest();
    }

    //method to test loggedIn office information for Shared Agent user.
    @isTest
    private static void testLoggedInAsUserInfoAsSharedAgentUser() {
        getUsers();
        System.runAs(ADMINUSER) {
            agentUser.Servicing_Agent_Associate_ID_List__c = 'mmccww11ttc,mmccww11ppc';
            update agentUser;
        }

        Test.StartTest();
        System.runas(agentUser) {
            VFC_UserOfficeInformationController controller = new VFC_UserOfficeInformationController();
            controller.queryOfficeInformation();
            system.assertEquals(controller.officeName, Label.CL_USER_LOGGED_IN_OFFICE + ' TestFirst Agt1 rrrr 13-2536', 'Expected label value is'+controller.officeName+', but actual value is'+Label.CL_USER_LOGGED_IN_OFFICE + ' TestFirst Agt1 rrrr 13-2536');
        }
        Test.StopTest();
    }

    //method to test loggedIn As user information for SalesLeader user.
    @isTest
    private static void testLoggedInAsUserInfoAsSalesLeaderUser() {
        getUsers();
        Test.StartTest();
        System.runas(salesLeaderUser) {
            VFC_UserOfficeInformationController controller = new VFC_UserOfficeInformationController();
            controller.queryOfficeInformation();
            system.assertEquals(controller.officeName, Label.CL_USER_LOGGED_IN_AS + ' TestUserLastName', 'Expected value is'+controller.officeName+', but actual value is'+Label.CL_USER_LOGGED_IN_AS + ' TestUserLastName');
        }
        Test.StopTest();
    }
}
