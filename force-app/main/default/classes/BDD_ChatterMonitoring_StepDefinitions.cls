@isTest
public class BDD_ChatterMonitoring_StepDefinitions {

	/**
	 * @description method to captured transcript getter and setter
	 */
    public Captured_Feed_Transcript__c capturedTranscript { get; private set; }

	/**
	 * @description method to given a captured transcript
	 */
    public void givenACapturedTranscript() {
    	capturedTranscript = TestDataFactory_CapturedTranscript.generateCapturedTranscript();

    	System.runAs(TestDataFactory_User_Wrapper.getChatterMonitoringUser()) {
    		TestDataFactory_CapturedTranscript.insertCapturedTranscript(capturedTranscript);
    	}
    }

	/**
	 * @description method to given the captured transcript date processed
	 * @param datez
	 */
    public void givenTheCapturedTranscriptDateProcessedIs(Date datez) {
    	capturedTranscript.DateProcessed__c = datez;

    	System.runAs(TestDataFactory_User_Wrapper.getChatterMonitoringUser()) {
    		update capturedTranscript;
    	}
    }

	/**
	 * @description given the captured transcript has not been processed
	 */
    public void givenTheCapturedTranscriptHasNotBeenProcessed() {
    	capturedTranscript.Status__c = 'ToBeProcessed';

    	System.runAs(TestDataFactory_User_Wrapper.getChatterMonitoringUser()) {
    		update capturedTranscript;
    	}
    }

	/**
	 * @description method when the system cleanup runs
	 */
    public void whenTheSystemCleanupRuns() {
    	System.runAs(TestDataFactory_User_Wrapper.getObjectRecordCleanupUser()) {

    		Database.insert(new ObjectCleanupRecord__c(Name='CapturedFeedTranscriptDelete',
    												   Batch_Size__c=200,
                                                       Batch_Handler__c='BATCH_ObjectRecordCleanUp',
    												   Criteria__c='SELECT ID FROM Captured_Feed_Transcript__c WHERE Status__c = \'Processed\' AND DateProcessed__c < LAST_N_DAYS:3',
    												   Object_Name__c='Captured_Feed_Transcript__c',
    												   Priority_Index__c=1.0));
    		Test.startTest();
    		SCH_ObjectRecordCleanup objectRecordCleanup = new SCH_ObjectRecordCleanup();
    		objectRecordCleanup.execute(null);
    		Test.stopTest();
    	}
    }

	/**
	 * @description method to captured transcript is deleted
	 */
    public void thenTheCapturedTranscriptIsDeleted() {
    	Integer recordCount = [SELECT count() FROM Captured_Feed_Transcript__c WHERE ID = :capturedTranscript.ID];
    	System.assertEquals(0, recordCount, 'Captured Transcript was not deleted');
    }

	/**
	 * @description method to captured transcript is not deleted
	 */
    public void thenTheCapturedTranscriptIsNotDeleted() {
    	Integer recordCount = [SELECT count() FROM Captured_Feed_Transcript__c WHERE ID = :capturedTranscript.ID];
    	System.assertEquals(1, recordCount, 'Captured Transcript was deleted');
    }
}