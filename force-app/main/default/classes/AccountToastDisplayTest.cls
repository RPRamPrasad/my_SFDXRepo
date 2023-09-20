@IsTest
//(seeAllData=false)

public with sharing class AccountToastDisplayTest {
    private static User systemUser;

    /**
     * @description Setup
     */
    public static void setup() {
        systemUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('Alias','SystemSA','systemUser@statefarm.com');
        insert systemUser;
    }
    
    @isTest
    public static void testCheckCache() {
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
        User testAgentUser = new User(Alias='ALIAS',LastName='LastName',Username='username@statefarm.com',Associate_ID__c='97PBB1YS000',UserExternalID__c='97PBB1YS000',Servicing_Agent_Associate_ID__c='97PBB1YS000',Territory_Associate_ID__c='TERRITORYID',Servicing_Agent_Associate_ID_List__c='ASSOCID',Territory_Associate_ID_List__c='TERRITORYID');
        User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser(testAgentUser);
        System.runAs(systemAdmin) {
            insert agentUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        }
        Boolean res; 
        test.startTest();
        System.runAs(agentUser) {
            res = AccountToastDisplay.checkCcpaCache('0010I00002ahfHfQAI');
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.CCPAToast');
            sessionPart.put('0010I00002ahfHfQAI','ToastDisplayed');
        }
        test.stopTest();
        System.assertEquals(true, res, 'cache is set');
    }
    
    @isTest
    public static void testCheckCacheFalse() {
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
        User testAgentUser = new User(Alias='ALIAS',LastName='LastName',Username='username@statefarm.com',Associate_ID__c='97PBB1YS000',UserExternalID__c='97PBB1YS000',Servicing_Agent_Associate_ID__c='97PBB1YS000',Territory_Associate_ID__c='TERRITORYID',Servicing_Agent_Associate_ID_List__c='ASSOCID',Territory_Associate_ID_List__c='TERRITORYID');
        User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser(testAgentUser);
        System.runAs(systemAdmin) {
            insert agentUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        }
		Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.CCPAToast');
        sessionPart.put('0010I00002ahfHfQAI','ToastDisplayed');
        Boolean res; 
        test.startTest();
        System.runAs(agentUser) {
            res = AccountToastDisplay.checkCcpaCache('0010I00002ahfHfQAI'); 
        }
        test.stopTest();
        System.assertEquals(true, !res, 'cache is not set');
    }
    
    @isTest
    public static void testClearCache() {
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
        User testAgentUser = new User(Alias='ALIAS',LastName='LastName',Username='username@statefarm.com',Associate_ID__c='97PBB1YS000',UserExternalID__c='97PBB1YS000',Servicing_Agent_Associate_ID__c='97PBB1YS000',Territory_Associate_ID__c='TERRITORYID',Servicing_Agent_Associate_ID_List__c='ASSOCID',Territory_Associate_ID_List__c='TERRITORYID');
        User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser(testAgentUser);
        System.runAs(systemAdmin) {
            insert agentUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        }
		Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.CCPAToast');
        sessionPart.put('0010I00002ahfHfQAI','ToastDisplayed');
        test.startTest();
        System.runAs(agentUser) {
            AccountToastDisplay.clearCache('0010I00002ahfHfQAI'); 
        }
        test.stopTest();
        System.assertEquals(true, !Cache.Session.contains('local.CCPAToast.0010I00002ahfHfQAI'), 'Cache is cleared');
    }     
}