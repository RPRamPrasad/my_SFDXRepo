public with sharing class AT_ABSActivitiesRemarksHandler{
    private static final String CLASS_NAME = 'AT_ABSActivitiesController';
    private static final String DEV_READONLY_PROFILE_NAME = 'Developer Read Only';
    //private static final String ACCOUNT_OBJECT_PREFIX = '001';

    public static final String CL_TRY_LATER = 'An unexpected error has occurred. Please contact your normal support channels for assistance.';
    public static final String CL_NO_RECORDS = 'No records to display';
     
    @TestVisible private static List<Remarks__x> mockedTempRemarkList = new List<Remarks__x>();

    @AuraEnabled
    public static String fetchRemark(String activityId) {
        //String loggedInAlias = UTIL_CurrentUser.retrieveCurrentUser().Alias;
        List<Remarks__x> oDataRemarksList = null;
        String remarksMessage = '';
        Boolean isValidResponseActivity = true;

        try {
            oDataRemarksList = getRemarksList(activityId);

            if(!oDataRemarksList.isEmpty()) {
                isValidResponseActivity = isValidRemarksList(oDataRemarksList);

                if(isValidResponseActivity) {
                    remarksMessage = formatRemarksMessage(oDataRemarksList);
                } else {
                    remarksMessage = CL_NO_RECORDS;
                }
            } else {
                remarksMessage = CL_NO_RECORDS;
            }
        } catch(Exception dataSourceExp) {
            remarksMessage = CL_TRY_LATER;
            LoggingService.logHandledException(dataSourceExp, CLASS_NAME, 'fetchRemark', System.LoggingLevel.ERROR);
        }
        return remarksMessage;
    }
    
    @AuraEnabled
    public static List<Remarks__x> getRemarksList(String activityId){
        List<Remarks__x> oDataRemarksList = null;
        String loggedInAlias = UTIL_CurrentUser.retrieveCurrentUser().Alias;

        if (Test.isRunningTest()) {
            oDataRemarksList = mockedTempRemarkList;
            if ('error'.equals(activityId)) {
                throw new DMLException('error'); //ask Amar why?
            }
        } else {
            oDataRemarksList = Security.stripInaccessible(
                AccessType.READABLE,
                [SELECT Remark__c, ActivityID__c FROM Remarks__x
                    WHERE ActivityID__c = :activityId
                    AND UserID__c = :loggedInAlias
                    LIMIT 200   //enforce security?
                ]).getRecords();
        }
        return oDataRemarksList;
    }
    
    private static Boolean isValidRemarksList(List<Remarks__x> oDataRemarksList){
        Boolean isValidResponseActivity = true;
            if(oDataRemarksList.size()==1 &&
                (String.isEmpty(oDataRemarksList[0].Remark__c) || oDataRemarksList[0].Remark__c.equalsIgnoreCase('null'))) {
                    isValidResponseActivity = false;
            }
            return isValidResponseActivity;
    }
  
    private static String formatRemarksMessage(List<Remarks__x> oDataRemarksList){
        String remarksMessage = '';

        for(Remarks__x selectRemark : oDataRemarksList) {
            List<String> lines = selectRemark.Remark__c.split('\\n');
            for (String line : lines) {
                remarksMessage += line + '<br/>';
            }
        }
        return remarksMessage;
    }
}
