/**
 * @description test class to captured transcript rest service
 */
@isTest(seeAllData = false)
public class WS_CapturedTranscriptRestService_TEST {

	private static final String CHATTER_MONITORING_USERNAME = UTIL_TestUsername_TEST.getTestUsername('chattmon');

    /**
     * @description test method to set up data
     */
    @testsetup
   	public static void testSetUpData(){
	   	User chatterMonitoringProcessId = UTIL_UserProvisioning_TEST.buildUserAPIDataAdmin (CHATTER_MONITORING_USERNAME);
	    insert chatterMonitoringProcessId;
        PermissionSetAssignment permSetAssignment = new PermissionSetAssignment();
        permSetAssignment.AssigneeId = chatterMonitoringProcessId.Id;
        permSetAssignment.PermissionSetId = [Select Id from PermissionSet where Name = 'SF_CRM_ChatterMonitoring_PermSetPID' Limit 1].Id;
	    insert permSetAssignment;
	}

    @isTest
    public static void testUpdateCapturedFeeds() {
        User chatterMonitoringProcessId = [select Id from User where username =: CHATTER_MONITORING_USERNAME];
    	Captured_Feed_Transcript__c capturedFeedTranscript = new Captured_Feed_Transcript__c(EmailSubject__c = 'EmailSubject', Status__c = 'ToBeProcessed');
        insert capturedFeedTranscript;

        List<String> processedFeedTranscriptList = new List<String>();
        processedFeedTranscriptList.add(capturedFeedTranscript.Id);

        Test.startTest();
        system.runAs(chatterMonitoringProcessId) {
            WS_CapturedTranscriptRestService.updateCapturedFeeds('Processed', processedFeedTranscriptList, '1234');
        }
        Captured_Feed_Transcript__c updatedFeedTranscript = [select Status__c, DateProcessed__c
        													from Captured_Feed_Transcript__c
        													where Id = :capturedFeedTranscript.Id];

        system.assertEquals('Processed', updatedFeedTranscript.Status__c, 'updated feed transcript status object equal to processed');
        System.assertEquals(System.today(), updatedFeedTranscript.DateProcessed__c, 'updated feed transcript date processed object equal to todays date');
    }

    @isTest
    public static void testUpdateCapturedFeedsFailure() {
        User chatterMonitoringProcessId = [select Id from User where username =: CHATTER_MONITORING_USERNAME];
    	Captured_Feed_Transcript__c capturedFeedTranscript = new Captured_Feed_Transcript__c(EmailSubject__c = 'EmailSubject', Status__c = 'ToBeProcessed');
        insert capturedFeedTranscript;

        List<String> processedFeedTranscriptList = new List<String>();
        processedFeedTranscriptList.add('somerandomid');

        Test.startTest();
        system.runAs(chatterMonitoringProcessId) {
            WS_CapturedTranscriptRestService.updateCapturedFeeds('Processed', processedFeedTranscriptList, '1234');
        }
        Captured_Feed_Transcript__c updatedFeedTranscript = [select Status__c, DateProcessed__c
        													from Captured_Feed_Transcript__c
        													where Id = :capturedFeedTranscript.Id];

        system.assertEquals('ToBeProcessed', updatedFeedTranscript.Status__c, 'updated feed transcript status equal to tobeprocessed');
        System.assertEquals(null, updatedFeedTranscript.DateProcessed__c, 'updated feed transcript date processed is null');
    }
}