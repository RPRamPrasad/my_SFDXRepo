/**
Author Team ClubCar
Name - Batch_HandleSwcNoResponse_Test
@description Test class written for Batch_HandleSwcNoResponse.cls
========================================================================================================================================+
VERSION         AUTHOR                      DATE                    DETAIL
1.0             Team ClubCar                10/20/2020              Initial Development
2.0             Team Incognito              08/19/2022               Refactored code
******************************************************************************************************************************************/
@isTest(SeeAlldata=false)
public with sharing class Batch_HandleSwcNoResponse_Test {
    private static User sysAdminuser;    
    private static Account testAccount;
    private static Opportunity oppForSwc;
    private static User systemAdmin;
    private static String optyRecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunity_Management').getRecordTypeId();
    private static User swcProcessId;
    
    @testsetup
    private static void setUp() {
        systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        System.runAs(systemAdmin) {  
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        HLPR_SignedWrittenConsent_TEST.createSwcToggleRecord();
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;
        CS001_ByPassTriggerAtoF__c accountByPassTrigger= new CS001_ByPassTriggerAtoF__c(Override_AccountBeforeInsert__c=false,Override_AgentRoleAfterInsert__c=false);
        insert accountByPassTrigger;
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(Name=UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER,SFDC_USER_ID__c=systemUser.id);            
        insert sysAdminUserIdSetting;
        CS001_ByPassTriggerGtoZ__c objectBasedByPassTrigger = CS001_ByPassTriggerGtoZ__c.getInstance();
        objectBasedByPassTrigger.Override_OpportunityAfterInsert__c = true;
        insert objectBasedByPassTrigger;  
        swcProcessId = UTIL_UserProvisioning_TEST.buildConnectedAppProcIdUser('alias','connectedAppProcId','connectedAppProcId@statefarm.com');
        insert swcProcessId;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(swcProcessId);
        // Admin team removed SF_CRM_ModifyAllData_PermSetPID; not familiar with all that is required for this test
        // class to work, so assigning SF_CRM_MarketingClConnect_PermSetPID which is just a scaled down modify all
        assignPermissionSet(swcProcessId, 'SF_CRM_MarketingClConnect_PermSetPID');
        }
    }

    // test method to make sure Batch updates SWC records with "No Response" Status
    @isTest 
    private static void testSWCBatchUpdatesNoResponseStatus(){
        swcProcessId = [Select id from User where lastname='connectedAppProcId' LIMIT 1];  
        System.runAs(swcProcessId) {
            createTestAccount();
            List<Opportunity> oppList = new List<Opportunity>();
            oppList.add(buildOpportunityRecord(testAccount.id, 'Auto', true));
            oppList.add(buildOpportunityRecord(testAccount.id, 'Fire', true));
            oppList.add(buildOpportunityRecord(testAccount.id, 'Auto', true));
            oppList.add(buildOpportunityRecord(testAccount.id, 'Fire', true));
            insert oppList;
            oppList[0].OppSignedWrittenConsentStatus__c = 'Requested';
            oppList[1].OppSignedWrittenConsentStatus__c = 'Requested';
            oppList[2].OppSignedWrittenConsentStatus__c = 'Requested';
            oppList[3].OppSignedWrittenConsentStatus__c = 'Requested';
            update oppList[0];
            update oppList[1];
            update oppList[2];
            update oppList[3];
            oppForSwc = oppList[0];
            SignedWrittenConsent__c signedWrittenConsentRecord = TestDataFactory_Journey.buildSwcRecord(System.Today() -2, System.Today()+30, oppForSwc);
            insert signedWrittenConsentRecord;
            SignedWrittenConsent__c signedWrittenConsentRecord1 = TestDataFactory_Journey.buildSwcRecord(System.Today() -60, System.Today()-30, oppForSwc);
            signedWrittenConsentRecord1.Status__c = 'Granted';
            insert signedWrittenConsentRecord1;            
            Test.startTest();
            Batch_HandleSwcNoResponse handleSWCNoResponseObj = new Batch_HandleSwcNoResponse ();
            Database.executebatch(handleSWCNoResponseObj);
            Test.stopTest();
            SignedWrittenConsent__c swcRecordAfterBatchRun = [Select Status__c from SignedWrittenConsent__c where Id =: signedWrittenConsentRecord.Id];
            for (Opportunity oppAfterBatchRun : [Select id, OppSignedWrittenConsentStatus__c from Opportunity where AccountId =: testAccount.Id]){
                System.Assert('No Response'.equals(oppAfterBatchRun.OppSignedWrittenConsentStatus__c),'Opportunity Status was not updated');
            }
            System.Assert('No Response'.equals(swcRecordAfterBatchRun.Status__c), 'SWC Status was not updated by Batch');
		}
    }

    // test SignedWrittenConsent batch exception scenario with bad Opportunity Id
    @isTest
    private static void testSwcBatchException(){ 

        swcProcessId = [Select id from User where lastname='connectedAppProcId' LIMIT 1];  
        System.runAs(swcProcessId) {
            createTestAccount();
            oppForSwc = new Opportunity(accountId = testAccount.id, name='Opp',closeDate=system.today(), stageName='Assigned',LOB__c='Auto',Description='Test Descrption',RecordTypeId=optyRecordTypeId);
            insert oppForSwc;
            SignedWrittenConsent__c signedWrittenConsentRecord = (TestDataFactory_Journey.buildSwcRecord(System.Today() -2, System.Today()+30,oppForSwc));
            signedWrittenConsentRecord.InitiatedFromId__c = '123456789';
            insert signedWrittenConsentRecord;
            Test.startTest();
            Batch_HandleSwcNoResponse handleSWCNoResponseObj = new Batch_HandleSwcNoResponse ();
            Database.executebatch(handleSWCNoResponseObj);
            Test.stopTest();   
            List<ExceptionLog__c> swcExLog = [SELECT Id from ExceptionLog__c class__c where class__c = 'Batch_HandleSwcNoResponse'];           
            System.Assert(swcExLog.size() ==1, 'SWC Batch Execption was not generated'); 
        }
    }

    
    // helper method to insert test Account records
    private static void createTestAccount(){
        systemAdmin = [Select id from User where username ='systemAdminTest@statefarm.com' LIMIT 1];
        System.runas(systemAdmin){
            testAccount= new Account(firstname ='SSSHHHH', lastname='SSSSSHHHH', ClientIdentifier__c = 'cid1', Edit_In_VFP__c = true);
            insert testAccount;
        }       
    }
  
    
    //method to assign permissionset for the given user in parameter value
    private static void assignPermissionSet(User testUser, String permissionSetName) {
        PermissionSet queryPermissionSet = [Select id FROM PermissionSet WHERE Name =: permissionSetName Limit 1];
        PermissionSetAssignment assignPermissionSet = new PermissionSetAssignment();
        assignPermissionSet.AssigneeId = testUser.id;
        assignPermissionSet.PermissionSetId = queryPermissionSet.id;
        insert assignPermissionSet;
    }

    //method to build Opportunity record with the given parameter value
    private static Opportunity buildOpportunityRecord(String paramAccountId, String paramLOB, Boolean populateSwcFields) {
        Opportunity opptyRecord = new Opportunity (Name = 'Tst Opportunity', AccountId = paramAccountId,CloseDate = System.today().addDays(10), LOB__c = paramLOB,
                                                    StageName = 'Assigned',DateCaptured__c = System.today().addDays(-9));
        if(populateSwcFields){
            opptyRecord.OppSignedWrittenConsentRequestedDate__c = System.Today();
            opptyRecord.OppSignedWrittenConsentStatus__c = 'Requested';
        }
        return opptyRecord; 
    }
}