/** Account Name Fields*/
import FIRST_NAME_FIELD from '@salesforce/schema/Account.FirstName';
import MIDDLE_NAME_FIELD from '@salesforce/schema/Account.MiddleName';
import LAST_NAME_FIELD from '@salesforce/schema/Account.LastName';
import SUFFIX_FIELD from '@salesforce/schema/Account.Suffix';
import PREFERRED_FIRST_NAME_FIELD from '@salesforce/schema/Account.PreferredFirstName__c';
/**Account Individual Section Fields */
//import GENDER_FIELD from '@salesforce/schema/Account.Gender__pc';
import CONTACT_GENDER_FIELD from '@salesforce/schema/Account.PersonContact.Gender__c';
import PERSON_BIRTH_DATE_FIELD from '@salesforce/schema/Account.PersonBirthdate';
//import SSN_FIELD from '@salesforce/schema/Account.SSN__pc';
import CONTACT_SSN_FIELD from '@salesforce/schema/Account.PersonContact.SSN__c';
//import MARITAL_STATUS_FIELD from '@salesforce/schema/Account.MaritalStatus__pc';
import CONTACT_MARITAL_STATUS_FIELD from '@salesforce/schema/Account.PersonContact.MaritalStatus__c';
import DRIVERS_LICENSE_NUMBER_FIELD from '@salesforce/schema/Account.DriversLicenseNumber__c';
import DRIVERS_LICENSE_STATE_PROVINCE_FIELD from '@salesforce/schema/Account.DriversLicenseStateProvince__c';
import MAILING_IN_CARE_OF_FIELD from '@salesforce/schema/Account.MailingInCareOf__c';
/**Account Organization Section Fields */
import TIN_FIELD from '@salesforce/schema/Account.TIN__c';
import TIN_TYPE_FIELD from '@salesforce/schema/Account.TIN_Type__c';
import TYPE_FIELD from '@salesforce/schema/Account.Type';
import INDUSTRY_FIELD from '@salesforce/schema/Account.Industry';
import MAILING_ATTENTION_FIELD from '@salesforce/schema/Account.MailingAttention__c';
/**Account Address Fields */
import BILLING_ADDRESS_TYPE_FIELD from '@salesforce/schema/Account.BillingAddressType__c';
import BILLING_STREET_FIELD from '@salesforce/schema/Account.BillingStreet';
import BILLING_CITY_FIELD from '@salesforce/schema/Account.BillingCity';
import BILLING_STATE_FIELD from '@salesforce/schema/Account.BillingState';
import BILLING_POSTAL_CODE_FIELD from '@salesforce/schema/Account.BillingPostalCode';
import BILLING_COUNTRY_FIELD from '@salesforce/schema/Account.BillingCountry';
import SHIPPING_ADDRESS_TYPE_FIELD from '@salesforce/schema/Account.ShippingAddressType__c';
import SHIPPING_STREET_FIELD from '@salesforce/schema/Account.ShippingStreet';
import SHIPPING_CITY_FIELD from '@salesforce/schema/Account.ShippingCity';
import SHIPPING_STATE_FIELD from '@salesforce/schema/Account.ShippingState';
import SHIPPING_POSTAL_CODE_FIELD from '@salesforce/schema/Account.ShippingPostalCode';
import SHIPPING_COUNTRY_FIELD from '@salesforce/schema/Account.ShippingCountry';
/**Account  Contact Information Fields*/
import CONTACT_EMAIL_FIELD from '@salesforce/schema/Account.PersonContact.Email';
import HAS_CONFIRMED_NO_EMAIL_FIELD from '@salesforce/schema/Account.HasConfirmedNoEmail__c';
import CONTACT_HOME_PHONE_FIELD from '@salesforce/schema/Account.PersonContact.HomePhone';
import CONTACT_MOBILE_PHONE_FIELD from '@salesforce/schema/Account.PersonContact.MobilePhone';
import CONTACT_PHONE_FIELD from '@salesforce/schema/Account.PersonContact.Phone';
import WORK_PHONE_EXTENSION_FIELD from '@salesforce/schema/Account.WorkPhoneExtension__c';
import TDD_PHONE_FIELD from '@salesforce/schema/Account.TDDPhone__c';
import FAX_FIELD from '@salesforce/schema/Account.Fax';
/**Account Personal Information Fields */
import SALUTAION_FIELD from '@salesforce/schema/Account.Salutation';
//import DESIGNATION_FIELD from '@salesforce/schema/Account.Designation__pc';
import CONTACT_DESIGNATION_FIELD from '@salesforce/schema/Account.PersonContact.Designation__c';
//import CITIZENSHIP_FIELD from '@salesforce/schema/Account.Citizenship__pc';
import CONTACT_CITIZENSHIP_FIELD from '@salesforce/schema/Account.PersonContact.Citizenship__c';
import LIVING_ARRANGEMENTS__FIELD from '@salesforce/schema/Account.LivingArrangements__c';
//import PREFERRED_SPOKEN_LANGUAGE_FIELD from '@salesforce/schema/Account.PreferredSpokenLanguage__pc';
import CONTACT_PREFERRED_SPOKEN_LANGUAGE_FIELD from '@salesforce/schema/Account.PersonContact.PreferredSpokenLanguage__c';
//import IS_HEARING_IMPAIRED_FIELD from '@salesforce/schema/Account.IsHearingImpaired__pc';
import CONTACT_IS_HEARING_IMPAIRED_FIELD from '@salesforce/schema/Account.PersonContact.IsHearingImpaired__c';
import BUSSINESS_OWNER_INDICATOR_FIELD from '@salesforce/schema/Account.BusinessOwnerIndicator__c';
//import DEATH_DATE_FIELD from '@salesforce/schema/Account.DeathDate__pc';
import CONTACT_DEATH_DATE_FIELD from '@salesforce/schema/Account.PersonContact.DeathDate__c';
//import IS_DEATH_NOTIFICATION_RECEIVED_FIELD from '@salesforce/schema/Account.IsDeathNotificationReceived__pc';
import CONTACT_IS_DEATH_NOTIFICATION_RECEIVED_FIELD from '@salesforce/schema/Account.PersonContact.IsDeathNotificationReceived__c';
/**Account Employement Information Fields */
//import OCCUPATION_CATEGORY_FIELD from '@salesforce/schema/Account.OccupationCategory__pc';
import CONTACT_OCCUPATION_CATEGORY_FIELD from '@salesforce/schema/Account.PersonContact.OccupationCategory__c';
//import EMPLOYER_NAME_FIELD from '@salesforce/schema/Account.EmployerName__pc';
import CONTACT_EMPLOYER_NAME_FIELD from '@salesforce/schema/Account.PersonContact.EmployerName__c';
//import OCCUPATION_STATUS_FIELD from '@salesforce/schema/Account.OccupationStatus__pc';
import CONTACT_OCCUPATION_STATUS_FIELD from '@salesforce/schema/Account.PersonContact.OccupationStatus__c';
//import OCCUPATION_START_DATE_FIELD from '@salesforce/schema/Account.OccupationStartDate__pc';
import CONTACT_OCCUPATION_START_DATE_FIELD from '@salesforce/schema/Account.PersonContact.OccupationStartDate__c';
//import OCCUPATION_FIELD from '@salesforce/schema/Account.Occupation__pc';
import CONTACT_OCCUPATION_FIELD from '@salesforce/schema/Account.PersonContact.Occupation__c';
/**Account Employer Information Fields */
import NO_OF_EMPLOYEED_FIELD from '@salesforce/schema/Account.NumberOfEmployees';
import ANNUAL_REVENUE_FIELD from '@salesforce/schema/Account.AnnualRevenue';
/**Account Preference Fields */
import HAS_PERMISSION_TO_SERVICE_EMAIL_FIELD from '@salesforce/schema/Account.HasPermissionToServiceEmail__c';
import HAS_PERMISSION_TO_SERVICE_TEXT_FIELD from '@salesforce/schema/Account.HasPermissionToServiceText__c';
import SFPP_BILLING_REMINDER_EMAIL_FIELD from '@salesforce/schema/Account.SFPPBillRemindersEmail__c';
import BILL_ALERT_TEXT_FIELD from '@salesforce/schema/Account.BillAlertText__c';
import HAS_PERMISSION_TO_CLAIM_EMAIL_FIELD from '@salesforce/schema/Account.HasPermissionToClaimEmail__c';
import HAS_PERMISSION_TO_CLAIM_TEXT_FIELD from '@salesforce/schema/Account.HasPermissionToClaimText__c';
import BILLING_STATEMENTS_FIELD from '@salesforce/schema/Account.Billing_Statements__c';
import POLICY_DOCUMENTS_FIELD from '@salesforce/schema/Account.PolicyDocuments__c';
import POLICY_NOTICES_EMAIL_FIELD from '@salesforce/schema/Account.Policy_Notices_Email__c';
import HAS_PERMISSION_TO_MARKETING_EMAIL_FIELD from '@salesforce/schema/Account.HasPermissionToMarketingEmail__c';
import CONTACT_IS_NOT_SHAREABLE_FIELD from '@salesforce/schema/Account.PersonContact.IsNotShareable__c';
import POLICY_NOTICES_TEXT_FIELD from '@salesforce/schema/Account.Policy_Notices_Text__c';
/**Account Additional Fields */
import IS_SUBJECT_TO_CASL_FIELD from '@salesforce/schema/Account.IsSubjecttoCASL__c';
import IS_PRIVACY_OPTION_SHARED_FIELD from '@salesforce/schema/Account.IsPrivacyOptionsShared__c';
import CLIENT_IDENTIFIER_FIELD from '@salesforce/schema/Account.ClientIdentifier__c';
import PERSON_CONTACT_ID_FIELD from '@salesforce/schema/Account.PersonContactId';
import IS_PROTECTED_PERSON from '@salesforce/schema/Account.IsProtectedPerson__c';
//import ISHEALTHSOURCED_FIELD from '@salesforce/schema/Account.IsHealthSourced__pc';
import CONTACT_ISHEALTHSOURCED_FIELD from '@salesforce/schema/Account.PersonContact.IsHealthSourced__c';
/**User Fields */
import USER_PROFILE_NAME from '@salesforce/schema/User.Profile.Name';
import USER_ASSOC_ID from '@salesforce/schema/User.Associate_ID__c';
import USER__TYPE from '@salesforce/schema/User.UserType__c';
import USER_SUB_TYPE from '@salesforce/schema/User.SubUserType__c';
import USER_SERVICING_AGENT_ASSOC_ID from '@salesforce/schema/User.Servicing_Agent_Associate_ID__c';
/**Account Custom Labels */
import agentProfile from '@salesforce/label/c.CL_Agent_Profile';
import atmProfile from '@salesforce/label/c.CL_ATM_Profile';
import techProfile from '@salesforce/label/c.CL_TechSupport_Profile';
import accountGenericErrorMessage from '@salesforce/label/c.CL_AccountGenericError';
import exceptionLabel from '@salesforce/label/c.CL_Exception_Message';
import tooManyCustomersLabel from '@salesforce/label/c.CL_Too_Many_Customer_Match';
import removeDLLabel from '@salesforce/label/c.CL_RemoveDL_Helptext';
import restoreDLLabel from '@salesforce/label/c.CL_RestoreDL_Helptext';
import removeSSNLabel from '@salesforce/label/c.CL_RemoveSSN_Helptext';
import restoreSSNLabel from '@salesforce/label/c.CL_RestoreSSN_Helptext';
import ssnPrivacyLabel from '@salesforce/label/c.CL_SSN_Privacy_Helptext';
import removeTINLabel from '@salesforce/label/c.CL_RemoveTIN_Helptext';
import restoreTINLabel from '@salesforce/label/c.CL_RestoreTIN_Helptext';
import tinPrivacyLabel from '@salesforce/label/c.CL_TIN_Privacy_Helptext';
import removeTINTypeLabel from '@salesforce/label/c.CL_RemoveTINType_HelpText';
import restoreTINTypeLabel from '@salesforce/label/c.CL_RestoreTINType_HelpText';
import tinTypePrivacyLabel from '@salesforce/label/c.CL_TINType_Privacy_Helptext';

