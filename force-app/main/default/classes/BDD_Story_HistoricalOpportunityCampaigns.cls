@isTest(seeAllData=false)
public with sharing class BDD_Story_HistoricalOpportunityCampaigns {
    private static BDD_HistOppCampaigns_StepDefinitions historicalOpportunityCampaigns_StepDefinitions;

    private static void init(){
        historicalOpportunityCampaigns_StepDefinitions = new BDD_HistOppCampaigns_StepDefinitions();
    }
    
    @isTest
    public static void opportunitiesExistAndCampaignsAreCreated(){
        init();
        historicalOpportunityCampaigns_StepDefinitions.givenAnAmountOfHistoricalOpportunitiesCreatedForAProxyUser(5);
        historicalOpportunityCampaigns_StepDefinitions.whenTheHistoricalOpportunityCampaignBatchRuns();
        historicalOpportunityCampaigns_StepDefinitions.thenTheHistoricalOpportunityCampaignAndCampaignMembersAreProperlyCreated();
    }
    @isTest
    public static void opportunitiesDoNotExistAndCampaignsAreNotCreated(){
        init();
        historicalOpportunityCampaigns_StepDefinitions.givenAnAmountOfHistoricalOpportunitiesCreatedForAProxyUser(0);
        historicalOpportunityCampaigns_StepDefinitions.whenTheHistoricalOpportunityCampaignBatchRuns();
        historicalOpportunityCampaigns_StepDefinitions.thenTheHistoricalOpportunityCampaignAndCampaignMembersAreProperlyCreated();        
    }
}