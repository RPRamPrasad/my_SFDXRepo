/**
 * @description This class is used to cover apex class CCV_RetrieveAccountIdQueryHelper
 * @Date: 12/24/2022
 * @author: Team Atlas
 */

@isTest(SeeAllData=false)
public with sharing class CCV_RetrieveAccountIdQueryHelper_Test {
    @testsetup
    static void testSetupData() {
        CCV_TestDataFactoryAllObjects.insertAccountWithHousehold();
        Account acctRec = [
            SELECT Id, Primary_Household__pc, PersonContactId
            FROM Account
            WHERE ClientIdentifier__c = :CCV_TestDataFactoryAllObjects.ACCOUNT_ONE_CLIENT_ID
        ];
        User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678901');
        agent = TestDataFactory_User.insertUser(agent);
        CCV_TestDataFactoryAllObjects.insertInsurancePolicy(acctRec, agent);
    }

    @isTest
    private static void testgetAccountIdFromAllObjects() {
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
        User agent = [SELECT Id FROM User WHERE Associate_ID__c = '12345678901'];
        Case caseRec = CCV_TestDataFactoryAllObjects.insertCase(acctRec, agent, insPlcyRec);
        Opportunity opptyRec = CCV_TestDataFactoryAllObjects.insertOpportunity(acctRec, agent);
        Billing_Account__c bilAcctRec = CCV_TestDataFactoryAllObjects.insertBillingAccounts(acctRec, agent, insPlcyRec);
        Claim claimRec = CCV_TestDataFactoryAllObjects.insertClaim(acctRec, agent, insPlcyRec);
        FinancialAccount__c finAcctRec = CCV_TestDataFactoryAllObjects.insertFinancialAccount(acctRec);
        Test.startTest();
        String caseAcctId = CCV_RetrieveAccountIdQueryHelper.getAccountIdFromCase(String.valueOf(caseRec.Id));
        String opptyAcctId = CCV_RetrieveAccountIdQueryHelper.getAccountIdFromOpportunity(String.valueOf(opptyRec.Id));
        Opportunity oppty = CCV_RetrieveAccountIdQueryHelper.getOpportunity(String.valueOf(opptyRec.Id));
        String ipAcctId = CCV_RetrieveAccountIdQueryHelper.getAccountIdFromInsurancePolicy(
            String.valueOf(insPlcyRec.Id)
        );
        String baAcctId = CCV_RetrieveAccountIdQueryHelper.getAccountIdFromBillingAccount(
            String.valueOf(bilAcctRec.Id)
        );
        String clmAcctId = CCV_RetrieveAccountIdQueryHelper.getAccountIdFromClaim(String.valueOf(claimRec.Id));
        String faAcctId = CCV_RetrieveAccountIdQueryHelper.getAccountIdFromFinancialAccount(
            String.valueOf(finAcctRec.Id)
        );
        Test.stopTest();
        System.assertEquals(true, caseAcctId != null, 'Case should return the account Id');
        System.assertEquals(true, opptyAcctId != null, 'Opportunity should return the account Id');
        System.assertEquals(true, oppty != null, 'Opportunity should return the opportunity details');
        System.assertEquals(true, ipAcctId != null, 'InsurancePolicy should return the account Id');
        System.assertEquals(true, baAcctId != null, 'Billing Account should return the account Id');
        System.assertEquals(true, clmAcctId != null, 'Claim should return the account Id');
        System.assertEquals(true, faAcctId != null, 'Financial Account should return the account Id');
    }
}
