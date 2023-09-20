@isTest(seeAllData = false)
public class WelcomeMatController_Test {
    private static User sysAdminUser {get;set;}
    private static User moaAgentUser {get;set;}
    private static User moaATMUser {get;set;}
    private static User noAccessUser {get;set;}
    
    /**
     * @description testUsersSetup
     */
    @testsetup
    public static void testUsersSetup() {  
        UTIL_CaseTestData.setUpUsersForCase();
        
        User sysAdminUser = UTIL_CaseTestData.getSysAdminUser();
        System.runAs(sysAdminUser){    
            UTIL_CaseTestData.createAccountWithOneActiveAgentRole();
        }
    }    
       
    private static void setupMOA() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        moaAgentUser = TestDataFactory_User_Wrapper.generateAgentUser('A1234', 'ABCD5678901');
        moaAgentUser.UserExternalId__c = 'ABCD5678901_ABCD5678901';
        moaAgentUser.Servicing_Agent_Associate_ID__c = 'ABCD5678901';
        moaAgentUser.WelcomeMatViewed__c = false;
        moaATMUser = TestDataFactory_User_Wrapper.generateAgentTeamMemberUser('ATM1234', 'ATM5678901');
        moaATMUser.UserExternalId__c = 'ATM5678901_ATM5678901';
        moaATMUser.WelcomeMatViewed__c = true;
        
        moaATMUser.Servicing_Agent_Associate_ID__c = 'ATM5678901';
        noAccessUser =  new User(alias = 'SYSA', email='noaccessTest@statefarm.com.bad', 
                                 emailencodingkey='UTF-8', lastname='TestSysRecOwner', languagelocalekey='en_US', 
                                 localesidkey='en_US', timezonesidkey='America/Chicago', username= 'sysAccRecOwner@test.com');
        noAccessUser.ProfileId = [select Id from Profile where name = '1.02 No Access' LIMIT 1].Id;
        
        insert new List<User>{moaAgentUser,moaATMUser,noAccessUser};
        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(true, moaAgentUser);
        insert passTriggerAll;
        
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(moaAgentUser);
        objectBasedByPassTrigger.Override_CustomerGroupBeforeInsert__c = true;
        insert objectBasedByPassTrigger;   
        
        CS001_ByPassTriggerAll__c passTriggerAllNoAccess = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(true, noAccessUser);
        insert passTriggerAllNoAccess;
        
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{moaAgentUser, moaATMUser});
        
    }
    
    private static WelcomeMat__c setUpWelcomeMatData(){
        WelcomeMat__c wm = new WelcomeMat__c();
        wm.Welcome_Mat_Title__c = 'ECRM Learning';
        wm.WelcomeMatDescription__c = 'A comprehensive location of all things ECRM';
        wm.WelcomeMat_Icon__c = 'standard:knowledge';
        wm.WelcomeMat_Section_Link__c = 'testLink';
        wm.WelcomeMat_Section_Number__c = 1 ;
        wm.WelcomeMat_TileToOpenInTab__c = true;
        wm.WelcomeMat_ReleaseNoteId__c = 'ka0290000005Me8AAE';
        return wm;
    }
    
    @isTest
    static void testWithAgentFetchWelcomeMatData(){
        Test.startTest();
        setupMOA();
        setUpWelcomeMatData();
        List<WelcomeMat__c> wmList = WelcomeMatController.fetchWelcomeMatData();
        System.runAs(moaAgentUser){
            for(WelcomeMat__c wm: wmList){
                System.assert(wm !=null, 'Welcome mat list records should not NULL');
                
            }
            
        }
        Test.stopTest();
    }

    @isTest
    static void testWithATMFetchWelcomeMatData(){
        Test.startTest();
        setupMOA();
        setUpWelcomeMatData();
        List<WelcomeMat__c> wmList = WelcomeMatController.fetchWelcomeMatData();
        System.runAs(moaATMUser){
            for(WelcomeMat__c wm: wmList){
                System.assert(wm !=null, 'Welcome mat list records should not NULL');
                
            }
            
        }
        Test.stopTest();
    } 
    
    @isTest
    static void testCurrentUserProfileWelcomeMatViewedTrue(){
        Test.startTest();
        setupMOA();
        boolean expectedResult = true;
        System.runAs(moaATMUser){
            Boolean welcomatMatViewed = WelcomeMatController.currentUserProfileWelcomeMatViewed();
            System.assertEquals(expectedResult, welcomatMatViewed, 'Welcome mat viewed is not matching up with data setup');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCurrentUserProfileWelcomeMatViewedTrueFalse(){
        Test.startTest();
        setupMOA();
        boolean expectedResult = false;
        System.runAs(moaAgentUser){
            Boolean welcomatMatViewed = WelcomeMatController.currentUserProfileWelcomeMatViewed();
            System.assertEquals(expectedResult, welcomatMatViewed, 'Welcome mat viewed is not matching up with data setup');
            
        }
        Test.stopTest();
    } 
    
    @isTest
    static void testUpdateUserProfileWelcomeMatViewedToTrue(){
        User agentUser = UTIL_CaseTestData.getAgentUser(); 
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        Test.startTest();
        boolean expectedResult = true;
        System.runAs(agentUser){
            WelcomeMatController.updateUserProfileWelcomeMatViewed(true);
            Boolean welcomatMatViewed = WelcomeMatController.currentUserProfileWelcomeMatViewed();
            System.assertEquals(expectedResult, welcomatMatViewed, 'Welcome mat viewed should be true');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetCurrentUserProfile(){
        User agentUser = UTIL_CaseTestData.getAgentUser(); 

        Test.startTest();
        String expectedResult = '2.00 Agent';
        System.runAs(agentUser){
            String agentProfileName = WelcomeMatController.currentUserProfile();
            System.assertEquals(expectedResult, agentProfileName, 'Welcome mat profile name not as expected');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateWelcomeMatViewedException() {
        User agentUser = UTIL_CaseTestData.getAgentUser(); 

        Test.startTest();
        DmlException expectedException;
        System.runAs(agentUser) {
            try {
                WelcomeMatController.updateUserProfileWelcomeMatViewed(null);
            } catch(DmlException dmx) {
                expectedException = dmx;
                System.Assert(expectedException.getMessage().contains('Exception'), 'Exception should be thrown here');
            }
       	}
        Test.stopTest();
    } 
}
