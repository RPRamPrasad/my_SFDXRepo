@isTest
(seeAllData = false)
private class ActivityControllerTest {
    private static final String CLIENT_IDENTIFIER1 = '12345678909';
    private static final String CLIENT_IDENTIFIER2 = '98765432101';
    private static final String ACTIVITY_OUTLINE_FILTER_PREFERENCE = '[{\"objectName\":\"Account\", \"activityTypes\":[\"Case\",\"Event\",\"log_a_call\",\"Account_Note__c\",\"Opportunity\",\"Task\",\"Virtual_Meeting__c\"]},{\"objectName\":\"Case\",\"activityTypes\":[\"Case_Note__c\",\"Task\"]},{\"objectName\":\"Opportunity\",\"activityTypes\":[\"Event\",\"Task\"]}]';
    private static Account account1;
    private static Account account2;
    private static Account household;
    private static List<Account> accounts;

    @testSetup
    private static void testSetup() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        TestUserSetupUtility.setupSystemAdminUser();
    }

    @isTest
    private static void testGetHouseholdMembers() {
        System.runAs(TestUserSetupUtility.getSysAdminUser()) {
            createAccounts();
            insert accounts;
            createHousehold();
            updateAccountsWithHHId();

            Test.startTest();
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.household');
            sessionPart.put(household.id, account1.Id);
            List<Account> hhMembers = ActivityController.getHouseholdMembers(household.id);
            Test.stopTest();

            System.assertEquals(2, hhMembers.size(), 'household members were not found');
        }
    }

    @isTest
    private static void testGetRecentlyAccessedAccountId() {
        System.runAs(TestUserSetupUtility.getSysAdminUser()) {
            createAccounts();
            insert accounts;
            createHousehold();
            updateAccountsWithHHId();

            Test.startTest();
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.household');
            sessionPart.put(household.id, account1.Id);
            String accountId = ActivityController.getRecentlyAccessedAccountId(household.id);
            Test.stopTest();

            System.assertEquals(account1.Id, accountId, 'household members were not found');
        }
    }

    @isTest
    private static void testGetPilotField() {
        User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');

        agent.Pilot_User_6__c = 'test pilot field';
        agent = TestDataFactory_User.insertUser(agent);

        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agent);
        System.runAs(agent) {
            test.startTest();
            String userPilotField = ActivityController.getPilotField();
            test.stopTest();

            System.assertEquals(agent.Pilot_User_6__c, userPilotField, 'Pilot field strings did not match.');
        }
    }

    @isTest
    private static void testRetrieveActivityOutlineFilterPreferences() {
        User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');

        agent.Activity_Outline_Filter_Preferences__c = ACTIVITY_OUTLINE_FILTER_PREFERENCE;
        agent = TestDataFactory_User.insertUser(agent);

        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agent);
        System.runAs(agent) {
            test.startTest();
            String preference = ActivityController.getActivityOutlineFilterPreference();
            test.stopTest();

            System.assertEquals(agent.Activity_Outline_Filter_Preferences__c, preference, 'Preference strings did not match.');
        }
    }

    @isTest
    private static void testRetrieveHouseholdNavigatorFilterPreferences() {
        User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');

        agent.Activity_Outline_Filter_Preferences__c = ACTIVITY_OUTLINE_FILTER_PREFERENCE;
        agent = TestDataFactory_User.insertUser(agent);

        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agent);
        System.runAs(agent) {
            test.startTest();
            List<ActivityController.PreferenceItem> userPrefs = ActivityController.getHouseholdNavigatorFilterPreference();
            test.stopTest();

            System.assertEquals(3, userPrefs.size(), 'Unexpected number of preference items returned');
            System.assertEquals('Account', userPrefs[0].objectName, 'Value from JSON not populated correctly');
            System.assertEquals('Case', userPrefs[1].objectName, 'Value from JSON not populated correctly');
            System.assertEquals('Opportunity', userPrefs[2].objectName, 'Value from JSON not populated correctly');
        }
    }

    @isTest
    private static void testRetrieveDefaultPreferenceItem() {
        User agent = TestDataFactory_user_wrapper.generateAgentUser('TEST', '1234568901');

        agent = TestDataFactory_User.insertUser(agent);

        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agent);
        System.runAs(agent) {
            test.startTest();
            ActivityController.PreferenceItem preferences = new ActivityController.PreferenceItem();
            test.stopTest();

            System.assertEquals(0, preferences.activityTypes.size(), 'Unexpected number of default activity types returned.');
            System.assertEquals(0, preferences.activitySettings.size(), 'Unexpected number of default activity settings returned');
            System.assertEquals('', preferences.objectName, 'Unexpected objectName default value returned.');
            System.assertEquals('3.3', preferences.version, 'Unexpected version default value returned.');
        }
    }

    @isTest
    private static void testUpdatePreferencesFromActivityOutlineFilters() {
        User user = TestDataFactory_User_Wrapper.generateTechnicalSupportUser('OHQWE', '1234590876');
        insert user;

        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(user);
        System.runAs(user) {
            Test.startTest();
            Boolean updateResult = ActivityController.updatePreferencesFromActivityOutlineFilters(ACTIVITY_OUTLINE_FILTER_PREFERENCE);
            Test.stopTest();

            User updatedUser = getUser(user.Id);

            System.assert(updateResult, 'Activity Outline Filter Preferences update failed');
            System.assertEquals(updatedUser.Activity_Outline_Filter_Preferences__c, ACTIVITY_OUTLINE_FILTER_PREFERENCE, 'User preferences does not match expected value');
        }
    }

    @isTest
    private static void testUpdatePreferencesFromActivityOutlineFiltersError() {
        User user = TestDataFactory_User_Wrapper.generateTechnicalSupportUser('OHQWE', '1234590876');
        insert user;

        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(user);
        System.runAs(user) {
            Test.startTest();
            try{
                ActivityController.isCatch = true;
                Boolean updateResult = ActivityController.updatePreferencesFromActivityOutlineFilters(ACTIVITY_OUTLINE_FILTER_PREFERENCE);  
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage(), 'Expected exception to match.');   
            }         
            Test.stopTest();  
                 
        }
    }

    @isTest
    private static void testUpdatePreferencesFromActivityOutlineSettings() {
        User user = TestDataFactory_User_Wrapper.generateTechnicalSupportUser('OHQWE', '1234590876');
        insert user;

        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(user);
        System.runAs(user) {
            Test.startTest();
            Boolean updateResult = ActivityController.updatePreferencesFromActivityOutlineSettings(ACTIVITY_OUTLINE_FILTER_PREFERENCE);
            Test.stopTest();

            User updatedUser = getUser(user.Id);

            System.assert(updateResult, 'Activity Outline Filter Preferences update failed');
            System.assertEquals(updatedUser.Activity_Outline_Filter_Preferences__c, ACTIVITY_OUTLINE_FILTER_PREFERENCE, 'User preferences does not match expected value');
        }
    }

    @isTest
    private static void testUpdatePreferencesFromActivityOutlineSettingsError() {
        User user = TestDataFactory_User_Wrapper.generateTechnicalSupportUser('OHQWE', '1234590876');
        insert user;

        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(user);
        System.runAs(user) {
            Test.startTest();
            try{
                ActivityController.isCatch = true;
                Boolean updateResult = ActivityController.updatePreferencesFromActivityOutlineSettings(ACTIVITY_OUTLINE_FILTER_PREFERENCE);  
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage(), 'Expected exception to match.');   
            }        
            Test.stopTest();
        }
    }

    @isTest
    private static void testUpdatePreferencesFromVersioning() {
        User user = TestDataFactory_User_Wrapper.generateTechnicalSupportUser('OHQWE', '1234590876');
        insert user;

        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(user);
        System.runAs(user) {
            Test.startTest();
            Boolean updateResult = ActivityController.updatePreferencesFromVersioning(ACTIVITY_OUTLINE_FILTER_PREFERENCE);
            Test.stopTest();

            User updatedUser = getUser(user.Id);

            System.assert(updateResult, 'Activity Outline Filter Preferences update failed');
            System.assertEquals(updatedUser.Activity_Outline_Filter_Preferences__c, ACTIVITY_OUTLINE_FILTER_PREFERENCE, 'User preferences does not match expected value');
        }
    }

    @isTest
    private static void testUpdatePreferencesFromVersioningError() {
        User user = TestDataFactory_User_Wrapper.generateTechnicalSupportUser('OHQWE', '1234590876');
        insert user;

        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(user);
        System.runAs(user) {
            Test.startTest();
            try{
                ActivityController.isCatch = true;
                Boolean updateResult = ActivityController.updatePreferencesFromVersioning(ACTIVITY_OUTLINE_FILTER_PREFERENCE);  
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage(), 'Expected exception to match.');   
            }     
            Test.stopTest();
        }
    }

    private static void createAccounts() {
        account1 = new Account(
            FirstName = 'FirstName1',
            LastName = 'LastName1',
            BillingAddressType__c = 'US',
            ClientIdentifier__c = CLIENT_IDENTIFIER1
        );

        account2 = new Account(
            FirstName = 'FirstName2',
            LastName = 'LastName2',
            BillingAddressType__c = 'US',
            ClientIdentifier__c = CLIENT_IDENTIFIER2
        );

        accounts = new List<Account>();
        accounts.add(account1);
        accounts.add(account2);
    }

    private static void createHousehold() {
        Id hhRecordtype = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName()
            .get('IndustriesHousehold')
            .getRecordTypeId();
        household = new Account(Name = 'Household', recordTypeId = hhRecordtype, AllowHousehold__c = true);
        insert household;
    }

    private static void updateAccountsWithHHId() {
        for (Account account : accounts) {
            account.Primary_Household__pc = household.Id;
        }
        update accounts;
    }

    private static User getUser(Id userId) {
        return [SELECT Activity_Outline_Filter_Preferences__c FROM User WHERE Id =: userId];
    }
}