/**
 * @name JustOneThingSaveLogController
 * @author Team Astro
 * @description This class is used when creating a Log through JOT for saving the Log onto the object
 */
public with sharing class JustOneThingSaveLogController {
    private static final String CLASS_NAME = 'JustOneThingSaveLogController';
    /**
     * @description - Executes the save process for saving an Log onto the object
     * @param paramMap - Parameters needed to create an Log
     *
     * The parameters that could be provided by the paramMap is:
     *  - EventStartDateTime: Start date and time of the Event
     *  - EventEndDateTime: End date and time of the Event
     *  - Subject: The subject title of the Log
     *  - WhoId: Contact Id of the associated account
     *  - OwnerId: Id of the user record who owns the Events (the id of the agent's office or the case owner)
     *  - AssignedTo: Id of the user record who is assigned to the Log
     *  - RelatedContactIds: Contact Ids of household members
     *  - Location: Location of the Event
     *
     * @param recordId - Id of the record that will be used to obtain needed record data
     * @return Map<String, Object> - returns a map that contains either the Log id on success or
     *                               an error message on failure
     */
    @AuraEnabled
    public static Map<String, Object> saveLog(Map<String, Object> paramMap, String recordId) {
        Map<String, Object> response = new Map<String, Object>();
        try {
            Database.SaveResult saveResult = JustOneThingUtilities.insertLog(JustOneThingUtilities.buildLog(paramMap, recordId));
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
            LoggingService.logHandledException(e, CLASS_NAME, 'saveLog', LoggingLevel.ERROR);
            throw new AuraHandledException('Failed to save log');
        }
        return response;
    }
}
