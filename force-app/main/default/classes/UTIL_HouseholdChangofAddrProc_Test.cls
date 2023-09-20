/**  
@Author Team Atlas - CustomerView  
@Name UTIL_HouseholdChangofAddrProc_Test
@CreateDate 10/28/2022
@description This class contains unit tests for validating the Case and Tasks on Address Change for a particular account by Agent and CCC
@Version 1.0
*/

@isTest(seeAllData=false)
public class UTIL_HouseholdChangofAddrProc_Test {
    
    /**
     * @description Test Users Setup
     */
	@testsetup
    public static void testUsersSetup() {  
        UTIL_CaseTestData.setUpUsersForCase();
        
        User sysAdminUser = UTIL_CaseTestData.getSysAdminUser();
        System.runAs(sysAdminUser){    
            UTIL_CaseTestData.createAccountWithOneActiveAgentRole();
        }
    }    

    /**
    * @description test Case Created by Agent User or Address Change of an account initiated by Agent User
    * @name   testCaseCreatedByAgentUser
    */ 
    @isTest    
    public static void testCaseCreatedByAgentUser(){
        User agentUser = UTIL_CaseTestData.getAgentUser();
        User proxyUser = UTIL_CaseTestData.getAgentProxyUser();
        Id accountId = UTIL_CaseTestData.getAccount().Id;
   		List<Id> actIdList = new List<Id>{accountId};
        Map<Id,String> idToDescMap = new Map<Id,String>();
        idToDescMap.put(accountId, 'because this is a test');
        
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);        
        System.runAs(agentUser){
            UTIL_HouseholdChangeofAddressProcess.assignedCasesAndTasksForMembers(actIdList, idToDescMap);
        }
        Test.stopTest();

        case actualCaseForCoA=[Select Id,AccountId,OwnerId,Priority,Status,Subject,Type,Case_Originator__c,Reason,Assigned_To__c,(select id, CaseAccessLevel from shares),(select id from tasks) 
                         From case Where AccountId=:accountId];
        System.assertEquals(proxyUser.Id, actualCaseForCoA.OwnerId, 'COA Case Owner should be Agent Office');           
        System.assertEquals(null, actualCaseForCoA.Assigned_To__c, 'COA Case should NOT be assigned to Agent');
        System.assertEquals('New', actualCaseForCoA.Status, 'COA Case status should be New');
        System.assertEquals(System.Label.CL_ADDRESS_CHANGE_SUBJECT, actualCaseForCoA.Subject, 'COA Case subject should be');
        System.assertEquals(UTIL_HouseholdChangeofAddressProcess.CASE_TYPE, actualCaseForCoA.Type, 'COA Case Type should be Account Change');           
        System.assertEquals(UTIL_HouseholdChangeofAddressProcess.CASE_REASON, actualCaseForCoA.Reason, 'COA Case Reason should be Change of Address');
                
