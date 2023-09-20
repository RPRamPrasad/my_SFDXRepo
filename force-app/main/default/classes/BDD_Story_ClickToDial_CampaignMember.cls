/**
 * @className: BDD_Story_ClickToDial_CampaignMember type Customer/Prospect
 * @Description: BDD Story for Click To Dial Phone number on CampaignMember
 * @Author: Team ITIC
 */
/**
 * @description BDD Story Click To Dial CampaignMember
 */
@isTest(seeAllData=false)
private class BDD_Story_ClickToDial_CampaignMember {
/**
  * Scenerio: Contact phone numbers are blank
  *
  * Given the Agent with Click to Dial Enabled 
  * When Agent views the Campaign Member
  * Then Phone display links are empty
  *
  * Related Stories:
  * S-232482
  * @description Campaign Member With Click To Dial Enabled Phone Blank
  */
  @isTest
  public static void campaignMemberWithClickToDialEnabledPhoneBlank() {
    UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
    TestDataFactory_Campaign.byPassTrigger();
    BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
    BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
    BDD_Campaign_StepDefinitions campaignStepDefinitions = new BDD_Campaign_StepDefinitions();
    BDD_CampaignMember_StepDefinition campaignMemberStepDefinition = new BDD_CampaignMember_StepDefinition();
    BDD_Contact_StepDefinitions contactStepDefinitions = new BDD_Contact_StepDefinitions();
    userStepDefinitions.givenAnUserSalesHierarchy(); 
    userStepDefinitions.givenAgentWithClickToDialPreferenceAs(userStepDefinitions.SalesUserHierarchy.Agent, '11', true);
    contactStepDefinitions.givenAContact('testFirstName', 'testLastName');
    contactStepDefinitions.givenTheContactHasPhoneNumber('MobilePhone', null);
    contactStepDefinitions.givenTheContactHasPhoneNumber('Phone', null);
    campaignStepDefinitions.givenACampaign(userStepDefinitions.SalesUserHierarchy.AgentOffice);
    campaignMemberStepDefinition.givenACampaignMemberForCampaign(campaignStepDefinitions.campaign, contactStepDefinitions.contact);
    campaignMemberStepDefinition.whenUserViewTheCampaignMember(userStepDefinitions.SalesUserHierarchy.Agent, campaignMemberStepDefinition.campaignMember);
    System.runAs(userStepDefinitions.SalesUserHierarchy.Agent){
      clickToDialStepDefinition.thenPhoneIsBlank(campaignMemberStepDefinition.campaignMember.Mobile_Phone__c);
      clickToDialStepDefinition.thenPhoneIsBlank(campaignMemberStepDefinition.campaignMember.Phone__c);
      clickToDialStepDefinition.thenPhoneIsBlank(removeNull(campaignMemberStepDefinition.campaignMember.MobilePhoneDoNotMarket__c + 
                                                      campaignMemberStepDefinition.campaignMember.MobilePhoneNumber__c + 
                                                      campaignMemberStepDefinition.campaignMember.MobilePhoneCallFailed__c +
                                                      campaignMemberStepDefinition.campaignMember.MobilePhoneClickHere__c));
      clickToDialStepDefinition.thenPhoneIsBlank(removeNull(campaignMemberStepDefinition.campaignMember.PhoneDoNotMarket__c + 
                                                      campaignMemberStepDefinition.campaignMember.PhoneNumber__c + 
                                                      campaignMemberStepDefinition.campaignMember.PhoneCallFailed__c + 
                                                      campaignMemberStepDefinition.campaignMember.PhoneClickHere__c));
    }
  }
/**
  * Scenerio: CampaignMember type Customer/Prospect Phone number fields are Hyperlinked
  *
  * Given the Agent with Click to Dial Preference as NONE
  * When User view the Campaign Member
  * Then default Phone display links are formated 
  *
  * Related Stories:
  * S-232482
  * @description Campaign Member Contact Agent With Click To Dial Enabled Preference As Null
  */
  @isTest
  public static void campaignMemberContactAgentWithClickToDialEnabledPreferenceAsNull() {
    UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
    TestDataFactory_Campaign.byPassTrigger();
    BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
    BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
    BDD_Campaign_StepDefinitions campaignStepDefinitions = new BDD_Campaign_StepDefinitions();
    BDD_CampaignMember_StepDefinition campaignMemberStepDefinition = new BDD_CampaignMember_StepDefinition();
    BDD_Contact_StepDefinitions contactStepDefinitions = new BDD_Contact_StepDefinitions();
    userStepDefinitions.givenAnUserSalesHierarchy(); 
    userStepDefinitions.givenAgentWithClickToDialPreferenceAs(userStepDefinitions.SalesUserHierarchy.Agent, '', true);
    contactStepDefinitions.givenAContact('testFirstName', 'testLastName');
    contactStepDefinitions.givenTheContactHasPhoneNumber('MobilePhone', '1234567123');
    contactStepDefinitions.givenTheContactHasPhoneNumber('Phone', '1234567123');
    campaignStepDefinitions.givenACampaign(userStepDefinitions.SalesUserHierarchy.AgentOffice);
    campaignMemberStepDefinition.givenACampaignMemberForCampaign(campaignStepDefinitions.campaign, contactStepDefinitions.contact);
    campaignMemberStepDefinition.whenUserViewTheCampaignMember(userStepDefinitions.SalesUserHierarchy.Agent, campaignMemberStepDefinition.campaignMember);

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper1 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper1.user = userStepDefinitions.SalesUserHierarchy.Agent;
	  bddWrapper1.display = '1234567123';
	  bddWrapper1.hyperLink =  '11234567123';
	  bddWrapper1.phoneFieldToAssert =  campaignMemberStepDefinition.campaignMember.Mobile_Phone__c;

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper2 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper2.user = userStepDefinitions.SalesUserHierarchy.Agent;
	  bddWrapper2.display = '1234567123';
	  bddWrapper2.hyperLink =  '11234567123';
	  bddWrapper2.phoneFieldToAssert =  campaignMemberStepDefinition.campaignMember.Phone__c;

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper3 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper3.user = userStepDefinitions.SalesUserHierarchy.Agent;
	  bddWrapper3.display = '1234567123';
	  bddWrapper3.hyperLink =  '11234567123';
	  bddWrapper3.phoneFieldToAssert =  removeNull(campaignMemberStepDefinition.campaignMember.MobilePhoneDoNotMarket__c + 
                                                    campaignMemberStepDefinition.campaignMember.MobilePhoneNumber__c + 
                                                    campaignMemberStepDefinition.campaignMember.MobilePhoneCallFailed__c +
                                                    campaignMemberStepDefinition.campaignMember.MobilePhoneClickHere__c);

    System.runAs(userStepDefinitions.SalesUserHierarchy.Agent){                                                    
      clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper1);
      clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper2);
      clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper3);
      clickToDialStepDefinition.thenPhoneIsJustText('', removeNull(campaignMemberStepDefinition.campaignMember.PhoneDoNotMarket__c + 
                                                      campaignMemberStepDefinition.campaignMember.PhoneNumber__c + 
                                                      campaignMemberStepDefinition.campaignMember.PhoneCallFailed__c + 
                                                      campaignMemberStepDefinition.campaignMember.PhoneClickHere__c));
    }
  }
