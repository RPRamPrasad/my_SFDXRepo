@isTest(seeAllData = false)
public class SCH_UpdateOppStageManagement_Test {
 	private static User sysAdminuser;
    public static User agentUser;
    private static User systemUser;
    private static User proxyUser;
    private static UserRole agentStandardUserRole;
    private static UserRole proxyStandardUserRole;
    private static UserRole agentTeamMemberUserRole;
    private static Account testAccount;
    public static String cronExp = '0 5 * * * ?';
    private static final String SYSADMIN_USER_ID = UTIL_TestUsername_TEST.getTestUsername('sysadmin');
    private static final String USER_PROVISIONING_PROC_ID = UTIL_TestUsername_TEST.getTestUsername('batch');
    private static  User procIDUser;

    /**
     * @description testSetUpData
     */
    @TestSetup
    public static void testSetUpData(){
         String apiDataUserProfileId = getProfileId(UTIL_Constants.API_DATA_USER_ADMIN);
        systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();  
        insert systemUser;
        sysAdminuser= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert sysAdminuser;
       CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c(Override_All__c= false);
        insert objectBasedByPassTrigger;
        CS001_ByPassTriggerAtoF__c accountByPassTrigger= new CS001_ByPassTriggerAtoF__c(Override_AccountBeforeInsert__c=false,Override_AgentRoleAfterInsert__c=false);
        insert accountByPassTrigger;
        insertAgentOfficeIntJobTracker();
        
        System.runAs(sysAdminUser){
            procIDUser = createUser(buildUser('TestUser6@sfa.com', apiDataUserProfileId));
            assignPermissionSet(procIDUser, 'SF_CRM_OpportunityAutoClose_PermSetPID');
            agentStandardUserRole= new UserRole(name='AgentRole');                    
            insert agentStandardUserRole;
            agentTeamMemberUserRole = new UserRole(name= 'AgentTeamMemberRole', parentRoleId = agentStandardUserRole.id);
            insert agentTeamMemberUserRole;
         proxyStandardUserRole = new UserRole(name='ProxyRole', parentRoleId = agentTeamMemberUserRole.id);
            insert proxyStandardUserRole;
            User testProxyUser1 = new User(Alias='Prox',LastName='opportunityAg',Username='TestProxUserForOppTst11@statefarm.com',UserExternalID__c='123testP',Servicing_Agent_Associate_ID__c='123test');
         proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId= proxyStandardUserRole.id;
            Database.insert(proxyUser);
            User testAgentUser1 = new User(Alias='Alia',LastName='opportunityProxy',Username='TestAgtUserForOppTst11@statefarm.com',Associate_ID__c='123test',UserExternalID__c='123test',Servicing_Agent_Associate_ID__c='123test');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
            agentUser.userRoleId= agentStandardUserRole.id;

            Database.insert(agentUser);
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);

            TestDataFactory_Account.byPassAccountBeforeTrigger();
            TestDataFactory_Opportunity.byPassOpportunityBeforeTrigger();  
             System.runAs(agentUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            Account act = buildAccountRecord('WCMGF8RBPXA');
            TestDataFactory_Account.byPassAccountBeforeTrigger();
            insert act;            
        }
        testAccount = [select id, ownerId from Account where CreatedbyId =:agentUser.id];            
        AgentRole__c newAgentRole = buildAgentRoleRecord(testAccount.id,agentUser.id );
        insert newAgentRole; 
        }
        
    }
    
    /**
     * @description testRunJob
     */
    @isTest
    public static void testRunJob(){
        procIDUser = [select id from user where alias = '12345' limit 1];
        agentUser = [select id from user where alias = 'Alia' limit 1];
        testAccount = [select id from account where ClientIdentifier__c='WCMGF8RBPXA'];               
        insert new CS_AutoCloseBatch__c(NumberOfThreads__c = 2000, Name = 'Test',DaysToLookBackForIPData__c=3,AgreementStatus__c = 'In Force',BatchEmailRecipient__c='home.sys-sfdctestexception.773h00@statefarm.com');
        SCH_UpdateOppStageManagement schUP = new SCH_UpdateOppStageManagement();
        System.runAs(procIDUser){ 
            Test.startTest();
            
            String jobId = System.schedule('Update Opportunity if Agreement is established', cronExp, schUP);
            // Verify job is scheduled
            CronTrigger ct = [SELECT TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobID];
            Assert.isNotNull(ct.NextFireTime);
            Test.stopTest();
        }
    }
    private static void insertAgentOfficeIntJobTracker(){
        AgentOffice_Integration_Job_Tracker__c aijt = new AgentOffice_Integration_Job_Tracker__c();
        aijt.ExtractedTillDate__c = Date.newInstance(2019, 09, 11);
        aijt.Name = 'AutoCloseJob';
        aijt.Increment__c=720;
        aijt.IncrementPeriod__c='MINUTE';
        aijt.IsIncremental__c=true;
        aijt.ObjectName__c='Opportunity';
        aijt.fileNamePrefix__c='csv';
        insert aijt;
    }
     private static Account buildAccountRecord(String clientId) {
        Account act = new Account(FirstName = 'rrrrr', LastName = 'tttttttt', ClientIdentifier__c = clientId);
        return act;
    }
     private static AgentRole__c buildAgentRoleRecord(String accountId, String agentId) {
        AgentRole__c agentRole = new AgentRole__c (RelationshipNature__c = 'Customer',
                       Agent__c = agentId, Customer__c = accountId);
        return agentRole;
    }

    /**
     * @description getProfileId
     * @param profileName 
     * @return  `String`
     */
     public static String getProfileId(String profileName) {
        String profileId = [SELECT Id FROM Profile WHERE name = :profileName LIMIT 1].Id;
        return profileId;
    }

    /**
     * @description buildUser
     * @param userName 
     * @param profileId 
     * @return  `User`
     */
    public static User buildUser(String userName, String profileId) {
        User testUser = new User(alias = '12345', email='testUser@statefarm.com.bad', emailencodingkey='UTF-8', lastname='TestUserLastName',
                            languagelocalekey='en_US',localesidkey='en_US', timezonesidkey='America/Chicago', 
                            username= userName, profileId = profileId
                        );
        
        return testUser;
    }

    /**
     * @description createUser
     * @param testUser 
     * @return  `User`
     */
    public static User createUser(User testUser) {
        insert testUser;
        return testUser;
    }

    /**
     * @description assignPermissionSet
     * @param testUser 
     * @param permissionSetName 
     */
    public static void assignPermissionSet(User testUser, String permissionSetName) {
        PermissionSet queryPermissionSet = [Select id FROM PermissionSet WHERE Name =: permissionSetName Limit 1];
        PermissionSetAssignment assignPermissionSet = new PermissionSetAssignment();
        assignPermissionSet.AssigneeId = testUser.id;
        assignPermissionSet.PermissionSetId = queryPermissionSet.id;
        insert assignPermissionSet;
    }
}
