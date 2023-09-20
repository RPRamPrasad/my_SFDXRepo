/**
@Author Team Loco Motivated
@Name UTIL_GroupDAO_Test 
@CreateDate 12/21/2017
@description Common class to access various Group operations for various Processor Test.
@Version 1.0
*/
@isTest(seeAllData=false)
public class UTIL_CustomerGroupDAO_Test {
    
    private static User systemUser;
    private static User testAPIUser;
    private static final String CLIENT_IDENTIFIER='IAMCLIENT12';
    private static final String CLIENT_IDENTIFIER1='IAMCLIENT13';
    private static final String CLIENT_IDENTIFIER2='IAMCLIENT17';
    private static final String AGENT1_ASSOCID='IAMASSCID1A'; 
    private static List<Account> accountLst = new List<Account>();
    
    /**
     * @description Setup - This method will create test data
     */
    public static void setup() {
        systemUser=UTIL_StageOrchestrationTestUtils.buildSystemAdmin('Alias','CmpMemSA','remCmpMemSysAd@statefarm.com');
        testAPIUser= UTIL_StageOrchestrationTestUtils.buildtestAPIUser('test','testing','test@statefarm.com');
        insert systemUser;
        insert testAPIUser;
    }
    
    @isTest
    static void testGroupForUpsert(){
        TestData_SalesRoleHierarchy salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('A');
        List<CustomerGroup__c> groupList= new List<CustomerGroup__c>();
        setup();        
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.Agent);  
        system.runAs(salesRoleHierarchy1.Agent){
            Test.startTest();
            groupList.add(new CustomerGroup__c(SFGroupIdentifier__c='GroupId1234',Agent__c=salesRoleHierarchy1.Agent.Id));
            UTIL_CustomerGroupDAO.upsertCustomerGroupList(groupList);           
            Test.stopTest();   
        }
        
        List<CustomerGroup__c> testgroup=[SELECT Id, Agent__c, SFGroupIdentifier__c FROM CustomerGroup__c where id IN : groupList];
        system.assertEquals('GroupId1234', testgroup.get(0).SFGroupIdentifier__c, 'Expected String is not equals to the actual String');
        system.assertEquals(salesRoleHierarchy1.Agent.Id, testgroup.get(0).Agent__c, 'Expected Id is not equals to the actual Id');
    }
}