@isTest
public class ActivityOutlineParametersTest {
    private static ActivityOutlineParameters mockParameters = new ActivityOutlineParameters();
	
    @isTest
    public static void testInitialization(){
        Test.startTest();

        // Check that the object initialized successfully.

        System.assertEquals(mockParameters.parentRecordId, null, 'everything should be null');
        System.assertEquals(mockParameters.parentSObjectName, null, 'everything should be null');
        System.assertEquals(mockParameters.requestType, null, 'everything should be null');
        System.assertEquals(mockParameters.accountRecordType, null, 'everything should be null');
        System.assertEquals(mockParameters.taskRecordType, null, 'everything should be null');
        System.assertEquals(mockParameters.currentOffset, null, 'everything should be null');
        System.assertEquals(mockParameters.pastOffset, null, 'everything should be null');
        System.assertEquals(mockParameters.selectedObjectFilter, null, 'everything should be null');
        System.assertEquals(mockParameters.newlyRequestedObjects, null, 'everything should be null');

        Test.stopTest();
    }
}