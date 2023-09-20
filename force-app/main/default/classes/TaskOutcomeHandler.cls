/**
* @description handler adding an outcomne to task
* @Owner: CATS
*/
public with sharing class TaskOutcomeHandler {

    /**
     * @description Handle close task with outcome method
     * @param taskRecord
     * @param oldTask
     */
    public static void handleCloseTaskWithOutcome(Task taskRecord, Task oldTask){
        if(TaskHandlerUtility.outcomeWasAddedToTask(taskRecord,oldTask)){
            appendOutcomeToDescription(taskRecord, oldTask);
        }
    }

    private static void appendOutcomeToDescription(Task taskRecord, Task oldTask){
        List<String> combinedCommentsAndDescriptionList = new List<String>();
        String taskOutcomeHeader = TaskHandlerUtility.buildTaskOutcomeHeader(taskRecord);
        combinedCommentsAndDescriptionList.add(taskOutcomeHeader);
        combinedCommentsAndDescriptionList.add(oldTask.Description);
        String updatedTaskDescription = String.join(combinedCommentsAndDescriptionList , '\n');
        taskRecord.Description = updatedTaskDescription;
    }

}