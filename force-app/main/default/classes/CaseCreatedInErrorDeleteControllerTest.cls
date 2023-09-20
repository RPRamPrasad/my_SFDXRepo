/** 
* @description CaseCreatedInErrorDeleteController unit tests
* @Owner: CATS
*/

@isTest
(seeAllData=false)

private class CaseCreatedInErrorDeleteControllerTest {
    
    @TestSetup
    private static void testSetup(){
        TestUserSetupUtility.setupAllUsers();
    }
    
    @isTest
    private static void canGetRelatedRecords() {
        Test.startTest();
		User agent = TestUserSetupUtility.getAgentUser();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agent);
        List<SObject> relatedRecords;
        Case newCase;
        Task taskRecord;
        Event newEvent;
        Case_Note__c caseNoteRecord;
        System.runAs(agent){
            newCase=new Case(subject='test');
           	insert newCase;
       		taskRecord = new Task(Subject='test', WhatId=newCase.Id, Status='Completed');
            insert taskRecord;         
			newEvent=new Event(Subject = 'tst sbjct', DurationInMinutes=10, ActivityDateTime = Datetime.now(), WhatId=newCase.Id);
            insert newEvent;
            caseNoteRecord=new Case_Note__c(name='new Note', Comments__c='comments', Case__c=newCase.Id, case__r=newCase);
            insert caseNoteRecord;
            relatedRecords=CaseCreatedInErrorDeleteController.getRelatedRecords(newCase.Id);
        }
        System.assertEquals(4, relatedRecords.size(), 'Related Records size should be 4');

        for(SObject relatedRecord:relatedRecords){
            if(relatedRecord instanceOf Case){
                Case relatedCase = (Case) relatedRecord;
                System.assertEquals(newCase.Id,relatedCase.id,'Case Ids should be equal');
                System.assertEquals(newCase.AccountId, relatedCase.AccountId, 'Account Ids should be equal');
            }
            if(relatedRecord instanceOf Task){
                Task relatedTask = (Task) relatedRecord;
                System.assertEquals(taskRecord.Id, relatedTask.Id, 'Task Ids should be equal');
                System.assert(relatedTask.IsClosed, 'Task should be closed');
            }
            if(relatedRecord instanceOf Event){
                Event relatedEvent = (Event) relatedRecord;
                System.assertEquals(newEvent.id, relatedEvent.id, 'Event Ids should be equal');
            }
            if(relatedRecord instanceOf Case_Note__c){
                Case_Note__c relatedNote = (Case_Note__c) relatedRecord;
                System.assertEquals(caseNoteRecord.id, relatedNote.id, 'Case Note ids should be equal');
            }
        }
        Test.stopTest();
        
    }
    
    @isTest
    private static void noCaseFoundReturnsEmptyList(){
        Test.startTest();
        List<SObject> relatedRecords = CaseCreatedInErrorDeleteController.getRelatedRecords(new Case(subject='test').Id);
		System.assert(relatedRecords.isEmpty(), 'relatedRecords should be empty');
        Test.stopTest();
    }
    
    @isTest
    private static void canDeleteErrorCase() {
        Test.startTest();
		User agent = TestUserSetupUtility.getAgentUser();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agent);
		Case newCase;     
        System.runAs(agent){
            newCase=new Case(subject='test');
           	insert newCase;
            Case searchedCaseBeforeDelete=[Select Id, Subject FROM Case WHERE id =: newCase.id];
            System.assertEquals(newCase.id,searchedCaseBeforeDelete.id,'Case should have been returned');
            List<Case> casesToDelete= new List<Case>();
            casesToDelete.add(newCase);
            CaseCreatedInErrorDeleteController.deleteErrorCase(casesToDelete);
        }
        List<Case> casesAfterDelete = [Select Id, Subject FROM Case WHERE id =: newCase.id];      
        System.assert(casesAfterDelete.isEmpty(), 'Case should have been deleted and no records returned');
        Test.stopTest();       
    }
      
}