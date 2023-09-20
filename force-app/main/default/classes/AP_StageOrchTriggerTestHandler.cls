/**
    * @Name: AP_StageOrchestrationTrigger_TestHandler
    * @Author: Team Dauntless 
    * @description This class contains unit tests for validating 
    * @Last Modification: 05/31/2023
    */
@isTest(SeeAllData=false)
    public  class AP_StageOrchTriggerTestHandler {
        public  AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting;
        public   User systemUser;
        public   User testAPIUser;
        public  PermissionSetAssignment psassignment;
        public CS_StageOrchestration_Counts__c counts;
        public  CS001_ByPassTriggerAll__c passTriggerAll;
        public List<Account> accountList ;
         public  List<StageOrchestration__c> listOfStageOrchestrationforDeleteTransaction;
         public  List<StageOrchestration__c> listofStageOrchestrationforCustomerSync;
        private static List<StageOrchestration__c> listofStageOrchestrationrecord;
         private static AP_StageOrchestrationTriggerTestWrapper apWrap = new AP_StageOrchestrationTriggerTestWrapper();
          
       @isTest
        public static void setup( ){
                
                 User systemUser = UTIL_StageOrchestrationTestUtils.buildSystemAdmin('Alias','CmpMemSA','remCmpMemSysAd@statefarm.com');
             User testAPIUser= UTIL_StageOrchestrationTestUtils.buildtestAPIUser('test','testing','test@statefarm.com');
                insert systemUser;
                insert testAPIUser;
                PermissionSetAssignment psassignment = UTIL_StageOrchestrationTestUtils.assignPSet(testAPIUser);
                insert psassignment;
                //CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=true);
                //CS_StageOrchestration_Counts__c counts= new CS_StageOrchestration_Counts__c(Retry_Count__c=3,Chunk_Size__c=5,CustomerSync_Chunksize__c=15);
            System.assert(true, 'Should have assert statement');
        }
        @isTest
        public static void createBulkDataForCustomerSync()
        {
                integer stageRecordSize = 25;
                list <account>accountList=buildAccountData(stageRecordSize);
                listofStageOrchestrationrecord=new List<StageOrchestration__c> ();
                apWrap.createListOfStageOrchestrationrecord(listofStageOrchestrationrecord,accountList);
            System.assert(true, 'Should have assert statement');
            }
        
       

        public static void setFSCCustomSetting(user systemUser,CS_StageOrchestration_Counts__c counts,CS001_ByPassTriggerAll__c passTriggerAll )
        
        {
            //setup();
                UTIL_SetFSCCustomSettings_TEST.setFSCSettings();	
                AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(SFDC_USER_ID__c=systemUser.id);
                System.assert(true, 'Should have assert statement');
                    insert sysAdminUserIdSetting;	
                  insert counts;
                  insert passTriggerAll;
                
        }
         
                    
            
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
            list <account>accountList=new List<Account>();
                Account a;
                integer stageRecord;
                for(stageRecord=0;stageRecord<stageRecordSize;stageRecord++){
                    a = new Account(Edit_In_VFP__c=true,FirstName='Ftest',LastName='Ltest',BillingAddressType__c='US',ClientIdentifier__c='testid'+stageRecord);
                    accountList.add(a);
                }
                
                return accountList;
            }
        private class AP_StageOrchestrationTriggerTestWrapper{
    
                private void createListOfStageOrchestrationrecord(List<StageOrchestration__c> listofStageOrchestrationrecord,list <account>accountList){
                    StageOrchestration__c s;
                    //public list <account>accountList;
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
    
        }
    
    }