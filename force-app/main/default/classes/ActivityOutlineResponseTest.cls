@isTest
public class ActivityOutlineResponseTest {
    private static ActivityOutlineResponse mockResponse = new ActivityOutlineResponse();
	
    @isTest
    public static void testInitialization(){
        Test.startTest();

        // Check that the object initialized successfully.
        System.assertEquals(mockResponse.hasMoreCurrentRecords, false);

        Test.stopTest();
    }
}