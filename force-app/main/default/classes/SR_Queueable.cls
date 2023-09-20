/**
 * @description A queueable class used by the SR flows to requeue payloads that need to run through matching again
 * @Owner CATs
 */
public without sharing class SR_Queueable implements Queueable {
    
    @TestVisible private List<SR_Payload> payloads = new List<SR_Payload>();
	@TestVisible private List<SR_Payload> remainingPayloads = new List<SR_Payload>();
    /**
     * @description SR_Queueable
     * @param payloads 
     */
    public SR_Queueable(List<SR_Payload> payloads) {
        this.payloads = payloads;
    }
    /**
     * @description execute
     * @param context 
     */
    public void execute(QueueableContext context) {
        if(!this.payloads.isEmpty()){
            SR_Processor processor = new SR_Processor();
            processor.hasQueueBeenRun = true;
            this.remainingPayloads = processor.handlePayloads(this.payloads);
        }
        if(!this.remainingPayloads.isEmpty() && !isQueueTest()){
            System.enqueueJob(new SR_QueueableChild(this.remainingPayloads));
        }
    }
    
    private boolean isQueueTest(){
        return Test.isRunningTest() && SR_TestDataUtility.isQueueTest;
    }
}