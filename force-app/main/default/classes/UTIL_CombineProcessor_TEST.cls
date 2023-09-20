/**
 * @name UTIL_CombineProcessor_TEST
 * @author Club Car Team
 * @description Apex unit testing for UTIL_CombineProcessor processor
 */

/**
 * @name UTIL_CombineProcessor_TEST
 * @author Team: Loco Motivated
 * @Version 2.0
 * @Description: Updated UTIL_CombineProcessor_TEST to accomodate Customer Relationships
 */

/**
 * @name UTIL_CombineProcessor_TEST
 * @author Team: Choo Choo
 * @Version 3.0
 * @Description: Updated UTIL_CombineProcessor_TEST to accomodate AssignedStaff
 */


/**
 * @Name UTIL_CombineProcessor
 * @Author Team Akita
 * @CreateDate 5/1/2018
 * @Description: Updated UTIL_CombineProcessor to merge customer details for multiple loosing clientIds
 * @Version 4.0
 */

/**
 * @Author Team Golden Spikes
 * @ModifiedDate 5/10/2018
 * @Description: Updated UTIL_CombineProcessor for Planning Conversation Log Object.
 * @Version 5.0
 */

/**
 * @Author Team Shenanigans
 * @ModifiedDate 07/19/2018
 * @Description: Added logic for Customer Initiated Cancellations Object for removed book of business, split and merge accounts
 * @Version 6.0
 */

/**
 * @Author Team Golden Spikes
 * @ModifiedDate 08/10/2018
 * @Description: Updated UTIL_CombineProcessor for Simple Conversation Object.
 * @Version 7.0
 */

/**
 * @Author Team ITIC
 * @ModifiedDate 09/16/2019
 * @Description: Updated UTIL_CombineProcessor for campaignmember Object.
 * @Version 8.0
 */

/**
 * @description Apex unit testing for UTIL_CombineProcessor processor
 */
@isTest(seeAllData=false)
private class UTIL_CombineProcessor_TEST {
    private static Account losingAccount;
    private static Account winningAccount;
    private static CustomerGroup__C testGroup;
    private static Account household1;
    private static Account household2;

    private static User sysAdminUser;
    private static User systemUser;
    private static User agentUser;
    private static Profile apiProfile = [
        SELECT Id, Name
        FROM Profile
        WHERE Name = :UTIL_StageOrchestrationConstants.STAGE_ORCHESTRATION_PROFILE_NAME
    ];

    //create API Admin user to run combine processor
    private static User testAPIUser;

    private static TestData_SalesRoleHierarchy salesRoleHierarchy0;
    private static TestData_SalesRoleHierarchy salesRoleHierarchy1;
    private static TestData_SalesRoleHierarchy salesRoleHierarchy2;
    private static PermissionSetAssignment psassignment;
    private static final String LOSING_CLIST = 'BBB5S6J0L';
    private static final String WINNING_CLIST = 'BBB5S6J0W';
    private static final String OTHER_CLIENT = 'BBB5S6J0D';
    public static final String HOUSEHOLD_RECORD_TYPE = 'IndustriesHousehold';

