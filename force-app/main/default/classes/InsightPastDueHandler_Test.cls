@isTest(seeAllData = false)
public class InsightPastDueHandler_Test {
    private static final String ITIM_PROC_ID = UTIL_TestUsername_TEST.getTestUsername('itimuser');
    private static Account acc {get;set;}
    private static User agentUser {get;set;}
    private static User sysAdminUser {get;set;}
    private static CustomerGroup__c custGroup {get;set;}

    @isTest
    static void testmethod1() {

        sysAdminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'syAdTLd'+UTIL_TestUsername_TEST.getTestUsername());

        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();

        System.runAs(sysAdminUser) {
            agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'AGNTName', 'AGNTName','AGNTName','AGNTName_AGNTName');

            insert new List<User>{agentUser};
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Propensity_Lapse_Cancel_Auto_PermSet_R'];
            insert new PermissionSetAssignment(AssigneeId = agentUser.id, PermissionSetId = ps.Id);

        }

       Test.startTest();
        setup();
        System.runAs(agentUser) {
            List<Account> acclist = new List<Account>();
            acc = createIndividualWithValues('Alice');
            acc.RecordTypeId = devRecordTypeId;
            acc.clientidentifier__c = 'TESTCLNTID9';
            insert acc;
            acclist.add(acc);

            InsurancePolicy ips = New InsurancePolicy();
            ips.Name = 'Test IP';
            ips.NameInsuredId = acc.Id;
            Insert ips;

            Claim clm = New Claim();
            clm.Name = 'Test CLM';
            clm.PolicyNumberId = ips.Id;
            clm.AccountId = acc.Id;
            clm.ClaimDescription__c = 'Test Description';
            clm.ClaimStatusCd__c = 'N';
            clm.ClaimType = 'Auto';
            clm.TotalLossIndicator__c = true;
            Insert clm;

            ClaimParticipant clmpart = New ClaimParticipant();
            clmpart.ParticipantAccountId = acc.Id;
            clmpart.ClaimId = clm.Id;
            clmpart.roleCd__c = 'NI';
            Insert clmpart;

            SimpleConversation__c simpConvo = New SimpleConversation__c();
            simpConvo.Account__c = acc.Id;
            simpConvo.SimpleConversationType__c = 'Simple Conversation';
            insert simpConvo;

            Billing_Account__c bac = New Billing_Account__c();
            bac.Name = 'Test BI';
            bac.AccountNumber__c = '12345';
            bac.SourceSystemIdentifier__c = 'Test SS';
            bac.PastDueIndicator__c = true;
            Insert bac;

            Billing_Participant__c bps = New Billing_Participant__c();
            bps.ParticipantAccountId__c = acc.Id;
            bps.BillingAccountID__c = bac.Id;
            bps.Name = 'Test BP';
            bps.SourceSystemIdentifier__c = 'Test';
            Insert bps;

            Propensity_Lapse_Cancel__c plc = New Propensity_Lapse_Cancel__c();
            plc.Name = 'Test PLC';
            plc.PRPNS_LEVL_CD__c = 'H';
            plc.Source_ClientIdentifier__c = acc.Id;
            Insert plc;

            ClaimParticipant cpartnt;
            cpartnt = [SELECT ClaimId,Claim.Name,Claim.ClaimDescription__c FROM ClaimParticipant WHERE roleCd__c='NI' and Claim.ClaimStatusCd__c in ('N','O','R') and Claim.ClaimType = 'Auto' and Claim.TotalLossIndicator__c = true and Id=:clmpart.Id];

            InsightHandler.getInsightData(acc.Id);
        }
        Test.stopTest();
        System.assert(true, 'Mandatory Assert statement on Tests');
    }
    @isTest
    static void testmethod2() {

        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();

        agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'AGNTName', 'AGNTName','AGNTName','AGNTName_AGNTName');

        insert new List<User>{agentUser};

        sysAdminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'syAdTLd'+UTIL_TestUsername_TEST.getTestUsername());


        User testCCCLicUser =  new User(Username=UTIL_TestUsername_TEST.getTestUsername('cccLicsU'),Alias='CCCL',Associate_ID__c='1111TEST321',UserExternalID__c='1111TEST321');
        user cccLincensedUser=AP_UserProvisioningProcess_TEST_UTIL.buildcccLincensedUserRecord(testCCCLicUser);

       Test.startTest();
        setup();
        List<Account> acclist = new List<Account>();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser,cccLincensedUser});
        System.runAs(agentUser) {
            acc = createIndividualWithValues('Alice');
            acc.RecordTypeId = devRecordTypeId;
            acc.clientidentifier__c = 'TESTCLNTID9';
            insert acc;
            acclist.add(acc);
        }

        System.runAs(cccLincensedUser) {

            Billing_Account__c bac = New Billing_Account__c();
            bac.Name = 'Test BI';
            bac.AccountNumber__c = '12345';
            bac.SourceSystemIdentifier__c = 'Test SS';
            Insert bac;

            Billing_Participant__c bps = New Billing_Participant__c();
            bps.ParticipantAccountId__c = acclist[0].Id;
            bps.BillingAccountID__c = bac.Id;
            bps.Name = 'Test BP';
            bps.SourceSystemIdentifier__c = 'Test';
            Insert bps;

            InsurancePolicy ips = New InsurancePolicy();
            ips.Name = 'Test IP';
            ips.NameInsuredId = acclist[0].Id;
            Insert ips;

            Claim clm = New Claim();
            clm.Name = 'Test CLM';
            clm.PolicyNumberId = ips.Id;
            clm.AccountId = acclist[0].Id;
            clm.ClaimDescription__c = 'Test Description';
            clm.ClaimStatusCd__c = 'N';
            clm.ClaimType = 'Auto';
            clm.TotalLossIndicator__c = true;
            Insert clm;

            ClaimParticipant clmpart = New ClaimParticipant();
            clmpart.ClaimId = clm.Id;
            clmpart.roleCd__c = 'NI';
            clmpart.ParticipantAccountId = acclist[0].Id;
            Insert clmpart;

            InsightPastDueHandler.getPastDueData(acclist);
        }
        Test.stopTest();
        System.assert(true, 'Mandatory Assert statement on Tests');
    }
    @isTest
    static void testmethod3() {

        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();

        agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'AGNTName', 'AGNTName','AGNTName','AGNTName_AGNTName');

        insert new List<User>{agentUser};

        sysAdminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'syAdTLd'+UTIL_TestUsername_TEST.getTestUsername());

        User testCCCLicUser =  new User(Username=UTIL_TestUsername_TEST.getTestUsername('cccLicsU'),Alias='CCCL',Associate_ID__c='1111TEST321',UserExternalID__c='1111TEST321');
        user cccLincensedUser=AP_UserProvisioningProcess_TEST_UTIL.buildcccLincensedUserRecord(testCCCLicUser);

       Test.startTest();
        setup();
        List<Account> acclist = new List<Account>();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser,cccLincensedUser});
        System.runAs(agentUser) {
            acc = createIndividualWithValues('Alice');
            acc.RecordTypeId = devRecordTypeId;
            acc.clientidentifier__c = 'TESTCLNTID9';
            insert acc;
            acclist.add(acc);
        }

        System.runAs(cccLincensedUser) {

            Billing_Account__c bac = New Billing_Account__c();
            bac.Name = 'Test BI';
            bac.AccountNumber__c = '12345';
            bac.SourceSystemIdentifier__c = 'Test SS';
            bac.PastDueIndicator__c = true;
            Insert bac;

            Billing_Participant__c bps = New Billing_Participant__c();
            bps.ParticipantAccountId__c = acclist[0].Id;
            bps.BillingAccountID__c = bac.Id;
            bps.Name = 'Test BP';
            bps.SourceSystemIdentifier__c = 'Test';
            Insert bps;

            InsurancePolicy ips = New InsurancePolicy();
            ips.Name = 'Test IP';
            ips.NameInsuredId = acclist[0].Id;
            Insert ips;

            Claim clm = New Claim();
            clm.Name = 'Test CLM';
            clm.PolicyNumberId = ips.Id;
            clm.AccountId = acclist[0].Id;
            clm.ClaimDescription__c = 'Test Description';
            clm.ClaimStatusCd__c = 'N';
            clm.ClaimType = 'Auto';
            clm.TotalLossIndicator__c = true;
            Insert clm;

            ClaimParticipant clmpart = New ClaimParticipant();
            clmpart.ClaimId = clm.Id;
            clmpart.roleCd__c = 'NI';
            clmpart.ParticipantAccountId = acclist[0].Id;
            Insert clmpart;

            List<Account> acList = [SELECT Id, (SELECT Id, BillingAccountID__r.PastDueIndicator__c FROM BillingParticipants__r) FROM Account WHERE Id =: bps.ParticipantAccountId__c];

            InsightPastDueHandler.getPastDueData(acList);
        }
        Test.stopTest();
        System.assert(true, 'Mandatory Assert statement on Tests');
    }
    @isTest
    static void testmethod4() {

        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();

        agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'AGNTName', 'AGNTName','AGNTName','AGNTName_AGNTName');

        insert new List<User>{agentUser};

        sysAdminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'syAdTLd'+UTIL_TestUsername_TEST.getTestUsername());

        User testCCCLicUser =  new User(Username=UTIL_TestUsername_TEST.getTestUsername('cccLicsU'),Alias='CCCL',Associate_ID__c='1111TEST321',UserExternalID__c='1111TEST321');
        user cccLincensedUser=AP_UserProvisioningProcess_TEST_UTIL.buildcccLincensedUserRecord(testCCCLicUser);

        system.runAs(sysAdminUser) {
            insert cccLincensedUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser,cccLincensedUser});
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Billing_W'];
            insert new PermissionSetAssignment(AssigneeId = cccLincensedUser.id, PermissionSetId = ps.Id);
        }

       Test.startTest();
        setup();
        List<Account> acclist = new List<Account>();
        System.runAs(agentUser) {
            acc = createIndividualWithValues('Alice');
            acc.RecordTypeId = devRecordTypeId;
            acc.clientidentifier__c = 'TESTCLNTID9';
            insert acc;
            acclist.add(acc);
        }

        System.runAs(cccLincensedUser) {

            Billing_Account__c bac = New Billing_Account__c();
            bac.Name = 'Test BI';
            bac.AccountNumber__c = '12345';
            bac.SourceSystemIdentifier__c = 'Test SS';
            Insert bac;

            Billing_Participant__c bps = New Billing_Participant__c();
            bps.ParticipantAccountId__c = acclist[0].Id;
            bps.BillingAccountID__c = bac.Id;
            bps.Name = 'Test BP';
            bps.SourceSystemIdentifier__c = 'Test';
            Insert bps;

            InsurancePolicy ips = New InsurancePolicy();
            ips.Name = 'Test IP';
            ips.NameInsuredId = acclist[0].Id;
            Insert ips;

            Claim clm = New Claim();
            clm.Name = 'Test CLM';
            clm.PolicyNumberId = ips.Id;
            clm.AccountId = acclist[0].Id;
            clm.ClaimDescription__c = 'Test Description';
            clm.ClaimStatusCd__c = 'N';
            clm.ClaimType = 'Auto';
            clm.TotalLossIndicator__c = true;
            Insert clm;

            ClaimParticipant clmpart = New ClaimParticipant();
            clmpart.ClaimId = clm.Id;
            clmpart.roleCd__c = 'NI';
            clmpart.ParticipantAccountId = acclist[0].Id;
            Insert clmpart;

            InsightPastDueHandler.getPastDueData(acclist);
        }
        Test.stopTest();
        System.assert(true, 'Mandatory Assert statement on Tests');
    }

    @isTest
    private static void testGetPastDueDataCatch(){
       sysAdminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'syAdTLd'+UTIL_TestUsername_TEST.getTestUsername());
       System.assert(true, 'Mandatory Assert statement on Tests');
        System.runAs(sysAdminUser){
			InsightPastDueHandler.getPastDueData(null);
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
        Account accName = UTIL_CreateCustomerTestData.createIndividualCustomer('Test Last Name');
        accName.FirstName = firstName;
        accName.BillingAddressType__c = 'US';
        accName.BillingStreet = 'Test Street Test Street Test Street \n Test Street Test Street Test Street \n Test Street Test Street Test Street Test Street Test Street ';
        accName.BillingCity = 'Bloomington';
        accName.BillingState = 'IL';
        accName.BillingPostalCode = '61704';
        accName.BillingCountry = 'US';
        accName.MailingAttention__c= 'Attn';
        accName.ShippingAddressType__c = 'US';
        accName.ShippingStreet = 'Test Street Test Street Test Street \n Test Street Test Street Test Street \n Test Street Test Street Test Street Test Street Test Street ';
        accName.ShippingCity = 'Bloomington';
        accName.ShippingState = 'IL';
        accName.ShippingPostalCode = '61704';
        accName.ShippingCountry = 'US';
        return accName;
    }

}