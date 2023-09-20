@isTest
(seeAllData=false)
public class HHNOutlookMetricsControllerTest {

    @isTest
    private static void testAllMetricsCallouts() {

        Test.startTest();

        System.assertEquals(true, HHNOutlookMetricsController.logClickLogEmail(), 'Expected Apex Call to always return true');

        Test.stopTest();

    }

    @isTest
    private static void testCatchStatement() {
        Test.startTest();
        try {
            HHNOutlookMetricsController.isCatch = true;
            HHNOutlookMetricsController.logClickLogEmail();
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Expected exception to match.');   
        }
        Test.stopTest();
    }

}