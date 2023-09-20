@isTest(seeAllData=false)
public with sharing class BDD_HistOppCampaigns_StepDefinitions {
    private List<Opportunity> opportunities;
    private List<Database.SaveResult> saveResults;
    public static AP_BatchReportRequest request = retrieveReportData();
    private Campaign campaign;
    private List<CampaignMember> campaignMembers = new List<CampaignMember>();
    User sysAdmin = TestDataFactory_User.getSysAdminUser();
    User batchProcessId = getBatchProcessId();
    TestData_SalesRoleHierarchy salesRoles = TestDataFactory_SalesRoleHierarchy.generateAgentOfficeHierarchy('A');
    List<Account> accounts;
    private static final String LOB_OPPORTUNITIES = request.getCampaignName();
    private static final String HISTORY_OPPORTUNITY_CAMPAIGN_PROCESS_ID_LOOKUP = 'sf_crm_historicalreportca@statefarm.com%';
    private static final String SECONDS_FORMAT= 'ssSSS';
    private BDD_HistOppCampaigns_StepDefinitionsWrap bddHistOppWrap = new BDD_HistOppCampaigns_StepDefinitionsWrap();
/**
 * @description givenAnAmountOfHistoricalOpportunitiesCreatedForAProxyUser
 * @param amount 
 */

    public void givenAnAmountOfHistoricalOpportunitiesCreatedForAProxyUser(Integer amount){
        if(amount > 0){
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoles.agent);
            System.runAs(salesRoles.agent){
                UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
                opportunities = buildHistoricalOpportunities(amount,salesRoles.AgentOffice.Id);
                saveResults = Database.insert(opportunities);
                setCreatedDateToThreeMonthsPrior(saveResults);
            }
        }
    }
