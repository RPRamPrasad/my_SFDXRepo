/**
 * @description BDD_Story_UserConfiguration_TechSupport
 */
@isTest
public class BDD_Story_UserConfiguration_TechSupport {
	
	/********************************************
	* @description Scenerio: Technical Support User has read access to case
	*
	* Given a Technical Support User
	* And a case is owned by an Agent office in Salesforce
	* When the Technical Support User view the case
	* Then the Technical Support User can review the case
	*
	* Related Stories:
	* S128248
	**********************************************/
	@isTest
	public static void technicalSupportCanReadCase() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
		userStepDefinitions.whenPermissionSetIsAssigned('Case_SupportUsers_Enhanced_W');
		userStepDefinitions.givenAnUserSalesHierarchy();
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		caseStepDefinitions.whenTheUserViewsTheCase(userStepDefinitions.user);
		caseStepDefinitions.thenTheUserCanReviewTheCase();
		
	}
	
	/********************************************
	* @description Scenerio: Technical Support User has edit access to case
	*
	* Given a Technical Support User
	* And a case is owned by an Agent office in Salesforce
	* When the Technical Support User edit the case
	* Then the Technical Support User can review the case
	*
	* Related Stories:
	* S128248
	**********************************************/
	@isTest
	public static void technicalSupportCanEditCase() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
		userStepDefinitions.whenPermissionSetIsAssigned('Case_SupportUsers_Enhanced_W');
		userStepDefinitions.givenAnUserSalesHierarchy();
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		caseStepDefinitions.whenTheUserEditsTheCase(userStepDefinitions.user);
		caseStepDefinitions.thenTheUserCanReviewTheCase();		
	}	
	
	/********************************************
	* @description Scenerio: Technical Support User has delete access to case
	*
	* Given a Technical Support User
	* And a case is owned by an Agent office in Salesforce
	* When the Technical Support User delete the case
	* Then the Technical Support User cannot review the case
	*
	* Related Stories:
	* S128248
	**********************************************/
	@isTest
	public static void technicalSupportCanDeleteCase() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		TestDataFactory_CustomSetting.createDeleteRecordConfig('1.07 Technical Support', 'Case'); 
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
		userStepDefinitions.whenPermissionSetIsAssigned('Case_SupportUsers_Enhanced_W');
		userStepDefinitions.givenAnUserSalesHierarchy();
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		caseStepDefinitions.whenTheUserDeleteTheCase(userStepDefinitions.user);
		caseStepDefinitions.thenTheUserCannotReviewTheCase();		
	}
	
		
	 /********************************************
	* @description Scenerio: Technical Support User can access an Opportunity Note for an Opportunity
	*
	* Given a Technical Support User
	* And a Opportunity in the Agent's Office
	* And an Opportunity Note created for the Opportunity
	* When the Technical Support views the Opportunity Note
	* Then the Technical Support is able to see the Opportunity Note
	*
	* Related Stories:
	* S-178474
	**********************************************/
	@isTest
	public static void technicalSupportCanViewOpportunityNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
		userStepDefinitions.whenPermissionSetIsAssigned('Opportunity_FullAccess_W');
		userStepDefinitions.givenAnUserSalesHierarchy();
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(TestDataFactory_User.getSysAdminUser());
		opportunityStepDefinitions.whenTheOpportunityNotesAreViewedBy(userStepDefinitions.user);
		opportunityStepDefinitions.thenTheOpportunityNotesAreViewable();
		
	}
	
	/********************************************
	* Scenerio: Technical Support User can delete an Opportunity 
	*
	* Given a Technical Support User
	* And a Opportunity in the Agent's Office
	* When the Technical Support tries to delete Opportunity
	* Then the Technical Support User cannot review the Opportunity
	*
	* Related Stories:
	* S-178474
	**********************************************/
	// @isTest
	// public static void technical_support_can_delete_opportunity() {
	// 	TestDataFactory_CustomSetting.createDeleteRecordConfig('1.07 Technical Support', 'Opportunity'); 
	// 	BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
	// 	BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();		
		
	// 	userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
	// 	userStepDefinitions.whenPermissionSetIsAssigned('Opportunity_FullAccess_W');
	// 	userStepDefinitions.givenAnUserSalesHierarchy();
	// 	opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
	// 	opportunityStepDefinitions.whenTheOpportunityAreDeletedBy(userStepDefinitions.User);
	// 	opportunityStepDefinitions.thenTheOpportunityIsDeleted();
		
	// }
	/********************************************
	* @description Scenerio: Technical Support User can create a Case Note for a Case
	*
	* Given a Technical Support User 
	* And a Case in the Agent's Office
	* When the Technical Support User creates a Case Note for the Case
	* Then the Case Note is created
	*
	* Related Stories:
	* S-178626
	**********************************************/
	@isTest
	public static void technicalSupportCanCreateCaseNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
		userStepDefinitions.whenPermissionSetIsAssigned('Case_SupportUsers_Enhanced_W');
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.user);
		caseStepDefinitions.whenACaseNoteIsCreatedForTheCaseBy(userStepDefinitions.user);
		caseStepDefinitions.thenTheCaseNoteIsCreated();
		
	}
	/********************************************
	* @description Scenerio: Technical Support User can edit an Case Note for a Case
	*
	* Given Technical Support User
	* And a Case in the Agent's Office
	* And a Case Note created for the Case
	* When Technical Support User edits the Case Note
	* Then Technical Support User is able to edit Case Note
	* 
	* Related Stories:
	* S-178626
	**********************************************/
	@isTest
	public static void technicalSupportCanEditCaseNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
		userStepDefinitions.whenPermissionSetIsAssigned('Case_SupportUsers_Enhanced_W');
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.user);
		caseStepDefinitions.givenAnCaseNoteIsCreatedForCaseBy(userStepDefinitions.user);
		caseStepDefinitions.whenTheCaseNotesAreEditedBy(userStepDefinitions.user);
		caseStepDefinitions.thenTheCaseNoteIsEdited();
		
	}
	
	/********************************************
	* @description Scenerio: Technical Support User can delete a Case Note
	*
	* Given Technical Support User
	* And a Case in the Agent's Office
	* And a Case Note created for the Case
	* When the Technical Support User edits the Case Note
	* Then the Technical Support User is able to delete
	*
	* Related Stories:
	* S-178626
	**********************************************/
	@isTest
	public static void technicalSupportCanDeleteCaseNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
		userStepDefinitions.whenPermissionSetIsAssigned('Case_SupportUsers_Enhanced_W');
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.user);
		caseStepDefinitions.givenAnCaseNoteIsCreatedForCaseBy(userStepDefinitions.user);
		caseStepDefinitions.whenTheCaseNotesAreDeletedBy(userStepDefinitions.user);
		caseStepDefinitions.thenTheCaseNoteIsDeleted();
		
	}
	
	/********************************************
	* Scenerio: Technical Support User can view a case Note for a Case created by Technical Support User
	*
	* Given Technical Support User
	* And a Case in created by Technical Support User
	* Then the Technical Support User can view the Case Note 
	* 
	*
	* Related Stories:
	* S-178626
	**********************************************/
	// @isTest
	// public static void technical_support_can_view_case_note() {
	// 	BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
	// 	BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
	// 	userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
	// 	userStepDefinitions.whenPermissionSetIsAssigned('Case_SupportUsers_Enhanced_W');
	// 	caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.user);
	// 	caseStepDefinitions.givenAnCaseNoteIsCreatedForCaseBy(userStepDefinitions.user);
	// 	caseStepDefinitions.whenTheCaseNotesAreViewedBy(userStepDefinitions.user);
	// 	caseStepDefinitions.thenTheCaseNotesAreViewable();
		
	// }
	
	/********************************************
	* @description Scenerio: Technical Support User can view a others case Note for a Case 
	*
	* Given Technical Support User
	* And a Case in created by Agent Office
	* Then the Technical Support User can view the Case Note 
	* 
	*
	* Related Stories:
	* S-178626
	**********************************************/
	@isTest
	public static void technicalSupportCanViewOtherCaseNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_User_StepDefinitions userStepDefinitionsOther = new BDD_User_StepDefinitions();		
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
		userStepDefinitions.whenPermissionSetIsAssigned('Case_SupportUsers_Enhanced_W');
		userStepDefinitionsOther.givenAnUserSalesHierarchy();
		
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitionsOther.SalesUserHierarchy.Agent);
		caseStepDefinitions.givenAnCaseNoteIsCreatedForCaseBy(userStepDefinitionsOther.SalesUserHierarchy.Agent);
		caseStepDefinitions.whenTheCaseNotesAreViewedBy(userStepDefinitions.user);
		caseStepDefinitions.thenTheCaseNotesAreViewable();
		
	}
	
	/**************************
     * @description Scenerio: Validate the Case note comments that SPI is not allowed.
     * 
     * Given a Case note on Salesforce
     * And has a valid Technical Support User on Salesforce
     * When Technical Support User enters the comments on Case Note which contains SPI data
     * Then verify the error message 'Sensitive Personal Information (SPI) is not allowed to be in entered in the Case Note Comments field' 
     * 
     * 
     * Related Stories: 
     * S-178626
     * 
     * ***********************/
    @isTest 
    static void validateCaseNoteCommentsWithSPIdata() {  
      
        BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
		userStepDefinitions.whenPermissionSetIsAssigned('Case_SupportUsers_Enhanced_W');
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.user);
		caseStepDefinitions.whenACaseNoteWithSPIIsCreatedForTheCaseBy(userStepDefinitions.user);								
		caseStepDefinitions.thenTheUserIsGivenAnError();
		caseStepDefinitions.thenTheCaseNoteIsNotCreated();
				        
    }
        
    
	/********************************************
	* @description Scenerio: Technical Support User has access to change the case owner
	*
	* Given a Technical Support User
	* And a case is created and owned by an Case QUEUE
	* When Technical Support User tries to change the case owner
	* Then the Case is reassigned to appropriate User
	*
	* Related Stories:
	* S-190195
	**********************************************/
	@isTest
	public static void technicalSupportUserCanChangeCaseOwner() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_User_StepDefinitions userStepDefinitionsOne = new BDD_User_StepDefinitions();
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
		userStepDefinitions.whenPermissionSetIsAssigned('Case_SupportUsers_Enhanced_W');
		userStepDefinitionsOne.givenAnUserSalesHierarchy('a');
		caseStepDefinitions.givenACaseIsOwnedByTheSupportQueue();
        caseStepDefinitions.whenTheUserChangeTheOwnerCaseBy(userStepDefinitions.user,userStepDefinitionsOne.SalesUserHierarchy.AgentOffice);
        caseStepDefinitions.thenTheCaseOwnerIsAgentOffice(userStepDefinitionsOne.SalesUserHierarchy.AgentOffice);		
	}	

	/********************************************
	* @description Scenerio: Technical Support User who is deactivated cannot change the case owner
	*
	* Given an InActive Technical Support User
	* And a case is created and owned by a Case QUEUE
	* When Technical Support User tries to change the case owner
	* Then the exception is thrown
	*
	* Related Stories:
	* S-191392
	**********************************************/
	@isTest
	public static void technicalSupportInactiveUserCannotChangeCaseOwner() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_User_StepDefinitions userStepDefinitionsOne = new BDD_User_StepDefinitions();
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAnInactiveUserInSalesforceWithProfile('1.07 Technical Support');
		userStepDefinitionsOne.givenAnUserSalesHierarchy('a');
		caseStepDefinitions.givenACaseIsOwnedByTheSupportQueue();
        caseStepDefinitions.whenTheUserChangeTheOwnerCaseBy(userStepDefinitions.user,userStepDefinitionsOne.SalesUserHierarchy.AgentOffice);
    	caseStepDefinitions.thenTheUserIsGivenAnError();		
	}
}
