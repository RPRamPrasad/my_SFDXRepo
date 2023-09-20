@isTest(seeAllData = false)
public class LightningUsageTrackerController_TEST {
	
    private static final String SYSTEM_RECORD_OWNER_USERNAME = UTIL_TestUsername_TEST.getTestUsername('recowner');
    private static final String SYSADMIN_USER_ID = UTIL_TestUsername_TEST.getTestUsername('sysadmin');
    private static User systemAdminUser {get;set;}
    private static User moaAgentUser {get;set;}
    private static User moaATMUser {get;set;}
    private static User noAccessUser {get;set;}
    
    private static void setupMOA() {
        
        systemAdminUser = AP_UserProvisioningProcess_TEST_UTIL.createGenericSystemAdmin(SYSADMIN_USER_ID);      
        AP_UserTestData_UTIL.byPassAllTrigger(SYSADMIN_USER_ID, systemAdminUser); 
        moaAgentUser = TestDataFactory_User_Wrapper.generateAgentUser('A1234', 'ABCD5678901');
        moaAgentUser.UserExternalId__c = 'ABCD5678901_ABCD5678901';
        moaAgentUser.Servicing_Agent_Associate_ID__c = 'ABCD5678901';
        moaATMUser = TestDataFactory_User_Wrapper.generateAgentTeamMemberUser('ATM1234', 'ATM5678901');
        moaATMUser.UserExternalId__c = 'ATM5678901_ATM5678901';
        moaATMUser.Servicing_Agent_Associate_ID__c = 'ATM5678901';
        
        noAccessUser =  new User(alias = 'SYSA', email='noaccessTest@statefarm.com.bad', 
                                 emailencodingkey='UTF-8', lastname='TestSysRecOwner', languagelocalekey='en_US', 
                                 localesidkey='en_US', timezonesidkey='America/Chicago', username= 'sysAccRecOwner@test.com');
        noAccessUser.ProfileId = [select Id from Profile where name = '1.02 No Access' LIMIT 1].Id;
        
        insert new List<User>{moaAgentUser, moaATMUser, noAccessUser};
            
        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(true, moaAgentUser);
        insert passTriggerAll;
        
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(moaAgentUser);
        objectBasedByPassTrigger.Override_CustomerGroupBeforeInsert__c = true;
        insert objectBasedByPassTrigger;   
        
        CS001_ByPassTriggerAll__c passTriggerAllNoAccess = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(true, noAccessUser);
        insert passTriggerAllNoAccess;

        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{moaAgentUser, moaATMUser});

    }

    @isTest
    static void testCreateTrackerRecordAgent(){
        Test.startTest();
        setupMOA();
        System.runAs(moaAgentUser) {
            
            String result = LightningUsageTrackerController.createTrackerRecord('Test Welcome Mat link');
            System.assertEquals('SUCCESS', result,'Tracker is not created');
            Test.stopTest();
        }
    }
    
    @isTest
    static void testCreateTrackerRecordATM(){
        Test.startTest();
        setupMOA();
        System.runAs(moaATMUser) {
            String result = LightningUsageTrackerController.createTrackerRecord('Test Welcome Mat link');
            System.assertEquals('SUCCESS', result,'Tracker is not created');
            Test.stopTest();
        }
    }
    
    @isTest
    static void testCreateTrackerRecordException(){
        Test.startTest();
        setupMOA();
        System.runAs(moaAgentUser) {
            String result = LightningUsageTrackerController.createTrackerRecord(null);    
            System.assertNotEquals('FAILURE', result,'null check failed');
    	}
        Test.stopTest();
    }
}