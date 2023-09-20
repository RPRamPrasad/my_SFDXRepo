/**
* @Name UTIL_OrchJSONtoAccountConverter_Test
* @Author Team Dream Builders,Team Loco Motivated
* @description UTIL_OrchJSONtoAccountConverter_Test class is used to test the UTIL_OrchestrationJSONtoAccountconverter class
*/
@isTest(SeeAllData=false)
private class UTIL_OrchJSONtoAccountConverter_Test {
    private static User testAPIUser; 
    private static PermissionSetAssignment psassignment;
    
    
    
    /**
* Setup method for UTIL_OrchJSONtoAccountConverter_Test test methods
* 
* @name setup
* @description Setup
*/ @Testsetup
    public static void setup(){
        testAPIUser= UTIL_StageOrchestrationTestUtils.buildtestAPIUser('test','testing','test@statefarm.com');
        insert testAPIUser;
        psassignment=UTIL_StageOrchestrationTestUtils.assignPSet(testAPIUser);
        insert psassignment;
    }
    
    /**
    * This test method tests that two accounts are successfully created from JSON string.
    * 
    * @name testJsontoAccountConverter
    * @description Test JSON To Account Converter
    */ 
    @isTest 
   private static void testJsontoAccountConverter() {
        testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where lastname='testing' ];
        String clientId1 = 'BBBMQ4DP005';
        String clientId2 = 'BBBMR0RN00Q';
        System.runAs(testAPIUser) {
            Test.startTest(); 

            List<Account> accounts = UTIL_OrchestrationJSONtoAccountconverter.jsontoAccountConverter(AP_StageOrchestrationJSONParser.parse(getJsonString(clientId1, clientId2)));

            System.assertEquals(2,  accounts.size(), 'Size of List<Account> is not equals to 2');
            for(Account acct : accounts){
                if(acct.ClientIdentifier__c.equalsIgnoreCase(clientId1)){
                    System.assertEquals('ALICE ',acct.FirstName, 'FirstName is not \'ALICE\'');
                }else if(acct.ClientIdentifier__c.equalsIgnoreCase(clientId2)){
                    System.assertEquals('BOBBY ',acct.FirstName, 'FirstName is not \'BOBBY\'');
                }
        }
        Test.stopTest();
        
    }
   }
    
    /**
    * This test method tests that four accounts are successfully created from JSON string and validate all preference field values are setting appropriate way in all four account.
    * 
    * @name testPreferencesJsontoAccountConverter
    * @description Test Preferences JSON To Account Converter
    */ 
    @isTest 
    private static void testPreferencesJsontoAccountConverter() {
       testAPIUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where lastname='testing' ];
        String clientId1 = 'BBBMQ4DPFF0';
        String clientId2 = 'BBBMR0RN00K';
        String clientId3 = 'BBBMR0RN007';
        String clientId4 = 'BBBMR0RN005';
        System.runAs(testAPIUser) {
            Test.startTest(); 

            ClientIdWrapper clientWrap = new ClientIdWrapper();
            clientWrap.clientId1 = clientId1;
            clientWrap.clientId2 = clientId2;
            clientWrap.clientId3 = clientId3;
            clientWrap.clientId4 = clientId4;
            
            List<Account> accounts = UTIL_OrchestrationJSONtoAccountconverter.jsontoAccountConverter(AP_StageOrchestrationJSONParser.parse(multipleAccountInJSONCustSync(clientWrap)));
			System.assertEquals(4,  accounts.size(), 'Size of List<Account> is not equals to 4');
            
            for(Account acct : accounts){
                if(acct.ClientIdentifier__c.equalsIgnoreCase(clientId1)){
                    assertForClientId1(acct);
                }else if(acct.ClientIdentifier__c.equalsIgnoreCase(clientId2)){
                    System.assertEquals('RIHANA ',acct.FirstName, 'FirstName is not equals to \'RIHANA\'');
                    system.assertEquals(false, acct.IsHearingImpaired__pc, '\'IsHearingImpaired__pc\' is true');
                    system.assertEquals(false, acct.IsNotShareable__pc, '\'IsNotShareable__pc\' is true');
                    system.assertEquals('No', acct.PaperlessPrivacyNotice__c, '\'PaperlessPrivacyNotice__c\' is not equals to \'No\'');
                }else if(acct.ClientIdentifier__c.equalsIgnoreCase(clientId3)){
                    assertForClientId3(acct);
                }else if(acct.ClientIdentifier__c.equalsIgnoreCase(clientId4)){
                    System.assertEquals('BRITNEY',acct.FirstName, 'FirstName is not equals to \'BRITNEY\'');
                    system.assertEquals(true, acct.IsHearingImpaired__pc, '\'IsHearingImpaired__pc\' is false');
                    assertForClientIDs( acct);
                }
            }
        }
        Test.stopTest();
        
    }

    private static void assertForClientId1(Account acct){
        System.assertEquals('MADONA ',acct.FirstName, 'FirstName is not \'MADONA\'');
        system.assertEquals(true, acct.IsHearingImpaired__pc, '\'IsHearingImpaired__pc\' is false');
        
        system.assertEquals(true, acct.IsNotShareable__pc, '\'IsNotShareable__pc\' is false');
        system.assertEquals(true, acct.DoNotMail__c, '\'DoNotMail__c\' is false');
        system.assertEquals(false, acct.PersonDoNotCall, '\'PersonDoNotCall\' is true');
        system.assertEquals(true, acct.IsProtectedPerson__c, '\'IsProtectedPerson__c\' is false');
        system.assertEquals(true, acct.IsPrivacyOptionsShared__c, '\'IsPrivacyOptionsShared__c\' is false');
        system.assertEquals(true, acct.IsHealthSourced__pc, '\'IsHealthSourced__pc\' is false');
        system.assertEquals('Yes', acct.PaperlessPrivacyNotice__c, '\'PaperlessPrivacyNotice__c\' is not equals \'Yes\'');
        system.assertEquals('Bengali', acct.PreferredSpokenLanguage__pc, '\'PreferredSpokenLanguage__pc\' is not \'Bengali\'');
        system.assertEquals('Yes', acct.IsSubjecttoCASL__c, '\'IsSubjecttoCASL__c\' is not equals \'Yes\'');
        system.assertEquals('Yes', acct.HasPermissionToServiceEmail__c, '\'HasPermissionToServiceEmail__c\' is not equals \'Yes\'');
        system.assertEquals('Yes', acct.HasPermissionToServiceText__c, '\'HasPermissionToServiceText__c\' is not equals \'Yes\'');
        system.assertEquals('Yes', acct.HasPermissionToMarketingEmail__c, '\'HasPermissionToMarketingEmail__c\' is not equals \'Yes\'');
        system.assertEquals('Yes', acct.HasPermissionToClaimEmail__c, '\'HasPermissionToClaimEmail__c\' is not equals \'Yes\'');
        system.assertEquals('No', acct.HasPermissionToClaimText__c, '\'HasPermissionToClaimText__c\' is not equals \'No\'');
        system.assertEquals('Yes', acct.Billing_Statements__c, '\'Billing_Statements__c\' is not equals \'Yes\'');
        system.assertEquals('Yes', acct.Policy_Notices_Email__c, '\'Policy_Notices_Email__c\' is not equals \'Yes\'');
    }

    private static void assertForClientId3(Account acct){
        System.assertEquals('CHRISTIANA',acct.FirstName, 'FirstName is not equals to \'CHRISTIANA\'');
        system.assertEquals(true, acct.IsHearingImpaired__pc, '\'IsHearingImpaired__pc\' is false');
        assertForClientIDs( acct);
    }
    private  static void assertForClientIDs(Account acct)
    {
      system.assertEquals(false, acct.IsNotShareable__pc, '\'IsNotShareable__pc\' is true');
        system.assertEquals(false, acct.DoNotMail__c, '\'DoNotMail__c\' is true');
        system.assertEquals(false, acct.PersonDoNotCall, '\'PersonDoNotCall\' is true');
        system.assertEquals(false, acct.IsProtectedPerson__c, '\'IsProtectedPerson__c\' is true');
        system.assertEquals(false, acct.IsPrivacyOptionsShared__c, '\'IsPrivacyOptionsShared__c\' is true');                  
        system.assertEquals(false, acct.IsHealthSourced__pc, '\'IsHealthSourced__pc\' is true');
        system.assertEquals(null, acct.PaperlessPrivacyNotice__c, '\'PaperlessPrivacyNotice__c\' is not null');
        system.assertEquals(null, acct.PreferredSpokenLanguage__pc, '\'PreferredSpokenLanguage__pc\' is not null');
        system.assertEquals(null, acct.IsSubjecttoCASL__c, '\'IsSubjecttoCASL__c\' is not null');
        system.assertEquals(null, acct.HasPermissionToServiceEmail__c, '\'HasPermissionToServiceEmail__c\' is not null');
        system.assertEquals(null, acct.HasPermissionToServiceText__c, '\'HasPermissionToServiceText__c\' is not null');
        system.assertEquals(null, acct.HasPermissionToMarketingEmail__c, '\'HasPermissionToMarketingEmail__c\' is not null');
        system.assertEquals(null, acct.HasPermissionToClaimEmail__c, '\'HasPermissionToClaimEmail__c\' is not null');
        system.assertEquals(null, acct.HasPermissionToClaimText__c, '\'HasPermissionToClaimText__c\' is not null'); 
    }
    
    /**
    * This method creates and returns the JSON string to be used in the test
    * 
    * @name getJsonString
    * @description get JSON String
    * @param clientId1
    * @param clientId2
    * @return String
    */ 
    private static String getJsonString(String clientId1, String clientId2) {
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
            '               "externalSourceSyncTime":"2016-10-03T09:40:58.044+0000",'+
            '               "dataExternalKeyValue":' + '"' + clientId1 + '"' + ','+
            '               "orchestrationDataValues":{'+  
            '                  "RecordTypeId":"Individual",'+
            '                  "PersonEmailBouncedReason":null,'+
            '                  "Phone":0,'+
            '                  "IsNotShareable":"N",'+
            '                  "PersonMobilePhone":0,'+
            '                  "HasConfirmedNoEmail":true,'+
            '                  "IsSubjecttoCASL":"N",'+
            '                  "ShippingState":"",'+
            '                  "IsPrivacyOptionsShared":"N",'+
            '                  "LastName":"STURZL ",'+
            '                  "PaperlessPrivacyNotice":"N",'+
            '                  "BillingState":"WI",'+
            '                  "EmployerName":"",'+
            '                  "TDDPhone":0,'+
            '                  "BillingPostalCode":"54946",'+
            '                  "OccupationStatus":"",'+
            '                  "jobTitle":"boss",' +
            '                  "Occupation":"insurance",'+
            '                  "jobTitleAsOfDate":"1999-09-26",' +
            '                  "ShippingCity":"",'+
            '                  "FirstName":"ALICE ",'+
            '                  "MaritalStatus":"",'+
            '                  "Military":"",'+
            '                  "IsDeathNotificationReceived":"false",'+
            '                  "IsProtectedPerson":"N",'+
            '                  "Citizenship":"",'+
            '                  "BillingCountry":"",'+
            '                  "ShippingCountry":"UNITED STATES",'+
            '                  "BillingAddressType":"USAddress",'+
            '                  "ShippingStreet":"",'+
            '                  "SSN":" ",'+
            '                  "Suffix":" ",'+
            '                  "BillingStreet":"422 BELL AVE ",'+
            '                  "PersonBirthdate":"1926-09-26",'+
            '                  "DriversLicenseStateProvince":null,'+
            '                  "ShippingAddressType":"CanadaAddress",'+
            '                  "DriversLicenseNumber":"",'+
            '                  "MailingInCareOf":"",'+
            '                  "PreferredSpokenLanguage":"",'+
            '                  "PersonHomePhone":7154860544,'+
            '                  "PreferredFirstName":null,'+
            '                  "MiddleName":" ",'+
            '                  "BillingCity":"KING ",'+
            '                  "MailingAttention":" ",'+
            '                  "Gender":"",'+
            '                  "ShippingPostalCode":"",'+
            '                  "PersonEmail":null,'+
            '                  "Designation":" "'+
            '               }'+
            '            }'+
            '         },'+
            '         {'+  
            '            "orchestrationNameDetail":{'+  
            '               "dataName":"Account",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"clientId",'+
            '               "externalSourceSyncTime":"2016-10-03T09:40:58.045+0000",'+
            '               "dataExternalKeyValue":' + '"' + clientId2 + '"' + ','+
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
            '                  "LastName":"BROWN ",'+
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
            '        '+
            '      ],'+
            '      "orchestrationEventName":{'+  
            '         "orchestrationEventType":"Separate Customer Record",'+
            '         "orchestrationEventDetail":{'+  
            '            "orchestrationEventVales":{'+  
            '               "ClientId1":"BBBMQ4DP005",'+
            '               "ClientId2":"BBBMR0RN00Q"'+
            '            }'+
            '         }'+
            '      }'+
            '   }'+
            '}';
        
    }
    
    /**
    * This method creates and returns the JSON string to be used in the test
    * 
    * @name setup
    * @description Multiple Account In JSON Cust Sync
    * @param clientWrap
    * @return String
    */ 
    private static String multipleAccountInJSONCustSync(ClientIdWrapper clientWrap) {

        String clientId1 = clientWrap.clientId1;
        String clientId2 = clientWrap.clientId2;
        String clientId3 = clientWrap.clientId3;
        String clientId4 = clientWrap.clientId4;

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
            '               "externalSourceSyncTime":"2016-10-03T09:40:58.044+0000",'+
            '               "dataExternalKeyValue":' + '"' + clientId1 + '"' + ','+
            '               "orchestrationDataValues":{'+ 
			'          		"preferences" : [ {'+
			'            	   "customerId" : "BBBCH6PVP06",'+
			'            	   "preferenceType" : "doNotShareIndicator",'+
			'            	   "preferenceValue" :true,'+
			'            	   "preferenceStartDate" : null,'+
			'            	   "preferenceEndDate" : null,'+
			'           	   "termsAndConditionVersion" : null,'+
			'            	   "termsAndConditionType" : null,'+
			'            	   "sourceId" : null,'+
			'            	   "sourceType" : null,'+
			'            	   "audit" : null'+
            '          		},{'+
            '            	    "customerId" : "BBBCH6PVP06",'+
			'	            	"preferenceType" : "doNotMailIndicator",'+
			'	            	"preferenceValue" : "Y",'+
			'	            	"preferenceStartDate" : null,'+
			'	            	"preferenceEndDate" : null,'+
			'	            	"termsAndConditionVersion" : null,'+
			'	            	"termsAndConditionType" : null,'+
			'	            	"sourceId" : null,'+
			'	            	"sourceType" : null,'+
			'	            	"audit" : null'+
            '          		},{'+
			'	            	"customerId" : "BBBCH6PVP06",'+
			'	            	"preferenceType" : "donotcallIndicator",'+
			'	            	"preferenceValue" : "N",'+
			'	            	"preferenceStartDate" : null,'+
			'	            	"preferenceEndDate" : null,'+
			'	            	"termsAndConditionVersion" : null,'+
			'	            	"termsAndConditionType" : null,'+
			'	            	"sourceId" : null,'+
			'	            	"sourceType" : null,'+
			'	            	"audit" : null'+
            '          		},{'+
			'	            	"customerId" : "BBBCH6PVP06",'+
			'	            	"preferenceType" : "isProtectedPerson",'+
			'	            	"preferenceValue" : "Y",'+
			'	            	"preferenceStartDate" : null,'+
			'	            	"preferenceEndDate" : null,'+
			'	            	"termsAndConditionVersion" : null,'+
			'	            	"termsAndConditionType" : null,'+
			'	            	"sourceId" : null,'+
			'	            	"sourceType" : null,'+
			'	            	"audit" : null'+
            '          		},{'+
			'	            	"customerId" : "BBBCH6PVP06",'+
			'	            	"preferenceType" : "providedPrivacyOptions",'+
			'	            	"preferenceValue" : "Y",'+
			'	            	"preferenceStartDate" : null,'+
			'	            	"preferenceEndDate" : null,'+
			'	            	"termsAndConditionVersion" : null,'+
			'	            	"termsAndConditionType" : null,'+
			'	            	"sourceId" : null,'+
			'	            	"sourceType" : null,'+
			'	            	"audit" : null'+
			'          		},{'+
			'	            	"customerId" : "BBBCH6PVP06",'+
			'	            	"preferenceType" : "Health Sourced",'+
			'	            	"preferenceValue" : "Y",'+
			'	            	"preferenceStartDate" : null,'+
			'	            	"preferenceEndDate" : null,'+
			'	            	"termsAndConditionVersion" : null,'+
			'	            	"termsAndConditionType" : null,'+
			'	            	"sourceId" : null,'+
			'	            	"sourceType" : null,'+
			'	            	"audit" : null'+
			'          		},{'+
			'	            	"customerId" : "BBBCH6PVP06",'+
			'	            	"preferenceType" : "paperlessPrivacyNoticeIndicator",'+
			'	            	"preferenceValue" : "Y",'+
			'	            	"preferenceStartDate" : null,'+
			'	            	"preferenceEndDate" : null,'+
			'	            	"termsAndConditionVersion" : null,'+
			'	            	"termsAndConditionType" : null,'+
			'	            	"sourceId" : null,'+
			'	            	"sourceType" : null,'+
			'	            	"audit" : null'+
			'          		},{'+
			'	            	"customerId" : "BBBCH6PVP06",'+
			'	            	"preferenceType" : "preferredSpokenLanguage",'+
			'	            	"preferenceValue" : "Bengali",'+
			'	            	"preferenceStartDate" : null,'+
			'	            	"preferenceEndDate" : null,'+
			'	            	"termsAndConditionVersion" : null,'+
			'	            	"termsAndConditionType" : null,'+
			'	            	"sourceId" : null,'+
			'	            	"sourceType" : null,'+
			'	            	"audit" : null'+
			'          		},{'+
			'	            	"customerId" : "BBBCH6PVP06",'+
			'	            	"preferenceType" : "isSubjectToCASL",'+
			'	            	"preferenceValue" : "Y",'+
			'	            	"preferenceStartDate" : null,'+
			'	            	"preferenceEndDate" : null,'+
			'	            	"termsAndConditionVersion" : null,'+
			'	            	"termsAndConditionType" : null,'+
			'	            	"sourceId" : null,'+
			'	            	"sourceType" : null,'+
			'	            	"audit" : null'+
			'          		},{'+
			'	            	"customerId" : "BBBCH6PVP06",'+
			'	            	"preferenceType" : "serviceEmail",'+
			'	            	"preferenceValue" : "Y",'+
			'	            	"preferenceStartDate" : null,'+
			'	            	"preferenceEndDate" : null,'+
			'	            	"termsAndConditionVersion" : null,'+
			'	            	"termsAndConditionType" : null,'+
			'	            	"sourceId" : null,'+
			'	            	"sourceType" : null,'+
			'	            	"audit" : null'+
			'          		},{'+
			'	            	"customerId" : "BBBCH6PVP06",'+
			'	            	"preferenceType" : "serviceText",'+
			'	            	"preferenceValue" : "Y",'+
			'	            	"preferenceStartDate" : null,'+
			'	            	"preferenceEndDate" : null,'+
			'	            	"termsAndConditionVersion" : null,'+
			'	            	"termsAndConditionType" : null,'+
			'	            	"sourceId" : null,'+
			'	            	"sourceType" : null,'+
			'	            	"audit" : null'+
			'          		},{'+
			'	            	"customerId" : "BBBCH6PVP06",'+
			'	            	"preferenceType" : "marketingEmail",'+
			'	            	"preferenceValue" : "Y",'+
			'	            	"preferenceStartDate" : null,'+
			'	            	"preferenceEndDate" : null,'+
			'	            	"termsAndConditionVersion" : null,'+
			'	            	"termsAndConditionType" : null,'+
			'	            	"sourceId" : null,'+
			'	            	"sourceType" : null,'+
			'	            	"audit" : null'+
			'          		},{'+
			'	            	"customerId" : "BBBCH6PVP06",'+
			'	            	"preferenceType" : "claimAlertEmail",'+
			'	            	"preferenceValue" : "Y",'+
			'	            	"preferenceStartDate" : null,'+
			'	            	"preferenceEndDate" : null,'+
			'	            	"termsAndConditionVersion" : null,'+
			'	            	"termsAndConditionType" : null,'+
			'	            	"sourceId" : null,'+
			'	            	"sourceType" : null,'+
			'	            	"audit" : null'+
			'          		},{'+
			'	            	"customerId" : "BBBCH6PVP06",'+
			'	            	"preferenceType" : "claimAlertText",'+
			'	            	"preferenceValue" : "N",'+
			'	            	"preferenceStartDate" : null,'+
			'	            	"preferenceEndDate" : null,'+
			'	            	"termsAndConditionVersion" : null,'+
			'	            	"termsAndConditionType" : null,'+
			'	            	"sourceId" : null,'+
			'	            	"sourceType" : null,'+
			'	            	"audit" : null'+
			'          		},{'+
            '            	"customerId" : "BBBCH6PVP06",'+
            '            	"preferenceType" : "billingPaperless",'+
            '            	"preferenceValue" : "Y",'+
            '            	"preferenceStartDate" : null,'+
            '            	"preferenceEndDate" : null,'+
            '            	"termsAndConditionVersion" : null,'+
            '            	"termsAndConditionType" : null,'+
            '            	"sourceId" : null,'+
            '            	"sourceType" : null,'+
            '            	"audit" : null'+
			'          		},{'+
            '            	"customerId" : "BBBCH6PVP06",'+
            '            	"preferenceType" : "accountPolicyNotification",'+
            '            	"preferenceValue" : "Y",'+
            '            	"preferenceStartDate" : null,'+
            '            	"preferenceEndDate" : null,'+
            '            	"termsAndConditionVersion" : null,'+
            '            	"termsAndConditionType" : null,'+
            '            	"sourceId" : null,'+
            '            	"sourceType" : null,'+
            '            	"audit" : null'+
			'          		}],'+			
		    '              "RecordTypeId":"Individual",'+
		    '              "PersonEmailBouncedReason":"Valid",'+
		    '              "Phone":0,'+
		    '              "PersonMobilePhone":2259070877,'+
		    '              "HasConfirmedNoEmail":false,'+
            '              "IsHearingImpaired" :true,'+
		    '              "ShippingState":"",'+
		    '              "deathdate":"",'+
		    '              "LastName":"STURZL1",'+
		    '              "BillingState":"LA",'+
		    '              "EmployerName":"",'+
		    '              "TDDPhone":0,'+
		    '              "BillingPostalCode":"70769",'+
		    '              "OccupationStatus":"",'+
		    '              "Occupation":"",'+
		    '              "ShippingCity":"",'+
		    '              "FirstName":"MADONA ",'+
		    '              "MaritalStatus":"",'+
		    '              "Military":"",'+
		    '              "IsDeathNotificationReceived":"false",'+
		    '              "Citizenship":"",'+
		    '              "BillingCountry":"UNITED STATES ",'+
		    '              "ShippingCountry":"",'+
		    '              "BillingAddressType":"USAddress",'+
		    '              "ShippingStreet":"",'+
		    '              "SSN":"3215 ",'+
		    '              "Suffix":" ",'+
		    '              "BillingStreet":"36339 LORENA DR ",'+
		    '              "PersonBirthdate":"1971-10-14",'+
		    '              "DriversLicenseStateProvince":"LOUISIANA ",'+
		    '              "ShippingAddressType":"",'+
		    '              "DriversLicenseNumber":" ",'+
		    '              "MailingInCareOf":"",'+
		    '              "PersonHomePhone":2256738477,'+
		    '              "PreferredFirstName":null,'+
		    '              "MiddleName":" ",'+
		    '              "BillingCity":"PRAIRIEVILLE ",'+
		    '              "MailingAttention":" ",'+
		    '              "Gender":"",'+
		    '              "ShippingPostalCode":"",'+
		    '              "PersonEmail":"AAHMIVVJDNTBOHWBANARNO@sftest.org ",'+
		    '              "Designation":" "'+
            '               }'+
            '            }'+
            '         },'+
            '         {'+  
            '            "orchestrationNameDetail":{'+  
            '               "dataName":"Account",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"clientId",'+
            '               "externalSourceSyncTime":"2016-10-03T09:40:58.045+0000",'+
            '               "dataExternalKeyValue":' + '"' + clientId2 + '"' + ','+
            '               "orchestrationDataValues":{'+ 
			'          		"preferences" : [ {'+
			'            	   "customerId" : "BBBCH6PVP06",'+
			'            	   "preferenceType" : "doNotShareIndicator",'+
			'            	   "preferenceValue" : "",'+
			'            	   "preferenceStartDate" : null,'+
			'            	   "preferenceEndDate" : null,'+
			'           	   "termsAndConditionVersion" : null,'+
			'            	   "termsAndConditionType" : null,'+
			'            	   "sourceId" : null,'+
			'            	   "sourceType" : null,'+
			'            	   "audit" : null'+
            '          		},{'+
            '            	    "customerId" : "BBBCH6PVP06",'+
			'	            	"preferenceType" : "paperlessPrivacyNoticeIndicator",'+
			'	            	"preferenceValue" : "N",'+
			'	            	"preferenceStartDate" : null,'+
			'	            	"preferenceEndDate" : null,'+
			'	            	"termsAndConditionVersion" : null,'+
			'	            	"termsAndConditionType" : null,'+
			'	            	"sourceId" : null,'+
			'	            	"sourceType" : null,'+
			'	            	"audit" : null'+
            '          		}],'+			
		    '              "RecordTypeId":"Individual",'+
		    '              "PersonEmailBouncedReason":"Valid",'+
		    '              "Phone":0,'+
		    '              "PersonMobilePhone":2259070877,'+
		    '              "HasConfirmedNoEmail":false,'+
            '              "IsHearingImpaired" :false,'+
		    '              "ShippingState":"",'+
		    '              "deathdate":"",'+
		    '              "LastName":"STURZL2 ",'+
		    '              "BillingState":"LA",'+
		    '              "EmployerName":"",'+
		    '              "TDDPhone":0,'+
		    '              "BillingPostalCode":"70769",'+
		    '              "OccupationStatus":"",'+
		    '              "Occupation":"",'+
		    '              "ShippingCity":"",'+
		    '              "FirstName":"RIHANA ",'+
		    '              "MaritalStatus":"",'+
		    '              "Military":"",'+
		    '              "IsDeathNotificationReceived":"false",'+
		    '              "Citizenship":"",'+
		    '              "BillingCountry":"UNITED STATES ",'+
		    '              "ShippingCountry":"",'+
		    '              "BillingAddressType":"USAddress",'+
		    '              "ShippingStreet":"",'+
		    '              "SSN":"3215 ",'+
		    '              "Suffix":" ",'+
		    '              "BillingStreet":"36339 LORENA DR ",'+
		    '              "PersonBirthdate":"1971-10-14",'+
		    '              "DriversLicenseStateProvince":"LOUISIANA ",'+
		    '              "ShippingAddressType":"",'+
		    '              "DriversLicenseNumber":" ",'+
		    '              "MailingInCareOf":"",'+
		    '              "PersonHomePhone":2256738477,'+
		    '              "PreferredFirstName":null,'+
		    '              "MiddleName":" ",'+
		    '              "BillingCity":"PRAIRIEVILLE ",'+
		    '              "MailingAttention":" ",'+
		    '              "Gender":"",'+
		    '              "ShippingPostalCode":"",'+
		    '              "PersonEmail":"AAHMIVVJDNTBOHWBANARNO@sftest.org ",'+
		    '              "Designation":" "'+
            '               }'+
            '            }'+
            '         },'+
            '         {'+  
            '            "orchestrationNameDetail":{'+  
            '               "dataName":"Account",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"clientId",'+
            '               "externalSourceSyncTime":"2016-10-03T09:40:58.045+0000",'+
            '               "dataExternalKeyValue":' + '"' + clientId3 + '"' + ','+
            '               "orchestrationDataValues":{'+ 
			'          	   "preferences" : [ {}],'+
		    '              "RecordTypeId":"Individual",'+
		    '              "PersonEmailBouncedReason":"Valid",'+
		    '              "Phone":0,'+
		    '              "PersonMobilePhone":2259070877,'+
		    '              "HasConfirmedNoEmail":false,'+
            '              "IsHearingImpaired" :true,'+
		    '              "ShippingState":"",'+
		    '              "deathdate":"",'+
		    '              "LastName":"STURZL3 ",'+
		    '              "BillingState":"LA",'+
		    '              "EmployerName":"",'+
		    '              "TDDPhone":0,'+
		    '              "BillingPostalCode":"70769",'+
		    '              "OccupationStatus":"",'+
		    '              "Occupation":"",'+
		    '              "ShippingCity":"",'+
		    '              "FirstName":"CHRISTIANA",'+
		    '              "MaritalStatus":"",'+
		    '              "Military":"",'+
		    '              "IsDeathNotificationReceived":"false",'+
		    '              "Citizenship":"",'+
		    '              "BillingCountry":"UNITED STATES ",'+
		    '              "ShippingCountry":"",'+
		    '              "BillingAddressType":"USAddress",'+
		    '              "ShippingStreet":"",'+
		    '              "SSN":"3215 ",'+
		    '              "Suffix":" ",'+
		    '              "BillingStreet":"36339 LORENA DR ",'+
		    '              "PersonBirthdate":"1971-10-14",'+
		    '              "DriversLicenseStateProvince":"LOUISIANA ",'+
		    '              "ShippingAddressType":"",'+
		    '              "DriversLicenseNumber":" ",'+
		    '              "MailingInCareOf":"",'+
		    '              "PersonHomePhone":2256738477,'+
		    '              "PreferredFirstName":null,'+
		    '              "MiddleName":" ",'+
		    '              "BillingCity":"PRAIRIEVILLE ",'+
		    '              "MailingAttention":" ",'+
		    '              "Gender":"",'+
		    '              "ShippingPostalCode":"",'+
		    '              "PersonEmail":"AAHMIVVJDNTBOHWBANARNO@sftest.org ",'+
		    '              "Designation":" "'+
            '               }'+
            '            }'+
            '         },'+
            '		  {'+  
            '            "orchestrationNameDetail":{'+  
            '               "dataName":"Account",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"clientId",'+
            '               "externalSourceSyncTime":"2016-10-03T09:40:58.045+0000",'+
            '               "dataExternalKeyValue":' + '"' + clientId4 + '"' + ','+
            '               "orchestrationDataValues":{'+ 
		    '              "RecordTypeId":"Individual",'+
		    '              "PersonEmailBouncedReason":"Valid",'+
		    '              "Phone":0,'+
		    '              "PersonMobilePhone":2259070877,'+
		    '              "HasConfirmedNoEmail":false,'+
            '              "IsHearingImpaired" :true,'+
		    '              "ShippingState":"",'+
		    '              "deathdate":"",'+
		    '              "LastName":"STURZL3 ",'+
		    '              "BillingState":"LA",'+
		    '              "EmployerName":"",'+
		    '              "TDDPhone":0,'+
		    '              "BillingPostalCode":"70769",'+
		    '              "OccupationStatus":"",'+
		    '              "Occupation":"",'+
		    '              "ShippingCity":"",'+
		    '              "FirstName":"BRITNEY",'+
		    '              "MaritalStatus":"",'+
		    '              "Military":"",'+
		    '              "IsDeathNotificationReceived":"false",'+
		    '              "Citizenship":"",'+
		    '              "BillingCountry":"UNITED STATES ",'+
		    '              "ShippingCountry":"",'+
		    '              "BillingAddressType":"USAddress",'+
		    '              "ShippingStreet":"",'+
		    '              "SSN":"3215 ",'+
		    '              "Suffix":" ",'+
		    '              "BillingStreet":"36339 LORENA DR ",'+
		    '              "PersonBirthdate":"1971-10-14",'+
		    '              "DriversLicenseStateProvince":"LOUISIANA ",'+
		    '              "ShippingAddressType":"",'+
		    '              "DriversLicenseNumber":" ",'+
		    '              "MailingInCareOf":"",'+
		    '              "PersonHomePhone":2256738477,'+
		    '              "PreferredFirstName":null,'+
		    '              "MiddleName":" ",'+
		    '              "BillingCity":"PRAIRIEVILLE ",'+
		    '              "MailingAttention":" ",'+
		    '              "Gender":"",'+
		    '              "ShippingPostalCode":"",'+
		    '              "PersonEmail":"AAHMIVVJDNTBOHWBANARNO@sftest.org ",'+
		    '              "Designation":" "'+
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
    
    /**
    * @Method This method is used to create a user with User Type
    * @description Build User API Data Admin
    * @param p_userName
    * @return User
    */    
    public static User buildUserAPIDataAdmin(String p_userName) {
        User user = new User(alias = 'APIA', email='APIA@statefarm.com', 
                             emailencodingkey='UTF-8', lastname='dataAdmin', languagelocalekey='en_US', 
                             localesidkey='en_US', timezonesidkey='Europe/London', username= p_userName);
        user.ProfileId = UTIL_ProfileId_TEST.getApiDataAdminProfileId();
        return user;
    }   

    class ClientIdWrapper{

        String clientId1;
        String clientId2;
        String clientId3;
        String clientId4;
    }
}