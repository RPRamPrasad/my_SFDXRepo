/**
 * @description Used to generate data for Insurance Policy tests
 * @Date 02/02/2021
 * @author Team Kraken - Joseph Remy (XGRG)
 */

@isTest
public with sharing class TestDataFactory_InsurancePolicy {

    // Vars
    public static final String ACCOUNT_ONE_CLIENT_ID = 'KRKNCID000A';
    public static final String ACCOUNT_ONE_FIRST_NAME = 'Navn';
    public static final String ACCOUNT_ONE_LAST_NAME = 'Navnsen';

    public static final String ACCOUNT_TWO_CLIENT_ID = 'KRKNCID000B';
    public static final String ACCOUNT_TWO_FIRST_NAME = 'Erika';
    public static final String ACCOUNT_TWO_LAST_NAME = 'Mustermann';

    public static final String POLICY_ASSURANT_HEALTH_SRC_SYS_ID = 'KRKNASSURH1';
    public static final String POLICY_BUSINESS_FIRE_SRC_SYS_ID = 'KRKNFIREBF1';
    public static final String POLICY_COMMERCIAL_AUTO_SRC_SYS_ID = 'KRKNAUTOCA1';
    public static final String POLICY_PRIVATE_PASSENGER_SRC_SYS_ID = 'KRKNAUTOPP1';
    public static final String POLICY_RENTERS_POLICY_SRC_SYS_ID = 'KRKNFIRERP1';
    public static final String POLICY_SHORT_TERM_LIFE_SRC_SYS_ID = 'KRKNLIFEST1';

    public static final String USER_ALIAS = 'KRKN';
    public static final String USER_ASSOC_ID = 'KRKNTESTAGT';
    public static final String USER_EXTERNAL_ID = 'KRKNTESTAGT_KRKNTESTAGT';
    public static final String USER_FIRST_NAME = 'Ash';
    public static final String USER_LAST_NAME = 'The-Agent';
    public static final String USER_STAGT_CODE = '3-9999';
    public static final String USER_TERRITORY_ASSOC_ID = 'KRKNTRASCID';
    public static final String USER_USERNAME = 'ash.the-agent.krkn@statefarm.com';

    /**
     * @description Creates two accounts, their household, a servicing agent user,
     * and *SIX* different policies! *sparkle sparkle*
     * @return List of Insurance Policies created
     */
    public static List<InsurancePolicy> createHouseholdWithPolicies() {


        User systemUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('Alias','SystemSA','systemUser@statefarm.com');
        insert systemUser;

        User syncUser = UTIL_UserProvisioning_TEST.buildUserWith103APIProfile();
        insert syncUser;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(syncUser);
        List<PermissionSetAssignment> psAssignments = assignPSets(syncUser);
        insert psAssignments;

        // Create Agent
        User testAgentUser = new User(Alias=USER_ALIAS,LastName=USER_LAST_NAME,Username=USER_USERNAME,Associate_ID__c=USER_ASSOC_ID,UserExternalID__c=USER_EXTERNAL_ID,Servicing_Agent_Associate_ID__c=USER_ASSOC_ID,Territory_Associate_ID__c=USER_TERRITORY_ASSOC_ID,Servicing_Agent_Associate_ID_List__c=USER_ASSOC_ID,Territory_Associate_ID_List__c=USER_TERRITORY_ASSOC_ID);
        User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser(testAgentUser);
        agentUser.FirstName = USER_FIRST_NAME;
        insert(agentUser);

        Account account1;
        Account account2;
        Account household;

        System.runAs(systemUser) {
            CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=true);
            insert passTriggerAll;
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();

            // Get household record type
            Id householdRTId = PolicySummaryController.getHouseholdRecordTypeId();

            // Create Accounts
            household = new Account(Name='Household', RecordTypeId=householdRTId, AllowHousehold__c = true);
            
            insert household;

            account1 = new Account(FirstName = ACCOUNT_ONE_FIRST_NAME,
                                            LastName = ACCOUNT_ONE_LAST_NAME,
                                            ClientIdentifier__c = ACCOUNT_ONE_CLIENT_ID,
                                            Primary_Household__pc = household.Id);
            insert account1;

            Contact contact1 = [SELECT id from Contact where AccountId=:account1.Id];

            account2 = new Account(FirstName = ACCOUNT_TWO_FIRST_NAME,
                                            LastName = ACCOUNT_TWO_LAST_NAME,
                                            ClientIdentifier__c = ACCOUNT_TWO_CLIENT_ID,
                                            Primary_Household__pc = household.Id);
            insert account2;

            Contact contact2 = [SELECT id from Contact where AccountId=:account2.Id];

            // Create ACRs for Household Rollup
            List<AccountContactRelation> acctContactRels = new List<AccountContactRelation> {
                new AccountContactRelation(
                    AccountId = household.Id,
                    ContactId = contact1.Id,
                    FinServ__PrimaryGroup__c = true,
                    FinServ__Primary__c = true,
                    FinServ__RollUps__c = 'All'
                ),
                new AccountContactRelation(
                    AccountId = household.Id,
                    ContactId = contact2.Id,
                    FinServ__PrimaryGroup__c = true,
                    FinServ__RollUps__c = 'All'
                )
            };

            insert acctContactRels;
        }

        List<InsurancePolicy> policies = new List<InsurancePolicy>();

        System.runAs(syncUser) {
            // Create Insurance Policy 1 (Auto, Terminated)
            TestDataFactory_InsurancePolicyWrapper createPrivateWrapper = new TestDataFactory_InsurancePolicyWrapper();
            createPrivateWrapper.agent = agentUser;
            createPrivateWrapper.pni = account1;
            createPrivateWrapper.ani = account2;
            createPrivateWrapper.householdAcct = household;
            policies.add(createPrivatePassengerPolicy(createPrivateWrapper));

            // Create Insurance Policy 2 (Fire, In Force, Newer Inception)
            policies.add(createRentersPolicy(agentUser, account2, household));
            
            // Create Insurance Policy 3 (Fire, In Force, Older Inception)
            policies.add(createBusinessFirePolicy(agentUser, account1, household));

            // Create Insurance Policy 4 (Life, Proposed)
            TestDataFactory_InsurancePolicyWrapper createShortTermWrapper = new TestDataFactory_InsurancePolicyWrapper();
            createShortTermWrapper.agent = agentUser;
            createShortTermWrapper.pni = account2;
            createShortTermWrapper.ani = account2;
            createShortTermWrapper.householdAcct = household;
            policies.add(createShortTermLifePolicy(createShortTermWrapper));

            // Create Insurance Policy 5 (Health, Suspended)
            TestDataFactory_InsurancePolicyWrapper createAssurantHealthWrapper = new TestDataFactory_InsurancePolicyWrapper();
            createAssurantHealthWrapper.agent = agentUser;
            createAssurantHealthWrapper.pni = account2;
            createAssurantHealthWrapper.ani = account1;
            createAssurantHealthWrapper.householdAcct = household;
            policies.add(createAssurantHealthPolicy(createAssurantHealthWrapper));

            // Create Insurance Policy 6 (Auto, In Force)
            TestDataFactory_InsurancePolicyWrapper createCommercialWrapper = new TestDataFactory_InsurancePolicyWrapper();
            createCommercialWrapper.agent = agentUser;
            createCommercialWrapper.pni = account1;
            createCommercialWrapper.ani = account2;
            createCommercialWrapper.householdAcct = household;
            policies.add(createCommercialAutoPolicy(createCommercialWrapper));
        }

        return policies;
    }

    /**
     * @description Gets an Account by ClientIdentifier__c
     * @param clientId Client id of customer/account
     * @return Account w/ matching client id or null
     */
    public static Account getAccountByClientId(String clientId) {
        return [SELECT FirstName, LastName, Id, ClientIdentifier__c, Primary_Household__pc, Name, RecordTypeId
                    FROM Account
                    WHERE ClientIdentifier__c = :clientId LIMIT 1];
    }

    /**
     * @description Gets Household Account obj by member Account's Client Id.
     * @param clientId Client id of member Account
     * @return Household Account obj or null
     */
    public static Account getPrimaryHouseholdByMemberClientId(String clientId) {
        Account acct = getAccountByClientId(clientId);

        return [SELECT Name,RecordTypeId,Id
            FROM Account
            WHERE Id = :acct.Primary_Household__pc
            LIMIT 1];
    }

    /**
     * @description Gets Insurance Policy + Assets and Particpants based on Source System Identifier.
     * @param agreIndexId AKA Source System Identifier on IP
     * @return InsurancePolicy w/ Assets (InsurancePolicyAssets list) and Participants (InsurancePolicyParticipants list)
     */
    public static InsurancePolicy getInsurancePolicyBySourceSystemId(String agreIndexId) {
        return [SELECT PolicyName, Name, SourceSystemIdentifier, PolicyType, NameInsuredId, Status,
                        ProdLineCd__c, CancellationDate, EffectiveDate, RenewalDate, FinServ__Household__c,
                        (SELECT Id, InsurancePolicyId, SourceSystemIdentifier, Description__c, RiskStatusText__c, 
                                RiskEndDate__c
                            FROM InsurancePolicyAssets),
                        (SELECT Id, InsurancePolicyId, PrimaryParticipantAccountId, Role, RoleNameCd__c,
                                SourceSystemIdentifier, FinServ__Household__c
                            FROM InsurancePolicyParticipants)
                    FROM InsurancePolicy
                    WHERE SourceSystemIdentifier = :agreIndexId LIMIT 1];
    }
