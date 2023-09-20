/**
 * @description BDD_Story_UserConfiguration_System_Admin
 */
@isTest
private class BDD_Story_UserConfiguration_System_Admin {


	/********************************************
	* @description Scenerio: Sytem Admin can create an Opportunity Note for an Opportunity
	*
	* Given a System Admin user 
	* And a Opportunity in the Agent's Office
	* When the Sytem Admin creates an Opportunity Note for the Opportunity
	* Then the Opportunity Note is created
	*
	* Related Stories:
	* S-178524
	**********************************************/
	@isTest
	public static void sytemAdminCanCreateOpportunityNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenASystemAdminIsCreated() ;
	
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.user);
		opportunityStepDefinitions.whenAnOpportunityNoteIsCreatedForTheOpportunityBy(userStepDefinitions.user);
		opportunityStepDefinitions.thenTheOpportunityNoteIsCreated();
		
	}
	/********************************************
	* @description Scenerio: System Admin User can edit an Opportunity Note for an Opportunity
	*
	* Given System Admin user
	* And a Opportunity in the Agent's Office
	* And an Opportunity Note created for the Opportunity
	* When System Admin user edits the Opportunity Note
	* Then System Admin user is able to edit Opportunity Note
	* 
	* Related Stories:
	* S-178524
	**********************************************/
	@isTest
	public static void systemAdminCanEditOpportunityNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAsystemAdminIsCreated();
		
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.user);
		opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(userStepDefinitions.user);
		opportunityStepDefinitions.whenTheOpportunityNotesAreEditedBy(userStepDefinitions.user);
		opportunityStepDefinitions.thenTheOpportunityNoteIsEdited();
		
	}
	/********************************************
	* @description Scenerio: System Admin can delete an Opportunity Note
	*
	* Given System Admin user
	* And a Opportunity in the Agent's Office
	* And an Opportunity Note created for the Opportunity
	* When the System Admmin edits the Opportunity Note
	* Then the System Admin is able to delete
	*
	* Related Stories:
	* S-178524
	**********************************************/
	@isTest
	public static void systenAdminCanDeleteOpportunityNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAsystemAdminIsCreated();
		
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.user);
		opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(userStepDefinitions.user);
		opportunityStepDefinitions.whenTheOpportunityNotesAreDeletedBy(userStepDefinitions.user);
		opportunityStepDefinitions.thenTheOpportunityNoteIsDeleted();
		
	}
	/********************************************
	* @description Scenerio: System Admin User can view an Opportunity Note for an Opportunity that someone else created
	*
	* Given System Admin User
	* And an Opportunity in created by someone else
	* Then the system admin can view the Opportunity Note 
	* 
	* Related Stories:
	* S-178524
	**********************************************/
	@isTest
	public static void systemAdminCanViewOpportunityNoteCreatedBySomeone() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_User_StepDefinitions userStepDefinitionsOther = new BDD_User_StepDefinitions();		
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAsystemAdminIsCreated();
		userStepDefinitionsOther.givenAnUserSalesHierarchy();
		
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitionsOther.SalesUserHierarchy.AgentTeamMember);
		opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(TestDataFactory_User.getSysAdminUser());
		opportunityStepDefinitions.whenTheOpportunityNotesAreViewedBy(userStepDefinitions.user);
		opportunityStepDefinitions.thenTheOpportunityNotesAreViewable();
		
	}
	
	/**************************
     * @description Scenerio: Validate the opportunity note comments that SPI is not allowed.
     * 
     * Given an opportunity note on Salesforce
     * And has a valid system admin user on Salesforce
     * When system admin user enters the comments on Opportunity Note which contains SPI data
     * Then verify the error message 'Sensitive Personal Information (SPI) is not allowed to be in entered in the Opportunity Note Comments field 
     * 
     * Related Stories: 
     * S-178261 
     * ***********************/
    @isTest 
    static void validateOpportunityNoteCommentsWithSPIdata() {
		
		TestDataFactory_CustomSetting.createSPIDataCustomSettingsForOpportunityNote();
    	TestDataFactory_CustomSetting.createSPISecurityControlsData();
		
        BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAsystemAdminIsCreated();
		
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.user);
		opportunityStepDefinitions.whenAnOpportunityNoteWithSPIIsCreatedForTheOpportunityBy(userStepDefinitions.user);								
		opportunityStepDefinitions.thenTheUserIsGivenAnError();
		opportunityStepDefinitions.thenTheOpportunityNoteIsNotCreated();
		        
    }
    /********************************************
	* @description Scenerio: Sytem Admin can create a Case Note for a Case
	*
	* Given a System Admin user 
	* And a Case in the Agent's Office
	* When the Sytem Admin creates a Case Note for the Case
	* Then the Case Note is created
	*
	* Related Stories:
	* S-178629
	**********************************************/
	@isTest
	public static void sytemAdminCanCreateCaseNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenASystemAdminIsCreated() ;
	
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.user);
		caseStepDefinitions.whenACaseNoteIsCreatedForTheCaseBy(userStepDefinitions.user);
		caseStepDefinitions.thenTheCaseNoteIsCreated();
		
	}
	/********************************************
	* @description Scenerio: System Admin User can edit an Case Note for a Case
	*
	* Given System Admin user
	* And a Case in the Agent's Office
	* And a Case Note created for the Case
	* When System Admin user edits the Case Note
	* Then System Admin user is able to edit Case Note
	* 
	* Related Stories:
	* S-178629
	**********************************************/
	@isTest
	public static void systemAdminCanEditCaseNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAsystemAdminIsCreated();
		
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.user);
		caseStepDefinitions.givenAnCaseNoteIsCreatedForCaseBy(userStepDefinitions.user);
		caseStepDefinitions.whenTheCaseNotesAreEditedBy(userStepDefinitions.user);
		caseStepDefinitions.thenTheCaseNoteIsEdited();
		
	}
	
	/********************************************
	* @description Scenerio: System Admin can delete a Case Note
	*
	* Given System Admin user
	* And a Case in the Agent's Office
	* And a Case Note created for the Case
	* When the System Admmin edits the Case Note
	* Then the System Admin is able to delete
	*
	* Related Stories:
	* S-178629
	**********************************************/
	@isTest
	public static void systenAdminCanDeleteCaseNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAsystemAdminIsCreated();
		
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.user);
		caseStepDefinitions.givenAnCaseNoteIsCreatedForCaseBy(userStepDefinitions.user);
		caseStepDefinitions.whenTheCaseNotesAreDeletedBy(userStepDefinitions.user);
		caseStepDefinitions.thenTheCaseNoteIsDeleted();
		
	}
		
	/********************************************
	* @description Scenerio: System Admin User can view a other's case Note for a Case 
	*
	* Given System Admin User
	* And a Case in created Agent's Office
	* Then the system admin can view the Case Note 
	* 
	* Related Stories:
	* S-178629
	**********************************************/
	@isTest
	public static void systemAdminCanViewOtherCaseNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_User_StepDefinitions userStepDefinitionsOther = new BDD_User_StepDefinitions();		
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAsystemAdminIsCreated();
		userStepDefinitionsOther.givenAnUserSalesHierarchy();
		
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitionsOther.SalesUserHierarchy.AgentTeamMember);
		caseStepDefinitions.givenAnCaseNoteIsCreatedForCaseBy(userStepDefinitionsOther.SalesUserHierarchy.AgentTeamMember);
		caseStepDefinitions.whenTheCaseNotesAreViewedBy(userStepDefinitions.user);
		caseStepDefinitions.thenTheCaseNotesAreViewable();
		
	}
	
	/********************************************
     * @description Scenerio: Validate the Case note comments that SPI is not allowed.
     * 
     * Given a Case note on Salesforce
     * And has a valid system admin user on Salesforce
     * When system admin user enters the comments on Case Note which contains SPI data
     * Then verify the error message 'Sensitive Personal Information (SPI) is not allowed to be in entered in the Case Note Comments field 
     * 
     * Related Stories: 
     * S-178625
     * ********************************************/
    @isTest 
    static void validateCaseNoteCommentsWithSPIdata() {  
      
        BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAsystemAdminIsCreated();
		
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.user);
		caseStepDefinitions.whenACaseNoteWithSPIIsCreatedForTheCaseBy(userStepDefinitions.user);								
		caseStepDefinitions.thenTheUserIsGivenAnError();
		caseStepDefinitions.thenTheCaseNoteIsNotCreated();
				        
    }
    
    /********************************************
	* @description Scenerio: System Admin user  has delete access to case
	*
	* Given a System Admin user 
	* And a case is owned by an Agent office in Salesforce
	* When the System Admin user delete the case
	* Then the System Admin user cannot review the case
	*
	* Related Stories:
	* S-179190
	**********************************************/
	@isTest
	public static void systemAdminCanDeleteCase() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		TestDataFactory_CustomSetting.createDeleteRecordConfig('System Administrator', 'Case'); 
		
		userStepDefinitions.givenASystemAdminIsCreated() ;
		userStepDefinitions.givenAnUserSalesHierarchy();
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		caseStepDefinitions.whenTheUserDeleteTheCase(userStepDefinitions.user);
		caseStepDefinitions.thenTheUserCannotReviewTheCase();		
	}
}