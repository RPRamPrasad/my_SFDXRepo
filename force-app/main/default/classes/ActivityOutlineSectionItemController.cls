/**
 * @description controller that is used to act on activity outline section items
 */
public with sharing class ActivityOutlineSectionItemController {
    @TestVisible private static final String ERROR_TASK_NO_ACCESS_TO_THIS_ACTION = 'You do not have access to complete this action';
    @TestVisible private static boolean mockIsOwnerProxy = false;
    @TestVisible private static boolean mockModifyAllAccess = false;
    @TestVisible private static boolean mockOutcomeAccess = false;
    @TestVisible private static List<UserPermissionAccess> mockUserPermList = new List<UserPermissionAccess>();
    
    /** 
     * @description returns a value that indicates if the user can mark completed 
     * @param taskRecord 
     * @return boolean
     */
    @AuraEnabled(cacheable=true)
    public static boolean userCanMarkCompleteWithOutcome(ActivityOutlineSObjectWrapper taskRecord){
        try {
            Task singleTask = taskSearch(taskRecord);
            boolean userCanAccessAddOutcome = userCanAddOutcome(singleTask);
            if(Test.isRunningTest() && UnitTestDataUtility.isUnitTest){
                userCanAccessAddOutcome = mockOutcomeAccess;
            }
            return userCanAccessAddOutcome;
        } catch (Exception e) {
            throw new AuraHandledException('User access check failed for mark complete with outcome');
        }
    }
    
    /** 
     * @description returns a value that indicates if the user can edit
     * @param taskRecord
     * @return boolean
     */
    @AuraEnabled(cacheable=true)
    public static boolean userCanEdit(ActivityOutlineSObjectWrapper taskRecord){
        try {
            Task singleTask = taskSearch(taskRecord);
            boolean userCanEdit = taskIsEditableByLoggedInUser(singleTask);
            if(Test.isRunningTest() && UnitTestDataUtility.isUnitTest){
                userCanEdit = mockOutcomeAccess;
            }
            return userCanEdit;
        } catch (Exception e) {
            throw new AuraHandledException('User edit access check failed');
        }
    }
    
    /** 
     * @description returns access error message
     * @return String
     */
    @AuraEnabled(cacheable=true)
    public static String getAccessErrorMessage(){
        try {
            return ERROR_TASK_NO_ACCESS_TO_THIS_ACTION;
        } catch (Exception e) {
            throw new AuraHandledException('Proper access error failed');
        }
    }
    
    @TestVisible
    private static Task taskSearch(ActivityOutlineSObjectWrapper taskRecord){
        Task singleTask;
        List<Task> taskQuery = security.stripInaccessible(AccessType.READABLE,
            					[SELECT Id, IsClosed, IsRecurrence, IsOwnerProxyofCurrentUser__c, Outcome_Added__c
                                 FROM Task
                                 WHERE Id=:taskRecord.sobjectRecordId WITH SECURITY_ENFORCED
                                 LIMIT 1]).getRecords();
        if(!taskQuery.isEmpty()){
           singleTask = taskQuery[0];
        }
        return singleTask;
    } 
    
    @TestVisible
    private static boolean userCanAddOutcome(Task singleTask){
        return (taskIsEditableByLoggedInUser(singleTask) && taskIsNotRecurringOrClosed(singleTask));
    }

    @TestVisible
    private static boolean taskIsEditableByLoggedInUser(Task singleTask){
        boolean userHasModifyAllAccess = userHasModifyAllAccess();
        boolean taskOwnerIsTheUsersProxy;
        if(Test.isRunningTest() && UnitTestDataUtility.isUnitTest){
            taskOwnerIsTheUsersProxy = mockIsOwnerProxy;
            userHasModifyAllAccess = mockModifyAllAccess;
        }else{
            taskOwnerIsTheUsersProxy = singleTask.IsOwnerProxyofCurrentUser__c;
        }
        return (taskOwnerIsTheUsersProxy || userHasModifyAllAccess);
    }
    
    @TestVisible
    private static boolean taskIsNotRecurringOrClosed(Task singleTask){
        return (!singleTask.IsRecurrence && !singleTask.IsClosed && !singleTask.Outcome_Added__c);
    }
    
    @TestVisible
    private static boolean userHasModifyAllAccess(){ 
        List<UserPermissionAccess> permissionList =
            security.stripInaccessible(AccessType.READABLE,
                                      [SELECT PermissionsModifyAllData FROM UserPermissionAccess WITH SECURITY_ENFORCED LIMIT 1]).getRecords();
        if(Test.isRunningTest() && UnitTestDataUtility.isUnitTest){
            permissionList = mockUserPermList;
        }
        return permissionList.get(0).PermissionsModifyAllData;
    }

}