/**
 * @description A queueable test class for SR_Queueable and SR_QueueableChild
 * @Owner CATs
 */
@isTest
(seeAllData=false)
private class SR_QueueableTest {

    @isTest
    private static void testQueueable(){
        Test.startTest();
        SR_TestDataUtility.isQueueTest = true;
		List<SR_Payload> payloads = SR_TestDataUtility.getBasicPayloadList(2);
        SR_Queueable job = new SR_Queueable(payloads);
		System.enqueueJob(job);
		System.assert(payloads.size() == job.payloads.size(), 'payloads were not passed to the queueable process');
        Test.stopTest();
    }
    
    @isTest
    private static void testQueueableChild(){
        Test.startTest();
        SR_TestDataUtility.isQueueTest = true;
		List<SR_Payload> payloads = SR_TestDataUtility.getBasicPayloadList(2);
        SR_QueueableChild job = new SR_QueueableChild(payloads);
		System.enqueueJob(job);
		System.assert(payloads.size() == job.payloads.size(), 'payloads were not passed to the queueable process');
        Test.stopTest();
    }
    
    
    
}