@isTest(seeAllData=false)
private class JustOneThingUtilitiesTest {
    @isTest
    private static void testSetTaskTypeServiceBillingAccount(){
        Test.startTest();
        String result = JustOneThingUtilities.setTaskType(Billing_Account__c.getSObjectType());
        System.assert(result == TaskHandlerConstants.TASK_TYPE_SERVICE, 'ASSERT_FAILED: Result was not Service');
        Test.stopTest();
    }

    @isTest
    private static void testSetTaskTypeServiceCase(){
        Test.startTest();
        String result = JustOneThingUtilities.setTaskType(Case.getSObjectType());
        System.assert(result == TaskHandlerConstants.TASK_TYPE_SERVICE, 'ASSERT_FAILED: Result was not Service');
        Test.stopTest();
    }

    @isTest
    private static void testSetTaskTypeServiceAccount(){
        Test.startTest();
        String result = JustOneThingUtilities.setTaskType(Account.getSObjectType());
        System.assert(result == TaskHandlerConstants.TASK_TYPE_SERVICE, 'ASSERT_FAILED: Result was not Service');
        Test.stopTest();
    }
    
    @isTest
    private static void testSetTaskTypeSales(){
        Test.startTest();
        String result = JustOneThingUtilities.setTaskType(Opportunity.getSObjectType());
        System.assert(result == TaskHandlerConstants.TASK_TYPE_SALES, 'ASSERT_FAILED: Result was not Sales');
        Test.stopTest();
    }
    
    @isTest
    private static void testSetTaskTypeBlank(){
        Test.startTest();
        String result = JustOneThingUtilities.setTaskType(Task.getSObjectType());
        System.assert(String.isEmpty(result), 'ASSERT_FAILED: Result was not empty');
        Test.stopTest(); 
    }
}
