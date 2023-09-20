/**
* @Name UTIL_OrchestrationJSONtoGroupDetail_Test
* @Author Team Loco Motivated
* @description UTIL_OrchestrationJSONtoGroupDetail_Test class is used to test the UTIL_OrchestrationJSONtoGroupDetails class
*/
@isTest(SeeAllData=false)
public class UTIL_OrchestrationJSONtoGroupDetail_Test{

    private static User testAPIUser;
    private static PermissionSetAssignment psassignment;
    private static TestData_SalesRoleHierarchy salesRoleHierarchy1;
    private static TestData_SalesRoleHierarchy salesRoleHierarchy2;

  /**
    * @name setup
    * @description Setup method for UTIL_OrchestrationDataTransf_Test test methods
    */
    public static void setup(){
        testAPIUser= UTIL_StageOrchestrationTestUtils.buildtestAPIUser('test','testing','test@statefarm.com');
        insert testAPIUser;
        psassignment=UTIL_StageOrchestrationTestUtils.assignPSet(testAPIUser);
        insert psassignment;

        salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('C');
        salesRoleHierarchy2 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
    }

  /**
    * @name testJsontoGroupDetailConverter
    * @description This test method tests that Group and Group member transformations from JSON is successfully tranformared.
    */ 
    @isTest 
    private static void testJsontoGroupDetailConverter() {
        setup();
        stageorchestration__c testRecord=new StageOrchestration__c();
        testRecord.Value__c=buildJsonGroupDetailsString('HouseholdA2','clientId123',salesRoleHierarchy2.Agent.Associate_Id__C);
        UTIL_OrchestrationJSONtoGroupDetails.HLPR_GroupAndGroupMemberWrapper groupDetails = runTest( testRecord.Value__c);

        List<CustomerGroup__c> actualGroupList = groupDetails.groupList;
        system.assertEquals(2, actualGroupList.size(), 'Size of List<CustomerGroup__c> is not equals to 2');
        List<CustomerGroupMember__c> actualGroupMemberList = groupDetails.groupMemberList;
        system.assertEquals(2, actualGroupMemberList.size(), 'Size of List<CustomerGroupMember__c6> is not equals to 2');
    }

  /**
    * @name testJsontoGroupDetailConverterWithSameAgent
    * @description This test method tests that Group and Group member transformations from JSON is successfully tranformared.    
    */ 
    @isTest 
    private static void testJsontoGroupDetailConverterWithSameAgent() {
        setup();
        stageorchestration__c testRecord=new StageOrchestration__c();
        testRecord.Value__c=buildJsonGroupDetailsString('HouseholdA1','clientId124',salesRoleHierarchy1.Agent.Associate_Id__C);
        UTIL_OrchestrationJSONtoGroupDetails.HLPR_GroupAndGroupMemberWrapper groupDetails = runTest( testRecord.Value__c);

        List<CustomerGroup__c> actualGroupList = groupDetails.groupList;
        system.assertEquals(1, actualGroupList.size(), 'Size of List<CustomerGroup__c> is not equals to 1');
        List<CustomerGroupMember__c> actualGroupMemberList = groupDetails.groupMemberList;
        system.assertEquals(2, actualGroupMemberList.size(), 'Size of List<CustomerGroupMember__c> is not equals to 2');
    }

  /**
    * @description This test method tests that Group and Group member transformations from JSON is successfully tranformared.
    * @name testJsontoGroupDetailConverter
    */ 
    @isTest 
    private static void testSingleJsontoGroupDetailConverter() {
        setup();
        stageorchestration__c testRecord=new StageOrchestration__c();
        testRecord.Value__c=buildSingleJson('clientId123','HouseholdA1');
        UTIL_OrchestrationJSONtoGroupDetails.HLPR_GroupAndGroupMemberWrapper groupDetails = runTest( testRecord.Value__c);
        

        List<CustomerGroup__c> actualGroupList = groupDetails.groupList;
        system.assertEquals(1, actualGroupList.size(), 'Size of List<CustomerGroup__c> is not equals to 1');
        List<CustomerGroupMember__c> actualGroupMemberList = groupDetails.groupMemberList;
        system.assertEquals(1, actualGroupMemberList.size(), 'Size of List<CustomerGroupMember__c> is not equals to 1');
    }

  /**
    * @description This test method tests that Group and Group member transformations from JSON is successfully tranformared.
    * @name testJsontoGroupDetailConverter
    */ 
    @isTest 
    private static void testJsonWithOutHouseHoldInfo() {
        setup();
        stageorchestration__c testRecord=new StageOrchestration__c();
        testRecord.Value__c=buildSingleJson('clientId123','');
        UTIL_OrchestrationJSONtoGroupDetails.HLPR_GroupAndGroupMemberWrapper groupDetails = runTest( testRecord.Value__c);
        List<CustomerGroup__c> actualGroupList = groupDetails.groupList;
        system.assertEquals(0, actualGroupList.size(), 'Size of List<CustomerGroup__c> is not equals to 0');
        List<CustomerGroupMember__c> actualGroupMemberList = groupDetails.groupMemberList;
        system.assertEquals(0, actualGroupMemberList.size(), 'Size of List<CustomerGroupMember__c> is not equals to 0');
    } 
    
