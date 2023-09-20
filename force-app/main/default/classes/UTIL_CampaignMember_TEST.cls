/* Version 2.0-   Team Incognito - Remove duplicate code /Refactor */

@isTest
private class UTIL_CampaignMember_TEST {
        static Contact contact;
        static Campaign campaign;
        static CampaignMember campaignMember;
        static Boolean isDMLSuccess= false;
        static List<CampaignMember> campaignMemberUpdated;

    @TestSetup
    static void makeData(){
        TestDataFactory_CampaignMember.byPassCampaignMemberTrigger();
    }

    @isTest
    static void updateCampaignMemberSuccess() {
        performDML('Admin', 'update');
        system.assertEquals(true, isDMLSuccess,'Expected Success is true, but actual value is'+isDMLSuccess);
        system.assertEquals('Responded', campaignMemberUpdated[0].status,'Expected Status is Responded, but actual value is'+campaignMemberUpdated[0].status);
    }
    
    @isTest
    static void updateCampaignMemberWithException() {
        performDML('Agent', 'update');
        system.assertEquals(false, isDMLSuccess,'Expected Success is false, but actual value is'+isDMLSuccess);
    }

    @isTest
    static void deleteCampaignMemberSuccess() {
        performDML('Admin', 'delete');
        system.assertEquals(true, isDMLSuccess,'Expected Success is true, but actual value is'+isDMLSuccess);
        system.assertEquals(0, campaignMemberUpdated.size(),'Size of Campaign Member Updated should be empty');
    }
    
    @isTest
    static void deleteCampaignMemberWithException() {
        performDML('Agent', 'delete');
        system.assertEquals(false, isDMLSuccess,'Expected Success is false, but actual value is'+isDMLSuccess);
    }
    static void performDML(String userType, String dmlType) {
        User adminUser = TestDataFactory_User.getSysAdminUser(); 
        
        contact = TestDataFactory_Contact.generateContact('firstnameCt','lastnameCt');
        contact = TestDataFactory_Contact.insertContact(contact);
        
        campaign = TestDataFactory_Campaign.generateCampaign();
        campaign.OwnerId = adminUser.Id;
        campaign = TestDataFactory_Campaign.insertCampaign(campaign);
        
        campaignMember = TestDataFactory_CampaignMember.generateCampaignMember(campaign,contact);
        campaignMember = TestDataFactory_CampaignMember.insertCampaignMember(campaignMember);
        if(userType == 'Admin' && dmlType == 'update')
        {   
            System.runAs(adminUser) {
            Test.startTest();
            isDMLSuccess = UTIL_CampaignMember.updateCampaignMember(new List<CampaignMember>{new CampaignMember(Id = campaignMember.Id, status='Responded')});
            Test.stopTest();
            }
             campaignMemberUpdated = [Select Id,status from CampaignMember where Id=: campaignMember.Id limit 1];
 
        }
        else if(userType == 'Admin' && dmlType == 'delete'){
            System.runAs(adminUser) {
            Test.startTest();
            isDMLSuccess = UTIL_CampaignMember.deleteCampaignMember(new List<CampaignMember>{new CampaignMember(Id = campaignMember.Id)});
            Test.stopTest();
        }
             campaignMemberUpdated = [Select Id,status from CampaignMember where Id=: campaignMember.Id limit 1];
            
        }
        
        else if(userType == 'Agent' && dmlType == 'update'){
            User agentUser = TestDataFactory_User.generateUser('2.00 Agent');
            agentUser.alias = 'test';
            agentUser = TestDataFactory_User.insertUser(agentUser);
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            System.runAs(agentUser) {
                Test.startTest();
                isDMLSuccess = UTIL_CampaignMember.updateCampaignMember(new List<CampaignMember>{});
                Test.stopTest();
            }
          
        }
        
        else if(userType == 'Agent' && dmlType == 'delete'){
            User agentUser = TestDataFactory_User.generateUser('2.00 Agent');
            agentUser.alias = 'test';
            agentUser = TestDataFactory_User.insertUser(agentUser);
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            System.runAs(agentUser) {
                Test.startTest();
                isDMLSuccess = UTIL_CampaignMember.deleteCampaignMember(new List<CampaignMember>{});
                Test.stopTest();
            }
            
        }
    }
}