/**
 * @description TestDataFactory_InsurancePolicyWrapper
 */
public class TestDataFactory_InsurancePolicyWrapper {
    User agent;
    Account pni;
    Account ani;
    Account householdAcct;
}
    /**
     * @description Create Private Passenger Policy - (Auto, Terminated)
     * @param createWrapper
     * @return  `InsurancePolicy`
     */
    public static InsurancePolicy createPrivatePassengerPolicy(TestDataFactory_InsurancePolicyWrapper createWrapper) {
        CreateInsurancePolicyWrapper createInsuranceWrapper = new CreateInsurancePolicyWrapper();
        createInsuranceWrapper.policyDescription = 'PRIVATE PASSENGER';
        createInsuranceWrapper.dispPolNum = 'G06KRKN-A28-13M';
        createInsuranceWrapper.agreIndexId = POLICY_PRIVATE_PASSENGER_SRC_SYS_ID;
        createInsuranceWrapper.lobText = 'Auto';
        createInsuranceWrapper.servicingAgent = createWrapper.agent;
        createInsuranceWrapper.nameInsured = createWrapper.pni;
        createInsuranceWrapper.status = 'Terminated';
        createInsuranceWrapper.householdAcct = createWrapper.householdAcct;
    
        InsurancePolicy ip = createInsurancePolicy(createInsuranceWrapper);

        ip.CancellationDate = DateTime.valueOf('2016-06-28 12:00:00.000Z');
        ip.EffectiveDate = DateTime.valueOf('1997-01-27 12:00:00.000Z');
        ip.RenewalDate = DateTime.valueOf('2017-01-27 12:00:00.000Z');

        if(createWrapper.householdAcct != null){
            ip.FinServ__Household__c = createWrapper.householdAcct.Id;
        }

        insert ip;

        // Asset
        CreateInsurancePolicyAssetWrapper newcreateInsuranceWrapper= new CreateInsurancePolicyAssetWrapper();
        newcreateInsuranceWrapper.insurancePolicy = ip;
        newcreateInsuranceWrapper.riskNumber = '';
        newcreateInsuranceWrapper.riskDescription = '2004 HYUNDAI ELANTRA 4DR';
        newcreateInsuranceWrapper.riskEndDate = '2016-06-28';
        newcreateInsuranceWrapper.riskStatus = 'Terminated';
        InsurancePolicyAsset asset = createInsurancePolicyAsset(newcreateInsuranceWrapper);

        insert asset;

        // Partcipant
        createInsurancePolicyParticipantWrapper newcreateInsurancePolicyParticipantWrapper = new createInsurancePolicyParticipantWrapper();
        newcreateInsurancePolicyParticipantWrapper.ip = ip;
        newcreateInsurancePolicyParticipantWrapper.account = createWrapper.ani;
        newcreateInsurancePolicyParticipantWrapper.roleName = 'Named Insured';
        newcreateInsurancePolicyParticipantWrapper.roleNameCd = '18';
        newcreateInsurancePolicyParticipantWrapper.householdAcct = createWrapper.householdAcct;
        InsurancePolicyParticipant participant = createInsurancePolicyParticipant(newcreateInsurancePolicyParticipantWrapper);

        insert participant;

        return ip;
    }

    /**
     * @description Create Commercial Auto Policy - (Auto, In Force) - 4528339910
     * @param createCommercialWrapper
     * @return  `InsurancePolicy`
     */
    public static InsurancePolicy createCommercialAutoPolicy(TestDataFactory_InsurancePolicyWrapper createCommercialWrapper) {
        CreateInsurancePolicyWrapper createInsuranceWrapper = new CreateInsurancePolicyWrapper();
        createInsuranceWrapper.policyDescription = 'Commercial Auto';
        createInsuranceWrapper.dispPolNum = '002KRKN-E19-23';
        createInsuranceWrapper.agreIndexId = POLICY_COMMERCIAL_AUTO_SRC_SYS_ID;
        createInsuranceWrapper.lobText = 'Auto';
        createInsuranceWrapper.servicingAgent = createCommercialWrapper.agent;
        createInsuranceWrapper.nameInsured = createCommercialWrapper.pni;
        createInsuranceWrapper.status = 'In Force';
        createInsuranceWrapper.householdAcct = createCommercialWrapper.householdAcct;
        InsurancePolicy ip = createInsurancePolicy(createInsuranceWrapper);

        ip.EffectiveDate = DateTime.valueOf('2020-11-19 12:00:00.000Z');
        ip.RenewalDate = DateTime.valueOf('2021-05-19 12:00:00.000Z');

        if(createCommercialWrapper.householdAcct != null){
            ip.FinServ__Household__c = createCommercialWrapper.householdAcct.Id;
        }

        insert ip;

        // Asset
        List<InsurancePolicyAsset> assets = new List<InsurancePolicyAsset>();
        CreateInsurancePolicyAssetWrapper newcreateInsuranceWrapper= new CreateInsurancePolicyAssetWrapper();
        newcreateInsuranceWrapper.insurancePolicy = ip;
        newcreateInsuranceWrapper.riskNumber = '001';
        newcreateInsuranceWrapper.riskDescription = 'Vehicle#001 :Truck/Van 2013 OTHER OTHER in Minnesota';
        newcreateInsuranceWrapper.riskEndDate = null;
        newcreateInsuranceWrapper.riskStatus = 'In Force';
        assets.add(createInsurancePolicyAsset(newcreateInsuranceWrapper));
        CreateInsurancePolicyAssetWrapper newcreateInsuranceWrapper1 = new CreateInsurancePolicyAssetWrapper();
        newcreateInsuranceWrapper1.insurancePolicy = ip;
        newcreateInsuranceWrapper1.riskNumber = '002';
        newcreateInsuranceWrapper1.riskDescription = 'Vehicle#002 :Trailer 2005 CHEVROLET S10 BLAZER in Minnesota';
        newcreateInsuranceWrapper1.riskEndDate = null;
        newcreateInsuranceWrapper1.riskStatus = 'In Force';
        assets.add(createInsurancePolicyAsset(newcreateInsuranceWrapper1));

        insert assets;

        // Partcipant
        createInsurancePolicyParticipantWrapper newcreateInsurancePolicyParticipantWrapper = new createInsurancePolicyParticipantWrapper();
        newcreateInsurancePolicyParticipantWrapper.ip = ip;
        newcreateInsurancePolicyParticipantWrapper.account = createCommercialWrapper.ani;
        newcreateInsurancePolicyParticipantWrapper.roleName = 'Named Insured';
        newcreateInsurancePolicyParticipantWrapper.roleNameCd = '18';
        newcreateInsurancePolicyParticipantWrapper.householdAcct = createCommercialWrapper.householdAcct;
        InsurancePolicyParticipant participant = createInsurancePolicyParticipant(newcreateInsurancePolicyParticipantWrapper);

        insert participant;

        return ip;
    }

    /**
     * @description Create Renter's Policy - (Fire, In Force, Inception 2019) - 4529181193
     * @param agent 
     * @param pni 
     * @param householdAcct 
     * @return  `InsurancePolicy`
     */
    public static InsurancePolicy createRentersPolicy(User agent, Account pni, Account householdAcct) {
        CreateInsurancePolicyWrapper createInsuranceWrapper = new CreateInsurancePolicyWrapper();
        createInsuranceWrapper.policyDescription = 'Renters Policy';
        createInsuranceWrapper.dispPolNum = '35-GG-KRKN-0';
        createInsuranceWrapper.agreIndexId = POLICY_RENTERS_POLICY_SRC_SYS_ID;
        createInsuranceWrapper.lobText = 'Fire';
        createInsuranceWrapper.servicingAgent = agent;
        createInsuranceWrapper.nameInsured = pni;
        createInsuranceWrapper.status = 'In Force';
        createInsuranceWrapper.householdAcct = householdAcct;
        InsurancePolicy ip = createInsurancePolicy(createInsuranceWrapper);

        ip.EffectiveDate = DateTime.valueOf('2019-01-06 12:00:00.000Z');
        ip.RenewalDate = DateTime.valueOf('2020-01-06 12:00:00.000Z');

        if(householdAcct != null){
            ip.FinServ__Household__c = householdAcct.Id;
        }

        insert ip;

        // Assets
        List<InsurancePolicyAsset> assets = new List<InsurancePolicyAsset>();
        CreateInsurancePolicyAssetWrapper newcreateInsuranceWrapper= new CreateInsurancePolicyAssetWrapper();
        newcreateInsuranceWrapper.insurancePolicy = ip;
        newcreateInsuranceWrapper.riskNumber = '1';
        newcreateInsuranceWrapper.riskDescription = '1: 7721 KOSTNER AVE, SKOKIE, IL 60076-3619';
        newcreateInsuranceWrapper.riskEndDate = null;
        newcreateInsuranceWrapper.riskStatus = 'In Force';
        InsurancePolicyAsset asset1 = createInsurancePolicyAsset(newcreateInsuranceWrapper);
        assets.add(asset1);

        CreateInsurancePolicyAssetWrapper newcreateInsuranceWrapper1= new CreateInsurancePolicyAssetWrapper();
        newcreateInsuranceWrapper1.insurancePolicy = ip;
        newcreateInsuranceWrapper1.riskNumber = '2';
        newcreateInsuranceWrapper1.riskDescription = '2: 415 E CIRCLE HILL DR APT 106, ARLINGTON HTS, IL 60004-3155';
        newcreateInsuranceWrapper1.riskEndDate = null;
        newcreateInsuranceWrapper1.riskStatus = 'In Force';
        InsurancePolicyAsset asset2 = createInsurancePolicyAsset(newcreateInsuranceWrapper1);
        assets.add(asset2);

        insert assets;

        return ip;
    }

    /**
     * @description Create Business Fire Policy - (Fire, In Force, Inception 2020) - 440207603
     * @param agent 
     * @param pni 
     * @param householdAcct 
     * @return  `InsurancePolicy`
     */
    public static InsurancePolicy createBusinessFirePolicy(User agent, Account pni, Account householdAcct) {
        CreateInsurancePolicyWrapper createInsuranceWrapper = new CreateInsurancePolicyWrapper();
        createInsuranceWrapper.policyDescription = 'Business Fire';
        createInsuranceWrapper.dispPolNum = '93-J9-KRKN-6';
        createInsuranceWrapper.agreIndexId = POLICY_BUSINESS_FIRE_SRC_SYS_ID;
        createInsuranceWrapper.lobText = 'Fire';
        createInsuranceWrapper.servicingAgent = agent;
        createInsuranceWrapper.nameInsured = pni;
        createInsuranceWrapper.status = 'In Force';
        createInsuranceWrapper.householdAcct = householdAcct;
        InsurancePolicy ip = createInsurancePolicy(createInsuranceWrapper);

        ip.EffectiveDate = DateTime.valueOf('2020-10-17 12:00:00.000Z');
        ip.RenewalDate = DateTime.valueOf('2021-10-17 12:00:00.000Z');

        insert ip;

        // Asset
        CreateInsurancePolicyAssetWrapper newcreateInsuranceWrapper= new CreateInsurancePolicyAssetWrapper();
        newcreateInsuranceWrapper.insurancePolicy = ip;
        newcreateInsuranceWrapper.riskNumber = '';
        newcreateInsuranceWrapper.riskDescription = '2475 WEDGEWOOD DR';
        newcreateInsuranceWrapper.riskEndDate = null;
        newcreateInsuranceWrapper.riskStatus = 'In Force';
        InsurancePolicyAsset asset = createInsurancePolicyAsset(newcreateInsuranceWrapper);

        insert asset;

        return ip;
    }

    /**
     * @description Create Life Policy - (Life, Proposed) - 451268668
     * @param createShortWrapper 
     * @return  `InsurancePolicy`
     */
    public static InsurancePolicy createShortTermLifePolicy(TestDataFactory_InsurancePolicyWrapper createShortWrapper) {
        CreateInsurancePolicyWrapper createInsuranceWrapper = new CreateInsurancePolicyWrapper();
        createInsuranceWrapper.policyDescription = 'Select Term - 20';
        createInsuranceWrapper.dispPolNum = 'LF-KRKN-5230';
        createInsuranceWrapper.agreIndexId = POLICY_SHORT_TERM_LIFE_SRC_SYS_ID;
        createInsuranceWrapper.lobText = 'Life';
        createInsuranceWrapper.servicingAgent = createShortWrapper.agent;
        createInsuranceWrapper.nameInsured = createShortWrapper.pni;
        createInsuranceWrapper.status = 'Proposed';
        createInsuranceWrapper.householdAcct = createShortWrapper.householdAcct;
        InsurancePolicy ip = createInsurancePolicy(createInsuranceWrapper);

        insert ip;

        // Asset
        CreateInsurancePolicyAssetWrapper newcreateInsuranceWrapper= new CreateInsurancePolicyAssetWrapper();
        newcreateInsuranceWrapper.insurancePolicy = ip;
        newcreateInsuranceWrapper.riskNumber = '00001';
        newcreateInsuranceWrapper.riskDescription = 'BYRD, TAMMIE M';
        newcreateInsuranceWrapper.riskEndDate = null;
        newcreateInsuranceWrapper.riskStatus = 'Proposed';
        InsurancePolicyAsset asset = createInsurancePolicyAsset(newcreateInsuranceWrapper);

        insert asset;

        // Partcipant
        createInsurancePolicyParticipantWrapper newcreateInsurancePolicyParticipantWrapper = new createInsurancePolicyParticipantWrapper();
        newcreateInsurancePolicyParticipantWrapper.ip = ip;
        newcreateInsurancePolicyParticipantWrapper.account = createShortWrapper.ani;
        newcreateInsurancePolicyParticipantWrapper.roleName = 'Insured Party';
        newcreateInsurancePolicyParticipantWrapper.roleNameCd = '12';
        newcreateInsurancePolicyParticipantWrapper.householdAcct = createShortWrapper.householdAcct;
        InsurancePolicyParticipant participant = createInsurancePolicyParticipant(newcreateInsurancePolicyParticipantWrapper);

        insert participant;

        return ip;
    }
    
    /**
     * @description createAssurantHealthPolicy: Create Health Poliicy - (Health, Suspended) - 366238000
     * @param createAssurantWrapper 
     * @return  `InsurancePolicy`
     */
    public static InsurancePolicy createAssurantHealthPolicy(TestDataFactory_InsurancePolicyWrapper createAssurantWrapper) {
        CreateInsurancePolicyWrapper createInsuranceWrapper = new CreateInsurancePolicyWrapper();
        createInsuranceWrapper.policyDescription = 'ASSURANT HLTH SHORT TERM MED';
        createInsuranceWrapper.dispPolNum = 'XXXXXXX KRKN';
        createInsuranceWrapper.agreIndexId = POLICY_ASSURANT_HEALTH_SRC_SYS_ID;
        createInsuranceWrapper.lobText = 'Health';
        createInsuranceWrapper.servicingAgent = createAssurantWrapper.agent;
        createInsuranceWrapper.nameInsured = createAssurantWrapper.pni;
        createInsuranceWrapper.status = 'Suspended';
        createInsuranceWrapper.householdAcct = createAssurantWrapper.householdAcct;
        InsurancePolicy ip = createInsurancePolicy(createInsuranceWrapper);

        ip.CancellationDate = DateTime.valueOf('2015-09-27 12:00:00.000Z');
        ip.EffectiveDate = DateTime.valueOf('2015-04-01 12:00:00.000Z');

        insert ip;

        // Asset
        CreateInsurancePolicyAssetWrapper newcreateInsuranceWrapper= new CreateInsurancePolicyAssetWrapper();
        newcreateInsuranceWrapper.insurancePolicy = ip;
        newcreateInsuranceWrapper.riskNumber = '00001';
        newcreateInsuranceWrapper.riskDescription = 'ARCHER,KAREN';
        newcreateInsuranceWrapper.riskEndDate = '2016-12-01';
        newcreateInsuranceWrapper.riskStatus = 'Terminated';
        InsurancePolicyAsset asset = createInsurancePolicyAsset(newcreateInsuranceWrapper);

        insert asset;

        // Partcipant
        createInsurancePolicyParticipantWrapper newcreateInsurancePolicyParticipantWrapper = new createInsurancePolicyParticipantWrapper();
        newcreateInsurancePolicyParticipantWrapper.ip = ip;
        newcreateInsurancePolicyParticipantWrapper.account = createAssurantWrapper.ani;
        newcreateInsurancePolicyParticipantWrapper.roleName = 'Insured Party';
        newcreateInsurancePolicyParticipantWrapper.roleNameCd = '12';
        newcreateInsurancePolicyParticipantWrapper.householdAcct = createAssurantWrapper.householdAcct;
        InsurancePolicyParticipant participant = createInsurancePolicyParticipant(newcreateInsurancePolicyParticipantWrapper);

        insert participant;

        return ip;
    }

