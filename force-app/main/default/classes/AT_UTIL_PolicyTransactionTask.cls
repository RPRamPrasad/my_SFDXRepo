/**
 * @description AT_UTIL_PolicyTransactionTask
 */
public with sharing class AT_UTIL_PolicyTransactionTask {
    
    private static final String CLASS_NAME = 'AT_UTIL_PolicyTransactionTask';
    @TestVisible private static List<Account> mockedAccount;
    private AT_UTIL_PolicyTransactionTask(){
        AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.info(CLASS_NAME, 'start time of execution: ' + System.now());
        logHolder.writeToLogExceptionObject();
    }
    /**
     * @description createTaskGetDefaultValues 
     * @param associateId 
     * @param accountId 
     * @return  `Map<String,String>`
     * @exception 
     */
    public static Map<String,String> createTaskGetDefaultValues(String associateId, String accountId) {
        String ownerId = null;
        Map<String,String> defaultVals = new Map<String,String>();
        string sfdcRecordId = String.escapeSingleQuotes(string.valueOf(accountId).replaceAll('[^\\w]',''));
        List<Account> accDataList = null;
        
        try {        
            if (Test.isRunningTest()) {  
                ownerId = 'test';
                accDataList = mockedAccount;
                if (null == accDataList) {
                    throw new DMLException('THIS IS AN ERROR');
                }
            }
            else {
                ownerId = UTIL_AgentOfficeDetails.getProxyforGivenServicingAgentAssocId(associateId).id;
                accDataList = Security.stripInaccessible(AccessType.READABLE, [SELECT PersonContactId FROM Account WHERE id = :sfdcRecordId]).getRecords();
            }
        }
        catch (Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, 'createTaskGetDefaultValues', System.LoggingLevel.ERROR);
        }
        finally {        
            defaultVals.put('taskRecordTypeId', Schema.SObjectType.Task.getRecordTypeInfosByName().get('Task').getRecordTypeId());
            defaultVals.put('ownerId', ownerId);
            if(null != accDataList && !accDataList.isEmpty()){
                defaultVals.put('contactId', accDataList[0].PersonContactId);
            }
        }
        return defaultVals;
    }

}