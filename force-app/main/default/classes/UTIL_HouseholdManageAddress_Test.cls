/**
* @author Team Stark
* @owner Team Stark
* @name UTIL_AccountCreateEdit_TEST
* @createDate 06/19/2020
* @description Common class to access various Account related Agent and CCC operations TEST.
* @version 1.0
*/
@isTest
private class UTIL_HouseholdManageAddress_Test {

    private static DAOMock_AccountCreateEditHelper daoMockHelperInstance = new DAOMock_AccountCreateEditHelper();
    private static UTIL_AccountCreateEditHelper doInstanceHelper = new UTIL_AccountCreateEditHelper();
    private static UTIL_AccountDAOMock daoMockAccountInstance = new UTIL_AccountDAOMock();
    private static User commonAgentUser = new User(Alias='ALIAS',LastName='LastName',Username='username@statefarm.com',Associate_ID__c='ASSOCID',UserExternalID__c='ASSOCID',Servicing_Agent_Associate_ID__c='ASSOCID',Territory_Associate_ID__c='TERRITORYID',Servicing_Agent_Associate_ID_List__c='ASSOCID',Territory_Associate_ID_List__c='TERRITORYID');
    private static final String HOUSEHOLD_RECORD_TYPE = 'IndustriesHousehold';
    
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
    * @description test Case fetch name and address
    * @name   testFetchMembersNameAddresses
    */     
    @isTest static void testFetchMembersNameAddresses() {
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId();
        Account householdAccount = new Account(Name='Household', recordTypeId=householdRecordTypeId, AllowHousehold__c = true);
        Account individualAccountOne = new Account(FirstName='Individual',LastName='AccountOne',BillingAddressType__c='US',BillingStreet='1234 Main St' ,BillingCity='Bloomington',BillingState='IL' ,BillingPostalCode='61704' ,BillingCountry='UNITED STATES' ,ClientIdentifier__c='SFFSP81LZYX');
        System.runAs(systemAdmin) {
            insert householdAccount;
            insert individualAccountOne;
        }
        Contact conRecord = [SELECT id from Contact where AccountId=:individualAccountOne.Id];
        AccountContactRelation acrRecord = new AccountContactRelation(AccountId=householdAccount.Id,ContactId=conRecord.Id,FinServ__PrimaryGroup__c=true);
        insert acrRecord;
        String hhAcctId = String.valueOf(householdAccount.Id);
        Test.startTest();
        	List<Account> allMembersList = UTIL_HouseholdManageAddress.fetchMembersNameAddresses(hhAcctId);
            List<Account> allMembersListNoCache = UTIL_HouseholdManageAddress.fetchMembersNameAddressesNoCache(hhAcctId);
        Test.stopTest();
        System.assert(!allMembersList.isEmpty(),'All active members name and address from ACR list should not be empty');
        System.assert(!allMembersListNoCache.isEmpty(),'All active members name and address from ACR no cache list should not be empty');
    }
    
    /**
    * @description test Case to fetch mailing address
    * @name   testFetchMailingAddresses
    */     
    @isTest static void testFetchMailingAddresses() {
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert systemAdmin;
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId();
        Account householdAccount = new Account(Name='Household', recordTypeId=householdRecordTypeId, AllowHousehold__c = true);
        Account individualAccountOne = new Account(FirstName='Individual',LastName='AccountOne',BillingAddressType__c='US',BillingStreet='1234 Main St' ,BillingCity='Bloomington',BillingState='IL' ,BillingPostalCode='61704' ,BillingCountry='UNITED STATES' ,ClientIdentifier__c='SFFSP81LZYX');
        System.runAs(systemAdmin) {
            insert householdAccount;
            insert individualAccountOne;
        }
        Contact conRecord = [SELECT id from Contact where AccountId=:individualAccountOne.Id];
        AccountContactRelation acrRecord = new AccountContactRelation(AccountId=householdAccount.Id,ContactId=conRecord.Id,FinServ__PrimaryGroup__c=true);
        insert acrRecord;
        String expectedMailingAddress = individualAccountOne.BillingCountry+','+ individualAccountOne.BillingStreet+','+individualAccountOne.BillingCity+','+individualAccountOne.BillingState+','+individualAccountOne.BillingPostalCode+','+individualAccountOne.BillingAddressType__c;
        Account actualAccount = UTIL_HouseholdManageAddress.fetchMailingAddresses(householdAccount.Id).get(0);
        Account actualAccountNoCache = UTIL_HouseholdManageAddress.fetchMailingAddressesNoCache(householdAccount.Id).get(0);
        String actualMailingAddress = actualAccount.BillingCountry+','+ actualAccount.BillingStreet+','+actualAccount.BillingCity+','+actualAccount.BillingState+','+actualAccount.BillingPostalCode+','+actualAccount.BillingAddressType__c;
        String actualMailingAddressNoCache = actualAccountNoCache.BillingCountry+','+ actualAccountNoCache.BillingStreet+','+actualAccountNoCache.BillingCity+','+actualAccountNoCache.BillingState+','+actualAccountNoCache.BillingPostalCode+','+actualAccountNoCache.BillingAddressType__c;
        Test.startTest();
            System.assertEquals(expectedMailingAddress,actualMailingAddress,'Mailing address mismatches'); 
            System.assertEquals(expectedMailingAddress,actualMailingAddressNoCache,'Mailing address mismatches no cache'); 
        Test.stopTest();
    }

