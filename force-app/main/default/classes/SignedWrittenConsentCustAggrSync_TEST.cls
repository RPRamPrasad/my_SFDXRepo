/****************************************************************************************
Name: SignedWrittenConsentCustAggrSync_TEST
=========================================================================================
@description Test class written for SignedWrittenConsentCustAggrSync
Team: ClubCar
=========================================================================================
VERSION         AUTHOR                    DATE                   DETAIL
1.0             ClubCar                  03/15/2021              Initial Development
******************************************************************************************/
@isTest(SeeAllData=false)
private class SignedWrittenConsentCustAggrSync_TEST {
    
    private static User proxyUser;
    private static User sysAdminuser;    
    private static Account testAccount;
    private static Opportunity oppForSwc;
    private static User systemAdmin;
    private static String optyRecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunity_Management').getRecordTypeId();
    
    // test setup method to insert/ update test data that will be used during entire test run
    @testSetup
    private static void setUp() {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
            insert systemUser;
            CS001_ByPassTriggerAtoF__c accountByPassTrigger= new CS001_ByPassTriggerAtoF__c(Override_AccountBeforeInsert__c=false,Override_AgentRoleAfterInsert__c=false);
            insert accountByPassTrigger;
            AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(Name=UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER,SFDC_USER_ID__c=systemUser.id);            
            insert sysAdminUserIdSetting;
            CS001_ByPassTriggerGtoZ__c objectBasedByPassTrigger = CS001_ByPassTriggerGtoZ__c.getInstance();
            objectBasedByPassTrigger.Override_OpportunityAfterInsert__c = true;
            insert objectBasedByPassTrigger;
            User testProxyUser1 = new User(Alias='Prox',LastName='opportunityAg',Username='TestProxUserForOppTst11@statefarm.com',UserExternalID__c='123testP',Servicing_Agent_Associate_ID__c='123test');  
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            insert proxyUser;
        	insertTechnicalPlatformDetails();
    }

    // test Account Phone fields are Updated based on the request when MPDSync__c record is created
    // private static testMethod void testSwcUpdatePhoneCalloutToAggregatorSucess(){
    //     User queryProxy = [Select id from User where username = 'TestProxUserForOppTst11@statefarm.com' LIMIT 1];  
    //     createTestAccount();
    //     oppForSwc = new Opportunity(accountId = testAccount.id, name='Opp',closeDate=system.today(), stageName='Assigned',LOB__c='Auto',Description='Test Descrption',RecordTypeId=optyRecordTypeId,OwnerId = queryProxy.id);
    //     insert oppForSwc; 
    //     SignedWrittenConsent__c signedWrittenConsentRecord = buildSwcRecord(System.Today(), System.Today()+30);
    //     insert signedWrittenConsentRecord;
    //     MPDSync__c mpdSyncRecord = buildMpdSyncRecord(signedWrittenConsentRecord.id);
    //     String responseString = '{"data":{"type":"customer","clientId":"SGGSP81L8XB","attributes":{"customerType":"Organization","organizationCustomer":' +
    //             '{"organizationName":"Sample Organization","organizationType":"Unknown Organization"},' + 
    //             '"mailingAddress":{"addressType":"US","preAddress":"Attn: Bob","street1":"1028 goldfinch way","street2":"Apt 9","city":"Bloomington","country":"US","postalCode":"61714","state":"IL","addressStandardizationCode":"C"}},'+
    //             '"relationships":{"agents":{"data":[{"id":"BZCWX1YS000","type":"ASSOCIATE","attributes":{"relationshipNature":"Ex-Client","relationshipStartDate":"2013-12-31"}},{"id":"HLGP84K3000",'+
    //             '"type":"ASSOCIATE","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2014-07-09"}},{"id":"29VXY1YS000","type":"ASSOCIATE","attributes":'+
    //             '{"relationshipNature":"Client","relationshipStartDate":"2015-02-10"}},{"id":"J0X494K7000","type":"ASSOCIATE","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2013-07-22"}},'+
    //             '{"id":"5ZZFQ1YS000","type":"ASSOCIATE","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2017-04-10"}}]}}}}';
    //     Test.startTest();        
    //     SignedWrittenConsentAggrMockHttpResp mockResponse = new SignedWrittenConsentAggrMockHttpResp(200,'OK',responseString);
    //     Test.setMock(HttpCalloutMock.class, mockResponse);
    //     insert mpdSyncRecord;
    //     Test.stopTest();
    //     List<ExceptionLog__c> swcCustAggrSyncExLog = [Select Class__c,Exception_Message__c from ExceptionLog__c where Class__c='SignedWrittenConsentCustAggrSync' order by createdDate desc limit 1];
    //     System.assert(swcCustAggrSyncExLog.size() == 0,'No Exception Log');        
    // }
    
