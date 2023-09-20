/**
 * @name JustOneThingSaveEventController
 * @author Team Astro
 * @description This class is used when creating an Event through JOT for saving the Event onto the object
 */
public with sharing class JustOneThingSaveEventController {
    private static final String CLASS_NAME = 'JustOneThingSaveEventController';
    /**
     * @description - Executes the save process for saving an Event onto the object
     * @param paramMap - Parameters needed to create an Event
     * 
     * The parameters that could be provided by the paramMap is:
     *  - EventStartDateTime: Start date and time of the Event
     *  - EventEndDateTime: End date and time of the Event 
     *  - Subject: The subject title of the Event
     *  - WhoId: Contact Id of the associated account
     *  - OwnerId: Id of the user record who owns the Events (the id of the agent's office or the case owner)
     *  - AssignedTo: Id of the user record who is assigned to the Event
     *  - RelatedContactIds: Contact Ids of household members
     *  - Location: Location of the Event
     * 
     * @param recordId - Id of the record that will be used to obtain needed record data
     * @return Map<String, Object> - returns a map that contains either the Event id on success or
     *                               an error message on failure
     */
    @AuraEnabled
    public static Map<String, Object> saveEvent(Map<String, Object> paramMap, String recordId) {
        Map<String, Object> response = new Map<String, Object>();
        try {
            Database.SaveResult saveResult = JustOneThingUtilities.insertEvent(JustOneThingUtilities.buildEvent(paramMap, recordId));
            if(saveResult.isSuccess()) {
                Id eventId = saveResult.getId();
                response.put('data', eventId);
                if (paramMap.get('RelatedContactIds') != null) {
                    List<Object> relatedContactIds = (List<Object>)paramMap.get('RelatedContactIds');
                    List<EventRelation> eventRelations = JustOneThingUtilities.buildEventRelations(relatedContactIds, eventId);
                    JustOneThingUtilities.insertEventRelations(eventRelations);
                }
                return response;
            }

            String errorMessage = saveResult.getErrors().get(0).getMessage();
            String statusCode = String.valueOf(saveResult.getErrors().get(0).getStatusCode());

            response.put('error', (statusCode + ' - ' + errorMessage));
        } catch (Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, 'saveEvent', LoggingLevel.ERROR);
            throw new AuraHandledException('Failed to save event');
        }
        return response;
    }
}
