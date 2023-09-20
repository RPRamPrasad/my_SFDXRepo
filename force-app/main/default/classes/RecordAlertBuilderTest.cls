/**
@author Team Skynet
@name RAO_RecordAlertBuilderTest
@createDate 09/8/2022
@description Handles testing for RecordAlertBuilder class
*/
@isTest
(seeAllData=false)
public with sharing class RecordAlertBuilderTest {
    public static User sysAdmin = TestDataFactory_User.getSysAdminUser();
    @TestVisible private static final String ACCOUNT_CLIENT_ID = '12345678915';

    @testSetup
    private static void testSetup(){
        TestUserSetupUtility.setupAgentOffice();
        TestUserSetupUtility.setupSystemAdminUser();
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            Account accountRecord = createAccount();
            setupAgentRole(TestUserSetupUtility.getAgentUser(), accountRecord);
        }
    }

    @TestVisible private static Account createAccount(){
        Account accountRecord = new Account(Edit_In_VFP__c=true,FirstName='fstName',LastName='lstName',
                                            BillingAddressType__c='US',BillingCity='Phoenix',
                                            ClientIdentifier__c=ACCOUNT_CLIENT_ID);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        insert accountRecord;
        return accountRecord;
    }

    @TestVisible private static Account getAccount(){
        return [SELECT Id, Name, PersonContactId, ClientIdentifier__c FROM Account WHERE  ClientIdentifier__c = :ACCOUNT_CLIENT_ID];
    }

    @TestVisible private static void setupAgentRole(User userRecord, Account accountRecord){
        AgentRole__c agentRole = new AgentRole__c();
        agentRole.Agent__c = userRecord.Id;
        agentRole.Customer__c = accountRecord.Id;
        agentRole.RelationshipNature__c = 'Customer';
        insert agentRole;
    }

    @isTest
    public static void buildRequiredFieldsTest(){
        Datetime createdDate = Datetime.newInstance(2020, 01, 01);
        Datetime validUntilDate = Datetime.newInstance(2097, 12, 21);
        RecordAlertBuilder raBuilder = new RecordAlertBuilder();

        Test.startTest();
        System.runAs(sysAdmin){

            /*
                TEST - RA BUILDER - ALL Required Fields ARE set
            */
            try{
                RecordAlert testRecordAlert = raBuilder
                .setRecordAlertCategoryId('0qX55000000000BEAQ')
                .setParentId(getAccount().Id)
                .setOwnerId('0055500000A10crAAB')
                .setValidUntilDate(validUntilDate)
                .setWhatId('a1X55000001DHhwEAG')
                .setCreatedDate(createdDate)
                .build();
                System.assertEquals(testRecordAlert.RecordAlertCategoryId , '0qX55000000000BEAQ','RecordAlertCategoryId not set');
                System.assertEquals(testRecordAlert.ParentId, getAccount().Id,'ParentId not set');
                System.assertEquals(testRecordAlert.OwnerId , '0055500000A10crAAB','OwnerId not set');
                System.assertEquals(testRecordAlert.ValidUntilDate , validUntilDate ,'ValidUntilDate not set');
                System.assertEquals(testRecordAlert.EffectiveDate , createdDate ,'CreatedDate not set');
            }catch (Exception e){
                System.assertEquals(e, null, 'Exception Message should be null');
            }
            Test.stopTest();
        }
    }

    /*
        TEST - RA BUILDER - ALL Required Fields ARE NOT set
    */
    @isTest
    public static void fieldParentIdTest(){
        Datetime createdDate = Datetime.newInstance(2020, 01, 01);
        Datetime validUntilDate = Datetime.newInstance(2097, 12, 21);
        RecordAlertBuilder raBuilder = new RecordAlertBuilder();

        Test.startTest();
        System.runAs(sysAdmin){

            try{
                RecordAlert testRecordAlert;
                testRecordAlert = raBuilder
                .setRecordAlertCategoryId('0qX55000000000BEAQ')
                .setOwnerId('0055500000A10crAAB')
                .setValidUntilDate(validUntilDate)
                .setWhatId('a1X55000001DHhwEAG')
                .setCreatedDate(createdDate)
                .build();
            }catch (Exception e){
                System.assertEquals(e.getMessage(), 'RecordAlertBuilder Missing the following fields: parentId', 'Exception Message does not match: parentId');
            }
            Test.stopTest();
        }
    }

    /*
        TEST - RA BUILDER - ALL Required Fields ARE NOT set
    */
    @isTest
    public static void fieldRecordAlertCategoryTest(){
        Datetime createdDate = Datetime.newInstance(2020, 01, 01);
        Datetime validUntilDate = Datetime.newInstance(2097, 12, 21);
        RecordAlertBuilder raBuilder = new RecordAlertBuilder();

        Test.startTest();
        System.runAs(sysAdmin){

            try{
                RecordAlert testRecordAlert;
                testRecordAlert = raBuilder
                .setParentId(getAccount().Id)
                .setOwnerId('0055500000A10crAAB')
                .setValidUntilDate(validUntilDate)
                .setWhatId('a1X55000001DHhwEAG')
                .setCreatedDate(createdDate)
                .build();
            }catch (Exception e){
                System.assertEquals(e.getMessage(), 'RecordAlertBuilder Missing the following fields: recordAlertCategoryId', 'Exception Message does not match: recordAlertCategoryId');
            }
            Test.stopTest();
        }
    }

    /*
        TEST - RA BUILDER - ALL Required Fields ARE NOT set
    */
    @isTest
    public static void fieldOwnerIdTest(){
        Datetime createdDate = Datetime.newInstance(2020, 01, 01);
        Datetime validUntilDate = Datetime.newInstance(2097, 12, 21);
        RecordAlertBuilder raBuilder = new RecordAlertBuilder();

        Test.startTest();
        System.runAs(sysAdmin){

            try{
                RecordAlert testRecordAlert;
                testRecordAlert = raBuilder
                .setRecordAlertCategoryId('0qX55000000000BEAQ')
                .setParentId(getAccount().Id)
                .setValidUntilDate(validUntilDate)
                .setWhatId('a1X55000001DHhwEAG')
                .setCreatedDate(createdDate)
                .build();
            }catch (Exception e){
                System.assertEquals(e.getMessage(), 'RecordAlertBuilder Missing the following fields: ownerId', 'Exception Message does not match: ownerId');
            }
            Test.stopTest();
        }
    }

    /*
        TEST - RA BUILDER - ALL Required Fields ARE NOT set
    */
    @isTest
    public static void fieldValidUntilDateTest(){
        Datetime createdDate = Datetime.newInstance(2020, 01, 01);
        Datetime validUntilDate;
        validUntilDate = Datetime.newInstance(2097, 12, 21);
        RecordAlertBuilder raBuilder = new RecordAlertBuilder();

        Test.startTest();
        System.runAs(sysAdmin){

            try{
                RecordAlert testRecordAlert;
                testRecordAlert = raBuilder
                .setRecordAlertCategoryId('0qX55000000000BEAQ')
                .setParentId(getAccount().Id)
                .setOwnerId('0055500000A10crAAB')
                .setWhatId('a1X55000001DHhwEAG')
                .setCreatedDate(createdDate)
                .build();
            }catch (Exception e){
                System.assertEquals(e.getMessage(), 'RecordAlertBuilder Missing the following fields: validUntilDate', 'Exception Message does not match: validUntilDate');
            }
            Test.stopTest();
        }
    }

    /*
        TEST - RA BUILDER - ALL Required Fields ARE NOT set
    */
    @isTest
    public static void fieldWhatIdTest(){
        Datetime createdDate = Datetime.newInstance(2020, 01, 01);
        Datetime validUntilDate = Datetime.newInstance(2097, 12, 21);
        RecordAlertBuilder raBuilder = new RecordAlertBuilder();

        Test.startTest();
        System.runAs(sysAdmin){

            try{
                RecordAlert testRecordAlert;
                testRecordAlert = raBuilder
                .setRecordAlertCategoryId('0qX55000000000BEAQ')
                .setParentId(getAccount().Id)
                .setOwnerId('0055500000A10crAAB')
                .setValidUntilDate(validUntilDate)
                .setCreatedDate(createdDate)
                .build();
            }catch (Exception e){
                System.assertEquals(e.getMessage(), 'RecordAlertBuilder Missing the following fields: whatId', 'Exception Message does not match: whatId');
            }
            Test.stopTest();
        }
    }

    /*
        TEST - RA BUILDER - ALL Required Fields ARE NOT set
    */
    @isTest
    public static void fieldCreatedDateTest(){
        Datetime createdDate;
        createdDate = Datetime.newInstance(2020, 01, 01);
        Datetime validUntilDate = Datetime.newInstance(2097, 12, 21);
        RecordAlertBuilder raBuilder = new RecordAlertBuilder();

        Test.startTest();
        System.runAs(sysAdmin){

            try{
                RecordAlert testRecordAlert;
                testRecordAlert = raBuilder
                .setRecordAlertCategoryId('0qX55000000000BEAQ')
                .setParentId(getAccount().Id)
                .setOwnerId('0055500000A10crAAB')
                .setValidUntilDate(validUntilDate)
                .setWhatId('a1X55000001DHhwEAG')
                .build();
            }catch (Exception e){
                System.assertEquals(e.getMessage(), 'RecordAlertBuilder Missing the following fields: createdDate', 'Exception Message does not match: createdDate');
            }
            Test.stopTest();
        }
    }

    /*
        TEST - RA BUILDER - ALL Required Fields ARE NOT set
    */
    @isTest
    public static void buildOnlyRequiredTest(){
        Datetime createdDate = Datetime.newInstance(2020, 01, 01);
        Datetime validUntilDate = Datetime.newInstance(2097, 12, 21);
        RecordAlertBuilder raBuilder = new RecordAlertBuilder();

        Test.startTest();
        System.runAs(sysAdmin){

            /*
                TEST - RA BUILDER - All Required Fields Set, and additional Field(s) are added
            */
            try{
                RecordAlert testRecordAlert = raBuilder
                .setRecordAlertCategoryId('0qX55000000000BEAQ')
                .setParentId(getAccount().Id)
                .setOwnerId('0055500000A10crAAB')
                .setValidUntilDate(validUntilDate)
                .setWhatId('a1X55000001DHhwEAG')
                .setCreatedDate(createdDate)
                .build();
                System.assertEquals(testRecordAlert.RecordAlertCategoryId , '0qX55000000000BEAQ','RecordAlertCategoryId not set');
                System.assertEquals(testRecordAlert.ParentId, getAccount().Id,'ParentId not set');
                System.assertEquals(testRecordAlert.OwnerId , '0055500000A10crAAB','OwnerId not set');
                System.assertEquals(testRecordAlert.ValidUntilDate , validUntilDate ,'ValidUntilDate not set');
                System.assertEquals(testRecordAlert.EffectiveDate , createdDate ,'CreatedDate not set');
            }catch (Exception e){
                System.assertEquals(null, e.getMessage(), 'Exception Message should be null');
            }
            Test.stopTest();
        }
    }

    /*
        TEST - RA BUILDER - ALL Required Fields ARE NOT set
    */
    @isTest
    public static void buildAllFieldsTest(){
        Datetime createdDate = Datetime.newInstance(2020, 01, 01);
        Datetime validUntilDate = Datetime.newInstance(2097, 12, 21);
        RecordAlertBuilder raBuilder = new RecordAlertBuilder();

        Test.startTest();
        System.runAs(sysAdmin){

            /*
                TEST - RA BUILDER - All Required Fields Set, and additional Field(s) are added
            */
            try{
                Datetime snoozeUntilDate = Datetime.newInstance(2097, 12, 19);
                RecordAlert testRecordAlert = raBuilder
                .setRecordAlertCategoryId('0qX55000000000BEAQ')
                .setSourceSystemIdentifier('123456789')
                .setHousehold('0015500001Q1TsvAAF')
                .setSnoozeUntilDate(snoozeUntilDate)
                .setisActive(true)
                .setSubject('Simple Conversation')
                .setSeverity('high')
                .setJsonData('{"id":"test"}')
                .setParentId(getAccount().Id)
                .setOwnerId('0055500000A10crAAB')
                .setValidUntilDate(validUntilDate)
                .setWhatId('a1X55000001DHhwEAG')
                .setId('0qZ550000008OgAEAU')
                .setCreatedDate(createdDate)
                .build();
                System.assertEquals(testRecordAlert.RecordAlertCategoryId , '0qX55000000000BEAQ','RecordAlertCategoryId not set');
                System.assertEquals(testRecordAlert.ParentId, getAccount().Id,'ParentId not set');
                System.assertEquals(testRecordAlert.OwnerId , '0055500000A10crAAB','OwnerId not set');
                System.assertEquals(testRecordAlert.ValidUntilDate , validUntilDate ,'ValidUntilDate not set');
                System.assertEquals(testRecordAlert.EffectiveDate , createdDate ,'CreatedDate not set');
                System.assertEquals(testRecordAlert.SourceSystemIdentifier , '123456789' ,'SourceSystemIdentifier not set');
                System.assertEquals(testRecordAlert.SnoozeUntilDate , snoozeUntilDate,'SnoozeUntilDate not set');
                System.assertEquals(testRecordAlert.Subject , 'Simple Conversation' ,'Subject not set');
                System.assertEquals(testRecordAlert.Id, '0qZ550000008OgAEAU' ,'Id not set');
                System.assertEquals(testRecordAlert.Severity, 'high', 'Severity not set');
                System.assertEquals(testRecordAlert.Household__c , '0015500001Q1TsvAAF' ,'Househhold not set');
            }catch (Exception e){
                System.assertEquals(null, e.getMessage(), 'Exception Message should be null');
            }
        }
        Test.stopTest();
    }

}