/**
 * Author : Golden Spikes Team
 * Date Created : 02/20/2020
 * @description : Test Class for OptyHotProspectPreferenceController Class.
 */
@isTest(seeAllData=false)
public class OptyHotProspectPreferenceController_TEST {
    private static final String HOT_PROSPECT_GROUPNAME_PREFIX = 'NewHotProspectNotifications-';
    private static User sysAdminUser;

    @TestSetup private static void setUpUserData() {
        insert new CS001_ByPassTriggerAll__c(Override_All__c = false);
        sysAdminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'sysAdm' + UTIL_TestUsername_TEST.getTestUsername());
        insert sysAdminUser;
        System.runAs(sysAdminUser) {
            UserRole agentUserRole = new UserRole(name = 'AgentRole');
            insert agentUserRole;

            UserRole atmUserRole = new UserRole(name = 'ATMMRole', parentRoleId = agentUserRole.id);
            insert atmUserRole;

            UserRole proxyUserRole = new UserRole(name = 'ProxyRole', parentRoleId = agentUserRole.id);
            insert proxyUserRole;

            User proxyUser = new User(alias = 'Prox',LastName='optyPrxy',Username='optyPrxy'+UTIL_TestUsername_TEST.getTestUsername(), UserExternalID__c='19ccww22zzc',Associate_ID__c='19ccww22zzc',Territory_Associate_ID__c='19ccww22zzc');
                
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser(proxyUser);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            User agentUser = new User(alias = 'Alia1',LastName='optyAgnt',Username='optyAgnt'+UTIL_TestUsername_TEST.getTestUsername(), UserExternalID__c='19ccww22zzc_19ccww22zzc',Associate_ID__c='19ccww22zzc',Territory_Associate_ID__c='19ccww22zzc',Servicing_Agent_Associate_ID__c='19ccww22zzc');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser(agentUser);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;

            User atmUser = new User(alias = 'Alia2',LastName='optyATM',Username='optyAtm'+UTIL_TestUsername_TEST.getTestUsername(), UserExternalID__c='20ccww22zzc_19ccww22zzc',Associate_ID__c='20ccww22zzc',Territory_Associate_ID__c='19ccww22zzc',Servicing_Agent_Associate_ID_List__c='19ccww22zzc',Territory_Associate_ID_List__c='19ccww22zzc');
            atmUser = UTIL_UserProvisioning_TEST.buildATMUser(atmUser);
            atmUser.userRoleId = atmUserRole.id;
            insert atmUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser, atmUser});

            CollaborationGroup hotProspectChatterGroup = new CollaborationGroup();
            hotProspectChatterGroup.Name = HOT_PROSPECT_GROUPNAME_PREFIX + agentUser.Alias;
            hotProspectChatterGroup.CollaborationType = 'Private';
            hotProspectChatterGroup.OwnerId = agentUser.Id;
            insert hotProspectChatterGroup;

            List<CollaborationGroupMember> groupMemberList = new List<CollaborationGroupMember>();
            groupMemberList.add(new CollaborationGroupMember(CollaborationGroupId = hotProspectChatterGroup.Id, MemberId = atmUser.Id, NotificationFrequency = 'P'));
            insert groupMemberList;
        }
    }

    @isTest private static void getLoggedInUserNotificationPreferencesReturnsPreferences() {
        System.runAs(getAgentUser()) {
            Test.startTest();
            String notificationPreference = OptyHotProspectPreferenceController.getLoggedInUserNotificationPreferences();
            Test.stopTest();
            System.assert(String.isNotBlank(notificationPreference), 'Invalid loggedInUserChatterPreference');
            validateLoggedInUserChatterPreference(notificationPreference);
        }
    }

    @isTest private static void testGetLoggedInUserChatterPreferenceAsATM() {
        System.runAs(getAtmUser()) {
            Test.startTest();
            String notificationPreference = OptyHotProspectPreferenceController.getLoggedInUserNotificationPreferences();
            Test.stopTest();
            System.assert(String.isNotBlank(notificationPreference), 'Invalid loggedInUserChatterPreference');
            validateLoggedInUserChatterPreference(notificationPreference);
        }
    }

    @SuppressWarnings('PMD.ApexUnitTestMethodShouldHaveIsTestAnnotation')
    private static void validateLoggedInUserChatterPreference(String loggedInUserChatterPreference) {
        Map<String, Object> chatterPreferenceResponseObject = (Map<String, Object>) JSON.deserializeUntyped(loggedInUserChatterPreference);
        System.assertEquals(HOT_PROSPECT_GROUPNAME_PREFIX + 'Alia1', chatterPreferenceResponseObject.get('groupName'), 'Invalid Chatter Group Name');
        System.assert(String.isBlank((String) chatterPreferenceResponseObject.get('groupURL')), 'Invalid Chatter Group URL');
        System.assert(chatterPreferenceResponseObject.get('loggedInUserNotificationPreferences') != null, 'Invalid Chatter Group Member Object');
        System.assert(!((Boolean) chatterPreferenceResponseObject.get('isError')), 'Invalid Fetch Error Flag');
    }

    @isTest private static void updateLoggedInUserNotificationPreferencesUpdatesPreferences() {
        User agentUser = getAgentUser();
        System.runAs(agentUser) {
            Test.startTest();
            Id npId = getNotificationPreferenceId(agentUser.Id);
            String isUpdateSuccess = OptyHotProspectPreferenceController.updateLoggedInUserNotificationPreferences(new NotificationPreference__c(Id=npId,enableSFComSkype__c=true),(HOT_PROSPECT_GROUPNAME_PREFIX + 'Alia1'));
            Test.stopTest();
            System.assertEquals(isUpdateSuccess, '','Expected value is '+isUpdateSuccess+', but actual value is empty');
        }
    }

    @isTest private static void testupdateChatterPreferenceAsATM() {
        User agentUser = getAgentUser();
        System.runAs(getAtmUser()) {
            Test.startTest();
            Id npId = getNotificationPreferenceId(agentUser.Id);
            String isUpdateSuccess = OptyHotProspectPreferenceController.updateLoggedInUserNotificationPreferences(new NotificationPreference__c(Id=npId,enableSFComSkype__c=true),(HOT_PROSPECT_GROUPNAME_PREFIX + 'Alia1'));
            Test.stopTest();
            System.assertEquals('', isUpdateSuccess,'Expected value is empty, but actual value is '+isUpdateSuccess);
        }
    }
    
    @isTest private static void testupdateChatterPreferenceAsATMSetAllValuesToFalse() {
        User agentUser = getAgentUser();
        User atmUser = getAtmUser();
        System.runAs(agentUser) {
            Test.startTest();
            NotificationPreference__c atmNp = new NotificationPreference__c(notificationGroupMemberId__c = atmUser.Id);
            atmNp.enableILPEmail__c=false;
            atmNp.enableILPSkype__c=false;
            insert atmNp;
            Id npId = getNotificationPreferenceId(agentUser.Id);
            String isUpdateSuccess = OptyHotProspectPreferenceController.updateLoggedInUserNotificationPreferences(new NotificationPreference__c(Id=npId,enableILPSkype__c=false,enableILPEmail__c=false),(HOT_PROSPECT_GROUPNAME_PREFIX + 'Alia1'));
            Test.stopTest();
            System.assertEquals('\n All Internet Lead Provider notifications have been turned off for all members of your office.', isUpdateSuccess,'Expected value is : \n All Internet Lead Provider notifications have been turned off for all members of your office. , but actual value is '+isUpdateSuccess);
        }
    }

    private static User getAgentUser() {
        return [SELECT Id, Alias FROM User WHERE UserExternalId__c = '19ccww22zzc_19ccww22zzc' LIMIT 1];
    }

    private static User getAtmUser() {
        return [SELECT Id, Alias FROM User WHERE UserExternalId__c = '20ccww22zzc_19ccww22zzc' LIMIT 1];
    }
    
    private static Id getNotificationPreferenceId(Id userId) {
        NotificationPreference__c np = new NotificationPreference__c(NotificationGroupMemberId__c = userId);
        insert np;
        return np.Id;
    }
}