/**
* @description CreateInsurancePolicyWrapper
*/
public class CreateInsurancePolicyWrapper{
        String policyDescription;
        String dispPolNum;
        String agreIndexId;
        String lobText;
        User servicingAgent;
        Account nameInsured;
        String status;
        Account householdAcct;
}
     /**
       * @description createInsurancePolicy : Creates an Insurance Policy for Policy Summary Search LWC testing
       * @param createWrapper
       * @return  `InsurancePolicy`
       */
    private static InsurancePolicy createInsurancePolicy(CreateInsurancePolicyWrapper createWrapper) {
        InsurancePolicy ip = new InsurancePolicy(
            PolicyName=createWrapper.policyDescription,
            Name=createWrapper.dispPolNum,
            SourceSystemIdentifier=createWrapper.agreIndexId,
            PolicyType=createWrapper.lobText,
            NameInsuredId=createWrapper.nameInsured.Id,
            Status=createWrapper.status
        );

        if(createWrapper.householdAcct != null){
            ip.FinServ__Household__c = createWrapper.householdAcct.Id;
        }

        ip.ProdLineCd__c = createWrapper.lobText.substring(0,1);

        return ip;
    }

/**
 * @description CreateInsurancePolicyAssetWrapper
 */
public class CreateInsurancePolicyAssetWrapper{
        InsurancePolicy insurancePolicy;
        String riskNumber;
        String riskDescription;
        String riskEndDate;
        String riskStatus;
}
    /**
     * @description createInsurancePolicyAsset: Creates an Asset for an Insurance Policy
     * @param createInsuranceWrapper
     * @return  `InsurancePolicyAsset`
     */
    private static InsurancePolicyAsset createInsurancePolicyAsset(CreateInsurancePolicyAssetWrapper createInsuranceWrapper) {
        InsurancePolicyAsset ipa = new InsurancePolicyAsset(
            InsurancePolicyId=createInsuranceWrapper.insurancePolicy.Id,
            SourceSystemIdentifier=createInsuranceWrapper.insurancePolicy.SourceSystemIdentifier + '~' + createInsuranceWrapper.riskNumber,
            Description__c=createInsuranceWrapper.riskDescription,
            RiskStatusText__c=createInsuranceWrapper.riskStatus
        );

        if(createInsuranceWrapper.riskEndDate != null){
            ipa.RiskEndDate__c = Date.valueOf(createInsuranceWrapper.riskEndDate);
        }

        return ipa;
    }

