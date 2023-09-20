@isTest(seeAllData=false)
private class BDD_Story_ClickToDial {
  /**
	* Scenerio: Account Phone number fields are Text
	*
	* Given the User with Click to Dial Disabled
	* When User view the account
	* Then Phone display links are just text
	*
	* Related Stories:
	* S-210138
	* @description Account With Click To Dial Disabled
	*/
   @isTest
  	public static void accountWithClickToDialDisabled() {
    	BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
    	BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
    	BDD_Account_StepDefinitions accountStepDefinitions = new BDD_Account_StepDefinitions();
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
		userStepDefinitions.whenPermissionSetIsAssigned('CustomerView_Support_ModifyAll');
		userStepDefinitions.whenPermissionSetIsAssigned('ClickToDial_ModifyAll');
		userStepDefinitions.givenUserWithClickToDialPreferenceAs(userStepDefinitions.user, '', false);
		BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper wrapper = new BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper();
        wrapper.recordType = 'Individual';
        wrapper.personMobilePhone = '1234567123';
        wrapper.personHomePhone = '1234567123';
        wrapper.phone = '1234567123';
        wrapper.isDoNotCallEnabled = false;
    	accountStepDefinitions.givenAccountWithPhoneNumbers (wrapper);
		System.runAs(userStepDefinitions.user){
    		clickToDialStepDefinition.whenUserViewTheAccount(userStepDefinitions.user, accountStepDefinitions.account);
		}
    	clickToDialStepDefinition.thenPhoneIsJustText('1234567123', clickToDialStepDefinition.account.MobilePhoneLink__c);
    	clickToDialStepDefinition.thenPhoneIsJustText('1234567123', clickToDialStepDefinition.account.HomePhoneLink__c);
    	clickToDialStepDefinition.thenPhoneIsJustText('1234567123', clickToDialStepDefinition.account.WorkPhoneLink__c);
  	}
  /**
	* Scenerio: Account Phone number fields are Blank
	*
	* Given the User with Click to Dial Enabled
	* When User view the account with no phone number
	* Then Phone display links empty
	*
	* Related Stories:
	* S-210138
	* @description Account With Click To Dial Enabled Phone Blank
	*/
   @isTest
  	public static void accountWithClickToDialEnabledPhoneBlank() {
    	BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
    	BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
    	BDD_Account_StepDefinitions accountStepDefinitions = new BDD_Account_StepDefinitions();
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
		userStepDefinitions.whenPermissionSetIsAssigned('CustomerView_Support_ModifyAll');
		userStepDefinitions.whenPermissionSetIsAssigned('ClickToDial_ModifyAll');
		userStepDefinitions.givenUserWithClickToDialPreferenceAs(userStepDefinitions.user, '11', true);
		BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper wrapper = new BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper();
        wrapper.recordType = 'Individual';
        wrapper.personMobilePhone = null;
        wrapper.personHomePhone = null;
        wrapper.phone = null;
        wrapper.isDoNotCallEnabled = false;
    	accountStepDefinitions.givenAccountWithPhoneNumbers (wrapper);

		System.runAs(userStepDefinitions.user){
    		clickToDialStepDefinition.whenUserViewTheAccount(userStepDefinitions.user, accountStepDefinitions.account);
		}
    	clickToDialStepDefinition.thenPhoneIsBlank(clickToDialStepDefinition.account.MobilePhoneLink__c);
    	clickToDialStepDefinition.thenPhoneIsBlank(clickToDialStepDefinition.account.HomePhoneLink__c);
    	clickToDialStepDefinition.thenPhoneIsBlank(clickToDialStepDefinition.account.WorkPhoneLink__c);
  	}
  /**
	* Scenerio: Account Phone number fields are link
	*
	* Given the User with Click to Dial Preference as NONE
	* When User view the account
	* Then Phone display links are formated according to the User preference
	*
	* Related Stories:
	* S-210138
	* @description Account With Click To Dial Enabled Preference As Null
	*/
   @isTest
	public static void accountWithClickToDialEnabledPreferenceAsNull() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
		BDD_Account_StepDefinitions accountStepDefinitions = new BDD_Account_StepDefinitions();
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
		userStepDefinitions.whenPermissionSetIsAssigned('CustomerView_Support_ModifyAll');
		userStepDefinitions.whenPermissionSetIsAssigned('ClickToDial_ModifyAll');
		userStepDefinitions.givenUserWithClickToDialPreferenceAs(userStepDefinitions.user, '', true);
		BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper wrapper = new BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper();
        wrapper.recordType = 'Individual';
        wrapper.personMobilePhone = '1234567123';
        wrapper.personHomePhone = '1234567123';
        wrapper.phone = '1234567123';
        wrapper.isDoNotCallEnabled = false;
		accountStepDefinitions.givenAccountWithPhoneNumbers (wrapper);

