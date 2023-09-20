/**
 * Author : Golden Spikes Team
 * Date Created : 03/28/2023
 * @description : Test Class for OptOutPreferenceController Class.
 */
@isTest(seeAllData=false)
public class OptOutPreferenceController_TEST {

    @TestSetup
    private static void setUpUserData() {
        insert new CS001_ByPassTriggerAll__c(Override_All__c = false);
        User systemAdminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'sysAdm' + UTIL_TestUsername_TEST.getTestUsername());
        insert systemAdminUser;
        System.runAs(systemAdminUser) {
            UserRole agentUserRole = new UserRole(name = 'AgentRole');
            insert agentUserRole;
            UserRole atmUserRole = new UserRole(name = 'ATMMRole', parentRoleId = agentUserRole.id);
            insert atmUserRole;
            User testAgentUser1 = new User(Alias='Alia6',LastName='optyOptAgnt',Username='optAgnt' + UTIL_TestUsername_TEST.getTestUsername(),Associate_ID__c='19ccww22zzc',UserExternalID__c='19ccww22zzc_19ccww22zzc',Servicing_Agent_Associate_ID__c='19ccww22zzc');
            User agentNewUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
            agentNewUser.userRoleId = agentUserRole.id;
            agentNewUser.OptPreference__c = '1';
            agentNewUser.UserType__c = 'Agency';
            insert agentNewUser;
            User testNewATMUser = new User(Alias='Alia7',LastName='OptNATM',Username='optAtm' + UTIL_TestUsername_TEST.getTestUsername(),Associate_ID__c='20ccww22zzc',UserExternalID__c='20ccww22zzc_19ccww22zzc',Servicing_Agent_Associate_ID__c='19ccww22zzc',Territory_Associate_ID__c='TERRITID',Servicing_Agent_Associate_ID_List__c='19ccww22zzc',Territory_Associate_ID_List__c='TERRITID');
            User atmNewUser = UTIL_UserProvisioning_TEST.buildATMUser(testNewATMUser);
            atmNewUser.userRoleId = atmUserRole.id;
            atmNewUser.OptPreference__c = '1';
            atmNewUser.UserType__c = 'Agency';
            insert atmNewUser;
            User cccSalesUser = UTIL_UserProvisioning_TEST.buildCCCLicensedUser();
            cccSalesUser.UserExternalID__c = 'OptOutCCC';
            cccSalesUser.UserType__c = 'CCC';
            insert cccSalesUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentNewUser, atmNewUser,cccSalesUser});
        }
    }

    @isTest private static void testGetLoggedInUserOptOutPreferenceAsAgent() {
        System.runAs(getAgentUser()) {
            Test.startTest();
            User loggedInUserOptPreference = OptOutPreferenceController.getLoggedInUserOptOutPreference();
            Test.stopTest();
            System.assertEquals('1', loggedInUserOptPreference.OptPreference__c, 'Invalid Opt Out Preference value');
            System.assertEquals('Agency', loggedInUserOptPreference.UserType__c, 'Invalid Opt Out value');
        }
    }

    @isTest private static void testGetLoggedInUserOptOutPreferenceAsAtm() {
        System.runAs(getAtmUser()) {
            Test.startTest();
            User loggedInUserOptPreference = OptOutPreferenceController.getLoggedInUserOptOutPreference();
            Test.stopTest();
            System.assertEquals('1', loggedInUserOptPreference.OptPreference__c, 'Invalid Opt Out Preference value');
            System.assertEquals('Agency', loggedInUserOptPreference.UserType__c, 'Invalid Opt Out value');
        }
    }
    
    @isTest private static void testGetLoggedInUserOptOutPreferenceAsCCC() {
        System.runAs(getCCCUser()) {
            try {
            	Test.startTest();
            	User loggedInUserOptPreference = OptOutPreferenceController.getLoggedInUserOptOutPreference();
            	Test.stopTest();
                System.assertEquals('CCC', loggedInUserOptPreference.UserType__c, 'Invalid Opt Out value');
            } catch (Exception e) {
            	System.assertEquals(System.AuraHandledException.class.getName(), e.getTypeName(), 'AuraHandledException is expected');
        	}
       }
    }

    @isTest private static void testUpdateOptOutAsAgent() {
        System.runAs(getAgentUser()) {
            Test.startTest();
            Boolean updateOptOutPreference = OptOutPreferenceController.updateOptOutPreference('1');
            Test.stopTest();
            System.assert(updateOptOutPreference, 'Opt Out Preference update failed');
        }
    }

    @isTest private static void testUpdateOptOutAsAtm() {
        System.runAs(getAtmUser()) {
            Test.startTest();
            Boolean updateOptOutPreference = OptOutPreferenceController.updateOptOutPreference('0');
            Test.stopTest();
            System.assert(updateOptOutPreference, 'Opt Out Preference update failed');
        }
    }

    private static User getCCCUser() {
        return [SELECT Id FROM User WHERE UserExternalId__c = 'OptOutCCC' LIMIT 1];
    }
    
    private static User getAgentUser() {
        return [SELECT Id, Alias FROM User WHERE UserExternalId__c = '19ccww22zzc_19ccww22zzc' LIMIT 1];
    }

    private static User getAtmUser() {
        return [SELECT Id, Alias FROM User WHERE UserExternalId__c = '20ccww22zzc_19ccww22zzc' LIMIT 1];
    }
}
