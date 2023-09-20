/**
* @name Batch_CleanupHouseholdRecord
* @author Targaryen
* @description This batch will remove all Orphan Households and Single Member Households including Household Memebrs, those are created / updated on CurrentDate -2 days (two days 
* less than todays date, it won't remove last two days Household records from current date)
*/
public without sharing class Batch_CleanupHouseholdRecord implements Database.batchable<Sobject>, Database.Stateful{
    public final String query;
    private final String hhRecordTypeId;
    private static final String HOUSEHOLD_RECORD_TYPE = 'IndustriesHousehold';
    private static final String BATCH_CLASS_NAME = 'Batch_CleanupHouseholdRecord';
    private static final String METHOD_NAME = 'deleteRecords';
    private static final String EMAIL_SENDER = 'ECRM 3.0 Household Cleanup Job';
    private static final String EMAIL_SUBJECT = 'ECRM 3.0 Household Cleanup Details for '+System.today().format();
	private static final String RICH_TEXT_NEW_LINE = '<br/> <br/> ';
    
    CS_HouseholdBatch__c customSettingsHouseholdBatch = CS_HouseholdBatch__c.getValues('EmailAndBatchDetails');
    
    public Integer totalHouseholdProcessed;
    public Integer totalHouseholdDeleted;
    public Integer totalHouseholdMemeberDeleted;
    public boolean isSchedule = false;

    Date minDateTimeToCheck = System.today().addDays(- (Integer) (customSettingsHouseholdBatch.StartDaysToCheck__c));
    Date maxDateTimeToCheck = System.today().addDays(- (Integer) (customSettingsHouseholdBatch.EndDaysToCheck__c));
   
    /**
     * @description This method checks for a schedualed run, and if it finds none, sets one up
     * @param isSchedule
     */
    public Batch_CleanupHouseholdRecord(boolean isSchedule){
        totalHouseholdProcessed = 0;
        totalHouseholdDeleted = 0;
        totalHouseholdMemeberDeleted = 0;
        
        // Onetime Batch Apex Query
        if(isSchedule){
             query = 'SELECT Id,'+
            '(SELECT Id FROM AccountContactRelations WHERE isActive=true)'+
            'FROM Account '+
            'WHERE ((SystemModStamp>= :minDateTimeToCheck AND SystemModStamp<=:maxDateTimeToCheck) OR (CreatedDate>= :minDateTimeToCheck AND CreatedDate<=:maxDateTimeToCheck))'+
            'AND RecordType.DeveloperName= \''+ HOUSEHOLD_RECORD_TYPE +'\'';
        }else{
            query = 'SELECT Id,'+
            '(SELECT Id FROM AccountContactRelations WHERE isActive=true)'+
            'FROM Account '+
            'WHERE RecordType.DeveloperName= \''+ HOUSEHOLD_RECORD_TYPE +'\''+
            'AND (SystemModStamp<: maxDateTimeToCheck OR CreatedDate<:maxDateTimeToCheck)';
        } 
    }
    
    /**
     * @description This method launches the locator for the batch list
     * @method start
     * @param batchContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext batchContext){ 
        return Database.getQueryLocator(query);     
    }

    /**
     * @description This method runs the batch job on the list of household values and deletes valid ACRecords
     * @param batchContext
     * @param listOfHousehold
     */
    public void execute(Database.BatchableContext batchContext, List<Account> listOfHousehold){
        List<Account> eligibleToDeleteHousehold = new List<Account>();
        List<AccountContactRelation> eligibleToDeleteACRrecord = new List<AccountContactRelation>();

        if(!listOfHousehold.isEmpty() && listOfHousehold !=null ){
            for(Account singleAccount : listOfHousehold){
                if(singleAccount.AccountContactRelations.isEmpty() && singleAccount.AccountContactRelations.Size()==0){
                    eligibleToDeleteHousehold.add(singleAccount);
                }else if(!singleAccount.AccountContactRelations.isEmpty() && singleAccount.AccountContactRelations.Size()==1){
                    eligibleToDeleteACRrecord.add(singleAccount.AccountContactRelations);
                    eligibleToDeleteHousehold.add(singleAccount);
                }
            }
            
            totalHouseholdProcessed = totalHouseholdProcessed + listOfHousehold.size();
            totalHouseholdDeleted = totalHouseholdDeleted + eligibleToDeleteHousehold.size();
            totalHouseholdMemeberDeleted = totalHouseholdMemeberDeleted + eligibleToDeleteACRrecord.size();
  
            // Delete List of HH and HHM (1st delete household members, after that Household )
            deleteRecords(eligibleToDeleteACRrecord);
            deleteRecords(eligibleToDeleteHousehold);
            
        }
    }
    
    /**
     * @description Calls sendEmail method
     * @param batchContext
     */
    public void finish (Database.BatchableContext batchContext){
        // On finish what we will do?
        sendEmail();
    }
    
    /**
     * @description This method runs the delete on any ACRecords provided
     * @param listToDelete
     */
    private void deleteRecords(List<Sobject> listToDelete){
        if(!listToDelete.isEmpty()){
            try{ Database.delete(listToDelete, false); }
            catch(DmlException e){             
                LoggingService.logHandledException(e,BATCH_CLASS_NAME,METHOD_NAME,System.LoggingLevel.ERROR);
            }	
        }
    }
    
    /**
	* @description This method is used to trigger the mail to the members who are part of the defined mail group in configuration when Household delete batch job triggered and processed.
	*/
    private void sendEmail() {
        if(totalHouseholdDeleted <> 0){
            Integer totalOrphanHouseholdDeleted = totalHouseholdDeleted - totalHouseholdMemeberDeleted;
            Integer totalSingleMemberHHdeleted = totalHouseholdMemeberDeleted;

            String[] toAddresses = new List<String> {customSettingsHouseholdBatch.BatchEmailRecipient__c};
            String bodyData = '';
            
            String emailTitleBody = 'Hi, Please find the below details for ECRM 3.0 Household cleanup Job. '+RICH_TEXT_NEW_LINE;
            String finalEmailBody = emailTitleBody+bodyData+RICH_TEXT_NEW_LINE+ '<b> Orphan Household Deleted: </b>'+totalOrphanHouseholdDeleted +RICH_TEXT_NEW_LINE +
                '<b> Single Member Household Deleted: </b>'+totalSingleMemberHHdeleted +RICH_TEXT_NEW_LINE +
                '<b> Household Member (ACR) Deleted: </b>'+totalHouseholdMemeberDeleted+RICH_TEXT_NEW_LINE+RICH_TEXT_NEW_LINE+'Customer View Support Team';
            Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
            emailMessage.setToAddresses(toAddresses);
            if(String.isNotBlank(EMAIL_SENDER)) {
                emailMessage.setSenderDisplayName(EMAIL_SENDER);
            }
            emailMessage.setSubject(EMAIL_SUBJECT);
            emailMessage.setHTMLBody(finalEmailBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailMessage });
        }
    }
}
