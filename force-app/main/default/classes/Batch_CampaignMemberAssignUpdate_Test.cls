/**
  * @name Batch_CampaignMemberAssignUpdate_Test
  * @author Team Incognito
  * @createdDate 06/01/2022
  * @description Unit tests for Batch_CampaignMemberAssignmentUpdate batch class
*/

@isTest(seeAllData=false)

public with sharing class Batch_CampaignMemberAssignUpdate_Test {

  /**
    * @description Setup method used for building test data (must be called at beginning of test)
  */
  @TestSetup
  static void setUp(){
      bypassTriggers();
    
      User atm1 = TestDataFactory_User_Wrapper.generateAgentTeamMemberUser('ATM1', '12345678912');
      atm1.FederationIdentifier = 'fedId1';
      atm1 = TestDataFactory_User.insertUser(atm1);
      User atm2 = TestDataFactory_User_Wrapper.generateAgentTeamMemberUser('ATM2', '12345678934');
      atm2.FederationIdentifier = '';
      atm2 = TestDataFactory_User.insertUser(atm2);
          
      Contact contact1 = TestDataFactory_Contact.generateContact('firstnameCt1','lastnameCt');
      Contact contact2 = TestDataFactory_Contact.generateContact('firstnameCt2','lastnameCt');
      TestDataFactory_Contact.insertContact(contact1);
      TestDataFactory_Contact.insertContact(contact2);
      
      Campaign campaign = TestDataFactory_Campaign.generateCampaign();
      User adminUser = TestDataFactory_User.getSysAdminUser();
      campaign.OwnerId = adminUser.Id;
      campaign.Name = 'fedIdTest';
      campaign.CampaignMemberAssignmentChanged__c = false;
      campaign = TestDataFactory_Campaign.insertCampaign(campaign);
        
  }
  
  private static void bypassTriggers() {
      TestDataFactory_CampaignMember.byPassTrigger();
      TestDataFactory_CampaignMember.byPassCampaignMemberTrigger();
  }
  
  private static User createProcIdUser() {
      User processID = UTIL_UserProvisioning_TEST.buildUserAPIDataAdmin('CreateCamMemAssUpdApiUser@statefarm.com');   
      User adminUser = TestDataFactory_User.getSysAdminUser();
      
      System.runAs(adminUser) {
        insert processID;
          TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(processID);
        PermissionSetAssignment assignPermissionSet = TestDataFactory_PermissionSetAssignment.assignPermissionToUser(processID,'SF_CRM_CampMemberUpdate_PermSetPID');
        TestDataFactory_PermissionSetAssignment.insertPermissionSetAssignment(assignPermissionSet);
      }
      
      return processID;
  }  
    

  @isTest
  static void campaignMemberAssignUpdateSuccess() {
      User atm1 = [select Id from User where alias = 'ATM1'];
      User atm2 = [select Id from User where alias = 'ATM2'];
      
      Campaign campaign = [select Id from Campaign where name = 'fedIdTest'];
      
      Contact contact1 = [select Id from Contact where firstName = 'firstnameCt1'];
      Contact contact2 = [select Id from Contact where firstName = 'firstnameCt2'];
      
      CampaignMember campaignMember1 = TestDataFactory_CampaignMember.generateCampaignMember(campaign,contact1);
      CampaignMember campaignMember2 = TestDataFactory_CampaignMember.generateCampaignMember(campaign,contact2);
      campaignMember1.AssignedTo__c = atm1.Id;
      campaignMember1.CampaignId = campaign.Id;
      campaignMember2.AssignedTo__c = atm2.Id;
      campaignMember2.CampaignId = campaign.Id;
      
      campaignMember1 = TestDataFactory_CampaignMember.insertCampaignMember(campaignMember1);
      campaignMember2 = TestDataFactory_CampaignMember.insertCampaignMember(campaignMember2);
      
      User batchUser = createProcIdUser();
      
      System.runAs(batchUser){
        Test.StartTest();
        Database.executeBatch(new Batch_CampaignMemberAssignUpdate(), 200);
        Test.stopTest();
      }	
      
      CampaignMember campaignMemb1 = [Select Id, AssignedTo__c from CampaignMember where Id = :campaignMember1.id];
      CampaignMember campaignMemb2 = [Select Id, AssignedTo__c from CampaignMember where Id = :campaignMember2.id];
      
      system.assert(campaignMemb1.AssignedTo__c == atm1.Id, 'Assigned to value should be ' + campaignMember1.id + ' but the actual value is ' + campaignMemb1.AssignedTo__c);
      system.assert(campaignMemb2.AssignedTo__c == null, 'Assigned to value should be null but the actual value is ' + campaignMemb2.AssignedTo__c);
  }
}