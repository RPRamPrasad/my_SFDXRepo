/**
* @author Impact Force
* @owner Team Stark
* @name UTIL_AccountDAO_TEST
* @createDate 10/6/2016
* @description Common class to access various Account related operations for various Processor TEST.
* @version 2.0
* History
* -------
* VERSION         AUTHOR                        DATE                   DETAIL
* 1.0             Jonathan Elliott (F0BM)     10/13/2016             Initial Development (Success/Fail)
* 2.0             Zeev Feldbeine              10/26/2016             adding logic
*/
@isTest(seeAllData=false)
private class UTIL_AccountDAO_TEST {
    
    private static Integer countOfAccountBefore = [SELECT count() FROM Account];
    private static Account acc;
    private static User systemAdmin;

    @testsetup
    private static void testSetupData() {
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
        insert sysAdminUserIdSetting;  
        TestDataFactory_CustomSetting.createDeleteRecordConfig('System Administrator', 'Account'); 
    }
    //Setup the executing user
    private static User setupRunAsUser() {
        return UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
    }
    //Description: Should insert Account successfully
    @isTest
    private static void testInsertAccountSuccess() {
        acc = new Account(FirstName = 'testUtilAccDAOFName', LastName = 'testUtilAccDAOLName');
        acc.ClientIdentifier__c= 'SFFSP81L8XB';
        systemAdmin = setupRunAsUser();
        Test.startTest();
        System.runAs(systemAdmin) {
            UTIL_AccountDAO.insertAccounts(new List<Account>{acc});
        }    
        Test.stopTest();
        Account insertedAccount = [SELECT Id, Name FROM Account WHERE Id = :acc.Id LIMIT 1]; 
        System.assertEquals('testUtilAccDAOFName testUtilAccDAOLName', insertedAccount.Name,'insert account');
    } 
   //Description: Should not insert Account since required field (Name is missing)
   @isTest
   private static void testInsertAccountFail() {
        acc = new Account();
        acc.ClientIdentifier__c= 'SFFSP81L8XB';
        systemAdmin = setupRunAsUser();
        Test.startTest();
        System.runAs(systemAdmin) {
            try {
                UTIL_AccountDAO.insertAccounts(new List<Account>{acc});
                 System.assert(false, 'A DmlException was expected.');
            } catch(Exception ex) {
                 System.assert(true, 'A DmlException was expected, and was thrown.');
            }
        }    
        Test.stopTest();
    }
    //Description: Should upsert (insert) Account successfully
    @isTest
    private static void testUpsertAccountSuccessfulInsert() {
        acc = new Account(FirstName = 'testUtilAccDAOFName', LastName = 'testUtilAccDAOLName');
        acc.ClientIdentifier__c= 'SFFSP81L8XB';    
        acc.Edit_In_VFP__c = true;
        systemAdmin = setupRunAsUser();
        Test.startTest();
        System.runAs(systemAdmin) {
            UTIL_AccountDAO.upsertAccounts(new List<Account>{acc});
        }    
        Test.stopTest();
        Account upsertedAccount = [SELECT Id, Name FROM Account WHERE Id = :acc.Id LIMIT 1]; 
        System.assertEquals('testUtilAccDAOFName testUtilAccDAOLName', upsertedAccount.Name,'upsert account');
    }
    //Description: Should not upsert (insert) Account successfully    
    @isTest
    private static void testUpsertAccountFailureInsert() {
        acc = new Account();
        systemAdmin = setupRunAsUser();
        Test.startTest();
        System.runAs(systemAdmin) {
             try {
                UTIL_AccountDAO.upsertAccounts(new List<Account>{acc});
                 System.assert(false, 'A DmlException was expected.');
            } catch(Exception ex) {
                 System.assert(true, 'A DmlException was expected, and was thrown.');
            }
        }    
        Test.stopTest();
    }
    //Description: Should upsert (update) Account successfully
    @isTest
    private static void testUpsertAccountSuccessUpdate() {
        acc = new Account(FirstName = 'testUtilAccDAOFName', LastName = 'testUtilAccDAOLName');
        acc.ClientIdentifier__c= 'SFFSP81L8XB';
        acc.Edit_In_VFP__c = true;
        insert acc;
        systemAdmin = setupRunAsUser();
        Test.startTest();
        System.runAs(systemAdmin) {
            acc.FirstName = 'updatedAccountNameDAOTest';
            UTIL_AccountDAO.upsertAccounts(new List<Account>{acc});
        }    
        Test.stopTest();
        Account upsertedAccount = [SELECT Id, Name FROM Account WHERE Id = :acc.Id LIMIT 1]; 
        System.assertEquals('updatedAccountNameDAOTest testUtilAccDAOLName', upsertedAccount.Name,'upsert account');
    }
    //Description: Should update Account successfully
    @isTest
    private static void testUpdateAccountSuccess() {
        acc = new Account(FirstName = 'testUtilAccDAOFName', LastName = 'testUtilAccDAOLName');
        acc.ClientIdentifier__c= 'SFFSP81L8XB';
        acc.Edit_In_VFP__c = true;
        insert acc;
        systemAdmin = setupRunAsUser();
        Test.startTest();
        System.runAs(systemAdmin) {
            acc.FirstName = 'updatedAccountNameDAOTest';
            UTIL_AccountDAO.updateAccounts(new List<Account>{acc});
        }    
        Test.stopTest();
        Account updatedAccount = [SELECT Id, Name FROM Account WHERE Id = :acc.Id LIMIT 1]; 
        System.assertEquals('updatedAccountNameDAOTest testUtilAccDAOLName', updatedAccount.Name,'update account');
    }
    //Description: Should NOT update Account successfully
    @isTest
    private static void testUpdateAccountFailure() {
        acc = new Account(FirstName = 'testUtilAccDAOFName', LastName = 'testUtilAccDAOLName');
        acc.ClientIdentifier__c= 'SFFSP81L8XB';
        acc.Edit_In_VFP__c = true;
        insert acc;
        systemAdmin = setupRunAsUser();
        Test.startTest();
        System.runAs(systemAdmin) {
            acc.FirstName = 'updatedAccountNameDAOTest';
            UTIL_AccountDAO.updateAccounts(null);
        }    
        Test.stopTest();
        Account updatedAccount = [SELECT Id, Name FROM Account WHERE Id = :acc.Id LIMIT 1]; 
        System.assertEquals('testUtilAccDAOFName testUtilAccDAOLName', updatedAccount.Name,'update account');
    }
    //Description: Should delete Account successfully
    @isTest
    private static void testDeleteAccountSuccess() {
        Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('agents');
        acc.ClientIdentifier__c= 'SFFSP81L8XB';
        insert acc;
        systemAdmin = setupRunAsUser();
        Test.startTest();
        Test.stopTest();
         System.runAs(systemAdmin) {
                UTIL_AccountDAO.deleteAccounts(new List<Account>{acc});
                List<Account> deletedAccount = [SELECT Id, Name FROM Account WHERE Id = :acc.Id LIMIT 1]; 
                System.assert(deletedAccount.isEmpty(),'delete account');
            }  
        
    }
    //Description: Should NOT delete Account successfully
    @isTest
    private static void testDeleteAccountFailure() {
        acc = new Account(FirstName = 'testUtilAccDAOFName', LastName = 'testUtilAccDAOLName');
        acc.ClientIdentifier__c= 'SFFSP81L8XB';
        insert acc;
        systemAdmin = setupRunAsUser();
        Test.startTest();
        System.runAs(systemAdmin) {
            UTIL_AccountDAO.deleteAccounts(null);
        }    
        Test.stopTest();
        List<Account> deletedAccount = [SELECT Id, Name FROM Account WHERE Id = :acc.Id LIMIT 1]; 
        System.assert(!deletedAccount.isEmpty(),'delete account');
        System.assertEquals(countOfAccountBefore+1, [SELECT count() FROM Account],'count before');
    }
    //Description: Should upsert (insert) Account successfully using External ID
    @isTest
    private static void testUpsertAccountByExternalClientIDSuccessfulInsert() {
        acc = new Account(FirstName = 'testUtilAccDAOFName', LastName = 'testUtilAccDAOLName', ClientIdentifier__c='accDAOTestz');
        acc.ClientIdentifier__c= 'SFFSP81L8XB';
        acc.Edit_In_VFP__c = true;
        systemAdmin = setupRunAsUser();
        Test.startTest();
        System.runAs(systemAdmin) {
            UTIL_AccountDAO.upsertAccountByClientIdentifier(acc);
        }    
        Test.stopTest();
        Account upsertedAccount = [SELECT Id, Name FROM Account WHERE Id = :acc.Id LIMIT 1]; 
        System.assertEquals('testUtilAccDAOFName testUtilAccDAOLName', upsertedAccount.Name,'upsert account');
        System.assertEquals(countOfAccountBefore+1, [SELECT count() FROM Account],'count before');
    }
    //Description: Should upsert (update) Account successfully
    @isTest
   private static void testUpsertAccountByExternalClientIDSuccessfulUpdate() {
        acc = new Account(FirstName = 'testUtilAccDAOFName', LastName = 'testUtilAccDAOLName', ClientIdentifier__c='accDAOTestz');
        acc.ClientIdentifier__c= 'SFFSP81L8XB';
        acc.Edit_In_VFP__c = true;
        insert acc;
        systemAdmin = setupRunAsUser();
        Test.startTest();
        System.runAs(systemAdmin) {
            acc.FirstName = 'updatedAccountNameDAOTest';
            UTIL_AccountDAO.upsertAccountByClientIdentifier(acc);
        }    
        Test.stopTest();
        Account upsertedAccount = [SELECT Id, Name FROM Account WHERE Id = :acc.Id LIMIT 1]; 
        System.assertEquals('updatedAccountNameDAOTest testUtilAccDAOLName', upsertedAccount.Name,'upsert account');
    }
     //Description: Should insert Account successfully
     @isTest
    private static void testInsertAccountNoListSuccess() {
        acc = new Account(FirstName = 'testUtilAccDAOFName', LastName = 'testUtilAccDAOLName');
        acc.ClientIdentifier__c= 'SFFSP81L8XB';
        systemAdmin = setupRunAsUser();
        Test.startTest();
        System.runAs(systemAdmin) {
            UTIL_AccountDAO.insertAccount(acc);
        }    
        Test.stopTest();
        Account insertedAccount = [SELECT Id, Name FROM Account WHERE Id = :acc.Id LIMIT 1]; 
        System.assertEquals('testUtilAccDAOFName testUtilAccDAOLName', insertedAccount.Name,'insert account');
    }
    //Description: Should not insert Account since required field (Name is missing)
    @isTest
   private static void testInsertAccountNoListFail() {
        acc = new Account();
        acc.ClientIdentifier__c= 'SFFSP81L8XB';
        systemAdmin = setupRunAsUser();
        Test.startTest();
        System.runAs(systemAdmin) {
            try {
                UTIL_AccountDAO.insertAccount(acc);
                 System.assert(false, 'A DmlException was expected.');
            } catch(Exception ex) {
                 System.assert(true, 'A DmlException was expected, and was thrown.');
            }
        }    
        Test.stopTest();
    }
    //Description: Should delete Account successfully
    @isTest
    private static void testDeleteAccountNoListSuccess() {
        Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('agents');
        acc.ClientIdentifier__c= 'SFFSP81L8XB';
        insert acc;
        systemAdmin = setupRunAsUser();
        Test.startTest();
        Test.stopTest();
        System.runAs(systemAdmin) {
            UTIL_AccountDAO.deleteAccount(acc);
        }    
        List<Account> deletedAccount = [SELECT Id, Name FROM Account WHERE Id = :acc.Id LIMIT 1]; 
        System.assert(deletedAccount.isEmpty(),'is account deleted');
    }
    //Description: Should NOT delete Account successfully
    @isTest
    private static void testDeleteAccountNoListFailure() {
        acc = new Account(FirstName = 'testUtilAccDAOFName', LastName = 'testUtilAccDAOLName');
        acc.ClientIdentifier__c= 'SFFSP81L8XB';
        insert acc;
        systemAdmin = setupRunAsUser();
        Test.startTest();
        System.runAs(systemAdmin) {
            UTIL_AccountDAO.deleteAccount(null);
        }    
        Test.stopTest();
        List<Account> deletedAccount = [SELECT Id, Name FROM Account WHERE Id = :acc.Id LIMIT 1]; 
        System.assert(!deletedAccount.isEmpty(),'delete account');
        System.assertEquals(countOfAccountBefore+1, [SELECT count() FROM Account],'count before delete');
    }
    //Description: Should update Account successfully
    @isTest
    private static void testUpdateAccountNoListSuccess() {
         acc = new Account(FirstName = 'testUtilAccDAOFName', LastName = 'testUtilAccDAOLName');
        acc.ClientIdentifier__c= 'SFFSP81L8XB';
		acc.Edit_In_VFP__c = true;
        insert acc;
        systemAdmin = setupRunAsUser();
        Test.startTest();
        System.runAs(systemAdmin) {
            acc.FirstName = 'updatedAccountNameDAOTest';
            UTIL_AccountDAO.updateAccount(acc);
        }    
        Test.stopTest();
        Account updatedAccount = [SELECT Id, Name FROM Account WHERE Id = :acc.Id LIMIT 1]; 
        System.assertEquals('updatedAccountNameDAOTest testUtilAccDAOLName', updatedAccount.Name,'updateAccount');

    }
    //Description: Should NOT update Account successfully
    @isTest
    private static void testUpdateAccountNoListFailure() {
        acc = new Account(FirstName = 'testUtilAccDAOFName', LastName = 'testUtilAccDAOLName');
        acc.ClientIdentifier__c= 'SFFSP81L8XB';
        insert acc;
        systemAdmin = setupRunAsUser();
        Test.startTest();
        System.runAs(systemAdmin) {
            acc.FirstName = 'updatedAccountNameDAOTest';
            UTIL_AccountDAO.updateAccount(null);
        }    
        Test.stopTest();
        Account updatedAccount = [SELECT Id, Name FROM Account WHERE Id = :acc.Id LIMIT 1]; 
        System.assertEquals('testUtilAccDAOFName testUtilAccDAOLName', updatedAccount.Name,'updateAccount');
    }
    
