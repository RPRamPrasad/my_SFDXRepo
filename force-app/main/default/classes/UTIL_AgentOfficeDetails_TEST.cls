/**
@Author Loco Motivated
@Name UTIL_AgentOfficeDetails_TEST
@description This is a test class to map of Agent SFDC Id and his Offcie Id and checking Agent Office availability in SFDC
@Version 1.0
*/

@isTest(seeAllData=false)
private class UTIL_AgentOfficeDetails_TEST {

    private static Account account;
    private static User systemAdminUser;
    private static List<AgentRole__c> agentRoleCreation;
    private static final String CUSTOMER = 'Customer';
    private static final String SYSADMIN_USER_ID = UTIL_TestUsername_TEST.getTestUsername('sysadmin');
    private static Map<Id,Id> agentProxyMap;

    /**
    * @method test Case Created by Agent User or Address Change of an account initiated by Agent User
    * @name   testcaseCreatedbyAgentUser
    * @description Single Agent Roles Proxy
    */
    @isTest
    static void singleAgentRolesProxy(){
        systemAdminUser = AP_UserProvisioningProcess_TEST_UTIL.createGenericSystemAdmin(SYSADMIN_USER_ID);
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        TestData_SalesRoleHierarchy salesRoleHierarchy = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('A');
        agentRoleCreation = new List<AgentRole__c>();
        Test.startTest();
        account = new Account(FirstName='FAccount',LastName='LAccount',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='SFFSP81L8XB');
        System.runAs(systemAdminUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert account;
            agentRoleCreation.add(new AgentRole__c(Agent__c=salesRoleHierarchy.Agent.Id, RelationshipNature__c=CUSTOMER,Customer__c=account.Id));
            insert agentRoleCreation;
            agentRoleCreation=[select id,Agent__r.Proxy_External_ID__c from Agentrole__c where id = :agentRoleCreation];
            agentProxyMap=UTIL_AgentOfficeDetails.getMapOfAgentAndProxyIds(agentRoleCreation);
        }
        Test.stopTest();
        system.assert(agentProxyMap.containsKey(salesRoleHierarchy.Agent.Id), 'Map should contain the given key');
        system.assertEquals(salesRoleHierarchy.AgentOffice.id, agentProxyMap.get(salesRoleHierarchy.Agent.Id), 'Expected parameter is not equals to the actual parameter');
    }

    /**
    * @method
    * Given a system admin user
    * When a agent SFDC Id is provided
    * Then it should return a map of agent id and proxy id
    * @name singleAgentIdWithProxyAvailable
    * @description Single Agent Id With Proxy Available
    */
    @isTest
    static void singleAgentIdWithProxyAvailable(){
        systemAdminUser = AP_UserProvisioningProcess_TEST_UTIL.createGenericSystemAdmin(SYSADMIN_USER_ID);
        TestData_SalesRoleHierarchy salesRoleHierarchy = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('A');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy.Agent);
        Test.startTest();
        System.runAs(salesRoleHierarchy.Agent){
            set<Id> agentUserList = new set<Id>{salesRoleHierarchy.Agent.Id};
            agentProxyMap=UTIL_AgentOfficeDetails.getAgentProxyMapForGivenAgentIds (agentUserList);
        }
        Test.stopTest();

