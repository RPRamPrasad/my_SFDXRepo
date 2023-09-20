@isTest(seeAllData = false)
public class InsightClickHandler_Test {

    private static Account acc {get;set;}
    private static User agentUser {get;set;}
    private static CustomerGroup__c custGroup {get;set;}

    @isTest
    static void testmethod1() {

        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();

        agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'AGNTName', 'AGNTName','AGNTName','AGNTName_AGNTName');

        insert new List<User>{agentUser};


      Test.startTest();
        setup();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            acc = createIndividualWithValues('Alice');
            acc.RecordTypeId = devRecordTypeId;
            acc.clientidentifier__c = 'TESTCLNTID9';
            insert acc;

            Map<string,object> checkVal = new Map<string,object>();
            String targetValue = 'New Simple Conversation';
            String url = 'http://';
            String clickLabel = 'Meet Now';
            InsightClickHandler.GetClickDetailWrapperList detailsWrap = new InsightClickHandler.GetClickDetailWrapperList();
		        detailsWrap.targetValue = targetValue;
		        detailsWrap.accountId = acc.Id;
		        detailsWrap.url = url;
		        detailsWrap.clickLabel = clickLabel;
	        checkVal = InsightClickHandler.getclickDetails(detailsWrap);
            System.assert(!checkVal.isEmpty(), 'size of the checkVal should be greater than 0');

            InsurancePolicy ips = New InsurancePolicy();
            ips.Name = 'Test IP';
            ips.NameInsuredId = acc.Id;
            Insert ips;

            Claim clm = New Claim();
            clm.Name = 'Test CLM';
            clm.PolicyNumberId = ips.Id;
           // clm.AccountId = acc.Id;
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


