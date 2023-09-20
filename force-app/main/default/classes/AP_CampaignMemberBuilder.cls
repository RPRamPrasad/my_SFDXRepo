/**
 * @description AP_CampaignMemberBuilder 
 */
public with sharing class AP_CampaignMemberBuilder {
    /**
     * @description buildContactCampaignMembersFromCampaignOwner
     * @param userIdToContactIdsMap 
     * @param campaigns 
     * @return  `List<CampaignMember>`
     */
    public List<CampaignMember> buildContactCampaignMembersFromCampaignOwner(Map<ID,Set<ID>> userIdToContactIdsMap,List<Campaign> campaigns){
        List<CampaignMember> campaignMembers = new List<CampaignMember>();
        Set<ID> contactIds;
        for(Campaign campaign: campaigns){
            if(!userIdToContactIdsMap.isEmpty() && userIdToContactIdsMap.containsKey(campaign.OwnerId)){
                contactIds = userIdToContactIdsMap.get(campaign.OwnerId);
                campaignMembers.addAll(buildCampaignMembersFromContacts(contactIds,campaign.id));
            }
        }
        return campaignMembers;
    }

    /**
     * @description buildContactCampaignMembersFromCampaignOwner
     * @param userIdToContactIdsMap 
     * @param campaigns
     * @param contactPolicyDataMap 
     * @return  `List<CampaignMember>`
     */
    public List<CampaignMember> buildCampaignMembersFromServiceCampaign(Map<ID,Set<ID>> userIdToContactIdsMap, Map<String,String> contactPolicyDataMap,List<Campaign> campaigns){
        List<CampaignMember> campaignMembers = new List<CampaignMember>();
        Set<ID> contactIds;
        for(Campaign campaign: campaigns){
            if(!userIdToContactIdsMap.isEmpty() && userIdToContactIdsMap.containsKey(campaign.OwnerId)){
                contactIds = userIdToContactIdsMap.get(campaign.OwnerId);
                campaignMembers.addAll(buildServiceCampaignMembersFromContacts(contactIds,campaign.id,contactPolicyDataMap));
            }
        }
        return campaignMembers;
    }
    /**
     * @description buildCampaignMembersFromContacts
     * @param contactIdsIn 
     * @param campaignIdIn 
     * @return  `List<CampaignMember>`
     */
    public List<CampaignMember> buildCampaignMembersFromContacts(Set<ID> contactIdsIn, ID campaignIdIn){
        List<CampaignMember> campaignMembers = new List<CampaignMember>();
        for (String contactId : contactIdsIn) {
            campaignMembers.add(buildContactCampaignMember(contactId,campaignIdIn));
        }
        return campaignMembers;
    }
    /**
     * @description buildServiceCampaignMembersFromContacts
     * @param contactIdsIn 
     * @param campaignIdIn 
     *  @param contactPolicyDataMap
     * @return  `List<CampaignMember>`
     */
    public List<CampaignMember> buildServiceCampaignMembersFromContacts(Set<ID> contactIdsIn, ID campaignIdIn,Map<String,String> contactPolicyDataMap){
        List<CampaignMember> campaignMembers = new List<CampaignMember>();
        for (String contactId : contactIdsIn) {
            campaignMembers.add(buildContactCampaignMemberService(contactId,campaignIdIn,contactPolicyDataMap.get(contactId)));
        }
        return campaignMembers;
    }
    /**
     * @description buildContactCampaignMember
     * @param contactIdIn 
     * @param campaignIdIn 
     * @return  `CampaignMember`
     */
    public CampaignMember buildContactCampaignMember(ID contactIdIn, ID campaignIdIn){
        return new CampaignMember(ContactId = contactIdIn, CampaignId = campaignIdIn);
    }
    /**
     * @description buildContactCampaignMember
     * @param contactIdIn 
     * @param campaignIdIn 
     * @param policyDataIn
     * @return  `CampaignMember`
     */
    public CampaignMember buildContactCampaignMemberService(ID contactIdIn, ID campaignIdIn,String policyDataIn){
        return new CampaignMember(ContactId = contactIdIn, CampaignId = campaignIdIn, ExternalData__c = policyDataIn);
    }
}