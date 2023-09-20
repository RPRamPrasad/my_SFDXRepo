/**
 * Author : Team Moneyball
 * Date Created : 06/21/2023
 * @description : test for class ClaimLossHistoryController
 * Version : 1.0
 */

 @isTest
 public with sharing class ClaimLossHistoryController_Test {
     private static final String CLIENTID = 'CIDHOUS';
     private static final String MEM_CLIENTID = 'CIDHMEM';
 
     /**
      * @description Prepare setup
      */
     @TestSetup
     public static void setup() {
         TestUserSetupUtility.setupSystemAdminUser();
         TestUserSetupUtility.setupAgentOffice();
 
         System.runAs(TestUserSetupUtility.getSysAdminUser()) {
             UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
             User agent = TestUserSetupUtility.getAgentUser();
             assignPermissionSet(agent, 'FSCInsurance');
             assignPermissionSet(agent, 'Insurance_RAll');
 
             Id householdId = createHouseholdAccount();
             List<Account> listAccnt = createHouseholdMemsAccount(householdId);
             createAgentRoles(agent.Id, listAccnt);
 
             Account accntWithoutHousehold = getAccountInstance(5);
             insert accntWithoutHousehold;
 
             List<Account> listAccnt2 = new List<Account>();
             listAccnt2.add(accntWithoutHousehold);
             createAgentRoles(agent.Id, listAccnt2);
             createPolicyRelated(agent, listAccnt);
         }
     }
 
     /**
      * @name getRestInfoTest
      * @description test for Rest callout
      */
     @isTest
     public static void getRestInfoTest() {
         Map<String, Object> input = inputParameters();
         HttpRequestCalloutHelper_Test.insertContinuationRecord('MockREST', 'https://mock.callout/request/{0}', '');
         Test.setMock(HttpCalloutMock.class, new HttpRequestCalloutResponseMockGenerator(200, '{payload:"value"}'));
 
         Test.startTest();
         HttpRequestCalloutHelper.HttpCalloutResponse response = ClaimLossHistoryController.getLossHistoryByClientId(input);
         HttpRequestCalloutHelper.HttpCalloutResponse response1 = ClaimLossHistoryController.getLossHistoryByAgreementId(input);
         Test.stopTest();
 
         System.assertNotEquals(null, response, 'not null');
         System.assertNotEquals(null, response1, 'not null');
     }
 
     /**
      * @name getLossHistoryByClientIdFailedTest
      * @description verifies that failed Rest info
      */
     @isTest
     public static void getLossHistoryByClientIdFailedTest() {
         try {
             Test.startTest();
             HttpRequestCalloutHelper.HttpCalloutResponse response = ClaimLossHistoryController.getLossHistoryByClientId(inputParameters());
             Test.stopTest();
         } catch (Exception e) {
             System.assertEquals(System.AuraHandledException.class.getName(), e.getTypeName(), 'AuraHandledException is expected');
         }
     }
 
     /**
      * @name getLossHistoryByAgreementIdFailedTest
      * @description verifies that failed Rest info
      */
     @isTest
     public static void getLossHistoryByAgreementIdFailedTest() {
         try {
             Test.startTest();
             HttpRequestCalloutHelper.HttpCalloutResponse response = ClaimLossHistoryController.getLossHistoryByAgreementId(
                 inputParameters()
             );
             Test.stopTest();
         } catch (Exception e) {
             System.assertEquals(System.AuraHandledException.class.getName(), e.getTypeName(), 'AuraHandledException is expected');
         }
     }
 
     /**
      * @name getLossHistoryParametersTest
      * @description account details are retrieved
      */
     @isTest
     public static void getLossHistoryParametersTest() {
         System.runAs(TestUserSetupUtility.getAgentUser()) {
             Id param1 = getAccountData(MEM_CLIENTID + '1').Id;
             Id param2 = getAccountData(MEM_CLIENTID + '5').Id;
             Id param3 = getHouseholdAccountData().Id;
             ClaimLossHistoryController.LossHistoryWrapper losshistoryParameter;
             ClaimLossHistoryController.LossHistoryWrapper losshistoryParameter1;
             ClaimLossHistoryController.LossHistoryWrapper losshistoryParameter2;
             Test.startTest();
             losshistoryParameter = ClaimLossHistoryController.getLossHistoryParameters(param1);
             losshistoryParameter1 = ClaimLossHistoryController.getLossHistoryParameters(param2);
             losshistoryParameter2 = ClaimLossHistoryController.getLossHistoryParameters(param3);
             Test.stopTest();
             System.assertEquals(3, losshistoryParameter.clientIds.size(), 'expected 3 client ids for household');
             System.assertEquals(1, losshistoryParameter1.clientIds.size(), 'expected 1 client ids for household');
             System.assertEquals(3, losshistoryParameter2.clientIds.size(), 'expected 3 client ids for household');
         }
     }

      /**
      * @name getPolicyDetailsTest
      * @description policy details are retrieved
      */
    @isTest
    public static void getPolicyDetailsTest() {
        Test.startTest();
        InsurancePolicy insurancePolicy = ClaimLossHistoryController.getPolicyDetails('AggrementId1');
        Test.stopTest();
        System.assertEquals('Policy1', insurancePolicy.PolicyName, 'expected result on policyName');
      }

     /**
     * @name getPolicyDetailsFailedTest
     * @description  verifies the failed scenario
     */
    @isTest
    public static void getPolicyDetailsFailedTest() {
        try {
            Test.startTest();
            InsurancePolicy insurancePolicy = ClaimLossHistoryController.getPolicyDetails('AggrementId');
            Test.stopTest();
        } catch (Exception e) {
            System.assertEquals(System.AuraHandledException.class.getName(), e.getTypeName(), 'AuraHandledException is expected');
        }
      }
 
     private static Map<String, Object> inputParameters() {
         Map<String, Object> input = new Map<String, Object>();
         List<String> params = new List<String>();
         params.add('one');
         params.add('{payload:"value"}');
         input.put('calloutName', 'MockREST');
         input.put('calloutParams', params);
         return input;
     }
 
     private static Id createHouseholdAccount() {
         Account accnt = new Account(
             Name = 'Household',
             ClientIdentifier__c = CLIENTID,
             recordTypeId = getRecordTypeId('IndustriesHousehold'),
             AllowHousehold__c = true
         );
         insert accnt;
         return accnt.Id;
     }
 
     private static List<Account> createHouseholdMemsAccount(Id householdId) {
         List<Account> listAccount = new List<Account>();
         for (Integer i = 0; i < 3; i++) {
             Account accnt = getAccountInstance(i);
             if (householdId != null) {
                 accnt.Primary_Household__pc = householdId;
             }
             listAccount.add(accnt);
         }
         insert listAccount;
         return listAccount;
     }
 
     private static Account getAccountInstance(Integer i) {
         return new Account(
             FirstName = 'FirstName' + i,
             LastName = 'LastName' + i,
             BillingAddressType__c = 'US',
             ClientIdentifier__c = MEM_CLIENTID + i,
             recordTypeId = getRecordTypeId('Individual')
         );
     }
 
     private static Id getRecordTypeId(String type) {
         return Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(type).getRecordTypeId();
     }
 
     private static void createAgentRoles(Id userId, List<Account> accounts) {
         List<AgentRole__c> agentRoles = new List<AgentRole__c>();
         for (Account account : accounts) {
             agentRoles.add(getAgentRoleInstance(userId, account.Id));
         }
         insert agentRoles;
     }
 
     private static AgentRole__c getAgentRoleInstance(Id userId, Id accountId) {
         return new AgentRole__c(Agent__c = userId, Customer__c = accountId, RelationshipNature__c = 'Customer');
     }
 
     private static Account getAccountData(String clientId) {
        return [SELECT Id FROM Account WHERE ClientIdentifier__c = :clientId LIMIT 1];
     }

     private static Account getHouseholdAccountData() {
        return [SELECT Id FROM Account WHERE recordTypeId = : getRecordTypeId('IndustriesHousehold') LIMIT 1];
     }
 
     private static void createPolicyRelated(User agent, List<Account> accountList) {
         List<InsurancePolicy> policyList = new List<InsurancePolicy>();
         for (Integer i = 0; i < 3; i++) {
             policyList.add(
                 new InsurancePolicy(
                     Servicing_Agent__c = agent.Id,
                     NameInsuredId = accountList[i].id,
                     AgreDisplayPartyName__c = 'TESTNAME' + i,
                     PolicyType = 'Auto',
                     PolicyName = 'Policy' + i,
                     AgreAccessKey__c = 'AggrementId' + i,
                     SourceSystemIdentifier = 'AggrementId' + i,
                     Name = '10-LQ-0000-0' + i
                 )
             );
         }
         insert policyList;
         List<InsurancePolicyParticipant> participantList = new List<InsurancePolicyParticipant>();
         for (Integer i = 0; i < 3; i++) {
             participantList.add(
                 new InsurancePolicyParticipant(
                     PrimaryParticipantAccountId = accountList[i].Id,
                     InsurancePolicyId = policyList[i].id,
                     Role = 'Named Insured'
                 )
             );
         }
         insert participantList;
     }
 
     private static void assignPermissionSet(User user, String name) {
         PermissionSet permissionSet = [SELECT Id, Name FROM PermissionSet WHERE Name = :name];
         PermissionSetAssignment psAssignment = new PermissionSetAssignment(PermissionSetId = permissionSet.Id, AssigneeId = user.Id);
         insert psAssignment;
     }
 } 