    // // test Account Phone field is Updated to null based on the request when MPDSync__c record is created 
    // private static testMethod void testSwcUpdatePhoneToNullSucess(){
    //     User queryProxy = [Select id from User where username = 'TestProxUserForOppTst11@statefarm.com' LIMIT 1];  
    //     createTestAccount();
    //     oppForSwc = new Opportunity(accountId = testAccount.id, name='Opp',closeDate=system.today(), stageName='Assigned',LOB__c='Auto',Description='Test Descrption',RecordTypeId=optyRecordTypeId,OwnerId = queryProxy.id);
    //     insert oppForSwc; 
    //     SignedWrittenConsent__c signedWrittenConsentRecord = buildSwcRecord(System.Today(), System.Today()+30);
    //     insert signedWrittenConsentRecord;
    //     MPDSync__c mpdSyncRecord = buildMpdSyncRecord(signedWrittenConsentRecord.id);
    //     mpdSyncRecord.UpdateFieldsJSON__c = '{"personHomePhone" : "3095318889","personMobilePhone" : ""}';
    //     String responseString = '{"data":{"type":"customer","clientId":"SGGSP81L8XB","attributes":{"customerType":"Organization","organizationCustomer":' +
    //             '{"organizationName":"Sample Organization","organizationType":"Unknown Organization"},' + 
    //             '"mailingAddress":{"addressType":"US","preAddress":"Attn: Bob","street1":"1028 goldfinch way","street2":"Apt 9","city":"Bloomington","country":"US","postalCode":"61714","state":"IL","addressStandardizationCode":"C"}},'+
    //             '"relationships":{"agents":{"data":[{"id":"BZCWX1YS000","type":"ASSOCIATE","attributes":{"relationshipNature":"Ex-Client","relationshipStartDate":"2013-12-31"}},{"id":"HLGP84K3000",'+
    //             '"type":"ASSOCIATE","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2014-07-09"}},{"id":"29VXY1YS000","type":"ASSOCIATE","attributes":'+
    //             '{"relationshipNature":"Client","relationshipStartDate":"2015-02-10"}},{"id":"J0X494K7000","type":"ASSOCIATE","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2013-07-22"}},'+
    //             '{"id":"5ZZFQ1YS000","type":"ASSOCIATE","attributes":{"relationshipNature":"Prospect","relationshipStartDate":"2017-04-10"}}]}}}}';
    //     Test.startTest();        
    //     SignedWrittenConsentAggrMockHttpResp mockResponse = new SignedWrittenConsentAggrMockHttpResp(200,'OK',responseString);
    //     Test.setMock(HttpCalloutMock.class, mockResponse);
    //     insert mpdSyncRecord;
    //     Test.stopTest();
        
    //     List<ExceptionLog__c> swcCustAggrSyncExLog = [Select Class__c,Exception_Message__c from ExceptionLog__c where Class__c='SignedWrittenConsentCustAggrSync' order by createdDate desc limit 1];
    //     System.assert(swcCustAggrSyncExLog.size() == 0,'Unexpected Exception Log List Size');
    // }
    
  	// test Callout to Aggregator with not desired response
    @isTest
    private static void testCalloutToAggregatorNotDesiredResp(){
        User queryProxy = [Select id from User where username = 'TestProxUserForOppTst11@statefarm.com' LIMIT 1];  
        createTestAccount();
        oppForSwc = new Opportunity(accountId = testAccount.id, name='Opp',closeDate=system.today(), stageName='Assigned',LOB__c='Auto',Description='Test Descrption',RecordTypeId=optyRecordTypeId,OwnerId = queryProxy.id);
        insert oppForSwc; 
        SignedWrittenConsent__c signedWrittenConsentRecord = buildSwcRecord(System.Today(), System.Today()+30);
        insert signedWrittenConsentRecord;
        MPDSync__c mpdSyncRecord = buildMpdSyncRecord(signedWrittenConsentRecord.id);
        String responseString = '{"errors": [{"status": "406","code": "invalid_auth_01","title": "Fault occurred while processing.",' +
                '"detail": " 2016-06-06-12.59.42.943M2DNJ    0   - Invalid credentials",' +
                '"source": {"pointer": "data/attributes/customer"}}]}';
        Test.startTest();        
        SignedWrittenConsentAggrMockHttpResp mockResponse = new SignedWrittenConsentAggrMockHttpResp(406,'OK',responseString);
        Test.setMock(HttpCalloutMock.class, mockResponse);
        insert mpdSyncRecord;
        Test.stopTest();
        
        List<ExceptionLog__c> swcCustAggrSyncExLog = [Select Class__c,Exception_Message__c from ExceptionLog__c where Class__c='SignedWrittenConsentCustAggrSync' order by createdDate desc limit 1];
        System.assert(swcCustAggrSyncExLog.get(0).Exception_Message__c != null,'No Exception Log');
    }
    
