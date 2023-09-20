//Description :Method created by Smart CRM team to capture the Mtrics for the click made in the Insight Component
//Author : Tamil Lakshmi and Suraj
/**
 * @description This class will process the InsightMetricsHandler
 */
public with sharing class InsightMetricsHandler {

    private InsightMetricsHandler(){
        AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.info('InsightMetricsHandler', 'start time of execution: ' + System.now());
        logHolder.writeToLogExceptionObject();
    }

    /**
     * @description This method will process the recordClicks
     * @param clickLabel
     * @param indicatorLabel
     */
    public static void recordClicks(String clickLabel,String indicatorLabel){
        try{
            Insight_Metrics__c insightMetricRecord = new Insight_Metrics__c();
            if(indicatorLabel.contains('-') && !indicatorLabel.contains('ABS'))
            {
                insightMetricRecord.Description__c = clickLabel;
            }
            else
            {
                insightMetricRecord.Description__c = indicatorLabel + '-' + clickLabel;
            }
            User currentUser = UTIL_CurrentUser.queryCurrentUser();
            insightMetricRecord.User_Type__c = currentUser.UserType__c;
            insightMetricRecord.Sub_User_Type__c = currentUser.SubUserType__c;
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.CREATABLE,new List<Insight_Metrics__c>{insightMetricRecord});
            Database.insert(securityDecision.getRecords());
        }
        catch(Exception exp){
            LoggingService.logHandledException(exp, 'InsightMetricsHandler', 'recordClicks', System.LoggingLevel.ERROR);
        }
    }
}