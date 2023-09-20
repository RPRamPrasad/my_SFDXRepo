@isTest(seeAllData = false)
public class CustomTemplateTriggerHelper_Test {

    
    
    @isTest
    public static void testCustomTemplateSPICheckInTrigger(){
        UTIL_CaseTestData.setUpSystemUserRecordOwnerOnly();
        Id systemRecordOwnerId = SystemRecordOwnerDetails.getSystemRecordOwnerId();
        Custom_Template__c customTemplate = new Custom_Template__c();
        customTemplate.Custom_Template_Title__c = 'Test SPI before Update Title';
        customTemplate.Task_Subject__c = 'Testing';
        customTemplate.RecordTypeId = Schema.SObjectType.Custom_Template__c.getRecordTypeInfosByDeveloperName().get('New_Corporate_Task_Template').getRecordTypeId();
        insert customTemplate;
        Custom_Template__c customTemplateAfterInsert = [SELECT Id FROM Custom_Template__c Where Custom_Template_Title__c = 'Test SPI before Update Title' LIMIT 1];
        customTemplateAfterInsert.Custom_Template_Title__c = 'Checking Update';
        update customTemplateAfterInsert;
        Custom_Template__c customTemplateAfterUpdate = [SELECT Id, OwnerId, Custom_Template_Title__c FROM Custom_Template__c Where Task_Subject__c = 'Testing' LIMIT 1];
        System.assertEquals(systemRecordOwnerId, customTemplateAfterUpdate.OwnerId, 'Owner Was Not System Record Owner');
    }
    
}