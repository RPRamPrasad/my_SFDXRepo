/**
* @author Team Atlas
* @owner Team Atlas
* @name UTIL_AccountCreateEdit_TEST
* @createDate 06/19/2020
* @description Common class to access various Account related Agent and CCC operations TEST.
* @version 1.0
*/
@isTest
private class UTIL_AccountCreateEdit_TEST {

    private static DAOMock_AccountCreateEditHelper daoMockHelperInstance = new DAOMock_AccountCreateEditHelper();
    private static UTIL_AccountDAOMock daoMockAccountInstance = new UTIL_AccountDAOMock();
    private static User commonAgentUser = new User(Alias='ALIAS',LastName='LastName',Username='username@statefarm.com',Associate_ID__c='ASSOCID',UserExternalID__c='ASSOCID',Servicing_Agent_Associate_ID__c='ASSOCID',Territory_Associate_ID__c='TERRITORYID',Servicing_Agent_Associate_ID_List__c='ASSOCID',Territory_Associate_ID_List__c='TERRITORYID');
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
    
    /**
    * @description Inner class is used wrapper for Servicing Agent
    * @name : ServicingAgent
    */
    public class Customer {
        Id id;
        String clientId;
    }

    @isTest static void testGetData() {        

        TestData_SalesRoleHierarchy salesRoleHierarchy = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy.agent);
        System.runAs(salesRoleHierarchy.agent){
            Test.startTest();        
            List<String> canList = UTIL_AccountCreateEdit.getStateProvinceData('CANADA');
            System.assertEquals(false, canList.isEmpty(),'Province List Canada');

            List<String> usList = UTIL_AccountCreateEdit.getStateProvinceData('US');
            System.assertEquals(false, usList.isEmpty(),'State List US');

            List<String> milList = UTIL_AccountCreateEdit.getStateProvinceData('Overseas Military');
            System.assertEquals(false, milList.isEmpty(),'State List Overseas Militry');

            List<String> milCityList = UTIL_AccountCreateEdit.getMilitaryCityData();
            System.assertEquals(false, milCityList.isEmpty(),'Militry City Data');
            
            CS_Customer_Suffix__c suffixCS = new CS_Customer_Suffix__c();
            suffixCS.Name = 'Jr';
            suffixCS.Sequence_Number__c = 1;
            insert suffixCS;

            List<String> sufList = UTIL_AccountCreateEdit.getSuffixOptions();
            System.assertEquals(1, sufList.size(),'Suffix data');

            List<RecordType> rtList = UTIL_AccountCreateEdit.fetchCustomerRecordTypes();
            System.assertEquals(false, rtList.isEmpty(),'Account Recordtype Data');
            
            UTIL_AccountCreateEdit.logError('exceptionMessage','className','methodName', 'INFO');
            System.assertEquals('', '', 'Throws account exception');

            UTIL_AccountCreateEdit.logError('exceptionMessage','className','methodName', 'WARN');
            System.assertEquals('', '', 'Throws account exception');

            UTIL_AccountCreateEdit.logError('exceptionMessage','className','methodName', 'ERROR');        
            Test.stopTest();
        }
    }
    
    @isTest static void testUpdateCustomerRecord() {
        User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser(commonAgentUser);
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        Account acct = (Account) JSON.deserializeStrict(createIndividualWithValues(),Account.class);
        acct.IsPrivacyOptionsShared__c= true;
        acct.ClientIdentifier__c = 'SGGSP81L8XB';
        acct.id = Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix() + '0'.repeat(11) + '1';
        daoMockHelperInstance.acct = acct;
        daoMockAccountInstance.clntIdToAcctIdMap.put(acct.clientidentifier__c, acct.id);
        System.runAs(agentUser) {
        	Test.startTest();
            UTIL_AccountCreateEdit.daoInstance = daoMockAccountInstance;
            Account uptAccount = new Account();
            uptAccount.Id = acct.Id;
            uptAccount.ClientIdentifier__c = acct.ClientIdentifier__c;
            uptAccount.Edit_In_VFP__c = true;
            uptAccount.LivingArrangements__c = 'Rent';
            String accountJSON = JSON.serialize(uptAccount);
            List<object> objectList = new List<object>();
            object result = UTIL_AccountCreateEdit.updateCustomerRecord(accountJSON);
            objectList.add(result);
            UTIL_AccountDAOMock newInstance = (UTIL_AccountDAOMock) UTIL_AccountCreateEdit.daoInstance;
            Account cust = (Account) newInstance.argCapture.get('updateCustomerRec');
            System.assertEquals('Rent', cust.LivingArrangements__c,'verify living arrangement');
            System.assertEquals(String.valueOf(acct.Id),String.valueOf(cust.id),'Update Account');
            
        	Test.stopTest();
        }
    }
    
    @isTest static void testValidateAndSaveCreateIndividual() {
        User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser(commonAgentUser);
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        daoMockHelperInstance.isCCCUser = false;
        Account acct = (Account) JSON.deserializeStrict(createIndividualWithValues(),Account.class);
        acct.IsPrivacyOptionsShared__c= true;
        acct.ClientIdentifier__c = 'SGGSP81L8XB';
        acct.id = Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix() + '0'.repeat(11) + '1';
        daoMockHelperInstance.acct = acct;
        daoMockAccountInstance.clntIdToAcctIdMap.put(acct.clientidentifier__c, acct.id);
        System.runAs(agentUser) {
            Test.startTest();
            UTIL_AccountCreateEdit.helperDAOInstance = daoMockHelperInstance;
            UTIL_AccountCreateEdit.daoInstance = daoMockAccountInstance;
            HttpRequest testMockReq = new HttpRequest();
            testMockReq.setMethod(UTIL_CreateCustomerConstants.POST);
            testMockReq.setHeader('Content-Type', 'application/json');
            String newAccountJSON = createIndividualWithValues();
            String accountJSON = createAccountJSON(null,newAccountJSON);
            String reqJSON = createReqJSON();
            Boolean isNewCustomer = true;
            Continuation cont = (Continuation)UTIL_AccountCreateEdit.validateAndSave(accountJSON,reqJSON,isNewCustomer);
            Map<String, HttpRequest> requests = cont.getRequests();
            List<object> objectList = new List<object>();
            object mockRequest = daoMockHelperInstance.getContinuationState(cont,testMockReq);
            objectList.add(mockRequest);
            System.assertEquals(1, requests.size(),'request size equals to 1');

            HttpResponse mockResponse = new HttpResponse();
            String responseString = '{"data":{"type":"customer","clientId":"SGGSP81L8XB","attributes":{"customerType":"Individual","individualCustomer":' +
                '{"individualName":{"prefix": "MR","firstName": "SARAH","middleName": "NE","lastName": "DAVIS","suffix": "1ST","designation": "DDS"}},' + 
                '"mailingAddress":{"addressType": "Us","street1":"1028 GOLDFINCH WAY","street2":"APT 5","city":"BLOOMINGTON","state": "IL","postalCode": "61714","country":"UNITED STATES"}}}}';
            mockResponse.setBody(responseString);
            mockResponse.setStatusCode(200);
            List<String> labels = new List<String>{responseString};
            UTIL_AccountCreateEditHelper.mockResponse = mockResponse;
            daoMockHelperInstance.mockResponse = mockResponse;
            daoMockHelperInstance.acct = new Account(Id=acct.Id);
            daoMockHelperInstance.acct = daoMockHelperInstance.getAccountDetails(acct.Id);
            Object result = UTIL_AccountCreateEdit.processCustAggResponse(labels,mockResponse);
            Customer cust = (Customer) JSON.deserialize(String.valueOf(result), Customer.class);
        	System.assert(String.valueOf(cust.id).startsWith(Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix()),'Account is created');

            Test.stopTest();
        }
    }
    @isTest static void testCreateIndividualAccountWithGroupIdParameter() {
        daoMockHelperInstance.isCCCUser = false;
        Account acct = (Account) JSON.deserializeStrict(createIndividualWithValues(),Account.class);
        acct.IsPrivacyOptionsShared__c= true;
        acct.ClientIdentifier__c = 'SGGSP81L8XB';
        acct.id = Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix() + '0'.repeat(11) + '1';
        daoMockHelperInstance.acct = acct;
        daoMockAccountInstance.clntIdToAcctIdMap.put(acct.clientidentifier__c, acct.id);
        TestData_SalesRoleHierarchy salesRoleHierarchy = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy.agent);
        System.runAs(salesRoleHierarchy.agent){
            Test.startTest();            
            UTIL_AccountCreateEdit.helperDAOInstance = daoMockHelperInstance;
            UTIL_AccountCreateEdit.daoInstance = daoMockAccountInstance;
            HttpRequest testMockReq = new HttpRequest();
            testMockReq.setMethod(UTIL_CreateCustomerConstants.POST);
            testMockReq.setHeader('Content-Type', 'application/json');
            String newAccountJSON = createIndividualWithValues();
            String accountJSON = createAccountJSON(null,newAccountJSON);
            String reqJSON = createReqJSON();
            Boolean isNewCustomer = true;
            Continuation cont = (Continuation)UTIL_AccountCreateEdit.validateAndSave(accountJSON,reqJSON,isNewCustomer);
            Map<String, HttpRequest> requests = cont.getRequests();
            List<object> objectList = new List<object>();
            object mockRequest = daoMockHelperInstance.getContinuationState(cont,testMockReq);
            objectList.add(mockRequest);
            System.assertEquals(1, requests.size(),'request size equals to 1');

            HttpResponse mockResponse = new HttpResponse();
            String responseString = '{"data":{"type":"customer","clientId":"SGGSP81L8XB","attributes":{"customerType":"Organization","organizationCustomer":{"organizationName":"CREATE ORG INC"},' + 
                '"mailingAddress":{"addressType": "Us","street1":"1028 GOLDFINCH WAY","street2":"APT 5","city":"BLOOMINGTON","state": "IL","postalCode": "61714","country":"UNITED STATES"}},' +
                '"relationships":{"agents":{"data":[{"id":"TestName","type":"ASSOCIATE","groupId": "J612L8RX6XA","attributes":{"relationshipNature":"Ex-Client","relationshipStartDate":"2013-12-31"}}]}}}}';
            
            mockResponse.setBody(responseString);
            mockResponse.setStatusCode(200);
            List<String> labels = new List<String>{responseString};
            UTIL_AccountCreateEditHelper.mockResponse = mockResponse;
            daoMockHelperInstance.mockResponse = mockResponse;
            daoMockHelperInstance.acct = new Account(Id=acct.Id);
            daoMockHelperInstance.acct = daoMockHelperInstance.getAccountDetails(acct.Id);
            Object result = UTIL_AccountCreateEdit.processCustAggResponse(labels,mockResponse);
            Customer cust = (Customer) JSON.deserialize(String.valueOf(result), Customer.class);
            System.assert(String.valueOf(cust.id).startsWith(Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix()),'Account is created');
            Test.stopTest();
        }        
    }
    @isTest static void testValidateAndSaveCreateOrganization() {
        daoMockHelperInstance.isCCCUser = false;
        Account acct = (Account) JSON.deserializeStrict(createIndividualWithValues(),Account.class);
        acct.IsPrivacyOptionsShared__c= true;
        acct.ClientIdentifier__c = 'SGGSP81L8XB';
        acct.id = Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix() + '0'.repeat(11) + '1';
        daoMockHelperInstance.acct = acct;
        daoMockAccountInstance.clntIdToAcctIdMap.put(acct.clientidentifier__c, acct.id);
        TestData_SalesRoleHierarchy salesRoleHierarchy = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy.agent);
        System.runAs(salesRoleHierarchy.agent){
            Test.startTest();                        
            UTIL_AccountCreateEdit.helperDAOInstance = daoMockHelperInstance;
            UTIL_AccountCreateEdit.daoInstance = daoMockAccountInstance;
            HttpRequest testMockReq = new HttpRequest();
            testMockReq.setMethod(UTIL_CreateCustomerConstants.POST);
            testMockReq.setHeader('Content-Type', 'application/json');
            String newAccountJSON = createOrganizationWithValues();
            String accountJSON = createAccountJSON(null,newAccountJSON);
            String reqJSON = createReqJSON();
            Boolean isNewCustomer = true;
            Continuation cont = (Continuation)UTIL_AccountCreateEdit.validateAndSave(accountJSON,reqJSON,isNewCustomer);
            Map<String, HttpRequest> requests = cont.getRequests();
            List<object> objectList = new List<object>();
            object mockRequest = daoMockHelperInstance.getContinuationState(cont,testMockReq);
            objectList.add(mockRequest);
            System.assertEquals(1, requests.size(),'request size equals to 1');

            HttpResponse mockResponse = new HttpResponse();
            String responseString = '{"data":{"type":"customer","clientId":"SGGSP81L8XB","attributes":{"customerType":"Organization","organizationCustomer":{"organizationName":"CREATE ORG INC"},' + 
                '"mailingAddress":{"addressType": "Us","street1":"1028 GOLDFINCH WAY","street2":"APT 5","city":"BLOOMINGTON","state": "IL","postalCode": "61714","country":"UNITED STATES"}},' +
                '"relationships":{"agents":{"data":[{"id":"BZCWX1YS000","type":"ASSOCIATE","attributes":{"relationshipNature":"Ex-Client","relationshipStartDate":"2013-12-31"}},{"id":"HLGP84K3000",'+
                '"type":"ASSOCIATE","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2014-07-09"}},{"id":"29VXY1YS000","type":"ASSOCIATE","attributes":'+
                '{"relationshipNature":"Client","relationshipStartDate":"2015-02-10"}},{"id":"J0X494K7000","type":"ASSOCIATE","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2013-07-22"}},'+
                '{"id":"5ZZFQ1YS000","type":"ASSOCIATE","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2017-04-10"}}]}}}}';
            
            mockResponse.setBody(responseString);
            mockResponse.setStatusCode(200);
            List<String> labels = new List<String>{responseString};
            UTIL_AccountCreateEditHelper.mockResponse = mockResponse;
            daoMockHelperInstance.mockResponse = mockResponse;
            daoMockHelperInstance.acct = new Account(Id=acct.Id);
            daoMockHelperInstance.acct = daoMockHelperInstance.getAccountDetails(acct.Id);
            Object result = UTIL_AccountCreateEdit.processCustAggResponse(labels,mockResponse);
            Customer cust = (Customer) JSON.deserialize(String.valueOf(result), Customer.class);
            System.assert(String.valueOf(cust.id).startsWith(Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix()),'Account is created');            
            Test.stopTest();
        }
    }
    @isTest static void testCreateOrgAccountSuccessWithGroupId() {
        daoMockHelperInstance.isCCCUser = false;
        Account acct = (Account) JSON.deserializeStrict(createIndividualWithValues(),Account.class);
        acct.IsPrivacyOptionsShared__c= true;
        acct.ClientIdentifier__c = 'SGGSP81L8XB';
        acct.id = Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix() + '0'.repeat(11) + '1';
        daoMockHelperInstance.acct = acct;
        daoMockAccountInstance.clntIdToAcctIdMap.put(acct.clientidentifier__c, acct.id);
        TestData_SalesRoleHierarchy salesRoleHierarchy = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy.agent);
        Test.startTest();            
            System.runAs(salesRoleHierarchy.agent){
                UTIL_AccountCreateEdit.helperDAOInstance = daoMockHelperInstance;
                UTIL_AccountCreateEdit.daoInstance = daoMockAccountInstance;
                HttpRequest testMockReq = new HttpRequest();
                testMockReq.setMethod(UTIL_CreateCustomerConstants.POST);
                testMockReq.setHeader('Content-Type', 'application/json');
                String newAccountJSON = createOrganizationWithValues();
                String accountJSON = createAccountJSON(null,newAccountJSON);
                String reqJSON = createReqJSON();
                Boolean isNewCustomer = true;
                Continuation cont = (Continuation)UTIL_AccountCreateEdit.validateAndSave(accountJSON,reqJSON,isNewCustomer);
                Map<String, HttpRequest> requests = cont.getRequests();
                List<object> objectList = new List<object>();
                object mockRequest = daoMockHelperInstance.getContinuationState(cont,testMockReq);
                objectList.add(mockRequest);
                System.assertEquals(1, requests.size(),'request size equals to 1');

                HttpResponse mockResponse = new HttpResponse();
                String responseString = '{"data":{"type":"customer","clientId":"SGGSP81L8XB","attributes":{"customerType":"Organization","organizationCustomer":{"organizationName":"CREATE ORG INC"},' + 
                    '"mailingAddress":{"addressType": "Us","street1":"1028 GOLDFINCH WAY","street2":"APT 5","city":"BLOOMINGTON","state": "IL","postalCode": "61714","country":"UNITED STATES"}},' +
                    '"relationships":{"agents":{"data":[{"id":"TestName","type":"ASSOCIATE","groupId": "J612L8RX6XA","attributes":{"relationshipNature":"Ex-Client","relationshipStartDate":"2013-12-31"}}]}}}}';
            
                mockResponse.setBody(responseString);
                mockResponse.setStatusCode(200);
                List<String> labels = new List<String>{responseString};
                UTIL_AccountCreateEditHelper.mockResponse = mockResponse;
                daoMockHelperInstance.mockResponse = mockResponse;
                daoMockHelperInstance.acct = new Account(Id=acct.Id);
                daoMockHelperInstance.acct = daoMockHelperInstance.getAccountDetails(acct.Id);
                Object result = UTIL_AccountCreateEdit.processCustAggResponse(labels,mockResponse);
                Customer cust = (Customer) JSON.deserialize(String.valueOf(result), Customer.class);
                System.assert(String.valueOf(cust.id).startsWith(Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix()),'Account is created');
            }
        Test.stopTest();
    }
    @isTest static void testValidateAndSaveUpdateIndividual() {
        User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser(commonAgentUser);
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        daoMockHelperInstance.isCCCUser = false;
        Account acct = (Account) JSON.deserializeStrict(createIndividualWithValues(),Account.class);
        acct.IsPrivacyOptionsShared__c= true;
        acct.ClientIdentifier__c = 'SGGSP81L8XB';
        acct.Gender__pc = 'Female';
        acct.id = Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix() + '0'.repeat(11) + '1';
        daoMockHelperInstance.acct = acct;
        daoMockAccountInstance.clntIdToAcctIdMap.put(acct.clientidentifier__c, acct.id);
        System.runAs(agentUser) {
            Test.startTest();
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            UTIL_AccountCreateEdit.helperDAOInstance = daoMockHelperInstance;
            UTIL_AccountCreateEdit.daoInstance = daoMockAccountInstance;
            HttpRequest testMockReq = new HttpRequest();
            testMockReq.setMethod(UTIL_CreateCustomerConstants.PATCH);
            testMockReq.setHeader('Content-Type', 'application/json');
            String oldAccountJSON = JSON.serialize(updateIndividualWithValues());
            Account uptAccount = updateIndividualWithValues();
            uptAccount.Id = acct.Id;
        	uptAccount.IsPrivacyOptionsShared__c= true;
        	uptAccount.ClientIdentifier__c = 'SGGSP81L8XB';
            uptAccount.Gender__pc = 'Male';
            String newAccountJSON = JSON.serialize(uptAccount);
            String accountJSON = createAccountJSON(oldAccountJSON,newAccountJSON);
            String reqJSON = updateReqJSON();
            Boolean isNewCustomer = false;
            daoMockHelperInstance.acct = new Account(Id=acct.Id);
            daoMockHelperInstance.acct = daoMockHelperInstance.getAccountDetails(acct.Id);
            UTIL_AccountCreateEditHelper.mockAccount = acct;
            Continuation cont = (Continuation)UTIL_AccountCreateEdit.validateAndSave(accountJSON,reqJSON,isNewCustomer);
            Map<String, HttpRequest> requests = cont.getRequests();
            List<object> objectList = new List<object>();
            object mockRequest = daoMockHelperInstance.getContinuationState(cont,testMockReq);
            objectList.add(mockRequest);
            System.assertEquals(1, requests.size(),'request size equals to 1');

            HttpResponse mockResponse = new HttpResponse();
            String responseString = '{"data":{"type":"customer","clientId":"SGGSP81L8XB","attributes":{"customerType":"Individual","individualCustomer":' +
                '{"individualName":{"prefix": "MR","firstName": "SARAH","middleName": "NE","lastName": "DAVIS","suffix": "1ST","designation": "DDS"}},' + 
                '"mailingAddress":{"addressType": "Us","street1":"1028 GOLDFINCH WAY","street2":"APT 5","city":"BLOOMINGTON","state": "IL","postalCode": "61714","country":"UNITED STATES"}}}}';
            
            mockResponse.setBody(responseString);
            mockResponse.setStatusCode(200);
            List<String> labels = new List<String>{responseString};
            UTIL_AccountCreateEditHelper.mockResponse = mockResponse;
        	daoMockHelperInstance.mockResponse = mockResponse;
            Object result = UTIL_AccountCreateEdit.processCustAggResponse(labels,mockResponse);
        	Customer cust = (Customer) JSON.deserialize(String.valueOf(result), Customer.class);
        	UTIL_AccountDAOMock newInstance = (UTIL_AccountDAOMock) UTIL_AccountCreateEdit.daoInstance;
            Account custm = (Account) newInstance.argCapture.get('upsertCustomerRec');
            System.assertEquals('SARAH', custm.FirstName,'verify first name');
            System.assertEquals(String.valueOf(acct.Id),String.valueOf(cust.id),'Update Account');
            Test.stopTest();
       }
    }
    @isTest static void testValidateAndSaveGlobalOptInEmailText() {
        HLPR_CustAggtReqPatchInd.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.TOGGLE_NBA, true);
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
        User testAgentUser = new User(Alias='ALIAS',LastName='LastName',Username='username@statefarm.com',Associate_ID__c='97PBB1YS000',UserExternalID__c='97PBB1YS000',Servicing_Agent_Associate_ID__c='97PBB1YS000',Territory_Associate_ID__c='TERRITORYID',Servicing_Agent_Associate_ID_List__c='ASSOCID',Territory_Associate_ID_List__c='TERRITORYID');
        User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser(testAgentUser);
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(systemAdmin) {
            agentUser.UserCriteriaList__c = 'NBA_Treatment_ECRM_Agency';
            update agentUser;
            PermissionSet permSet1 = [select Id from PermissionSet where Name = 'NextBestAction'];
        	PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = agentUser.Id, PermissionSetId = permSet1.Id);
            insert psa1;
        }
        //TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        daoMockHelperInstance.isCCCUser = false;
        Account acct = (Account) JSON.deserializeStrict(createIndividualWithValues(),Account.class);
        acct.IsPrivacyOptionsShared__c= true;
        acct.ClientIdentifier__c = 'SGGSP81L8XB';
        acct.Gender__pc = 'Female';
        acct.id = Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix() + '0'.repeat(11) + '1';
        daoMockHelperInstance.acct = acct;
        daoMockAccountInstance.clntIdToAcctIdMap.put(acct.clientidentifier__c, acct.id);
        System.runAs(agentUser) {
            Test.startTest();
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            UTIL_AccountCreateEdit.helperDAOInstance = daoMockHelperInstance;
            UTIL_AccountCreateEdit.daoInstance = daoMockAccountInstance;
            HttpRequest testMockReq = new HttpRequest();
            testMockReq.setMethod(UTIL_CreateCustomerConstants.PATCH);
            testMockReq.setHeader('Content-Type', 'application/json');
            String oldAccountJSON = JSON.serialize(updateIndividualWithValues());
            Account uptAccount = updateIndividualWithValues();
            uptAccount.Id = acct.Id;
        	uptAccount.IsPrivacyOptionsShared__c= true;
        	uptAccount.ClientIdentifier__c = 'SGGSP81L8XB';
            uptAccount.Gender__pc = 'Male';
            String newAccountJSON = JSON.serialize(uptAccount);
            String accountJSON = createAccountJSON(oldAccountJSON,newAccountJSON);
            String reqJSON = '{"billingStreet1":"1234 Test Street", "billingStreet2":"Apt#4",'
            +'"billingAddStdCode":"C", "isMailingUpdated":false, "isResidenceUpdated":false, "joesiContext":"Marital status change","isJoesiCallNeeded":true,'
            +'"associateId":"TESTASSOC87", "agentAssociateId":"97PBB1YS000", "isUpdateAfterSearch":false,"isEmailValidationChanged":false, "OptInEmail":"Yes", "OptInText":"Yes"}';
            Boolean isNewCustomer = false;
            daoMockHelperInstance.acct = new Account(Id=acct.Id);
            daoMockHelperInstance.acct = daoMockHelperInstance.getAccountDetails(acct.Id);
            daoMockHelperInstance.mockIsActiveCustomer = daoMockHelperInstance.isActiveCustomer(agentUser.Associate_ID__c,acct.ClientIdentifier__c);
            UTIL_AccountCreateEditHelper.mockAccount = acct;
            UTIL_AccountCreateEditHelper.mockIsActiveCustomer = 1;
            Continuation cont = (Continuation)UTIL_AccountCreateEdit.validateAndSave(accountJSON,reqJSON,isNewCustomer);
            Map<String, HttpRequest> requests = cont.getRequests();
            List<object> objectList = new List<object>();
            object mockRequest = daoMockHelperInstance.getContinuationState(cont,testMockReq);
            objectList.add(mockRequest);
            System.assertEquals(1, requests.size(),'request size equals to 1');

            HttpResponse mockResponse = new HttpResponse();
            String responseString = '{"data":{"type":"customerPatch","clientId":"7GRMTB93VWD","attributes":{"customerType":"Individual","individualCustomer":{"deathNotificationReceived":"N","gender":"Male","maritalStatus":"Widowed","individualName":{"firstName":"JOE","lastName":"SEE"},"preferredFirstName":"JOESI"},'
            +'"mailingAddress":{"addressType":"US","street1":"3 STATE FARM PLAZA","city":"BLOOMINGTON","state":"IL","postalCode":"617910001","country":"UNITED STATES"},"doesNotHaveEmail":"N","preferences":[{"preferenceType":"preferredSpokenLanguage"},{"preferenceType":"contactPreference"},{"preferenceType":"doNotShareIndicator","preferenceValue":"N"},'
            +'{"preferenceType":"isSubjectToCASL","preferenceValue":"N"},{"preferenceType":"paperlessPrivacyNoticeIndicator","preferenceValue":"N"},{"preferenceType":"providedPrivacyOptions","preferenceValue":"Y"},{"preferenceType":"isProtectedPerson","preferenceValue":"N"},{"preferenceType":"Health Sourced","preferenceValue":"N"},{"preferenceType":"Health Prospect","preferenceValue":"N"},'
            +'{"preferenceType":"doNotCallIndicator","preferenceValue":"N"},{"preferenceType":"doNotMailIndicator","preferenceValue":"N"}]},"relationships":{"agents":{"data":[{"id":"W05XR1YS000","type":"associate","groupId":"G00ZPB93BWD","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2022-01-31"}},{"id":"97PBB1YS000","type":"associate","groupId":"ZHKL3B93YWD","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2022-01-31"}}]}},'
            +'"nbaResponse":{"data":[{"id":"temp Id","type":"temp type","attributes":{"client_id":"temp client id","interaction_id":"temp entrp interaction Id","context_type":"temp context type","salesforce":{"salesforce_account_id":"001Z000001XmiJeIAJ","associate_id_agent":"98765432109"},'
            +'"containerList":[{"experiment_name":"temp Experiment name","variation":"temp Variation","rankedResults":[{"identifier":"temp Identifier","direction":"Temp direction","treatment":"Temp treatment","actionID":"temp action id","placement":"temp placement","decisionTime":"Temp time ","propensity":"0.80","issue":"temp issue","interactionID":"temp interaction id","category":"Temp category","group":"temp group","rank":1,"subjectID":"temp subject id","variant":"temp varient","label":"temp label","name":"temp name","priority":"temp priority","channel":"temp Channel"}],"containerName":"Temp Contatiner Name","status":"temp Status"}],"status":"temp status"},"relationships":{"interaction":["temp ineraction"]}}]}}}';
            
            mockResponse.setBody(responseString);
            mockResponse.setStatusCode(200);
            List<String> labels = new List<String>{responseString};
            UTIL_AccountCreateEditHelper.mockResponse = mockResponse;
        	daoMockHelperInstance.mockResponse = mockResponse;
            Object result = UTIL_AccountCreateEdit.processCustAggResponse(labels,mockResponse);
        	Customer cust = (Customer) JSON.deserialize(String.valueOf(result), Customer.class);
        	UTIL_AccountDAOMock newInstance = (UTIL_AccountDAOMock) UTIL_AccountCreateEdit.daoInstance;
            Account custm = (Account) newInstance.argCapture.get('upsertCustomerRec');
            System.assertEquals('JOE', custm.FirstName,'verify first name');
            System.assertEquals(String.valueOf(acct.Id),String.valueOf(cust.id),'Update Account');
            Test.stopTest();
       }
    }
    @isTest static void testValidateAndSaveJoesiCallMaritalStatusChange() {
        //Toggle TOGGLE_NBA set to true
        HLPR_CustAggtReqPatchInd.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.TOGGLE_NBA, true);
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
        User testAgentUser = new User(Alias='ALIAS',LastName='LastName',Username='username@statefarm.com',Associate_ID__c='97PBB1YS000',UserExternalID__c='97PBB1YS000',Servicing_Agent_Associate_ID__c='97PBB1YS000',Territory_Associate_ID__c='TERRITORYID',Servicing_Agent_Associate_ID_List__c='ASSOCID',Territory_Associate_ID_List__c='TERRITORYID');
        User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser(testAgentUser);
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(systemAdmin) {
            agentUser.UserCriteriaList__c = 'NBA_Treatment_ECRM_Agency';
            update agentUser;
            PermissionSet permSet1 = [select Id from PermissionSet where Name = 'NextBestAction'];
        	PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = agentUser.Id, PermissionSetId = permSet1.Id);
            insert psa1;
        }
        daoMockHelperInstance.isCCCUser = false;
        Account acct = (Account) JSON.deserializeStrict(createIndividualWithValues(),Account.class);
        acct.IsPrivacyOptionsShared__c= true;
        acct.ClientIdentifier__c = 'SGGSP81L8XB';
        acct.Gender__pc = 'Female';
        acct.id = Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix() + '0'.repeat(11) + '1';
        daoMockHelperInstance.acct = acct;
        daoMockAccountInstance.clntIdToAcctIdMap.put(acct.clientidentifier__c, acct.id);
        System.runAs(agentUser) {
            Test.startTest();
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            UTIL_AccountCreateEdit.helperDAOInstance = daoMockHelperInstance;
            UTIL_AccountCreateEdit.daoInstance = daoMockAccountInstance;
            HttpRequest testMockReq = new HttpRequest();
            testMockReq.setMethod(UTIL_CreateCustomerConstants.PATCH);
            testMockReq.setHeader('Content-Type', 'application/json');
            String oldAccountJSON = JSON.serialize(updateIndividualWithValues());
            Account uptAccount = updateIndividualWithValues();
            uptAccount.Id = acct.Id;
        	uptAccount.IsPrivacyOptionsShared__c= true;
        	uptAccount.ClientIdentifier__c = 'SGGSP81L8XB';
            uptAccount.Gender__pc = 'Male';
            String newAccountJSON = JSON.serialize(uptAccount);
            String accountJSON = createAccountJSON(oldAccountJSON,newAccountJSON);
            String reqJSON = '{"billingStreet1":"1234 Test Street", "billingStreet2":"Apt#4",'
            +'"billingAddStdCode":"C", "isMailingUpdated":false, "isResidenceUpdated":false, "joesiContext":"Marital status change","isJoesiCallNeeded":true,'
            +'"associateId":"TESTASSOC87", "agentAssociateId":"97PBB1YS000", "isUpdateAfterSearch":false,"isEmailValidationChanged":false}';
            Boolean isNewCustomer = false;
            daoMockHelperInstance.acct = new Account(Id=acct.Id);
            daoMockHelperInstance.acct = daoMockHelperInstance.getAccountDetails(acct.Id);
            daoMockHelperInstance.mockIsActiveCustomer = daoMockHelperInstance.isActiveCustomer(agentUser.Associate_ID__c,acct.ClientIdentifier__c);
            UTIL_AccountCreateEditHelper.mockAccount = acct;
            UTIL_AccountCreateEditHelper.mockIsActiveCustomer = 1;
            Continuation cont = (Continuation)UTIL_AccountCreateEdit.validateAndSave(accountJSON,reqJSON,isNewCustomer);
            Map<String, HttpRequest> requests = cont.getRequests();
            List<object> objectList = new List<object>();
            object mockRequest = daoMockHelperInstance.getContinuationState(cont,testMockReq);
            objectList.add(mockRequest);
            System.assertEquals(1, requests.size(),'request size equals to 1');

            HttpResponse mockResponse = new HttpResponse();
            String responseString = '{"data":{"type":"customerPatch","clientId":"7GRMTB93VWD","attributes":{"customerType":"Individual","individualCustomer":{"deathNotificationReceived":"N","gender":"Male","maritalStatus":"Widowed","individualName":{"firstName":"JOE","lastName":"SEE"},"preferredFirstName":"JOESI"},'
            +'"mailingAddress":{"addressType":"US","street1":"3 STATE FARM PLAZA","city":"BLOOMINGTON","state":"IL","postalCode":"617910001","country":"UNITED STATES"},"doesNotHaveEmail":"N","preferences":[{"preferenceType":"preferredSpokenLanguage"},{"preferenceType":"contactPreference"},{"preferenceType":"doNotShareIndicator","preferenceValue":"N"},'
            +'{"preferenceType":"isSubjectToCASL","preferenceValue":"N"},{"preferenceType":"paperlessPrivacyNoticeIndicator","preferenceValue":"N"},{"preferenceType":"providedPrivacyOptions","preferenceValue":"Y"},{"preferenceType":"isProtectedPerson","preferenceValue":"N"},{"preferenceType":"Health Sourced","preferenceValue":"N"},{"preferenceType":"Health Prospect","preferenceValue":"N"},'
            +'{"preferenceType":"doNotCallIndicator","preferenceValue":"N"},{"preferenceType":"doNotMailIndicator","preferenceValue":"N"}]},"relationships":{"agents":{"data":[{"id":"W05XR1YS000","type":"associate","groupId":"G00ZPB93BWD","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2022-01-31"}},{"id":"97PBB1YS000","type":"associate","groupId":"ZHKL3B93YWD","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2022-01-31"}}]}},'
            +'"nbaResponse":{"data":[{"id":"temp Id","type":"temp type","attributes":{"client_id":"temp client id","interaction_id":"temp entrp interaction Id","context_type":"temp context type","salesforce":{"salesforce_account_id":"001Z000001XmiJeIAJ","associate_id_agent":"98765432109"},'
            +'"containerList":[{"experiment_name":"temp Experiment name","variation":"temp Variation","rankedResults":[{"identifier":"temp Identifier","direction":"Temp direction","treatment":"Temp treatment","actionID":"temp action id","placement":"temp placement","decisionTime":"Temp time ","propensity":"0.80","issue":"temp issue","interactionID":"temp interaction id","category":"Temp category","group":"temp group","rank":1,"subjectID":"temp subject id","variant":"temp varient","label":"temp label","name":"temp name","priority":"temp priority","channel":"temp Channel"}],"containerName":"Temp Contatiner Name","status":"temp Status"}],"status":"temp status"},"relationships":{"interaction":["temp ineraction"]}}]}}}';
            
            mockResponse.setBody(responseString);
            mockResponse.setStatusCode(200);
            List<String> labels = new List<String>{responseString};
            UTIL_AccountCreateEditHelper.mockResponse = mockResponse;
        	daoMockHelperInstance.mockResponse = mockResponse;
            Object result = UTIL_AccountCreateEdit.processCustAggResponse(labels,mockResponse);
        	Customer cust = (Customer) JSON.deserialize(String.valueOf(result), Customer.class);
        	UTIL_AccountDAOMock newInstance = (UTIL_AccountDAOMock) UTIL_AccountCreateEdit.daoInstance;
            Account custm = (Account) newInstance.argCapture.get('upsertCustomerRec');
            System.assertEquals('JOE', custm.FirstName,'verify first name');
            System.assertEquals(String.valueOf(acct.Id),String.valueOf(cust.id),'Update Account');
            Test.stopTest();
       }
    }
    @isTest static void testValidateAndSaveJoesiCallAddressChange() {
        //Toggle TOGGLE_NBA set to true
        HLPR_CustAggtReqPatchInd.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.TOGGLE_NBA, true);
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
        User testAgentUser = new User(Alias='ALIAS',LastName='LastName',Username='username@statefarm.com',Associate_ID__c='97PBB1YS000',UserExternalID__c='97PBB1YS000',Servicing_Agent_Associate_ID__c='97PBB1YS000',Territory_Associate_ID__c='TERRITORYID',Servicing_Agent_Associate_ID_List__c='ASSOCID',Territory_Associate_ID_List__c='TERRITORYID');
        User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser(testAgentUser);
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(systemAdmin) {
            agentUser.UserCriteriaList__c = 'NBA_Treatment_ECRM_Agency';
            update agentUser;
            PermissionSet permSet1 = [select Id from PermissionSet where Name = 'NextBestAction'];
        	PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = agentUser.Id, PermissionSetId = permSet1.Id);
            insert psa1;
        }
        daoMockHelperInstance.isCCCUser = false;
        Account acct = (Account) JSON.deserializeStrict(createIndividualWithValues(),Account.class);
        acct.IsPrivacyOptionsShared__c= true;
        acct.ClientIdentifier__c = 'SGGSP81L8XB';
        acct.Gender__pc = 'Female';
        acct.id = Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix() + '0'.repeat(11) + '1';
        daoMockHelperInstance.acct = acct;
        daoMockAccountInstance.clntIdToAcctIdMap.put(acct.clientidentifier__c, acct.id);
        System.runAs(agentUser) {
            Test.startTest();
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            UTIL_AccountCreateEdit.helperDAOInstance = daoMockHelperInstance;
            UTIL_AccountCreateEdit.daoInstance = daoMockAccountInstance;
            HttpRequest testMockReq = new HttpRequest();
            testMockReq.setMethod(UTIL_CreateCustomerConstants.PATCH);
            testMockReq.setHeader('Content-Type', 'application/json');
            String oldAccountJSON = JSON.serialize(updateIndividualWithValues());
            Account uptAccount = updateIndividualWithValues();
            uptAccount.Id = acct.Id;
        	uptAccount.IsPrivacyOptionsShared__c= true;
        	uptAccount.ClientIdentifier__c = 'SGGSP81L8XB';
            uptAccount.Gender__pc = 'Male';
            String newAccountJSON = JSON.serialize(uptAccount);
            String accountJSON = createAccountJSON(oldAccountJSON,newAccountJSON);
            String reqJSON = '{"billingStreet1":"1234 Test Street", "billingStreet2":"Apt#4",'
            +'"billingAddStdCode":"C", "isMailingUpdated":false, "isResidenceUpdated":false, "joesiContext":"Address change","isJoesiCallNeeded":true,'
            +'"associateId":"TESTASSOC87", "agentAssociateId":"97PBB1YS000", "isUpdateAfterSearch":false,"isEmailValidationChanged":false}';
            Boolean isNewCustomer = false;
            daoMockHelperInstance.acct = new Account(Id=acct.Id);
            daoMockHelperInstance.acct = daoMockHelperInstance.getAccountDetails(acct.Id);
            daoMockHelperInstance.mockIsActiveCustomer = daoMockHelperInstance.isActiveCustomer(agentUser.Associate_ID__c,acct.ClientIdentifier__c);
            UTIL_AccountCreateEditHelper.mockAccount = acct;
            UTIL_AccountCreateEditHelper.mockIsActiveCustomer = 1;
            Continuation cont = (Continuation)UTIL_AccountCreateEdit.validateAndSave(accountJSON,reqJSON,isNewCustomer);
            Map<String, HttpRequest> requests = cont.getRequests();
            List<object> objectList = new List<object>();
            object mockRequest = daoMockHelperInstance.getContinuationState(cont,testMockReq);
            objectList.add(mockRequest);
            System.assertEquals(1, requests.size(),'request size equals to 1');

            HttpResponse mockResponse = new HttpResponse();
            String responseString = '{"data":{"type":"customerPatch","clientId":"7GRMTB93VWD","attributes":{"customerType":"Individual","individualCustomer":{"deathNotificationReceived":"N","gender":"Male","maritalStatus":"Widowed","individualName":{"firstName":"JOE","lastName":"SEE"},"preferredFirstName":"JOESI"},'
            +'"mailingAddress":{"addressType":"US","street1":"3 STATE FARM PLAZA","city":"BLOOMINGTON","state":"IL","postalCode":"617910001","country":"UNITED STATES"},"doesNotHaveEmail":"N","preferences":[{"preferenceType":"preferredSpokenLanguage"},{"preferenceType":"contactPreference"},{"preferenceType":"doNotShareIndicator","preferenceValue":"N"},'
            +'{"preferenceType":"isSubjectToCASL","preferenceValue":"N"},{"preferenceType":"paperlessPrivacyNoticeIndicator","preferenceValue":"N"},{"preferenceType":"providedPrivacyOptions","preferenceValue":"Y"},{"preferenceType":"isProtectedPerson","preferenceValue":"N"},{"preferenceType":"Health Sourced","preferenceValue":"N"},{"preferenceType":"Health Prospect","preferenceValue":"N"},'
            +'{"preferenceType":"doNotCallIndicator","preferenceValue":"N"},{"preferenceType":"doNotMailIndicator","preferenceValue":"N"}]},"relationships":{"agents":{"data":[{"id":"W05XR1YS000","type":"associate","groupId":"G00ZPB93BWD","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2022-01-31"}},{"id":"97PBB1YS000","type":"associate","groupId":"ZHKL3B93YWD","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2022-01-31"}}]}},'
            +'"nbaResponse":{"data":[{"id":"temp Id","type":"temp type","attributes":{"client_id":"temp client id","interaction_id":"temp entrp interaction Id","context_type":"temp context type","salesforce":{"salesforce_account_id":"001Z000001XmiJeIAJ","associate_id_agent":"98765432109"},'
            +'"containerList":[{"experiment_name":"temp Experiment name","variation":"temp Variation","rankedResults":[{"identifier":"temp Identifier","direction":"Temp direction","treatment":"Temp treatment","actionID":"temp action id","placement":"temp placement","decisionTime":"Temp time ","propensity":"0.80","issue":"temp issue","interactionID":"temp interaction id","category":"Temp category","group":"temp group","rank":1,"subjectID":"temp subject id","variant":"temp varient","label":"temp label","name":"temp name","priority":"temp priority","channel":"temp Channel"}],"containerName":"Temp Contatiner Name","status":"temp Status"}],"status":"temp status"},"relationships":{"interaction":["temp ineraction"]}}]}}}';

            mockResponse.setBody(responseString);
            mockResponse.setStatusCode(200);
            List<String> labels = new List<String>{responseString};
            UTIL_AccountCreateEditHelper.mockResponse = mockResponse;
        	daoMockHelperInstance.mockResponse = mockResponse;
            Object result = UTIL_AccountCreateEdit.processCustAggResponse(labels,mockResponse);
        	Customer cust = (Customer) JSON.deserialize(String.valueOf(result), Customer.class);
        	UTIL_AccountDAOMock newInstance = (UTIL_AccountDAOMock) UTIL_AccountCreateEdit.daoInstance;
            Account custm = (Account) newInstance.argCapture.get('upsertCustomerRec');
            System.assertEquals('JOE', custm.FirstName,'verify first name');
            System.assertEquals(String.valueOf(acct.Id),String.valueOf(cust.id),'Update Account');
            Test.stopTest();
       }
    }
    @isTest static void testValidateAndSaveUpdateOrganization() {
        daoMockHelperInstance.isCCCUser = false;
        Account acct = (Account) JSON.deserializeStrict(createOrganizationWithValues(),Account.class);
        acct.ClientIdentifier__c = 'SGGSP81L8XB';
        acct.id = Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix() + '0'.repeat(11) + '1';
        daoMockHelperInstance.acct = acct;
        daoMockAccountInstance.clntIdToAcctIdMap.put(acct.clientidentifier__c, acct.id);
        TestData_SalesRoleHierarchy salesRoleHierarchy = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy.agent);
        System.runAs(salesRoleHierarchy.agent){
            Test.startTest();            

            UTIL_AccountCreateEdit.helperDAOInstance = daoMockHelperInstance;
            UTIL_AccountCreateEdit.daoInstance = daoMockAccountInstance;
            HttpRequest testMockReq = new HttpRequest();
            testMockReq.setMethod(UTIL_CreateCustomerConstants.PATCH);
            testMockReq.setHeader('Content-Type', 'application/json');
            String oldAccountJSON = JSON.serialize(updateOrganizationWithValues());
            Account uptAccount = updateOrganizationWithValues();
            uptAccount.Id = acct.Id;
            uptAccount.ClientIdentifier__c = 'SGGSP81L8XB';
            uptAccount.Phone = '6745634021';
            String newAccountJSON = JSON.serialize(uptAccount);
            String accountJSON = createAccountJSON(oldAccountJSON,newAccountJSON);
            String reqJSON = createReqJSON();
            Boolean isNewCustomer = false;
            UTIL_AccountCreateEditHelper.mockAccount = acct;
            Continuation cont = (Continuation)UTIL_AccountCreateEdit.validateAndSave(accountJSON,reqJSON,isNewCustomer);
            Map<String, HttpRequest> requests = cont.getRequests();
            List<object> objectList = new List<object>();
            object mockRequest = daoMockHelperInstance.getContinuationState(cont,testMockReq);
            objectList.add(mockRequest);
            System.assertEquals(1, requests.size(),'request size equals to 1');

            HttpResponse mockResponse = new HttpResponse();
            String responseString = '{"data":{"type":"customer","clientId":"SGGSP81L8XB","attributes":{"customerType":"Organization","organizationCustomer":{"organizationName":"CREATE ORG INC"},' + 
                '"mailingAddress":{"addressType": "Us","street1":"1028 GOLDFINCH WAY","street2":"APT 5","city":"BLOOMINGTON","state": "IL","postalCode": "61714","country":"UNITED STATES"}},' +
                '"relationships":{"agents":{"data":[{"id":"BZCWX1YS000","type":"ASSOCIATE","attributes":{"relationshipNature":"Ex-Client","relationshipStartDate":"2013-12-31"}},{"id":"HLGP84K3000",'+
                '"type":"ASSOCIATE","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2014-07-09"}},{"id":"29VXY1YS000","type":"ASSOCIATE","attributes":'+
                '{"relationshipNature":"Client","relationshipStartDate":"2015-02-10"}},{"id":"J0X494K7000","type":"ASSOCIATE","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2013-07-22"}},'+
                '{"id":"5ZZFQ1YS000","type":"ASSOCIATE","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2017-04-10"}}]}}}}';
            
            mockResponse.setBody(responseString);
            mockResponse.setStatusCode(200);
            List<String> labels = new List<String>{responseString};
            UTIL_AccountCreateEditHelper.mockResponse = mockResponse;
            daoMockHelperInstance.mockResponse = mockResponse;
            Object result = UTIL_AccountCreateEdit.processCustAggResponse(labels,mockResponse);
            Customer cust = (Customer) JSON.deserialize(String.valueOf(result), Customer.class);
            UTIL_AccountDAOMock newInstance = (UTIL_AccountDAOMock) UTIL_AccountCreateEdit.daoInstance;
            Account custm = (Account) newInstance.argCapture.get('upsertCustomerRec');
            System.assertEquals('CREATE ORG INC', custm.LastName,'verify organization name');
            System.assertEquals(String.valueOf(acct.Id),String.valueOf(cust.id),'Update Account');            
            Test.stopTest();
        }    
    }
    @isTest static void testValidateAndSaveCreateIndividualByCCC() {
        List<User> userList = new List<User>();
        User cccSalesUser = TestDataFactory_User.generateUser('3.00 CCC Licensed');
        userList.add(cccSalesUser);
        daoMockHelperInstance.isCCCUser = true;
        Account acct = (Account) JSON.deserializeStrict(createIndividualWithValues(),Account.class);
        acct.IsPrivacyOptionsShared__c= true;
        acct.ClientIdentifier__c = 'SGGSP81L8XB';
        acct.id = Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix() + '0'.repeat(11) + '1';
        daoMockHelperInstance.acct = acct;
        daoMockAccountInstance.clntIdToAcctIdMap.put(acct.clientidentifier__c, acct.id);
        TestData_SalesRoleHierarchy salesRoleHierarchy = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy.agent);
        //System.runAs(cccSalesUser) {
        
        System.runAs(salesRoleHierarchy.agent){
            Test.startTest();
            UTIL_AccountCreateEdit.helperDAOInstance = daoMockHelperInstance;
            UTIL_AccountCreateEdit.daoInstance = daoMockAccountInstance;
            HttpRequest testMockReq = new HttpRequest();
            testMockReq.setMethod(UTIL_CreateCustomerConstants.POST);
            testMockReq.setHeader('Content-Type', 'application/json');
        	String newAccountJSON = createIndividualWithValues();
            String accountJSON = createAccountJSON(null,newAccountJSON);
            String reqJSON = createReqJSON();
            Boolean isNewCustomer = true;
            Continuation cont = (Continuation)UTIL_AccountCreateEdit.validateAndSave(accountJSON,reqJSON,isNewCustomer);
            Map<String, HttpRequest> requests = cont.getRequests();
            List<object> objectList = new List<object>();
            object mockRequest = daoMockHelperInstance.getContinuationState(cont,testMockReq);
            objectList.add(mockRequest);
            System.assertEquals(1, requests.size(),'request size equals to 1');

            HttpResponse mockResponse = new HttpResponse();
            String responseString = '{"data":{"type":"customer","clientId":"SGGSP81L8XB","attributes":{"customerType":"Individual","individualCustomer":' +
                '{"individualName":{"prefix": "MR","firstName": "SARAH","middleName": "NE","lastName": "DAVIS","suffix": "1ST","designation": "DDS"}},' + 
                '"mailingAddress":{"addressType": "Us","street1":"1028 GOLDFINCH WAY","street2":"APT 5","city":"BLOOMINGTON","state": "IL","postalCode": "61714","country":"UNITED STATES"}},'+
                '"relationships":{"agents":{"data":[{"id":"BZCWX1YS000","type":"ASSOCIATE","attributes":{"relationshipNature":"Ex-Client","relationshipStartDate":"2013-12-31"}},{"id":"HLGP84K3000",'+
                '"type":"ASSOCIATE","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2014-07-09"}},{"id":"29VXY1YS000","type":"ASSOCIATE","attributes":'+
                '{"relationshipNature":"Client","relationshipStartDate":"2015-02-10"}},{"id":"J0X494K7000","type":"ASSOCIATE","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2013-07-22"}},'+
                '{"id":"5ZZFQ1YS000","type":"ASSOCIATE","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2017-04-10"}}]}}}}';
            mockResponse.setBody(responseString);
            mockResponse.setStatusCode(200);
            List<String> labels = new List<String>{responseString};
            UTIL_AccountCreateEditHelper.mockResponse = mockResponse;
        	daoMockHelperInstance.mockResponse = mockResponse;
        	daoMockHelperInstance.acct = new Account(Id=acct.Id);
            daoMockHelperInstance.acct = daoMockHelperInstance.getAccountDetails(acct.Id);
            Object result = UTIL_AccountCreateEdit.processCustAggResponse(labels,mockResponse);
        	Customer cust = (Customer) JSON.deserialize(String.valueOf(result), Customer.class);
        	System.assert(String.valueOf(cust.id).startsWith(Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix()),'Account is created');
            Test.stopTest();
        }            
    }
    @isTest static void testValidateAndSaveCreateOrganizationByCCC() {
        List<User> userList = new List<User>();
        User cccSalesUser = TestDataFactory_User.generateUser('3.00 CCC Licensed');
        userList.add(cccSalesUser);
        daoMockHelperInstance.isCCCUser = true;
        Account acct = (Account) JSON.deserializeStrict(createIndividualWithValues(),Account.class);
        acct.IsPrivacyOptionsShared__c= true;
        acct.ClientIdentifier__c = 'SGGSP81L8XB';
        acct.id = Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix() + '0'.repeat(11) + '1';
        daoMockHelperInstance.acct = acct;
        daoMockAccountInstance.clntIdToAcctIdMap.put(acct.clientidentifier__c, acct.id);
        TestData_SalesRoleHierarchy salesRoleHierarchy = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy.agent);
        //System.runAs(cccSalesUser) {
        System.runAs(salesRoleHierarchy.agent){
            Test.startTest();
            UTIL_AccountCreateEdit.helperDAOInstance = daoMockHelperInstance;
            UTIL_AccountCreateEdit.daoInstance = daoMockAccountInstance;
            HttpRequest testMockReq = new HttpRequest();
            testMockReq.setMethod(UTIL_CreateCustomerConstants.POST);
            testMockReq.setHeader('Content-Type', 'application/json');
        	String newAccountJSON = createOrganizationWithValues();
            String accountJSON = createAccountJSON(null,newAccountJSON);
            String reqJSON = createReqJSON();
            Boolean isNewCustomer = true;
            Continuation cont = (Continuation)UTIL_AccountCreateEdit.validateAndSave(accountJSON,reqJSON,isNewCustomer);
            Map<String, HttpRequest> requests = cont.getRequests();
            List<object> objectList = new List<object>();
            object mockRequest = daoMockHelperInstance.getContinuationState(cont,testMockReq);
            objectList.add(mockRequest);
            System.assertEquals(1, requests.size(),'request size equals to 1');

            HttpResponse mockResponse = new HttpResponse();
            String responseString = '{"data":{"type":"customer","clientId":"SGGSP81L8XB","attributes":{"customerType":"Organization","organizationCustomer":{"organizationName":"CREATE ORG INC"},' + 
                '"mailingAddress":{"addressType": "Us","street1":"1028 GOLDFINCH WAY","street2":"APT 5","city":"BLOOMINGTON","state": "IL","postalCode": "61714","country":"UNITED STATES"}},' +
                '"relationships":{"agents":{"data":[{"id":"BZCWX1YS000","type":"ASSOCIATE","attributes":{"relationshipNature":"Ex-Client","relationshipStartDate":"2013-12-31"}},{"id":"HLGP84K3000",'+
                '"type":"ASSOCIATE","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2014-07-09"}},{"id":"29VXY1YS000","type":"ASSOCIATE","attributes":'+
                '{"relationshipNature":"Client","relationshipStartDate":"2015-02-10"}},{"id":"J0X494K7000","type":"ASSOCIATE","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2013-07-22"}},'+
                '{"id":"5ZZFQ1YS000","type":"ASSOCIATE","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2017-04-10"}}]}}}}';
            mockResponse.setBody(responseString);
            mockResponse.setStatusCode(200);
            List<String> labels = new List<String>{responseString};
            UTIL_AccountCreateEditHelper.mockResponse = mockResponse;
        	daoMockHelperInstance.mockResponse = mockResponse;
        	daoMockHelperInstance.acct = new Account(Id=acct.Id);
            daoMockHelperInstance.acct = daoMockHelperInstance.getAccountDetails(acct.Id);
            Object result = UTIL_AccountCreateEdit.processCustAggResponse(labels,mockResponse);
        	Customer cust = (Customer) JSON.deserialize(String.valueOf(result), Customer.class);
        	System.assert(String.valueOf(cust.id).startsWith(Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix()),'Account is created');
        }
            Test.stopTest();
        //}
            
    }
    @isTest static void testValidateAndSaveUpdateIndividualByCCC() {
        User cccSalesUser = TestDataFactory_User.generateUser('3.00 CCC Licensed');
        daoMockHelperInstance.isCCCUser = true;
        daoMockHelperInstance.loggedInUser = cccSalesUser;
        Account acct = (Account) JSON.deserializeStrict(createIndividualWithValues(),Account.class);
        acct.ClientIdentifier__c = 'SGGSP81L8XB';
        acct.Gender__pc = 'Female';
        acct.id = Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix() + '0'.repeat(11) + '1';
        daoMockHelperInstance.acct = acct;
        daoMockAccountInstance.clntIdToAcctIdMap.put(acct.clientidentifier__c, acct.id);
        AgentContext__c agtCtxt = new AgentContext__c();
        agtCtxt.AgentContextIdentifier__c = cccSalesUser.Associate_ID__c+'~'+acct.ClientIdentifier__c;
        agtCtxt.CCCRepresentative__c = cccSalesUser.id;
        agtCtxt.InteractionId__c = '123456790';
        insert agtCtxt;
        TestData_SalesRoleHierarchy salesRoleHierarchy = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy.agent);
        //System.runAs(cccSalesUser) {
        System.runAs(salesRoleHierarchy.agent){
            Test.startTest();
            UTIL_AccountCreateEdit.helperDAOInstance = daoMockHelperInstance;
            UTIL_AccountCreateEdit.daoInstance = daoMockAccountInstance;
            HttpRequest testMockReq = new HttpRequest();
            testMockReq.setMethod(UTIL_CreateCustomerConstants.PATCH);
            testMockReq.setHeader('Content-Type', 'application/json');
        	String oldAccountJSON = JSON.serialize(updateIndividualWithValues());
            Account uptAccount = updateIndividualWithValues();
            uptAccount.Id = acct.Id;
        	uptAccount.IsPrivacyOptionsShared__c= true;
        	uptAccount.ClientIdentifier__c = 'SGGSP81L8XB';
            uptAccount.Gender__pc = 'Male';
            String newAccountJSON = JSON.serialize(uptAccount);
            String accountJSON = createAccountJSON(oldAccountJSON,newAccountJSON);
            String reqJSON = updateReqJSON();
            Boolean isNewCustomer = false;
        	UTIL_AccountCreateEditHelper.mockAccount = acct;
            Continuation cont = (Continuation)UTIL_AccountCreateEdit.validateAndSave(accountJSON,reqJSON,isNewCustomer);
            Map<String, HttpRequest> requests = cont.getRequests();
            List<object> objectList = new List<object>();
            object mockRequest = daoMockHelperInstance.getContinuationState(cont,testMockReq);
            objectList.add(mockRequest);
            System.assertEquals(1, requests.size(),'request size equals to 1');

            HttpResponse mockResponse = new HttpResponse();
            String responseString = '{"data":{"type":"customer","clientId":"SGGSP81L8XB","attributes":{"customerType":"Individual","individualCustomer":' +
                '{"individualName":{"prefix": "MR","firstName": "SARAH","middleName": "NE","lastName": "DAVIS","suffix": "1ST","designation": "DDS"}},' + 
                '"mailingAddress":{"addressType": "Us","street1":"1028 GOLDFINCH WAY","street2":"APT 5","city":"BLOOMINGTON","state": "IL","postalCode": "61714","country":"UNITED STATES"}},'+
                '"relationships":{"agents":{"data":[{"id":"BZCWX1YS000","type":"ASSOCIATE","attributes":{"relationshipNature":"Ex-Client","relationshipStartDate":"2013-12-31"}},{"id":"HLGP84K3000",'+
                '"type":"ASSOCIATE","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2014-07-09"}},{"id":"29VXY1YS000","type":"ASSOCIATE","attributes":'+
                '{"relationshipNature":"Client","relationshipStartDate":"2015-02-10"}},{"id":"J0X494K7000","type":"ASSOCIATE","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2013-07-22"}},'+
                '{"id":"5ZZFQ1YS000","type":"ASSOCIATE","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2017-04-10"}}]}}}}';
            mockResponse.setBody(responseString);
            mockResponse.setStatusCode(200);
            List<String> labels = new List<String>{responseString};
            UTIL_AccountCreateEditHelper.mockResponse = mockResponse;
        	daoMockHelperInstance.mockResponse = mockResponse;
            Object result = UTIL_AccountCreateEdit.processCustAggResponse(labels,mockResponse);
        	Customer cust = (Customer) JSON.deserialize(String.valueOf(result), Customer.class);
        	UTIL_AccountDAOMock newInstance = (UTIL_AccountDAOMock) UTIL_AccountCreateEdit.daoInstance;
            Account custm = (Account) newInstance.argCapture.get('upsertCustomerRec');
            System.assertEquals('SARAH', custm.FirstName,'verify first name');
            System.assertEquals(String.valueOf(acct.Id),String.valueOf(cust.id),'Update Account');

            Test.stopTest();
        }
            
    }
    @isTest static void testValidateAndSaveUpdateOrganizationByCCC() {
        User cccSalesUser = TestDataFactory_User.generateUser('3.00 CCC Licensed');
        daoMockHelperInstance.isCCCUser = true;
        daoMockHelperInstance.loggedInUser = cccSalesUser;
        Account acct = (Account) JSON.deserializeStrict(createOrganizationWithValues(),Account.class);
        acct.ClientIdentifier__c = 'SGGSP81L8XB';
        acct.id = Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix() + '0'.repeat(11) + '1';
        daoMockHelperInstance.acct = acct;
        daoMockAccountInstance.clntIdToAcctIdMap.put(acct.clientidentifier__c, acct.id);
        AgentContext__c agtCtxt = new AgentContext__c();
        agtCtxt.AgentContextIdentifier__c = cccSalesUser.Associate_ID__c+'~'+acct.ClientIdentifier__c;
        agtCtxt.CCCRepresentative__c = cccSalesUser.id;
        agtCtxt.InteractionId__c = '123456790';
        insert agtCtxt;
        TestData_SalesRoleHierarchy salesRoleHierarchy = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy.agent);
        //System.runAs(cccSalesUser) {
        System.runAs(salesRoleHierarchy.agent){
            Test.startTest();
            UTIL_AccountCreateEdit.helperDAOInstance = daoMockHelperInstance;
            UTIL_AccountCreateEdit.daoInstance = daoMockAccountInstance;
            HttpRequest testMockReq = new HttpRequest();
            testMockReq.setMethod(UTIL_CreateCustomerConstants.PATCH);
            testMockReq.setHeader('Content-Type', 'application/json');
        	String oldAccountJSON = JSON.serialize(updateIndividualWithValues());
            Account uptAccount = updateOrganizationWithValues();
            uptAccount.Id = acct.Id;
        	uptAccount.ClientIdentifier__c = 'SGGSP81L8XB';
            uptAccount.Phone = '6745634021';
            String newAccountJSON = JSON.serialize(uptAccount);
            String accountJSON = createAccountJSON(oldAccountJSON,newAccountJSON);
            String reqJSON = createReqJSON();
            Boolean isNewCustomer = false;
        	UTIL_AccountCreateEditHelper.mockAccount = acct;
            Continuation cont = (Continuation)UTIL_AccountCreateEdit.validateAndSave(accountJSON,reqJSON,isNewCustomer);
            Map<String, HttpRequest> requests = cont.getRequests();
            List<object> objectList = new List<object>();
            object mockRequest = daoMockHelperInstance.getContinuationState(cont,testMockReq);
            objectList.add(mockRequest);
            System.assertEquals(1, requests.size(),'request size equals to 1');

            HttpResponse mockResponse = new HttpResponse();
            String responseString = '{"data":{"type":"customer","clientId":"SGGSP81L8XB","attributes":{"customerType":"Organization","organizationCustomer":' +
                '{"organizationName":"Sample Organization","organizationType":"Unknown Organization"},' + 
                '"mailingAddress":{"addressType":"US","preAddress":"Attn: Bob","street1":"1028 goldfinch way","street2":"Apt 9","city":"Bloomington","country":"US","postalCode":"61714","state":"IL","addressStandardizationCode":"C"}},'+
                '"relationships":{"agents":{"data":[{"id":"BZCWX1YS000","type":"ASSOCIATE","attributes":{"relationshipNature":"Ex-Client","relationshipStartDate":"2013-12-31"}},{"id":"HLGP84K3000",'+
                '"type":"ASSOCIATE","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2014-07-09"}},{"id":"29VXY1YS000","type":"ASSOCIATE","attributes":'+
                '{"relationshipNature":"Client","relationshipStartDate":"2015-02-10"}},{"id":"J0X494K7000","type":"ASSOCIATE","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2013-07-22"}},'+
                '{"id":"5ZZFQ1YS000","type":"ASSOCIATE","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2017-04-10"}}]}}}}';
            mockResponse.setBody(responseString);
            mockResponse.setStatusCode(200);
            List<String> labels = new List<String>{responseString};
            UTIL_AccountCreateEditHelper.mockResponse = mockResponse;
        	daoMockHelperInstance.mockResponse = mockResponse;
            Object result = UTIL_AccountCreateEdit.processCustAggResponse(labels,mockResponse);
        	Customer cust = (Customer) JSON.deserialize(String.valueOf(result), Customer.class);
        	UTIL_AccountDAOMock newInstance = (UTIL_AccountDAOMock) UTIL_AccountCreateEdit.daoInstance;
            Account custm = (Account) newInstance.argCapture.get('upsertCustomerRec');
            System.assertEquals('Sample Organization', custm.LastName,'verify organization name');
            System.assertEquals(String.valueOf(acct.Id),String.valueOf(cust.id),'Update Account');

            Test.stopTest();
        }
            
    }
    @isTest static void testValidateAndSaveNoOperation() {
        User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser(commonAgentUser);
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        daoMockHelperInstance.isCCCUser = false;
        Account acct = (Account) JSON.deserializeStrict(createIndividualWithValues(),Account.class);
        acct.ClientIdentifier__c = 'SGGSP81L8XB';
        acct.id = Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix() + '0'.repeat(11) + '1';
        daoMockHelperInstance.acct = acct;
        daoMockAccountInstance.clntIdToAcctIdMap.put(acct.clientidentifier__c, acct.id);
        System.runAs(agentUser) {
            Test.startTest();
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            UTIL_AccountCreateEdit.helperDAOInstance = daoMockHelperInstance;
            UTIL_AccountCreateEdit.daoInstance = daoMockAccountInstance;
            HttpRequest testMockReq = new HttpRequest();
            testMockReq.setMethod(UTIL_CreateCustomerConstants.PATCH);
            testMockReq.setHeader('Content-Type', 'application/json');
            String oldAccountJSON = JSON.serialize(updateIndividualWithValues());
            Account uptAccount = (Account) JSON.deserializeStrict(createIndividualWithValues(),Account.class);
            uptAccount.Id = acct.Id;
        	uptAccount.ClientIdentifier__c = 'SGGSP81L8XB';
            String newAccountJSON = JSON.serialize(uptAccount);
            String accountJSON = createAccountJSON(oldAccountJSON,newAccountJSON);
            String reqJSON = updateReqJSON();
            Boolean isNewCustomer = false;
            daoMockHelperInstance.acct = new Account(Id=acct.Id);
            daoMockHelperInstance.acct = daoMockHelperInstance.getAccountDetails(acct.Id);
            UTIL_AccountCreateEditHelper.mockAccount = acct;
            //Continuation cont = (Continuation)UTIL_AccountCreateEdit.validateAndSave(accountJSON,reqJSON,isNewCustomer);
            String result = (String)UTIL_AccountCreateEdit.validateAndSave(accountJSON,reqJSON,isNewCustomer);
        	Customer cust = (Customer) JSON.deserialize(String.valueOf(result), Customer.class);
            System.assertEquals(String.valueOf(acct.Id),String.valueOf(cust.id),'Update Account');
            Test.stopTest();
       }
    }
    @isTest static void testhandleCustAggtErrors400() {
        TestData_SalesRoleHierarchy salesRoleHierarchy = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy.agent);
        System.runAs(salesRoleHierarchy.agent){
            Test.startTest();
            HttpRequest testMockReq = new HttpRequest();
            testMockReq.setMethod(UTIL_CreateCustomerConstants.PATCH);
            testMockReq.setHeader('Content-Type', 'application/json');
            String newAccountJSON = createOrganizationWithValues();
            String accountJSON = createAccountJSON(null,newAccountJSON);
            String reqJSON = createReqJSON();
            Boolean isNewCustomer = true;
            Continuation cont = (Continuation)UTIL_AccountCreateEdit.validateAndSave(accountJSON,reqJSON,isNewCustomer);
            Map<String, HttpRequest> requests = cont.getRequests();
            List<object> objectList = new List<object>();
            object mockRequest = daoMockHelperInstance.getContinuationState(cont,testMockReq);
            objectList.add(mockRequest);
            System.assertEquals(1, requests.size(),'request size equals to 1');

            HttpResponse mockResponse = new HttpResponse();
        	String responseString = '{"errors": [{"status": "400","code": "invalid_fault_01","title": "Fault occurred while processing.",' +
                '"detail": " 2016-06-06-12.59.42.943M2DNJ    0   - INFORMATION ONLY INVALID TAX IDENTIFIER/S SN -- CANNOT PROCESS REQUESTED ACTION ZABIPCAD ",' +
                '"source": {"pointer": "data/attributes/customer"}}]}';
        
        	mockResponse.setBody(responseString);
            mockResponse.setStatusCode(400);
            List<String> labels = new List<String>{responseString};
            UTIL_AccountCreateEditHelper.mockResponse = mockResponse;
        	daoMockHelperInstance.mockResponse = mockResponse;
            try {
                List<Object> listObject = new List<Object>();
                Object result = UTIL_AccountCreateEdit.processCustAggResponse(labels,mockResponse);
                listObject.add(result);
            } 
        	catch (Exception e) {
                System.assertEquals('AccountCreateEditException',e.getTypeName(),'Custom Error thrown'); 
            }
  		    Test.stopTest();
        }
    }
    @isTest static void testhandleCustAggtErrors406() {
        TestData_SalesRoleHierarchy salesRoleHierarchy = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy.agent);
        System.runAs(salesRoleHierarchy.agent){
            Test.startTest();
            HttpRequest testMockReq = new HttpRequest();
            testMockReq.setMethod(UTIL_CreateCustomerConstants.PATCH);
            testMockReq.setHeader('Content-Type', 'application/json');
            String newAccountJSON = createOrganizationWithValues();
            String accountJSON = createAccountJSON(null,newAccountJSON);
            String reqJSON = createReqJSON();
            Boolean isNewCustomer = true;
            Continuation cont = (Continuation)UTIL_AccountCreateEdit.validateAndSave(accountJSON,reqJSON,isNewCustomer);
            Map<String, HttpRequest> requests = cont.getRequests();
            List<object> objectList = new List<object>();
            object mockRequest = daoMockHelperInstance.getContinuationState(cont,testMockReq);
            objectList.add(mockRequest);
            System.assertEquals(1, requests.size(),'request size equals to 1');

            HttpResponse mockResponse = new HttpResponse();
        	String responseString = '{"errors": [{"status": "406","code": "invalid_auth_01","title": "Fault occurred while processing.",' +
                '"detail": " 2016-06-06-12.59.42.943M2DNJ    0   - Invalid credentials",' +
                '"source": {"pointer": "data/attributes/customer"}}]}';
        
        	mockResponse.setBody(responseString);
            mockResponse.setStatusCode(406);
            List<String> labels = new List<String>{responseString};
            UTIL_AccountCreateEditHelper.mockResponse = mockResponse;
        	daoMockHelperInstance.mockResponse = mockResponse;
            try {
                List<Object> listObject = new List<Object>();
                Object result = UTIL_AccountCreateEdit.processCustAggResponse(labels,mockResponse);
                listObject.add(result);
            } 
        	catch (Exception e) {
                System.assertEquals('AccountCreateEditException',e.getTypeName(),'Custom Error thrown'); 
            }
  		    Test.stopTest();
        }
    }
    @isTest static void testhandleCustAggtErrors422() {
        TestData_SalesRoleHierarchy salesRoleHierarchy = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy.agent);
        System.runAs(salesRoleHierarchy.agent){
            Test.startTest();
            HttpRequest testMockReq = new HttpRequest();
            testMockReq.setMethod(UTIL_CreateCustomerConstants.PATCH);
            testMockReq.setHeader('Content-Type', 'application/json');
            String newAccountJSON = createOrganizationWithValues();
            String accountJSON = createAccountJSON(null,newAccountJSON);
            String reqJSON = createReqJSON();
            Boolean isNewCustomer = true;
            Continuation cont = (Continuation)UTIL_AccountCreateEdit.validateAndSave(accountJSON,reqJSON,isNewCustomer);
            Map<String, HttpRequest> requests = cont.getRequests();
            List<object> objectList = new List<object>();
            object mockRequest = daoMockHelperInstance.getContinuationState(cont,testMockReq);
            objectList.add(mockRequest);
            System.assertEquals(1, requests.size(),'request size equals to 1');

            HttpResponse mockResponse = new HttpResponse();
        	String responseString = '{"errors": [{"status": "422","code": "address_standardization_03","title": "Address Standardization",' +
                '"detail": "Address Standardization Issue(s) must be resolved","source": {"pointer": "data/customerAttribute/mailingAddress"},' + 
                '"meta": {"addressStandardizationOutcomes":    {"addressStandardizationStatusCode": "06","standardizedAddress": null,"standardizedMessage":[{' +
                '"addressStandardizationMessageCode": "SOT412","addressStandardizationMessageText": "Multiple matches found in Postal Service Directory. ' +
                'Enter additional information."},{"addressStandardizationMessageCode": "SOT412","addressStandardizationMessageText": ' +
                '"Address is not in Postal Service Directory. Verify address is correct."}]}}}]}';
        
        	mockResponse.setBody(responseString);
            mockResponse.setStatusCode(422);
            List<String> labels = new List<String>{responseString};
            UTIL_AccountCreateEditHelper.mockResponse = mockResponse;
        	daoMockHelperInstance.mockResponse = mockResponse;
            try {
                List<Object> listObject = new List<Object>();
                Object result = UTIL_AccountCreateEdit.processCustAggResponse(labels,mockResponse);
                listObject.add(result);
            } 
        	catch (Exception e) {
                System.assertEquals('AccountCreateEditException',e.getTypeName(),'Custom Error thrown'); 
            }
  		    Test.stopTest();
        }
    }
    @isTest static void testhandleCustAggtErrors423(){
        TestData_SalesRoleHierarchy salesRoleHierarchy = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy.agent);
        System.runAs(salesRoleHierarchy.agent){
            Test.startTest();
            HttpRequest testMockReq = new HttpRequest();
            testMockReq.setMethod(UTIL_CreateCustomerConstants.PATCH);
            testMockReq.setHeader('Content-Type', 'application/json');
            String newAccountJSON = createOrganizationWithValues();
            String accountJSON = createAccountJSON(null,newAccountJSON);
            String reqJSON = createReqJSON();
            Boolean isNewCustomer = true;
            Continuation cont = (Continuation)UTIL_AccountCreateEdit.validateAndSave(accountJSON,reqJSON,isNewCustomer);
            Map<String, HttpRequest> requests = cont.getRequests();
            List<object> objectList = new List<object>();
            object mockRequest = daoMockHelperInstance.getContinuationState(cont,testMockReq);
            objectList.add(mockRequest);
            System.assertEquals(1, requests.size(),'request size equals to 1');

            HttpResponse mockResponse = new HttpResponse();
        	String responseString = '{"errors": [{"status": "423","code": "email_verification_failed_06","title": "Email Verification","detail": "Email is invalid",'+
   				'"source": {"pointer": "data/customerAttribute/emailAddress"},"meta": {"emailVerificationOutcomes":{'+
      			'"verifiedMessage":[{"emailVerificationMessageText": "Vendor service has been called with the following error message: \'Email account invalid\'."}]}}}]}';
        	mockResponse.setBody(responseString);
            mockResponse.setStatusCode(423);
            List<String> labels = new List<String>{responseString};
            UTIL_AccountCreateEditHelper.mockResponse = mockResponse;
        	daoMockHelperInstance.mockResponse = mockResponse;
            new UTIL_AccountCreateEdit_TestWrapper().createListObject(labels, mockResponse);
  		    Test.stopTest();
        }
    }

    @isTest static void testhandleCustAggtErrors500() {
        TestData_SalesRoleHierarchy salesRoleHierarchy = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy.agent);
        System.runAs(salesRoleHierarchy.agent){
            Test.startTest();
            HttpRequest testMockReq = new HttpRequest();
            testMockReq.setMethod(UTIL_CreateCustomerConstants.PATCH);
            testMockReq.setHeader('Content-Type', 'application/json');
            String newAccountJSON = createOrganizationWithValues();
            String accountJSON = createAccountJSON(null,newAccountJSON);
            String reqJSON = createReqJSON();
            Boolean isNewCustomer = true;
            Continuation cont = (Continuation)UTIL_AccountCreateEdit.validateAndSave(accountJSON,reqJSON,isNewCustomer);
            Map<String, HttpRequest> requests = cont.getRequests();
            List<object> objectList = new List<object>();
            object mockRequest = daoMockHelperInstance.getContinuationState(cont,testMockReq);
            objectList.add(mockRequest);
            System.assertEquals(1, requests.size(),'request size equals to 1');

            HttpResponse mockResponse = new HttpResponse();
        	String responseString = '{"errors": [{"status": "500","code": "invalid_auth_01","title": "Fault occurred while processing.",' +
                '"detail": " 2016-06-06-12.59.42.943M2DNJ    0   - Invalid credentials",' +
                '"source": {"pointer": "data/attributes/customer"}}]}';
        
        	mockResponse.setBody(responseString);
            mockResponse.setStatusCode(500);
            List<String> labels = new List<String>{responseString};
            UTIL_AccountCreateEditHelper.mockResponse = mockResponse;
        	daoMockHelperInstance.mockResponse = mockResponse;
            try {
                List<Object> listObject = new List<Object>();
                Object result = UTIL_AccountCreateEdit.processCustAggResponse(labels,mockResponse);
                listObject.add(result);
            } 
        	catch (Exception e) {
                System.assertEquals('AccountCreateEditException',e.getTypeName(),'Custom Error thrown'); 
            }
  		    Test.stopTest();
        }
    }
    @isTest static void testhandleCustAggtErrors() {
        TestData_SalesRoleHierarchy salesRoleHierarchy = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy.agent);
        System.runAs(salesRoleHierarchy.agent){
            Test.startTest();
            HttpRequest testMockReq = new HttpRequest();
            testMockReq.setMethod(UTIL_CreateCustomerConstants.PATCH);
            testMockReq.setHeader('Content-Type', 'application/json');
            String newAccountJSON = createOrganizationWithValues();
            String accountJSON = createAccountJSON(null,newAccountJSON);
            String reqJSON = createReqJSON();
            Boolean isNewCustomer = true;
            Continuation cont = (Continuation)UTIL_AccountCreateEdit.validateAndSave(accountJSON,reqJSON,isNewCustomer);
            Map<String, HttpRequest> requests = cont.getRequests();
            List<object> objectList = new List<object>();
            object mockRequest = daoMockHelperInstance.getContinuationState(cont,testMockReq);
            objectList.add(mockRequest);
            System.assertEquals(1, requests.size(),'request size equals to 1');

            HttpResponse mockResponse = new HttpResponse();
        	String responseString = '{"errors": [{"status": "405","code": "invalid_auth_01","title": "Fault occurred while processing.",' +
                '"detail": " 2016-06-06-12.59.42.943M2DNJ    0   - Invalid credentials",' +
                '"source": {"pointer": "data/attributes/customer"}}]}';
        
        	mockResponse.setBody(responseString);
            mockResponse.setStatusCode(405);
            List<String> labels = new List<String>{responseString};
            UTIL_AccountCreateEditHelper.mockResponse = mockResponse;
        	daoMockHelperInstance.mockResponse = mockResponse;
            try {
                List<Object> listObject = new List<Object>();
                Object result = UTIL_AccountCreateEdit.processCustAggResponse(labels,mockResponse);
                listObject.add(result);
            } 
        	catch (Exception e) {
                System.assertEquals('AccountCreateEditException',e.getTypeName(),'Custom Error thrown'); 
            }
  		    Test.stopTest();
        }
    }
    
    private static string createAccountJSON(String oldCustomer, String newCustomer) {
        UTIL_AccountCreateEdit_Additional.AccountJSONWrapper acctWrapper = new UTIL_AccountCreateEdit_Additional.AccountJSONWrapper();
        acctWrapper.oldCustomer = oldCustomer;
        acctWrapper.customer = newCustomer;
        return JSON.serialize(acctWrapper);
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

    private static Id getRecordTypeIdbyName(String objectName, String strRecordTypeName) {
        return  Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
    }
    
    private static String createIndividualWithValues() {
        Account fields = new Account();
        fields.RecordTypeId = getRecordTypeIdbyName('Account',UTIL_CreateCustomerConstants.INDIVIDUAL_RECORD_TYPE_NAME);
        fields.Edit_In_VFP__c = true;
        fields.FirstName = 'Test First Name';
        fields.MiddleName = 'M';
        fields.LastName = 'Test Last Name';
        fields.MailingInCareOf__c = 'Test Care';
        fields.BillingAddressType__c = 'US';
        fields.BillingStreet = '1234 Test Street';
        fields.BillingCity = 'Bloomington';
        fields.BillingState = 'IL';
        fields.BillingPostalCode = '61704';
        fields.BillingCountry = 'US';
        return JSON.serialize(fields);
        
    }
    private static Account updateIndividualWithValues() {
        Account fields = new Account();
        fields.RecordTypeId = getRecordTypeIdbyName('Account',UTIL_CreateCustomerConstants.INDIVIDUAL_RECORD_TYPE_NAME);
        fields.Edit_In_VFP__c = true;
        fields.FirstName = 'Test First Name';
        fields.MiddleName = 'M';
        fields.LastName = 'Test Last Name';
        fields.MailingInCareOf__c = 'Test Care';
        fields.BillingAddressType__c = 'US';
        fields.BillingStreet = '1234 Test Street';
        fields.BillingCity = 'Bloomington';
        fields.BillingState = 'IL';
        fields.BillingPostalCode = '61704';
        fields.BillingCountry = 'US';
        return fields;
    }
    private static Account createIndividualWithForeignValues() {
        Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('Test Last Name');
        acc.FirstName = 'Test First Name';
        acc.BillingAddressType__c = 'Foreign';
        acc.BillingStreet = 'Test Street';
        acc.BillingCountry = 'India';
        acc.MailingAttention__c= 'Attn';
        acc.ShippingAddressType__c = 'Foreign';
        acc.ShippingStreet = 'Test Street Test Street \n Test Street  Test Street Test Street Test Street \n Test Street Test Street Test Street Test Street Test Street ';
        acc.ShippingCountry = 'India';
        return acc;
    }
    
    private static Account createIndividualWithMatchValues(){
        Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('Doe');
        acc.FirstName = 'John';
        acc.BillingAddressType__c = 'US';
        acc.BillingStreet = '1 Statefarm Plz';
        acc.BillingCity = 'Bloomington';
        acc.BillingState = 'IL';
        acc.BillingPostalCode = '61710';
        acc.BillingCountry = 'US';
        acc.ShippingStreet = '1 Statefarm Plz';
        acc.ShippingCity = 'Bloomington';
        acc.ShippingState = 'IL';
        acc.ShippingPostalCode = '61710';
        acc.ShippingCountry = 'US';
        return acc;
    }
    
    private static Account createIndividualWithoutShippingAddress(){
        Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('Test Last Name');
        acc.FirstName = 'Test First Name';
        acc.BillingAddressType__c = 'US';
        acc.BillingStreet = 'Test Street Test Street Test Street \n Test Street Test Street Test Street \n Test Street Test Street Test Street Test Street Test Street ';
        acc.BillingCity = 'Bloomington';
        acc.BillingState = 'IL';
        acc.BillingPostalCode = '61704';
        acc.BillingCountry = 'US';
        return acc;
    }
    
    private static String createOrganizationWithValues() {
        Account fields = new Account();
        fields.RecordTypeId = getRecordTypeIdbyName('Account',UTIL_CreateCustomerConstants.ORGANIZATION_RECORD_TYPE_NAME);
        fields.Edit_In_VFP__c = true;
        fields.LastName = 'Test Organization Name';
        fields.MailingAttention__c = 'Test Attention';
        fields.BillingAddressType__c = 'US';
        fields.BillingStreet = '1234 Test Street';
        fields.BillingCity = 'Bloomington';
        fields.BillingState = 'IL';
        fields.BillingPostalCode = '61704';
        fields.BillingCountry = 'US';
        return JSON.serialize(fields);
    }
    private static Account updateOrganizationWithValues() {
        Account fields = new Account();
        fields.RecordTypeId = getRecordTypeIdbyName('Account',UTIL_CreateCustomerConstants.ORGANIZATION_RECORD_TYPE_NAME);
        fields.Edit_In_VFP__c = true;
        fields.LastName = 'Test Organization Name';
        fields.MailingAttention__c = 'Test Attention';
        fields.BillingAddressType__c = 'US';
        fields.BillingStreet = '1234 Test Street';
        fields.BillingCity = 'Bloomington';
        fields.BillingState = 'IL';
        fields.BillingPostalCode = '61704';
        fields.BillingCountry = 'US';
        return fields;
    }
    private static String createReqJSON() {
        return '{"billingStreet1":"1234 Test Street", "billingStreet2":"Apt#4",'
        +'"billingAddStdCode":"C", "isMailingUpdated":false, "isResidenceUpdated":false,'
        +'"associateId":"TESTASSOC87", "agentAssociateId":"TESTAGTASS6", "isUpdateAfterSearch":false,"isEmailValidationChanged":false, "optInEmail":"Yes"}';     
    }
    private static String updateReqJSON() {
        return '{"billingStreet1":"1234 Test Street", "billingStreet2":"Apt#4",'
        +'"billingAddStdCode":"C", "isMailingUpdated":false, "isResidenceUpdated":false,"isJoesiCallNeeded":false, "joesiContext":null,'
        +'"associateId":"TESTASSOC87", "agentAssociateId":null, "isUpdateAfterSearch":false,"isEmailValidationChanged":false}';     
    }

    private class UTIL_AccountCreateEdit_TestWrapper{
        private void createListObject(List<String> labels, HttpResponse mockResponse){
            try {
                List<Object> listObject = new List<Object>();
                Object result = UTIL_AccountCreateEdit.processCustAggResponse(labels,mockResponse);
                listObject.add(result);
            } 
            catch (Exception e) {
                System.assertEquals('AccountCreateEditException',e.getTypeName(),'Custom Error thrown'); 
            }
        }
    }    
}