/**
 * @description CreateInsurancePolicyParticipantWrapper
 */
public class CreateInsurancePolicyParticipantWrapper{
        InsurancePolicy ip;
        Account account;
        String roleName;
        String roleNameCd;
        Account householdAcct;
}

    /**
     * @description createInsurancePolicyParticipant : Creates a Participant for an Insurance Policy
     * @param createInsurancePolicyWrapper
     * @return InsurancePolicyParticipant
     */
    private static InsurancePolicyParticipant createInsurancePolicyParticipant(CreateInsurancePolicyParticipantWrapper createInsurancePolicyWrapper) {
        InsurancePolicyParticipant ipp = new InsurancePolicyParticipant(
            InsurancePolicyId=createInsurancePolicyWrapper.ip.Id,
            PrimaryParticipantAccountId=createInsurancePolicyWrapper.account.Id,
            Role=createInsurancePolicyWrapper.roleName,
            RoleNameCd__c=createInsurancePolicyWrapper.roleNameCd,
            SourceSystemIdentifier=createInsurancePolicyWrapper.ip.SourceSystemIdentifier + '~' + Account.ClientIdentifier__c + '~' + createInsurancePolicyWrapper.roleNameCd
        );

        if(createInsurancePolicyWrapper.householdAcct != null){
            ipp.FinServ__Household__c = createInsurancePolicyWrapper.householdAcct.Id;
        }

        return ipp;
    }

    /**
     * @description assignPSets : Assign permission sets for mock sync user
     * @param testUser
     * @return List<PermissionSetAssignment>
     */
    public static List<PermissionSetAssignment> assignPSets (User testUser){
        PermissionSet psFSC = [Select Id, Name FROM PermissionSet WHERE Name='FSCInsurance'];
        PermissionSet psSync = [Select Id, Name FROM PermissionSet WHERE Name='SF_CRM_FSCPolicySync1_PermSet'];
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment> {
            new PermissionSetAssignment(AssigneeId=testUser.Id,PermissionSetId=psFSC.Id),
            new PermissionSetAssignment(AssigneeId=testUser.Id,PermissionSetId=psSync.Id)
        };
        return assignments;
    }
}