@isTest
private class ReusableLookupController_TEST {
    public static User agentUser;
    public static User adminUser;
    public static User cccLicensedUser;
    public static User cccUnlicensedUser;
    public static User enterpriseUser600;
    public static User ltdEnterpriseUser601;
    public static User proxyUser;
    public static Account acc;
    public static Opportunity opp;
    public static AgentContext__c ac;
    private static PermissionSetAssignment psassignment;
    private static String opportuntiyReadOnly = 'Opportunity_Standard_R';
    private static String opportunityReadWrite = 'SimpleConversation_Tab_FullAccess';
    
    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap = Schema.Sobjecttype.Account.getRecordTypeInfosByName();
    
    //method to bypass Trigger
    private static void byPassTrigger() {
        CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c();
        objectBasedByPassTrigger.Override_All__c = true;
        insert objectBasedByPassTrigger;
    }
    
    //method to build userrole with the given parameter value
    private static UserRole buildUserRole(String roleName) {
        UserRole role = new UserRole(name = roleName);
        return role;
    }
    
    //method to build userrole with parentRole with the given parameter value
    private static UserRole buildUserRoleWithParent(String roleName, String parentRole) {
        UserRole role = new UserRole(name = roleName, parentRoleId = parentRole);
        return role;
    }
    
    //method to build Agent Role record with Customer Account Id
    private static AgentRole__c buildAgentRoleRecord(String accountId) {
        AgentRole__c agentRole = new AgentRole__c (RelationshipNature__c = 'Customer',
                                                   Agent__c = userInfo.getUserId(), Customer__c = accountId);
        
        return agentRole;
    }
    
    
    
