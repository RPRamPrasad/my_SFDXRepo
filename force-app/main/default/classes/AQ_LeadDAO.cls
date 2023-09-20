/**
  * @name AQ_LeadDAO
  * @author Team Skynet
  * @createdDate 12/07/2022
  * @description  This class will handle Data retrieval for Agent Queue Lead Object
*/
public with sharing class AQ_LeadDAO {

    private static final List<String> LEAD_FIELDS = new List<String> {
        'Id',
        'AssignedTo__r.Name',
        'CreatedDate',
        'DaysOpen__c',
        'LeadSource',
        'MultiLOB__c',
        'Name',
        'Submitted_First_Name__c',
        'Submitted_Last_Name__c'
    };

	private static final String LEAD_FIELDS_STR=String.join(LEAD_FIELDS, ', ');
    private static final String TASK_INNER_QUERY = '(Select Id, Subject, ActivityDate, AssignedTo__r.Name from Tasks'
        											+' where isClosed = false order by ActivityDate asc limit 4)';

    private AQ_LeadDAO(){
        AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.info('AQ_LeadDAO', 'start time of execution: ' + System.now());
        logHolder.writeToLogExceptionObject();
    }
    /**
    * @name: getWorkItems
    * @description Method to return Lead Work Items
    * @param assignedTo For My work items queue
    * @return List of Lead work items
    */
    public static List<AQ_workItem> getWorkItems(Id assignedTo){

        String leadQueryStr = String.format('Select {0}, {1} From Lead Where IsConverted = false Order By CreatedDate Desc',
                                           new List<String> {LEAD_FIELDS_STR, TASK_INNER_QUERY});

        //system.debug('Query String: '+ leadQueryStr);

        List<sObject> leads = Security.stripInaccessible(
                AccessType.READABLE,
                Database.Query(String.escapeSingleQuotes(leadQueryStr) )
            ).getRecords();

        return transform(leads);
    }


    private static List<AQ_workItem> transform(List<SObject> records){
        List<AQ_workItem> workItems = new List<AQ_workItem>();

        for(SObject record: records){
            AQ_workItem workItem = new AQ_workItem(record,  String.valueOf(record.getSObjectType()));
            workItem.childItems = record.getSObjects('Tasks');
            if(workItem.childItems != null){
                workItem.dueDate = (Date)workItem.childItems.get(0).get('ActivityDate');
            }
            workItems.add(workItem);
        }
        return workItems;
    }

}