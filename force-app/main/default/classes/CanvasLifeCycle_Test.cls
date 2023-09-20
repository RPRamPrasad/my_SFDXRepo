/**
* Author : Team Poseidon
* Date Created : 05/02/2019
* @description : Test class for the CanvasLifeCycle class
*/
@isTest
public with sharing class CanvasLifeCycle_Test {
    
    private static User agentUser {get;set;}
    private static Case caseRecord {get;set;}
    private static String transactionType {get;set;}
    
    private static Case setUpCase(){
        caseRecord = new Case();
        caseRecord.Status = 'new';
        caseRecord.PolicyNumber__c = '6736858A1413G';
        caseRecord.LOB__c = 'Auto';
        return caseRecord;
    }
    
    @isTest
    static void testDefaultMockValues(){
        // Test handler using the default mock RenderContext Canvas.Test creates
        CanvasLifeCycle handler = new CanvasLifeCycle();
        User systemAdminUser = TestDataFactory_User_Wrapper.generateSystemAdministratorUser('TEST', '12345678913');
        System.runAs(systemAdminUser){
        handler.excludeContextTypes();
        Canvas.Test.testCanvasLifecycle(handler,null);
        }
        System.assertNotEquals(null, handler, 'Canvas handler should not be null.');
    }  
}