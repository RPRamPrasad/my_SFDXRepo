/**
    * @Name: AP_StageOrchestrationTrigger_Test
    * @Author: Team Dauntless 
    * @description This class contains unit tests for validating 
    * @Last Modification: 05/31/2023
    */
    
   @IsTest(seeAllData=false)
    private class AP_StageOrchestrationTrigger_Test {
        public static Map<String,Id> profileNameIdMap;  
        private static User systemUser;
        private static User testAPIUser;
        private static AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting;
        private static PermissionSetAssignment psassignment;
        private static List<Account> accountList ;
        private static List<StageOrchestration__c> listOfStageOrchestrationforDeleteTransaction;
        private static List<StageOrchestration__c> listofStageOrchestrationforCustomerSync;
        private static List<StageOrchestration__c> listofStageOrchestrationrecord;
        private static CS001_ByPassTriggerAll__c passTriggerAll;
        private static CS_StageOrchestration_Counts__c counts;
        private static final String CLIENT_IDENTIFIER='IAMCLIENTID';
        private static AP_StageOrchestrationTriggerTestWrapper apWrap = new AP_StageOrchestrationTriggerTestWrapper();
        
        /**
         * @description Test Setup Data
         */
        @testsetup
        public static void testSetUpData() {
        	TestDataFactory_CustomSetting.createDeleteRecordConfig('1.03 SF API Only User - Data & User Admin', 'Account');
        }
        
        /**
         * @description This method will create test data
         */
        public static void setup(){
            
            systemUser = UTIL_StageOrchestrationTestUtils.buildSystemAdmin('Alias','CmpMemSA','remCmpMemSysAd@statefarm.com');
            testAPIUser= UTIL_StageOrchestrationTestUtils.buildtestAPIUser('test','testing','test@statefarm.com');
            insert systemUser;
            insert testAPIUser;
            psassignment = UTIL_StageOrchestrationTestUtils.assignPSet(testAPIUser);
            insert psassignment;
            passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=true);
            counts= new CS_StageOrchestration_Counts__c(Retry_Count__c=3,Chunk_Size__c=5,CustomerSync_Chunksize__c=15);
        }

        private static void createBulkDataForCustomerSync(){
			integer stageRecordSize = 25;
            accountList=buildAccountData(stageRecordSize);
            listofStageOrchestrationrecord=new List<StageOrchestration__c> ();
            apWrap.createListOfStageOrchestrationrecord(listofStageOrchestrationrecord);
        }
  /*      
        static void SetFSCCustomSetting()
        {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();	
                sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(SFDC_USER_ID__c=systemUser.id);	
            	insert sysAdminUserIdSetting;	
                insert counts;	
                insert passTriggerAll;	
                
        }
*/

        @isTest
        static void testNumberOfJobsBeingCreatedforCustomerSync(){
        	setup();
            createBulkDataForCustomerSync();  
            
            System.runAs(systemUser) {
                AP_StageOrchTriggerTestHandler.SetFSCCustomSetting(systemUser,counts, passTriggerAll);
                //SetFSCCustomSetting();
                insert accountList;
                passTriggerAll.Override_All__c=false;	
                update passTriggerAll;
            }
           
            System.runAs(testAPIUser){
                Test.startTest(); 
                insert listofStageOrchestrationrecord;
                system.assertEquals(math.ceil(listofStageOrchestrationrecord.size()/counts.CustomerSync_Chunksize__c),system.Limits.getQueueableJobs(), 'Expected parameter should be equals to the actual parameter');
                Test.stopTest();
            }
            
            List<Account> testacc2=[select id,lastname, ClientIdentifier__c from account Where id=:accountList.get(22).Id];
            system.assertEquals('testid22', testacc2.get(0).clientidentifier__c, 'Expected parameter should be equals to the actual parameter');            
            apWrap.assertSSLLSS22(testacc2);            
        }

        @isTest
        static void testNumberOfJobsBeingCreatedAndExecuteProcessors(){
        	setup();
            createBulkData();  
            
            System.runAs(systemUser) {
                AP_StageOrchTriggerTestHandler.SetFSCCustomSetting(systemUser,counts, passTriggerAll);
                    //SetFSCCustomSetting();
                insert accountList;
                passTriggerAll.Override_All__c=false;
                update passTriggerAll;
            }
           
            System.runAs(testAPIUser){
                Test.startTest(); 
                insert listofStageOrchestrationrecord;
                system.assertEquals(math.ceil(listofStageOrchestrationrecord.size()/counts.Chunk_Size__c),system.Limits.getQueueableJobs(), 'Expected parameter should be equals to the actual parameter');
                Test.stopTest();
            }

            List<Account> testacc1 = [Select Id,ClientIdentifier__c From account Where id=:accountList.get(100).Id];
            system.assertEquals(0,testacc1.size(), 'Size of List<Account> should be 0');
        }
        
        private static void createBulkData(){
			integer stageRecordsSize = 198;
            accountList=buildAccountData(stageRecordsSize);
            listofStageOrchestrationrecord=new List<StageOrchestration__c> ();
            StageOrchestration__c s;
            for(integer stageRecord=0;stageRecord<accountList.size();stageRecord++){

                s=new StageOrchestration__c();
                s.VersionNumber__c=1.0;
                s.IdentifierValue__c=accountList.get(stageRecord).ClientIdentifier__c;
                
                StageOrchestration__c retStOrch = evaluateTransactionAndValue0TO141(stageRecord, accountList);
                s.TransactionType__c = retStOrch.TransactionType__c;
                s.Value__c = retStOrch.Value__c;
                
                 listofStageOrchestrationrecord.add(s);           
            }
        }
        
        private static StageOrchestration__c evaluateTransactionAndValue0TO141(Integer stageRecord, List<Account> accountList){

            StageOrchestration__c stageOrch = new StageOrchestration__C();
            Boolean isInRange = false;

            if(stageRecord>=0 && stageRecord<101) {
                stageOrch.TransactionType__c=UTIL_StageOrchestrationConstants.RECORD_REMOVE_DELETE_TRANSACTION;
                stageOrch.Value__c=buildJSONForDeleteTransaction(accountList.get(stageRecord).ClientIdentifier__c);
                isInRange = true;
            }
            else if (stageRecord>=101 && stageRecord<141){
                stageOrch.TransactionType__c=UTIL_StageOrchestrationConstants.CHANGE_OF_AGENT_TRANSACTION;
                stageOrch.Value__c='{Random JSON}';   
                isInRange = true;
            }else if(isInRange == false){
                stageOrch = evaluateTransactionAndValue141To198(stageRecord);
            }

            return stageOrch;
        }

        private static StageOrchestration__c evaluateTransactionAndValue141To198(Integer stageRecord){

            StageOrchestration__c stageOrch = new StageOrchestration__C();

            if (stageRecord>=141 && stageRecord<161){
                stageOrch.TransactionType__c=UTIL_StageOrchestrationConstants.REMOVE_FROM_BOOK_TRANSACTION;
                stageOrch.Value__c='{Random JSON}';
            }
            else if (stageRecord>=161 && stageRecord<181){
                stageOrch.TransactionType__c=UTIL_StageOrchestrationConstants.SEPERATE_TRANSACTION;
                stageOrch.Value__c='{Random JSON}';   
            }
            else if (stageRecord>=181 && stageRecord<198){
                stageOrch.TransactionType__c=UTIL_StageOrchestrationConstants.COMBINE_CUSTOMER_TRANSACTION;
                stageOrch.Value__c='{Random JSON}';   
            }

            return stageOrch;
        }

        @isTest
        static void executePositiveScenarioForDeleteProcessor(){
            setup();
            Account acc= new Account(Edit_In_VFP__c=true,FirstName='Ftest',LastName='Ltest',BillingAddressType__c='US',ClientIdentifier__c=CLIENT_IDENTIFIER);
            System.runAs(systemUser) {
                AP_StageOrchTriggerTestHandler.SetFSCCustomSetting(systemUser,counts, passTriggerAll);
				//SetFSCCustomSetting();
                insert acc;
                passTriggerAll.Override_All__c = false;
                update passTriggerAll;
            }
            
            System.runAs(testAPIUser){
                Test.startTest(); 
                StageOrchestration__c stgorc = new StageOrchestration__c();
                stgorc.TransactionType__c=UTIL_StageOrchestrationConstants.RECORD_REMOVE_DELETE_TRANSACTION;
                stgorc.VersionNumber__c=1.0;
                stgorc.IdentifierValue__c=CLIENT_IDENTIFIER;
                stgorc.Value__c=buildJSONForDeleteTransaction(CLIENT_IDENTIFIER);
                insert stgorc;
                Test.stopTest();
            }
            List<Account> testacc = [Select Id From account Where id=:acc.Id];
            system.assertEquals(0,testacc.size(), 'Size of List<Account> should be 0');
        }
        
        @isTest
        static void executechangeOfAgentTransaction(){
            
            setup();
             System.runAs(systemUser) {
                insert passTriggerAll;
                insert counts;
                passTriggerAll.Override_All__c = false;
                update passTriggerAll;
            }
            
            StageOrchestration__c result=insertStageOrcWithTestApiUser(UTIL_StageOrchestrationConstants.CHANGE_OF_AGENT_TRANSACTION);
            system.assert(String.isNotBlank(result.Error__c), 'StageOrchestration__c.Error__c should not be blank');
            
        }
        
        @isTest
        static void executecustomerSyncTransaction(){
            setup();
             System.runAs(systemUser) {
                insert counts;
                insert passTriggerAll;
                passTriggerAll.Override_All__c=false;
                update passTriggerAll;
                
            }
           
            StageOrchestration__c result=insertStageOrcWithTestApiUser(UTIL_StageOrchestrationConstants.CUSTOMER_SYNC_TRANSACTION);
            System.assertEquals(UTIL_StageOrchestrationConstants.FAILURE_STATUS,result.Status__c, 'Expected parameter should be equals to the actual parameter');
            system.assert(String.isNotBlank(result.Error__c), 'StageOrchestration__c.Error__c should not be blank');
        }
        
        @isTest
        static void executePositiveScenarioForcustomerSync(){
            setup();
            Account accrecord = new Account(Edit_In_VFP__c=true,FirstName='Ftest',LastName='Ltest',BillingAddressType__c='US',ClientIdentifier__c=CLIENT_IDENTIFIER);
             System.runAs(systemUser) {
				UTIL_SetFSCCustomSettings_TEST.setFSCSettings(); 
                insert counts;
                insert passTriggerAll;
                insert accrecord;
                passTriggerAll.Override_All__c=false;
                update passTriggerAll;
                
            }
            StageOrchestration__c testRecord=new StageOrchestration__c();
            testRecord.TransactionType__c=UTIL_StageOrchestrationConstants.CUSTOMER_SYNC_TRANSACTION;
            testRecord.IdentifierValue__c=CLIENT_IDENTIFIER;
            testRecord.Value__c=buildJsonAccountOnlyString(CLIENT_IDENTIFIER,String.valueOf(Datetime.now().addMinutes(1).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')),'SSLLSS');
            testRecord.VersionNumber__c=1.0;
            
            System.runAs(testAPIUser) {
                Test.startTest();
                insert testRecord;
                Test.stopTest();
            }
            //StageOrchestration__c result=[SELECT Id, TransactionType__c, Status__c, Error__c, Value__c, VersionNumber__c FROM StageOrchestration__c where id= :testRecord.id];
            //System.assertEquals(UTIL_StageOrchestrationConstants.SUCCESS_STATUS,result.Status__c);
            //system.assert(String.isBlank(result.Error__c));            
            apWrap.assertSuccessStatus(testRecord);
           List<Account> lstAcc=[select id,LastName from Account where clientidentifier__c=:CLIENT_IDENTIFIER];
            if(lstAcc!=null && lstAcc.size()>0)
            {
                for(Account objAcc : lstAcc){
					if(objAcc.lastName == 'SSLLSS'){
           				 system.assertEquals('SSLLSS', objAcc.LastName, 'Expected LastName should be equals to the actual LastName');
                    }
                }
            }
        }
        
        @isTest
        static void executeleadConversionTransaction(){
            setup();
    
    
            Lead lead = new Lead(LastName = 'LTestLead', Status='Open');
            Account acc = new Account(Edit_In_VFP__c=true,FirstName=lead.LastName,LastName=lead.LastName,BillingAddressType__c='US',ClientIdentifier__c='extTestId');  

            UTIL_StageOrchestrationTestUtils.AgentUserWrapper agentWrap = new UTIL_StageOrchestrationTestUtils.AgentUserWrapper();
            agentWrap.a_alias = 'alias';
            agentWrap.a_lastName = 'accOwner';
            agentWrap.a_UserName = 'accOwnerAgent@statefarm.com';
            agentWrap.a_associateId = '123test';
            agentWrap.a_userExternalId = '123test123te';
            agentWrap.a_servicingAgentAssocId = '123test';

            User agentUser = UTIL_StageOrchestrationTestUtils.buildAgentUser(agentWrap);

            System.runAs(systemUser){
				UTIL_SetFSCCustomSettings_TEST.setFSCSettings(); 
                insert counts;
                insert passTriggerAll;
                insert agentUser;
            }
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);

            
            system.runas(agentUser){
                insert lead;
                insert acc;
            }
            system.runAs(systemUser){
            passTriggerAll.Override_All__c = false;
            update passTriggerAll;   
            }
           
            StageOrchestration__c testRecord = new StageOrchestration__c();
            testRecord.Value__c = buildJSON(lead.Id,acc.Id);
            testRecord.TransactionType__c=UTIL_StageOrchestrationConstants.LEAD_CONVERSION_TRANSACTION;
            testRecord.VersionNumber__c=1.0;
            
            System.runAs(agentUser) {
                Test.startTest(); 
                insert testRecord;
                Test.stopTest();
            }
            
            StageOrchestration__c result=[SELECT Id, TransactionType__c, Status__c, Error__c, Value__c, VersionNumber__c FROM StageOrchestration__c where id= :testRecord.id];
            System.assertEquals(UTIL_StageOrchestrationConstants.SUCCESS_STATUS,result.Status__c, 'Expected status should be equals to the actual status');
            system.assert(String.isBlank(result.Error__c), 'Error__c should be blank'); 
            String leadLastName = lead.LastName;
            LeadConversionDetail__c testConversionDetails =[select id from LeadConversionDetail__c where LastName__c= :leadLastName LIMIT 1];
            system.assertNotEquals(null, testConversionDetails, 'LeadConversionDetail__c should not be null');
        }
        
        @isTest
        static void executerecordRemoveDeleteTransaction(){
            setup();
            System.runAs(systemUser) {
                insert passTriggerAll;
                insert counts;
                passTriggerAll.Override_All__c = false;
                update passTriggerAll;
            }
            
            
            StageOrchestration__c testRecord=new StageOrchestration__c();
            testRecord.TransactionType__c=UTIL_StageOrchestrationConstants.RECORD_REMOVE_DELETE_TRANSACTION;
            testRecord.Value__c=null;
            testRecord.VersionNumber__c=1.0;
            System.runAs(testAPIUser) {
                Test.startTest();
                insert testRecord;
                Test.stopTest();
            }
            StageOrchestration__c result=[SELECT Id, TransactionType__c, Status__c, Error__c, Value__c, VersionNumber__c FROM StageOrchestration__c where id= :testRecord.id];
            System.assertEquals(UTIL_StageOrchestrationConstants.FAILURE_STATUS,result.Status__c, 'Expected status should be equals to the actual status');
            system.assert(String.isNotBlank(result.Error__c), 'Error__c should not be blank');
        }
        
        @isTest
        static void executeremoveFromBookTransaction(){
            setup();
            System.runAs(systemUser) {
                insert passTriggerAll;
                insert counts;
                passTriggerAll.Override_All__c = false;
                update passTriggerAll;
            }
            
            StageOrchestration__c result=insertStageOrcWithTestApiUser(UTIL_StageOrchestrationConstants.REMOVE_FROM_BOOK_TRANSACTION);
            System.assertEquals(UTIL_StageOrchestrationConstants.FAILURE_STATUS,result.Status__c, 'Expected status should be equals to the actual status');
            system.assert(String.isNotBlank(result.Error__c), 'Error__c should not be blank');
        }
        
        @isTest
        static void executeseperateTransaction(){
            setup();
            System.runAs(systemUser) {
                insert passTriggerAll;
                insert counts;
                passTriggerAll.Override_All__c = false;
                update passTriggerAll;
            }
           
            StageOrchestration__c result=insertStageOrcWithTestApiUser(UTIL_StageOrchestrationConstants.SEPERATE_TRANSACTION);
            System.assertEquals(UTIL_StageOrchestrationConstants.FAILURE_STATUS,result.Status__c, 'Expected status should be equals to the actual status');
            system.assert(String.isNotBlank(result.Error__c), 'Error__c should not be blank');
        }
        @isTest
        static void donotExecuteTrigger(){
            
            setup(); 
            System.runAs(systemUser) {
                insert passTriggerAll;
                insert counts;
            }
           
            StageOrchestration__c result=insertStageOrcWithTestApiUser(UTIL_StageOrchestrationConstants.CUSTOMER_SYNC_TRANSACTION);
            System.assertEquals(result.Status__c,UTIL_StageOrchestrationConstants.DEFAULT_STATUS, 'Expected status should be equals to the actual status');
            
        }
        
        private static String buildJSON(id leadId,id accId) {
            
            string json = '{ '+
                '"orchestrationInfo" : { '+
                '"jsonVersionNumber" : "1.0", '+
                '"orchestrationEventName" : { '+
                '"orchestrationEventType" : "Conversion Lead Details",'+
                '"orchestrationEventDetail" : { '+
                '"orchestrationEventValues" : { '+
                '"leadId" : "'+leadId+'", '+
                '"accountId" : "'+accId+'" '+
                '} '+
                '} '+
                '} '+
                '} '+
                '}';
            return json;
        }
        private static String buildJSONForDeleteTransaction(String clientId) {
            return '{"orchestrationInfo" : {"jsonVersionNumber" : "1.0","orchestrationEventName" : {"orchestrationEventType" : "Record Remove- Delete","orchestrationEventDetail" : {"orchestrationEventValues" : { "clientId" : "'+clientId+'" }}}}}';
        }
        
        /**
         * @description Build Json Account Only String
         * @param clientId
         * @param externalSourceSyncTime
         * @param lastName
         * @return String
         */
        public static String buildJsonAccountOnlyString(String clientId,String externalSourceSyncTime,String lastName) {
            return
                '{'+  
                '   "orchestrationInfo":{'+  
                '      "jsonVersionNumber":"1.0",'+
                '      "orchestrationDataName":['+  
                '         {'+  
                '            "orchestrationNameDetail":{'+  
                '               "dataName":"Account",'+
                '               "dataDeleteIndicator":false,'+
                '               "dataExternalKey":"clientId",'+
                '               "externalSourceSyncTime":"'+externalSourceSyncTime+'",'+
                '               "dataExternalKeyValue":"'+clientId+'",'+
                '               "orchestrationDataValues":{'+  
                '                  "RecordTypeId":"Individual",'+
                '                  "PersonEmailBouncedReason":"Valid",'+
                '                  "Phone":0,'+
                '                  "IsNotShareable":"N",'+
                '                  "PersonMobilePhone":2259070877,'+
                '                  "HasConfirmedNoEmail":false,'+
                '                  "IsSubjecttoCASL":"N",'+
                '                  "ShippingState":"",'+
                '                  "IsPrivacyOptionsShared":"Y",'+
                '                  "deathdate":"",'+
                '                  "LastName":"'+lastName+'",'+
                '                  "PaperlessPrivacyNotice":"N",'+
                '                  "BillingState":"LA",'+
                '                  "EmployerName":"",'+
                '                  "TDDPhone":0,'+
                '                  "BillingPostalCode":"70769",'+
                '                  "OccupationStatus":"",'+
                '                  "Occupation":"",'+
                '                  "ShippingCity":"",'+
                '                  "FirstName":"BOBBY ",'+
                '                  "MaritalStatus":"",'+
                '                  "Military":"",'+
                '                  "IsDeathNotificationReceived":"false",'+
                '                  "IsProtectedPerson":"N",'+
                '                  "Citizenship":"",'+
                '                  "BillingCountry":"UNITED STATES ",'+
                '                  "ShippingCountry":"",'+
                '                  "BillingAddressType":"USAddress",'+
                '                  "ShippingStreet":"",'+
                '                  "SSN":"3215 ",'+
                '                  "Suffix":" ",'+
                '                  "BillingStreet":"36339 LORENA DR ",'+
                '                  "PersonBirthdate":"1971-10-14",'+
                '                  "DriversLicenseStateProvince":"LOUISIANA ",'+
                '                  "ShippingAddressType":"",'+
                '                  "DriversLicenseNumber":" ",'+
                '                  "MailingInCareOf":"",'+
                '                  "PreferredSpokenLanguage":"",'+
                '                  "PersonHomePhone":2256738477,'+
                '                  "PreferredFirstName":null,'+
                '                  "MiddleName":" ",'+
                '                  "BillingCity":"PRAIRIEVILLE ",'+
                '                  "MailingAttention":" ",'+
                '                  "Gender":"",'+
                '                  "ShippingPostalCode":"",'+
                '                  "PersonEmail":"AAHMIVVJDNTBOHWBANARNO@sftest.org ",'+
                '                  "Designation":" "'+
                '               }'+
                '            }'+
                '         }'+
                '      ],'+
                '      "orchestrationEventName":{'+  
                '         "orchestrationEventType":"Customer Sync",'+
                '         "orchestrationEventDetail":'+null+
                '      }'+
                '   }'+
                '}';
            
        }
		
		private static List<Account> buildAccountData(integer stageRecordSize){
 			accountList=new List<Account>();
    		Account a;
    		integer stageRecord;
    		for(stageRecord=0;stageRecord<stageRecordSize;stageRecord++){
        		a = new Account(Edit_In_VFP__c=true,FirstName='Ftest',LastName='Ltest',BillingAddressType__c='US',ClientIdentifier__c='testid'+stageRecord);
        		accountList.add(a);
    		}
            
            return accountList;
		}
		
		private static StageOrchestration__c insertStageOrcWithTestApiUser(String transactionType){
		
			StageOrchestration__c testRecord=new StageOrchestration__c();
            testRecord.TransactionType__c=transactionType;
            testRecord.Value__c='{Random JSON}';
            testRecord.VersionNumber__c=1.0;
            System.runAs(testAPIUser) {
                Test.startTest();
                insert testRecord;
                Test.stopTest();
            }
            StageOrchestration__c result=[SELECT Id, TransactionType__c, Status__c, Error__c, Value__c, VersionNumber__c FROM StageOrchestration__c where id= :testRecord.id];
			
			return result;
		}
		
        private class AP_StageOrchestrationTriggerTestWrapper{

            private void createListOfStageOrchestrationrecord(List<StageOrchestration__c> listofStageOrchestrationrecord){
                StageOrchestration__c s;
                for(integer stageRecord=0;stageRecord<accountList.size();stageRecord++){
                    s=new StageOrchestration__c();
                    s.VersionNumber__c=1.0;
                    s.IdentifierValue__c=accountList.get(stageRecord).ClientIdentifier__c;
                    if(stageRecord>=0 && stageRecord<25) {
                    s.TransactionType__c=UTIL_StageOrchestrationConstants.CUSTOMER_SYNC_TRANSACTION;
                    s.Value__c=buildJsonAccountOnlyString(accountList.get(stageRecord).ClientIdentifier__c,String.valueOf(Datetime.now().addMinutes(1).format('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')),'SSLLSS'+stageRecord);
                    }
                    listofStageOrchestrationrecord.add(s);           
                }
            }

            private void assertSSLLSS22(List<Account> testacc2){
                if(testacc2 != null && testacc2.size()>0){
                    for(Account objAcc : testacc2){
                        if(objAcc.lastName == 'SSLLSS22'){
                            system.assertEquals('SSLLSS22', objAcc.lastname, 'Expected LastName should be equals to the actual LastName');
                        }
                    }
                }
            }

            private void assertSuccessStatus(StageOrchestration__c testRecord){
                List<StageOrchestration__c> lstStgOrc = [SELECT Id, TransactionType__c, Status__c, Error__c, Value__c, VersionNumber__c FROM StageOrchestration__c where id= :testRecord.id];
                if(lstStgOrc != null && lstStgOrc.size()>0)
                {
                    for(StageOrchestration__c objStgOrc : lstStgOrc){
                        if(objStgOrc.Status__c == 'Complete'){			
                            System.assertEquals(UTIL_StageOrchestrationConstants.SUCCESS_STATUS,objStgOrc.Status__c, 'Expected status should be equals to the actual status');
                            system.assert(String.isBlank(objStgOrc.Error__c), 'Error__c should be blank');
                        }
                    }
                }
            }
        }
    }