    // test Callout to Aggregator Failure
    @isTest
    private static void testCalloutToAggregatorFailure(){
        User queryProxy = [Select id from User where username = 'TestProxUserForOppTst11@statefarm.com' LIMIT 1];  
        createTestAccount();
        oppForSwc = new Opportunity(accountId = testAccount.id, name='Opp',closeDate=system.today(), stageName='Assigned',LOB__c='Auto',Description='Test Descrption',RecordTypeId=optyRecordTypeId,OwnerId = queryProxy.id);
        insert oppForSwc; 
        SignedWrittenConsent__c signedWrittenConsentRecord = buildSwcRecord(System.Today(), System.Today()+30);
        insert signedWrittenConsentRecord;
        MPDSync__c mpdSyncRecord = buildMpdSyncRecord(signedWrittenConsentRecord.id);
        String responseString = '{"errors": [{"status": "422","code": "address_standardization_03","title": "Address Standardization",' +
                '"detail": "Address Standardization Issue(s) must be resolved","source": {"pointer": "data/customerAttribute/mailingAddress"},' + 
                '"meta": {"addressStandardizationOutcomes":    {"addressStandardizationStatusCode": "06","standardizedAddress": null,"standardizedMessage":[{' +
                '"addressStandardizationMessageCode": "SOT412","addressStandardizationMessageText": "Multiple matches found in Postal Service Directory. ' +
                'Enter additional information."},{"addressStandardizationMessageCode": "SOT412","addressStandardizationMessageText": ' +
                '"Address is not in Postal Service Directory. Verify address is correct."}]}}}]}';
        Test.startTest();        
        SignedWrittenConsentAggrMockHttpResp mockResponse = new SignedWrittenConsentAggrMockHttpResp(null,'OK',responseString);
        Test.setMock(HttpCalloutMock.class, mockResponse);
        insert mpdSyncRecord;
        Test.stopTest();
        List<ExceptionLog__c> swcCustAggrSyncExLog = [Select Class__c,Exception_Message__c from ExceptionLog__c where Class__c='SignedWrittenConsentCustAggrSync' order by createdDate desc limit 1];
        System.assert(swcCustAggrSyncExLog.get(0).Exception_Message__c != null,'No Exception Log');
    }

    //test MPDSync__c create exception 
    @isTest
    private static void testSwcUpdatePhoneExecption(){
        User queryProxy = [Select id from User where username = 'TestProxUserForOppTst11@statefarm.com' LIMIT 1];  
        createTestAccount();
        oppForSwc = new Opportunity(accountId = testAccount.id, name='Opp',closeDate=system.today(), stageName='Assigned',LOB__c='Auto',Description='Test Descrption',RecordTypeId=optyRecordTypeId,OwnerId = queryProxy.id);
        insert oppForSwc; 
        SignedWrittenConsent__c signedWrittenConsentRecord = buildSwcRecord(System.Today(), System.Today()+30);
        signedWrittenConsentRecord.InitiatedFromId__c = null;
        insert signedWrittenConsentRecord;
        MPDSync__c mpdSyncRecord = buildMpdSyncRecord(signedWrittenConsentRecord.id);
        
        Test.startTest();
        insert mpdSyncRecord;
        Test.stopTest();
        
        List<ExceptionLog__c> swcCustAggrSyncExLog = [SELECT Id from ExceptionLog__c class__c where class__c = 'SignedWrittenConsentCustAggrSync'];           
        System.Assert(swcCustAggrSyncExLog.size() ==1, 'Swc Customer Aggregator Sync Execption was not generated'); 
    }