/**
  * Scenerio: CampaignMember type Customer/Prospect Phone number fields are Hyperlinked 
  * with Click to Dial Preference as 7
  *
  * Given the Agent with Click to Dial Preference as 7
  * When Agent views Campaign Member
  * Then Phone display links are formated according to the User preference
  *
  * Related Stories:
  * S-232482
  * @description Campaign Member Contact Agent With Click To Dial Enabled Preference As 7
  */
  @isTest
  public static void campaignMemberContactAgentWithClickToDialEnabledPreferenceAs7() {
    UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
    TestDataFactory_Campaign.byPassTrigger();
    BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
    BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
    BDD_Campaign_StepDefinitions campaignStepDefinitions = new BDD_Campaign_StepDefinitions();
    BDD_CampaignMember_StepDefinition campaignMemberStepDefinition = new BDD_CampaignMember_StepDefinition();
    BDD_Contact_StepDefinitions contactStepDefinitions = new BDD_Contact_StepDefinitions();
    userStepDefinitions.givenAnUserSalesHierarchy(); 
    userStepDefinitions.givenAgentWithClickToDialPreferenceAs(userStepDefinitions.SalesUserHierarchy.Agent, '7', true);
    contactStepDefinitions.givenAContact('testFirstName', 'testLastName');
    contactStepDefinitions.givenTheContactHasPhoneNumber('MobilePhone', '1234567123');
    contactStepDefinitions.givenTheContactHasPhoneNumber('Phone', '1234567123');
    campaignStepDefinitions.givenACampaign(userStepDefinitions.SalesUserHierarchy.AgentOffice);
    campaignMemberStepDefinition.givenACampaignMemberForCampaign(campaignStepDefinitions.campaign, contactStepDefinitions.contact);
    campaignMemberStepDefinition.whenUserViewTheCampaignMember(userStepDefinitions.SalesUserHierarchy.Agent, campaignMemberStepDefinition.campaignMember);

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper1 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper1.user = userStepDefinitions.SalesUserHierarchy.Agent;
	  bddWrapper1.display = '1234567123';
	  bddWrapper1.hyperLink =  '4567123';
	  bddWrapper1.longDistanceNumber = '11234567123';
	  bddWrapper1.phoneFieldToAssert =  campaignMemberStepDefinition.campaignMember.Mobile_Phone__c;

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper2 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper2.user = userStepDefinitions.SalesUserHierarchy.Agent;
	  bddWrapper2.display = '1234567123';
	  bddWrapper2.hyperLink =  '4567123';
	  bddWrapper2.longDistanceNumber = '11234567123';
	  bddWrapper2.phoneFieldToAssert =  campaignMemberStepDefinition.campaignMember.Phone__c;

    System.runAs(userStepDefinitions.SalesUserHierarchy.Agent){
      clickToDialStepDefinition.thenPhoneDisplayLinksAreFormated(bddWrapper1);
      clickToDialStepDefinition.thenPhoneDisplayLinksAreFormated(bddWrapper2);
    }
  }
