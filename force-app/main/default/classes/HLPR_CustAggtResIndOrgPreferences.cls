/**
 * @aname HLPR_CustAggtResIndOrgPreferences
 * @description This is a helper class to build customer record with the values received from customer aggregator JSON response
 * @author Team Stark
 * @owner Team Stark
 * @createdDate 03/07/2021
 */
public with sharing class HLPR_CustAggtResIndOrgPreferences extends HLPR_CustAggtResPreference{
    
    private static final String PROTECTED_PERSON_PREF_TYPE = 'isProtectedPerson';
    private static final String SUBJ_CASL_PREF_TYPE = 'isSubjectToCASL';
    private static final String PAPERLESS_PRIVACY_PREF_TYPE = 'paperlessPrivacyNoticeIndicator';
    private static final String DO_NOT_MAIL_PREF_TYPE = 'doNotMailIndicator';
    private static final String DO_NOT_CALL_PREF_TYPE  = 'doNotCallIndicator';
    private static final String LANG_PREF_TYPE = 'preferredSpokenLanguage';
    private static final String SERVICE_TEXT_PREF_TYPE = 'serviceText';
    private static final String PPO_PREF_TYPE = 'providedPrivacyOptions';
    private static final String DO_NOT_SHARE_PREF_TYPE = 'doNotShareIndicator';
    private static final String CLAIM_TEXT_PREF_TYPE = 'claimAlertText';
    private static final String BILL_TEXT_PREF_TYPE = 'billText';
    private static final String MKTG_EMAIL_PREF_TYPE = 'marketingEmail';
    private static final String SERVICE_EMAIL_PREF_TYPE = 'serviceEmail';
    private static final String CLAIM_EMAIL_PREF_TYPE = 'claimAlertEmail';
    private static final String HEALTH_SOURCE_PREF_TYPE = 'Health Sourced';
    private static final String BILLING_STMT_PREF_TYPE = 'billingPaperless';
    private static final String POLICY_EMAIL_PREF_TYPE = 'accountPolicyNotification';
    private static final String POLICY_TEXT_PREF_TYPE = 'policyAlertText';
    private static final String POLICY_DOCS_PREF_TYPE = 'policyPaperless'; 
    private static final String BILL_ALERT_EMAIL = 'billAlertEmail';   
    
    /**
     * @name populatePreferences
     * @description Populate account preferences values received from customer aggregator response
     * @param customer
     * @param custAggtRes
     */
    public static void populatePreferences(Account customer, AP_CustAggtRes custAggtRes) {
        for(AP_CustAggtRes.cls_preferences pref : custAggtRes.data.attributes.preferences) {
            if(PROTECTED_PERSON_PREF_TYPE.equalsIgnoreCase(pref.preferenceType)) {
                populateProtectedPerson(customer, pref);    
            }
            else if(SUBJ_CASL_PREF_TYPE.equalsIgnoreCase(pref.preferenceType)) {
                populateSubjToCASL(customer, pref); 
            }
            else if(PAPERLESS_PRIVACY_PREF_TYPE.equalsIgnoreCase(pref.preferenceType)) {
                populatePaperlessPrivacy(customer, pref);   
            }
            else if(DO_NOT_MAIL_PREF_TYPE.equalsIgnoreCase(pref.preferenceType)) {
                populateDoNotMail(customer, pref);  
            }
            else if(DO_NOT_CALL_PREF_TYPE.equalsIgnoreCase(pref.preferenceType)) {
                populateDoNotCall(customer, pref);  
            }
            else {
                populatePreferencesI(customer, pref);
            }
        }
    }

    private static void populatePreferencesI(Account customer, AP_CustAggtRes.cls_preferences pref) {
        if(LANG_PREF_TYPE.equalsIgnoreCase(pref.preferenceType)) {
            populatePrefLang(customer, pref);   
        }
        else if(SERVICE_TEXT_PREF_TYPE.equalsIgnoreCase(pref.preferenceType)) {
            populateServiceText(customer, pref);    
        }
        else if(PPO_PREF_TYPE.equalsIgnoreCase(pref.preferenceType)) {
            populatePPO(customer, pref);    
        }
        else if(DO_NOT_SHARE_PREF_TYPE.equalsIgnoreCase(pref.preferenceType)) {
            populateDoNotShare(customer, pref); 
        }
        else {
            populatePreferencesII(customer, pref);
        }
    }

    private static void populatePreferencesII(Account customer, AP_CustAggtRes.cls_preferences pref) {
        if(CLAIM_TEXT_PREF_TYPE.equalsIgnoreCase(pref.preferenceType)) {
            populateClaimText(customer, pref);  
        }
        else if(MKTG_EMAIL_PREF_TYPE.equalsIgnoreCase(pref.preferenceType)) {
            populateMktgEmail(customer, pref);  
        }
        else if(SERVICE_EMAIL_PREF_TYPE.equalsIgnoreCase(pref.preferenceType)) {
            populateServiceEmail(customer, pref);   
        }
        else if(CLAIM_EMAIL_PREF_TYPE.equalsIgnoreCase(pref.preferenceType)) {
            populateClaimEmail(customer, pref); 
        }
        else if(HEALTH_SOURCE_PREF_TYPE.equalsIgnoreCase(pref.preferenceType)) {
            populateHealthSource(customer, pref);   
        }
        else {
            populatePreferencesIII(customer, pref);
        }
    }

    private static void populatePreferencesIII(Account customer, AP_CustAggtRes.cls_preferences pref) {
        if(BILLING_STMT_PREF_TYPE.equalsIgnoreCase(pref.preferenceType)) {
            populateBillingStatements(customer, pref);   
        }
        else if(POLICY_EMAIL_PREF_TYPE.equalsIgnoreCase(pref.preferenceType)) {
            populatPolicyNoticesEmail(customer, pref);   
        }
        else if(BILL_ALERT_EMAIL.equalsIgnoreCase(pref.preferenceType) && HLPR_CustAggtResIndOrg.toggleContext.isNotActive(UTIL_Toggles.ADDLBUSINESSDATAFIELDS)) {
            populateBillAlertEmail(customer, pref);
        }
        else if(POLICY_DOCS_PREF_TYPE.equalsIgnoreCase(pref.preferenceType)) {
            populatePolicyDocsEmail(customer, pref);   
        }
        else if(BILL_TEXT_PREF_TYPE.equalsIgnoreCase(pref.preferenceType)) {
            populateBillAlertText(customer, pref);   
        }
        else if(POLICY_TEXT_PREF_TYPE.equalsIgnoreCase(pref.preferenceType)) {
            populatePolicyNoticesText(customer, pref);
        }
    } 
    
}
