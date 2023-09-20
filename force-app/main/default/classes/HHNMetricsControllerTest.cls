@isTest
(seeAllData=false)
public class HHNMetricsControllerTest {

    @isTest
    private static void testAllMetricsCallouts() {
        Test.startTest();

        System.assertEquals(true, HHNMetricsController.logComponentLoaded(), 'Expected Apex Call to always return true');
        System.assertEquals(true, HHNMetricsController.logClickEditMenuDropDown(), 'Expected Apex Call to always return true');
        System.assertEquals(true, HHNMetricsController.logClickJOTCreateNew(), 'Expected Apex Call to always return true');
        System.assertEquals(true, HHNMetricsController.logClickJumpToHousehold(), 'Expected Apex Call to always return true');
        System.assertEquals(true, HHNMetricsController.logClickLoadHistory(), 'Expected Apex Call to always return true');
        System.assertEquals(true, HHNMetricsController.logClickLogToTaskMenuDropdown(), 'Expected Apex Call to always return true');
        System.assertEquals(true, HHNMetricsController.logClickPreferenceGear(), 'Expected Apex Call to always return true');
        System.assertEquals(true, HHNMetricsController.logClickPreferenceSave(), 'Expected Apex Call to always return true');
        System.assertEquals(true, HHNMetricsController.logClickQuickCloseTask(), 'Expected Apex Call to always return true');
        System.assertEquals(true, HHNMetricsController.logClickRefresh(), 'Expected Apex Call to always return true');
        System.assertEquals(true, HHNMetricsController.logClickSearchInput(), 'Expected Apex Call to always return true');
        System.assertEquals(true, HHNMetricsController.logClickSectionItemSubject(), 'Expected Apex Call to always return true');
        System.assertEquals(true, HHNMetricsController.logClickTaskSubject(), 'Expected Apex Call to always return true');
        System.assertEquals(true, HHNMetricsController.logClickLogSubject(), 'Expected Apex Call to always return true');
        System.assertEquals(true, HHNMetricsController.logClickEventSubject(), 'Expected Apex Call to always return true');
        System.assertEquals(true, HHNMetricsController.logClickBillingSubject(), 'Expected Apex Call to always return true');
        System.assertEquals(true, HHNMetricsController.logClickAccountSubject(), 'Expected Apex Call to always return true');
        System.assertEquals(true, HHNMetricsController.logClickCaseSubject(), 'Expected Apex Call to always return true');
        System.assertEquals(true, HHNMetricsController.logClickClaimSubject(), 'Expected Apex Call to always return true');
        System.assertEquals(true, HHNMetricsController.logClickOpportunitySubject(), 'Expected Apex Call to always return true');
        System.assertEquals(true, HHNMetricsController.logClickInsurancePolicySubject(), 'Expected Apex Call to always return true');
        System.assertEquals(true, HHNMetricsController.logClickTodoView(), 'Expected Apex Call to always return true');

        Test.stopTest();
    }

    @isTest
    private static void testCatchStatement() {
        Test.startTest();
        try {
            HHNMetricsController.isCatch = true;
            HHNMetricsController.logComponentLoaded();
            HHNMetricsController.logClickEditMenuDropDown();
            HHNMetricsController.logClickJOTCreateNew();
            HHNMetricsController.logClickJumpToHousehold();
            HHNMetricsController.logClickLoadHistory();
            HHNMetricsController.logClickLogToTaskMenuDropdown();
            HHNMetricsController.logClickPreferenceGear();
            HHNMetricsController.logClickPreferenceSave();
            HHNMetricsController.logClickQuickCloseTask();
            HHNMetricsController.logClickRefresh();
            HHNMetricsController.logClickSearchInput();
            HHNMetricsController.logClickSectionItemSubject();
            HHNMetricsController.logClickTaskSubject();
            HHNMetricsController.logClickLogSubject();
            HHNMetricsController.logClickEventSubject();
            HHNMetricsController.logClickBillingSubject();
            HHNMetricsController.logClickAccountSubject();
            HHNMetricsController.logClickCaseSubject();
            HHNMetricsController.logClickClaimSubject();
            HHNMetricsController.logClickOpportunitySubject();
            HHNMetricsController.logClickInsurancePolicySubject();
            HHNMetricsController.logClickTodoView();
        } catch (Exception e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Expected exception to match.');   
        }
        Test.stopTest();
    }

}