/**
  * Scenerio: Campaign Member type Customer/Prospect Phone number fields are link
  * with Click to Dial Preference as 10
  *
  * Given the Agent with Click to Dial Preference as 10
  * When Agent views the Campaign Member
  * then Phone display links are formated according to the User preference
  *
  * Related Stories:
  * S-232482
  * @description Campaign Member Contact Agent With Click To Dial Enabled Preference As 10
  */
  @isTest
  public static void campaignMemberContactAgentWithClickToDialEnabledPreferenceAs10() {
    UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
    TestDataFactory_Campaign.byPassTrigger();
    BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
    BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
    BDD_Campaign_StepDefinitions campaignStepDefinitions = new BDD_Campaign_StepDefinitions();
    BDD_CampaignMember_StepDefinition campaignMemberStepDefinition = new BDD_CampaignMember_StepDefinition();
    BDD_Contact_StepDefinitions contactStepDefinitions = new BDD_Contact_StepDefinitions();
    userStepDefinitions.givenAnUserSalesHierarchy(); 
    userStepDefinitions.givenAgentWithClickToDialPreferenceAs(userStepDefinitions.SalesUserHierarchy.Agent, '10', true); 
    contactStepDefinitions.givenAContact('testFirstName', 'testLastName');
    contactStepDefinitions.givenTheContactHasPhoneNumber('MobilePhone', '1234567123');
    contactStepDefinitions.givenTheContactHasPhoneNumber('Phone', '1234567123');
    campaignStepDefinitions.givenACampaign(userStepDefinitions.SalesUserHierarchy.AgentOffice);
    campaignMemberStepDefinition.givenACampaignMemberForCampaign(campaignStepDefinitions.campaign, contactStepDefinitions.contact);
    campaignMemberStepDefinition.whenUserViewTheCampaignMember(userStepDefinitions.SalesUserHierarchy.Agent, campaignMemberStepDefinition.campaignMember);

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper1 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper1.user = userStepDefinitions.SalesUserHierarchy.Agent;
	  bddWrapper1.display = '1234567123';
	  bddWrapper1.hyperLink =  '1234567123';
	  bddWrapper1.longDistanceNumber = '11234567123';
	  bddWrapper1.phoneFieldToAssert =  campaignMemberStepDefinition.campaignMember.Mobile_Phone__c;

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper2 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper2.user = userStepDefinitions.SalesUserHierarchy.Agent;
	  bddWrapper2.display = '1234567123';
	  bddWrapper2.hyperLink =  '1234567123';
	  bddWrapper2.longDistanceNumber = '11234567123';
	  bddWrapper2.phoneFieldToAssert =  campaignMemberStepDefinition.campaignMember.Phone__c;

    System.runAs(userStepDefinitions.SalesUserHierarchy.Agent){
      clickToDialStepDefinition.thenPhoneDisplayLinksAreFormated(bddWrapper1);
      clickToDialStepDefinition.thenPhoneDisplayLinksAreFormated(bddWrapper2);
    }
  }
/**
  * Scenerio: Campaign Member type Customer/Prospect Phone number fields are link
  * with Click to Dial Preference as 11
  *
  * Given the Agent with Click to Dial Preference as 11
  * When Agent views the Campaign Member
  * then Phone display links are formated according to the User preference
  *
  * Related Stories:
  * S-232482
  * @description Campaign Member Contact Agent With Click To Dial Enabled Preference As 11
  */
  @isTest
  public static void campaignMemberContactAgentWithClickToDialEnabledPreferenceAs11() {
    UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
    TestDataFactory_Campaign.byPassTrigger();
    BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
    BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
    BDD_Campaign_StepDefinitions campaignStepDefinitions = new BDD_Campaign_StepDefinitions();
    BDD_CampaignMember_StepDefinition campaignMemberStepDefinition = new BDD_CampaignMember_StepDefinition();
    BDD_Contact_StepDefinitions contactStepDefinitions = new BDD_Contact_StepDefinitions();
    userStepDefinitions.givenAnUserSalesHierarchy(); 
    userStepDefinitions.givenAgentWithClickToDialPreferenceAs(userStepDefinitions.SalesUserHierarchy.Agent, '11', true); 
    contactStepDefinitions.givenAContact('testFirstName', 'testLastName');
    contactStepDefinitions.givenTheContactHasPhoneNumber('MobilePhone', '1234567123');
    contactStepDefinitions.givenTheContactHasPhoneNumber('Phone', '1234567123');
    campaignStepDefinitions.givenACampaign(userStepDefinitions.SalesUserHierarchy.AgentOffice);
    campaignMemberStepDefinition.givenACampaignMemberForCampaign(campaignStepDefinitions.campaign, contactStepDefinitions.contact);
    campaignMemberStepDefinition.whenUserViewTheCampaignMember(userStepDefinitions.SalesUserHierarchy.Agent, campaignMemberStepDefinition.campaignMember); 

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper1 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper1.user = userStepDefinitions.SalesUserHierarchy.Agent;
	  bddWrapper1.display = '1234567123';
	  bddWrapper1.hyperLink =  '11234567123';
	  bddWrapper1.phoneFieldToAssert =  campaignMemberStepDefinition.campaignMember.Mobile_Phone__c;

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper2 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper2.user = userStepDefinitions.SalesUserHierarchy.Agent;
	  bddWrapper2.display = '1234567123';
	  bddWrapper2.hyperLink =  '11234567123';
	  bddWrapper2.phoneFieldToAssert =  campaignMemberStepDefinition.campaignMember.Phone__c;

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper3 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper3.user = userStepDefinitions.SalesUserHierarchy.Agent;
	  bddWrapper3.display = '1234567123';
	  bddWrapper3.hyperLink =  '11234567123';
	  bddWrapper3.phoneFieldToAssert =  removeNull(campaignMemberStepDefinition.campaignMember.MobilePhoneDoNotMarket__c + 
                                                    campaignMemberStepDefinition.campaignMember.MobilePhoneNumber__c + 
                                                    campaignMemberStepDefinition.campaignMember.MobilePhoneCallFailed__c +
                                                    campaignMemberStepDefinition.campaignMember.MobilePhoneClickHere__c);
    
    System.runAs(userStepDefinitions.SalesUserHierarchy.Agent){
      clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper1);
      clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper2);
      clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper3);
      clickToDialStepDefinition.thenPhoneIsJustText('', removeNull(campaignMemberStepDefinition.campaignMember.PhoneDoNotMarket__c + 
                                                      campaignMemberStepDefinition.campaignMember.PhoneNumber__c + 
                                                      campaignMemberStepDefinition.campaignMember.PhoneCallFailed__c + 
                                                      campaignMemberStepDefinition.campaignMember.PhoneClickHere__c));
    }
  }