/**
 * @description whenTheHistoricalOpportunityCampaignBatchRuns
 */

    public void whenTheHistoricalOpportunityCampaignBatchRuns(){
        bddHistOppWrap.whenTheHistoricalOpportunityCampaignBatchRuns(batchProcessId);
    }
    /**
     * @description thenTheHistoricalOpportunityCampaignAndCampaignMembersAreProperlyCreated
     */
    
    public void thenTheHistoricalOpportunityCampaignAndCampaignMembersAreProperlyCreated(){
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoles.agent);
        System.runAs(salesRoles.agent){
        Integer count = [SELECT count() from campaign];
        if(count > 0){
            campaign = retrieveHistoricalOpportunityCampaign(removeLastCharacter(salesRoles.AgentOffice.alias));
            campaignMembers = retrieveCampaignMembers(campaign.id);
            validateHistoricalOpportunityCampaign(campaign);
            validateCampaignMembers(campaignMembers, campaign.id, opportunities.size());
        }else{
            System.assertEquals(null,opportunities,'Opportunities should be null');
        }
        }
    }
    private static AP_BatchReportRequest retrieveReportData(){
		AP_RetrieveBatchReportFieldData  reportFieldValue = new AP_RetrieveBatchReportFieldData();
		return reportFieldValue.setBatchReportRequest('Batch_NeglectedAbandonedAutoOpportunity');
	}
    private Campaign retrieveHistoricalOpportunityCampaign(String alias){
        return [SELECT id, name, status,StartDate,EndDate,
        Type,Assigned_To__c,Initiated_By_Id__c,Initiated_by_Id__r.name,Office_assigned__c, Submitted_Campaign_Count__c,
        source__c,Original_Campaign_Count__c from Campaign where Source__c = 'Report'/*name = :name */limit 1];
    }
    private List<CampaignMember> retrieveCampaignMembers(Id campaignId){
        return [SELECT id, contactid,campaignid,Status__c from CampaignMember where campaignId = :campaignId];
    }
    private void validateHistoricalOpportunityCampaign(Campaign campaign){
        isCampaignCustomerProspect(campaign);
        isCampaignCreatedToday(campaign);
        isCampaignEndDate90DayFromToday(campaign);
        isCampaignInitiatedByProcessId(campaign,'SF_CRM_HISTORICALREPORTCA');
        isCampaignAssignedToBlank(campaign);
        isCampaignSourceReport(campaign);
        isOriginalCampaignCountValid(campaign,opportunities.size());
        isCampaignEndDate90DayFromToday(campaign);
        isCampaignStatusFulfillmentCompleted(campaign);
        isCampaignNameValidForHistoricalOpportunityCampaign(campaign);
    }
    private void validateCampaignMembers(List<CampaignMember> campaignMembers, ID campaignId, Integer campaignMemberTotal){
        System.assertEquals(campaignMemberTotal, campaignMembers.size(),'Expected Size is'+campaignMemberTotal+'but actual is'+campaignMembers.size());
        BDD_HistOppCampaignsVaribaleWrapper bddWrapper = new BDD_HistOppCampaignsVaribaleWrapper();
        bddWrapper.bddHist_opportunities = opportunities;
        bddWrapper.campaignMemberTotal = campaignMemberTotal;
        bddHistOppWrap.validateCampaignMembers(campaignMembers, campaignId, bddWrapper);
    }
    private void isCampaignCustomerProspect(Campaign campaign){
        System.assertEquals('Customer/Prospect',campaign.Type,'Expected Type is Customer/Prospect but actual is'+campaign.Type);
    }
    private void isCampaignCreatedToday(Campaign campaign){
        System.assertEquals(System.today(),campaign.StartDate,'Expected StartDate value is'+System.today()+', but actual StartDate value is'+campaign.StartDate);
    }
    private void isCampaignEndDate90DayFromToday(Campaign campaign){
        System.assertEquals(System.today().addDays(90),campaign.EndDate,'Expected EndDate value is'+System.today().addDays(90)+', but actual EndDate value is'+campaign.EndDate);
    }
    private void isCampaignInitiatedByProcessId(Campaign campaign, String processIdName){
        System.assertEquals(processIdName, campaign.Initiated_by_Id__r.name,'Expected Initiated_by_Id value is'+processIdName+', but actual Initiated_by_Id value is'+campaign.Initiated_by_Id__r.name);
    }
    private void isCampaignAssignedToBlank(Campaign campaign){
        System.assertEquals(null, campaign.Assigned_To__c,'Assigned_To value should be null');
    }
    private void isCampaignSourceReport(Campaign campaign){
        System.assertEquals('Report', campaign.Source__c,'Expected Source value is Report, but actual Source value is'+campaign.Source__c);
    }
    private void isOriginalCampaignCountValid(Campaign campaign, Integer amount){
        System.assertEquals(amount, campaign.Original_Campaign_Count__c,'Expected Original_Campaign_Count value is'+amount+', but actual Original_Campaign_Count value is'+campaign.Original_Campaign_Count__c);
        System.assertEquals(amount, campaign.Submitted_Campaign_Count__c,'Expected Submitted_Campaign_Count value is'+amount+', but actual Submitted_Campaign_Count value is'+campaign.Submitted_Campaign_Count__c);
    }
    private void isCampaignStatusFulfillmentCompleted(Campaign campaign){
        System.assertEquals('Fulfillment Completed', campaign.Status,'Expected Status value is Fulfillment Completed, but actual value is'+campaign.Status);
    }
    private void isCampaignNameValidForHistoricalOpportunityCampaign(Campaign campaign){
        Date startDate = Date.today();
        System.assertEquals(LOB_OPPORTUNITIES + '- ' + getMonthAndYearFormatted(startDate, '/') + '- ' 
                            + removeLastCharacter(salesRoles.AgentOffice.alias),campaign.name,'Expected Name value is'+LOB_OPPORTUNITIES + '- ' + getMonthAndYearFormatted(startDate, '/') + '- ' 
                            + removeLastCharacter(salesRoles.AgentOffice.alias)+', but actual Name value is'+campaign.name);
    }

   private User getBatchProcessId(){
       User user =  UTIL_UserProvisioning_TEST.buildUserAPIDataAdmin();
       user.lastName='SF_CRM_HISTORICALREPORTCA';
       System.runAs(sysAdmin){
        user.id = Database.insert(user).getId();
        assignPermissionSet(user, 'SF_CRM_HistoricalReportCampaign_PermSetPID');
       }
       return user;
   }
    private List<Opportunity> buildHistoricalOpportunities(Integer amount,ID ownerId){
        String name = 'CatCat';
        String stageName = 'New';
        String lineOfBusiness = 'Auto';
        String company = 'Mutual';
        Datetime opportunityClosed = System.today();
        String journeyId = null;
        String closedReason = 'Too Busy';
        BDD_HistOppCampaigns_StepDefinitionsWrapper wrap = new BDD_HistOppCampaigns_StepDefinitionsWrapper();
        wrap.amount = amount;
        wrap.name = name;
        wrap.stageName = stageName;
        wrap.lineOfBusiness = lineOfBusiness;
        wrap.company = company;
        wrap.closedDate = opportunityClosed;
        wrap.journeyId = journeyId;
        wrap.ownerid = ownerId;
        wrap.closedReason = closedReason;
        return buildOpportunitiesWithAccount(wrap);
    }
   
