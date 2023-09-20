/**
* @Name     p9 
* @Author Team Loco Motivated
* @description UTIL_OrchJSONtoC2CConverter_Test class is used to test the UTIL_OrchestrationJSONtoC2CConverter class
*/
@isTest(SeeAllData=false)
private class UTIL_OrchJSONtoC2CConverter_Test {
    
    private static User testAPIUser; 
    private static PermissionSetAssignment psassignment; 
    
    /**
    * @description Setup method for UTIL_OrchJSONtoAccountConverter_Test test methods
    * @name setup
    */     
    public static void setup(){
        testAPIUser= UTIL_StageOrchestrationTestUtils.buildtestAPIUser('test','testing','test@statefarm.com');
        insert testAPIUser;
        psassignment=UTIL_StageOrchestrationTestUtils.assignPSet(testAPIUser);
        insert psassignment;
    }
        
    /**
    * This test method tests that two accounts are successfully created from JSON string.
    * @name testJsontoRelationshipConverter
    * @description Test JSON To Relationship Converter
    */    
    @isTest 
    static void testJsontoRelationshipConverter() {
        setup();
        String clientId1 = 'BBBMQ4DP005';
        String clientId2 = 'BBBMR0RN00Q';
        System.runAs(testAPIUser) {
            Test.startTest(); 
            List<Relationship__c> relationships 
                = UTIL_OrchestrationJSONtoC2CConverter.jsontoCustomerRelationshipConverter
                						(AP_StageOrchestrationJSONParser.parse(getJsonString(clientId1, clientId2,'Father')));
            System.assertEquals(1,  relationships.size(), 'Size of List<Relationship__c> is not equals to 1');
           /* for(Relationship__c relshp : relationships){
                system.assertEquals('BBBMQ4DP005~BBBMR0RN00Q', relshp.RelationshipIdentifier__c, 'The given two parameters are not equal');
                system.assertEquals('Father', relshp.RelationshipType__c, 'Relationship type is not father');
                system.assertEquals('2016-10-03 10:40:58', string.valueOf(relshp.ExternalSourceSyncTime__c), 'The given two parameters are not equal');
            }
            */
            verifyRelationships(relationships, 'Father');
            Test.stopTest();            
        }
    }
    
    /**
    * This test method tests that two accounts are successfully created from JSON string.
    * @name testJsontoRelationshipConverterwithBlankRelType
    * @description Test JSON To Relationship Converter With Blank Rel Type
    */    
    @isTest 
    static void testJsontoRelationshipConverterwithBlankRelType() {
        setup();
        String clientId1 = 'BBBMQ4DP005';
        String clientId2 = 'BBBMR0RN00Q';
        System.runAs(testAPIUser) {
            Test.startTest(); 
            List<Relationship__c> relationships 
                = UTIL_OrchestrationJSONtoC2CConverter.jsontoCustomerRelationshipConverter
                						(AP_StageOrchestrationJSONParser.parse(getJsonString(clientId1, clientId2,'')));
            System.assertEquals(1,  relationships.size(), 'Size of List<Relationship__c> is not 1');
            verifyRelationships(relationships, 'other');
           
            Test.stopTest();            
        }
        
    }
    private static  void verifyRelationships( List<Relationship__c> relationships, string relationshipNature )
    {
       
            for(Relationship__c relshp : relationships){
                system.assertEquals('BBBMQ4DP005~BBBMR0RN00Q', relshp.RelationshipIdentifier__c, 'The given two parameters are not equal');
                system.assertEquals(relationshipNature, relshp.RelationshipType__c, 'Relationship type is not others');
                system.assertEquals('2016-10-03 10:40:58', string.valueOf(relshp.ExternalSourceSyncTime__c), 'The given two parameters are not equal');
            }
    }
    
