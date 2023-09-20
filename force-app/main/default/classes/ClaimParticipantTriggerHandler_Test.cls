/**
 * @name ClaimParticipantTriggerHandler_Test
 * @author Moneyball
 * @description Tests the ClaimParticipantTriggerHandler class.
 */
@isTest(seeAllData=false)
public with sharing class ClaimParticipantTriggerHandler_Test {
    /**
    * @name setup
    * @description creates the users and configures the custom settings to allow data to be created
    */
    @TestSetup
    public static void setup() {
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;

        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false, systemUser);
        insert passTriggerAll;
    }

    /**
    * @name testHandleAfterInsertToggledOn
    * @description verifies that claim share insert operations occurs when toggled on
    */
    @isTest
    private static void testHandleAfterInsertToggledOn() {
        ClaimParticipantTriggerHandler.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIMANT_SHARES, true);
        Claim claim = new Claim();
        claim.Name = 'test claim 123';
        insert claim;

        Test.startTest();
        ClaimParticipant claimParticipant = new ClaimParticipant();
        claimParticipant.ClaimId  = claim.Id;
        insert claimParticipant;
        Test.stopTest();
        
        System.assertEquals(true, ClaimParticipantTriggerHandler.handledMockClaimParticipantInsertOperation, 'Operation was handled');
    }

    /**
    * @name testHandleAfterInsertToggledOff
    * @description verifies that operations, such as ClaimShare management, would occur when run as the Claim Sync User
    */
    @isTest
    private static void testHandleAfterInsertToggledOff() {
        ClaimParticipantTriggerHandler.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIMANT_SHARES, false);
        Claim claim = new Claim();
        claim.Name = 'test claim 123';
        insert claim;

        Test.startTest();
        ClaimParticipant claimParticipant = new ClaimParticipant();
        claimParticipant.ClaimId  = claim.Id;
        insert claimParticipant;
        Test.stopTest();
        
        System.assertEquals(false, ClaimParticipantTriggerHandler.handledMockClaimParticipantInsertOperation, 'Operation was not handled');
    }

}

