/**
Author Team ClubCar
Name - CMP_NewCampaignMessageButton_TEST
@description - Test class written for CMP_NewCampaignMessageButton 
==========================================================================================+
History
-------
VERSION         AUTHOR                      DATE                    DETAIL
1.0             Team ClubCar                02/14/2019              Initial Development
******************************************************************************************/

@isTest()
public with sharing class CMP_NewCampaignMessageButton_TEST {   
    private static User sysAdminUser;
    private static User agentUser;
    private static User proxyUser;
    private static User systemUser;
    private static UserRole proxyStandardUserRole;
    private static UserRole agentStandardUserRole;
    private static UserRole agentTeamMemberUserRole;
    private static Map<String, Schema.Recordtypeinfo> campaignRecordTypeMap 
        = Schema.Sobjecttype.Campaign.getRecordTypeInfosByName();
    
    /**
    * @method Setup method used for building test data (must be called at beginning of test)
    * @description Setup method used for building test data
    * @name  setUpTriggerAndUserData
    */
    @TestSetup
    private static void setUpTriggerAndUserAndCampaignData() {
        
        systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();  
        insert systemUser;
        
        CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c(Override_All__c= false);
        insert objectBasedByPassTrigger;
        
        CS001_ByPassTriggerAtoF__c accountByPassTrigger= new CS001_ByPassTriggerAtoF__c(Override_AccountBeforeInsert__c=false,Override_AgentRoleAfterInsert__c=false);
        insert accountByPassTrigger;
        
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(Name=UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER,SFDC_USER_ID__c=systemUser.id);            
        insert sysAdminUserIdSetting;
        
        CS001_ByPassTriggerGtoZ__c oppByPassTrigger = new CS001_ByPassTriggerGtoZ__c(Override_OppBeforeInsert__c=false);
        insert oppByPassTrigger;
        
        sysAdminUser= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert sysAdminUser;
        
        System.runAs(sysAdminUser) {
   
            agentStandardUserRole = new UserRole(name = 'AgentRole');                    
            insert agentStandardUserRole;
            
            agentTeamMemberUserRole = new UserRole(name= 'AgentTeamMemberRole', parentRoleId = agentStandardUserRole.id);
            insert agentTeamMemberUserRole;
            
            proxyStandardUserRole = new UserRole(name='ProxyRole', parentRoleId = AgentTeamMemberUserRole.id);
            insert proxyStandardUserRole;
            User testProxyUser1 = new User(Alias='Prox',LastName='opportunityAg',Username='TestProxUserForOppTst11@statefarm.com',UserExternalID__c='123testP',Servicing_Agent_Associate_ID__c='123test');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId= proxyStandardUserRole.id;
            Database.insert(proxyUser);
            User testAgentUser1 = new User(Alias='Alia',LastName='opportunityProxy',Username='TestAgtUserForCmpgnTst11@statefarm.com',Associate_ID__c='123test',UserExternalID__c='123test',Servicing_Agent_Associate_ID__c='123test');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
            agentUser.State_Agent_Code__c = '13-3050';
            agentUser.userRoleId= agentStandardUserRole.id;
            Database.insert(agentUser);
        }
    }
    
    //Method to test retrieval of Campaign and LoggedInUser details based on passed campaignId
    @isTest
    private static void testCampaignDataIsRetrievedWithValidUserProfileAndCampaignId() {
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(getValidAgentUserProfile());
        System.runAs(getValidAgentUserProfile()) {
            
            Campaign testCampaign = new Campaign(
            	Name = 'TestSendMessageButtonCampaign', 
            	RecordTypeId = campaignRecordTypeMap.get('Customer/Prospect Campaign').RecordTypeId
        	);
        	insert testCampaign;
            
            Test.startTest();
            CMP_NewCampaignMessageButton.CampaignDataWithPermission campaignDataWithPermission = CMP_NewCampaignMessageButton.getCampaignDataWithPermission(testCampaign.Id);
            Test.stopTest();
            System.assertEquals(
                true, 
                campaignDataWithPermission.userMayView,'User may not have access to view the Campaign data'
            );
            System.assertEquals(campaignDataWithPermission.record.Id, testCampaign.Id,'Campaign Id did not match');
            System.assertEquals(campaignDataWithPermission.record.RecordType.DeveloperName, 'Customer_Prospect_Campaign','Campaign record type developer name did not match');
        }                  
    }
    
    //Method to test Invalid profile
    @isTest
    private static void testUserMayNotViewWithInvalidProfile() {
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(getInvalidAgentUserProfile());
        System.runAs(getInvalidAgentUserProfile()) {
            
            Campaign testCampaign = new Campaign(
            	Name='TestSendMessageButtonCampaign', 
            	RecordTypeId = campaignRecordTypeMap.get('Customer/Prospect Campaign').RecordTypeId
        	);
        	insert testCampaign;
            
            
            Test.startTest();
            CMP_NewCampaignMessageButton.CampaignDataWithPermission campaignDataWithPermission 
                = CMP_NewCampaignMessageButton.getCampaignDataWithPermission(testCampaign.Id);
            Test.stopTest();
            System.assertEquals(false, campaignDataWithPermission.userMayView,'User may not have access to view the Campaign data');
        }
    }
    
    //Method to test Exception scenario
    @isTest
    private static void testExceptionLoggedFromAttemptToRetrieveCampaignDataWithBadParameters() {
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(getValidAgentUserProfile());
        System.runAs(getValidAgentUserProfile()) {
            
            Test.startTest();
            CMP_NewCampaignMessageButton.getCampaignDataWithPermission(null);
            Test.stopTest();      
            System.assertEquals(1, [SELECT Id,name, class__c, exception_Message__c from ExceptionLog__c where class__c = 'CMP_NewCampaignMessageButton' LIMIT 1].size(),'Exception Log size did not match');            
        }
    }
    
    private static User getInvalidAgentUserProfile() {
        
        return [Select id, Alias, lastname, email, profileid, username from User where username = 'systemAdminTest@statefarm.com' LIMIT 1];
    }
    
    private static User getValidAgentUserProfile() {
        
        return [Select id, Proxy_External_ID__c, UserExternalID__c, Associate_ID__c, Alias, lastname, email, profileid from User where username = 'TestAgtUserForCmpgnTst11@statefarm.com' LIMIT 1];
    }
}