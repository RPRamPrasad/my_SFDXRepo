/**
@Author: Team Dream Builders
@name: UTIL_SeparateProcessor_Test
@CreatedDate: 9/01/2016
@Description: This class tests the functionality of UTIL_SeparateProcessor
@TODO: Revisit the class for Additional Logic
@Version <1.0>
@reference: StageOrchestrationProcessor

@Author: Team Golden Spikes - Updated to handle original account planning conversation log record owner as SYSTEM_USER_REC_OWNER for no Book of Business match.
@ModifiedDate: 5/10/2018

@Author: Team Golden Spikes - Updated to handle original account simple conversation record owner as SYSTEM_USER_REC_OWNER for no Book of Business match.
@ModifiedDate: 08/10/2018

@Author: Team ITIC - Updated to handle original account Campaign Members for no Book of Business match.
@ModifiedDate: 09/18/2019
*/
/**
 * @description This class tests the functionality of UTIL_SeparateProcessor
 */
@isTest(SeeAllData=false)
private class UTIL_SeparateProcessor_Test {

    public static Map<String,Id> profileNameIdMap;
    private static User systemUser;
    private static User testAPIUser;
    private static User noAccessUser;
    private static User agentUser;
    private static PermissionSetAssignment psassignment;
    private final static String NEW_CLIENT_TEST_ID = 'BBB5S6J0N';
    private final static String ORIGINAL_CLIENT_TEST_ID = 'BBB5S6J0O';
    private final static String OTHER_ACNT_3 = 'BBB5S7G0O';
    private final static String OTHER_ACNT_4 = 'BBB5S8G0O';
    private final static String OTHER_ACNT_5 = 'BBB5S9G0O';
    private final static String EXTERNAL_TEST_KEY = 'clientId';
    private final static String EXTERNAL_SOURCE_TEST_SYNC_TIME = '2017-10-03T09:40:58.044+0000';
    private static TestData_SalesRoleHierarchy salesRoleHierarchyOriginal1;
    private static TestData_SalesRoleHierarchy salesRoleHierarchyOriginal2;
    private static TestData_SalesRoleHierarchy salesRoleHierarchyNew1;
    private static TestData_SalesRoleHierarchy salesRoleHierarchyOriginal3;
    private final static UTIL_SeparateProcessor PROCESSOR_TEST = new UTIL_SeparateProcessor();
    private static String optyRecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunity_Management').getRecordTypeId();

    /**
     * @description test method setup
     */
    @testsetup
    public static void setup(){
        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=true);
        insert passTriggerAll;

        Profile sysProfile = [Select Id from Profile where name = :UTIL_Constants.SYSTEM_ADMIN_PROFILE_NAME LIMIT 1];
        systemUser = buildtestUser('sepProcSysAd@statefarm.com', sysProfile);
        Profile apiProfile = [Select Id FROM Profile WHERE Name =:UTIL_StageOrchestrationConstants.STAGE_ORCHESTRATION_PROFILE_NAME];
        testAPIUser= buildtestUser('testAPI@statefarm.com', apiProfile);

        UTIL_StageOrchestrationTestUtils.AgentUserWrapper agentWrap = new UTIL_StageOrchestrationTestUtils.AgentUserWrapper();
        agentWrap.a_alias = 'echo';
        agentWrap.a_lastName = 'lastname';
        agentWrap.a_UserName = 'agentUser@statefarm.com';
        agentWrap.a_associateId = 'associate11';
        agentWrap.a_userExternalId = 'externId';
        agentWrap.a_servicingAgentAssocId = 'associate11';

