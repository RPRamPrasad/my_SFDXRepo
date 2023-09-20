/** 
* @description task after trigger handler utility test
* @Owner: CATS
*/
@isTest (seeAllData=false)
private class CustomerOnboardingCase_Test {

    @testSetup
    private static void testSetup() {  
        TestUserSetupUtility.setupAllUsers();
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            CaseTestDataUtility.createAccount();
            CaseTestDataUtility.setupAgentRole(TestUserSetupUtility.getAgentUser(), CaseTestDataUtility.getAccount());
        }
    }


    @isTest
    private static void testCustomerOnboardingCase(){
       User agentUser = TestUserSetupUtility.getAgentUser();
       List<String> customTemplateIdList;
       customTemplateIdList = new List<String>();
       List<CustomerOnboardingCase.FlowInputs> flowinputslist = new List<CustomerOnboardingCase.FlowInputs>();
       Test.startTest();
       TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
            flowinputslist = createFlowInputs();
       		CustomerOnboardingCase.setUpOnboardingCase(flowinputslist);
        }
       Test.stopTest();  
       Case onboardingCase = CaseTestDataUtility.retrieveCaseAfterInsert(CustomerOnboardingCase.newCase);
       System.assert(onboardingCase.RecordTypeId == CaseHandlerConstants.CASE_RECORDTYPE_ID_CUSTOMER_ONBOARDING, 'case record type was not onboarding'); 
    }
    
    @TestVisible
    private static List<String> createCustomTempaltes(){
        List<Custom_Template__c> customTemplateList = new List<Custom_Template__c>();
        List<String> customTemplateIdList = new List<String>();
        
        Custom_Template__c customTemplate1 = new Custom_Template__c(
        Custom_Template_Title__c = 'Testing Title',Task_Subject__c = 'Testing Task Subject',Task_Description__c = 'Flow description',
        Due_Date_Number_of_Days_from_Today__c = 3,Task_Priority__c = 'Low',
        Task_Type__c = 'Service',Template_Type__c = 'Onboarding',
        RecordTypeId = Schema.SObjectType.Custom_Template__c.getRecordTypeInfosByDeveloperName().get('New_Corporate_Task_Template').getRecordTypeId());
        customTemplateList.add(customTemplate1);
        
        Custom_Template__c customTemplate2 = new Custom_Template__c(
        Custom_Template_Title__c = 'Testing Title 2',Task_Subject__c = 'Testing Task Subject 2',Task_Description__c = 'Flow description 2',
        Due_Date_Number_of_Days_from_Today__c = 5,Task_Priority__c = 'High',
        Task_Type__c = 'Service',Template_Type__c = 'Onboarding',
        RecordTypeId = Schema.SObjectType.Custom_Template__c.getRecordTypeInfosByDeveloperName().get('New_Corporate_Task_Template').getRecordTypeId());
        customTemplateList.add(customTemplate2);
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            insert customTemplateList;
        }
        String mimicFlowList = (customTemplate1.Id + '; '+ customTemplate2.Id);
        customTemplateIdList.add(mimicFlowList);
        return customTemplateIdList;
    }
    @TestVisible
    private static List<CustomerOnboardingCase.FlowInputs> createFlowInputs(){
       CustomerOnboardingCase.FlowInputs flowinputs = new CustomerOnboardingCase.FlowInputs(); 
       List<CustomerOnboardingCase.FlowInputs> flowinputslist = new List<CustomerOnboardingCase.FlowInputs>();
       flowinputs.corporateTaskTemplateNameList = createCustomTempaltes();
       flowinputs.account = CaseTestDataUtility.getAccount();
       flowinputs.taskAppCode = 'SFDC UI - Account';
       flowinputslist.add(flowinputs);
       
       return flowinputslist;
    }
    
    
}