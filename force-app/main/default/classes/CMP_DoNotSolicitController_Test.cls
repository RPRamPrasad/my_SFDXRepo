/**
* Author : Golden Spikes Team
* Date Created : 02/04/2019
* Description : Test class for the CMP_DoNotSolicitController apex class.
* @description CMP_DoNotSolicitController_Test
*/

@isTest(seeAllData=false)
private class CMP_DoNotSolicitController_Test {

    private static final String SECONDS_FORMAT= 'ssSSS';
    private static Map<String, Schema.Recordtypeinfo> leadRecordTypeMap = Schema.Sobjecttype.Lead.getRecordTypeInfosByName();
    private static TestData_SalesRoleHierarchy salesRoleHierarchy;
    private static User agentUser;
    private static User atmUser;
    private static User proxyUser;
    private static User adminUser;   
    private static UserRole proxyStandardUserRole;
    private static UserRole atmStandardUserRole;
    private static UserRole agentStandardUserRole;

    @TestSetup
    private static void makeData() {     
        salesRoleHierarchy = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('');
        adminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTestcvtdxe@statefarm.com');
        System.runAs(adminUser) {            
            agentStandardUserRole = new UserRole(name='AgentRole');                    
            insert agentStandardUserRole;
            atmStandardUserRole = new UserRole(name='ATMMRole', parentRoleId = agentStandardUserRole.id);                    
            insert atmStandardUserRole;
            proxyStandardUserRole = new UserRole(name='ProxyRole', parentRoleId = atmStandardUserRole.id);
            insert proxyStandardUserRole;
            User testProxyUser1 = new User(Alias='Proxy',LastName='TaskProxy',Username='testcvtproxyleadfetchdxt@statefarm.com',UserExternalID__c='11ccww22zzcP',Servicing_Agent_Associate_ID__c='11ccww22zzc');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId = proxyStandardUserRole.id;
            proxyUser.UserExternalID__c = '11ccww22zzcP';
            Database.insert(proxyUser);
            atmUser = UTIL_UserProvisioning_TEST.buildAgentTeamUser('ATM', 'TaskATM', 'testcvtAtmleadfetchdxt@statefarm.com');
            atmUser.userRoleId = atmStandardUserRole.id;
            atmUser.Servicing_Agent_Associate_ID__c = '11ccww22zzc';
            Database.insert(atmUser);
            User testAgentUser1 = new User(Alias='Agent',LastName='TaskAgent',Username='testcvtAgentleadfetchdxt@statefarm.com',Associate_ID__c='11ccww22zzc',UserExternalID__c='11ccww22zzc_11ccww22zzc',Servicing_Agent_Associate_ID__c='11ccww22zzc');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
            agentUser.userRoleId = agentStandardUserRole.id;
            agentUser.UserExternalID__c = '11ccww22zzc_11ccww22zzc';
            agentUser.UserPermissionsMarketingUser = true;
            Database.insert(agentUser);
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser, atmUser});
        }
    }   
    
    //method to get user data 
    private static void getUsers(){
        List<User> usrlist=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, UserType__c, SubUserType__c FROM User where UserExternalID__c in('11ccww22zzc_11ccww22zzc','11ccww22zzcP')];
        for(User usrobj:usrlist){
            if(usrobj.UserExternalID__c=='11ccww22zzc_11ccww22zzc'){
                agentUser=usrobj;
            }
            else {
                proxyUser=usrobj;
            }
        }
    }

    //Delete Lead: test method to set do not solicit preference and delete Lead record as an Agent.
    @isTest private static void testDoNotSolicitLeadRecordDeleteAsAgent() {
        getUsers();
        System.runAs(agentUser) {
            Lead leadRec = new Lead (LastName='LeadTest123', ownerId = proxyUser.id, recordtypeId = leadRecordTypeMap.get('Lead').RecordTypeId);
            insert leadRec;

            Test.startTest();

            Lead leadRecBeforeDelete = [select id, SetDoNotSolicit__c, isDeleted from Lead where id =: leadRec.id LIMIT 1];
            System.assertEquals(null, leadRecBeforeDelete.SetDoNotSolicit__c,'Expected value is null, but actual value is'+leadRecBeforeDelete.SetDoNotSolicit__c);
            System.assertEquals(false, leadRecBeforeDelete.isDeleted,'Expected value is false, but actual value is'+leadRecBeforeDelete.isDeleted);

            System.assertEquals(true, CMP_DoNotSolicitController.isLeadDeleteAllowed(), 'Lead is not allowed to delete');
            CMP_DoNotSolicitController.handleDelete(leadRec.id, '1','Lead');

            Lead leadRecAfterDelete = [select id, SetDoNotSolicit__c, isDeleted from Lead where id =: leadRec.id LIMIT 1 ALL ROWS];
            System.assertEquals('1', leadRecAfterDelete.SetDoNotSolicit__c,'Expected value is 1, but actual value is'+leadRecAfterDelete.SetDoNotSolicit__c);
            System.assertEquals(true, leadRecAfterDelete.isDeleted,'Expected value is true, but actual value is'+leadRecAfterDelete.isDeleted);

            Test.stopTest();
         }
    }

    //Delete Lead: test method for exception on delete Lead record as an Agent.
    @isTest private static void testDoNotSolicitLeadRecordDeleteAsAgentForException() {
        getUsers();
        System.runAs(agentUser) {
            Test.startTest();

            List<ExceptionLog__c> exceptionLogBefore = [Select id from ExceptionLog__c where Class__c = 'CMP_DoNotSolicitController' and Method__c='handleDelete'];
            System.assertEquals(0, exceptionLogBefore.size(),'Expected value is 0, but actual value is'+exceptionLogBefore.size());

            CMP_DoNotSolicitController.handleDelete(null, '1','Lead');

            List<ExceptionLog__c> exceptionLogAfter = [Select id from ExceptionLog__c where Class__c = 'CMP_DoNotSolicitController' and Method__c='handleDelete'];
            System.assertEquals(1, exceptionLogAfter.size(),'Expected value is 1, but actual value is'+exceptionLogAfter.size());

            Test.stopTest();
         }
    }
    
    @isTest private static void testRemoveLeadCampaignMemberAsAnAgent() {
        salesRoleHierarchy = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('');
        Lead lead = TestDataFactory_Lead.generateLead('lastNameforLead');
        lead.OwnerId = salesRoleHierarchy.AgentOffice.Id;
        lead = TestDataFactory_Lead.insertLead(lead);
        
        Campaign campaign;
        campaign = TestDataFactory_Campaign.generateCampaign();
        campaign.OwnerId = salesRoleHierarchy.AgentOffice.Id;
        campaign.RecordTypeId = [Select id from RecordType where DeveloperName='Lead_Campaign'].id;
        campaign = TestDataFactory_Campaign.insertCampaign(campaign);
        
        CampaignMember campaignMember;
        campaignMember = TestDataFactory_CampaignMember.generateLeadCampaignMember(campaign,lead);
        campaignMember = TestDataFactory_CampaignMember.insertCampaignMember(campaignMember);
        
        Boolean isSuccess = null;
        System.runAs(salesRoleHierarchy.Agent){
            Test.startTest();
            isSuccess = CMP_DoNotSolicitController.handleDelete(campaignMember.id, '1','Campaign Member');
            Test.stopTest();
        }
        CampaignMember campaignMemberRemoved = [Select Id,Name,Removed__c,SetDoNotSolicit__c from CampaignMember where id =:campaignMember.Id];
        List<CampaignAction__c> campaignAction = [Select id, Action__c,CampaignId__c,Description__c,LeadIdentifier__c,OwnerId from CampaignAction__c where CampaignId__c=:campaign.Id];
        System.assertEquals(true, campaignAction.size()>0,'Expected value is true, but actual value is' +(campaignAction.size()>0));
        System.assertEquals('People Removed', campaignAction[0].Action__c,'Expected value is People Removed, but actual value is'+campaignAction[0].Action__c);
        System.assertEquals('Remove Lead', campaignAction[0].Description__c,'Expected value is Remove Lead, but actual value is'+campaignAction[0].Description__c);
        System.assertEquals(Campaign.Id, campaignAction[0].CampaignId__c,'Expected value is'+Campaign.Id+', but actual value is'+campaignAction[0].CampaignId__c);
        System.assertEquals(true, isSuccess,'Expected isSuccess is true, but actual value is'+isSuccess);
        System.assertEquals('1', campaignMemberRemoved.SetDoNotSolicit__c,'Expected SetDoNotSolicit value is 1, but actual value is'+campaignMemberRemoved.SetDoNotSolicit__c);
        System.assertEquals(true, campaignMemberRemoved.Removed__c,'Expected Removed value is true, but actual value is'+campaignMemberRemoved.Removed__c);
    }

    //method to validate Number of Campaign Members Removed field
    @isTest private static void testRemoveLeadCampaignMemberCountUpdateAsAnAgent() {
        salesRoleHierarchy = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('');
        Lead lead = TestDataFactory_Lead.generateLead('lastNameforLead');
        lead.OwnerId = salesRoleHierarchy.AgentOffice.Id;
        lead = TestDataFactory_Lead.insertLead(lead);

        Campaign campaign;
        campaign = TestDataFactory_Campaign.generateCampaign();
        campaign.OwnerId = salesRoleHierarchy.AgentOffice.Id;
        campaign.RecordTypeId = [Select id from RecordType where DeveloperName='Lead_Campaign'].id;
        campaign.CampaignMembersRemovedManual__c = null;
        campaign = TestDataFactory_Campaign.insertCampaign(campaign);

        CampaignMember campaignMember;
        campaignMember = TestDataFactory_CampaignMember.generateLeadCampaignMember(campaign,lead);
        campaignMember = TestDataFactory_CampaignMember.insertCampaignMember(campaignMember);

        Boolean isSuccess = null;
        System.runAs(salesRoleHierarchy.Agent) {
            Test.startTest();
            isSuccess = CMP_DoNotSolicitController.handleDelete(campaignMember.id, '1','Campaign Member');
            Test.stopTest();
        }
        CampaignMember campaignMemberRemoved = [Select Id,Name,Removed__c,SetDoNotSolicit__c from CampaignMember where id =:campaignMember.Id];
        System.assertEquals(true, isSuccess,'Expected isSuccess is true, but actual value is'+isSuccess);
        System.assertEquals('1', campaignMemberRemoved.SetDoNotSolicit__c,'Expected SetDoNotSolicit value is 1, but actual value is'+campaignMemberRemoved.SetDoNotSolicit__c);
        System.assertEquals(true, campaignMemberRemoved.Removed__c,'Expected Removed value is true, but actual value is'+campaignMemberRemoved.Removed__c);
        Campaign campaignAfterUpdated = [select id, CampaignMembersRemovedManual__c from Campaign where id = :campaign.id limit 1];
        System.assertEquals(1, campaignAfterUpdated.CampaignMembersRemovedManual__c,'Expected value is 1, but actual value is'+campaignAfterUpdated.CampaignMembersRemovedManual__c);
    }
}