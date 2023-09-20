/** 
* @description invocable class for New Customer Onboarding flow
* @Owner: CATS
*/
public without sharing class CustomerOnboardingCase{
    
    @TestVisible private static List<Custom_Template__c> mockSelectedCustomTemplates = new List<Custom_Template__c>();
    @TestVisible private static List<FlowOutputs> results = new List<FlowOutputs>();
    @TestVisible private static FlowOutputs result = new FlowOutputs();
	@TestVisible private static List<Custom_Template__c> customTemplateList = new List<Custom_Template__c>();
    @TestVisible private static Case newCase = new Case();
    /**
     * @description setUpOnboardingCase
     * @param flowInputs 
     * @return  `List<FlowOutputs>`
     */
    @InvocableMethod
    public static List<FlowOutputs> setUpOnboardingCase(List<FlowInputs> flowInputs){
        List<String> customTemplateIdList = flowInputs.get(0).corporateTaskTemplateNameList.get(0).split('; ');
        String taskAppCode = flowInputs.get(0).taskAppCode; 
        newCase = createOnboardingCase(flowInputs);
        result.newCaseId = String.valueOf(newCase.Id);
        results.add(result);  
        if(!customTemplateIdList.isEmpty() &&  newCase.Id !=null){
            customTemplateList = getCustomTemplates(customTemplateIdList);
        }     
        if(!customTemplateList.isEmpty()){
            createTasks(customTemplateList, newCase, taskAppCode);
        }
        return results;
    }

    @TestVisible private static Case createOnboardingCase(List<FlowInputs> flowInputs){
        List<Case> onboardingCaseList = new List<Case>();
        Account currentAccount = flowInputs.get(0).account;
        String assignedTo = flowInputs.get(0).assignedTo;
        String opportunityId = flowInputs.get(0).relatedOpportunityId;
        if(currentAccount != null){
            CaseFactoryCustomerOnboarding caseFactory = new CaseFactoryCustomerOnboarding();
            caseFactory.setAssignedTo(assignedTo);
            caseFactory.setRelatedOpportunityId(opportunityId);
            onboardingCaseList.add(caseFactory.buildCase(currentAccount, UserInfo.getUserId()));
			SObjectAccessDecision accessDecision = Security.stripInaccessible(AccessType.CREATABLE, onboardingCaseList, true);
            newCase = (Case)accessDecision.getRecords().get(0);
            insert accessDecision.getRecords(); 
        }
        return newCase;
    }
    
    @TestVisible private static List<Custom_Template__c> getCustomTemplates(List<String> templateIds){ 
    	List<Custom_Template__c> selectedCustomTemplates = Security.stripInaccessible(AccessType.READABLE,
                                                                                     [SELECT Id, Task_Subject__c , Task_Description__c,Task_Due_Date__c, 
                                                                                      Task_Category__c, Task_Subcategory__c, Task_Priority__c, Task_Type__c
                                                                                      FROM Custom_Template__c
                                                                                      WHERE Id In: templateIds]).getRecords();
        if(Test.isRunningTest() && UnitTestDataUtility.isUnitTest){
            selectedCustomTemplates = mockSelectedCustomTemplates;
        }
        return selectedCustomTemplates;

    }
    
    @TestVisible private static void createTasks(List<Custom_Template__c> customTemplates, Case caseRecord, String taskAppCode){
        List<Task> taskList = new List<Task>();
        for(Custom_Template__c customTemplate : customTemplates){
            Task taskRecord = new Task();
            TaskFactoryTask myTaskFactory = new TaskFactoryTask();    
            myTaskFactory.setCustomTemplateId(customTemplate.Id)
                .setActivityDate(customTemplate.Task_Due_Date__c)
                .setPriority(customTemplate.Task_Priority__c)
                .setSubject(customTemplate.Task_Subject__c)
                .setDescription(customTemplate.Task_Description__c)
                .setTaskCategory(customTemplate.Task_Category__c)
                .setTaskSubCategory(customTemplate.Task_Subcategory__c)
                .setTaskType(customTemplate.Task_Type__c)
                .setAppCode(taskAppCode)
                .setOwnerId(caseRecord.OwnerId)
                .setWhoId(caseRecord.ContactId)
                .setWhatId(caseRecord.Id)
                .setLineOfBusiness(caseRecord.LOB__c)
                .setAssignedTo(caseRecord.Assigned_To__c);
            taskRecord = myTaskFactory.returnTask();
            taskRecord.IsTaskCreatedWhenCaseCreated__c = true;
            taskRecord.Status = 'Not Started';
            taskList.add(taskRecord);
        }
            insert Security.stripInaccessible(AccessType.CREATABLE, taskList, true).getRecords();
    }
    
    /** 
	* @description flow inputs 
	* @Owner: CATS
	*/
    public with sharing class FlowInputs{ 
        @InvocableVariable
        public List<String> corporateTaskTemplateNameList;

        @InvocableVariable
        public Account account;
        
        @InvocableVariable
        public String taskAppCode;
        
        @InvocableVariable
        public String assignedTo;

		@InvocableVariable
        public String relatedOpportunityId;
        
    }
    
    
	/** 
	* @description flow outputs 
	* @Owner: CATS
	*/
    public with sharing class FlowOutputs{       
        @InvocableVariable
        public String newCaseId;
    }


}