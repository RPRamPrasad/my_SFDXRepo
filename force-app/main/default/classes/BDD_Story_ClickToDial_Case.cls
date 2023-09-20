/**
 * @className: BDD_Story_ClickToDial_Case
 * @description BDD Story for Click To Dial Phone numbers on Case
 * @Author: Team ITIC
 **/
 
@isTest(seeAllData=false)
private class BDD_Story_ClickToDial_Case {

  /******************************************************************
  * Scenerio: Case Phone number fields are referred from Person Account
  * Click to Dial Disabled on User Agent with no preference set
  * 
  * @description Given the Agent with Click to Dial Disabled When Agent views the case Then Phone display links are just text
  *
  * Related Stories:
  * S-199189
  *********************************************************************/
   @isTest
  	public static void caseAgentWithClickToDialDisabled() { 
    	BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
    	BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
    	BDD_Account_StepDefinitions accountStepDefinitions = new BDD_Account_StepDefinitions();
    	BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
    
   	 	userStepDefinitions.givenAnUserSalesHierarchy(); 
		userStepDefinitions.givenAgentWithClickToDialPreferenceAs(userStepDefinitions.SalesUserHierarchy.Agent, '', false); /***(User, ClicktoDialPreference__c, ClickToDialEnabled__c)***/
    	/*****************(AccountType, Account.PersonMobilePhone, Account.PersonHomePhone, Account.Phone, isDoNotCallEnabled)****************/
		BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper wrapper = new BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper();
        wrapper.recordType = 'Individual';
        wrapper.personMobilePhone = '1234567123';
        wrapper.personHomePhone = '1234567123';
        wrapper.phone = '1234567123';
        wrapper.isDoNotCallEnabled = false;
    	accountStepDefinitions.givenAccountWithPhoneNumbers (wrapper);
    	caseStepDefinitions.givenANewCaseOnExistingAccount (accountStepDefinitions.account,userStepDefinitions.SalesUserHierarchy.AgentOffice);
    	
		System.runAs(userStepDefinitions.SalesUserHierarchy.Agent){
    		clickToDialStepDefinition.whenUserViewTheCase(userStepDefinitions.SalesUserHierarchy.Agent, caseStepDefinitions.cases);
		}
    
    	clickToDialStepDefinition.thenPhoneIsJustText('1234567123', clickToDialStepDefinition.caseRecord.MobilePhone__c);
    	clickToDialStepDefinition.thenPhoneIsJustText('1234567123', clickToDialStepDefinition.caseRecord.HomePhone__c);
    	clickToDialStepDefinition.thenPhoneIsJustText('1234567123', clickToDialStepDefinition.caseRecord.WorkPhone__c);
  	}
  	
  /********************************************
  * Scenerio: Case Phone number fields are Blank
  *
  * @description Given the Agent with Click to Dial Enabled and account phone numbers are blank When Agent views the case Then Phone display links are empty
  *
  * Related Stories:
  * S-199189
  **********************************************/
   @isTest
  	public static void caseAgentWithClickToDialEnabledPhoneBlank() {
    	BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
    	BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
    	BDD_Account_StepDefinitions accountStepDefinitions = new BDD_Account_StepDefinitions();
    	BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
    
    	userStepDefinitions.givenAnUserSalesHierarchy(); 
		userStepDefinitions.givenAgentWithClickToDialPreferenceAs(userStepDefinitions.SalesUserHierarchy.Agent, '11', true); /***(User, ClicktoDialPreference__c, ClickToDialEnabled__c)***/
    	/*****************(AccountType, Account.PersonMobilePhone, Account.PersonHomePhone, Account.Phone, isDoNotCallEnabled)****************/
		BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper wrapper = new BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper();
        wrapper.recordType = 'Individual';
        wrapper.personMobilePhone = null;
        wrapper.personHomePhone = null;
        wrapper.phone = null;
        wrapper.isDoNotCallEnabled = false;
    	accountStepDefinitions.givenAccountWithPhoneNumbers (wrapper);
    	caseStepDefinitions.givenANewCaseOnExistingAccount (accountStepDefinitions.account,userStepDefinitions.SalesUserHierarchy.AgentOffice);
    	
		System.runAs(userStepDefinitions.SalesUserHierarchy.Agent){
    		clickToDialStepDefinition.whenUserViewTheCase(userStepDefinitions.SalesUserHierarchy.Agent, caseStepDefinitions.cases);
		}
    
    	clickToDialStepDefinition.thenPhoneIsBlank(clickToDialStepDefinition.caseRecord.MobilePhone__c);
    	clickToDialStepDefinition.thenPhoneIsBlank(clickToDialStepDefinition.caseRecord.HomePhone__c);
    	clickToDialStepDefinition.thenPhoneIsBlank(clickToDialStepDefinition.caseRecord.WorkPhone__c);
  	}
  	
