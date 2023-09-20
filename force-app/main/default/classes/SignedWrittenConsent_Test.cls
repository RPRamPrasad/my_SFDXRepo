/**
Author Team ClubCar
Name - SignedWrittenConsent_Test
@description Test class written for SignedWrittenConsent.cls
========================================================================================================================================+
VERSION         AUTHOR                      DATE                    DETAIL
1.0             Team ClubCar                10/20/2020              Initial Development
******************************************************************************************************************************************/
@isTest(SeeAlldata=false)
public with sharing class SignedWrittenConsent_Test {

    private static User proxyUser;
    private static User sysAdminuser;    
    private static Account testAccount;
    private static Opportunity oppForSwc;
    private static User systemAdmin;
    private static String optyRecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunity_Management').getRecordTypeId();
    
    // test setup method to insert/ update test data that will be used during entire test run
    @testsetup
    private static void setUp() {
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
          User testProxyUser1 = new User(Alias='Prox',LastName='opportunityAg',Username='TestProxUserForOppTst11@statefarm.com',UserExternalID__c='123testP',Servicing_Agent_Associate_ID__c='123test');  
          proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
          insert proxyUser;

    }

    // test SignedWrittenConsent update scenario when first SWC record under a Account is consent granted  
    @isTest
    private static void testFirstSwcGranted(){
        String taskDescription = 'Beginning this due date, consent has been provided to continue marketing efforts.Depending on the state, this can be a 30 day window or a 90 day window that you are able to market to the prospect';
        User queryProxy = [Select id from User where username = 'TestProxUserForOppTst11@statefarm.com' LIMIT 1];  
        createTestAccount();
        oppForSwc = new Opportunity(accountId = testAccount.id, name='Opp',closeDate=system.today(), stageName='Assigned',LOB__c='Auto',Description='Test Descrption',RecordTypeId=optyRecordTypeId,OwnerId = queryProxy.id);
        oppForSwc.OppSignedWrittenConsentRequestedDate__c = System.Today();
        oppForSwc.OppSignedWrittenConsentStatus__c = 'Requested';
        insert oppForSwc; 
        SignedWrittenConsent__c signedWrittenConsentRecord = buildSwcRecord(System.Today(), System.Today()+30);
        insert signedWrittenConsentRecord;
        signedWrittenConsentRecord.Status__c = 'Granted';
        Test.startTest();
        update signedWrittenConsentRecord;
        Test.stopTest();
        Opportunity oppAfterSwcGranted = [Select id, OppSignedWrittenConsentGrantedDate__c , OppSignedWrittenConsentStatus__c from Opportunity where Id =:oppForSwc.id Limit 1];
        Task swcTask = [Select Description, subject, ActivityDate from Task where Whatid =:oppForSwc.id and Subject = 'Signed Written Consent Granted' Limit 1];
        System.AssertEquals('Granted',oppAfterSwcGranted.OppSignedWrittenConsentStatus__c, 'Opportunity SignedWrittenConsent status was not updated');
        System.AssertEquals(System.Today(),oppAfterSwcGranted.OppSignedWrittenConsentGrantedDate__c, 'Opportunity SignedWrittenConsentDate RequestedDate was not updated');
        System.AssertEquals('Signed Written Consent Granted', swcTask.Subject, 'SWC Granted Task was not created with required Subject');
        System.AssertEquals(System.Today(), swcTask.ActivityDate, 'SWC Granted Task was not created with required Due Date');
        System.AssertEquals(taskDescription, swcTask.Description, 'SWC Granted Task was not created with required description');
    }
    
    //test SignedWrittenConsent Update scenario SWC record is consent granted after new opportunity under same Account
    @isTest
    private static void testSwcGrantedAfterNewOpportunity(){ 
        User queryProxy = [Select id from User where username = 'TestProxUserForOppTst11@statefarm.com' LIMIT 1];  
        createTestAccount();
        oppForSwc = new Opportunity(accountId = testAccount.id, name='Opp',closeDate=system.today(), stageName='Assigned',LOB__c='Auto',Description='Test Descrption',RecordTypeId=optyRecordTypeId,OwnerId = queryProxy.id);
        insert oppForSwc; 
        SignedWrittenConsent__c signedWrittenConsentRecord = buildSwcRecord(System.Today(), System.Today()+30);
        insert signedWrittenConsentRecord;
        signedWrittenConsentRecord.Status__c = 'Granted';
        Test.startTest();
        update signedWrittenConsentRecord;
        Test.stopTest();
        SignedWrittenConsent__c swcGrantedRecord = [Select Status__c from SignedWrittenConsent__c where id =: signedWrittenConsentRecord.id Limit 1 ];
        Opportunity oppAfterSwcGranted = [Select id, OppSignedWrittenConsentGrantedDate__c , OppSignedWrittenConsentStatus__c from Opportunity where Id =:oppForSwc.id Limit 1];
        List<Task> swcTaskList = [Select Description, subject, ActivityDate from Task where Whatid =:oppForSwc.id and Subject = 'Signed Written Consent Granted' Limit 1];
        System.AssertEquals('Granted - After New Opportunity',swcGrantedRecord.Status__c, 'SignedWrittenConsent status was not updated');
        System.AssertEquals(null, oppAfterSwcGranted.OppSignedWrittenConsentGrantedDate__c, 'Opportunity SignedWrittenConsentDate RequestedDate was updated');
        System.assert(swcTaskList.isEmpty(), 'SWC granted task was created');

    }

    // test SignedWrittenConsent update scenario when Second SWC record under a Account is consent granted
    @isTest
    private static void testSecondSwcGrantedOnSameAccount(){ 
        User queryProxy = [Select id from User where username = 'TestProxUserForOppTst11@statefarm.com' LIMIT 1]; 
        createTestAccount();
        oppForSwc = new Opportunity(accountId = testAccount.id, name='Opp',closeDate=system.today(), stageName='Assigned',LOB__c='Auto',Description='Test Descrption',RecordTypeId=optyRecordTypeId, OwnerId = queryProxy.id);
        oppForSwc.OppSignedWrittenConsentGrantedDate__c = System.Today() -10;
        oppForSwc.OppSignedWrittenConsentStatus__c = 'Granted';
        insert oppForSwc;
        SignedWrittenConsent__c signedWrittenConsentRecord = buildSwcRecord(System.Today() +10, System.Today()+40);
        insert signedWrittenConsentRecord;        
        Test.startTest();
        signedWrittenConsentRecord.Status__c = 'Granted'; 
        update signedWrittenConsentRecord;
        Test.stopTest();
        
	    SignedWrittenConsent__c swcGrantedRecord = [Select id, RequestStartDate__c, Status__c from SignedWrittenConsent__c where id =: signedWrittenConsentRecord.id Limit 1 ];
        Opportunity oppAfterSwcGranted = [Select id, DateCaptured__c, OppSignedWrittenConsentGrantedDate__c , OppSignedWrittenConsentStatus__c from Opportunity where Id =:oppForSwc.id Limit 1];
        Task swcTask = [Select subject, ActivityDate from Task where Whatid =:oppForSwc.id Limit 1];
        System.AssertEquals('Granted',oppAfterSwcGranted.OppSignedWrittenConsentStatus__c, 'Opportunity SignedWrittenConsent status was not updated');
        System.AssertEquals(System.Today() +10,oppAfterSwcGranted.OppSignedWrittenConsentGrantedDate__c, 'Opportunity SignedWrittenConsentDate RequestedDate was not updated');
        System.assert(oppAfterSwcGranted.DateCaptured__c.isSameDay(System.Today() -10), 'Opportunity Date Captured was not updated');
        System.assert('Granted'.equals(swcGrantedRecord.Status__c), 'SWC status was not updated with correct picklist value');
        System.AssertEquals('Signed Written Consent Granted', swcTask.Subject, 'SWC Granted Task was not created with required Subject');
        System.AssertEquals(System.Today() +10, swcTask.ActivityDate, 'SWC Granted Task was not created with required Due Date');   
    }

        // test SignedWrittenConsent update scenario when previous swc status was 'No Response' 
        @isTest
        private static void testSwcGrantedwithPrevNoResponse(){
            User queryProxy = [Select id from User where username = 'TestProxUserForOppTst11@statefarm.com' LIMIT 1];  
            createTestAccount();
            oppForSwc = new Opportunity(accountId = testAccount.id, name='Opp',closeDate=system.today(), stageName='Assigned',LOB__c='Auto',Description='Test Descrption',RecordTypeId=optyRecordTypeId,OwnerId = queryProxy.id);
            insert oppForSwc; 
            SignedWrittenConsent__c signedWrittenConsentRecord = buildSwcRecord(System.Today(), System.Today()+30);
            signedWrittenConsentRecord.Status__c = 'No Response';
            insert signedWrittenConsentRecord;
            signedWrittenConsentRecord.Status__c = 'Granted';
            Test.startTest();
            update signedWrittenConsentRecord;
            Test.stopTest();
            Opportunity oppAfterSwcGranted = [Select id, OppSignedWrittenConsentGrantedDate__c , OppSignedWrittenConsentStatus__c from Opportunity where Id =:oppForSwc.id Limit 1];
            SignedWrittenConsent__c swcRecord = [Select id, Status__c from SignedWrittenConsent__c where id =: signedWrittenConsentRecord.id Limit 1];
            List<Task> swcTaskList = [Select Description, subject, ActivityDate from Task where Whatid =:oppForSwc.id and Subject = 'Signed Written Consent Granted' Limit 1];
            System.AssertEquals('No Response',swcRecord.Status__c, 'Swc record status was not updated correctly');
            System.AssertEquals(null, oppAfterSwcGranted.OppSignedWrittenConsentGrantedDate__c, 'Opportunity SignedWrittenConsentDate RequestedDate was updated');
            System.assert(swcTaskList.isEmpty(), 'SWC granted task was created'); 
        }
   
    // test SignedWrittenConsent exception scenario- When InitiatedById is Null  
    @isTest
    private static void testSwcGrantedException(){ 
        createTestAccount();
        oppForSwc = new Opportunity(accountId = testAccount.id, name='Opp',closeDate=system.today(), stageName='Assigned',LOB__c='Auto',Description='Test Descrption',RecordTypeId=optyRecordTypeId);
        oppForSwc.OppSignedWrittenConsentRequestedDate__c = System.Today();
        oppForSwc.OppSignedWrittenConsentStatus__c = 'Requested';
        insert oppForSwc;
        SignedWrittenConsent__c signedWrittenConsentRecord = (buildSwcRecord(System.Today(), System.Today()+30));
        signedWrittenConsentRecord.InitiatedFromId__c = Null;
        insert signedWrittenConsentRecord;
        signedWrittenConsentRecord.Status__c = 'Granted';
        Test.startTest();
        update signedWrittenConsentRecord;
        Test.stopTest();     
        List<ExceptionLog__c> swcExLog = [SELECT Id from ExceptionLog__c class__c where class__c = 'SignedWrittenConsent'];           
        System.Assert(swcExLog.size() ==1, 'SWC Execption was not generated'); 
    }
    
    // test SignedWrittenConsent update scenario should not fire when Trigger is bypassed
    @isTest
    private static void testFirstSwcGrantedTriggerBypass(){
        CS001_ByPassTriggerGtoZ__c objectBasedByPassTrigger = CS001_ByPassTriggerGtoZ__c.getInstance();
        objectBasedByPassTrigger.Override_SWCBeforeUpdate__c = true;
        update objectBasedByPassTrigger; 
        User queryProxy = [Select id from User where username = 'TestProxUserForOppTst11@statefarm.com' LIMIT 1];  
        createTestAccount();
        oppForSwc = new Opportunity(accountId = testAccount.id, name='Opp',closeDate=system.today(), stageName='Assigned',LOB__c='Auto',Description='Test Descrption',RecordTypeId=optyRecordTypeId,OwnerId = queryProxy.id);
        oppForSwc.OppSignedWrittenConsentRequestedDate__c = System.Today();
        oppForSwc.OppSignedWrittenConsentStatus__c = 'Requested';
        insert oppForSwc; 
        SignedWrittenConsent__c signedWrittenConsentRecord = buildSwcRecord(System.Today(), System.Today()+30);
        insert signedWrittenConsentRecord;
        signedWrittenConsentRecord.Status__c = 'Granted';
        Test.startTest();
        update signedWrittenConsentRecord;
        Test.stopTest();
        Opportunity oppAfterSwcGranted = [Select id, OppSignedWrittenConsentGrantedDate__c , OppSignedWrittenConsentStatus__c from Opportunity where Id =:oppForSwc.id Limit 1];
        System.AssertEquals('Requested',oppAfterSwcGranted.OppSignedWrittenConsentStatus__c, 'Opportunity SWC status was not updated');
        System.AssertEquals(null,oppAfterSwcGranted.OppSignedWrittenConsentGrantedDate__c, 'Opportunity SWC granted date was updated');
    }
    
    // helper method to insert test Account records
    private static void createTestAccount(){
        systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com'); 
       insert systemAdmin;
       System.runas(systemAdmin){
           testAccount= new Account(firstname ='SSSHHHH', lastname='SSSSSHHHH', ClientIdentifier__c = 'cid1', Edit_In_VFP__c = true);
           insert testAccount;
       }       
   }
    // helper method to build Test SignedWrittenConsent records
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
}