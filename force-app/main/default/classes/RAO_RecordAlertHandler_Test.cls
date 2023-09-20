/**
@author Team Skynet
@name RAO_RecordAlertHandler_Test
@createDate 09/8/2022
@description Handles testing for RecordAlertHandler class
*/

@isTest
(seeAllData=false)
public with sharing class RAO_RecordAlertHandler_Test {

    private static final String CLASS_NAME = 'RAO_RecordAlertHandler';
    private static final String PLATFORMEVENT_ACTION_CREATE = 'CREATE';
    private static final String PLATFORMEVENT_ACTION_DELETE = 'DELETE';
    private static final String PLATFORMEVENT_ACTION_UPDATE = 'UPDATE';
    private static final String SC_SUBJECT = 'Simple Conversation';

    private static final String CS_RECORDALERTCATEGORY_SIMPLECONVERSATION = 'SimpleConversation';
    private static final CS_RecordAlert_Config__c RECORDALERTCATEGORYID_SIMPLECONVERSATION = CS_RecordAlert_Config__c.getValues(CS_RECORDALERTCATEGORY_SIMPLECONVERSATION);

    @TestVisible private static final String ACCOUNT_CLIENT_ID = '12345678915';
    //@TestVisible private static final String ACCOUNT_ID = '0015500000pVKUFAA4';

    private static Account accountRecord {get;set;}
    private static User agentUser {get;set;}
    private static User sysAdmin {get;set;}

    @TestSetup
    private static void testSetup(){
        TestUserSetupUtility.setupAgentOffice();
        TestUserSetupUtility.setupSystemAdminUser();
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            //Setup Configuration - Bypass Triggers
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false,TestUserSetupUtility.getSysAdminUser());
            insert passTriggerAll;
            CS001_ByPassTriggerGtoZ__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerGtoZ(TestUserSetupUtility.getSysAdminUser());
            objectBasedByPassTrigger.Override_SimpleConversationBeforeInsert__c = true;
            insert objectBasedByPassTrigger;
            //Setup Configuration - RecordAlerts
            createRecordAlertConfiguration();

            //Setup Users + Accounts
            accountRecord = createAccount();
            agentUser = TestUserSetupUtility.getAgentUser();
            setupAgentRole(agentUser, accountRecord);

            sysAdmin = TestUserSetupUtility.getSysAdminUser();

            //Setup Permission Sets
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'FinancialServicesCloudExtension'];
            insert new PermissionSetAssignment(AssigneeId = agentUser.id, PermissionSetId = ps.Id);
            insert new PermissionSetAssignment(AssigneeId = sysAdmin.id, PermissionSetId = ps.Id);

            PermissionSet simpleConvo_ps = [SELECT Id FROM PermissionSet WHERE Name = 'SF_CRM_VirtualMeetingAPTC_PermSetPID'];
            insert new PermissionSetAssignment(AssigneeId = agentUser.id, PermissionSetId = simpleConvo_ps.Id);
        }
        System.runAs(agentUser){
            //Setup Data/Objects
            createSimpleConversation();
        }
    }

    @TestVisible private static void createRecordAlertConfiguration(){
        List<RecordAlertCategory> recordAlertCategoryList = [SELECT Id, DeveloperName, Description, Severity, MasterLabel, CreatedDate, CreatedById FROM RecordAlertCategory];
        CS_RecordAlert_Config__c recordAlertConfig;
        List<CS_RecordAlert_Config__c> configList = new List<CS_RecordAlert_Config__c>();
        for (RecordAlertCategory rac : recordAlertCategoryList){
            recordAlertConfig = new CS_RecordAlert_Config__c();
            recordAlertConfig.Name = rac.DeveloperName;
            recordAlertConfig.Value__c = rac.Id;
            configList.add(recordAlertConfig);
        }
        insert configList;
    }

    @TestVisible private static Account createAccount(){
        Account account_Record = new Account(Edit_In_VFP__c=true,FirstName='fstName',LastName='lstName',
                                            BillingAddressType__c='US',BillingCity='Phoenix',
                                            ClientIdentifier__c=ACCOUNT_CLIENT_ID);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        insert account_Record;
        return account_Record;
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

    @TestVisible private static RecordAlert createRecordAlert(String parent_id, String owner_id, String what_id) {
        RecordAlert ra = new RecordAlert(
            IsActive=true,
            Subject=SC_SUBJECT,
            RecordAlertCategoryId = (Id)RECORDALERTCATEGORYID_SIMPLECONVERSATION.Value__c,
            ParentId=parent_id,
            OwnerId=owner_id,
            ValidUntilDate= Datetime.now(),
            EffectiveDate= Datetime.now(),
            WhatId=what_id);
        insert ra;
        return ra;
    }

    @TestVisible private static Record_Alert__e createRecordAlertEvent(String validDate) {
        SimpleConversation__c scRecord = getSimpleConversation();
        Account account_Record = getAccount();

        /*Record_Alert__e rae = new Record_Alert__e(
            Event_Types__c = 'Simple Conversation',
            ParentId__c = accountRecord.Id,
            ValidUntilDate__c= Date.parse(validDate),
            WhatId__c=scRecord.Id,
            Household__c=accountRecord.Id,
            Action__c='CREATE'
        );*/
        return new Record_Alert__e(
            Event_Types__c = 'Simple Conversation',
            ParentId__c = account_Record.Id,
            ValidUntilDate__c= Date.parse(validDate),
            WhatId__c=scRecord.Id,
            Household__c=account_Record.Id,
            Action__c='CREATE'
        );
    }

    @TestVisible private static SimpleConversation__c createSimpleConversation() {
        SimpleConversation__c sc = new SimpleConversation__c();
        sc.Account__c = accountRecord.Id;
        sc.AppointmentEndDateTime__c = Date.valueOf('2030-09-03T17:25:46.000Z');
        sc.SimpleConversationType__c = 'Simple Conversation';
        sc.Primary_Household__c = '0015500001Q1TsvAAF';

        insert sc;
        return sc;
    }

    @TestVisible private static SimpleConversation__c getSimpleConversation() {
        Account account_Record = getAccount();
        return [SELECT Id, Account__c, Primary_Household__c, AppointmentEndDateTime__c FROM SimpleConversation__c WHERE Account__c =: account_Record.Id];
    }

    @isTest
    public static void newRecordAlertEventSimpleConvoTest(){
        User sys_Admin = TestUserSetupUtility.getSysAdminUser();

        Record_Alert__e recordAlertEvent;
        Map<String,List<RecordAlert>> emptyMap = new Map<String,List<RecordAlert>>();
        RecordAlert ra_results;

        //submitting a request where there is no existing RecordAlert for this event
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            recordAlertEvent = createRecordAlertEvent('08/31/2021');
        }


        Test.startTest();
        System.runAs(sys_Admin) {
            ra_results = RAO_RecordAlertHandler.simpleConversationHandler(recordAlertEvent,emptyMap);
        }

        Test.stopTest();
        System.assertEquals(recordAlertEvent.ParentId__c, ra_results.ParentId, 'Incorrect ParentId');
        System.assertEquals((Id)RECORDALERTCATEGORYID_SIMPLECONVERSATION.Value__c,ra_results.RecordAlertCategoryId,'Incorrect RecordAlertCategoryId');
        System.assertEquals(null, ra_results.Id, 'There should not be any ID field for a new record that does not match');

    }

    @isTest
    public static void updateRecordAlertEventSimpleConvoTest(){

        User agentUser = TestUserSetupUtility.getAgentUser();
        User sys_Admin = TestUserSetupUtility.getSysAdminUser();
        Account account_Record = getAccount();

        Record_Alert__e recordAlertEvent;
        Map<String,List<RecordAlert>> existingMap = new Map<String,List<RecordAlert>>();
        List<RecordAlert> recordAlertList = new List<RecordAlert>();
        RecordAlert ra_results;

        SimpleConversation__c scRecord = getSimpleConversation();
        RecordAlert oldRecordAlert;

        //submitting a request where there is no existing RecordAlert for this event
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            oldRecordAlert = createRecordAlert(account_Record.Id,agentUser.Id,scRecord.Id);

            recordAlertList.add(oldRecordAlert);
            existingMap.put(oldRecordAlert.ParentId,recordAlertList);
            recordAlertEvent = createRecordAlertEvent('08/31/2021');
        }

        Test.startTest();
        System.runAs(sys_Admin) {
            ra_results = RAO_RecordAlertHandler.simpleConversationHandler(recordAlertEvent,existingMap);
        }

        Test.stopTest();
        System.assertEquals(account_Record.Id, ra_results.ParentId, 'Incorrect ParentId');
        System.assertEquals(oldRecordAlert.Id, ra_results.Id, 'There should not be any ID field for a new record that does not match');

    }


    @isTest
    public static void findExistingSimpleConvoTest(){
        User agent_User = TestUserSetupUtility.getAgentUser();
        Account account_Record = getAccount();

        List<RecordAlert> recordAlertList_1 = new List<RecordAlert>();
        RecordAlert ra_results_1;
        List<RecordAlert> recordAlertList_2 = new List<RecordAlert>();
        RecordAlert ra_results_2;
        List<RecordAlert> recordAlertList_3 = new List<RecordAlert>();
        RecordAlert ra_results_3;

        SimpleConversation__c scRecord = getSimpleConversation();

        Test.startTest();
        //submitting a request where there is no existing RecordAlert for this event
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            recordAlertList_1.add(createRecordAlert(account_Record.Id,agent_User.Id,scRecord.Id));

            recordAlertList_2.add(createRecordAlert(account_Record.Id,agent_User.Id,scRecord.Id));

            //List with Match
            ra_results_1 = RAO_RecordAlertHandler.findExistingSimpleConvo(recordAlertList_1);
            //List with no Match
            try{
                ra_results_2 = RAO_RecordAlertHandler.findExistingSimpleConvo(recordAlertList_2);
            } catch(RAO_RecordAlertHandler.RAOMatchNotFoundException e){
                System.assertEquals('No Existing SimpleConversation in Existing Record Alerts',e.getMessage(),'Exception should have been thrown');
            }
            //List with empty List
            try{
                ra_results_3 = RAO_RecordAlertHandler.findExistingSimpleConvo(recordAlertList_3);
            } catch(RAO_RecordAlertHandler.RAOMatchNotFoundException ex){
                System.assertEquals('findExistingSimpleConvo: Empty List of RecordAlerts passed in. Nothing to match against.',ex.getMessage(),'Exception should have been thrown');
            }
        }
        Test.stopTest();
        System.assertEquals(recordAlertList_1.get(0).ParentId, ra_results_1.ParentId, 'Incorrect match');

    }

    @isTest
    public static void updatePlatformEventSimpleConvoTest(){
        SimpleConversation__c scRecord = getSimpleConversation();

        Record_Alert__e raEvent = new Record_Alert__e();
        raEvent.WhatId__c = scRecord.Id;
        raEvent.ParentId__c = scRecord.Account__c;
        raEvent.Action__c = 'CREATE';
        raEvent.Household__c = scRecord.Primary_Household__c;
        raEvent.Event_Types__c = 'Simple Conversation';
        raEvent.ValidUntilDate__c = scRecord.AppointmentEndDateTime__c;

        List<Record_Alert__e> raEventList = new List<Record_Alert__e>();
        raEventList.add(raEvent);

        Record_Alert__e raEvent2 = new Record_Alert__e();
        raEvent2.WhatId__c = scRecord.Id;
        raEvent2.ParentId__c = scRecord.Account__c;
        raEvent2.Action__c = 'UPDATE';
        raEvent2.Household__c = scRecord.Primary_Household__c;
        raEvent2.Event_Types__c = 'Simple Conversation';
        raEvent2.ValidUntilDate__c = scRecord.AppointmentEndDateTime__c.addDays(3);

        List<Record_Alert__e> raEventList2 = new List<Record_Alert__e>();
        raEventList2.add(raEvent2);

        Database.SaveResult result;
        Database.SaveResult result2;

        result = EventBus.publish(raEvent);
        Test.getEventBus().deliver();

        List<RecordAlert> ra_query1 = [SELECT Id,ValidUntilDate from RecordAlert];
        System.assertEquals(1, ra_query1.size(), 'There should be 1 RecordAlert');

        Test.startTest();
        System.assertEquals(raEvent2.WhatId__c, raEvent.WhatId__c, 'WhatIds should match');
        System.assertEquals(Date.parse('09/03/2030'), raEvent.ValidUntilDate__c, 'ValidUntilDate should match');
        System.assertEquals(Date.parse('09/06/2030'), raEvent2.ValidUntilDate__c, 'ValidUntilDate 2 should match');
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            result2 = EventBus.publish(raEvent2);
        }
        Test.stopTest();
        Test.getEventBus().deliver();
        List<RecordAlert> ra_query2 = [SELECT Id,ValidUntilDate,ParentId,WhatId,OwnerId from RecordAlert WHERE WhatId =:raEvent.WhatId__c];

        System.assertEquals(1, ra_query2.size(), 'There should only be 1 RecordAlert'+ra_query2);
        System.assertEquals(Date.parse('09/06/2031'), ra_query2.get(0).ValidUntilDate, 'ValidUntilDate has been updated'+ra_query2);
    }

}