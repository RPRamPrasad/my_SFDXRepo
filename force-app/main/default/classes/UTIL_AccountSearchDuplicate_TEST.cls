/**
* @author Team Stark
* @owner Team Stark
* @name UTIL_AccountSearchDuplicate_TEST
* @createDate 06/19/2020
* @description Common class to access various Account related Searching Duplicate record operations TEST.
* @version 1.0
*/
@isTest(seeAllData=false)
private with sharing class UTIL_AccountSearchDuplicate_TEST {

    @TestSetup
    static void makeData() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;
        
        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false,SystemUser);
        insert passTriggerAll;
        
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemUser);
        objectBasedByPassTrigger.Override_AgentRoleAfterInsert__c = false;
        objectBasedByPassTrigger.Override_AgentRoleBeforeDelete__c = false;
        
        insert objectBasedByPassTrigger;
        
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
        insert sysAdminUserIdSetting;   
    
    }

    private static User setupRunAsUser() {
        return UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
    }

    @isTest private static void testFindDuplicateCustomers() {
        String accountJSON = '{"LastName":"Test Last Name","FirstName":"Test First Name",'
        	+'"BillingAddressType__c":"US","BillingStreet":"Test Street","BillingCity":"Bloomington","BillingState":"IL",'
        	+'"BillingPostalCode":"61704","BillingCountry":"US","PersonMobilePhone":"1234567890","PersonHomePhone":"2345678901",'
            +'"Phone":"3456789012","TDDPhone__c":"5678901234","ShippingStreet":"Test Street"}';
        Test.startTest();
            Object searchList = UTIL_AccountSearchDuplicate.findDuplicateCustomers(accountJSON);
        	System.assert(true,searchList==null);
        Test.stopTest();
    }

    @isTest private static void testGotoVerificationPopup() {
		User runTest1 = UTIL_UserProvisioning_TEST.buildSystemAdmin('alia1','systemAdmin1','systemAdminTest1@statefarm.com');
        RecordType recType = [Select Id From RecordType Where DeveloperName = 'Individual' AND SobjectType = 'Account'];
        Account acc = new Account(FirstName='Faccount',LastName='Laccount',BillingAddressType__c='US',BillingCity='Bloomington',ClientIdentifier__c='SFFSP81LXYZ',RecordTypeId=recType.Id);
        Contact cont = new Contact(FirstName='Test First Name',LastName='Test Last Name');
        System.runAs(setupRunAsUser()){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert acc;
            insert cont;
        }
        
        Test.startTest();
        System.runAs(runTest1){
            UTIL_AccountSearchDuplicate.DuplicateCustomerDataWrap duplicateString = UTIL_AccountSearchDuplicate.gotoVerificationPopup(acc.id);
        	System.assertEquals(false,duplicateString.isAlreadyServicing,'Out of Book search done');
        }
        Test.stopTest();
    }

    @isTest private static void testCreateTaskAndUpdateAgentRole() {

        RecordType recType = [Select Id From RecordType Where DeveloperName = 'Individual' AND SobjectType = 'Account'];
        Account acc = new Account(FirstName='Faccount',LastName='Laccount',BillingAddressType__c='US',BillingCity='Bloomington',ClientIdentifier__c='SFFSP81LXYZ',RecordTypeId=recType.Id);
        Contact cont = new Contact(FirstName='Test First Name',LastName='Test Last Name');
        System.runAs(setupRunAsUser()){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert acc;
            insert cont;
        }
        String reasonJson = '{"accountId":"'+acc.Id+'","personContactId":"'+cont.Id
            +'","selectedReason":"Customer requested service","accessComments":"Test comments","accessKeyMatchCount":1,"isIndividual":true}';
        Test.startTest();
            UTIL_AccountSearchDuplicate.createTaskAndUpdateAgentRole(reasonJson);
        	System.assert(true,[Select id, whatId from Task where whatId = :acc.Id] !=null);
        Test.stopTest();

    }
    
    private static Account createIndividualWithValues() {
        Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('Test Last Name');
        acc.FirstName = 'Test First Name';
        acc.BillingAddressType__c = 'US';
        acc.BillingStreet = 'Test Street Test Street Test Street \n Test Street Test Street Test Street \n Test Street Test Street Test Street Test Street Test Street ';
        acc.BillingCity = 'Bloomington';
        acc.BillingState = 'IL';
        acc.BillingPostalCode = '61704';
        acc.BillingCountry = 'US';
        acc.PersonBirthDate=Date.today()-10000;
        return acc;
    }

}