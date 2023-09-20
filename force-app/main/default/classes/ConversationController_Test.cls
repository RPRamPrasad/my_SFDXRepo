/**
* Author : Team Octonauts
* Date Created : 10/12/2020
* @description : Test class for the ConversationController apex class.
*/
@isTest(seeAllData = false)
public class ConversationController_Test {
    private static User systemUser;
    private static AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting;

    private static TestData_SalesRoleHierarchy salesRoleHierarchy1;

    private static account accRecord1=new Account(FirstName='Tracey',LastName='Watson',BillingAddressType__c='US',BillingCity='FL',ClientIdentifier__c='FSCHHC2C132');

    //method to build Simple Conversation record with the given parameter value
    private static SimpleConversation__c buildSimpleConversationRecord(String param_accountId, String param_conductedBy) {
        return new SimpleConversation__c (Account__c = param_accountId,
                                                                            SimpleConversationType__c = 'Simple Conversation',
                                                                            Status__c = 'New', ConductedBy__c = param_conductedBy, SimpleConversationName__c = 'Test Simple Conv');
        
    }

    /**
     * @description test method for set up user
     */
    public static void setup() {
        systemUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('Alias','SystemSA','systemUser@statefarm.com');
        insert systemUser;

        salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.Agent);
        AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(salesRoleHierarchy1.Agent.Id, 'SF_CRM_VirtualMeetingAPTC_PermSetPID');


        System.runAs(systemUser){
            AccountOwnerSystemUserCustomSetting__c systemAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);
            insert systemAdminUserIdSetting;
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false,systemUser);
            insert passTriggerAll;
            CS001_ByPassTriggerGtoZ__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerGtoZ(systemUser);
            objectBasedByPassTrigger.Override_SimpleConversationBeforeInsert__c = false;
            insert objectBasedByPassTrigger;

            Account accountRecord1=new Account(FirstName='Tracey',LastName='Watson',BillingAddressType__c='US',BillingCity='FL',ClientIdentifier__c='FSCHHC2C132');
            insert accountRecord1;

            List<AgentRole__c> agentRoleList = new List<AgentRole__c>();
            AgentRole__c agentRole = new AgentRole__c (customer__c = accountRecord1.id, agent__c = salesRoleHierarchy1.Agent.id, RelationshipNature__c = 'Customer');
            agentRoleList.add(agentRole);
            insert agentRoleList;
        }
    }


    //method to test last accessed on Simple conversation Record Creation
    @isTest
    private static void testSimpleConRecordInsertAsAgent() {
        setup();
        System.runAs(salesRoleHierarchy1.Agent){
            Account acc = [select ID,ClientIdentifier__c,Primary_Household__pc from Account Where ClientIdentifier__c='FSCHHC2C132'].get(0);

            Test.startTest();
            SimpleConversation__c simpleConversationRecord = buildSimpleConversationRecord(acc.id, salesRoleHierarchy1.Agent.id);
            insert simpleConversationRecord;

            ConversationController.updateConversation(simpleConversationRecord.Id);

            SimpleConversation__c simpleConversation = [Select Id, Account__c,LastAccessedTime__c from SimpleConversation__c WHERE Id =: simpleConversationRecord.Id];

            DateTime currentDateTime = System.now();
            //Changed comparision of datetime to date, hour and minute to fix sporadic failures with mismatch seconds.
            System.assertEquals(currentDateTime.date(), simpleConversation.LastAccessedTime__c.date(),'LastAccessedTime__c Date did not match');
            System.assertEquals(currentDateTime.hour(), simpleConversation.LastAccessedTime__c.hour(),'LastAccessedTime__c Hour did not match');
            System.assertEquals(currentDateTime.minute(), simpleConversation.LastAccessedTime__c.minute(),'LastAccessedTime__c Minute did not match');
            Test.stopTest();
        }
    }

    //method to test exception on Simple conversation Record Creation
    @isTest
    private static void testSimpleConRecordException() {
        setup();

        System.runAs(salesRoleHierarchy1.Agent){
            Account acc = [select ID,ClientIdentifier__c,Primary_Household__pc from Account Where ClientIdentifier__c='FSCHHC2C132'].get(0);

            Test.startTest();
            SimpleConversation__c simpleConversationRecord = buildSimpleConversationRecord(acc.id, salesRoleHierarchy1.Agent.id);
            insert simpleConversationRecord;
            ConversationController.updateConversation(acc.Id);

            SimpleConversation__c simpleConversation;
            simpleConversation = [Select Id, Account__c,LastAccessedTime__c from SimpleConversation__c WHERE Id =: simpleConversationRecord.Id];

            System.assertEquals(simpleConversationRecord.Account__c,acc.id,'acc id did not match');

            Test.stopTest();
        }
    }
    }