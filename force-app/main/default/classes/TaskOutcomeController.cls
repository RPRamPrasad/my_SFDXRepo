/** 
* @description LWC controller for Mark Task Complete with outcome 
* @Owner: BabyYoda
*/
public with sharing class TaskOutcomeController {

    @TestVisible private static final String ERROR_TASK_IS_ALREADY_CLOSED = 'This task is already closed';
    @TestVisible private static final String ERROR_TASK_IS_ALREADY_HAS_OUTCOME = 'This task already has an outcome';
    @TestVisible private static final String ERROR_TASK_IS_NOT_OWNED_BY_USERS_PROXY = 'This task is not owned by your office';
    @TestVisible private static final String ERROR_TASK_IS_A_RECURRING_PARENT = 'You cannot add an outcome to a recurring task';
    @TestVisible private static final String ERROR_TASK_UPDATE_FAILED = 'The update when adding an outcome failed';
    @TestVisible private static List<Task> mockTaskList = new List<Task>();
    @TestVisible private static boolean mockOutcomeAccess = false;
    @TestVisible private static boolean mockModifyAllAccess = false;
    @TestVisible private static boolean mockIsOwnerProxy = false;
    @TestVisible private static boolean mockIsClosed = false;
    @TestVisible private static boolean mockIsRecurrance = false;
    @TestVisible private static List<UserPermissionAccess> mockUserPermList = new List<UserPermissionAccess>();
        
    @TestVisible private static Task getTaskInfo(Id recordId){
		List<Task> taskList = Security.stripInaccessible(AccessType.READABLE, 
                                                         [SELECT Id, Description, IsOwnerProxyofCurrentUser__c, 
                                                          Outcome_Added__c, Status, isClosed, Subject, IsRecurrence 
                                                          FROM Task 
                                                          WHERE Id =: recordId 
                                                          LIMIT 1]).getRecords();  
        if(Test.isRunningTest() && UnitTestDataUtility.isUnitTest){
        	taskList = mockTaskList;
        } 
        return taskList.get(0);
    }

    /**
     * @name getTask
     * @description getTask
     * @param recordId
     * @return Task
     */
	@AuraEnabled(cacheable=true)
    public static Task getTask(Id recordId){
        Task taskRecord = getTaskInfo(recordId);
        return taskRecord;
    }
    
    /**
     * @name getOutcomeAccess
     * @description getOutcomeAccess
     * @param taskRecord
     * @return boolean
     */
    @AuraEnabled(cacheable=false)
    public static boolean getOutcomeAccess(Task taskRecord){
        boolean usersAccessToAddOutcome = userCanAddOutcome(taskRecord);
        if(Test.isRunningTest() && UnitTestDataUtility.isUnitTest){
            usersAccessToAddOutcome = mockOutcomeAccess;
        }
        return usersAccessToAddOutcome;
    }
    
    /**
     * @name getOutcomeMaxLength
     * @description getOutcomeMaxLength
     * @param taskRecord
     * @return Integer
     */
    @AuraEnabled(cacheable=false)
    public static Integer getOutcomeMaxLength(Task taskRecord){
        Integer taskDescriptionCharacterLimit = Schema.SObjectType.Task.fields.Description.getLength();
        if(String.isNotBlank(taskRecord.Description)){
            taskDescriptionCharacterLimit = (taskDescriptionCharacterLimit - taskRecord.Description.length());
        }
        return taskDescriptionCharacterLimit;
    }
    
    /**
     * @name getAccessErrorMessage
     * @description getAccessErrorMessage
     * @param taskRecord
     * @return String
     */
    @AuraEnabled(cacheable=false)
    public static String getAccessErrorMessage(Task taskRecord){
        String errorMessage = null;
        boolean taskIsClosed = taskRecord.IsClosed;
        boolean taskIsRecurrance = taskRecord.IsRecurrence;
        if(test.isRunningTest() && UnitTestDataUtility.isUnitTest){
            taskIsClosed = mockIsClosed;
            taskIsRecurrance = mockIsRecurrance;
        }
        if(taskRecord.Outcome_Added__c){
            errorMessage = ERROR_TASK_IS_ALREADY_HAS_OUTCOME;
        }else if(taskIsClosed){
			errorMessage = ERROR_TASK_IS_ALREADY_CLOSED;
        }else if(taskIsRecurrance){
            errorMessage = ERROR_TASK_IS_A_RECURRING_PARENT;
        }else if(!taskRecord.IsOwnerProxyofCurrentUser__c && !userHasModifyAllAccess()){
            errorMessage = ERROR_TASK_IS_NOT_OWNED_BY_USERS_PROXY;
        }
		return errorMessage;
    }
	
    /**
     * @name markCompleteWithOutcome
     * @description markCompleteWithOutcome
     * @param taskRecord
     * @param outcomeEntered
     */
	@AuraEnabled
    public static void markCompleteWithOutcome(Task taskRecord, String outcomeEntered){
        List<Task> taskList = new List<Task>();
        taskRecord.Outcome_Added__c = true;
        taskRecord.Description = outcomeEntered;
        taskRecord.Status = 'Completed';
        taskList.add(taskRecord);
        try{
            update Security.stripInaccessible(AccessType.UPDATABLE, taskList, true).getRecords();
        }catch(Exception ex){
            ex.setMessage(ERROR_TASK_UPDATE_FAILED);
        	throw ex;  
        }
    }

    @TestVisible private static boolean userCanAddOutcome(Task taskRecord){
        return (taskIsEditableByLoggedInUser(taskRecord) && taskIsNotRecurringOrClosed(taskRecord));
    }
	@TestVisible private static boolean userHasModifyAllAccess(){
        UserPermissionAccess userPermission = getUsersModifyAllAccess();
        boolean modifyAllPermission = userPermission.PermissionsModifyAllData;
        return modifyAllPermission;
    }
    
    @TestVisible private static UserPermissionAccess getUsersModifyAllAccess(){
        List<UserPermissionAccess> permissionList = Security.stripInaccessible(AccessType.READABLE,
                                                                               [SELECT PermissionsModifyAllData FROM UserPermissionAccess LIMIT 1]).getRecords();
        if(Test.isRunningTest() && UnitTestDataUtility.isUnitTest){
            permissionList = mockUserPermList;
        }
        return permissionList.get(0);
    }
    
    @TestVisible private static boolean taskIsNotRecurringOrClosed(Task taskRecord){
        return (!taskRecord.IsRecurrence && !taskRecord.IsClosed && !taskRecord.Outcome_Added__c);
    }
    @TestVisible private static boolean taskIsEditableByLoggedInUser(Task taskRecord){
        boolean userHasModifyAllAccess = userHasModifyAllAccess();
        boolean taskOwnerIsTheUsersProxy = taskRecord.IsOwnerProxyofCurrentUser__c;
        if(Test.isRunningTest() && UnitTestDataUtility.isUnitTest){
            taskOwnerIsTheUsersProxy = mockIsOwnerProxy;
            userHasModifyAllAccess = mockModifyAllAccess;
        }
        return ((taskOwnerIsTheUsersProxy || userHasModifyAllAccess) && !taskRecord.Outcome_Added__c);
    }    
    
}