/**
 * Author : Team Moneyball
 * Date Created : 10/18/2022
 * @description : test for class ClaimHighlightPanelController
 * Version : 1.0
 */

@isTest
public with sharing class ClaimHighlightPanelController_Test {
    /**
     * @description Prepare  setup by disabling triggers
     */
    @TestSetup
    public static void setup() {
        disableTriggers();
        
        HttpRequestCalloutHelper_Test.insertContinuationRecord('MockREST', 'https://mock.callout/request/{0}', '');
    }

    private static void disableTriggers() {
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;

        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(
            false,
            systemUser
        );
        insert passTriggerAll;

        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(
            systemUser
        );
        objectBasedByPassTrigger.Override_AgentRoleAfterInsert__c = false;
        objectBasedByPassTrigger.Override_AgentRoleBeforeDelete__c = false;
        insert objectBasedByPassTrigger;

        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(
            systemUser.id
        );
        insert sysAdminUserIdSetting;

        TestDataFactory_Claim.byPassClaimAfterTriggers();
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
    }
    /**
     * @name getIndicatortest
     * @description verifies that claim getIndicator for Auto claims
     */
    @isTest
    public static void getIndicatorTest() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        Account claimAccount = TestDataFactory_Account.createIndividualCustomer('testAccntxxx');
        insert claimAccount;
        InsurancePolicy policy = TestDataFactory_Claim.createInsurancePolicy('policy11', claimAccount);
        List<Claim> claims = TestDataFactory_Claim.generateClaims(2, claimAccount, policy);
        claims.get(0).ProdLineCd__c = 'A';
        claims.get(1).ProdLineCd__c='F';
        claims = TestDataFactory_Claim.insertClaims(claims);

        List<ClaimParticipant> claimParticipants = TestDataFactory_Claim.generateClaimParticipants(
            claims,
            claimAccount.Id,
            'C'
        );
        claimParticipants.get(0).DeceasedIndicator__c = true;
        insert claimParticipants;

        List<ClaimParticipant> claimParticipants1 = TestDataFactory_Claim.generateClaimParticipants(
            claims,
            claimAccount.Id,
            'C'
        );
        claimParticipants1.get(0).TotalLossIndicator__c = true;
        insert claimParticipants1;

        ClaimHighlightPanelController.IndicatorWrapper indicatorWrap = ClaimHighlightPanelController.getIndicator(
            claims.get(0).Id,true
        );
        ClaimHighlightPanelController.IndicatorWrapper indicatorWrap1;
        indicatorWrap1 = ClaimHighlightPanelController.getIndicator(
            claims.get(1).Id,false
        );
        system.assert(indicatorWrap.totalloss, true);
        system.assert(indicatorWrap.deceasedIndicator, true);
        system.assertEquals(indicatorWrap1, null,'null');
    }

    @isTest
    public static void getRestInfoTest() {
        Map<String,Object> input =inputParameters();
        Test.setMock(HttpCalloutMock.class, new HttpRequestCalloutResponseMockGenerator(200,'{payload:"value"}' ));

        Test.startTest();
        HttpRequestCalloutHelper.HttpCalloutResponse response  = ClaimHighlightPanelController.getVehicleInfo(input);
        HttpRequestCalloutHelper.HttpCalloutResponse response2 = ClaimHighlightPanelController.getParticipantInfo(input);
        Test.stopTest();
        System.assertNotEquals(null, response,  'not null');
        System.assertNotEquals(null, response2, 'not null');
    }

    @isTest
    public static void getVehicleInfoFailedTest() {
        try {
            Test.startTest();
                ClaimHighlightPanelController.getVehicleInfo(inputParameters());
            Test.stopTest();
        } catch (Exception e) {
            System.assertEquals(System.AuraHandledException.class.getName(), e.getTypeName(), 'AuraHandledException is expected');
        }
    }
    
    @isTest
    public static void getClaimParticipantFailedTest() {
        try {
            Test.startTest();
                ClaimHighlightPanelController.getParticipantInfo(inputParameters());
            Test.stopTest();
        } catch (Exception e) {
            System.assertEquals(System.AuraHandledException.class.getName(), e.getTypeName(), 'AuraHandledException is expected');
        }
    }
    
    private static Map<String,Object> inputParameters()
    {
        Map<String,Object> input = new Map<String, Object>();
        List<String> params = new List<String>();
        params.add('one');
        params.add('{payload:"value"}');
        input.put('calloutName', 'MockREST');
        input.put('calloutParams', params);
        return input;
    }

}