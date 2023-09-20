@isTest
private class BDD_Story_UserConfig_BusinessSupport {
	
	/********************************************
	* @description Scenerio: Business Support User has read access to case
	*
	* Given a Business Support User
	* And a case is owned by an Agent office in Salesforce
	* When the Business Support User view the case
	* Then the Business Support User can review the case
	*
	* Related Stories:
	* S128247
	**********************************************/
   @isTest
	public static void businessSupportUserCanReadCase() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.08 Business Support');
		userStepDefinitions.whenPermissionSetIsAssigned('Case_SupportUsers_Enhanced_W');
		userStepDefinitions.givenAnUserSalesHierarchy();
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		caseStepDefinitions.whenTheUserViewsTheCase(userStepDefinitions.user);
		caseStepDefinitions.thenTheUserCanReviewTheCase();
		
	}
	
	/********************************************
	* @description Scenerio: Business Support User cannot edit case
	*
	* Given a Business Support User
	* And a case is owned by an Agent office in Salesforce
	* When the Business Support User edit the case
	* Then the Business Support User is given an error
	*
	* Related Stories:
	* S128257
	**********************************************/
	@isTest
	public static void businessSupportUserCannotEditCase() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.08 Business Support');
		userStepDefinitions.whenPermissionSetIsAssigned('Case_SupportUsers_R');
		userStepDefinitions.givenAnUserSalesHierarchy();
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		caseStepDefinitions.whenTheUserEditsTheCase(userStepDefinitions.user);
		caseStepDefinitions.thenTheUserIsGivenAnError();		
	}
	
	/********************************************
	* @description Scenerio: Business Support User cannot delete case
	*
	* Given a Business Support User
	* And a case is owned by an Agent office in Salesforce
	* When the Business Support User delete the case
	* Then the Business Support User is given an error
	*
	* Related Stories:
	* S128257
	**********************************************/
	@isTest
	public static void businessSupportUserCannotDeleteCase() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.08 Business Support');
		userStepDefinitions.givenAnUserSalesHierarchy();
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		caseStepDefinitions.whenTheUserDeleteTheCase(userStepDefinitions.user);
		caseStepDefinitions.thenTheUserIsGivenAnError();		
	}
	
	/********************************************
	* @description Scenerio: Business Support User cannot create case
	*
	* Given a Business Support User	
	* When the Business Support User create the case
	* Then the Business Support User is given an error
	*
	* Related Stories:
	* S128257
	**********************************************/
	@isTest
	public static void businessSupportUserCannotCreateCase() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.08 Business Support');	
		caseStepDefinitions.whenCaseIsCreatedByUser(userStepDefinitions.user);
		caseStepDefinitions.thenTheUserIsGivenAnError();		
	}
	
	/********************************************
	* @description Scenerio: Business Support User can access an Opportunity Note for an Opportunity
	*
	* Given a Business Support User
	* And a Opportunity in the Agent's Office
	* And an Opportunity Note created for the Opportunity
	* When the Business Support views the Opportunity Note
	* Then the Business Support is able to see the Opportunity Note
	*
	* Related Stories:
	* S-178474
	**********************************************/
	@isTest
	public static void businessSupportCanViewOpportunityNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.08 Business Support');
		userStepDefinitions.whenPermissionSetIsAssigned('Opportunity_FullAccess_W');
		userStepDefinitions.givenAnUserSalesHierarchy();
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(TestDataFactory_User.getSysAdminUser());
		opportunityStepDefinitions.whenTheOpportunityNotesAreViewedBy(userStepDefinitions.user);
		opportunityStepDefinitions.thenTheOpportunityNotesAreViewable();
		
	}
	
	/********************************************
	* @description Scenerio: Business Support User cannot create an Opportunity Note for an Opportunity
	*
	* Given a Business Support User
	* And a Opportunity in the Agent's Office
	* When the Business Support creates an Opportunity Note for the Opportunity
	* Then the Business Support is given an error
	*
	* Related Stories:
	* S-178474
	**********************************************/
	@isTest
	public static void businessSupportCannotCreateOpportunityNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.08 Business Support');
		userStepDefinitions.givenAnUserSalesHierarchy();
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.whenAnOpportunityNoteIsCreatedForTheOpportunityBy(userStepDefinitions.user);
		opportunityStepDefinitions.thenTheUserisGivenAnError();
		
	}
	
	/********************************************
	* @description Scenerio: Business Support User cannot edit an Opportunity Note for an Opportunity in their hierarchy
	*
	* Given a Business Support User
	* And a Opportunity in the Agent's Office
	* And an Opportunity Note created for the Opportunity
	* When the Business Support edits the Opportunity Note
	* Then the Business Support is given an error
	*
	* Related Stories:
	* S-178474
	**********************************************/
	@isTest
	public static void businessSupportCannotEditOpportunityNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.08 Business Support');
		userStepDefinitions.givenAnUserSalesHierarchy();
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(TestDataFactory_User.getSysAdminUser());
		opportunityStepDefinitions.whenTheOpportunityNotesAreEditedBy(userStepDefinitions.user);
		opportunityStepDefinitions.thenTheUserisGivenAnError();
		
	}

	/********************************************
	* @description Scenerio: Business Support User cannot delete an Opportunity Note for an Opportunity
	*
	* Given a Business Support User
	* And a Opportunity in the Agent's Office
	* And an Opportunity Note created for the Opportunity
	* When the Business Support edits the Opportunity Note
	* Then the Business Support is given an error
	*
	* Related Stories:
	* S-178474
	**********************************************/
	@isTest
	public static void businessSupportCannotDeleteOpportunityNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.08 Business Support');
		userStepDefinitions.givenAnUserSalesHierarchy();
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(userStepDefinitions.SalesUserHierarchy.AgentTeamMember);
		opportunityStepDefinitions.whenTheOpportunityNotesAreDeletedBy(userStepDefinitions.user);
		opportunityStepDefinitions.thenTheUserisGivenAnError();
		
	}
	
	/********************************************
	* @description Scenerio: Business Support User can view a others case Note for a Case 
	*
	* Given Business Support User
	* And a Case in created by Agent Office
	* Then the Business Support User can view the Case Note 
	* 
	*
	* Related Stories:
	* S-178626
	**********************************************/
	@isTest
	public static void businessSupportUserCanViewOtherCaseNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_User_StepDefinitions userStepDefinitionsOther = new BDD_User_StepDefinitions();		
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.08 Business Support');
		userStepDefinitions.whenPermissionSetIsAssigned('Case_SupportUsers_Enhanced_W');
		userStepDefinitionsOther.givenAnUserSalesHierarchy();
		
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitionsOther.SalesUserHierarchy.Agent);
		caseStepDefinitions.givenAnCaseNoteIsCreatedForCaseBy(userStepDefinitionsOther.SalesUserHierarchy.Agent);
		caseStepDefinitions.whenTheCaseNotesAreViewedBy(userStepDefinitions.user);
		caseStepDefinitions.thenTheCaseNotesAreViewable();
		
	}
}
