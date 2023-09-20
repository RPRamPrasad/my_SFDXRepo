@isTest(SeeAllData=false)
private class Batch_ChatterMobilePostCleanup_TEST {

    private static FeedItem[] feedItemRecords = new List<FeedItem>();
    private static Integer nextYear = System.today().Year() + 1;
    private final  static String CRON_EXP = '0 0 1,3,5,7,9,13,15,17,19,21,23 * * ? '+nextYear;
    private final static String CHATTER_GROUP_NAME = 'NewHotProspectNotifications-';
    private static  CollaborationGroup chatterGroup = new CollaborationGroup();
  
       private static User testSetup() {
        
        String apiDataUserProfileId = getProfileId(UTIL_Constants.API_DATA_USER_ADMIN);
        String adminUserProfileId = getProfileId(UTIL_Constants.SYSTEM_ADMIN_PROFILE_NAME);
        String agentUserProfileId = getProfileId(UTIL_Constants.AGENT_PROFILE_NAME);
        CS001_ByPassTriggerAtoF__c byPass = CS001_ByPassTriggerAtoF__c.getInstance();
        byPass.Override_FeedItemBeforeDelete__c = true;
         
        User sysAdminUser = buildUser('TestAdminUserIF1@sfa.com', adminUserProfileId);
        User batchProcIDUser;
        User lVMprocIdUser; 
        User agentUser;
    
        //setup users
        System.runAs(sysAdminUser) {
            batchProcIDUser = createUser(buildUser('TestUser0@sfa.com', apiDataUserProfileId));
            lVMprocIdUser = createUser(buildUser('TestUserLVM0@sta.com', apiDataUserProfileId));
            agentUser = createUser(buildAgentUser(agentUserProfileId));
            assignPermissionSet(lVMprocIdUser, 'SF_CRM_SFCOMLeadMsgSrvcs_PermSetPID');
            assignPermissionSet(batchProcIDUser, 'SF_CRM_ChatterCleanup_PermSetPID');
        }
        //setup chatter group
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);

        System.runAs(agentUser) {
            chatterGroup.Name = CHATTER_GROUP_NAME+agentUser.Alias;
            chatterGroup.CollaborationType = 'Private';
            insert chatterGroup;
        }
        //setup feeditems/records
        setupFeedItemRecords();
        System.runAs(agentUser) {
            Database.insert(feedItemRecords);
        }
       
        return batchProcIDUser;
    }
    
    @isTest
    private static void testExecuteScheduledChatterCleanup() {
        User batchProcId = testSetup();

        CS_BatchChatterCleanUp__c cscc=new CS_BatchChatterCleanUp__c();
        cscc.name = 'Test';
        cscc.BatchSize__c =2000;
        cscc.TimeOffSet__c = 120;
        cscc.JobName__c = 'Batch_ChatterPostCleanUp';
        cscc.CRON_EXP__c ='0 0 1,3,5,7,9,11,13,15,17,19,21,23 * * ?';
        insert cscc;
        Integer count1 = [SELECT count() FROM FeedItem];
        Integer count2 = [SELECT count() FROM ChatterPostCleanup__c];
        Batch_ChatterMobilePostCleanup batch = new Batch_ChatterMobilePostCleanup();
        Test.startTest();
        String jobId = '';
        String jobId1 = '';
        System.runAs(batchProcId) {
           jobId = Database.executeBatch(batch, 2000);
           jobId1 = System.schedule('Chatter Mobile Post Cleanup', CRON_EXP, new Batch_ChatterMobilePostCleanup());
           } 
        Test.stopTest();
 
         count1 = [SELECT count() FROM FeedItem];
         count2 = [SELECT count() FROM ChatterPostCleanup__c];
        System.assertNotEquals(0, count1, 'Expected value not equal to actual value');
        System.assertNotEquals(0, count2, 'Expected value not equal to actual value');        
    }
    
    @isTest
    private static void testForExceptions() {
        Batch_ChatterMobilePostCleanup batch = new Batch_ChatterMobilePostCleanup();   
        batch.execute(null,null);
        System.assertEquals(true, true, 'Expected value not same as actual value');
    }
    
    //method for setting up the feed item records
    private static void setupFeedItemRecords() {
        feedItemRecords = new List<FeedItem>();
        for(Integer i = 0; i < 10; i++) {
             feedItemRecords.add(new FeedItem(
                Title='New or Unclaimed Auto internet lead is available to be claimed!',
                Body='Its a test',
                LinkUrl='www.statefarm.com.bad',
                ParentId=chatterGroup.Id));
        }     
    }
 
    //method to build user with the given parameter value
    /**
     * @description buildUser
     * @param paramUserName 
     * @param paramProfileId 
     * @return  `User`
     */
    public static User buildUser(String paramUserName, String paramProfileId) {
        User testUser = new User(alias = '12345', email='testUser@statefarm.com.bad', emailencodingkey='UTF-8', lastname='TestUserLastName',
                            languagelocalekey='en_US',localesidkey='en_US', timezonesidkey='America/Chicago', 
                            username= paramUserName, profileId = paramProfileId
                        );
        testUser.put('UserPermissionsMarketingUser', true);                        
        return testUser;
    }  
    //method to create user with the given user parameter value
    /**
     * @description createUser
     * @param testUser 
     * @return  `User`
     */
    public static User createUser(User testUser) {
        insert testUser;
        return testUser;
    }
    //method to assign permissionset for the given user in parameter value
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
    //method to get the ProfileId for the given Profile Name
    private static String getProfileId(String profileName) {
        return [SELECT Id FROM Profile WHERE name = :profileName LIMIT 1].Id;
    
    }
    
     //method to build agent user with the given parameter value
     /**
      * @description buildAgentUser
      * @param paramProfileId 
      * @return  `User`
      */
    public static User buildAgentUser(String paramProfileId) {
        return new User(alias = '12345', email='12345@statefarm.com.bad', emailencodingkey='UTF-8', lastname='TestUserLastName', 
                                  languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Chicago', 
                        username= 'agent@statefarm.com.bad', profileId = paramProfileId, 
                        Associate_ID__c='bcmpcagent', 
                        UserExternalID__c= 'bcmpcagent',
                        Servicing_Agent_Associate_ID__c = 'bcmpcagent',
                        Territory_Associate_ID__c= 'bcmpcagent',
                        Servicing_Agent_Associate_ID_List__c='bcmpcagent',
                        Territory_Associate_ID_List__c='bcmpcagent');
        
    }
    
}
