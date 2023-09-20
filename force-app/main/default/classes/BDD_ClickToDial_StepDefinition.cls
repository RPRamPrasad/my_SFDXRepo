@isTest
public class BDD_ClickToDial_StepDefinition {

	/**
	 * @description Account
	 * @return Account
	 */
	public Account account { get; private set; }

	/**
	 * @description Opportunity
	 * @return Opportunity
	 */
	public Opportunity opportunity { get; private set; }

	/**
	 * @description Lead
	 * @return Lead
	 */
	public Lead lead { get; private set; }

	/**
	 * @description Case Record
	 * @return Case
	 */
	public Case caseRecord { get; private set; }



	/******** Query Account Data for Phone Number in test Context *******/
	/**
	 * @description When User View The account
	 * @param user
	 * @param accountToView
	 */
	public void whenUserViewTheAccount(User user, Account accountToView) {
    	system.runAs(user) {
    		account = [SELECT id, PersonMobilePhone, PersonHomePhone, Phone, MobilePhoneLink__c, HomePhoneLink__c, WorkPhoneLink__c
    	 		   	   FROM Account
    	 		  	   WHERE id = :accountToView.Id];
    	}
    }



    /******** Query Opportunity Data for Phone Number in test Context *******/
	/**
	 * @description When User View The Opportunity
	 * @param user
	 * @param opportunityToView
	 */
    public void whenUserViewTheOpportunity(User user, Opportunity opportunityToView) {
    	system.runAs(user) {
    		opportunity = [SELECT id, Submitted_Phone_Link__c, HomePhone__c, MobilePhone__c, Phone__c, WorkPhone__c, DoNotCallPreference__c
    	 		   		   FROM Opportunity
    	 		  		   WHERE id = :opportunityToView.Id];
    	}
    }



    /******** Query Lead Data for Phone Number in test Context *******/
	/**
	 * @description When User View The Lead
	 * @param user
	 * @param leadToView
	 */
    public void whenUserViewTheLead(User user, Lead leadToView) {
    	system.runAs(user) {
    		lead = [SELECT id, Submitted_Phone_Number__c, Phone, Phone__c, Submitt_Phone_Number__c
    	 		   	FROM Lead
    	 		  	WHERE id = :leadToView.Id];
    	}
    }

    /******** Query Case Data for Phone Numbers in test Context *******/
	/**
	 * @description When User View The Case
	 * @param user
	 * @param caseToView
	 */
    public void whenUserViewTheCase(User user, Case caseToView) {
    	system.runAs(user) {
    		caseRecord = [SELECT id, MobilePhone__c, HomePhone__c, WorkPhone__c
    	 		   	FROM Case
    	 		  	WHERE id = :caseToView.Id];
    	}
    }

    /******** Assert Phone link is Blank *********/
	/**
	 * @description Then Phone Is Blank
	 * @param phoneFieldToAssert
	 */
    public void thenPhoneIsBlank(String phoneFieldToAssert) {
      	system.assert(String.isBlank(phoneFieldToAssert), phoneFieldToAssert + ' number link is incorrect');
    }

    /******** Assert Phone number is Display Text *********/
	/**
	 * @description Then Phone Is Just Text
	 * @param display
	 * @param phoneFieldToAssert
	 */
    public void thenPhoneIsJustText(String display, String phoneFieldToAssert) {
      	system.assertEquals(display, phoneFieldToAssert, phoneFieldToAssert + ' number link is incorrect');
    }

	/**
	 * @description BDD click to dial step definition Wrapper
	 */
	public class BDDClickToDialStepDefinitionWrapper{
		public User user;
		public String display;
		public String hyperLink;
		public String longDistanceNumber;
		public String phoneFieldToAssert;
	}
    /******** Assert Phone Numbers where Click To Dial preference is 7 or 10 , Do Not Call = FALSE********/
	/**
	 * @description Then Phone Display Links Are Formated
	 * @param bddWrapper
	 */
    public void thenPhoneDisplayLinksAreFormated(BDDClickToDialStepDefinitionWrapper bddWrapper) {
    	system.assert(bddWrapper.phoneFieldToAssert.equals('<a href="tel:'+ bddWrapper.hyperLink + '" target="_self">' + bddWrapper.display + '</a> Call Failed? <a href="tel:' + bddWrapper.longDistanceNumber + '" target="_self">Click Here</a>')
    			   || thenCiscoPhoneLinkFor7or10(bddWrapper), bddWrapper.phoneFieldToAssert +' number link is incorrect');
    }

    /******** Assert Phone Numbers where Click To Dial preference is 7 or 10 , Do Not Call = TRUE********/
	/**
	 * @description Then Phone Links Are Formated Do Not Market
	 * @param bddWrapper
	 */
    public void thenPhoneLinksAreFormatedDoNotMarket(BDDClickToDialStepDefinitionWrapper bddWrapper) {
    	system.assert(bddWrapper.phoneFieldToAssert.equals('Do Not Market: <a href="tel:'+ bddWrapper.hyperLink + '" target="_self">' + bddWrapper.display + '</a> Call Failed? <a href="tel:' + bddWrapper.longDistanceNumber + '" target="_self">Click Here</a>')
    			   || thenCiscoPhoneLinkDoNotMarket(bddWrapper), bddWrapper.phoneFieldToAssert +' number link is incorrect');

    }

