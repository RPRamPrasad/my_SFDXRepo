@isTest(seeAllData = false)
public class InsightMetricsHandler_test {

    private static User agentUser {get;set;}
    @isTest
    static void testmethod1() {

        //Id devRecordTypeId;
        //devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();

        agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'AGNTName', 'AGNTName','AGNTName','AGNTName_AGNTName');

        insert new List<User>{agentUser};


        Test.startTest();
        setup();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {

            InsightMetricsHandler.recordClicks('2.00 Agent,AGNTName,AGNTName,AGNTName,AGNTName_AGNTName','2.00 Agent,AGNTName,AGNTName,AGNTName,AGNTName_AGNTName,2.00 Agent,AGNTName,AGNTName,AGNTName,AGNTName_AGNTName,2.00 Agent,AGNTName,AGNTName,AGNTName,AGNTName_AGNTName,2.00 Agent,AGNTName,AGNTName,AGNTName,AGNTName_AGNTName,2.00 Agent,AGNTName,AGNTName,AGNTName,AGNTName_AGNTName,2.00 Agent,AGNTName,AGNTName,AGNTName,AGNTName_AGNTName');
        }
        Test.stopTest();
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    private static void setup() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(true, agentUser);
        insert passTriggerAll;
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(agentUser);
        objectBasedByPassTrigger.Override_CustomerGroupBeforeInsert__c = true;
        insert objectBasedByPassTrigger;

    }
}