		System.runAs(userStepDefinitions.user){
			clickToDialStepDefinition.whenUserViewTheAccount(userStepDefinitions.user, accountStepDefinitions.account);
		}

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper1 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    	bddWrapper1.user = userStepDefinitions.user;
		bddWrapper1.display = '1234567123';
		bddWrapper1.hyperLink =  '11234567123';
		bddWrapper1.phoneFieldToAssert = clickToDialStepDefinition.account.MobilePhoneLink__c;

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper2 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
		bddWrapper2.user = userStepDefinitions.user;
		bddWrapper2.display = '1234567123';
		bddWrapper2.hyperLink =  '11234567123';
		bddWrapper2.phoneFieldToAssert = clickToDialStepDefinition.account.HomePhoneLink__c;

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper3 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
		bddWrapper3.user = userStepDefinitions.user;
		bddWrapper3.display = '1234567123';
		bddWrapper3.hyperLink =  '11234567123';
		bddWrapper3.phoneFieldToAssert = clickToDialStepDefinition.account.WorkPhoneLink__c;

		clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper1);
		clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper2);
		clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper3);
	}
  /**
	* Scenerio: Account Phone number fields are link
	*
	* Given the User with Click to Dial Preference as 10
	* When User view the account
	* then Phone display links are formated according to the User preference
	*
	* Related Stories:
	* S-210138
	* @description Account With Click To Dial Enabled Preference As 10
	*/
   @isTest
	public static void accountWithClickToDialEnabledPreferenceAs10() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
		BDD_Account_StepDefinitions accountStepDefinitions = new BDD_Account_StepDefinitions();
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
		userStepDefinitions.whenPermissionSetIsAssigned('CustomerView_Support_ModifyAll');
		userStepDefinitions.whenPermissionSetIsAssigned('ClickToDial_ModifyAll');
		userStepDefinitions.givenUserWithClickToDialPreferenceAs(userStepDefinitions.user, '10', true);
		BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper wrapper = new BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper();
        wrapper.recordType = 'Individual';
        wrapper.personMobilePhone = '1234567123';
        wrapper.personHomePhone = '1234567123';
        wrapper.phone = '1234567123';
        wrapper.isDoNotCallEnabled = false;
		accountStepDefinitions.givenAccountWithPhoneNumbers (wrapper);

		System.runAs(userStepDefinitions.user){
			clickToDialStepDefinition.whenUserViewTheAccount(userStepDefinitions.user, accountStepDefinitions.account);
		}

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper1 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    	bddWrapper1.user = userStepDefinitions.user;
	  	bddWrapper1.display = '1234567123';
	  	bddWrapper1.hyperLink =  '1234567123';
	  	bddWrapper1.longDistanceNumber = '11234567123';
	  	bddWrapper1.phoneFieldToAssert =  clickToDialStepDefinition.account.MobilePhoneLink__c;

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper2 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    	bddWrapper2.user = userStepDefinitions.user;
	  	bddWrapper2.display = '1234567123';
	  	bddWrapper2.hyperLink =  '1234567123';
	  	bddWrapper2.longDistanceNumber = '11234567123';
	  	bddWrapper2.phoneFieldToAssert =  clickToDialStepDefinition.account.HomePhoneLink__c;

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper3 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    	bddWrapper3.user = userStepDefinitions.user;
	  	bddWrapper3.display = '1234567123';
	  	bddWrapper3.hyperLink =  '1234567123';
	  	bddWrapper3.longDistanceNumber = '11234567123';
	  	bddWrapper3.phoneFieldToAssert =  clickToDialStepDefinition.account.WorkPhoneLink__c;

		clickToDialStepDefinition.thenPhoneDisplayLinksAreFormated(bddWrapper1);
		clickToDialStepDefinition.thenPhoneDisplayLinksAreFormated(bddWrapper2);
		clickToDialStepDefinition.thenPhoneDisplayLinksAreFormated(bddWrapper3);
	}
  /**
	* Scenerio: Account Phone number fields are link
	*
	* Given the User with Click to Dial Preference as 11
	* When User view the account
	* then Phone display links are formated according to the User preference
	*
	* Related Stories:
	* S-210138
	* @description Account With Click To Dial Enabled Preference As 11
	*/
   @isTest
	public static void accountWithClickToDialEnabledPreferenceAs11() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
		BDD_Account_StepDefinitions accountStepDefinitions = new BDD_Account_StepDefinitions();
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
		userStepDefinitions.whenPermissionSetIsAssigned('CustomerView_Support_ModifyAll');
		userStepDefinitions.whenPermissionSetIsAssigned('ClickToDial_ModifyAll');
		userStepDefinitions.givenUserWithClickToDialPreferenceAs(userStepDefinitions.user, '11', true);
		BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper wrapper = new BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper();
        wrapper.recordType = 'Individual';
        wrapper.personMobilePhone = '1234567123';
        wrapper.personHomePhone = '1234567123';
        wrapper.phone = '1234567123';
        wrapper.isDoNotCallEnabled = false;
		accountStepDefinitions.givenAccountWithPhoneNumbers (wrapper);

		System.runAs(userStepDefinitions.user){
			clickToDialStepDefinition.whenUserViewTheAccount(userStepDefinitions.user, accountStepDefinitions.account);
		}

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper1 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    	bddWrapper1.user = userStepDefinitions.user;
		bddWrapper1.display = '1234567123';
		bddWrapper1.hyperLink =  '11234567123';
		bddWrapper1.phoneFieldToAssert = clickToDialStepDefinition.account.MobilePhoneLink__c;

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper2 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
		bddWrapper2.user = userStepDefinitions.user;
		bddWrapper2.display = '1234567123';
		bddWrapper2.hyperLink =  '11234567123';
		bddWrapper2.phoneFieldToAssert = clickToDialStepDefinition.account.HomePhoneLink__c;

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper3 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
		bddWrapper3.user = userStepDefinitions.user;
		bddWrapper3.display = '1234567123';
		bddWrapper3.hyperLink =  '11234567123';
		bddWrapper3.phoneFieldToAssert = clickToDialStepDefinition.account.WorkPhoneLink__c;

		clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper1);
		clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper2);
		clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper3);
	}
  /**
	* Scenerio: Account Phone number fields are link
	*
	* Given the User with Click to Dial Preference as 11
	* When User view the account with do not call true
	* then Phone display links are formated with do not call
	*
	* Related Stories:
	* S-210138
	* @description Account With Do Not Call True Preference As 11
	*/
   @isTest
	public static void accountWithDoNotCallTruePreferenceAs11() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
		BDD_Account_StepDefinitions accountStepDefinitions = new BDD_Account_StepDefinitions();
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
		userStepDefinitions.whenPermissionSetIsAssigned('CustomerView_Support_ModifyAll');
		userStepDefinitions.whenPermissionSetIsAssigned('ClickToDial_ModifyAll');
		userStepDefinitions.givenUserWithClickToDialPreferenceAs(userStepDefinitions.user, '11', true);
		BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper wrapper = new BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper();
        wrapper.recordType = 'Individual';
        wrapper.personMobilePhone = '1234567123';
        wrapper.personHomePhone = '1234567123';
        wrapper.phone = '1234567123';
        wrapper.isDoNotCallEnabled = true;
		accountStepDefinitions.givenAccountWithPhoneNumbers (wrapper);

		System.runAs(userStepDefinitions.user){
			clickToDialStepDefinition.whenUserViewTheAccount(userStepDefinitions.user, accountStepDefinitions.account);
		}

		BDD_ClickToDial_StepDefinition.PolyBDDClickToDialStepDefinitionWrapper bddWrapper1 = new BDD_ClickToDial_StepDefinition.PolyBDDClickToDialStepDefinitionWrapper();
    	bddWrapper1.user = userStepDefinitions.user;
	  	bddWrapper1.display = '1234567123';
	  	bddWrapper1.hyperLink =  '11234567123';
	  	bddWrapper1.phoneFieldToAssert =  clickToDialStepDefinition.account.MobilePhoneLink__c;

		BDD_ClickToDial_StepDefinition.PolyBDDClickToDialStepDefinitionWrapper bddWrapper2 = new BDD_ClickToDial_StepDefinition.PolyBDDClickToDialStepDefinitionWrapper();
		bddWrapper2.user = userStepDefinitions.user;
		bddWrapper2.display = '1234567123';
		bddWrapper2.hyperLink =  '11234567123';
		bddWrapper2.phoneFieldToAssert =  clickToDialStepDefinition.account.HomePhoneLink__c;

		BDD_ClickToDial_StepDefinition.PolyBDDClickToDialStepDefinitionWrapper bddWrapper3 = new BDD_ClickToDial_StepDefinition.PolyBDDClickToDialStepDefinitionWrapper();
		bddWrapper3.user = userStepDefinitions.user;
		bddWrapper3.display = '1234567123';
		bddWrapper3.hyperLink =  '11234567123';
		bddWrapper3.phoneFieldToAssert =  clickToDialStepDefinition.account.WorkPhoneLink__c;

		clickToDialStepDefinition.thenPhoneLinksAreFormatedDoNotMarket(bddWrapper1);
		clickToDialStepDefinition.thenPhoneLinksAreFormatedDoNotMarket(bddWrapper2);
		clickToDialStepDefinition.thenPhoneLinksAreFormatedDoNotMarket(bddWrapper3);
	}
  /**
	* Scenerio: Account Phone number fields are link
	*
	* Given the User with Click to Dial Preference as 10
	* When User view the account with do not call true
	* then Phone display links are formated according to the User preference
	*
	* Related Stories:
	* S-210138
	* @description Account With Do Not Call True Preference As 10
	*/
   @isTest
	public static void accountWithDoNotCallTruePreferenceAs10() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
		BDD_Account_StepDefinitions accountStepDefinitions = new BDD_Account_StepDefinitions();
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
		userStepDefinitions.whenPermissionSetIsAssigned('CustomerView_Support_ModifyAll');
		userStepDefinitions.whenPermissionSetIsAssigned('ClickToDial_ModifyAll');
		userStepDefinitions.givenUserWithClickToDialPreferenceAs(userStepDefinitions.user, '10', true);
		BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper wrapper = new BDD_Account_StepDefinitions.BDD_Account_StepDefinitionsWrapper();
        wrapper.recordType = 'Individual';
        wrapper.personMobilePhone = '1234567123';
        wrapper.personHomePhone = '1234567123';
        wrapper.phone = '1234567123';
        wrapper.isDoNotCallEnabled = true;
		accountStepDefinitions.givenAccountWithPhoneNumbers (wrapper);

		System.runAs(userStepDefinitions.user){
			clickToDialStepDefinition.whenUserViewTheAccount(userStepDefinitions.user, accountStepDefinitions.account);
		}
		
		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper1 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    	bddWrapper1.user = userStepDefinitions.user;
	  	bddWrapper1.display = '1234567123';
	  	bddWrapper1.hyperLink =  '1234567123';
	  	bddWrapper1.longDistanceNumber = '11234567123';
	  	bddWrapper1.phoneFieldToAssert =  clickToDialStepDefinition.account.MobilePhoneLink__c;

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper2 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
		bddWrapper2.user = userStepDefinitions.user;
		bddWrapper2.display = '1234567123';
		bddWrapper2.hyperLink =  '1234567123';
		bddWrapper2.longDistanceNumber = '11234567123';
		bddWrapper2.phoneFieldToAssert =  clickToDialStepDefinition.account.HomePhoneLink__c;

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper3 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
		bddWrapper3.user = userStepDefinitions.user;
		bddWrapper3.display = '1234567123';
		bddWrapper3.hyperLink =  '1234567123';
		bddWrapper3.longDistanceNumber = '11234567123';
		bddWrapper3.phoneFieldToAssert =  clickToDialStepDefinition.account.WorkPhoneLink__c;

		clickToDialStepDefinition.thenPhoneLinksAreFormatedDoNotMarket(bddWrapper1);
		clickToDialStepDefinition.thenPhoneLinksAreFormatedDoNotMarket(bddWrapper2);
		clickToDialStepDefinition.thenPhoneLinksAreFormatedDoNotMarket(bddWrapper3);
	}
  /**
  	* Scenerio: Opportunity Phone number fields are text
  	*
  	* Given the User with Click to Dial Disabled
  	* When User view the Opportunity
  	* Then Phone display links are formated
  	*
  	* Related Stories:
  	* S-210148 
	  * @description Opportunity With Click To Dial Disabled
  	*/
   @isTest
 	public static void opportunityWithClickToDialDisabled() {
    	BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
    	BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
    	BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
		userStepDefinitions.whenPermissionSetIsAssigned('CustomerView_Support_ModifyAll');
		userStepDefinitions.whenPermissionSetIsAssigned('Opportunity_FullAccess_W');
		userStepDefinitions.whenPermissionSetIsAssigned('ClickToDial_ModifyAll');
		userStepDefinitions.givenUserWithClickToDialPreferenceAs(userStepDefinitions.user, '', false);
    	opportunityStepDefinitions.givenAnOpportunityWithPhoneNumbers (userStepDefinitions.user, '1111111111','2222222222', '3333333333', '4444444444', false);
		System.runAs(userStepDefinitions.user){
    		clickToDialStepDefinition.whenUserViewTheOpportunity(userStepDefinitions.user, opportunityStepDefinitions.bddOpportunity);
		}
    	clickToDialStepDefinition.thenPhoneIsJustText('1111111111', clickToDialStepDefinition.opportunity.MobilePhone__c);
    	clickToDialStepDefinition.thenPhoneIsJustText('2222222222', clickToDialStepDefinition.opportunity.HomePhone__c);
    	clickToDialStepDefinition.thenPhoneIsJustText('3333333333', clickToDialStepDefinition.opportunity.WorkPhone__c);
    	clickToDialStepDefinition.thenPhoneIsJustText('4444444444', clickToDialStepDefinition.opportunity.Submitted_Phone_Link__c);
  	}
  /**
  	* Scenerio: Opportunity Phone number fields are blank
  	*
  	* Given the User with Click to Dial Enabled
  	* When User view the Opportunity with no phone numbers
  	* Then Phone display is blank
  	*
  	* Related Stories:
  	* S-210148 
	* @description Opportunity With Click To Dial Enabled Phone Blank
  	*/
   @isTest
  	public static void opportunityWithClickToDialEnabledPhoneBlank() {
    	BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
    	BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
    	BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
		userStepDefinitions.whenPermissionSetIsAssigned('CustomerView_Support_ModifyAll');
		userStepDefinitions.whenPermissionSetIsAssigned('Opportunity_FullAccess_W');
		userStepDefinitions.whenPermissionSetIsAssigned('ClickToDial_ModifyAll');
		userStepDefinitions.givenUserWithClickToDialPreferenceAs(userStepDefinitions.user, '', true);
    	opportunityStepDefinitions.givenAnOpportunityWithPhoneNumbers (userStepDefinitions.user, null, null, null, null, false);

		System.runAs(userStepDefinitions.user){
    		clickToDialStepDefinition.whenUserViewTheOpportunity(userStepDefinitions.user, opportunityStepDefinitions.bddOpportunity);
		}

    	clickToDialStepDefinition.thenPhoneIsBlank(clickToDialStepDefinition.opportunity.MobilePhone__c);
    	clickToDialStepDefinition.thenPhoneIsBlank(clickToDialStepDefinition.opportunity.HomePhone__c);
    	clickToDialStepDefinition.thenPhoneIsBlank(clickToDialStepDefinition.opportunity.WorkPhone__c);
    	clickToDialStepDefinition.thenPhoneIsBlank(clickToDialStepDefinition.opportunity.Submitted_Phone_Link__c);
  	}
  /**
	* Scenerio: Opportunity Phone number fields are link
	*
	* Given the User with Click to Dial Preference as 10
	* When User view the Opportunity
	* Then Phone display links are formated according to the User preference
	*
	* Related Stories:
	* S-210148
	* @description Opportunity With Click To Dial Enabled Preference As 10
	*/
   @isTest
	public static void opportunityWithClickToDialEnabledPreferenceAs10() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
		userStepDefinitions.whenPermissionSetIsAssigned('CustomerView_Support_ModifyAll');
		userStepDefinitions.whenPermissionSetIsAssigned('Opportunity_FullAccess_W');
		userStepDefinitions.whenPermissionSetIsAssigned('ClickToDial_ModifyAll');
		userStepDefinitions.givenUserWithClickToDialPreferenceAs(userStepDefinitions.user, '10', true); 
		opportunityStepDefinitions.givenAnOpportunityWithPhoneNumbers (userStepDefinitions.user, '1111111111','2222222222', '3333333333','4444444444', false);

		System.runAs(userStepDefinitions.user){
			clickToDialStepDefinition.whenUserViewTheOpportunity(userStepDefinitions.user, opportunityStepDefinitions.bddOpportunity);
		}

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper1 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    	bddWrapper1.user = userStepDefinitions.user;
	  	bddWrapper1.display = '1111111111';
	  	bddWrapper1.hyperLink =  '1111111111';
	  	bddWrapper1.longDistanceNumber = '11111111111';
	  	bddWrapper1.phoneFieldToAssert =  clickToDialStepDefinition.opportunity.MobilePhone__c;

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper2 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    	bddWrapper2.user = userStepDefinitions.user;
	  	bddWrapper2.display = '2222222222';
	  	bddWrapper2.hyperLink =  '2222222222';
	  	bddWrapper2.longDistanceNumber = '12222222222';
	  	bddWrapper2.phoneFieldToAssert =  clickToDialStepDefinition.opportunity.HomePhone__c;

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper3 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    	bddWrapper3.user = userStepDefinitions.user;
	  	bddWrapper3.display = '3333333333';
	  	bddWrapper3.hyperLink =  '3333333333';
	  	bddWrapper3.longDistanceNumber = '13333333333';
	  	bddWrapper3.phoneFieldToAssert =  clickToDialStepDefinition.opportunity.WorkPhone__c;

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper4 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    	bddWrapper4.user = userStepDefinitions.user;
	  	bddWrapper4.display = '4444444444';
	  	bddWrapper4.hyperLink =  '4444444444';
	  	bddWrapper4.longDistanceNumber = '14444444444';
	  	bddWrapper4.phoneFieldToAssert =  clickToDialStepDefinition.opportunity.Submitted_Phone_Link__c;

		clickToDialStepDefinition.thenPhoneDisplayLinksAreFormated(bddWrapper1);
		clickToDialStepDefinition.thenPhoneDisplayLinksAreFormated(bddWrapper2);
		clickToDialStepDefinition.thenPhoneDisplayLinksAreFormated(bddWrapper3);
		clickToDialStepDefinition.thenPhoneDisplayLinksAreFormated(bddWrapper4);
	}
  /**
	* Scenerio: Opportunity Phone number fields are link
	*
	* Given the User with Click to Dial Preference as 11
	* When User view the Opportunity
	* Then Phone display links are formated according to the User preference
	*
	* Related Stories:
	* S-210148
	* @description Opportunity With Click To Dial Enabled Preference As 11
	*/
   @isTest
	public static void opportunityWithClickToDialEnabledPreferenceAs11() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
		BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
		userStepDefinitions.whenPermissionSetIsAssigned('CustomerView_Support_ModifyAll');
		userStepDefinitions.whenPermissionSetIsAssigned('Opportunity_FullAccess_W');
		userStepDefinitions.whenPermissionSetIsAssigned('ClickToDial_ModifyAll');
		userStepDefinitions.givenUserWithClickToDialPreferenceAs(userStepDefinitions.user, '11', true); 
		opportunityStepDefinitions.givenAnOpportunityWithPhoneNumbers (userStepDefinitions.user, '1111111111','2222222222', '3333333333', '4444444444', false);

		System.runAs(userStepDefinitions.user){
			clickToDialStepDefinition.whenUserViewTheOpportunity(userStepDefinitions.user, opportunityStepDefinitions.bddOpportunity);
		}

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper1 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    	bddWrapper1.user = userStepDefinitions.user;
		bddWrapper1.display = '1111111111';
		bddWrapper1.hyperLink =  '11111111111';
		bddWrapper1.phoneFieldToAssert = clickToDialStepDefinition.opportunity.MobilePhone__c;

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper2 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
		bddWrapper2.user = userStepDefinitions.user;
		bddWrapper2.display = '2222222222';
		bddWrapper2.hyperLink =  '12222222222';
		bddWrapper2.phoneFieldToAssert = clickToDialStepDefinition.opportunity.HomePhone__c;

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper3 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
		bddWrapper3.user = userStepDefinitions.user;
		bddWrapper3.display = '3333333333';
		bddWrapper3.hyperLink =  '13333333333';
		bddWrapper3.phoneFieldToAssert = clickToDialStepDefinition.opportunity.WorkPhone__c;

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper4 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
		bddWrapper4.user = userStepDefinitions.user;
		bddWrapper4.display = '4444444444';
		bddWrapper4.hyperLink =  '14444444444';
		bddWrapper4.phoneFieldToAssert = clickToDialStepDefinition.opportunity.Submitted_Phone_Link__c;

		clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper1);
		clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper2);
		clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper3);
		clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper4);
	}
  /**
  	* Scenerio: Opportunity Phone number fields are link with Do Not Market
  	*
  	* Given the User with Click to Dial Enabled
  	* When User view the Opportunity with DoNotCall, created more than 30 days ago
  	* Then Phone display links are formated with a prefix Do Not Market
  	*
  	* Related Stories:
  	* S-210148 
	* @description Opportunity With Do Not Call True Preference 11 After 30 days
  	*/
   @isTest
  	public static void opportunityWithDoNotCallTruePreference11After30days() {
    	BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
    	BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
    	BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
		userStepDefinitions.whenPermissionSetIsAssigned('CustomerView_Support_ModifyAll');
		userStepDefinitions.whenPermissionSetIsAssigned('Opportunity_FullAccess_W');
		userStepDefinitions.whenPermissionSetIsAssigned('ClickToDial_ModifyAll');
		userStepDefinitions.givenUserWithClickToDialPreferenceAs(userStepDefinitions.user, '11', true);     
        opportunityStepDefinitions.givenAnOpportunityWithPhoneNumberAndDate (userStepDefinitions.user, '1111111111','2222222222', '3333333333', '4444444444', true, 91);
		opportunityStepDefinitions.bddOpportunity.DateCaptured__c = null;
        update opportunityStepDefinitions.bddOpportunity;
		System.runAs(userStepDefinitions.user){
    		clickToDialStepDefinition.whenUserViewTheOpportunity(userStepDefinitions.user, opportunityStepDefinitions.bddOpportunity);
		}

        clickToDialStepDefinition.thenPhoneIsJustText('Do Not Market: 1111111111', clickToDialStepDefinition.opportunity.MobilePhone__c);
        clickToDialStepDefinition.thenPhoneIsJustText('Do Not Market: 2222222222', clickToDialStepDefinition.opportunity.HomePhone__c);
        clickToDialStepDefinition.thenPhoneIsJustText('Do Not Market: 3333333333', clickToDialStepDefinition.opportunity.WorkPhone__c);
        clickToDialStepDefinition.thenPhoneIsJustText('Do Not Market: 4444444444', clickToDialStepDefinition.opportunity.Submitted_Phone_Link__c);
  	}
  /**
	* Scenerio: lead Phone number fields are text 
	*
	* Given the User with Click to Dial Preference as 11
	* When User view the Lead
	* Then Phone display links are formated according to the User preference
	*
	* Related Stories:
	* S-210150
	* @description Lead With Click To Dial Disabled
	*/
   @isTest
	public static void leadWithClickToDialDisabled() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
		BDD_Lead_StepDefinition leadStepDefinitions = new BDD_Lead_StepDefinition();
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
		userStepDefinitions.whenPermissionSetIsAssigned('CustomerView_Support_ModifyAll');
		userStepDefinitions.whenPermissionSetIsAssigned('Lead_Management_Tech_Support_Users');
		userStepDefinitions.whenPermissionSetIsAssigned('ClickToDial_ModifyAll');

		userStepDefinitions.givenUserWithClickToDialPreferenceAs(userStepDefinitions.user, '', false); 
		leadStepDefinitions.givenALeadCreatedWithPhoneNumber (userStepDefinitions.user, '1234567123','1234567123');

		System.runAs(userStepDefinitions.user){
			clickToDialStepDefinition.whenUserViewTheLead(userStepDefinitions.user, leadStepDefinitions.lead);
		}

		clickToDialStepDefinition.thenPhoneIsJustText('1234567123', clickToDialStepDefinition.lead.Phone__c);
		clickToDialStepDefinition.thenPhoneIsJustText('1234567123', clickToDialStepDefinition.lead.Submitt_Phone_Number__c);
	}
  /**
	* Scenerio: lead Phone number fields are blank
	*
	* Given the User with Click to Dial Preference as 11
	* When User view the Lead
	* Then Phone display links are formated according to the User preference
	*
	* Related Stories:
	* S-210150
	* @description Lead With Click To Dial Enabled Phone Blank
	*/
   @isTest
	public static void leadWithClickToDialEnabledPhoneBlank() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
		BDD_Lead_StepDefinition leadStepDefinitions = new BDD_Lead_StepDefinition();
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
		userStepDefinitions.whenPermissionSetIsAssigned('CustomerView_Support_ModifyAll');
		userStepDefinitions.whenPermissionSetIsAssigned('Lead_Management_Tech_Support_Users');
		userStepDefinitions.whenPermissionSetIsAssigned('ClickToDial_ModifyAll');
		userStepDefinitions.givenUserWithClickToDialPreferenceAs(userStepDefinitions.user, '11', true); 
		leadStepDefinitions.givenALeadCreatedWithPhoneNumber (userStepDefinitions.user, null, null);

		System.runAs(userStepDefinitions.user){
			clickToDialStepDefinition.whenUserViewTheLead(userStepDefinitions.user, leadStepDefinitions.lead);
		}
		clickToDialStepDefinition.thenPhoneIsBlank(clickToDialStepDefinition.lead.Phone__c);
		clickToDialStepDefinition.thenPhoneIsBlank(clickToDialStepDefinition.lead.Submitt_Phone_Number__c);
	}
  /**
	* Scenerio: lead Phone number fields are links
	*
	* Given the User with Click to Dial Preference as 10
	* When User view the Lead
	* Then Phone display links are formated according to the User preference
	*
	* Related Stories:
	* S-210150
	* @description Lead With Click To Dial Enabled Preference As 10
	*/
   @isTest
	public static void leadWithClickToDialEnabledPreferenceAs10() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
		BDD_Lead_StepDefinition leadStepDefinitions = new BDD_Lead_StepDefinition();
		userStepDefinitions.givenAUserInSalesforceWithProfile('2.00 Agent');
		userStepDefinitions.whenPermissionSetIsAssigned('CustomerView_Support_ModifyAll');
		userStepDefinitions.whenPermissionSetIsAssigned('Lead_Management_Tech_Support_Users');
		//userStepDefinitions.whenPermissionSetIsAssigned('ClickToDial_ModifyAll');
		userStepDefinitions.givenUserWithClickToDialPreferenceAs(userStepDefinitions.user, '10', true); 
		leadStepDefinitions.givenALeadCreatedWithPhoneNumber (userStepDefinitions.user, '1234567123','1234567123');

		System.runAs(userStepDefinitions.user){
			clickToDialStepDefinition.whenUserViewTheLead(userStepDefinitions.user, leadStepDefinitions.lead);
		}

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper1 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    	bddWrapper1.user = userStepDefinitions.user;
	  	bddWrapper1.display = '1234567123';
	  	bddWrapper1.hyperLink =  '1234567123';
	  	bddWrapper1.longDistanceNumber = '11234567123';
	  	bddWrapper1.phoneFieldToAssert =  clickToDialStepDefinition.lead.Phone__c;

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper2 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    	bddWrapper2.user = userStepDefinitions.user;
	  	bddWrapper2.display = '1234567123';
	  	bddWrapper2.hyperLink =  '1234567123';
	  	bddWrapper2.longDistanceNumber = '11234567123';
	  	bddWrapper2.phoneFieldToAssert =  clickToDialStepDefinition.lead.Submitt_Phone_Number__c;

		clickToDialStepDefinition.thenPhoneDisplayLinksAreFormated(bddWrapper1);
		clickToDialStepDefinition.thenPhoneDisplayLinksAreFormated(bddWrapper2);
	}
  /**
	* Scenerio: lead Phone number fields are links
	*
	* Given the User with Click to Dial Preference as 11
	* When User view the Lead
	* Then Phone display links are formated according to the User preference
	*
	* Related Stories:
	* S-210150
	* @description Lead With Click To Dial Enabled Preference As 11
	*/
   @isTest
	public static void leadWithClickToDialEnabledPreferenceAs11() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
		BDD_Lead_StepDefinition leadStepDefinitions = new BDD_Lead_StepDefinition();
		userStepDefinitions.givenAUserInSalesforceWithProfile('2.00 Agent');
		userStepDefinitions.whenPermissionSetIsAssigned('CustomerView_Support_ModifyAll');
		userStepDefinitions.whenPermissionSetIsAssigned('Lead_Management_Tech_Support_Users');
		//userStepDefinitions.whenPermissionSetIsAssigned('ClickToDial_ModifyAll');
		userStepDefinitions.givenUserWithClickToDialPreferenceAs(userStepDefinitions.user, '11', true);
		leadStepDefinitions.givenALeadCreatedWithPhoneNumber (userStepDefinitions.user, '1234567123','1234567123');

		System.runAs(userStepDefinitions.user){
			clickToDialStepDefinition.whenUserViewTheLead(userStepDefinitions.user, leadStepDefinitions.lead);
		}

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper1 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
    	bddWrapper1.user = userStepDefinitions.user;
		bddWrapper1.display = '1234567123';
		bddWrapper1.hyperLink =  '11234567123';
		bddWrapper1.phoneFieldToAssert = clickToDialStepDefinition.lead.Phone__c;

		BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper bddWrapper2 = new BDD_ClickToDial_StepDefinition.BDDClickToDialStepDefinitionWrapper();
		bddWrapper2.user = userStepDefinitions.user;
		bddWrapper2.display = '1234567123';
		bddWrapper2.hyperLink =  '11234567123';
		bddWrapper2.phoneFieldToAssert = clickToDialStepDefinition.lead.Submitt_Phone_Number__c;

		clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper1);
		clickToDialStepDefinition.thenDefaultPhoneDisplayLinksAreFormated(bddWrapper2);
	}
  /**
	* Scenerio: Lead Phone number fields are Blank
	*
	* Given the User with Click to Dial Preference as 11
	* When User view the lead with Do Not Call checked
	* then Phone Numbers should be Blank
	*
	* Related Stories:
	* S-372654
	* @description Lead With Do Not Call True Preference As 10
	*/
   @isTest
	public static void leadWithDoNotCallTruePreferenceAs10() {
		BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
		BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
		BDD_Lead_StepDefinition leadStepDefinitions = new BDD_Lead_StepDefinition();
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
		userStepDefinitions.whenPermissionSetIsAssigned('CustomerView_Support_ModifyAll');
		userStepDefinitions.whenPermissionSetIsAssigned('Lead_Management_Tech_Support_Users');
		userStepDefinitions.whenPermissionSetIsAssigned('ClickToDial_ModifyAll');
		userStepDefinitions.givenUserWithClickToDialPreferenceAs(userStepDefinitions.user, '10', true); 
		leadStepDefinitions.givenALeadCreatedWithPhoneNumber (userStepDefinitions.user, '1234567123','1234567123');
		leadStepDefinitions.givenDoNotCall(true);
        leadStepDefinitions.givenSubmittedDoNotCall(true);

		System.runAs(userStepDefinitions.user){
			clickToDialStepDefinition.whenUserViewTheLead(userStepDefinitions.user, leadStepDefinitions.lead);
		}

		clickToDialStepDefinition.thenPhoneIsBlank(clickToDialStepDefinition.lead.Phone__c);
		clickToDialStepDefinition.thenPhoneIsBlank(clickToDialStepDefinition.lead.Submitt_Phone_Number__c);
	}
  /**
  	* Scenerio: Opportunity shows Do Not call preference image after 30 days
  	*
  	* Given the User with Click to Dial Enabled
  	* When User view the Opportunity with DoNotCall, created more than 30 days ago
  	* Then DoNotCallPreference Image Is Visible
  	*
  	* Related Stories:
  	* S-228938 
	* @description Opportunity With Do Not Call True After 30 Days
  	*/
   @isTest
  	public static void opportunityWithDoNotCallTrueAfter30Days() {
    	BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
    	BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
    	BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
		userStepDefinitions.whenPermissionSetIsAssigned('CustomerView_Support_ModifyAll');
		userStepDefinitions.whenPermissionSetIsAssigned('Opportunity_FullAccess_W');
		userStepDefinitions.whenPermissionSetIsAssigned('ClickToDial_ModifyAll');
		userStepDefinitions.givenUserWithClickToDialPreferenceAs(userStepDefinitions.user, '11', true); 
		opportunityStepDefinitions.givenAnOpportunityWithPhoneNumberAndDate (userStepDefinitions.user, '1111111111','2222222222', '3333333333', '4444444444', true, 91);
		opportunityStepDefinitions.bddOpportunity.DateCaptured__c = null;
        update opportunityStepDefinitions.bddOpportunity;
		System.runAs(userStepDefinitions.user){
    		clickToDialStepDefinition.whenUserViewTheOpportunity(userStepDefinitions.user, opportunityStepDefinitions.bddOpportunity);
		}
    	clickToDialStepDefinition.thenDoNotCallPreferenceImageIsVisible();
  	}
  /**
  	* Scenerio: Opportunity does not shows Do Not call preference image before 30 days
  	*
  	* Given the User with Click to Dial Enabled
  	* When User view the Opportunity with DoNotCall, created before 30 days
  	* Then DoNotCallPreference Image Is Not Visible
  	*
  	* Related Stories:
  	* S-228938 
	* @description Opportunity With Do Not Call True Before 30 Days
  	*/
   @isTest
  	public static void opportunityWithDoNotCallTrueBefore30Days() {
    	BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();
    	BDD_ClickToDial_StepDefinition clickToDialStepDefinition = new BDD_ClickToDial_StepDefinition();
    	BDD_Opportunity_StepDefinitions opportunityStepDefinitions = new BDD_Opportunity_StepDefinitions();
		userStepDefinitions.givenAUserInSalesforceWithProfile('1.07 Technical Support');
		userStepDefinitions.whenPermissionSetIsAssigned('CustomerView_Support_ModifyAll');
		userStepDefinitions.whenPermissionSetIsAssigned('Opportunity_FullAccess_W');
		userStepDefinitions.whenPermissionSetIsAssigned('ClickToDial_ModifyAll');
		userStepDefinitions.givenUserWithClickToDialPreferenceAs(userStepDefinitions.user, '11', true); 
		opportunityStepDefinitions.givenAnOpportunityWithPhoneNumberAndDate (userStepDefinitions.user, '1111111111','2222222222', '3333333333', '4444444444', true, 1);

		System.runAs(userStepDefinitions.user){
    		clickToDialStepDefinition.whenUserViewTheOpportunity(userStepDefinitions.user, opportunityStepDefinitions.bddOpportunity);
		}
		
    	clickToDialStepDefinition.thenDoNotCallPreferenceImageIsNotVisible();
  	}
}