    /******** Assert Phone Numbers where Click To Dial preference is 11 , Do Not Call = FALSE********/
	/**
	 * @description Then Default Phone Display Links Are Formated
	 * @param bddWrapper
	 */
    public void thenDefaultPhoneDisplayLinksAreFormated(BDDClickToDialStepDefinitionWrapper bddWrapper) {
    	system.assert(bddWrapper.phoneFieldToAssert.equals('<a href="tel:'+ bddWrapper.hyperLink + '" target="_self">' + bddWrapper.display + '</a>')
    			   || thenCiscoDefaultPhoneLink(bddWrapper), bddWrapper.phoneFieldToAssert +' number link is incorrect');
    }


	/**
	 * @description Poly BDD click to dail step definition wrapper 
	 */
	public class PolyBDDClickToDialStepDefinitionWrapper{
		public User user;
		public String display;
		public String hyperLink;
		public String phoneFieldToAssert;
	}
    /******** Assert Phone Numbers where Click To Dial preference is 11 , Do Not Call =  TRUE********/
	/**
	 * @description Then Phone Links Are Formated Do Not Market
	 * @param bddWrapper
	 */
    public void thenPhoneLinksAreFormatedDoNotMarket(PolyBDDClickToDialStepDefinitionWrapper bddWrapper) {
    	system.assert(bddWrapper.phoneFieldToAssert.equals('Do Not Market: <a href="tel:'+ bddWrapper.hyperLink + '" target="_self">' + bddWrapper.display + '</a>')
    			   || thenCiscoPhoneLinkDoNotMarket(bddWrapper), bddWrapper.phoneFieldToAssert +' number link is incorrect');
    }

	/**
	 * @description Then Cisco Phone Link For 7 or 10
	 * @param bddWrapper
	 * @return boolean
	 */
   	public boolean thenCiscoPhoneLinkFor7or10(BDDClickToDialStepDefinitionWrapper bddWrapper) {
   		system.runAs(bddWrapper.user) {
   			return(!UserInfo.getUiTheme().equals('Theme4t')
   						&& bddWrapper.phoneFieldToAssert.equals('<a href="ciscotel:'+ bddWrapper.hyperLink + '" target="_self">' + bddWrapper.display + '</a> Call Failed? <a href="ciscotel:' + bddWrapper.longDistanceNumber + '" target="_self">Click Here</a>'));
   		}
   		return false;
   	}

	/**
	 * @description Then Cisco Phone Link Do Not Market
	 * @param bddWrapper
	 * @return boolean
	 */
   	public boolean thenCiscoPhoneLinkDoNotMarket(BDDClickToDialStepDefinitionWrapper bddWrapper) {
   		system.runAs(bddWrapper.user) {
   			return (!UserInfo.getUiTheme().equals('Theme4t')
   						&& bddWrapper.phoneFieldToAssert.equals('Do Not Market: <a href="ciscotel:'+ bddWrapper.hyperLink + '" target="_self">' + bddWrapper.display + '</a> Call Failed? <a href="ciscotel:' + bddWrapper.longDistanceNumber + '" target="_self">Click Here</a>'));
   		}
   		return false;
   	}

	/**
	 * @description Then Cisco Default Phone Link
	 * @param bddWrapper
	 * @return boolean
	 */
   	public boolean thenCiscoDefaultPhoneLink(BDDClickToDialStepDefinitionWrapper bddWrapper) {
   		system.runAs(bddWrapper.user) {
   			return(!UserInfo.getUiTheme().equals('Theme4t')
   						&& bddWrapper.phoneFieldToAssert.equals('<a href="ciscotel:'+ bddWrapper.hyperLink + '" target="_self">' + bddWrapper.display + '</a>'));
   		}
   		return false;
   	}

	/**
	 * @description Then Cisco Phone Link Do Not Market
	 * @param bddWrapper
	 * @return boolean
	 */
   	public boolean thenCiscoPhoneLinkDoNotMarket(PolyBDDClickToDialStepDefinitionWrapper bddWrapper) {
   		system.runAs(bddWrapper.user) {
   			return(!UserInfo.getUiTheme().equals('Theme4t')
   						&& bddWrapper.phoneFieldToAssert.equals('Do Not Market: <a href="ciscotel:'+ bddWrapper.hyperLink + '" target="_self">' + bddWrapper.display + '</a>'));
   		}
   		return false;
   	}

   	/******** Assert Phone Numbers with Do Not Call =  TRUE, have the image Do Not Call for Marketing ********/
	/**
	 * @description Then Do Not Call Preference Image Is Visible
	 */
    public void thenDoNotCallPreferenceImageIsVisible() {
    	system.assertEquals('<img src="/resource/DoNotCall" alt=" " border="0"/>', opportunity.DoNotCallPreference__c, 'The given two parameters are not equal');
    }

    /******** Assert Phone Numbers with Do Not Call =  TRUE, does not have the image Do Not Call for Marketing ********/
	/**
	 * @description Then Do Not Call Preference Image Is Not Visible
	 */
    public void thenDoNotCallPreferenceImageIsNotVisible() {
    	system.assertEquals(null, opportunity.DoNotCallPreference__c, 'Marketing Call Preference field is not displaying');
    }
}