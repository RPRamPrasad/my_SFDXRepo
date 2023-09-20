/****************************************************************************************
Name: HLPR_AutoCompleteJsonController_TEST
Copyright © State Farm
=========================================================================================
Purpose:
-------
Decription: Test class written for HLPR_AutoCompleteJsonController
Team: TrailBlazers
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Joseph Abell (EGDB) 	04/01/2018             Initial Development
******************************************************************************************/
/**
 * @description HLPR_AutoCompleteJsonController_TEST
 */
@isTest(SeeAllData = false)
public class HLPR_AutoCompleteJsonController_TEST {
    
    private static String agentProfileId = getProfileId(UTIL_Constants.AGENT_PROFILE_NAME);
    private static String proxyProfileId = getProfileId(UTIL_Constants.PROXY_PROFILE_NAME);
    private static String adminProfileId = getProfileId(UTIL_Constants.SYSTEM_ADMIN_PROFILE_NAME);
    
    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap = Schema.Sobjecttype.Account.getRecordTypeInfosByName();
    static User agentUser;
    static User adminUser;
    static Account acc; 
    /**
     * @description setUp
     */
    @testSetup
    public static void setUp() {
        
        BuildUserWrapper buildUserWrapper = new BuildUserWrapper();
        buildUserWrapper.associateId = ''; 
        buildUserWrapper.servicingAgentAssociateId = ''; 
        buildUserWrapper.externalId = '';
        User newAdminUser = buildUser('TestAdminUser@statefarm.com.bad', adminProfileId, buildUserWrapper);
        insert newAdminUser;
        
        User newAgentUser;
        
        System.runAs(newAdminUser) {
            byPassTrigger();
            
            UserRole agentUserRole = buildUserRole('AgentRole');
            insert agentUserRole;
            
            BuildUserWrapper buildWrapper = new BuildUserWrapper();
            buildWrapper.associateId = 'ASSOCID0001'; 
            buildWrapper.servicingAgentAssociateId = 'AGTASSOCID1'; 
            buildWrapper.externalId = 'EXTERNALID1';
            newAgentUser = buildUser('TestAgentUser@statefarm.com.bad', agentProfileId , buildWrapper);
            newAgentUser.userRoleId = agentUserRole.id;
            insert newAgentUser;
            
        }
    }
    /**
     * @description testConstructor
     */
    @isTest
    public static void testConstructor() {
        queryTestData();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            Test.startTest();
            Test.setCurrentPage(Page.VFP_AutoCompleteJson);
            Apexpages.currentPage().getParameters().put('q', 'test');
            Apexpages.currentPage().getParameters().put('obj', 'User');
            Apexpages.currentPage().getParameters().put('label', 'Email');
            Apexpages.currentPage().getParameters().put('detail', 'Email');
            ApexPages.currentPage().getParameters().put('lm', '5');
            Apexpages.currentPage().getParameters().put('value', 'Email' );
            
           	HLPR_AutoCompleteJsonController ctr = new HLPR_AutoCompleteJsonController();
    		System.assertNotEquals(null, ctr,'ctr should not be null');
            Test.stopTest();   
        }
    }
    /**
     * @description testSingleDetailAndLimit5
     */
    @isTest
    public static void testSingleDetailAndLimit5() {
        queryTestData();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            Test.startTest();
            Test.setCurrentPage(Page.VFP_AutoCompleteJson);
            Apexpages.currentPage().getParameters().put('q', 'test');
            Apexpages.currentPage().getParameters().put('obj', 'User');
            Apexpages.currentPage().getParameters().put('label', 'Email');
            Apexpages.currentPage().getParameters().put('detail', 'Email');
            ApexPages.currentPage().getParameters().put('lm', '5');
            Apexpages.currentPage().getParameters().put('value', 'Email' );
            
           	HLPR_AutoCompleteJsonController ctr = new HLPR_AutoCompleteJsonController();
            String result = ctr.getJson();
            List<String> results = result.split('\\}\\,\\{');
            System.assertEquals(5, results.size(),'Size of results should be 5');
            Test.stopTest();   
        }
    }
    /**
     * @description testNoLimitProvided
     */
    @isTest
    public static void testNoLimitProvided() {
        queryTestData();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            Test.startTest();
            Test.setCurrentPage(Page.VFP_AutoCompleteJson);
            Apexpages.currentPage().getParameters().put('q', 'test');
            Apexpages.currentPage().getParameters().put('obj', 'User');
            Apexpages.currentPage().getParameters().put('label', 'Email');
            Apexpages.currentPage().getParameters().put('detail', 'Email');
            ApexPages.currentPage().getParameters().put('lm', '');
            Apexpages.currentPage().getParameters().put('value', 'Email' );
            
           	HLPR_AutoCompleteJsonController ctr = new HLPR_AutoCompleteJsonController();
            String result = ctr.getJson();
            List<String> results = result.split('\\}\\,\\{');
            System.assertEquals(10, results.size(),'Size of results should be 10');
            Test.stopTest();   
        }
    }
    /**
     * @description testMultipleDetails
     */
    @isTest
    public static void testMultipleDetails() {
        queryTestData();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            Test.startTest();
            Test.setCurrentPage(Page.VFP_AutoCompleteJson);
            Apexpages.currentPage().getParameters().put('q', 'TestAgentUser@statefarm.com.bad');
            Apexpages.currentPage().getParameters().put('obj', 'User');
            Apexpages.currentPage().getParameters().put('label', 'Email');
            Apexpages.currentPage().getParameters().put('detail', 'Email,Associate_ID__c');
            ApexPages.currentPage().getParameters().put('lm', '');
            Apexpages.currentPage().getParameters().put('value', 'Email' );
            
           	HLPR_AutoCompleteJsonController ctr = new HLPR_AutoCompleteJsonController();
            String result = ctr.getJson();
            System.assert(result.contains('testagentuser@statefarm.com.bad, ASSOCID0001'), 'result should contain \'testagentuser@statefarm.com.bad, ASSOCID0001\'');
            Test.stopTest();   
        }
    }
    /**
     * @description testNoResultsWithSuggestions
     */
    @isTest
    public static void testNoResultsWithSuggestions() {
        queryTestData();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            Test.startTest();
            Test.setCurrentPage(Page.VFP_AutoCompleteJson);
            Apexpages.currentPage().getParameters().put('q', 'xxxxxxxxxxxxxxxxxxxxxxxxxxx');
            Apexpages.currentPage().getParameters().put('obj', 'User');
            Apexpages.currentPage().getParameters().put('label', 'Email');
            Apexpages.currentPage().getParameters().put('detail', 'Email');
            ApexPages.currentPage().getParameters().put('lm', '');
            Apexpages.currentPage().getParameters().put('value', 'Email' );
            
           	HLPR_AutoCompleteJsonController ctr = new HLPR_AutoCompleteJsonController();
            String result = ctr.getJson();
            System.assert(result.contains('No results found for xxxxxxxxxxxxxxxxxxxxxxxxxxx'), 'result should contain \'No results found for xxxxxxxxxxxxxxxxxxxxxxxxxxx\'');
            System.assert(result.contains('Suggestions'), 'result should contain \'Suggestions\'');
            Test.stopTest();   
        }
    }
    /**
     * @description testNoResults
     */
    @isTest
    public static void testNoResults() {
        queryTestData();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            Test.startTest();
            Test.setCurrentPage(Page.VFP_AutoCompleteJson);
            Apexpages.currentPage().getParameters().put('q', '????');
            Apexpages.currentPage().getParameters().put('obj', 'User');
            Apexpages.currentPage().getParameters().put('label', 'Email');
            Apexpages.currentPage().getParameters().put('detail', 'Email');
            ApexPages.currentPage().getParameters().put('lm', '');
            Apexpages.currentPage().getParameters().put('value', 'Email' );
            
           	HLPR_AutoCompleteJsonController ctr = new HLPR_AutoCompleteJsonController();
            String result = ctr.getJson();
            System.assert(result.contains('No results found for ????'), 'result should contain \'No results found for ????\'');
            System.assert(!result.contains('Suggestions'), 'result should not contain \'Suggestions\'');
            Test.stopTest();   
        }
    }
    /**
     * @description createAccount
     * @param clientIdentifier
     * @return Account
     */
    //method to build Account record with the given clientID
    public static Account createAccount(String clientIdentifier){
        return new Account(FirstName = 'tst1', LastName='Ltst'+clientIdentifier, ClientIdentifier__c  = clientIdentifier);
    }
    
    //method to get the ProfileId for the given Profile Name
    private static String getProfileId(String profileName) {
        return [SELECT Id FROM Profile WHERE name = :profileName LIMIT 1].Id;
    }
    
    private class BuildUserWrapper{
        String associateId; 
        String servicingAgentAssociateId; 
        String externalId;
    }

    //method to build user with the given parameter value
    private static User buildUser(String userName, String profileId, BuildUserWrapper buildWrap) {
        return new User (alias = 'XXXX', email = userName, emailencodingkey='UTF-8', lastname=userName.substringBefore('@'),
        languagelocalekey='en_US',localesidkey='en_US', timezonesidkey='America/Chicago', 
        username= userName, profileId = profileId, Associate_ID__c = buildWrap.associateId, 
        Servicing_Agent_Associate_ID__c = buildWrap.servicingAgentAssociateId, UserExternalID__c = buildWrap.externalId);
    }
    
    //method to bypass Trigger
    private static void byPassTrigger() {
        CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c();
        objectBasedByPassTrigger.Override_All__c = true;
        insert objectBasedByPassTrigger;
    }
    
    //method to build User Role with the given parameter value
    private static UserRole buildUserRole(String roleName) {
        return new UserRole(name = roleName);
    }
    
    //method to build User Role with parentRoleId as the given parameter value
    private static UserRole buildUserRole(String roleName, String parentRoleId) {
        return new UserRole(name = roleName, parentRoleId = parentRoleId);
    }
    /**
     * @description queryTestData
     */
    //Query the test data
    public static void queryTestData(){
        agentUser = [Select Id from User where username = 'TestAgentUser@statefarm.com.bad'];
        adminUser = [Select Id from User where username = 'TestAdminUser@statefarm.com.bad'];
    }
    
}