/**
* @Author Impact Force
* @Name UTIL_AccountMessageDAO_TEST
* @CreateDate 10/6/2016
* @description Common class to access various AccountMessage related operations for various Processor.
* @Version 1.0
* History
* -------
* VERSION         AUTHOR                        DATE                   DETAIL
* 1.0             Zeev Feldbeine             10/07/2016             Initial Development
*/

@isTest(seeAllData=false)
public class UTIL_AccountMessageDAO_TEST
{

    private static String className = 'UTIL_AccountMessageDAO_TEST';
    private static User runAsUser;
    private static Integer countOfAccountMessageBeforeInsert = [SELECT count() FROM AccountMessage__c];

    //test setup
    private static User setUpTestData() {
        User testAgentUser1 = new User(Alias='agen',LastName='agentTestUserzzzgdseajdfndf',Username='tqczjpkgfmnghdv@statefarm.com.bad',Associate_ID__c='zzzzxzxzx',UserExternalID__c='zzzzxzxzx',Servicing_Agent_Associate_ID__c='zzzzxzxzx'); 
        runAsUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
        insert runAsUser;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(runAsUser);
        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(true, runAsUser);
        insert passTriggerAll;

        return runAsUser;
    }

    private static Account accountSetUp()
    {
        Account acc = new Account();
        acc = new Account();
        acc.FirstName = 'jlrcnbgchmxtxb';
        acc.LastName = 'jlrcnbgchmxtxb';
        acc.clientIdentifier__c = 'jlrc';
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        UTIL_AccountDAO.insertAccount(acc);
        return [select Id from Account where Id =: acc.Id];
    }

    @isTest
    private static void testinsertTasksForAccountSuccess() {
        runAsUser = setUpTestData();
        System.runAs(runAsUser) {
            Account accTemp = accountSetUp();
            AccountMessage__c accMessage = new AccountMessage__c(Name = 'zeev', Account__c = accTemp.Id);
            Test.startTest();
            UTIL_AccountMessageDAO.insertAccountMessages(new List<AccountMessage__c>{accMessage});
            Test.stopTest();
            Integer countCurrentAccountMessages = [SELECT count() FROM AccountMessage__c];
            System.assertEquals(countOfAccountMessageBeforeInsert+1, countCurrentAccountMessages, 'Expected parameter should be equals to the actual parameter');
        }
      }

    @isTest
    private static void testinsertTasksForAccountFailure() {
        runAsUser = setUpTestData();
        System.runAs(runAsUser) {            
            Test.startTest();           
            UTIL_AccountMessageDAO.insertAccountMessages(new List<AccountMessage__c>{});
            Test.stopTest();
            Integer countCurrentAccountMessages = [SELECT count() FROM AccountMessage__c];
            System.assertEquals(countOfAccountMessageBeforeInsert, countCurrentAccountMessages, 'Expected parameter should be equals to the actual parameter');
        }
      }

        @isTest
    private static void testdeleteTasksForAccountSuccess() {
        runAsUser = setUpTestData();
        System.runAs(runAsUser) {
            Account accTemp = accountSetUp();
            AccountMessage__c accMessage = new AccountMessage__c(Name = 'zeev', Account__c = accTemp.Id);
            Test.startTest();
            UTIL_AccountMessageDAO.insertAccountMessages(new List<AccountMessage__c>{accMessage});
            Integer countCurrentAccountMessages = [SELECT count() FROM AccountMessage__c];
            UTIL_AccountMessageDAO.deleteAccountMessages(new List<AccountMessage__c>{accMessage});
            Test.stopTest();
            System.assertEquals(countOfAccountMessageBeforeInsert, countCurrentAccountMessages-1, 'Expected parameter should be equals to the actual parameter');
        }
      }

