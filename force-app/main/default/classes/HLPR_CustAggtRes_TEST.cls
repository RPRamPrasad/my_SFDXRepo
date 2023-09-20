/****************************************************************************************
Name: HLPR_CustAggtRes_test
Copyright © State Farm
=========================================================================================
Purpose:
-------
Test class for HLPR_CustAggtRes 

Team: Stark
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Choo_Choo		         10/23/2017             R4 Major Release
******************************************************************************************/
/**
 * @description HLPR_CustAggtRes_TEST
 */
@isTest
private class HLPR_CustAggtRes_TEST {

	@isTest
    static void testGetIndCreateCustResToggleOff() {
    	HLPR_CustAggtResIndOrg.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.ADDLBUSINESSDATAFIELDS, false);
      	Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('testLastName');
        acc.PersonBirthdate = System.today()-4;
        acc.MailingInCareOf__c= 'testCO';
        acc.BillingAddressType__c = 'US';
        acc.BillingStreet = 'testStreet';
        acc.BillingCity = 'testCity';
        acc.BillingState = 'IL';
        acc.BillingPostalCode = '55555';
        acc.BillingCountry = 'UNITED STATES';
        acc.DriversLicenseNumber__c = 'A77765349';
        acc.DriversLicenseStateProvince__c = 'Virginia';
        acc.Gender__pc = 'Male';
        acc.SSN__pc = '901226789';
        acc.DeathDate__pc = System.today();
        acc.IsDeathNotificationReceived__pc = TRUE;
        acc.Citizenship__pc = 'Other';
        acc.EmployerName__pc = 'Enterprise';
        acc.OccupationCategory__pc = 'Athletics';
        acc.OccupationStatus__pc = 'Full Time';
        acc.Occupation__pc = 'Administrator';
        acc.OccupationStartDate__pc = System.today();
        acc.IsHearingImpaired__pc = true;
        acc.PreferredSpokenLanguage__pc = 'Spanish';
        
		Test.startTest();
			AP_CustAggtRes custAggtRes = new AP_CustAggtRes();
        	AP_CustAggtRes.cls_data data = new AP_CustAggtRes.cls_data();
        	AP_CustAggtRes.cls_attributes attributes = new AP_CustAggtRes.cls_attributes();
        
        	AP_CustAggtRes.cls_individualCustomer individualCustomer = new AP_CustAggtRes.cls_individualCustomer();
        	AP_CustAggtRes.cls_mailingAddress mailingAddress = new AP_CustAggtRes.cls_mailingAddress();
        	AP_CustAggtRes.cls_residenceAddress residenceAddress = new AP_CustAggtRes.cls_residenceAddress();
       		AP_CustAggtRes.cls_individualName individualName = new AP_CustAggtRes.cls_individualName();
        	AP_CustAggtRes.cls_driversLicense driversLicense = new AP_CustAggtRes.cls_driversLicense();
        	
            data.clientId = 'SDRAVA1231A';
        	data.type='Individual';
        	attributes.emailAddress= 'sdfsdf@noemail.com';
        	attributes.emailUndeliverableReason = 'Undeliverable Email';
        	attributes.textUndeliverableIndicator = 'Valid';
        	attributes.doesNotHaveEmail = 'True';
         	attributes.customerType = 'Individual';
        	individualCustomer.dateOfBirth = '1969-09-10';
        	individualCustomer.dateOfDeath = '1990-09-10';
        	individualCustomer.deathNotificationReceived = 'true';
      		individualCustomer.citizenship='USA';
        	individualCustomer.gender='male';
        	individualCustomer.hearingImpaired = 'true';
        	individualCustomer.maritalStatus = 'Single';
        	individualCustomer.taxIdentificationNumber = '320515059';
        	individualCustomer.preferredFirstName= 'ddddd';
        	individualCustomer.mobilePhoneNumber = '4055550188';																
			individualCustomer.workPhoneNumber = '4055550188';
        	individualCustomer.workPhoneExtension = '0';
        	individualCustomer.homePhoneNumber = '4055550188';
        	individualCustomer.tddPhoneNumber = '4055550188';
        	individualCustomer.employerName ='ffffffff';
        	individualCustomer.occupation = 'Clergy';
        	individualCustomer.occupationStartDate = '1700-01-01';
        	individualCustomer.occupationStatus = 'Retired';
        	individualCustomer.jobTitle ='Minister';
        	individualCustomer.businessOwnerIndicator = 'Y';
        	
        	individualName.prefix ='Brother';
        	individualName.firstName ='ddddddd';
        	individualName.middleName = 'ddddddd';
       		individualName.lastName = 'ddddddddd';
			individualName.suffix ='JR';
        	individualName.designation = 'LPN';
        	
        	driversLicense.state='Illinois';
        	driversLicense.dlNumber = '4444';
       		
        	mailingAddress.addressType ='Foriegn';
        	mailingAddress.street1 = 'ddddddddd';
        	mailingAddress.street2 = 'ddddddddd';
        	mailingAddress.street3 = 'ddddddddd';
        	mailingAddress.street4 = 'ddddddddd';
        	mailingAddress.city = 'ddddddddd';
           	mailingAddress.country = 'ddddddddd';
        	mailingAddress.postalCode = '50007';
        	mailingAddress.state = 'Illinois';
        	mailingAddress.addressStandardizationCode='04';
        	mailingAddress.preAddress = 'ddddddd';
        	
        	residenceAddress.addressType ='Foriegn';
        	residenceAddress.street1 = 'ddddddddd';
        	residenceAddress.street2 = 'ddddddddd';
        	residenceAddress.street3 = 'ddddddddd';
        	residenceAddress.street4 = 'ddddddddd';
        	residenceAddress.city = 'ddddddddd';
           	residenceAddress.country = 'ddddddddd';
        	residenceAddress.postalCode = '50007';
        	residenceAddress.state = 'Illinois';
        	residenceAddress.addressStandardizationCode='04';
        	
