@isTest
public class BDD_Story_ChatterMonitoring {

     /**************************
     * Scenerio: 3 days after a captured transcript is processed, it should be deleted
     *
     * Given a Captured Transcript
     * And the Captured Transcript was processed more than 3 days ago
     * When the system cleanup runs
     * Then the Captured Transcript should be deleted
     *
     *
     * Related Stories:
     * S-149456
     *
     * ***********************/
    /**
     * @description method to 3 days after a captured transcript is processed, it should be deleted
     */
    @isTest
    public static void capturedTransriptIsDeleted3DaysAfterProcessing() {
    	BDD_ChatterMonitoring_StepDefinitions chatterMonitoringStepDefinitions = new BDD_ChatterMonitoring_StepDefinitions();

    	chatterMonitoringStepDefinitions.givenACapturedTranscript();
        chatterMonitoringStepDefinitions.givenTheCapturedTranscriptDateProcessedIs(System.today().addDays(-4));
    	chatterMonitoringStepDefinitions.whenTheSystemCleanupRuns();
    	chatterMonitoringStepDefinitions.thenTheCapturedTranscriptIsDeleted();
    }

    /**************************
     * Scenerio: Captured Transcripts that are 3 days or less are not deleted
     *
     * Given a Captured Transcript
     * And the Captured Transcript was processed less than or equal to 3 days ago
     * When the system cleanup runs
     * Then the Captured Transcript should not be deleted
     *
     *
     * Related Stories:
     * S-149456
     *
     * ***********************/
    /**
     * @description method to Captured Transcripts that are 3 days or less are not deleted
     */
    @isTest
    public static void capturedTransriptProcessedLessThan3DaysIsNotDeleted() {
    	BDD_ChatterMonitoring_StepDefinitions chatterMonitoringStepDefinitions = new BDD_ChatterMonitoring_StepDefinitions();

    	chatterMonitoringStepDefinitions.givenACapturedTranscript();
    	chatterMonitoringStepDefinitions.givenTheCapturedTranscriptDateProcessedIs(System.today().addDays(-3));
    	chatterMonitoringStepDefinitions.whenTheSystemCleanupRuns();
    	chatterMonitoringStepDefinitions.thenTheCapturedTranscriptIsNotDeleted();
    }

    /**************************
     * Scenerio: Captured Transcripts that have not been processed are not deleted
     *
     * Given a Captured Transcript
     * And the Captured Transcript has not been processed
     * When the system cleanup runs
     * Then the Captured Transcript should not be deleted
     *
     *
     * Related Stories:
     * S-149456
     *
     * ***********************/
    /**
     * @description Captured Transcripts that have not been processed are not deleted
     */
    @isTest
    public static void capturedTransriptThatHasNotBeenProcessedIsNotDeleted() {
    	BDD_ChatterMonitoring_StepDefinitions chatterMonitoringStepDefinitions = new BDD_ChatterMonitoring_StepDefinitions();

    	chatterMonitoringStepDefinitions.givenACapturedTranscript();
    	chatterMonitoringStepDefinitions.givenTheCapturedTranscriptHasNotBeenProcessed();
    	chatterMonitoringStepDefinitions.whenTheSystemCleanupRuns();
    	chatterMonitoringStepDefinitions.thenTheCapturedTranscriptIsNotDeleted();
    }
}