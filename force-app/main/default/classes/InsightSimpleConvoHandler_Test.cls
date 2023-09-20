@isTest(seeAllData = false)
public class InsightSimpleConvoHandler_Test {

    private static User agentUser {get;set;}
    private static CustomerGroup__c custGroup {get;set;}

    private static SimpleConversation__c buildSimpleConversationRecord(String param_accountId, String param_conductedBy) {
        /*SimpleConversation__c simpleConvRecord = new SimpleConversation__c (Account__c = param_accountId,
                            Status__c = 'New', ConductedBy__c = param_conductedBy, SimpleConversationName__c = 'Test Simple Conv', SimpleConversationType__c = 'Simple Conversation');*/
        return new SimpleConversation__c (Account__c = param_accountId,
                    Status__c = 'New', ConductedBy__c = param_conductedBy, SimpleConversationName__c = 'Test Simple Conv', SimpleConversationType__c = 'Simple Conversation');
    }
    @isTest
    static void testSuccessValidation() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        Account acc= new Account();
        List<Account> accList= new List<Account>();
        User sysAdminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'syAdTLd'+UTIL_TestUsername_TEST.getTestUsername());

        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();

        System.runAs(sysAdminUser) {
            agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'AGNTName', 'AGNTName','AGNTName','AGNTName_AGNTName');

            insert agentUser;
                }


        Test.startTest();
        setup();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            acc = createIndividualWithValues('Alice');
            acc.RecordTypeId = devRecordTypeId;
            acc.clientidentifier__c = 'TESTCLNTID9';
            accList.add(acc);
            insert accList;



            SimpleConversation__c simpConvo = buildSimpleConversationRecord(accList[0].Id, agentUser.id);

            insert simpConvo;
            simpConvo.AppointmentStartDateTime__c = Date.newInstance(2020, 1, 1);
            simpConvo.AppointmentEndDateTime__c = Date.newInstance(2022, 1, 1);
            Update simpConvo;

            List<SimpleConversation__c> simpConv = [SELECT Id, SimpleConversationType__c, AppointmentEndDateTime__c, AppointmentStartDateTime__c,CreatedDate, LastConversationDate__c, Account__c FROM SimpleConversation__c WHERE Account__c =: accList[0].Id];


            List<Account> acList = [SELECT Id, (SELECT Id, SimpleConversationType__c, AppointmentEndDateTime__c, AppointmentStartDateTime__c,CreatedDate, LastConversationDate__c, Account__c, DaysSinceLastConversation__c FROM Simple_Conversations__r) FROM Account WHERE Id =: simpConv[0].Account__c];


            InsightSimpleConvoHandler.getSCData(acList);

        }
        Test.stopTest();
        System.assert(true, 'Mandatory Assert statement on Tests');
    }
    @isTest
    static void testErrorValidation() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        Account acc= new Account();
        List<Account> accList= new List<Account>();
        User sysAdminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'syAdTLd'+UTIL_TestUsername_TEST.getTestUsername());

        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();

        System.runAs(sysAdminUser) {
            agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'AGNTName', 'AGNTName','AGNTName','AGNTName_AGNTName');

            insert agentUser;
                }


        Test.startTest();
        setup();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            acc = createIndividualWithValues('Alice');
            acc.RecordTypeId = devRecordTypeId;
            acc.clientidentifier__c = 'TESTCLNTID9';
            accList.add(acc);
            insert accList;


            SimpleConversation__c simpConvo = buildSimpleConversationRecord(accList[0].Id, agentUser.id);
            insert simpConvo;
            simpConvo.AppointmentStartDateTime__c = Date.newInstance(2022, 1, 1);
            simpConvo.AppointmentEndDateTime__c = null;
            Update simpConvo;

            List<SimpleConversation__c> simpConv = [SELECT Id, SimpleConversationType__c, AppointmentEndDateTime__c, AppointmentStartDateTime__c,CreatedDate, LastConversationDate__c, Account__c FROM SimpleConversation__c WHERE Account__c =: accList[0].Id];


            List<Account> acList = [SELECT Id, (SELECT Id, SimpleConversationType__c,AppointmentEndDateTime__c, AppointmentStartDateTime__c, CreatedDate, LastConversationDate__c, Account__c, DaysSinceLastConversation__c FROM Simple_Conversations__r) FROM Account WHERE Id =: simpConv[0].Account__c];


            InsightSimpleConvoHandler.getSCData(acList);

        }
        Test.stopTest();
        System.assert(true, 'Mandatory Assert statement on Tests');
    }
    @isTest
    static void testErrorValidation2() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        Account acc= new Account();
        List<Account> accList= new List<Account>();
        User sysAdminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'syAdTLd'+UTIL_TestUsername_TEST.getTestUsername());

        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();

        System.runAs(sysAdminUser) {
            agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'AGNTName', 'AGNTName','AGNTName','AGNTName_AGNTName');

            insert agentUser;
                }


        Test.startTest();
        setup();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            acc = createIndividualWithValues('Alice');
            acc.RecordTypeId = devRecordTypeId;
            acc.clientidentifier__c = 'TESTCLNTID9';
            accList.add(acc);
            insert accList;


            SimpleConversation__c simpConvo = buildSimpleConversationRecord(accList[0].Id, agentUser.id);
            insert simpConvo;
            simpConvo.AppointmentStartDateTime__c = Date.newInstance(2020, 1, 1);
            simpConvo.AppointmentEndDateTime__c = Date.newInstance(2022, 1, 1);
            Update simpConvo;

            List<SimpleConversation__c> simpConv = [SELECT Id, SimpleConversationType__c, AppointmentEndDateTime__c, AppointmentStartDateTime__c,CreatedDate, LastConversationDate__c, Account__c FROM SimpleConversation__c WHERE Account__c =: accList[0].Id];


            List<Account> acList = [SELECT Id, (SELECT Id, SimpleConversationType__c,AppointmentEndDateTime__c, AppointmentStartDateTime__c, CreatedDate, LastConversationDate__c, Account__c, DaysSinceLastConversation__c FROM Simple_Conversations__r) FROM Account WHERE Id =: simpConv[0].Account__c];


            InsightSimpleConvoHandler.getSCData(acList);

        }
        Test.stopTest();
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    @isTest
    private static void testGetSCDataCatch(){
        User sysAdminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'syAdTLd'+UTIL_TestUsername_TEST.getTestUsername());
       System.assert(true, 'Mandatory Assert statement on Tests');
        System.runAs(sysAdminUser){
            try {
                Test.startTest();
                InsightSimpleConvoHandler.getSCData(null);
                Test.stopTest();
            } catch (Exception e) {
                System.assertEquals(System.AuraHandledException.class.getName(), e.getTypeName(), 'AuraHandledException is expected');
            }
        }
    }


    private static void setup() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        custGroup = null;
        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(true, agentUser);
        insert passTriggerAll;
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(agentUser);
        objectBasedByPassTrigger.Override_CustomerGroupBeforeInsert__c = true;
        insert objectBasedByPassTrigger;

    }
    private static Account createIndividualWithValues(String firstName) {
        Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('Test Last Name');
        acc.FirstName = firstName;
        acc.BillingAddressType__c = 'US';
        acc.BillingStreet = 'Test Street Test Street Test Street \n Test Street Test Street Test Street \n Test Street Test Street Test Street Test Street Test Street ';
        acc.BillingCity = 'Bloomington';
        acc.BillingState = 'IL';
        acc.BillingPostalCode = '61704';
        acc.BillingCountry = 'US';
        acc.MailingAttention__c= 'Attn';
        acc.ShippingAddressType__c = 'US';
        acc.ShippingStreet = 'Test Street Test Street Test Street \n Test Street Test Street Test Street \n Test Street Test Street Test Street Test Street Test Street ';
        acc.ShippingCity = 'Bloomington';
        acc.ShippingState = 'IL';
        acc.ShippingPostalCode = '61704';
        acc.ShippingCountry = 'US';
        return acc;
    }

}