        	List<AP_CustAggtRes.cls_preferences> preferenceList = new List<AP_CustAggtRes.cls_preferences>();
        	AP_CustAggtRes.cls_preferences serviceTextPref = new AP_CustAggtRes.cls_preferences();
        	serviceTextPref.preferenceType='serviceText';
            serviceTextPref.preferenceValue='Y';
            serviceTextPref.termsAndConditionsVersion='5.0';
            serviceTextPref.termsAndConditionsType='serviceTextTermsAndCondition';
            serviceTextPref.sourceId='9377699287';
            serviceTextPref.sourceType='phone';	
        	preferenceList.add(serviceTextPref);
        	AP_CustAggtRes.cls_preferences claimTextPref = new AP_CustAggtRes.cls_preferences();
        	claimTextPref.preferenceType='claimAlertText';
            claimTextPref.preferenceValue='N';
            claimTextPref.termsAndConditionsVersion='5.0';
            claimTextPref.termsAndConditionsType='claimTextTermsAndCondition';
            claimTextPref.sourceId='9377699287';
            claimTextPref.sourceType='phone';
        	preferenceList.add(claimTextPref);
			 AP_CustAggtRes.cls_preferences claimTextPendPref = new AP_CustAggtRes.cls_preferences();
            claimTextPendPref.preferenceType='claimAlertText';
            claimTextPendPref.preferenceValue='P';
            claimTextPendPref.termsAndConditionsVersion='5.0';
            claimTextPendPref.termsAndConditionsType='claimTextTermsAndCondition';
            claimTextPendPref.sourceId='9377699287';
            claimTextPendPref.sourceType='phone';
            preferenceList.add(claimTextPendPref);
        	AP_CustAggtRes.cls_preferences mktgEmailPref = new AP_CustAggtRes.cls_preferences();
        	mktgEmailPref.preferenceType='marketingEmail';
            mktgEmailPref.preferenceValue='N';
            mktgEmailPref.termsAndConditionsVersion='5.0';
            mktgEmailPref.sourceType='email';
        	preferenceList.add(mktgEmailPref);
        	AP_CustAggtRes.cls_preferences serviceEmailPref = new AP_CustAggtRes.cls_preferences();
        	serviceEmailPref.preferenceType='serviceEmail';
            serviceEmailPref.preferenceValue='Y';
            serviceEmailPref.sourceType='email';
        	preferenceList.add(serviceEmailPref);
        	AP_CustAggtRes.cls_preferences claimEmailPref = new AP_CustAggtRes.cls_preferences();
        	claimEmailPref.preferenceType='claimAlertEmail';
            claimEmailPref.preferenceValue='N';
            claimEmailPref.termsAndConditionsVersion='5.0';
            claimEmailPref.sourceType='email';
        	preferenceList.add(claimEmailPref);
        	AP_CustAggtRes.cls_preferences isProtectedPersonPref = new AP_CustAggtRes.cls_preferences();
        	isProtectedPersonPref.preferenceType ='isProtectedPerson';
        	isProtectedPersonPref.preferenceValue='N';
       		preferenceList.add(isProtectedPersonPref);
        	AP_CustAggtRes.cls_preferences isSubjectToCASLPref = new AP_CustAggtRes.cls_preferences();
        	isSubjectToCASLPref.preferenceType ='isSubjectToCASL';
        	isSubjectToCASLPref.preferenceValue='N';
       		preferenceList.add(isSubjectToCASLPref);
        	AP_CustAggtRes.cls_preferences paperlessPrivacyNoticeIndicatorPref = new AP_CustAggtRes.cls_preferences();
        	paperlessPrivacyNoticeIndicatorPref.preferenceType ='paperlessPrivacyNoticeIndicator';
        	paperlessPrivacyNoticeIndicatorPref.preferenceValue='N';
        	preferenceList.add(paperlessPrivacyNoticeIndicatorPref);
            AP_CustAggtRes.cls_preferences doNotMailIndicatorPref = new AP_CustAggtRes.cls_preferences();
        	doNotMailIndicatorPref.preferenceType ='doNotMailIndicator';
        	doNotMailIndicatorPref.preferenceValue='N';
        	preferenceList.add(doNotMailIndicatorPref);
        	AP_CustAggtRes.cls_preferences doNotCallIndicatorPref = new AP_CustAggtRes.cls_preferences();
        	doNotCallIndicatorPref.preferenceType ='doNotCallIndicator';
        	doNotCallIndicatorPref.preferenceValue='N';
        	preferenceList.add(doNotCallIndicatorPref);
        	AP_CustAggtRes.cls_preferences preferredSpokenLanguagePref = new AP_CustAggtRes.cls_preferences();
        	preferredSpokenLanguagePref.preferenceType ='preferredSpokenLanguage';
        	preferredSpokenLanguagePref.preferenceValue='English';
        	preferenceList.add(preferredSpokenLanguagePref);
      		AP_CustAggtRes.cls_preferences providedPrivacyOptionsPref = new AP_CustAggtRes.cls_preferences();
        	providedPrivacyOptionsPref.preferenceType ='providedPrivacyOptions';
        	providedPrivacyOptionsPref.preferenceValue='Y';
        	preferenceList.add(providedPrivacyOptionsPref);
        	AP_CustAggtRes.cls_preferences doNotShareIndicatorPref = new AP_CustAggtRes.cls_preferences();
        	doNotShareIndicatorPref.preferenceType ='doNotShareIndicator';
        	doNotShareIndicatorPref.preferenceValue='Y';
        	preferenceList.add(doNotShareIndicatorPref);
            AP_CustAggtRes.cls_preferences isHealthSourcedPref = new AP_CustAggtRes.cls_preferences();
        	isHealthSourcedPref.preferenceType ='Health Sourced';
        	isHealthSourcedPref.preferenceValue='N';
        	preferenceList.add(isHealthSourcedPref);
        	AP_CustAggtRes.cls_preferences isBillingStatement = new AP_CustAggtRes.cls_preferences();
        	isBillingStatement.preferenceType ='billingPaperless';
        	isBillingStatement.preferenceValue='N';
        	preferenceList.add(isBillingStatement);
        	AP_CustAggtRes.cls_preferences isPendingBillingStatement = new AP_CustAggtRes.cls_preferences();
            isPendingBillingStatement.preferenceType ='billingPaperless';
            isPendingBillingStatement.preferenceValue='P';
            preferenceList.add(isPendingBillingStatement);
			AP_CustAggtRes.cls_preferences isAccPolicyNotification = new AP_CustAggtRes.cls_preferences();
        	isAccPolicyNotification.preferenceType ='accountPolicyNotification';
        	isAccPolicyNotification.preferenceValue='Y';
        	preferenceList.add(isAccPolicyNotification);
        	AP_CustAggtRes.cls_preferences billAlertEmailPref = new AP_CustAggtRes.cls_preferences();
        	billAlertEmailPref.preferenceType ='billAlertEmail';
        	billAlertEmailPref.preferenceValue='Y';
        	preferenceList.add(billAlertEmailPref);
        	AP_CustAggtRes.cls_preferences policyPaperlessEmailPref = new AP_CustAggtRes.cls_preferences();
        	policyPaperlessEmailPref.preferenceType ='policyPaperless';
        	policyPaperlessEmailPref.preferenceValue='Y';
        	preferenceList.add(policyPaperlessEmailPref);
        	AP_CustAggtRes.cls_preferences policyPaperlessEmailPendPref = new AP_CustAggtRes.cls_preferences();
            policyPaperlessEmailPendPref.preferenceType ='policyPaperless';
            policyPaperlessEmailPendPref.preferenceValue='P';
            preferenceList.add(policyPaperlessEmailPendPref);
			AP_CustAggtRes.cls_preferences billAlertTextPref = new AP_CustAggtRes.cls_preferences();
        	billAlertTextPref.preferenceType ='billText';
        	billAlertTextPref.preferenceValue='P';
        	preferenceList.add(billAlertTextPref);
                       
        	custAggtRes.data=data;
        	attributes.individualCustomer = individualCustomer;
       	    attributes.residenceaddress = residenceaddress;
        	attributes.mailingAddress = mailingAddress;
        	attributes.residenceAddress = residenceAddress;
        	attributes.individualCustomer.individualName = individualName;
        	attributes.individualCustomer.driversLicense = driversLicense;
        	attributes.preferences= preferenceList;
        	custAggtRes.data.attributes = attributes;

			User agentRunningUser = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678914');
	        agentRunningUser = TestDataFactory_User.insertUser(agentRunningUser); 

