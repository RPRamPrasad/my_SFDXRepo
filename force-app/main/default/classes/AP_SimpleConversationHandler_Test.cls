/**
* Author : Team Octonauts
* Date Created : 08/05/2020
* @description Test class for the AP_SimpleConversationHandler apex class.
*/
@isTest(seeAllData = false)
public class AP_SimpleConversationHandler_Test {
    private static User systemUser;
    private static User testFSCHHUser;
    public static final String FSC_HOUSEHOLD_PERMISSION_SET_NAME ='SF_CRMDM_FSCHH_PermSetPID';
    public static final String HOUSEHOLD_RECORD_TYPE = 'IndustriesHousehold';
    private static PermissionSetAssignment psassignment;
    private static AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting;

    private static TestData_SalesRoleHierarchy salesRoleHierarchy1;


    private static account accRecord1=new Account(FirstName='Tracey',LastName='Watson',BillingAddressType__c='US',BillingCity='FL',ClientIdentifier__c='FSCHHC2C132');
    private static Account hhRecord1;



    //method to build Simple Conversation record with the given parameter value
    private static SimpleConversation__c buildSimpleConversationRecord(String accountId, String conductedBy) {
        return new SimpleConversation__c (Account__c = accountId,
                                                                            SimpleConversationType__c = 'Simple Conversation',
                                                                            Status__c = 'New', ConductedBy__c = conductedBy, SimpleConversationName__c = 'Test Simple Conv');
        
    }

    /**
     * @description test method to setup user
     */
    public static void setup() {
        systemUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('Alias','SystemSA','systemUser@statefarm.com');
        insert systemUser;
        testFSCHHUser = UTIL_UserProvisioning_TEST.buildUserWith103APIProfile();
        insert testFSCHHUser;
        psassignment = assignPSet(testFSCHHUser);
        insert psassignment;
        salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.Agent);
        System.runAs(systemUser){
            AccountOwnerSystemUserCustomSetting__c systemAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);
            insert systemAdminUserIdSetting;
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false,systemUser);
            insert passTriggerAll;
            CS001_ByPassTriggerGtoZ__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerGtoZ(systemUser);
            objectBasedByPassTrigger.Override_SimpleConversationBeforeInsert__c = false;
            insert objectBasedByPassTrigger;
        }
    }


    //method to test Primary_Household__c update on Simple conversation Record Creation
    @isTest
    private static void testSimpleConRecordInsertAsAgent() {
        setup();
        System.runAs(testFSCHHUser){
            hhRecord1 = new Account(Name='Household', recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId());
            insert hhRecord1;

        }
        System.runAs(systemUser){
            accRecord1.Primary_Household__pc = hhRecord1.id;
            insert accRecord1;

            List<AgentRole__c> agentRoleList = new List<AgentRole__c>();
            AgentRole__c agentRole = new AgentRole__c (customer__c = accRecord1.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Customer');
            agentRoleList.add(agentRole);
            insert agentRoleList;

        }

       AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(salesRoleHierarchy1.Agent.Id, 'SF_CRM_VirtualMeetingAPTC_PermSetPID');

        System.runAs(salesRoleHierarchy1.Agent){

            Account acc = [select ID,ClientIdentifier__c,Primary_Household__pc from Account Where ClientIdentifier__c='FSCHHC2C132'].get(0);

            Test.startTest();
            SimpleConversation__c simpleConversationRecord = buildSimpleConversationRecord(acc.id, salesRoleHierarchy1.Agent.id);
            insert simpleConversationRecord;

            List<SimpleConversation__c> simpleConverLog = [Select Id, Agent__c, OwnerId,Primary_Household__c from SimpleConversation__c WHERE Account__r.ClientIdentifier__c='FSCHHC2C132'];

            System.assertEquals(acc.Primary_Household__pc, simpleConverLog[0].Primary_Household__c,'FSC HouseHold ID did not match');
            System.assert(!simpleConverLog.isEmpty(),'No Simple Conversation records found');

            Test.stopTest();
        }
    }

    /**
* This method is used for assign a particular PermissionSet to a particular User
* @description assignPSet <This method is used to get Standard testUser>
* @param testUser
* @return assignment
*/
    private static PermissionSetAssignment assignPSet (User testUser){
        PermissionSet ps = [Select Id, Name FROM PermissionSet WHERE Name=:FSC_HOUSEHOLD_PERMISSION_SET_NAME];
        return new PermissionSetAssignment(AssigneeId=testUser.Id,PermissionSetId=ps.Id);
        
    }
}