    //test MPDSync__c is not updated when Trigger is bypassed 
    @isTest
    private static void testMpdSyncTriggerBypass(){
        CS001_ByPassTriggerGtoZ__c objectBasedByPassTrigger = CS001_ByPassTriggerGtoZ__c.getInstance();
        objectBasedByPassTrigger.Override_MpdSyncAfterInsert__c = true;
        update objectBasedByPassTrigger; 
        User queryProxy = [Select id from User where username = 'TestProxUserForOppTst11@statefarm.com' LIMIT 1];  
        createTestAccount();
        oppForSwc = new Opportunity(accountId = testAccount.id, name='Opp',closeDate=system.today(), stageName='Assigned',LOB__c='Auto',Description='Test Descrption',RecordTypeId=optyRecordTypeId,OwnerId = queryProxy.id);
        insert oppForSwc; 
        SignedWrittenConsent__c signedWrittenConsentRecord = buildSwcRecord(System.Today(), System.Today()+30);
        signedWrittenConsentRecord.InitiatedFromId__c = null;
        insert signedWrittenConsentRecord;
        MPDSync__c mpdSyncRecord = buildMpdSyncRecord(signedWrittenConsentRecord.id);
        
        Test.startTest();
        insert mpdSyncRecord;
        Test.stopTest();
        
        System.AssertEquals(false, mpdSyncRecord.IsProcessed__c, 'Mpd Sync Record is updated');
    }
  

    // helper method to insert test Account records
    private static void createTestAccount(){
        systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com'); 
        insert systemAdmin;
        System.runas(systemAdmin){
            testAccount= new Account(firstname ='SSSHHHH', lastname='SSSSSHHHH', ClientIdentifier__c = 'cid1', Edit_In_VFP__c = true,
                                     personHomePhone = '4123456789',personMobilePhone = '3127893456');
            insert testAccount;
        }       
    }

    // helper method to build Test SignedWrittenConsent record
    private static SignedWrittenConsent__c buildSwcRecord(Date consentStartDate, Date consentEndDate) {
        SignedWrittenConsent__c signedWrittenConsentRecord = new SignedWrittenConsent__c();
        signedWrittenConsentRecord.InitiatedFromId__c = oppForSwc.Id;
        signedWrittenConsentRecord.Account__c = oppForSwc.AccountId;
        signedWrittenConsentRecord.Status__c = 'Requested';
        signedWrittenConsentRecord.RequestStartDate__c = consentStartDate;
        signedWrittenConsentRecord.RequestEndDate__c = consentEndDate;
        signedWrittenConsentRecord.RequestedDate__c = System.Today();
        return signedWrittenConsentRecord;
    }

    // helper method to build Test MPDSync__c record
    private static MPDSync__c buildMpdSyncRecord(Id swcId) {
        MPDSync__c mpdSyncRecord = new MPDSync__c();
        mpdSyncRecord.InitiatingProcessRecordId__c = swcId;
        mpdSyncRecord.Account__c = oppForSwc.AccountId;
        mpdSyncRecord.UpdateFieldsJSON__c = '{"personHomePhone" : "3095318889","personMobilePhone" : "2038211144"}';
        mpdSyncRecord.InitiatingProcess__c = 'MarketingCloud-SWC';
        return mpdSyncRecord;
    }
    
    
    //Class implements HttpCalloutmock and sends a mock response for a specific endpoint
    private class SignedWrittenConsentAggrMockHttpResp implements HttpCalloutMock{
        protected Integer code;
        protected String status;
        protected String responseString;
        //Constructors
        private SignedWrittenConsentAggrMockHttpResp(Integer code, String status, String responseString) {
            this.code = code;
            this.status = status;
            this.responseString = responseString;
        }     
        
        /**
		* @description : Implement this interface method
		* @param request : Request body sent to service
		* @return response
		*/
        public HTTPResponse respond(HTTPRequest request) {
            //Create a fake response
            system.assert(request.getEndpoint()!= null);
            system.assertEquals('callout:Customer_Aggregator_Process_Id/customer', request.getEndpoint(),'Endpoint is incorrect');
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(responseString);
            response.setStatusCode(code);
            response.setStatus(status);
            return response; 
        }
    }
    
    //Helper method to insert TechnicalPlatformDetails Custom Settings
    private static void insertTechnicalPlatformDetails(){
        CS_TechnicalPlatform__c srKey = new CS_TechnicalPlatform__c();
        srKey.Name = 'SR_API_KEY';
        srKey.Value__c = 'Test Key';
        
        CS_TechnicalPlatform__c srCategory = new CS_TechnicalPlatform__c();
        srCategory.Name = 'SR_CATEGORY';
        srCategory.Value__c = 'a';
        insert new List<CS_TechnicalPlatform__c>{srKey, srCategory};
    }
}