/**
  * Scenerio: CampaignMember type Lead Phone number fields are Hyperlinked 
  * with Click to Dial Preference as 7
  *
  * Given the Agent with Click to Dial Preference as 7
  * When Agent views Campaign Member with Type Lead
  * Then Phone display links are formated according to the User preference
  *
  * Related Stories:
  * S-232482
  * @description Campaign Member Lead Agent With Click To Dial Enabled Preference As 7
  */
  @isTest
  public static void campaignMemberLeadAgentWithClickToDialEnabledPreferenceAs7() {
    BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
    BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
    BDD_Campaign_StepDefinitions campaignStepDefinitions = new BDD_Campaign_StepDefinitions();
    BDD_CampaignMember_StepDefinition campaignMemberStepDefinition = new BDD_CampaignMember_StepDefinition();
    BDD_Lead_StepDefinition leadStepDefinitions = new BDD_Lead_StepDefinition();
    userStepDefinitions.givenAnUserSalesHierarchy(); 
    userStepDefinitions.givenAgentWithClickToDialPreferenceAs(userStepDefinitions.SalesUserHierarchy.Agent, '7', true);
    leadStepDefinitions.givenALeadCreatedWithPhoneNumber (userStepDefinitions.SalesUserHierarchy.Agent, '1234567123','1234567123');
    campaignStepDefinitions.givenACampaignTypeLead(userStepDefinitions.SalesUserHierarchy.AgentOffice);
    campaignMemberStepDefinition.givenALeadCampaignMemberForCampaign(campaignStepDefinitions.campaign, leadStepDefinitions.lead);
    campaignMemberStepDefinition.whenUserViewTheCampaignMember(userStepDefinitions.SalesUserHierarchy.Agent, campaignMemberStepDefinition.campaignMember);

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper1 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper1.user = userStepDefinitions.SalesUserHierarchy.Agent;
	  bddWrapper1.display = '1234567123';
	  bddWrapper1.hyperLink =  '4567123';
	  bddWrapper1.longDistanceNumber = '11234567123';
	  bddWrapper1.phoneFieldToAssert =  campaignMemberStepDefinition.campaignMember.Mobile_Phone__c;

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper2 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper2.user = userStepDefinitions.SalesUserHierarchy.Agent;
	  bddWrapper2.display = '1234567123';
	  bddWrapper2.hyperLink =  '4567123';
	  bddWrapper2.longDistanceNumber = '11234567123';
	  bddWrapper2.phoneFieldToAssert =  campaignMemberStepDefinition.campaignMember.Phone__c;

    System.runAs(userStepDefinitions.SalesUserHierarchy.Agent){
      clickToDialStepDefinition.thenPhoneDisplayLinksAreFormated(bddWrapper1);
      clickToDialStepDefinition.thenPhoneDisplayLinksAreFormated(bddWrapper2);
    }
  }
/**
  * Scenerio: Campaign Member with Type Lead Phone number fields are hyperlinked
  * with Click to Dial Preference as 10
  *
  * Given the Agent with Click to Dial Preference as 10
  * When Agent views the Campaign Member with Type Lead
  * then Phone display links are formated according to the User preference
  *
  * Related Stories:
  * S-232482
  * @description Campaign Member Lead Agent With Click To Dial Enabled Preference As 10
  */
  @isTest
  public static void campaignMemberLeadAgentWithClickToDialEnabledPreferenceAs10() {
    BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
    BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
    BDD_Campaign_StepDefinitions campaignStepDefinitions = new BDD_Campaign_StepDefinitions();
    BDD_CampaignMember_StepDefinition campaignMemberStepDefinition = new BDD_CampaignMember_StepDefinition();
    BDD_Lead_StepDefinition leadStepDefinitions = new BDD_Lead_StepDefinition();
    userStepDefinitions.givenAnUserSalesHierarchy(); 
    userStepDefinitions.givenAgentWithClickToDialPreferenceAs(userStepDefinitions.SalesUserHierarchy.Agent, '10', true); 
    leadStepDefinitions.givenALeadCreatedWithPhoneNumber (userStepDefinitions.SalesUserHierarchy.Agent, '1234567123','1234567123');
    campaignStepDefinitions.givenACampaignTypeLead(userStepDefinitions.SalesUserHierarchy.AgentOffice);
    campaignMemberStepDefinition.givenALeadCampaignMemberForCampaign(campaignStepDefinitions.campaign, leadStepDefinitions.lead);
    campaignMemberStepDefinition.whenUserViewTheCampaignMember(userStepDefinitions.SalesUserHierarchy.Agent, campaignMemberStepDefinition.campaignMember);

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper1 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper1.user = userStepDefinitions.SalesUserHierarchy.Agent;
	  bddWrapper1.display = '1234567123';
	  bddWrapper1.hyperLink =  '1234567123';
	  bddWrapper1.longDistanceNumber = '11234567123';
	  bddWrapper1.phoneFieldToAssert =  campaignMemberStepDefinition.campaignMember.Mobile_Phone__c;

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper2 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper2.user = userStepDefinitions.SalesUserHierarchy.Agent;
	  bddWrapper2.display = '1234567123';
	  bddWrapper2.hyperLink =  '1234567123';
	  bddWrapper2.longDistanceNumber = '11234567123';
	  bddWrapper2.phoneFieldToAssert =  campaignMemberStepDefinition.campaignMember.Phone__c;

    System.runAs(userStepDefinitions.SalesUserHierarchy.Agent){
      clickToDialStepDefinition.thenPhoneDisplayLinksAreFormated(bddWrapper1);
      clickToDialStepDefinition.thenPhoneDisplayLinksAreFormated(bddWrapper2);
    }
  }
