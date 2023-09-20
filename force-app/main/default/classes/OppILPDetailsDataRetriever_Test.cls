/** 
@Author Team AKITA
@Name OppILPDetailsDataRetriever_Test
@CreateDate 10/15/2021  
@description Test class for OppILPDetailsDataRetriever
@Version 1.0
Copyright © StateFarm  
*/
@isTest
public with sharing class OppILPDetailsDataRetriever_Test {
    public static User agentUser;
    public static User adminUser;
    public static User proxyUser;
    public static Account acc;
    
    static List<Opportunity> emptyObjectList = new List<Opportunity>();


    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap = Schema.Sobjecttype.Account.getRecordTypeInfosByName();


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

    //method to build Agent Role record with Customer Account Id
    private static AgentRole__c buildAgentRoleRecord(String accountId) {
        AgentRole__c agentRole = new AgentRole__c (RelationshipNature__c = 'Customer',
                                                    Agent__c = userInfo.getUserId(), Customer__c = accountId);
        
        return agentRole;
    }

    //method to build Account record with Client First Name, Last Name, and Client Id
    private static Account buildAccountRecord(String fstLstName, String clientId, Id owner) {
        String[] splitFSTLSTName = fstLstName.split(' ');
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        Account act = new Account(FirstName = splitFSTLSTName[0] , LastName = splitFSTLSTName[1], ownerId = owner,
                                    RecordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId, ClientIdentifier__c = clientId, BillingState = 'MD');
        return act;
    }

    /**
    * @description setup method to build the account and agent relationships
    */
    @testSetup
    public static void setUp() {
        
        User adminUser = UTIL_UserProvisioning_TEST.buildUserWithSystemAdminProfile('TestAdminUser@statefarm.com.bad');
        insert adminuser;
        User agentUser;
        User proxyUser; 
        
        System.runAs(adminUser) {
            byPassTrigger();
            
            UserRole agentUserRole = buildUserRole('AgentRole');
            insert agentUserRole;
            
            UserRole proxyUserRole = buildUserRoleWithParent('ProxyRole', agentUserRole.id);
            insert proxyUserRole;
            User testAgentUser = new User(Alias='X7PZ',LastName='agent,user,75-338-Office',Username='TestAgentUser@statefarm.com.bad',Associate_ID__c='ASSOCID0001',UserExternalID__c='EXTERNALID1',Servicing_Agent_Associate_ID__c='AGTASSOCID1',Territory_Associate_ID__c='',Servicing_Agent_Associate_ID_List__c='',Territory_Associate_ID_List__c='');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser(testAgentUser);
            agentUser.userRoleId = agentUserRole.id;
            agentUser.state_agent_code__c = '20-7185';
            agentUser.state_agent_code_list__c = '20-7185,05-7185,32-7185';
            agentUser.SubUserType__c = 'Agent';
            agentUser.UserExternalID__c = 'SERVICINID1_SERVICINID1';

            insert agentUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);

            User testProxyUser1 = new User(Alias='X7PX',LastName='middle,Last,75-338-Office',Username='TestProxyUser@statefarm.com.bad',UserExternalID__c='EXTERNALID1_EXTERNALID1',Servicing_Agent_Associate_ID__c='SERVICINID1');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;
        }
        Account acc = OppILPDetailsDataRetriever_Test.buildAccountRecord('FST LST','111',agentUser.Id);
        insert acc;
        
        //Insert agent role to give account access to the Agent
        AgentRole__c agentRole;
        System.runAs(agentUser) {
            agentRole = buildAgentRoleRecord(acc.Id);
        }
        insert agentRole;
    }

    /**
    * @description queires the test data
    */
    public static void queryTestData() {
        adminUser = [Select Id,Associate_ID__c from User where username = 'TestAdminUser@statefarm.com.bad'];
        agentUser = [Select Id,Associate_ID__c, UserExternalID__c from User where username = 'TestAgentUser@statefarm.com.bad'];
        proxyUser = [Select Id,Associate_ID__c from User where username = 'TestProxyUser@statefarm.com.bad'];
        acc = [Select Id,ClientIdentifier__c, Name from Account where lastname = 'LST'];
    }

    //Method to test the getAllILPObjects method for an opp with only one ILP_Opportunity_General_Party_Info__c object
    @isTest
    private static void getAllILPObjectsAsAgent() {
        List<List<SObject>> emptyTwoDimList = new List<List<SObject>>();
        queryTestData();
        System.runAs(agentUser) {
            Opportunity opp = buildAnILPOpportunity();
            insert opp;
            ILP_Opportunity_General_Party_Info__c generalPartyInfo = buildGeneralPartyInfoRecord(opp.Id, 'firstGeneralPartyInfoRecord');
            insert generalPartyInfo;
            Test.startTest();
            List<List<SObject>> serializedData = OppILPDetailsDataRetriever.getAllILPObjects(opp.Id);
            Test.stopTest();
            List<ILP_Opportunity_General_Party_Info__c> generalPartyInfoList = [SELECT WorkPhone__c, HomePhone__c, Designation__c, NameOfCarrier__c, Citizenship__c, MilitaryService__c, MobilePhone__c, 
                                                                                 MonthsWithCarrier__c, InsuranceCancellationReason__c, ContactPreference__c, LastName__c, Language__c, Id, FirstName__c, Email__c FROM ILP_Opportunity_General_Party_Info__c WHERE Opportunity__c =: opp.Id];
            emptyTwoDimList.add(generalPartyInfoList);
            for (Integer i = 0; i < 9; i++) {
                emptyTwoDimList.add(emptyObjectList);
            }
            System.assertEquals(emptyTwoDimList, serializedData, 'Failed to assert that lists were equal.');
        } 
    }

    //Method to test the getAllILPObjects method for an opp with two ILP_Opportunity_General_Party_Info__c objects
    @isTest
    private static void getAllILPObjectsAsAgentWith2GeneralPartyInfos() {
        List<List<SObject>> emptyTwoDimList = new List<List<SObject>>();
        queryTestData();
        System.runAs(agentUser) {
            Opportunity opp = buildAnILPOpportunity();
            insert opp;
            ILP_Opportunity_General_Party_Info__c generalPartyInfo = buildGeneralPartyInfoRecord(opp.Id, 'firstGeneralPartyInfoRecord');
            insert generalPartyInfo;
            ILP_Opportunity_General_Party_Info__c secondGeneralPartyInfo = buildGeneralPartyInfoRecord(opp.Id, 'secondGeneralPartyInfoRecord');
            insert secondGeneralPartyInfo;
            Test.startTest();
            List<List<SObject>> serializedData = OppILPDetailsDataRetriever.getAllILPObjects(opp.Id);
            Test.stopTest();
            List<ILP_Opportunity_General_Party_Info__c> generalPartyInfoList = [SELECT WorkPhone__c, HomePhone__c, Designation__c, NameOfCarrier__c, Citizenship__c, MilitaryService__c, MobilePhone__c, 
                                                                                    MonthsWithCarrier__c, InsuranceCancellationReason__c, ContactPreference__c, LastName__c, Language__c, Id, FirstName__c, Email__c FROM ILP_Opportunity_General_Party_Info__c WHERE Opportunity__c =: opp.Id];
            generalPartyInfoList.sort();
            emptyTwoDimList.add(generalPartyInfoList);
            for (Integer i = 0; i < 9; i++) {
                emptyTwoDimList.add(emptyObjectList);
            }
            System.assertEquals(emptyTwoDimList, serializedData, 'Failed to assert that lists were equal.');
        } 
    }

    //Method to test the getAllILPObjects method for an opp with one ILP_Opportunity_General_Party_Info__c object and two ILP_Opportunity_Address__c objects
    @isTest
    private static void getAllILPObjectsAsAgentWith2Addresses() {
        List<List<SObject>> emptyTwoDimList = new List<List<SObject>>();
        queryTestData();
        System.runAs(agentUser) {
            Opportunity opp = buildAnILPOpportunity();
            insert opp;
            ILP_Opportunity_General_Party_Info__c generalPartyInfo = buildGeneralPartyInfoRecord(opp.Id, 'firstGeneralPartyInfoRecord');
            insert generalPartyInfo;
            ILP_Opportunity_Address__c addressInfo = buildAddressInfoRecord(opp.Id, 'firstAddressRecord', generalPartyInfo.Id);
            insert addressInfo;
            ILP_Opportunity_Address__c secondAddressInfo = buildAddressInfoRecord(opp.Id, 'secondAddressRecord', generalPartyInfo.Id);
            insert secondAddressInfo;
            Test.startTest();
            List<List<SObject>> serializedData = OppILPDetailsDataRetriever.getAllILPObjects(opp.Id);
            Test.stopTest();
            List<ILP_Opportunity_General_Party_Info__c> generalPartyInfoList = [SELECT WorkPhone__c, HomePhone__c, Designation__c, NameOfCarrier__c, Citizenship__c, MilitaryService__c, MobilePhone__c, 
                                                                                    MonthsWithCarrier__c, InsuranceCancellationReason__c, ContactPreference__c, LastName__c, Language__c, Id, FirstName__c, Email__c FROM ILP_Opportunity_General_Party_Info__c WHERE Opportunity__c =: opp.Id];
            emptyTwoDimList.add(generalPartyInfoList);
            List<ILP_Opportunity_Address__c> addressInfoList = [SELECT Type__c, Address1__c, Address2__c, City__c, State__c, Zip__c, Country__c, Id FROM ILP_Opportunity_Address__c WHERE Opportunity__c =: opp.Id];
            addressInfoList.sort();
            emptyTwoDimList.add(addressInfoList);
            for (Integer i = 0; i < 8; i++) {
                emptyTwoDimList.add(emptyObjectList);
            }
            System.assertEquals(emptyTwoDimList, serializedData, 'Failed to assert that lists were equal.');
        } 
    }

    //Method to test the getAllILPObjects method for an opp with no ILP Object data
    @isTest
    private static void getAllILPObjectsAsAgentNoResults() {
        String errorMessage;
        queryTestData();
        System.runAs(agentUser) {
            Opportunity opp = buildAnILPOpportunity();
            insert opp;
            Test.startTest();
            try {
                OppILPDetailsDataRetriever.getAllILPObjects(opp.Id);
            }
            catch (Exception e) {
                errorMessage = e.getMessage();
            }
            Test.stopTest();
            System.assertEquals('Apex returned no records', errorMessage, 'Failed to assert exception message.');
        } 
    }

    private static Opportunity buildAnILPOpportunity() {
        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Name = 'ILP Test Opp';
        newOpportunity.AccountId = acc.Id;
        newOpportunity.Type = 'New Business';
        newOpportunity.Lead_Validation_Date__c = System.today();
        newOpportunity.Vendor_Id__c = 'ILP1';
        newOpportunity.StageName = 'New';
        newOpportunity.LOB__c = 'Auto';
        newOpportunity.ForecastCategoryName = 'Pipeline';
        newOpportunity.CloseDate = System.today()+60;
        newOpportunity.ExternalILPId__c = 'sdxch';
        newOpportunity.Transaction_ID__c = 'wsghbyy';
        newOpportunity.OwnerId = proxyUser.Id;
        return newOpportunity;
    }
    
    private static ILP_Opportunity_General_Party_Info__c buildGeneralPartyInfoRecord(Id opp, String name) {
        ILP_Opportunity_General_Party_Info__c generalPartyInfoRecord = new ILP_Opportunity_General_Party_Info__c();
        generalPartyInfoRecord.Name = name;
        generalPartyInfoRecord.Opportunity__c = opp;
        generalPartyInfoRecord.FirstName__c = name;
        generalPartyInfoRecord.LastName__c = 'LLLLL';
        generalPartyInfoRecord.Designation__c = 'designation';
        generalPartyInfoRecord.MilitaryService__c = 'Colonel';
        generalPartyInfoRecord.Citizenship__c = 'Canadian';
        generalPartyInfoRecord.HomePhone__c = '309-111-1111';
        generalPartyInfoRecord.MobilePhone__c = '309-111-1111';
        generalPartyInfoRecord.WorkPhone__c = '309-111-1111';
        generalPartyInfoRecord.Email__c = 'ffffflllll@gmail.com';
        generalPartyInfoRecord.ContactPreference__c = 'Phone';
        generalPartyInfoRecord.Language__c = 'English';
        generalPartyInfoRecord.NameOfCarrier__c = 'Geico';
        generalPartyInfoRecord.MonthsWithCarrier__c = '12';
        generalPartyInfoRecord.InsuranceCancellationReason__c = 'Price';

        return generalPartyInfoRecord;
    }

    private static ILP_Opportunity_Address__c buildAddressInfoRecord(Id opp, String name, Id generalPartyInfo) {
        ILP_Opportunity_Address__c addressInfoRecord = new ILP_Opportunity_Address__c();
        addressInfoRecord.Name = name;
        addressInfoRecord.Opportunity__c = opp;
        addressInfoRecord.Type__c = 'Home';
        addressInfoRecord.Address1__c = '123 Street Road';
        addressInfoRecord.Address2__c = 'Apt. 1';
        addressInfoRecord.City__c = 'Bloomington';
        addressInfoRecord.State__c = 'IL';
        addressInfoRecord.Zip__c = '61701';
        addressInfoRecord.Country__c = 'United States';
        addressInfoRecord.GeneralPartyInfo__c = generalPartyInfo;

        return addressInfoRecord;
    }
}