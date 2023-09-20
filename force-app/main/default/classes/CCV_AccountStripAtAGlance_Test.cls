/**
 * @description This class is used to cover apex class CCV_AccountStripAtAGlance
 * @Date: 12/24/2022
 * @author: Team Atlas
 */

@isTest(SeeAllData=false)
public with sharing class CCV_AccountStripAtAGlance_Test {
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
    private static void testFetchAccountDetailsError() {
        CCV_AccountStripAtAGlance.AtAGlanceWrapper wrapper = new CCV_AccountStripAtAGlance.AtAGlanceWrapper();
        Test.startTest();
        try {
            wrapper = CCV_AccountStripAtAGlance.fetchAccountDetails(null, 'Account');
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Exception thrown');
        }
        Test.stopTest();
        System.assertEquals(false, wrapper.account != null, 'Account should not return the account details');
    }

    @isTest
    private static void testFetchAccountDetailsAllObjects() {
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
        CCV_AccountStripAtAGlance.AtAGlanceWrapper acctWrapper = CCV_AccountStripAtAGlance.fetchAccountDetails(
            String.valueOf(acctRec.Id),
            'Account'
        );
        CCV_AccountStripAtAGlance.AtAGlanceWrapper caseWrapper = CCV_AccountStripAtAGlance.fetchAccountDetails(
            String.valueOf(caseRec.Id),
            'Case'
        );
        CCV_AccountStripAtAGlance.AtAGlanceWrapper opptyWrapper = CCV_AccountStripAtAGlance.fetchAccountDetails(
            String.valueOf(opptyRec.Id),
            'Opportunity'
        );
        CCV_AccountStripAtAGlance.AtAGlanceWrapper ipWrapper = CCV_AccountStripAtAGlance.fetchAccountDetails(
            String.valueOf(insPlcyRec.Id),
            'InsurancePolicy'
        );
        CCV_AccountStripAtAGlance.AtAGlanceWrapper baWrapper = CCV_AccountStripAtAGlance.fetchAccountDetails(
            String.valueOf(bilAcctRec.Id),
            'Billing_Account__c'
        );
        CCV_AccountStripAtAGlance.AtAGlanceWrapper clmWrapper = CCV_AccountStripAtAGlance.fetchAccountDetails(
            String.valueOf(claimRec.Id),
            'Claim'
        );
        CCV_AccountStripAtAGlance.AtAGlanceWrapper faWrapper = CCV_AccountStripAtAGlance.fetchAccountDetails(
            String.valueOf(finAcctRec.Id),
            'FinancialAccount__c'
        );
        Test.stopTest();

        System.assertEquals(true, acctWrapper.account != null, 'Account should return the account details');
        System.assertEquals(true, caseWrapper.account != null, 'Case should return the account details');
        System.assertEquals(true, opptyWrapper.account != null, 'Opportunity should return the account details');
        System.assertEquals(
            true,
            opptyWrapper.opportunity != null,
            'Opportunity should return the opportunity details'
        );
        System.assertEquals(true, ipWrapper.account != null, 'InsurancePolicy should return the account details');
        System.assertEquals(true, baWrapper.account != null, 'Billing Account should return the account details');
        System.assertEquals(true, clmWrapper.account != null, 'Claim should return the account details');
        System.assertEquals(true, faWrapper.account != null, 'Financial Account should return the account details');
    }
}
