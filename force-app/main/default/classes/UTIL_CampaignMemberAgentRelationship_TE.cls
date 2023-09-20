@isTest (seeAllData=false)
public with sharing class UTIL_CampaignMemberAgentRelationship_TE {
    
    private static User adminUser;
    private static User agentUser;
    private static User proxyUser;

    private static Campaign customerProsectCampaign;
    private static Campaign leadCampaign;
/**
 * @description setup
 */
    @TestSetup
    public static void setup() {
        TestDataFactory_Campaign.TestDataFactory_CampaignWrapper wrap = new TestDataFactory_Campaign.TestDataFactory_CampaignWrapper();
        wrap.param_UserName = UTIL_TestUsername_TEST.getTestUsername();
        wrap.param_profileId = TestDataFactory_Campaign.adminProfileId;
        wrap.param_associateId = '';
        wrap.param_servicingAgentAssociateId = '';
        wrap.param_externalId = '';
        adminUser = TestDataFactory_Campaign.buildUser(wrap);
        System.runAs(adminUser) {
            setEnvironment();
            UTIL_UserProvisioning_TEST.setUpAgentUser(1);
            proxyUser = UTIL_UserProvisioning_TEST.getAgentProxyUser(1);
            customerProsectCampaign = TestDataFactory_Campaign.setUpCustomerProspectCampaign(proxyUser);
            leadCampaign = TestDataFactory_Campaign.setUpUploadLeadIndividualCampaign(proxyUser);
            
        }
    }

    private static void setEnvironment(){
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        TestDataFactory_CampaignMember.byPassTrigger();
    }

    @IsTest
    public static void testAccountCampaignCampaignMembersWithRelationshipsAreAdded() {
        customerProsectCampaign = TestDataFactory_Campaign.retrieveCustomerProspectCampaign();
        TestDataFactory_Campaign.TestDataFactory_CampaignWrapper wrap = new TestDataFactory_Campaign.TestDataFactory_CampaignWrapper();
        wrap.param_UserName = UTIL_TestUsername_TEST.getTestUsername();
        wrap.param_profileId = TestDataFactory_Campaign.adminProfileId;
        wrap.param_associateId = '';
        wrap.param_servicingAgentAssociateId = '';
        wrap.param_externalId = '';
        adminUser = TestDataFactory_Campaign.buildUser(wrap);
        agentUser = UTIL_UserProvisioning_TEST.getAgentUser(1);
        
        System.runAs(adminUser) {

            TestDataFactory_CampaignMember.TestDataFactory_CampaignMemberWrapperClass wrapper = new TestDataFactory_CampaignMember.TestDataFactory_CampaignMemberWrapperClass();
            wrapper.count = 3;
            wrapper.campaign = customerProsectCampaign;
            wrapper.systemUser = adminUser;
            wrapper.agentUser = agentUser; 
            TestDataFactory_CampaignMember.setUpMultipleAccountCampaignMember(wrapper);
            List<CampaignMember> actualCampaignMembers = TestDataFactory_CampaignMember.retrieveAllCampaignMembersForCampaign(customerProsectCampaign);

            System.assertEquals(3, actualCampaignMembers.size(),'Size of actual Campaign Members should be 3');
        }
        
    }

    @IsTest
    public static void testAccountCampaignCampaignMembersWithoutRelationshipsAreNotAdded() {
        customerProsectCampaign = TestDataFactory_Campaign.retrieveCustomerProspectCampaign();
        TestDataFactory_Campaign.TestDataFactory_CampaignWrapper wrap = new TestDataFactory_Campaign.TestDataFactory_CampaignWrapper();
        wrap.param_UserName = UTIL_TestUsername_TEST.getTestUsername();
        wrap.param_profileId = TestDataFactory_Campaign.adminProfileId;
        wrap.param_associateId = '';
        wrap.param_servicingAgentAssociateId = '';
        wrap.param_externalId = '';
        adminUser = TestDataFactory_Campaign.buildUser(wrap);
        agentUser = UTIL_UserProvisioning_TEST.getAgentUser(1);
        
        System.runAs(adminUser) {
            Contact noRelationshipContact = TestDataFactory_Contact.generateContact('Steve', 'Urkle');
            noRelationshipContact.ClientIdentifier__c = 'TESTNOMATCH';
            TestDataFactory_Contact.insertContact(noRelationshipContact);

            CampaignMember noMatchCampaignMember = TestDataFactory_CampaignMember.generateCampaignMember(customerProsectCampaign, noRelationshipContact);
            Database.SaveResult saveResults = Database.insert(noMatchCampaignMember, false);
            List<CampaignMember> actualCampaignMembers = TestDataFactory_CampaignMember.retrieveAllCampaignMembersForCampaign(customerProsectCampaign);
            
            System.assertEquals(0, actualCampaignMembers.size(),'Size of actual Campaign Members should be 0');
            System.assertEquals(false, saveResults.isSuccess(),'Expected Success is false, but actual value is'+saveResults.isSuccess());
            System.assertEquals('No relationship found between campaign member and agent', saveResults.getErrors()[0].getMessage(),'Expected getMessage is \'No relationship found between campaign member and agent\', but actual value is'+saveResults.getErrors()[0].getMessage());
        }
    }

    @IsTest
    public static void testAccountCampaignCampaignMembersWithoutRelationshipsAreNotAddedReportCampaign() {
        customerProsectCampaign = TestDataFactory_Campaign.retrieveCustomerProspectCampaign();
        customerProsectCampaign.Source__c = 'Report';
        update customerProsectCampaign;

        TestDataFactory_Campaign.TestDataFactory_CampaignWrapper wrap = new TestDataFactory_Campaign.TestDataFactory_CampaignWrapper();
        wrap.param_UserName = UTIL_TestUsername_TEST.getTestUsername();
        wrap.param_profileId = TestDataFactory_Campaign.adminProfileId;
        wrap.param_associateId = '';
        wrap.param_servicingAgentAssociateId = '';
        wrap.param_externalId = '';
        adminUser = TestDataFactory_Campaign.buildUser(wrap);
        agentUser = UTIL_UserProvisioning_TEST.getAgentUser(1);
        
        System.runAs(adminUser) {
            Contact noRelationshipContact = TestDataFactory_Contact.generateContact('Steve', 'Urkle');
            noRelationshipContact.ClientIdentifier__c = 'TESTNOMATCH';
            TestDataFactory_Contact.insertContact(noRelationshipContact);

            CampaignMember noMatchCampaignMember = TestDataFactory_CampaignMember.generateCampaignMember(customerProsectCampaign, noRelationshipContact);
            Database.SaveResult saveResults = Database.insert(noMatchCampaignMember, false);
            List<CampaignMember> actualCampaignMembers = TestDataFactory_CampaignMember.retrieveAllCampaignMembersForCampaign(customerProsectCampaign);
            
            System.assertEquals(1, actualCampaignMembers.size(),'Size of actual Campaign Members should be 1');
            System.assertEquals(true, saveResults.isSuccess(),'Expected Success is true, but actual value is'+saveResults.isSuccess());
        }
    }

    @IsTest
    public static void testLeadCampaignCampaignMembersAreAdded() {
        leadCampaign = TestDataFactory_Campaign.retrieveLeadUploadIndividualCampaign();

        TestDataFactory_Campaign.TestDataFactory_CampaignWrapper wrap = new TestDataFactory_Campaign.TestDataFactory_CampaignWrapper();
        wrap.param_UserName = UTIL_TestUsername_TEST.getTestUsername();
        wrap.param_profileId = TestDataFactory_Campaign.adminProfileId;
        wrap.param_associateId = '';
        wrap.param_servicingAgentAssociateId = '';
        wrap.param_externalId = '';
        adminUser = TestDataFactory_Campaign.buildUser(wrap);
        agentUser = UTIL_UserProvisioning_TEST.getAgentUser(1);
        proxyUser = UTIL_UserProvisioning_TEST.getAgentProxyUser(1);

        System.runAs(adminUser) {
            TestDataFactory_CampaignMember.setUpLeadCampaignMember(leadCampaign, proxyUser);

            List<CampaignMember> actualCampaignMembers = TestDataFactory_CampaignMember.retrieveAllCampaignMembersForCampaign(leadCampaign);
            System.assertEquals(1, actualCampaignMembers.size(),'Size of actual Campaign Members should be 1');
        }
    }

    @IsTest
    public static void testCampaignMixtureCampaignMembersAreAddedAppropriately() {
        TestDataFactory_Campaign.TestDataFactory_CampaignWrapper wrap = new TestDataFactory_Campaign.TestDataFactory_CampaignWrapper();
        wrap.param_UserName = UTIL_TestUsername_TEST.getTestUsername();
        wrap.param_profileId = TestDataFactory_Campaign.adminProfileId;
        wrap.param_associateId = '';
        wrap.param_servicingAgentAssociateId = '';
        wrap.param_externalId = '';
        adminUser = TestDataFactory_Campaign.buildUser(wrap);       
        leadCampaign = TestDataFactory_Campaign.retrieveLeadUploadIndividualCampaign();
        customerProsectCampaign = TestDataFactory_Campaign.retrieveCustomerProspectCampaign();
        
        agentUser = UTIL_UserProvisioning_TEST.getAgentUser(1);
        proxyUser = UTIL_UserProvisioning_TEST.getAgentProxyUser(1);

        System.runAs(adminUser) {
            TestDataFactory_CampaignMember.TestDataFactory_CampaignMemberWrapper wrapper = new TestDataFactory_CampaignMember.TestDataFactory_CampaignMemberWrapper();
            wrapper.count = 3;
            wrapper.campaign = customerProsectCampaign;
            wrapper.systemUser = adminUser;
            wrapper.agentUser = agentUser;
            wrapper.insertCampaignMembers = false;
            List<CampaignMember> campaignMembersToAdd = TestDataFactory_CampaignMember.setUpMultipleAccountCampaignMember(wrapper);
            
            Contact contactToDeleteRole = [SELECT ID, CLientIdentifier__c
                                           FROM Contact 
                                           WHERE ID = :campaignMembersToAdd[2].ContactId
                                           LIMIT 1];

            AgentRole__c agentRole = [SELECT ID
                                      FROM AgentRole__c 
                                      WHERE AgentRoleIdentifier__c = :(agentUser.Associate_ID__c + '~' + contactToDeleteRole.ClientIdentifier__c)
                                      LIMIT 1];

            delete agentRole;

            campaignMembersToAdd.add(TestDataFactory_CampaignMember.setUpLeadCampaignMember(leadCampaign, proxyUser));

            Database.insert(campaignMembersToAdd, false);

            List<CampaignMember> actualCustomerCampaignMembers = TestDataFactory_CampaignMember.retrieveAllCampaignMembersForCampaign(customerProsectCampaign);

            System.assertEquals(2, actualCustomerCampaignMembers.size(),'Size of actual Customer Campaign Members should be 2');

            List<CampaignMember> actualLeadCampaignMembers = TestDataFactory_CampaignMember.retrieveAllCampaignMembersForCampaign(leadCampaign);
            System.assertEquals(1, actualLeadCampaignMembers.size(),'Size of actual Lead Campaign Members should be 1');
        }
    }

    @IsTest
    public static void testAgentRelationshipQueriesDontRunIfNoContacts(){
        proxyUser = UTIL_UserProvisioning_TEST.getAgentProxyUser(1);
        leadCampaign = TestDataFactory_Campaign.retrieveLeadUploadIndividualCampaign();
        CampaignMember leadCampaignMember = TestDataFactory_CampaignMember.setUpLeadCampaignMember(leadCampaign,proxyUser);

        List<CampaignMember> members = new List<CampaignMember>();
        members.add(leadCampaignMember);

        TestDataFactory_Campaign.TestDataFactory_CampaignWrapper wrap = new TestDataFactory_Campaign.TestDataFactory_CampaignWrapper();
        wrap.param_UserName = UTIL_TestUsername_TEST.getTestUsername();
        wrap.param_profileId = TestDataFactory_Campaign.getProfileId(UTIL_Constants.NO_ACCESS_PROFILE_NAME);
        User noAccessUser = TestDataFactory_Campaign.buildUser(wrap);

        String errorMessage = '';
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(noAccessUser);
        System.runAs(noAccessUser) {
            try {
                UTIL_CampaignMemberAgentRelationship.verifyCampaignMemberAgentRelationship(members);
            } catch (Exception e) {
                errorMessage = e.getMessage();
            }
        }
        System.assertEquals('', errorMessage, 'Error should not be thrown');
    }
}
