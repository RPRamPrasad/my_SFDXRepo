/**
 * @description class to test data factory captured transcript
 */
@isTest
public without sharing class TestDataFactory_CapturedTranscript {

	/**
	 * @description method to generate captured transcript
	 * @return  `Captured_Feed_Transcript__c`
	 */
    public static Captured_Feed_Transcript__c generateCapturedTranscript() {

    	return new Captured_Feed_Transcript__c(BatchId__c = 'Batch1',
    											EmailBody__c = 'Test Email Body',
    											EmailSubject__c = 'Test Email Subject',
    											FeedItem__c = '1234567890',
    											Status__c = 'Processed');
    }

	/**
	 * @description method to insert captured transcript
	 * @param capturedTranscript
	 * @return  `Captured_Feed_Transcript__c`
	 */
    public static Captured_Feed_Transcript__c insertCapturedTranscript(Captured_Feed_Transcript__c capturedTranscript) {
    	insert capturedTranscript;
    	return capturedTranscript;
    }
}