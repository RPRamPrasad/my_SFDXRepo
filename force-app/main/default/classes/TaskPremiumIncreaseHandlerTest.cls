/** 
* @description Handles
* @Owner: Astro
*/
@isTest
(seeAllData = false)
private class TaskPremiumIncreaseHandlerTest {
    
    private static Task mockTaskRecord = UnitTestDataUtility.buildTask(false);
    private static List<Task> mockTaskList = new List<Task>();
    
    @isTest
    private static void testHandleNonPremiumIncreaseTask(){
        Test.startTest();
        
        UnitTestDataUtility.isUnitTest = true;

        // Init normal task.
        mockTaskRecord.AppCode__c = '';
        mockTaskRecord.Subject = '';
        mockTaskList.add(mockTaskRecord);

        TaskPremiumIncreaseHandler.handlePremiumIncrease(mockTaskList);
        System.assertEquals(mockTaskRecord.PremiumChangeDescription__c, null, 'PremiumChangeDescription__c should be empty.');
        System.assertEquals(mockTaskRecord.PremiumChangeAmount__c, null, 'PremiumChangeAmount__c should be empty.');
        System.assertEquals(mockTaskRecord.PremiumChangeRate__c, null, 'PremiumChangeRate__c should be empty.');

        Test.stopTest();
    }

    @isTest
    private static void testHandlePremiumIncreaseTask(){
        Test.startTest();
        
        UnitTestDataUtility.isUnitTest = true;

        // Init complete premium increase task.
        mockTaskRecord.AppCode__c = 'BOD - Auto Extracts';
        mockTaskRecord.Subject = 'BOD Premium Increase';
        mockTaskRecord.Description = 'The premium for this policy increased by $123.45. This represents a premium increase of 15%. Before calling the Personal Lines Call Center, reference the following four resources and review each item listed in the attached checklist to determine the changes or events that may have impacted the auto renewal premium. 1. Review household activities to see what occurred around the date of change. 2. Check NECHO for abbreviated messages for discounts or losses. 3. Review discrepancies between current and prior renewal notices via customer\'s household page>Marketing>Direct Mail>Customer Document Center 4. For further information on each item, consult the Auto Answers Tool. (May not apply to all states) *Checklist can be accessed by selecting the work item link within the follow up.';
        mockTaskList.add(mockTaskRecord);

        TaskPremiumIncreaseHandler.handlePremiumIncrease(mockTaskList);
        System.assertEquals(mockTaskRecord.PremiumChangeDescription__c, 'BOD Premium Increase', 'PremiumChangeDescription__c should be empty.');
        System.assertEquals(mockTaskRecord.PremiumChangeAmount__c, 123.45, 'PremiumChangeAmount__c should be non-empty.');
        System.assertEquals(mockTaskRecord.PremiumChangeRate__c, 15, 'PremiumChangeRate__c should be non-empty.');

        Test.stopTest();
    }

    @isTest
    private static void testHandlePremiumIncreaseTaskMatchAmount(){
        Test.startTest();
        
        UnitTestDataUtility.isUnitTest = true;

        // Init complete premium increase task.
        mockTaskRecord.AppCode__c = 'BOD - Auto Extracts';
        mockTaskRecord.Subject = 'BOD Premium Increase';
        mockTaskRecord.Description = 'The premium for this policy increased by $123.45. Before calling the Personal Lines Call Center, reference the following four resources and review each item listed in the attached checklist to determine the changes or events that may have impacted the auto renewal premium. 1. Review household activities to see what occurred around the date of change. 2. Check NECHO for abbreviated messages for discounts or losses. 3. Review discrepancies between current and prior renewal notices via customer\'s household page>Marketing>Direct Mail>Customer Document Center 4. For further information on each item, consult the Auto Answers Tool. (May not apply to all states) *Checklist can be accessed by selecting the work item link within the follow up.';
        mockTaskList.add(mockTaskRecord);

        TaskPremiumIncreaseHandler.handlePremiumIncrease(mockTaskList);
        System.assertEquals(mockTaskRecord.PremiumChangeDescription__c, 'BOD Premium Increase', 'PremiumChangeDescription__c should be empty.');
        System.assertEquals(mockTaskRecord.PremiumChangeAmount__c, null, 'PremiumChangeAmount__c should be empty.');
        System.assertEquals(mockTaskRecord.PremiumChangeRate__c, null, 'PremiumChangeRate__c should be empty.');

        Test.stopTest();
    }

    @isTest
    private static void testHandlePremiumIncreaseTaskMatchRateChange(){
        Test.startTest();
        
        UnitTestDataUtility.isUnitTest = true;

        // Init complete premium increase task.
        mockTaskRecord.AppCode__c = 'BOD - Auto Extracts';
        mockTaskRecord.Subject = 'BOD Premium Increase';
        mockTaskRecord.Description = 'This represents a premium increase of 15%. Before calling the Personal Lines Call Center, reference the following four resources and review each item listed in the attached checklist to determine the changes or events that may have impacted the auto renewal premium. 1. Review household activities to see what occurred around the date of change. 2. Check NECHO for abbreviated messages for discounts or losses. 3. Review discrepancies between current and prior renewal notices via customer\'s household page>Marketing>Direct Mail>Customer Document Center 4. For further information on each item, consult the Auto Answers Tool. (May not apply to all states) *Checklist can be accessed by selecting the work item link within the follow up.';
        mockTaskList.add(mockTaskRecord);

        TaskPremiumIncreaseHandler.handlePremiumIncrease(mockTaskList);
        System.assertEquals(mockTaskRecord.PremiumChangeDescription__c, 'BOD Premium Increase', 'PremiumChangeDescription__c should be empty.');
        System.assertEquals(mockTaskRecord.PremiumChangeAmount__c, null, 'PremiumChangeAmount__c should be empty.');
        System.assertEquals(mockTaskRecord.PremiumChangeRate__c, null, 'PremiumChangeRate__c should be empty.');

        Test.stopTest();
    }

    @isTest
    private static void testHandlePremiumIncreaseTaskNoMatch(){
        Test.startTest();
        
        UnitTestDataUtility.isUnitTest = true;

        // Init complete premium increase task.
        mockTaskRecord.AppCode__c = 'BOD - Auto Extracts';
        mockTaskRecord.Subject = 'BOD Premium Increase';
        mockTaskRecord.Description = 'Before calling the Personal Lines Call Center, reference the following four resources and review each item listed in the attached checklist to determine the changes or events that may have impacted the auto renewal premium. 1. Review household activities to see what occurred around the date of change. 2. Check NECHO for abbreviated messages for discounts or losses. 3. Review discrepancies between current and prior renewal notices via customer\'s household page>Marketing>Direct Mail>Customer Document Center 4. For further information on each item, consult the Auto Answers Tool. (May not apply to all states) *Checklist can be accessed by selecting the work item link within the follow up.';
        mockTaskList.add(mockTaskRecord);

        TaskPremiumIncreaseHandler.handlePremiumIncrease(mockTaskList);
        System.assertEquals(mockTaskRecord.PremiumChangeDescription__c, 'BOD Premium Increase', 'PremiumChangeDescription__c should be empty.');
        System.assertEquals(mockTaskRecord.PremiumChangeAmount__c, null, 'PremiumChangeAmount__c should be empty.');
        System.assertEquals(mockTaskRecord.PremiumChangeRate__c, null, 'PremiumChangeRate__c should be empty.');

        Test.stopTest();
    }
}