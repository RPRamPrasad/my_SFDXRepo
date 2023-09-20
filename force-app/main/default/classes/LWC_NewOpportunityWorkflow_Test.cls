/**
* Author : Team AKITA
* Date Created : 09/15/2019
* @description  Test class for lWC_NewOpportunityWorkflow - Apex Class.
* @Version 1.0
* Copyright © StateFarm
Version     Author        Date           Description
1.1          Akita        01-08-2020     Refactored the test class
1.2          Akita        09-1-2020      Updated the test class with respect to the new changes made
1.3          Akita        10-9-2020      Updated few test methods external Id format
1.4          Opptimizers  4/10/2022      Updated test class PS-MOD Effort
*/

@isTest(SeeAllData=false)
public with sharing class LWC_NewOpportunityWorkflow_Test {

    private static DAOMock_AccountCreateEditHelper daoMockHelperInstance = new DAOMock_AccountCreateEditHelper();
    private static final String OPPORTUNITY_ORIGINATOR_DEFAULT = 'Agent/Team member';
    private static Id campaignId = null;

    //CCC
    private static final String DEFAULT_OPPORTUNITY_RECORD_TYPE_NAME = 'Opportunity Management';
    private static final String OPPORTUNITY_ORIGINATOR = 'Customer Care Center';
    private static final String OPPORTUNITY_QUOTE_ING = 'Quoting';
    private static final String TILDE = '~';
    private static final String HYPEN = '-';
    private static final String SECONDS_FORMAT= 'ssSSS';
    private static final String SYSTEM_DEFAULT_ACCOUNT_OWNER = 'State Farm';

    public static User agentUser;
    public static User adminUser;
    public static User cccLicensedUser;
    public static User proxyUser;
    public static Account acc;

    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap = Schema.Sobjecttype.Account.getRecordTypeInfosByName();
    private static Map<String, Schema.Recordtypeinfo> opportunityRecordTypeMap = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName();

    //method to bypass Trigger
    private static void byPassTrigger() {
        CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c();
        objectBasedByPassTrigger.Override_All__c = true;
        insert objectBasedByPassTrigger;
    }

    //method to build userrole with the given parameter value
    private static UserRole buildUserRole(String roleName) {
        UserRole role = new UserRole(name = roleName);
        return role;
    }

    //method to build userrole with parentRole with the given parameter value
    private static UserRole buildUserRoleWithParent(String roleName, String parentRole) {
        UserRole role = new UserRole(name = roleName, parentRoleId = parentRole);
        return role;
    }

    //method to build Agent Role record with the given parameter value
    private static AgentRole__c buildAgentRoleRecord(String paramAccountId, String paramAgentuser) {
        AgentRole__c agentRole = new AgentRole__c (RelationshipNature__c = 'Customer',
                                                   Agent__c = paramAgentuser, Customer__c = paramAccountId);
        return agentRole;
    }

    //method to build Account Owner custom setting record with the given parameter value
    private static AccountOwnerSystemUserCustomSetting__c buildCustomSettingRecord(String userId) {
        AccountOwnerSystemUserCustomSetting__c actOwnerCs = new AccountOwnerSystemUserCustomSetting__c(Name = SYSTEM_DEFAULT_ACCOUNT_OWNER, SFDC_USER_ID__c = userId);
        return actOwnerCs;
    }

    //method to build Agent Context Record with the given parameter value
    private static AgentContext__c buildAgentContextRecord(String paramAccountId, String paramAgntContxtIdentifier, String paramAgntUser) {
        AgentContext__c agentContext = new AgentContext__c(Agent__c = paramAgntUser, AgentContextIdentifier__c = paramAgntContxtIdentifier,
                                                           CCCRepresentative__c = userInfo.getUserId(), Customer__c = paramAccountId);
        return agentContext;
    }

     //method to build Account record with Client First Name, Last Name, and Client Id
    private static Account buildAccountRecord(String fstLstName, String clientId, Id owner) {
        String[] splitFSTLSTName = fstLstName.split(' ');
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        Account act = new Account(FirstName = splitFSTLSTName[0] , LastName = splitFSTLSTName[1], ownerId = owner,
                                  RecordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId, ClientIdentifier__c = clientId);
        return act;
    }

    //method to build Agent Role record with Customer Account Id
    private static AgentRole__c buildAgentRoleRecord(String accountId) {
        AgentRole__c agentRole = new AgentRole__c (RelationshipNature__c = 'Customer',
                                                   Agent__c = userInfo.getUserId(), Customer__c = accountId);

        return agentRole;
    }

    // End----
/**
 * @description setUp
 */
    @testSetup
    public static void setUp() {

        User adminUser = UTIL_UserProvisioning_TEST.buildUserWithSystemAdminProfile('TestAdminUser@statefarm.com.bad');
        insert adminuser;
        User agentUser;
        User proxyUser;
        User cccLicensedUser;

        System.runAs(adminUser) {
            byPassTrigger();

            UserRole agentUserRole = buildUserRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildUserRoleWithParent('ProxyRole', agentUserRole.id);
            insert proxyUserRole;
            User testAgentUser = new User(Alias='X7PZ',LastName='agent,user,75-338-Office',Username='TestAgentUser@statefarm.com.bad',Associate_ID__c='ASSOCID0001',UserExternalID__c='ASSOCID0001_ASSOCID0001',Servicing_Agent_Associate_ID__c='ASSOCID0001',Territory_Associate_ID__c='',Servicing_Agent_Associate_ID_List__c='',Territory_Associate_ID_List__c='');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser (testAgentUser);
            agentUser.userRoleId = agentUserRole.id;
            agentUser.State_Agent_Code__c = '17-3338';
            agentUser.State_Agent_Code_List__c = '17-3338';
            insert agentUser;
            User testProxyUser = new User(Alias='X7PX',FirstName='middle,Last,75-338-Office',LastName='TestProxyUser@statefarm.com.bad',Associate_ID__c='',UserExternalID__c='ASSOCID0001',Territory_Associate_ID__c='');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser(testProxyUser);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;
            User testCCCLicenUser1 = new User(Alias='X7PT',LastName='CCC,user,75-338-Office',Username='TestCCCUser@statefarm.com.bad',Associate_ID__c='ppcczz33ttc',UserExternalID__c='');
            cccLicensedUser = UTIL_UserProvisioning_TEST.buildCCCLicensedUser(testCCCLicenUser1);
            insert cccLicensedUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser,cccLicensedUser});


        }

        acc = LWC_NewOpportunityWorkflow_Test.buildAccountRecord('FST LST','111',agentUser.Id);
        insert acc;

        //Insert agent role to give account access to the Agent
        AgentRole__c agentRole;
        System.runAs(agentUser) {
            agentRole = buildAgentRoleRecord(acc.Id);
        }
        insert agentRole;

    }

    /**
     * @description queryTestData
     */
    //Query the test data
    public static void queryTestData() {
        agentUser = [Select Id,Associate_ID__c from User where username = 'TestAgentUser@statefarm.com.bad'];
        adminUser = [Select Id,Associate_ID__c from User where username = 'TestAdminUser@statefarm.com.bad'];
        cccLicensedUser = [Select Id,Associate_ID__c from User where username = 'TestCCCUser@statefarm.com.bad'];
        acc = [Select Id,ClientIdentifier__c, Name from Account where lastname = 'LST'];
    }


    //test method to insert opportunity from Agent Workflow - Single LOB
    @isTest
    private static void testInsertOpportunityFromAgentWorkflowSingleLOB() {
        queryTestData();
        Map<String, Object> expectedResults = new Map<String, Object>{
            'Lob__c' => 'Auto',
            'Opportunity_Originator__c' => 'Agent/Team Member',
            'AccountId' => acc.Id,
            'Marketing_Source__c' => '1-800-State-Farm',
            'StageName'=>'New'
        };
        AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(agentUser.Id, 'Opportunity_PartialAccess');
        System.runAs(agentUser) {
            Test.startTest();
            LWC_NewOpportunityworkflow.SaveData data = new LWC_NewOpportunityworkflow.SaveData();
           data.lobSelection = new  List<LWC_NewOpportunityworkflow.ProductLineItem>{createProduct('Private Passenger-System1',Date.Today(),'Auto')};
                data.accId = acc.id;
            data.sourceComments = 'Test';
                data.marketSource = '1-800-State-Farm';
                data.saveNquote = 'Save';
                data.marketSourceSub = '';
                data.oppOrg = 'Agent/Team Member';
                data.selectedAgentContext = '';
                data.isguided =false;
                data.campaignId = campaignId;
                data.effectiveDate = date.today();
            ApexResponse response = (ApexResponse)JSON.deserialize(
                LWC_NewOpportunityWorkflow.saveOpp(JSON.serialize(data)),ApexResponse.class);

            Test.stopTest();
            system.assert(response.status == 'Success','Assertion Failed Error');
            system.assert(response.result != null,'The value is null');
            List<Opportunity> result = (List<Opportunity>)response.result;
            system.assertEquals(result.size(),1,'Invalid Opp Length');
            for(String prop : expectedResults.keySet()) {
                System.assertEquals(expectedResults.get(prop), result[0].get(prop),'testInsertOpportunityFromAgentWorkflowSingleLOB failed');
            }
        }
    }

    //test method to insert opportunity from Agent Workflow - Multiple LOB
    @isTest
    private static void testInsertOpportunityFromAgentWorkflowMultipleLOB() {
        queryTestData();
        Map<Integer, Map<String,Object>> expectedResults = new Map<Integer, Map<String,Object>>{
                0 => new Map<String,Object> {
                    'Lob__c' => 'Auto',
                    'Opportunity_Originator__c' => 'Agent/Team Member',
                    'AccountId' => acc.Id,
                    'Marketing_Source__c' => '1-800-State-Farm',
                    'StageName'=>'Quoting',
                    'status__c'=>'Quote In Progress'
                },
                1 => new Map<String, Object> {
                    'Lob__c' => 'Life',
                    'StageName'=>'New'
                },
                2 => new Map<String, Object> {
                    'Lob__c' => 'Health',
                    'StageName'=>'New'
                }

        };
        AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(agentUser.Id, 'Opportunity_PartialAccess');
        System.runAs(agentUser) {
            Test.startTest();
            LWC_NewOpportunityworkflow.SaveData data = new LWC_NewOpportunityworkflow.SaveData();

                        data.lobSelection = new List<LWC_NewOpportunityWorkflow.ProductLineItem> {
                            createProduct('Private Passenger-System1',Date.Today(),'Auto'),
                                createProduct('Hospital Income-System2',Date.Today(),'Health'),
                                createProduct('Life Insurance-System3',Date.Today(),'Life')};

                data.accId = acc.id;
            data.sourceComments = 'Test';
                data.marketSource = '1-800-State-Farm';
                data.saveNquote = 'saveNquote';
                data.marketSourceSub = '';
                data.oppOrg = 'Agent/Team Member';
                data.selectedAgentContext = '';
                data.isguided =false;
                data.campaignId = campaignId;
                data.effectiveDate = date.today();
            ApexResponse response = (ApexResponse)JSON.deserialize(LWC_NewOpportunityWorkflow.saveOpp(JSON.serialize(data)),ApexResponse.class);
            Test.stopTest();

            system.assert(response.status == 'Success','Assertion Failed Error');
            system.assert(response.result != null,'The value is Null');
            List<Opportunity> result = (List<Opportunity>)response.result;
            system.assertEquals(response.result.size(),3,'Invalid Opp Length');
            for(Integer index : expectedResults.keySet()) {
                for(String prop : expectedResults.get(index).keySet()) {
                    System.assertEquals(expectedResults.get(index).get(prop), result.get(index).get(prop),'testInsertOpportunityFromAgentWorkflowMultipleLOB Failed');
                }
            }
        }
    }

    //test method to insert opportunity from CCC Workflow - Single LOB
    @isTest
    private static void testInsertOpportunityFromCCCWorkflowSingleLOB() {
        queryTestData();
        daoMockHelperInstance.acct = acc;
        Map<String, Object> expectedResults = new Map<String, Object>{
            'Lob__c' => 'Auto',
            'Assigned_To__c' => null
        };
        AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(cccLicensedUser.Id, 'Opportunity_PartialAccess');
        System.runAs(cccLicensedUser) {
            Test.startTest();
            LWC_NewOpportunityworkflow.SaveData data = new LWC_NewOpportunityworkflow.SaveData();
              data.lobSelection = new List<LWC_NewOpportunityWorkflow.ProductLineItem> {
                  createProduct('Private Passenger-System1',Date.Today(),'Auto')};
                data.accId = acc.id;
            data.sourceComments = 'Test';
                data.marketSource = '1-800-State-Farm';
                data.saveNquote = 'saveNquote';
                data.marketSourceSub = 'Agent';
                data.oppOrg = 'Customer Care Center';
                data.selectedAgentContext = 'ASSOCID0001-X7PZ';
                data.isguided =true;
                data.campaignId = campaignId;
                data.effectiveDate = date.today();
            daoMockHelperInstance.acct = daoMockHelperInstance.getAccountDetails(acc.Id);
            UTIL_AccountCreateEditHelper.mockAccount = new Account(Id=acc.Id);
           ApexResponse response = (ApexResponse)JSON.deserialize(LWC_NewOpportunityWorkflow.saveOpp(JSON.serialize(data)),ApexResponse.class);
            Test.stopTest();

            system.assert(response.status == 'Success','Assertion Failed Error');
            system.assert(response.result != null,'The value is null');
            List<Opportunity> result = (List<Opportunity>)response.result;
            system.assertEquals(result.size(),1,'Invalid Opp Length');
        }
    }

    //test method to insert opportunity from CCC Workflow - Multiple LOB
    @isTest
    private static void testInsertOpportunityFromCCCWorkflowMultipleLOB() {
        queryTestData();
        daoMockHelperInstance.acct = acc;
        AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(cccLicensedUser.Id, 'Opportunity_PartialAccess');
        System.runAs(cccLicensedUser) {
            Test.startTest();
            LWC_NewOpportunityworkflow.SaveData data = new LWC_NewOpportunityworkflow.SaveData();
            data.lobSelection = new List<LWC_NewOpportunityWorkflow.ProductLineItem> {
                            createProduct('Private Passenger-System1',Date.Today(),'Auto'),
                                createProduct('Renters-System2',Date.Today(),'Fire'),
                                createProduct('Life Insurance-System3',Date.Today(),'Life')};

                data.accId = acc.id;
            data.sourceComments = 'Test';
                data.marketSource = 'Internet';
                data.saveNquote = 'saveNquote';
                data.marketSourceSub = 'Micro Site';
                data.oppOrg = 'Customer Care Center';
                data.selectedAgentContext = 'ASSOCID0001-X7PZ';
                data.isguided =true;
                data.campaignId = campaignId;
                data.effectiveDate = date.today();
            daoMockHelperInstance.acct = daoMockHelperInstance.getAccountDetails(acc.Id);
            UTIL_AccountCreateEditHelper.mockAccount = new Account(Id=acc.Id);
           ApexResponse response = (ApexResponse)JSON.deserialize(LWC_NewOpportunityWorkflow.saveOpp(JSON.serialize(data)),ApexResponse.class);

            Test.stopTest();
            system.assert(response.status == 'Success','Assertion Failed Error');
            system.assert(response.result != null,'The value is null');
            List<Opportunity> result = (List<Opportunity>)response.result;
            system.assertEquals(result.size(),3,'Invalid Opp Length');
            system.assertEquals(result[0].Lob__c,'Auto','Received Wrong LOB');
            system.assertEquals(result[0].Opportunity_Originator__c,'Customer Care Center','Received Agent Originator');
        }
    }

    //Negative testing with blank LOB
    @isTest
    private static void createOpportunitywithBlankLOB() {
        queryTestData();
        AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(agentUser.Id, 'Opportunity_PartialAccess');
         System.runAs(agentUser) {
            Test.startTest();
             LWC_NewOpportunityworkflow.SaveData data = new LWC_NewOpportunityworkflow.SaveData();
           data.lobSelection = new List<LWC_NewOpportunityWorkflow.ProductLineItem>();

                data.accId = acc.id;
            data.sourceComments = 'Test';
                data.marketSource = '1-800-State-Farm';
                data.saveNquote = 'Save';
                data.marketSourceSub = '';
                data.oppOrg = 'Agent/Team Member';
                data.selectedAgentContext = '';
                data.isguided =false;
                data.campaignId = campaignId;
                data.effectiveDate = date.today();
           ApexResponse response = (ApexResponse)JSON.deserialize(LWC_NewOpportunityWorkflow.saveOpp(JSON.serialize(data)),ApexResponse.class);
            Test.stopTest();
            system.assert(response.status == 'Error','Assertion Failed Error');
            system.assert(response.result == null,'The value is null');
            List<Opportunity> result = (List<Opportunity>)response.result;
            system.assertEquals(result,null,'Invalid Opp Length');
        }
    }

    //Negative testing with blank LOB
    @isTest
    private static void saveOpportunitywithBlankAssociateId() {
        queryTestData();
        agentUser.Associate_ID__c = '';
        update agentUser;
        AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(agentUser.Id, 'Opportunity_PartialAccess');
        System.runAs(agentUser) {
            Test.startTest();
            LWC_NewOpportunityworkflow.SaveData data = new LWC_NewOpportunityworkflow.SaveData();
             data.lobSelection = new List<LWC_NewOpportunityWorkflow.ProductLineItem> {
                            createProduct('Private Passenger-System1',Date.Today(),'Auto'),
                                createProduct('Hospital Income-System2',Date.Today(),'Health'),
                                createProduct('Life Insurance-System3',Date.Today(),'Life')};
                data.accId = acc.id;
            data.sourceComments = 'Test';
                data.marketSource = '1-800-State-Farm';
                data.saveNquote = 'saveNquote';
                data.marketSourceSub = '';
                data.oppOrg = 'Agent/Team Member';
                data.selectedAgentContext = '';
                data.isguided =false;
                data.campaignId = campaignId;
                data.effectiveDate = date.today();
           ApexResponse response = (ApexResponse)JSON.deserialize(LWC_NewOpportunityWorkflow.saveOpp(JSON.serialize(data)),ApexResponse.class);
            Test.stopTest();
            System.assertEquals(response.status, 'Error','Assertion Failed');
            System.assertEquals(response.message, 'There was an error creating the opportunity, please contact the normal support channel.','Incorrect Message');
        }
    }

    //Sending blank AgentContext to validate Logging Service
    @isTest
    private static void validateLogging() {
        queryTestData();
        AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(cccLicensedUser.Id, 'Opportunity_PartialAccess');
        System.runAs(cccLicensedUser) {
            Test.startTest();
             LWC_NewOpportunityworkflow.SaveData data = new LWC_NewOpportunityworkflow.SaveData();
           data.lobSelection = new List<LWC_NewOpportunityWorkflow.ProductLineItem> {
                            createProduct('Private Passenger-System1',Date.Today(),'Auto'),
                                createProduct('Renters-System2',Date.Today(),'Fire'),
                                createProduct('Life Insurance-System3',Date.Today(),'Life')};

                data.accId = acc.id;
            data.sourceComments = 'Test';
                data.marketSource = '1-800-State-Farm';
                data.saveNquote = 'saveNquote';
                data.marketSourceSub = 'Agent';
                data.oppOrg = 'Customer Care Center';
                data.selectedAgentContext = '';
                data.isguided =true;
                data.campaignId = campaignId;
                data.effectiveDate = date.today();
           ApexResponse response = (ApexResponse)JSON.deserialize(LWC_NewOpportunityWorkflow.saveOpp(JSON.serialize(data)),ApexResponse.class);
            Test.stopTest();
            System.assertEquals(response.status, 'Error','Assertion Failed');
            System.assertEquals(response.message, 'There was an error creating the opportunity, please contact the normal support channel.','Incorrect Message');
        }
    }

    //method to test that Agent Context values are quered based on Account ID
    @isTest
    private static void validateAgentContextQuery() {
        queryTestData();
        System.runAs(cccLicensedUser) {
            AgentContext__c agentContext = buildAgentContextRecord(acc.id, cccLicensedUser.Associate_ID__c + TILDE + acc.ClientIdentifier__c, agentUser.id);
            insert agentContext;
            Test.startTest();
            LWC_NewOpportunityworkflow.WrapperAgentRoleSelectedContext selectedContext = LWC_NewOpportunityWorkflow.lwcqueryAgentRolePicklistOptions(acc.id);
            Test.stopTest();
            System.assertEquals('agent,user,75-338-Office', selectedContext.wrapperList[0].label, 'WrapperList WrapperAgentRole label not what was expected');
            System.assertEquals('ASSOCID0001-X7PZ', selectedContext.wrapperList[0].value, 'WrapperList WrapperAgentRole value not what was expected');
            System.assertEquals('ASSOCID0001-X7PZ', selectedContext.selectedAgentContext, 'selectedAgentContext not what was expected');
        }
    }

        //method to test that Agent Context values are quered based on Account ID
    @isTest
    private static void validateStateSelection() {
        queryTestData();
        System.runAs(agentUser) {
            Test.startTest();
             LWC_NewOpportunityworkflow.StateSelectionOptions selectedContext = LWC_NewOpportunityWorkflow.getStateSelectionOptions(string.valueOf(agentUser.Id));
            Test.stopTest();
             System.assertEquals(true, selectedContext.stateList.size() > 0, 'WrapperList WrapperAgentRole label not what was expected');
        }
    }

    // class for ApexResponse
    private with sharing class ApexResponse {

        /**
         * @description status
         */
        public String status{get;set;}

        /**
         * @description message
         */
        public String message{get;set;}

        /**
         * @description result
         */
        public List<Opportunity> result{get;set;}
    }

    private static LWC_NewOpportunityWorkflow.ProductLineItem createProduct(String product, Date effectiveDate, String lob) {
        LWC_NewOpportunityWorkflow.ProductLineItem item = new LWC_NewOpportunityWorkflow.ProductLineItem();
        item.selectedLineOfBusiness = lob;
        item.selectedEffectiveDate = effectiveDate;
        item.selectedProduct = new LWC_NewOpportunityWorkflow.ProductData();
        item.selectedProduct.productSystemName = product.split('-')[1];
        item.selectedProduct.productDescription = product.split('-')[0];
        item.keyField = '1';
        return item;
    }

    @isTest
    private static void testCustomMetaDataAgainstStaticMap() {
       List<CM_USStateCodeMapping__mdt> rows = [SELECT StateCode__c,State__c FROM CM_USStateCodeMapping__mdt];
       Set<String> stateCodesFromCustomMetaData = new Set<String>();
       for(CM_USStateCodeMapping__mdt row : rows){
           stateCodesFromCustomMetaData.add(row.StateCode__c);
       }
       Map<String,String> returnData = LWC_NewOpportunityWorkflow.getStateAbbreviations(stateCodesFromCustomMetaData);
       List<CM_USStateCodeMapping__mdt> stCodeMetaData = [SELECT StateCode__c,State__c FROM CM_USStateCodeMapping__mdt WHERE StateCode__c IN :returnData.keySet()];
       Map<String, List<CM_USStateCodeMapping__mdt>> mapStateCode = new Map<String, List<CM_USStateCodeMapping__mdt>>();
        for(CM_USStateCodeMapping__mdt mdt: stCodeMetaData){

            mapStateCode.put(mdt.StateCode__c, new List<CM_USStateCodeMapping__mdt>());

       }

       for(CM_USStateCodeMapping__mdt mdt: stCodeMetaData){

           List<CM_USStateCodeMapping__mdt> lstState = mapStateCode.get(mdt.StateCode__c);
            lstState.add(mdt);
            mapStateCode.put(mdt.StateCode__c, lstState);

       }
       for(String key: stateCodesFromCustomMetaData){
           String fromReturnData = returnData.get(key);
           List<CM_USStateCodeMapping__mdt> fromMetaData =  mapStateCode.get(key);
           System.assertEquals(fromMetaData.size(),1,'Size of fromMetaData should be 1');
           System.assertEquals(fromReturnData,fromMetaData[0].State__c,'Expected value is '+fromReturnData+', but actual value is '+fromMetaData[0].State__c);
        }
       System.assertEquals('TX',LWC_NewOpportunityWorkflow.getStateAbbreviations(new Set<String>{'53'}).get('53'),'Expected value is TX, but actual value is '+LWC_NewOpportunityWorkflow.getStateAbbreviations(new Set<String>{'53'}).get('53'));
       System.assertEquals('NY',LWC_NewOpportunityWorkflow.getStateAbbreviations(new Set<String>{'52'}).get('52'),'Expected value is NY, but actual value is '+LWC_NewOpportunityWorkflow.getStateAbbreviations(new Set<String>{'52'}).get('52'));
       System.assertEquals('CA',LWC_NewOpportunityWorkflow.getStateAbbreviations(new Set<String>{'55'}).get('55'),'Expected value is CA, but actual value is '+LWC_NewOpportunityWorkflow.getStateAbbreviations(new Set<String>{'55'}).get('55'));
       System.assertEquals('CA',LWC_NewOpportunityWorkflow.getStateAbbreviations(new Set<String>{'75'}).get('75'),'Expected value is CA, but actual value is '+LWC_NewOpportunityWorkflow.getStateAbbreviations(new Set<String>{'75'}).get('75'));
    }


    @isTest
    private static void testThatPassingInvalidStateCodeReturnsEmptyMap(){
        Map<String,String> returnMap = LWC_NewOpportunityWorkflow.getStateAbbreviations(new Set<String>{'InvalidStateCode'});
        System.assertEquals(returnMap.get('InvalidStateCode'),null,'Expected value is '+returnMap.get('InvalidStateCode')+', but actual value is null');
    }

    @isTest
    private static void testThatPassingMultipleStateCodesValidAndInvalidReturnsCorrectMap(){
        Map<String,String> returnMap = LWC_NewOpportunityWorkflow.getStateAbbreviations(new Set<String>{'InvalidStateCode','03','46','Invalid'});
        System.assertEquals(returnMap.get('03'),[SELECT StateCode__c,State__c FROM CM_USStateCodeMapping__mdt WHERE StateCode__c = '03'][0].State__c,'Expected value is '+returnMap.get('03')+', but actual value is '+[SELECT StateCode__c,State__c FROM CM_USStateCodeMapping__mdt WHERE StateCode__c = '03'][0].State__c);
        System.assertEquals(returnMap.get('46'),[SELECT StateCode__c,State__c FROM CM_USStateCodeMapping__mdt WHERE StateCode__c = '46'][0].State__c,'Expected value is '+returnMap.get('46')+', but actual value is '+[SELECT StateCode__c,State__c FROM CM_USStateCodeMapping__mdt WHERE StateCode__c = '46'][0].State__c);
    }
}