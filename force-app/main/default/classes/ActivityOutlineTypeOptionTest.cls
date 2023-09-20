@isTest
public class ActivityOutlineTypeOptionTest {
    private static ActivityOutlineTypeOption mockTypeOption = new ActivityOutlineTypeOption(null, null, false);
	
    @isTest
    public static void testInitialization(){
        Test.startTest();

        // Check that the object initialized successfully.
        System.assertEquals(mockTypeOption.label, null, 'everything should be null');
        System.assertEquals(mockTypeOption.value, null, 'everything should be null');
        System.assertEquals(mockTypeOption.isDefault, false, 'everything should be null');

        Test.stopTest();
    }
}