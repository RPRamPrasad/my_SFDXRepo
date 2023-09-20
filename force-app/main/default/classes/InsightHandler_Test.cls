@isTest(seeAllData = false)
public class InsightHandler_Test {

    private static Account acc {get;set;}
    private static User agentUser {get;set;}
    private static CustomerGroup__c custGroup {get;set;}
    @isTest
    static void validateLWCDataTable() {

        User sysAdminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'syAdTLd'+UTIL_TestUsername_TEST.getTestUsername());

        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();

        System.runAs(sysAdminUser) {
            agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'AGNTName', 'AGNTName','AGNTName','AGNTName_AGNTName');
            agentUser.UserCriteriaList__c = 'ADT_Insight_Pilot';
            insert new List<User>{agentUser};
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Claim_R'];

            SetupEntityAccess sea = new SetupEntityAccess();
            sea.ParentId = ps.Id;
            sea.SetupEntityId = [select Id from CustomPermission where DeveloperName = 'ADT_User'][0].Id;
            insert sea;
            insert new PermissionSetAssignment(AssigneeId = agentUser.id, PermissionSetId = ps.Id);
        }

       Test.startTest();
        setup();
        setupFeatureAccess();
        System.runAs(agentUser) {
            acc = createIndividualWithValues('Alice');
            acc.RecordTypeId = devRecordTypeId;
            acc.clientidentifier__c = 'TESTCLNTID9';
            acc.PersonDoNotCall=false;
            acc.DoNotMail__c=false;
            acc.HasPermissionToMarketingEmail__c ='Yes';
            acc.BillingAddressType__c='US';
            acc.BillingCity='Boone';
            acc.BillingState='IL';
            insert acc;

            InsurancePolicy ips = New InsurancePolicy();
            ips.Name = 'Test IP';
            ips.NameInsuredId = acc.Id;
            Insert ips;

            InsurancePolicy ips1 = New InsurancePolicy();
            ips1.Name = 'Test IP1';
            ips1.NameInsuredId = acc.Id;
            ips1.policyName='Homeowners policy';
            Insert ips1;



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


            List<Account> accList = [SELECT Id, (SELECT Id FROM CPAccounts), (SELECT Id FROM Claims), (SELECT Id FROM BillingParticipants__r) FROM Account WHERE Id=:acc.Id];
            System.assert(accList[0].CPAccounts.size() == 1, 'size of the cp account list should be equal to 1');

            InsightHandler.getInsightData(acc.Id);
        }
        Test.stopTest();

    }
    @isTest
    static void validateLWCDataTable2() {

        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();

        agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'AGNTName', 'AGNTName','AGNTName','AGNTName_AGNTName');
        agentUser.UserCriteriaList__c = 'ADT_Insight_Pilot';
        insert new List<User>{agentUser};
        System.assert(true, 'Mandatory Assert statement on Tests');
       Test.startTest();
        setup();
        setupFeatureAccess();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            acc = createIndividualWithValues('Alice');
            acc.RecordTypeId = devRecordTypeId;
            acc.clientidentifier__c = 'TESTCLNTID9';
            insert acc;

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

            InsurancePolicyParticipant participant =  new InsurancePolicyParticipant(
                RoleNameCd__c = '12',
                SecondaryRoleNameCd__c = '29',
                PrimaryParticipantAccount = acc,
                InsurancePolicyId = ips.Id,
                Role = 'Insured Party'
            );
            insert participant;

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
            clmpart.ClaimId = clm.Id;
            clmpart.roleCd__c = 'NI';
            clmpart.ParticipantAccountId = acc.Id;
            Insert clmpart;

            InsightHandler.getInsightData(acc.Id);
        }
        Test.stopTest();
    }

    @isTest
    private static void testShowTotalLossIndicatorCatch(){
        User sysAdminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'syAdTLd'+UTIL_TestUsername_TEST.getTestUsername());
        System.assert(true, 'Mandatory Assert statement on Tests');
        System.runAs(sysAdminUser){
			InsightHandler.showTotalLossIndicator(null,null,null);
        }
    }

    @isTest
    private static void testShowPropensityIndicatorCatch(){
        User sysAdminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'syAdTLd'+UTIL_TestUsername_TEST.getTestUsername());
        System.assert(true, 'Mandatory Assert statement on Tests');
        System.runAs(sysAdminUser){
			InsightHandler.showPropensityIndicator(null);
        }
    }

    @isTest
    private static void testShowPastDueBillIndicatorCatch(){
        User sysAdminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'syAdTLd'+UTIL_TestUsername_TEST.getTestUsername());
        System.assert(true, 'Mandatory Assert statement on Tests');
        System.runAs(sysAdminUser){
			InsightHandler.showPastDueBillIndicator(null,null,null);
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
    private static void setupFeatureAccess() {

        FeatureAccess__c pilotEntry = new FeatureAccess__c(
                Feature_Name__c = 'ADT_Indicator',
                Managed_By_Team__c = 'Skynet',
                Permission__c = '{ "visible": true }',
                UserFieldName__c ='UserCriteriaList__c',
                UserFieldValue__c = 'ADT_Insight_Pilot'
        );

        insert pilotEntry;
    }

    private static Account createIndividualWithValues(String firstName) {
        Account accCustData = UTIL_CreateCustomerTestData.createIndividualCustomer('Test Last Name');
        accCustData.FirstName = firstName;
        accCustData.BillingAddressType__c = 'US';
        accCustData.BillingStreet = 'Test Street Test Street Test Street \n Test Street Test Street Test Street \n Test Street Test Street Test Street Test Street Test Street ';
        accCustData.BillingCity = 'Bloomington';
        accCustData.BillingState = 'IL';
        accCustData.BillingPostalCode = '61704';
        accCustData.BillingCountry = 'US';
        accCustData.MailingAttention__c= 'Attn';
        accCustData.ShippingAddressType__c = 'US';
        accCustData.ShippingStreet = 'Test Street Test Street Test Street \n Test Street Test Street Test Street \n Test Street Test Street Test Street Test Street Test Street ';
        accCustData.ShippingCity = 'Bloomington';
        accCustData.ShippingState = 'IL';
        accCustData.ShippingPostalCode = '61704';
        accCustData.ShippingCountry = 'US';
        return accCustData;
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
