/*
 	* Author : Team Bisbee
    * Date Created : 01/09/2019
    * Description : This class is used to query the Alerts based on the page you are on.
    * Modified By: Team QuadCore 02/07/2019
*/
@isTest
public with sharing class CMP_AlertToastController_Test {

    private static final String NEW_STATUS = 'New';
    @isTest
    private static void testFindCaseNotesWithAlerts(){       
        Test.startTest();
        Case newcase = createCaseWithStatus(NEW_STATUS, UTIL_CaseTestData.contactId());       
        Case_Note__c caseNote = new Case_Note__c();		
		caseNote.Name='demo';
		caseNote.Comments__c = 'Comment is added';
        caseNote.Case__c = newcase.Id;
        caseNote.Alert__c = true;
		insert caseNote;   
        Boolean showToast = CMP_AlertToastController.showAlertToast(caseNote.Case__c);	
        System.assert( showToast,'showToast is'+showToast);
        Test.stopTest();      
    }   
    
    private static Case createCaseWithStatus(String status, Id contactId){
        Case caseRecord = new Case(Status = status, ContactId = contactId);
        insert caseRecord;     
        return caseRecord;
    }   
}