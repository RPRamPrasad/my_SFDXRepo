/**
 * @description BDD_Story_UserConfig_CCCUnlicensed
*/
@isTest
private class BDD_Story_UserConfig_CCCUnlicensed {

    /********************************************
	* @description Scenerio: CCC Unlicensed User can access an Opportunity Note for an Opportunity 
	*
	* Given a CCC Unlicensed User
	* And a Opportunity in the Agent's Office
	* And an Opportunity Note created for the Opportunity
	* When the CCC Unlicensed User views the Opportunity Note
	* Then the CCC Unlicensed User is able to see the Opportunity Note
	*
	* Related Stories:
	* S-178612
	**********************************************/
	@isTest
	public static void cccunlicensedCanViewOpportunityNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('3.01 CCC Unlicensed');
		userStepDefinitions.givenAnUserSalesHierarchy();
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(TestDataFactory_User.getSysAdminUser());
		opportunityStepDefinitions.whenTheOpportunityNotesAreViewedBy(userStepDefinitions.User);
		opportunityStepDefinitions.thenTheOpportunityNotesAreViewable();
		
	}
	/********************************************
	* @description Scenerio: CCC Unlicensed can cannot create an Opportunity Note for an Opportunity
	*
	* Given an CCC Unlicensed User 
	* And a Opportunity in the Agent's Office
	* When the CCC Unlicensed User creates an Opportunity Note for the Opportunity
	* Then the CCC Unlicensed User is given an error
	*
	* Related Stories:
	* S-178612
	**********************************************/
	@isTest
	public static void cccunlicensedCannotCreateOpportunityNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('3.01 CCC Unlicensed');
		userStepDefinitions.givenAnUserSalesHierarchy();
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.whenAnOpportunityNoteIsCreatedForTheOpportunityBy(userStepDefinitions.User);
		opportunityStepDefinitions.thenTheUserisGivenAnError();
		
	}
	
	/********************************************
	* @description Scenerio: CCC Unlicensed User cannot edit an Opportunity Note for an Opportunity
	*
	* Given an CCC Unlicensed User
	* And a Opportunity in the Agent's Office
	* And an Opportunity Note created for the Opportunity
	* When the CCC Unlicensed User edits the Opportunity Note
	* Then the CCC Unlicensed User is given an error
	*
	* Related Stories:
	* S-178612
	**********************************************/
	@isTest
	public static void cccunlicensedCannotEditOpportunityNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('3.01 CCC Unlicensed');
		userStepDefinitions.givenAnUserSalesHierarchy();
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(TestDataFactory_User.getSysAdminUser());
		opportunityStepDefinitions.whenTheOpportunityNotesAreEditedBy(userStepDefinitions.User);
		opportunityStepDefinitions.thenTheUserisGivenAnError();
		
	}

	/********************************************
	* @description Scenerio: CCC Unlicensed User cannot delete an Opportunity Note for an Opportunity
	*
	* Given a CCC Unlicensed User
	* And a Opportunity in the Agent's Office
	* And an Opportunity Note created for the Opportunity
	* When the CCC Unlicensed User edits the Opportunity Note
	* Then the CCC Unlicensed User is given an error
	*
	* Related Stories:
	* S-178612
	**********************************************/
	@isTest
	public static void cccunlicensedCannotDeleteOpportunityNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('3.01 CCC Unlicensed');
		userStepDefinitions.givenAnUserSalesHierarchy();
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(userStepDefinitions.SalesUserHierarchy.AgentTeamMember);
		opportunityStepDefinitions.whenTheOpportunityNotesAreDeletedBy(userStepDefinitions.User);
		opportunityStepDefinitions.thenTheUserisGivenAnError();
		
	}	
	
	 /********************************************
	* @description Scenerio: CCC Unlicensed user can view a Case Note for a Case
	*
	* Given a CCC Unlicensed user in a Salesforce
	* And a Case is owned by the Agent's Office
	* When the CCC Unlicensed user views a Case Note for a Case
	* Then the CCC Unlicensed user is able to see the Case Notes detail
	*
	* Related Stories:
	* S-187203
	**********************************************/
	@isTest
	public static void ccclicensedCanReadCaseNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		userStepDefinitions.givenAUserInSalesforceWithProfile('3.01 CCC UnLicensed');
		userStepDefinitions.givenAnUserSalesHierarchy();
		caseStepDefinitions.givenACaseIsOwnedBy (userStepDefinitions.SalesUserHierarchy.AgentOffice);
		caseStepDefinitions.whenACaseNoteIsCreatedForTheCaseBy (userStepDefinitions.SalesUserHierarchy.Agent); 
		caseStepDefinitions.whenTheCaseNotesAreViewedBy (userStepDefinitions.User);
		caseStepDefinitions.thenTheCaseNotesAreViewable();
	}
	
}