/**
  * Scenerio: Campaign Member with Type Lead Phone number fields are hyperlinked
  * with Click to Dial Preference as 11
  *
  * Given the Agent with Click to Dial Preference as 11
  * When Agent views the Campaign Member with Type Lead
  * then Phone display links are formated according to the User preference
  *
  * Related Stories:
  * S-232482
  * @description Campaign Member Lead Agent With Click To Dial Enabled Preference As 11
  */
  @isTest
  public static void campaignMemberLeadAgentWithClickToDialEnabledPreferenceAs11() {
    BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
    BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
    BDD_Campaign_StepDefinitions campaignStepDefinitions = new BDD_Campaign_StepDefinitions();
    BDD_CampaignMember_StepDefinition campaignMemberStepDefinition = new BDD_CampaignMember_StepDefinition();
    BDD_Lead_StepDefinition leadStepDefinitions = new BDD_Lead_StepDefinition();
    userStepDefinitions.givenAnUserSalesHierarchy(); 
    userStepDefinitions.givenAgentWithClickToDialPreferenceAs(userStepDefinitions.SalesUserHierarchy.Agent, '11', true); 
    leadStepDefinitions.givenALeadCreatedWithPhoneNumber (userStepDefinitions.SalesUserHierarchy.Agent, '1234567123','1234567123');
    campaignStepDefinitions.givenACampaignTypeLead(userStepDefinitions.SalesUserHierarchy.AgentOffice);
    campaignMemberStepDefinition.givenALeadCampaignMemberForCampaign(campaignStepDefinitions.campaign, leadStepDefinitions.lead);
    campaignMemberStepDefinition.whenUserViewTheCampaignMember(userStepDefinitions.SalesUserHierarchy.Agent, campaignMemberStepDefinition.campaignMember);

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper1 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper1.user = userStepDefinitions.SalesUserHierarchy.Agent;
	  bddWrapper1.display = '1234567123';
	  bddWrapper1.hyperLink =  '11234567123';
	  bddWrapper1.phoneFieldToAssert =  campaignMemberStepDefinition.campaignMember.Mobile_Phone__c;

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper2 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper2.user = userStepDefinitions.SalesUserHierarchy.Agent;
	  bddWrapper2.display = '1234567123';
	  bddWrapper2.hyperLink =  '11234567123';
	  bddWrapper2.phoneFieldToAssert =  campaignMemberStepDefinition.campaignMember.Phone__c;

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper3 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper3.user = userStepDefinitions.SalesUserHierarchy.Agent;
	  bddWrapper3.display = '1234567123';
	  bddWrapper3.hyperLink =  '11234567123';
	  bddWrapper3.phoneFieldToAssert = campaignMemberStepDefinition.campaignMember.SubmittedPhoneNumber__c;

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper4 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper4.user = userStepDefinitions.SalesUserHierarchy.Agent;
	  bddWrapper4.display = '1234567123';
	  bddWrapper4.hyperLink =  '11234567123';
	  bddWrapper4.phoneFieldToAssert =  removeNull(campaignMemberStepDefinition.campaignMember.MobilePhoneDoNotMarket__c + 
                                                    campaignMemberStepDefinition.campaignMember.MobilePhoneNumber__c + 
                                                    campaignMemberStepDefinition.campaignMember.MobilePhoneCallFailed__c +
                                                    campaignMemberStepDefinition.campaignMember.MobilePhoneClickHere__c);

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper5 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper5.user = userStepDefinitions.SalesUserHierarchy.Agent;
	  bddWrapper5.display = '1234567123';
	  bddWrapper5.hyperLink =  '11234567123';
	  bddWrapper5.phoneFieldToAssert =  removeNull(campaignMemberStepDefinition.campaignMember.PhoneDoNotMarket__c + 
                                                    campaignMemberStepDefinition.campaignMember.PhoneNumber__c + 
                                                    campaignMemberStepDefinition.campaignMember.PhoneCallFailed__c + 
                                                    campaignMemberStepDefinition.campaignMember.PhoneClickHere__c);

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper6 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper6.user = userStepDefinitions.SalesUserHierarchy.Agent;
	  bddWrapper6.display = '1234567123';
	  bddWrapper6.hyperLink =  '11234567123';
	  bddWrapper6.phoneFieldToAssert =  removeNull(campaignMemberStepDefinition.campaignMember.SubmitPhoneNumber__c +
                                                    campaignMemberStepDefinition.campaignMember.SubmittedPhoneCallFailed__c + 
                                                    campaignMemberStepDefinition.campaignMember.SubmittedPhoneClickHere__c);

    System.runAs(userStepDefinitions.SalesUserHierarchy.Agent){
      clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper1);
      clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper2);
      clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper3);
      clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper4);
      clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper5);
      clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper6);
    }
  }
