@isTest
(seeAllData=false)
public class AP_CampaignBuilder_TEST {
   
    static AP_CampaignBuilder campaignFromReportBuilder;
    static AP_BatchReportRequest request = retrieveReportData();
    static Date today;
     /**
     * @description init
     */
    public static void init(){
        campaignFromReportBuilder = new AP_CampaignBuilder();
        today = Date.today();
    }
    private static AP_BatchReportRequest retrieveReportData(){
		AP_RetrieveBatchReportFieldData  reportFieldValue = new AP_RetrieveBatchReportFieldData();
		return reportFieldValue.setBatchReportRequest('Batch_NeglectedAbandonedAutoOpportunity');
	}
   @IsTest
   public static void buildCampaignsForHistoricalOpportunityTest(){
       init();
       Map<ID,Set<ID>> userToOpportunitiesMap = new Map<ID,Set<ID>>(); 
       Map<ID,String> userIdToAliasMap = new Map<ID,String>();
       User proxyUser;
       Id proxyUserId;
       String proxyUserAlias;
       for(Integer i = 0; i < 2; i++){
            proxyUser = getProxyUser();
            proxyUserId = proxyUser.Id;
            proxyUserAlias = proxyUser.alias;
            userToOpportunitiesMap.put(proxyUserId, getIdsOfOpportunities(i + 1));
            userIdToAliasMap.put(proxyUserId, proxyUserAlias);
        }

       Test.startTest();
        List<Campaign> campaigns = campaignFromReportBuilder.buildCampaignsForHistoricalOpportunitiesReport(userToOpportunitiesMap,userIdToAliasMap, request);
        List<ID> campaignIds = new List<ID>();
        Database.SaveResult[] saveResults = Database.insert(campaigns, false);
        for(Database.SaveResult saveResult: saveResults){
            campaignIds.add(saveResult.getId());
        }
        campaigns = [SELECT id, name,Description,Assigned_To__c, startdate,RecordTypeId,OwnerId,Status,EndDate,Initiated_By_Id__c,Source__c,type from Campaign where id in :campaignIds];
        String name = request.getCampaignName() + '- ' + getMonthAndYearFormatted(today, '/') + '- cats';
        for(Campaign campaign: campaigns){
            System.assertEquals(name,campaign.name,'Name is not matched');
            System.assertEquals('Customer/Prospect',Campaign.Type,'Campaign Type is not equal to Customer/Prospect');
            System.assertEquals(today,campaign.startDate,'startDate is not equal to today');
            System.assertEquals(true,userToOpportunitiesMap.containsKey(campaign.OwnerId),'userToOpportunitiesMap does not contain OwnerId');
            System.assertEquals(today.addDays(90),campaign.EndDate,'EndDate is not same');
            System.assertEquals(null,campaign.Assigned_To__c,'Assigned_To is not null');
            System.assertEquals(System.UserInfo.getUserId(),campaign.Initiated_By_Id__c,'Expected Initiated User is'+System.UserInfo.getUserId()+', but actual value is'+campaign.Initiated_By_Id__c);
            System.assertEquals('Report',campaign.Source__c,'Campaign Source is not equal to Report');
            System.assert(campaign.Description!=null,'Description is empty');
        }
       Test.stopTest();
       
   }
   @IsTest
   public static void buildCampaignForHistoricalOpportunityTest(){
       init();
       User testProxyUser = new User(Alias='cats',FirstName='alex',LastName='cat',Associate_ID__c='ASSOCIATE1',UserExternalID__c='ASSOCIATE1',Territory_Associate_ID__c='ASSOCIATE2');
       User proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser(testProxyUser);
       insert proxyUser;   
       String name = request.getCampaignName() + '- ' + getMonthAndYearFormatted(today, '/') + '- cats';                            
       Test.startTest();
        Campaign campaign = campaignFromReportBuilder.buildCampaignForHistoricalOpportunitiesReport(proxyUser.id,proxyUser.alias,request);
        insert campaign;
        campaign = [SELECT id, name,Description,Assigned_To__c, startdate,RecordTypeId,OwnerId,Status,EndDate,Initiated_By_Id__c,Source__c,type from Campaign where name = :campaign.name and ownerId = :proxyUser.Id];

        
        System.assertEquals(name,campaign.name,'Name is not matched');
        System.assertEquals('Customer/Prospect',Campaign.Type,'Campaign Type is not equal to Customer/Prospect');
        System.assertEquals(today,campaign.startDate,'startDate is not equal to today');
        System.assertEquals(today.addDays(90),campaign.EndDate,'Expected End Date is'+today.addDays(90)+', but actual value is'+campaign.EndDate);
        System.assertEquals(proxyUser.id,campaign.OwnerId,'Expected Owner Id is'+proxyUser.id+', but actual value is'+campaign.OwnerId);
        System.assertEquals(null,campaign.Assigned_To__c,'Assigned_To is not null');
        System.assertEquals(System.UserInfo.getUserId(),campaign.Initiated_By_Id__c,'Expected Initiated User is'+System.UserInfo.getUserId()+', but actual value is'+campaign.Initiated_By_Id__c);
        System.assertEquals('Report',campaign.Source__c,'Campaign Source is not equal to Report');
        System.assert(campaign.Description!=null,'Description is empty');
       Test.stopTest();
       
   }
    @IsTest
   public static void buildCampaignTest(){
      init();

        Date endDate = today.addDays(90);
        String status = 'meow';
		ID recordTypeId = AP_CampaignBuilder.campaignRecordTypeMap.get(UTIL_Constants.CUSTOMER_PROSPECT_CAMPAIGN).RecordTypeId;
        ID initiatedById = System.UserInfo.getUserId();
        ID ownerId = System.UserInfo.getUserId();
        String name = 'kitty';
        String source = 'cat';                         
        String description = 'Campaign Description';
       Test.startTest();
       AP_CampaignBuilder.AP_CampaignBuilderWrapper wrap = new AP_CampaignBuilder.AP_CampaignBuilderWrapper();
        wrap.nameIn = name;
        wrap.recordTypeIdIn = recordTypeId;
        wrap.statusIn = status;
        wrap.startDateIn = today;
        wrap.endDateIn = endDate;
        wrap.initiatedByIn = initiatedById;
        wrap.ownerIdIn = ownerId;
        wrap.sourceIn = source;
        wrap.description = description; 
        Campaign campaign = campaignFromReportBuilder.buildCampaign(wrap);
        System.assertEquals(name,campaign.name,'Expected name is'+name+', but actual value is'+campaign.name);
        System.assertEquals(today,campaign.startDate,'Expected Start Date is'+today+', but actual value is'+campaign.startDate);
        System.assertEquals(endDate,campaign.EndDate,'Expected End Date is'+endDate+', but actual value is'+campaign.EndDate);
        System.assertEquals(null,campaign.Assigned_To__c,'Expected Assigned To is null, but actual is'+campaign.Assigned_To__c);
        System.assertEquals(ownerId,campaign.OwnerId,'Expected Owner Id is'+ownerId+', but actual value is'+campaign.OwnerId);
        System.assertEquals(initiatedById,campaign.Initiated_By_Id__c,'Expected Initiated By Id is'+initiatedById+', but actual value is'+campaign.Initiated_By_Id__c);
        System.assertEquals('cat',campaign.Source__c,'Expected Source is cat, but actual value is'+campaign.Source__c);
        System.assert(campaign.Description!=null,'Description should not be empty');
       Test.stopTest();
       
   }
   private static Set<ID> getIdsOfOpportunities(Integer numberOfOpportunities){

       List<Opportunity> opportunities = new List<Opportunity>();
       Set<ID> opportunityIds =new Set<ID>();
       for(Integer i = 0; i < 10;i ++){
           opportunities.add(TestDataFactory_Opportunity.generateOpportunity('cat' + i));
       }
       Database.SaveResult[] saveResults = Database.insert(opportunities, false);
       for(Database.SaveResult saveResult: saveResults){
           opportunityIds.add(saveResult.getId());
       }
       return opportunityIds;
   }
   private static User getProxyUser(){
    User testProxyUser = new User(Alias='cats',FirstName='alex',LastName='cat',Associate_ID__c='ASSOCIATE1',UserExternalID__c='ASSOCIATE1',Territory_Associate_ID__c='ASSOCIATE2');
       User proxyUser = UTIL_UserProvisioning_TEST.buildProxyUserRandomUsername(testProxyUser);
       Database.SaveResult result = Database.insert(proxyUser);
       proxyUser.id = result.getId();
       return proxyUser;
   }
   private static String getMonthAndYearFormatted(Date dateIn,String delimiter){
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
}