    //Setup method to create custom settings and test users
    /**
     * @description Setup method to create custom settings and test users
     */
    @TestSetup
    public static void setup() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        UTIL_CombineProcessor.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CUSTOMERGROUPINGS, true);
        //create system Admin user to insert accounts
        Profile sysProfile = [SELECT Id FROM Profile WHERE name = :UTIL_Constants.SYSTEM_ADMIN_PROFILE_NAME LIMIT 1];
        sysAdminUser = buildtestUser('remCmpMemSysAd@statefarm.com', sysProfile, 'A1A');
        insert sysAdminUser;
        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(
        Override_All__c = true);
        insert passTriggerAll;
        testAPIUser = buildtestUser('testAPI@statefarm.com', apiProfile, 'A2A');
        insert testAPIUser;
        //assigning API Admin user to permission set
        psAssignment = assignPermissionSet(testAPIUser);
        //insert psAssignment;
        //build system User
        Profile systemUserProfile = [
            SELECT Id
            FROM Profile
            WHERE name = :UTIL_Constants.NO_ACCESS_PROFILE_NAME
            LIMIT 1
        ];
        systemUser = buildtestUser('t1s11t1Sys111tem11User', systemUserProfile, 'P2P');
        insert systemUser;
        //build agent User
        Profile agentUserProfile = [SELECT Id FROM Profile WHERE name = :UTIL_Constants.AGENT_PROFILE_NAME LIMIT 1];
        agentUser = buildtestUser('TestAgentUser', agentUserProfile, 'TAU');
        insert agentUser;
        //build custom setting record
        AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
        insert accountOwner;
        salesRoleHierarchy0 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('S');
        salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('Q');
        salesRoleHierarchy2 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('T');
    }

    //method to fetch users
    private static void fetchUsers() {
        List<User> usrlist = [
            SELECT
                Id,
                Username,
                Associate_ID__c,
                Proxy_External_ID__c,
                Servicing_Agent_Associate_ID__c,
                Servicing_Agent_External_ID__c,
                UserExternalID__c,
                Agent_Name_Alias__c,
                SubUserType__c
            FROM User
            WHERE UserExternalID__c IN ('SAAA1A_SAAA1A', 'SAAA2A_SAAA2A','SAAP2P_SAAP2P', 'SAATAU_SAATAU')
            ORDER BY UserExternalID__c ASC
        ];
        sysAdminUser = usrlist.get(0);
        systemUser = usrlist.get(2);
        agentUser = usrlist.get(3);
        testAPIUser = usrlist.get(1);
        salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('Q');
        salesRoleHierarchy2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('T');
    }
    //method to build Account Owner custom setting record with the given parameter value
    private static AccountOwnerSystemUserCustomSetting__c buildCustomSettingRecord(String userId) {
        AccountOwnerSystemUserCustomSetting__c actOwnerCs = new AccountOwnerSystemUserCustomSetting__c(Name = UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER, SFDC_USER_ID__c = userId);
        return actOwnerCs;
    }

    /**
     * @description This method is used for to build a test API user with a specific Profile
     * @Method: buildtestUser <This method is used to create test users>
     * @param t_lastName
     * @param testProfile
     * @param t_userExternalID
     * @return User
     */

    public static User buildtestUser(String t_lastName, Profile testProfile, String t_userExternalID) {
        User testUser= new User(alias = 'test', email= 'testuser@statefarm.com', profileid = testProfile.id,
                                emailencodingkey='UTF-8', lastname=t_lastName, languagelocalekey='en_US',
                                localesidkey='en_US', timezonesidkey='Europe/London', username= t_lastName+'@statefarm.com',
                                UserExternalID__c = 'SAA'+t_userExternalID+'_'+'SAA'+t_userExternalID,Associate_ID__c = 'SAA'+t_userExternalID,SubUserType__c='Agent');
        return testUser;
    }

    /**
     * @description This method is used for assign a particular PermissionSet to a particular User
     * @Method: assignPSet <This method is used to get Standard testUser>
     * @param testUser
     * @return PermissionSetAssignment
     */
    public static PermissionSetAssignment assignPermissionSet(User testUser){
        PermissionSet ps = [Select Id, Name FROM PermissionSet WHERE Name=:UTIL_StageOrchestrationConstants.STAGE_ORCHESTRATION_PERMISSION_SET_NAME];
        PermissionSetAssignment assignment = new PermissionSetAssignment(AssigneeId=testUser.Id, PermissionSetId=ps.Id);
        return assignment;
    }

    /**
     * @description method is used to create ACR data
     * @param householdAccount
     * @param acc
     */
    public static void createACRData(Account householdAccount, Account acc){
        AccountContactRelation acr = new AccountContactRelation();
		Account accRecord = [Select personcontactid from Account where id =: acc.id];
		acr.AccountId =  householdAccount.Id; // household id
		acr.contactId =  accRecord.PersonContactId; // person contact id
        acr.FinServ__PrimaryGroup__c = true;
        insert acr;
    }

    /**
     * @description method used for testing account messages merge
     * @name   setUp
     */
     @isTest
    private static void combineProcessorWithAllDataByCustomerGroupingEnabled() {
        Map<UTIL_Toggles, boolean> toggleMap = new Map<UTIL_Toggles, boolean>();
        toggleMap.put(UTIL_Toggles.CUSTOMERGROUPINGS, true);
        toggleMap.put(UTIL_Toggles.TOGGLE_FSC, true);
        UTIL_CombineProcessor.toggleContext = UTIL_ToggleTestUtils.buildContext(toggleMap);
        fetchUsers();
        List<Account> accountList = new List<Account>();
        List<Account> accountListToBeUpdated = new List<Account>();
        List<Account_Note__c> accountNotesList = new List<Account_Note__c>();
		Account_Note__c losingAccountNote;
        Account_Note__c winningAccountNote;
        ProductsServicedByMe__c losingAccountPSBM;
        ProductsServicedByMe__c winningAccountPSBM;

        accountList.add(createAccount(LOSING_CLIST));
        accountList.add(createAccount(WINNING_CLIST));
        accountList.add(createAccount(OTHER_CLIENT));
        psAssignment = assignPermissionSet(testAPIUser);
        System.runAs(sysAdminUser) {
            insert psAssignment;
            insert accountList;
        }
        losingAccount = [Select id, personcontactid from Account where ClientIdentifier__c = :LOSING_CLIST];
        winningAccount = [Select id, personcontactid from Account where ClientIdentifier__c = :WINNING_CLIST];
        insertChildObjects(accountList);
        System.runAs(sysAdminUser){
            losingAccount.Primary_Household__pc = household1.id;
            winningAccount.Primary_Household__pc = household2.id;
            losingAccountNote = new Account_Note__c(Alert__c=true,Account__C=losingAccount.id, Primary_Household__c=household1.id, Comments__c='losing comments');
            winningAccountNote = new Account_Note__c(Alert__c=true,Account__C=winningAccount.id, Primary_Household__c=household2.id, Comments__c='winning comments');
            losingAccountPSBM = new ProductsServicedByMe__c(customer__c=losingAccount.Id,ProductType__c='Disability Income', Primary_Household__c=household1.id,
                                                                    CarrierName__c='Trupanion',ProductLine__c='Health',Agent__c=salesRoleHierarchy1.Agent.id);
            winningAccountPSBM = new ProductsServicedByMe__c(customer__c=winningAccount.Id,ProductType__c='Motorcycle', Primary_Household__c=household2.id,
                                                                    CarrierName__c='Assigned Risk/JUA',ProductLine__c='Auto',Agent__c=salesRoleHierarchy1.Agent.id);
            List<ProductsServicedByMe__c> psbmList = new List<ProductsServicedByMe__c>();
            psbmList.add(losingAccountPSBM);
            psbmList.add(winningAccountPSBM);
            accountNotesList.add(losingAccountNote);
            accountNotesList.add(winningAccountNote);
            accountListToBeUpdated.add(losingAccount);
            accountListToBeUpdated.add(winningAccount);

            update accountListToBeUpdated;
            insert accountNotesList;
            insert psbmList;
            CS001_ByPassTriggerAll__c passTriggerAll1 = [SELECT Id, Override_All__c FROM CS001_ByPassTriggerAll__c];
            passTriggerAll1.Override_All__c = false;
            update passTriggerAll1;
            CS001_ByPassTriggerAtoF__c byPassTriggerAtoF = new CS001_ByPassTriggerAtoF__c(Override_AccountBeforeDelete__c  = true, Override_ACRAfterUpdate__c=false);
            insert byPassTriggerAtoF;
        }

        System.runas(testAPIUser){
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            BuildJsonWrapperList apiUserWrap = new BuildJsonWrapperList();
				apiUserWrap.lclientId = LOSING_CLIST;
				apiUserWrap.wcliendId = WINNING_CLIST;
				apiUserWrap.otherid = OTHER_CLIENT;
				apiUserWrap.assocId = 'SAA1A';
				apiUserWrap.externalSyncTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			testStageOrchestration.Value__c = buildJSON(apiUserWrap);
            stgorcList.add(testStageOrchestration);
            test.startTest();
            new UTIL_CombineProcessor().execute(stgorcList);
            test.stopTest();
        }
        //checking assignment of account messages to winner
        Account accountUpdateList = [Select id,FirstName, (Select id,Name from AccountMessage__r)
                                     from Account where ClientIdentifier__c  =: WINNING_CLIST];

        System.assertEquals(accountUpdateList.AccountMessage__r.size(),22, 'Size of List<Account> is not equals to 22');
        System.assertEquals([Select id from AgentRole__c].size(),2, 'Size of List<AgentRole__c> is not equals to 2');
        System.assertEquals(accountUpdateList.FirstName, 'GIOVAN', 'Expected FirstName is not equals to the actual FirstName');
		assertChildObjects(accountList);

        System.assertEquals([SELECT Primary_Household__c FROM Account_Note__c where id =: losingAccountNote.id].Primary_Household__c, [SELECT Primary_Household__c FROM Account_Note__c where id =: winningAccountNote.id].Primary_Household__c, 'On Combine Losing acconts Primary_Household__c is not matching with winning account Primary_Household__c');
        //checking if PSBM are assigned to winner
        System.assertEquals([Select Id, Primary_Household__c from ProductsServicedByMe__c where id =: losingAccountPSBM.Id].Primary_Household__c, [Select Id, Primary_Household__c from ProductsServicedByMe__c where id =: winningAccountPSBM.Id].Primary_Household__c, 'On combine Losing Account PSBM Primary_Household__c is not matching with Winning Account PSBM Primary_Household__c ');

        //System.assert(![Select Id, isActive FROM AccountContactRelation where AccountId =: household1.Id].isActive,'on combine losing Accounts ACR record Should be inactive');
        System.assertEquals(0, [Select Id FROM AccountContactRelation where AccountId =: household1.Id].size(), 'on combine losing Accounts ACR record Should be deleted');
        System.assertEquals(1, [Select Id FROM AccountContactRelation where AccountId =: household2.Id].size(), 'on combine winning Accounts ACR record Should not be deleted');
        assertCustometGroupings(accountList);
    }

    private static void assertCustometGroupings(List<Account> accountList){
        List<CustomerGroup__c> listofHouseholdGroup = [Select id, GroupCategory__c from CustomerGroup__c Where SFGroupIdentifier__c IN ('HouseholdA1','HouseholdA2')];
        for (CustomerGroup__c newGroup:listofHouseholdGroup){
            System.assertEquals(newGroup.GroupCategory__c, 'Primary', 'GroupCategory__c is not equals to \'Primary\'');
        }
        List<CustomerGroupMember__c> houseHoldGroupMemberList = [Select Id, GroupCategory__c from CustomerGroupMember__c Where GroupMemberId__c IN ('HouseholdA1~BBB5S6J0W','HouseholdA2~BBB5S6J0W')];
        for (CustomerGroupMember__c newGroupMember:houseHoldGroupMemberList){
            System.assertEquals(newGroupMember.GroupCategory__c, 'Primary', 'GroupCategory__c is not equals to \'Primary\'');
        }
        System.assertEquals([Select id from CustomerGroup__c WHere SFGroupIdentifier__c IN ('HouseholdA1','HouseholdA2')].size(),2, 'Size of List<CustomerGroup__c> is not equals to 2');
        System.assertEquals([Select id from CustomerGroupMember__c Where GroupMemberId__c IN ('HouseholdA1~BBB5S6J0W','HouseholdA2~BBB5S6J0W')].size(),2, 'Size of List<CustomerGroupMember__c> is not equals to 2');

        //checking for loosingClient GroupMember
        List<CustomerGroupMember__c> loosingGroupMemberList = [select Id from CustomerGroupMember__c where Customer__c=:accountList[0].Id];
        system.assert(loosingGroupMemberList.isEmpty(), 'List<CustomerGroupMember__c> is not empty');
    }
    private static void assertChildObjects(List<Account> accountList){
        //checking if lead conversion details deleted to loser account
         List<LeadConversionDetail__c>  leadList = [Select id,name,Customer__r.ClientIdentifier__c  from LeadConversionDetail__c
                                                   Where Customer__r.ClientIdentifier__c  =: LOSING_CLIST];
        System.assertEquals(leadList.size(),0, 'Size of List<LeadConversionDetail__c> is not equals to 0');

        //checking customer Relationships details list deleted for Loosing and Winning Master side
        List<Relationship__c> relationshipsList=[select AccountTwo__r.clientIdentifier__c,AccountOne__r.clientIdentifier__c,RelationshipType__c,RelationshipIdentifier__c
                                                 from Relationship__c where AccountTwo__C=:accountList OR AccountOne__C =:accountList];
        system.assertEquals(WINNING_CLIST, relationshipsList.get(0).AccountTwo__r.clientIdentifier__c, 'Expected parameter is not equals to the actual parameter');
        system.assertEquals(OTHER_CLIENT, relationshipsList.get(0).AccountOne__r.clientIdentifier__c, 'Expected parameter is not equals to the actual parameter');
        system.assertEquals('Father', relationshipsList.get(0).RelationshipType__c, 'Relationship type is not \'Father\'');
        system.assertEquals(WINNING_CLIST + '~' + OTHER_CLIENT, relationshipsList.get(0).RelationshipIdentifier__c, 'Expected parameter is not equals to the actual parameter');
        System.assertEquals(1, relationshipsList.size(), 'Size of List<Relationship__c> is not equals to 1');

        //checking if only unique id record is upserted
        List<AgentRole__c> agentlist = [SELECT id, AgentRoleIdentifier__c, RelationshipNature__c FROM AgentRole__c];
        System.assertEquals(agentlist[0].AgentRoleIdentifier__c, 'SAA1A~' + WINNING_CLIST, 'Expected parameter is not equals to the actual parameter');
        System.assertEquals(agentlist[1].AgentRoleIdentifier__c, 'SAA2A~' + WINNING_CLIST, 'Expected parameter is not equals to the actual parameter');
        System.assertEquals(agentlist[0].RelationshipNature__c, UTIL_StageOrchestrationConstants.EX_CUSTOMER, 'Expected parameter is not equals to the actual parameter');

        //checking if tasks are assigned to winner
        for(Task checkTask : [Select id,WhatId from Task]){
            System.assertEquals(checkTask.WhatId, accountList[1].Id,'WhatId is not equals to AccountId');
        }
        System.assertEquals([SELECT id FROM account where RecordType.DeveloperName!=:HOUSEHOLD_RECORD_TYPE].size(), 2, 'Size of List<Account> is not equals to 2');

        //checking if opportunities are assigned to winner
        for(Opportunity checkOppty : [Select id,AccountId from Opportunity]){
            System.assertEquals(checkOppty.AccountId, accountList[1].Id, 'Expected Account Id is not equals to the actual Account Id');
        }
        //checking for AgentContext
        List<AgentContext__c> agContextList =[select id from AgentContext__c where Customer__c=:accountList[0].Id ];
        system.assert(agContextList.isEmpty(), 'List<AgentContext__c> is not empty');
    }

    private static void insertChildObjects(List<Account> accountList){
        List<AccountMessage__c> accountMessageList = new List<AccountMessage__c>();
        List<Account>  householdAccountList= new List<Account>();
        List<AgentRole__c> agentRoleList = new List<AgentRole__c>();
        List<Task> taskList = new List<Task>();
        List<User> agentUserList = new List<User>();
        List<Opportunity> opportunityList = new List<Opportunity>();
        List<LeadConversionDetail__c> leadConversionList = new List<LeadConversionDetail__c>();
        List<Relationship__c> relationshipList = new List<Relationship__c>();
        List<AgentContext__c> testAgentContext = new List<AgentContext__c>();
        List<sobject> insertAll = new List<sobject>();
        System.runAs(salesRoleHierarchy1.Agent) {
           household1 = new Account(name='Household', recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId(), AllowHousehold__c = true);
           household2 = new Account(name='Household', recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId(), AllowHousehold__c = true);
           householdAccountList.add(household1);
           householdAccountList.add(household2);
           insert householdAccountList;
        }

        System.runAs(testAPIUser){
            createACRData(household1, losingAccount);
            createACRData(household2, winningAccount);
        }

         for (Integer i = 0; i <= 10; i++) {
            accountMessageList.add(createAccountMessage('test' + i, accountList[0].Id, 'Sent'));
            accountMessageList.add(createAccountMessage('testS' + i, accountList[0].Id, 'Scheduled'));
            accountMessageList.add(createAccountMessage('testC' + i, accountList[0].Id, 'Cancelled-stopped journey'));

            agentRoleList.add(createAgentRole('1C8UTE3' + i, accountList[0].Id));
            leadConversionList.add(createLeadConversion('testL' + i, accountList[0].Id));
            taskList.add(createTask(accountList[0].Id, i));
            opportunityList.add(createOpportunity(accountList[0].Id, i));
        }

        relationshipList.add(
            createC2CRelationships(accountList[0].clientIdentifier__C, accountList[1].clientIdentifier__C, 'Parent')
        );
        relationshipList.add(
            createC2CRelationships(accountList[1].clientIdentifier__C, accountList[0].clientIdentifier__C, 'Son')
        );
        relationshipList.add(
            createC2CRelationships(accountList[0].clientIdentifier__C, accountList[2].clientIdentifier__C, 'Other')
        );
        relationshipList.add(
            createC2CRelationships(accountList[2].clientIdentifier__C, accountList[0].clientIdentifier__C, 'Account')
        );
        relationshipList.add(
            createC2CRelationships(accountList[1].clientIdentifier__C, accountList[2].clientIdentifier__C, 'Spouse')
        );

        testAgentContext.add(
            new AgentContext__c(
                Customer__c = accountList[0].Id,
                AgentContextIdentifier__c = '1C8UTE30~' + accountList[0].clientIdentifier__C
            )
        );
        testAgentContext.add(
            new AgentContext__c(
                Customer__c = accountList[0].Id,
                AgentContextIdentifier__c = '1C8UTE31~' + accountList[0].clientIdentifier__C
            )
        );

        Profile agentProfile = [Select Id from Profile where name = '2.00 Agent'];
        agentUserList.add(buildtestUser('agent1@statefarm.com', agentProfile, '1A'));
        agentUserList.add(buildtestUser('agent2@statefarm.com', agentProfile, '2A'));

        insertAll.addAll((List<sObject>) accountMessageList);
        insertAll.addAll((List<sObject>) agentRoleList);
       insertAll.addAll((List<sObject>) leadConversionList);
        insertAll.addAll((List<sObject>) taskList);
        insertAll.addAll((List<sObject>) opportunityList);
        insertAll.addAll((List<sObject>) relationshipList);
        insertAll.addAll((List<sObject>) testAgentContext);

        System.runas(sysAdminUser){
            insert agentUserList;
        }

        System.runas(testAPIUser){
            insert insertAll;
            CustomerGroup__c custGroup = new CustomerGroup__c(Agent__c=agentUserList.get(0).Id, SFGroupIdentifier__c='UNIQUEGROUP');
            insert custGroup;
            insert new CustomerGroupMember__c(Group__c=custGroup.id,Customer__c=accountList[0].Id,GroupMemberId__c='UNIQUEGROUP~'+accountList[0].clientIdentifier__C);
        }
    }
    /**
     * @description method used for testing account messages merge
     * @name   setUp
     */
    @isTest
    private static void combineProcessorForEntityIsDeletedException() {
        fetchUsers();
        List<Account> accountList = new List<Account>();
        List<User> agentUserList = new List<User>();
        List<AgentRole__c> agentRoleList = new List<AgentRole__c>();
        List<AgentContext__c> testAgentContext = new List<AgentContext__c>();
        List<sobject> insertAll = new List<sobject>();

        accountList.add(createAccount(LOSING_CLIST));
        accountList.add(createAccount(WINNING_CLIST));
        accountList.add(createAccount(OTHER_CLIENT));
		psAssignment = assignPermissionSet(testAPIUser);
        System.runAs(sysAdminUser) {
            insert psAssignment;
            insert accountList;
        }
        for(Integer i=0; i<=10; i++){
            agentRoleList.add(createAgentRole('1C8UTE3'+i, accountList[0].Id));
        }
        testAgentContext.add(new AgentContext__c (Customer__c=accountList[0].Id,AgentContextIdentifier__c='1C8UTE30~'+accountList[0].clientIdentifier__C));
        testAgentContext.add(new AgentContext__c (Customer__c=accountList[0].Id,AgentContextIdentifier__c='1C8UTE31~'+accountList[0].clientIdentifier__C));

        Profile agentProfile = [Select Id from Profile where name = '2.00 Agent'];
        agentUserList.add(buildtestUser('agent1@statefarm.com', agentProfile, '1A'));
        agentUserList.add(buildtestUser('agent2@statefarm.com', agentProfile, '2A'));

        insertAll.addAll((List<sObject>) agentUserList);
        insertAll.addAll((List<sObject>) agentRoleList);
        insertAll.addAll((List<sObject>) testAgentContext);
        System.runAs(sysAdminUser) {
            insert insertAll;
            delete testAgentContext;
        }
        System.runAs(testAPIUser) {
            Test.startTest();
            UTIL_CombineProcessor combineProcess=new UTIL_CombineProcessor();
            combineProcess.deletesObjectList(testAgentContext,'UTIL_CombineProcessor','handleMergeOperations');
            Test.stopTest();
        }

        //checking for AgentContext
        List<AgentContext__c> agContextList =[select id from AgentContext__c where Customer__c=:accountList[0].Id ];
        system.assert(agContextList.isEmpty(), 'List<AgentContext__c> is not empty');

        ExceptionLog__c results = [SELECT IsHandled__c,Class__c,Method__c,Exception_Message__c  FROM ExceptionLog__c
                                   where class__c like '%UTIL_CombineProcessor%' limit 1];
        System.assertEquals('UTIL_CombineProcessor' , results.Class__c, 'Expected parameter is not equals to the actual parameter');
        System.assertEquals('handleMergeOperations', results.Method__c, 'Expected parameter is not equals to the actual parameter');
        System.assertEquals(true, results.IsHandled__c, 'IsHandled__c is false');
        System.assertEquals(
            'Records already deleted: ' +
            testAgentContext.get(0).id +
            ',' +
            testAgentContext.get(1).id,
            results.Exception_Message__c, 'Expected exception message is not equals to the actual exception message'
        );
    }

	/*
    private static testMethod void combineProcessorWithAllDataByCustomerGroupingDisabled() {
        Map<UTIL_Toggles, boolean> toggleMap = new Map<UTIL_Toggles, boolean>();
        toggleMap.put(UTIL_Toggles.CUSTOMERGROUPINGS, false);
        toggleMap.put(UTIL_Toggles.TOGGLE_FSC, false);
        UTIL_CombineProcessor.toggleContext = UTIL_ToggleTestUtils.buildContext(toggleMap);
        fetchUsers();
        List<Account> accountList = new List<Account>();
        List<Account> accountListToBeUpdated = new List<Account>();
        List<Account_Note__c> accountNotesList = new List<Account_Note__c>();
        Account_Note__c losingAccountNote;
        Account_Note__c winningAccountNote;
       	ProductsServicedByMe__c losingAccountPSBM;
        ProductsServicedByMe__c winningAccountPSBM;

        accountList.add(createAccount(LOSING_CLIST));
        accountList.add(createAccount(WINNING_CLIST));
        accountList.add(createAccount(OTHER_CLIENT));
		psAssignment = assignPermissionSet(testAPIUser);
        System.runAs(sysAdminUser) {
            insert psAssignment;
            insert accountList;
        }
        losingAccount = [Select id, personcontactid from Account where ClientIdentifier__c = :LOSING_CLIST];
        winningAccount = [Select id, personcontactid from Account where ClientIdentifier__c = :WINNING_CLIST];

        insertChildObjects(accountList);
        System.runAs(sysAdminUser){
            losingAccount.Primary_Household__pc = household1.id;
            winningAccount.Primary_Household__pc = household2.id;
            losingAccountNote = new Account_Note__c(Alert__c=true,Account__C=losingAccount.id, Primary_Household__c=household1.id, Comments__c='losing comments');
            winningAccountNote = new Account_Note__c(Alert__c=true,Account__C=winningAccount.id, Primary_Household__c=household2.id, Comments__c='winning comments');
            losingAccountPSBM = new ProductsServicedByMe__c(customer__c=losingAccount.Id,ProductType__c='Disability Income', Primary_Household__c=household1.id,
                                                                    CarrierName__c='Trupanion',ProductLine__c='Health',Agent__c=salesRoleHierarchy1.Agent.id);
            winningAccountPSBM = new ProductsServicedByMe__c(customer__c=winningAccount.Id,ProductType__c='Motorcycle', Primary_Household__c=household2.id,
                                                                    CarrierName__c='Assigned Risk/JUA',ProductLine__c='Auto',Agent__c=salesRoleHierarchy1.Agent.id);
            List<ProductsServicedByMe__c> psbmList = new List<ProductsServicedByMe__c>();
            psbmList.add(losingAccountPSBM);
            psbmList.add(winningAccountPSBM);
            accountNotesList.add(losingAccountNote);
            accountNotesList.add(winningAccountNote);
            accountListToBeUpdated.add(losingAccount);
            accountListToBeUpdated.add(winningAccount);

            update accountListToBeUpdated;
            insert accountNotesList;
            insert psbmList;
        }

        System.runAs(testAPIUser) {
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = buildJSON(LOSING_CLIST, WINNING_CLIST,OTHER_CLIENT, 'SAA1A', String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')));
            stgorcList.add(testStageOrchestration);
            test.startTest();
            new UTIL_CombineProcessor().execute(stgorcList);
            test.stopTest();
        }

        //checking assignment of account messages to winner
        Account accountUpdateList = [Select id,FirstName, (Select id,Name from AccountMessage__r)
                                     from Account where ClientIdentifier__c  =: WINNING_CLIST];
        System.assertEquals(accountUpdateList.AccountMessage__r.size(),22);
        System.assertEquals([Select id from AgentRole__c].size(),2);
        System.assertEquals(accountUpdateList.FirstName, 'GIOVAN');
		assertChildObjects(accountList);

        System.assertNotEquals([SELECT Primary_Household__c FROM Account_Note__c where id =: losingAccountNote.id].Primary_Household__c, [SELECT Primary_Household__c FROM Account_Note__c where id =: winningAccountNote.id].Primary_Household__c, 'On Combine when FSC is toggled off Losing acconts Primary_Household__c should not be updated with winning accounts Primary_Household__c');

       	 //checking if PSBM are assigned to winner
        System.assertNotEquals([Select Id, Primary_Household__c from ProductsServicedByMe__c where id =: losingAccountPSBM.Id].Primary_Household__c, [Select Id, Primary_Household__c from ProductsServicedByMe__c where id =: winningAccountPSBM.Id].Primary_Household__c, 'On combine  when FSC is toggled off Losing Account PSBM Primary_Household__c should not be updated with Winning Account PSBM Primary_Household__c ');

       	System.assertEquals(1, [Select Id FROM AccountContactRelation where AccountId =: household2.Id].size(), 'on combine winning Accounts ACR record Should not be deleted');

        List<CustomerGroup__c> listofHouseholdGroup = [Select id from CustomerGroup__c Where SFGroupIdentifier__c IN ('HouseholdA1','HouseholdA2')];
        List<CustomerGroupMember__c> houseHoldGroupMemberList = [Select Id from CustomerGroupMember__c Where GroupMemberId__c IN ('HouseholdA1~BBB5S6J0W','HouseholdA2~BBB5S6J0W')];
        System.assert(listofHouseholdGroup.isEmpty());
        System.assert(houseHoldGroupMemberList.isEmpty());
    }
    */
    @isTest
    private static void testCombinewithNoChildData() {
        fetchUsers();
        List<Account> accountList = new List<Account>();
        List<User> agentUserList = new List<User>();

        accountList.add(createAccount('BBB5S6J0J'));
        accountList.add(createAccount('BBB5S6J0K'));
        accountList.add(createAccount('BBB5S6J0L'));
        accountList.add(createAccount('BBB5S6J0M'));
        accountList.add(createAccount(WINNING_CLIST));
        accountList.add(createAccount(OTHER_CLIENT));
        Profile agentProfile = [Select Id from Profile where name = '2.00 Agent'];
        agentUserList.add(buildtestUser('agent1@statefarm.com', agentProfile, '1A'));
        agentUserList.add(buildtestUser('agent2@statefarm.com', agentProfile, '2A'));
        psAssignment = assignPermissionSet(testAPIUser);
        System.runAs(sysAdminUser) {
            insert psAssignment;
            insert accountList;
            insert agentUserList;
        }
        System.runAs(testAPIUser) {
            test.startTest();
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            BuildJsonWrapperList testApiUserWrap = new BuildJsonWrapperList();
				testApiUserWrap.lclientId = 'BBB5S6J0J,BBB5S6J0K,BBB5S6J0L,BBB5S6J0M';
				testApiUserWrap.wcliendId = WINNING_CLIST;
				testApiUserWrap.otherid = OTHER_CLIENT;
				testApiUserWrap.assocId = 'SAA1A';
				testApiUserWrap.externalSyncTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
				testStageOrchestration.Value__c = buildJSON(testApiUserWrap);
            stgorcList.add(testStageOrchestration);
            new UTIL_CombineProcessor().execute(stgorcList);
            test.stopTest();
        }
        Account afterMergeChildRecords=[Select Name, Id, ClientIdentifier__c, (Select Id, Name From LeadConversionDetails__r),
                                        (Select Id, Name From Agent_Roles__r),
                                        (Select Id, Name From Opportunities),(Select Id, AccountOne__c From Relationships__r),
                                        (Select Id, Account__c, Status__c From AccountMessage__r Where Status__c!=null)
                                        From Account WHERE ClientIdentifier__c=: WINNING_CLIST];
        System.assertEquals(afterMergeChildRecords.AccountMessage__r.size(),0, 'Size of List<AccountMessage__c> is not equals to 0');
        System.assertEquals(afterMergeChildRecords.Agent_Roles__r.size(),2, 'Size of List<Agent_Roles__c> is not equals to 2');
        System.assertEquals(afterMergeChildRecords.Relationships__r.size(),1, 'Size of List<Relationships__c> is not equals to 1');
        System.assertEquals(afterMergeChildRecords.LeadConversionDetails__r.size(),0, 'Size of List<LeadConversionDetails__c> is not equals to 0');
        System.assertEquals(afterMergeChildRecords.Opportunities.size(),0, 'Size of List<Opportunity> is not equals to 0');
    }

    @isTest
    private static void testNoAccountUpdateByComparingTime() {
        fetchUsers();
        List<Account> accountList = new List<Account>();
        List<User> agentUserList = new List<User>();
        String externalSourceOldSyncTime = '2015-10-01T09:40:58.044+0000';
        accountList.add(createAccount(LOSING_CLIST));
        accountList.add(createAccount(WINNING_CLIST));
        accountList.add(createAccount(OTHER_CLIENT));
        Profile agentProfile = [Select Id from Profile where name = '2.00 Agent'];
        agentUserList.add(buildtestUser('agent1@statefarm.com', agentProfile, '1A'));
        agentUserList.add(buildtestUser('agent2@statefarm.com', agentProfile, '2A'));

        psAssignment = assignPermissionSet(testAPIUser);
        System.runAs(sysAdminUser) {
            insert psAssignment;
            insert accountList;
            insert agentUserList;
        }
        System.runAs(testAPIUser) {
            test.startTest();
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            BuildJsonWrapperList testApiUserNoAccountUpdateWrap = new BuildJsonWrapperList();
				testApiUserNoAccountUpdateWrap.lclientId = LOSING_CLIST;
				testApiUserNoAccountUpdateWrap.wcliendId = WINNING_CLIST;
				testApiUserNoAccountUpdateWrap.otherid = OTHER_CLIENT;
				testApiUserNoAccountUpdateWrap.assocId = 'SAA1A';
				testApiUserNoAccountUpdateWrap.externalSyncTime = externalSourceOldSyncTime;
			testStageOrchestration.Value__c = buildJSON(testApiUserNoAccountUpdateWrap);
            stgorcList.add(testStageOrchestration);
            new UTIL_CombineProcessor().execute(stgorcList);
            test.stopTest();
        }
        Account checkAccount = [Select id, FirstName from account where ClientIdentifier__c =: WINNING_CLIST];
        System.assertEquals('tst1', checkAccount.FirstName, 'Expected FirstName is not equals to the actual FirstName');
    }

    //This method is used to test if one othe clientID coming from json in not SFDC
    @isTest
    private static void losingAccountNotInSFDC() {
        fetchUsers();
        List<Account> accountList = new List<Account>();
        List<User> agentUserList = new List<User>();

        accountList.add(createAccount(WINNING_CLIST));
        accountList.add(createAccount(OTHER_CLIENT));
        Profile agentProfile = [Select Id from Profile where name = '2.00 Agent'];
        agentUserList.add(buildtestUser('agent1@statefarm.com', agentProfile, '1A'));
        agentUserList.add(buildtestUser('agent2@statefarm.com', agentProfile, '2A'));
        psAssignment = assignPermissionSet(testAPIUser);
        System.runAs(sysAdminUser) {
            insert psAssignment;
            insert accountList;
            insert agentUserList;
        }
        System.runAs(testAPIUser) {
            test.startTest();
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            BuildJsonWrapperList testApiUserLosingAccountWrap = new BuildJsonWrapperList();
				testApiUserLosingAccountWrap.lclientId = 'LIDNOTINSF';
				testApiUserLosingAccountWrap.wcliendId = WINNING_CLIST;
				testApiUserLosingAccountWrap.otherid = OTHER_CLIENT;
				testApiUserLosingAccountWrap.assocId = 'SAA1A';
				testApiUserLosingAccountWrap.externalSyncTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			testStageOrchestration.Value__c = buildJSON(testApiUserLosingAccountWrap);
            stgorcList.add(testStageOrchestration);
            new UTIL_CombineProcessor().execute(stgorcList);
            test.stopTest();
        }
        Account checkAccount = [Select id, FirstName, (Select Id, Name From Agent_Roles__r),(Select Id, AccountOne__c From Relationships__r)
                                from account where ClientIdentifier__c =: WINNING_CLIST];
        System.assertEquals('GIOVAN', checkAccount.FirstName, 'Expected FirstName is not equals to the actual FirstName');
        System.assertEquals(2, checkAccount.Agent_Roles__r.size(), 'Size of List<Agent_Roles__c> is not equals to 2');
        System.assertEquals(1, checkAccount.Relationships__r.size(), 'Size of List<Relationships__c> is not equals to 1');
    }

    //This method is used to test if one of the related clientID coming from json in not in SFDC
    @isTest
    private static void relatedAccountNotInSFDC() {
        fetchUsers();
        List<User> agentUserList = new List<User>();
        Account winningAccount = createAccount(WINNING_CLIST);
        Profile agentProfile = [SELECT Id FROM Profile WHERE name = '2.00 Agent'];
        agentUserList.add(buildtestUser('agent1@statefarm.com', agentProfile, '1A'));
        agentUserList.add(buildtestUser('agent2@statefarm.com', agentProfile, '2A'));

        psAssignment = assignPermissionSet(testAPIUser);
        System.runAs(sysAdminUser) {
            insert psAssignment;
            insert winningAccount;
            insert agentUserList;
        }
        System.runAs(testAPIUser) {
            test.startTest();
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            BuildJsonWrapperList testApiUserRelatedAccountWrap = new BuildJsonWrapperList();
				testApiUserRelatedAccountWrap.lclientId = 'LIDNOTINSF';
				testApiUserRelatedAccountWrap.wcliendId = WINNING_CLIST;
				testApiUserRelatedAccountWrap.otherid = OTHER_CLIENT;
				testApiUserRelatedAccountWrap.assocId = 'SAA1A';
				testApiUserRelatedAccountWrap.externalSyncTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			testStageOrchestration.Value__c = buildJSON(testApiUserRelatedAccountWrap);
            stgorcList.add(testStageOrchestration);
            try {
                new UTIL_CombineProcessor().execute(stgorcList);
                System.assert(false, 'Expected StageProcessorException');
            } catch (StageProcessorException ex) {
                System.assert(ex.getCause() instanceof DMLException, 'Cause of Exception is an instance of DMLException');
            }
            test.stopTest();
        }
    }

    //This method is used to test if one of the related clientID coming from json in not in SFDC
    @isTest
    private static void relatedAccountNotInSFDCMaxTries() {
        fetchUsers();
        List<User> agentUserList = new List<User>();
        Account winningAccount=createAccount(WINNING_CLIST);
        Profile agentProfile = [Select Id from Profile where name = '2.00 Agent'];
        agentUserList.add(buildtestUser('agent1@statefarm.com', agentProfile, '1A'));
        agentUserList.add(buildtestUser('agent2@statefarm.com', agentProfile, '2A'));
        psAssignment = assignPermissionSet(testAPIUser);
        System.runAs(sysAdminUser) {
            insert psAssignment;
            insert winningAccount;
            insert agentUserList;
        }
        System.runAs(testAPIUser) {
            test.startTest();
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.ReprocessCount__c=UTIL_StageOrchestrationConstants.MAX_REPROCESS_COUNT;
            BuildJsonWrapperList testApiUserRelatedAccountNotInSFDCWrap = new BuildJsonWrapperList();
				testApiUserRelatedAccountNotInSFDCWrap.lclientId = 'LIDNOTINSF';
				testApiUserRelatedAccountNotInSFDCWrap.wcliendId = WINNING_CLIST;
				testApiUserRelatedAccountNotInSFDCWrap.otherid = OTHER_CLIENT;
				testApiUserRelatedAccountNotInSFDCWrap.assocId = 'SAA1A';
				testApiUserRelatedAccountNotInSFDCWrap.externalSyncTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			testStageOrchestration.Value__c = buildJSON(testApiUserRelatedAccountNotInSFDCWrap);
            stgorcList.add(testStageOrchestration);
            try{
                new UTIL_CombineProcessor().execute(stgorcList);
                System.assert(true, 'Assertion returns false');
            }
            catch(StageProcessorException ex){
                System.assert(false,'Unexpected Exception occured');
            }
            test.stopTest();
        }
        ExceptionLog__c c2cInsertFailure=[SELECT Id, Class__c, Exception_Message__c, Exception_Type__c, Method__c, Severity__c FROM ExceptionLog__c where class__c='UTIL_RelationshipDAO'];
        System.assertEquals('insertC2CRelationshipsFailSafe', c2cInsertFailure.Method__c,'Unexpected Exception');
    }

    @isTest
    private static void winningAccountNotInSFDC() {
        fetchUsers();
        List<User> agentUserList = new List<User>();
        List<Account> accountList = new List<Account>();
        List<Opportunity> opportunityList = new List<Opportunity>();
        List<AccountMessage__c> accountMessageList = new List<AccountMessage__c>();
        List<Relationship__c> relationshipList = new List<Relationship__c>();
        List<sobject> insertAll = new List<sobject>();

        Profile agentProfile = [Select Id from Profile where name = '2.00 Agent'];
        agentUserList.add(buildtestUser('agent1@statefarm.com', agentProfile, '1A'));
        agentUserList.add(buildtestUser('agent2@statefarm.com', agentProfile, '2A'));

        accountList.add(createAccount(LOSING_CLIST));
        accountList.add(createAccount(OTHER_CLIENT));
		psAssignment = assignPermissionSet(testAPIUser);
        System.runAs(sysAdminUser) {
            insert psAssignment;
            insert accountList;
        }

        for(Integer i=0; i<=10; i++){
            accountMessageList.add(createAccountMessage('test'+i, accountList.get(0).Id,'Sent'));
            accountMessageList.add(createAccountMessage('testS'+i, accountList.get(0).Id,'Scheduled'));

            opportunityList.add(createOpportunity(accountList.get(0).Id, i));
        }
        relationshipList.add(createC2CRelationships(accountList[0].clientIdentifier__C, accountList[1].clientIdentifier__C,'Parent'));
        relationshipList.add(createC2CRelationships(accountList[1].clientIdentifier__C, accountList[0].clientIdentifier__C,'Son'));

        insertAll.addAll((List<sObject>) opportunityList);
        insertAll.addAll((List<sObject>) accountMessageList);
        insertAll.addAll((List<sObject>) relationshipList);
        insertAll.addAll((List<sObject>) agentUserList);
        System.runAs(sysAdminUser) {
            insert insertAll;
        }
        System.runAs(testAPIUser) {
            test.startTest();
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            BuildJsonWrapperList testApiUserWinningAccountWrap = new BuildJsonWrapperList();
				testApiUserWinningAccountWrap.lclientId = LOSING_CLIST;
				testApiUserWinningAccountWrap.wcliendId = 'WIDNOTINSF';
				testApiUserWinningAccountWrap.otherid = OTHER_CLIENT;
				testApiUserWinningAccountWrap.assocId = 'SAA1A';
				testApiUserWinningAccountWrap.externalSyncTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			testStageOrchestration.Value__c = buildJSON(testApiUserWinningAccountWrap);
            stgorcList.add(testStageOrchestration);
            new UTIL_CombineProcessor().execute(stgorcList);
            test.stopTest();
        }
        Account checkAccount = [Select id, LastName, (Select Id, Name From AccountMessage__r)
                                from account where ClientIdentifier__c = 'WIDNOTINSF'];
        System.assertEquals('Hkhk', checkAccount.LastName, 'Expected LastName is not equals to the actual LastName');
        System.assertEquals(checkAccount.AccountMessage__r.size(), 11, 'Size of List<AccountMessage__c> is not equals to 11');

        List<AgentRole__c> agentlist = [SELECT id, AgentRoleIdentifier__c, RelationshipNature__c FROM AgentRole__c];
        System.assertEquals(agentlist[0].AgentRoleIdentifier__c, 'SAA1A~' + 'WIDNOTINSF', 'Expected parameter is not equals to the actual parameter');
        System.assertEquals(agentlist.size(), 2, 'Size of List<AgentRole__c> is not equals to 2');

        System.assertEquals([Select id from account where ClientIdentifier__c = :LOSING_CLIST].size(),0, 'Size of List<Account> is not equals to 0');
        for(Opportunity checkOppty : [Select id,AccountId from Opportunity]){
            System.assertEquals(checkOppty.AccountId, checkAccount.Id, 'Expected Account Id is not equals to the actual Account Id');
        }

        //checking customer Relationships details list deleted for Loosing and Winning Master side
        List<Relationship__c> relationshipsList=[select AccountTwo__r.clientIdentifier__c,AccountOne__r.clientIdentifier__c,RelationshipType__c,RelationshipIdentifier__c
                                                 from Relationship__c where AccountTwo__C=:accountList OR AccountOne__C =:accountList];
        system.assertEquals('WIDNOTINSF', relationshipsList.get(0).AccountTwo__r.clientIdentifier__c, 'Expected parameter is not equals to the actual parameter');
        system.assertEquals(OTHER_CLIENT, relationshipsList.get(0).AccountOne__r.clientIdentifier__c, 'Expected parameter is not equals to the actual parameter');
        system.assertEquals('Father', relationshipsList.get(0).RelationshipType__c, 'RelationshipType is not Father');
        system.assertEquals('WIDNOTINSF' + '~' + OTHER_CLIENT, relationshipsList.get(0).RelationshipIdentifier__c, 'Expected parameter is not equals to the actual parameter');
        System.assertEquals(1, relationshipsList.size(), 'Size of List<Relationship__c> is not equals to 1');
    }

    @isTest
    private static void noAccountsInSFDC() {
        fetchUsers();
        List<User> agentUserList = new List<User>();
        Profile agentProfile = [SELECT Id FROM Profile WHERE name = '2.00 Agent'];
        agentUserList.add(buildtestUser('agent1@statefarm.com', agentProfile, '1A'));
        agentUserList.add(buildtestUser('agent2@statefarm.com', agentProfile, '2A'));
        Account relatedAccount = createAccount(OTHER_CLIENT);
        psAssignment = assignPermissionSet(testAPIUser);
        System.runAs(sysAdminUser) {
            insert psAssignment;
            insert agentUserList;
            insert relatedAccount;
        }
        System.runAs(testAPIUser) {
            test.startTest();
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            BuildJsonWrapperList testApiUserNoAccountsWrap = new BuildJsonWrapperList();
				testApiUserNoAccountsWrap.lclientId = 'LIDNOTINSF';
				testApiUserNoAccountsWrap.wcliendId = 'WIDNOTINSF';
				testApiUserNoAccountsWrap.otherid = OTHER_CLIENT;
				testApiUserNoAccountsWrap.assocId = 'SAA1A';
				testApiUserNoAccountsWrap.externalSyncTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			testStageOrchestration.Value__c = buildJSON(testApiUserNoAccountsWrap);
            stgorcList.add(testStageOrchestration);
            new UTIL_CombineProcessor().execute(stgorcList);
            test.stopTest();
        }
        System.assertEquals(1, [SELECT id FROM account WHERE clientidentifier__c = 'WIDNOTINSF'].size(), 'Size of List<Account> is not equals to 1');
    }

    //This method is used to test Null Pointer exception
    @isTest
    private static void catchNullPointerException() {
        fetchUsers();
        System.runAs(testAPIUser) {
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = null;
            stgorcList.add(testStageOrchestration);
            test.StartTest();
            try{
                new UTIL_CombineProcessor().execute(stgorcList);
            }
            catch(StageProcessorException ex){
                System.assert(ex.getCause() instanceof InvalidInputException, 'Cause of Exception is an instance of InvalidInputException');
            }
        }
    }

    @isTest
    private static void catchUserNotFoundException() {
        fetchUsers();
        List<Account> accountList = new List<Account>();
        List<User> agentUserList = new List<User>();

        accountList.add(createAccount(LOSING_CLIST));
        accountList.add(createAccount(WINNING_CLIST));
        accountList.add(createAccount(OTHER_CLIENT));
        Profile agentProfile = [Select Id from Profile where name = '2.00 Agent'];
        agentUserList.add(buildtestUser('agent1@statefarm.com', agentProfile, '1A'));
        agentUserList.add(buildtestUser('agent2@statefarm.com', agentProfile, '2A'));
        psAssignment = assignPermissionSet(testAPIUser);
        System.runAs(sysAdminUser) {
            insert psAssignment;
            insert accountList;
            insert agentUserList;
        }
        List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
        StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
        BuildJsonWrapperList testApiUserCatchUserNotFoundWrap = new BuildJsonWrapperList();
			testApiUserCatchUserNotFoundWrap.lclientId = LOSING_CLIST;
			testApiUserCatchUserNotFoundWrap.wcliendId = WINNING_CLIST;
			testApiUserCatchUserNotFoundWrap.otherid = OTHER_CLIENT;
			testApiUserCatchUserNotFoundWrap.assocId = 'SAA3A';
			testApiUserCatchUserNotFoundWrap.externalSyncTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
		testStageOrchestration.Value__c = buildJSON(testApiUserCatchUserNotFoundWrap);
        stgorcList.add(testStageOrchestration);
        System.runAs(testAPIUser) {
            test.startTest();
            try{
                new UTIL_CombineProcessor().execute(stgorcList);
                system.assert(false, 'Assertion returns true');
            }catch(exception ex){
                System.assert(ex.getCause() instanceof DataNotFoundException, 'Cause of Exception is an instance of DataNotFoundException');
                system.assert(ex.getMessage().contains(UTIL_StageOrchestrationConstants.INVALID_USER_NOT_FOUND), 'Exception message does not contain the String');
            }
            test.stopTest();
        }
    }

    /**
     *   @description <This method is used to create new account>
     *   @param clientIdentifier
     *   @return account record
     */

    public static Account createAccount(String clientIdentifier) {
        Account getAccount = new Account(
            FirstName = 'tst1',
            LastName = 'Ltst' + clientIdentifier,
            ClientIdentifier__c = clientIdentifier,
            ExternalSourceSyncTime__c = DateTime.newInstance(2016, 10, 1, 7, 30, 0)
        );
        return getAccount;
    }

    /**
     *   @description <This method is used to create new account>
     *   @param clientIdentifier
     *   @return account record
     */

    public static Account createOrgAccount(String clientIdentifier) {
        Map<String, ID> accountRecordTypeMap = new Map<String, ID>();
        Map<String, Schema.Recordtypeinfo> schemaRtMap = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();
        for (String s : schemaRtMap.keySet()) {
            accountRecordTypeMap.put(s, schemaRtMap.get(s).RecordTypeId);
        }
        Id accRecordtype = accountRecordTypeMap.get(UTIL_CreateCustomerConstants.ORGANIZATION_RECORD_TYPE_NAME);
        Account getAccount = new Account(
            LastName = 'Ltst' + clientIdentifier,
            ClientIdentifier__c = clientIdentifier,
            ExternalSourceSyncTime__c = DateTime.newInstance(2016, 10, 1, 7, 30, 0),
            RecordTypeId = accRecordtype
        );
        return getAccount;
    }

    /**
     *   @description <This method is used to create new account message>
     *   @param am_name
     *   @param accountId
     *   @param status
     *   @return account message record
     */

    public static AccountMessage__c createAccountMessage(String am_name, String accountId, String status) {
        AccountMessage__c accountMessage = new AccountMessage__c(
            Name = am_name,
            Account__c = accountId,
            Status__c = status
        );
        return accountMessage;
    }

    /**
     *   @description <This method is used to create a lead conversion record>
     *   @param l_name
     *   @param losingCustomer
     *   @return agent role
     */

    public static LeadConversionDetail__c createLeadConversion(String l_name, String losingCustomer) {
        LeadConversionDetail__c leadConversion = new LeadConversionDetail__c(
            Name = l_name,
            Customer__c = losingCustomer
        );
        return leadConversion;
    }

    /**
     *   @description <This method is used to create new agent role>
     *   @param ag_roleValue
     *   @param customerId
     *   @return agent role
     */
    public static AgentRole__c createAgentRole(String ag_roleValue, String customerId) {
        AgentRole__c agentRole = new AgentRole__c(
            RelationshipNature__c = 'Customer',
            AgentRoleIdentifier__c = ag_roleValue,
            Agent__c = userInfo.getUserId(),
            Customer__c = customerId
        );
        return agentRole;
    }

    /**
     * @description This method is used to create createC2CRelationships
     * @param customerId
     * @param relationshipWith
     * @param relationNature
     * @return testRelationship
     */
    public static Relationship__c createC2CRelationships(
        String customerId,
        String relationshipWith,
        string relationNature
    ) {
        Relationship__c testRelationship = new Relationship__c(
            AccountTwo__r = new account(ClientIdentifier__C = customerId),
            AccountOne__r = new account(ClientIdentifier__C = relationshipWith),
            RelationshipType__c = relationNature,
            RelationshipIdentifier__c = customerId + '~' + relationshipWith
        );
        return testRelationship;
    }

    /**
     * @description This method is used to create tasks
     * @param customerId
     * @param i
     * @return testTask
     */
    public static Task createTask(String customerId, Integer i) {
        Task testTask = new Task(
            WhatId = customerId,
            subject = 'Call',
            Priority = 'No',
            ActivityDate = Date.today() + i,
            Description = 'TASK111',
            Status = 'Not Started',
            TaskCategory__c = 'Alert',
            OwnerId = agentUser.Id
        );
        return testTask;
    }

    /**
     * @description This method is used to create Opportunities
     * @param customerId
     * @param i
     * @return newOpportunity
     */
    public static Opportunity createOpportunity(String customerId, Integer i) {
        Opportunity newOpportunity = new Opportunity(
            Name = 'testOppty' + i,
            AccountId = customerId,
            Type = 'ABC',
            StageName = 'Needs Analysis',
            LOB__c = 'Auto',
            ForecastCategoryName = 'Pipeline',
            CloseDate = Date.today() + i
        );
        return newOpportunity;
    }

    /**
     *   @description <This method is used to create a System Admin User>
     */

    public static void buildSystemAdmin() {
        sysAdminUser = new User(
            alias = 'sys1',
            email = 'remCmpMemSysAd@statefarm.com',
            emailencodingkey = 'UTF-8',
            lastname = 'Sys User',
            languagelocalekey = 'en_US',
            localesidkey = 'en_US',
            timezonesidkey = 'Europe/London',
            username = 'remCmpMemSysAd@statefarm.com'
        );
        sysAdminUser.ProfileId = [SELECT Id FROM Profile WHERE name = :UTIL_Constants.SYSTEM_ADMIN_PROFILE_NAME LIMIT 1]
        .Id;
    }

    /**
     *   @description <This method is used to combine assigned staff for [WC-> AG1-AS1 LC-> AG1-AS1 == CC -> AG1 - AS1], WC & LC Both in SFDC>
     */
     @isTest
    private static void combineProcessorSameAgentStaff() {
        fetchUsers();
        List<Account> accountList = new List<Account>();
        accountList.add(createAccount(LOSING_CLIST));
        accountList.add(createAccount(WINNING_CLIST));
        accountList.add(createAccount(OTHER_CLIENT));
        insert accountList;

        TestData_SalesRoleHierarchy salesRoleHierarchy0 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('S');
        AssignedStaff__c newAssignedStaff0= new AssignedStaff__c(Agent__c=salesRoleHierarchy0.Agent.Id, AssignedStaffIdentifier__c =accountList[0].clientIdentifier__c+'~'+salesRoleHierarchy0.Agent.Associate_ID__c+'~'+salesRoleHierarchy0.AgentTeamMember.Associate_Id__c,Customer__c=accountList[0].Id,Staff__c=salesRoleHierarchy0.AgentTeamMember.Id);
        AssignedStaff__c newAssignedStaff1= new AssignedStaff__c(Agent__c=salesRoleHierarchy0.Agent.Id, AssignedStaffIdentifier__c =accountList[1].clientIdentifier__c+'~'+salesRoleHierarchy0.Agent.Associate_ID__c+'~'+salesRoleHierarchy0.AgentTeamMember.Associate_Id__c,Customer__c=accountList[1].Id,Staff__c=salesRoleHierarchy0.AgentTeamMember.Id);

        Profile agentProfile = [Select Id from Profile where name = '2.00 Agent'];
        insert buildtestUser('agent2@statefarm.com', agentProfile, '2A');
        psAssignment = assignPermissionSet(testAPIUser);
        Test.startTest();
        System.runAs(sysAdminUser) {
            insert psAssignment;
            insert newAssignedStaff0;
            insert newAssignedStaff1;
        }
        System.runAs(testAPIUser) {
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            BuildJsonWrapperList testApiUserCombineProcessorWrap = new BuildJsonWrapperList();
				testApiUserCombineProcessorWrap.lclientId = LOSING_CLIST;
				testApiUserCombineProcessorWrap.wcliendId = WINNING_CLIST;
				testApiUserCombineProcessorWrap.otherid = OTHER_CLIENT;
				testApiUserCombineProcessorWrap.assocId = salesRoleHierarchy0.Agent.Associate_Id__c;
				testApiUserCombineProcessorWrap.externalSyncTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			testStageOrchestration.Value__c = buildJSON(testApiUserCombineProcessorWrap);
            stgorcList.add(testStageOrchestration);
            new UTIL_CombineProcessor().execute(stgorcList);
        }

        //checking assignment of Assigned Staff to winner
        List<AssignedStaff__c> winningAssignedStaff = [Select id,name,ownerId,Customer__r.clientIdentifier__c, assignedstaffidentifier__c from AssignedStaff__c];
        System.assertEquals(newAssignedStaff1.id,winningAssignedStaff[0].id, 'Expected AssignedStaff__c Id is not equals to the actual AssignedStaff__c Id');
        System.assertEquals(WINNING_CLIST,winningAssignedStaff[0].Customer__r.clientIdentifier__c, 'Expected parameter is not equals to the actual parameter');
        System.assert(winningAssignedStaff[0].assignedstaffidentifier__c.contains(WINNING_CLIST), 'String does not contain the given parameter');
        System.assertEquals(winningAssignedStaff.size(), 1, 'Size of List<AssignedStaff__c> is not equals to 1');
        test.stopTest();
    }

    /**
     *   @description <This method is used to combine assigned staff for [WC-> AG1-AS1 LC-> AG1-AS2 == CC-> AG1 - AS1,AS2], WC & LC Both in SFDC>
     */
    @isTest
    private static void combineProcessorDifferentAgentStaff() {
        fetchUsers();
        CS_DeleteRecordConfig__c deleteConfig = new CS_DeleteRecordConfig__c(
            Name = 'TestConfig',
            ProfileName__c = apiProfile.name,
            SobjectType__c = 'Account',
            Allowdelete__c = true
        );
        insert deleteConfig;
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(
            testAPIUser
        );
        objectBasedByPassTrigger.Override_AgentRoleAfterInsert__c = true;
        insert objectBasedByPassTrigger;
        CS001_ByPassTriggerAll__c byPassTrigger = [Select id, OverRide_ALL__c, SetupOwner.Name, SetUpOwnerId from CS001_ByPassTriggerAll__c LIMIT 1];
        byPassTrigger.Override_All__c = false;
        update byPassTrigger;
        AssignedStaff__c newAssignedStaff0;
        AssignedStaff__c newAssignedStaff1;
        List<Account> accountList = new List<Account>();
        accountList.add(createAccount(LOSING_CLIST));
        accountList.add(createAccount(WINNING_CLIST));
        accountList.add(createAccount(OTHER_CLIENT));
        insert accountList;
        psAssignment = assignPermissionSet(testAPIUser);
        System.runAs(sysAdminUser) {
            insert psAssignment;
            salesRoleHierarchy0 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('S');
            salesRoleHierarchy1.agent.associate_id__c = 'SAA2A';
            salesRoleHierarchy1.agent.userexternalId__c = 'SAA2A_SAA2A';
            salesRoleHierarchy1.agentOffice.userexternalId__c = 'SAA2AP';
            salesRoleHierarchy1.agent.Servicing_Agent_Associate_ID__c = 'SAA2A';
            update salesRoleHierarchy1.agent;
            update salesRoleHierarchy1.agentOffice;
            User agentTeamMember1 = TestDataFactory_User_Wrapper.generateAgentTeamMemberUser('ATM2', '222222223S');
            agentTeamMember1.UserRoleId = salesRoleHierarchy0.AgentTeamMember.UserRoleId;
            agentTeamMember1.Servicing_Agent_Associate_ID__c = salesRoleHierarchy0.Agent.Associate_Id__c;
            agentTeamMember1.Servicing_Agent_Associate_ID_List__c = salesRoleHierarchy0.Agent.Associate_Id__c;
            insert agentTeamMember1;

            List<AgentRole__c> newAgentRole = new List<AgentRole__c>();
        newAgentRole.add(new AgentRole__c(Agent__c = salesRoleHierarchy0.Agent.id, Customer__c = accountList[0].id, relationshipNature__c = 'Prospect'));
        newAgentRole.add(new AgentRole__c(Agent__c = salesRoleHierarchy0.Agent.id, Customer__c = accountList[1].id, relationshipNature__c = 'Prospect'));
            insert newAgentRole;

        newAssignedStaff0= new AssignedStaff__c(Agent__c=salesRoleHierarchy0.Agent.Id, AssignedStaffIdentifier__c =accountList[0].clientIdentifier__c+'~'+salesRoleHierarchy0.Agent.Associate_ID__c+'~'+salesRoleHierarchy0.AgentTeamMember.Associate_Id__c,Customer__c=accountList[0].Id,Staff__c=salesRoleHierarchy0.AgentTeamMember.Id);
        newAssignedStaff1= new AssignedStaff__c(Agent__c=salesRoleHierarchy0.Agent.Id, AssignedStaffIdentifier__c =accountList[1].clientIdentifier__c+'~'+salesRoleHierarchy0.Agent.Associate_ID__c+'~'+agentTeamMember1.Associate_Id__c,Customer__c=accountList[1].Id,Staff__c=agentTeamMember1.Id);

            insert newAssignedStaff0;
            insert newAssignedStaff1;
        }
        Test.startTest();
        System.runAs(testAPIUser) {
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            BuildJsonWrapperList testApiUserCombineProcessorDifferentAgentWrap = new BuildJsonWrapperList();
				testApiUserCombineProcessorDifferentAgentWrap.lclientId = LOSING_CLIST;
				testApiUserCombineProcessorDifferentAgentWrap.wcliendId = WINNING_CLIST;
				testApiUserCombineProcessorDifferentAgentWrap.otherid = OTHER_CLIENT;
				testApiUserCombineProcessorDifferentAgentWrap.assocId = salesRoleHierarchy0.Agent.Associate_Id__c;
				testApiUserCombineProcessorDifferentAgentWrap.externalSyncTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			testStageOrchestration.Value__c = buildJSON(testApiUserCombineProcessorDifferentAgentWrap);
            stgorcList.add(testStageOrchestration);
            new UTIL_CombineProcessor().execute(stgorcList);
        }

        List<AssignedStaff__c> actualAssignedStaffList = [Select id,name,ownerId,Customer__r.clientIdentifier__c, assignedstaffidentifier__c from AssignedStaff__c];
        System.assertEquals(actualAssignedStaffList.size(), 2, 'Size of List<AssignedStaff__c> is not equals to 2');
        for (AssignedStaff__c newStaff : actualAssignedStaffList) {
            System.assertEquals(WINNING_CLIST, newStaff.Customer__r.clientidentifier__c, 'Expected parameter is not equals to the actual parameter');
            System.assert(newStaff.assignedstaffidentifier__c.contains(WINNING_CLIST), 'String does not contain the parameter');
        }
        test.stopTest();
    }

    /**
     *   @description <This method is used to test for combine assigned staff for failed update to Assigned Staff scenario>
     */
    @isTest
    private static void combineProcessorAssignedStaffUpdateFailed() {
        CS_DeleteRecordConfig__c deleteConfig = new CS_DeleteRecordConfig__c(
            Name = 'TestConfig',
            ProfileName__c = apiProfile.name,
            SobjectType__c = 'Account',
            Allowdelete__c = true
        );
        insert deleteConfig;

        fetchUsers();

        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(
            testAPIUser
        );
        objectBasedByPassTrigger.Override_AgentRoleAfterInsert__c = true;
        insert objectBasedByPassTrigger;

        CS001_ByPassTriggerAll__c bypass = [Select Id,SetupOwnerId from
        CS001_ByPassTriggerAll__c where Override_All__c = true];
        bypass.SetupOwnerId = sysAdminUser.Id;
        update bypass;

        AssignedStaff__c newAssignedStaff0;
        AssignedStaff__c newAssignedStaff1;
        List<Account> accountList = new List<Account>();
        accountList.add(createAccount(LOSING_CLIST));
        accountList.add(createAccount(WINNING_CLIST));
        accountList.add(createAccount(OTHER_CLIENT));
        insert accountList;
         psAssignment = assignPermissionSet(testAPIUser);
        System.runAs(sysAdminUser) {
            insert psAssignment;
            salesRoleHierarchy0 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('S');
            salesRoleHierarchy1.agent.associate_id__c = 'SAA2A';
            salesRoleHierarchy1.agent.userexternalId__c = 'SAA2A_SAA2A';
            salesRoleHierarchy1.agentOffice.userexternalId__c = 'SAA2AP';
            salesRoleHierarchy1.agent.Servicing_Agent_Associate_ID__c = 'SAA2A';
            update salesRoleHierarchy1.agent;
            update salesRoleHierarchy1.agentOffice;
            User agentTeamMember1 = TestDataFactory_User_Wrapper.generateAgentTeamMemberUser('ATM2', '222222223S');
            agentTeamMember1.UserRoleId = salesRoleHierarchy0.AgentTeamMember.UserRoleId;
            agentTeamMember1.Servicing_Agent_Associate_ID__c = salesRoleHierarchy0.Agent.Associate_Id__c;
            agentTeamMember1.Servicing_Agent_Associate_ID_List__c = salesRoleHierarchy0.Agent.Associate_Id__c;
            insert agentTeamMember1;

            List<AgentRole__c> newAgentRole = new List<AgentRole__c>();
            newAgentRole.add(new AgentRole__c(Agent__c = salesRoleHierarchy0.Agent.id, Customer__c = accountList[0].id, relationshipNature__c = 'Prospect'));
            newAgentRole.add(new AgentRole__c(Agent__c = salesRoleHierarchy0.Agent.id, Customer__c = accountList[1].id, relationshipNature__c = 'Prospect'));
            insert newAgentRole;

            newAssignedStaff0= new AssignedStaff__c(Agent__c=salesRoleHierarchy0.Agent.Id, AssignedStaffIdentifier__c =accountList[1].clientIdentifier__c+'~'+salesRoleHierarchy0.Agent.Associate_ID__c+'~'+salesRoleHierarchy0.AgentTeamMember.Associate_Id__c,Customer__c=accountList[1].Id,Staff__c=salesRoleHierarchy0.AgentTeamMember.Id);
            newAssignedStaff1= new AssignedStaff__c(Agent__c=salesRoleHierarchy0.Agent.Id, AssignedStaffIdentifier__c =accountList[0].clientIdentifier__c+'~'+salesRoleHierarchy0.Agent.Associate_ID__c+'~'+agentTeamMember1.Associate_Id__c,Customer__c=accountList[0].Id,Staff__c=agentTeamMember1.Id);

            insert newAssignedStaff0;
            insert newAssignedStaff1;

            agentTeamMember1.UserRoleId = null;
            agentTeamMember1.Servicing_Agent_Associate_ID__c = null;
            agentTeamMember1.Servicing_Agent_Associate_ID_List__c = null;
            update agentTeamMember1;
        }
        Test.startTest();
        System.runAs(testAPIUser) {
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            BuildJsonWrapperList testApiUserCombineProcessorAssignedStaffWrap = new BuildJsonWrapperList();
				testApiUserCombineProcessorAssignedStaffWrap.lclientId = LOSING_CLIST;
				testApiUserCombineProcessorAssignedStaffWrap.wcliendId = WINNING_CLIST;
				testApiUserCombineProcessorAssignedStaffWrap.otherid = OTHER_CLIENT;
				testApiUserCombineProcessorAssignedStaffWrap.assocId = salesRoleHierarchy0.Agent.Associate_Id__c;
				testApiUserCombineProcessorAssignedStaffWrap.externalSyncTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			testStageOrchestration.Value__c = buildJSON(testApiUserCombineProcessorAssignedStaffWrap);
            stgorcList.add(testStageOrchestration);
            new UTIL_CombineProcessor().execute(stgorcList);
        }

        List<AssignedStaff__c> actualAssignedStaffList = [Select id,name,ownerId,Customer__r.clientIdentifier__c, assignedstaffidentifier__c from AssignedStaff__c];
        System.assertEquals(actualAssignedStaffList.size(), 1, 'Size of List<AssignedStaff__c> is not equals to 1');
        for (AssignedStaff__c newStaff : actualAssignedStaffList) {
            System.assertEquals(WINNING_CLIST, newStaff.Customer__r.clientidentifier__c, 'Expected parameter is not equals to the actual parameter');
            System.assert(newStaff.assignedstaffidentifier__c.contains(WINNING_CLIST), 'String does not contain the parameter');
        }
        test.stopTest();
    }

    /**
     *   @description <This method is used to combine assigned staff for [WC -> AG1-AS1, AG1-AS2 , LC-> AG1-AS1,AG1-AS3 == CC-> AG1-AS1,AS2,AS3], WC & LC Both in SFDC>
     */
    @isTest
    private static void combineProcessorCommonAndDifferentAssignedStaff() {
        fetchUsers();
        List<Account> accountList = new List<Account>();
        accountList.add(createAccount(LOSING_CLIST));
        accountList.add(createAccount(WINNING_CLIST));
        accountList.add(createAccount(OTHER_CLIENT));
        insert accountList;
        AssignedStaff__c newAssignedStaff0;
        AssignedStaff__c newAssignedStaff1;
        AssignedStaff__c newAssignedStaff2;
        AssignedStaff__c newAssignedStaff3;
        psAssignment = assignPermissionSet(testAPIUser);
        System.runAs(sysAdminUser) {
            insert psAssignment;
            salesRoleHierarchy0 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('S');

            User agentTeamMember1 = TestDataFactory_User_Wrapper.generateAgentTeamMemberUser('ATM2', '222222223S');
            agentTeamMember1.UserRoleId = salesRoleHierarchy0.AgentTeamMember.UserRoleId;
            agentTeamMember1.Servicing_Agent_Associate_ID__c = salesRoleHierarchy0.Agent.Associate_Id__c;
            agentTeamMember1.Servicing_Agent_Associate_ID_List__c = salesRoleHierarchy0.Agent.Associate_Id__c;
            insert agentTeamMember1;

            User agentTeamMember2 = TestDataFactory_User_Wrapper.generateAgentTeamMemberUser('ATM3', '222222224S');
            agentTeamMember2.UserRoleId = salesRoleHierarchy0.AgentTeamMember.UserRoleId;
            agentTeamMember2.Servicing_Agent_Associate_ID__c = salesRoleHierarchy0.Agent.Associate_Id__c;
            agentTeamMember2.Servicing_Agent_Associate_ID_List__c = salesRoleHierarchy0.Agent.Associate_Id__c;
            insert agentTeamMember2;

            newAssignedStaff0= new AssignedStaff__c(Agent__c=salesRoleHierarchy0.Agent.Id, AssignedStaffIdentifier__c =accountList[0].clientIdentifier__c+'~'+salesRoleHierarchy0.Agent.Associate_ID__c+'~'+salesRoleHierarchy0.AgentTeamMember.Associate_Id__c,Customer__c=accountList[0].Id,Staff__c=salesRoleHierarchy0.AgentTeamMember.Id);
            newAssignedStaff1= new AssignedStaff__c(Agent__c=salesRoleHierarchy0.Agent.Id, AssignedStaffIdentifier__c =accountList[0].clientIdentifier__c+'~'+salesRoleHierarchy0.Agent.Associate_ID__c+'~'+agentTeamMember1.Associate_Id__c,Customer__c=accountList[0].Id,Staff__c=agentTeamMember1.Id);

            newAssignedStaff2= new AssignedStaff__c(Agent__c=salesRoleHierarchy0.Agent.Id, AssignedStaffIdentifier__c =accountList[1].clientIdentifier__c+'~'+salesRoleHierarchy0.Agent.Associate_ID__c+'~'+salesRoleHierarchy0.AgentTeamMember.Associate_Id__c,Customer__c=accountList[1].Id,Staff__c=salesRoleHierarchy0.AgentTeamMember.Id);
            newAssignedStaff3= new AssignedStaff__c(Agent__c=salesRoleHierarchy0.Agent.Id, AssignedStaffIdentifier__c =accountList[1].clientIdentifier__c+'~'+salesRoleHierarchy0.Agent.Associate_ID__c+'~'+agentTeamMember2.Associate_Id__c,Customer__c=accountList[1].Id,Staff__c=agentTeamMember2.Id);

        Profile agentProfile = [Select Id from Profile where name = '2.00 Agent'];
            insert buildtestUser('agent2@statefarm.com', agentProfile, '2A');
            Test.startTest();

            insert newAssignedStaff0;
            insert newAssignedStaff1;
            insert newAssignedStaff2;
            insert newAssignedStaff3;
        }
        System.runAs(testAPIUser) {
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            BuildJsonWrapperList testApiUserCombineProcessorCommonAndDifferentAssignedWrap = new BuildJsonWrapperList();
				testApiUserCombineProcessorCommonAndDifferentAssignedWrap.lclientId = LOSING_CLIST;
				testApiUserCombineProcessorCommonAndDifferentAssignedWrap.wcliendId = WINNING_CLIST;
				testApiUserCombineProcessorCommonAndDifferentAssignedWrap.otherid = OTHER_CLIENT;
				testApiUserCombineProcessorCommonAndDifferentAssignedWrap.assocId = salesRoleHierarchy0.Agent.Associate_Id__c;
				testApiUserCombineProcessorCommonAndDifferentAssignedWrap.externalSyncTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			testStageOrchestration.Value__c = buildJSON(testApiUserCombineProcessorCommonAndDifferentAssignedWrap);
            stgorcList.add(testStageOrchestration);
            new UTIL_CombineProcessor().execute(stgorcList);
        }

         List<AssignedStaff__c> actualAssignedStaffList = [Select id,name,ownerId,Customer__r.clientIdentifier__c from AssignedStaff__c];
        System.assertEquals(3, actualAssignedStaffList.size(), 'Size of List<AssignedStaff__c> is not equals to 3');
         for(AssignedStaff__c assignStaff: actualAssignedStaffList){
            if((newAssignedStaff1.id).equals(assignStaff.id)){
                System.assertEquals(WINNING_CLIST,assignStaff.Customer__r.clientIdentifier__c, 'Expected parameter is not equals to the actual parameter');
            }
            else if((newAssignedStaff2.id).equals(assignStaff.id)){
                System.assertEquals(WINNING_CLIST,assignStaff.Customer__r.clientIdentifier__c, 'Expected parameter is not equals to the actual parameter');
            }
            else {
                System.assertEquals(newAssignedStaff3.id,assignStaff.id, 'Expected Id is not equals to the actual Id');
                System.assertEquals(WINNING_CLIST,assignStaff.Customer__r.clientIdentifier__c, 'Expected parameter is not equals to the actual parameter');
            }
        }
        test.stopTest();
    }

    /**
     *   @description <This method is used to combine assigned staff for [WC -> AG1-AS1,AG2-AS2 , LC-> AG2-AS2, AG3-AS3 == CC->AG1-AS1,AG2-AS2], WC & LC Both in SFDC>
     */
    @isTest
    private static void combineProcessorCommonAndDifferentAgentStaff1() {
        fetchUsers();
        List<Account> accountList = new List<Account>();
        accountList.add(createAccount(LOSING_CLIST));
        accountList.add(createAccount(WINNING_CLIST));
        accountList.add(createAccount(OTHER_CLIENT));
        insert accountList;
        AssignedStaff__c newAssignedStaff0;
        AssignedStaff__c newAssignedStaff1;
        AssignedStaff__c newAssignedStaff2;
        AssignedStaff__c newAssignedStaff3;
        psAssignment = assignPermissionSet(testAPIUser);
        System.runAs(sysAdminUser) {
            insert psAssignment;
            salesRoleHierarchy0 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('S');
            Profile agentProfile = [SELECT Id FROM Profile WHERE name = '2.00 Agent'];
            User testUser = buildtestUser('agent2@statefarm.com', agentProfile, '2A');
            salesRoleHierarchy1.Agent.Associate_Id__c = testUser.UserExternalID__c;
            salesRoleHierarchy1.Agent.UserExternalId__c = testUser.UserExternalID__c;
            salesRoleHierarchy1.Agent.Servicing_Agent_Associate_ID_List__c = testUser.UserExternalID__c;
            salesRoleHierarchy1.Agent.Servicing_Agent_Associate_ID__c = testUser.UserExternalID__c;
            update salesRoleHierarchy1.Agent;

            newAssignedStaff0= new AssignedStaff__c(Agent__c=salesRoleHierarchy0.Agent.Id, AssignedStaffIdentifier__c =accountList[0].clientIdentifier__c+'~'+salesRoleHierarchy0.Agent.Associate_ID__c+'~'+salesRoleHierarchy0.AgentTeamMember.Associate_Id__c,Customer__c=accountList[0].Id,Staff__c=salesRoleHierarchy0.AgentTeamMember.Id);
            newAssignedStaff1= new AssignedStaff__c(Agent__c=salesRoleHierarchy1.Agent.Id, AssignedStaffIdentifier__c =accountList[0].clientIdentifier__c+'~'+salesRoleHierarchy1.Agent.Associate_ID__c+'~'+salesRoleHierarchy1.AgentTeamMember.Associate_Id__c,Customer__c=accountList[0].Id,Staff__c=salesRoleHierarchy1.AgentTeamMember.Id);

            newAssignedStaff2= new AssignedStaff__c(Agent__c=salesRoleHierarchy2.Agent.Id, AssignedStaffIdentifier__c =accountList[1].clientIdentifier__c+'~'+salesRoleHierarchy2.Agent.Associate_ID__c+'~'+salesRoleHierarchy2.AgentTeamMember.Associate_Id__c,Customer__c=accountList[1].Id,Staff__c=salesRoleHierarchy2.AgentTeamMember.Id);
            newAssignedStaff3= new AssignedStaff__c(Agent__c=salesRoleHierarchy1.Agent.Id, AssignedStaffIdentifier__c =accountList[1].clientIdentifier__c+'~'+salesRoleHierarchy1.Agent.Associate_ID__c+'~'+salesRoleHierarchy1.AgentTeamMember.Associate_Id__c,Customer__c=accountList[1].Id,Staff__c=salesRoleHierarchy1.AgentTeamMember.Id);

            Test.startTest();
            insert newAssignedStaff0;
            insert newAssignedStaff1;
            insert newAssignedStaff2;
            insert newAssignedStaff3;
        }
        System.runAs(testAPIUser) {
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            BuildJsonWrapperList testApiUserCombineProcessorCommonAndDifferentAgentWrap = new BuildJsonWrapperList();
				testApiUserCombineProcessorCommonAndDifferentAgentWrap.lclientId = LOSING_CLIST;
				testApiUserCombineProcessorCommonAndDifferentAgentWrap.wcliendId = WINNING_CLIST;
				testApiUserCombineProcessorCommonAndDifferentAgentWrap.otherid = OTHER_CLIENT;
				testApiUserCombineProcessorCommonAndDifferentAgentWrap.assocId = salesRoleHierarchy2.Agent.Associate_Id__c;
				testApiUserCombineProcessorCommonAndDifferentAgentWrap.externalSyncTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			testStageOrchestration.Value__c = buildJSON(testApiUserCombineProcessorCommonAndDifferentAgentWrap);
            stgorcList.add(testStageOrchestration);
            new UTIL_CombineProcessor().execute(stgorcList);
        }

        List<AssignedStaff__c> actualAssignedStaffList = [Select id,name,ownerId,Customer__r.clientIdentifier__c, assignedstaffidentifier__c from AssignedStaff__c];
        System.assertEquals(actualAssignedStaffList.size(),2, 'Size of List<AssignedStaff__c> is not equals to 2');
        for(AssignedStaff__c assignStaff: actualAssignedStaffList){
            if(assignStaff.Id == newAssignedStaff2.id){
                system.assertEquals(WINNING_CLIST, assignStaff.Customer__r.clientIdentifier__c, 'Expected parameter is not equals to the actual parameter');
            } else {
                system.assertEquals(newAssignedStaff3.Id, assignStaff.Id, 'Expected Id is not equals to the actual Id');
                system.assertEquals(WINNING_CLIST, assignStaff.Customer__r.clientIdentifier__c, 'Expected parameter is not equals to the actual parameter');
            }
        }
        test.stopTest();
    }

    /**
     *   @description <This method is used to combine assigned staff for [WC -> AG1, LC -> AG1-AS1 == CC-> AG1-AS1], WC Not in SFDC, LC in SFDC>
     */
    @isTest
    private static void combineProcessorWCNotInSFDC() {
        fetchUsers();
        List<Account> accountList = new List<Account>();
        accountList.add(createAccount(LOSING_CLIST));
        accountList.add(createAccount(OTHER_CLIENT));

        insert accountList;

        TestData_SalesRoleHierarchy salesRoleHierarchy0 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('S');
        AssignedStaff__c newAssignedStaff0= new AssignedStaff__c(Agent__c=salesRoleHierarchy0.Agent.Id, AssignedStaffIdentifier__c =accountList[0].clientIdentifier__c+'~'+salesRoleHierarchy0.Agent.Associate_ID__c+'~'+salesRoleHierarchy0.AgentTeamMember.Associate_Id__c,Customer__c=accountList[0].Id,Staff__c=salesRoleHierarchy0.AgentTeamMember.Id);

        Profile agentProfile = [Select Id from Profile where name = '2.00 Agent'];
        insert buildtestUser('agent2@statefarm.com', agentProfile, '2A');
        Test.startTest();
        psAssignment = assignPermissionSet(testAPIUser);
        System.runAs(sysAdminUser) {
            insert psAssignment;
            insert newAssignedStaff0;
        }
        System.runAs(testAPIUser) {
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            BuildJsonWrapperList testApiUserCombineProcessorWCWrap = new BuildJsonWrapperList();
				testApiUserCombineProcessorWCWrap.lclientId = LOSING_CLIST;
				testApiUserCombineProcessorWCWrap.wcliendId = 'WIDNOTINSF';
				testApiUserCombineProcessorWCWrap.otherid = OTHER_CLIENT;
				testApiUserCombineProcessorWCWrap.assocId = salesRoleHierarchy0.Agent.Associate_Id__c;
				testApiUserCombineProcessorWCWrap.externalSyncTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			testStageOrchestration.Value__c = buildJSON(testApiUserCombineProcessorWCWrap);
            stgorcList.add(testStageOrchestration);
            new UTIL_CombineProcessor().execute(stgorcList);
        }

        List<AssignedStaff__c> actualAssignedStaffList = [Select id,name,ownerId,Customer__r.clientIdentifier__c from AssignedStaff__c];
        System.assertEquals(actualAssignedStaffList.size(), 1, 'Size of List<AssignedStaff__c> is not equals to 1');
        System.assertEquals('WIDNOTINSF', actualAssignedStaffList[0].Customer__r.clientIdentifier__c, 'Expected parameter is not equals to the actual parameter');
        Test.stopTest();
    }

    /**
     *   @description <This method is used to combine assigned staff for [WC->AG1,LC-> AG1-AS1,AG2-AS2 == CC->AG1-AS1], WC Not in SFDC, LC in SFDC>
     */
    @isTest
    private static void combineProcessorWCNotInSFDCExtraAssignedStaff() {
        fetchUsers();
        List<Account> accountList = new List<Account>();
        accountList.add(createAccount(LOSING_CLIST));
        accountList.add(createAccount(OTHER_CLIENT));
        insert accountList;
        psAssignment = assignPermissionSet(testAPIUser);
        System.runAs(sysAdminUser) {
            insert psAssignment;
            salesRoleHierarchy0 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('S');
            User agentTeamMember1 = TestDataFactory_User_Wrapper.generateAgentTeamMemberUser('ATM2', '222222223S');
            agentTeamMember1.UserRoleId = salesRoleHierarchy0.AgentTeamMember.UserRoleId;
            agentTeamMember1.Servicing_Agent_Associate_ID__c = salesRoleHierarchy0.Agent.Associate_Id__c;
            agentTeamMember1.Servicing_Agent_Associate_ID_List__c = salesRoleHierarchy0.Agent.Associate_Id__c;
            insert agentTeamMember1;

            AssignedStaff__c newAssignedStaff0= new AssignedStaff__c(Agent__c=salesRoleHierarchy0.Agent.Id, AssignedStaffIdentifier__c =accountList[0].clientIdentifier__c+'~'+salesRoleHierarchy0.Agent.Associate_ID__c+'~'+salesRoleHierarchy0.AgentTeamMember.Associate_Id__c,Customer__c=accountList[0].Id,Staff__c=salesRoleHierarchy0.AgentTeamMember.Id);
            AssignedStaff__c newAssignedStaff1= new AssignedStaff__c(Agent__c=salesRoleHierarchy1.Agent.Id, AssignedStaffIdentifier__c =accountList[1].clientIdentifier__c+'~'+salesRoleHierarchy1.Agent.Associate_ID__c+'~'+agentTeamMember1.Associate_Id__c,Customer__c=accountList[1].Id,Staff__c=agentTeamMember1.Id);

            Profile agentProfile = [Select Id from Profile where name = '2.00 Agent'];
            insert buildtestUser('agent2@statefarm.com', agentProfile, '2A');
            Test.startTest();
            insert newAssignedStaff0;
            insert newAssignedStaff1;
        }
        System.runAs(testAPIUser) {
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            BuildJsonWrapperList testApiUserCombineProcessorWCNotInSFDCExtraAssignedWrap = new BuildJsonWrapperList();
				testApiUserCombineProcessorWCNotInSFDCExtraAssignedWrap.lclientId = LOSING_CLIST;
				testApiUserCombineProcessorWCNotInSFDCExtraAssignedWrap.wcliendId = 'WIDNOTINSF';
				testApiUserCombineProcessorWCNotInSFDCExtraAssignedWrap.otherid = OTHER_CLIENT;
				testApiUserCombineProcessorWCNotInSFDCExtraAssignedWrap.assocId = salesRoleHierarchy0.Agent.Associate_Id__c;
				testApiUserCombineProcessorWCNotInSFDCExtraAssignedWrap.externalSyncTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			testStageOrchestration.Value__c = buildJSON(testApiUserCombineProcessorWCNotInSFDCExtraAssignedWrap);
            stgorcList.add(testStageOrchestration);
            new UTIL_CombineProcessor().execute(stgorcList);
        }

        List<AssignedStaff__c> actualAssignedStaffList = [Select id,name,ownerId,Customer__r.clientIdentifier__c from AssignedStaff__c];
        System.assertEquals('WIDNOTINSF', actualAssignedStaffList[0].Customer__r.clientIdentifier__c, 'Expected parameter is not equals to the actual parameter');
        Test.stopTest();
    }

    /**
     *   @description <This method is used to combine and update Planning Conversation Log Owner as SYSTEM_USER_REC_OWNER in the WC, When both WC & LC available in SFDC>
     */
     @isTest
    private static void testcombineProcessorForPlanningConvLogRecordOwnerUpdate() {
        fetchUsers();
        TestData_SalesRoleHierarchy salesRoleHierarchyForPlanConvLog1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy(
            'Q'
        );
        TestData_SalesRoleHierarchy salesRoleHierarchyForPlanConvLog2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy(
            'T'
        );
        List<Account> accountList = new List<Account>();
        PlanningConversationLog__c planConvLog1;
        PlanningConversationLog__c planConvLog2;
		psAssignment = assignPermissionSet(testAPIUser);
        System.runAs(salesRoleHierarchyForPlanConvLog1.agent) {
            insert psAssignment;
            accountList.add(createAccount(LOSING_CLIST));
            accountList.add(createAccount(WINNING_CLIST));
            accountList.add(createAccount(OTHER_CLIENT));
            insert accountList;

            AgentRole__c agentRole11 = createAgentRole(salesRoleHierarchyForPlanConvLog1.Agent.Associate_ID__c + '~' + accountList[0].clientIdentifier__c, accountList[0].id);
            insert agentRole11;
            AgentRole__c agentRole21 = createAgentRole(salesRoleHierarchyForPlanConvLog2.Agent.Associate_ID__c + '~' + accountList[0].clientIdentifier__c, accountList[0].id);
            agentRole21.Agent__c = salesRoleHierarchyForPlanConvLog2.Agent.id;
            insert agentRole21;
        }

        System.runAs(sysAdminUser) {
            Profile agentProfile = [Select Id from Profile where name = '2.00 Agent'];
            insert buildtestUser('tttestttt11223agnt2', agentProfile, '2A');

            SimpleConversation__c simpleConv1 = new SimpleConversation__c(
                SimpleConversationName__c = 'testSimple1',
                Account__c = accountList[0].id,
                Agent__c = salesRoleHierarchyForPlanConvLog1.agent.id,
                ownerId = salesRoleHierarchyForPlanConvLog1.agentOffice.id,
                SimpleConversationType__c = 'Simple Conversation',
                Status__c = 'New'
            );
            insert simpleConv1;
            SimpleConversation__c simpleConv2 = new SimpleConversation__c (SimpleConversationName__c = 'testSimple2', Account__c = accountList[0].id, Agent__c = salesRoleHierarchyForPlanConvLog2.agent.id, ownerId = salesRoleHierarchyForPlanConvLog2.agentOffice.id, SimpleConversationType__c = 'Simple Conversation', Status__c = 'New');
            insert simpleConv2;

            planConvLog1 = new PlanningConversationLog__c (Account__c = accountList[0].id, Comments__c = 'Test Comments', Agent__c = salesRoleHierarchyForPlanConvLog1.agent.id, SimpleConversation__c = simpleConv1.id, ownerId = salesRoleHierarchyForPlanConvLog1.agentOffice.id);
            insert planConvLog1;
            planConvLog2 = new PlanningConversationLog__c (Account__c = accountList[0].id, Comments__c = 'Test Comments', Agent__c = salesRoleHierarchyForPlanConvLog2.agent.id, SimpleConversation__c = simpleConv2.id, ownerId = salesRoleHierarchyForPlanConvLog2.agentOffice.id);
            insert planConvLog2;
        }

        Test.startTest();
        System.runAs(testAPIUser) {
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            BuildJsonWrapperList testApiUserCombineProcessorForPlanningConvLogWrap = new BuildJsonWrapperList();
				testApiUserCombineProcessorForPlanningConvLogWrap.lclientId = LOSING_CLIST;
				testApiUserCombineProcessorForPlanningConvLogWrap.wcliendId = WINNING_CLIST;
				testApiUserCombineProcessorForPlanningConvLogWrap.otherid = OTHER_CLIENT;
				testApiUserCombineProcessorForPlanningConvLogWrap.assocId = salesRoleHierarchyForPlanConvLog1.Agent.Associate_Id__c;
				testApiUserCombineProcessorForPlanningConvLogWrap.externalSyncTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			testStageOrchestration.Value__c = buildJSON(testApiUserCombineProcessorForPlanningConvLogWrap);
            stgorcList.add(testStageOrchestration);
            new UTIL_CombineProcessor().execute(stgorcList);
        }

        List<PlanningConversationLog__c> actualPlanConvList = [Select id, name, ownerId, Account__r.clientIdentifier__c from PlanningConversationLog__c];
        System.assertEquals(actualPlanConvList.size(), 2, 'Size of List<PlanningConversationLog__c> is not equals to 2');

        for(PlanningConversationLog__c planConvLog: actualPlanConvList) {
            if((planConvLog.Id).equals(planConvLog1.id)) {
                system.assertEquals(WINNING_CLIST, planConvLog.Account__r.clientIdentifier__c, 'Expected parameter is not equals to the actual parameter');
                system.assertEquals(salesRoleHierarchyForPlanConvLog1.agentOffice.id, planConvLog.ownerId, 'Expected Id is not equals to the actual Id');
            } else if ((planConvLog.Id).equals(planConvLog2.id)) {
                system.assertEquals(systemUser.Id, planConvLog.ownerId, 'Expected Id is not equals to the actual Id');
                system.assertEquals(WINNING_CLIST, planConvLog.Account__r.clientIdentifier__c, 'Expected parameter is not equals to the actual parameter');
            }
        }
        Test.stopTest();
    }

    /**
     *   @description <This method is used to test the change in ownership between losing and winning acounts for CICs from the losing account>
     */
     @isTest
    private static void testCICOwnershipUpdate() {
        fetchUsers();
        List<Account> accountList = new List<Account>();
        CustomerInitiatedCancellations__c losingCIC;
		psAssignment = assignPermissionSet(testAPIUser);
        System.runAs(salesRoleHierarchy1.agent) {
            accountList.add(createAccount(LOSING_CLIST));
            accountList.add(createAccount(WINNING_CLIST));
            accountList.add(createAccount(OTHER_CLIENT));
            insert accountList;

            AgentRole__c agentRole11 = createAgentRole(salesRoleHierarchy1.Agent.Associate_ID__c + '~' + accountList[0].clientIdentifier__c, accountList[0].id);
            insert agentRole11;
            AgentRole__c agentRole21 = createAgentRole(salesRoleHierarchy2.Agent.Associate_ID__c + '~' + accountList[0].clientIdentifier__c, accountList[0].id);
            agentRole21.Agent__c = salesRoleHierarchy2.Agent.id;
            insert agentRole21;
        }

        System.runAs(sysAdminUser) {
            insert psAssignment;
            Profile agentProfile = [Select Id from Profile where name = '2.00 Agent'];
            insert buildtestUser('test1357agnt2', agentProfile, '2A');

            losingCIC = new CustomerInitiatedCancellations__c (Customer__c = accountList[0].id, AssociatedPolicyNumber__c = '987 8747-A25-46B', CancellationReason__c = 'reason', DateOfContact__c = Date.today(), EffectiveDateOfCancellation__c = Date.today(), LineOfBusiness__c = 'Auto', MethodOfContact__c = 'E-Mail', PersonRequestingCancellationName__c = 'Me', PolicyDescription__c = 'Desc', ownerId = salesRoleHierarchy1.agentOffice.id);

            insert losingCIC;
        }

        Test.startTest();
        System.runAs(testAPIUser) {
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            BuildJsonWrapperList testApiUserCICOwnershipUpdateWrap = new BuildJsonWrapperList();
				testApiUserCICOwnershipUpdateWrap.lclientId = LOSING_CLIST;
				testApiUserCICOwnershipUpdateWrap.wcliendId = WINNING_CLIST;
				testApiUserCICOwnershipUpdateWrap.otherid = OTHER_CLIENT;
				testApiUserCICOwnershipUpdateWrap.assocId = salesRoleHierarchy1.Agent.Associate_Id__c;
				testApiUserCICOwnershipUpdateWrap.externalSyncTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			testStageOrchestration.Value__c = buildJSON(testApiUserCICOwnershipUpdateWrap);
            stgorcList.add(testStageOrchestration);
            new UTIL_CombineProcessor().execute(stgorcList);
        }

        List<CustomerInitiatedCancellations__c> actualCICList = [Select id, name, ownerId, Customer__r.id from CustomerInitiatedCancellations__c];
        System.assertEquals(actualCICList.size(), 1, 'Size of List<CustomerInitiatedCancellations__c> is not equals to 1');

        for(CustomerInitiatedCancellations__c cic: actualCICList) {
            if((cic.Id).equals(losingCIC.id)) {
                system.assertEquals(salesRoleHierarchy1.agentOffice.id, cic.ownerId, 'Expected Id is not equals to the actual Id');
                system.assertNotEquals(accountList[0].Id, cic.Customer__r.id, 'Expected Id is equals to the actual Id');
                system.assertEquals(accountList[1].Id, cic.Customer__r.id, 'Expected Id is not equals to the actual Id');
            }
        }
        Test.stopTest();
    }

    /**
     *   @description <This method is used to combine and update Planning Conversation Log Owner as SYSTEM_USER_REC_OWNER, When WC Not in SFDC & LC in SFDC>
     */
     @isTest
    private static void testcombineProcessorForPlanningConvLogRecordOwnerUpdateForWinningClientNotInSFDC() {
        fetchUsers();
        TestData_SalesRoleHierarchy salesRoleHierarchyForPlanConvLog1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy(
            'Q'
        );
        TestData_SalesRoleHierarchy salesRoleHierarchyForPlanConvLog2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy(
            'T'
        );
        List<Account> accountList = new List<Account>();
        PlanningConversationLog__c planConvLog1;
        PlanningConversationLog__c planConvLog2;

        System.runAs(salesRoleHierarchyForPlanConvLog1.agent) {
            accountList.add(createAccount(LOSING_CLIST));
            accountList.add(createAccount(OTHER_CLIENT));
            insert accountList;

            AgentRole__c agentRole11 = createAgentRole(salesRoleHierarchyForPlanConvLog1.Agent.Associate_ID__c + '~' + accountList[0].clientIdentifier__c, accountList[0].id);
            insert agentRole11;
            AgentRole__c agentRole21 = createAgentRole(salesRoleHierarchyForPlanConvLog2.Agent.Associate_ID__c + '~' + accountList[0].clientIdentifier__c, accountList[0].id);
            agentRole21.Agent__c = salesRoleHierarchyForPlanConvLog2.Agent.id;
            insert agentRole21;
        }
		psAssignment = assignPermissionSet(testAPIUser);
        System.runAs(sysAdminUser) {
            insert psAssignment;
            Profile agentProfile = [Select Id from Profile where name = '2.00 Agent'];
            insert buildtestUser('tt111eee11ssst22agnt2', agentProfile, '2A');

            SimpleConversation__c simpleConv1 = new SimpleConversation__c (SimpleConversationName__c = 'testSimple1', Account__c = accountList[0].id, Agent__c = salesRoleHierarchyForPlanConvLog1.agent.id, ownerId = salesRoleHierarchyForPlanConvLog1.agentOffice.id, SimpleConversationType__c = 'Simple Conversation', Status__c = 'New');
            insert simpleConv1;
            SimpleConversation__c simpleConv2 = new SimpleConversation__c (SimpleConversationName__c = 'testSimple2', Account__c = accountList[0].id, Agent__c = salesRoleHierarchyForPlanConvLog2.agent.id, ownerId = salesRoleHierarchyForPlanConvLog2.agentOffice.id, SimpleConversationType__c = 'Simple Conversation', Status__c = 'New');
            insert simpleConv2;

            planConvLog1 = new PlanningConversationLog__c (Account__c = accountList[0].id, Comments__c = 'Test Comments', Agent__c = salesRoleHierarchyForPlanConvLog1.agent.id, SimpleConversation__c = simpleConv1.id, ownerId = salesRoleHierarchyForPlanConvLog1.agentOffice.id);
            insert planConvLog1;
            planConvLog2 = new PlanningConversationLog__c (Account__c = accountList[0].id, Comments__c = 'Test Comments', Agent__c = salesRoleHierarchyForPlanConvLog2.agent.id, SimpleConversation__c = simpleConv2.id, ownerId = salesRoleHierarchyForPlanConvLog2.agentOffice.id);
            insert planConvLog2;
        }

        Test.startTest();
        System.runAs(testAPIUser) {
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            BuildJsonWrapperList testApiUserPlanningConvLogRecordOwnerUpdateWrap = new BuildJsonWrapperList();
				testApiUserPlanningConvLogRecordOwnerUpdateWrap.lclientId = LOSING_CLIST;
				testApiUserPlanningConvLogRecordOwnerUpdateWrap.wcliendId = 'WIDNOTINSF';
				testApiUserPlanningConvLogRecordOwnerUpdateWrap.otherid = OTHER_CLIENT;
				testApiUserPlanningConvLogRecordOwnerUpdateWrap.assocId = salesRoleHierarchyForPlanConvLog1.Agent.Associate_Id__c;
				testApiUserPlanningConvLogRecordOwnerUpdateWrap.externalSyncTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			testStageOrchestration.Value__c = buildJSON(testApiUserPlanningConvLogRecordOwnerUpdateWrap);
            stgorcList.add(testStageOrchestration);
            new UTIL_CombineProcessor().execute(stgorcList);
        }

        List<PlanningConversationLog__c> actualPlanConvList = [Select id, name, ownerId, Account__r.clientIdentifier__c from PlanningConversationLog__c];
        System.assertEquals(actualPlanConvList.size(), 2, 'Size of List<PlanningConversationLog__c> is not equals to 2');
        for(PlanningConversationLog__c planConvLog: actualPlanConvList) {
            if((planConvLog.Id).equals(planConvLog1.id)) {
                system.assertEquals('WIDNOTINSF', planConvLog.Account__r.clientIdentifier__c, 'Expected parameter is not equals to the actual parameter');
                system.assertEquals(salesRoleHierarchyForPlanConvLog1.agentOffice.id, planConvLog.ownerId, 'Expected Id is not equals to the actual parameter');
            } else if((planConvLog.Id).equals(planConvLog2.id)) {
                system.assertEquals(systemUser.Id, planConvLog.ownerId, 'Expected Id is not equals to the actual parameter');
                system.assertEquals('WIDNOTINSF', planConvLog.Account__r.clientIdentifier__c, 'Expected parameter is not equals to the actual parameter');
            }
        }
        Test.stopTest();
    }

    /**
     *   @description <This method is used to combine and update Simple Conversation Owner as SYSTEM_USER_REC_OWNER in the WC, When both WC & LC available in SFDC>
     */
     @isTest
    private static void testcombineProcessorForSimpleConvRecordOwnerUpdate() {
        fetchUsers();
        TestData_SalesRoleHierarchy salesRoleHierarchyForSimpleConv1 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy(
            'G'
        );
        TestData_SalesRoleHierarchy salesRoleHierarchyForSimpleConv2 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy(
            'K'
        );
        List<Account> accountList = new List<Account>();
        SimpleConversation__c simpleConv1;
        SimpleConversation__c simpleConv2;

        System.runAs(salesRoleHierarchyForSimpleConv1.agent) {
            accountList.add(createAccount(LOSING_CLIST));
            accountList.add(createAccount(WINNING_CLIST));
            accountList.add(createAccount(OTHER_CLIENT));
            insert accountList;

            AgentRole__c agentRole11 = createAgentRole(salesRoleHierarchyForSimpleConv1.Agent.Associate_ID__c + '~' + accountList[0].clientIdentifier__c, accountList[0].id);
            insert agentRole11;
            AgentRole__c agentRole21 = createAgentRole(salesRoleHierarchyForSimpleConv2.Agent.Associate_ID__c + '~' + accountList[0].clientIdentifier__c, accountList[0].id);
            agentRole21.Agent__c = salesRoleHierarchyForSimpleConv2.Agent.id;
            insert agentRole21;
        }
		psAssignment = assignPermissionSet(testAPIUser);
        System.runAs(sysAdminUser) {
            insert psAssignment;
            Profile agentProfile = [Select Id from Profile where name = '2.00 Agent'];
            insert buildtestUser('tttestttt11223agnt2', agentProfile, '2A');

            simpleConv1 = new SimpleConversation__c (SimpleConversationName__c = 'testSimple1', Account__c = accountList[0].id, Agent__c = salesRoleHierarchyForSimpleConv1.agent.id, ownerId = salesRoleHierarchyForSimpleConv1.agentOffice.id, SimpleConversationType__c = 'Simple Conversation', Status__c = 'New');
            insert simpleConv1;
            simpleConv2 = new SimpleConversation__c (SimpleConversationName__c = 'testSimple2', Account__c = accountList[0].id, Agent__c = salesRoleHierarchyForSimpleConv2.agent.id, ownerId = salesRoleHierarchyForSimpleConv2.agentOffice.id, SimpleConversationType__c = 'Simple Conversation', Status__c = 'New');
            insert simpleConv2;
        }

        Test.startTest();
        System.runAs(testAPIUser) {
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            BuildJsonWrapperList testApiUserCombineProcessorForSimpleConvWrap = new BuildJsonWrapperList();
				testApiUserCombineProcessorForSimpleConvWrap.lclientId = LOSING_CLIST;
				testApiUserCombineProcessorForSimpleConvWrap.wcliendId = WINNING_CLIST;
				testApiUserCombineProcessorForSimpleConvWrap.otherid = OTHER_CLIENT;
				testApiUserCombineProcessorForSimpleConvWrap.assocId = salesRoleHierarchyForSimpleConv1.Agent.Associate_Id__c;
				testApiUserCombineProcessorForSimpleConvWrap.externalSyncTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			testStageOrchestration.Value__c = buildJSON(testApiUserCombineProcessorForSimpleConvWrap);
            stgorcList.add(testStageOrchestration);
            new UTIL_CombineProcessor().execute(stgorcList);
        }
        List<SimpleConversation__c> actualSimpleConvList = [Select id, ownerId, Account__r.clientIdentifier__c from SimpleConversation__c];
        System.assertEquals(actualSimpleConvList.size(), 2, 'Size of List<SimpleConversation__c> is not equals to 2');
		SimpleConversationWrapperList testApiUserSimpleConvRecordOwnerUpdateWrap = new SimpleConversationWrapperList();
			testApiUserSimpleConvRecordOwnerUpdateWrap.actualSimpleConvList = actualSimpleConvList;
			testApiUserSimpleConvRecordOwnerUpdateWrap.clientId = WINNING_CLIST;
			testApiUserSimpleConvRecordOwnerUpdateWrap.simpleConv1 = simpleConv1;
			testApiUserSimpleConvRecordOwnerUpdateWrap.simpleConv2 = simpleConv2;
			testApiUserSimpleConvRecordOwnerUpdateWrap.agentOfficeId = salesRoleHierarchyForSimpleConv1.agentOffice.id;
		assertSimpleConversation(testApiUserSimpleConvRecordOwnerUpdateWrap);
        Test.stopTest();
    }

    private static void assertSimpleConversation(SimpleConversationWrapperList assertSimpleConversationWrapper){
        List<SimpleConversation__c> actualSimpleConvList = assertSimpleConversationWrapper.actualSimpleConvList;
        String clientId = assertSimpleConversationWrapper.clientId;
        SimpleConversation__c simpleConv1 = assertSimpleConversationWrapper.simpleConv1;
        SimpleConversation__c simpleConv2 = assertSimpleConversationWrapper.simpleConv2;
        Id agentOfficeId = assertSimpleConversationWrapper.agentOfficeId;
        for(SimpleConversation__c simpleConvRec: actualSimpleConvList) {
            if((simpleConvRec.Id).equals(simpleConv1.id)) {
                system.assertEquals(clientId, simpleConvRec.Account__r.clientIdentifier__c, 'Expected parameter is not equals to the actual parameter');
                system.assertEquals(agentOfficeId, simpleConvRec.ownerId, 'Expected Id is not equals to the actual Id');
            } else if((simpleConvRec.Id).equals(simpleConv2.id)) {
                system.assertEquals(systemUser.Id, simpleConvRec.ownerId, 'Expected Id is not equals to the actual Id');
                system.assertEquals(clientId, simpleConvRec.Account__r.clientIdentifier__c, 'Expected parameter is not equals to the actual parameter');
            }
        }
    }

    private class SimpleConversationWrapperList{
        private List<SimpleConversation__c> actualSimpleConvList;
        private String clientId;
        private SimpleConversation__c simpleConv1;
        private SimpleConversation__c simpleConv2;
		private Id agentOfficeId;
	}

    /**
     *   @description <This method is used to combine and update Simple Conversation Owner as SYSTEM_USER_REC_OWNER, When WC Not in SFDC & LC in SFDC>
     */
     @isTest
    private static void testcombineProcessorForSimpleConvRecordOwnerUpdateForWinningClientNotInSFDC() {
        fetchUsers();
        TestData_SalesRoleHierarchy salesRoleHierarchyForSimpleConv1 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy(
            'P'
        );
        TestData_SalesRoleHierarchy salesRoleHierarchyForSimpleConv2 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy(
            'O'
        );
        List<Account> accountList = new List<Account>();
        SimpleConversation__c simpleConv1;
        SimpleConversation__c simpleConv2;

        System.runAs(salesRoleHierarchyForSimpleConv1.agent) {
            accountList.add(createAccount(LOSING_CLIST));
            accountList.add(createAccount(OTHER_CLIENT));
            insert accountList;

            AgentRole__c agentRole11 = createAgentRole(salesRoleHierarchyForSimpleConv1.Agent.Associate_ID__c + '~' + accountList[0].clientIdentifier__c, accountList[0].id);
            insert agentRole11;
            AgentRole__c agentRole21 = createAgentRole(salesRoleHierarchyForSimpleConv2.Agent.Associate_ID__c + '~' + accountList[0].clientIdentifier__c, accountList[0].id);
            agentRole21.Agent__c = salesRoleHierarchyForSimpleConv2.Agent.id;
            insert agentRole21;
        }
		psAssignment = assignPermissionSet(testAPIUser);
        System.runAs(sysAdminUser) {
            insert psAssignment;
            Profile agentProfile = [Select Id from Profile where name = '2.00 Agent'];
            insert buildtestUser('tt111eee11ssst22agnt2', agentProfile, '2A');

            simpleConv1 = new SimpleConversation__c (SimpleConversationName__c = 'testSimple1', Account__c = accountList[0].id, Agent__c = salesRoleHierarchyForSimpleConv1.agent.id, ownerId = salesRoleHierarchyForSimpleConv1.agentOffice.id, SimpleConversationType__c = 'Simple Conversation', Status__c = 'New');
            insert simpleConv1;
            simpleConv2 = new SimpleConversation__c (SimpleConversationName__c = 'testSimple2', Account__c = accountList[0].id, Agent__c = salesRoleHierarchyForSimpleConv2.agent.id, ownerId = salesRoleHierarchyForSimpleConv2.agentOffice.id, SimpleConversationType__c = 'Simple Conversation', Status__c = 'New');
            insert simpleConv2;
        }

        Test.startTest();
        System.runAs(testAPIUser) {
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            BuildJsonWrapperList testApiUserSimpleConvRecordOwnerUpdateWrap = new BuildJsonWrapperList();
				testApiUserSimpleConvRecordOwnerUpdateWrap.lclientId = LOSING_CLIST;
				testApiUserSimpleConvRecordOwnerUpdateWrap.wcliendId = 'WIDNOTINSF';
				testApiUserSimpleConvRecordOwnerUpdateWrap.otherid = OTHER_CLIENT;
				testApiUserSimpleConvRecordOwnerUpdateWrap.assocId = salesRoleHierarchyForSimpleConv1.Agent.Associate_Id__c;
				testApiUserSimpleConvRecordOwnerUpdateWrap.externalSyncTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			testStageOrchestration.Value__c = buildJSON(testApiUserSimpleConvRecordOwnerUpdateWrap);
            stgorcList.add(testStageOrchestration);
            new UTIL_CombineProcessor().execute(stgorcList);
        }
		List<SimpleConversation__c> actualSimpleConvList = [Select id, ownerId, Account__r.clientIdentifier__c from SimpleConversation__c];
        System.assertEquals(actualSimpleConvList.size(), 2, 'Size of List<SimpleConversation__c> is not equals to 2');
        SimpleConversationWrapperList testApiUserRecordOwnerUpdateForWinningClientWrap = new SimpleConversationWrapperList();
			testApiUserRecordOwnerUpdateForWinningClientWrap.actualSimpleConvList = actualSimpleConvList;
			testApiUserRecordOwnerUpdateForWinningClientWrap.clientId = 'WIDNOTINSF';
			testApiUserRecordOwnerUpdateForWinningClientWrap.simpleConv1 = simpleConv1;
			testApiUserRecordOwnerUpdateForWinningClientWrap.simpleConv2 = simpleConv2;
			testApiUserRecordOwnerUpdateForWinningClientWrap.agentOfficeId = salesRoleHierarchyForSimpleConv1.agentOffice.id;
		assertSimpleConversation(testApiUserRecordOwnerUpdateForWinningClientWrap);
        Test.stopTest();
    }

    /**
     *   @description <This method is used to delete Campaign Members for Losing Client, When both WC & LC available in SFDC>
     */
     @isTest
    private static void testCombineProcessorForCampaignMemberDelete() {
        Map<String, Schema.Recordtypeinfo> campaignRecordTypeMap = Schema.Sobjecttype.Campaign.getRecordTypeInfosByName();
        fetchUsers();
        TestData_SalesRoleHierarchy salesRoleHierarchyForSimpleConv1 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy(
            'G'
        );
        TestData_SalesRoleHierarchy salesRoleHierarchyForSimpleConv2 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy(
            'K'
        );
        List<Account> accountList = new List<Account>();
        CampaignMember campMemb1;

        System.runAs(salesRoleHierarchyForSimpleConv1.agent) {
            accountList.add(createAccount(LOSING_CLIST));
            accountList.add(createAccount(WINNING_CLIST));
            accountList.add(createAccount(OTHER_CLIENT));
            insert accountList;

            AgentRole__c agentRole11 = createAgentRole(salesRoleHierarchyForSimpleConv1.Agent.Associate_ID__c + '~' + accountList[0].clientIdentifier__c, accountList[0].id);
            insert agentRole11;
            AgentRole__c agentRole21 = createAgentRole(salesRoleHierarchyForSimpleConv2.Agent.Associate_ID__c + '~' + accountList[0].clientIdentifier__c, accountList[0].id);
            agentRole21.Agent__c = salesRoleHierarchyForSimpleConv2.Agent.id;
            insert agentRole21;
        }
		psAssignment = assignPermissionSet(testAPIUser);
        System.runAs(sysAdminUser) {
            insert psAssignment;
            Profile agentProfile = [Select Id from Profile where name = '2.00 Agent'];
            insert buildtestUser('tttestttt11223agnt2', agentProfile, '2A');

            Account accountClientId = [SELECT PersonContactId FROM Account WHERE Id =: accountList[0].id limit 1];
            Campaign tstCampaign = new Campaign(Name = 'tstCmpMembDisplayRecords', RecordTypeId = campaignRecordTypeMap.get('Customer/Prospect Campaign').RecordTypeId, ownerId = salesRoleHierarchyForSimpleConv1.agentOffice.id);
            insert tstCampaign;

            campMemb1 = new CampaignMember (campaignId = tstCampaign.id, contactId = accountClientId.PersonContactId);
            insert campMemb1;
        }

        List<CampaignMember> beforeCampaignMemberList = [Select id from CampaignMember];
        System.assertEquals(beforeCampaignMemberList.size(), 1, 'Size of List<CampaignMember> is not equals to 1');

        Test.startTest();
        System.runAs(testAPIUser) {
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            BuildJsonWrapperList testApiUserCombineProcessorForCampaignMemberDeleteWrap = new BuildJsonWrapperList();
				testApiUserCombineProcessorForCampaignMemberDeleteWrap.lclientId = LOSING_CLIST;
				testApiUserCombineProcessorForCampaignMemberDeleteWrap.wcliendId = WINNING_CLIST;
				testApiUserCombineProcessorForCampaignMemberDeleteWrap.otherid = OTHER_CLIENT;
				testApiUserCombineProcessorForCampaignMemberDeleteWrap.assocId = salesRoleHierarchyForSimpleConv1.Agent.Associate_Id__c;
				testApiUserCombineProcessorForCampaignMemberDeleteWrap.externalSyncTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			testStageOrchestration.Value__c = buildJSON(testApiUserCombineProcessorForCampaignMemberDeleteWrap);

            stgorcList.add(testStageOrchestration);
            new UTIL_CombineProcessor().execute(stgorcList);
        }

        List<CampaignMember> actualCampaignMemberList = [Select id from CampaignMember];

        System.assert(actualCampaignMemberList.isEmpty(), 'List<CampaignMember> is not empty');

        Test.stopTest();
    }

    @isTest
    private static void testcombineProcessorForSFDCMasteredFieldsWithJsonDataAsLatest() {
        fetchUsers();
        salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('Q');
        salesRoleHierarchy2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('T');
        List<Account> accountList = new List<Account>();

        System.runAs(salesRoleHierarchy1.agent) {
            Account winningAccount = createAccount(WINNING_CLIST);
            winningAccount.LivingArrangementsModDate__c = Datetime.now().addhours(-5);
            winningAccount.LivingArrangements__c = 'Rent';
            Account losingAccount = createAccount(LOSING_CLIST);
            losingAccount.LivingArrangementsModDate__c = Datetime.now();
            losingAccount.LivingArrangements__c = 'Unknown';
            accountList.add(losingAccount);
            accountList.add(winningAccount);
            accountList.add(createAccount(OTHER_CLIENT));
            Account winningOrgAccount = createOrgAccount('TSTORGCLIDW');
            winningOrgAccount.NumberofEmployees = 10;
            winningOrgAccount.NumberofEmployeesModDate__c = Datetime.now().addhours(-5);
            Account losingOrgAccount = createOrgAccount('TSTORGCLIDL');
            losingOrgAccount.NumberofEmployees = 15;
            losingOrgAccount.NumberofEmployeesModDate__c = Datetime.now();
            accountList.add(winningOrgAccount);
            accountList.add(losingOrgAccount);
            accountList.add(createOrgAccount('TSTORGCLIDO'));
            insert accountList;

            AgentRole__c agentRole11 = createAgentRole(salesRoleHierarchy1.Agent.Associate_ID__c + '~' + winningAccount.clientIdentifier__c, winningAccount.id);
            insert agentRole11;
            AgentRole__c agentRole21 = createAgentRole(salesRoleHierarchy2.Agent.Associate_ID__c + '~' + winningAccount.clientIdentifier__c, winningAccount.id);
            agentRole21.Agent__c = salesRoleHierarchy2.Agent.id;
            insert agentRole21;
        }
		psAssignment = assignPermissionSet(testAPIUser);
        System.runAs(sysAdminUser) {
            insert psAssignment;
            Profile agentProfile = [Select Id from Profile where name = '2.00 Agent'];
            insert buildtestUser('tt111eee11ssst22agnt2', agentProfile, '2A');
        }

        Test.startTest();
        System.runAs(testAPIUser) {
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            BuildJsonWrapperList testApiUserCombineProcessorForSFDCMasteredFieldsWrap = new BuildJsonWrapperList();
				testApiUserCombineProcessorForSFDCMasteredFieldsWrap.lclientId = LOSING_CLIST;
				testApiUserCombineProcessorForSFDCMasteredFieldsWrap.wcliendId = WINNING_CLIST;
				testApiUserCombineProcessorForSFDCMasteredFieldsWrap.otherid = OTHER_CLIENT;
				testApiUserCombineProcessorForSFDCMasteredFieldsWrap.assocId = salesRoleHierarchy1.Agent.Associate_Id__c;
				testApiUserCombineProcessorForSFDCMasteredFieldsWrap.externalSyncTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			testStageOrchestration.Value__c = buildJSON(testApiUserCombineProcessorForSFDCMasteredFieldsWrap);
            stgorcList.add(testStageOrchestration);
            new UTIL_CombineProcessor().execute(stgorcList);
        }

        Account winAccount = [Select id, LivingArrangements__c from Account Where clientidentifier__c = :WINNING_CLIST];
        System.assertEquals('Unknown', winAccount.LivingArrangements__c, 'Expected String is not equals to the actual String');

        System.runAs(testAPIUser) {
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            BuildJsonWrapperList testApiUserSFDCMasteredFieldsWithJsonDataAsLatestWrap = new BuildJsonWrapperList();
				testApiUserSFDCMasteredFieldsWithJsonDataAsLatestWrap.lclientId = 'TSTORGCLIDL';
				testApiUserSFDCMasteredFieldsWithJsonDataAsLatestWrap.wcliendId = 'TSTORGCLIDW';
				testApiUserSFDCMasteredFieldsWithJsonDataAsLatestWrap.otherid = 'TSTORGCLIDO';
				testApiUserSFDCMasteredFieldsWithJsonDataAsLatestWrap.assocId =  salesRoleHierarchy1.Agent.Associate_Id__c;
				testApiUserSFDCMasteredFieldsWithJsonDataAsLatestWrap.externalSyncTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			testStageOrchestration.Value__c = buildJSON(testApiUserSFDCMasteredFieldsWithJsonDataAsLatestWrap);
            stgorcList.add(testStageOrchestration);
            new UTIL_CombineProcessor().execute(stgorcList);
        }

        Account winOrgAccount = [Select id, NumberOfEmployees from Account Where clientidentifier__c = 'TSTORGCLIDW'];
        System.assertEquals(15, winOrgAccount.NumberOfEmployees, 'Expected NumberOfEmployees is not equals to the actual NumberOfEmployees');

        Test.stopTest();
    }

    @isTest
    private static void testcombineProcessorForSFDCMasteredFieldsWithSfdcDataAsLatest() {
        fetchUsers();
        salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('Q');
        salesRoleHierarchy2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('T');
        List<Account> accountList = new List<Account>();

        System.runAs(salesRoleHierarchy1.agent) {
            Account winningAccount = createAccount(WINNING_CLIST);
            winningAccount.LivingArrangementsModDate__c = Datetime.now().addhours(-5);
            winningAccount.LivingArrangements__c = 'Rent';
            Account losingAccount = createAccount(LOSING_CLIST);
            losingAccount.LivingArrangementsModDate__c = Datetime.now();
            losingAccount.LivingArrangements__c = 'Unknown';
            accountList.add(losingAccount);
            accountList.add(winningAccount);
            accountList.add(createAccount(OTHER_CLIENT));
            Account winningOrgAccount = createOrgAccount('TSTORGCLIDW');
            winningOrgAccount.NumberofEmployees = 10;
            winningOrgAccount.NumberofEmployeesModDate__c = Datetime.now().addhours(-5);
            Account losingOrgAccount = createOrgAccount('TSTORGCLIDL');
            losingOrgAccount.NumberofEmployees = 15;
            losingOrgAccount.NumberofEmployeesModDate__c = Datetime.now();
            accountList.add(winningOrgAccount);
            accountList.add(losingOrgAccount);
            accountList.add(createOrgAccount('TSTORGCLIDO'));
            insert accountList;

            AgentRole__c agentRole11 = createAgentRole(salesRoleHierarchy1.Agent.Associate_ID__c + '~' + winningAccount.clientIdentifier__c, winningAccount.id);
            insert agentRole11;
            AgentRole__c agentRole21 = createAgentRole(salesRoleHierarchy2.Agent.Associate_ID__c + '~' + winningAccount.clientIdentifier__c, winningAccount.id);
            agentRole21.Agent__c = salesRoleHierarchy2.Agent.id;
            insert agentRole21;
        }
		psAssignment = assignPermissionSet(testAPIUser);
        System.runAs(sysAdminUser) {
            insert psAssignment;
            Profile agentProfile = [Select Id from Profile where name = '2.00 Agent'];
            insert buildtestUser('tt111eee11ssst22agnt2', agentProfile, '2A');
        }

        Test.startTest();
        System.runAs(testAPIUser) {
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            BuildJsonWrapperList testApiUserForSFDCMasteredFieldsWrap = new BuildJsonWrapperList();
				testApiUserForSFDCMasteredFieldsWrap.lclientId = LOSING_CLIST;
				testApiUserForSFDCMasteredFieldsWrap.wcliendId = WINNING_CLIST;
				testApiUserForSFDCMasteredFieldsWrap.otherid = OTHER_CLIENT;
				testApiUserForSFDCMasteredFieldsWrap.assocId =  salesRoleHierarchy1.Agent.Associate_Id__c;
				testApiUserForSFDCMasteredFieldsWrap.externalSyncTime = String.valueOf(Datetime.now().addYears(-5).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			testStageOrchestration.Value__c = buildJSON(testApiUserForSFDCMasteredFieldsWrap);

            stgorcList.add(testStageOrchestration);
            new UTIL_CombineProcessor().execute(stgorcList);
        }

        Account winAccount = [Select id, LivingArrangements__c from Account Where clientidentifier__c = :WINNING_CLIST];
        System.assertEquals('Unknown', winAccount.LivingArrangements__c, 'Expected String is not equals to the actual String');

        System.runAs(testAPIUser) {
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
			BuildJsonWrapperList testApiUserMasteredFieldsWithSfdcDataAsLatestWrap = new BuildJsonWrapperList();
				testApiUserMasteredFieldsWithSfdcDataAsLatestWrap.lclientId = 'TSTORGCLIDL';
				testApiUserMasteredFieldsWithSfdcDataAsLatestWrap.wcliendId = 'TSTORGCLIDW';
				testApiUserMasteredFieldsWithSfdcDataAsLatestWrap.otherid = 'TSTORGCLIDO';
				testApiUserMasteredFieldsWithSfdcDataAsLatestWrap.assocId =  salesRoleHierarchy1.Agent.Associate_Id__c;
				testApiUserMasteredFieldsWithSfdcDataAsLatestWrap.externalSyncTime = String.valueOf(Datetime.now().addyears(-5).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			testStageOrchestration.Value__c = buildJSON(testApiUserMasteredFieldsWithSfdcDataAsLatestWrap);
            stgorcList.add(testStageOrchestration);
            new UTIL_CombineProcessor().execute(stgorcList);
        }

        Account winOrgAccount = [Select id, NumberOfEmployees from Account Where clientidentifier__c = 'TSTORGCLIDW'];
        System.assertEquals(15, winOrgAccount.NumberOfEmployees, 'Expected NumberOfEmployees is not equals to the actual NumberOfEmployees');

        Test.stopTest();
    }

    @isTest
    private static void testcombineProcessorForSFDCMasteredFieldsWinningAccountlastModified() {
        fetchUsers();
        salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('Q');
        salesRoleHierarchy2 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('T');
        List<Account> accountList = new List<Account>();

        System.runAs(salesRoleHierarchy1.agent) {
            Account winningAccount = createAccount(WINNING_CLIST);
            winningAccount.LivingArrangementsModDate__c = Datetime.now();
            winningAccount.LivingArrangements__c = 'Other';
            winningAccount.LivingArrangementsOtherDescription__c = 'Living in a Garage';
            Account losingAccount = createAccount(LOSING_CLIST);
            losingAccount.LivingArrangementsModDate__c = Datetime.now().addhours(-5);
            losingAccount.LivingArrangements__c = 'Unknown';
            accountList.add(losingAccount);
            accountList.add(winningAccount);
            accountList.add(createAccount(OTHER_CLIENT));
            Account winningOrgAccount = createOrgAccount('TSTORGCLIDW');
            winningOrgAccount.NumberofEmployees = 10;
            winningOrgAccount.NumberofEmployeesModDate__c = Datetime.now();
            Account losingOrgAccount = createOrgAccount('TSTORGCLIDL');
            losingOrgAccount.NumberofEmployees = 15;
            losingOrgAccount.NumberofEmployeesModDate__c = Datetime.now().addhours(-5);
            accountList.add(winningOrgAccount);
            accountList.add(losingOrgAccount);
            accountList.add(createOrgAccount('TSTORGCLIDO'));
            insert accountList;

            AgentRole__c agentRole11 = createAgentRole(salesRoleHierarchy1.Agent.Associate_ID__c + '~' + winningAccount.clientIdentifier__c, winningAccount.id);
            insert agentRole11;
            AgentRole__c agentRole21 = createAgentRole(salesRoleHierarchy2.Agent.Associate_ID__c + '~' + winningAccount.clientIdentifier__c, winningAccount.id);
            agentRole21.Agent__c = salesRoleHierarchy2.Agent.id;
            insert agentRole21;
        }
		psAssignment = assignPermissionSet(testAPIUser);
        System.runAs(sysAdminUser) {
            insert psAssignment;
            Profile agentProfile = [Select Id from Profile where name = '2.00 Agent'];
            insert buildtestUser('tt111eee11ssst22agnt2', agentProfile, '2A');
        }

        Test.startTest();
        System.runAs(testAPIUser) {
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            BuildJsonWrapperList testApiUserCombineProcessorForSFDCMasteredFieldsWrap = new BuildJsonWrapperList();
				testApiUserCombineProcessorForSFDCMasteredFieldsWrap.lclientId = LOSING_CLIST;
				testApiUserCombineProcessorForSFDCMasteredFieldsWrap.wcliendId = WINNING_CLIST;
				testApiUserCombineProcessorForSFDCMasteredFieldsWrap.otherid = OTHER_CLIENT;
				testApiUserCombineProcessorForSFDCMasteredFieldsWrap.assocId =  salesRoleHierarchy1.Agent.Associate_Id__c;
				testApiUserCombineProcessorForSFDCMasteredFieldsWrap.externalSyncTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			testStageOrchestration.Value__c = buildJSON(testApiUserCombineProcessorForSFDCMasteredFieldsWrap);
            stgorcList.add(testStageOrchestration);
            new UTIL_CombineProcessor().execute(stgorcList);
        }

        Account winAccount = [Select id, LivingArrangements__c, LivingArrangementsOtherDescription__c  from Account Where clientidentifier__c = :WINNING_CLIST];
        System.assertEquals('Other', winAccount.LivingArrangements__c, 'Expected String is not equals to the actual String');
        System.assertEquals('Living in a Garage', winAccount.LivingArrangementsOtherDescription__c, 'Expected String is not equals to the actual String');

        System.runAs(testAPIUser) {
            List<StageOrchestration__c> stgorcList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            BuildJsonWrapperList testApiUserWinningAccountlastModifiedWrap = new BuildJsonWrapperList();
				testApiUserWinningAccountlastModifiedWrap.lclientId = 'TSTORGCLIDL';
				testApiUserWinningAccountlastModifiedWrap.wcliendId = 'TSTORGCLIDW';
				testApiUserWinningAccountlastModifiedWrap.otherid = 'TSTORGCLIDO';
				testApiUserWinningAccountlastModifiedWrap.assocId =  salesRoleHierarchy1.Agent.Associate_Id__c;
				testApiUserWinningAccountlastModifiedWrap.externalSyncTime = String.valueOf(Datetime.now().addyears(-5).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ'));
			testStageOrchestration.Value__c = buildJSON(testApiUserWinningAccountlastModifiedWrap);
            stgorcList.add(testStageOrchestration);
            new UTIL_CombineProcessor().execute(stgorcList);
        }

        Account winOrgAccount = [Select id, NumberOfEmployees from Account Where clientidentifier__c = 'TSTORGCLIDW'];
        System.assertEquals(10, winOrgAccount.NumberOfEmployees, 'Expected NumberOfEmployees is not equals to the actual NumberOfEmployees');

        Test.stopTest();
    }

    /**
     *   @description <This method is used to create new json>
     *   @param jsonWrapper
     *   @return json
     */
    public static String buildJSON(BuildJsonWrapperList jsonWrapper) {
        String lclientId = jsonWrapper.lclientId;
        String wcliendId = jsonWrapper.wcliendId;
        String otherid = jsonWrapper.otherid;
        String assocId = jsonWrapper.assocId;
        String externalSyncTime = jsonWrapper.externalSyncTime;

        String json=       '{'+
            '  "orchestrationInfo" : {'+
            '    "jsonVersionNumber" : "1.0",'+
            '    "orchestrationDataName" : [ {'+
            '      "orchestrationNameDetail" : {'+
            '        "dataName" : "Account",'+
            '        "dataDeleteIndicator" : false,'+
            '        "dataExternalKey" : "clientId",'+
            '        "externalSourceSyncTime" : "'+externalSyncTime+'",'+
            '        "dataExternalKeyValue" : "'+wcliendId+'",'+
            '        "orchestrationDataValues" : {'+
            '          "RecordTypeId" : "Individual",'+
            '          "PersonEmailBouncedReason" : "",'+
            '          "Phone" : 3472730865,'+
            '          "IsNotShareable" : "N",'+
            '          "PersonMobilePhone" : 0,'+
            '          "HasConfirmedNoEmail" : true,'+
            '          "IsSubjecttoCASL" : "N",'+
            '          "ShippingState" : "",'+
            '          "IsPrivacyOptionsShared" : "Y",'+
            '          "LastName" : "Hkhk",'+
            '          "PaperlessPrivacyNotice" : "N",'+
            '          "BillingState" : "VA",'+
            '          "EmployerName" : "",'+
            '          "TDDPhone" : 0,'+
            '          "BillingPostalCode" : "235231223",'+
            '          "OccupationStatus" : "Full-time",'+
            '          "Occupation" : "Other",'+
            '          "ShippingCity" : "",'+
            '          "FirstName" : "GIOVAN",'+
            '          "MaritalStatus" : "Married",'+
            '          "Military" : "No",'+
            '          "IsDeathNotificationReceived" : "false",'+
            '          "IsProtectedPerson" : "N",'+
            '          "IsHearingImpaired" : "true",'+
            '          "Citizenship" : "",'+
            '          "BillingCountry" : "UNITED STATES",'+
            '          "ShippingCountry" : "",'+
            '          "BillingAddressType" : "USAddress",'+
            '          "ShippingStreet" : "",'+
            '          "SSN" : "0000",'+
            '          "Suffix" : " ",'+
            '          "BillingStreet" : "120 W BERKLEY AVE",'+
            '          "PersonBirthdate" : "1984-03-09",'+
            '          "DriversLicenseStateProvince" : "VIRGINIA",'+
            '          "ShippingAddressType" : "",'+
            '          "DriversLicenseNumber" : "6789",'+
            '          "MailingInCareOf" : "",'+
            '          "PreferredSpokenLanguage" : "",'+
            '          "PersonHomePhone" : 3472730865,'+
            '          "PreferredFirstName" : null,'+
            '          "MiddleName" : "",'+
            '          "BillingCity" : "NORFOLK",'+
            '          "MailingAttention":" ",'+
            '          "Gender" : "Female",'+
            '          "ShippingPostalCode" : "",'+
            '          "PersonEmail" : "DWRD747@AUTOFILL.COM",'+
            '          "Designation" : " "'+
            '        }'+
            '      }'+
            '    }, {'+
            '      "orchestrationNameDetail" : {'+
            '        "dataName" : "Agent Role",'+
            '        "dataDeleteIndicator" : false,'+
            '        "dataExternalKey" : "AgentRoleIdentifier",'+
            '        "externalSourceSyncTime" : "2016-09-22T04:32:55.906+0000",'+
            '        "dataExternalKeyValue" : "'+assocId+'~'+wcliendId+'", '+
            '        "orchestrationDataValues" : {'+
            '          "Customer" : "'+wcliendId+'",'+
            '          "RelationshipNature" : "Ex-Client", '+
            '          "StartDate" : "2013-09-24",'+
            '          "Agent" : "'+assocId+'",'+
            '          "HouseholdGroupId":"HouseholdA1"'+
            '        }'+
            '      }'+
            '    }, {'+
            '      "orchestrationNameDetail" : {'+
            '        "dataName" : "Agent Role",'+
            '        "dataDeleteIndicator" : false,'+
            '        "dataExternalKey" : "AgentRoleIdentifier",'+
            '        "externalSourceSyncTime" : "2016-09-22T04:32:55.907+0000",'+
            '        "dataExternalKeyValue" : "SAA2A~'+wcliendId+'", '+
            '        "orchestrationDataValues" : {'+
            '          "Customer" : "'+wcliendId+'",'+
            '          "RelationshipNature" : "Prospect",'+
            '          "StartDate" : "2013-09-03",'+
            '          "Agent" : "SAA2A",'+
            '          "HouseholdGroupId":"HouseholdA2"'+
            '        }'+
            '      }'+
            '    }, {'+
            '       "orchestrationNameDetail":{'+
            '       "dataName":"Customer2Customer",'+
            '       "dataDeleteIndicator":false,'+
            '       "dataExternalKey":"RelationshipIdentifier",'+
            '       "externalSourceSyncTime":"2017-05-03T04:32:55.907+0000",'+
            '       "dataExternalKeyValue":"'+wcliendId+'~'+otherid+'",'+
            '       "orchestrationDataValues":{'+
            '       "Customer":"'+wcliendId+'",'+
            '       "relationwith":"'+otherid+'",'+
            '       "RelationshipNature":"Father",'+
            '       "StartDate":"2008-08-01"'+
            '    }'+
            '    }'+
            '    } ],'+
            '    "orchestrationEventName" : {'+
            '      "orchestrationEventType" : "Combine Customer Record",'+
            '      "orchestrationEventDetail" : {'+
            '        "orchestrationEventValues" : {'+
            '          "lClientId" : "'+lclientId+'", '+
            '          "wClientId" : "'+wcliendId+'" '+
            '        }'+
            '      }'+
            '    }'+
            '  }'+
            '}';
        return  json;
    }

    /**
     * @description build json wrapper list
     */
    private class BuildJsonWrapperList{
        private String lclientId;
        private String wcliendId;
        private String otherid;
		private String assocId;
		private String externalSyncTime;
    }

}