/**
  * Scenerio: Campaign Member has phone number hyperlinked
  *
  * Given the User with Click to Dial Enabled
  * When User views a Campaign Member with a phone number
  * Then phone number is Click to Dial enabled
  *
  * Related Stories:
  * S-415854 
  * @description Campaign Member With Phone Number Displays Clickable PhoneNumber
  */
  @isTest
  public static void campaignMemberWithPhoneNumberDisplaysClickablePhoneNumber() {
    BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
    BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
    BDD_Campaign_StepDefinitions campaignStepDefinition = new BDD_Campaign_StepDefinitions();
    BDD_CampaignMember_StepDefinition campaignMemberStepDefinition = new BDD_CampaignMember_StepDefinition();
    BDD_Lead_StepDefinition leadStepDefinitions = new BDD_Lead_StepDefinition();
    userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
    userStepDefinitions.whenPermissionSetIsAssigned('CustomerView_Support_ModifyAll');
    userStepDefinitions.whenPermissionSetIsAssigned('Campaign_Support_W');
    userStepDefinitions.whenPermissionSetIsAssigned('Lead_Management_Tech_Support_Users');
    userStepDefinitions.whenPermissionSetIsAssigned('ClickToDial_ModifyAll');
    userStepDefinitions.givenUserWithClickToDialPreferenceAs(userStepDefinitions.user, '10', true); 
    leadStepDefinitions.givenALeadCreatedWithPhoneNumber (userStepDefinitions.user, '1234567123','1234567123');
    leadStepDefinitions.givenDoNotCall(false);
    campaignStepDefinition.givenACampaignTypeLead(userStepDefinitions.user);
    campaignMemberStepDefinition.givenALeadCampaignMemberForCampaign(campaignStepDefinition.campaign, leadStepDefinitions.lead);
    campaignMemberStepDefinition.whenUserViewTheCampaignMember(userStepDefinitions.user, campaignMemberStepDefinition.campaignMember);

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper1 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper1.user = userStepDefinitions.user;
	  bddWrapper1.display = '1234567123';
	  bddWrapper1.hyperLink =  '1234567123';
	  bddWrapper1.longDistanceNumber = '11234567123';
	  bddWrapper1.phoneFieldToAssert =  campaignMemberStepDefinition.campaignMember.Mobile_Phone__c;

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper2 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper2.user = userStepDefinitions.user;
	  bddWrapper2.display = '1234567123';
	  bddWrapper2.hyperLink =  '1234567123';
	  bddWrapper2.longDistanceNumber = '11234567123';
	  bddWrapper2.phoneFieldToAssert =  campaignMemberStepDefinition.campaignMember.Phone__c;
	userStepDefinitions.givenAnUserSalesHierarchy(); 
    System.runAs(userStepDefinitions.SalesUserHierarchy.Agent){
      clickToDialStepDefinition.thenPhoneDisplayLinksAreFormated(bddWrapper1);
      clickToDialStepDefinition.thenPhoneDisplayLinksAreFormated(bddWrapper2);
    }
  }
/**
  * Scenerio: Campaign Member marked Do Not Call has phone number hidden
  *
  * Given the User with Click to Dial Enabled
  * When User views a Campaign Member with a phone number and is flagged as Do Not Call
  * Then phone number is hidden
  *
  * Related Stories:
  * S-415854 
  * @description Lead Campaign Member With Do Not Call Has Phone Hidden
  */
  @isTest
  public static void leadCampaignMemberWithDoNotCallHasPhoneHidden() {
    BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
    BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
    BDD_Campaign_StepDefinitions campaignStepDefinition = new BDD_Campaign_StepDefinitions();
    BDD_CampaignMember_StepDefinition campaignMemberStepDefinition = new BDD_CampaignMember_StepDefinition();
    BDD_Lead_StepDefinition leadStepDefinitions = new BDD_Lead_StepDefinition();
    userStepDefinitions.givenAUserInSalesforceWithProfile('2.00 Agent');
    userStepDefinitions.whenPermissionSetIsAssigned('CustomerView_Support_ModifyAll');
    userStepDefinitions.whenPermissionSetIsAssigned('Campaign_Support_W');
    userStepDefinitions.whenPermissionSetIsAssigned('Lead_Management_Tech_Support_Users');
		//userStepDefinitions.whenPermissionSetIsAssigned('ClickToDial_ModifyAll');
    userStepDefinitions.givenUserWithClickToDialPreferenceAs(userStepDefinitions.user, '10', true); 
    leadStepDefinitions.givenALeadCreatedWithPhoneNumber (userStepDefinitions.user, '1234567123','1234567123');
    leadStepDefinitions.givenDoNotCall(true);
    campaignStepDefinition.givenACampaignTypeLead(userStepDefinitions.user);
    campaignMemberStepDefinition.givenALeadCampaignMemberForCampaign(campaignStepDefinition.campaign, leadStepDefinitions.lead);
    campaignMemberStepDefinition.whenUserViewTheCampaignMember(userStepDefinitions.user, campaignMemberStepDefinition.campaignMember);
    clickToDialStepDefinition.thenPhoneIsBlank(campaignMemberStepDefinition.campaignMember.Phone__c);
    clickToDialStepDefinition.thenPhoneIsBlank(campaignMemberStepDefinition.campaignMember.Mobile_Phone__c);

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper.user = userStepDefinitions.user;
	  bddWrapper.display = '1234567123';
	  bddWrapper.hyperLink =  '1234567123';
	  bddWrapper.longDistanceNumber = '11234567123';
	  bddWrapper.phoneFieldToAssert =  campaignMemberStepDefinition.campaignMember.SubmittedPhoneNumber__c;

    userStepDefinitions.givenAnUserSalesHierarchy(); 
    System.runAs(userStepDefinitions.SalesUserHierarchy.Agent){
      clickToDialStepDefinition.thenPhoneDisplayLinksAreFormated(bddWrapper);
      clickToDialStepDefinition.thenPhoneIsBlank(removeNull(campaignMemberStepDefinition.campaignMember.PhoneDoNotMarket__c + 
                                                    campaignMemberStepDefinition.campaignMember.PhoneNumber__c + 
                                                    campaignMemberStepDefinition.campaignMember.PhoneCallFailed__c + 
                                                    campaignMemberStepDefinition.campaignMember.PhoneClickHere__c));
      clickToDialStepDefinition.thenPhoneIsBlank(removeNull(campaignMemberStepDefinition.campaignMember.MobilePhoneDoNotMarket__c + 
                                                    campaignMemberStepDefinition.campaignMember.MobilePhoneNumber__c + 
                                                    campaignMemberStepDefinition.campaignMember.MobilePhoneCallFailed__c +
                                                    campaignMemberStepDefinition.campaignMember.MobilePhoneClickHere__c));
    }
  }
  @isTest
  public static void accountCampaignMemberWithDoNotCallHasDoNotMarket() {
    TestDataFactory_Campaign.byPassTrigger();
    BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
    BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
    BDD_Campaign_StepDefinitions campaignStepDefinition = new BDD_Campaign_StepDefinitions();
    BDD_CampaignMember_StepDefinition campaignMemberStepDefinition = new BDD_CampaignMember_StepDefinition();
    BDD_Account_StepDefinitions accountStepDefinitions = new BDD_Account_StepDefinitions();
    userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
    userStepDefinitions.whenPermissionSetIsAssigned('CustomerView_Support_ModifyAll');
    userStepDefinitions.whenPermissionSetIsAssigned('Campaign_Support_W');
    userStepDefinitions.whenPermissionSetIsAssigned('Lead_Management_Tech_Support_Users');
		userStepDefinitions.whenPermissionSetIsAssigned('ClickToDial_ModifyAll');
    userStepDefinitions.givenUserWithClickToDialPreferenceAs(userStepDefinitions.user, '10', true); 
    BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper wrapper = new BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper();
    wrapper.recordType = 'Individual';
    wrapper.personMobilePhone = '3095554444';
    wrapper.personHomePhone = '3095554445';
    wrapper.phone = '3095554446';
    wrapper.isDoNotCallEnabled = true;
    accountStepDefinitions.givenAccountWithPhoneNumbers(wrapper);
    campaignStepDefinition.givenACampaign(userStepDefinitions.user);
    campaignMemberStepDefinition.givenAnAccountCampaignMemberForCampaign(campaignStepDefinition.campaign, accountStepDefinitions.account);
    campaignMemberStepDefinition.whenUserViewTheCampaignMember(userStepDefinitions.user, campaignMemberStepDefinition.campaignMember);

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper1 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper1.user = userStepDefinitions.user;
	  bddWrapper1.display = '3095554446';
	  bddWrapper1.hyperLink =  '3095554446';
	  bddWrapper1.longDistanceNumber = '13095554446';
	  bddWrapper1.phoneFieldToAssert =  campaignMemberStepDefinition.campaignMember.Phone__c;

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper2 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper2.user = userStepDefinitions.user;
	  bddWrapper2.display = '3095554444';
	  bddWrapper2.hyperLink =  '3095554444';
	  bddWrapper2.longDistanceNumber = '13095554444';
	  bddWrapper2.phoneFieldToAssert =  campaignMemberStepDefinition.campaignMember.Mobile_Phone__c;
	userStepDefinitions.givenAnUserSalesHierarchy(); 
    System.runAs(userStepDefinitions.SalesUserHierarchy.Agent){
      clickToDialStepDefinition.thenPhoneLinksAreFormatedDoNotMarket(bddWrapper1);
      clickToDialStepDefinition.thenPhoneLinksAreFormatedDoNotMarket(bddWrapper2);
    }
  }
