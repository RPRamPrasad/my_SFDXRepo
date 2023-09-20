/**
 * @name JustOneThingSaveTaskController
 * @author Team Astro
 * @description This class is used when creating a Task through JOT for saving the Task onto the object
 */
public with sharing class JustOneThingSaveTaskController {
    private static final String CLASS_NAME = 'JustOneThingSaveTaskController';
    /**
     * @description - Executes the save process for saving an Task onto the object
     * @param paramMap - Parameters needed to create an Task
     * 
     * The parameters that could be provided by the paramMap is:
     *  - EventStartDateTime: Start date and time of the Event
     *  - EventEndDateTime: End date and time of the Event 
     *  - Subject: The subject title of the Task
     *  - WhoId: Contact Id of the associated account
     *  - OwnerId: Id of the user record who owns the Events (the id of the agent's office or the case owner)
     *  - AssignedTo: Id of the user record who is assigned to the Task
     *  - RelatedContactIds: Contact Ids of household members
     *  - Location: Location of the Event
     * 
     * @param recordId - Id of the record that will be used to obtain needed record data
     * @return Map<String, Object> - returns a map that contains either the Task id on success or
     *                               an error message on failure
     */
    @AuraEnabled
    public static Map<String, Object> saveTask(Map<String, Object> paramMap, String recordId) {
        Map<String, Object> response = new Map<String, Object>();
        try {
            Database.SaveResult saveResult = JustOneThingUtilities.insertTask(JustOneThingUtilities.buildTask(paramMap, recordId));
            if(saveResult.isSuccess()) {
                Id taskId = saveResult.getId();
                response.put('data', taskId);
                if (paramMap.get('RelatedContactIds') != null) {
                    List<Object> relatedContactIds = (List<Object>)paramMap.get('RelatedContactIds');
                    List<TaskRelation> taskRelations = JustOneThingUtilities.buildTaskRelations(relatedContactIds, taskId);
                    JustOneThingUtilities.insertTaskRelations(taskRelations);
                }
                return response;
            }

            String errorMessage = saveResult.getErrors().get(0).getMessage();
            String statusCode = String.valueOf(saveResult.getErrors().get(0).getStatusCode());

            response.put('error', (statusCode + ' - ' + errorMessage));
        } catch (Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, 'saveTask', LoggingLevel.ERROR);
            throw new AuraHandledException('Failed to save task');
        }
        return response;
    }
}
