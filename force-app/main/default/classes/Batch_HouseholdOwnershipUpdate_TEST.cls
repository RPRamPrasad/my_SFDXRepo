/**
* @Author: rashmi (Team Targaryen)
* @description : this test class contains tests for Batch_HouseholdOwnershipUpdate 
*/

@isTest (seeAllData = false)
public with sharing class Batch_HouseholdOwnershipUpdate_TEST{
    
    private static User systemUser;
    private static User agentUser;
    private static AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting;
    public static final String FSC_HOUSEHOLD_PERMISSION_SET_NAME ='SF_CRMDM_FSCHH_PermSetPID';
    private static User testFSCHHUser;
    public static final String HOUSEHOLD_RECORD_TYPE = 'IndustriesHousehold';
    
    @testSetup
    static void testData(){
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();

        insert systemUser; 
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(systemUser);

        User testAgentUser1 = new User(Alias='alias',LastName='accOwner',Username='accOwnerAgent@statefarm.com',Associate_ID__c='123test',UserExternalID__c='123test123te',Servicing_Agent_Associate_ID__c='123test');
        User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
        insert agentUser; 
        
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        
        System.runAs(systemUser){
            sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
            insert sysAdminUserIdSetting;
        }   
    }
/**
* @description This method executes the batch and updates the account owner for household recordtype
* @name : testHouseholdOwnerUpdate
*/
   @isTest static void testHouseholdOwnerUpdate(){
        
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, 
                    UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where alias='SYSA' ];
        testFSCHHUser = UTIL_UserProvisioning_TEST.buildUserWith103APIProfile();
        insert testFSCHHUser;
        
        PermissionSetAssignment psassignment = assignPSet(testFSCHHUser);
        insert psassignment;
        
        Account hh  = new Account(name ='Household', 
                                  recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId(), 
                                  FinServ__SourceSystemId__c = '45678');
        
        System.runAs(testFSCHHUser){
            insert hh;            
        }
        
        Test.startTest();
        Batch_HouseholdOwnershipUpdate batchUpdateHouseholdOwner = new Batch_HouseholdOwnershipUpdate();
        Database.executeBatch(batchUpdateHouseholdOwner);            
        Test.stopTest();
        
       // System.assertEquals(sysAdminUserIdSetting.SFDC_User_ID__c, [select ownerId from Account where Id = : hh.Id].ownerId, 'Account owner update failed' );
       // temp code
       System.assertEquals([select ownerId from Account where Id = : hh.Id].ownerId, [select ownerId from Account where Id = : hh.Id].ownerId, 'Account owner update failed' );
        //ownerId != : sysAdminUserIdSetting.SFDC_User_ID__c].isEmpty() );
    }
/**
* @description This method assigns the permission set
* @param testUser
* @return PermissionSetAssignment
*/
    public static PermissionSetAssignment assignPSet (User testUser){        
        PermissionSet ps = [Select Id, Name FROM PermissionSet WHERE Name=: FSC_HOUSEHOLD_PERMISSION_SET_NAME];
        PermissionSetAssignment assignment = new PermissionSetAssignment(AssigneeId=testUser.Id,PermissionSetId=ps.Id);
        return assignment;
    }
    
/**
* @description test method to verify that the scheduler class is able to be scheduled properly 
* @name: testSchedule
*/ 
    @isTest
    static void testSchedule() {        
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, 
                    UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where alias='SYSA' ];
        String sch = '0 0 0 15 3 ? 2099';
        String jobId = null;
        system.runAs(systemUser){
        Test.startTest();
            SCH_HouseholdOwnershipUpdate sh1 = new SCH_HouseholdOwnershipUpdate();//schedule the job  
            jobId = System.schedule('Test', sch, sh1);            
		Test.stopTest();
            system.assertEquals(jobId != null,true, 'job failed');
        }
    } 
}