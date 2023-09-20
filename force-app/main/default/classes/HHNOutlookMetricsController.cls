/**
* Author : Team Astro
* Date Created : 08/3/2022
* @description : A metrics controller that contains methods used to log events from Outlook into Kibana
* Version : 1.0
*/
public with sharing class HHNOutlookMetricsController extends HHNMetricsController {

    @TestVisible private static Boolean isCatch = false;
    
    /**
     * @description - Logs when the Log Email button is clicked
     * @return boolean
     */
    @AuraEnabled(cacheable=false)
    public static Boolean logClickLogEmail() {
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