private class BDD_HistOppCampaigns_StepDefinitionsWrapper{
    Integer amount;
    String name;
    String stageName;
    String lineOfBusiness;
    String company;
    Datetime closedDate;
    String journeyId;
    ID ownerid;
    String closedReason;
}

    private List<Opportunity> buildOpportunitiesWithAccount(BDD_HistOppCampaigns_StepDefinitionsWrapper wrap){
        List<Opportunity> opportunities_WithAccount = new List<Opportunity>();
        for(Integer i = 0; i < wrap.amount; i++){
            Opportunity opp= new Opportunity();
            opp.name = wrap.name + i;
            opp.StageName = wrap.stageName;
            opp.LOB__c = wrap.lineOfBusiness;
            opp.Company__c = wrap.company;
            opp.OppClosedDateTime__c = wrap.closedDate;
            opp.Journey_ID__c = wrap.journeyId;
            opp.OwnerId = wrap.ownerId;
            opp.Closed_Reason__c = wrap.closedReason;
            opportunities_WithAccount.add( buildOpportunity(opp));
        }
      
        List<ID> accountIds = generateAccountIds(wrap.name, wrap.amount);
        List<AgentRole__c> agentRoles = new List<AgentRole__c>();
        for(Integer i = 0; i < wrap.amount; i++){
            agentRoles.add(buildAgentRoleRecord(accountIds.get(i)));
            opportunities_WithAccount.get(i).accountId = accountIds.get(i);
        }
        Database.insert(agentRoles);
        return opportunities_WithAccount;
    }

    private Opportunity buildOpportunity(Opportunity sampleOpp){
        Opportunity opportunity = new Opportunity();
        opportunity.name = sampleOpp.name;
        opportunity.StageName = sampleOpp.StageName;
        opportunity.LOB__c = sampleOpp.LOB__c;
        opportunity.OppClosedDateTime__c = sampleOpp.OppClosedDateTime__c;
        opportunity.Journey_ID__c = sampleOpp.Journey_ID__c;
        opportunity.closeDate = System.today().addDays(30);
        opportunity.OwnerId = sampleOpp.OwnerId;
        opportunity.Company__c = sampleOpp.Company__c;
        opportunity.Closed_Reason__c = sampleOpp.Closed_Reason__c;
        return opportunity;
    }
    private void setCreatedDateToThreeMonthsPrior(List<Database.SaveResult> saveResults){
        DateTime threeMonthsPrior = getDateFromThreeMonthsPrior();
        bddHistOppWrap.setCreatedDateToThreeMonthsPrior(saveResults, threeMonthsPrior);
    }
     private DateTime getDateFromThreeMonthsPrior(){
        return DateTime.now().addMonths(-2);
    }
    private List<ID> generateAccountIds(String name, Integer amount){
        accounts = new List<Account>();
        List<Database.SaveResult> save_Results;
        List<ID> ids = new List<ID>();
        for(Integer i = 0; i < amount; i++){
            accounts.add(buildAccount(name + i));
        }

    	TestDataFactory_Account.byPassAccountBeforeTrigger();
    	save_Results = Database.insert(accounts);
    	
        return bddHistOppWrap.generateAccountIds(save_Results, ids);
    }
    private Account buildAccount(String name){
        Account account = TestDataFactory_Account.createIndividualCustomer(name,name);
        return account;
    }
    private static AgentRole__c buildAgentRoleRecord(String param_accountId) {
        AgentRole__c agentRole = new AgentRole__c (RelationshipNature__c = 'Ex-Customer',
                       Agent__c = userInfo.getUserId(), Customer__c = param_accountId);
        return agentRole;
    }
    private String removeLastCharacter(String content){
        return content.substring(0,content.length() - 1);
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
    private String getMonthAndYearFormatted(Date dateIn,String delimiter){
        String result;
        String month;
        String year = String.valueOf(dateIn.year());

        if(dateIn.month() < 10){
            month = '0' + String.valueOf(dateIn.month());
        }else{
            month = String.valueOf(dateIn.month());
        }
        result = month + delimiter + year;
        return result;
    }

    private class BDD_HistOppCampaignsVaribaleWrapper{
        List<Opportunity> bddHist_opportunities;
        Integer campaignMemberTotal;
    }

    private class BDD_HistOppCampaigns_StepDefinitionsWrap{
        private void whenTheHistoricalOpportunityCampaignBatchRuns(User batchProcessId){
            System.runAs(batchProcessId){
                Test.startTest();
                    Database.executeBatch(new Batch_HistoricalOpportunityCampaign(request), 200);
                Test.stopTest();
            }
        }

        private void validateCampaignMembers(List<CampaignMember> campaignMembers, ID campaignId, BDD_HistOppCampaignsVaribaleWrapper bddWrap){
            for(Integer i = 0; i < bddWrap.campaignMemberTotal;i++){
                isCampaignMemberAMemberOfCampaign(campaignMembers.get(i), campaignId);
                isCampaignMemberAssociatedToAContact(campaignMembers.get(i), bddWrap.bddHist_opportunities.get(i).account.personcontactid);
                isCampaignMemberStatusSetDefault(campaignMembers.get(i));
            }
        }

        private void isCampaignMemberStatusSetDefault(CampaignMember campaignMember){
            System.assert(campaignMember.Status__c!=null,'Status of CampaignMember should not be empty');
        }

        private void isCampaignMemberAMemberOfCampaign(CampaignMember campaignMember,ID campaignId){
            System.assertEquals(campaignId, campaignMember.CampaignId,'Expected Campaign Id is'+campaignId+'but actual is'+campaignMember.CampaignId);
        }

        private void isCampaignMemberAssociatedToAContact(CampaignMember campaignMember, ID contactId){
            System.assert(campaignMember.contactId != null,'Contact Id should not be empty');
        }

        private List<ID> generateAccountIds(List<Database.SaveResult> saveResults, List<ID> ids){
            for(Database.SaveResult saveResult: saveResults){
                ids.add(saveResult.getId());
            }
            return ids;
        }

        private void setCreatedDateToThreeMonthsPrior(List<Database.SaveResult> saveResults, DateTime threeMonthsPrior){
            for(Database.SaveResult saveResult:saveResults){
                setCreatedDate(saveResult, threeMonthsPrior);
            }
        }
        private void setCreatedDate(Database.SaveResult saveResult, DateTime dateTimeIn){
            Test.setCreatedDate(saveResult.getId(), dateTimeIn);
        }
    }
}