    /**
    * This test method tests that two accounts are successfully created from JSON string.
    * @name testJsontoRelationshipConverterwithNullRelType
    * @description Test Json to Relationship Converter With Null Rel Type
    */    
    @isTest 
    static void testJsontoRelationshipConverterwithNullRelType() {
        setup();
        String clientId1 = 'BBBMQ4DP005';
        String clientId2 = 'BBBMR0RN00Q';
        System.runAs(testAPIUser) {
            Test.startTest(); 
            List<Relationship__c> relationships 
                = UTIL_OrchestrationJSONtoC2CConverter.jsontoCustomerRelationshipConverter
                						(AP_StageOrchestrationJSONParser.parse(getJsonStringwithNullReltype(clientId1, clientId2)));
            System.assertEquals(1,  relationships.size(), 'Size of List<Relationship__c> is not equals to 1');
            verifyRelationships(relationships,'other');  
            Test.stopTest();            
        }
    }
    

    
    /**
    * This test method tests that two accounts are successfully created from JSON string.
    * @name testListJsontoRelationshipConverter
    * @description Test List JSON To Relationship Converter
    */    
    @isTest 
    static void testListJsontoRelationshipConverter() {
        setup();
        String clientId1 = 'BBBMQ4DP005';
        String clientId2 = 'BBBMR0RN00Q';
        System.runAs(testAPIUser) {
            Test.startTest(); 
            List<Relationship__c> relationships 
               							 = UTIL_OrchestrationJSONtoC2CConverter.jsontoCustomerRelationshipConverter
                													(AP_StageOrchestrationJSONParser.parse(multipleAccountInJSONCustRelashp(clientId1, clientId2)));
            System.assertEquals(2,  relationships.size(), 'Size of List<Relationship__c> is not equals to 2');
            for(Relationship__c relshp : relationships){
                if(relshp.RelationshipType__c.equalsIgnorecase('Father')){
                    system.assertEquals('BBBMQ4DP005~BBBMR0RN00Q', relshp.RelationshipIdentifier__c, 'The given two parameters are not equal');
                    system.assertEquals('Father', relshp.RelationshipType__c, 'Relationship is not Father');
                    system.assertEquals('2017-04-17 12:33:59', string.valueOf(relshp.ExternalSourceSyncTime__c), 'The given two parameters are not equal');
                }if(relshp.RelationshipType__c.equalsIgnorecase('Spouse')){
                    system.assertEquals('BBBMR0RN00Q~BBBMQ4DP005', relshp.RelationshipIdentifier__c, 'The given two parameters are not equal');
                    system.assertEquals('Spouse', relshp.RelationshipType__c, 'Relationship is not Spouse');
                    system.assertEquals('2017-04-17 12:33:59', string.valueOf(relshp.ExternalSourceSyncTime__c), 'The given two parameters are not equal');
                }
            }
            Test.stopTest();            
        }
    } 
    
    
    /**
    * This method creates and returns the JSON string to be used in the test
    * @name getJsonString
    * @description Get JSON String
    * @param clientId1
    * @param clientId2
    * @param relationshipNature
    * @return String
    */     
    public static String getJsonString(String clientId1, String clientId2, string relationshipNature) {
        return '{'+  
            '   "orchestrationInfo":{'+  
            '      "jsonVersionNumber":"1.0",'+
            '      "orchestrationDataName":['+  
            '         {'+
            '               "orchestrationNameDetail":{'+  
            '               "dataName":"Customer2Customer",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"RelationshipIdentifier",'+
            '               "externalSourceSyncTime":"2016-10-03T09:40:58.045+0000",'+
            '               "dataExternalKeyValue":"'+clientId1+'~'+clientId2+'",'+
            '               "orchestrationDataValues":{'+  
            '               "Customer":"'+clientId1+'",'+
            '               "relationwith":"'+clientId2+'",'+
            '               "RelationshipNature":"'+ relationshipNature +'",'+
            '               "StartDate":"2008-08-01"'+
            '               }'+
            '            }'+
            '         }'+
            '      ],'+
            '         "orchestrationEventName":{'+  
            '         "orchestrationEventType":"Customer2Customer",'+
            '         "orchestrationEventDetail":'+null+
            '      }'+
            '   }'+
            '}';
    }
    
    /**
    * This method creates and returns the JSON string to be used in the test
    * @name getJsonStringwithNullReltype
    * @description Get JSON String With Null Reltype
    * @param clientId1
    * @param clientId2
    * @return String
    */     
    public static String getJsonStringwithNullReltype(String clientId1, String clientId2) {
        return '{'+  
            '   "orchestrationInfo":{'+  
            '      "jsonVersionNumber":"1.0",'+
            '      "orchestrationDataName":['+  
            '         {'+
            '               "orchestrationNameDetail":{'+  
            '               "dataName":"Customer2Customer",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"RelationshipIdentifier",'+
            '               "externalSourceSyncTime":"2016-10-03T09:40:58.045+0000",'+
            '               "dataExternalKeyValue":"'+clientId1+'~'+clientId2+'",'+
            '               "orchestrationDataValues":{'+  
            '               "Customer":"'+clientId1+'",'+
            '               "relationwith":"'+clientId2+'",'+
            '               "StartDate":"2008-08-01"'+
            '               }'+
            '            }'+
            '         }'+
            '      ],'+
            '         "orchestrationEventName":{'+  
            '         "orchestrationEventType":"Customer2Customer",'+
            '         "orchestrationEventDetail":'+null+
            '      }'+
            '   }'+
            '}';
    }
    
    /**
    * This method creates and returns the JSON string to be used in the test
    * @name multipleAccountInJSONCustSync
    * @description Multiple Account In JSON CustRelashp
    * @param clientId1
    * @param clientId2
    * @return String
    */ 
    public static String multipleAccountInJSONCustRelashp(String clientId1, String clientId2) {
        return '{'+  
            '   "orchestrationInfo":{'+  
            '      "jsonVersionNumber":"1.0",'+
            '      "orchestrationDataName":['+  
            '         {'+  
            '           "orchestrationNameDetail":{'+  
			'			"dataName":"Customer2Customer",'+
			'			"dataDeleteIndicator":false, '+
			'			"dataExternalKey":"RelationshipIdentifier",  '+
			'			"externalSourceSyncTime":"2017-04-17T11:33:59.045+0000",'+
			'			"dataExternalKeyValue":"'+clientId1+'~'+clientId2+'",'+
			'			"orchestrationDataValues":{       '+
			'           "Customer":"'+clientId1+'",'+
            '           "relationwith":"'+clientId2+'",'+
			'			"RelationshipNature":"Father",  '+
			'			"StartDate":"2008-08-01" '+
            '               }'+
            '            }'+
            '         },'+
            '         {'+  
            '            "orchestrationNameDetail":{'+  
            '			"dataName":"Customer2Customer",'+
			'			"dataDeleteIndicator":false, '+
			'			"dataExternalKey":"RelationshipIdentifier",  '+
			'			"externalSourceSyncTime":"2017-04-17T11:33:59.045+0000",'+
			'			"dataExternalKeyValue":"'+clientId2+'~'+clientId1+'",'+
			'			"orchestrationDataValues":{       '+
			'           "Customer":"'+clientId2+'",'+
            '           "relationwith":"'+clientId1+'",'+
			'			"RelationshipNature":"Spouse",  '+
			'			"StartDate":"2008-08-01" '+
            '               }'+
            '            }'+
            '         }'+          
            '      ],'+
            '      "orchestrationEventName":{'+  
            '         "orchestrationEventType":"Customer2Customer",'+
            '         "orchestrationEventDetail":'+null+
            '      }'+
            '   }'+
            '}';        
    }
}