/**
 * @description class to captured transcript rest service
 */
@RestResource(urlMapping='/updatecapturedtranscripts/*')
global with sharing class WS_CapturedTranscriptRestService {
    private static String className = 'WS_CapturedTranscriptRestService';

    /**
     * @description method to update captured feeds
     * @param status
     * @param capturedFeedTranscriptIdList
     * @param batchId
     * @return  `String`
     */
    @HttpPost
    global static String updateCapturedFeeds(String status, List<String> capturedFeedTranscriptIdList, String batchId) {
        try {
            List<Captured_Feed_Transcript__c> capturedFeedTranscriptList = constructCapturedFeedTranscripts(status, capturedFeedTranscriptIdList);
            List<Database.SaveResult> updateResultList = Database.update(capturedFeedTranscriptList);
            checkForErrorsAndLog(updateResultList, capturedFeedTranscriptList, batchId);
            return 'Updating status for Captured_Feed_Transcript__c with BATCH_ID = ' + batchId + ' succeeded';
        } catch (Exception ex) {
            logException(batchId, ex);
            return 'Updating status for Captured_Feed_Transcript__c with BATCH_ID = ' + batchId + ' failed';
        }
    }

    private static List<Captured_Feed_Transcript__c> constructCapturedFeedTranscripts(String status, List<String> capturedFeedTranscriptIdList) {
        List<Captured_Feed_Transcript__c> capturedFeedTranscriptList = new List<Captured_Feed_Transcript__c>();
        for (String capturedFeedTranscriptId : capturedFeedTranscriptIdList) {
            Captured_Feed_Transcript__c capturedFeedTranscript = new Captured_Feed_Transcript__c(Id = capturedFeedTranscriptId,
															            Status__c = status,
															            DateProcessed__c = determineDateProcessed(status));
            capturedFeedTranscriptList.add(capturedFeedTranscript);
        }
        return capturedFeedTranscriptList;
    }

    private static void checkForErrorsAndLog(List<Database.SaveResult> saveResultList, List<Captured_Feed_Transcript__c> capturedFeedTranscriptList, String batchId) {
        AP_LogHolder logHolder =  new AP_LogHolder();
        Integer index = 0;
        for (Database.SaveResult saveResult : saveResultList) {
            if (!saveResult.isSuccess()) {
                logHolder.error(className, 'Updating the status of Captured_Feed_Transcript__c failed for record with Id: ' +
                                capturedFeedTranscriptList.get(index).Id + 'and BATCH_ID: ' + batchId);
            }
            index++;
        }
        logHolder.writeToLogExceptionObject();
    }

    private static void logException(String batchId, Exception ex) {
        AP_LogHolder logHolder =  new AP_LogHolder();
        logHolder.error(className, 'Exception while updating status of Captured_Feed_Transcript__c with BATCH_ID: ' + batchId, ex);
        logHolder.writeToLogExceptionObject();
    }

    private static Date determineDateProcessed(String status) {
    	if ('Processed'.equalsIgnoreCase(status)) {
    		return System.today();
    	}
    	return null;
    }
}