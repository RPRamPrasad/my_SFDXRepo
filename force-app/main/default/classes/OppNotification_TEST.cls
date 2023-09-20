@isTest
public with sharing class OppNotification_TEST {

    public static User agentUser;
    public static User adminUser;
    public static User proxyUser;
    public static CS_EnvironmentURLCustomSetting__c baseURLCustomSetting = new CS_EnvironmentURLCustomSetting__c();

    public static Account accountNoah;
    private static final String ICP_TP_ENV = 'ICP_TP_ENV';

    /**
     * @description The test setup, adding needed users for testing and inserting them
     */
    @testSetup
    public static void setUp() {
        
        User adminUser = UTIL_UserProvisioning_TEST.buildUserWithSystemAdminProfile('TestAdminUser@statefarm.com.bad');
        insert adminuser;
        User agentUser;
        User proxyUser; 
        
        System.runAs(adminUser) {
            OppNotificationPreferenceRetriever_TEST.byPassTrigger();
            
            UserRole agentUserRole = TestDataFactory_Campaign.buildUserRole('AgentRole');
            insert agentUserRole;
            
            UserRole proxyUserRole = OppNotificationPreferenceRetriever_TEST.buildUserRoleWithParent('ProxyRole', agentUserRole.id);
            insert proxyUserRole;
            
            User testAgentUser = new User(Alias='X7PZ',LastName='agent,user,75-338-Office',Username='TestAgentUser@statefarm.com.bad',Associate_ID__c='ASSOCID0001',UserExternalID__c='EXTERNALID1',Servicing_Agent_Associate_ID__c='AGTASSOCID1',Territory_Associate_ID__c='',Servicing_Agent_Associate_ID_List__c='',Territory_Associate_ID_List__c='');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser (testAgentUser);
            agentUser.userRoleId = agentUserRole.id;

            insert agentUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);

            
            User testProxyUser = new User(Alias='X7PX',LastName='middle,Last,75-338-Office',Username='TestProxyUser@statefarm.com.bad',UserExternalID__c='EXTERNALID2',Servicing_Agent_Associate_ID__c='ASSOCID0001', Territory_Associate_ID__c='');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser(testProxyUser);
            insert proxyUser;

            CS_EnvironmentURLCustomSetting__c baseURLCustomSetting = new CS_EnvironmentURLCustomSetting__c();
            baseUrlCustomSetting.Name = ICP_TP_ENV;
            baseUrlCustomSetting.Value__c = '.statefarm.com';
            baseUrlCustomSetting.EXT_ID__c= 'ECRM_6';

            insert baseURLCustomSetting;
        }
    }

    private static void queryTestData() {
        agentUser = [SELECT Id ,Associate_ID__c, UserExternalID__c FROM User WHERE username = 'TestAgentUser@statefarm.com.bad'];
        adminUser = [SELECT Id, Associate_ID__c FROM User WHERE username = 'TestAdminUser@statefarm.com.bad'];
        proxyUser = [SELECT Id, Associate_ID__c FROM User WHERE Alias = 'X7PXP'];
        baseURLCustomSetting = [SELECT Value__c FROM CS_EnvironmentURLCustomSetting__c WHERE Name =: ICP_TP_ENV];

        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        Account acc = OppNotificationPreferenceRetriever_TEST.buildAccountRecord('Steve Blunier','111', agentUser.Id);
        insert acc;
        accountNoah = [SELECT Id, ClientIdentifier__c, Name FROM Account WHERE lastname = 'Blunier'];
    }

    // BEGIN TESTS -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    //will inlcude all needed opp fields to form a full message to return
    @isTest
    public static void getChatterMessageSetsFullUnclaimedMessage() {
        queryTestData();

        Opportunity opp;

        System.runAs(agentUser) {
            opp = OppNotificationPreferenceRetriever_TEST.buildOpportunityRecord(accountNoah.id,'Auto-GAINSCO', proxyUser.Id);
            insert opp;
        }

        opp.Opportunity_Originator__c = 'Internet Lead Provider';
        update opp;

        OppNotification notification = new OppNotification();
        String actualRetVal = notification.setBaseNotificationProperties(opp).get('chatterMessage');
        String expectedRetVal = 'New or Unclaimed Internet Lead Provider Auto opportunity is available to be claimed!';

        System.assertEquals(expectedRetVal, actualRetVal,
        'Unclaimed opp, getUpdatedChatterMessage() should return the proper full message');
    }

    @isTest
    public static void getUpdatedChatterMessageSetsFullUpdatedMessage() {
        queryTestData();

        Opportunity opp;

        System.runAs(agentUser) {
            opp = OppNotificationPreferenceRetriever_TEST.buildOpportunityRecord(accountNoah.id,'Auto-GAINSCO', proxyUser.Id);
            insert opp;
        }

        opp.Opportunity_Originator__c = 'Internet Lead Provider';
        opp.stageName = 'Assigned'; 
        opp.Assigned_To__c = agentUser.Id;
        update opp;

        OppNotification notification = new OppNotification();
        String actualRetVal = notification.setBaseNotificationProperties(opp).get('chatterMessage');
        String expectedRetVal = 'An update has been made to the Internet Lead Provider Auto Opportunity!';

        System.assertEquals(expectedRetVal, actualRetVal,
        'Updated/claimed opp, Method getUpdatedChatterMessage() should return the proper full message');
    }

     //unclaimed opp chatter message, will exclude the opp originator
     @isTest
     public static void getUpdatedChatterMessageUnclaimedWithoutOppOriginator() {
         queryTestData();
 
         Opportunity opp;
 
         System.runAs(agentUser) {
             opp = OppNotificationPreferenceRetriever_TEST.buildOpportunityRecord(accountNoah.id,'Auto-GAINSCO', proxyUser.Id);
             insert opp;
         }

         OppNotification notification = new OppNotification();
         notification.setBaseNotificationProperties(opp);
 
         String actualRetVal = notification.setBaseNotificationProperties(opp).get('chatterMessage');
         String expectedRetVal = 'New or Unclaimed  Auto opportunity is available to be claimed!'; //JANK DOUBLE SPACE ISSUE WHEN NO ORIGINATOR IS FOUND
 
         System.assertEquals(expectedRetVal, actualRetVal,
         'Method getUpdatedChatterMessage() should not contain the opp originator');
     }

     //claimed opp chatter message, will exclude the opp originator
     @isTest
     public static void getUpdatedChatterMessageClaimedWithoutOppOriginator() {
         queryTestData();
 
         Opportunity opp;
 
         System.runAs(agentUser) {
             opp = OppNotificationPreferenceRetriever_TEST.buildOpportunityRecord(accountNoah.id,'Auto-GAINSCO', proxyUser.Id);
             insert opp;
         }

         opp.stageName = 'Assigned'; 
         opp.Assigned_To__c = agentUser.Id;
         update opp;
 
         OppNotification notification = new OppNotification();
         String actualRetVal = notification.setBaseNotificationProperties(opp).get('chatterMessage');
         String expectedRetVal = 'An update has been made to the  Auto Opportunity!'; //JANK DOUBLE SPACE ISSUE WHEN NO ORIGINATOR IS FOUND
 
         System.assertEquals(expectedRetVal, actualRetVal,
         'Method getUpdatedChatterMessage() should not contain the opp originator');
     }

     //unclaimed opp chatter message, will exclude the opp originator
     @isTest
     public static void unclaimedOppGivesCorrectTitle() {
         queryTestData();
 
         Opportunity opp;
 
         System.runAs(agentUser) {
             opp = OppNotificationPreferenceRetriever_TEST.buildOpportunityRecord(accountNoah.id,'Auto-GAINSCO', proxyUser.Id);
             insert opp;
         }

         update opp;
 
         OppNotification notification = new OppNotification();
         String actualRetVal = notification.setBaseNotificationProperties(opp).get('title');
         String expectedRetVal = 'New or Unclaimed Hot Prospect Opportunity';
 
         System.assertEquals(expectedRetVal, actualRetVal,
         'Method setBaseNotificationProperties() should set key "title" be the unclaimed opp title');
     }

     @isTest
     public static void updatedOppGivesCorrectTitle() {
         queryTestData();
 
         Opportunity opp;
 
         System.runAs(agentUser) {
             opp = OppNotificationPreferenceRetriever_TEST.buildOpportunityRecord(accountNoah.id,'Auto-GAINSCO', proxyUser.Id);
             insert opp;
         }

         opp.stageName = 'Assigned'; 
         opp.Assigned_To__c = agentUser.Id;
         update opp;
 
         OppNotification notification = new OppNotification();
         String actualRetVal = notification.setBaseNotificationProperties(opp).get('title');
 
         String expectedRetVal = 'Updated Hot Prospect Opportunity'; 
         System.assertEquals(expectedRetVal, actualRetVal,
         'Method setBaseNotificationProperties() should set key "title" be the updated opp title');
     }

    @isTest
    public static void setSkypeMessageSetsFullMessage() {
        queryTestData();

        Opportunity opp;

        System.runAs(agentUser) {
            opp = OppNotificationPreferenceRetriever_TEST.buildOpportunityRecord(accountNoah.id,'Auto-GAINSCO', proxyUser.Id);
            opp.Marketing_Source__c = 'Claims Department';
            insert opp;
        }

        opp.Opportunity_Originator__c = 'Internet Lead Provider';
        opp.LOB__c = 'Auto';
        update opp;

        OppNotification notification = new OppNotification();

        String mockRedirectURL = 'https://customer' + baseURLCustomSetting.Value__c + 
             '/urlGateway/ExternalRedirect/Salesforce' +
              '?callingApplication=chatternotification&objectType=Opportunity&opportunityrecordId=' +
             opp.Id + '&action=view';
        
        String actualRetVal =  notification.createSkypeMessage(opp, mockRedirectURL);
        String expectedRetVal = '\nAuto-Steve Blunier\nInternet Lead Provider\nClaims Department\n' + mockRedirectURL;

        System.assertEquals(expectedRetVal, actualRetVal,
        'Method createSkypeMessage() should return the proper message for Skype notifications');
    }

     @isTest
     public static void setRedirectURLReturnsCorrectLink() {
         queryTestData();
 
         Opportunity opp;
 
         System.runAs(agentUser) {
             opp = OppNotificationPreferenceRetriever_TEST.buildOpportunityRecord(accountNoah.id,'Auto-GAINSCO', proxyUser.Id);
             insert opp;
         }

        opp.Opportunity_Originator__c = 'Internet Lead Provider';
        opp.LOB__c = 'Auto';

        update opp;
 
        OppNotification notification = new OppNotification();
 
         String expectedRetVal = 'https://customer' + baseURLCustomSetting.Value__c + 
         '/urlGateway/ExternalRedirect/Salesforce' +
          '?callingApplication=chatternotification&objectType=Opportunity&opportunityrecordId=' +
         opp.Id + '&action=view';

         String actualRetVal = notification.setBaseNotificationProperties(opp).get('redirectURL');
 
         System.assertEquals(expectedRetVal, actualRetVal,
         'Method setBaseNotificationProperties() should set the proper URL');
     }

     @isTest
     public static void getRecipientReturnsCorrectId() {

        OppNotification notification = new OppNotification();
        notification.setRecipient('0050n0000046td5AA8');

        Id expectedRetVal = '0050n0000046td5AA8';

        System.assertEquals(expectedRetVal, notification.getRecipient(),
        'Method setRecipient() and getRecipient() returns the proper Id');
     }
}