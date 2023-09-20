/*
 * Test class for Event Before Delete trigger
 * @author Team Choo Choo
 * @owner Team Stark
 * @createdDate 4/18/2016
 */
@isTest
private class AP_EventBeforeDelete_TEST {

    //Method to validate system admin to delete event record after setting up trigger bypass settings
    @isTest
    static void testAllowAdminToDeleteEvent() {
        User sysAdminUser = UTIL_CreateCustomerTestData.createUserWithAssoId('System Administrator', 'test', 'test123', 'test123', 'test123');
        insert sysAdminUser;
        
        CS001_ByPassTriggerAtoF__c byPassCS = new CS001_ByPassTriggerAtoF__c();
        byPassCS.Override_EventBeforeDelete__c = true;
        byPassCS.SetupOwnerId = sysAdminUser.Id;
        insert byPassCS;
        
        Event delEvent = UTIL_ActivityTestData.createEvent('Call');
        insert delEvent;
        
        Test.startTest();
            System.runAs(sysAdminUser) {
                delete delEvent;
                Event[] eventList = [Select Id from Event];
                System.assertEquals(0, eventList.size(), 'Size of \'eventList\' is not equals to 0');
            }
        Test.stopTest();
    }
    
    //Method to validate agent is prevented from deleting event record
    @isTest
    static void testPreventAgentFromDeleteEvent() {
        User agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'test', 'test123', 'test123', 'test123');
        insert agentUser;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        
        Event delEvent = UTIL_ActivityTestData.createEvent('Call');
        
        Test.startTest();
            System.runAs(agentUser) {
                insert delEvent;
                try {
                    Database.DeleteResult delResult = Database.delete(delEvent);
                    System.assertEquals(false, delResult.isSuccess(), ' Method \'isSuccess\' returns true');
                }
                catch(DMLException dmlExp) {
                    System.assert(dmlExp.getMessage().contains(Label.CL_EventPreventDeleteMsg), '\'dmlExp\' does not contains \'CL_EventPreventDeleteMsg\'');
                }                Event[] eventList = [Select Id from Event];
                System.assertEquals(1, eventList.size(), 'Size of \'eventList\' is not equals to 1');
            }
        Test.stopTest();
    }
    
    //Method to validate ATM is prevented from deleting event records
    @isTest
    static void testPreventATMFromDeleteEvent() {
        User agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.01 Agent Team Member', 'test', 'test123', 'test123', 'test123');
        insert agentUser;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        
        Event delEvent1 = UTIL_ActivityTestData.createEvent('Call');
        Event delEvent2 = UTIL_ActivityTestData.createEvent('Email');
        List<Event> eventList = new List<Event>{delEvent1, delEvent2};
        
        Test.startTest();
            System.runAs(agentUser) {
                insert eventList;
                try {
                    Database.DeleteResult[] delResults = Database.delete(eventList);
                    System.assertEquals(false, delResults[0].isSuccess(), 'Method \'isSuccess\' returns true');
                    System.assertEquals(false, delResults[1].isSuccess(), 'Method \'isSuccess\' returns true');
                }
                catch(DMLException dmlExp) {
                    System.assert(dmlExp.getMessage().contains(Label.CL_EventPreventDeleteMsg), '\'dmlExp\' does not contains \'CL_EventPreventDeleteMsg\'');
                }
                Event[] dbEventList = [Select Id from Event];
                System.assertEquals(2, dbEventList.size(), 'Size of \'dbEventList\' is not equals to 2');
            }
        Test.stopTest();
    }
}