			Account indJsonRes;
			TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentRunningUser);

			System.runAs(agentRunningUser){
        		indJsonRes = HLPR_CustAggtRes.buildCustomerFromAggtRes(acc, custAggtRes);
			}
            System.assert(indJsonRes!=null, 'Ind Json request is not null');
        	//System.assertEquals('ddddddd', indJsonRes.FirstName, 'First Name: '+indJsonRes.FirstName);
        	//System.assertEquals('ddddddddd', indJsonRes.LastName, 'Last Name: '+indJsonRes.LastName);
        	System.assert(indJsonRes.HasPermissionToServiceText__c.equalsIgnoreCase('Yes'), 'Permission to Service Text: '+indJsonRes.HasPermissionToServiceText__c);
        	//System.assertEquals(null, indJsonRes.OccupationStartDate__pc, 'Occupation Start Date '+indJsonRes.OccupationStartDate__pc);
        	//System.assertEquals('0', indJsonRes.WorkPhoneExtension__c, 'Work hone Extension: '+indJsonRes.WorkPhoneExtension__c);
			assertGetIndCreateCustResToggleOff(indJsonRes);
         Test.stopTest();
    }

	private static void assertGetIndCreateCustResToggleOff(Account indJsonRes){
		System.assertEquals('Yes', indJsonRes.businessownerindicator__c, 'Business Owner Indicator: '+indJsonRes.businessOwnerIndicator__c);
		System.assertEquals('Yes', indJsonRes.SFPPBillRemindersEmail__c, 'SFPP Bill reminder Email: '+indJsonRes.SFPPBillRemindersEmail__c);
		System.assertEquals('Waiting For Confirmation', indJsonRes.BillAlertText__c, 'Bill Alert Text: '+indJsonRes.BillAlertText__c);
		System.assertEquals('Yes', indJsonRes.PolicyDocuments__c, 'Policy documents: '+ indJsonRes.PolicyDocuments__c);
		System.assertEquals('Undeliverable Email', indJsonRes.PersonEmailBouncedReason__c, 'Person Email: '+indJsonRes.PersonEmailBouncedReason__c);
		System.assertEquals('Valid', indJsonRes.TextBouncedReason__c, 'Text Bounced Reason: '+indJsonRes.TextBouncedReason__c);
	}
    
	@isTest
    static void testGetIndCreateCustResToggleOn() {
    	HLPR_CustAggtResIndOrg.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.ADDLBUSINESSDATAFIELDS, true);
      	Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('testLastName');
        acc.PersonBirthdate = System.today()-4;
        acc.MailingInCareOf__c= 'testCO';
        acc.BillingAddressType__c = 'US';
        acc.BillingStreet = 'testStreet';
        acc.BillingCity = 'testCity';
        acc.BillingState = 'IL';
        acc.BillingPostalCode = '55555';
        acc.BillingCountry = 'UNITED STATES';
        acc.DriversLicenseNumber__c = 'A77765349';
        acc.DriversLicenseStateProvince__c = 'Virginia';
        acc.Gender__pc = 'Male';
        acc.SSN__pc = '901226789';
        acc.DeathDate__pc = System.today();
        acc.IsDeathNotificationReceived__pc = TRUE;
        acc.Citizenship__pc = 'Other';
        acc.EmployerName__pc = 'Enterprise';
        acc.OccupationCategory__pc = 'Athletics';
        acc.OccupationStatus__pc = 'Full Time';
        acc.Occupation__pc = 'Administrator';
        acc.OccupationStartDate__pc = System.today();
        acc.IsHearingImpaired__pc = true;
        acc.PreferredSpokenLanguage__pc = 'Spanish';
        
		Test.startTest();
			AP_CustAggtRes custAggtRes = new AP_CustAggtRes();
        	AP_CustAggtRes.cls_data data = new AP_CustAggtRes.cls_data();
        	AP_CustAggtRes.cls_attributes attributes = new AP_CustAggtRes.cls_attributes();
        
        	AP_CustAggtRes.cls_individualCustomer individualCustomer = new AP_CustAggtRes.cls_individualCustomer();
        	AP_CustAggtRes.cls_mailingAddress mailingAddress = new AP_CustAggtRes.cls_mailingAddress();
        	AP_CustAggtRes.cls_residenceAddress residenceAddress = new AP_CustAggtRes.cls_residenceAddress();
       		AP_CustAggtRes.cls_individualName individualName = new AP_CustAggtRes.cls_individualName();
        	AP_CustAggtRes.cls_driversLicense driversLicense = new AP_CustAggtRes.cls_driversLicense();
        	
            data.clientId = 'SDRAVA1231A';
        	data.type='Individual';
        	attributes.emailAddress= 'sdfsdf@noemail.com';
        	attributes.doesNotHaveEmail = 'True';
         	attributes.customerType = 'Individual';
        	individualCustomer.dateOfBirth = '1969-09-10';
        	individualCustomer.dateOfDeath = '1990-09-10';
        	individualCustomer.deathNotificationReceived = 'true';
      		individualCustomer.citizenship='USA';
        	individualCustomer.gender='male';
        	individualCustomer.hearingImpaired = 'true';
        	individualCustomer.maritalStatus = 'Single';
        	individualCustomer.taxIdentificationNumber = '320515059';
        	individualCustomer.preferredFirstName= 'ddddd';
        	individualCustomer.mobilePhoneNumber = '4055550188';																
			individualCustomer.workPhoneNumber = '4055550188';
        	individualCustomer.workPhoneExtension = '0';
        	individualCustomer.homePhoneNumber = '4055550188';
        	individualCustomer.tddPhoneNumber = '4055550188';
        	individualCustomer.employerName ='ffffffff';
        	individualCustomer.occupation = 'Clergy';
        	individualCustomer.occupationStartDate = '1700-01-01';
        	individualCustomer.occupationStatus = 'Retired';
        	individualCustomer.jobTitle ='Minister';
        	individualCustomer.businessOwnerIndicator = 'Y';
        	
        	individualName.prefix ='Brother';
        	individualName.firstName ='ddddddd';
        	individualName.middleName = 'ddddddd';
       		individualName.lastName = 'ddddddddd';
			individualName.suffix ='JR';
        	individualName.designation = 'LPN';
        	
        	driversLicense.state='Illinois';
        	driversLicense.dlNumber = '4444';
       		
        	mailingAddress.addressType ='Foriegn';
        	mailingAddress.street1 = 'ddddddddd';
        	mailingAddress.street2 = 'ddddddddd';
        	mailingAddress.street3 = 'ddddddddd';
        	mailingAddress.street4 = 'ddddddddd';
        	mailingAddress.city = 'ddddddddd';
           	mailingAddress.country = 'ddddddddd';
        	mailingAddress.postalCode = '50007';
        	mailingAddress.state = 'Illinois';
        	mailingAddress.addressStandardizationCode='04';
        	mailingAddress.preAddress = 'ddddddd';
        	
        	residenceAddress.addressType ='Foriegn';
        	residenceAddress.street1 = 'ddddddddd';
        	residenceAddress.street2 = 'ddddddddd';
        	residenceAddress.street3 = 'ddddddddd';
        	residenceAddress.street4 = 'ddddddddd';
        	residenceAddress.city = 'ddddddddd';
           	residenceAddress.country = 'ddddddddd';
        	residenceAddress.postalCode = '50007';
        	residenceAddress.state = 'Illinois';
        	residenceAddress.addressStandardizationCode='04';
        	
        	List<AP_CustAggtRes.cls_preferences> preferenceList = new List<AP_CustAggtRes.cls_preferences>();
        	AP_CustAggtRes.cls_preferences serviceTextPref = new AP_CustAggtRes.cls_preferences();
        	serviceTextPref.preferenceType='serviceText';
            serviceTextPref.preferenceValue='Y';
            serviceTextPref.termsAndConditionsVersion='5.0';
            serviceTextPref.termsAndConditionsType='serviceTextTermsAndCondition';
            serviceTextPref.sourceId='9377699287';
            serviceTextPref.sourceType='phone';	
        	preferenceList.add(serviceTextPref);
        	AP_CustAggtRes.cls_preferences claimTextPref = new AP_CustAggtRes.cls_preferences();
        	claimTextPref.preferenceType='claimAlertText';
            claimTextPref.preferenceValue='N';
            claimTextPref.termsAndConditionsVersion='5.0';
            claimTextPref.termsAndConditionsType='claimTextTermsAndCondition';
            claimTextPref.sourceId='9377699287';
            claimTextPref.sourceType='phone';
        	preferenceList.add(claimTextPref);
        	AP_CustAggtRes.cls_preferences mktgEmailPref = new AP_CustAggtRes.cls_preferences();
        	mktgEmailPref.preferenceType='marketingEmail';
            mktgEmailPref.preferenceValue='N';
            mktgEmailPref.termsAndConditionsVersion='5.0';
            mktgEmailPref.sourceType='email';
        	preferenceList.add(mktgEmailPref);
        	AP_CustAggtRes.cls_preferences serviceEmailPref = new AP_CustAggtRes.cls_preferences();
        	serviceEmailPref.preferenceType='serviceEmail';
            serviceEmailPref.preferenceValue='Y';
            serviceEmailPref.sourceType='email';
        	preferenceList.add(serviceEmailPref);
        	AP_CustAggtRes.cls_preferences claimEmailPref = new AP_CustAggtRes.cls_preferences();
        	claimEmailPref.preferenceType='claimAlertEmail';
            claimEmailPref.preferenceValue='N';
            claimEmailPref.termsAndConditionsVersion='5.0';
            claimEmailPref.sourceType='email';
        	preferenceList.add(claimEmailPref);
        	AP_CustAggtRes.cls_preferences isProtectedPersonPref = new AP_CustAggtRes.cls_preferences();
        	isProtectedPersonPref.preferenceType ='isProtectedPerson';
        	isProtectedPersonPref.preferenceValue='N';
       		preferenceList.add(isProtectedPersonPref);
        	AP_CustAggtRes.cls_preferences isSubjectToCASLPref = new AP_CustAggtRes.cls_preferences();
        	isSubjectToCASLPref.preferenceType ='isSubjectToCASL';
        	isSubjectToCASLPref.preferenceValue='N';
       		preferenceList.add(isSubjectToCASLPref);
        	AP_CustAggtRes.cls_preferences paperlessPrivacyNoticeIndicatorPref = new AP_CustAggtRes.cls_preferences();
        	paperlessPrivacyNoticeIndicatorPref.preferenceType ='paperlessPrivacyNoticeIndicator';
        	paperlessPrivacyNoticeIndicatorPref.preferenceValue='N';
        	preferenceList.add(paperlessPrivacyNoticeIndicatorPref);
            AP_CustAggtRes.cls_preferences doNotMailIndicatorPref = new AP_CustAggtRes.cls_preferences();
        	doNotMailIndicatorPref.preferenceType ='doNotMailIndicator';
        	doNotMailIndicatorPref.preferenceValue='N';
        	preferenceList.add(doNotMailIndicatorPref);
        	AP_CustAggtRes.cls_preferences doNotCallIndicatorPref = new AP_CustAggtRes.cls_preferences();
        	doNotCallIndicatorPref.preferenceType ='doNotCallIndicator';
        	doNotCallIndicatorPref.preferenceValue='N';
        	preferenceList.add(doNotCallIndicatorPref);
        	AP_CustAggtRes.cls_preferences preferredSpokenLanguagePref = new AP_CustAggtRes.cls_preferences();
        	preferredSpokenLanguagePref.preferenceType ='preferredSpokenLanguage';
        	preferredSpokenLanguagePref.preferenceValue='English';
        	preferenceList.add(preferredSpokenLanguagePref);
      		AP_CustAggtRes.cls_preferences providedPrivacyOptionsPref = new AP_CustAggtRes.cls_preferences();
        	providedPrivacyOptionsPref.preferenceType ='providedPrivacyOptions';
        	providedPrivacyOptionsPref.preferenceValue='Y';
        	preferenceList.add(providedPrivacyOptionsPref);
        	AP_CustAggtRes.cls_preferences doNotShareIndicatorPref = new AP_CustAggtRes.cls_preferences();
        	doNotShareIndicatorPref.preferenceType ='doNotShareIndicator';
        	doNotShareIndicatorPref.preferenceValue='Y';
        	preferenceList.add(doNotShareIndicatorPref);
            AP_CustAggtRes.cls_preferences isHealthSourcedPref = new AP_CustAggtRes.cls_preferences();
        	isHealthSourcedPref.preferenceType ='Health Sourced';
        	isHealthSourcedPref.preferenceValue='N';
        	preferenceList.add(isHealthSourcedPref);
        	AP_CustAggtRes.cls_preferences isBillingStatement = new AP_CustAggtRes.cls_preferences();
        	isBillingStatement.preferenceType ='billingPaperless';
        	isBillingStatement.preferenceValue='N';
        	preferenceList.add(isBillingStatement);
        	AP_CustAggtRes.cls_preferences isAccPolicyNotification = new AP_CustAggtRes.cls_preferences();
        	isAccPolicyNotification.preferenceType ='accountPolicyNotification';
        	isAccPolicyNotification.preferenceValue='Y';
        	preferenceList.add(isAccPolicyNotification);
        	AP_CustAggtRes.cls_preferences billAlertEmailPref = new AP_CustAggtRes.cls_preferences();
        	billAlertEmailPref.preferenceType ='billAlertEmail';
        	billAlertEmailPref.preferenceValue='Y';
        	preferenceList.add(billAlertEmailPref);
                       
        	custAggtRes.data=data;
        	attributes.individualCustomer = individualCustomer;
       	    attributes.residenceaddress = residenceaddress;
        	attributes.mailingAddress = mailingAddress;
        	attributes.residenceAddress = residenceAddress;
        	attributes.individualCustomer.individualName = individualName;
        	attributes.individualCustomer.driversLicense = driversLicense;
        	attributes.preferences= preferenceList;
        	custAggtRes.data.attributes = attributes;

			User agentRunningUser = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678914');
	        agentRunningUser = TestDataFactory_User.insertUser(agentRunningUser);  

        	Account indJsonRes;
			TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentRunningUser);

        	System.runAs(agentRunningUser){
        		indJsonRes = HLPR_CustAggtRes.buildCustomerFromAggtRes(acc, custAggtRes);
			}
            System.assert(indJsonRes!=null, 'Ind Json request is not null');
        	System.assertEquals('ddddddd', indJsonRes.FirstName, 'First Name: '+indJsonRes.FirstName);
        	System.assertEquals('ddddddddd', indJsonRes.LastName, 'Last Name: '+indJsonRes.LastName);
        	System.assert(indJsonRes.HasPermissionToServiceText__c.equalsIgnoreCase('Yes'), 'Permission to Service Text: '+indJsonRes.HasPermissionToServiceText__c);
        	System.assertEquals(null, indJsonRes.OccupationStartDate__pc, 'Occupation Start Date: '+indJsonRes.OccupationStartDate__pc);
        	System.assertEquals('0', indJsonRes.WorkPhoneExtension__c, 'Work Phone extension: '+indJsonRes.WorkPhoneExtension__c);
        	System.assertEquals(null, indJsonRes.businessownerindicator__c, 'Business Owner Indicator: '+indJsonRes.businessOwnerIndicator__c);
        	System.assertEquals(null, indJsonRes.SFPPBillRemindersEmail__c, 'SFPP Bill Reminder Email: '+indJsonRes.SFPPBillRemindersEmail__c);
        	System.assertEquals(null, indJsonRes.PolicyDocuments__c, 'Policy Documents: '+indJsonRes.PolicyDocuments__c);
         Test.stopTest();
    }

	@isTest
    static void testGetOrgCreateCustResToggleOff() {
    	HLPR_CustAggtResIndOrg.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.ADDLBUSINESSDATAFIELDS, false);
      	Account acc = UTIL_CreateCustomerTestData.createOrganizationCustomer('testLastName');
        acc.BillingAddressType__c = 'US';
        acc.BillingStreet = 'testStreet';
        acc.BillingCity = 'testCity';
        acc.BillingState = 'IL';
        acc.BillingPostalCode = '55555';
        acc.BillingCountry = 'UNITED STATES';
        acc.ShippingAddressType__c = 'US';
        acc.ShippingStreet = 'testStreet';
        acc.ShippingCity = 'testCity';
        acc.ShippingState = 'IL';
        acc.ShippingPostalCode = '55555';
        acc.ShippingCountry = 'UNITED STATES';
        acc.TIN__c = '901226789';
        acc.PreferredSpokenLanguage__pc = 'English';
        acc.PersonEmail = 'noemail@noemail.com';
        acc.HasConfirmedNoEmail__c = TRUE;
        acc.HasPermissionToServiceEmail__c = 'YES';
        acc.HasPermissionToClaimEmail__c = 'YES';
        acc.HasPermissionToMarketingEmail__c = 'NO';
        acc.HasPermissionToServiceText__c = 'NO';
        acc.HasPermissionToClaimText__c = 'YES';
        acc.PersonMobilePhone = '7328900774';
        acc.WorkPhoneExtension__c = '7600';
        acc.Phone = '7328900778';
        acc.PersonHomePhone = '7328900775';
        acc.TDDPhone__c = '7890234255';
        acc.Fax = '7890234255';
        
		Test.startTest();
			AP_CustAggtRes custAggtRes = new AP_CustAggtRes();
        	AP_CustAggtRes.cls_data data = new AP_CustAggtRes.cls_data();
        	AP_CustAggtRes.cls_attributes attributes = new AP_CustAggtRes.cls_attributes();
        
      		AP_CustAggtRes.cls_organizationCustomer organizationCustomer = new AP_CustAggtRes.cls_organizationCustomer();
        	AP_CustAggtRes.cls_mailingAddress mailingAddress = new AP_CustAggtRes.cls_mailingAddress();
        	AP_CustAggtRes.cls_residenceAddress residenceAddress = new AP_CustAggtRes.cls_residenceAddress();
        	
            data.clientId = 'SDRAVA1231A';
        	data.type='Organization';
        	attributes.emailAddress= 'sdfsdf@noemail.com';
        	attributes.doesNotHaveEmail = 'True';
         	attributes.customerType = 'Organization';
         	attributes.emailUndeliverableReason = 'Undeliverable Email';
        	attributes.textUndeliverableIndicator = 'Valid';
        	
        	organizationCustomer.organizationName='testorgname';
        	organizationCustomer.organizationType='corp';
        	organizationCustomer.taxIdentificationNumber='901226789';
        	organizationCustomer.mobilePhoneNumber='9377699287';
        	organizationCustomer.workPhoneNumber='9377699287';
        	organizationCustomer.workPhoneExtension='0100';
        	organizationCustomer.faxPhoneNumber='9377699287';
        	organizationCustomer.tddPhoneNumber='9377699287';
        	organizationCustomer.industry = 'Other';
        	organizationCustomer.revenueAmount = '50000';
        	
        	mailingAddress.addressType ='US';
        	mailingAddress.street1 = 'teststreet1';
        	mailingAddress.street2 = 'teststreet2';
        	mailingAddress.street3 = 'teststreet3';
        	mailingAddress.street4 = 'teststreet4';
        	mailingAddress.city = 'testcity';
           	mailingAddress.country = 'UNITED STATES';
        	mailingAddress.postalCode = '50007';
        	mailingAddress.state = 'Illinois';
        	mailingAddress.addressStandardizationCode='04';
        	mailingAddress.preAddress = 'testpreaddress';
        	
        	residenceAddress.addressType ='US';
        	residenceAddress.street1 = 'teststreet1';
        	residenceAddress.street2 = 'teststreet2';
        	residenceAddress.street3 = 'teststreet3';
        	residenceAddress.street4 = 'teststreet4';
        	residenceAddress.city = 'testcity';
           	residenceAddress.country = 'UNITED STATES';
        	residenceAddress.postalCode = '50007';
        	residenceAddress.state = 'Illinois';
        	residenceAddress.addressStandardizationCode='04';
        	
        	List<AP_CustAggtRes.cls_preferences> preferenceList = new List<AP_CustAggtRes.cls_preferences>();
        	AP_CustAggtRes.cls_preferences serviceTextPref = new AP_CustAggtRes.cls_preferences();
        	serviceTextPref.preferenceType='serviceText';
            serviceTextPref.preferenceValue='Y';
            serviceTextPref.termsAndConditionsVersion='5.0';
            serviceTextPref.termsAndConditionsType='serviceTextTermsAndCondition';
            serviceTextPref.sourceId='9377699287';
            serviceTextPref.sourceType='phone';	
        	preferenceList.add(serviceTextPref);
        	AP_CustAggtRes.cls_preferences claimTextPref = new AP_CustAggtRes.cls_preferences();
        	claimTextPref.preferenceType='claimAlertText';
            claimTextPref.preferenceValue='N';
            claimTextPref.termsAndConditionsVersion='5.0';
            claimTextPref.termsAndConditionsType='claimTextTermsAndCondition';
            claimTextPref.sourceId='9377699287';
            claimTextPref.sourceType='phone';
        	preferenceList.add(claimTextPref);
        	AP_CustAggtRes.cls_preferences mktgEmailPref = new AP_CustAggtRes.cls_preferences();
        	mktgEmailPref.preferenceType='marketingEmail';
            mktgEmailPref.preferenceValue='N';
            mktgEmailPref.termsAndConditionsVersion='5.0';
            mktgEmailPref.sourceType='email';
        	preferenceList.add(mktgEmailPref);
        	AP_CustAggtRes.cls_preferences serviceEmailPref = new AP_CustAggtRes.cls_preferences();
        	serviceEmailPref.preferenceType='serviceEmail';
            serviceEmailPref.preferenceValue='Y';
            serviceEmailPref.sourceType='email';
        	preferenceList.add(serviceEmailPref);
        	AP_CustAggtRes.cls_preferences claimEmailPref = new AP_CustAggtRes.cls_preferences();
        	claimEmailPref.preferenceType='claimAlertEmail';
            claimEmailPref.preferenceValue='N';
            claimEmailPref.termsAndConditionsVersion='5.0';
            claimEmailPref.sourceType='email';
        	preferenceList.add(claimEmailPref);
        	AP_CustAggtRes.cls_preferences isProtectedPersonPref = new AP_CustAggtRes.cls_preferences();
        	isProtectedPersonPref.preferenceType ='isProtectedPerson';
        	isProtectedPersonPref.preferenceValue='N';
       		preferenceList.add(isProtectedPersonPref);
        	AP_CustAggtRes.cls_preferences isSubjectToCASLPref = new AP_CustAggtRes.cls_preferences();
        	isSubjectToCASLPref.preferenceType ='isSubjectToCASL';
        	isSubjectToCASLPref.preferenceValue='N';
       		preferenceList.add(isSubjectToCASLPref);
        	AP_CustAggtRes.cls_preferences paperlessPrivacyNoticeIndicatorPref = new AP_CustAggtRes.cls_preferences();
        	paperlessPrivacyNoticeIndicatorPref.preferenceType ='paperlessPrivacyNoticeIndicator';
        	paperlessPrivacyNoticeIndicatorPref.preferenceValue='N';
        	preferenceList.add(paperlessPrivacyNoticeIndicatorPref);
            AP_CustAggtRes.cls_preferences doNotMailIndicatorPref = new AP_CustAggtRes.cls_preferences();
        	doNotMailIndicatorPref.preferenceType ='doNotMailIndicator';
        	doNotMailIndicatorPref.preferenceValue='N';
        	preferenceList.add(doNotMailIndicatorPref);
        	AP_CustAggtRes.cls_preferences doNotCallIndicatorPref = new AP_CustAggtRes.cls_preferences();
        	doNotCallIndicatorPref.preferenceType ='doNotCallIndicator';
        	doNotCallIndicatorPref.preferenceValue='N';
        	preferenceList.add(doNotCallIndicatorPref);
        	AP_CustAggtRes.cls_preferences preferredSpokenLanguagePref = new AP_CustAggtRes.cls_preferences();
        	preferredSpokenLanguagePref.preferenceType ='preferredSpokenLanguage';
        	preferredSpokenLanguagePref.preferenceValue='English';
        	preferenceList.add(preferredSpokenLanguagePref);
      		AP_CustAggtRes.cls_preferences providedPrivacyOptionsPref = new AP_CustAggtRes.cls_preferences();
        	providedPrivacyOptionsPref.preferenceType ='providedPrivacyOptions';
        	providedPrivacyOptionsPref.preferenceValue='Y';
        	preferenceList.add(providedPrivacyOptionsPref);
        	AP_CustAggtRes.cls_preferences doNotShareIndicatorPref = new AP_CustAggtRes.cls_preferences();
        	doNotShareIndicatorPref.preferenceType ='doNotShareIndicator';
        	doNotShareIndicatorPref.preferenceValue='Y';
        	preferenceList.add(doNotShareIndicatorPref);
            AP_CustAggtRes.cls_preferences isBillingStatement = new AP_CustAggtRes.cls_preferences();
        	isBillingStatement.preferenceType ='billingPaperless';
        	isBillingStatement.preferenceValue='Y';
        	preferenceList.add(isBillingStatement);
        	AP_CustAggtRes.cls_preferences isAccPolicyNotification = new AP_CustAggtRes.cls_preferences();
        	isAccPolicyNotification.preferenceType ='accountPolicyNotification';
        	isAccPolicyNotification.preferenceValue='N';
        	preferenceList.add(isAccPolicyNotification);
        
        	custAggtRes.data=data;
        	attributes.organizationCustomer = organizationCustomer;
       	    attributes.residenceaddress = residenceaddress;
        	attributes.mailingAddress = mailingAddress;
        	attributes.residenceAddress = residenceAddress;
        	attributes.preferences= preferenceList;
        	custAggtRes.data.attributes = attributes;

			User agentRunningUser = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678914');
            agentRunningUser = TestDataFactory_User.insertUser(agentRunningUser);  
            
            Account orgJsonRes;
			TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentRunningUser);

            System.runAs(agentRunningUser){
        		orgJsonRes = HLPR_CustAggtRes.buildCustomerFromAggtRes(acc, custAggtRes);
			}
            System.assert(orgJsonRes!=null, 'Org Json request is not null');
        	System.assertEquals('testorgname', orgJsonRes.LastName, 'Last Name: '+orgJsonRes.LastName);
        	System.assert(orgJsonRes.HasPermissionToServiceText__c.equalsIgnoreCase('Yes'), 'Permission to Service Text: '+orgJsonRes.HasPermissionToServiceText__c);
        	System.assertEquals('Other',orgJsonRes.industry, 'Industry: '+orgJsonRes.industry);
        	System.assertEquals(50000, orgJsonRes.AnnualRevenue, 'Annual Revenue: '+orgJsonRes.AnnualRevenue);
        	System.assertEquals('Undeliverable Email', orgJsonRes.PersonEmailBouncedReason__c, 'Person Email Bounsed Reason: '+orgJsonRes.PersonEmailBouncedReason__c);
        	System.assertEquals('Valid', orgJsonRes.TextBouncedReason__c, 'Text Bounced Reason: '+orgJsonRes.TextBouncedReason__c);	
         Test.stopTest();
    }
    
	@isTest
    static void testGetOrgCreateCustResToggleOn() {
    	HLPR_CustAggtResIndOrg.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.ADDLBUSINESSDATAFIELDS, true);
      	Account acc = UTIL_CreateCustomerTestData.createOrganizationCustomer('testLastName');
        acc.BillingAddressType__c = 'US';
        acc.BillingStreet = 'testStreet';
        acc.BillingCity = 'testCity';
        acc.BillingState = 'IL';
        acc.BillingPostalCode = '55555';
        acc.BillingCountry = 'UNITED STATES';
        acc.ShippingAddressType__c = 'US';
        acc.ShippingStreet = 'testStreet';
        acc.ShippingCity = 'testCity';
        acc.ShippingState = 'IL';
        acc.ShippingPostalCode = '55555';
        acc.ShippingCountry = 'UNITED STATES';
        acc.TIN__c = '901226789';
        acc.PreferredSpokenLanguage__pc = 'English';
        acc.PersonEmail = 'noemail@noemail.com';
        acc.HasConfirmedNoEmail__c = TRUE;
        acc.HasPermissionToServiceEmail__c = 'YES';
        acc.HasPermissionToClaimEmail__c = 'YES';
        acc.HasPermissionToMarketingEmail__c = 'NO';
        acc.HasPermissionToServiceText__c = 'NO';
        acc.HasPermissionToClaimText__c = 'YES';
        acc.PersonMobilePhone = '7328900774';
        acc.WorkPhoneExtension__c = '7600';
        acc.Phone = '7328900778';
        acc.PersonHomePhone = '7328900775';
        acc.TDDPhone__c = '7890234255';
        acc.Fax = '7890234255';
        
		Test.startTest();
			AP_CustAggtRes custAggtRes = new AP_CustAggtRes();
        	AP_CustAggtRes.cls_data data = new AP_CustAggtRes.cls_data();
        	AP_CustAggtRes.cls_attributes attributes = new AP_CustAggtRes.cls_attributes();
        
      		AP_CustAggtRes.cls_organizationCustomer organizationCustomer = new AP_CustAggtRes.cls_organizationCustomer();
        	AP_CustAggtRes.cls_mailingAddress mailingAddress = new AP_CustAggtRes.cls_mailingAddress();
        	AP_CustAggtRes.cls_residenceAddress residenceAddress = new AP_CustAggtRes.cls_residenceAddress();
        	
            data.clientId = 'SDRAVA1231A';
        	data.type='Organization';
        	attributes.emailAddress= 'sdfsdf@noemail.com';
        	attributes.doesNotHaveEmail = 'True';
         	attributes.customerType = 'Organization';
        	
        	organizationCustomer.organizationName='testorgname';
        	organizationCustomer.organizationType='corp';
        	organizationCustomer.taxIdentificationNumber='901226789';
        	organizationCustomer.mobilePhoneNumber='9377699287';
        	organizationCustomer.workPhoneNumber='9377699287';
        	organizationCustomer.workPhoneExtension='0100';
        	organizationCustomer.faxPhoneNumber='9377699287';
        	organizationCustomer.tddPhoneNumber='9377699287';
        	organizationCustomer.industry = 'Other';
        	organizationCustomer.revenueAmount = '50000';
        	
        	mailingAddress.addressType ='US';
        	mailingAddress.street1 = 'teststreet1';
        	mailingAddress.street2 = 'teststreet2';
        	mailingAddress.street3 = 'teststreet3';
        	mailingAddress.street4 = 'teststreet4';
        	mailingAddress.city = 'testcity';
           	mailingAddress.country = 'UNITED STATES';
        	mailingAddress.postalCode = '50007';
        	mailingAddress.state = 'Illinois';
        	mailingAddress.addressStandardizationCode='04';
        	mailingAddress.preAddress = 'testpreaddress';
        	
        	residenceAddress.addressType ='US';
        	residenceAddress.street1 = 'teststreet1';
        	residenceAddress.street2 = 'teststreet2';
        	residenceAddress.street3 = 'teststreet3';
        	residenceAddress.street4 = 'teststreet4';
        	residenceAddress.city = 'testcity';
           	residenceAddress.country = 'UNITED STATES';
        	residenceAddress.postalCode = '50007';
        	residenceAddress.state = 'Illinois';
        	residenceAddress.addressStandardizationCode='04';
        	
        	List<AP_CustAggtRes.cls_preferences> preferenceList = new List<AP_CustAggtRes.cls_preferences>();
        	AP_CustAggtRes.cls_preferences serviceTextPref = new AP_CustAggtRes.cls_preferences();
        	serviceTextPref.preferenceType='serviceText';
            serviceTextPref.preferenceValue='Y';
            serviceTextPref.termsAndConditionsVersion='5.0';
            serviceTextPref.termsAndConditionsType='serviceTextTermsAndCondition';
            serviceTextPref.sourceId='9377699287';
            serviceTextPref.sourceType='phone';	
        	preferenceList.add(serviceTextPref);
        	AP_CustAggtRes.cls_preferences claimTextPref = new AP_CustAggtRes.cls_preferences();
        	claimTextPref.preferenceType='claimAlertText';
            claimTextPref.preferenceValue='N';
            claimTextPref.termsAndConditionsVersion='5.0';
            claimTextPref.termsAndConditionsType='claimTextTermsAndCondition';
            claimTextPref.sourceId='9377699287';
            claimTextPref.sourceType='phone';
        	preferenceList.add(claimTextPref);
        	AP_CustAggtRes.cls_preferences mktgEmailPref = new AP_CustAggtRes.cls_preferences();
        	mktgEmailPref.preferenceType='marketingEmail';
            mktgEmailPref.preferenceValue='N';
            mktgEmailPref.termsAndConditionsVersion='5.0';
            mktgEmailPref.sourceType='email';
        	preferenceList.add(mktgEmailPref);
        	AP_CustAggtRes.cls_preferences serviceEmailPref = new AP_CustAggtRes.cls_preferences();
        	serviceEmailPref.preferenceType='serviceEmail';
            serviceEmailPref.preferenceValue='Y';
            serviceEmailPref.sourceType='email';
        	preferenceList.add(serviceEmailPref);
        	AP_CustAggtRes.cls_preferences claimEmailPref = new AP_CustAggtRes.cls_preferences();
        	claimEmailPref.preferenceType='claimAlertEmail';
            claimEmailPref.preferenceValue='N';
            claimEmailPref.termsAndConditionsVersion='5.0';
            claimEmailPref.sourceType='email';
        	preferenceList.add(claimEmailPref);
        	AP_CustAggtRes.cls_preferences isProtectedPersonPref = new AP_CustAggtRes.cls_preferences();
        	isProtectedPersonPref.preferenceType ='isProtectedPerson';
        	isProtectedPersonPref.preferenceValue='N';
       		preferenceList.add(isProtectedPersonPref);
        	AP_CustAggtRes.cls_preferences isSubjectToCASLPref = new AP_CustAggtRes.cls_preferences();
        	isSubjectToCASLPref.preferenceType ='isSubjectToCASL';
        	isSubjectToCASLPref.preferenceValue='N';
       		preferenceList.add(isSubjectToCASLPref);
        	AP_CustAggtRes.cls_preferences paperlessPrivacyNoticeIndicatorPref = new AP_CustAggtRes.cls_preferences();
        	paperlessPrivacyNoticeIndicatorPref.preferenceType ='paperlessPrivacyNoticeIndicator';
        	paperlessPrivacyNoticeIndicatorPref.preferenceValue='N';
        	preferenceList.add(paperlessPrivacyNoticeIndicatorPref);
            AP_CustAggtRes.cls_preferences doNotMailIndicatorPref = new AP_CustAggtRes.cls_preferences();
        	doNotMailIndicatorPref.preferenceType ='doNotMailIndicator';
        	doNotMailIndicatorPref.preferenceValue='N';
        	preferenceList.add(doNotMailIndicatorPref);
        	AP_CustAggtRes.cls_preferences doNotCallIndicatorPref = new AP_CustAggtRes.cls_preferences();
        	doNotCallIndicatorPref.preferenceType ='doNotCallIndicator';
        	doNotCallIndicatorPref.preferenceValue='N';
        	preferenceList.add(doNotCallIndicatorPref);
        	AP_CustAggtRes.cls_preferences preferredSpokenLanguagePref = new AP_CustAggtRes.cls_preferences();
        	preferredSpokenLanguagePref.preferenceType ='preferredSpokenLanguage';
        	preferredSpokenLanguagePref.preferenceValue='English';
        	preferenceList.add(preferredSpokenLanguagePref);
      		AP_CustAggtRes.cls_preferences providedPrivacyOptionsPref = new AP_CustAggtRes.cls_preferences();
        	providedPrivacyOptionsPref.preferenceType ='providedPrivacyOptions';
        	providedPrivacyOptionsPref.preferenceValue='Y';
        	preferenceList.add(providedPrivacyOptionsPref);
        	AP_CustAggtRes.cls_preferences doNotShareIndicatorPref = new AP_CustAggtRes.cls_preferences();
        	doNotShareIndicatorPref.preferenceType ='doNotShareIndicator';
        	doNotShareIndicatorPref.preferenceValue='Y';
        	preferenceList.add(doNotShareIndicatorPref);
            AP_CustAggtRes.cls_preferences isBillingStatement = new AP_CustAggtRes.cls_preferences();
        	isBillingStatement.preferenceType ='billingPaperless';
        	isBillingStatement.preferenceValue='Y';
        	preferenceList.add(isBillingStatement);
        	AP_CustAggtRes.cls_preferences isAccPolicyNotification = new AP_CustAggtRes.cls_preferences();
        	isAccPolicyNotification.preferenceType ='accountPolicyNotification';
        	isAccPolicyNotification.preferenceValue='N';
        	preferenceList.add(isAccPolicyNotification);
        
        	custAggtRes.data=data;
        	attributes.organizationCustomer = organizationCustomer;
       	    attributes.residenceaddress = residenceaddress;
        	attributes.mailingAddress = mailingAddress;
        	attributes.residenceAddress = residenceAddress;
        	attributes.preferences= preferenceList;
        	custAggtRes.data.attributes = attributes;

        	User agentRunningUser = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678914');
            agentRunningUser = TestDataFactory_User.insertUser(agentRunningUser);  
            
            Account orgJsonRes;
			TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentRunningUser);

            System.runAs(agentRunningUser){
        		orgJsonRes = HLPR_CustAggtRes.buildCustomerFromAggtRes(acc, custAggtRes);
            }
            System.assert(orgJsonRes!=null, 'Org Json request is not null');
        	System.assertEquals('testorgname', orgJsonRes.LastName, 'Last Name: '+orgJsonRes.LastName);
        	System.assert(orgJsonRes.HasPermissionToServiceText__c.equalsIgnoreCase('Yes'), 'Permission to Service Text: '+orgJsonRes.HasPermissionToServiceText__c);
        	System.assertEquals(null,orgJsonRes.industry, 'Industry: '+orgJsonRes.industry);
        	System.assertEquals(null, orgJsonRes.AnnualRevenue, 'Annual revenue: '+orgJsonRes.AnnualRevenue);	
         Test.stopTest();
    }

	@isTest
    static void testGetIndCreateCustResNullCheck() {
      	Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('testLastName');
        acc.PersonBirthdate = System.today()-4;
        acc.MailingInCareOf__c= 'testCO';
        acc.BillingAddressType__c = 'US';
        acc.BillingStreet = 'testStreet';
        acc.BillingCity = 'testCity';
        acc.BillingState = 'IL';
        acc.BillingPostalCode = '55555';
        acc.BillingCountry = 'UNITED STATES';
        
        acc.ShippingAddressType__c = 'US';
        acc.ShippingCity = 'testCity';
        acc.ShippingStreet = 'testStreet';
        acc.ShippingCountry = 'UNITED STATES';
        acc.ShippingPostalCode = '55555';
		acc.ShippingCountry = 'UNITED STATES';
        
        acc.DriversLicenseNumber__c = 'A77765349';
        acc.DriversLicenseStateProvince__c = 'Virginia';
        
        acc.Gender__pc = 'Male';
        acc.SSN__pc = '901226789';
        acc.DeathDate__pc = System.today();
        acc.IsDeathNotificationReceived__pc = TRUE;
        acc.Citizenship__pc = 'Other';
        acc.EmployerName__pc = 'Enterprise';
        acc.OccupationCategory__pc = 'Athletics';
        acc.OccupationStatus__pc = 'Full Time';
        acc.Occupation__pc = 'Administrator';
        acc.OccupationStartDate__pc = System.today();
        acc.IsHearingImpaired__pc = true;
        acc.PreferredSpokenLanguage__pc = 'Spanish';
        
		Test.startTest();
        	system.debug(LoggingLevel.warn, acc);
			AP_CustAggtRes custAggtRes = new AP_CustAggtRes();
        	AP_CustAggtRes.cls_data data = new AP_CustAggtRes.cls_data();
        	AP_CustAggtRes.cls_attributes attributes = new AP_CustAggtRes.cls_attributes();
        
        	AP_CustAggtRes.cls_individualCustomer individualCustomer = new AP_CustAggtRes.cls_individualCustomer();
        	AP_CustAggtRes.cls_mailingAddress mailingAddress = new AP_CustAggtRes.cls_mailingAddress();
        	AP_CustAggtRes.cls_residenceAddress residenceAddress = new AP_CustAggtRes.cls_residenceAddress();
       		AP_CustAggtRes.cls_individualName individualName = new AP_CustAggtRes.cls_individualName();
        	AP_CustAggtRes.cls_driversLicense driversLicense = new AP_CustAggtRes.cls_driversLicense();
        	
            data.clientId = 'SDRAVA1231A';
        	data.type='Individual';
        	attributes.emailAddress= 'sdfsdf@noemail.com';
        	attributes.doesNotHaveEmail = 'True';
         	attributes.customerType = 'Individual';
        	individualCustomer.dateOfBirth = '1969-09-10';
        	individualCustomer.dateOfDeath = '1990-09-10';
        	individualCustomer.deathNotificationReceived = 'true';
      		individualCustomer.citizenship='USA';
        	individualCustomer.gender='male';
        	individualCustomer.hearingImpaired = 'true';
        	individualCustomer.maritalStatus = 'Single';
        	individualCustomer.taxIdentificationNumber = '320515059';
        	individualCustomer.preferredFirstName= 'ddddd';
        	individualCustomer.mobilePhoneNumber = '4055550188';																
			individualCustomer.workPhoneNumber = '4055550188';
        	individualCustomer.workPhoneExtension = '0';
        	individualCustomer.homePhoneNumber = '4055550188';
        	individualCustomer.tddPhoneNumber = '4055550188';
        	individualCustomer.employerName ='testemployer';
        	individualCustomer.occupation = 'Clergy';
        	individualCustomer.occupationStartDate = '1700-01-01';
        	individualCustomer.occupationStatus = 'Retired';
        	individualCustomer.jobTitle ='Minister';
        	
        	individualName.prefix ='Brother';
        	individualName.firstName ='testfirstname';
        	individualName.middleName = 'testmiddlename';
       		individualName.lastName = 'testlastname';
			individualName.suffix ='JR';
        	individualName.designation = 'LPN';
        	
        	driversLicense = null;
       		
        	mailingAddress.addressType ='US';
        	mailingAddress.street1 = 'testStreet1';
        	mailingAddress.street2 = 'testStreet2';
        	mailingAddress.street3 = 'testStreet3';
        	mailingAddress.street4 = 'testStreet4';
        	mailingAddress.city = 'testCity';
           	mailingAddress.country = 'UNITED STATES';
        	mailingAddress.postalCode = '50007';
        	mailingAddress.state = 'Illinois';
        	mailingAddress.addressStandardizationCode='04';
        	mailingAddress.preAddress = 'testpreaddress';
        	
        	residenceAddress = null;
        	
        	List<AP_CustAggtRes.cls_preferences> preferenceList = new List<AP_CustAggtRes.cls_preferences>();
        	AP_CustAggtRes.cls_preferences serviceTextPref = new AP_CustAggtRes.cls_preferences();
        	serviceTextPref.preferenceType='serviceText';
            serviceTextPref.preferenceValue='Y';
            serviceTextPref.termsAndConditionsVersion='5.0';
            serviceTextPref.termsAndConditionsType='serviceTextTermsAndCondition';
            serviceTextPref.sourceId='9377699287';
            serviceTextPref.sourceType='phone';	
        	preferenceList.add(serviceTextPref);
        	AP_CustAggtRes.cls_preferences claimTextPref = new AP_CustAggtRes.cls_preferences();
        	claimTextPref.preferenceType='claimAlertText';
            claimTextPref.preferenceValue='N';
            claimTextPref.termsAndConditionsVersion='5.0';
            claimTextPref.termsAndConditionsType='claimTextTermsAndCondition';
            claimTextPref.sourceId='9377699287';
            claimTextPref.sourceType='phone';
        	preferenceList.add(claimTextPref);
        	AP_CustAggtRes.cls_preferences mktgEmailPref = new AP_CustAggtRes.cls_preferences();
        	mktgEmailPref.preferenceType='marketingEmail';
            mktgEmailPref.preferenceValue='N';
            mktgEmailPref.termsAndConditionsVersion='5.0';
            mktgEmailPref.sourceType='email';
        	preferenceList.add(mktgEmailPref);
        	AP_CustAggtRes.cls_preferences serviceEmailPref = new AP_CustAggtRes.cls_preferences();
        	serviceEmailPref.preferenceType='serviceEmail';
            serviceEmailPref.preferenceValue='Y';
            serviceEmailPref.sourceType='email';
        	preferenceList.add(serviceEmailPref);
        	AP_CustAggtRes.cls_preferences claimEmailPref = new AP_CustAggtRes.cls_preferences();
        	claimEmailPref.preferenceType='claimAlertEmail';
            claimEmailPref.preferenceValue='N';
            claimEmailPref.termsAndConditionsVersion='5.0';
            claimEmailPref.sourceType='email';
        	preferenceList.add(claimEmailPref);
        	AP_CustAggtRes.cls_preferences isProtectedPersonPref = new AP_CustAggtRes.cls_preferences();
        	isProtectedPersonPref.preferenceType ='isProtectedPerson';
        	isProtectedPersonPref.preferenceValue='N';
       		preferenceList.add(isProtectedPersonPref);
        	AP_CustAggtRes.cls_preferences isSubjectToCASLPref = new AP_CustAggtRes.cls_preferences();
        	isSubjectToCASLPref.preferenceType ='isSubjectToCASL';
        	isSubjectToCASLPref.preferenceValue='N';
       		preferenceList.add(isSubjectToCASLPref);
        	AP_CustAggtRes.cls_preferences paperlessPrivacyNoticeIndicatorPref = new AP_CustAggtRes.cls_preferences();
        	paperlessPrivacyNoticeIndicatorPref.preferenceType ='paperlessPrivacyNoticeIndicator';
        	paperlessPrivacyNoticeIndicatorPref.preferenceValue='N';
        	preferenceList.add(paperlessPrivacyNoticeIndicatorPref);
            AP_CustAggtRes.cls_preferences doNotMailIndicatorPref = new AP_CustAggtRes.cls_preferences();
        	doNotMailIndicatorPref.preferenceType ='doNotMailIndicator';
        	doNotMailIndicatorPref.preferenceValue='N';
        	preferenceList.add(doNotMailIndicatorPref);
        	AP_CustAggtRes.cls_preferences doNotCallIndicatorPref = new AP_CustAggtRes.cls_preferences();
        	doNotCallIndicatorPref.preferenceType ='doNotCallIndicator';
        	doNotCallIndicatorPref.preferenceValue='N';
        	preferenceList.add(doNotCallIndicatorPref);
        	AP_CustAggtRes.cls_preferences preferredSpokenLanguagePref = new AP_CustAggtRes.cls_preferences();
        	preferredSpokenLanguagePref.preferenceType ='preferredSpokenLanguage';
        	preferredSpokenLanguagePref.preferenceValue='English';
        	preferenceList.add(preferredSpokenLanguagePref);
      		AP_CustAggtRes.cls_preferences providedPrivacyOptionsPref = new AP_CustAggtRes.cls_preferences();
        	providedPrivacyOptionsPref.preferenceType ='providedPrivacyOptions';
        	providedPrivacyOptionsPref.preferenceValue='Y';
        	preferenceList.add(providedPrivacyOptionsPref);
        	AP_CustAggtRes.cls_preferences doNotShareIndicatorPref = new AP_CustAggtRes.cls_preferences();
        	doNotShareIndicatorPref.preferenceType ='doNotShareIndicator';
        	doNotShareIndicatorPref.preferenceValue='Y';
        	preferenceList.add(doNotShareIndicatorPref);
        	AP_CustAggtRes.cls_preferences isBillingStatement = new AP_CustAggtRes.cls_preferences();
        	isBillingStatement.preferenceType ='billingPaperless';
        	isBillingStatement.preferenceValue='N';
        	preferenceList.add(isBillingStatement);
        	AP_CustAggtRes.cls_preferences isAccPolicyNotification = new AP_CustAggtRes.cls_preferences();
        	isAccPolicyNotification.preferenceType ='accountPolicyNotification';
        	isAccPolicyNotification.preferenceValue='N';
        	preferenceList.add(isAccPolicyNotification);
			AP_CustAggtRes.cls_preferences isPolicyAlertText = new AP_CustAggtRes.cls_preferences();
        	isAccPolicyNotification.preferenceType ='policyAlertText';
        	isAccPolicyNotification.preferenceValue='N';
        	preferenceList.add(isPolicyAlertText);
                       
        	custAggtRes.data=data;
        	attributes.individualCustomer = individualCustomer;
       	    attributes.residenceaddress = residenceaddress;
        	attributes.mailingAddress = mailingAddress;
        	attributes.residenceAddress = residenceAddress;
        	attributes.individualCustomer.individualName = individualName;
        	attributes.individualCustomer.driversLicense = driversLicense;
        	attributes.preferences= preferenceList;
        	custAggtRes.data.attributes = attributes;
        
        	AP_CustAggtRes.cls_relationShips relationships = new AP_CustAggtRes.cls_relationShips();
        	AP_CustAggtRes.cls_agentRole agentRole = new AP_CustAggtRes.cls_agentRole();
            AP_CustAggtRes.cls_agentRoleData agentRoleData1 = new AP_CustAggtRes.cls_agentRoleData();
        	AP_CustAggtRes.cls_agentRoleData agentRoleData2 = new AP_CustAggtRes.cls_agentRoleData();
        	AP_CustAggtRes.cls_agentRoleData agentRoleData3 = new AP_CustAggtRes.cls_agentRoleData();
            AP_CustAggtRes.cls_agentRoleAttributes agentRoleAttributes1 = new AP_CustAggtRes.cls_agentRoleAttributes();
        	AP_CustAggtRes.cls_agentRoleAttributes agentRoleAttributes2 = new AP_CustAggtRes.cls_agentRoleAttributes();
        	AP_CustAggtRes.cls_agentRoleAttributes agentRoleAttributes3 = new AP_CustAggtRes.cls_agentRoleAttributes();
        
        	agentRoleAttributes1.relationshipNature = 'Ex-Client';
        	agentRoleAttributes1.relationshipStartDate = Date.today()-300;
        	agentRoleData1.id = 'TSTAGENT100';
        	agentRoleData1.type = 'ASSOCIATE';
        	agentRoleData1.attributes = agentRoleAttributes1;
        	
        	agentRoleAttributes2.relationshipNature = 'Client';
        	agentRoleAttributes2.relationshipStartDate = Date.today()-200;
        	agentRoleData2.id = 'TSTAGENT200';
        	agentRoleData2.type = 'ASSOCIATE';
        	agentRoleData2.attributes = agentRoleAttributes2;        
        
        	agentRoleAttributes3.relationshipNature = 'Prospect';
        	agentRoleAttributes3.relationshipStartDate = Date.today()-100;
        	agentRoleData3.id = 'TSTAGENT300';
        	agentRoleData3.type = 'ASSOCIATE';
        	agentRoleData3.attributes = agentRoleAttributes3;
        
        	agentRole.data = new AP_CustAggtRes.cls_agentRoleData[]{agentRoleData1, agentRoleData2, agentRoleData3};
        	relationships.agents = agentRole;
        	custAggtRes.data.relationShips = relationships;

        	User agentRunningUser = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678914');
            agentRunningUser = TestDataFactory_User.insertUser(agentRunningUser);  
            
            Account indJsonRes;
			TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentRunningUser);

            System.runAs(agentRunningUser){
        		indJsonRes = HLPR_CustAggtRes.buildCustomerFromAggtRes(acc, custAggtRes);
            }
        	//System.debug(LoggingLevel.warn, indJsonRes);
            System.assert(indJsonRes!=null, 'Ind Json response is not null');
        	System.assertEquals('testfirstname', indJsonRes.FirstName, 'First Name: '+indJsonRes.FirstName);
        	System.assertEquals('testlastname', indJsonRes.LastName, 'Last Name: '+indJsonRes.LastName);
        	//System.assert(indJsonRes.HasPermissionToServiceText__c.equalsIgnoreCase('Yes'), 'Permission to Service Text: '+indJsonRes.HasPermissionToServiceText__c);
        	System.assertEquals(null, indJsonRes.OccupationStartDate__pc, 'Occupation Start Date: '+indJsonRes.OccupationStartDate__pc);
        	System.assertEquals('0', indJsonRes.WorkPhoneExtension__c, 'Work Phone Extension: '+indJsonRes.WorkPhoneExtension__c);
        	//System.assertEquals(null, indJsonRes.DriversLicenseNumber__c, 'Driver License Number: '+indJsonRes.DriversLicenseNumber__c);
        	//System.assertEquals(null, indJsonRes.DriversLicenseStateProvince__c, 'Drivers License State Province: '+indJsonRes.DriversLicenseStateProvince__c);
        	//System.assertEquals(null, indJsonRes.ShippingCity, 'Shipping City: '+indJsonRes.ShippingCity);
        	
        	String selectedReason = 'Customer requested quote';
        	Boolean isUpdateAfterSearch = true;
        	String agentAssociateId = 'TSTAGENT300';

			HLPR_CustAggtRes.HLPR_CustAggtResWrapper hlprWrap = new HLPR_CustAggtRes.HLPR_CustAggtResWrapper();
			hlprWrap.custAggtRes = custAggtRes;
			hlprWrap.selectedReason = selectedReason;
			hlprWrap.isUpdateAfterSearch = isUpdateAfterSearch;
			hlprWrap.agentAssociateId = agentAssociateId;

        	List<AgentRole__c> agentRoles = HLPR_CustAggtRes.buildAgentRolesFromAggtRes(hlprWrap);
			assertGetIndCreateCustResNullCheck(agentRoles);
        	
         Test.stopTest();
    }

	private static void assertGetIndCreateCustResNullCheck(List<AgentRole__c> agentRoles){
		System.assert(agentRoles!=null, 'Agent Roles is not null');
		System.assertEquals(3, agentRoles.size(), 'Agent Roles: '+agentRoles.size());
		System.assert(agentRoles.get(1).RelationshipNature__c.equalsIgnoreCase('Customer'), 'Relationship with Agent is Customer');
		System.assert(agentRoles.get(0).RelationshipNature__c.equalsIgnoreCase('Ex-Customer'), 'Relationship with Agent is Ex-Customer');
		System.assert(agentRoles.get(2).RelationshipNature__c.equalsIgnoreCase('Prospect'), 'Relationship with Agent is Prospect');
		System.assert(agentRoles.get(2).RelationshipReason__c.equalsIgnoreCase('Customer requested quote'), 'Reason is Customer requested quote ');
	}
}