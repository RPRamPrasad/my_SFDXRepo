/**
  * @name AQ_OpportunityDAO
  * @author Team Skynet
  * @createdDate 12/07/2022
  * @description  This class will handle Data retrieval for Agent Queue Opportunity Object
*/
public with sharing class AQ_OpportunityDAO {

    private static final List<String> OPP_FIELDS = new List<String> {
        'Id',
		'AccountId',
		'FinServ__Household__c',
		'Assigned_To__r.Name',
        'CreatedDate',
        'LOB__c',
        'Account.FirstName',
        'Account.LastName',
        'Account.PersonDoNotCall',
        'Account.PersonHomePhone',
        'Account.PersonMobilePhone',
        'Account.Phone',
        'DisplayDoNotMarket__c',
        'Duration_of_Opportunity__c',
        'AccountEmail__c',
        'Marketing_Source__c',
        'Marketing_Sub_Source__c',
        'Name',
        'Opportunity_Originator__c',
        'Product__c',
        'Requested_Effective_Date__c',
        'StageName'
    };

	private static final String OPP_FIELDS_STR=String.join(OPP_FIELDS, ', ');
    private static final String TASK_INNER_QUERY = '(Select Id, Subject, ActivityDate, AssignedTo__r.Name from Tasks'
        											+' where isClosed = false order by ActivityDate asc limit 4)';
                                                    
    private AQ_OpportunityDAO(){
        AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.info('AQ_OpportunityDAO', 'start time of execution: ' + System.now());
        logHolder.writeToLogExceptionObject();
    }
    /**
    * @name: getWorkItems
    * @description Method to return Opportunity Work Items
    * @param assignedTo For My work items queue
    * @return List of Opportunity work items
    */
    public static List<AQ_workItem> getWorkItems(Id assignedTo){

        String oppQueryStr = String.format('Select {0}, {1} From Opportunity Where isClosed = false Order By CreatedDate Desc',
                                           new List<String> {OPP_FIELDS_STR, TASK_INNER_QUERY});

        //system.debug('Query String: '+ oppQueryStr);

        List<sObject> opportunities = Security.stripInaccessible(
                AccessType.READABLE,
                Database.Query(String.escapeSingleQuotes(oppQueryStr) )
            ).getRecords();

        return transform(opportunities);
    }

    private static List<AQ_workItem> transform(List<SObject> records){
        List<AQ_workItem> workItems = new List<AQ_workItem>();

        for(SObject record: records){
            AQ_workItem workItem = new AQ_workItem(record,  String.valueOf(record.getSObjectType()));
            workItem.accountId = (Id)record.get('AccountId');
            workItem.hhid = (Id)record.get('FinServ__Household__c');
            workItem.childItems = record.getSObjects('Tasks');

            if(workItem.childItems != null){
                workItem.dueDate = (Date)workItem.childItems.get(0).get('ActivityDate');
            }
            workItems.add(workItem);

        }

        return workItems;
    }
}