@isTest
public class AP_OpportunityKillProcess_Test {

    private static User sysAdminuser;
    public static User agentUser;
    public static User bankUser;
    private static User systemUser;
    private static User proxyUser;
    private static UserRole agentStandardUserRole;
    private static UserRole proxyStandardUserRole;
    private static UserRole agentTeamMemberUserRole;
    private static Account testAccount;
    private static  User procIDUser;
    public static User atmUser;
    private static Map<String, Schema.Recordtypeinfo> opportunityRecordTypeMap = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName();
    
    @TestSetup
    private static void setUpUserData() {
          UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
         
        User sysAdminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'sysAdm'+UTIL_TestUsername_TEST.getTestUsername());
          insert sysAdminUser;
        System.runAs(sysAdminUser) {
            UserRole agentUserRole = new UserRole(name = 'AgentRole');                    
            insert agentUserRole;

            UserRole  proxyUserRole = new UserRole(name='ProxyRole', parentRoleId = agentUserRole.id);
            insert proxyUserRole;
            User testProxyUser1 = new User(Alias='Prox',LastName='prefAgnt',Username='PrxPrf'+UTIL_TestUsername_TEST.getTestUsername(),UserExternalID__c='10ccww22zzcP',Servicing_Agent_Associate_ID__c='10ccww22zzc');
            User proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;
            User testAgentUser1 = new User(Alias='Alia',LastName='prefPrxy',Username='AgtPrf'+UTIL_TestUsername_TEST.getTestUsername(),Associate_ID__c='10ccww22zzc',UserExternalID__c='10ccww22zzc_10ccww22zzc',Servicing_Agent_Associate_ID__c='10ccww22zzc');
            User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
            agentUser.userRoleId= agentUserRole.id;
            insert agentUser;
            User testBankAffiliateUser = new User(Alias='BAlia',LastName='bankUser',Username='bankUser'+UTIL_TestUsername_TEST.getTestUsername(),Associate_ID__c='10ccww22zzb',UserExternalID__c='10ccww22zzb_10ccww22zzb');
            User bankUser = UTIL_UserProvisioning_TEST.buildBankAffiliateUser(testBankAffiliateUser);
            bankUser.userRoleId= agentUserRole.id;
            insert bankUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser,bankUser});
            insert new PermissionSetAssignment(AssigneeId=agentUser.Id, PermissionSetId=[SELECT Id FROM PermissionSet WHERE Name = 'SF_CRM_Opportunity_DNSh_W_PermSet'].Id);

            insert new PermissionSetAssignment(AssigneeId=bankUser.Id, PermissionSetId=[SELECT Id FROM PermissionSet WHERE Name = 'Activities_DNSh_W'].Id);
            insert new PermissionSetAssignment(AssigneeId=bankUser.Id, PermissionSetId=[SELECT Id FROM PermissionSet WHERE Name = 'SF_CRM_Opportunity_DNSh_W_PermSet'].Id);
            
            Account act = buildAccountRecord('WCMGF8RBPXA');
            TestDataFactory_Account.byPassAccountBeforeTrigger();
            insert act;
        }

    }
    private static Account buildAccountRecord(String paramclientIdentifier) {
        return new Account(FirstName = 'rrrrr', LastName = 'tttttttt', ClientIdentifier__c = paramclientIdentifier);
        
    }
    private static AgentRole__c buildAgentRoleRecord(String paramaccountId, String agentId) {
        return new AgentRole__c (RelationshipNature__c = 'Customer',
                                                   Agent__c = agentId, Customer__c = paramaccountId);
        
    }

    /**
     * @description getProfileId
     * @param profileName 
     * @return  `String`
     */
    public static String getProfileId(String profileName) {
        return [SELECT Id FROM Profile WHERE name = :profileName LIMIT 1].Id;
        
    }

    /**
     * @description buildUser
     * @param paramUserName 
     * @param paramprofileId 
     * @return  `User`
     */
    public static User buildUser(String paramUserName, String paramprofileId) {
        return new User(alias = '12345', email='testUser@statefarm.com.bad', emailencodingkey='UTF-8', lastname='TestUserLastName',
                                 languagelocalekey='en_US',localesidkey='en_US', timezonesidkey='America/Chicago', 
                                 username= paramUserName, profileId = paramprofileId
                                );
        
        
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
    
    /**
     * @description insertoppOpportunityData
     * @param ownerIdd 
     * @param agentId 
     * @return  `Opportunity`
     */
    public static Opportunity insertoppOpportunityData(String ownerIdd, String agentId){
        Opportunity opp = new Opportunity();
        opp.AccountId = testAccount.Id;
        opp.LOB__c = 'Auto';             
        opp.OwnerId = ownerIdd;
        opp.StageName='New';
        opp.name = 'Testabc';
        opp.CloseDate = System.today()+60;
        opp.Assigned_To__c=agentId;
        opp.RecordTypeId = opportunityRecordTypeMap.get('Opportunity Management').RecordTypeId;             
        insert opp;
        return opp;
    }
    
    @isTest
    public static void testKilltaskSwitchWhenCustomSettingsPresentForBankProfileWithOppPermission() {
        bankUser = [Select Id from User where UserExternalId__c = '10ccww22zzb_10ccww22zzb' LIMIT 1];
        agentUser = [Select Id from User where UserExternalId__c = '10ccww22zzc_10ccww22zzc' LIMIT 1];
        proxyUser = [Select Id from User where UserExternalId__c = '10ccww22zzcP' LIMIT 1];
        testAccount = [select id,clientidentifier__c from account where ClientIdentifier__c='WCMGF8RBPXA'];
        Opportunity opp = insertoppOpportunityData(proxyUser.Id, agentUser.id);
        System.runAs(agentUser) {
        	UTIL_TaskDAO.insertTasks(new List<Task>{new Task(Subject = 'Test', Status = 'In Progress', TaskCategory__c = 'Prospecting Plan',WhatId = opp.Id)});
        }
        insert new TaskUpdateProfileAccess__c(Name='Test Setting',Profile_Name__c = '6.03 Bank Affiliate',Permissionset_Name__c = 'SF_CRM_Opportunity_Standard_W_PermSet',Is_Task_Editable__c=false,Is_Opp_Editable__c=true);
        Test.startTest();
        System.runAs(bankUser) {
            opp.StageName  = 'App Submitted';
            update opp;
        }
        Test.stopTest();
        Task task = [SELECT Id, Status FROM Task WHERE WhatId =: opp.Id LIMIT 1];
        System.assertEquals('In Progress', task.Status,'Expected is not same as actual');
    }
    
    @isTest
    public static void testKillSwitchWhenCustomSettingsPresentForBankProfile() {
        agentUser = [Select Id from User where UserExternalId__c = '10ccww22zzc_10ccww22zzc' LIMIT 1];
        bankUser = [Select Id from User where UserExternalId__c = '10ccww22zzb_10ccww22zzb' LIMIT 1];
        proxyUser = [Select Id from User where UserExternalId__c = '10ccww22zzcP' LIMIT 1];
        testAccount = [select id,clientidentifier__c from account where ClientIdentifier__c='WCMGF8RBPXA'];
        Opportunity opp = insertoppOpportunityData(proxyUser.Id, agentUser.id);
        System.runAs(agentUser) {
        	UTIL_TaskDAO.insertTasks(new List<Task>{new Task(Subject = 'Test', Status = 'In Progress', TaskCategory__c = 'Prospecting Plan',WhatId = opp.Id)});
        }
        insert new TaskUpdateProfileAccess__c(Name='Test Setting',Profile_Name__c = '6.03 Bank Affiliate',Permissionset_Name__c = 'Activities_DNSh_W',Is_Task_Editable__c=true,Is_Opp_Editable__c=false);
        insert new TaskUpdateProfileAccess__c(Name='Test Setting',Profile_Name__c = '6.03 Bank Affiliate',Permissionset_Name__c = 'SF_CRM_Opportunity_DNSh_W_PermSet',Is_Task_Editable__c=false,Is_Opp_Editable__c=true);
        Test.startTest();
        System.runAs(bankUser) {
            opp.StageName  = 'App Submitted';
            update opp;
        }
        Test.stopTest();
        Task task = [SELECT Id, Status FROM Task where whatId = :opp.Id LIMIT 1];
        System.assertEquals('Cancelled', task.Status,'Expected is not same as actual');
    }
    
    @isTest
    public static void testKillSwitchWhenCustomSettingsPresentForBankProfileWithOppPermission() {
        bankUser = [Select Id from User where UserExternalId__c = '10ccww22zzb_10ccww22zzb' LIMIT 1];
        agentUser = [Select Id from User where UserExternalId__c = '10ccww22zzc_10ccww22zzc' LIMIT 1];
        proxyUser = [Select Id from User where UserExternalId__c = '10ccww22zzcP' LIMIT 1];
        testAccount = [select id,clientidentifier__c from account where ClientIdentifier__c='WCMGF8RBPXA'];
        Opportunity opp = insertoppOpportunityData(proxyUser.Id, agentUser.id);
        System.runAs(agentUser) {
        	UTIL_TaskDAO.insertTasks(new List<Task>{new Task(Subject = 'Test', Status = 'In Progress', TaskCategory__c = 'Prospecting Plan',WhatId = opp.Id)});
        }
        insert new TaskUpdateProfileAccess__c(Name='Test Setting',Profile_Name__c = '6.03 Bank Affiliate',Permissionset_Name__c = 'SF_CRM_Opportunity_DNSh_W_PermSet',Is_Task_Editable__c=false,Is_Opp_Editable__c=true);
        Test.startTest();
        List<Id> oppIdToUpdateTaskList = new List<Id>();
        oppIdToUpdateTaskList.add(opp.Id);
        System.runAs(agentUser){
            AP_OpportunityKillProcess.updateTaskStatusToCancelled(oppIdToUpdateTaskList);
        }
        Test.stopTest();
        Task task = [SELECT Id, Status FROM Task LIMIT 1];
        System.assertEquals('Cancelled', task.Status,'Expected is not same as actual');
    }
    
}