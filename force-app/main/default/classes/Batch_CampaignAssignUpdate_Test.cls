/**
  * @name Batch_CampaignAssignUpdate_Test
  * @author Team Incognito
  * @createdDate 07/11/2022
  * @description Unit tests for Batch_CampaignAssignUpdate_Test batch class
*/

@isTest(seeAllData=false)

public with sharing class Batch_CampaignAssignUpdate_Test {
  
  /**
  * @description Setup method used for building test data (must be called at beginning of test)
  */
  
  @TestSetup
  static void setUp(){
      bypassTriggers();
    
      User atm1 = TestDataFactory_User_Wrapper.generateAgentTeamMemberUser('ATM1', '12345678912');
      atm1.FirstName = 'ATM1';
      atm1.LastName = 'LastName';
      atm1 = TestDataFactory_User.insertUser(atm1);
      User atm2 = TestDataFactory_User_Wrapper.generateAgentTeamMemberUser('ATM2', '12345678934');
      atm2.FirstName = 'ATM2';
      atm2.LastName = 'LastName';
      atm2 = TestDataFactory_User.insertUser(atm2);
  }
  
  private static void bypassTriggers() {
      TestDataFactory_CampaignMember.byPassTrigger();
      TestDataFactory_CampaignMember.byPassCampaignMemberTrigger();
  }
  
  private static User createProcIdUser() {
      User processID = UTIL_UserProvisioning_TEST.buildUserAPIDataAdmin('CreateCamAssUpdApiUser@statefarm.com');   
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
  static void testSingleAtmAssignedCampaignMembers() {
      User atm1 = [select Id,Name from User where alias = 'ATM1'];
      User atm2 = [select Id,Name from User where alias = 'ATM2'];
      
      Campaign campaign = TestDataFactory_Campaign.generateCampaign('fedIdTest');
      User adminUser = TestDataFactory_User.getSysAdminUser();
      campaign.OwnerId = adminUser.Id;
      campaign.CampaignMemberAssignmentChanged__c = true;
      campaign.Assigned_to_Campaign__c = atm1.Name + ' | ' + atm2.Name;
      campaign.CampaignMembersAssignedToList__c = atm1.Id + '|' + atm2.Id;
      campaign = TestDataFactory_Campaign.insertCampaign(campaign);

      Contact contact1 = TestDataFactory_Contact.generateContact('firstnameCt1','lastnameCt');
      Contact contact2 = TestDataFactory_Contact.generateContact('firstnameCt2','lastnameCt');
      TestDataFactory_Contact.insertContact(contact1);
      TestDataFactory_Contact.insertContact(contact2);

      CampaignMember campaignMember1 = TestDataFactory_CampaignMember.generateCampaignMember(campaign,contact1);
      CampaignMember campaignMember2 = TestDataFactory_CampaignMember.generateCampaignMember(campaign,contact2);
      campaignMember1.AssignedTo__c = atm1.Id;
      campaignMember1.CampaignId = campaign.Id;
      campaignMember2.AssignedTo__c = null;
      campaignMember2.CampaignId = campaign.Id;
      
      campaignMember1 = TestDataFactory_CampaignMember.insertCampaignMember(campaignMember1);
      campaignMember2 = TestDataFactory_CampaignMember.insertCampaignMember(campaignMember2);
      
      User batchUser = createProcIdUser();
      System.runAs(batchUser){
        Test.StartTest();
        Database.executeBatch(new Batch_CampaignAssignUpdate(), 200);
        Test.stopTest();
      }	
                
      Campaign camp = [Select Id, Assigned_to_Campaign__c, CampaignMembersAssignedToList__c from Campaign where Id = :campaign.Id];
      
      system.assert(camp.CampaignMembersAssignedToList__c == atm1.Id, 'CampaignMembersAssignedToList__c value should be equal to' + atm1.id + ' but the actual value is ' + camp.CampaignMembersAssignedToList__c);
      system.assert(camp.Assigned_to_Campaign__c == atm1.Name, 'Assigned_to_Campaign__c value should be equal to' + atm1.Name + ' but the actual value is ' + camp.Assigned_to_Campaign__c);
    
  }

  @isTest
  static void testMultipleAtmAssignedCampaignMembers() {
      User atm1 = [select Id,Name from User where alias = 'ATM1'];
      User atm2 = [select Id,Name from User where alias = 'ATM2'];
      
      Campaign campaign = TestDataFactory_Campaign.generateCampaign('fedIdTest');
      User adminUser = TestDataFactory_User.getSysAdminUser();
      campaign.OwnerId = adminUser.Id;
      campaign.CampaignMemberAssignmentChanged__c = true;
      campaign.Assigned_to_Campaign__c = atm1.Name + ' | ' + atm2.Name;
      campaign.CampaignMembersAssignedToList__c = atm1.Id + '|' + atm2.Id;
      campaign = TestDataFactory_Campaign.insertCampaign(campaign);

      Contact contact1 = TestDataFactory_Contact.generateContact('firstnameCt1','lastnameCt');
      Contact contact2 = TestDataFactory_Contact.generateContact('firstnameCt2','lastnameCt');
      TestDataFactory_Contact.insertContact(contact1);
      TestDataFactory_Contact.insertContact(contact2);

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
        Database.executeBatch(new Batch_CampaignAssignUpdate(), 200);
        Test.stopTest();
      }	
                
      Campaign camp = [Select Id, Assigned_to_Campaign__c, CampaignMembersAssignedToList__c from Campaign where Id = :campaign.Id];
      
      system.assert(camp.CampaignMembersAssignedToList__c == atm1.Id + '|' + atm2.Id, 'CampaignMembersAssignedToList__c value should be equal to' + atm1.Id + '|' + atm2.Id + ' but the actual value is ' + camp.CampaignMembersAssignedToList__c);
      system.assert(camp.Assigned_to_Campaign__c == atm1.Name + ' | ' + atm2.Name, 'Assigned_to_Campaign__c value should be equal to' + atm1.Name + ' | ' + atm2.Name + ' but the actual value is ' + camp.Assigned_to_Campaign__c);
    
  }

  @isTest
  static void testNoAtmAssignedCampaignMembers() {
      User atm1 = [select Id,Name from User where alias = 'ATM1'];
      User atm2 = [select Id,Name from User where alias = 'ATM2'];
      
      Campaign campaign = TestDataFactory_Campaign.generateCampaign('fedIdTest');
      User adminUser = TestDataFactory_User.getSysAdminUser();
      campaign.OwnerId = adminUser.Id;
      campaign.CampaignMemberAssignmentChanged__c = true;
      campaign.Assigned_to_Campaign__c = atm1.Name + ' | ' + atm2.Name;
      campaign.CampaignMembersAssignedToList__c = atm1.Id + '|' + atm2.Id;
      campaign = TestDataFactory_Campaign.insertCampaign(campaign);

      Contact contact1 = TestDataFactory_Contact.generateContact('firstnameCt1','lastnameCt');
      Contact contact2 = TestDataFactory_Contact.generateContact('firstnameCt2','lastnameCt');
      TestDataFactory_Contact.insertContact(contact1);
      TestDataFactory_Contact.insertContact(contact2);

      CampaignMember campaignMember1 = TestDataFactory_CampaignMember.generateCampaignMember(campaign,contact1);
      CampaignMember campaignMember2 = TestDataFactory_CampaignMember.generateCampaignMember(campaign,contact2);
      campaignMember1.AssignedTo__c = null;
      campaignMember1.CampaignId = campaign.Id;
      campaignMember2.AssignedTo__c = null;
      campaignMember2.CampaignId = campaign.Id;
      
      campaignMember1 = TestDataFactory_CampaignMember.insertCampaignMember(campaignMember1);
      campaignMember2 = TestDataFactory_CampaignMember.insertCampaignMember(campaignMember2);
      
      User batchUser = createProcIdUser();
      System.runAs(batchUser){
        Test.StartTest();
        Database.executeBatch(new Batch_CampaignAssignUpdate(), 200);
        Test.stopTest();
      }	
                
      Campaign camp = [Select Id, Assigned_to_Campaign__c, CampaignMembersAssignedToList__c from Campaign where Id = :campaign.Id];
      
      system.assert(camp.CampaignMembersAssignedToList__c == null, 'CampaignMembersAssignedToList__c value should be equal to null but the actual value is ' + camp.CampaignMembersAssignedToList__c);
      system.assert(camp.Assigned_to_Campaign__c == null, 'Assigned_to_Campaign__c value should be equal to null but the actual value is ' + camp.Assigned_to_Campaign__c);
    
  }

  @isTest
  static void testNoChangeToCampaign() {
      User atm1 = [select Id,Name from User where alias = 'ATM1'];
      User atm2 = [select Id,Name from User where alias = 'ATM2'];
      
      Campaign campaign = TestDataFactory_Campaign.generateCampaign('fedIdTest');
      User adminUser = TestDataFactory_User.getSysAdminUser();
      campaign.OwnerId = adminUser.Id;
      campaign.CampaignMemberAssignmentChanged__c = false;
      campaign.Assigned_to_Campaign__c = atm1.Name + ' | ' + atm2.Name;
      campaign.CampaignMembersAssignedToList__c = atm1.Id + '|' + atm2.Id;
      campaign = TestDataFactory_Campaign.insertCampaign(campaign);

      Contact contact1 = TestDataFactory_Contact.generateContact('firstnameCt1','lastnameCt');
      Contact contact2 = TestDataFactory_Contact.generateContact('firstnameCt2','lastnameCt');
      TestDataFactory_Contact.insertContact(contact1);
      TestDataFactory_Contact.insertContact(contact2);

      CampaignMember campaignMember1 = TestDataFactory_CampaignMember.generateCampaignMember(campaign,contact1);
      CampaignMember campaignMember2 = TestDataFactory_CampaignMember.generateCampaignMember(campaign,contact2);
      campaignMember1.AssignedTo__c = atm1.Id;
      campaignMember1.CampaignId = campaign.Id;
      campaignMember2.AssignedTo__c = null;
      campaignMember2.CampaignId = campaign.Id;
      
      campaignMember1 = TestDataFactory_CampaignMember.insertCampaignMember(campaignMember1);
      campaignMember2 = TestDataFactory_CampaignMember.insertCampaignMember(campaignMember2);
      
      User batchUser = createProcIdUser();
      System.runAs(batchUser){
        Test.StartTest();
        Database.executeBatch(new Batch_CampaignAssignUpdate(), 200);
        Test.stopTest();
      }	
                
      Campaign camp = [Select Id, Assigned_to_Campaign__c, CampaignMembersAssignedToList__c from Campaign where Id = :campaign.Id];
      
      system.assert(camp.CampaignMembersAssignedToList__c == atm1.Id + '|' + atm2.Id, 'CampaignMembersAssignedToList__c value should be equal to' + atm1.Id + '|' + atm2.Id + ' but the actual value is ' + camp.CampaignMembersAssignedToList__c);
      system.assert(camp.Assigned_to_Campaign__c == atm1.Name + ' | ' + atm2.Name, 'Assigned_to_Campaign__c value should be equal to' + atm1.Name + ' | ' + atm2.Name + ' but the actual value is ' + camp.Assigned_to_Campaign__c);
    
  }
}
