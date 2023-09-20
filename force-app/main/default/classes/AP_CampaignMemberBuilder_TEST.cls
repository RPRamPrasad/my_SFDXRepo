@isTest
(seeAllData=false)
public with sharing class AP_CampaignMemberBuilder_TEST {
    
    static AP_CampaignMemberBuilder campaignMemberFromReportBulder;

    private static void init(){
        TestDataFactory_CampaignMember.byPassCampaignMemberTrigger();
        campaignMemberFromReportBulder = new AP_CampaignMemberBuilder();
    }
    @IsTest
    public static void buildCampaignMembersFromCampaignOwnerTest(){
        init();
        Map<ID,Set<ID>> userIdToContactIdsMap = new Map<ID,Set<ID>>();
        List<Campaign> campaigns = new List<Campaign>();
        List<CampaignMember> campaignMembers;
        User proxyUser;
        for(Integer i = 0; i < 2; i++){
            proxyUser = generateProxyUser();
            userIdToContactIdsMap.put(proxyUser.Id, generateContactIds('catFirstName', 'lastName', 2));
            campaigns.add(generateCampaign('AlexCampaign',proxyUser.Id));
        }
        Test.startTest();
            campaignMembers = campaignMemberFromReportBulder.buildContactCampaignMembersFromCampaignOwner(userIdToContactIdsMap,campaigns);
        Test.stopTest();
        System.assertEquals(4, campaignMembers.size(),'The size of Campaign Members should be 4');
        List<ID> contactIds = new List<ID>();
        contactIds.addAll(userIdToContactIdsMap.get(campaigns.get(0).OwnerId));
        contactIds.addAll(userIdToContactIdsMap.get(campaigns.get(1).OwnerId));

            System.assertEquals(contactIds.get(0),campaignMembers.get(0).ContactId,'contactId is not same');
            System.assertEquals(campaigns.get(0).id, campaignMembers.get(0).CampaignId,'Campaign Id is different');

            System.assertEquals(contactIds.get(1), campaignMembers.get(1).ContactId,'contactId is not same');
            System.assertEquals(campaigns.get(0).id, campaignMembers.get(1).CampaignId,'Campaign Id is different');

            System.assertEquals(contactIds.get(2),campaignMembers.get(2).ContactId,'contactId is not same');
            System.assertEquals(campaigns.get(1).id, campaignMembers.get(2).CampaignId,'Campaign Id is different');

            System.assertEquals(contactIds.get(3), campaignMembers.get(3).ContactId,'contactId is not same');
            System.assertEquals(campaigns.get(1).id, campaignMembers.get(3).CampaignId,'Campaign Id is different');
       

    }
    @IsTest
    public static void testBuildCampaignMembers(){
        init();
        Set<ID> contactIds = new Set<ID>();
        Contact contact;
        String contactId;
        for(Integer i = 0; i < 5; i++){
            contact = generateContact('Alex' + i,'kek');
            contactIds.add(contact.Id);
        }

        Campaign campaign =  generateCampaign('AlexCatCampaign');
        Test.startTest();
            List<CampaignMember> campaignMembers = campaignMemberFromReportBulder.buildCampaignMembersFromContacts(contactIds,campaign.Id);
        Test.stopTest();

        for(CampaignMember campaignMember:campaignMembers){
            System.assertEquals(campaign.Id, campaignMember.campaignId,'Campaign Id is different');
            System.assert(contactIds.contains(campaignMember.contactId),'contactIds does not contain campaignMember contactId');
        }
    }


    @IsTest
    public static void testBuildCampaignMember(){
        init();
        Contact contact = generateContact('alex','cat');
        
        Campaign campaign =  generateCampaign('AlexCatCampaign');
        Test.startTest();
            CampaignMember campaignMember = campaignMemberFromReportBulder.buildContactCampaignMember(contact.id,campaign.id);
            ID campaignMemberId = Database.insert(campaignMember).getId();
            campaignMember = [SELECT id, contactId,campaignId from campaignMember where id = :campaignMemberId];
        Test.stopTest();
        
        System.assertEquals(contact.id, campaignMember.contactId,'contactId is not same');
        System.assertEquals(campaign.id, campaignMember.campaignId,'Campaign Id is different');
    }
    private static Set<ID> generateContactIds(String firstName,String lastName, Integer amount){
        Set<ID> contactIds = new Set<ID>();
        Contact contact;
        for(Integer i = 0; i < amount; i++){
            contact = generateContact(firstName + i, lastName);
            contactIds.add(contact.id);
        }
        return contactIds;
    }
    private static Contact generateContact(String firstname, String lastname){
        Contact contact = TestDataFactory_Contact.generateContact(firstName,lastName);
        contact.id = Database.insert(contact).getId();
        return contact;
    }
    private static Campaign generateCampaign(String campaignName, ID ownerIdIn){
        Campaign campaign =  TestDataFactory_Campaign.generateCampaign(campaignName);
        campaign.OwnerId = ownerIdIn;
        campaign.id = Database.insert(campaign).getId();
        
        return campaign;
    }
    private static Campaign generateCampaign(String campaignName){
        Campaign campaign =  TestDataFactory_Campaign.generateCampaign(campaignName);
        campaign.id = Database.insert(campaign).getId();
        
        return campaign;
    }
    private static User generateProxyUser(){
        User testProxyUser = new User(Alias='cats',FirstName='alex',LastName='cat',Associate_ID__c='ASSOCIATE1',UserExternalID__c='ASSOCIATE1',Territory_Associate_ID__c='ASSOCIATE2');
       User proxyUser = UTIL_UserProvisioning_TEST.buildProxyUserRandomUsername(testProxyUser);
       Database.SaveResult result = Database.insert(proxyUser);
        proxyUser.Id = result.getId();
       return proxyUser;
   }
}