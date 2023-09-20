@isTest(SeeAllData=false)
public class AT_UTIL_PolicyTransactionTask_Test {
    
    @isTest
    private static void testException() {
        AT_UTIL_PolicyTransactionTask.mockedAccount = null;
        Test.startTest();
        Map<String,String> returnValue = AT_UTIL_PolicyTransactionTask.createTaskGetDefaultValues('associateId','001xa000003DIlo');
        Test.stopTest();
        System.assertEquals(2, returnValue.size(),'Size of returnValue is 2');
    }   

}