        agentUser = UTIL_StageOrchestrationTestUtils.buildAgentUser(agentWrap);
        insert systemUser;
        insert testAPIUser;
        insert agentUser;
        //build system User
        Profile noAccessUserProfile = [Select Id from Profile where name = :UTIL_Constants.NO_ACCESS_PROFILE_NAME LIMIT 1];
        noAccessUser = buildtestUser('tst111noAccess111111User', noAccessUserProfile);
        insert noAccessUser;
        //build custom setting record
        AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(noAccessUser.id);
        insert accountOwner;
        System.runAs(systemUser) {
            assignPermissionSet(testAPIUser);
        }
        salesRoleHierarchyOriginal1 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('A');
        salesRoleHierarchyOriginal2 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('B');
        salesRoleHierarchyNew1 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('C');
        salesRoleHierarchyOriginal3 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('D');
    }

    //method to build Account Owner custom setting record with the given parameter value
    private static AccountOwnerSystemUserCustomSetting__c buildCustomSettingRecord(String userId) {
        AccountOwnerSystemUserCustomSetting__c actOwnerCs = new AccountOwnerSystemUserCustomSetting__c(Name = UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER, SFDC_USER_ID__c = userId);
        return actOwnerCs;
    }

    @isTest
    static void testSeparateProcessorNewAccountDoesNotExist() {//only original exists for this test
        UTIL_SeparateProcessor.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CUSTOMERGROUPINGS,true);
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='sepProcSysAd@statefarm.com@statefarm.com' ];
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='testAPI@statefarm.com@statefarm.com' ];
        agentUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='agentUser@statefarm.com' ];
        noAccessUser=[SELECT Id  FROM User where lastname='tst111noAccess111111User' ];
        salesRoleHierarchyOriginal1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('A');
        salesRoleHierarchyOriginal2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('B');
        salesRoleHierarchyNew1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('C');
        salesRoleHierarchyOriginal3 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('D');

        List<Account> accountList = new List<Account>();
        List<Relationship__c> relationshipList = new List<Relationship__c>();
        List<ProductsServicedByMe__c> productsServicedByMeList = new List<ProductsServicedByMe__c>();

        accountList.add(createAccount(ORIGINAL_CLIENT_TEST_ID));
        accountList.add(createAccount(OTHER_ACNT_3));
        accountList.add(createAccount(OTHER_ACNT_4));

        System.runas(systemUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accountList;

        }
        Account acct1 = [Select id,ExternalSourceSyncTime__c, ClientIdentifier__c from Account where ClientIdentifier__c=:ORIGINAL_CLIENT_TEST_ID];


        //create Agent Roles for original Account in SFDC
        List<agentRole__C> originalAccountRoles = createAgentRolesData('1C8UTE3', ORIGINAL_CLIENT_TEST_ID, acct1);
        System.runas(systemUser){
            insert originalAccountRoles;
        }


        relationshipList.add(createC2CRelationships(accountList[0].ClientIdentifier__C, accountList[1].ClientIdentifier__C,'Parent'));
        relationshipList.add(createC2CRelationships(accountList[1].ClientIdentifier__C, accountList[0].ClientIdentifier__C,'Son'));
        relationshipList.add(createC2CRelationships(accountList[0].ClientIdentifier__C, accountList[2].ClientIdentifier__C,'Uncle'));
        relationshipList.add(createC2CRelationships(accountList[2].ClientIdentifier__C, accountList[0].ClientIdentifier__C,'Nephew'));

        insert relationshipList;
        List<Relationship__c> relationshipsListPriorExec=[select AccountTwo__r.clientIdentifier__c,AccountOne__r.clientIdentifier__c,RelationshipType__c,RelationshipIdentifier__c
                                                          from Relationship__c where AccountTwo__C=:accountList];

        System.assertEquals(4,relationshipsListPriorExec.size(), 'Size of \'relationshipsListPriorExec\' not equals to 4');
        UTIL_SeparateProcessor_TestWrapper wrap1 = new UTIL_SeparateProcessor_TestWrapper();
        wrap1.accountId = accountList[0].Id;
        wrap1.productType = 'Disability Income';
        wrap1.carrierName = 'Trupanion';
        wrap1.productLine = 'Health';
        productsServicedByMeList.add(createProductsServicedByMe(wrap1));

        UTIL_SeparateProcessor_TestWrapper wrap2 = new UTIL_SeparateProcessor_TestWrapper();
        wrap2.accountId = accountList[0].Id;
        wrap2.productType = 'ATV';
        wrap2.carrierName = 'Maryland Auto Insurance Fund';
        wrap2.productLine = 'Auto';
        productsServicedByMeList.add(createProductsServicedByMe(wrap2));
        insert productsServicedByMeList;

        System.runAs(testAPIUser){
            test.startTest();
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = getJsonString(ORIGINAL_CLIENT_TEST_ID, NEW_CLIENT_TEST_ID, EXTERNAL_SOURCE_TEST_SYNC_TIME);
            stgorcList.add(testStageOrchestration);
            PROCESSOR_TEST.execute(stgorcList);
            test.stopTest();
        }

        Account acctOri = [SELECT Id, ExternalSourceSyncTime__c, ClientIdentifier__c, BillingAddress, FirstName, LastName, (Select Id from ProductsServicedByMe__r) FROM Account
                           WHERE ClientIdentifier__c =:ORIGINAL_CLIENT_TEST_ID];
        Account acctNew = [SELECT Id, ExternalSourceSyncTime__c, ClientIdentifier__c, BillingAddress, FirstName, LastName FROM Account
                           WHERE ClientIdentifier__c =:NEW_CLIENT_TEST_ID];
        List<Account> accountUpdatedList = [Select id from Account where ClientIdentifier__c =: NEW_CLIENT_TEST_ID];
        System.assertEquals(accountUpdatedList.size(), 1, 'Size of \'accountUpdatedList\' not equals to 1');
        System.assertEquals('ALICE', acctOri.FirstName, '\'FirstName\' not equals to \'ALICE\'');
        System.assertEquals('BOBBY', acctNew.FirstName, '\'FirstName\' not equals to \'BOBBY\'');

        System.assertEquals(0,acctOri.ProductsServicedByMe__r.size(), 'Size of \'ProductsServicedByMe__r\' not equals to 0');

        List<Relationship__c> relationshipsList=[select AccountTwo__r.clientIdentifier__c,AccountOne__r.clientIdentifier__c,RelationshipType__c,RelationshipIdentifier__c
                                                 from Relationship__c where AccountTwo__C=:acctOri.id OR  AccountOne__C=:acctOri.id];

        system.assertEquals(ORIGINAL_CLIENT_TEST_ID, relationshipsList.get(0).AccountTwo__r.clientIdentifier__c, 'The given two paramters are not equal');
        system.assertEquals(NEW_CLIENT_TEST_ID, relationshipsList.get(0).AccountOne__r.clientIdentifier__c, 'The given two paramters are not equal');
        system.assertEquals('Other - Non-Relative', relationshipsList.get(0).RelationshipType__c, 'The given two paramters are not equal');
        system.assertEquals(ORIGINAL_CLIENT_TEST_ID+'~'+NEW_CLIENT_TEST_ID, relationshipsList.get(0).RelationshipIdentifier__c, 'The given two paramters are not equal');
        System.assertEquals(2,relationshipsList.size(), 'Size of \'relationshipsList\' not equals to 2');

        CustomerGroup__c actualGroup =[select id,SFGroupIdentifier__c,Agent__C,GroupCategory__c from CustomerGroup__c where SFGroupIdentifier__c='HouseholdA1'];
        system.assertEquals('HouseholdA1', actualGroup.SFGroupIdentifier__c, 'The given two paramters are not equal');
        system.assertEquals('Primary', actualGroup.GroupCategory__c, 'The given two paramters are not equal');
        system.assertEquals(salesRoleHierarchyOriginal1.Agent.Id, actualGroup.Agent__C, 'The given two paramters are not equal');

        CustomerGroupMember__c actualGroupMember=[SELECT Id, Group__c, Customer__c, GroupMemberId__c FROM CustomerGroupMember__c where Customer__c=:acctOri.id];
        system.assertEquals(actualGroup.Id, actualGroupMember.Group__c, 'The given two paramters are not equal');
        system.assertEquals(acctOri.Id, actualGroupMember.Customer__c, 'The given two paramters are not equal');
        system.assertEquals('HouseholdA1~'+ORIGINAL_CLIENT_TEST_ID, actualGroupMember.GroupMemberId__c, 'The given two paramters are not equal');
    }

    @isTest
    static void testNewAccountDoesNotExistWithOutCustomerGroupings() {//only original exists for this test
        UTIL_SeparateProcessor.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CUSTOMERGROUPINGS,false);
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='sepProcSysAd@statefarm.com@statefarm.com' ];
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='testAPI@statefarm.com@statefarm.com' ];
        agentUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='agentUser@statefarm.com' ];
        noAccessUser=[SELECT Id  FROM User where lastname='tst111noAccess111111User' ];
        salesRoleHierarchyOriginal1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('A');
        salesRoleHierarchyOriginal2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('B');
        salesRoleHierarchyNew1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('C');
        salesRoleHierarchyOriginal3 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('D');

        List<Account> accountList = new List<Account>();

        accountList.add(createAccount(ORIGINAL_CLIENT_TEST_ID));
        accountList.add(createAccount(OTHER_ACNT_3));
        accountList.add(createAccount(OTHER_ACNT_4));

        System.runas(systemUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accountList;

        }
        Account acct1 = [Select id,ExternalSourceSyncTime__c, ClientIdentifier__c from Account where ClientIdentifier__c=:ORIGINAL_CLIENT_TEST_ID];


        //create Agent Roles for original Account in SFDC
        List<agentRole__C> originalAccountRoles = createAgentRolesData('1C8UTE3', ORIGINAL_CLIENT_TEST_ID, acct1);
        System.runas(systemUser){
            insert originalAccountRoles;
        }

        System.runAs(testAPIUser){
            test.startTest();
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = getJsonStringWithOutCustomerGroupings(ORIGINAL_CLIENT_TEST_ID, NEW_CLIENT_TEST_ID, EXTERNAL_SOURCE_TEST_SYNC_TIME);
            stgorcList.add(testStageOrchestration);
            PROCESSOR_TEST.execute(stgorcList);
            test.stopTest();
        }

        Account acctOri = [SELECT Id, ExternalSourceSyncTime__c, ClientIdentifier__c, BillingAddress, FirstName, LastName FROM Account
                           WHERE ClientIdentifier__c =:ORIGINAL_CLIENT_TEST_ID];
        Account acctNew = [SELECT Id, ExternalSourceSyncTime__c, ClientIdentifier__c, BillingAddress, FirstName, LastName FROM Account
                           WHERE ClientIdentifier__c =:NEW_CLIENT_TEST_ID];
        List<Account> accountUpdatedList = [Select id from Account where ClientIdentifier__c =: NEW_CLIENT_TEST_ID];
        System.assertEquals(accountUpdatedList.size(), 1, 'Size of \'accountUpdatedList\' not equals to 1');
        System.assertEquals('ALICE', acctOri.FirstName, '\'FirstName\' not equals to \'ALICE\'');
        System.assertEquals('BOBBY', acctNew.FirstName, '\'FirstName\' not equals to \'BOBBY\'');
    }

    @isTest
    static void testSeparateProcessorNewExists() {
        UTIL_SeparateProcessor.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CUSTOMERGROUPINGS,true);
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='sepProcSysAd@statefarm.com@statefarm.com' ];
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='testAPI@statefarm.com@statefarm.com' ];
        agentUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='agentUser@statefarm.com' ];
        noAccessUser=[SELECT Id  FROM User where lastname='tst111noAccess111111User' ];
        salesRoleHierarchyOriginal1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('A');
        salesRoleHierarchyOriginal2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('B');
        salesRoleHierarchyNew1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('C');
        salesRoleHierarchyOriginal3 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('D');

        List<Account> accountList = new List<Account>();
        List<Relationship__c> relationshipList = new List<Relationship__c>();
        List<ProductsServicedByMe__c> productsServicedByMeList = new List<ProductsServicedByMe__c>();
        List<FeedItem> lOrignalAccFeedItem = New List<FeedItem>();

        accountList.add(createAccount(ORIGINAL_CLIENT_TEST_ID));
        accountList.add(createAccount(NEW_CLIENT_TEST_ID));
        accountList.add(createAccount(OTHER_ACNT_3));
        accountList.add(createAccount(OTHER_ACNT_4));
        accountList.add(createAccount(OTHER_ACNT_5));
        System.runas(systemUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accountList;

            //Insertion on new FeedItems for Original Account
            Account acctOriFeedParent = [SELECT Id FROM Account WHERE ClientIdentifier__c =:ORIGINAL_CLIENT_TEST_ID];
            lOrignalAccFeedItem = createFeedItems(acctOriFeedParent.id);
            Insert lOrignalAccFeedItem;
        }

        Account acct1 = [Select id,ExternalSourceSyncTime__c, ClientIdentifier__c from Account where ClientIdentifier__c=:ORIGINAL_CLIENT_TEST_ID];

        //create Agent Roles for original Account in SFDC
        List<agentRole__C> originalAccountRoles = createAgentRolesData('1C8UTE3', ORIGINAL_CLIENT_TEST_ID, acct1);

        insert originalAccountRoles;
        relationshipList.add(createC2CRelationships(accountList[0].ClientIdentifier__C, accountList[2].ClientIdentifier__C,'Father'));
        relationshipList.add(createC2CRelationships(accountList[2].ClientIdentifier__C, accountList[0].ClientIdentifier__C,'Son'));
        relationshipList.add(createC2CRelationships(accountList[0].ClientIdentifier__C, accountList[3].ClientIdentifier__C,'Uncle'));
        relationshipList.add(createC2CRelationships(accountList[3].ClientIdentifier__C, accountList[0].ClientIdentifier__C,'Nephew'));
        relationshipList.add(createC2CRelationships(accountList[1].ClientIdentifier__C, accountList[2].ClientIdentifier__C,'Mother'));
        relationshipList.add(createC2CRelationships(accountList[2].ClientIdentifier__C, accountList[1].ClientIdentifier__C,'Son'));
        relationshipList.add(createC2CRelationships(accountList[1].ClientIdentifier__C, accountList[4].ClientIdentifier__C,'Friend'));
        relationshipList.add(createC2CRelationships(accountList[4].ClientIdentifier__C, accountList[1].ClientIdentifier__C,'Friend'));

        insert relationshipList;

        UTIL_SeparateProcessor_TestWrapper wrap1 = new UTIL_SeparateProcessor_TestWrapper();
        wrap1.accountId = accountList[0].Id;
        wrap1.productType = 'Disability Income';
        wrap1.carrierName = 'Trupanion';
        wrap1.productLine = 'Health';
        productsServicedByMeList.add(createProductsServicedByMe(wrap1));

        UTIL_SeparateProcessor_TestWrapper wrap2 = new UTIL_SeparateProcessor_TestWrapper();
        wrap2.accountId = accountList[0].Id;
        wrap2.productType = 'ATV';
        wrap2.carrierName = 'Maryland Auto Insurance Fund';
        wrap2.productLine = 'Auto';
        productsServicedByMeList.add(createProductsServicedByMe(wrap2));

        UTIL_SeparateProcessor_TestWrapper wrap3 = new UTIL_SeparateProcessor_TestWrapper();
        wrap3.accountId = accountList[1].Id;
        wrap3.productType = 'Disability Income';
        wrap3.carrierName = 'Trupanion';
        wrap3.productLine = 'Health';
        productsServicedByMeList.add(createProductsServicedByMe(wrap3));

        UTIL_SeparateProcessor_TestWrapper wrap4 = new UTIL_SeparateProcessor_TestWrapper();
        wrap4.accountId = accountList[1].Id;
        wrap4.productType = 'ATV';
        wrap4.carrierName = 'Maryland Auto Insurance Fund';
        wrap4.productLine = 'Auto';
        productsServicedByMeList.add(createProductsServicedByMe(wrap4));
        insert productsServicedByMeList;
        System.runAs(testAPIUser){
            test.startTest();
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = getJsonString(ORIGINAL_CLIENT_TEST_ID, NEW_CLIENT_TEST_ID, EXTERNAL_SOURCE_TEST_SYNC_TIME);
            stgorcList.add(testStageOrchestration);
            PROCESSOR_TEST.execute(stgorcList);
            test.stopTest();
        }
        Account acctOri = [SELECT Id, ExternalSourceSyncTime__c, ClientIdentifier__c, BillingAddress, FirstName, LastName, (Select Id from ProductsServicedByMe__r) FROM Account
                           WHERE ClientIdentifier__c =:ORIGINAL_CLIENT_TEST_ID];
        Account acctNew = [SELECT Id, ExternalSourceSyncTime__c, ClientIdentifier__c, BillingAddress, FirstName, LastName, (Select Id from ProductsServicedByMe__r) FROM Account
                           WHERE ClientIdentifier__c =:NEW_CLIENT_TEST_ID];
        List<Account> accountUpdatedList = [Select id from Account where ClientIdentifier__c =: NEW_CLIENT_TEST_ID];
        System.assertEquals(accountUpdatedList.size(), 1, 'Size of \'accountUpdatedList\' not equals to 1');
        System.assertEquals('ALICE', acctOri.FirstName, '\'FirstName\' not equals to \'ALICE\'');
        System.assertEquals('BOBBY', acctNew.FirstName, '\'FirstName\' not equals to \'BOBBY\'');

        System.assertEquals(0,acctOri.ProductsServicedByMe__r.size(), 'Size of \'ProductsServicedByMe__r\' not equals to 0');
        System.assertEquals(2,acctNew.ProductsServicedByMe__r.size(), 'Size of \'ProductsServicedByMe__r\' not equals to 2');

        Relationship__c relationshipOne = [select AccountTwo__r.clientIdentifier__c,AccountOne__r.clientIdentifier__c,RelationshipType__c,RelationshipIdentifier__c
                                           from Relationship__c where AccountTwo__C=:acctOri.id];

        system.assertEquals(NEW_CLIENT_TEST_ID, relationshipOne.AccountOne__r.clientIdentifier__c, 'The given two paramters are not equal');
        system.assertEquals('Other - Non-Relative', relationshipOne.RelationshipType__c, 'The given two paramters are not equal');
        system.assertEquals(ORIGINAL_CLIENT_TEST_ID+'~'+NEW_CLIENT_TEST_ID, relationshipOne.RelationshipIdentifier__c, 'The given two paramters are not equal');
        Relationship__c relationshipTwo = [select AccountTwo__r.clientIdentifier__c,AccountOne__r.clientIdentifier__c,RelationshipType__c,RelationshipIdentifier__c
                                           from Relationship__c where AccountTwo__C=:acctNew.id];

        system.assertEquals(NEW_CLIENT_TEST_ID, relationshipTwo.AccountTwo__r.clientIdentifier__c, 'The given two paramters are not equal');
        system.assertEquals(ORIGINAL_CLIENT_TEST_ID, relationshipTwo.AccountOne__r.clientIdentifier__c, 'The given two paramters are not equal');
        system.assertEquals('Other - Non-Relative', relationshipTwo.RelationshipType__c, 'The given two paramters are not equal');
        system.assertEquals(NEW_CLIENT_TEST_ID+'~'+ORIGINAL_CLIENT_TEST_ID, relationshipTwo.RelationshipIdentifier__c, 'The given two paramters are not equal');

        CustomerGroup__c actualGroup =[select id,SFGroupIdentifier__c,Agent__C,GroupCategory__c from CustomerGroup__c where SFGroupIdentifier__c='HouseholdA1'];
        system.assertEquals('HouseholdA1', actualGroup.SFGroupIdentifier__c, 'The given two paramters are not equal');
        system.assertEquals('Primary', actualGroup.GroupCategory__c, 'The given two paramters are not equal');
        system.assertEquals(salesRoleHierarchyOriginal1.Agent.Id, actualGroup.Agent__C, 'The given two paramters are not equal');

        CustomerGroupMember__c actualGroupMember=[SELECT Id, Group__c, Customer__c, GroupMemberId__c FROM CustomerGroupMember__c where Customer__c=:acctOri.id];
        system.assertEquals(actualGroup.Id, actualGroupMember.Group__c, 'The given two paramters are not equal');
        system.assertEquals(acctOri.Id, actualGroupMember.Customer__c, 'The given two paramters are not equal');
        system.assertEquals('HouseholdA1~'+ORIGINAL_CLIENT_TEST_ID, actualGroupMember.GroupMemberId__c, 'The given two paramters are not equal');
    }

    @isTest
    static void testSeparateProcessorNewExistsWithCustomerGroupingsEnabled() {
        UTIL_SeparateProcessor.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CUSTOMERGROUPINGS,true);
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='sepProcSysAd@statefarm.com@statefarm.com' ];
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='testAPI@statefarm.com@statefarm.com' ];
        agentUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='agentUser@statefarm.com' ];
        noAccessUser=[SELECT Id  FROM User where lastname='tst111noAccess111111User' ];
        salesRoleHierarchyOriginal1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('A');
        salesRoleHierarchyOriginal2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('B');
        salesRoleHierarchyNew1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('C');
        salesRoleHierarchyOriginal3 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('D');

        List<Account> accountList = new List<Account>();
        List<Relationship__c> relationshipList = new List<Relationship__c>();
        List<ProductsServicedByMe__c> productsServicedByMeList = new List<ProductsServicedByMe__c>();
        List<FeedItem> lOrignalAccFeedItem = New List<FeedItem>();
        accountList.add(createAccount(ORIGINAL_CLIENT_TEST_ID));
        accountList.add(createAccount(NEW_CLIENT_TEST_ID));
        accountList.add(createAccount(OTHER_ACNT_3));
        accountList.add(createAccount(OTHER_ACNT_4));
        accountList.add(createAccount(OTHER_ACNT_5));
        System.runas(systemUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accountList;

            //Insertion on new FeedItems for Original Account
            Account acctOriFeedParent = [SELECT Id FROM Account WHERE ClientIdentifier__c =:ORIGINAL_CLIENT_TEST_ID];
            lOrignalAccFeedItem = createFeedItems(acctOriFeedParent.id);
            Insert lOrignalAccFeedItem;
        }

        Account acct1 = [Select id,ExternalSourceSyncTime__c, ClientIdentifier__c from Account where ClientIdentifier__c=:ORIGINAL_CLIENT_TEST_ID];

        //create Agent Roles for original Account in SFDC
        List<agentRole__C> originalAccountRoles = createAgentRolesData('1C8UTE3', ORIGINAL_CLIENT_TEST_ID, acct1);

        insert originalAccountRoles;
        relationshipList.add(createC2CRelationships(accountList[0].ClientIdentifier__C, accountList[2].ClientIdentifier__C,'Father'));
        relationshipList.add(createC2CRelationships(accountList[2].ClientIdentifier__C, accountList[0].ClientIdentifier__C,'Son'));
        relationshipList.add(createC2CRelationships(accountList[0].ClientIdentifier__C, accountList[3].ClientIdentifier__C,'Uncle'));
        relationshipList.add(createC2CRelationships(accountList[3].ClientIdentifier__C, accountList[0].ClientIdentifier__C,'Nephew'));
        relationshipList.add(createC2CRelationships(accountList[1].ClientIdentifier__C, accountList[2].ClientIdentifier__C,'Mother'));
        relationshipList.add(createC2CRelationships(accountList[2].ClientIdentifier__C, accountList[1].ClientIdentifier__C,'Son'));
        relationshipList.add(createC2CRelationships(accountList[1].ClientIdentifier__C, accountList[4].ClientIdentifier__C,'Friend'));
        relationshipList.add(createC2CRelationships(accountList[4].ClientIdentifier__C, accountList[1].ClientIdentifier__C,'Friend'));

        insert relationshipList;

        UTIL_SeparateProcessor_TestWrapper wrap1 = new UTIL_SeparateProcessor_TestWrapper();
        wrap1.accountId = accountList[0].Id;
        wrap1.productType = 'Disability Income';
        wrap1.carrierName = 'Trupanion';
        wrap1.productLine = 'Health';
        productsServicedByMeList.add(createProductsServicedByMe(wrap1));

        UTIL_SeparateProcessor_TestWrapper wrap2 = new UTIL_SeparateProcessor_TestWrapper();
        wrap2.accountId = accountList[0].Id;
        wrap2.productType = 'ATV';
        wrap2.carrierName = 'Maryland Auto Insurance Fund';
        wrap2.productLine = 'Auto';
        productsServicedByMeList.add(createProductsServicedByMe(wrap2));
        insert productsServicedByMeList;
        System.runAs(testAPIUser){
            test.startTest();
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = getJsonStringWithCSameCustomerGrouping(ORIGINAL_CLIENT_TEST_ID, NEW_CLIENT_TEST_ID, EXTERNAL_SOURCE_TEST_SYNC_TIME);
            stgorcList.add(testStageOrchestration);
            PROCESSOR_TEST.execute(stgorcList);
            test.stopTest();
        }
        Account acctOri = [SELECT Id, ExternalSourceSyncTime__c, ClientIdentifier__c, BillingAddress, FirstName, LastName, (Select Id from ProductsServicedByMe__r) FROM Account
                           WHERE ClientIdentifier__c =:ORIGINAL_CLIENT_TEST_ID];
        Account acctNew = [SELECT Id, ExternalSourceSyncTime__c, ClientIdentifier__c, BillingAddress, FirstName, LastName FROM Account
                           WHERE ClientIdentifier__c =:NEW_CLIENT_TEST_ID];
        List<Account> accountUpdatedList = [Select id from Account where ClientIdentifier__c =: NEW_CLIENT_TEST_ID];
        System.assertEquals(accountUpdatedList.size(), 1, 'Size of \'accountUpdatedList\' not equals to 1');
        System.assertEquals('ALICE', acctOri.FirstName, '\'FirstName\' not equals to \'ALICE\'');
        System.assertEquals('BOBBY', acctNew.FirstName, '\'FirstName\' not equals to \'BOBBY\'');

        System.assertEquals(0,acctOri.ProductsServicedByMe__r.size(), 'Size of \'ProductsServicedByMe__r\' not equals to 0');

        List<Relationship__c> relationshipsList=[select AccountTwo__r.clientIdentifier__c,AccountOne__r.clientIdentifier__c,RelationshipType__c,RelationshipIdentifier__c
                                                 from Relationship__c where AccountTwo__C=:acctOri.id OR  AccountOne__C=:acctOri.id];
        if((ORIGINAL_CLIENT_TEST_ID+'~'+NEW_CLIENT_TEST_ID).equals(relationshipsList.get(0).RelationshipIdentifier__c)){
            system.assertEquals(ORIGINAL_CLIENT_TEST_ID, relationshipsList.get(0).AccountTwo__r.clientIdentifier__c, 'The given two paramters are not equal');
            system.assertEquals(NEW_CLIENT_TEST_ID, relationshipsList.get(0).AccountOne__r.clientIdentifier__c, 'The given two paramters are not equal');
            system.assertEquals('Other - Non-Relative', relationshipsList.get(0).RelationshipType__c, 'The given two paramters are not equal');
            system.assertEquals(ORIGINAL_CLIENT_TEST_ID+'~'+NEW_CLIENT_TEST_ID, relationshipsList.get(0).RelationshipIdentifier__c, 'The given two paramters are not equal');
        }else{
            system.assertEquals(ORIGINAL_CLIENT_TEST_ID, relationshipsList.get(1).AccountTwo__r.clientIdentifier__c, 'The given two paramters are not equal');
            system.assertEquals(NEW_CLIENT_TEST_ID, relationshipsList.get(1).AccountOne__r.clientIdentifier__c, 'The given two paramters are not equal');
            system.assertEquals('Other - Non-Relative', relationshipsList.get(1).RelationshipType__c, 'The given two paramters are not equal');
            system.assertEquals(ORIGINAL_CLIENT_TEST_ID+'~'+NEW_CLIENT_TEST_ID, relationshipsList.get(1).RelationshipIdentifier__c, 'The given two paramters are not equal');
        }

        System.assertEquals(2,relationshipsList.size(), 'Size of \'relationshipsList\' not equals to 2');
        List<Relationship__c> relationshipsListNew=[select AccountTwo__r.clientIdentifier__c,AccountOne__r.clientIdentifier__c,RelationshipType__c,RelationshipIdentifier__c
                                                    from Relationship__c where AccountTwo__C=:acctNew.id OR  AccountOne__C=:acctNew.id];
        if((NEW_CLIENT_TEST_ID+'~'+ORIGINAL_CLIENT_TEST_ID).equals(relationshipsListNew.get(1).RelationshipIdentifier__c)){
            system.assertEquals(NEW_CLIENT_TEST_ID, relationshipsListNew.get(1).AccountTwo__r.clientIdentifier__c, 'The given two paramters are not equal');
            system.assertEquals(ORIGINAL_CLIENT_TEST_ID, relationshipsListNew.get(1).AccountOne__r.clientIdentifier__c, 'The given two paramters are not equal');
            system.assertEquals('Other - Non-Relative', relationshipsListNew.get(1).RelationshipType__c, 'The given two paramters are not equal');
            system.assertEquals(NEW_CLIENT_TEST_ID+'~'+ORIGINAL_CLIENT_TEST_ID, relationshipsListNew.get(1).RelationshipIdentifier__c, 'The given two paramters are not equal');
        }else{
            system.assertEquals(NEW_CLIENT_TEST_ID, relationshipsListNew.get(0).AccountTwo__r.clientIdentifier__c, 'The given two paramters are not equal');
            system.assertEquals(ORIGINAL_CLIENT_TEST_ID, relationshipsListNew.get(0).AccountOne__r.clientIdentifier__c, 'The given two paramters are not equal');
            system.assertEquals('Other - Non-Relative', relationshipsListNew.get(0).RelationshipType__c, 'The given two paramters are not equal');
            system.assertEquals(NEW_CLIENT_TEST_ID+'~'+ORIGINAL_CLIENT_TEST_ID, relationshipsListNew.get(0).RelationshipIdentifier__c, 'The given two paramters are not equal');
        }

        System.assertEquals(2,relationshipsListNew.size(), 'Size of \'relationshipsListNew\' not equals to 2');

        CustomerGroup__c actualGroup =[select id,SFGroupIdentifier__c,Agent__C,GroupCategory__c from CustomerGroup__c where SFGroupIdentifier__c='HouseholdA1'];
        system.assertEquals('HouseholdA1', actualGroup.SFGroupIdentifier__c, 'The given two paramters are not equal');
        system.assertEquals('Primary', actualGroup.GroupCategory__c, 'The given two paramters are not equal');
        system.assertEquals(salesRoleHierarchyOriginal1.Agent.Id, actualGroup.Agent__C, 'The given two paramters are not equal');

        List<CustomerGroupMember__c> actualGroupMemberList=[SELECT Id, Group__c, Customer__c, GroupMemberId__c FROM CustomerGroupMember__c where Customer__c =:acctOri.id OR  Customer__c=:acctNew.id];
        System.assertEquals(3,actualGroupMemberList.size(), 'Size of \'actualGroupMemberList\' not equals to 3');
    }

    @isTest
    static void testSeparateProcessorException() {//testing exception
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='sepProcSysAd@statefarm.com@statefarm.com' ];
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='testAPI@statefarm.com@statefarm.com' ];
        agentUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='agentUser@statefarm.com' ];
        noAccessUser=[SELECT Id  FROM User where lastname='tst111noAccess111111User' ];
        salesRoleHierarchyOriginal1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('A');
        salesRoleHierarchyOriginal2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('B');
        salesRoleHierarchyNew1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('C');
        salesRoleHierarchyOriginal3 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('D');

        System.runAs(testAPIUser){
            test.startTest();
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = getJsonString(ORIGINAL_CLIENT_TEST_ID, NEW_CLIENT_TEST_ID, EXTERNAL_SOURCE_TEST_SYNC_TIME);
            stgorcList.add(testStageOrchestration);
            try {
                PROCESSOR_TEST.execute(stgorcList);
                System.assert(true, 'Mandatory Assert statement on Tests');
            } catch (Exception e) {
                AP_LogHolder logHolder = new AP_LogHolder();
                logHolder.info('UTIL_SeparateProcessor', 'start time of execution: ' + System.now());
                logHolder.writeToLogExceptionObject();
            }
            test.stopTest();
        }
    }


    //This method is used to test agent roles
    @isTest
    static void testAgentRoles(){
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='sepProcSysAd@statefarm.com@statefarm.com' ];
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='testAPI@statefarm.com@statefarm.com' ];
        agentUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='agentUser@statefarm.com' ];
        noAccessUser=[SELECT Id  FROM User where lastname='tst111noAccess111111User' ];
        salesRoleHierarchyOriginal1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('A');
        salesRoleHierarchyOriginal2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('B');
        salesRoleHierarchyNew1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('C');
        salesRoleHierarchyOriginal3 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('D');

        String originalId = 'CCC5S6J0O';
        String newId = 'CCC5S6J0N';

        List<Account> accountList = new List<Account>();
        accountList.add(createAccount(originalId));
        accountList.add(createAccount(newId));
        System.runas(systemUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accountList;
        }
        Account acct1 = [Select id,ExternalSourceSyncTime__c, ClientIdentifier__c from Account where ClientIdentifier__c=:originalId];


        //create Agent Roles for original Account in SFDC
        List<AgentRole__C> originalAccountRoles = createAgentRolesData('1C8UTE3', originalId, acct1);
        AgentRole__C sameOriginalAccountRole = createAgentRole(salesRoleHierarchyOriginal1.Agent.Associate_Id__C+'~'+originalId, acct1.ID);
        originalAccountRoles.add(sameOriginalAccountRole);

        insert originalAccountRoles;

        System.runAs(testAPIUser){
            test.startTest();
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = getJsonString(originalId,newId,EXTERNAL_SOURCE_TEST_SYNC_TIME);
            stgorcList.add(testStageOrchestration);
            PROCESSOR_TEST.execute(stgorcList);
            test.stopTest();
        }

        //verify the agent roles sizes equal b/w json and SFDC
        List<AgentRole__C> sfdcRoles = [SELECT AgentRoleIdentifier__c, Agent__c, Customer__c, RelationshipNature__c FROM AgentRole__c WHERE Customer__c in
                                        (SELECT id from Account where clientidentifier__c=:originalId) order by AgentRoleIdentifier__c];
        List<AgentRole__C> sfdcNewRoles = [SELECT AgentRoleIdentifier__c, Agent__c, Customer__c, RelationshipNature__c FROM AgentRole__c WHERE Customer__c in
                                           (SELECT id from Account where clientidentifier__c=:newId)];

        System.assertEquals(2, sfdcRoles.size(), 'Size of \'sfdcRoles\' not equals to 2');
        System.assertEquals(2, sfdcNewRoles.size(), 'Size of \'sfdcNewRoles\' not equals to 2');
        System.assertEquals(salesRoleHierarchyOriginal1.Agent.Associate_Id__C+'~'+originalId, sfdcRoles[0].AgentRoleIdentifier__c, 'The given two paramters are not equal');
        System.assertEquals(salesRoleHierarchyOriginal2.Agent.Associate_Id__C+'~'+originalId, sfdcRoles[1].AgentRoleIdentifier__c, 'The given two paramters are not equal');
        System.assertEquals(salesRoleHierarchyOriginal1.Agent.Associate_Id__C+'~'+newId, sfdcNewRoles[0].AgentRoleIdentifier__c, 'The given two paramters are not equal');
        System.assertEquals(salesRoleHierarchyNew1.Agent.Associate_Id__C+'~'+newId, sfdcNewRoles[1].AgentRoleIdentifier__c, 'The given two paramters are not equal');
    }

    //This method is used to test agent roles
    @isTest
    static void testAgentRolesWithNoAgentInSFDC(){
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='sepProcSysAd@statefarm.com@statefarm.com' ];
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='testAPI@statefarm.com@statefarm.com' ];
        agentUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='agentUser@statefarm.com' ];
        noAccessUser=[SELECT Id  FROM User where lastname='tst111noAccess111111User' ];
        salesRoleHierarchyOriginal1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('A');
        salesRoleHierarchyOriginal2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('B');
        salesRoleHierarchyNew1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('C');
        salesRoleHierarchyOriginal3 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('D');

        String originalId = 'CCC5S6J0O';
        String newId = 'CCC5S6J0N';

        List<Account> accountList = new List<Account>();
        accountList.add(createAccount(originalId));
        accountList.add(createAccount(newId));
        System.runas(systemUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accountList;
        }
        Account acct1 = [Select id,ExternalSourceSyncTime__c, ClientIdentifier__c from Account where ClientIdentifier__c=:originalId];

        //createAgentUserData();

        //create Agent Roles for original Account in SFDC
        List<AgentRole__C> originalAccountRoles = createAgentRolesData('1C8UTE3', originalId, acct1);
        AgentRole__C sameOriginalAccountRole = createAgentRole(salesRoleHierarchyOriginal1.Agent.Associate_Id__C+'~'+originalId, acct1.ID);
        originalAccountRoles.add(sameOriginalAccountRole);

        insert originalAccountRoles;

        System.runAs(testAPIUser){
            test.startTest();
            try{
                List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
                StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
                testStageOrchestration.Value__c = getJsonStringToGetError(originalId,newId,EXTERNAL_SOURCE_TEST_SYNC_TIME);
                stgorcList.add(testStageOrchestration);
                PROCESSOR_TEST.execute(stgorcList);
                system.assert(false, 'Assertion returns true');
            }catch(StageProcessorException e){
                system.assert(e.getCause() instanceof DataNotFoundException, 'e.getCause() instanceof DataNotFoundException');
                system.assert(e.getMessage().contains(UTIL_StageOrchestrationConstants.INVALID_USER_NOT_FOUND), 'e.getMessage() does not contain the given parameter');
            }
            test.stopTest();
        }
    }

    /* Description : Test Method for Chatter feeds creation for new Account
    * Created By  : Suresh CH
    */
    @isTest
    static void testCreateChatterFeed() {
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='sepProcSysAd@statefarm.com@statefarm.com' ];
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='testAPI@statefarm.com@statefarm.com' ];
        agentUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='agentUser@statefarm.com' ];
        noAccessUser=[SELECT Id  FROM User where lastname='tst111noAccess111111User' ];
        salesRoleHierarchyOriginal1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('A');
        salesRoleHierarchyOriginal2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('B');
        salesRoleHierarchyNew1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('C');
        salesRoleHierarchyOriginal3 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('D');

        List<Account> accountList = new List<Account>();
        List<FeedItem> lOrignalAccFeedItem = New List<FeedItem>();
        accountList.add(createAccount(ORIGINAL_CLIENT_TEST_ID));
        accountList.add(createAccount(NEW_CLIENT_TEST_ID));
        System.runas(systemUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accountList;

            //Insertion on new FeedItems for Original Account
            Account acctOriFeedParent = [SELECT Id FROM Account WHERE ClientIdentifier__c =:ORIGINAL_CLIENT_TEST_ID];
            lOrignalAccFeedItem = createFeedItems(acctOriFeedParent.id);
            Insert lOrignalAccFeedItem;
        }

        Account acct1 = [Select id,ExternalSourceSyncTime__c, ClientIdentifier__c from Account where ClientIdentifier__c=:ORIGINAL_CLIENT_TEST_ID];
        Account acct2 = [Select id,ExternalSourceSyncTime__c, ClientIdentifier__c from Account where ClientIdentifier__c=:NEW_CLIENT_TEST_ID];
        //create Agent Roles for original Account in SFDC
        List<agentRole__C> originalAccountRoles = createAgentRolesData('1C8UTE3', ORIGINAL_CLIENT_TEST_ID, acct1);

        insert originalAccountRoles;

        System.runAs(testAPIUser){//run processor
            test.startTest();
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = getJsonString(ORIGINAL_CLIENT_TEST_ID, NEW_CLIENT_TEST_ID, EXTERNAL_SOURCE_TEST_SYNC_TIME);
            stgorcList.add(testStageOrchestration);
            PROCESSOR_TEST.execute(stgorcList);
            test.stopTest();
        }

        List<AccountFeed> lInsertNewFeed = New List<AccountFeed>([Select ID from AccountFeed where ParentID = :acct2.id]);
        System.assertEquals(lOrignalAccFeedItem.size(), lInsertNewFeed.size(), 'Size of \'lOrignalAccFeedItem\' not equals to the size of \'lInsertNewFeed\'');
    }

    /* Description : Test Method for Task creation for new Account
    * Created By  : Suresh CH
    */
    @isTest
    static void testCreateTask() {
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='sepProcSysAd@statefarm.com@statefarm.com' ];
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='testAPI@statefarm.com@statefarm.com' ];
        agentUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='agentUser@statefarm.com' ];
        noAccessUser=[SELECT Id  FROM User where lastname='tst111noAccess111111User' ];
        salesRoleHierarchyOriginal1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('A');
        salesRoleHierarchyOriginal2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('B');
        salesRoleHierarchyNew1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('C');
        salesRoleHierarchyOriginal3 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('D');

        List<Account> accountList = new List<Account>();
        List<FeedItem> lOrignalAccTaskFeedItem = New List<FeedItem>();
        accountList.add(createAccount(ORIGINAL_CLIENT_TEST_ID));
        accountList.add(createAccount(NEW_CLIENT_TEST_ID));
        List<Task> lnewTask = new List<Task>();
        System.runas(systemUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accountList;

            //Insertion on new FeedItems for Original Account
            Account acctOriFeedParent = [SELECT Id FROM Account WHERE ClientIdentifier__c =:ORIGINAL_CLIENT_TEST_ID];
            lnewTask = createTask(acctOriFeedParent.id);
            Insert lnewTask;
            lOrignalAccTaskFeedItem = createFeedItems(lnewTask[0].id);
            Insert lOrignalAccTaskFeedItem;
        }

        Account acct1 = [Select id,ExternalSourceSyncTime__c, ClientIdentifier__c from Account where ClientIdentifier__c=:ORIGINAL_CLIENT_TEST_ID];
        Account acct2 = [Select id,ExternalSourceSyncTime__c, ClientIdentifier__c from Account where ClientIdentifier__c=:NEW_CLIENT_TEST_ID];
        //create Agent Roles for original Account in SFDC
        List<agentRole__C> originalAccountRoles = createAgentRolesData('1C8UTE3', ORIGINAL_CLIENT_TEST_ID, acct1);

        insert originalAccountRoles;

        System.runAs(testAPIUser){//run processor
            test.startTest();
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = getJsonString(ORIGINAL_CLIENT_TEST_ID, NEW_CLIENT_TEST_ID, EXTERNAL_SOURCE_TEST_SYNC_TIME);
            stgorcList.add(testStageOrchestration);
            PROCESSOR_TEST.execute(stgorcList);
            test.stopTest();
        }

        List<Task> lInsertNewTask = New List<Task>([Select ID from Task where WhatID = :acct2.id]);
        System.assertNotEquals(lInsertNewTask.size(),0, 'Size of \'lInsertNewTask\' should not be equals to 0');
    }

    /* Description : Test Method for Opportunity creation for new Account
    * Created By  : kavitha B
    */
    @isTest
    public static void testGetOpportunityOnOriginalAccount() {
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='sepProcSysAd@statefarm.com@statefarm.com' ];
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='testAPI@statefarm.com@statefarm.com' ];
        agentUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='agentUser@statefarm.com' ];
        noAccessUser=[SELECT Id  FROM User where lastname='tst111noAccess111111User' ];
        salesRoleHierarchyOriginal1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('A');
        salesRoleHierarchyOriginal2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('B');
        salesRoleHierarchyNew1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('C');
        salesRoleHierarchyOriginal3 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('D');

        List<Account> accountList = new List<Account>();
        List<FeedItem> lOrignalOpportunityTaskFeedItem = New List<FeedItem>();
        accountList.add(createAccount(ORIGINAL_CLIENT_TEST_ID));
        accountList.add(createAccount(NEW_CLIENT_TEST_ID));
        List<Opportunity> lNewOpportunity = new List<Opportunity>();
        System.runas(systemUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accountList;

            //Insertion on new FeedItems for Original Account
            Account acctOriFeedParent = [SELECT Id FROM Account WHERE ClientIdentifier__c =:ORIGINAL_CLIENT_TEST_ID];
            lNewOpportunity = createOpportunityWithOwner(acctOriFeedParent.id, salesRoleHierarchyOriginal1.Agent.id);
            Insert lNewOpportunity;
            lOrignalOpportunityTaskFeedItem = createFeedItems(lNewOpportunity[0].id);
            Insert lOrignalOpportunityTaskFeedItem;
        }

        Account acct1 = [Select id,ExternalSourceSyncTime__c, ClientIdentifier__c from Account where ClientIdentifier__c=:ORIGINAL_CLIENT_TEST_ID];
        Account acct2 = [Select id,ExternalSourceSyncTime__c, ClientIdentifier__c from Account where ClientIdentifier__c=:NEW_CLIENT_TEST_ID];
        //create Agent Roles for original Account in SFDC
        List<agentRole__C> originalAccountRoles = createAgentRolesData('1C8UTE3', ORIGINAL_CLIENT_TEST_ID, acct1);

        insert originalAccountRoles;

        System.runAs(testAPIUser){//run processor
            test.startTest();
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = getJsonString(ORIGINAL_CLIENT_TEST_ID, NEW_CLIENT_TEST_ID, EXTERNAL_SOURCE_TEST_SYNC_TIME);
            stgorcList.add(testStageOrchestration);
            PROCESSOR_TEST.execute(stgorcList);
            test.stopTest();
        }

        List<Opportunity> lInsertNewOpportunity = New List<Opportunity>([Select ID from Opportunity where AccountId = :acct2.id]);
        System.assertEquals(lNewOpportunity.size(), lInsertNewOpportunity.size(), 'Size of \'lNewOpportunity\' not equals to size of \'lInsertNewOpportunity\'');
    }

    //Method to test duplcating of cases and their related feeds once account is seoerated
    @isTest
    public static void testCreateCaseOnNewAccount() {
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='sepProcSysAd@statefarm.com@statefarm.com' ];
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='testAPI@statefarm.com@statefarm.com' ];
        agentUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='agentUser@statefarm.com' ];
        noAccessUser=[SELECT Id  FROM User where lastname='tst111noAccess111111User' ];
        salesRoleHierarchyOriginal1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('A');
        salesRoleHierarchyOriginal2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('B');
        salesRoleHierarchyNew1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('C');
        salesRoleHierarchyOriginal3 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('D');

        List<Account> accountList = new List<Account>();
        List<FeedItem> orignalCaseTaskFeedItem = New List<FeedItem>();
        accountList.add(createAccount(ORIGINAL_CLIENT_TEST_ID));
        accountList.add(createAccount(NEW_CLIENT_TEST_ID));
        List<Case> lNewCase = new List<Case>();
        System.runas(systemUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accountList;

            //Insertion on new FeedItems for Original Account
            Account acctOriginal = [SELECT Id FROM Account WHERE ClientIdentifier__c =:ORIGINAL_CLIENT_TEST_ID];
            lNewCase = createCaseWithOwner(acctOriginal.id,salesRoleHierarchyOriginal1.Agent.id);
            Insert lNewCase;
            orignalCaseTaskFeedItem = createFeedItems(lNewCase[0].id);
            Insert orignalCaseTaskFeedItem;
        }

        Account acct1 = [Select id,ExternalSourceSyncTime__c, ClientIdentifier__c from Account where ClientIdentifier__c=:ORIGINAL_CLIENT_TEST_ID];
        Account acct2 = [Select id,ExternalSourceSyncTime__c, ClientIdentifier__c from Account where ClientIdentifier__c=:NEW_CLIENT_TEST_ID];
        //create Agent Roles for original Account in SFDC
        List<agentRole__C> originalAccountRoles = createAgentRolesData('1C8UTE3', ORIGINAL_CLIENT_TEST_ID, acct1);

        insert originalAccountRoles;

        System.runAs(testAPIUser){//run processor
            test.startTest();
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = getJsonString(ORIGINAL_CLIENT_TEST_ID, NEW_CLIENT_TEST_ID, EXTERNAL_SOURCE_TEST_SYNC_TIME);
            stgorcList.add(testStageOrchestration);
            PROCESSOR_TEST.execute(stgorcList);
            test.stopTest();
        }

        List<Case> lInsertNewCase = New List<Case>([Select ID from Case where AccountId = :acct2.id]);
        System.assertEquals(lNewCase.size(), lInsertNewCase.size(), 'Size of \'lNewCase\' not equals to the size of \'lInsertNewCase\'');
    }

    //Test Method Creation of Tasks on cases and duplicate on seperate
    @isTest
    public static void testduplicateTasksOnCases(){
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='sepProcSysAd@statefarm.com@statefarm.com' ];
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='testAPI@statefarm.com@statefarm.com' ];
        agentUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='agentUser@statefarm.com' ];
        noAccessUser=[SELECT Id  FROM User where lastname='tst111noAccess111111User' ];
        salesRoleHierarchyOriginal1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('A');
        salesRoleHierarchyOriginal2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('B');
        salesRoleHierarchyNew1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('C');
        salesRoleHierarchyOriginal3 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('D');

        List<Account> accountList = new List<Account>();
        accountList.add(createAccount(ORIGINAL_CLIENT_TEST_ID));
        accountList.add(createAccount(NEW_CLIENT_TEST_ID));

        List<Case> caseList = new List<Case>();
        System.runas(systemUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accountList;
        }

        Account acct1 = [Select ExternalSourceSyncTime__c, ClientIdentifier__c,Id,Ownerid,PreferredSpokenLanguage__pc,RecordType.Name,PersonEmail,Phone,Gender__pc,MaritalStatus__pc,PersonContactId  from Account where ClientIdentifier__c=:ORIGINAL_CLIENT_TEST_ID];
        Account acct2 = [Select ExternalSourceSyncTime__c, ClientIdentifier__c,Id,Ownerid,PreferredSpokenLanguage__pc,RecordType.Name,PersonEmail,Phone,Gender__pc,MaritalStatus__pc,PersonContactId  from Account where ClientIdentifier__c=:NEW_CLIENT_TEST_ID];
        Set<ID> sAccid = New Set<ID>();
        sAccid.Add(acct1.id);
        sAccid.Add(acct2.id);
        //create Agent Roles for original Account in SFDC
        List<agentRole__C> originalAccountRoles = createAgentRolesData('1C8UTE3', ORIGINAL_CLIENT_TEST_ID, acct1);
        insert originalAccountRoles;
        caseList = createCase(acct1.id);
        Insert caseList;
        Case newCase = new Case (AccountId=acct2.id, Status='New',
                                 Case_Originator__c = 'CCC Sales');
        Insert newCase;

        Map<ID,Case> mnewCase = New Map<Id,Case>();
        mnewCase.put(caseList[0].id,newCase);

        Task newTask = new Task();
        newTask.Subject = 'Call';
        newTask.ActivityDate = System.today()+5;
        newTask.Status = 'Not Started';
        newTask.whatid = caseList[0].id;
        newTask.Ownerid = agentUser.id;
        Insert newTask;
        System.assertNotEquals(newTask, null, 'Task is null');
        Contact oldContact = [Select ID from Contact where Accountid=:acct1.id];
        Contact newContact = [Select ID from Contact where Accountid=:acct2.id];

        TaskRelation taskrelation = new TaskRelation();
        taskrelation.RelationId = oldContact.id;
        taskrelation.TaskId = newTask.id;
        Insert taskrelation;
        System.assertNotEquals(taskrelation, null, 'TaskRelation is null');

        TaskRelation taskrelation1 = new TaskRelation();
        taskrelation1.RelationId = newContact.id;
        taskrelation1.TaskId = newTask.id;
        Insert taskrelation1;
        System.assertNotEquals(taskrelation1, null, 'TaskRelation is null');

        System.runAs(testAPIUser){//run processor
            test.startTest();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = getJsonString(ORIGINAL_CLIENT_TEST_ID, NEW_CLIENT_TEST_ID, EXTERNAL_SOURCE_TEST_SYNC_TIME);
            UTIL_DuplicateTasks.CasesWrapperList caseOpportunitsWrap = new UTIL_DuplicateTasks.CasesWrapperList();
		        caseOpportunitsWrap.originalAccount = acct1;
		        caseOpportunitsWrap.newAccount = acct2;
		        caseOpportunitsWrap.originalCasesList = caseList;
		        caseOpportunitsWrap.addedNewCasesMap = mnewCase;
	        UTIL_DuplicateTasks.duplicateTasksOnCases(caseOpportunitsWrap);
            test.stopTest();
        }

        List<Task> lNewOptyTask = new List<Task>();
        lNewOptyTask =[Select ID from Task where Whatid=:caseList[0].id];
        System.assertNotEquals(lNewOptyTask.size(), 0, 'Size of List<Task> is 0');
    }

    /* Description : Test Method for Testing 'Seprate Task' for Original Account and new Account
    * Created By  : Suresh CH
    */
    @isTest
    public static void testcreateSeprateTaskonAccount(){
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='sepProcSysAd@statefarm.com@statefarm.com' ];
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='testAPI@statefarm.com@statefarm.com' ];
        agentUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='agentUser@statefarm.com' ];
        noAccessUser=[SELECT Id  FROM User where lastname='tst111noAccess111111User' ];
        salesRoleHierarchyOriginal1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('A');
        salesRoleHierarchyOriginal2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('B');
        salesRoleHierarchyNew1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('C');
        salesRoleHierarchyOriginal3 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('D');

        List<Account> accountList = new List<Account>();
        accountList.add(createAccount(ORIGINAL_CLIENT_TEST_ID));
        accountList.add(createAccount(NEW_CLIENT_TEST_ID));

        List<Contact> lnewContact = new List<Contact>();
        System.runas(systemUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accountList;
        }

        Account acct1 = [Select ExternalSourceSyncTime__c, ClientIdentifier__c,Id,Ownerid,PreferredSpokenLanguage__pc,
                         RecordType.Name,PersonEmail,Phone,Gender__pc,MaritalStatus__pc,PersonContactId
                         from Account where ClientIdentifier__c=:ORIGINAL_CLIENT_TEST_ID];
        Account acct2 = [Select ExternalSourceSyncTime__c, ClientIdentifier__c,Id,Ownerid,PreferredSpokenLanguage__pc,
                         RecordType.Name,PersonEmail,Phone,Gender__pc,MaritalStatus__pc,PersonContactId
                         from Account where ClientIdentifier__c=:NEW_CLIENT_TEST_ID];
        Set<ID> sAccid = New Set<ID>();
        sAccid.Add(acct1.id);
        sAccid.Add(acct2.id);
        //create Agent Roles for original Account in SFDC
        List<agentRole__C> originalAccountRoles = createAgentRolesData('1C8UTE3', ORIGINAL_CLIENT_TEST_ID, acct1);
        insert originalAccountRoles;
        Contact oldContact1 =[Select Id from Contact where Accountid=:acct1.id];
        	Task lparentAccTask1 = new Task();
            Task lparentAccTask2 = new Task();
            lparentAccTask1 = createRecurringTask(acct1.id,oldContact1.id);
            Insert lparentAccTask1;
            lparentAccTask2 = createRecurringTask(acct1.id,oldContact1.id);
            Insert lparentAccTask2;
        System.runAs(testAPIUser){//run processor
            test.startTest();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = getJsonString(ORIGINAL_CLIENT_TEST_ID, NEW_CLIENT_TEST_ID, EXTERNAL_SOURCE_TEST_SYNC_TIME);
            PROCESSOR_TEST.createTaskForNotificationOnOrginalAndNewCustomer(acct1,acct2);
            test.stopTest();
        }
        lnewContact =[Select ID from Contact where Accountid IN : sAccid];
        Contact oldContact =[Select Id from Contact where Accountid=:acct1.id];

        List<Task> originalAccTask = New List<Task>();
        List<Task> newAccTask = New List<Task>();
        List<Task> recurringTasksOldAcc = New List<Task>();
        List<Task> recurringTasksNewAcc = New List<Task>();
        originalAccTask = [Select ID from Task where Subject='Customer Separate' And Whoid=:oldContact.id];
        newAccTask = [Select ID from Task where Subject='Customer Separate' And Whoid=:lnewContact[0].id];
        recurringTasksNewAcc = [Select ID,Whoid,isRecurrence,Subject from Task where Subject='CustomerSeparate-RecTask'
                          And WhatId=:acct2.id And isRecurrence = true];
        recurringTasksOldAcc = [Select ID,Whoid,isRecurrence,Subject from Task where Subject='CustomerSeparate-RecTask'
                          And WhatId =:acct1.id And isRecurrence = true];
        System.assertNotEquals(originalAccTask.size(), 0, 'Size of List<Task> is equals to 0');
        System.assertNotEquals(newAccTask.size(), 0, 'Size of List<Task> is equals to 0');
        System.assertEquals(recurringTasksNewAcc.size(), 0, 'Size of List<Task> is not equals to 0');
        System.assertEquals(recurringTasksOldAcc.size(), 2, 'Size of List<Task> is not equals to 2');
    }

    /* Description : Test Method Creation of Tasks on New Opportunity
    * Created By  : Suresh CH
    */
    @isTest
    public static void testduplicateTasksOnOpportunits(){
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='sepProcSysAd@statefarm.com@statefarm.com' ];
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='testAPI@statefarm.com@statefarm.com' ];
        agentUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='agentUser@statefarm.com' ];
        noAccessUser=[SELECT Id  FROM User where lastname='tst111noAccess111111User' ];
        salesRoleHierarchyOriginal1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('A');
        salesRoleHierarchyOriginal2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('B');
        salesRoleHierarchyNew1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('C');
        salesRoleHierarchyOriginal3 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('D');

        List<Account> accountList = new List<Account>();
        accountList.add(createAccount(ORIGINAL_CLIENT_TEST_ID));
        accountList.add(createAccount(NEW_CLIENT_TEST_ID));

        System.runas(systemUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accountList;
        }

        Account acct1 = [Select ExternalSourceSyncTime__c, ClientIdentifier__c,Id,Ownerid,PreferredSpokenLanguage__pc,RecordType.Name,PersonEmail,Phone,Gender__pc,MaritalStatus__pc,PersonContactId  from Account where ClientIdentifier__c=:ORIGINAL_CLIENT_TEST_ID];
        Account acct2 = [Select ExternalSourceSyncTime__c, ClientIdentifier__c,Id,Ownerid,PreferredSpokenLanguage__pc,RecordType.Name,PersonEmail,Phone,Gender__pc,MaritalStatus__pc,PersonContactId  from Account where ClientIdentifier__c=:NEW_CLIENT_TEST_ID];
        Set<ID> sAccid = New Set<ID>();
        sAccid.Add(acct1.id);
        sAccid.Add(acct2.id);
        //create Agent Roles for original Account in SFDC
        List<agentRole__C> originalAccountRoles = createAgentRolesData('1C8UTE3', ORIGINAL_CLIENT_TEST_ID, acct1);
        insert originalAccountRoles;
        Opportunity newOldOpportunity = new Opportunity (Name='testOppty', AccountId=acct1.id, Type='ABC',
                                                         StageName='Needs Analysis', LOB__c='Auto',
                                                         ForecastCategoryName='Pipeline', CloseDate=Date.today());
        Insert newOldOpportunity;
        List<Opportunity> lOldOpty = new List<Opportunity>();
        lOldOpty.Add(newOldOpportunity);

        Opportunity newOpportunity = new Opportunity (Name='testOppty', AccountId=acct2.id, Type='ABC',
                                                      StageName='Needs Analysis', LOB__c='Auto',
                                                      ForecastCategoryName='Pipeline', CloseDate=Date.today());
        Insert newOpportunity;

        Map<ID,Opportunity> mnewOpty = New Map<Id,Opportunity>();
        mnewOpty.put(newOldOpportunity.id,newOpportunity);

        Task newTask = new Task();
        newTask.Subject = 'Call';
        newTask.ActivityDate = System.today()+5;
        newTask.Status = 'Not Started';
        newTask.whatid = newOldOpportunity.id;
        newTask.OwnerId = agentUser.id;
        Insert newTask;
        System.assertNotEquals(newTask, null, 'Task is null');
        Contact oldContact = [Select ID from Contact where Accountid=:acct1.id];

        TaskRelation taskrelation = new TaskRelation();
        taskrelation.RelationId = oldContact.id;
        taskrelation.TaskId = newTask.id;
        Insert taskrelation;
        System.assertNotEquals(taskrelation, null, 'TaskRelation is null');

        System.runAs(testAPIUser){//run processor
            test.startTest();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = getJsonString(ORIGINAL_CLIENT_TEST_ID, NEW_CLIENT_TEST_ID, EXTERNAL_SOURCE_TEST_SYNC_TIME);
            UTIL_DuplicateTasks.DuplicateTasksWrapperList duplicateTaskOpportunitWrap = new UTIL_DuplicateTasks.DuplicateTasksWrapperList();
		        duplicateTaskOpportunitWrap.originalAccount = acct1;
		        duplicateTaskOpportunitWrap.newAccount = acct2;
		        duplicateTaskOpportunitWrap.originalOpportunityList = lOldOpty;
		        duplicateTaskOpportunitWrap.addedNewOpportunitysMap = mnewOpty;
	        UTIL_DuplicateTasks.duplicateTasksOnOpportunits(duplicateTaskOpportunitWrap);
            test.stopTest();
        }

        List<Task> lNewOptyTask = new List<Task>();
        lNewOptyTask =[Select ID from Task where Whatid=:newOldOpportunity.id];
        System.assertNotEquals(lNewOptyTask.size(), 0, 'Size of List<Task> equals to 0');
    }

    @isTest
    public static void testAssignedStaffDelete(){
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='sepProcSysAd@statefarm.com@statefarm.com' ];
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='testAPI@statefarm.com@statefarm.com' ];
        agentUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='agentUser@statefarm.com' ];
        noAccessUser=[SELECT Id  FROM User where lastname='tst111noAccess111111User' ];
        salesRoleHierarchyOriginal1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('A');
        salesRoleHierarchyOriginal2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('B');
        salesRoleHierarchyNew1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('C');
        salesRoleHierarchyOriginal3 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('D');

        Account acc = createAccount(ORIGINAL_CLIENT_TEST_ID);
        System.runas(systemUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert acc;
        }

        List<agentRole__C> originalAccountRoles = createAgentRolesData('1C8UTE3', ORIGINAL_CLIENT_TEST_ID, acc);
        originalAccountRoles.add(new AgentRole__c(customer__c = acc.id, Agent__c = salesRoleHierarchyOriginal3.Agent.Id, AgentRoleIdentifier__c = salesRoleHierarchyOriginal3.Agent.Associate_Id__c + '~' + acc.clientidentifier__c));
        AssignedStaff__c assignStaff = new AssignedStaff__c(Agent__c=salesRoleHierarchyOriginal3.Agent.Id, AssignedStaffIdentifier__c =acc.clientIdentifier__c+'~'+salesRoleHierarchyOriginal3.Agent.Associate_ID__c+'~'+salesRoleHierarchyOriginal3.AgentTeamMember.Associate_Id__c,Customer__c=acc.Id,Staff__c=salesRoleHierarchyOriginal3.AgentTeamMember.Id);
        System.runas(systemUser){
            insert originalAccountRoles;
            insert assignStaff;
        }
        System.runAs(testAPIUser){//run processor
            test.startTest();
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = getJsonString(ORIGINAL_CLIENT_TEST_ID, NEW_CLIENT_TEST_ID, EXTERNAL_SOURCE_TEST_SYNC_TIME);
            stgorcList.add(testStageOrchestration);
            PROCESSOR_TEST.execute(stgorcList);
            test.stopTest();
        }
        List<AssignedStaff__c> assignStaffList = [Select id, name from AssignedStaff__c where id = :assignStaff.Id];
        system.assert(assignStaffList.isEmpty(), 'List<AssignedStaff__c> is not empty');
    }

    @isTest
    public static void testMultiAssignedStaffDelete(){
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='sepProcSysAd@statefarm.com@statefarm.com' ];
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='testAPI@statefarm.com@statefarm.com' ];
        agentUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='agentUser@statefarm.com' ];
        noAccessUser=[SELECT Id  FROM User where lastname='tst111noAccess111111User' ];
        salesRoleHierarchyOriginal1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('A');
        salesRoleHierarchyOriginal2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('B');
        salesRoleHierarchyNew1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('C');
        salesRoleHierarchyOriginal3 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('D');

        Account acc = createAccount(ORIGINAL_CLIENT_TEST_ID);


        User agentTeamMember1 = TestDataFactory_User_Wrapper.generateAgentTeamMemberUser('ATM2', '222222223S');

        System.runas(systemUser){
            agentTeamMember1.UserRoleId = salesRoleHierarchyOriginal3.AgentTeamMember.UserRoleId;
            agentTeamMember1.Servicing_Agent_Associate_ID__c = salesRoleHierarchyOriginal3.Agent.Associate_Id__c;
            agentTeamMember1.Servicing_Agent_Associate_ID_List__c = salesRoleHierarchyOriginal3.Agent.Associate_Id__c;
            insert agentTeamMember1;
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();

            insert acc;
        }

        List<agentRole__C> originalAccountRoles = createAgentRolesData('1C8UTE3', ORIGINAL_CLIENT_TEST_ID, acc);
        originalAccountRoles.add(new AgentRole__c(customer__c = acc.id, Agent__c = salesRoleHierarchyOriginal3.Agent.Id, AgentRoleIdentifier__c = salesRoleHierarchyOriginal3.Agent.Associate_Id__c + '~' + acc.clientidentifier__c));
        originalAccountRoles.add(new AgentRole__c(customer__c = acc.id, Agent__c = salesRoleHierarchyOriginal2.Agent.Id, AgentRoleIdentifier__c = salesRoleHierarchyOriginal2.Agent.Associate_Id__c + '~' + acc.clientidentifier__c));
        List<AssignedStaff__c> assignStaffListToInsert = new List<AssignedStaff__c>();
        assignStaffListToInsert.add(new AssignedStaff__c(Agent__c=salesRoleHierarchyOriginal3.Agent.Id, AssignedStaffIdentifier__c =acc.clientIdentifier__c+'~'+salesRoleHierarchyOriginal3.Agent.Associate_ID__c+'~'+salesRoleHierarchyOriginal3.AgentTeamMember.Associate_Id__c,Customer__c=acc.Id,Staff__c=salesRoleHierarchyOriginal3.AgentTeamMember.Id));
        assignStaffListToInsert.add(new AssignedStaff__c(Agent__c=salesRoleHierarchyOriginal3.Agent.Id, AssignedStaffIdentifier__c =acc.clientIdentifier__c+'~'+salesRoleHierarchyOriginal3.Agent.Associate_ID__c+'~'+agentTeamMember1.Associate_Id__c,Customer__c=acc.Id,Staff__c=agentTeamMember1.Id));
        assignStaffListToInsert.add(new AssignedStaff__c(Agent__c=salesRoleHierarchyOriginal2.Agent.Id, AssignedStaffIdentifier__c =acc.clientIdentifier__c+'~'+salesRoleHierarchyOriginal2.Agent.Associate_ID__c+'~'+salesRoleHierarchyOriginal2.AgentTeamMember.Associate_Id__c,Customer__c=acc.Id,Staff__c=salesRoleHierarchyOriginal2.AgentTeamMember.Id));
        System.runas(systemUser){
            insert originalAccountRoles;
            insert assignStaffListToInsert;
        }
        System.runAs(testAPIUser){//run processor
            test.startTest();
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = getJsonString(ORIGINAL_CLIENT_TEST_ID, NEW_CLIENT_TEST_ID, EXTERNAL_SOURCE_TEST_SYNC_TIME);
            stgorcList.add(testStageOrchestration);
            PROCESSOR_TEST.execute(stgorcList);
            test.stopTest();
        }
        List<AssignedStaff__c> assignStaffList = [Select id,Agent__c, name from AssignedStaff__c];
        system.assert(!assignStaffList.isEmpty(), 'List<AssignedStaff__c> is empty');
        system.assertEquals(1,assignStaffList.size(), 'Size of List<AssignedStaff__c> is not equals to 1');
        system.assertEquals(salesRoleHierarchyOriginal2.Agent.Id, assignStaffList[0].Agent__c, 'The given two paramters are not equal');
    }

    /**
    *   @description <This method is used to validate original account planning conversation log record owner as SYSTEM_USER_REC_OWNER for no Book of Business match>
    */
    @isTest
    private static void testPlanningConversationLogUpdateForSeperateProcessor() {
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='sepProcSysAd@statefarm.com@statefarm.com' ];
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='testAPI@statefarm.com@statefarm.com' ];
        agentUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='agentUser@statefarm.com' ];
        noAccessUser=[SELECT Id  FROM User where lastname='tst111noAccess111111User' ];
        salesRoleHierarchyOriginal1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('A');
        salesRoleHierarchyOriginal2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('B');
        salesRoleHierarchyNew1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('C');
        salesRoleHierarchyOriginal3 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('D');

        Account acc;
        TestData_SalesRoleHierarchy salesRoleHierarchyForPlanConvLog1 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('T');
        PlanningConversationLog__c planConvLog1;
        PlanningConversationLog__c planConvLog2;
        PlanningConversationLog__c planConvLog3;
        PlanningConversationLog__c planConvLog4;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        System.runAs(salesRoleHierarchyOriginal1.agent) {
            acc = createAccount(ORIGINAL_CLIENT_TEST_ID);
            insert acc;

            AgentRole__c agentRole11 = createAgentRole(salesRoleHierarchyOriginal1.Agent.Associate_ID__c + '~' + acc.clientIdentifier__c, acc.id);
            insert agentRole11;
            AgentRole__c agentRole21 = createAgentRole(salesRoleHierarchyOriginal2.Agent.Associate_ID__c + '~' + acc.clientIdentifier__c, acc.id);
            agentRole21.Agent__c = salesRoleHierarchyOriginal2.Agent.id;
            insert agentRole21;
            AgentRole__c agentRole31 = createAgentRole(salesRoleHierarchyNew1.Agent.Associate_ID__c + '~' + acc.clientIdentifier__c, acc.id);
            agentRole31.Agent__c = salesRoleHierarchyNew1.Agent.id;
            insert agentRole31;
            AgentRole__c agentRole41 = createAgentRole(salesRoleHierarchyForPlanConvLog1.Agent.Associate_ID__c + '~' + acc.clientIdentifier__c, acc.id);
            agentRole41.Agent__c = salesRoleHierarchyForPlanConvLog1.Agent.id;
            insert agentRole41;
        }

        System.runAs(systemUser) {
            SimpleConversation__c simpleConv1 = new SimpleConversation__c (SimpleConversationName__c = 'testSimple1', Account__c = acc.id, Agent__c = salesRoleHierarchyOriginal1.agent.id, ownerId = salesRoleHierarchyOriginal1.agentOffice.id, SimpleConversationType__c = 'Simple Conversation', Status__c = 'New');
            insert simpleConv1;
            SimpleConversation__c simpleConv2 = new SimpleConversation__c (SimpleConversationName__c = 'testSimple2', Account__c = acc.id, Agent__c = salesRoleHierarchyOriginal2.agent.id, ownerId = salesRoleHierarchyOriginal2.agentOffice.id, SimpleConversationType__c = 'Simple Conversation', Status__c = 'New');
            insert simpleConv2;
            SimpleConversation__c simpleConv3 = new SimpleConversation__c (SimpleConversationName__c = 'testSimple3', Account__c = acc.id, Agent__c = salesRoleHierarchyNew1.agent.id, ownerId = salesRoleHierarchyNew1.agentOffice.id, SimpleConversationType__c = 'Simple Conversation', Status__c = 'New');
            insert simpleConv3;
            SimpleConversation__c simpleConv4 = new SimpleConversation__c (SimpleConversationName__c = 'testSimple4', Account__c = acc.id, Agent__c = salesRoleHierarchyForPlanConvLog1.agent.id, ownerId = salesRoleHierarchyForPlanConvLog1.agentOffice.id, SimpleConversationType__c = 'Simple Conversation', Status__c = 'New');
            insert simpleConv4;

            planConvLog1 = new PlanningConversationLog__c (Account__c = acc.id, Comments__c = 'Test Comments', Agent__c = salesRoleHierarchyOriginal1.agent.id, SimpleConversation__c = simpleConv1.id, ownerId = salesRoleHierarchyOriginal1.agentOffice.id);
            insert planConvLog1;
            planConvLog2 = new PlanningConversationLog__c (Account__c = acc.id, Comments__c = 'Test Comments', Agent__c = salesRoleHierarchyOriginal2.agent.id, SimpleConversation__c = simpleConv2.id, ownerId = salesRoleHierarchyOriginal2.agentOffice.id);
            insert planConvLog2;
            planConvLog3 = new PlanningConversationLog__c (Account__c = acc.id, Comments__c = 'Test Comments', Agent__c = salesRoleHierarchyNew1.agent.id, SimpleConversation__c = simpleConv3.id, ownerId = salesRoleHierarchyNew1.agentOffice.id);
            insert planConvLog3;
            planConvLog4 = new PlanningConversationLog__c (Account__c = acc.id, Comments__c = 'Test Comments', Agent__c = salesRoleHierarchyForPlanConvLog1.agent.id, SimpleConversation__c = simpleConv4.id, ownerId = salesRoleHierarchyForPlanConvLog1.agentOffice.id);
            insert planConvLog4;
        }

        Test.startTest();
        System.runAs(testAPIUser) {//run processor
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = getJsonString(ORIGINAL_CLIENT_TEST_ID, NEW_CLIENT_TEST_ID, EXTERNAL_SOURCE_TEST_SYNC_TIME);
            stgorcList.add(testStageOrchestration);
            PROCESSOR_TEST.execute(stgorcList);
        }

        List<PlanningConversationLog__c> actualPlanConvList = [Select id, name, ownerId, Account__r.clientIdentifier__c from PlanningConversationLog__c];
        System.assertEquals(actualPlanConvList.size(), 4, 'Size of List<PlanningConversationLog__c> is not equals to 4');
        for(PlanningConversationLog__c planConvLog: actualPlanConvList) {
            if((planConvLog.Id).equals(planConvLog1.id)) {
                system.assertEquals(ORIGINAL_CLIENT_TEST_ID, planConvLog.Account__r.clientIdentifier__c, 'The given two paramters are not equal');
                system.assertEquals(salesRoleHierarchyOriginal1.agentOffice.id, planConvLog.ownerId, 'The given two paramters are not equal');
            } else if((planConvLog.Id).equals(planConvLog2.id)) {
                system.assertEquals(salesRoleHierarchyOriginal2.agentOffice.Id, planConvLog.ownerId, 'The given two paramters are not equal');
                system.assertEquals(ORIGINAL_CLIENT_TEST_ID, planConvLog.Account__r.clientIdentifier__c, 'The given two paramters are not equal');
            } else if((planConvLog.Id).equals(planConvLog3.id)) {
                system.assertEquals(noAccessUser.Id, planConvLog.ownerId, 'The given two paramters are not equal');
                system.assertEquals(ORIGINAL_CLIENT_TEST_ID, planConvLog.Account__r.clientIdentifier__c, 'The given two paramters are not equal');
            } else if((planConvLog.Id).equals(planConvLog4.id)) {
                system.assertEquals(noAccessUser.Id, planConvLog.ownerId, 'The given two paramters are not equal');
                system.assertEquals(ORIGINAL_CLIENT_TEST_ID, planConvLog.Account__r.clientIdentifier__c, 'The given two paramters are not equal');
            }
        }
        Test.stopTest();
    }

    /**
    *   @description <This method is used to validate original account simple conversation record owner as SYSTEM_USER_REC_OWNER for no Book of Business match>
    */
    @isTest
    private static void testSimpleConversationLogUpdateForSeperateProcessor() {
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='sepProcSysAd@statefarm.com@statefarm.com' ];
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='testAPI@statefarm.com@statefarm.com' ];
        agentUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='agentUser@statefarm.com' ];
        noAccessUser=[SELECT Id  FROM User where lastname='tst111noAccess111111User' ];
        salesRoleHierarchyOriginal1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('A');
        salesRoleHierarchyOriginal2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('B');
        salesRoleHierarchyNew1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('C');
        salesRoleHierarchyOriginal3 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('D');

        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        Account acc;
        TestData_SalesRoleHierarchy salesRoleHierarchyForSimpleConvLog1 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('G');
        SimpleConversation__c simpleConv1;
        SimpleConversation__c simpleConv2;
        SimpleConversation__c simpleConv3;
        SimpleConversation__c simpleConv4;

        System.runAs(salesRoleHierarchyOriginal1.agent) {
            acc = createAccount(ORIGINAL_CLIENT_TEST_ID);
            insert acc;

            AgentRole__c agentRole11 = createAgentRole(salesRoleHierarchyOriginal1.Agent.Associate_ID__c + '~' + acc.clientIdentifier__c, acc.id);
            insert agentRole11;
            AgentRole__c agentRole21 = createAgentRole(salesRoleHierarchyOriginal2.Agent.Associate_ID__c + '~' + acc.clientIdentifier__c, acc.id);
            agentRole21.Agent__c = salesRoleHierarchyOriginal2.Agent.id;
            insert agentRole21;
            AgentRole__c agentRole31 = createAgentRole(salesRoleHierarchyNew1.Agent.Associate_ID__c + '~' + acc.clientIdentifier__c, acc.id);
            agentRole31.Agent__c = salesRoleHierarchyNew1.Agent.id;
            insert agentRole31;
            AgentRole__c agentRole41 = createAgentRole(salesRoleHierarchyForSimpleConvLog1.Agent.Associate_ID__c + '~' + acc.clientIdentifier__c, acc.id);
            agentRole41.Agent__c = salesRoleHierarchyForSimpleConvLog1.Agent.id;
            insert agentRole41;
        }

        System.runAs(systemUser) {
            simpleConv1 = new SimpleConversation__c (SimpleConversationName__c = 'testSimple1', Account__c = acc.id, Agent__c = salesRoleHierarchyOriginal1.agent.id, ownerId = salesRoleHierarchyOriginal1.agentOffice.id, SimpleConversationType__c = 'Simple Conversation', Status__c = 'New');
            insert simpleConv1;
            simpleConv2 = new SimpleConversation__c (SimpleConversationName__c = 'testSimple2', Account__c = acc.id, Agent__c = salesRoleHierarchyOriginal2.agent.id, ownerId = salesRoleHierarchyOriginal2.agentOffice.id, SimpleConversationType__c = 'Simple Conversation', Status__c = 'New');
            insert simpleConv2;
            simpleConv3 = new SimpleConversation__c (SimpleConversationName__c = 'testSimple3', Account__c = acc.id, Agent__c = salesRoleHierarchyNew1.agent.id, ownerId = salesRoleHierarchyNew1.agentOffice.id, SimpleConversationType__c = 'Simple Conversation', Status__c = 'New');
            insert simpleConv3;
            simpleConv4 = new SimpleConversation__c (SimpleConversationName__c = 'testSimple4', Account__c = acc.id, Agent__c = salesRoleHierarchyForSimpleConvLog1.agent.id, ownerId = salesRoleHierarchyForSimpleConvLog1.agentOffice.id, SimpleConversationType__c = 'Simple Conversation', Status__c = 'New');
            insert simpleConv4;
        }

        Test.startTest();
        System.runAs(testAPIUser) {//run processor
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = getJsonString(ORIGINAL_CLIENT_TEST_ID, NEW_CLIENT_TEST_ID, EXTERNAL_SOURCE_TEST_SYNC_TIME);
            stgorcList.add(testStageOrchestration);
            new UTIL_SeparateProcessor().execute(stgorcList);
        }

        List<SimpleConversation__c> actualSimpleConvList = [Select id, ownerId, Account__r.clientIdentifier__c from SimpleConversation__c];
        System.assertEquals(actualSimpleConvList.size(), 4, 'Size of List<SimpleConversation__c> is not equals to 4');
        for(SimpleConversation__c simpleConv: actualSimpleConvList) {
            if((simpleConv.Id).equals(simpleConv1.id)) {
                system.assertEquals(ORIGINAL_CLIENT_TEST_ID, simpleConv.Account__r.clientIdentifier__c, 'The given two paramters are not equal');
                system.assertEquals(salesRoleHierarchyOriginal1.agentOffice.id, simpleConv.ownerId, 'The given two paramters are not equal');
            } else if((simpleConv.Id).equals(simpleConv2.id)) {
                system.assertEquals(salesRoleHierarchyOriginal2.agentOffice.Id, simpleConv.ownerId, 'The given two paramters are not equal');
                system.assertEquals(ORIGINAL_CLIENT_TEST_ID, simpleConv.Account__r.clientIdentifier__c, 'The given two paramters are not equal');
            } else if((simpleConv.Id).equals(simpleConv3.id)) {
                system.assertEquals(noAccessUser.Id, simpleConv.ownerId, 'The given two paramters are not equal');
                system.assertEquals(ORIGINAL_CLIENT_TEST_ID, simpleConv.Account__r.clientIdentifier__c, 'The given two paramters are not equal');
            } else if((simpleConv.Id).equals(simpleConv4.id)) {
                system.assertEquals(noAccessUser.Id, simpleConv.ownerId, 'The given two paramters are not equal');
                system.assertEquals(ORIGINAL_CLIENT_TEST_ID, simpleConv.Account__r.clientIdentifier__c, 'The given two paramters are not equal');
            }
        }
        Test.stopTest();
    }

    /**
    *   @description <This method is used to validate original account CampaignMembers for no Book of Business match>
    */
    @isTest
    private static void testCampaignMemberDeleteForSeperateProcessor() {
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='sepProcSysAd@statefarm.com@statefarm.com' ];
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='testAPI@statefarm.com@statefarm.com' ];
        agentUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='agentUser@statefarm.com' ];
        noAccessUser=[SELECT Id  FROM User where lastname='tst111noAccess111111User' ];
        salesRoleHierarchyOriginal1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('A');
        salesRoleHierarchyOriginal2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('B');
        salesRoleHierarchyNew1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('C');
        salesRoleHierarchyOriginal3 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('D');

        Account acc;
        CampaignMember campMemb1;
        Map<String, Schema.Recordtypeinfo> campaignRecordTypeMap = Schema.Sobjecttype.Campaign.getRecordTypeInfosByName();
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        System.runAs(salesRoleHierarchyOriginal1.agent) {
            acc = createAccount(ORIGINAL_CLIENT_TEST_ID);
            insert acc;

            AgentRole__c agentRole11 = createAgentRole(salesRoleHierarchyOriginal1.Agent.Associate_ID__c + '~' + acc.clientIdentifier__c, acc.id);
            insert agentRole11;
            AgentRole__c agentRole21 = createAgentRole(salesRoleHierarchyOriginal2.Agent.Associate_ID__c + '~' + acc.clientIdentifier__c, acc.id);
            agentRole21.Agent__c = salesRoleHierarchyOriginal2.Agent.id;
            insert agentRole21;
            AgentRole__c agentRole31 = createAgentRole(salesRoleHierarchyNew1.Agent.Associate_ID__c + '~' + acc.clientIdentifier__c, acc.id);
            agentRole31.Agent__c = salesRoleHierarchyNew1.Agent.id;
            insert agentRole31;
        }

        System.runAs(systemUser) {
            Account accountClientId = [SELECT PersonContactId FROM Account WHERE Id =: acc.id limit 1];
            Campaign tstCampaign = new Campaign(Name = 'tstCmpMembDisplayRecords', RecordTypeId = campaignRecordTypeMap.get('Customer/Prospect Campaign').RecordTypeId, ownerId = salesRoleHierarchyNew1.agentOffice.id);
            insert tstCampaign;

            campMemb1 = new CampaignMember (campaignId = tstCampaign.id, contactId = accountClientId.PersonContactId);
            insert campMemb1;
        }

        List<CampaignMember> beforeCampaignMemberList = [Select id from CampaignMember];
        System.assertEquals(beforeCampaignMemberList.size(), 1, 'Size of List<CampaignMember> not equals to 1');
        Test.startTest();
        System.runAs(testAPIUser) {//run processor
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = getJsonString(ORIGINAL_CLIENT_TEST_ID, NEW_CLIENT_TEST_ID, EXTERNAL_SOURCE_TEST_SYNC_TIME);
            stgorcList.add(testStageOrchestration);
            PROCESSOR_TEST.execute(stgorcList);
        }
        List<CampaignMember> actualCampaignMemberList = [Select id from CampaignMember];
        System.assert(actualCampaignMemberList.isEmpty(), 'List<CampaignMember> is not empty');
        Test.stopTest();
    }

    @isTest
    public static void testConvertSetOfIDSAsString(){
        String convertedAsString='';
        Set<ID> newset= new Set<ID>();
        newset.add('00TR000000YUIPZ');

        convertedAsString= UTIL_SeparateProcessor.convertSetOfIDSAsString(newset);
        System.assertNotEquals('\'' + '00TR000000YUIPZ' + '\'',convertedAsString, 'The given two paramters should not be equal');
    }

    /**
    *   @description <This method is used to validate original account customer initiated cancallations cloned to new account>
    */
    @isTest
    private static void testCustomerInitiatedCancellationsForSeparateProcessor() {
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='sepProcSysAd@statefarm.com@statefarm.com' ];
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where username='testAPI@statefarm.com@statefarm.com' ];
        agentUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where email='agentUser@statefarm.com' ];
        noAccessUser=[SELECT Id  FROM User where lastname='tst111noAccess111111User' ];
        salesRoleHierarchyOriginal1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('A');
        salesRoleHierarchyOriginal2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('B');
        salesRoleHierarchyNew1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('C');
        salesRoleHierarchyOriginal3 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('D');

        List<Account> accountList = new List<Account>();
        accountList.add(createAccount(ORIGINAL_CLIENT_TEST_ID));
        accountList.add(createAccount(NEW_CLIENT_TEST_ID));

        System.runas(systemUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accountList;
        }

        Account acct1 = [Select ExternalSourceSyncTime__c, ClientIdentifier__c,Id,Ownerid,PreferredSpokenLanguage__pc,RecordType.Name,PersonEmail,Phone,Gender__pc,MaritalStatus__pc,PersonContactId  from Account where ClientIdentifier__c=:ORIGINAL_CLIENT_TEST_ID];

        //create Agent Roles for original Account in SFDC
        List<agentRole__C> originalAccountRoles = createAgentRolesData('1C8UTE3', ORIGINAL_CLIENT_TEST_ID, acct1);
        insert originalAccountRoles;

        List<CustomerInitiatedCancellations__c> cicList = createCustomerInitiatedCancellations(acct1);
        insert cicList;

        System.runAs(testAPIUser){//run processor
            test.startTest();
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = getJsonString(ORIGINAL_CLIENT_TEST_ID, NEW_CLIENT_TEST_ID, EXTERNAL_SOURCE_TEST_SYNC_TIME);
            stgorcList.add(testStageOrchestration);
            PROCESSOR_TEST.execute(stgorcList);
            test.stopTest();
        }

        Account acctOri = [SELECT Id, ExternalSourceSyncTime__c, ClientIdentifier__c, BillingAddress, FirstName, LastName FROM Account
                           WHERE ClientIdentifier__c =:ORIGINAL_CLIENT_TEST_ID];
        Account acctNew = [SELECT Id, ExternalSourceSyncTime__c, ClientIdentifier__c, BillingAddress, FirstName, LastName FROM Account
                           WHERE ClientIdentifier__c =:NEW_CLIENT_TEST_ID];
        List<Account> accountUpdatedList = [Select id from Account where ClientIdentifier__c =: NEW_CLIENT_TEST_ID];
        System.assertEquals(accountUpdatedList.size(), 1, 'Size of List<Account> is not equals to 1');
        System.assertEquals('ALICE', acctOri.FirstName, '\'FirstName\' not equals to \'ALICE\'');
        System.assertEquals('BOBBY', acctNew.FirstName, '\'FirstName\' not equals to \'BOBBY\'');

        List<CustomerInitiatedCancellations__c> actualCICList = [SELECT id, name, ownerId, Customer__r.clientIdentifier__c FROM CustomerInitiatedCancellations__c
                                                                 WHERE AssociatedPolicyNumber__c = '46-12-3123-1'
                                                                 AND Customer__r.ClientIdentifier__c =: NEW_CLIENT_TEST_ID];
        System.assert(actualCICList.size() > 0, 'Size of List<CustomerInitiatedCancellations__c> is not greater than 0');
    }

    /**
    * @description This method is used for to build a test API user with a specific Profile
    * @Method: buildtestUser <This method is used to create test users>
    * @param t_lastName
    * @param testProfile
    * @return User
    */
    public static User buildtestUser(String t_lastName, Profile testProfile) {
        User testUser= new User(alias = 'test', email= 'testuser@statefarm.com', profileid = testProfile.id,
                                emailencodingkey='UTF-8', lastname=t_lastName, languagelocalekey='en_US',
                                localesidkey='en_US', timezonesidkey='Europe/London', username= t_lastName+'@statefarm.com');
        return testUser;
    }

    /**
    * @description This method is used for assign a particular PermissionSet to a particular User
    * @Method: assignPSet <This method is used to get Standard testUser>
    * @param testUser
    */

    private static void assignPermissionSet(User testUser){
        PermissionSet ps = [Select Id, Name FROM PermissionSet WHERE Name=:UTIL_StageOrchestrationConstants.STAGE_ORCHESTRATION_PERMISSION_SET_NAME];
        PermissionSetAssignment assignment = new PermissionSetAssignment(AssigneeId=testUser.Id, PermissionSetId=ps.Id);
        insert assignment;
    }

    /**
     * @description this method is for test build agent user
     * @param agentName
     * @return  `User`
     */
    public static User buildAgentUser(String agentName) {
        User agentUser = new User(alias = 'p_alias', email='test123@statefarm.com',
                                  emailencodingkey='UTF-8', lastname='TestLName', languagelocalekey='en_US',SubUserType__c='Agent',
                                  localesidkey='en_US', timezonesidkey='Europe/London', username= agentName+'@salesforce.com',
                                  Associate_ID__c=agentName, UserExternalID__c= agentName);
        agentUser.ProfileId = UTIL_ProfileId_TEST.getAgentProfileId();

        return agentUser;
    }

    /**
     * @description This method creates the agentRoles
     * @param account
     * @return agentRoleList
     */
    public static List<AgentRole__c> createAgentRoles(List<Account> account){
        List<AgentRole__c> agentRoleList = new List<AgentRole__c>();
        for(Integer i=0; i<=9; i++){
            agentRoleList.add(createAgentRole('1C8UTE3'+i, account[0].Id));
        }

        return agentRoleList;
    }

    /**
    * @description <This method is used to create new account>
    * @param clientIdentifier
    * @return account record
    */
    public static Account createAccount(String clientIdentifier){
        DateTime dt = DateTime.newInstance(2006, 3, 16, 23, 0, 0);
        Account getAccount = new Account(FirstName = 'tst1',LastName='Ltst'+clientIdentifier, ExternalSourceSyncTime__c = dt , ClientIdentifier__c = clientIdentifier);

        return getAccount;
    }

    /**
    *   @description <This method is used to create accounts, original and new>
    *   @param originalClientId
    *   @param newclientId
    *   @return Map of account records
    */
    public static Map<String,Account> createAccounts(String originalClientId, String newclientId){
        Map<String, Account> accountMap = new Map<String, Account> ();
        accountMap.put(originalClientId, createAccount(originalClientId));
        accountMap.put(newclientId, createAccount(newclientId));

        return accountMap;
    }

    /**
    *   @description <This method is used to create ProductsServicedByMe>
    *   @param wrap
    *   @return ProductsServicedByMe
    */
    public static ProductsServicedByMe__c createProductsServicedByMe(UTIL_SeparateProcessor_TestWrapper wrap){
        Id accountId = wrap.accountId;
        String productType = wrap.productType;
        String carrierName = wrap.carrierName;
        String productLine = wrap.productLine;

        ProductsServicedByMe__C productsServicedByMe = new ProductsServicedByMe__C(customer__c=accountId,ProductType__c=productType,
                                                                                   CarrierName__c=carrierName,ProductLine__c=productLine);
        return productsServicedByMe;
    }

    private class UTIL_SeparateProcessor_TestWrapper{
        private Id accountId;
        private String productType;
        private String carrierName;
        private String productLine;
    }
    /**
    *   @description <This method is used to create new agent role>
    *   @param ag_roleValue
    *   @param customerId
    *   @return agent role
    */

    public static AgentRole__c createAgentRole(final String ag_roleValue, final ID customerId){
        AgentRole__c agentRole = new AgentRole__c(RelationshipNature__c = 'Customer',
                                                  AgentRoleIdentifier__c = ag_roleValue,
                                                  Agent__c = agentUser.id,
                                                  Customer__c = customerId);
        return agentRole;

    }

    /**
     * @description this method is used to create agent roles data
     * @param ag_roleValue1
     * @param customerId1
     * @param acct
     * @return  `List<AgentRole__c>`
     */
    public static List<AgentRole__c> createAgentRolesData(final String ag_roleValue1, final String customerId1, final Account acct){
        List<AgentRole__c> agentRoleList = new List<AgentRole__c>();
        for(Integer i=0; i<=5; i++){
            agentRoleList.add(createAgentRole(ag_roleValue1+i, acct.Id));
        }
        return agentRoleList;
    }

    /**
     * @description This method is used to create createC2CRelationships
     * @param customerId
     * @param relationshipWith
     * @param relationNature
     * @return testRelationship
     */
    public static Relationship__c createC2CRelationships(String customerId, String relationshipWith,string relationNature){
        Relationship__c testRelationship = new Relationship__c(AccountTwo__r=new account(ClientIdentifier__C=customerId),
                                                               AccountOne__r=new account(ClientIdentifier__C=relationshipWith),
                                                               RelationshipType__c=relationNature,
                                                               RelationshipIdentifier__c=customerId+'~'+relationshipWith);
        return testRelationship;
    }

    /* Description : Creation of a CustomerInitiatedCancellations associated to Original Account
	*/
    static List<CustomerInitiatedCancellations__c> createCustomerInitiatedCancellations(Account parent){
        List<CustomerInitiatedCancellations__c> cicList = New List<CustomerInitiatedCancellations__c>();

        for(Integer i=0;i<=10;i++){
            CustomerInitiatedCancellations__c cicTemp = new CustomerInitiatedCancellations__c();
            cicTemp.Customer__c = parent.Id;
            cicTemp.AssociatedPolicyNumber__c = '46-12-3123-1';
            cicTemp.CancellationReason__c = 'Mistake';
            cicTemp.DateOfContact__c = Date.today();
            cicTemp.EffectiveDateOfCancellation__c = Date.today();
            cicList.Add(cicTemp);
        }

        return cicList;
    }


    /* Description : Creation of a FeedItem associated to Original Account
    * Created By : Suresh CH
    *
    */
    static List<FeedItem> createFeedItems(ID parentID){
        List<FeedItem> lFeedItem = New List<FeedItem>();

        for(Integer i=0;i<=10;i++){
            FeedItem feedTemp = new Feeditem();
            feedTemp.parentID = parentID;
            feedTemp.Body='sample Post';
            feedTemp.Title ='TestPost';
            lFeedItem.Add(feedTemp);
        }

        return lFeedItem;
    }

    /* Description : Creation of a Task associated to Original Account
	* Created By : Suresh CH
	*/
    static List<Task> createTask(ID parentID){
        List<Task> lNewTask = New List<Task>();

        for(Integer i=0;i<=10;i++){
            Task t = new Task();
            t.Subject = 'test Call';
            t.whatID = parentID;
            t.TaskCategory__c   ='Alert';
            t.Status='Not Started';
            t.ActivityDate = System.today()+30;
            t.Priority='NO';
            t.OwnerId = agentUser.id;
            lNewTask.Add(t);
        }

        return lNewTask;
    }

    /**
    * @description Creation of a Opportunity and associate to Original Account
    * @param parentID
    * @return lNewOpportunity
	* Created By : Kavitha B
	*/
    public static List<Opportunity> createOpportunity(ID parentID){
        List<Opportunity> lNewOpportunity = New List<Opportunity>();

        for(Integer i=0;i<=10;i++){

            Opportunity newOpportunity = new Opportunity (Name='testOppty'+i, AccountId=parentID, Type='ABC', RecordTypeId=optyRecordTypeId,
                                                          StageName='Needs Analysis', LOB__c='Auto',
                                                          ForecastCategoryName='Pipeline', CloseDate=Date.today()+i);
            lNewOpportunity.Add(newOpportunity);
        }

        return lNewOpportunity;
    }

    /**
     * @description test method for create opportunity with owner
     * @param parentID
     * @param agentId
     * @return  `List<Opportunity>`
     */
    public static List<Opportunity> createOpportunityWithOwner(ID parentID, Id agentId){
        List<Opportunity> lNewOpportunity = New List<Opportunity>();

        for(Integer i=0;i<=10;i++){

            Opportunity newOpportunity = new Opportunity (Name='testOppty'+i, AccountId=parentID, Type='ABC', RecordTypeId=optyRecordTypeId,
                                                          StageName='Needs Analysis', LOB__c='Auto', OwnerId = agentId,
                                                          ForecastCategoryName='Pipeline', CloseDate=Date.today()+i);
            lNewOpportunity.Add(newOpportunity);
        }

        return lNewOpportunity;
    }

    /**
     * @description Method to create test case Data
     * @param parentID
     * @return lNewCases
     */
    public static List<Case> createCase(ID parentID){
        List<Case> lNewCases = New List<Case>();
        for(Integer i=0;i<=10;i++){
            Case newCase = new Case (AccountId=parentID, Status='New',
                                     Case_Originator__c = 'CCC Sales');
            lNewCases.Add(newCase);
        }
        return lNewCases;
    }

    /**
     * @description test method for create case with owner
     * @param parentID
     * @param agentId
     * @return  `List<Case>`
     */
    public static List<Case> createCaseWithOwner(ID parentID, Id agentId){
        List<Case> lNewCases = New List<Case>();
        for(Integer i=0;i<=10;i++){
            Case newCase = new Case (AccountId=parentID, Status='New',
                                     Case_Originator__c = 'CCC Sales', OwnerId = agentId);
            lNewCases.Add(newCase);
        }
        return lNewCases;
    }

    /**
     * @description get json string
     * @param originalClientId
     * @param newClientId
     * @param externalSourceSyncTime
     * @return  `String`
     */
    public static String getJsonString(String originalClientId, String newClientId,  String externalSourceSyncTime) {
        return
            '{'+
            '   "orchestrationInfo":{'+
            '      "jsonVersionNumber":"1.0",'+
            '      "orchestrationDataName":['+
            '         {'+
            '            "orchestrationNameDetail":{'+
            '               "dataName":"Account",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"clientId",'+
            '               "externalSourceSyncTime":"'+externalSourceSyncTime+'",'+
            '               "dataExternalKeyValue":"'+originalClientId+'",'+
            '               "orchestrationDataValues":{'+
            '                  "RecordTypeId":"Individual",'+
            '                  "PersonEmailBouncedReason":null,'+
            '                  "Phone":0,'+
            '                  "IsNotShareable":"N",'+
            '                  "PersonMobilePhone":0,'+
            '                  "HasConfirmedNoEmail":false,'+
            '                  "IsSubjecttoCASL":"N",'+
            '                  "ShippingState":"",'+
            '                  "IsPrivacyOptionsShared":"N",'+
            '                  "LastName":"STURZL ",'+
            '                  "PaperlessPrivacyNotice":"N",'+
            '                  "BillingState":"WI",'+
            '                  "EmployerName":"",'+
            '                  "TDDPhone":0,'+
            '                  "BillingPostalCode":"54946",'+
            '                  "OccupationStatus":"",'+
            '                  "Occupation":"",'+
            '                  "ShippingCity":"",'+
            '                  "FirstName":"ALICE ",'+
            '                  "MaritalStatus":"",'+
            '                  "Military":"",'+
            '                  "IsDeathNotificationReceived":"false",'+
            '                  "IsProtectedPerson":"N",'+
            '                  "Citizenship":"",'+
            '                  "BillingCountry":"UNITED STATES ",'+
            '                  "ShippingCountry":"",'+
            '                  "BillingAddressType":"USAddress",'+
            '                  "ShippingStreet":"",'+
            '                  "SSN":" ",'+
            '                  "Suffix":" ",'+
            '                  "BillingStreet":"422 BELL AVE ",'+
            '                  "PersonBirthdate":"1926-09-26",'+
            '                  "DriversLicenseStateProvince":null,'+
            '                  "ShippingAddressType":"",'+
            '                  "DriversLicenseNumber":"",'+
            '                  "MailingInCareOf":"",'+
            '                  "PreferredSpokenLanguage":"",'+
            '                  "PersonHomePhone":7154860544,'+
            '                  "PreferredFirstName":null,'+
            '                  "MiddleName":" ",'+
            '                  "BillingCity":"KING ",'+
            '                  "MailingAttention":" ",'+
            '                  "Gender":"",'+
            '                  "ShippingPostalCode":"",'+
            '                  "PersonEmail":null,'+
            '                  "Designation":" "'+
            '               }'+
            '            }'+
            '         },'+
            '         {'+
            '            "orchestrationNameDetail":{'+
            '               "dataName":"Account",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"clientId",'+
            '               "externalSourceSyncTime":"'+externalSourceSyncTime+'",'+
            '               "dataExternalKeyValue":"'+newClientId+'",'+
            '               "orchestrationDataValues":{'+
            '                  "RecordTypeId":"Individual",'+
            '                  "PersonEmailBouncedReason":"Valid",'+
            '                  "Phone":0,'+
            '                  "IsNotShareable":"N",'+
            '                  "PersonMobilePhone":2259070877,'+
            '                  "HasConfirmedNoEmail":false,'+
            '                  "IsSubjecttoCASL":"N",'+
            '                  "ShippingState":"",'+
            '                  "IsPrivacyOptionsShared":"Y",'+
            '                  "LastName":"BROWN ",'+
            '                  "PaperlessPrivacyNotice":"N",'+
            '                  "BillingState":"LA",'+
            '                  "EmployerName":"",'+
            '                  "TDDPhone":0,'+
            '                  "BillingPostalCode":"70769",'+
            '                  "OccupationStatus":"",'+
            '                  "Occupation":"",'+
            '                  "ShippingCity":"",'+
            '                  "FirstName":"BOBBY ",'+
            '                  "MaritalStatus":"",'+
            '                  "Military":"",'+
            '                  "IsDeathNotificationReceived":"false",'+
            '                  "IsProtectedPerson":"N",'+
            '                  "Citizenship":"",'+
            '                  "BillingCountry":"UNITED STATES ",'+
            '                  "ShippingCountry":"",'+
            '                  "BillingAddressType":"USAddress",'+
            '                  "ShippingStreet":"",'+
            '                  "SSN":"3215 ",'+
            '                  "Suffix":" ",'+
            '                  "BillingStreet":"36339 LORENA DR ",'+
            '                  "PersonBirthdate":"1971-10-14",'+
            '                  "DriversLicenseStateProvince":"LOUISIANA ",'+
            '                  "ShippingAddressType":"",'+
            '                  "DriversLicenseNumber":" ",'+
            '                  "MailingInCareOf":"",'+
            '                  "PreferredSpokenLanguage":"",'+
            '                  "PersonHomePhone":2256738477,'+
            '                  "PreferredFirstName":null,'+
            '                  "MiddleName":" ",'+
            '                  "BillingCity":"PRAIRIEVILLE ",'+
            '                  "MailingAttention":" ",'+
            '                  "Gender":"",'+
            '                  "ShippingPostalCode":"",'+
            '                  "PersonEmail":"AAHMIVVJDNTBOHWBANARNO@sftest.org ",'+
            '                  "Designation":" "'+
            '               }'+
            '            }'+
            '         },'+
            '         {'+
            '            "orchestrationNameDetail":{'+
            '               "dataName":"Agent Role",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"AgentRoleIdentifier",'+
            '               "externalSourceSyncTime":"2016-10-03T09:40:58.045+0000",'+
            '               "dataExternalKeyValue":"'+salesRoleHierarchyOriginal1.Agent.Associate_Id__C+'~'+originalClientId+'",'+
            '               "orchestrationDataValues":{'+
            '                  "Customer":"'+originalClientId+'",'+
            '                  "RelationshipNature":"Ex-Customer",'+
            '                  "StartDate":"2006-08-08",'+
            '                  "Agent":"'+salesRoleHierarchyOriginal1.Agent.Associate_Id__C+'",'+
            '                  "HouseholdGroupId":"HouseholdA1"'+
            '               }'+
            '            }'+
            '         },'+
            '         {'+
            '            "orchestrationNameDetail":{'+
            '               "dataName":"Agent Role",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"AgentRoleIdentifier",'+
            '               "externalSourceSyncTime":"2016-10-03T09:40:58.045+0000",'+
            '               "dataExternalKeyValue":"'+salesRoleHierarchyOriginal1.Agent.Associate_Id__C+'~'+newClientId+'",'+
            '               "orchestrationDataValues":{'+
            '                  "Customer":"'+newClientId+'",'+
            '                  "RelationshipNature":"Ex-Customer",'+
            '                  "StartDate":"2006-08-08",'+
            '                  "Agent":"'+salesRoleHierarchyOriginal1.Agent.Associate_Id__C+'",'+
            '                  "HouseholdGroupId":"HouseholdA2"'+
            '               }'+
            '            }'+
            '         },'+
            '         {'+
            '            "orchestrationNameDetail":{'+
            '               "dataName":"Agent Role",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"AgentRoleIdentifier",'+
            '               "externalSourceSyncTime":"2016-10-03T09:40:58.045+0000",'+
            '               "dataExternalKeyValue":"'+salesRoleHierarchyOriginal2.Agent.Associate_Id__C+'~'+originalClientId+'",'+
            '               "orchestrationDataValues":{'+
            '                  "Customer":"'+originalClientId+'",'+
            '                  "RelationshipNature":"Prospect ",'+
            '                  "StartDate":"2008-08-01",'+
            '                  "Agent":"'+salesRoleHierarchyOriginal2.Agent.Associate_Id__C+'"'+
            '               }'+
            '            }'+
            '         },'+
            '         {'+
            '            "orchestrationNameDetail":{'+
            '               "dataName":"Agent Role",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"AgentRoleIdentifier",'+
            '               "externalSourceSyncTime":"2016-10-03T09:40:58.045+0000",'+
            '               "dataExternalKeyValue":"'+salesRoleHierarchyNew1.Agent.Associate_Id__c+'~'+newClientId+'",'+
            '               "orchestrationDataValues":{'+
            '                  "Customer":"'+newClientId+'",'+
            '                  "RelationshipNature":"Customer ",'+
            '                  "StartDate":"2008-08-01",'+
            '                  "Agent":"'+salesRoleHierarchyNew1.Agent.Associate_Id__c+'"'+
            '               }'+
            '            }'+
            '         },'+
            '         {'+
            '           "orchestrationNameDetail": {'+
            '               "dataName": "Customer2Customer",'+
            '               "dataDeleteIndicator": false,'+
            '               "dataExternalKey": "RelationshipIdentifier",'+
            '               "externalSourceSyncTime": "2017-06-07T19:17:57.182+0000",'+
            '               "dataExternalKeyValue": "'+originalClientId+'~'+newClientId+'",'+
            '               "orchestrationDataValues": {'+
            '                   "Customer": "'+originalClientId+'",'+
            '                   "RelationshipNature": "Other - Non-Relative",'+
            '                   "StartDate": "2012-01-10",'+
            '                   "RelationWith": "'+newClientId+'"'+
            '               }'+
            '           }'+
            '       },'+
            '       {'+
            '           "orchestrationNameDetail": {'+
            '               "dataName": "Customer2Customer",'+
            '               "dataDeleteIndicator": false,'+
            '               "dataExternalKey": "RelationshipIdentifier",'+
            '               "externalSourceSyncTime": "2017-06-07T19:17:57.182+0000",'+
            '               "dataExternalKeyValue": "'+newClientId+'~'+originalClientId+'",'+
            '               "orchestrationDataValues": {'+
            '                   "Customer": "'+newClientId+'",'+
            '                   "RelationshipNature": "Other - Non-Relative",'+
            '                   "StartDate": "2012-01-10",'+
            '                   "RelationWith": "'+originalClientId+'" '+
            '               }'+
            '           }'+
            '       }'+
            '      ],'+
            '      "orchestrationEventName":{'+
            '         "orchestrationEventType":"Separate Customer Record",'+
            '         "orchestrationEventDetail":{'+
            '            "orchestrationEventValues":{'+
            '               "ClientId1" : "'+originalClientId+'", '+
            '               "ClientId2":"'+newClientId+'"'+
            '            }'+
            '         }'+
            '      }'+
            '   }'+
            '}';
    }

    /**
     * @description get json string with same customer grouping
     * @param originalClientId
     * @param newClientId
     * @param externalSourceSyncTime
     * @return  `String`
     */
    public static String getJsonStringWithCSameCustomerGrouping(String originalClientId, String newClientId,  String externalSourceSyncTime) {
        return
            '{'+
            '   "orchestrationInfo":{'+
            '      "jsonVersionNumber":"1.0",'+
            '      "orchestrationDataName":['+
            '         {'+
            '            "orchestrationNameDetail":{'+
            '               "dataName":"Account",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"clientId",'+
            '               "externalSourceSyncTime":"'+externalSourceSyncTime+'",'+
            '               "dataExternalKeyValue":"'+originalClientId+'",'+
            '               "orchestrationDataValues":{'+
            '                  "RecordTypeId":"Individual",'+
            '                  "PersonEmailBouncedReason":null,'+
            '                  "Phone":0,'+
            '                  "IsNotShareable":"N",'+
            '                  "PersonMobilePhone":0,'+
            '                  "HasConfirmedNoEmail":false,'+
            '                  "IsSubjecttoCASL":"N",'+
            '                  "ShippingState":"",'+
            '                  "IsPrivacyOptionsShared":"N",'+
            '                  "LastName":"STURZL ",'+
            '                  "PaperlessPrivacyNotice":"N",'+
            '                  "BillingState":"WI",'+
            '                  "EmployerName":"",'+
            '                  "TDDPhone":0,'+
            '                  "BillingPostalCode":"54946",'+
            '                  "OccupationStatus":"",'+
            '                  "Occupation":"",'+
            '                  "ShippingCity":"",'+
            '                  "FirstName":"ALICE ",'+
            '                  "MaritalStatus":"",'+
            '                  "Military":"",'+
            '                  "IsDeathNotificationReceived":"false",'+
            '                  "IsProtectedPerson":"N",'+
            '                  "Citizenship":"",'+
            '                  "BillingCountry":"UNITED STATES ",'+
            '                  "ShippingCountry":"",'+
            '                  "BillingAddressType":"USAddress",'+
            '                  "ShippingStreet":"",'+
            '                  "SSN":" ",'+
            '                  "Suffix":" ",'+
            '                  "BillingStreet":"422 BELL AVE ",'+
            '                  "PersonBirthdate":"1926-09-26",'+
            '                  "DriversLicenseStateProvince":null,'+
            '                  "ShippingAddressType":"",'+
            '                  "DriversLicenseNumber":"",'+
            '                  "MailingInCareOf":"",'+
            '                  "PreferredSpokenLanguage":"",'+
            '                  "PersonHomePhone":7154860544,'+
            '                  "PreferredFirstName":null,'+
            '                  "MiddleName":" ",'+
            '                  "BillingCity":"KING ",'+
            '                  "MailingAttention":" ",'+
            '                  "Gender":"",'+
            '                  "ShippingPostalCode":"",'+
            '                  "PersonEmail":null,'+
            '                  "Designation":" "'+
            '               }'+
            '            }'+
            '         },'+
            '         {'+
            '            "orchestrationNameDetail":{'+
            '               "dataName":"Account",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"clientId",'+
            '               "externalSourceSyncTime":"'+externalSourceSyncTime+'",'+
            '               "dataExternalKeyValue":"'+newClientId+'",'+
            '               "orchestrationDataValues":{'+
            '                  "RecordTypeId":"Individual",'+
            '                  "PersonEmailBouncedReason":"Valid",'+
            '                  "Phone":0,'+
            '                  "IsNotShareable":"N",'+
            '                  "PersonMobilePhone":2259070877,'+
            '                  "HasConfirmedNoEmail":false,'+
            '                  "IsSubjecttoCASL":"N",'+
            '                  "ShippingState":"",'+
            '                  "IsPrivacyOptionsShared":"Y",'+
            '                  "LastName":"BROWN ",'+
            '                  "PaperlessPrivacyNotice":"N",'+
            '                  "BillingState":"LA",'+
            '                  "EmployerName":"",'+
            '                  "TDDPhone":0,'+
            '                  "BillingPostalCode":"70769",'+
            '                  "OccupationStatus":"",'+
            '                  "Occupation":"",'+
            '                  "ShippingCity":"",'+
            '                  "FirstName":"BOBBY ",'+
            '                  "MaritalStatus":"",'+
            '                  "Military":"",'+
            '                  "IsDeathNotificationReceived":"false",'+
            '                  "IsProtectedPerson":"N",'+
            '                  "Citizenship":"",'+
            '                  "BillingCountry":"UNITED STATES ",'+
            '                  "ShippingCountry":"",'+
            '                  "BillingAddressType":"USAddress",'+
            '                  "ShippingStreet":"",'+
            '                  "SSN":"3215 ",'+
            '                  "Suffix":" ",'+
            '                  "BillingStreet":"36339 LORENA DR ",'+
            '                  "PersonBirthdate":"1971-10-14",'+
            '                  "DriversLicenseStateProvince":"LOUISIANA ",'+
            '                  "ShippingAddressType":"",'+
            '                  "DriversLicenseNumber":" ",'+
            '                  "MailingInCareOf":"",'+
            '                  "PreferredSpokenLanguage":"",'+
            '                  "PersonHomePhone":2256738477,'+
            '                  "PreferredFirstName":null,'+
            '                  "MiddleName":" ",'+
            '                  "BillingCity":"PRAIRIEVILLE ",'+
            '                  "MailingAttention":" ",'+
            '                  "Gender":"",'+
            '                  "ShippingPostalCode":"",'+
            '                  "PersonEmail":"AAHMIVVJDNTBOHWBANARNO@sftest.org ",'+
            '                  "Designation":" "'+
            '               }'+
            '            }'+
            '         },'+
            '         {'+
            '            "orchestrationNameDetail":{'+
            '               "dataName":"Agent Role",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"AgentRoleIdentifier",'+
            '               "externalSourceSyncTime":"2016-10-03T09:40:58.045+0000",'+
            '               "dataExternalKeyValue":"'+salesRoleHierarchyOriginal1.Agent.Associate_Id__C+'~'+originalClientId+'",'+
            '               "orchestrationDataValues":{'+
            '                  "Customer":"'+originalClientId+'",'+
            '                  "RelationshipNature":"Ex-Customer",'+
            '                  "StartDate":"2006-08-08",'+
            '                  "Agent":"'+salesRoleHierarchyOriginal1.Agent.Associate_Id__C+'",'+
            '                  "HouseholdGroupId":"HouseholdA1"'+
            '               }'+
            '            }'+
            '         },'+
            '         {'+
            '            "orchestrationNameDetail":{'+
            '               "dataName":"Agent Role",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"AgentRoleIdentifier",'+
            '               "externalSourceSyncTime":"2016-10-03T09:40:58.045+0000",'+
            '               "dataExternalKeyValue":"'+salesRoleHierarchyOriginal1.Agent.Associate_Id__C+'~'+newClientId+'",'+
            '               "orchestrationDataValues":{'+
            '                  "Customer":"'+newClientId+'",'+
            '                  "RelationshipNature":"Prospect ",'+
            '                  "StartDate":"2008-08-01",'+
            '                  "Agent":"'+salesRoleHierarchyOriginal1.Agent.Associate_Id__C+'",'+
            '                  "HouseholdGroupId":"HouseholdA1"'+
            '               }'+
            '            }'+
            '         },'+
            '         {'+
            '            "orchestrationNameDetail":{'+
            '               "dataName":"Agent Role",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"AgentRoleIdentifier",'+
            '               "externalSourceSyncTime":"2016-10-03T09:40:58.045+0000",'+
            '               "dataExternalKeyValue":"'+salesRoleHierarchyNew1.Agent.Associate_Id__c+'~'+newClientId+'",'+
            '               "orchestrationDataValues":{'+
            '                  "Customer":"'+newClientId+'",'+
            '                  "RelationshipNature":"Customer ",'+
            '                  "StartDate":"2008-08-01",'+
            '                  "Agent":"'+salesRoleHierarchyNew1.Agent.Associate_Id__c+'",'+
            '                  "HouseholdGroupId":"HouseholdA2"'+
            '               }'+
            '            }'+
            '         },'+
            '         {'+
            '           "orchestrationNameDetail": {'+
            '               "dataName": "Customer2Customer",'+
            '               "dataDeleteIndicator": false,'+
            '               "dataExternalKey": "RelationshipIdentifier",'+
            '               "externalSourceSyncTime": "2017-06-07T19:17:57.182+0000",'+
            '               "dataExternalKeyValue": "'+originalClientId+'~'+newClientId+'",'+
            '               "orchestrationDataValues": {'+
            '                   "Customer": "'+originalClientId+'",'+
            '                   "RelationshipNature": "Other - Non-Relative",'+
            '                   "StartDate": "2012-01-10",'+
            '                   "RelationWith": "'+newClientId+'"'+
            '               }'+
            '           }'+
            '       },'+
            '       {'+
            '           "orchestrationNameDetail": {'+
            '               "dataName": "Customer2Customer",'+
            '               "dataDeleteIndicator": false,'+
            '               "dataExternalKey": "RelationshipIdentifier",'+
            '               "externalSourceSyncTime": "2017-06-07T19:17:57.182+0000",'+
            '               "dataExternalKeyValue": "'+newClientId+'~'+originalClientId+'",'+
            '               "orchestrationDataValues": {'+
            '                   "Customer": "'+newClientId+'",'+
            '                   "RelationshipNature": "Other - Non-Relative",'+
            '                   "StartDate": "2012-01-10",'+
            '                   "RelationWith": "'+originalClientId+'" '+
            '               }'+
            '           }'+
            '       }'+
            '      ],'+
            '      "orchestrationEventName":{'+
            '         "orchestrationEventType":"Separate Customer Record",'+
            '         "orchestrationEventDetail":{'+
            '            "orchestrationEventValues":{'+
            '               "ClientId1" : "'+originalClientId+'", '+
            '               "ClientId2":"'+newClientId+'"'+
            '            }'+
            '         }'+
            '      }'+
            '   }'+
            '}';
    }

    /**
     * @description get json string with out customer groupings
     * @param originalClientId
     * @param newClientId
     * @param externalSourceSyncTime
     * @return  `String`
     */
    public static String getJsonStringWithOutCustomerGroupings(String originalClientId, String newClientId,  String externalSourceSyncTime) {
        return
            '{'+
            '   "orchestrationInfo":{'+
            '      "jsonVersionNumber":"1.0",'+
            '      "orchestrationDataName":['+
            '         {'+
            '            "orchestrationNameDetail":{'+
            '               "dataName":"Account",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"clientId",'+
            '               "externalSourceSyncTime":"'+externalSourceSyncTime+'",'+
            '               "dataExternalKeyValue":"'+originalClientId+'",'+
            '               "orchestrationDataValues":{'+
            '                  "RecordTypeId":"Individual",'+
            '                  "PersonEmailBouncedReason":null,'+
            '                  "Phone":0,'+
            '                  "IsNotShareable":"N",'+
            '                  "PersonMobilePhone":0,'+
            '                  "HasConfirmedNoEmail":false,'+
            '                  "IsSubjecttoCASL":"N",'+
            '                  "ShippingState":"",'+
            '                  "IsPrivacyOptionsShared":"N",'+
            '                  "LastName":"STURZL ",'+
            '                  "PaperlessPrivacyNotice":"N",'+
            '                  "BillingState":"WI",'+
            '                  "EmployerName":"",'+
            '                  "TDDPhone":0,'+
            '                  "BillingPostalCode":"54946",'+
            '                  "OccupationStatus":"",'+
            '                  "Occupation":"",'+
            '                  "ShippingCity":"",'+
            '                  "FirstName":"ALICE ",'+
            '                  "MaritalStatus":"",'+
            '                  "Military":"",'+
            '                  "IsDeathNotificationReceived":"false",'+
            '                  "IsProtectedPerson":"N",'+
            '                  "Citizenship":"",'+
            '                  "BillingCountry":"UNITED STATES ",'+
            '                  "ShippingCountry":"",'+
            '                  "BillingAddressType":"USAddress",'+
            '                  "ShippingStreet":"",'+
            '                  "SSN":" ",'+
            '                  "Suffix":" ",'+
            '                  "BillingStreet":"422 BELL AVE ",'+
            '                  "PersonBirthdate":"1926-09-26",'+
            '                  "DriversLicenseStateProvince":null,'+
            '                  "ShippingAddressType":"",'+
            '                  "DriversLicenseNumber":"",'+
            '                  "MailingInCareOf":"",'+
            '                  "PreferredSpokenLanguage":"",'+
            '                  "PersonHomePhone":7154860544,'+
            '                  "PreferredFirstName":null,'+
            '                  "MiddleName":" ",'+
            '                  "BillingCity":"KING ",'+
            '                  "MailingAttention":" ",'+
            '                  "Gender":"",'+
            '                  "ShippingPostalCode":"",'+
            '                  "PersonEmail":null,'+
            '                  "Designation":" "'+
            '               }'+
            '            }'+
            '         },'+
            '         {'+
            '            "orchestrationNameDetail":{'+
            '               "dataName":"Account",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"clientId",'+
            '               "externalSourceSyncTime":"'+externalSourceSyncTime+'",'+
            '               "dataExternalKeyValue":"'+newClientId+'",'+
            '               "orchestrationDataValues":{'+
            '                  "RecordTypeId":"Individual",'+
            '                  "PersonEmailBouncedReason":"Valid",'+
            '                  "Phone":0,'+
            '                  "IsNotShareable":"N",'+
            '                  "PersonMobilePhone":2259070877,'+
            '                  "HasConfirmedNoEmail":false,'+
            '                  "IsSubjecttoCASL":"N",'+
            '                  "ShippingState":"",'+
            '                  "IsPrivacyOptionsShared":"Y",'+
            '                  "LastName":"BROWN ",'+
            '                  "PaperlessPrivacyNotice":"N",'+
            '                  "BillingState":"LA",'+
            '                  "EmployerName":"",'+
            '                  "TDDPhone":0,'+
            '                  "BillingPostalCode":"70769",'+
            '                  "OccupationStatus":"",'+
            '                  "Occupation":"",'+
            '                  "ShippingCity":"",'+
            '                  "FirstName":"BOBBY ",'+
            '                  "MaritalStatus":"",'+
            '                  "Military":"",'+
            '                  "IsDeathNotificationReceived":"false",'+
            '                  "IsProtectedPerson":"N",'+
            '                  "Citizenship":"",'+
            '                  "BillingCountry":"UNITED STATES ",'+
            '                  "ShippingCountry":"",'+
            '                  "BillingAddressType":"USAddress",'+
            '                  "ShippingStreet":"",'+
            '                  "SSN":"3215 ",'+
            '                  "Suffix":" ",'+
            '                  "BillingStreet":"36339 LORENA DR ",'+
            '                  "PersonBirthdate":"1971-10-14",'+
            '                  "DriversLicenseStateProvince":"LOUISIANA ",'+
            '                  "ShippingAddressType":"",'+
            '                  "DriversLicenseNumber":" ",'+
            '                  "MailingInCareOf":"",'+
            '                  "PreferredSpokenLanguage":"",'+
            '                  "PersonHomePhone":2256738477,'+
            '                  "PreferredFirstName":null,'+
            '                  "MiddleName":" ",'+
            '                  "BillingCity":"PRAIRIEVILLE ",'+
            '                  "MailingAttention":" ",'+
            '                  "Gender":"",'+
            '                  "ShippingPostalCode":"",'+
            '                  "PersonEmail":"AAHMIVVJDNTBOHWBANARNO@sftest.org ",'+
            '                  "Designation":" "'+
            '               }'+
            '            }'+
            '         },'+
            '         {'+
            '            "orchestrationNameDetail":{'+
            '               "dataName":"Agent Role",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"AgentRoleIdentifier",'+
            '               "externalSourceSyncTime":"2016-10-03T09:40:58.045+0000",'+
            '               "dataExternalKeyValue":"'+salesRoleHierarchyOriginal1.Agent.Associate_Id__C+'~'+originalClientId+'",'+
            '               "orchestrationDataValues":{'+
            '                  "Customer":"'+originalClientId+'",'+
            '                  "RelationshipNature":"Ex-Customer",'+
            '                  "StartDate":"2006-08-08",'+
            '                  "Agent":"'+salesRoleHierarchyOriginal1.Agent.Associate_Id__C+'"'+
            '               }'+
            '            }'+
            '         },'+
            '         {'+
            '            "orchestrationNameDetail":{'+
            '               "dataName":"Agent Role",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"AgentRoleIdentifier",'+
            '               "externalSourceSyncTime":"2016-10-03T09:40:58.045+0000",'+
            '               "dataExternalKeyValue":"'+salesRoleHierarchyOriginal2.Agent.Associate_Id__C+'~'+originalClientId+'",'+
            '               "orchestrationDataValues":{'+
            '                  "Customer":"'+originalClientId+'",'+
            '                  "RelationshipNature":"Prospect ",'+
            '                  "StartDate":"2008-08-01",'+
            '                  "Agent":"'+salesRoleHierarchyOriginal2.Agent.Associate_Id__C+'"'+
            '               }'+
            '            }'+
            '         },'+
            '         {'+
            '            "orchestrationNameDetail":{'+
            '               "dataName":"Agent Role",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"AgentRoleIdentifier",'+
            '               "externalSourceSyncTime":"2016-10-03T09:40:58.045+0000",'+
            '               "dataExternalKeyValue":"'+salesRoleHierarchyNew1.Agent.Associate_Id__c+'~'+newClientId+'",'+
            '               "orchestrationDataValues":{'+
            '                  "Customer":"'+newClientId+'",'+
            '                  "RelationshipNature":"Customer ",'+
            '                  "StartDate":"2008-08-01",'+
            '                  "Agent":"'+salesRoleHierarchyNew1.Agent.Associate_Id__c+'"'+
            '               }'+
            '            }'+
            '         }'+
            '      ],'+
            '      "orchestrationEventName":{'+
            '         "orchestrationEventType":"Separate Customer Record",'+
            '         "orchestrationEventDetail":{'+
            '            "orchestrationEventValues":{'+
            '               "ClientId1" : "'+originalClientId+'", '+
            '               "ClientId2":"'+newClientId+'"'+
            '            }'+
            '         }'+
            '      }'+
            '   }'+
            '}';
    }

    /**
     * @description get json string to get error
     * @param originalClientId
     * @param newClientId
     * @param externalSourceSyncTime
     * @return  `String`
     */
    public static String getJsonStringToGetError(String originalClientId, String newClientId,  String externalSourceSyncTime) {
        return
            '{'+
            '   "orchestrationInfo":{'+
            '      "jsonVersionNumber":"1.0",'+
            '      "orchestrationDataName":['+
            '         {'+
            '            "orchestrationNameDetail":{'+
            '               "dataName":"Account",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"clientId",'+
            '               "externalSourceSyncTime":"'+externalSourceSyncTime+'",'+
            '               "dataExternalKeyValue":"'+originalClientId+'",'+
            '               "orchestrationDataValues":{'+
            '                  "RecordTypeId":"Individual",'+
            '                  "PersonEmailBouncedReason":null,'+
            '                  "Phone":0,'+
            '                  "IsNotShareable":"N",'+
            '                  "PersonMobilePhone":0,'+
            '                  "HasConfirmedNoEmail":false,'+
            '                  "IsSubjecttoCASL":"N",'+
            '                  "ShippingState":"",'+
            '                  "IsPrivacyOptionsShared":"N",'+
            '                  "LastName":"STURZL ",'+
            '                  "PaperlessPrivacyNotice":"N",'+
            '                  "BillingState":"WI",'+
            '                  "EmployerName":"",'+
            '                  "TDDPhone":0,'+
            '                  "BillingPostalCode":"54946",'+
            '                  "OccupationStatus":"",'+
            '                  "Occupation":"",'+
            '                  "ShippingCity":"",'+
            '                  "FirstName":"ALICE ",'+
            '                  "MaritalStatus":"",'+
            '                  "Military":"",'+
            '                  "IsDeathNotificationReceived":"false",'+
            '                  "IsProtectedPerson":"N",'+
            '                  "Citizenship":"",'+
            '                  "BillingCountry":"UNITED STATES ",'+
            '                  "ShippingCountry":"",'+
            '                  "BillingAddressType":"USAddress",'+
            '                  "ShippingStreet":"",'+
            '                  "SSN":" ",'+
            '                  "Suffix":" ",'+
            '                  "BillingStreet":"422 BELL AVE ",'+
            '                  "PersonBirthdate":"1926-09-26",'+
            '                  "DriversLicenseStateProvince":null,'+
            '                  "ShippingAddressType":"",'+
            '                  "DriversLicenseNumber":"",'+
            '                  "MailingInCareOf":"",'+
            '                  "PreferredSpokenLanguage":"",'+
            '                  "PersonHomePhone":7154860544,'+
            '                  "PreferredFirstName":null,'+
            '                  "MiddleName":" ",'+
            '                  "BillingCity":"KING ",'+
            '                  "MailingAttention":" ",'+
            '                  "Gender":"",'+
            '                  "ShippingPostalCode":"",'+
            '                  "PersonEmail":null,'+
            '                  "Designation":" "'+
            '               }'+
            '            }'+
            '         },'+
            '         {'+
            '            "orchestrationNameDetail":{'+
            '               "dataName":"Account",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"clientId",'+
            '               "externalSourceSyncTime":"'+externalSourceSyncTime+'",'+
            '               "dataExternalKeyValue":"'+newClientId+'",'+
            '               "orchestrationDataValues":{'+
            '                  "RecordTypeId":"Individual",'+
            '                  "PersonEmailBouncedReason":"Valid",'+
            '                  "Phone":0,'+
            '                  "IsNotShareable":"N",'+
            '                  "PersonMobilePhone":2259070877,'+
            '                  "HasConfirmedNoEmail":false,'+
            '                  "IsSubjecttoCASL":"N",'+
            '                  "ShippingState":"",'+
            '                  "IsPrivacyOptionsShared":"Y",'+
            '                  "LastName":"BROWN ",'+
            '                  "PaperlessPrivacyNotice":"N",'+
            '                  "BillingState":"LA",'+
            '                  "EmployerName":"",'+
            '                  "TDDPhone":0,'+
            '                  "BillingPostalCode":"70769",'+
            '                  "OccupationStatus":"",'+
            '                  "Occupation":"",'+
            '                  "ShippingCity":"",'+
            '                  "FirstName":"BOBBY ",'+
            '                  "MaritalStatus":"",'+
            '                  "Military":"",'+
            '                  "IsDeathNotificationReceived":"false",'+
            '                  "IsProtectedPerson":"N",'+
            '                  "Citizenship":"",'+
            '                  "BillingCountry":"UNITED STATES ",'+
            '                  "ShippingCountry":"",'+
            '                  "BillingAddressType":"USAddress",'+
            '                  "ShippingStreet":"",'+
            '                  "SSN":"3215 ",'+
            '                  "Suffix":" ",'+
            '                  "BillingStreet":"36339 LORENA DR ",'+
            '                  "PersonBirthdate":"1971-10-14",'+
            '                  "DriversLicenseStateProvince":"LOUISIANA ",'+
            '                  "ShippingAddressType":"",'+
            '                  "DriversLicenseNumber":" ",'+
            '                  "MailingInCareOf":"",'+
            '                  "PreferredSpokenLanguage":"",'+
            '                  "PersonHomePhone":2256738477,'+
            '                  "PreferredFirstName":null,'+
            '                  "MiddleName":" ",'+
            '                  "BillingCity":"PRAIRIEVILLE ",'+
            '                  "MailingAttention":" ",'+
            '                  "Gender":"",'+
            '                  "ShippingPostalCode":"",'+
            '                  "PersonEmail":"AAHMIVVJDNTBOHWBANARNO@sftest.org ",'+
            '                  "Designation":" "'+
            '               }'+
            '            }'+
            '         },'+
            '         {'+
            '            "orchestrationNameDetail":{'+
            '               "dataName":"Agent Role",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"AgentRoleIdentifier",'+
            '               "externalSourceSyncTime":"2016-10-03T09:40:58.045+0000",'+
            '               "dataExternalKeyValue":"40NCX4Z3MA2~'+newClientId+'",'+
            '               "orchestrationDataValues":{'+
            '                  "Customer":"'+newClientId+'",'+
            '                  "RelationshipNature":"Customer ",'+
            '                  "StartDate":"2008-08-01",'+
            '                  "Agent":"40NCX4Z3MA2"'+
            '               }'+
            '            }'+
            '         }'+
            '      ],'+
            '      "orchestrationEventName":{'+
            '         "orchestrationEventType":"Separate Customer Record",'+
            '         "orchestrationEventDetail":{'+
            '            "orchestrationEventValues":{'+
            '               "ClientId1" : "'+originalClientId+'", '+
            '               "ClientId2":"'+newClientId+'"'+
            '            }'+
            '         }'+
            '      }'+
            '   }'+
            '}';
    }
    /* Description : Creation of a Recurring Task associated to Original Account
    * Created By : Rashmi
    */
    static Task createRecurringTask(ID parentID, Id oldContact){
        Task t = new Task();
            t.Subject = 'CustomerSeparate-RecTask';
        	t.WhoId = oldContact;
            t.whatID = parentID;
            t.TaskCategory__c   ='Alert';
            t.Status='Not Started';
            t.RecurrenceStartDateOnly = System.today()+15;
            t.RecurrenceType = 'RecursEveryWeekday';
            t.RecurrenceTimeZoneSidKey = 'America/Chicago';
            t.RecurrenceDayOfWeekMask = 62;
            t.RecurrenceEndDateOnly = System.today()+30;
            //t.ActivityDate = System.today()+30;
            t.Priority='NO';
            t.OwnerId = agentUser.id;
            t.IsRecurrence = true;
        	return t;
    }
}