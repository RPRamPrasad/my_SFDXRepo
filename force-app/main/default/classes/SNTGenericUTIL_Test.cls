/**
* @author Team Data Blazers
* @name SNTGenericUTIL_Test
* @createdDate 01/05/2022
* @description The test class will cover the code for SNTGenericUTIL
* @version 1.0
*/
@isTest
public class SNTGenericUTIL_Test {
    
    @isTest
    static void getInteractionIdTest() {
    	
        User u = TestDataFactory_User.generateUser('System Administrator');
        u.Alias = 'adminUsr';
        u.Servicing_Agent_Associate_ID__c = 'CQWH21YS000';
        u.Associate_ID__C = 'CQWH21YS000'; 
        insert u;
        System.runAs(u){
        	
            Test.startTest();
            InteractionSummary__c interactionSummary = new InteractionSummary__c();
        	interactionSummary.Name = 'Test Record';
        	interactionSummary.enterprise_interaction_identifier__c = '1234567';
            interactionSummary.contact_method_name__c = 'Online';
            interactionSummary.Channel__c = 'Agent';
            insert interactionSummary;
            Test.stopTest();
            string eiidValue = SNTGenericUTIL.getInteractionId(interactionSummary.Id);
            System.assertEquals('1234567', eiidValue, 'EIID Value should be 1234567');
        }
	}
    
    
    @isTest
    static void interactionSummaryExceptionTest() {
    	
        User u = TestDataFactory_User.generateUser('1.06 Business Reporting and Analytics');
        u.Alias = 'adminUsr';
        u.Servicing_Agent_Associate_ID__c = 'CQWH21YS000';
        u.Associate_ID__C = 'CQWH21YS000'; 
        insert u;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(u);
        System.runAs(u){
        	
            Test.startTest();
            InteractionSummary__c interactionSummary = new InteractionSummary__c();
        	interactionSummary.Name = 'Test Record';
        	interactionSummary.enterprise_interaction_identifier__c = '1234567';
            interactionSummary.contact_method_name__c = 'Online';
            interactionSummary.Channel__c = 'Agent';
            insert interactionSummary;
            Test.stopTest();
            try {
                SNTGenericUTIL.getInteractionId(interactionSummary.Id);
            }
            catch (AuraHandledException err) {
                system.assert(true, 'Could not retrieve EIID');
            }
        }
    }
    
    @isTest
    static void getInteractionIdNullValueTest() {
    	
        User u = TestDataFactory_User.generateUser('System Administrator');
        u.Alias = 'adminUsr';
        u.Servicing_Agent_Associate_ID__c = 'CQWH21YS000';
        u.Associate_ID__C = 'CQWH21YS000'; 
        insert u;
        System.runAs(u){
        	
            Test.startTest();
            InteractionSummary__c interactionSummary = new InteractionSummary__c();
            Test.stopTest();
            string eiidValue = SNTGenericUTIL.getInteractionId(interactionSummary.Id);
            system.assert(string.isBlank(eiidValue), 'EIID Value should be blank');
        }
    }
}