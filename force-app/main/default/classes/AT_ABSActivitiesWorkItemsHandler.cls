public with sharing class AT_ABSActivitiesWorkItemsHandler {
    private static final String CLASS_NAME = 'AT_ABSActivitiesController';
    private static final String DEV_READONLY_PROFILE_NAME = 'Developer Read Only';
    private static final String ACCOUNT_OBJECT_PREFIX = '001';

    public static final String CL_TRY_LATER = 'An unexpected error has occurred. Please contact your normal support channels for assistance.';
    public static final String CL_NO_RECORDS = 'No records to display';
    
    @TestVisible private static List<WorkItems__x> mockedTempWorkItemList = new List<WorkItems__x>();

    @AuraEnabled
    public static String fetchWorkItems(String activityId, String statusFilter, String ownerAssociateId) {
        List<WorkItems__x> oDataWorkItemList = null;
        String workItemMessage = '';
        try {
            oDataWorkItemList = getWorkItemsList(activityId, statusFilter, ownerAssociateId);

            if(!oDataWorkItemList.isEmpty()) {
                Boolean isValidResponseActivity = isValidWorkItemsList(oDataWorkItemList);
                if(isValidResponseActivity){
                    workItemMessage = formatWorkItemMessage(oDataWorkItemList);
                } else {
                    workItemMessage = CL_NO_RECORDS;
                }
            } else {
                workItemMessage = CL_NO_RECORDS;
            }
        } catch(Exception dataSourceExp) {
            workItemMessage = CL_TRY_LATER;
            LoggingService.logHandledException(dataSourceExp, CLASS_NAME, 'fetchWorkItems', System.LoggingLevel.ERROR);
        }
        return workItemMessage;
    }

    @AuraEnabled
    public static List<WorkItems__x> getWorkItemsList(String activityId, String statusFilter, String ownerAssociateId){
        List<WorkItems__x> oDataWorkItemList = null;
        String loggedInAlias = UTIL_CurrentUser.retrieveCurrentUser().Alias;

        if (Test.isRunningTest()) {
            oDataWorkItemList = mockedTempWorkItemList;
            if ('error'.equals(activityId)) {
                throw new DMLException('error');
            }
        } else {
            oDataWorkItemList = Security.stripInaccessible(
                AccessType.READABLE,
                [SELECT WorkItemLink__c FROM WorkItems__x
                    WHERE ActivityID__c = :activityId
                    AND StatusFilter__c = :statusFilter
                    AND AssociateId__c = :ownerAssociateId
                    LIMIT 200
                ]).getRecords();
        }
        return oDataWorkItemList;
    }
    
    private static Boolean isValidWorkItemsList(List<WorkItems__x> oDataWorkItemList){
        Boolean isValidResponseActivity = true;
        if(oDataWorkItemList.size()==1 
            && (String.isEmpty(oDataWorkItemList[0].WorkItemLink__c) 
                || oDataWorkItemList[0].WorkItemLink__c .equalsIgnoreCase('null'))) {
            isValidResponseActivity = false;
        }
        return isValidResponseActivity;
    }

    private static String formatWorkItemMessage(List<WorkItems__x> oDataWorkItemList){
        String workItemMessage = '';

        for(WorkItems__x selectWorkItem : oDataWorkItemList) {
            List<String> lines = selectWorkItem.WorkItemLink__c .split('\\n');
            for (String line : lines) {
                workItemMessage += line + '<br/>';
            }
        }
        return workItemMessage;
    }
}
