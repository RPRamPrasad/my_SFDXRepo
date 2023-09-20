/** 
* @description handler for task priority
* @Owner: CATS
*/
public with sharing class TaskPriorityHandler {

    /**
     * @name handlePriority
     * @description handlePriority
     * @param taskRecord
     */
    public static void handlePriority(Task taskRecord){
        String taskPriority = taskRecord.Priority;
        switch on taskPriority{
            when 'Yes'{
                taskRecord.Priority = TaskHandlerConstants.TASK_PRIORITY_HIGH;
            }
            when 'No'{
                taskRecord.Priority = TaskHandlerConstants.TASK_PRIORITY_NONE;
            }
            when else{
                return;
            }
        }
    }
    
}