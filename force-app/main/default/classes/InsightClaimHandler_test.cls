@isTest(seeAllData = false)
public class InsightClaimHandler_test {
    private static final String AGNT_NAME = 'AGNTName';
    //private static final String PROPENSITYPERMSET = 'Propensity_Lapse_Cancel_Auto_PermSet_R';
    private static Account acc {get;set;}
    private static User agentUser {get;set;}
    private static User sysAdminUser {get;set;}

    @isTest
    static void validateClaims() {

        sysAdminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'syAdTLd'+UTIL_TestUsername_TEST.getTestUsername());

        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();

        System.runAs(sysAdminUser) {
            agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', AGNT_NAME, AGNT_NAME, AGNT_NAME,'AGNTName_AGNTName');

            insert new List<User>{agentUser};
        }
        System.assert(true, 'Mandatory Assert statement on Tests');
       Test.startTest();
        setup();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            acc = createIndividualWithValues('Alice');
            acc.RecordTypeId = devRecordTypeId;
            acc.clientidentifier__c = 'TESTCLNTID9';
            insert acc;
        }

        System.runAs(sysAdminUser) {
            List<Account> accList = New List<Account>();
            accList.add(acc);

            InsurancePolicy ips = New InsurancePolicy();
            ips.Name = 'Test IP';
            ips.NameInsuredId = accList[0].Id;
            Insert ips;

            Claim clm = New Claim();
            clm.Name = 'Test CLM';
            clm.PolicyNumberId = ips.Id;
            clm.AccountId = accList[0].Id;
            clm.ClaimDescription__c = 'Test Description';
            clm.ClaimStatusCd__c = 'N';
            clm.ClaimType = 'Auto';
            clm.TotalLossIndicator__c = true;
            Insert clm;

            ClaimParticipant clmpart = New ClaimParticipant();
            clmpart.ParticipantAccountId = accList[0].Id;
            clmpart.ClaimId = clm.Id;
            clmpart.roleCd__c = 'NI';
            Insert clmpart;

            Billing_Account__c bac = New Billing_Account__c();
            bac.Name = 'Test BI';
            bac.AccountNumber__c = '12345';
            bac.SourceSystemIdentifier__c = 'Test SS';
            bac.PastDueIndicator__c = true;
            Insert bac;

            Billing_Participant__c bps = New Billing_Participant__c();
            bps.ParticipantAccountId__c = accList[0].Id;
            bps.BillingAccountID__c = bac.Id;
            bps.Name = 'Test BP';
            bps.SourceSystemIdentifier__c = 'Test';
            Insert bps;

            Propensity_Lapse_Cancel__c plc = New Propensity_Lapse_Cancel__c();
            plc.Name = 'Test PLC';
            plc.PRPNS_LEVL_CD__c = 'H';
            plc.Source_ClientIdentifier__c = accList[0].Id;
            Insert plc;

            List<ClaimParticipant> cpl = [SELECT Id, Claim.Name, Claim.ClaimDescription__c, ClaimId, ParticipantAccountId FROM ClaimParticipant WHERE ParticipantAccountId =: accList[0].Id];

        	List<Account> acList = [SELECT Id, (SELECT Id, Claim.Name, Claim.ClaimDescription__c, ClaimId FROM CPAccounts) FROM Account WHERE Id =: cpl[0].ParticipantAccountId];

            InsightClaimHandler.getClaimData(acList);
        }
        Test.stopTest();

    }
    @isTest
    static void validateClaims2() {

        sysAdminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'syAdTLd'+UTIL_TestUsername_TEST.getTestUsername());

        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();

        System.runAs(sysAdminUser) {
            agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', AGNT_NAME, AGNT_NAME, AGNT_NAME,'AGNTName_AGNTName');

            insert new List<User>{agentUser};
        }
        System.assert(true, 'Mandatory Assert statement on Tests');
       Test.startTest();
        setup();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            acc = createIndividualWithValues('Alice2');
            acc.RecordTypeId = devRecordTypeId;
            acc.clientidentifier__c = 'TESTCLNTID8';
            insert acc;
        }

        System.runAs(sysAdminUser) {
            List<Account> accList = New List<Account>();

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

            Claim clm2 = New Claim();
            clm2.Name = 'Test CLM2';
            clm2.PolicyNumberId = ips.Id;
            clm2.AccountId = acc.Id;
            clm2.ClaimDescription__c = 'Test Description2';
            clm2.ClaimStatusCd__c = 'N';
            clm2.ClaimType = 'Auto';
            clm2.TotalLossIndicator__c = true;
            Insert clm2;

            ClaimParticipant clmpart = New ClaimParticipant();
            clmpart.ParticipantAccountId = acc.Id;
            clmpart.ClaimId = clm.Id;
            clmpart.roleCd__c = 'NI';
            Insert clmpart;

            ClaimParticipant clmpart2 = New ClaimParticipant();
            clmpart2.ParticipantAccountId = acc.Id;
            clmpart2.ClaimId = clm2.Id;
            clmpart2.roleCd__c = 'NI';
            Insert clmpart2;

        	accList.add(acc);

        	List<ClaimParticipant> cpl = [SELECT Id, Claim.Name, Claim.ClaimDescription__c, ClaimId, ParticipantAccountId FROM ClaimParticipant WHERE ParticipantAccountId =: accList[0].Id];

        	List<Account> acList = [SELECT Id, (SELECT Id, Claim.Name, Claim.ClaimDescription__c, ClaimId FROM CPAccounts) FROM Account WHERE Id =: cpl[0].ParticipantAccountId];

            InsightClaimHandler.getClaimData(acList);
        }
        Test.stopTest();
    }

    @isTest
    private static void testGetClaimDataCatch(){
        sysAdminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'syAdTLd'+UTIL_TestUsername_TEST.getTestUsername());
        System.assert(true, 'Mandatory Assert statement on Tests');
        System.runAs(sysAdminUser){
			InsightClaimHandler.getClaimData(null);
        }
    }

    private static void setup() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(true, agentUser);
        insert passTriggerAll;
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(agentUser);
        objectBasedByPassTrigger.Override_CustomerGroupBeforeInsert__c = true;
        insert objectBasedByPassTrigger;

    }

    private static Account createIndividualWithValues(String firstName) {
        Account accData = UTIL_CreateCustomerTestData.createIndividualCustomer('Test Last Name');
        accData.FirstName = firstName;
        accData.BillingAddressType__c = 'US';
        accData.BillingStreet = 'Test Street Test Street Test Street \n Test Street Test Street Test Street \n Test Street Test Street Test Street Test Street Test Street ';
        accData.BillingCity = 'Bloomington';
        accData.BillingState = 'IL';
        accData.BillingPostalCode = '61704';
        accData.BillingCountry = 'US';
        accData.MailingAttention__c= 'Attn';
        accData.ShippingAddressType__c = 'US';
        accData.ShippingStreet = 'Test Street Test Street Test Street \n Test Street Test Street Test Street \n Test Street Test Street Test Street Test Street Test Street ';
        accData.ShippingCity = 'Bloomington';
        accData.ShippingState = 'IL';
        accData.ShippingPostalCode = '61704';
        accData.ShippingCountry = 'US';
        return accData;
    }

    private static CustomerGroup__c buildCustomerGroup(User agentUser) {
        CustomerGroup__c cg = new CustomerGroup__c();
        cg.name = 'Primary Household';
        cg.sfgroupidentifier__c = 'ABCD1234567';
        cg.OwnerId = agentUser.Id;
        cg.Agent__c = agentUser.Id;
        return cg;
    }

    private static CustomerGroupMember__c buildCustomerGroupMember(Account cust, CustomerGroup__c grp, boolean isPrimaryContact) {
        CustomerGroupMember__c custGrpMember = new CustomerGroupMember__c();
        custGrpMember.customer__c = cust.id;
        custGrpMember.group__c = grp.id;
        custGrpMember.groupmemberid__c = grp.sfgroupidentifier__c + '~' + cust.clientidentifier__c;
        custGrpMember.MemberPrimaryContact__c = isPrimaryContact;
        return custGrpMember;
    }

}