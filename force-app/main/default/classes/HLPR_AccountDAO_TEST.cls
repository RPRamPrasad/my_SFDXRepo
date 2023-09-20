/**
Decription: this class is responsible for testing an HLPR_AccountDAO object.
Team: ImpactForce & Team Pike
Owner: Stark
Date: 8/25/2016  
*/

/**
 * @description HLPR_AccountDAO_TEST
 */
@isTest(SeeAllData = false)
private class HLPR_AccountDAO_TEST {
    private static Account account;
    private static Account account2;
    private static String currentUserID = UserInfo.getUserId();
    private static Integer countOfAccountbeforeInsert = [SELECT count() FROM Account];
    private static User systemAdmin;
    
    /**
     * @description testSetupData
     */
    @testsetup
    public static void testSetupData() {
        
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
        insert sysAdminUserIdSetting;  

    }
    
    @isTest
    private static void shouldHaveOneAccountRecordCreatedWithValidAccountObject() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        account = new Account();
        account.FirstName = 'jlrcnbgchmxtxb';
        account.LastName = 'jlrcnbgchmxtxb';
        account.ClientIdentifier__c = 'jlrc'; 
        account.Edit_In_VFP__c = true;      
        systemAdmin = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        
        Test.startTest();        
        System.runAs(systemAdmin) {
            HLPR_AccountDAO doa = new HLPR_AccountDAO();
            doa.upsertAccount(account);
            Integer countOfAccounts = [SELECT count() FROM Account];
            System.assertEquals(countOfAccountbeforeInsert + 1,countOfAccounts, 'Count of Accounts'+countOfAccounts);
        }
        Test.stopTest();
    }
   
   @isTest
    private static void shouldNotCreateAccountWithInvalidAccountObject() {
        account = new Account();
        systemAdmin = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        account.Edit_In_VFP__c = true;  
        Test.startTest();
        System.runAs(systemAdmin) {
            try {
                HLPR_AccountDAO doa = new HLPR_AccountDAO();
                doa.upsertAccount(account);
            } catch (Exception e) {
                System.assert(true, 'A DmlException was expected, and was thrown.');
            }
            Integer countOfAccounts = [SELECT count() FROM Account];
            System.assertEquals(countOfAccountbeforeInsert,countOfAccounts, 'Count of Accounts: '+countOfAccounts);
        }
        Test.stopTest();
    }
    
    @isTest
    private static void shouldUpdateAccount() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        account = new Account();
        account2 = new Account();
        account.FirstName = 'jlrcnbgchmxtxb';
        account.LastName = 'jlrcnbgchmxtxb';
        account.ClientIdentifier__c = 'zzzz'; 
        account.Edit_In_VFP__c = true;
        
        account2.FirstName = 'jlrc';
        account2.LastName = 'jbzzz';
        account2.ClientIdentifier__c = 'zzzz';
        account2.Edit_In_VFP__c = true;
        systemAdmin = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        
        Test.startTest();
        System.runAs(systemAdmin) {
            HLPR_AccountDAO dao1 = new HLPR_AccountDAO();
            HLPR_AccountDAO dao2= new HLPR_AccountDAO();
            dao1.upsertAccount(account);
            dao2.upsertAccount(account2);
            System.assertEquals('jlrc jbzzz',[SELECT name FROM Account WHERE ClientIdentifier__c = 'zzzz'].get(0).Name, 'Name of the Account is matching');
        }
        Test.stopTest();
    }
    
    @isTest
    private static void shouldInsertAccountTest() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        //setup   
        account = new Account(FirstName = 'jlrcnbgchmxtxb', LastName = 'jlrcnbgchmxtxb',ClientIdentifier__c = 'TESTCLNTID1');
        systemAdmin = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        account.Edit_In_VFP__c = true;  
        Test.startTest();
        System.runAs(systemAdmin) {
            new HLPR_AccountDAO().insertAccount(account);
            //get the newly created test account.
            Account insertedAccount =
                [SELECT Id, Name FROM Account WHERE Id = :account.Id LIMIT 1].get(0); 
            System.assertEquals('jlrcnbgchmxtxb jlrcnbgchmxtxb', insertedAccount.Name, 'Account Name: '+insertedAccount.Name);
        }    
        Test.stopTest();
    }
    
    @isTest
    private static void shouldGetDmlExceptionWhenInsertAccountTest() {
        //setup
        account = new Account(FirstName = 'jlrcnbgchmxtxb');
        try {
            systemAdmin = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
            
            Test.startTest();
            System.runAs(systemAdmin) {
                new HLPR_AccountDAO().insertAccount(account);
            }
        }
        catch(DmlException ex){
            System.assert(true, 'A DmlException was expected, and was thrown.');
            System.assertEquals(null, account.Id, 'Account Id is null');
        }   
        Test.stopTest();
    }
    
    @isTest
    private static void shouldUpdateUsingUpdateAccountTest() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        account = new Account(FirstName = 'jlrcnbgchmxtxb', LastName = 'jlrcnbgchmxtxb', Description = 'jlrcnbgchmxtxz');
        account.ClientIdentifier__c = 'zzzz';
        systemAdmin = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        System.runAs(systemAdmin) {
            insert account;
            //set the account name to new value
            Account accountToUpdate = new Account(FirstName = 'jlrcnbgchmxtxb1', LastName = 'jlrcnbgchmxtxb2');
            accountToUpdate.ClientIdentifier__c = 'zzzz';
            accountToUpdate.Edit_In_VFP__c = true;
            Test.startTest();
            new HLPR_AccountDAO().updateAccount(accountToUpdate);
            Account afterUpdate =
                [SELECT Name, Description FROM Account WHERE ClientIdentifier__c = :accountToUpdate.ClientIdentifier__c LIMIT 1].get(0);
            System.assertEquals('jlrcnbgchmxtxb1 jlrcnbgchmxtxb2', afterUpdate.Name, 'Updated Name: '+afterUpdate.Name);
            //Check that the Description remains unchanged.
            System.assertEquals('jlrcnbgchmxtxz', afterUpdate.Description, 'Updated Description: '+afterUpdate.Description);
            Test.stopTest();
        }                          
    }
    
    @isTest
    private static void shouldGetDmlExceptionWhenUpdateAccountTest() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        account = new Account(FirstName = 'jlrcnbgchmxtxb', LastName = 'jlrcnbgchmxtxb');
        account.ClientIdentifier__c = 'zzzz';
        account.Edit_In_VFP__c = true;
        systemAdmin = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        System.runAs(systemAdmin) {
            try {
                insert account;
                Account accountToUpdate = new Account(FirstName = null, LastName = null);
                accountToUpdate.ClientIdentifier__c = 'zzzz';
                
                Test.startTest();
                new HLPR_AccountDAO().updateAccount(accountToUpdate);
            }
            catch(DmlException ex){
                System.assert(true, 'A DmlException was expected, and was thrown.');
            }  
            Test.stopTest();
        }                          
    }
    
}