/**
  * Scenerio: Campaign Member marked Submitted Do Not Call has submitted phone number hidden
  *           Campaign member marked both submitted_donot_call and do_not_call has phone and submitted phone number hidden     
  *
  * Given the User with Click to Dial Enabled
  * When User views a Campaign Member with a  submitted phone number and submitted do not call as marked
  * Then submitted phone number is hidden
  *
  * Related Stories:
  * S-638366  
  * @description Lead Campaign Member With Submitted Do Not Call Has Submitted Phone Hidden
  */
  @isTest
  public static void leadCampaignMemberWithSubmittedDoNotCallHasSubmittedphoneHidden() {
    BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
    BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
    BDD_Campaign_StepDefinitions campaignStepDefinition = new BDD_Campaign_StepDefinitions();
    BDD_CampaignMember_StepDefinition campaignMemberStepDefinition = new BDD_CampaignMember_StepDefinition();
    BDD_Lead_StepDefinition leadStepDefinitions = new BDD_Lead_StepDefinition();
    userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
    userStepDefinitions.whenPermissionSetIsAssigned('CustomerView_Support_ModifyAll');
    userStepDefinitions.whenPermissionSetIsAssigned('Campaign_Support_W');
    userStepDefinitions.whenPermissionSetIsAssigned('Lead_Management_Tech_Support_Users');
		userStepDefinitions.whenPermissionSetIsAssigned('ClickToDial_ModifyAll');
    userStepDefinitions.givenUserWithClickToDialPreferenceAs(userStepDefinitions.user, '11', true); 
    leadStepDefinitions.givenALeadCreatedWithPhoneNumber (userStepDefinitions.user, '1234567123','1234567123');
    leadStepDefinitions.givenSubmittedDoNotCall(true);
    campaignStepDefinition.givenACampaignTypeLead(userStepDefinitions.user);
    campaignMemberStepDefinition.givenALeadCampaignMemberForCampaign(campaignStepDefinition.campaign, leadStepDefinitions.lead);
    campaignMemberStepDefinition.whenUserViewTheCampaignMember(userStepDefinitions.user, campaignMemberStepDefinition.campaignMember);

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper1 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper1.user = userStepDefinitions.user;
	  bddWrapper1.display = '1234567123';
	  bddWrapper1.hyperLink =  '11234567123';
	  bddWrapper1.phoneFieldToAssert =  campaignMemberStepDefinition.campaignMember.Mobile_Phone__c;

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper2 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper2.user = userStepDefinitions.user;
	  bddWrapper2.display = '1234567123';
	  bddWrapper2.hyperLink =  '11234567123';
	  bddWrapper2.phoneFieldToAssert =  campaignMemberStepDefinition.campaignMember.Phone__c;

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper3 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper3.user = userStepDefinitions.user;
	  bddWrapper3.display = '1234567123';
	  bddWrapper3.hyperLink =  '11234567123';
	  bddWrapper3.phoneFieldToAssert = removeNull(campaignMemberStepDefinition.campaignMember.MobilePhoneDoNotMarket__c + 
                                                    campaignMemberStepDefinition.campaignMember.MobilePhoneNumber__c + 
                                                    campaignMemberStepDefinition.campaignMember.MobilePhoneCallFailed__c +
                                                    campaignMemberStepDefinition.campaignMember.MobilePhoneClickHere__c);

    BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper4 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    bddWrapper4.user = userStepDefinitions.user;
	  bddWrapper4.display = '1234567123';
	  bddWrapper4.hyperLink =  '11234567123';
	  bddWrapper4.phoneFieldToAssert =  removeNull(campaignMemberStepDefinition.campaignMember.PhoneDoNotMarket__c + 
                                                    campaignMemberStepDefinition.campaignMember.PhoneNumber__c + 
                                                    campaignMemberStepDefinition.campaignMember.PhoneCallFailed__c + 
                                                    campaignMemberStepDefinition.campaignMember.PhoneClickHere__c);
	userStepDefinitions.givenAnUserSalesHierarchy(); 
    System.runAs(userStepDefinitions.SalesUserHierarchy.Agent){
      clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper1);
      clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper2);
      clickToDialStepDefinition.thenPhoneIsBlank(campaignMemberStepDefinition.campaignMember.SubmittedPhoneNumber__c);
      clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper3);
      clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper4);
      clickToDialStepDefinition.thenPhoneIsBlank(removeNull(campaignMemberStepDefinition.campaignMember.SubmitPhoneNumber__c +
                                                      campaignMemberStepDefinition.campaignMember.SubmittedPhoneCallFailed__c +
                                                      campaignMemberStepDefinition.campaignMember.SubmittedPhoneClickHere__c));
    }
  }
  @isTest
  public static void leadCampaignMemberWithSubmitteddonotcallAndDoNotCallHasPhoneAndSubmittedphoneHidden() {
    BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
    BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
    BDD_Campaign_StepDefinitions campaignStepDefinition = new BDD_Campaign_StepDefinitions();
    BDD_CampaignMember_StepDefinition campaignMemberStepDefinition = new BDD_CampaignMember_StepDefinition();
    BDD_Lead_StepDefinition leadStepDefinitions = new BDD_Lead_StepDefinition();
    userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
    userStepDefinitions.whenPermissionSetIsAssigned('CustomerView_Support_ModifyAll');
    userStepDefinitions.whenPermissionSetIsAssigned('Campaign_Support_W');
    userStepDefinitions.whenPermissionSetIsAssigned('Lead_Management_Tech_Support_Users');
		userStepDefinitions.whenPermissionSetIsAssigned('ClickToDial_ModifyAll');
    userStepDefinitions.givenUserWithClickToDialPreferenceAs(userStepDefinitions.user, '11', true); 
    leadStepDefinitions.givenALeadCreatedWithPhoneNumber (userStepDefinitions.user, '1234567123','1234567123');
    leadStepDefinitions.givenDoNotCall(true);
    leadStepDefinitions.givenSubmittedDoNotCall(true);
    campaignStepDefinition.givenACampaignTypeLead(userStepDefinitions.user);
    campaignMemberStepDefinition.givenALeadCampaignMemberForCampaign(campaignStepDefinition.campaign, leadStepDefinitions.lead);
    campaignMemberStepDefinition.whenUserViewTheCampaignMember(userStepDefinitions.user, campaignMemberStepDefinition.campaignMember);
	userStepDefinitions.givenAnUserSalesHierarchy(); 
    System.runAs(userStepDefinitions.SalesUserHierarchy.Agent){
      clickToDialStepDefinition.thenPhoneIsBlank(campaignMemberStepDefinition.campaignMember.Phone__c);
      clickToDialStepDefinition.thenPhoneIsBlank(campaignMemberStepDefinition.campaignMember.Mobile_Phone__c);
      clickToDialStepDefinition.thenPhoneIsBlank(campaignMemberStepDefinition.campaignMember.SubmittedPhoneNumber__c);
      clickToDialStepDefinition.thenPhoneIsBlank(removeNull(campaignMemberStepDefinition.campaignMember.PhoneDoNotMarket__c + 
                                                      campaignMemberStepDefinition.campaignMember.PhoneNumber__c + 
                                                      campaignMemberStepDefinition.campaignMember.PhoneCallFailed__c + 
                                                      campaignMemberStepDefinition.campaignMember.PhoneClickHere__c));
      clickToDialStepDefinition.thenPhoneIsBlank(removeNull(campaignMemberStepDefinition.campaignMember.MobilePhoneDoNotMarket__c + 
                                                      campaignMemberStepDefinition.campaignMember.MobilePhoneNumber__c + 
                                                      campaignMemberStepDefinition.campaignMember.MobilePhoneCallFailed__c +
                                                      campaignMemberStepDefinition.campaignMember.MobilePhoneClickHere__c));
      clickToDialStepDefinition.thenPhoneIsBlank(removeNull(campaignMemberStepDefinition.campaignMember.SubmitPhoneNumber__c +
                                                      campaignMemberStepDefinition.campaignMember.SubmittedPhoneCallFailed__c +
                                                      campaignMemberStepDefinition.campaignMember.SubmittedPhoneClickHere__c));
    }
  }
  private static String removeNull(String target) { return target.remove('null'); } 
}
