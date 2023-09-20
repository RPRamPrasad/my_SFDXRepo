/**
 * @description AP_CampaignBuilder
 */
public with sharing class AP_CampaignBuilder {
    
    public static Map<String, Schema.Recordtypeinfo> campaignRecordTypeMap = Schema.Sobjecttype.Campaign.getRecordTypeInfosByDeveloperName();
    private static String name_Prepend = 'New Campaign';
    private static final String REPORT = 'Report';
    private static final String FULFILLMENT_PENDING = 'Fulfillment Pending';
    private static final String CUSTOMER_PROSPECT = 'Customer/Prospect';
    private static final String SERVICE = 'Service';
    
    /**
     * @description buildCampaignsForHistoricalOpportunitiesReport
     * @param userContactsMap 
     * @param userIdToAliasMap 
     * @param request 
     * @return  `List<Campaign>`
     */
    public List<Campaign> buildCampaignsForHistoricalOpportunitiesReport(Map<ID,Set<ID>> userContactsMap,Map<ID,String> userIdToAliasMap,AP_BatchReportRequest request){
          List<Campaign> campaigns = new List<Campaign>();
          Set<ID> userIds =  userIdToAliasMap.keySet();
          for(ID userID: userIds){
              campaigns.add(buildCampaignForHistoricalOpportunitiesReport(userID,userIdToAliasMap.get(userID),request));
          }  
          return campaigns;
    } 

    /**
     * @description buildCampaignsForHistoricalOpportunitiesReport
     * @param userContactsMap 
     * @param userIdToAliasMap 
     * @param request 
     * @return  `List<Campaign>`
     */
    public List<Campaign> buildCampaignsForServiceCampaign(AP_CampaignBuilderRequest request){
        List<Campaign> campaigns = new List<Campaign>();
        for(ID userID: request.userContactsMapIn.keySet()){
            campaigns.add(buildCampaignForServiceCampaign(request,request.associateExternalIdMapIn.get(userID),userId));
        }  
        return campaigns;
  }
    /**
     * @description buildCampaignForHistoricalOpportunitiesReport 
     * @param userId 
     * @param alias 
     * @param request 
     * @return  `Campaign`
     */
    public Campaign buildCampaignForHistoricalOpportunitiesReport(ID userId, String alias,AP_BatchReportRequest request){
        name_Prepend = request.getCampaignName();
		Date startDate = Date.today();
        Date endDate = startDate.addDays(90);
        String status = request.getCampaignStatus();
		ID recordTypeId = campaignRecordTypeMap.get(UTIL_Constants.CUSTOMER_PROSPECT_CAMPAIGN).RecordTypeId;
        ID initiatedById = getCurrentUserID();
        ID ownerId = userId;
        String name = name_Prepend + '- ' + getMonthAndYearFormatted(startDate, '/') + '- ' + removeLastCharacter(alias);
        String source = request.getCampaignSource();
        String description = request.getCampaignDescription();
       	
        AP_CampaignBuilderWrapper wrap = new AP_CampaignBuilderWrapper();
        wrap.nameIn = name;
        wrap.recordTypeIdIn = recordTypeId;
        wrap.statusIn = status;
        wrap.startDateIn = startDate;
        wrap.endDateIn = endDate;
        wrap.initiatedByIn = initiatedById;
        wrap.ownerIdIn = ownerId;
        wrap.sourceIn = source;
        wrap.description = description;
		return buildCampaign(wrap);        
    }

    /**
     * @description buildCampaignForHistoricalOpportunitiesReport 
     * @param userId 
     * @param alias 
     * @param request 
     * @return  `Campaign`
     */
    public Campaign buildCampaignForServiceCampaign(AP_CampaignBuilderRequest request, String externalId,String userId){
        Date startDate = request.startDateIn;
        Date endDate = startDate.addDays(90);
        String statusIn = FULFILLMENT_PENDING;
		ID recordTypeId = campaignRecordTypeMap.get(SERVICE).RecordTypeId;
        ID initiatedById = getCurrentUserID();
        ID ownerId = userId;
        String name = request.campaignNameIn;
        String externalIdValue = externalId;
        String source = REPORT;
        String type = CUSTOMER_PROSPECT;
        //String description = request.getCampaignDescription();
       	
        AP_CampaignBuilderWrapper wrap = new AP_CampaignBuilderWrapper();
        wrap.nameIn = name;
        wrap.recordTypeIdIn = recordTypeId;
        wrap.startDateIn = startDate;
        wrap.endDateIn = endDate;
        wrap.initiatedByIn = initiatedById;
        wrap.ownerIdIn = ownerId;
        wrap.externalId =externalIdValue;
        wrap.statusIn = FULFILLMENT_PENDING; 
        wrap.sourceIn = source;
       return buildCampaign(wrap);        
    }
    
    /**
     * @description AP_CampaignBuilderWrapper
     */
    public class AP_CampaignBuilderWrapper{
       public String nameIn;
       public String recordTypeIdIn;
       public String statusIn;
       public  Date startDateIn;
       public Date endDateIn;
       public  ID initiatedByIn;
       public  ID ownerIdIn;
       public  String sourceIn;
       public  String description;
       public String externalId;
    }
    /**
     * @description buildCampaign
     * @param wrap
     * @return  `Campaign`
     */
    public Campaign buildCampaign(AP_CampaignBuilderWrapper wrap){
        Campaign campaign = new Campaign(Name = wrap.nameIn);
        campaign.RecordTypeId = wrap.recordTypeIdIn;
        campaign.OwnerId = wrap.ownerIdIn;
        campaign.Status = wrap.statusIn;
        campaign.StartDate = wrap.startDateIn;
        campaign.EndDate = wrap.endDateIn;
        campaign.Initiated_By_Id__c = wrap.initiatedByIn;
        campaign.OwnerId = wrap.ownerIdIn;
        campaign.Source__c = wrap.sourceIn;
        campaign.Description = wrap.description;  
        campaign.External_Campaign_ID__c = wrap.externalId;   
        return campaign; 
    }
    private String removeLastCharacter(String content){
        return content.substring(0,content.length() - 1);
    }
    private ID getCurrentUserID(){
        return System.UserInfo.getUserId();
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
    /**
     * @description AP_CampaignBuilderRequest
     */
    public class AP_CampaignBuilderRequest{
       public Map<ID,Set<ID>> userContactsMapIn;
       public Map<String, String> associateExternalIdMapIn;
       public String campaignNameIn;
       public  Date startDateIn;
    }
}