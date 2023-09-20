@isTest
(seeAllData=false)
private class EventTriggerHandlerTest {

    private static Event mockEvent = new Event();
    private static List<Event> mockEventList = new List<Event>();
    
    @isTest
    private static void testPreventEventDelete(){
        Test.startTest();
        UnitTestDataUtility.isUnitTest = true;
        mockEventList.add(mockEvent);
        try{
            EventTriggerHandler.preventEventDelete(mockEventList);
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('You are not permitted to delete this event') ? true : false;
			System.AssertEquals(expectedExceptionThrown, true, 'expectedExceptionThrown is false');
        }
        Test.stopTest();
    }
    
}