        system.assert(agentProxyMap.containsKey(salesRoleHierarchy.Agent.Id), 'Map should contain the given key');
        system.assertEquals(salesRoleHierarchy.AgentOffice.id, agentProxyMap.get(salesRoleHierarchy.Agent.Id), 'Expected parameter is not equals to the actual parameter');
    }

    /**
    * @method
    * Given a system admin user
    * When multiple agent SFDC Ids are provided
    * Then it should return a map of agent ids and proxy ids
    * @name mutilpleAgentIdWithProxy
    * @description Multiple Agent Id With Proxy
    */
    @isTest
    static void mutilpleAgentIdWithProxy(){
        systemAdminUser = AP_UserProvisioningProcess_TEST_UTIL.createGenericSystemAdmin(SYSADMIN_USER_ID);
        TestData_SalesRoleHierarchy salesRoleHierarchy = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('A');
        TestData_SalesRoleHierarchy salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('B');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy.Agent);
        Test.startTest();
        System.runAs(salesRoleHierarchy.Agent){
            set<Id> agentUserList = new set<Id>{salesRoleHierarchy.Agent.Id,salesRoleHierarchy1.Agent.Id };
            agentProxyMap=UTIL_AgentOfficeDetails.getAgentProxyMapForGivenAgentIds (agentUserList);
        }
        Test.stopTest();

        system.assert(agentProxyMap.containsKey(salesRoleHierarchy.Agent.Id), 'Mapshould contain the given key');
        system.assertEquals(salesRoleHierarchy.AgentOffice.id, agentProxyMap.get(salesRoleHierarchy.Agent.Id), 'Expected parameter is not equals to the actual parameter');
        system.assertEquals(salesRoleHierarchy1.AgentOffice.id, agentProxyMap.get(salesRoleHierarchy1.Agent.Id), 'Expected parameter is not equals to the actual parameter');
    }

    /**
    * @method
    * Given a system admin user
    * When multiple agent SFDC Ids with one of agent's office is invalid
    * Then it should return a map of agent id and proxy id and exception is being logged for the invalid agent office
    * @name mutilpleAgentIdWithInvalidProxyId
    * @description Mutilple Agent Id With Invalid Proxy Id
    */
    @isTest
    static void mutilpleAgentIdWithInvalidProxyId(){
        systemAdminUser = AP_UserProvisioningProcess_TEST_UTIL.createGenericSystemAdmin(SYSADMIN_USER_ID);
        TestData_SalesRoleHierarchy salesRoleHierarchy = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('A');
        TestData_SalesRoleHierarchy salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('B');
         salesRoleHierarchy1.AgentOffice.UserExternalID__c='B';
         TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy.AgentTeamMember);
        Test.startTest();
        System.runAs(systemAdminUser){
            update salesRoleHierarchy1.AgentOffice;
        }System.runAs(salesRoleHierarchy.AgentTeamMember){
            set<Id> agentUserList = new set<Id>{salesRoleHierarchy.Agent.Id,salesRoleHierarchy1.Agent.Id };
            agentProxyMap=UTIL_AgentOfficeDetails.getAgentProxyMapForGivenAgentIds (agentUserList);
        }
        Test.stopTest();

        system.assert(agentProxyMap.containsKey(salesRoleHierarchy.Agent.Id), 'Map should contain the given key');
        system.assertEquals(salesRoleHierarchy.AgentOffice.id, agentProxyMap.get(salesRoleHierarchy.Agent.Id), 'Expected parameter is not equals to the actual parameter');

        ExceptionLog__c actualException=[SELECT Id, Class__c, Exception_Message__c, Exception_Type__c, Method__c, Severity__c FROM ExceptionLog__c];
        system.assertEquals('UTIL_AgentOfficeDetails', actualException.Class__c, 'Class__c should be UTIL_AgentOfficeDetails');
        system.assertEquals('ProxyUserNotFoundException', actualException.Exception_Type__c, 'Exception_Type__c should be ProxyUserNotFoundException');
        system.assertEquals('getMapOfAgentAndProxyIds', actualException.Method__c, 'Method__c should be getMapOfAgentAndProxyIds');
        system.assertEquals('ASSOCIDs: {'+salesRoleHierarchy1.Agent.UserExternalID__c+'}', actualException.Exception_Message__c, 'Expected parameter is not equals to the actual parameter');
        system.assertEquals('WARN', actualException.Severity__c, 'Severity__c should be WARN');
    }

    /**
    * @method
    * Given a ccc licensed user
    * When a agent associate id is provided
    * Then it should return the proxy user record id
    * @name   agentRoleWithProxyFound
    * @description Agent Role With Proxy Found
    */
    @isTest
    static void agentRoleWithProxyFound(){
        User testCCCLicUser =  new User(Username=UTIL_TestUsername_TEST.getTestUsername('cccLicsU'),Alias='CCCL',Associate_ID__c='1111TEST321',UserExternalID__c='1111TEST321');
        user cccLicensedUser=AP_UserProvisioningProcess_TEST_UTIL.buildcccLincensedUserRecord(testCCCLicUser);
        TestData_SalesRoleHierarchy salesRoleHierarchy = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('A');
        user proxyUserRecord;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccLicensedUser);
        Test.startTest();
        System.runAs(cccLicensedUser){
            user agentUser =[select UserExternalID__c,Servicing_Agent_Associate_ID__c from user where id = :salesRoleHierarchy.Agent.Id];
            proxyUserRecord=UTIL_AgentOfficeDetails.getProxyforGivenServicingAgentAssocId(agentUser.Servicing_Agent_Associate_ID__c);
            system.assertEquals(salesRoleHierarchy.AgentOffice.id, proxyUserRecord.Id, 'Expected id is not equals to the actual id');
        }
        Test.stopTest();
    }

    /**
    * @method
    * Given a ccc licensed user
    * When a agent associate id with invalid agent office is provided
    * Then an exception is being logged as proxy not found
    * @name   agentWithOutProxyException
    * @description Agent WithOut Proxy Exception
    */
    @isTest
    static void agentWithOutProxyException(){
        systemAdminUser = AP_UserProvisioningProcess_TEST_UTIL.createGenericSystemAdmin(SYSADMIN_USER_ID);
        User testCCCLicUser =  new User(Username=UTIL_TestUsername_TEST.getTestUsername('cccLicsUS'),Alias='CCCL',Associate_ID__c='1111TEST321',UserExternalID__c='1111TEST321');
        user cccLicensedUser=AP_UserProvisioningProcess_TEST_UTIL.buildcccLincensedUserRecord(testCCCLicUser);
        TestData_SalesRoleHierarchy salesRoleHierarchy = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('A');
        salesRoleHierarchy.AgentOffice.UserExternalID__c='B';
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccLicensedUser);
        System.runAs(systemAdminUser){
            update salesRoleHierarchy.AgentOffice;
        }
        Test.startTest();
        System.runAs(cccLicensedUser){
            user agentUser =[select id,UserExternalID__c,Servicing_Agent_Associate_ID__c from user where id = :salesRoleHierarchy.Agent.Id];
            try{
                UTIL_AgentOfficeDetails.getProxyforGivenServicingAgentAssocId(agentUser.Servicing_Agent_Associate_ID__c);
                system.assert(false, 'Assertion returns true');
            }catch(exception ex){
                system.assert(true, 'Assertion returns false');
                system.assertEquals('Proxy User not found: 1111111111A', ex.getMessage(), 'Proxy User found');
            }
        }
        Test.stopTest();
    }

    /**
    * @method
    * Given a System admin user
    * When agent ids list is provided
    * Then it should return a map of proxy ids and agent ids
    * @name   testcaseCreatedbyAgentUser
    * @description Mutilple Agent Roles Proxy List
    */
    @isTest
    static void mutilpleAgentRolesProxyList(){
        systemAdminUser = AP_UserProvisioningProcess_TEST_UTIL.createGenericSystemAdmin(SYSADMIN_USER_ID);
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        TestData_SalesRoleHierarchy salesRoleHierarchy = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('A');
        TestData_SalesRoleHierarchy salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('B');
        agentRoleCreation = new List<AgentRole__c>();
        Test.startTest();
        account = new Account(FirstName='FAccount2',LastName='LAccount2',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='SSSSP81L8XV');
        System.runAs(systemAdminUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert account;
            agentRoleCreation.add(new AgentRole__c(Agent__c=salesRoleHierarchy.Agent.Id, RelationshipNature__c=CUSTOMER,Customer__c=account.Id ));
            agentRoleCreation.add(new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c=CUSTOMER,Customer__c=account.Id ));
            insert agentRoleCreation;
            agentRoleCreation=[select id,Agent__r.Proxy_External_ID__c from Agentrole__c where id IN :agentRoleCreation];
            agentProxyMap=UTIL_AgentOfficeDetails.getMapOfAgentAndProxyIds(agentRoleCreation);
        }
        Test.stopTest();
        system.assert(agentProxyMap.containsKey(salesRoleHierarchy.Agent.Id), 'Map should contain the given key');
        system.assertEquals(salesRoleHierarchy.AgentOffice.id, agentProxyMap.get(salesRoleHierarchy.Agent.Id), 'Expected id is not equals to the actual id');
        system.assertEquals(salesRoleHierarchy1.AgentOffice.id, agentProxyMap.get(salesRoleHierarchy1.Agent.Id), 'Expected id is not equals to the actual id');
    }

    /**
    * @method
    * Given a System admin user
    * When agent ids list is provided with one of agent's office is invalid
    * Then it should return a map of proxy ids and agent ids and exception is logged for invalid agent's office
    * @name   testcaseCreatedbyAgentUser
    * @description Mutiple Agent Roles With Single Proxy List
    */
    @isTest
    static void mutipleAgentRolesWithSingleProxyList(){
        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=false);
        insert passTriggerAll;
        passTriggerAll = [select Override_All__c from CS001_ByPassTriggerAll__c];
        passTriggerAll.Override_All__c = true;
        systemAdminUser = AP_UserProvisioningProcess_TEST_UTIL.createGenericSystemAdmin(SYSADMIN_USER_ID);
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        TestData_SalesRoleHierarchy salesRoleHierarchy = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('A');
        TestData_SalesRoleHierarchy salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('C');
        salesRoleHierarchy1.AgentOffice.UserExternalID__c='P';
        agentRoleCreation = new List<AgentRole__c>();
        Test.startTest();
        account = new Account(FirstName='FAccount2',LastName='LAccount2',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='SSSSP81L8XV');
        System.runAs(systemAdminUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert account;
            update salesRoleHierarchy1.AgentOffice;
            agentRoleCreation.add(new AgentRole__c(Agent__c=salesRoleHierarchy.Agent.Id, RelationshipNature__c=CUSTOMER,Customer__c=account.Id));
            update passTriggerAll;
            agentRoleCreation.add(new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c=CUSTOMER,Customer__c=account.Id));
            insert agentRoleCreation;
            agentRoleCreation=[select id,Agent__r.Proxy_External_ID__c,Agent__r.UserExternalID__c from Agentrole__c where id IN :agentRoleCreation];
            agentProxyMap=UTIL_AgentOfficeDetails.getMapOfAgentAndProxyIds(agentRoleCreation);
        }
        Test.stopTest();
        system.assert(agentProxyMap.containsKey(salesRoleHierarchy.Agent.Id), 'Map should contain the given id');
        system.assertEquals(salesRoleHierarchy.AgentOffice.id, agentProxyMap.get(salesRoleHierarchy.Agent.Id), 'Expected id is not equals to the actual id');
        ExceptionLog__c actualException=[SELECT Id, Class__c, Exception_Message__c, Exception_Type__c, Method__c, Severity__c FROM ExceptionLog__c];
        system.assertEquals('UTIL_AgentOfficeDetails', actualException.Class__c, 'Class__c should be UTIL_AgentOfficeDetails');
        system.assertEquals('getMapOfAgentAndProxyIds', actualException.Method__c, 'Method__c should be getMapOfAgentAndProxyIds');
        system.assertEquals('WARN', actualException.Severity__c, 'Severity__c should be WARN');
        system.assertEquals('ProxyUserNotFoundException', actualException.Exception_Type__c, 'Exception_Type__c should be ProxyUserNotFoundException');
        system.assertEquals('ASSOCIDs: {'+salesRoleHierarchy1.Agent.UserExternalID__c+'}', actualException.Exception_Message__c, 'Expected parameter is should be equals to the actual parameter');
    }
}