        List<caseshare> caseshareRecordList = actualCaseForCoA.shares;
        system.assertEquals(1,caseshareRecordList.size(), 'COA Case should have 1 Case share');
        for(CaseShare caseshare: caseshareRecordList){
            System.assertEquals('All', caseshare.CaseAccessLevel, 'COA Case Share should have ALL Access Level');
        }
    }
    
   /**
    * @description test Case Created by CCC Licensed User or Address Change of an account initiated by CCC Licensed User
    * @name   testCaseCreatedByCCCLicensedUser
    */ 
    @isTest   
    public static void testCaseCreatedByCCCLicensedUser(){
        User cccSalesUser = UTIL_CaseTestData.getCCCLicensedUser();
        User proxyUser = UTIL_CaseTestData.getAgentProxyUser();
        Id accountId = UTIL_CaseTestData.getAccount().Id;
        List<Id> actIdList = new List<Id>{accountId};
        Map<Id,String> idToDescMap = new Map<Id,String>();
        idToDescMap.put(accountId, 'because this is a test');
        
        Test.startTest();       
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccSalesUser);     
        System.runAs(cccSalesUser){
            UTIL_HouseholdChangeofAddressProcess.assignedCasesAndTasksForMembers(actIdList, idToDescMap);
        }
        Test.stopTest();

        case actualCaseForCoA = [Select Id,AccountId,OwnerId,Priority,Status,Subject,Type,Case_Originator__c,Reason,Assigned_To__c,(select id, CaseAccessLevel from shares),(select id from tasks) 
                         From case Where AccountId=:accountId];
        
        System.assertEquals(proxyUser.Id, actualCaseForCoA.OwnerId, 'COA Case Owner should be Agent Office');  
        System.assertEquals(null, actualCaseForCoA.Assigned_To__c, 'COA Case AssignedTo should be null by CCC user');
        System.assertEquals(UTIL_HouseholdChangeofAddressProcess.CASE_STATUS, actualCaseForCoA.Status, 'COA Case status should NEW by CCC user');
        System.assertEquals(UTIL_HouseholdChangeofAddressProcess.CASE_TYPE, actualCaseForCoA.Type, 'COA Case Type should be Account Change');
        System.assertEquals(UTIL_HouseholdChangeofAddressProcess.CASE_REASON, actualCaseForCoA.Reason, 'COA Case Reason should be Change of Address');
    }  
    
    /**
    * @description test Case Created by CCC UNLicensed User or Address Change of an account initiated by CCC UnLicensed User
    * @name   testCaseCreatedbyCCCUnLicensedUser
    */ 
    @isTest   
    public static void testCaseCreatedbyCCCUnLicensedUser(){
        User cccServiceUser = UTIL_CaseTestData.getCCCUnLicensedUser();
        User proxyUser = UTIL_CaseTestData.getAgentProxyUser();
        Id accountId = UTIL_CaseTestData.getAccount().Id;
        List<Id> actIdList = new List<Id>{accountId};
        Map<Id,String> idToDescMap = new Map<Id,String>();
        idToDescMap.put(accountId, 'because this is a test');
        Test.startTest();       
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccServiceUser);
        System.runAs(cccServiceUser){
            UTIL_HouseholdChangeofAddressProcess.assignedCasesAndTasksForMembers(actIdList, idToDescMap);
        }
        Test.stopTest();

        case actualCaseForCoA = [Select Id,AccountId,OwnerId,Priority,Status,Subject,Type,Case_Originator__c,Reason,Assigned_To__c,(select id, CaseAccessLevel from shares),(select id from tasks) 
                         From case Where AccountId=:accountId];
        
        System.assertEquals(proxyUser.Id, actualCaseForCoA.OwnerId, 'COA Case Owner should be Agent Office');  
		System.assertEquals(null, actualCaseForCoA.Assigned_To__c, 'COA Case AssignedTo should be null by CCC UnLicensed user');
        System.assertEquals(UTIL_HouseholdChangeofAddressProcess.CASE_STATUS, actualCaseForCoA.Status, 'COA Case status should NEW by CCC UnLicensed user');
        System.assertEquals(UTIL_HouseholdChangeofAddressProcess.CASE_TYPE, actualCaseForCoA.Type, 'COA Case Type should be Account Change');
        System.assertEquals(UTIL_HouseholdChangeofAddressProcess.CASE_REASON, actualCaseForCoA.Reason, 'COA Case Reason should be Change of Address');
    } 
    
    
   /**
    * @description CaseCreationWithNullAgentAssociateIDException: Exception Handling for coa creation 
    */  
    @isTest   
    public static void testCaseCreationWithNullAgentAssociateIDException(){       
        User sysAdminUser = UTIL_CaseTestData.getSysAdminUser();
        System.runAs(sysAdminUser){    
			User agentUser = UTIL_CaseTestData.getAgentUser();
            agentUser.Servicing_Agent_Associate_ID__c = null;
            update agentUser;
        }
        
        User agentUser = UTIL_CaseTestData.getAgentUser();
        Id accountId = UTIL_CaseTestData.getAccount().Id;
        List<Id> actIdList = new List<Id>{accountId};
        Map<Id,String> idToDescMap = new Map<Id,String>();
        idToDescMap.put(accountId, 'because this is a test');
        
        Test.startTest();  
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);     
        System.runAs(agentUser){
            try{
            	UTIL_HouseholdChangeofAddressProcess.assignedCasesAndTasksForMembers(actIdList, idToDescMap);
            }
            catch(NoDataFoundException ex){
                System.assert(ex.getCause() != null, 'Agent with NULL Sersociate ID should throw error');
                System.assert(ex.getMessage().contains('Unable to create COA'), 'Unexpected Error message');
                System.assert(ex.getCause() instanceof NoDataFoundException , 'Empty customer id should throw Null Pointer exception');
            }
        }
        Test.stopTest();
    }
}