@isTest(SeeAllData=false)
private class SCH_ChatterMobilePostCleanup_TEST {
    
    private static ChatterPostCleanup__c[] cleanupRecords = new List<ChatterPostCleanup__c>();
    private static FeedItem[] feedItemRecords = new List<FeedItem>();
    private static Integer nextYear = System.today().Year() + 1;
    private static String cron_Exp = '0 0 1,3,5,7,9,13,15,17,19,21,23 * * ? '+nextYear;
    private static String chatter_Group_Name= 'NewHotProspectNotifications-';
    private static  CollaborationGroup chatterGroup = new CollaborationGroup();
    
    private static User testSetup() {
        
        String apiDataUserProfileId = getProfileId(UTIL_Constants.API_DATA_USER_ADMIN);
        String adminUserProfileId = getProfileId(UTIL_Constants.SYSTEM_ADMIN_PROFILE_NAME);
        String agentUserProfileId = getProfileId(UTIL_Constants.AGENT_PROFILE_NAME);
        
        User sysAdminUser = buildUser('TestAdminUserIF1@sfa.com', adminUserProfileId);
        User batchProcIDUser;
        User lVMprocIdUser; 
        User agentUser;
        
        //setup users
        System.runAs(sysAdminUser) {
            batchProcIDUser = createUser(buildUser('TestUser0@sfa.com', apiDataUserProfileId));
            lVMprocIdUser = createUser(buildUser('TestUserLVM0@sta.com', apiDataUserProfileId));
            agentUser = createUser(buildAgentUser('agent@statefarm.com.bad', agentUserProfileId, 'bcmpcagent', 'bcmpcagent', 'bcmpcagent', 'bcmpcagent', 'bcmpcagent', 'bcmpcagent'));
            assignPermissionSet(lVMprocIdUser, 'SF_CRM_SFCOMLeadMsgSrvcs_PermSetPID');
            assignPermissionSet(batchProcIDUser, 'SF_CRM_ChatterCleanup_PermSetPID');
        }
        //setup chatter group
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);

        System.runAs(agentUser) {
            chatterGroup.Name = chatter_Group_Name+agentUser.Alias;
            chatterGroup.CollaborationType = 'Private';
            insert chatterGroup;
        }
        //setup feeditems/records
        setupFeedItemRecords();
        System.runAs(lVMprocIdUser) {
            UTIL_FeedItemDAO.insertFeedItems(feedItemRecords);
        }
        return batchProcIDUser;
    }
    
    @isTest
    private static void testExecuteScheduledChatterCleanup() {
        User batchProcId = testSetup();
        Test.startTest();
        String jobId = '';
        CS_BatchChatterCleanUp__c cscc=new CS_BatchChatterCleanUp__c();
        cscc.name = 'Test';
        cscc.BatchSize__c =2000;
        cscc.TimeOffSet__c = 120;
        cscc.JobName__c = 'Batch_ChatterPostCleanUp';
        cscc.CRON_EXP__c ='0 0 1,3,5,7,9,11,13,15,17,19,21,23 * * ?';
        insert cscc;
        System.runAs(batchProcId) {
           jobId = System.schedule('SCH_ChatterPostCleanUp', cron_Exp, new SCH_ChatterMobilePostCleanup());
        } 
        CronTrigger cronTriggerTest = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId]; 
        Test.stopTest();
        
        System.assertEquals(cron_Exp, cronTriggerTest.CronExpression,'Expected value is '+cron_Exp+', but actual value is '+cronTriggerTest.CronExpression);
        System.assertEquals(0, cronTriggerTest.TimesTriggered,'Expected value is 0, but actual value is '+cronTriggerTest.TimesTriggered);
        System.assertEquals(nextYear+'-01-01 01:00:00',String.valueOf(cronTriggerTest.NextFireTime),'Expected value is '+nextYear+'-01-01 01:00:00, but actual value is '+String.valueOf(cronTriggerTest.NextFireTime)); 
    }
    
    //method for setting up the feed item records
    private static void setupFeedItemRecords() {
        for(Integer i = 0; i < 10; i++) {
             feedItemRecords.add(new FeedItem(
                 Title='New or Unclaimed Auto internet lead is available to be claimed!',
                 LinkUrl='statefarm.com.bad',
                 ParentId=chatterGroup.Id));
        }

    }
    //method for setting up the staged cleanup records
    private static void setupCleanupRecords() {
        for(Integer i = 0; i < 10; i++) {
            cleanupRecords.add(new ChatterPostCleanup__c(Name=feedItemRecords[i].Id));
        }

    }  

    /**
     * @description buildUser
     * @param param_UserName
     * @param param_profileId
     * @return User
     */
    //method to build user with the given parameter value
    public static User buildUser(String param_UserName, String param_profileId) {
        User testUser = new User(alias = '12345', email='testUser@statefarm.com.bad', emailencodingkey='UTF-8', lastname='TestUserLastName',
                            languagelocalekey='en_US',localesidkey='en_US', timezonesidkey='America/Chicago', 
                            username= param_UserName, profileId = param_profileId
                        );
        testUser.put('UserPermissionsMarketingUser', true);                        
        return testUser;
    }  

    /**
     * @description createUser
     * @param testUser
     * @return User
     */
    //method to create user with the given user parameter value
    public static User createUser(User testUser) {
        insert testUser;
        return testUser;
    }

    /**
     * @description assignPermissionSet
     * @param testUser
     * @param permissionSetName
     */
    //method to assign permissionset for the given user in parameter value
    public static void assignPermissionSet(User testUser, String permissionSetName) {
        PermissionSet queryPermissionSet = [Select id FROM PermissionSet WHERE Name =: permissionSetName Limit 1];
        PermissionSetAssignment assignPermissionSet = new PermissionSetAssignment();
        assignPermissionSet.AssigneeId = testUser.id;
        assignPermissionSet.PermissionSetId = queryPermissionSet.id;
        insert assignPermissionSet;
    }
    //method to get the ProfileId for the given Profile Name
    private static String getProfileId(String profileName) {
        String profileId = [SELECT Id FROM Profile WHERE name = :profileName LIMIT 1].Id;
        return profileId;
    }

    /**
     * @description buildAgentUser
     * @param param_userName
     * @param param_profileId
     * @param param_associateId
     * @param param_userExternalId
     * @param param_servicingAgentAssocId
     * @param param_territoryAssocId
     * @param param_servicingAgentAssocIdList
     * @param param_territoryAssocIdList
     * @return User
     */
     //method to build agent user with the given parameter value
    public static User buildAgentUser(String param_userName, String param_profileId,
                                      String param_associateId, String param_userExternalId,
                                      String param_servicingAgentAssocId, String param_territoryAssocId, 
                                      String param_servicingAgentAssocIdList, String param_territoryAssocIdList) {
        User agent = new User(alias = '12345', email='12345@statefarm.com.bad', emailencodingkey='UTF-8', lastname='TestUserLastName', 
                                  languagelocalekey='en_US', localesidkey='en_US', timezonesidkey='America/Chicago', 
                        username= param_userName, profileId = param_profileId, 
                        Associate_ID__c=param_associateId, 
                        UserExternalID__c= param_userExternalId,
                        Servicing_Agent_Associate_ID__c = param_servicingAgentAssocId,
                        Territory_Associate_ID__c= param_territoryAssocId,
                        Servicing_Agent_Associate_ID_List__c=param_servicingAgentAssocIdList,
                        Territory_Associate_ID_List__c=param_territoryAssocIdList);
        return agent;
    }
}