/**
* Author : Team ITIC
* Date Created : 09/09/2019 
* Description : Test class for triggers AfterInsert and AfterDelete on Campaign object
* @description AP_CampaignArchive_TEST 
*/

@isTest(seeAllData=false) 
public class AP_CampaignArchive_TEST {
    @TestSetup
    static void testSetupData(){
       CS_FeatureToggle__c featureToggle = new CS_FeatureToggle__c();
       featureToggle.Name='CampaignArchive';
       featureToggle.CampaignArchive__c =  true;
       insert featureToggle;
    }
    
    @isTest
     private static void testCampaignArchive(){
        User campaignUser = TestDataFactory_User_Wrapper.generateSystemAdministratorUser('ADMN','OOOCAMPUSER');
        campaignUser.UserPermissionsMarketingUser = true;
        insert campaignUser;
        Campaign newCampaign = new Campaign(Name='Test Campaign Archive');
        newCampaign.NewOpportunityCreatedCount__c = 1;
        newCampaign.Assigned_to_Campaign__c = 'Team Member1| Team Member2';
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(campaignUser);
        system.runAs(campaignUser){
            Test.startTest();
            insert newCampaign;
            Test.stopTest();
        }
         String campaignId = newCampaign.Id;
         List<CampaignArchive__c> campaignArchiveList = [Select Id, Name from CampaignArchive__c where OriginalCampaignSfdcID__c=:campaignId limit 1];
         system.assertEquals(1, campaignArchiveList.size(),'The size of campaign Archive List should be 1');
         delete newCampaign;
         campaignArchiveList = [Select Id, Name, CampaignDeletedDate__c,NewOpportunityCreatedCount__c,Assigned_to_Campaign__c from CampaignArchive__c where OriginalCampaignSfdcID__c=:campaignId];
         system.assertEquals(1, campaignArchiveList.size(),'The size of campaign Archive List should be 1');
         system.assert(campaignArchiveList[0].CampaignDeletedDate__c!=null,'Campaign Deleted Date should not be empty');
         system.assertEquals(campaignArchiveList[0].NewOpportunityCreatedCount__c, newCampaign.NewOpportunityCreatedCount__c,'Expected Created Count is'+campaignArchiveList[0].NewOpportunityCreatedCount__c+', but actual value is'+newCampaign.NewOpportunityCreatedCount__c);//test new opportunity count archived
         system.assertEquals(campaignArchiveList[0].Assigned_to_Campaign__c, newCampaign.Assigned_to_Campaign__c,'Expected Assigned To Campaign is'+campaignArchiveList[0].Assigned_to_Campaign__c+', but actual value is'+newCampaign.Assigned_to_Campaign__c);
     }

     @isTest
     private static void testCampaignArchiveBulk(){
        User campaignUser = TestDataFactory_User_Wrapper.generateSystemAdministratorUser('ADMN','OOOCAMPUSER');
        campaignUser.UserPermissionsMarketingUser = true;
        insert campaignUser;
        List<Campaign> campaignList = new List<Campaign>();
        for(Integer i=0; i<105; i++){
            Campaign newCampaign = new Campaign(Name='Test Campaign Archive'+i);
            campaignList.add(newCampaign);
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(campaignUser);
        system.runAs(campaignUser){
            Test.startTest();
            insert campaignList;
            Test.stopTest();
        }
        Set<String> campaignIds = new Set<String>();
        for(Campaign campaignRecord: campaignList){
            if(campaignRecord.Id!=null){
                String idValue = campaignRecord.Id;
                campaignIds.add(idValue);
            }
        }
        List<Campaign> campaignsCreatedList = [Select Id from Campaign where createdby.id=:campaignUser.Id];
        system.assertEquals(105, campaignsCreatedList.size(),'The size of campaign Created List should be 105');
         List<CampaignArchive__c> campaignArchiveList = [Select Id, Name from CampaignArchive__c where OriginalCampaignSfdcID__c =:campaignIds];
         system.assertEquals(105, campaignArchiveList.size(),'The size of campaign Archive List should be 105');
         delete campaignList;
         campaignArchiveList = [Select Id, Name, CampaignDeletedDate__c from CampaignArchive__c where OriginalCampaignSfdcID__c =:campaignIds];
         system.assertEquals(105, campaignArchiveList.size(),'The size of campaign Archive List should be 105');
         system.assert(campaignArchiveList[0].CampaignDeletedDate__c!=null,'Campaign Deleted Date should not be empty');
     }
}