    /**
     * @description Run test
     * @param testRecordValue
     * @return UTIL_OrchestrationJSONtoGroupDetails.HLPR_GroupAndGroupMemberWrapper
     */
    private static UTIL_OrchestrationJSONtoGroupDetails.HLPR_GroupAndGroupMemberWrapper runTest(String testRecordValue){
        UTIL_OrchestrationJSONtoGroupDetails.HLPR_GroupAndGroupMemberWrapper groupDetails;
        System.runAs(testAPIUser) {
            Test.startTest();
            AP_StageOrchestrationJSONParser jsonObject = AP_StageOrchestrationJSONParser.parse(testRecordValue);
            groupDetails= UTIL_OrchestrationJSONtoGroupDetails.jsonGroupDetailsConverter(jsonObject);
            Test.stopTest();
        }
        return groupDetails;
    }
    
    /**
     * @description Build JSON Group Details String
     * @param householdId
     * @param clientid2
     * @param associateId
     * @return String
     */
    public static String buildJsonGroupDetailsString(String householdId, String clientid2, String associateId) {
        return
            '{'+
            '   "orchestrationInfo":{'+
            '      "jsonVersionNumber":"1.0",'+
            '      "orchestrationDataName":['+
            '         {'+
            '               "orchestrationNameDetail":{'+
            '               "dataName":"Agent Role",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"AgentRoleIdentifier",'+
            '               "externalSourceSyncTime":"2016-10-03T09:40:58.045+0000",'+
            '               "dataExternalKeyValue":"'+salesRoleHierarchy1.Agent.Associate_Id__C+'~client123",'+
            '               "orchestrationDataValues":{'+
            '               "Customer":"client123",'+
            '               "RelationshipNature":"Prospect",'+
            '               "StartDate":"2008-08-01",'+
            '               "Agent":"'+salesRoleHierarchy1.Agent.Associate_Id__C+'",'+
            '               "HouseholdGroupId":"HouseholdA1"'+
            '               }'+
            '            }'+
            '         },'+
            '         {'+
            '               "orchestrationNameDetail":{'+
            '               "dataName":"Agent Role",'+
            '               "dataDeleteIndicator":false,'+
            '               "dataExternalKey":"AgentRoleIdentifier",'+
            '               "externalSourceSyncTime":"2016-10-03T09:40:58.045+0000",'+
            '               "dataExternalKeyValue":"'+associateId+'~'+clientId2+'",'+
            '               "orchestrationDataValues":{'+
            '               "Customer":"'+clientId2+'",'+
            '               "RelationshipNature":"Customer",'+
            '               "StartDate":"2008-08-01",'+
            '               "Agent":"'+associateId+'",'+
            '               "HouseholdGroupId":"'+householdId+'"'+
            '               }'+
            '            }'+
            '         }'+
            '      ],'+
            '         "orchestrationEventName":{'+
            '         "orchestrationEventType":"Customer Sync",'+
            '         "orchestrationEventDetail":'+null+
            '      }'+
            '   }'+
            '}';
    }

     /**
     * @description Builds Single JSON
     * @param clientId
     * @param householdId
     * @return String
     */
    public static String buildSingleJson(String clientId, String householdId){
        return 
        '{'+
        '   "orchestrationInfo":{'+
        '      "jsonVersionNumber":"1.0",'+
        '      "orchestrationDataName":['+
        '         {'+
        '               "orchestrationNameDetail":{'+
        '               "dataName":"Agent Role",'+
        '               "dataDeleteIndicator":false,'+
        '               "dataExternalKey":"AgentRoleIdentifier",'+
        '               "externalSourceSyncTime":"2016-10-03T09:40:58.045+0000",'+
        '               "dataExternalKeyValue":"'+salesRoleHierarchy1.Agent.Associate_Id__C+'~'+clientId+'",'+
        '               "orchestrationDataValues":{'+
        '               "Customer":"'+clientId+'",'+
        '               "RelationshipNature":"Prospect",'+
        '               "StartDate":"2008-08-01",'+
        '               "Agent":"'+salesRoleHierarchy1.Agent.Associate_Id__C+'",'+
        '               "HouseholdGroupId":"'+householdId+'"'+
        '               }'+
        '            }'+
        '         }'+
        '      ],'+
        '         "orchestrationEventName":{'+
        '         "orchestrationEventType":"Customer Sync",'+
        '         "orchestrationEventDetail":'+null+
        '      }'+
        '   }'+
        '}';
    }    
    
}