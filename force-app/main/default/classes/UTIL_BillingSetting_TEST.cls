@isTest
(seeAllData=false)
public with sharing class UTIL_BillingSetting_TEST {

    private static final String CORPORATE_SUPPORT_USER_TYPE = 'Corporate Support';
    private static final String ELIGIBLE_STATE_CODE = '38-1234';
    private static final String INELIGIBLE_STATE_CODE = '99-1234';

    @TestSetup
    static void makeData(){
        User agent1 = TestDataFactory_User_Wrapper.generateAgentUser('AGENT1', '11111111111');
        agent1.State_Agent_Code__c = ELIGIBLE_STATE_CODE;
        agent1 = TestDataFactory_User.insertUser(agent1);

        User agent2 = TestDataFactory_User_Wrapper.generateAgentUser('AGENT2', '22222222222');
        agent2.State_Agent_Code__c = INELIGIBLE_STATE_CODE;
        agent2 = TestDataFactory_User.insertUser(agent2);

        User atm1 = TestDataFactory_User_Wrapper.generateAgentTeamMemberUser('ATM1', '33333333333');
        atm1.State_Agent_Code__c = ELIGIBLE_STATE_CODE;
        atm1.SubUserType__c = UTIL_Constants.USER_TYPE_ATM;
        atm1 = TestDataFactory_User.insertUser(atm1);
        
        User cccUser = TestDataFactory_User_Wrapper.generateCCCUnLicensedUser('CCCU', '55555555955');
        cccUser = TestDataFactory_User.insertUser(cccUser);

        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agent1, atm1});
    }
    /**
    * @name isPayBillEnabled_AgentWasEnabledTest
    * @description expect to return true if state was enabled for Agent Bill Pay
    */
    
    @isTest 
    public static void isPayBillEnabledAgentWasEnabledTest() {
        boolean result = false;

        User agent = [SELECT id FROM User WHERE Alias = 'AGENT1' LIMIT 1];

        Test.startTest();
            System.runAs(agent) {
                result = UTIL_BillingSetting.isPayBillEnabled();
            }
        Test.stopTest();

        System.assertEquals(true, result, 'Expected IL state agent code to return true');
    }

    /**
    * @name isPayBillEnabled_ATMWasEnabledTest
    * @description expect to return true if state was enabled for ATM Bill Pay
    */
    
    @isTest 
    public static void isPayBillEnabledATMWasEnabledTest() {
        boolean result = false;

        User atm = [SELECT id FROM User WHERE Alias = 'ATM1' LIMIT 1];

        Test.startTest();
            System.runAs(atm) {
                result = UTIL_BillingSetting.isPayBillEnabled();
            }
        Test.stopTest();

        System.assertEquals(true, result, 'Expected IL state agent code to return true for ATM');
    }
}