    /**
    * @description test Case Created by Agent User or Address Change of an account initiated by Agent User
    * This test is used to cover UTIL_HouseholdManageAddress.createCasesAndTasksForMembers(caseAndTaskJson);
    * @name   testCreateCasesAndTasksForMembers
    */     
    @isTest static void testCreateCasesAndTasksForMembers(){
        User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser(commonAgentUser);
        daoMockHelperInstance.isCCCUser = false;
        Account acct = (Account) JSON.deserializeStrict(createIndividualWithValues(),Account.class);
        acct.IsPrivacyOptionsShared__c= true;
        acct.ClientIdentifier__c = 'SGGSP81L8XB';
        acct.Gender__pc = 'Female';
        acct.id = Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix() + '0'.repeat(11) + '1';
        String caseAndTaskJson = '{"newAddress":{"street1":"3 Statefarm Plaza","street2":"BLDN M","street3":"Floor 3", '+
            '"city":"Bloomington", "state":"IL", "zipCode":"617048563", "country":"United States"},"toastName":"success",'+
            '"successMembers":[{"id":"SGGSP81L8XB","sfdcId":"'+acct.id+'",'+
            '"name":"Test Acct","address":"1 Statefarm Plaza, Bloomington, IL-61704, United States","recordTypeName":"individual","url":"url", '+
            '"oldAddress":{"street1":"1 Statefarm Plaza","street2":"BLDN M","street3":"Floor 3", "city":"Bloomington", '+
            '"state":"IL", "zipCode":"617048563", "country":"United States"}}]}';
        Test.startTest();    
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);        
        System.runAs(agentUser){
            UTIL_HouseholdManageAddress.createCasesAndTasksForMembers(caseAndTaskJson);
        }
        Test.stopTest();
       List<Account> accList = [SELECT Id from Account where id=:acct.id];
       System.assert(accList != null, 'Account list is not empty');
    }
    
    /**
    * @description test Case Created by Agent User or Address Change of an account initiated by Agent User
    * This test is used to cover UTIL_HouseholdManageAddress.createCasesAndTasksForMembers(caseAndTaskJson);
    * @name   testCreateCasesAndTasksForMembersWithSameAddress
    */     
    @isTest static void testCreateCasesAndTasksForMembersWithSameAddress(){
        User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser(commonAgentUser);
        daoMockHelperInstance.isCCCUser = false;
        Account acct = (Account) JSON.deserializeStrict(createIndividualWithValues(),Account.class);
        acct.IsPrivacyOptionsShared__c= true;
        acct.ClientIdentifier__c = 'SGGSP81L8XB';
        acct.Gender__pc = 'Female';
        acct.id = Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix() + '0'.repeat(11) + '1';
        String caseAndTaskJson = '{"newAddress":{"street1":"3 Statefarm Plaza","street2":"BLDN M","street3":"Floor 3", '+
            '"city":"Bloomington", "state":"IL", "zipCode":"617048563", "country":"United States"},"toastName":"success",'+
            '"successMembers":[{"id":"SGGSP81L8XB","sfdcId":"'+acct.id+'",'+
            '"name":"Test Acct","address":"1 Statefarm Plaza, Bloomington, IL-61704, United States","recordTypeName":"individual","url":"url", '+
            '"oldAddress":{"street1":"3 Statefarm Plaza","street2":"BLDN M","street3":"Floor 3", "city":"Bloomington", '+
            '"state":"IL", "zipCode":"617048563", "country":"United States"}}]}';
        Test.startTest();   
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);            
        System.runAs(agentUser){
            UTIL_HouseholdManageAddress.createCasesAndTasksForMembers(caseAndTaskJson);
        }
        Test.stopTest();
       List<Account> accList = [SELECT Id from Account where id=:acct.id];
       System.assert(accList != null, 'Account list is not empty');
    }

    /**
    * @description test Case validate and save individual customers with success message
    * @name   testValidateAndSaveIndividualSuccess
    */     
    @isTest static void testValidateAndSaveIndividualSuccess() {
        User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser(commonAgentUser);
        daoMockHelperInstance.isCCCUser = false;
        Account acct = (Account) JSON.deserializeStrict(createIndividualWithValues(),Account.class);
        acct.IsPrivacyOptionsShared__c= true;
        acct.ClientIdentifier__c = 'SGGSP81L8XB';
        acct.Gender__pc = 'Female';
        acct.id = Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix() + '0'.repeat(11) + '1';
        daoMockHelperInstance.acct = acct;
        daoMockAccountInstance.clntIdToAcctIdMap.put(acct.clientidentifier__c, acct.id);
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);        
        System.runAs(agentUser) {
            Test.startTest();
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            UTIL_HouseholdManageAddress.helperDAOInstance = daoMockHelperInstance;
            UTIL_HouseholdManageAddress.daoInstance = daoMockAccountInstance;
            HttpRequest testMockReq = new HttpRequest();
            testMockReq.setMethod(UTIL_CreateCustomerConstants.PATCH);
            testMockReq.setHeader('Content-Type', 'application/json');
            Account uptAccount = updateIndividualWithValues();
            uptAccount.Id = acct.Id;
        	uptAccount.IsPrivacyOptionsShared__c= true;
        	uptAccount.ClientIdentifier__c = 'SGGSP81L8XB';
            uptAccount.Gender__pc = 'Male';
            String hhMembAddrJSON = '{"addressType":"US","address1":"2802 Rainbow Ave Apt 6","city":"Bloomington","country":"US","zip":"617048563",'+
                '"state":"IL","addressStandardizationCode":"F","associateId":"W08H21YS000","agentAssociateId":null,'+
                '"membersData":[{"customerType":"Individual","clientId":"SGGSP81L8XB"}]}';
            daoMockHelperInstance.acct = new Account(Id=acct.Id);
            daoMockHelperInstance.acct = daoMockHelperInstance.getAccountDetails(acct.Id);
            UTIL_AccountCreateEditHelper.mockAccount = acct;
            Continuation cont = (Continuation)UTIL_HouseholdManageAddress.validateAndSave(hhMembAddrJSON);
            Map<String, HttpRequest> requests = cont.getRequests();
            List<object> objectList = new List<object>();
            object mockRequest = daoMockHelperInstance.getContinuationState(cont,testMockReq);
            objectList.add(mockRequest);
            System.assertEquals(1, requests.size(),'request size equals to 1');

            HttpResponse mockResponse = new HttpResponse();
            String responseString = '{"success":false,"customerResponse":[{"data":{"clientId":"HGZ9JBKKNYC","attributes":{"customerType":"Individual",'+
                '"individualCustomer":{"individualName":{"firstName":"TEST FNAME","lastName":"TEST LNAME COA"},"homePhoneNumber":"3896723231"},'+
                '"mailingAddress":{"addressType":"US","street1":"3257 BREMERTON LN","city":"AURORA","state":"IL","postalCode":"605047267","country":"UNITED STATES"},'+
                '"emailAddress":"EMAILY456@GMAIL.COM"}}}]}';
            
            mockResponse.setBody(responseString);
            mockResponse.setStatusCode(200);
            List<String> labels = new List<String>{responseString};
            UTIL_AccountCreateEditHelper.mockResponse = mockResponse;
        	daoMockHelperInstance.mockResponse = mockResponse;
            Object result = UTIL_HouseholdManageAddress.processBulkAddrUpdateResponse(labels,mockResponse);
            List<Object> resultList;
            if(result instanceOf List<Object>) {
                    resultList = (List<Object>) result;
             }
            Test.stopTest();
       }
    }
    
    /**
    * @description test Case to validate and save individual customers with warning message
    * @name   testValidateAndSaveIndividualWarning
    */     
    @isTest static void testValidateAndSaveIndividualWarning() {
        User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser(commonAgentUser);
        daoMockHelperInstance.isCCCUser = false;
        Account acct = (Account) JSON.deserializeStrict(createIndividualWithValues(),Account.class);
        acct.IsPrivacyOptionsShared__c= true;
        acct.ClientIdentifier__c = 'SGGSP81L8XB';
        acct.Gender__pc = 'Female';
        acct.id = Schema.Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix() + '0'.repeat(11) + '1';
        daoMockHelperInstance.acct = acct;
        daoMockAccountInstance.clntIdToAcctIdMap.put(acct.clientidentifier__c, acct.id);
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);        
        System.runAs(agentUser) {
            Test.startTest();
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            UTIL_HouseholdManageAddress.helperDAOInstance = daoMockHelperInstance;
            UTIL_HouseholdManageAddress.daoInstance = daoMockAccountInstance;
            HttpRequest testMockReq = new HttpRequest();
            testMockReq.setMethod(UTIL_CreateCustomerConstants.PATCH);
            testMockReq.setHeader('Content-Type', 'application/json');
            Account uptAccount = updateIndividualWithValues();
            uptAccount.Id = acct.Id;
        	uptAccount.IsPrivacyOptionsShared__c= true;
        	uptAccount.ClientIdentifier__c = 'SGGSP81L8XB';
            uptAccount.Gender__pc = 'Male';
            String hhMembAddrJSON = '{"addressType":"US","address1":"2802 Rainbow Ave Apt 6","city":"Bloomington","country":"US","zip":"617048563",'+
                '"state":"IL","addressStandardizationCode":"F","associateId":"W08H21YS000","agentAssociateId":null,'+
                '"membersData":[{"customerType":"Individual","clientId":"SGGSP81L8XB"}]}';
            daoMockHelperInstance.acct = new Account(Id=acct.Id);
            daoMockHelperInstance.acct = daoMockHelperInstance.getAccountDetails(acct.Id);
            UTIL_AccountCreateEditHelper.mockAccount = acct;
            Continuation cont = (Continuation)UTIL_HouseholdManageAddress.validateAndSave(hhMembAddrJSON);
            Map<String, HttpRequest> requests = cont.getRequests();
            List<object> objectList = new List<object>();
            object mockRequest = daoMockHelperInstance.getContinuationState(cont,testMockReq);
            objectList.add(mockRequest);
            System.assertEquals(1, requests.size(),'request size equals to 1');

            HttpResponse mockResponse = new HttpResponse();
            String responseString = '{"success":false,"customerResponse":[{"errors":[{"status":"500","code":"soap_fault_04","title":"SOAPFaultException","detail":"SPCUS call failed"}]},'+
                '{"data":{"clientId":"HGZ9JBKKNYC","attributes":{"customerType":"Individual",'+
                '"individualCustomer":{"individualName":{"firstName":"TEST FNAME","lastName":"TEST LNAME COA"},"homePhoneNumber":"3896723231"},'+
                '"mailingAddress":{"addressType":"US","street1":"3257 BREMERTON LN","city":"AURORA","state":"IL","postalCode":"605047267","country":"UNITED STATES"},'+
                '"emailAddress":"EMAILY456@GMAIL.COM"}}}]}';
            
            mockResponse.setBody(responseString);
            mockResponse.setStatusCode(200);
            List<String> labels = new List<String>{responseString};
            UTIL_AccountCreateEditHelper.mockResponse = mockResponse;
        	daoMockHelperInstance.mockResponse = mockResponse;
            Object result = UTIL_HouseholdManageAddress.processBulkAddrUpdateResponse(labels,mockResponse);
            List<Object> resultList;
            if(result instanceOf List<Object>) {
                    resultList = (List<Object>) result;
             }
            Test.stopTest();
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
}