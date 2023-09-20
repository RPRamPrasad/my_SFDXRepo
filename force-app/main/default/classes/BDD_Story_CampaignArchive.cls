/**
* Author : Team ITIC
* Date Created : 09/04/2019
* Name : BDD for Campaign Member Archive.
* @description BDD_Story_CampaignArchive
*/
@isTest(seeAllData = false) 
private class BDD_Story_CampaignArchive {
    private static BDD_CampaignArchive_StepDefinitions campaignArchiveStepDefinitions;
    private static void init(){
        campaignArchiveStepDefinitions = new BDD_CampaignArchive_StepDefinitions();
    }
    //test method to validate CampaignArchive creation from Prospect Campaign
    @isTest
    private static void testCreateCampaignAchiveFromCustomerPropsectCampaign() {
        init();
        campaignArchiveStepDefinitions.givenAnCustomerProspectCampaignGetsCreatedForAProxyUser();
        campaignArchiveStepDefinitions.whenTheCampaignGetsDeleted();
        campaignArchiveStepDefinitions.thenTheCampaignArchiveIsUpdated();
    }
    //test method to validate CampaignArchive creation From Lead Campaign
    @isTest
    private static void testCreateCampaignAchiveForLeadCampaignMember() {
        init();
        campaignArchiveStepDefinitions.givenAnLeadCampaignGetsCreatedForAProxyUser();
        campaignArchiveStepDefinitions.whenTheCampaignGetsDeleted();
        campaignArchiveStepDefinitions.thenTheCampaignArchiveIsUpdated();
    }
}