  	/******************************************************
	* Scenerio: Case Phone number fields are Hyperlinked
	*
	* @description Given the Agent with Click to Dial Preference as NONE When User view the account Then default Phone display links are formated 
	*
	* Related Stories:
	* S-199189
	********************************************************/
   @isTest
	public static void caseAgentWithClickToDialEnabledPreferenceAsNull() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
		BDD_Account_StepDefinitions accountStepDefinitions = new BDD_Account_StepDefinitions();
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAnUserSalesHierarchy(); 
		userStepDefinitions.givenAgentWithClickToDialPreferenceAs(userStepDefinitions.SalesUserHierarchy.Agent, '', true); /***(User, ClicktoDialPreference__c, ClickToDialEnabled__c)***/
		/*****************(Account Type, Account.PersonMobilePhone, Account.PersonHomePhone, Account.Phone, isDoNotCallEnabled)****************/
		BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper wrapper = new BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper();
        wrapper.recordType = 'Individual';
        wrapper.personMobilePhone = '1234567123';
        wrapper.personHomePhone = '1234567123';
        wrapper.phone = '1234567123';
        wrapper.isDoNotCallEnabled = false;
		accountStepDefinitions.givenAccountWithPhoneNumbers (wrapper);
		caseStepDefinitions.givenANewCaseOnExistingAccount (accountStepDefinitions.account,userStepDefinitions.SalesUserHierarchy.AgentOffice);
    	
		System.runAs(userStepDefinitions.SalesUserHierarchy.Agent){
    		clickToDialStepDefinition.whenUserViewTheCase(userStepDefinitions.SalesUserHierarchy.Agent, caseStepDefinitions.cases);
		}
		
		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper1 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    	bddWrapper1.user = userStepDefinitions.SalesUserHierarchy.Agent;
		bddWrapper1.display = '1234567123';
		bddWrapper1.hyperLink =  '11234567123';
		bddWrapper1.phoneFieldToAssert = clickToDialStepDefinition.caseRecord.MobilePhone__c;

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper2 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
		bddWrapper2.user = userStepDefinitions.SalesUserHierarchy.Agent;
		bddWrapper2.display = '1234567123';
		bddWrapper2.hyperLink =  '11234567123';
		bddWrapper2.phoneFieldToAssert = clickToDialStepDefinition.caseRecord.HomePhone__c;

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper3 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
		bddWrapper3.user = userStepDefinitions.SalesUserHierarchy.Agent;
		bddWrapper3.display = '1234567123';
		bddWrapper3.hyperLink =  '11234567123';
		bddWrapper3.phoneFieldToAssert = clickToDialStepDefinition.caseRecord.WorkPhone__c;

		clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper1);
		clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper2);
		clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper3);
	}
	
	 /********************************************
	* Scenerio: Case Phone number fields are Hyperlinked 
	* with Click to Dial Preference as 7
	*
	* @description Given the Agent with Click to Dial Preference as 7 When Agent views the account Then Phone display links are formated according to the User preference
	*
	* Related Stories:
	* S-199189
	**********************************************/
   @isTest
	public static void caseAgentWithClickToDialEnabledPreferenceAs7() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
		BDD_Account_StepDefinitions accountStepDefinitions = new BDD_Account_StepDefinitions();
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAnUserSalesHierarchy();
		userStepDefinitions.givenAgentWithClickToDialPreferenceAs(userStepDefinitions.SalesUserHierarchy.Agent, '7', true); /***(User, ClicktoDialPreference__c, ClickToDialEnabled__c)***/
		/*****************(Account Type, Account.PersonMobilePhone, Account.PersonHomePhone, Account.Phone, isDoNotCallEnabled)****************/
		BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper wrapper = new BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper();
        wrapper.recordType = 'Individual';
        wrapper.personMobilePhone = '1234567123';
        wrapper.personHomePhone = '1234567123';
        wrapper.phone = '1234567123';
        wrapper.isDoNotCallEnabled = false;
		accountStepDefinitions.givenAccountWithPhoneNumbers (wrapper);
		caseStepDefinitions.givenANewCaseOnExistingAccount (accountStepDefinitions.account,userStepDefinitions.SalesUserHierarchy.AgentOffice);
    	
		System.runAs(userStepDefinitions.SalesUserHierarchy.Agent){
    		clickToDialStepDefinition.whenUserViewTheCase(userStepDefinitions.SalesUserHierarchy.Agent, caseStepDefinitions.cases);
		}
		
		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper1 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    	bddWrapper1.user = userStepDefinitions.SalesUserHierarchy.Agent;
	  	bddWrapper1.display = '1234567123';
	  	bddWrapper1.hyperLink =  '4567123';
	  	bddWrapper1.longDistanceNumber = '11234567123';
	  	bddWrapper1.phoneFieldToAssert =  clickToDialStepDefinition.caseRecord.MobilePhone__c;

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper2 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    	bddWrapper2.user = userStepDefinitions.SalesUserHierarchy.Agent;
	  	bddWrapper2.display = '1234567123';
	  	bddWrapper2.hyperLink =  '4567123';
	  	bddWrapper2.longDistanceNumber = '11234567123';
	  	bddWrapper2.phoneFieldToAssert =  clickToDialStepDefinition.caseRecord.HomePhone__c;

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper3 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    	bddWrapper3.user = userStepDefinitions.SalesUserHierarchy.Agent;
	  	bddWrapper3.display = '1234567123';
	  	bddWrapper3.hyperLink =  '4567123';
	  	bddWrapper3.longDistanceNumber = '11234567123';
	  	bddWrapper3.phoneFieldToAssert =  clickToDialStepDefinition.caseRecord.WorkPhone__c;

		clickToDialStepDefinition.thenPhoneDisplayLinksAreFormated(bddWrapper1);
		clickToDialStepDefinition.thenPhoneDisplayLinksAreFormated(bddWrapper2);
		clickToDialStepDefinition.thenPhoneDisplayLinksAreFormated(bddWrapper3);
		
	}
	
	/********************************************
	* Scenerio: Case Phone number fields are link
	* with Click to Dial Preference as 10
	*
	* @description Given the Agent with Click to Dial Preference as 10
	* When Agent views the account
	* then Phone display links are formated according to the User preference
	*
	* Related Stories:
	* S-199189
	**********************************************/
   @isTest
	public static void caseAgentWithClickToDialEnabledPreferenceAs10() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
		BDD_Account_StepDefinitions accountStepDefinitions = new BDD_Account_StepDefinitions();
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAnUserSalesHierarchy();
		userStepDefinitions.givenAgentWithClickToDialPreferenceAs(userStepDefinitions.SalesUserHierarchy.Agent, '10', true); /***(User, ClicktoDialPreference__c, ClickToDialEnabled__c)***/
		/*****************(AccountType, Account.PersonMobilePhone, Account.PersonHomePhone, Account.Phone, isDoNotCallEnabled)****************/
		BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper wrapper = new BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper();
        wrapper.recordType = 'Individual';
        wrapper.personMobilePhone = '1234567123';
        wrapper.personHomePhone = '1234567123';
        wrapper.phone = '1234567123';
        wrapper.isDoNotCallEnabled = false;
		accountStepDefinitions.givenAccountWithPhoneNumbers (wrapper);
		caseStepDefinitions.givenANewCaseOnExistingAccount (accountStepDefinitions.account,userStepDefinitions.SalesUserHierarchy.AgentOffice);
    	
		System.runAs(userStepDefinitions.SalesUserHierarchy.Agent){
    		clickToDialStepDefinition.whenUserViewTheCase(userStepDefinitions.SalesUserHierarchy.Agent, caseStepDefinitions.cases);
		}
				
		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper1 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    	bddWrapper1.user = userStepDefinitions.SalesUserHierarchy.Agent;
	  	bddWrapper1.display = '1234567123';
	  	bddWrapper1.hyperLink =  '1234567123';
	  	bddWrapper1.longDistanceNumber = '11234567123';
	  	bddWrapper1.phoneFieldToAssert =  clickToDialStepDefinition.caseRecord.MobilePhone__c;

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper2 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    	bddWrapper2.user = userStepDefinitions.SalesUserHierarchy.Agent;
	  	bddWrapper2.display = '1234567123';
	  	bddWrapper2.hyperLink =  '1234567123';
	  	bddWrapper2.longDistanceNumber = '11234567123';
	  	bddWrapper2.phoneFieldToAssert =  clickToDialStepDefinition.caseRecord.HomePhone__c;

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper3 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    	bddWrapper3.user = userStepDefinitions.SalesUserHierarchy.Agent;
	  	bddWrapper3.display = '1234567123';
	  	bddWrapper3.hyperLink =  '1234567123';
	  	bddWrapper3.longDistanceNumber = '11234567123';
	  	bddWrapper3.phoneFieldToAssert =  clickToDialStepDefinition.caseRecord.WorkPhone__c;

		clickToDialStepDefinition.thenPhoneDisplayLinksAreFormated(bddWrapper1);
		clickToDialStepDefinition.thenPhoneDisplayLinksAreFormated(bddWrapper2);
		clickToDialStepDefinition.thenPhoneDisplayLinksAreFormated(bddWrapper3);
	}
	
	/********************************************
	* Scenerio: Account Phone number fields are link
	* with Click to Dial Preference as 11
	*
	* @description Given the Agent with Click to Dial Preference as 11
	* When Agent views the account
	* then Phone display links are formated according to the User preference
	*
	* Related Stories:
	* S-199189
	**********************************************/
   @isTest
	public static void caseAgentWithClickToDialEnabledPreferenceAs11() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
		BDD_Account_StepDefinitions accountStepDefinitions = new BDD_Account_StepDefinitions();
		BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
		
		userStepDefinitions.givenAnUserSalesHierarchy();
		userStepDefinitions.givenAgentWithClickToDialPreferenceAs(userStepDefinitions.SalesUserHierarchy.Agent, '11', true); /***(User, ClicktoDialPreference__c, ClickToDialEnabled__c)***/
		/*****************(AccountType, Account.PersonMobilePhone, Account.PersonHomePhone, Account.Phone, isDoNotCallEnabled)****************/
		BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper wrapper = new BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper();
        wrapper.recordType = 'Individual';
        wrapper.personMobilePhone = '1234567123';
        wrapper.personHomePhone = '1234567123';
        wrapper.phone = '1234567123';
        wrapper.isDoNotCallEnabled = false;
		accountStepDefinitions.givenAccountWithPhoneNumbers (wrapper);
		caseStepDefinitions.givenANewCaseOnExistingAccount (accountStepDefinitions.account,userStepDefinitions.SalesUserHierarchy.AgentOffice);
    	
		System.runAs(userStepDefinitions.SalesUserHierarchy.Agent){
    		clickToDialStepDefinition.whenUserViewTheCase(userStepDefinitions.SalesUserHierarchy.Agent, caseStepDefinitions.cases);
		}
				
		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper1 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    	bddWrapper1.user = userStepDefinitions.SalesUserHierarchy.Agent;
		bddWrapper1.display = '1234567123';
		bddWrapper1.hyperLink =  '11234567123';
		bddWrapper1.phoneFieldToAssert = clickToDialStepDefinition.caseRecord.MobilePhone__c;

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper2 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
		bddWrapper2.user = userStepDefinitions.SalesUserHierarchy.Agent;
		bddWrapper2.display = '1234567123';
		bddWrapper2.hyperLink =  '11234567123';
		bddWrapper2.phoneFieldToAssert = clickToDialStepDefinition.caseRecord.HomePhone__c;

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper3 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
		bddWrapper3.user = userStepDefinitions.SalesUserHierarchy.Agent;
		bddWrapper3.display = '1234567123';
		bddWrapper3.hyperLink =  '11234567123';
		bddWrapper3.phoneFieldToAssert = clickToDialStepDefinition.caseRecord.WorkPhone__c;

		clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper1);
		clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper2);
		clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper3);
		 
	}
	
  /******************************************************************
  * Scenerio: Case Phone number fields are referred from Person Account
  * Click to Dial Disabled for a Sales leader
  * 
  * @description Given the Sales leader with Click to Dial Disabled
  * When a Sales leader views the case
  * Then Phone display links are just text
  *
  * Related Stories:
  * S-199189
  *********************************************************************/
   @isTest
  	public static void caseSalesleaderWithClickToDialDisabled() {
    	BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
    	BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
    	BDD_Account_StepDefinitions accountStepDefinitions = new BDD_Account_StepDefinitions();
    	BDD_Case_StepDefinition caseStepDefinitions = new BDD_Case_StepDefinition();
    
   	 	userStepDefinitions.givenAnUserSalesHierarchy(); 
		userStepDefinitions.givenAgentWithClickToDialPreferenceAs(userStepDefinitions.SalesUserHierarchy.SalesLeader, '', false); /***(User, ClicktoDialPreference__c, ClickToDialEnabled__c)***/
    	/*****************(AccountType, Account.PersonMobilePhone, Account.PersonHomePhone, Account.Phone, isDoNotCallEnabled)****************/
		BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper wrapper = new BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper();
        wrapper.recordType = 'Individual';
        wrapper.personMobilePhone = '1234567123';
        wrapper.personHomePhone = '1234567123';
        wrapper.phone = '1234567123';
        wrapper.isDoNotCallEnabled = false;
    	accountStepDefinitions.givenAccountWithPhoneNumbers (wrapper);
    	caseStepDefinitions.givenANewCaseOnExistingAccount (accountStepDefinitions.account,userStepDefinitions.SalesUserHierarchy.AgentOffice);
    	
		System.runAs(userStepDefinitions.SalesUserHierarchy.SalesLeader){
    		clickToDialStepDefinition.whenUserViewTheCase(userStepDefinitions.SalesUserHierarchy.SalesLeader, caseStepDefinitions.cases);
		}
    
    	clickToDialStepDefinition.thenPhoneIsJustText('1234567123', clickToDialStepDefinition.caseRecord.MobilePhone__c);
    	clickToDialStepDefinition.thenPhoneIsJustText('1234567123', clickToDialStepDefinition.caseRecord.HomePhone__c);
    	clickToDialStepDefinition.thenPhoneIsJustText('1234567123', clickToDialStepDefinition.caseRecord.WorkPhone__c);
  	}
}