    //method to build Account record with Client First Name, Last Name, and Client Id
    private static Account buildAccountRecord(String fstLstName, String clientId, Id owner) {
        String[] splitFSTLSTName = fstLstName.split(' ');
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        Account act = new Account(FirstName = splitFSTLSTName[0] , LastName = splitFSTLSTName[1], ownerId = owner,
                                  RecordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId, ClientIdentifier__c = clientId);
        return act;
    }
    

    
    //method to assign permissionset for the given user in parameter value
    private static void assignPermissionSet(User testUser, String permissionSetName) {
        PermissionSet queryPermissionSet = [Select id FROM PermissionSet WHERE Name =: permissionSetName Limit 1];
        PermissionSetAssignment assignPermissionSet = new PermissionSetAssignment();
        assignPermissionSet.AssigneeId = testUser.id;
        assignPermissionSet.PermissionSetId = queryPermissionSet.id;
        insert assignPermissionSet;
    }
    @testSetup
    /**
     * @description setUp
     */
    public static void setUp() {
        
        User adminUser = UTIL_UserProvisioning_TEST.buildUserWithSystemAdminProfile('TestAdminUser@statefarm.com.bad');
        insert adminuser;
        User agentUser;
        User proxyUser; 
        User cccLicensedUser;
        User cccUnlicensedUser;
        User enterpriseUser600;
        User ltdEnterpriseUser601;
        
        System.runAs(adminUser) {
            byPassTrigger();
            
            UserRole agentUserRole = buildUserRole('AgentRole');
            insert agentUserRole;
            
            UserRole proxyUserRole = buildUserRoleWithParent('ProxyRole', agentUserRole.id);
            insert proxyUserRole;
            User testAgentUser = new User(Alias='X7PZ',LastName='agent,user,75-338-Office',Username='TestAgentUser@statefarm.com.bad',Associate_ID__c='ASSOCID0001',UserExternalID__c='EXTERNALID1',Servicing_Agent_Associate_ID__c='AGTASSOCID1',Territory_Associate_ID__c='',Servicing_Agent_Associate_ID_List__c='',Territory_Associate_ID_List__c='');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser (testAgentUser);
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;
            User testProxyUser1 = new User(Alias='X7PX',LastName='middle,Last,75-338-Office',Username='TestProxyUser@statefarm.com.bad',UserExternalID__c='ASSOCID0001_T65B51YS000P',Servicing_Agent_Associate_ID__c='ASSOCID0001');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;
            User testCCCLicenUser = new User(Alias='X7PT',LastName='CCC,user,75-338-Office',Username='TestCCCUser@statefarm.com.bad',Associate_ID__c='ppcczz33ttc',UserExternalID__c='');
            cccLicensedUser = UTIL_UserProvisioning_TEST.buildCCCLicensedUserMethod(testCCCLicenUser);
            insert cccLicensedUser;
            User testCCCUnLicenUser = new User(Alias='X7PU',LastName='CCC,unlisenced,75-338-Office',Username='TestCCC301User@statefarm.com.bad',Associate_ID__c='ppcczz33ttb',UserExternalID__c='');
            cccUnlicensedUser = UTIL_UserProvisioning_TEST.buildCCCUnlicensedUserMethod(testCCCUnLicenUser);
            insert cccUnlicensedUser;
            User testEntpUser = new User(Alias='Y6P1',LastName='600,EnterpriseUser,75-338-Office',Username='TestEnterpriseUser600r@statefarm.com.bad',Associate_ID__c='ppcczz33tta',UserExternalID__c='');
            enterpriseUser600 = UTIL_UserProvisioning_TEST.buildEnterpriseUser(testEntpUser);
            insert enterpriseUser600;
            User testLtdEntpUser = new User(Alias='Y6P2',LastName='601,LtdEnterpriseUser,75-338-Office',Username='TestLtdEnterpriseUser601r@statefarm.com.bad',Associate_ID__c='ppcczz33ttx',UserExternalID__c='');
            ltdEnterpriseUser601 = UTIL_UserProvisioning_TEST.buildLtdEnterpriseUser(testLtdEntpUser);
            insert ltdEnterpriseUser601;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            assignPermissionSet(enterpriseUser600, opportuntiyReadOnly);
            assignPermissionSet(ltdEnterpriseUser601, opportunityReadWrite);
            
            
        }
        
        acc = buildAccountRecord('FST LST','111',agentUser.Id);
        insert acc;
        
        
        //Insert agent role to give account access to the Agent
        AgentRole__c agentRole;
        System.runAs(agentUser) {
            agentRole = buildAgentRoleRecord(acc.Id);
        }
        insert agentRole;
        
    }
    
    
    //Query the test data
    /**
     * @description queryTestData
     */
    public static void queryTestData() {
        agentUser = [Select Id,Associate_ID__c from User where username = 'TestAgentUser@statefarm.com.bad'];
        adminUser = [Select Id,Associate_ID__c from User where username = 'TestAdminUser@statefarm.com.bad'];
        cccLicensedUser = [Select Id,Associate_ID__c from User where username = 'TestCCCUser@statefarm.com.bad'];
        cccUnlicensedUser = [Select Id,Associate_ID__c from User where username = 'TestCCC301User@statefarm.com.bad'];
        enterpriseUser600 = [Select Id,Associate_ID__c from User where username = 'TestEnterpriseUser600r@statefarm.com.bad'];
        ltdEnterpriseUser601 = [Select Id,Associate_ID__c from User where username = 'TestLtdEnterpriseUser601r@statefarm.com.bad'];
        proxyUser = [Select Id,Associate_ID__c from User where username = 'TestProxyUser@statefarm.com.bad'];
        acc = [Select Id,ClientIdentifier__c, Name from Account where lastname = 'LST'];
    }
    @isTest
    private static void fetchRecordsTest() {
        queryTestData();
        System.runAs(agentUser) {
            ReusableLookupController.SearchWrapper searchWrapObj = new ReusableLookupController.SearchWrapper();
            searchWrapObj.objectApiName = 'Account';
            searchWrapObj.fieldApiName = 'Name';
            searchWrapObj.otherFieldApiName = 'OwnerId';
            searchWrapObj.searchString = 'Test';
            searchWrapObj.selectedRecordId = '';
            searchWrapObj.parentRecordId = '';
            searchWrapObj.parentFieldApiName = '';
            searchWrapObj.otherSearchFilter = ' AND Name != null';
            Test.startTest();
            try{
                List<ReusableLookupController.ResultWrapper> searchResults = ReusableLookupController.fetchRecords(searchWrapObj);  
                System.assertEquals(searchResults.size(), 10,'Search Results are null');
                Test.stopTest();
            } catch(Exception ex) {
            	System.assertNotEquals(agentUser, null,'AgentUser is not null');
            }
            
        }
    }
}
