/**
 * @name ClaimTriggerHandler_Test
 * @author NSYNC
 * @description Tests the ClaimTriggerHandler class.
 */
@isTest(seeAllData=false)
public with sharing class ClaimTriggerHandler_Test {
    private static final String CLAIM_SYNC_NAME = 'SF_CRM_FSCCLAIMSYNC';

    /**
    * @name setup
    * @description creates the users and configures the custom settings to allow data to be created
    */
    @TestSetup
    public static void setup() {
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(systemUser);
        
        User claimSyncUser = UTIL_UserProvisioning_TEST.buildUserWith103APIProfile();
        claimSyncUser.LastName = CLAIM_SYNC_NAME;
        insert claimSyncUser;

        System.runAs(systemUser) {
            PermissionSet psFSC = [SELECT Id, Name FROM PermissionSet WHERE Name='FSCInsurance'];
            PermissionSet psSync = [SELECT Id, Name FROM PermissionSet WHERE Name='SF_CRM_FSCClaimSync_PermSet'];
            List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment> {
                new PermissionSetAssignment(AssigneeId=claimSyncUser.Id, PermissionSetId=psFSC.Id),
                new PermissionSetAssignment(AssigneeId=claimSyncUser.Id, PermissionSetId=psSync.Id)
            };
            insert assignments;

            CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false, systemUser);
            insert passTriggerAll;
        }
    }

    /**
    * @name testHandleAfterInsert_claimSyncUser_toggledOn
    * @description verifies that operations, such as ClaimShare management, would occur when run as the Claim Sync User
    */
    @isTest
    private static void testHandleAfterInsertClaimSyncUserToggledOn() {
        ClaimTriggerHandler.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_TRIGGER_TRANSACTION, true);

        Test.startTest();
        System.runAs(getClaimSyncUser()) {
            Claim claim = new Claim(Name = 'Test');
            insert claim;
        }
        Test.stopTest();
        
        System.assert(ClaimTriggerHandler.handledMockClaimSyncOperation, 'Operation was not handled');
    }

    /**
    * @name testHandleAfterInsert_claimSyncUser_toggledOff
    * @description verifies that operations, such as ClaimShare management, would occur when run as the Claim Sync User
    */
    @isTest
    private static void testHandleAfterInsertClaimSyncUserToggledOff() {
        ClaimTriggerHandler.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_TRIGGER_TRANSACTION, false);

        Test.startTest();
        System.runAs(getClaimSyncUser()) {
            Claim claim = new Claim(Name = 'Test');
            insert claim;
        }
        Test.stopTest();
        
        System.assert(ClaimTriggerHandler.handledMockClaimSyncOperation, 'Operation was not handled');
    }

    /**
    * @name testHandleAfterInsert_nonClaimSyncUser
    * @description verifies that operations, such as ClaimShare management, would not occur when run as a non-Claim Sync User
    */
    @isTest
    private static void testHandleAfterInsertNonClaimSyncUser() {
        Test.startTest();
        Claim claim = new Claim(Name = 'Test');
        insert claim;
        Test.stopTest();
        
        System.assertEquals(false, ClaimTriggerHandler.handledMockClaimSyncOperation, 'Operation was not ignored');
    }

    /**
    * @name testHandleAfterUpdate_claimSyncUser_toggledOn
    * @description verifies that operations, such as ClaimShare management, would occur when run as the Claim Sync User
    */
    @isTest
    private static void testHandleAfterUpdateClaimSyncUserToggledOn() {
        ClaimTriggerHandler.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_TRIGGER_TRANSACTION, true);

        User claimSyncUser = getClaimSyncUser();

        Claim claim = new Claim(Name = 'Test');
        System.runAs(claimSyncUser) {
            insert claim;
        }

        Test.startTest();
        System.runAs(claimSyncUser) {
            ClaimTriggerHandler.handledMockClaimSyncOperation = false;
            claim.Name = 'Updated';
            upsert claim;
        }
        Test.stopTest();
        
        System.assert(ClaimTriggerHandler.handledMockClaimSyncOperation, 'Operation was not handled');
    }

    /**
    * @name testHandleAfterUpdate_claimSyncUser_toggledOff
    * @description verifies that operations, such as ClaimShare management, would occur when run as the Claim Sync User
    */
    @isTest
    private static void testHandleAfterUpdateClaimSyncUserToggledOff() {
        ClaimTriggerHandler.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_TRIGGER_TRANSACTION, false);
        
        User claimSyncUser = getClaimSyncUser();

        Claim claim = new Claim(Name = 'Test');
        System.runAs(claimSyncUser) {
            insert claim;
        }

        Test.startTest();
        System.runAs(claimSyncUser) {
            ClaimTriggerHandler.handledMockClaimSyncOperation = false;
            claim.Name = 'Updated';
            upsert claim;
        }
        Test.stopTest();
        
        System.assert(ClaimTriggerHandler.handledMockClaimSyncOperation, 'Operation was not handled');
    }

    /**
    * @name testHandleAfterUpdate_nonClaimSyncUser
    * @description verifies that operations, such as ClaimShare management, would not occur when run as a non-Claim Sync User
    */
    @isTest
    private static void testHandleAfterUpdateNonClaimSyncUser() {
        Claim claim = new Claim(Name = 'Test');
        insert claim;

        Test.startTest();
        ClaimTriggerHandler.handledMockClaimSyncOperation = false;
        claim.Name = 'Updated';
        upsert claim;
        Test.stopTest();
        
        System.assertEquals(false, ClaimTriggerHandler.handledMockClaimSyncOperation, 'Operation was not ignored');
    }

    /**
    * @name testIsClaimSyncUser_claimSyncUser
    * @description verifies that the Claim Sync user is correctly identified.
    */
    @isTest
    private static void testIsClaimSyncUserClaimSyncUser() {
        Test.startTest();
        Boolean isClaimSyncUser = false;
        System.runAs(getClaimSyncUser()) {
            isClaimSyncUser = ClaimTriggerHandler.isClaimSyncUser();
        }
        Test.stopTest();

        System.assertEquals(true, isClaimSyncUser, 'This user should have been the Claim Sync user');
    }

    /**
    * @name testIsClaimSyncUser_nonClaimSyncUser
    * @description verifies that other users are determined to not be the Claim Sync user.
    */
    @isTest
    private static void testIsClaimSyncUserNonClaimSyncUser() {
        Boolean isClaimSyncUser = true;

        Test.startTest();
        isClaimSyncUser = ClaimTriggerHandler.isClaimSyncUser();
        Test.stopTest();

        System.assertEquals(false, isClaimSyncUser, 'This user should not be the Claim Sync user');
    }

    private static User getClaimSyncUser() {
        return [SELECT Id FROM User WHERE NAME = :CLAIM_SYNC_NAME LIMIT 1];
    }
}