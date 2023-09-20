@isTest
(seeAllData=false)
public class SR_EventIdHandlerTest {

    
    private static SR_Payload payload = SR_TestDataUtility.getBasicPayload();
    private static Integer indexNumber = 2;
    private static String requestId = '2345HKSDFISF_353L';
    
    @isTest
    private static void testConstructor(){
        Test.startTest();
        SR_EventIdHandler handler = new SR_EventIdHandler(payload, indexNumber, requestId);
        System.assertEquals(payload, handler.payload, 'payload was not set properly');
        System.assertEquals(requestId + '_' + indexNumber, handler.eventId, 'eventId was not set properly');
        Test.stopTest();
    }
    
    
    @isTest
    private static void testSetIndexNumbersWithoutDefaults(){
        Test.startTest();
        payload.defaults = null;
        setupAllSObjects();
        SR_EventIdHandler handler = new SR_EventIdHandler(payload, indexNumber, requestId);
        payload = handler.setEventIds();
        System.assertEquals(payload.caseRecord.Event_Id__c, handler.eventId, 'event on case was not set properly');
        System.assertEquals(payload.taskRecord.Event_Id__c, handler.eventId, 'event on task was not set properly');
        System.assertEquals(payload.logRecord.Event_Id__c, handler.eventId, 'event on log was not set properly');
        Test.stopTest();
    }
    
    @isTest
    private static void testSetIndexNumbersWithDefaults(){
        Test.startTest();
        setupAllSObjects();
        setupAllDefaultSObjects();
        SR_EventIdHandler handler = new SR_EventIdHandler(payload, indexNumber, requestId);
        payload = handler.setEventIds();
        System.assertEquals(payload.caseRecord.Event_Id__c, handler.eventId, 'event on case was not set properly');
        System.assertEquals(payload.taskRecord.Event_Id__c, handler.eventId, 'event on task was not set properly');
        System.assertEquals(payload.logRecord.Event_Id__c, handler.eventId, 'event on log was not set properly');
        System.assertEquals(payload.defaults.caseRecord.Event_Id__c, handler.eventId, 'event on default case was not set properly');
        System.assertEquals(payload.defaults.taskRecord.Event_Id__c, handler.eventId, 'event on default task was not set properly');
        System.assertEquals(payload.defaults.logRecord.Event_Id__c, handler.eventId, 'event on default log was not set properly');
        Test.stopTest();
    }
    
    private static void setupAllSObjects(){
        if(payload.caseRecord == null){
            payload.caseRecord = new Case();
        }
        if(payload.taskRecord == null){
            payload.taskRecord = new Task();
        }
        if(payload.logRecord == null){
            payload.logRecord = new Task();
        }
    }
    
    private static void setupAllDefaultSObjects(){
        if(payload.defaults == null){
           payload.defaults = new SR_Defaults();
        }
        if(payload.defaults.caseRecord == null){
            payload.defaults.caseRecord = new Case();
        }
        if(payload.defaults.taskRecord == null){
            payload.defaults.taskRecord = new Task();
        }
        if(payload.defaults.logRecord == null){
            payload.defaults.logRecord = new Task();
        }
    }
    
}