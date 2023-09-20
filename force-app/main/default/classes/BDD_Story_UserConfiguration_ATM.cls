/**
 * @description BDD_Story_UserConfiguration_ATM
 */
@isTest
public class BDD_Story_UserConfiguration_ATM {
	
	/********************************************
	* @description Scenerio: Agent Team Member (ATM) User has read access to case
	*
	* Given an ATM in a Sales Role Hierarchy
	* And a case is owned by the ATM's Agent office
	* When the ATM view the case
	* Then the ATM can review the case
	*
	* Related Stories:
	* S128246
	**********************************************/
	@isTest
	public static void atmCanReadCase() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAnUserSalesHierarchy();
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		caseStepDefinitions.whenTheUserViewsTheCase(userStepDefinitions.SalesUserHierarchy.AgentTeamMember);
		caseStepDefinitions.thenTheUserCanReviewTheCase();
		
	}
	
	/********************************************
	* @description Scenerio: Agent Team Member (ATM) User has edit access to case
	*
	* Given an ATM in a Sales Role Hierarchy
	* And a case is owned by the ATM's Agent office
	* When the ATM view the case
	* Then the ATM can review the case
	*
	* Related Stories:
	* S128246
	**********************************************/
	@isTest
	public static void atmCanEditCase() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAnUserSalesHierarchy();
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		caseStepDefinitions.whenTheUserEditsTheCase(userStepDefinitions.SalesUserHierarchy.AgentTeamMember);
		caseStepDefinitions.thenTheUserCanReviewTheCase();
		
	}
	
	
	/********************************************
	* @description Scenerio: ATM User cannot edit an Opportunity Note for an Opportunity in their hierarchy
	*
	* Given an ATM in a Sales Role Hierarchy
	* And a Opportunity in the Agent's Office
	* And an Opportunity Note created for the Opportunity
	* When the ATM edits the Opportunity Note
	* Then the ATM is given an error
	*
	* Related Stories:
	* S-178261
	**********************************************/
	@isTest
	public static void atmCannotEditOpportunityNoteInHierarchy() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAnUserSalesHierarchy();
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(TestDataFactory_User.getSysAdminUser());
		opportunityStepDefinitions.whenTheOpportunityNotesAreEditedBy(userStepDefinitions.SalesUserHierarchy.AgentTeamMember);
		//opportunityStepDefinitions.thenTheUserisGivenAnError();
		
	}


	/********************************************
	* @description Scenerio: ATM User cannot delete an Opportunity Note for an Opportunity
	*
	* Given an ATM in a Sales Role Hierarchy
	* And a Opportunity in the Agent's Office
	* And an Opportunity Note created for the Opportunity
	* When the ATM edits the Opportunity Note
	* Then the ATM is given an error
	*
	* Related Stories:
	* S-178261
	**********************************************/
	@isTest
	public static void atmCannotDeleteOpportunityNoteInHierarchy() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAnUserSalesHierarchy();
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(userStepDefinitions.SalesUserHierarchy.AgentTeamMember);
		opportunityStepDefinitions.whenTheOpportunityNotesAreDeletedBy(userStepDefinitions.SalesUserHierarchy.AgentTeamMember);
		opportunityStepDefinitions.thenTheUserisGivenAnError();
		
	}
	
	
	/********************************************
	* @description Scenerio: ATM User can access an Opportunity Note for an Opportunity in their hierarchy
	*
	* Given an ATM in a Sales Role Hierarchy
	* And a Opportunity in the Agent's Office
	* And an Opportunity Note created for the Opportunity
	* When the ATM views the Opportunity Note
	* Then the ATM is able to see the Opportunity Note
	*
	* Related Stories:
	* S-178465
	**********************************************/
	@isTest
	public static void atmCanViewOpportunityNoteInHierarchy() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAnUserSalesHierarchy();
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(TestDataFactory_User.getSysAdminUser());
		opportunityStepDefinitions.whenTheOpportunityNotesAreViewedBy(userStepDefinitions.SalesUserHierarchy.AgentTeamMember);
		opportunityStepDefinitions.thenTheOpportunityNotesAreViewable();
		
	}
	
	/********************************************
	* @description Scenerio: ATM User cannot view an Opportunity Note for an Opportunity outside their Hierarchy
	*
	* Given an ATM in a Sales Role Hierarchy
	* And a Opportunity in another Agent's Office
	* And an Opportunity Note created for the Opportunity
	* Then the ATM cannot view the Opportunity Note
	*
	* Related Stories:
	* S-178465
	**********************************************/
	@isTest
	public static void atmCannotViewOpportunityNoteOutsideHierarchy() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_User_StepDefinitions userStepDefinitionsOther = new BDD_User_StepDefinitions();		
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		
		userStepDefinitions.givenAnUserSalesHierarchy('a');
		userStepDefinitionsOther.givenAnUserSalesHierarchy('b');
		opportunityStepDefinitions.givenAnOpportunityForOwner(userStepDefinitionsOther.SalesUserHierarchy.AgentOffice);
		opportunityStepDefinitions.givenAnOpportunityNoteIsCreatedForOpportunityBy(userStepDefinitionsOther.SalesUserHierarchy.AgentTeamMember);
		opportunityStepDefinitions.whenTheOpportunityNotesAreViewedBy(userStepDefinitions.SalesUserHierarchy.AgentTeamMember);
		opportunityStepDefinitions.thenTheUserisNotAbleToViewTheNotes();
		
	}
	
	/**************************
     * @description Scenerio: Validate the opportunity note comments that SPI is not alloawed.
     * 
     * Given an Account and Opportunity on Salesforce
     * And has a valid Agent Team Member User on Salesforce
     * When Agent Team Member user enters the comments on Opportunity Note which contains SPI data
     * Then verify the error message 'Sensitive Personal Information (SPI) is not allowed to be in entered in the Opportunity Note Comments field' 
     * 
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
		opportunityStepDefinitions.whenAnOpportunityNoteWithSPIIsCreatedForTheOpportunityBy(TestDataFactory_User.getSysAdminUser());								
		opportunityStepDefinitions.thenTheUserIsGivenAnError();
		opportunityStepDefinitions.thenTheOpportunityNoteIsNotCreated();
        
    }
    
    /********************************************
	* @description Scenerio: ATM can create a Case Note for a Case
	*
	* Given a ATM in a Sales Role Hierarchy
	* And a Case is owned by the Agent's Office
	* When the ATM creates a Case Note for a Case
	* Then the Case Note is created
	*
	* Related Stories:
	* S-178627
	**********************************************/
	@isTest
	public static void atmCanCreateCaseNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		userStepDefinitions.givenAnUserSalesHierarchy();
		caseStepDefinitions.givenACaseIsOwnedBy (userStepDefinitions.SalesUserHierarchy.AgentOffice);
		caseStepDefinitions.whenACaseNoteIsCreatedForTheCaseBy (userStepDefinitions.SalesUserHierarchy.AgentTeamMember);
		caseStepDefinitions.thenTheCaseNoteIsCreated();
	}
	
	 /********************************************
	* @description Scenerio: ATM can view a Case Note for a Case
	*
	* Given a ATM in a Sales Role Hierarchy
	* And a Case is owned by the Agent's Office
	* When the ATM views a Case Note for a Case
	* Then the ATM is able to see the Case Notes detail
	*
	* Related Stories:
	* S-178627
	**********************************************/
	@isTest
	public static void atmCanReadCaseNote() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		userStepDefinitions.givenAnUserSalesHierarchy();
		caseStepDefinitions.givenACaseIsOwnedBy (userStepDefinitions.SalesUserHierarchy.AgentOffice);
		caseStepDefinitions.whenACaseNoteIsCreatedForTheCaseBy (userStepDefinitions.SalesUserHierarchy.Agent);
		caseStepDefinitions.whenTheCaseNotesAreViewedBy (userStepDefinitions.SalesUserHierarchy.AgentTeamMember);
		caseStepDefinitions.thenTheCaseNotesAreViewable();
	}
	
	/**************************
     * @description Scenerio: Validate the Case note comments that SPI is not allowed.
     * 
     * Given a Case note on Salesforce
     * And has a valid ATM user on Salesforce
     * When ATM user enters the comments on Case Note which contains SPI data
     * Then verify the error message 'Sensitive Personal Information (SPI) is not allowed to be in entered in the Case Note Comments field' 
     * 
     * Related Stories: 
     * S-178625 
     * ***********************************************/
    @isTest 
    static void validateCaseNoteCommentsWithSPIdata() {  
      
        BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();	
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAnUserSalesHierarchy();
		
		caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions.SalesUserHierarchy.AgentOffice);
		caseStepDefinitions.whenACaseNoteWithSPIIsCreatedForTheCaseBy(userStepDefinitions.SalesUserHierarchy.AgentTeamMember);								
		caseStepDefinitions.thenTheUserIsGivenAnError();
		caseStepDefinitions.thenTheCaseNoteIsNotCreated();
				        
    }
    
     /********************************************
	* @description Scenerio: ATM User cannot change case owner  
	*
	* Given an ATM in a Sales Role Hierarchy
	* And a case is owned by the Agent office	
	* When the  ATM User tries to change the case owner
	* Then the ATM User is given an error
	*
	* Related Stories:
	* S-181498
	**********************************************/
	@isTest
    public static void atmCannotChangeCaseOwner() {
      	       
        BDD_User_StepDefinitions userStepDefinitions_One = new BDD_User_StepDefinitions();
        BDD_User_StepDefinitions userStepDefinitions_Two = new BDD_User_StepDefinitions();		        	
        BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
                
        userStepDefinitions_One.givenAnUserSalesHierarchy('a');
        userStepDefinitions_Two.givenAnUserSalesHierarchy('b');
        
    	caseStepDefinitions.givenACaseIsOwnedBy(userStepDefinitions_One.SalesUserHierarchy.AgentOffice);		    	    	    	    	
   		caseStepDefinitions.whenTheUserChangeTheOwnerCaseBy(userStepDefinitions_One.SalesUserHierarchy.AgentTeamMember,userStepDefinitions_Two.SalesUserHierarchy.AgentOffice);
    	caseStepDefinitions.thenTheUserisGivenAnError();		
    	
    }
}