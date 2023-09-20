/**
 * @name PrimaryHousehold_TEST
 * @author : Targaryen
 * @date : 11/01/2021
 * @description : Added for Agency, CCC Licensed and UnLicensed Users and Caching Scenarios for CCC Users
 */

@isTest(seeAllData=false)
public with sharing class UTIL_RemoveFromBook_TEST {
    private static DAOMock_AccountCreateEditHelper daoMockHelperInstance = new DAOMock_AccountCreateEditHelper();
    public static final String INDIVIDUAL_RECORD_TYPE = 'Individual';
    private static final String SYSADMIN_USER_ID = UTIL_TestUsername_TEST.getTestUsername('sysadmin');
    
    @TestSetup
    static void makeData() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;
        
        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false,SystemUser);
        insert passTriggerAll;
        
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemUser);
        objectBasedByPassTrigger.Override_AgentRoleAfterInsert__c = false;
        objectBasedByPassTrigger.Override_AgentRoleBeforeDelete__c = false;
        
        insert objectBasedByPassTrigger;
        
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
        insert sysAdminUserIdSetting;

        insertTechnicalPlatformDetails();
    }
    
    private static Account hhAccRec;

    private static account accRecord = new Account(
        FirstName = 'FNameForPrimaryHousehold',
        LastName = 'LNameForPrimaryHousehold',        
        recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(INDIVIDUAL_RECORD_TYPE).getRecordTypeId(),
        BillingAddressType__c = 'US',
        BillingCity = 'TX',
        ClientIdentifier__c = 'C2CSP81L8XB'
    );
   
    @isTest
    public static void testGetLoggedInContextForRFBWithHouseHold() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemAdminUser= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
            insert systemAdminUser;
            TestData_SalesRoleHierarchy salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('X');
            
            User agentUser = [SELECT Id,Associate_ID__c,Name from User where Id = :salesRoleHierarchy1.agent.id];
            System.runAs(systemAdminUser) {
           
            insert accRecord;
            
            Id hhRecordtype = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName()
                .get('IndustriesHousehold')
                .getRecordTypeId();

            hhAccRec = new Account(Name = 'Household', recordTypeId = hhRecordtype, AllowHousehold__c = true);
            insert hhAccRec;

            accRecord.Primary_Household__pc = hhAccRec.id;
            update accRecord;
            
            AgentRole__c agtRole = new AgentRole__c(
                Agent__c = agentUser.Id,
                RelationshipNature__c = 'Prospect',
                Customer__c = accRecord.Id,
                Primary_Household__c = hhAccRec.Id
            );
            insert agtRole;
        }
        List<AgentRole__c> agentRoleList = new List<AgentRole__c>();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.agent);
        System.runAs(salesRoleHierarchy1.agent){
            Test.startTest();
            agentRoleList = UTIL_RemoveFromBook.getLoggedInContextForRFB(accRecord.id,agentUser.Associate_ID__c);
            Test.stopTest();
        }
        System.assertEquals(accRecord.FirstName+' '+accRecord.LastName,agentRoleList[0].Customer__r.Name, 'Account name are not equal');
        System.assertEquals(agentUser.Name,agentRoleList[0].Agent__r.Name, 'Agent name are not equal');
        System.assert(!agentRoleList.isEmpty(), 'agentRoleList is Empty');
        System.assertEquals(agentUser.Associate_ID__c, agentRoleList[0].Agent__r.Associate_ID__c, 'Agent name are not equal');
    }
    
    @isTest
    public static void testGetLoggedInContextNull() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemAdminUser= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
            insert systemAdminUser;
            TestData_SalesRoleHierarchy salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('X');
            
            User agentUser = [SELECT Id,Associate_ID__c,Name from User where Id = :salesRoleHierarchy1.agent.id];
            System.runAs(systemAdminUser) {
           
            insert accRecord;
            
            Id hhRecordtype = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName()
                .get('IndustriesHousehold')
                .getRecordTypeId();

            hhAccRec = new Account(Name = 'Household', recordTypeId = hhRecordtype, AllowHousehold__c = true);
            insert hhAccRec;

            accRecord.Primary_Household__pc = hhAccRec.id;
            update accRecord;
            
            AgentRole__c agtRole = new AgentRole__c(
                Agent__c = agentUser.Id,
                RelationshipNature__c = 'Prospect',
                Customer__c = accRecord.Id,
                Primary_Household__c = hhAccRec.Id
            );
            insert agtRole;
        }
        List<AgentRole__c> agentRoleList = new List<AgentRole__c>();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.agent);
        System.runAs(salesRoleHierarchy1.agent){
            Test.startTest();
            Try{
                agentRoleList = UTIL_RemoveFromBook.getLoggedInContextForRFB(null,null);
            }catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Exception thrown');
        }
            
            Test.stopTest();
        }
    }
    
     @isTest
    public static void testGetLoggedInContextForRFBWithoutHouseHold() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            User systemAdminUser= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
            insert systemAdminUser;
            TestData_SalesRoleHierarchy salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('X');
            //TestData_SalesRoleHierarchy salesRoleHierarchy2 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('Y');
            User agentUser = [SELECT Id,Associate_ID__c,Name from User where Id = :salesRoleHierarchy1.agent.id];
        System.runAs(systemAdminUser) {
            insert accRecord;
            AgentRole__c agtRole = new AgentRole__c(
                Agent__c = salesRoleHierarchy1.Agent.Id,
                RelationshipNature__c = 'Prospect',
                RelationshipStartDate__c = System.today(),
                Customer__c = accRecord.Id
            );
            insert agtRole;
        }
        List<AgentRole__c> agentRoleList = new List<AgentRole__c>();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.agent);
        System.runAs(salesRoleHierarchy1.agent){
            Test.startTest();
            agentRoleList = UTIL_RemoveFromBook.getLoggedInContextForRFB(accRecord.id,agentUser.Associate_ID__c);
            Test.stopTest();
        }
        System.assert(!agentRoleList.isEmpty(), 'agentRoleList is Empty');
    }
    
    @isTest
    public static void testProcessRemoveFromBook() {
        
         UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemAdminUser= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
            insert systemAdminUser;
            TestData_SalesRoleHierarchy salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('X');
            TestData_SalesRoleHierarchy salesRoleHierarchy2 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('Y');
            Account accountForAgentRole = new Account(FirstName='FaccountForAgentRole',LastName='LaccountForAgentRole',BillingAddressType__c='US',BillingCity='Bloomington',ClientIdentifier__c='SFFSP81LXYZ');
            System.runAs(systemAdminUser){
                insert accountForAgentRole;
            } 
            User testAgentUser = new User(Alias='ALIAS',LastName='LastName',Username='username@statefarm.com',Associate_ID__c='97PBB1YS000',UserExternalID__c='97PBB1YS000',Servicing_Agent_Associate_ID__c='97PBB1YS000',Territory_Associate_ID__c='TERRITORYID',Servicing_Agent_Associate_ID_List__c='ASSOCID',Territory_Associate_ID_List__c='TERRITORYID');
            User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser(testAgentUser);
            insert agentUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(systemAdminUser) {
            
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accRecord;
            AgentRole__c agtRole = new AgentRole__c(
                Agent__c = salesRoleHierarchy1.Agent.Id,
                RelationshipNature__c = 'Prospect',
                RelationshipStartDate__c = System.today(),
                Customer__c = accRecord.Id
            );
            insert agtRole;
            
            AgentRole__c agtRole1 = new AgentRole__c(
                Agent__c = salesRoleHierarchy1.Agent.Id,
                RelationshipNature__c = 'Prospect',
                RelationshipStartDate__c = System.today(),
                Customer__c = accRecord.Id
            );
            insert agtRole1;
          System.runAs(agentUser) {
            Test.startTest();
            HttpRequest testMockReq = new HttpRequest();
            testMockReq.setMethod(UTIL_CreateCustomerConstants.POST);
            testMockReq.setHeader('Content-Type', 'application/json');
              List<id> agtRoleList = new List<id>{agtRole.id,agtRole1.id};
            String agentRoleIdSerialized = JSON.serialize(agtRoleList);
               //System.debug(LoggingLevel.DEBUG,'agentRoleIdSerializedg '+agentRoleIdSerialized);
            Continuation cont = (Continuation)UTIL_RemoveFromBook.processRemoveFromBook(agentRoleIdSerialized);
            Map<String, HttpRequest> requests = cont.getRequests();
            List<object> objectList = new List<object>();
            object mockRequest = daoMockHelperInstance.getContinuationState(cont,testMockReq);
            objectList.add(mockRequest);
             System.assertEquals(1, requests.size(),'request size equals to 1');
            HttpResponse mockResponse = new HttpResponse();
            String responseString = '{"data": [   {"clientIdentifier": "7LBZBBT6XYC","associateId": "QZZL81YS000","errors": []},'+
                '{"clientIdentifier": "J0Y09BRDMYC","associateId": "QZZL81YS000","errors": [{"code":"500", "detail":"M2RNS    01 CLIENT CAN NOT BE REMOVED FROM AGENTS BOOK", "title":"Error Calling DB2 Stored Procedure"}]}],"errors": []}';
                
            String resultString = '{"rfbSuccessfulList": ["7LBZBBT6XYC-QZZL81YS000"],'+
                                 '"rfbUnSuccessfulList": ["J0Y09BRDMYC-QZZL81YS000-(RemoveFromBookErrors:[code=500, detail=M2RNS    01 CLIENT CAN NOT BE REMOVED FROM AGENTS BOOK, title=Error Calling DB2 Stored Procedure])"]}';
             
            mockResponse.setBody(responseString);
            mockResponse.setStatusCode(200);
            List<String> labels = new List<String>{responseString};
            UTIL_AccountCreateEditHelper.mockResponse = mockResponse;
        	daoMockHelperInstance.mockResponse = mockResponse;
            Object result = UTIL_RemoveFromBook.processRemoveFromBookAggregatorResponse(labels,mockResponse);            
            Test.stopTest();
          }
        }
    }
    
     @isTest
    public static void testRemoveFromBookStatusCode2000() {
        
         UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemAdminUser= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
            insert systemAdminUser;
            TestData_SalesRoleHierarchy salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('X');
            TestData_SalesRoleHierarchy salesRoleHierarchy2 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('Y');
            Account accountForAgentRole = new Account(FirstName='FaccountForAgentRole',LastName='LaccountForAgentRole',BillingAddressType__c='US',BillingCity='Bloomington',ClientIdentifier__c='SFFSP81LXYZ');
            System.runAs(systemAdminUser){
                insert accountForAgentRole;
            } 
            User testAgentUser = new User(Alias='ALIAS',LastName='LastName',Username='username@statefarm.com',Associate_ID__c='97PBB1YS000',UserExternalID__c='97PBB1YS000',Servicing_Agent_Associate_ID__c='97PBB1YS000',Territory_Associate_ID__c='TERRITORYID',Servicing_Agent_Associate_ID_List__c='ASSOCID',Territory_Associate_ID_List__c='TERRITORYID');
            User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser(testAgentUser);
            insert agentUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(systemAdminUser) {
            
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            insert accRecord;
            AgentRole__c agtRole = new AgentRole__c(
                Agent__c = salesRoleHierarchy1.Agent.Id,
                RelationshipNature__c = 'Prospect',
                RelationshipStartDate__c = System.today(),
                Customer__c = accRecord.Id
            );
            insert agtRole;
            
            AgentRole__c agtRole1 = new AgentRole__c(
                Agent__c = salesRoleHierarchy1.Agent.Id,
                RelationshipNature__c = 'Prospect',
                RelationshipStartDate__c = System.today(),
                Customer__c = accRecord.Id
            );
            insert agtRole1;
          System.runAs(agentUser) {
            Test.startTest();
            UTIL_RemoveFromBook rfbUtil = new UTIL_RemoveFromBook();
            HttpRequest testMockReq = new HttpRequest();
            testMockReq.setMethod(UTIL_CreateCustomerConstants.POST);
            testMockReq.setHeader('Content-Type', 'application/json');
              List<id> agtRoleList = new List<id>{agtRole.id,agtRole1.id};
            String agentRoleIdSerialized = JSON.serialize(agtRoleList);
               //System.debug(LoggingLevel.DEBUG,'agentRoleIdSerializedg '+agentRoleIdSerialized);
            Continuation cont = (Continuation)UTIL_RemoveFromBook.processRemoveFromBook(agentRoleIdSerialized);
            Map<String, HttpRequest> requests = cont.getRequests();
            List<object> objectList = new List<object>();
            object mockRequest = daoMockHelperInstance.getContinuationState(cont,testMockReq);
            objectList.add(mockRequest);
              System.assertEquals(1, requests.size(),'request size equals to 1');
            HttpResponse mockResponse = new HttpResponse();
            String responseString = '{"data": [   {"clientIdentifier": "7LBZBBT6XYC","associateId": "QZZL81YS000","errors": []},'+
                '{"clientIdentifier": "J0Y09BRDMYC","associateId": "QZZL81YS000","errors": [{"code":"500", "detail":"M2RNS    01 CLIENT CAN NOT BE REMOVED FROM AGENTS BOOK", "title":"Error Calling DB2 Stored Procedure"}]}],"errors": [{"code":"500", "detail":"M2RNS    01 CLIENT CAN NOT BE REMOVED FROM AGENTS BOOK", "title":"Error Calling DB2 Stored Procedure"}]}';
                
            String resultString = '{"rfbSuccessfulList": ["7LBZBBT6XYC-QZZL81YS000"],'+
                                 '"rfbUnSuccessfulList": ["J0Y09BRDMYC-QZZL81YS000-(RemoveFromBookErrors:[code=500, detail=M2RNS    01 CLIENT CAN NOT BE REMOVED FROM AGENTS BOOK, title=Error Calling DB2 Stored Procedure])"]}';
             
            mockResponse.setBody(responseString);
            mockResponse.setStatusCode(2001);
            List<String> labels = new List<String>{responseString};
            UTIL_AccountCreateEditHelper.mockResponse = mockResponse;
        	daoMockHelperInstance.mockResponse = mockResponse;
            Object result = UTIL_RemoveFromBook.processRemoveFromBookAggregatorResponse(labels,mockResponse);
            Test.stopTest();
          }
        }
    }
    
    private static  void insertTechnicalPlatformDetails(){
        CS_TechnicalPlatform__c srKey = new CS_TechnicalPlatform__c();
        srKey.Name = 'SR_API_KEY';
        srKey.Value__c = 'Test Key';
        
        CS_TechnicalPlatform__c srCategory = new CS_TechnicalPlatform__c();
        srCategory.Name = 'SR_CATEGORY';
        srCategory.Value__c = 'a';
        insert new List<CS_TechnicalPlatform__c>{srKey, srCategory};

        CS_EnvironmentURLCustomSetting__c envURL = new CS_EnvironmentURLCustomSetting__c(Name = 'S1BaseUrl', Value__c = 'TestURL');
        insert envURL;
    }
    
}