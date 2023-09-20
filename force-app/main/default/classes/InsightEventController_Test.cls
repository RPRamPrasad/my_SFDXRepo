/**
 * @description This class is used to capture usage events on Insights/Indicators component
 * @Date: 07/10/2023
 * @author: Team Skynet
 */

 @isTest(SeeAllData=false)
 public with sharing class InsightEventController_Test {
     @isTest
     private static void testAllshowEvents() {
        User sysAdminUser = TestDataFactory_User_Wrapper.generateSystemAdministratorUser('TEST', '12345678915');
        System.runAs(sysAdminUser){
        System.assert(InsightEventController.showAutoPropensityIndicator(),true);
        System.assert(InsightEventController.showBillPastDueIndicator(),true);
        System.assert(InsightEventController.showTotalLossIndicator(),true);
        System.assert(InsightEventController.showADTIndicator(),true);
        System.assert(InsightEventController.showAdditionalInfo(),true);
        }
     }
 }