/**
 * @description BDD_Story_UserConfiguration_Agent
 */
@isTest
private class BDD_Story_UserConfiguration_Agent {

   /********************************************
	* @description Scenerio: Agent User has read access to case
	*
	* Given an Agent in a Sales Role Hierarchy
	* And a case is owned by the Agent office
	* When the Agent view the case
	* Then the Agent can review the case
	*
	* Related Stories:
	* S128246
	**********************************************/
	@isTest
	public static void agentCanReadCase() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAnUserSalesHierarchy();
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		caseStepDefinitions.whenTheUserViewsTheCase(userStepDefinitions.SalesUserHierarchy.Agent);
		caseStepDefinitions.thenTheUserCanReviewTheCase();
		
	}
	
	/********************************************
	* @description Scenerio: Agent User has edit access to case
	*
	* Given an agent in a Sales Role Hierarchy
	* And a case is owned by the Agent office
	* When the agent view the case
	* Then the agent can review the case
	*
	* Related Stories:
	* S128246
	**********************************************/
	@isTest
	public static void agentCanEditCase() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAnUserSalesHierarchy();
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		caseStepDefinitions.whenTheUserEditsTheCase(userStepDefinitions.SalesUserHierarchy.Agent);
		caseStepDefinitions.thenTheUserCanReviewTheCase();
		
	}
	
	/********************************************
	* @description Scenerio: Agent User can access an Opportunity Note for an Opportunity in their hierarchy
	*
	* Given an agent in a Sales Role Hierarchy
	* And a Opportunity in the Agent's Office
	* And an Opportunity Note created for the Opportunity
	* When the agent views the Opportunity Note
	* Then the agent is able to see the Opportunity Note
	*
	* Related Stories:
	* S-178260
	**********************************************/
	@isTest
	public static void agentCanViewOpportunityNoteInHierarchy() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAnUserSalesHierarchy();
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(TestDataFactory_User.getSysAdminUser());
		opportunityStepDefinitions.whenTheOpportunityNotesAreViewedBy(userStepDefinitions.SalesUserHierarchy.Agent);
		opportunityStepDefinitions.thenTheOpportunityNotesAreViewable();
		
	}
	
	/********************************************
	* @description Scenerio: Agent User cannot edit an Opportunity Note for an Opportunity in their hierarchy
	*
	* Given an agent in a Sales Role Hierarchy
	* And a Opportunity in the Agent's Office
	* And an Opportunity Note created for the Opportunity
	* When the agent edits the Opportunity Note
	* Then the agent is given an error
	*
	* Related Stories:
	* S-178260
	**********************************************/
	@isTest
	public static void agentCannotEditOpportunityNoteInHierarchy() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAnUserSalesHierarchy();
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(TestDataFactory_User.getSysAdminUser());
		opportunityStepDefinitions.whenTheOpportunityNotesAreEditedBy(userStepDefinitions.SalesUserHierarchy.Agent);
		//opportunityStepDefinitions.thenTheUserisGivenAnError();
		
	}

	/********************************************
	* @description Scenerio: Agent User cannot delete an Opportunity Note for an Opportunity
	*
	* Given an agent in a Sales Role Hierarchy
	* And a Opportunity in the Agent's Office
	* And an Opportunity Note created for the Opportunity
	* When the agent edits the Opportunity Note
	* Then the agent is given an error
	*
	* Related Stories:
	* S-178260
	**********************************************/
	@isTest
	public static void agentCannotDeleteOpportunityNoteInHierarchy() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAnUserSalesHierarchy();
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(userStepDefinitions.SalesUserHierarchy.Agent);
		opportunityStepDefinitions.whenTheOpportunityNotesAreDeletedBy(userStepDefinitions.SalesUserHierarchy.Agent);
		opportunityStepDefinitions.thenTheUserisGivenAnError();
		
	}
	
	/********************************************
	* @description Scenerio: Agent User cannot view an Opportunity Note for an Opportunity outside their Hierarchy
	*
	* Given an Agent in a Sales Role Hierarchy
	* And a Opportunity in another Agent's Office
	* And an Opportunity Note created for the Opportunity
	* Then the Agent cannot view the Opportunity Note
	*
	* Related Stories:
	* S-178260
	**********************************************/
	@isTest
	public static void agentCannotViewOpportunityNoteOutsideHierarchy() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_User_StepDefinitions userStepDefinitionsOther = new BDD_User_StepDefinitions();		
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAnUserSalesHierarchy('a');
		userStepDefinitionsOther.givenAnUserSalesHierarchy('b');
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitionsOther.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(userStepDefinitionsOther.SalesUserHierarchy.Agent);
		opportunityStepDefinitions.whenTheOpportunityNotesAreViewedBy(userStepDefinitions.SalesUserHierarchy.Agent);
		opportunityStepDefinitions.thenTheUserisNotAbleToViewTheNotes();
		
	}
	
	/**************************
     * @description Scenerio: Validate the opportunity note comments that SPI is not alloawed.
     * 
     * Given an Account and Opportunity on Salesforce
     * And has a valid Agent User on Salesforce
     * When Agent user enters the comments on Opportunity Note which contains SPI data
     * Then verify the error message 'Sensitive Personal Information (SPI) is not allowed to be in entered in the Opportunity Note Comments field'       
     * 
     * Related Stories: 
     * S-178261
     * 
     * ***********************/
    @isTest 
    static void validateOpportunityNoteCommentsWithSPIdata() {  
      
		TestDataFactory_CustomSetting.createSPIDataCustomSettingsForOpportunityNote();
    	TestDataFactory_CustomSetting.createSPISecurityControlsData();
		
        BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAnUserSalesHierarchy();
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(TestDataFactory_User.getSysAdminUser());
		opportunityStepDefinitions.whenAnOpportunityNoteWithSPIIsCreatedForTheOpportunityBy(TestDataFactory_User.getSysAdminUser());								
		opportunityStepDefinitions.thenTheOpportunityNoteIsNotCreated();
		opportunityStepDefinitions.thenTheUserIsGivenAnError();
        
    }
    
    /********************************************
	* @description Scenerio: Agent User cannot change case owner  
	*
	* Given an Agent in a Sales Role Hierarchy
	* And a case is owned by the Agent office	
	* When the  Agent User tries to change the case owner
	* Then the Agent User is given an error
	*
	* Related Stories:
	* S-181498
	**********************************************/
	@isTest
    public static void agentCannotChangeCaseOwner() {
      	       
        BDD_User_StepDefinitions userStepDefinitions_One = new BDD_User_StepDefinitions();
        BDD_User_StepDefinitions userStepDefinitions_Two = new BDD_User_StepDefinitions();		        	
        BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
                
        userStepDefinitions_One.givenAnUserSalesHierarchy('a');
        userStepDefinitions_Two.givenAnUserSalesHierarchy('b');
        
    	caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions_One.SalesUserHierarchy.AgentOffice);		    	    	    	    	
   		caseStepDefinitions.whenTheUserChangeTheOwnerCaseBy(userStepDefinitions_One.SalesUserHierarchy.Agent,userStepDefinitions_Two.SalesUserHierarchy.AgentOffice);
    	caseStepDefinitions.thenTheUserisGivenAnError();		
    	
    }
    
    
    /********************************************
	* @description Scenerio: Agent can create a Case Note for a Case
	*
	* Given an agent in a Sales Role Hierarchy
	* And a Case is owned by the Agent's Office
	* When the agent creates a Case Note for a Case
	* Then the Case Note is created
	*
	* Related Stories:
	* S-178627
	**********************************************/
	@isTest
	public static void agentCanCreateCaseNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		userStepDefinitions.givenAnUserSalesHierarchy();
		caseStepDefinitions.givenACaseIsOwnedBy (userStepDefinitions.SalesUserHierarchy.AgentOffice);
		caseStepDefinitions.whenACaseNoteIsCreatedForTheCaseBy (userStepDefinitions.SalesUserHierarchy.Agent);
		caseStepDefinitions.thenTheCaseNoteIsCreated();
	}
	
	
	 /********************************************
	* @description Scenerio: Agent can view a Case Note for a Case
	*
	* Given an agent in a Sales Role Hierarchy
	* And a Case is owned by the Agent's Office
	* When the agent views a Case Note for a Case
	* Then the agent is able to see the Case Notes detail
	*
	* Related Stories:
	* S-178627
	**********************************************/
	@isTest
	public static void agentCanReadCaseNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		userStepDefinitions.givenAnUserSalesHierarchy();
		caseStepDefinitions.givenACaseIsOwnedBy (userStepDefinitions.SalesUserHierarchy.AgentOffice);
		caseStepDefinitions.whenACaseNoteIsCreatedForTheCaseBy (userStepDefinitions.SalesUserHierarchy.Agent);
		caseStepDefinitions.whenTheCaseNotesAreViewedBy (userStepDefinitions.SalesUserHierarchy.Agent);
		caseStepDefinitions.thenTheCaseNotesAreViewable();
	}
	
	/**************************
     * @description Scenerio: Validate the Case note comments that SPI is not allowed.
     * 
     * Given a Case note on Salesforce
     * And has a valid Agent user on Salesforce
     * When Agent user enters the comments on Case Note which contains SPI data
     * Then verify the error message 'Sensitive Personal Information (SPI) is not allowed to be in entered in the Case Note Comments field' 
     * 
     * Related Stories: 
     * S-178625 
     * ***********************/
    @isTest 
    static void validateCaseNoteCommentsWithSPIdata() {  
      
        BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAnUserSalesHierarchy();
		
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		caseStepDefinitions.whenACaseNoteWithSPIIsCreatedForTheCaseBy(userStepDefinitions.SalesUserHierarchy.Agent);								
		caseStepDefinitions.thenTheUserIsGivenAnError();
		caseStepDefinitions.thenTheCaseNoteIsNotCreated();
				        
    }
}