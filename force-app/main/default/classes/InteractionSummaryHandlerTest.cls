/**
* @Author: Team Trailblazers
* @owner: Team Trailblazers
* @description : This class will cover InteractionSummaryHandler 
* @createdDate: 01/05/2022
* @version 1.0
*/
@isTest
public class InteractionSummaryHandlerTest {
	@isTest
    static void populateHouseholdInteractionSummaryTest() {
    	CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=true);
        insert passTriggerAll;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        
        ID hhRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        ID individualRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();

        User u = TestDataFactory_User.generateUser('System Administrator');
        u.Alias = 'adminUsr';
        u.Servicing_Agent_Associate_ID__c = 'CQWH21YS000';
        u.Associate_ID__C = 'CQWH21YS000'; 
        insert u;
        System.runAs(u){
        	Account householdAccount = new Account(Name = 'Household',  AllowHousehold__c  = true, ClientIdentifier__c  = '123456789', RecordtypeId = hhRecordId);
            insert householdAccount ; 
            Account individualAccountRecord = new Account(FirstName = 'testF1',LastName = 'testL1', RecordtypeId = individualRecordId, ClientIdentifier__c  = '12345678901', Primary_Household__pc = householdAccount.Id);
            insert individualAccountRecord ;
            Account newIndividualAccountRecord = new Account(FirstName = 'testF2',LastName = 'testL2', RecordtypeId = individualRecordId, ClientIdentifier__c  = '12345678902', Primary_Household__pc = householdAccount.Id);
            insert newIndividualAccountRecord ; 
            
            delete passTriggerAll; 
            
            Test.startTest();
            InteractionSummary__c interactionSummary = new InteractionSummary__c();
        	interactionSummary.Name = 'Test Record';
        	interactionSummary.enterprise_interaction_identifier__c = '1234567';
            interactionSummary.contact_method_name__c = 'Online';
            interactionSummary.Channel__c = 'Agent';
            interactionSummary.Customer__c = individualAccountRecord.Id;
            insert interactionSummary;
            
            interactionSummary.Customer__c = newIndividualAccountRecord.Id;
            update interactionSummary;
            
            InteractionSummaryHandler.updateInteractionSummaryHHId(individualAccountRecord, new List<InteractionSummary__c>{interactionSummary});
            Test.stopTest();
            
            System.assertEquals(newIndividualAccountRecord.Id, 
                                [SELECT Customer__c FROM InteractionSummary__c WHERE Name = 'Test Record' LIMIT 1].Customer__c, 
                                'Customer__c will be newIndividualAccountRecord record Id');
        }
	}
    
    @isTest
    static void byPassTriggerFalseInteractionSummaryTest() {
    	CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=true);
        insert passTriggerAll;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        
        ID hhRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        ID individualRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();

        User u = TestDataFactory_User.generateUser('System Administrator');
        u.Alias = 'adminUsr';
        u.Servicing_Agent_Associate_ID__c = 'CQWH21YS000';
        u.Associate_ID__C = 'CQWH21YS000'; 
        insert u;
        System.runAs(u){
        	Account householdAccount = new Account(Name = 'Household',  AllowHousehold__c  = true, ClientIdentifier__c  = '123456789', RecordtypeId = hhRecordId);
            insert householdAccount ; 
            Account individualAccountRecord = new Account(FirstName = 'testF1',LastName = 'testL1', RecordtypeId = individualRecordId, ClientIdentifier__c  = '12345678901', Primary_Household__pc = householdAccount.Id);
            insert individualAccountRecord ;
            Account newIndividualAccountRecord = new Account(FirstName = 'testF2',LastName = 'testL2', RecordtypeId = individualRecordId, ClientIdentifier__c  = '12345678902', Primary_Household__pc = householdAccount.Id);
            insert newIndividualAccountRecord ; 

            Test.startTest();
            InteractionSummary__c interactionSummary = new InteractionSummary__c();
        	interactionSummary.Name = 'Test Record';
        	interactionSummary.enterprise_interaction_identifier__c = '1234567';
            interactionSummary.contact_method_name__c = 'Online';
            interactionSummary.Channel__c = 'Agent';
            interactionSummary.Customer__c = individualAccountRecord.Id;
            interactionSummary.Primary_Household__c = individualAccountRecord.Id;
            insert interactionSummary;
            Test.stopTest();
            
            System.assertEquals(individualAccountRecord.Id, 
                                [SELECT Primary_Household__c FROM InteractionSummary__c WHERE Name = 'Test Record' LIMIT 1].Primary_Household__c, 
                                'Primary_Household__c will not change as Override_All__c=true');
        }
	}
}