        //Description: Should upsert (insert) Account successfully using External ID
    @isTest
    private static void testUpsertAccountByExternalClientIDSuccessfulInsertList() {
        acc = new Account(FirstName = 'testUtilAccDAOFName', LastName = 'testUtilAccDAOLName', ClientIdentifier__c='accDAOTestz');
        acc.Edit_In_VFP__c = true;
        systemAdmin = setupRunAsUser();
        Test.startTest();
        System.runAs(systemAdmin) {
            UTIL_AccountDAO.upsertAccountsByClientIdentifier(new List<Account>{acc});
        }    
        Test.stopTest();
        Account upsertedAccount = [SELECT Id, Name FROM Account WHERE Id = :acc.Id LIMIT 1]; 
        System.assertEquals('testUtilAccDAOFName testUtilAccDAOLName', upsertedAccount.Name,'upsertAccountsByClientIdentifier');
        System.assertEquals(countOfAccountBefore+1, [SELECT count() FROM Account],'count');
    }
    //Description: Should upsert (update) Account successfully
    @isTest
   private static void testUpsertAccountByExternalClientIDSuccessfulUpdateList() {
        acc = new Account(FirstName = 'testUtilAccDAOFName', LastName = 'testUtilAccDAOLName', ClientIdentifier__c='accDAOTestz');
        acc.Edit_In_VFP__c = true;
        insert acc;
        systemAdmin = setupRunAsUser();
        Test.startTest();
        System.runAs(systemAdmin) {
            acc.FirstName = 'updatedAccountNameDAOTest';
             UTIL_AccountDAO.upsertAccountsByClientIdentifier(new List<Account>{acc});
        }    
        Test.stopTest();
        Account upsertedAccount = [SELECT Id, Name FROM Account WHERE Id = :acc.Id LIMIT 1]; 
        System.assertEquals('updatedAccountNameDAOTest testUtilAccDAOLName', upsertedAccount.Name,'upsertAccountsByClientIdentifier');
    }

    //@Description: Should update Account successfully
    @isTest
    private static void testUpdateCustomer() {
        acc = new Account(FirstName = 'testUtilAccDAOFName', LastName = 'testUtilAccDAOLName', ClientIdentifier__c='accDAOTestz');
        acc.Edit_In_VFP__c = true;
        insert acc;
        systemAdmin = setupRunAsUser();
        Test.startTest();
        System.runAs(systemAdmin) {
            acc.FirstName = 'updatedAccountNameDAOTest';
             UTIL_AccountDAO.updateCustomer(acc);
        }    
        Test.stopTest();
        Account upsertedAccount = [SELECT Id, Name FROM Account WHERE Id = :acc.Id LIMIT 1]; 
        System.assertEquals('updatedAccountNameDAOTest testUtilAccDAOLName', upsertedAccount.Name, 'Update Customer');
    }
}