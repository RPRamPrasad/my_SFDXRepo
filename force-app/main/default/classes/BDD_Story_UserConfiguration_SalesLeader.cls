/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-20-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-20-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
private class BDD_Story_UserConfiguration_SalesLeader {
	
	
	/********************************************
	* @description Scenerio: SalesLeader (SL) User has read access to case
	*
	* Given an SL in a Sales Role Hierarchy
	* And a case is owned by the Agent office
	* When the SL view the case
	* Then the SL can review the case
	*
	* Related Stories:
	* S-128243
	**********************************************/
	@isTest
    public static void salesleaderCanReadCase() {
      	       
        BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();		
        BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
        
        userStepDefinitions.givenAnUserSalesHierarchy();
    	caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.SalesUserHierarchy.AgentOffice);
   		caseStepDefinitions.whenTheUserViewsTheCase(userStepDefinitions.SalesUserHierarchy.SalesLeader);
    	caseStepDefinitions.thenTheUserCanReviewTheCase();				        
    }
    
    /********************************************
	* @description Scenerio: SalesLeader (SL) User cannot access cases owned by office in different territory
	*
	* Given an SL in a Sales Role Hierarchy
	* And a case is owned by the Agent office
	* And an second SL in Sales Role Hierarchy
	* When the SL view the case
	* Then the SL cannot review the case
	*
	* Related Stories:
	* S-128243
	**********************************************/
	@isTest	
    public static void salesleaderCannotReadCase() {
     
        BDD_User_StepDefinitions userStepDefinitionsOne = new BDD_User_StepDefinitions();
        BDD_User_StepDefinitions userStepDefinitionsTwo = new BDD_User_StepDefinitions();		
        BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
        
        userStepDefinitionsOne.givenAnUserSalesHierarchy('a');
        userStepDefinitionsTwo.givenAnUserSalesHierarchy('b');
    	caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitionsOne.SalesUserHierarchy.AgentOffice);
   		caseStepDefinitions.whenTheUserTryToViewTheCase(userStepDefinitionsTwo.SalesUserHierarchy.SalesLeader);
    	caseStepDefinitions.thenTheUserCannotReviewTheCase();				        
     }
     
    /********************************************
	* @description Scenerio: SalesLeader (SL) User can access an Opportunity Note for an Opportunity in their hierarchy
	*
	* Given an Sales Leader in a Sales Role Hierarchy
	* And a Opportunity in the Agent's Office
	* And an Opportunity Note created for the Opportunity
	* When the Sales Leader views the Opportunity Note
	* Then the Sales Leader is able to see the Opportunity Note
	*
	* Related Stories:
	* S-178465
	**********************************************/
	@isTest
	public static void salesleaderCanViewOpportunityNoteInHierarchy() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAnUserSalesHierarchy();
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(TestDataFactory_User.getSysAdminUser());
		opportunityStepDefinitions.whenTheOpportunityNotesAreViewedBy(userStepDefinitions.SalesUserHierarchy.SalesLeader);
		opportunityStepDefinitions.thenTheOpportunityNotesAreViewable();
		
	}
	
	/********************************************
	* @description Scenerio: SalesLeader (SL) User cannot create an Opportunity Note for an Opportunity
	*
	* Given an Sales Leader in a Sales Role Hierarchy
	* And a Opportunity in the Agent's Office
	* When the Sales Leader creates an Opportunity Note for the Opportunity
	* Then the Sales Leader is given an error
	*
	* Related Stories:
	* S-178465
	**********************************************/
	@isTest
	public static void salesleaderCannotCreateOpportunityNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAnUserSalesHierarchy();
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.whenAnOpportunityNoteIsCreatedForTheOpportunityBy(userStepDefinitions.SalesUserHierarchy.SalesLeader);
		opportunityStepDefinitions.thenTheUserisGivenAnError();
		
	}
	
	/********************************************
	* @description Scenerio: SalesLeader (SL) User cannot edit an Opportunity Note for an Opportunity in their hierarchy
	*
	* Given an Sales Leader in a Sales Role Hierarchy
	* And a Opportunity in the Agent's Office
	* And an Opportunity Note created for the Opportunity
	* When the Sales Leader edits the Opportunity Note
	* Then the Sales Leader is given an error
	*
	* Related Stories:
	* S-178465
	**********************************************/
	@isTest
	public static void salesleaderCannotEditOpportunityNoteInHierarchy() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAnUserSalesHierarchy();
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(TestDataFactory_User.getSysAdminUser());
		opportunityStepDefinitions.whenTheOpportunityNotesAreEditedBy(userStepDefinitions.SalesUserHierarchy.SalesLeader);
		opportunityStepDefinitions.thenTheUserisGivenAnError();
		
	}

	/********************************************
	* @description Scenerio: SalesLeader (SL) User cannot delete an Opportunity Note for an Opportunity
	*
	* Given an Sales Leader in a Sales Role Hierarchy
	* And a Opportunity in the Agent's Office
	* And an Opportunity Note created for the Opportunity
	* When the Sales Leader edits the Opportunity Note
	* Then the Sales Leader is given an error
	*
	* Related Stories:
	* S-178465
	**********************************************/
	@isTest
	public static void salesleaderCannotDeleteOpportunityNoteInHierarchy() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAnUserSalesHierarchy();
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(userStepDefinitions.SalesUserHierarchy.AgentTeamMember);
		opportunityStepDefinitions.whenTheOpportunityNotesAreDeletedBy(userStepDefinitions.SalesUserHierarchy.SalesLeader);
		opportunityStepDefinitions.thenTheUserisGivenAnError();
		
	}
	
	/********************************************
	* @description Scenerio: SalesLeader (SL) User cannot view an Opportunity Note for an Opportunity outside their Hierarchy
	*
	* Given an Sales Leader in a Sales Role Hierarchy
	* And a Opportunity in another Agent's Office
	* And an Opportunity Note created for the Opportunity
	* When the Sales Leader edits the Opportunity Note
	* Then the Sales Leader cannot view the Opportunity Note
	*
	* Related Stories:
	* S-178465
	**********************************************/
	@isTest
	public static void salesleaderCannotViewOpportunityNoteOutsideHierarchy() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_User_StepDefinitions userStepDefinitionsOther = new BDD_User_StepDefinitions();		
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAnUserSalesHierarchy('a');
		userStepDefinitionsOther.givenAnUserSalesHierarchy('b');
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitionsOther.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(userStepDefinitionsOther.SalesUserHierarchy.AgentTeamMember);
		opportunityStepDefinitions.whenTheOpportunityNotesAreViewedBy(userStepDefinitions.SalesUserHierarchy.SalesLeader);
		opportunityStepDefinitions.thenTheUserisNotAbleToViewTheNotes();
		
	}
		
	/********************************************
	* @description Scenerio: Sales Leader can view a Case Note for a Case
	*
	* Given a Sales Leader in a Sales Role Hierarchy
	* And a Case is owned by the Agent's Office
	* When the Sales Leader views a Case Note for a Case
	* Then the Sales Leader is able to see the Case Notes detail
	*
	* Related Stories:
	* S-178628
	**********************************************/
	@isTest
	public static void salesleaderCanReadCaseNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		userStepDefinitions.givenAnUserSalesHierarchy();
		caseStepDefinitions.givenACaseIsOwnedBy (userStepDefinitions.SalesUserHierarchy.AgentOffice);
		caseStepDefinitions.whenACaseNoteIsCreatedForTheCaseBy (userStepDefinitions.SalesUserHierarchy.Agent);
		caseStepDefinitions.whenTheCaseNotesAreViewedBy (userStepDefinitions.SalesUserHierarchy.SalesLeader);
		caseStepDefinitions.thenTheCaseNotesAreViewable();
	}
	
	/********************************************
	* @description Scenerio: Sales Leader can view the Reports and Dashboards
	*
	* Given a Sales Leader in a Sales Role Hierarchy
	* When batch executes
	* Then the Sales Leader is added to public group
	* Related Stories:
	* S-188230
	**********************************************/
	@isTest
	public static void salesleaderCanViewReportsAndDashboards() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_GroupMember_StepDefinitions groupMemberStepDefinitions = new BDD_GroupMember_StepDefinitions();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('2.02 Sales Leader');	
		userStepDefinitions.whenBatchExecutes('Batch_SalesLeaderProvisioning,Batch_PublicGroupProcessing');
		groupMemberStepDefinitions.thenUserIsAddedToPublicGroup(userStepDefinitions.user, 'Sales_Leaders');		
	}
	
	/********************************************
	* @description Scenerio: Sales Leader cannot view the Reports and Dashboards
	*
	* Given a Sales Leader 
	* Given Sales Leader is member of a Public Group
	* When Sales Leader got deactivate
	* Then the Sales Leader Is removed from Public Group
	* Related Stories:
	* S-188244
	**********************************************/
	@isTest
	public static void salesleaderCannotViewReportsAndDashboards() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_GroupMember_StepDefinitions groupMemberStepDefinitions = new BDD_GroupMember_StepDefinitions();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('2.02 Sales Leader');
		userStepDefinitions.givenTheUserIsMemberOfGroup(groupMemberStepDefinitions.getGroupId('Sales_Leaders'));
		userStepDefinitions.whenTheyAreDeactivated(userStepDefinitions.user);		
		userStepDefinitions.whenBatchExecutes('Batch_SalesLeaderProvisioning,Batch_PublicGroupProcessing');
		groupMemberStepDefinitions.thenUserIsRemovedFromPublicGroup(userStepDefinitions.user, 'Sales_Leaders');
	}
	
	/********************************************
	* @description Scenerio: Sales Leader cannot view the Reports and Dashboards after role change
	*
	* Given a user profile is Sales Leader 
	* When the profile changes to Agent
	* Then the Sales Leader Is removed from Public Group
	* Related Stories:
	* S-188767
	**********************************************/
	@isTest
	public static void salesleaderChangeProfileToAgent() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_GroupMember_StepDefinitions groupMemberStepDefinitions = new BDD_GroupMember_StepDefinitions();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('2.02 Sales Leader');
		userStepDefinitions.givenTheUserIsMemberOfGroup(groupMemberStepDefinitions.getGroupId('Sales_Leaders'));
		userStepDefinitions.userProfileChange('2.00 Agent');
		userStepDefinitions.whenBatchExecutes('Batch_SalesLeaderProvisioning,Batch_PublicGroupProcessing');
		groupMemberStepDefinitions.thenUserIsRemovedFromPublicGroup(userStepDefinitions.user, 'Sales_Leaders');			
	}
		
}