/**
* @Author  ScrumDwags
* @description  Test class for WS_DeleteUpdateProductData - Apex Rest service.
* Copyright © StateFarm
*/
@isTest(SeeAllData = false)
private class WS_DeleteUpdateProductData_Test {
    
    private static User processId1;
    private static User processId2;
    private static User processId3;
    private static User proxyUser;
    private static User sysAdminUser =  TestDataFactory_User.getSysAdminUser();
    private static String processId1UserName = 'procId';
    private static String processId2UserName = 'procId2';
    private static String processId3UserName = 'procId3';    

    //method to assign permissionset for the given user in parameter value
    private static void assignPermissionSet(User testUser, String permissionSetName) {
        PermissionSet queryPermissionSet = [Select id FROM PermissionSet WHERE Name =: permissionSetName Limit 1];
        PermissionSetAssignment assignPermissionSet = new PermissionSetAssignment();
        assignPermissionSet.AssigneeId = testUser.id;
        assignPermissionSet.PermissionSetId = queryPermissionSet.id;
        insert assignPermissionSet;
    }
    
    //setting up Data for the tests
    private static Opportunityproduct__c createProduct(){
        OpportunityProduct__c opp = new OpportunityProduct__c();
        opp.Name='Opp Name';
        opp.Category_Name__c ='Something'; 
        opp.Lob_Name__c	='Auto';
        opp.status__c =true;
        opp.Lob_Cd__c ='111';
        return opp;
    } 
    
    //setting up data for the update tests
    private static Opportunityproduct__c updateProduct(){
        OpportunityProduct__c opp1 = new OpportunityProduct__c();
        opp1.Name='Opp Name';
        opp1.Category_Name__c ='Something';
        opp1.Lob_Name__c	='Auto';
        opp1.status__c =false;
        opp1.Lob_Cd__c ='111';
        return opp1;
    }
         
    //Description: passing valid user and trying to Upsert Account,Agent Role and Insert Opportunity with invalid AccountType to test fail scenario
      @isTest
      private static void verifyStatusUpdate() {
        
       	processId1 = TestDataFactory_User_Wrapper.generateApiOnlyUser(processId1UserName, 'catAssocId');
        processId1 = TestDataFactory_User.insertUser(processId1); 
        assignPermissionSet(processId1, 'SF_CRM_OPPPRODMGMNTRETRIEVAL_PermSetPID');
        String id ='';
        System.runAs(processId1) {
            OpportunityProduct__c prtrue = createProduct();
            insert prtrue; 
            id = prtrue.id;
            OpportunityProduct__c prfalse = updateProduct();
            insert prfalse;
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            RestContext.request = req;
            RestContext.response= res;
                
            req.requestURI = '/services/apexrest/productRetrievalServiceUpdate';
            req.httpMethod = 'GET';  
            
            Test.starttest();
            CS_EnvironmentURLCustomSetting__c envCS = new CS_EnvironmentURLCustomSetting__c();
            envCS.name = 'ICP_TP_ENV';
            envCS.value__c = 'unittest.statefarm.com';
            insert envCS;
            WS_DeleteUpdateProductData.deleteUpdateProductData();
            List<OpportunityProduct__c> idList = new List<OpportunityProduct__c>();
            idList = [SELECT Id from OpportunityProduct__c where Id = :prtrue.id];
            System.assert(idList.isEmpty(), 'List size is wrong');
            Test.stoptest();         
        }           
    }    
    
    //Description: production custom setting test
    @isTest
    private static void verifyStatusUpdateForProdCustomSettingTest() {
        
       	processId1 = TestDataFactory_User_Wrapper.generateApiOnlyUser(processId1UserName, 'catAssocId');
        processId1 = TestDataFactory_User.insertUser(processId1); 
        assignPermissionSet(processId1, 'SF_CRM_OPPPRODMGMNTRETRIEVAL_PermSetPID');      
        String id ='';
        System.runAs(processId1) {
            OpportunityProduct__c prtrue = createProduct();
            insert prtrue; 
            id = prtrue.id;
		    OpportunityProduct__c prfalse = updateProduct();
            insert prfalse;
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
        	RestContext.request = req;
        	RestContext.response= res;
                
            req.requestURI = '/services/apexrest/productRetrievalServiceUpdate';
            req.httpMethod = 'GET';  
            
            Test.starttest();
            CS_EnvironmentURLCustomSetting__c envCS = new CS_EnvironmentURLCustomSetting__c();
            envCS.name = 'ICP_TP_ENV';
            envCS.value__c = '.statefarm.com';
            insert envCS;              
            WS_DeleteUpdateProductData.deleteUpdateProductData();
            List<OpportunityProduct__c> idList = new List<OpportunityProduct__c>();
            idList = [SELECT Id from OpportunityProduct__c where Id = :prtrue.id];
            System.assert(idList.isEmpty(), 'List size is wrong');
            Test.stoptest();         
        }           
    }   
    