export const ACCOUNT_FIELDS = [ 
    FIRST_NAME_FIELD, MIDDLE_NAME_FIELD, LAST_NAME_FIELD, SUFFIX_FIELD, PREFERRED_FIRST_NAME_FIELD,
    PERSON_BIRTH_DATE_FIELD, DRIVERS_LICENSE_NUMBER_FIELD, DRIVERS_LICENSE_STATE_PROVINCE_FIELD, MAILING_IN_CARE_OF_FIELD,
    TIN_FIELD, TIN_TYPE_FIELD, TYPE_FIELD, INDUSTRY_FIELD, MAILING_ATTENTION_FIELD,
    BILLING_ADDRESS_TYPE_FIELD, BILLING_STREET_FIELD, BILLING_CITY_FIELD, BILLING_STATE_FIELD, BILLING_POSTAL_CODE_FIELD, BILLING_COUNTRY_FIELD,
    SHIPPING_ADDRESS_TYPE_FIELD, SHIPPING_STREET_FIELD, SHIPPING_CITY_FIELD, SHIPPING_STATE_FIELD, SHIPPING_POSTAL_CODE_FIELD, SHIPPING_COUNTRY_FIELD,
    HAS_CONFIRMED_NO_EMAIL_FIELD, WORK_PHONE_EXTENSION_FIELD, TDD_PHONE_FIELD, FAX_FIELD,
    SALUTAION_FIELD, LIVING_ARRANGEMENTS__FIELD,
    BUSSINESS_OWNER_INDICATOR_FIELD,
    NO_OF_EMPLOYEED_FIELD, ANNUAL_REVENUE_FIELD,
    HAS_PERMISSION_TO_SERVICE_EMAIL_FIELD, HAS_PERMISSION_TO_SERVICE_TEXT_FIELD, SFPP_BILLING_REMINDER_EMAIL_FIELD, BILL_ALERT_TEXT_FIELD,
    HAS_PERMISSION_TO_CLAIM_EMAIL_FIELD, HAS_PERMISSION_TO_CLAIM_TEXT_FIELD, BILLING_STATEMENTS_FIELD, POLICY_DOCUMENTS_FIELD,
    POLICY_NOTICES_EMAIL_FIELD, HAS_PERMISSION_TO_MARKETING_EMAIL_FIELD, POLICY_NOTICES_TEXT_FIELD, 
    IS_SUBJECT_TO_CASL_FIELD, IS_PRIVACY_OPTION_SHARED_FIELD, CLIENT_IDENTIFIER_FIELD, IS_PROTECTED_PERSON,
    CONTACT_GENDER_FIELD, CONTACT_SSN_FIELD, CONTACT_MARITAL_STATUS_FIELD, 
    CONTACT_EMAIL_FIELD, CONTACT_HOME_PHONE_FIELD, CONTACT_MOBILE_PHONE_FIELD, CONTACT_PHONE_FIELD,
    CONTACT_DESIGNATION_FIELD, CONTACT_CITIZENSHIP_FIELD, CONTACT_PREFERRED_SPOKEN_LANGUAGE_FIELD,
    CONTACT_IS_HEARING_IMPAIRED_FIELD, CONTACT_DEATH_DATE_FIELD, CONTACT_IS_DEATH_NOTIFICATION_RECEIVED_FIELD,
    CONTACT_OCCUPATION_CATEGORY_FIELD, CONTACT_EMPLOYER_NAME_FIELD, CONTACT_OCCUPATION_STATUS_FIELD, CONTACT_OCCUPATION_START_DATE_FIELD, CONTACT_OCCUPATION_FIELD,
    CONTACT_IS_NOT_SHAREABLE_FIELD, PERSON_CONTACT_ID_FIELD, CONTACT_ISHEALTHSOURCED_FIELD
];

export const USER_FIELDS = [
    USER_PROFILE_NAME, USER_ASSOC_ID, USER__TYPE, USER_SUB_TYPE, USER_SERVICING_AGENT_ASSOC_ID
];

export const ACCOUNT_LABELS = {
    agentProfile, atmProfile, accountGenericErrorMessage, exceptionLabel, techProfile, tooManyCustomersLabel,
    removeDLLabel, restoreDLLabel, removeSSNLabel, restoreSSNLabel, ssnPrivacyLabel, tinPrivacyLabel,
    removeTINLabel, restoreTINLabel, removeTINTypeLabel, restoreTINTypeLabel, tinTypePrivacyLabel
};