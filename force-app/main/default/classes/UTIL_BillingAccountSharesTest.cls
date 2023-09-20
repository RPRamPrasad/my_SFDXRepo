/**
 * @description This class will be used to test the UTIL_BillingAccountShares Class
 * @Date: 10/25/21
 * @author: Stephen White YCDB, Jonathan Larkin VAASTT
 */
@isTest
(seeAllData = false)
public with sharing class UTIL_BillingAccountSharesTest extends UTIL_AgencyShares {
    private static final String MANUAL_ROW_CAUSE = 'Manual';

    /**
     * @description Setup Tests by generating agent data and bypassing the appropraite triggers.
     */
    @testsetup
    public static void testSetupData() {

        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=true);
        insert passTriggerAll;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        
        TestDataFactory_BillingShares.generateBillingShareTestData();
    }

    @isTest 
    public static void createBillingAccountSharesFromAgentRoleDataException() {
        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);
        UTIL_BillingAccountShares.createBillingAccountSharesFromAgentRoleData(null);
        System.assertEquals(1, [SELECT COUNT() FROM ExceptionLog__c], 'One ExceptionLog__c record should have been created');
    }

    @isTest 
    public static void deleteBillingAccountSharesFromAgentRoleDataException() {
        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);
        UTIL_BillingAccountShares.deleteBillingAccountSharesFromAgentRoleData(null);
        System.assertEquals(1, [SELECT COUNT() FROM ExceptionLog__c], 'One ExceptionLog__c record should have been created');
    }

    @isTest
    public static void createBillingAccountSharesToggleDisabled() {
        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, false);

        // Create System Admin
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
    
        Test.startTest();
    
        System.runAs(systemAdmin){

            List<AgentRole__c> agentRoles = new List<AgentRole__c>();
            TestDataFactory_BillingSharesAgentRoles.setupBasicAgentTest(agentRoles);

            // Add Data to agent Role Data Object and call add method.
            AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);

            UTIL_BillingAccountShares.createBillingAccountSharesFromAgentRoleData(agentRoleData);

            Integer numShares = UTIL_BillingAccountSharesTest.countBillingSharesWhereRowCauseIsManual();

            System.assertEquals(0, numShares, 'No Billing shares should have been created.');

        }

        Test.stopTest();
    }

    @isTest
    public static void createBillingAccountSharesToggleEnabled() {
        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);

        // Create System Admin
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
    
        Test.startTest();
    
        System.runAs(systemAdmin){

            List<AgentRole__c> agentRoles = TestDataFactory_BillingSharesAgentRoles.setupOneAccountTwoInsurancePoliciesAndParticipants();

            AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);

            UTIL_BillingAccountShares.createBillingAccountSharesFromAgentRoleData(agentRoleData);

            Integer numShares = UTIL_BillingAccountSharesTest.countBillingSharesWhereRowCauseIsManual();

            System.assertEquals(2, numShares, 'Expected 2 Billing shares to have been created.');

            List<Billing_Account__Share> billingAccountShares = UTIL_BillingAccountSharesTest.getBillingSharesWhereRowCauseIsManual();

            List<Id> parentIdList = new List<Id>();
            List<Id> userOrGroupIdList = new List<Id>();

            for (Billing_Account__Share share : billingAccountShares) {
                parentIdList.add(share.ParentId);
                userOrGroupIdList.add(share.UserOrGroupId);
            }

            System.assert(parentIdList.contains(TestDataFactory_BillingShares.getBillingAccount1().Id), 'Expected getBillingAccount1 Id to be in parentIdList');
            System.assert(parentIdList.contains(TestDataFactory_BillingShares.getBillingAccount2().Id), 'Expected getBillingAccount2 Id to be in parentIdList');

            System.assert(userOrGroupIdList.contains(TestDataFactory_BillingShares.getAgentProxy3().Id), 'Expected Agent3 ProxyId to be in userOrGroupIdList');

        }

        Test.stopTest();
    }

    @isTest
    private static void deleteBillingAccountSharesToggleDisabled(){
        Account customerAccount3 = TestDataFactory_BillingShares.getAccount3();
        Billing_Account__c billingAccount1 = TestDataFactory_BillingShares.getBillingAccount1();
        Billing_Account__c billingAccount2 = TestDataFactory_BillingShares.getBillingAccount2();

        Billing_Participant__c bp1 = new Billing_Participant__c();
        bp1.BillingAccountID__c = billingAccount1.Id;
        bp1.SourceSystemIdentifier__c = billingAccount1.AccountNumber__c + '~' + '00' + '~' + billingAccount1.Id;
        bp1.ParticipantAccountId__c = customerAccount3.Id;

        Billing_Participant__c bp2 = new Billing_Participant__c();
        bp2.BillingAccountID__c = billingAccount2.Id;
        bp2.SourceSystemIdentifier__c = billingAccount2.AccountNumber__c + '~' + '00' + '~' + billingAccount2.Id;
        bp2.ParticipantAccountId__c = customerAccount3.Id;

        insert bp1;
        insert bp2;

        // enable the toggle to allow shares to be created
        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);

        Integer expectedSharesBeforeDelete = 4;
        Integer expectedSharesAfterDelete = 4;

        // Create Shares using logic from createBillingAccountSharesToggleEnabled test class in UTIL_BillingAccountSharesAddTest
        List<AgentRole__c> agentRoles = TestDataFactory_BillingSharesAgentRoles.setupTwoCustAccountsTwoBillAccountsTwoAgent();

        // add agent role with a policy association
        agentRoles.add(new AgentRole__c(Customer__c = customerAccount3.id, Agent__c = TestDataFactory_BillingShares.getAgent2().id));

        AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
        UTIL_BillingAccountShares.createBillingAccountSharesFromAgentRoleData(agentRoleData);

        // Validate that shares where created before we delete them.
        Integer numShares = UTIL_BillingAccountSharesTest.countBillingSharesWhereRowCauseIsManual();
        System.assertEquals(expectedSharesBeforeDelete, numShares, 'Incorrect number of Billing Shares Created');

        // disable the toggle to ensure shares dont get deleted
        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, false);

        UTIL_BillingAccountShares.deleteBillingAccountSharesFromAgentRoleData(agentRoleData);

        numShares = UTIL_BillingAccountSharesTest.countBillingSharesWhereRowCauseIsManual();
        System.assertEquals(expectedSharesAfterDelete, numShares, 'No shares should have been deleted');

    }

    @isTest
    private static void deleteBillingAccountShares(){
        Account customerAccount3 = TestDataFactory_BillingShares.getAccount3();
        Billing_Account__c billingAccount1 = TestDataFactory_BillingShares.getBillingAccount1();
        Billing_Account__c billingAccount2 = TestDataFactory_BillingShares.getBillingAccount2();

        Billing_Participant__c bp1 = new Billing_Participant__c();
        bp1.BillingAccountID__c = billingAccount1.Id;
        bp1.SourceSystemIdentifier__c = billingAccount1.AccountNumber__c + '~' + '00' + '~' + billingAccount1.Id;
        bp1.ParticipantAccountId__c = customerAccount3.Id;

        Billing_Participant__c bp2 = new Billing_Participant__c();
        bp2.BillingAccountID__c = billingAccount2.Id;
        bp2.SourceSystemIdentifier__c = billingAccount2.AccountNumber__c + '~' + '00' + '~' + billingAccount2.Id;
        bp2.ParticipantAccountId__c = customerAccount3.Id;

        insert bp1;
        insert bp2;


        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);

        Integer expectedSharesBeforeDelete = 4;
        Integer expectedSharesAfterDelete = 0;

        // Create Shares using logic from createBillingAccountSharesToggleEnabled test class in UTIL_BillingAccountSharesAddTest
        List<AgentRole__c> agentRoles = TestDataFactory_BillingSharesAgentRoles.setupTwoCustAccountsTwoBillAccountsTwoAgent();

        // add agent role with a policy association
        agentRoles.add(new AgentRole__c(Customer__c = customerAccount3.id, Agent__c = TestDataFactory_BillingShares.getAgent2().id));

        AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
        UTIL_BillingAccountShares.createBillingAccountSharesFromAgentRoleData(agentRoleData);

        // Validate that shares where created before we delete them.
        Integer numShares = UTIL_BillingAccountSharesTest.countBillingSharesWhereRowCauseIsManual();
        System.assertEquals(expectedSharesBeforeDelete, numShares, 'Incorrect number of Billing Shares Created');

        UTIL_BillingAccountShares.deleteBillingAccountSharesFromAgentRoleData(agentRoleData);

        numShares = UTIL_BillingAccountSharesTest.countBillingSharesWhereRowCauseIsManual();
        System.assertEquals(expectedSharesAfterDelete, numShares, 'Incorrect number of shares were deleted.');

    }

    @isTest
    private static void deleteBillingAccountSharesNoDelete(){
        List<AgentRole__c> agentRoles = new List<AgentRole__c>();

        // Get Agent
        User agentUser4 = TestDataFactory_BillingShares.getAgent4();

        Account customerAccount5 = TestDataFactory_BillingShares.getAccount5();
        Account customerAccount6 = TestDataFactory_BillingShares.getAccount6();

        
        AgentRole__c agentRole1 = new AgentRole__c(Customer__c=customerAccount5.Id, Agent__c = agentUser4.id);
        agentRoles.add(agentRole1);

        AgentRole__c agentRole2 = new AgentRole__c(Customer__c=customerAccount6.Id, Agent__c = agentUser4.id);
        agentRoles.add(agentRole2);

        insert agentRoles;

        UTIL_BillingAccountShares.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.BILLING_SHARES, true);

        Integer expectedSharesBeforeDelete = 1;
        Integer expectedSharesAfterDelete = 1;

        AgentRoleData agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(agentRoles);
        UTIL_BillingAccountShares.createBillingAccountSharesFromAgentRoleData(agentRoleData);

        // Validate that shares where created berfore we delete them.
        Integer numShares = UTIL_BillingAccountSharesTest.countBillingSharesWhereRowCauseIsManual();
        System.assertEquals(expectedSharesBeforeDelete, numShares, 'Incorrect number of Billing Shares Created');

        List<AgentRole__c> newAgentRoleListForDelete = new List<AgentRole__c>();
        newAgentRoleListForDelete.add(agentRole1);

        // overwrite agent role data
        agentRoleData = TestDataFactory_AgencyShares.populateAgentRoleDataObject(newAgentRoleListForDelete);
        UTIL_BillingAccountShares.deleteBillingAccountSharesFromAgentRoleData(agentRoleData);

        numShares = UTIL_BillingAccountSharesTest.countBillingSharesWhereRowCauseIsManual();
        System.assertEquals(expectedSharesAfterDelete, numShares, 'Incorrect number of shares were deleted.');

    }


    /**
     * @description - Runs a SOQL query which counts the number of Manual Billing Account Shares
     * @return an Integer denoting how many Billing Account Shares exist
     */
    public static Integer countBillingSharesWhereRowCauseIsManual() {
        return [SELECT COUNT() FROM Billing_Account__Share WHERE RowCause = :MANUAL_ROW_CAUSE];
    }

    /**
     * @description - Runs a SOQL query which counts the number of Manual Billing Account Shares
     * @return an Integer denoting how many Billing Account Shares exist
     */
    public static List<Billing_Account__Share> getBillingSharesWhereRowCauseIsManual() {
        return [SELECT ParentId, UserOrGroupId FROM Billing_Account__Share WHERE RowCause = :MANUAL_ROW_CAUSE];
    }

}