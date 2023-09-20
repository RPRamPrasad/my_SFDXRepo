/**
* Author : Team Astro
* Date Created : 08/3/2022
* @description : A metrics controller that contains methods used to log events into Kibana
* Version : 1.0
*/
public virtual with sharing class HHNMetricsController {

    @TestVisible private static Boolean isCatch = false;

    /**
     * @description - Logs when a component loaded onto the page
     * @return boolean
     */
    @AuraEnabled(cacheable=false)
    public static Boolean logComponentLoaded() {
        return returnTrue();
    }

    /**
     * @description - Logs when the Edit option in the menu dropdown is clicked
     * @return boolean
     */
    @AuraEnabled(cacheable=false)
    public static Boolean logClickEditMenuDropdown() {
        return returnTrue();
    }

    /**
     * @description - Logs when the Create New button in JOT is clicked
     * @return boolean
     */
    @AuraEnabled(cacheable=false)
    public static Boolean logClickJOTCreateNew() {
        return returnTrue();
    }

    /**
     * @description - Logs when the Jump to HH button is clicked
     * @return boolean
     */
    @AuraEnabled(cacheable=false)
    public static Boolean logClickJumpToHousehold() {
        return returnTrue();
    }

    /**
     * @description - Logs when the Load History is clicked.
     * @return boolean
     */
    @AuraEnabled(cacheable=false)
    public static Boolean logClickLoadHistory() {
        return returnTrue();
    }

    /**
     * @description - Logs when the Log To Task convert is clicked.
     * @return boolean
     */
    @AuraEnabled(cacheable=false)
    public static Boolean logClickLogToTaskMenuDropdown() {
        return returnTrue();
    }

    /**
     * @description - Logs when the Preference Gear is clicked.
     * @return boolean
     */
    @AuraEnabled(cacheable=false)
    public static Boolean logClickPreferenceGear() {
        return returnTrue();
    }

    /**
     * @description - Logs when the Preference Save button is clicked.
     * @return boolean
     */
    @AuraEnabled(cacheable=false)
    public static Boolean logClickPreferenceSave() {
        return returnTrue();
    }

    /**
     * @description - Logs when the Quick close task checkbox is clicked.
     * @return boolean
     */
    @AuraEnabled(cacheable=false)
    public static Boolean logClickQuickCloseTask() {
        return returnTrue();
    }

    /**
     * @description - Logs when the Refresh button is clicked.
     * @return boolean
     */
    @AuraEnabled(cacheable=false)
    public static Boolean logClickRefresh() {
        return returnTrue();
    }

    /**
     * @description - Logs when the Search input is clicked.
     * @return boolean
     */
    @AuraEnabled(cacheable=false)
    public static Boolean logClickSearchInput() {
        return returnTrue();
    }

    /**
     * @description - Logs when the Section Item Subject is clicked.
     * @return boolean
     */
    @AuraEnabled(cacheable=false)
    public static Boolean logClickSectionItemSubject() {
        return returnTrue();
    }

    /**
     * @description - Logs when the Section Item Task Subject is clicked.
     * @return boolean
     */
    @AuraEnabled(cacheable=false)
    public static Boolean logClickTaskSubject() {
        return returnTrue();
    }

    /**
     * @description - Logs when the Section Item Log Subject is clicked.
     * @return boolean
     */
    @AuraEnabled(cacheable=false)
    public static Boolean logClickLogSubject() {
        return returnTrue();
    }

    /**
     * @description - Logs when the Section Item Event Subject is clicked.
     * @return boolean
     */
    @AuraEnabled(cacheable=false)
    public static Boolean logClickEventSubject() {
        return returnTrue();
    }

    /**
     * @description - Logs when the Section Item Billing Subject is clicked.
     * @return boolean
     */
    @AuraEnabled(cacheable=false)
    public static Boolean logClickBillingSubject() {
        return returnTrue();
    }

    /**
     * @description - Logs when the Section Item Account Subject is clicked.
     * @return boolean
     */
    @AuraEnabled(cacheable=false)
    public static Boolean logClickAccountSubject() {
        return returnTrue();
    }

    /**
     * @description - Logs when the Section Item Case Subject is clicked.
     * @return boolean
     */
    @AuraEnabled(cacheable=false)
    public static Boolean logClickCaseSubject() {
        return returnTrue();
    }

    /**
     * @description - Logs when the Section Item Event Subject is clicked.
     * @return boolean
     */
    @AuraEnabled(cacheable=false)
    public static Boolean logClickClaimSubject() {
        return returnTrue();
    }

    /**
     * @description - Logs when the Section Item Opportunity Subject is clicked.
     * @return boolean
     */
    @AuraEnabled(cacheable=false)
    public static Boolean logClickOpportunitySubject() {
        return returnTrue();
    }

    /**
     * @description - Logs when the Section Item Insurance Policy Subject is clicked.
     * @return boolean
     */
    @AuraEnabled(cacheable=false)
    public static Boolean logClickInsurancePolicySubject() {
        return returnTrue();
    }

    /**
     * @description - Logs when the Todo View button is clicked.
     * @return boolean
     */
    @AuraEnabled(cacheable=false)
    public static Boolean logClickTodoView() {
        return returnTrue();
    }

    private static Boolean returnTrue() {
        try {
            if (isCatch) {
                throw new AuraHandledException('Failed to return true');
            }
            return true;
        } catch (Exception e) {
            return false;
        }
    }

}