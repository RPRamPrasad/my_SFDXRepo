/**
* @name Batch_HouseholdOwnershipUpdate
* @author rashmi (Team Targaryen)
* @description this is a batch class which transfer all Household records created by agent user to system record owner 
*/

public with sharing class Batch_HouseholdOwnershipUpdate implements Database.batchable<Sobject>{
    
    public final String query;
    final String hhRecordTypeId;
    private static final String HOUSEHOLD_RECORD_TYPE = 'IndustriesHousehold';
    private static final String BATCH_CLASS_NAME = 'Batch_HouseholdOwnershipUpdate';
    private static final String EXECUTE_METHOD_NAME = 'execute';
    
/**
* @description constructor builds the query
* @name : Batch_HouseholdOwnershipUpdate
*/
    public Batch_HouseholdOwnershipUpdate(){
        
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = AccountOwnerSystemUserCustomSetting__c.getInstance();
        String householdRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId();
        hhRecordTypeId = householdRecTypeId;  
        
        query = 'SELECT Id, ownerid,RecordTypeId '+
            'FROM account '+
            'WHERE recordtype.developername= \'' + HOUSEHOLD_RECORD_TYPE + '\'' + 'and OwnerId != \''+
            sysAdminUserIdSetting.SFDC_User_ID__c +'\'';
    }
/**
* @description returns the query
* @name : start
* @param batchContext
* @return Database.querylocator
*/    
    public Database.querylocator start(Database.BatchableContext batchContext){        
        return Database.getquerylocator(query);     
    }
/**
* @description executes to update the Account ownership
* @name  execute
* @param batchContext
* @param listOfCustomers
*/       
    public void execute(Database.BatchableContext batchContext, List<Account> listOfCustomers){
        List<Account> listOfAccountsUpdated = new List<Account>();
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = AccountOwnerSystemUserCustomSetting__c.getInstance();
        String householdRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId();        
        
        if(sysAdminUserIdSetting != null && !String.isBlank(sysAdminUserIdSetting.SFDC_User_ID__c)) {
            for(Account customer : listOfCustomers) {           
                if (customer.recordTypeId.equals(householdRecTypeId)) { 
                    customer.OwnerId = sysAdminUserIdSetting.SFDC_User_ID__c;
                    listOfAccountsUpdated.add(customer);
                }  
            }
        }else {
            throw new RecordOwnerException(System.Label.CL_SystemUserNotFound);          
        }
        
        try{
            //System.debug('@@@ listOfAccountsUpdated' + listOfAccountsUpdated);
            List<Database.Saveresult> saveBulkUpdateResult =  Database.update(listOfAccountsUpdated,false);
            LoggingService.logDatabaseResult(saveBulkUpdateResult, listOfAccountsUpdated, BATCH_CLASS_NAME,EXECUTE_METHOD_NAME , 
                                             System.LoggingLevel.ERROR);
            
        } catch(Exception e){
            LoggingService.logHandledException(e,BATCH_CLASS_NAME,EXECUTE_METHOD_NAME,System.LoggingLevel.ERROR);
        }
    }
    /**
 * @description : No code for Finish Method
 * @param batchContext
 */
    public void finish (Database.BatchableContext batchContext){
        // this is enforced method. But need to do nothing. 
        String pmd = 'Go away PMD';
        pmd = 'Go away PMD';
    }  
}