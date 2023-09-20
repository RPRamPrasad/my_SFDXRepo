/**
* @name RecordAlertOrchestrator_Test
* @author Team Skynet
* @createDate 09/01/2022
* @description The Apex test class for RecordAlertOrchestrator class.
*/
@isTest
public with sharing class RecordAlertOrchestrator_Test {

    @TestVisible private static final String ACCOUNT_CLIENT_ID = '12345678915';
    //@TestVisible private static final String ACCOUNT_ID = '0015500000pVKUFAA4';
    private static final String CS_RECORDALERTCATEGORY_SIMPLECONVERSATION = 'SimpleConversation';
    private static final CS_RecordAlert_Config__c RECORDALERTCATEGORYID_SIMPLECONVERSATION = CS_RecordAlert_Config__c.getValues(CS_RECORDALERTCATEGORY_SIMPLECONVERSATION);
    private static Account accountRecord {get;set;}
    private static User agentUser {get;set;}
    private static User sysAdmin {get;set;}

    @testSetup
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
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            //Setup Permission Sets
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
        accountRecord = new Account(Edit_In_VFP__c=true,FirstName='fstName',LastName='lstName',
                                            BillingAddressType__c='US',BillingCity='Phoenix',
                                            ClientIdentifier__c=ACCOUNT_CLIENT_ID);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        insert accountRecord;
        return accountRecord;
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

    @TestVisible private static RecordAlert createRecordAlert(String parent_id, String owner_id, String what_id) {
        RecordAlert ra = new RecordAlert(
            IsActive=true,
            Subject='Simple Conversation',
            RecordAlertCategoryId = (Id)RECORDALERTCATEGORYID_SIMPLECONVERSATION.Value__c,
            ParentId=parent_id,
            OwnerId=owner_id,
            ValidUntilDate= Datetime.now(),
            EffectiveDate= Datetime.now(),
            WhatId=what_id);
        insert ra;
        return ra;
    }

    @TestVisible private static Claim createClaim() {
        //Claim claimRec = new Claim();

        return new Claim();
    }

    @TestVisible private static Account getAccount(){
        return [SELECT Id, Name, PersonContactId, ClientIdentifier__c FROM Account WHERE ClientIdentifier__c = :ACCOUNT_CLIENT_ID];
    }

    @TestVisible private static SimpleConversation__c getSimpleConversation() {
        return [SELECT Id, Account__c, Primary_Household__c, AppointmentEndDateTime__c FROM SimpleConversation__c WHERE Account__c =: accountRecord.Id];
    }

    @TestVisible private static void setupAgentRole(User userRecord, Account accountRecord){
        AgentRole__c agentRole = new AgentRole__c();
        agentRole.Agent__c = userRecord.Id;
        agentRole.Customer__c = accountRecord.Id;
        agentRole.RelationshipNature__c = 'Customer';
        insert agentRole;
    }

    @isTest
    public static void testHandleRecordAlertEvent() {
        User sys_Admin = TestUserSetupUtility.getSysAdminUser();
        accountRecord = getAccount();
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

        Database.SaveResult result;
        Test.startTest();
        System.runAs(sys_Admin){
            result = EventBus.publish(raEvent);

            RecordAlertOrchestrator recordAlertOrchestrator = new RecordAlertOrchestrator();
            recordAlertOrchestrator.handleRecordAlertEvent(raEventList);
        }
        Test.stopTest();

        // Verify SaveResult value
        System.assertEquals(true, result.isSuccess(), 'Unexpected publish result');

        List<RecordAlert> recs = [SELECT Id, WhatId, Household__c, ParentId, Subject FROM RecordAlert];
        System.assertEquals(1, recs.size(), 'Unexpected Record alert counts');
        System.assertEquals('Simple Conversation', recs.get(0).Subject, 'Unexpected Subject');

    }

    @isTest
    public static void testHandleRecordAlertEventDelete() {
        sysAdmin = TestUserSetupUtility.getSysAdminUser();

        accountRecord = getAccount();
        SimpleConversation__c scRecord = getSimpleConversation();

        Record_Alert__e raEvent = new Record_Alert__e();
        raEvent.WhatId__c = scRecord.Id;
        raEvent.ParentId__c = scRecord.Account__c;
        raEvent.Action__c = 'DELETE';
        raEvent.Household__c = scRecord.Primary_Household__c;
        raEvent.Event_Types__c = 'Simple Conversation';
        raEvent.ValidUntilDate__c = scRecord.AppointmentEndDateTime__c;

        List<Record_Alert__e> raEventList = new List<Record_Alert__e>();
        raEventList.add(raEvent);

        RecordAlert oldRecordAlert;
        Database.SaveResult result;

        Test.startTest();
        System.runAs(sysAdmin){
            oldRecordAlert = createRecordAlert(accountRecord.Id, sysAdmin.Id, scRecord.Id);
            result = EventBus.publish(raEvent);
            RecordAlertOrchestrator recordAlertOrchestrator = new RecordAlertOrchestrator();
            recordAlertOrchestrator.handleRecordAlertEvent(raEventList);
        }
        Test.stopTest();

        // Verify SaveResult value
        System.assertEquals(true, result.isSuccess(), 'Unexpected publish result');

        List<RecordAlert> recs = [SELECT Id, WhatId, Household__c, ParentId, Subject FROM RecordAlert WHERE Id =: oldRecordAlert.Id];
        System.assertEquals(0, recs.size(), 'Unexpected Record alert counts');

    }
}