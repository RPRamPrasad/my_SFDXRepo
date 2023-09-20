/**
* @name AP_OpportunityTriggers_Test
* @author ITIC Team
Version     Author         Date         Description
1.1         Opptimizers    9-8-2022     added @isTest annotations 
* @description Apex unit testing for Opportunity Insert Trigger set owner to Proxy.
*/
@isTest(seeAllData = false)
public class AP_OpportunityTriggers_Test {

    private static User sysAdminuser;
    private static User agentUsr;
    private static User agentUsr2;
    private static User proxyUsr;
    private static User proxyUsr2;
    private static UserRole proxyStandardUsrRole;
    private static UserRole proxyStandardUsrRole2;
    private static UserRole agentStandardUsrRole;
    private static UserRole agentStandardUsrRole2;
    private static Account testAccount;
    private static String optyRecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunity_Management').getRecordTypeId();

    /**
* @method Setup method used for building test data
* @description   setUp
*/
    @testsetup
    public static void testSetupData() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;
        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=false);
        insert passTriggerAll;
        CS001_ByPassTriggerAtoF__c accountByPassTrigger= new CS001_ByPassTriggerAtoF__c(Override_AccountBeforeInsert__c=false,Override_AgentRoleAfterInsert__c=false);
        insert accountByPassTrigger;
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(Name=UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER,SFDC_USER_ID__c=systemUser.id);
        insert sysAdminUserIdSetting;
        CS001_ByPassTriggerGtoZ__c oppByPassTrigger = new CS001_ByPassTriggerGtoZ__c(Override_OppBeforeInsert__c=false);
        oppByPassTrigger.Override_OpportunityProductAfterInsert__c = true;
        insert oppByPassTrigger;

    }
    /**
*@method - This method will set up test data for First Agent Office(Creation of Agent, ATM, Proxy Users and Role hierarchy)
*@description - setUpAgentOffice
*/
    public static void setUpAgentOffice() {
        agentStandardUsrRole = new UserRole(name='AgentRole');
        insert agentStandardUsrRole;
        agentStandardUsrRole2 = new UserRole(name='AgentRole2');
        insert agentStandardUsrRole2;
        proxyStandardUsrRole = new UserRole(name='ProxyRole', parentRoleId = agentStandardUsrRole.id);
        insert proxyStandardUsrRole;
        proxyStandardUsrRole2 = new UserRole(name='ProxyRole2', parentRoleId = agentStandardUsrRole2.id);
        insert proxyStandardUsrRole2;
        User testProxyUser1 = new User(Alias='Proxy',LastName='TaskProxy',Username='verifytaskproxy@statefarm.com.bad',UserExternalID__c='123testP',Servicing_Agent_Associate_ID__c='123test');
        proxyUsr = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
        proxyUsr.userRoleId = proxyStandardUsrRole.id;
        Database.insert(proxyUsr);
        testProxyUser1 = new User(Alias='Proxy2',LastName='TaskProxy2',Username='verifytaskproxy2@statefarm.com.bad',UserExternalID__c='234testP',Servicing_Agent_Associate_ID__c='234test');
        proxyUsr2 = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
        proxyUsr2.userRoleId = proxyStandardUsrRole2.id;
        Database.insert(proxyUsr2);
        User testAgentUser1 = new User(Alias='Agent',LastName='TaskAgent',Username='verifytaskAgent@statefarm.com.bad',Associate_ID__c='123test',UserExternalID__c='123test_123test',Servicing_Agent_Associate_ID__c='123test');
        agentUsr= UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
        agentUsr.userRoleId= agentStandardUsrRole.id;
        agentUsr.UserExternalID__c = '123test_123test';

        Database.insert(agentUsr);
        testAgentUser1 = new User(Alias='Agent2',LastName='TaskAgent2',Username='verifytaskAgent2@statefarm.com.bad',Associate_ID__c='234test',UserExternalID__c='234test_234test',Servicing_Agent_Associate_ID__c='234test');
        agentUsr2 = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
        agentUsr2.userRoleId = agentStandardUsrRole2.id;
        agentUsr2.UserExternalID__c = '234test_234test';
        Database.insert(agentUsr2);
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUsr,agentUsr2});
        addPermissionSet('SF_CRM_OpportunityApi_PermSetPID', agentUsr);
        addPermissionSet('SF_CRM_OpportunityApi_PermSetPID', agentUsr2);
    }

    /**
     * @description addPermissionSet
     * @param permSet 
     * @param user 
     */
    public static void addPermissionSet(String permSet, User user) {
        PermissionSet userPermSet = [SELECT Id FROM PermissionSet WHERE Name =: permSet Limit 1];
        PermissionSetAssignment userPermSetAssign = new PermissionSetAssignment();
        userPermSetAssign.AssigneeId = user.Id;
        userPermSetAssign.PermissionSetId = userPermSet.Id;
        insert userPermSetAssign;
    }

    //method to build Opportunity record with Lob,Product
    private static OpportunityProduct__c insertOpportunityProductData(String lob, String product){
        OpportunityProduct__c oppProduct = new OpportunityProduct__c();
        oppProduct.name='TestProduct';
        oppProduct.lob_Name__c=lob;
        oppProduct.Category_Name__c='Product Selection';
        oppProduct.Product_Description__c=product;
        oppProduct.Product_Form_NUM__c='PFM1';
        oppProduct.Product_Id__c='PID';
        oppProduct.Product_End_Date__c=Date.today()+100;
        oppProduct.Product_Start_Date__c=Date.today()-50;
        oppProduct.Product_Postal_State__c='IL';
        oppProduct.Product_Type__c=product;
        oppProduct.status__c=true;
        oppProduct.lob_cd__c = '041';
        oppProduct.Product_System_Name__c = 'UNIT_SYSTEM_NAME';
        return oppProduct;
    }

    /**
     * @description buildUserAPIDataAdmin
     * @param aPIuserName 
     * @return  `User`
    * @Method This method is used to create API Data Admin User Type  */
    public static User buildUserAPIDataAdmin(String aPIuserName) {
        User user = new User(alias = 'APIA', email='APIA@statefarm.com',emailencodingkey='UTF-8', lastname='dataAdmin', languagelocalekey='en_US',
                             localesidkey='en_US', timezonesidkey='America/Chicago', username= aPIuserName, MasterUserRecord__c = true);
        user.ProfileId = UTIL_ProfileId_TEST.getApiDataAdminProfileId();
        insert user;
        addPermissionSet('SF_CRMDM_UserManagement_PermSetPID', user);
        addPermissionSet('SF_CRM_OpportunityApi_PermSetPID', user);
        addPermissionSet('Opportunity_FullAccess_W', user);
        return user;
    }

    /**
* @method Test Opportunity Insert scenarios to assign opportunity to proxy record.
* @description   testOpportunityInsertByAgent
*/
    @isTest
    public static void testOpportunityInsertByAgent() {
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        UserRole agentStandardUserRole;
        UserRole proxyStandardUserRole;
        System.runAs(systemAdmin) {
            agentStandardUserRole = new UserRole(name='AgentRole');
            insert agentStandardUserRole;
            proxyStandardUserRole = new UserRole(name='ProxyRole', parentRoleId = agentStandardUserRole.id);
            insert proxyStandardUserRole;
        }

        User agentUser;
        User proxyUser;
        System.runAs(systemAdmin) {
            User testAgentUser1 = new User(Alias='alias',LastName='accOwner',Username='agent@statefarm.com',Associate_ID__c='123test',UserExternalID__c='123test_123test',Servicing_Agent_Associate_ID__c='123test');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
            agentUser.userRoleId= agentStandardUserRole.id;

            insert agentUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);

        }
        system.runAs(systemAdmin) {
            User testProxyUser1 = new User(Alias='Proxy',LastName='ProxyAccOwner',Username='proxyAgent@statefarm.com',UserExternalID__c='123testP',Servicing_Agent_Associate_ID__c='123test');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId= proxyStandardUserRole.id;
            insert proxyUser;
            User queryProxy = [Select id,Proxy_External_ID__c,UserExternalID__c,Alias,lastname,email,profileid from User where id =: proxyUser.id];
            proxyUser= queryProxy ;
            User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,profileid from User where id =: agentUser.id];
            agentUser= queryAgent ;
        }

        List<User> databaseStateFarmAccOwnerList = [select id,Username,name from User where name = 'TestSysRecOwner'];
        User databaseStateFarmAccOwner = databaseStateFarmAccOwnerList.get(0);
        Account testAccount;
        system.runAs(agentUser) {
            testAccount= new Account(firstname ='SSSHHHH', lastname='SSSSSHHHH', ClientIdentifier__c ='SFFSP81L8XB');
            insert testAccount;
        }
        testAccount = [select id, ownerId from Account where CreatedbyId =:agentUser.id];
        system.AssertEquals(databaseStateFarmAccOwner.Id, testAccount.OwnerId,'Account Ownership failed.');
        system.runAs(agentUser) {
            Opportunity errorOpp1 = new Opportunity(accountId = testAccount.id, name='ErrorOpp',closeDate=system.today(), stageName='Test',LOB__c='Auto',Description='Test Descrption');
            String error1;
            try {
                insert errorOpp1;
            }
            catch(Exception e) {
                error1 = e.getMessage();
            }
            system.assertEquals(false,String.isBlank(error1),'Exception path for Oppprtunity creation without Agent Role failed');
            Opportunity errorOpp2 = new Opportunity(accountId = testAccount.id, name='ErrorOpp',closeDate=system.today(), stageName='Test',LOB__c='Auto',Description='Test Descrption');
            String error2;
            try {
                insert errorOpp2;
            }
            catch(Exception e) {
                error2 = e.getMessage();
            }
            system.assertEquals(false,String.isBlank(error2),'Exception path for Oppprtunity creation without Proxy failed');
        }

        AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentUser.id);
        insert newAgentRole;
        List<AccountShare> accShare = [select id, RowCause, accountId, AccountAccessLevel, OpportunityAccessLevel, UserOrGroupId from AccountShare where AccountId = :testAccount.id];
        system.assertEquals(2, accShare.size(),'Expected value is 2, but actual value is ' +accShare.size());
        system.runAs(agentUser) {
            List<Account> acc = [select id, name, OwnerId from Account];
            system.AssertEquals(true, acc!=null && acc.size()==1, 'Agent not able to see Account');
            Opportunity opp = new Opportunity(accountId =  testAccount.id, name='TestOpp', closeDate=System.today(), StageName='Test',LOB__c='Auto', Description = 'Test Description');
            insert opp;
            List<Opportunity> saveopp = [select id, name, ownerId from opportunity where id  = : opp.id];
            system.assertEquals(1, saveOpp.size(),'Agent not able to see Opportunity');
            system.assertEquals(proxyUser.id, saveopp.get(0).ownerId,'Proxy Ownership failed.');
        }
        system.runAs(agentUser) {
            List<Account> acc = [select id, name, OwnerId from Account];
            system.AssertEquals(true, acc!=null && acc.size()==1, 'Agent not able to see Account');
            Opportunity opp1 = new Opportunity(accountId =  testAccount.id, name='TestOpp1', closeDate=System.today(), StageName='Test',LOB__c='Auto', Description = 'Test Description');
            insert opp1;
        }
    }

    /**
* @Author - Team TGV - Added new mthod to increase code coverage.
* @method Method to test exception encountered when Agent without proxy tries to create a Opportunity
* @description   testOpportunityInsertByAgentWithoutProxy
*/
    @isTest
    public static void testOpportunityInsertByAgentWithoutProxy() {
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        User agentUserWithoutProxy;
        System.runAs(systemAdmin) {
            User testAgentUser1 = new User(Alias='alias',LastName='accOwner',Username='agent1@statefarm.com',Associate_ID__c='124test',UserExternalID__c='124testextId',Servicing_Agent_Associate_ID__c='124test');
            agentUserWithoutProxy = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);

            insert agentUserWithoutProxy;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUserWithoutProxy);

        }
        Account testAccount1;
        system.runAs(agentUserWithoutProxy) {
            testAccount1= new Account(firstname ='SSSHHHH123', lastname='SSSSSHHHH', ClientIdentifier__c ='SFFSP81L8XB');
            insert testAccount1;
        }
        testAccount1 = [select id, ownerId from Account where CreatedbyId =:agentUserWithoutProxy.id];
        AccountShare share = new AccountShare(accountId=testAccount1.id,AccountAccessLevel='edit',OpportunityAccessLevel='None',CaseAccessLevel='None',
                                              UserOrGroupId= agentUserWithoutProxy.id);
        insert share;
        system.runAs(agentUserWithoutProxy) {
            List<Account> acc = [select id, name, OwnerId from Account];
            system.AssertEquals(true, acc!=null && acc.size()==1, 'Agent not able to see Account');
            String error1;
            try {
                Opportunity opp = new Opportunity(accountId =  testAccount1.id, name='TestOpp', closeDate=System.today(), StageName='Test',LOB__c='Auto', Description = 'Test Description');
                insert opp;
            }
            catch(Exception e) {
                error1 = e.getMessage();
            }
            system.assertEquals(false,String.isBlank(error1),'Exception path to test opportunity  with No Proxy');
        }
    }

    /**
* @method Test Opportunity Insert scenarios to assign opportunity to proxy record.
* @description   testsetOpportunityOwnerForAgentAtm
*/
    @isTest
    public static void testsetOpportunityOwnerForAgentAtm() {
        UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        setUpAgentOffice();
        Account testAccount;
        
        system.runAs(agentUsr) {
            testAccount= new Account(firstname ='TESTOWNER', lastname='SSSSSHHHH', ClientIdentifier__c ='SFFSP81L8XB');
            insert testAccount;
        }
        testAccount = [select id, ownerId from Account where firstname ='TESTOWNER'];
        system.runAs(agentUsr) {
            Opportunity opp1 = new Opportunity(accountId = testAccount.id, name='opp123',closeDate=system.today(), stageName='Test',LOB__c='Auto',Description='Test Description');
            String error1;
            try {
                insert opp1;
                Opportunity opty =[Select id, OriginalOwner__c, OwnerId from Opportunity where ID=:opp1.id];
                System.assertEquals(opty.OriginalOwner__c, opty.OwnerId,'Expected value is '+opty.OriginalOwner__c+', but actual value is '+opty.OwnerId);
            }
            catch(Exception e) {
                error1 = e.getMessage();
            }
        }

    }

    @isTest
    static void oppTypeAndRelationshipToSFPopulatedWhenOppCreatedBy103User(){
        User apiUser = buildUserAPIDataAdmin('Apidataadmin@statefarm.com');
        setUpAgentOffice();
        Account testAccount;
        system.runAs(apiUser) {
            testAccount = new Account(firstname ='Test First', lastname='Test Last', ClientIdentifier__c ='SFFSP81L8XB');
            insert testAccount;
            AgentRole__c agentRole = new AgentRole__c(Customer__c=testAccount.Id,Agent__c=agentUsr.Id,RelationshipNature__c='Customer');
            insert agentRole;
            Opportunity opp1 = new Opportunity(ownerId = proxyUsr.Id, accountId = testAccount.id, name='opp123',closeDate=system.today(), stageName='Test',LOB__c='Auto',
                                    Description='Test Description', RecordTypeId = optyRecordTypeId);

            insert opp1;
            opp1 = [SELECT Id, Relationship_to_State_Farm__c, Type, Owner.Name FROM Opportunity WHERE Id=:opp1.Id];
            system.assertEquals('Customer',opp1.Relationship_to_State_Farm__c,'Expected value is Customer, but actual value is '+opp1.Relationship_to_State_Farm__c);
            system.assertEquals('Existing Business',opp1.Type,'Expected value is Existing Business, but actual value is ' +opp1.Type);
        }
    }

    @isTest
    static void oppTypeAndRelationshipToSFPopulatedForCustomer(){
        User apiUser = buildUserAPIDataAdmin('Apidataadmin@statefarm.com');
        setUpAgentOffice();
        Account testAccount;
        system.runAs(agentUsr) {
            testAccount = new Account(firstname ='Test First', lastname='Test Last', ClientIdentifier__c ='SFFSP81L8XB');
            insert testAccount;
        }
        system.runAs(apiUser){
            AgentRole__c agentRole = new AgentRole__c(Customer__c=testAccount.Id,Agent__c=agentUsr.Id,RelationshipNature__c='Customer');
            insert agentRole;
        }

        system.runAs(agentUsr) {
            Opportunity opp1 = new Opportunity(accountId = testAccount.id, name='opp123',closeDate=system.today(), stageName='Test',LOB__c='Auto',Description='Test Description');
            insert opp1;
            opp1 = [SELECT Id, Relationship_to_State_Farm__c, Type, Owner.Name FROM Opportunity WHERE Id=:opp1.Id];
            system.assertEquals('Customer',opp1.Relationship_to_State_Farm__c,'Expected value is Customer, but actual value is '+opp1.Relationship_to_State_Farm__c);
            system.assertEquals('Existing Business',opp1.Type,'Expected value is Existing Business, but actual value is ' +opp1.Type);
        }
    }

    @isTest
    static void oppTypeAndRelationshipToSFPopulatedForExCustomer(){
        User apiUser = buildUserAPIDataAdmin('Apidataadmin@statefarm.com');
        setUpAgentOffice();
        Account testAccount;
        system.runAs(agentUsr) {
            testAccount = new Account(firstname ='Test First', lastname='Test Last', ClientIdentifier__c ='SFFSP81L8XB');
            insert testAccount;
        }

        system.runAs(apiUser){
            AgentRole__c agentRole = new AgentRole__c(Customer__c=testAccount.Id,Agent__c=agentUsr.Id,RelationshipNature__c='Ex-Customer');
            insert agentRole;
        }

        system.runAs(agentUsr) {
            Opportunity opp1 = new Opportunity(accountId = testAccount.id, name='opp123',closeDate=system.today(), stageName='Test',LOB__c='Auto',Description='Test Description');
            insert opp1;

            opp1 = [SELECT Id, Relationship_to_State_Farm__c, Type, Owner.Name FROM Opportunity WHERE Id=:opp1.Id];
            system.assertEquals('Ex-Customer',opp1.Relationship_to_State_Farm__c,'Expected value is Ex-Customer, but actual value is '+opp1.Relationship_to_State_Farm__c);
            system.assertEquals('Win-Back',opp1.Type,'Expected value is Win-Back, but actual value is ' +opp1.Type);
        }
    }

    @isTest
    static void oppTypeAndRelationshipToSFPopulatedForProspect(){
        User apiUser = buildUserAPIDataAdmin('Apidataadmin@statefarm.com');
        setUpAgentOffice();
        Account testAccount;
        system.runAs(agentUsr) {
            testAccount = new Account(firstname ='Test First', lastname='Test Last', ClientIdentifier__c ='SFFSP81L8XB');
            insert testAccount;
        }

        system.runAs(apiUser){
            AgentRole__c agentRole = new AgentRole__c(Customer__c=testAccount.Id,Agent__c=agentUsr.Id,RelationshipNature__c='Prospect');
            insert agentRole;
        }

        system.runAs(agentUsr) {
            Opportunity opp1 = new Opportunity(accountId = testAccount.id, name='opp123',closeDate=system.today(), stageName='Test',LOB__c='Auto',Description='Test Description');
            insert opp1;

            opp1 = [SELECT Id, Relationship_to_State_Farm__c, Type, Owner.Name FROM Opportunity WHERE Id=:opp1.Id];
            system.assertEquals('Prospect',opp1.Relationship_to_State_Farm__c,'Expected value is Prospect, but actual value is '+opp1.Relationship_to_State_Farm__c);
            system.assertEquals('New Business',opp1.Type,'Expected value is New Business, but actual value is ' +opp1.Type);
        }
    }

    @isTest
    static void oppTypeAndRelationshipToSFPopulatedWithProspectAndCustRelationships(){
        User apiUser = buildUserAPIDataAdmin('Apidataadmin@statefarm.com');
        setUpAgentOffice();
        Account testAccount;
        system.runAs(agentUsr2) {
            testAccount = new Account(firstname ='Test First', lastname='Test Last', ClientIdentifier__c ='SFFSP81L8XB');
            insert testAccount;
        }
        system.runAs(apiUser){
            AgentRole__c agentRole = new AgentRole__c(Customer__c=testAccount.Id,Agent__c=agentUsr2.Id,RelationshipNature__c='Prospect');
            insert agentRole;
            AgentRole__c agentRole2 = new AgentRole__c(Customer__c=testAccount.Id,Agent__c=agentUsr.Id,RelationshipNature__c='Customer');
            insert agentRole2;
        }

        system.runAs(agentUsr2) {
            Opportunity opp1 = new Opportunity(accountId = testAccount.id, name='opp123',closeDate=system.today(), stageName='Test',LOB__c='Auto',Description='Test Description');
            insert opp1;

            opp1 = [SELECT Id, Relationship_to_State_Farm__c, Type, Owner.Name FROM Opportunity WHERE Id=:opp1.Id];
            system.assertEquals('Customer',opp1.Relationship_to_State_Farm__c,'Expected value is Customer, but actual value is '+opp1.Relationship_to_State_Farm__c);
            system.assertEquals('New Business',opp1.Type,'Expected value is New Business, but actual value is ' +opp1.Type);
        }
    }

    @isTest
    static void oppTypeAndRelationshipToSFPopulatedWithProspectAndExCustRelationships(){
        User apiUser = buildUserAPIDataAdmin('Apidataadmin@statefarm.com');
        setUpAgentOffice();
        Account testAccount;
        system.runAs(agentUsr2) {
            testAccount = new Account(firstname ='Test First', lastname='Test Last', ClientIdentifier__c ='SFFSP81L8XB');
            insert testAccount;
        }
        system.runAs(apiUser){
            AgentRole__c agentRole = new AgentRole__c(Customer__c=testAccount.Id,Agent__c=agentUsr2.Id,RelationshipNature__c='Prospect');
            insert agentRole;
            AgentRole__c agentRole2 = new AgentRole__c(Customer__c=testAccount.Id,Agent__c=agentUsr.Id,RelationshipNature__c='Ex-Customer');
            insert agentRole2;
        }

        system.runAs(agentUsr2) {
            Opportunity opp1 = new Opportunity(accountId = testAccount.id, name='opp123',closeDate=system.today(), stageName='Test',LOB__c='Auto',Description='Test Description');
            insert opp1;

            opp1 = [SELECT Id, Relationship_to_State_Farm__c, Type, Owner.Name FROM Opportunity WHERE Id=:opp1.Id];
            system.assertEquals('Ex-Customer',opp1.Relationship_to_State_Farm__c,'Expected value is Ex-Customer, but actual value is '+opp1.Relationship_to_State_Farm__c);
            system.assertEquals('New Business',opp1.Type,'Expected value is New Business, but actual value is ' +opp1.Type);
        }
    }

    @isTest
    static void oppTypeAndRelationshipToSFSetToNewWhenRelationshipNatureIsBlank(){
        User apiUser = buildUserAPIDataAdmin('Apidataadmin@statefarm.com');
        setUpAgentOffice();
        Account testAccount;
        system.runAs(apiUser) {
            testAccount = new Account(firstname ='Test First', lastname='Test Last', ClientIdentifier__c ='SFFSP81L8XB');
            insert testAccount;
            AgentRole__c agentRole = new AgentRole__c(Customer__c=testAccount.Id,Agent__c=agentUsr.Id,RelationshipNature__c='');
            insert agentRole;
            Opportunity opp1 = new Opportunity(ownerId = proxyUsr.Id, accountId = testAccount.id, name='opp123',closeDate=system.today(), stageName='Test',LOB__c='Auto',Description='Test Description', RecordTypeId = optyRecordTypeId);
            insert opp1;
            opp1 = [SELECT Id, Relationship_to_State_Farm__c, Type, Owner.Name FROM Opportunity WHERE Id=:opp1.Id];
            system.assertEquals('Prospect',opp1.Relationship_to_State_Farm__c,'Expected value is Prospect, but actual value is '+opp1.Relationship_to_State_Farm__c);
            system.assertEquals('New Business',opp1.Type,'Expected value is New Business, but actual value is ' +opp1.Type);
        }
    }

    @isTest
    static void  updateOpportunityPSPBasedOnEffectivedateAsAGENT(){

        setUpAgentOffice();
        Account testAccount;
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
        system.runAs(systemAdmin){

            Map<String, String> lobProdValue = new Map<String, String>{
                'Auto'=>'UNIT TESTING'
                    };
                        List<OpportunityProduct__c> oppProds = new List<OpportunityProduct__c>();
            for(String lob : lobProdValue.keySet()) {
                oppProds.add(insertOpportunityProductData(lob,lobProdValue.get(lob)));
            }
            insert oppProds;
        }

        system.runAs(agentUsr) {
            testAccount = new Account(firstname ='Test First', lastname='Test Last', ClientIdentifier__c ='SFFSP81L8XB');
            insert testAccount;
            AgentRole__c agentRole = new AgentRole__c(Customer__c=testAccount.Id,Agent__c=agentUsr.Id,RelationshipNature__c='Prospect');
            insert agentRole;

            Opportunity opp1 = new Opportunity(ownerId = proxyUsr.Id, accountId = testAccount.id, name='opp123',closeDate=system.today(),
                                               stageName='Test',LOB__c='Auto',Description='Test Description',RecordTypeId = optyRecordTypeId,
                                               State_Code__c='IL / 75-3338', Requested_Effective_Date__c = Date.today()-1,Product__c='UNIT TESTING',Product_System_Name__c='TEST');
            insert opp1;

            Opportunity updateOpp = new Opportunity();
            updateOpp.Id = opp1.Id;
            updateOpp.Requested_Effective_Date__c = Date.today()+3;
            updateOpp.State_Code__c = opp1.State_Code__c;
            updateOpp.LOB__c = opp1.LOB__c;
            updateOpp.Product__c = Opp1.Product__c;
            updateOpp.Product_System_Name__c = Opp1.Product_System_Name__c;
            HLPR_SignedWrittenConsent.byPassOpportunityBeforeUpdate = false;
            update updateOpp;

            AP_OpportunityTrigger.updateOpportunityPSPBasedOnEffectivedate(updateOpp,opp1);

            opp1 = [SELECT Id, Requested_Effective_Date__c, Product__c,Product_System_Name__c FROM Opportunity WHERE Id=:opp1.Id];
            system.assertEquals('UNIT_SYSTEM_NAME',opp1.Product_System_Name__c,'Expected value is UNIT_SYSTEM_NAME, but actual value is ' +opp1.Product_System_Name__c);
        }
    }

}