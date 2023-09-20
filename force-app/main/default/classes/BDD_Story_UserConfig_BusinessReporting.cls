@isTest
private class BDD_Story_UserConfig_BusinessReporting {
	
	/********************************************
	* @description Scenerio: Business Reporting and Analytics User has read access to case
	*
	* Given a Business Reporting and Analytics User
	* And a case is owned by an Agent office in Salesforce
	* When the Business Reporting and Analytics User view the case
	* Then the Business Reporting and Analytics User can review the case
	*
	* Related Stories:
	* S128257
	**********************************************/
   @isTest
	public static void businessReportingAnalyticalUserCanReadCase() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.06 Business Reporting and Analytics');
		userStepDefinitions.givenAnUserSalesHierarchy();
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		caseStepDefinitions.whenTheUserViewsTheCase(userStepDefinitions.user);
		caseStepDefinitions.thenTheUserCanReviewTheCase();
		
	}
	
	/********************************************
	* @description Scenerio: Business Reporting and Analytics User cannot edit case
	*
	* Given a Business Reporting and Analytics User
	* And a case is owned by an Agent office in Salesforce
	* When the Business Reporting and Analytics User edit the case
	* Then the Business Reporting and Analytics User is given an error
	*
	* Related Stories:
	* S128257
	**********************************************/
	@isTest
	public static void businessReportingAnalyticalUserCannotEditCase() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.06 Business Reporting and Analytics');
		userStepDefinitions.givenAnUserSalesHierarchy();
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		caseStepDefinitions.whenTheUserEditsTheCase(userStepDefinitions.user);
		caseStepDefinitions.thenTheUserIsGivenAnError();		
	}
	
	/********************************************
	* @description Scenerio: Business Reporting and Analytics User cannot delete case
	*
	* Given a Business Reporting and Analytics User
	* And a case is owned by an Agent office in Salesforce
	* When the Business Reporting and Analytics User delete the case
	* Then the Business Reporting and Analytics User is given an error
	*
	* Related Stories:
	* S128257
	**********************************************/
	@isTest
	public static void businessReportingAnalyticalUserCannotDeleteCase() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.06 Business Reporting and Analytics');
		userStepDefinitions.givenAnUserSalesHierarchy();
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		caseStepDefinitions.whenTheUserDeleteTheCase(userStepDefinitions.user);
		caseStepDefinitions.thenTheUserIsGivenAnError();		
	}
	
	/********************************************
	* @description Scenerio: Business Reporting and Analytics User cannot create case
	*
	* Given a Business Reporting and Analytics User	
	* When the Business Reporting and Analytics User create the case
	* Then the Business Reporting and Analytics User is given an error
	*
	* Related Stories:
	* S128257
	**********************************************/
	@isTest
	public static void businessReportingAnalyticalUserCannotCreateCase() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.06 Business Reporting and Analytics');	
		caseStepDefinitions.whenCaseIsCreatedByUser(userStepDefinitions.user);
		caseStepDefinitions.thenTheUserIsGivenAnError();		
	}
	
	/********************************************
	* @description Scenerio: Business Reporting and Analytics User can access an Opportunity Note for an Opportunity
	*
	* Given a Business reporting analytical User
	* And a Opportunity in the Agent's Office
	* And an Opportunity Note created for the Opportunity
	* When the Business Reporting and Analytics User views the Opportunity Note
	* Then the Business Reporting and Analytics User is able to see the Opportunity Note
	*
	* Related Stories:
	* S-178474
	**********************************************/
	@isTest
	public static void businessReportingAnalyticalUserCanViewOpportunityNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.06 Business Reporting and Analytics');
		userStepDefinitions.givenAnUserSalesHierarchy();
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
        opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(TestDataFactory_User.getSysAdminUser());
		opportunityStepDefinitions.whenTheOpportunityNotesAreViewedBy(userStepDefinitions.user);
		opportunityStepDefinitions.thenTheOpportunityNotesAreViewable();
		
	}
	
	/********************************************
	* @description Scenerio: Business Reporting and Analytics User cannot create an Opportunity Note for an Opportunity
	*
	* Given a Business reporting analytical User
	* And a Opportunity in the Agent's Office
	* When the Business Reporting and Analytics User creates an Opportunity Note for the Opportunity
	* Then the Business Reporting and Analytics User is given an error
	*
	* Related Stories:
	* S-178474
	**********************************************/
	@isTest
	public static void businessReportingAnalyticalUserCannotCreateOpportunityNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.06 Business Reporting and Analytics');
		userStepDefinitions.givenAnUserSalesHierarchy();
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.whenAnOpportunityNoteIsCreatedForTheOpportunityBy(userStepDefinitions.user);
		opportunityStepDefinitions.thenTheUserisGivenAnError();
		
	}
	
	/********************************************
	* @description Scenerio: Business Reporting and Analytics User cannot edit an Opportunity Note for an Opportunity in their hierarchy
	*
	* Given a Business reporting analytical User
	* And a Opportunity in the Agent's Office
	* And an Opportunity Note created for the Opportunity
	* When the Business Reporting and Analytics User edits the Opportunity Note
	* Then the Business Reporting and Analytics user is given an error
	*
	* Related Stories:
	* S-178474
	**********************************************/
	@isTest
	public static void businessReportingAnalyticalUserCannotEditOpportunityNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.06 Business Reporting and Analytics');
		userStepDefinitions.givenAnUserSalesHierarchy();
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(TestDataFactory_User.getSysAdminUser());
		opportunityStepDefinitions.whenTheOpportunityNotesAreEditedBy(userStepDefinitions.user);
		opportunityStepDefinitions.thenTheUserisGivenAnError();
		
	}

	/********************************************
	* @description Scenerio: Business Reporting and Analytics User cannot delete an Opportunity Note for an Opportunity
	*
	* Given a Business Reporting and Analytics User
	* And a Opportunity in the Agent's Office
	* And an Opportunity Note created for the Opportunity
	* When the Business Reporting and Analytics User edits the Opportunity Note
	* Then the Business Reporting and Analytics User is given an error
	*
	* Related Stories:
	* S-178474
	**********************************************/
	@isTest
	public static void businessReportingAnalyticalUserCannotDeleteOpportunityNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.06 Business Reporting and Analytics');
		userStepDefinitions.givenAnUserSalesHierarchy();
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(userStepDefinitions.SalesUserHierarchy.AgentTeamMember);
		opportunityStepDefinitions.whenTheOpportunityNotesAreDeletedBy(userStepDefinitions.user);
		opportunityStepDefinitions.thenTheUserisGivenAnError();
		
	}
	
	/********************************************
	* @description Scenerio: Business Reporting and Analytics User can view a others case Note for a Case 
	*
	* Given Business Reporting and Analytics User
	* And a Case in created by Agent Office
	* Then the Business Reporting and Analytics User can view the Case Note 
	* 
	*
	* Related Stories:
	* S-178626
	**********************************************/
	@isTest
	public static void businessReportingAnalyticalUserCanViewOtherCaseNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_User_StepDefinitions userStepDefinitionsOther = new BDD_User_StepDefinitions();		
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.06 Business Reporting and Analytics');
		userStepDefinitionsOther.givenAnUserSalesHierarchy();
		
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitionsOther.SalesUserHierarchy.Agent);
		caseStepDefinitions.givenAnCaseNoteIsCreatedForCaseBy(userStepDefinitionsOther.SalesUserHierarchy.Agent);
		caseStepDefinitions.whenTheCaseNotesAreViewedBy(userStepDefinitions.user);
		caseStepDefinitions.thenTheCaseNotesAreViewable();
		
	}
}