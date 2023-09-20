/**
 * @description LightningUsageTrackerController
 */
public with sharing class LightningUsageTrackerController {
    private static final String CLASS_NAME = 'LightningUsageTrackerController';
    /**
     * @description createTrackerRecord
     * @param destination 
     * @return  `String`
     */
    @AuraEnabled
    public static String createTrackerRecord(String destination) {
        User currentUser = UTIL_CurrentUser.retrieveCurrentUser();
        String territoryId = currentUser.Territory_Associate_ID__c;
        String userProfileName = currentUser.Profile.Name;

        if(!String.isEmpty(destination)){
            Lightning_Usage_Tracker__c newLightningTrackerRecordObj = new Lightning_Usage_Tracker__c();
            newLightningTrackerRecordObj.UserProfileName__c = userProfileName; 
            newLightningTrackerRecordObj.Destination__c = destination;
            newLightningTrackerRecordObj.TerritoryId__c = territoryId;
            List<Lightning_Usage_Tracker__c> recordList = new List<Lightning_Usage_Tracker__c>();
            recordList.add(newLightningTrackerRecordObj);

            try {
                upsert Security.stripInaccessible(AccessType.UPSERTABLE, recordList).getRecords();
            } catch (DmlException dmlException) {
                LoggingService.logHandledException(dmlException, CLASS_NAME, 'Exception occurred while upserting data in LightningUsageTrackerController', System.LoggingLevel.ERROR);
            }
        }
        return 'SUCCESS';
    }
    
}