    //Description: passing valid user and trying to Upsert Account,Agent Role and Insert Opportunity with invalid AccountType to test fail scenario
    @isTest  
    private static void verifyStatusUpdateWithException() {
        
       	processId1 = TestDataFactory_User_Wrapper.generateApiOnlyUser(processId1UserName, 'catAssocId');
        processId1 = TestDataFactory_User.insertUser(processId1); 
        assignPermissionSet(processId1, 'SF_CRM_OPPPRODMGMNTRETRIEVAL_PermSetPID');
        processId2 = TestDataFactory_User_Wrapper.generateApiOnlyUser(processId2UserName, 'catAssocId2');
        processId2 = TestDataFactory_User.insertUser(processId2); 
        assignPermissionSet(processId2, 'SF_CRM_SFCOMLeadMsgSrvcs_PermSetPID');     
        String id ='';
        OpportunityProduct__c prtrue = new OpportunityProduct__c();
        System.runAs(processId1) {
            prtrue = createProduct();
            insert prtrue; 
            id = prtrue.id;
        }
        System.runAs(processId2) {
             
		    OpportunityProduct__c prfalse = updateProduct();
            prfalse.Lob_Name__c ='Test';
            insert prfalse;
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
        	RestContext.request = req;
        	RestContext.response= res;
                
            req.requestURI = '/services/apexrest/productRetrievalServiceUpdate';
            req.httpMethod = 'GET';  
            
            Test.starttest();
            try {                       
                WS_DeleteUpdateProductData.deleteUpdateProductData();
            } catch (Exception e) {
                System.assertEquals(prfalse.status__c, false, 'prfalse status not equal to false'); 
            }
            Test.stoptest();         
        }    
    }   
    
    //Description: passing valid user and verify the update Exception

    @isTest
    private static void verifyUpdateException() {
       
       	processId1 = TestDataFactory_User_Wrapper.generateApiOnlyUser(processId1UserName, 'catAssocId');
        processId1 = TestDataFactory_User.insertUser(processId1); 
        assignPermissionSet(processId1, 'SF_CRM_OPPPRODMGMNTRETRIEVAL_PermSetPID');
        processId3 = TestDataFactory_User_Wrapper.generateApiOnlyUser(processId3UserName, 'catAssocId3');
        processId3 = TestDataFactory_User.insertUser(processId3); 
        assignPermissionSet(processId3, 'SF_CRM_OpportunityAutoClose_PermSetPID');   
        String id ='';
        OpportunityProduct__c prtrue = new OpportunityProduct__c();
        System.runAs(processId1) {
            prtrue = createProduct();
            insert prtrue; 
            id = prtrue.id;
        }
        System.runAs(processId3) {
             
		    OpportunityProduct__c prfalse = updateProduct();
            prfalse.Lob_Name__c ='Test';
            insert prfalse;
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
        	RestContext.request = req;
        	RestContext.response= res;			
                
            req.requestURI = '/services/apexrest/productRetrievalServiceUpdate';
            req.httpMethod = 'GET';  
            
            Test.starttest();
            try {
                CS_EnvironmentURLCustomSetting__c envCS = new CS_EnvironmentURLCustomSetting__c();
                envCS.name = 'ICP_TP_ENV';
                envCS.value__c = '.statefarm.com';
                insert envCS;
                WS_DeleteUpdateProductData.deleteUpdateProductData();
            } catch (Exception e) {
               System.assertEquals(prfalse.status__c, false, 'prfalse status not equal to false');
            }
            Test.stoptest();         
        }    
    }     
}