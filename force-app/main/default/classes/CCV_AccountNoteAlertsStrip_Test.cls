/**
 * @description This class is used to cover apex CCV_AccountNoteAlertsStrip
 * @Date: 12/24/2022
 * @author: Team Atlas
 */

@isTest(SeeAllData=false)
public with sharing class CCV_AccountNoteAlertsStrip_Test {
    @testsetup
    static void testSetupData() {
        CCV_TestDataFactoryAllObjects.insertAccountWithHousehold();
        Account acctRec = [
            SELECT Id, Primary_Household__pc, PersonContactId
            FROM Account
            WHERE ClientIdentifier__c = :CCV_TestDataFactoryAllObjects.ACCOUNT_ONE_CLIENT_ID
        ];
        User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', 'ATLS5678ASC');
        agent = TestDataFactory_User.insertUser(agent);
        CCV_TestDataFactoryAllObjects.insertInsurancePolicy(acctRec, agent);
    }

    @isTest
    private static void testFetchAccountNoteAlertsError() {
        List<CCV_AccountNoteAlertsStrip.AccountAlert> wrapper = new List<CCV_AccountNoteAlertsStrip.AccountAlert>();
        Test.startTest();
        try {
            wrapper = CCV_AccountNoteAlertsStrip.fetchAccountNoteAlerts(null, 'Account');
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Exception thrown');
        }
        Test.stopTest();
        System.assertEquals(true, wrapper.isEmpty(), 'Account should not return the AccountNote alerts');
    }

    @isTest
    private static void testFetchAccountNoteAlertsAllObjects() {
        Account acctRec = [
            SELECT Id, Primary_Household__pc, PersonContactId, ClientIdentifier__c
            FROM Account
            WHERE ClientIdentifier__c = :CCV_TestDataFactoryAllObjects.ACCOUNT_ONE_CLIENT_ID
        ];
        InsurancePolicy insPlcyRec = [
            SELECT Id, NameInsuredId, FinServ__Household__c
            FROM InsurancePolicy
            WHERE SourceSystemIdentifier = :CCV_TestDataFactoryAllObjects.POLICY_PRIVATE_PASSENGER_SRC_SYS_ID
        ];
        User agent = [SELECT Id FROM User WHERE Associate_ID__c = 'ATLS5678ASC'];
        Case caseRec = CCV_TestDataFactoryAllObjects.insertCase(acctRec, agent, insPlcyRec);
        Opportunity opptyRec = CCV_TestDataFactoryAllObjects.insertOpportunity(acctRec, agent);
        Billing_Account__c bilAcctRec = CCV_TestDataFactoryAllObjects.insertBillingAccounts(acctRec, agent, insPlcyRec);
        Claim claimRec = CCV_TestDataFactoryAllObjects.insertClaim(acctRec, agent, insPlcyRec);
        FinancialAccount__c finAcctRec = CCV_TestDataFactoryAllObjects.insertFinancialAccount(acctRec);

        Test.startTest();
        List<CCV_AccountNoteAlertsStrip.AccountAlert> acctWrapper = CCV_AccountNoteAlertsStrip.fetchAccountNoteAlerts(
            String.valueOf(acctRec.Id),
            'Account'
        );
        List<CCV_AccountNoteAlertsStrip.AccountAlert> caseWrapper = CCV_AccountNoteAlertsStrip.fetchAccountNoteAlerts(
            String.valueOf(caseRec.Id),
            'Case'
        );
        List<CCV_AccountNoteAlertsStrip.AccountAlert> opptyWrapper = CCV_AccountNoteAlertsStrip.fetchAccountNoteAlerts(
            String.valueOf(opptyRec.Id),
            'Opportunity'
        );
        List<CCV_AccountNoteAlertsStrip.AccountAlert> ipWrapper = CCV_AccountNoteAlertsStrip.fetchAccountNoteAlerts(
            String.valueOf(insPlcyRec.Id),
            'InsurancePolicy'
        );
        List<CCV_AccountNoteAlertsStrip.AccountAlert> baWrapper = CCV_AccountNoteAlertsStrip.fetchAccountNoteAlerts(
            String.valueOf(bilAcctRec.Id),
            'Billing_Account__c'
        );
        List<CCV_AccountNoteAlertsStrip.AccountAlert> clmWrapper = CCV_AccountNoteAlertsStrip.fetchAccountNoteAlerts(
            String.valueOf(claimRec.Id),
            'Claim'
        );
        List<CCV_AccountNoteAlertsStrip.AccountAlert> faWrapper = CCV_AccountNoteAlertsStrip.fetchAccountNoteAlerts(
            String.valueOf(finAcctRec.Id),
            'FinancialAccount__c'
        );
        Test.stopTest();

        System.assertEquals(false, acctWrapper.isEmpty(), 'Account should return the AccountNote alerts');
        System.assertEquals(false, caseWrapper.isEmpty(), 'Case should return the AccountNote alerts');
        System.assertEquals(false, opptyWrapper.isEmpty(), 'Opportunity should return the AccountNote alerts');
        System.assertEquals(false, ipWrapper.isEmpty(), 'InsurancePolicy should return the AccountNote alerts');
        System.assertEquals(false, baWrapper.isEmpty(), 'Billing Account should return the AccountNote alerts');
        System.assertEquals(false, clmWrapper.isEmpty(), 'Claim should return the AccountNote alerts');
        System.assertEquals(false, faWrapper.isEmpty(), 'Financial Account should return the AccountNote alerts');
    }
}
