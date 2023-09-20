/**
 * @description apex methods for the Activity History LWC to utilize
 */
public with sharing class ActivityHistoryController {

    public static final String TASK_FIELDS = 'SELECT Id, CreatedDate, RecordTypeId, LastModifiedDate, LastModifiedBy.Name, AssignedTo__r.Name, Subject, Status, LineofBusiness__c, WhoId, Who.Name, What.Id, What.Name, Description, IsHighPriority, ActivityDate, isClosed, isArchived ';
    public static final String TASK_FROM_OBJECT = ' FROM Task ';

    public static final String EVENT_FIELDS = 'SELECT Id, CreatedDate, LastModifiedDate, LastModifiedBy.Name,  AssignedTo__r.Name, Subject, LineofBusiness__c, WhoId, Who.Name, What.Id, What.Name, Description, StartDateTime, IsAllDayEvent, ActivityDate, isArchived ';
    public static final String EVENT_FROM_OBJECT = ' FROM Event ';

    public static final String ARCHIVE_CALL = ' WHERE What.Id =: parentId AND isArchived=true ALL ROWS';

    private static final String CLASS_NAME = 'ActivityHistoryController';

    @TestVisible private static List<Task> mockedTasks = new List<Task>();
    @TestVisible private static List<Event> mockedEvents = new List<Event>();

    /**
     * @description queries and returns all archived tasks and events associated to the passed in objectId
     * @param parentId Id of the record to get all archived activities for
     * @return A list of ActivityOutlineSObjectWrappers containing all archived records for the passed in objectId
     */
    @AuraEnabled(cacheable=false)
    public static List<ActivityOutlineSObjectWrapper> getArchivedRecords(String parentId) {

        String taskQueryToExecute = TASK_FIELDS + TASK_FROM_OBJECT + ARCHIVE_CALL;
        String eventQueryToExecute = EVENT_FIELDS + EVENT_FROM_OBJECT + ARCHIVE_CALL;

        List<ActivityOutlineSObjectWrapper> archivedRecords = new List<ActivityOutlineSObjectWrapper>();

        try {
            if(parentId != null && parentId.length() > 0) {
                List<Task> archivedTasks = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(taskQueryToExecute))).getRecords();
                List<Event> archivedEvents = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(eventQueryToExecute))).getRecords();

                if (Test.isRunningTest()) {
                    archivedTasks = mockedTasks;
                    archivedEvents = mockedEvents;
                }

                archivedRecords = HHNUtilities.transformTasks(archivedTasks);
                archivedRecords.addAll(HHNUtilities.transformEvents(archivedEvents));
            }
        } catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, 'getArchivedRecords', LoggingLevel.ERROR);
            throw new AuraHandledException('Unable to retrieve historical records');
        }

        return archivedRecords;
    }
}