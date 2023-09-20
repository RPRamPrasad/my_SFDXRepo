@isTest
private class BDD_Story_UserConfiguration_CCC_Licensed {

   	/********************************************
	* @description Scenerio: CCC Licensed User can access an Opportunity Note for an Opportunity 
	*
	* Given a CCC Licensed User
	* And a Opportunity in the Agent's Office
	* And an Opportunity Note created for the Opportunity
	* When the CCC Licensed User views the Opportunity Note
	* Then the CCC Licensed User is able to see the Opportunity Note
	*
	* Related Stories:
	* S-178598
	**********************************************/
	@isTest
	public static void ccclicensedCanViewOpportunityNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('3.00 CCC Licensed');
		userStepDefinitions.givenAnUserSalesHierarchy();
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(TestDataFactory_User.getSysAdminUser());
		opportunityStepDefinitions.whenTheOpportunityNotesAreViewedBy(userStepDefinitions.User);
		opportunityStepDefinitions.thenTheOpportunityNotesAreViewable();
		
	}
   
	/********************************************
	* @description Scenerio: CCC Licensed User cannot edit an Opportunity Note for an Opportunity
	*
	* Given an CCC Licensed User
	* And a Opportunity in the Agent's Office
	* And an Opportunity Note created for the Opportunity
	* When the CCC Licensed User edits the Opportunity Note
	* Then the CCC Licensed User is given an error
	*
	* Related Stories:
	* S-178598
	**********************************************/
	@isTest
	public static void ccclicensedCannotEditOpportunityNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('3.00 CCC Licensed');
		userStepDefinitions.givenAnUserSalesHierarchy();
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(TestDataFactory_User.getSysAdminUser());
		opportunityStepDefinitions.whenTheOpportunityNotesAreEditedBy(userStepDefinitions.User);
		opportunityStepDefinitions.thenTheUserisGivenAnError();
		
	}

	/********************************************
	* @description Scenerio: CCC Licensed User cannot delete an Opportunity Note for an Opportunity
	*
	* Given a CCC Licensed User
	* And a Opportunity in the Agent's Office
	* And an Opportunity Note created for the Opportunity
	* When the CCC Licensed User edits the Opportunity Note
	* Then the CCC Licensed User is given an error
	*
	* Related Stories:
	* S-178598
	**********************************************/
	@isTest
	public static void ccclicensedCannotDeleteOpportunityNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('3.00 CCC Licensed');
		userStepDefinitions.givenAnUserSalesHierarchy();
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(userStepDefinitions.SalesUserHierarchy.AgentTeamMember);
		opportunityStepDefinitions.whenTheOpportunityNotesAreDeletedBy(userStepDefinitions.User);
		opportunityStepDefinitions.thenTheUserisGivenAnError();
		
	}
	
	/********************************************
	* @description Scenerio: CCC Licensed User cannot delete an Opportunity 
	*
	* Given a CCC Licensed User
	* And a Opportunity in the Agent's Office
	* When the CCC Licensed User tries to delete Opportunity
	* Then the CCC Licensed User is given an error
	*
	* Related Stories:
	* S-130301
	**********************************************/
	@isTest
	public static void ccclicensedCannotDeleteOpportunity() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('3.00 CCC Licensed');
		userStepDefinitions.givenAnUserSalesHierarchy();
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.whenTheOpportunityAreDeletedBy(userStepDefinitions.User);
		opportunityStepDefinitions.thenTheUserisGivenAnError();
		
	}
	
	/********************************************
	* @description Scenerio: CCC Licensed User cannot delete an Individual Account 
	*
	* Given a CCC Licensed User
	* And a Customer for the Agent's Office
	* When the CCC Licensed User tries to delete an Account 
	* Then the CCC Licensed User is given an error
	*
	* Related Stories:
	* S-130300
	**********************************************/
	@isTest
	public static void ccclicensedCannotDeleteIndividualAccount() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Account_StepDefinitions accountStepDefinitions = new BDD_Account_StepDefinitions();
		accountStepDefinitions.givenAnExistingAccountOnSalesforce ('Individual');
		userStepDefinitions.givenAUserInSalesforceWithProfile('3.00 CCC Licensed');
		accountStepDefinitions.whenTheAccountIsDeletedBy(userStepDefinitions.User);
		accountStepDefinitions.thenTheUserisGivenAnError();
	}	
	
	/********************************************
	* @description Scenerio: CCC Licensed User cannot delete an Organization Account 
	*
	* Given a CCC Licensed User
	* And a Customer for the Agent's Office
	* When the CCC Licensed User tries to delete an Account 
	* Then the CCC Licensed User is given an error
	*
	* Related Stories:
	* S-130300
	**********************************************/
	@isTest
	public static void ccclicensedCannotDeleteOrganizationAccount() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Account_StepDefinitions accountStepDefinitions = new BDD_Account_StepDefinitions();
		accountStepDefinitions.givenAnExistingAccountOnSalesforce ('Organization');
		userStepDefinitions.givenAUserInSalesforceWithProfile('3.00 CCC Licensed');
		accountStepDefinitions.whenTheAccountIsDeletedBy(userStepDefinitions.User);
		accountStepDefinitions.thenTheUserisGivenAnError();
	}
	
	/**************************
     * @description Scenerio: Validate CCC licensed user is not able to delete a CASE.
     * 
     * Given a Case exists on Salesforce
     * When CCC(licensed) user tries to delete the CASE
     * Then verify the case is NOT deleted      
     * 
     * Related Stories: 
     * S-130302,S-179190 
     * ***********************/     
    @isTest
    public static void cccLicensedCannotDeleteCase() {
    	BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
    	BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
    	
    	userStepDefinitions.givenAUserInSalesforceWithProfile('3.00 CCC Licensed');
    	userStepDefinitions.givenAnUserSalesHierarchy();
    	caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.SalesUserHierarchy.AgentOffice);
        caseStepDefinitions.whenTheUserDeleteTheCase(userStepDefinitions.User);
    	caseStepDefinitions.thenTheUserIsGivenAnError();
    }
    
    /**************************
     * @description Scenerio: Validate CCC licensed user is can able to delete a CASE.
     * 
     * Given a Case exists on Salesforce
     * When CCC(licensed) user tries to delete the CASE
     * Then verify the case is deleted      
     * 
     * Related Stories: 
     * S-130302,S-179190 
     * ***********************/         
    @isTest
    public static void cccLicensedCanDeleteCase() {
    	TestDataFactory_CustomSetting.createDeleteRecordConfig('3.00 CCC Licensed', 'Case'); 
    	BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
    	BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
    	
    	userStepDefinitions.givenAUserInSalesforceWithProfile('3.00 CCC Licensed');
    	userStepDefinitions.givenAnUserSalesHierarchy();
    	caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.SalesUserHierarchy.AgentOffice);
        caseStepDefinitions.whenTheUserDeleteTheCase(userStepDefinitions.User);
    	caseStepDefinitions.thenTheUserCannotReviewTheCase();   	
    }
    
	/********************************************
	* Scenerio: CCC Licensed User cannot change case owner  
	*
	* Given an Agent in a Sales Role Hierarchy
	* And a case is owned by the Agent office
	* And a CCC Licenced User
	* When the  CCC Licensed User tries to change the case owner
	* Then the CCC Licensed User is given an error
	*
	* Related Stories:
	* S-181503
	**********************************************/
	// @isTest
    // public static void ccclicensed_cannot_change_case_owner() {
      	       
    //     BDD_User_StepDefinitions userStepDefinitions_One = new BDD_User_StepDefinitions();
    //     BDD_User_StepDefinitions userStepDefinitions_CCC = new BDD_User_StepDefinitions();	
    //     BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
        
    //     userStepDefinitions_CCC.givenAUserInSalesforceWithProfile('3.00 CCC Licensed');
	// 	userStepDefinitions_One.givenAnUserSalesHierarchy('b');
    // 	caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions_One.SalesUserHierarchy.AgentOffice);    	   	
   	// 	caseStepDefinitions.whenTheUserChangeTheOwnerCaseBy(userStepDefinitions_CCC.User,userStepDefinitions_One.SalesUserHierarchy.AgentOffice);
    // 	caseStepDefinitions.thenTheUserisGivenAnError();		   	
    // }
    
    /********************************************
	* @description Scenerio: CCC Licensed user can view a Case Note for a Case
	*
	* Given a CCC Licensed user in a Salesforce
	* And a Case is owned by the Agent's Office
	* When the CCC Licensed user views a Case Note for a Case
	* Then the CCC Licensed user is able to see the Case Notes detail
	*
	* Related Stories:
	* S-187195
	*********************************************/
	@isTest
	public static void ccclicensedCanReadCaseNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		userStepDefinitions.givenAUserInSalesforceWithProfile('3.00 CCC Licensed');
		userStepDefinitions.givenAnUserSalesHierarchy();
		caseStepDefinitions.givenACaseIsOwnedBy (userStepDefinitions.SalesUserHierarchy.AgentOffice);
		caseStepDefinitions.whenACaseNoteIsCreatedForTheCaseBy (userStepDefinitions.SalesUserHierarchy.Agent); 
		caseStepDefinitions.whenTheCaseNotesAreViewedBy (userStepDefinitions.User);
		caseStepDefinitions.thenTheCaseNotesAreViewable();
	}
	
	/********************************************
	* @description Scenerio: CCC Licensed user can create a Case Note for a Case
	*
	* Given a CCC Licensed user in a Salesforce
	* And a Case is owned by the Agent's Office
	* When the CCC Licensed user creates a Case Note for a Case
	* Then the Case Note is created
	*
	* Related Stories:
	* S-187195
	**********************************************/
	@isTest
	public static void ccclicensedCanCreateCaseNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		userStepDefinitions.givenAUserInSalesforceWithProfile('3.00 CCC Licensed');
		userStepDefinitions.givenAnUserSalesHierarchy();
		caseStepDefinitions.givenACaseIsOwnedBy (userStepDefinitions.SalesUserHierarchy.AgentOffice);
		caseStepDefinitions.whenACaseNoteIsCreatedForTheCaseBy (userStepDefinitions.User);
		caseStepDefinitions.thenTheCaseNoteIsCreated();
	}
	
	/********************************************
     * @description Scenerio: Validate the Case note comments that SPI is not allowed.
     * 
     * Given a Case note on Salesforce
     * And has a valid CCC Licensed user on Salesforce
     * When CCC Licensed user enters the comments on Case Note which contains SPI data
     * Then verify the error message 'Sensitive Personal Information (SPI) is not allowed to be in entered in the Case Note Comments field 
     * 
     * Related Stories: 
     * S-187195
     * ********************************************/
    @isTest 
    static void validateCaseNoteCommentsWithSPIdata() {        
        BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAUserInSalesforceWithProfile('3.00 CCC Licensed');
		
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.user);
		caseStepDefinitions.whenACaseNoteWithSPIIsCreatedForTheCaseBy(userStepDefinitions.user);								
		caseStepDefinitions.thenTheUserIsGivenAnError();
		caseStepDefinitions.thenTheCaseNoteIsNotCreated();				        
    }
}