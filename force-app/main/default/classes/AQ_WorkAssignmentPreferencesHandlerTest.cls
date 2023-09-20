/**
@author Team Skynet
@name AQ_WorkAssignmentPreferencesHandlerTest
@createDate 10/18/2022
@description Handles testing for AgentRoutingHandler class
*/
@isTest
public with sharing class AQ_WorkAssignmentPreferencesHandlerTest {
    @TestVisible private static final String ACCOUNT_CLIENT_ID = '12345678915';
    private static Account accountRecord {get;set;}
    private static User agentUser {get;set;}
    private static User sysAdmin {get;set;}

    @testSetup
    private static void testSetup(){
        TestUserSetupUtility.setupAgentOffice();
        TestUserSetupUtility.setupSystemAdminUser();
        TestUserSetupUtility.setupApiOnlyUser();
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            //Setup Configuration - Bypass Triggers
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false,TestUserSetupUtility.getSysAdminUser());
            insert passTriggerAll;
            CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(TestUserSetupUtility.getSysAdminUser());

            insert objectBasedByPassTrigger;

            //Setup Users + Accounts
            accountRecord = createAccount();
            agentUser = TestUserSetupUtility.getAgentUser();
            setupAgentRole(agentUser, accountRecord);

            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            sysAdmin = TestUserSetupUtility.getSysAdminUser();

            //Setup Permission Sets
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'AgentQueue'];
            insert new PermissionSetAssignment(AssigneeId = agentUser.id, PermissionSetId = ps.Id);
            insert new PermissionSetAssignment(AssigneeId = sysAdmin.id, PermissionSetId = ps.Id);
        }
    }

    @TestVisible private static Account createAccount(){
        Account account_Record = new Account(Edit_In_VFP__c=true,FirstName='fstName',LastName='lstName',
                                            BillingAddressType__c='US',BillingCity='Phoenix',
                                            ClientIdentifier__c=ACCOUNT_CLIENT_ID);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        insert account_Record;
        return account_Record;
    }

    @TestVisible private static Account getAccount(){
        return [SELECT Id, Name, PersonContactId, ClientIdentifier__c FROM Account WHERE  ClientIdentifier__c = :ACCOUNT_CLIENT_ID];
    }

    @TestVisible private static void setupAgentRole(User userRecord, Account accountRecord){
        AgentRole__c agentRole = new AgentRole__c();
        agentRole.Agent__c = userRecord.Id;
        agentRole.Customer__c = accountRecord.Id;
        agentRole.RelationshipNature__c = 'Customer';
        insert agentRole;
    }

    @TestVisible private static AQ_WorkAssignmentRule__c createWorkAssignment(User assignUser) {
        AQ_WorkAssignmentRule__c workAssignment = new AQ_WorkAssignmentRule__c(
            StartAlpha__c = 'A',
            EndAlpha__c = 'F',
            Task_LOB__c = 'Auto',
            LOB_Stored__c = 'Auto',
            Subject__c = 'BOD Address Change',
            Task_Subject__c = 'Test Task Subject',
            Marketing_Source_Stored__c = 'Marketing Source',
            Opp_Originator_Stored__c = 'Opportunity Originator',
            User__c = assignUser.Id
        );
        insert workAssignment;
        return workAssignment;
    }

    @TestVisible private static AQ_WorkAssignmentRule__c createWorkAssignmentMissingFields(User assignUser) {
        AQ_WorkAssignmentRule__c workAssignment = new AQ_WorkAssignmentRule__c(
            StartAlpha__c = 'A',
            EndAlpha__c = 'F',
            User__c = assignUser.Id
        );
        insert workAssignment;
        return workAssignment;
    }

    @isTest
    public static void testGetRoutingDataRecord() {
        User agent_User = TestUserSetupUtility.getAgentUser();
        agent_User.FederationIdentifier = 'xyz';
        update agent_User;
        AQ_WorkAssignmentRule__c testRule = new AQ_WorkAssignmentRule__c();
        List<AQ_WorkAssignmentPreferencesHandler.AQ_WorkAssignmentWrapper> wrapperList = new List<AQ_WorkAssignmentPreferencesHandler.AQ_WorkAssignmentWrapper>();

        Test.startTest();
        System.runAs(agent_User) {
            testRule = createWorkAssignment(agent_User);
            wrapperList = AQ_WorkAssignmentPreferencesHandler.getRoutingDataRecord();
        }
        Test.stopTest();

        AQ_WorkAssignmentRule__c workAssignmentRule = [SELECT EndAlpha__c,Id,Task_LOB__c,LOB_Stored__c,Marketing_Source_Stored__c, Name, Opp_Originator_Stored__c, StartAlpha__c,Subject__c,Task_Subject__c,User__c,user__r.name, User__r.FederationIdentifier
                                                        FROM AQ_WorkAssignmentRule__c
                                                         WHERE User__r.Id =: agent_User.Id AND User__r.FederationIdentifier != null];
        System.assert(!wrapperList.isEmpty(), 'AQ Wrapper list should not be empty');
        System.assertEquals(workAssignmentRule.Id, wrapperList.get(0).aqId, 'Unexpected wrapper rule id');
        System.assertEquals(workAssignmentRule.User__r.Name, wrapperList.get(0).userName, 'Unexpected wrapper userName');
        System.assertEquals(workAssignmentRule.StartAlpha__c, wrapperList.get(0).alphaStart, 'Unexpected wrapper alphaStart');
        System.assertEquals(workAssignmentRule.EndAlpha__c, wrapperList.get(0).alphaEnd, 'Unexpected wrapper alphaEnd');
        System.assertEquals(workAssignmentRule.LOB_Stored__c, wrapperList.get(0).lobValues.get(0), 'Unexpected wrapper lobValues');
        System.assertEquals(workAssignmentRule.Task_Subject__c, wrapperList.get(0).taskSubject.get(0), 'Unexpected wrapper taskSubject');
        System.assertEquals(workAssignmentRule.Marketing_Source_Stored__c, wrapperList.get(0).marketingSource.get(0), 'Unexpected wrapper marketingSource');
        System.assertEquals(workAssignmentRule.Opp_Originator_Stored__c, wrapperList.get(0).oppOriginator.get(0), 'Unexpected wrapper oppOriginator');

    }

    @isTest
    public static void testSaveRoutingDataRecordsSuccessful() {
        User agent_User = TestUserSetupUtility.getAgentUser();
        AQ_WorkAssignmentRule__c testRule;
        String isResultSaved;

        Test.startTest();
        System.runAs(agent_User) {
            testRule = createWorkAssignment(agent_User);
            User proxyUser = TestUserSetupUtility.getProxyUser();
            List<AQ_WorkAssignmentPreferencesHandler.AQ_WorkAssignmentWrapper> wrapperList = new List<AQ_WorkAssignmentPreferencesHandler.AQ_WorkAssignmentWrapper>();
            AQ_WorkAssignmentPreferencesHandler.AQ_WorkAssignmentWrapper wrapper = new AQ_WorkAssignmentPreferencesHandler.AQ_WorkAssignmentWrapper();
            List<String> lobValues = new List<String>();
            lobValues.add('Auto');
            lobValues.add('Fire');
            wrapper.lobValues = lobValues;
            List<String> taskSubjects = new List<String>();
            taskSubjects.add('BOD Address Change');
            wrapper.taskSubject = taskSubjects;
            List<String> marketingSource = new List<String>();
            marketingSource.add('Sources');
            wrapper.marketingSource = marketingSource;
            List<String> oppOriginator = new List<String>();
            oppOriginator.add('Opportunity');
            wrapper.oppOriginator = oppOriginator;
            wrapper.ownerId = proxyUser.Id;
            wrapper.aqId = testRule.Id;
            wrapper.alphaStart = 'A';
            wrapper.alphaEnd = 'F';
            wrapper.userId = agent_User.Id;
            wrapper.userName = agent_User.Username;
			wrapper.disableTaskSubject = false;
			wrapper.disableLob = false;
            wrapperList.add(wrapper);

            AQ_WorkAssignmentPreferencesHandler.AQ_WorkAssignmentWrapper workAssignWrapper = new AQ_WorkAssignmentPreferencesHandler.AQ_WorkAssignmentWrapper();
            workAssignWrapper.lobValues = lobValues;
            workAssignWrapper.taskSubject = taskSubjects;
            workAssignWrapper.marketingSource = marketingSource;
            workAssignWrapper.oppOriginator = oppOriginator;
            workAssignWrapper.alphaStart = 'A';
            workAssignWrapper.alphaEnd = 'F';
            workAssignWrapper.userId = agent_User.Id;
            workAssignWrapper.userName = agent_User.Username;
			workAssignWrapper.disableTaskSubject = false;
			workAssignWrapper.disableLob = false;
            wrapperList.add(workAssignWrapper);

            isResultSaved = AQ_WorkAssignmentPreferencesHandler.saveRoutingDataRecords(wrapperList);
        }
        Test.stopTest();

        System.assertEquals('Success', isResultSaved, 'Unexpected save status');

        AQ_WorkAssignmentRule__c workAssignmentRule = [SELECT Last_Assigned_User__c,Last_Assigned_Date_Time__c,EndAlpha__c,Id,Task_LOB__c,LOB_Stored__c,Marketing_Source_Stored__c,Name,Opp_Originator_Stored__c, StartAlpha__c,Subject__c,Task_Subject__c,User__c,user__r.name
                                                        FROM AQ_WorkAssignmentRule__c WHERE User__r.Id =: agent_User.Id AND Id =: testRule.Id];

        System.assertEquals('A', workAssignmentRule.StartAlpha__c, 'Unexpected Start Alpha value');
        System.assertEquals('F', workAssignmentRule.EndAlpha__c, 'Unexpected End Alpha value');
        System.assertEquals('BOD Address Change', workAssignmentRule.Task_Subject__c, 'Unexpected task subject value');
        System.assertEquals('Auto,Fire', workAssignmentRule.LOB_Stored__c, 'Unexpected stored LOB value');
        System.assertEquals('Sources', workAssignmentRule.Marketing_Source_Stored__c, 'Unexpected task subject value');
        System.assertEquals('Opportunity', workAssignmentRule.Opp_Originator_Stored__c, 'Unexpected task subject value');
        System.assertEquals(agent_User.Id, workAssignmentRule.Last_Assigned_User__c, 'Unexpected Assigned User');
        //System.assertEquals(datetime.now(), workAssignmentRule.Last_Assigned_Date_Time__c, 'Unexpected Assigned  Date Time');

    }

    @isTest
    public static void testSaveRoutingDataRecordsError() {
        User agent_User = TestUserSetupUtility.getAgentUser();
        AQ_WorkAssignmentRule__c testRule;
        String isResultSaved;

        Test.startTest();
        System.runAs(TestUserSetupUtility.getApiOnlyUser()) {
            testRule = createWorkAssignment(agent_User);
            List<AQ_WorkAssignmentPreferencesHandler.AQ_WorkAssignmentWrapper> wrapperList = new List<AQ_WorkAssignmentPreferencesHandler.AQ_WorkAssignmentWrapper>();
            isResultSaved = AQ_WorkAssignmentPreferencesHandler.saveRoutingDataRecords(wrapperList);
        }
        Test.stopTest();

        System.assertEquals('error', isResultSaved, 'Unexpected save status');

    }
    @isTest
    public static void testGetUserListWrapperList() {
        User agent_User = TestUserSetupUtility.getAgentUser();
        agent_User.LastName ='testUser';
        agent_User.FirstName ='test1User';
        AQ_WorkAssignmentRule__c testRule;
        Test.startTest();
        System.runAs(agent_User) {
            List<User> userList = new List<User>();
            testRule = createWorkAssignment(agent_User);
            userList.add(agent_User);
            Map<Id,AQ_WorkAssignmentRule__c> userRuleAssignMap = new Map <Id,AQ_WorkAssignmentRule__c>();
            userRuleAssignMap.put(agent_User.ID, testRule);
            List <AQ_WorkAssignmentPreferencesHandler.AQ_WorkAssignmentWrapper> aqWrapper = new List<AQ_WorkAssignmentPreferencesHandler.AQ_WorkAssignmentWrapper>();
            aqWrapper = AQ_WorkAssignmentPreferencesHandler.getUserListWrapperList(userList, userRuleAssignMap);
            System.assert(aqWrapper != null, 'aqWrapper is not euql to null');
            aqWrapper = AQ_WorkAssignmentPreferencesHandler.getUserListWrapperList(userList, null);
            System.assert(aqWrapper != null, 'aqWrapper is not euql to null');

            testRule.Task_Subject__c = '';
            update testRule;
            aqWrapper = AQ_WorkAssignmentPreferencesHandler.getUserListWrapperList(userList, userRuleAssignMap);
            System.assert(aqWrapper != null, 'aqWrapper is not euql to null');
            testRule.Task_Subject__c =  'Test Task Subject';
            testRule.LOB_Stored__c = '';
            update testRule;
            aqWrapper = AQ_WorkAssignmentPreferencesHandler.getUserListWrapperList(userList, userRuleAssignMap);
            System.assert(aqWrapper != null, 'aqWrapper is not euql to null');
        }
        Test.stopTest();
    }


}