            List<Account> accList = [SELECT Id, (SELECT Id FROM CPAccounts), (SELECT Id FROM Claims), (SELECT Id FROM BillingParticipants__r) FROM Account WHERE Id=:acc.Id];
            System.assert(accList[0].CPAccounts.size() == 1, 'size of the accList[0].CPAccounts should be equal to 1');


        }
        Test.stopTest();

    }

        @isTest
        static void testmethod2() {

        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();

        agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'AGNTName', 'AGNTName','AGNTName','AGNTName_AGNTName');

        insert new List<User>{agentUser};

       Test.startTest();
        setup();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            acc = createIndividualWithValues('Alice');
            acc.RecordTypeId = devRecordTypeId;
            acc.clientidentifier__c = 'TESTCLNTID9';
            insert acc;

            Map<string,object> checkVal = new Map<string,object>();
            String targetValue = 'TestAbc';
            String url = 'http://';
            String clickLabel = 'Meet Now';
            InsightClickHandler.GetClickDetailWrapperList getDetailWrap = new InsightClickHandler.GetClickDetailWrapperList();
				getDetailWrap.targetValue = targetValue;
				getDetailWrap.accountId = acc.Id;
				getDetailWrap.url = url;
				getDetailWrap.clickLabel = clickLabel;
			checkVal = InsightClickHandler.getclickDetails(getDetailWrap);
            System.assert(!checkVal.isEmpty(), 'size of the checkVal should be greater than 0');

            InsurancePolicy ips = New InsurancePolicy();
            ips.Name = 'Test IP';
            ips.NameInsuredId = acc.Id;
            Insert ips;

            Claim clm = New Claim();
            clm.Name = 'Test CLM';
            clm.PolicyNumberId = ips.Id;
           // clm.AccountId = acc.Id;
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


            List<Account> accList = [SELECT Id, (SELECT Id FROM CPAccounts), (SELECT Id FROM Claims), (SELECT Id FROM BillingParticipants__r) FROM Account WHERE Id=:acc.Id];
            System.assert(accList[0].CPAccounts.size() == 1, 'size of the accList[0].CPAccounts should be equal to 1');


        }
        Test.stopTest();

    }
    @isTest
    static void testmethod3() {

        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();

        agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'AGNTName', 'AGNTName','AGNTName','AGNTName_AGNTName');

        insert new List<User>{agentUser};

       Test.startTest();
        setup();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            acc = createIndividualWithValues('Alice');
            acc.RecordTypeId = devRecordTypeId;
            acc.clientidentifier__c = 'TESTCLNTID9';
            insert acc;

            Map<string,object> checkVal = new Map<string,object>();
            String targetValue = 'Simple Conversation - ABS';
            String url = 'http://';
            String clickLabel = 'Meet Now';
            InsightClickHandler.GetClickDetailWrapperList detailWrap = new InsightClickHandler.GetClickDetailWrapperList();
				detailWrap.targetValue = targetValue;
				detailWrap.accountId = acc.Id;
				detailWrap.url = url;
				detailWrap.clickLabel = clickLabel;
            checkVal = InsightClickHandler.getclickDetails(detailWrap);
            System.assert(!checkVal.isEmpty(), 'size of the checkVal should be greater than 0');

            Billing_Account__c bac = New Billing_Account__c();
            bac.Name = 'Test BI';
            bac.AccountNumber__c = '12345';
            bac.SourceSystemIdentifier__c = 'Test SS';
            Insert bac;

            Billing_Participant__c bps = New Billing_Participant__c();
            bps.ParticipantAccountId__c = acc.Id;
            bps.BillingAccountID__c = bac.Id;
            bps.Name = 'Test BP';
            bps.SourceSystemIdentifier__c = 'Test';
            Insert bps;

            InsurancePolicy ips = New InsurancePolicy();
            ips.Name = 'Test IP';
            ips.NameInsuredId = acc.Id;
            Insert ips;

            Claim clm = New Claim();
            clm.Name = 'Test CLM';
            clm.PolicyNumberId = ips.Id;
           // clm.AccountId = acc.Id;
            clm.ClaimDescription__c = 'Test Description';
            clm.ClaimStatusCd__c = 'N';
            clm.ClaimType = 'Auto';
            clm.TotalLossIndicator__c = true;
            Insert clm;

            ClaimParticipant clmpart = New ClaimParticipant();
            clmpart.ClaimId = clm.Id;
            clmpart.roleCd__c = 'NI';
            clmpart.ParticipantAccountId = acc.Id;
            Insert clmpart;


        }
        Test.stopTest();

    }

    @isTest
    public static void testCustomerRetentionABS(){
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();

        agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'AGNTName', 'AGNTName','AGNTName','AGNTName_AGNTName');

        insert new List<User>{agentUser};

        Test.startTest();
        setup();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            Map<string,object> checkVal = new Map<string,object>();
            String targetValue = 'Customer Retention - ABS';
            String url = 'http://';
            String clickLabel = 'Meet Now';
            InsightClickHandler.GetClickDetailWrapperList detailWrap = new InsightClickHandler.GetClickDetailWrapperList();
				detailWrap.targetValue = targetValue;
				detailWrap.accountId = null;
				detailWrap.url = null;
				detailWrap.clickLabel = null;
            checkVal = InsightClickHandler.getclickDetails(detailWrap);
            System.assertEquals(checkVal.get('typedetails'), 'standard__webPage', 'Expected typeDetails should be standard__webPage');
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
        Account accTestData = UTIL_CreateCustomerTestData.createIndividualCustomer('Test Last Name');
        accTestData.FirstName = firstName;
        accTestData.BillingAddressType__c = 'US';
        accTestData.BillingStreet = 'Test Street Test Street Test Street \n Test Street Test Street Test Street \n Test Street Test Street Test Street Test Street Test Street ';
        accTestData.BillingCity = 'Bloomington';
        accTestData.BillingState = 'IL';
        accTestData.BillingPostalCode = '61704';
        accTestData.BillingCountry = 'US';
        accTestData.MailingAttention__c= 'Attn';
        accTestData.ShippingAddressType__c = 'US';
        accTestData.ShippingStreet = 'Test Street Test Street Test Street \n Test Street Test Street Test Street \n Test Street Test Street Test Street Test Street Test Street ';
        accTestData.ShippingCity = 'Bloomington';
        accTestData.ShippingState = 'IL';
        accTestData.ShippingPostalCode = '61704';
        accTestData.ShippingCountry = 'US';
        return accTestData;
    }

}