    @isTest
    private static void testdeleteTasksForAccountFailure() {
        runAsUser = setUpTestData();
        System.runAs(runAsUser) {
            Account accTemp = accountSetUp();
            AccountMessage__c accMessage = new AccountMessage__c(Name = 'zeev', Account__c = accTemp.Id);
            Test.startTest();
            UTIL_AccountMessageDAO.insertAccountMessages(new List<AccountMessage__c>{accMessage});
            Integer countCurrentAccountMessages = [SELECT count() FROM AccountMessage__c];
            UTIL_AccountMessageDAO.deleteAccountMessages(new List<AccountMessage__c>{});
            Test.stopTest();
            System.assertEquals(countOfAccountMessageBeforeInsert+1, countCurrentAccountMessages, 'Expected parameter should be equals to the actual parameter');
        }
      }

    @isTest
    private static void testupdateTasksForAccountSuccess() {
        runAsUser = setUpTestData();
        System.runAs(runAsUser) {
            Account accTemp = accountSetUp();
            AccountMessage__c accMessage = new AccountMessage__c(Name = 'zeev', Account__c = accTemp.Id);
            Test.startTest();
            UTIL_AccountMessageDAO.insertAccountMessages(new List<AccountMessage__c>{accMessage});
            accMessage.Name = 'zeev feldbeine';
            UTIL_AccountMessageDAO.updateAccountMessages(new List<AccountMessage__c>{accMessage});
            Test.stopTest();
            System.assertEquals([select Name from AccountMessage__c where Id = : accMessage.Id].Name, 'zeev feldbeine', 'Name should be \'zeev feldbeine\'');
        }
      }

    @isTest
    private static void testupdateTasksForAccountFailure() {
        runAsUser = setUpTestData();
        System.runAs(runAsUser) {
            Account accTemp = accountSetUp();
            AccountMessage__c accMessage = new AccountMessage__c(Name = 'zeev', Account__c = accTemp.Id);
            Test.startTest();
            UTIL_AccountMessageDAO.insertAccountMessages(new List<AccountMessage__c>{accMessage});
            accMessage.Name = 'zeev feldbeine';
            UTIL_AccountMessageDAO.updateAccountMessages(new List<AccountMessage__c>{});
            Test.stopTest();
            System.assertEquals([select Name from AccountMessage__c where Id = : accMessage.Id].Name, 'zeev', 'Name should be \'zeev\'');
        }
      }
        @isTest
    private static void testupsertTasksForAccountSuccess() {
        runAsUser = setUpTestData();
        System.runAs(runAsUser) {
            Account accTemp = accountSetUp();
            AccountMessage__c accMessage = new AccountMessage__c(Name = 'zeev', Account__c = accTemp.Id);
            Test.startTest();
            UTIL_AccountMessageDAO.insertAccountMessages(new List<AccountMessage__c>{accMessage});
            accMessage.Name = 'zeev feldbeine';
            UTIL_AccountMessageDAO.upsertAccountMessages(new List<AccountMessage__c>{accMessage});
            Test.stopTest();
            System.assertEquals([select Name from AccountMessage__c where Id = : accMessage.Id].Name, 'zeev feldbeine', 'Name should be \'zeev feldbeine\'');
        }
      }

    @isTest
    private static void testupsertTasksForAccountFailure() {
        runAsUser = setUpTestData();
        System.runAs(runAsUser) {
            Account accTemp = accountSetUp();
            AccountMessage__c accMessage = new AccountMessage__c(Name = 'zeev', Account__c = accTemp.Id);
            Test.startTest();
            UTIL_AccountMessageDAO.insertAccountMessages(new List<AccountMessage__c>{accMessage});
            accMessage.Name = 'zeev feldbeine';
            UTIL_AccountMessageDAO.upsertAccountMessages(new List<AccountMessage__c>{});
            Test.stopTest();
            System.assertEquals([select Name from AccountMessage__c where Id = : accMessage.Id].Name, 'zeev', 'Name should be \'zeev\'');
        }
      }


}