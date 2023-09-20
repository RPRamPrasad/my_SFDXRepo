/**
         * @description TaskCreationController
         */
public with sharing class TaskCreationController {
    private static final String CLASS_NAME = 'TaskCreationController';
    private static final String METHOD_NAME = 'createTasks';
    private static final String PREFERENCE_NAME = 'Templates';
/**
         * @description TaskCreationRequest
         */
    public with sharing class TaskCreationRequest{
       @AuraEnabled
       /**
         * @description taskBasicDetails
         */
       public List<Map<String,String>> taskBasicDetails{get;set;}
       @AuraEnabled
       /**
         * @description relationFieldName
         */
       public String relationFieldName {get; set;} 
       @AuraEnabled
       /**
         * @description relationId
         */
       public String relationId {get; set;} 
       @AuraEnabled
       /**
         * @description userIdsToAssign
         */
       public List<String> userIdsToAssign {get; set;} 
       @AuraEnabled
       /**
         * @description lob 
         */
       public String lob {get; set;} 
       @AuraEnabled
       /**
         * @description whoid
         */
       public String whoid {get; set;} 
    }
  /**
         * @description TaskCreationResponse
         */
    public with sharing class TaskCreationResponse{
        @AuraEnabled
        /**
         * @description success
         */
        public Boolean success {get;set;}
        @AuraEnabled
        /**
         * @description errorMessage
         */
        
        public String errorMessage {get;set;}
        @AuraEnabled
        /**
         * @description ids
         */
        
        public List<String> ids {get;set;}
    }

    @AuraEnabled(cacheable = true)
    /**
     * @description getCustomTemplatesByTemplateType
     * @param templateType 
     * @return  `List<Custom_Template__c>`
     */
    
    public static List<Custom_Template__c> getCustomTemplatesByTemplateType(String templateType){
        return TaskCreationDAO.getCustomTemplatesByTemplateType(templateType);
    }

    @AuraEnabled
    /**
     * @description createTasks
     * @param taskCreationRequest 
     * @return  `TaskCreationResponse`
     */
    
    public static TaskCreationResponse createTasks(TaskCreationRequest taskCreationRequest){

        TaskCreationResponse response = new TaskCreationResponse();
        Set<ID> userIds = listOfStringToSetOfId(taskCreationRequest.userIdsToAssign);
        List<Task> tasks = createTasks(taskCreationRequest,userIds);
        
        List<Database.SaveResult> results;
        try{
            results = Database.insert(tasks);
            
            response.success = allSaveResultsAreSuccess(results);
            response.ids = getIdsFromSaveResults(results);
        }catch(Exception taskException){
            response.success = false;
            response.errorMessage = taskException.getMessage();
            LoggingService.logHandledException(taskException, CLASS_NAME, METHOD_NAME, System.LoggingLevel.ERROR);
        }
        
        
        return response;
    }

    private static List<Task> createTasks(TaskCreationRequest request, Set<ID> userIds){
        List<Task> tasks = new List<Task>();
        for(ID id: userIds){
            tasks.addAll(createTasks(request,id));
        }
        return tasks;
    }
   
    private static List<Task> createTasks(TaskCreationRequest request, String userId){
        List<Task> tasks = new List<Task>();
        for(Map<String,String> basicDetail: request.taskBasicDetails){
            Task task = new Task();
            //task = assignValueToField(task,'TaskCategory__c','Sales Follow-Up');
             task = assignValueToField(task,'TaskCategory__c',basicDetail.get('category'));
            task = assignValueToField(task,'Description',basicDetail.get('description'));
            task.ActivityDate = getDateFromNumberOfDaysFromToday(Integer.valueOf(basicDetail.get('numberOfDaysUntilDue')));
            task = assignValueToField(task,'Priority',basicDetail.get('priority'));
            task = assignValueToField(task,'TaskSubCategory__c',basicDetail.get('subCategory'));
            task = assignValueToField(task,'Subject',basicDetail.get('subject'));
            task = assignValueToField(task,'CreatedFromTemplate__c',!String.isBlank(basicDetail.get('templateId')));
            task = assignValueToField(task,'WhatId',request.relationId);
            task = assignValueToField(task,'Task_Type__c',basicDetail.get('type'));
            task = assignValueToField(task,'Contact_Type__c',basicDetail.get('contactType'));
            task = assignValueToField(task,'Pivoted__c', basicDetail.get('pivoted') == 'true');
            task = assignValueToField(task,'Status',basicDetail.get('status'));
            task = assignValueToField(task,'Source__c',basicDetail.get('source'));
            task = assignValueToField(task,'Campaign__c',basicDetail.get('campaign'));
            task = assignValueToField(task,'WhoId',request.whoid);
            task = assignValueToField(task,'Log_Call__c', basicDetail.get('isLog') == 'true');
            task = assignValueToField(task,'Log_Title__c', basicDetail.get('logTitle'));
            task = assignValueToField(task,'LineOfBusiness__c', request.lob);
            if(request.relationFieldName != null) {
                task = assignValueToField(task,request.relationFieldName,request.relationId);
            }
            task.AssignedTo__c = userId;
            task.ownerId = userId;
            tasks.add(task);
        }
        return tasks;
    }
    private static Date getDateFromNumberOfDaysFromToday(Integer numberOfDays){
            return Date.today().addDays(numberOfDays);
    }
    private static Task assignValueToField(Task task, String field, Object value){
        if(field != null && value != null){
            task.put(field,value);
        }
        return task;
    }
    private static Set<ID> listOfStringToSetOfId(List<String> stringList){
        Set<ID> ids = new Set<ID>();
        for(String stringItem: stringList){
            ids.add(ID.valueOf(stringItem));
        }
        return ids;
    }

    private static Boolean allSaveResultsAreSuccess(List<Database.SaveResult> results){
        if(results == null){
            return false;
        }
        for(Database.SaveResult result: results){
            if(!result.success){
                return false;
            }
        }
        return true;
    }
    private static List<String> getIdsFromSaveResults(List<Database.SaveResult> results){
        List<String> ids = new List<String>();
        if(results == null){
            return null;
        }
        for(Database.SaveResult result: results){
            if(result.id != null){
                ids.add(result.id);
            }
        }
        return ids;
    }
    @AuraEnabled(cacheable=false)
    /**
     * @description getLoggedInUserPreferenceTemplates
     * @param preferenceObject 
     * @return  `List<Task_Step__c>`
     */
    
    public static List<Task_Step__c> getLoggedInUserPreferenceTemplates(String preferenceObject) {
        String agentProxyId = getLoggedInUserAgentProxy();
        Preference__c userPreference = getPreferenceData(agentProxyId, preferenceObject);
        return getTaskSteps(userPreference);
    }
    @AuraEnabled(cacheable=true)
    /**
     * @description getPreferenceTemplates
     * @param preferenceObject 
     * @param ownerId 
     * @return  `List<Task_Step__c>`
     */
    
    public static List<Task_Step__c> getPreferenceTemplates(String preferenceObject, String ownerId) {
        Preference__c userPreference = getPreferenceData(ownerId, preferenceObject);
        return getTaskSteps(userPreference);
    }
    private static list<Task_Step__c> getTaskSteps(Preference__c userPreference) {
        List<Task_Step__c> taskSteps = new List<Task_Step__c>();
        if (String.isNotBlank(userPreference?.TemplateIds__c)) {
            List<String> templateIds = userPreference.TemplateIds__c.split(';');
             taskSteps = getTaskStepData(templateIds);
        }
        return taskSteps;
    }
    private static List<Task_Step__c> getTaskStepData(List<String> templateIds){
        List<Task_Step__c> taskSteps = [SELECT Id, Contact_Method__c, Task_Category__c ,Due_Date_Number_of_Days_from_Start__c, Due_Date__c,  Task_Description__c, Task_Subcategory__c, Task_Priority__c, Name, Template__r.Type__c, Template__r.Workflow__c, Template__r.Name FROM Task_Step__c WHERE  template__c IN :templateIds  WITH SECURITY_ENFORCED ORDER BY Due_Date_Number_of_Days_from_Start__c];
        return taskSteps;
    }

    private static Preference__c getPreferenceData(String agentProxySfdcId, String preferenceObject) {
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', agentProxySfdcId, User.class);
        String validatedObjectName = new UTIL_ParameterValidator_SObjectName().validateParameter('ObjectName', preferenceObject);
        Preference__c userPreference = null;
        for (Preference__c pref : [SELECT Id, TemplateIds__c FROM Preference__c WHERE 
            PreferenceUser__c = :agentProxySfdcId AND OwnerId = :agentProxySfdcId AND  PreferenceName__c = :PREFERENCE_NAME 
            AND PreferenceObject__c = :validatedObjectName WITH SECURITY_ENFORCED LIMIT 1]) {
            userPreference = pref;
        }
        return userPreference;
    }
    private static String getLoggedInUserAgentProxy() {
        User loggedInUserInfo = [SELECT Servicing_Agent_Associate_Id__c FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED LIMIT 1];
        User loggedInUserProxyInfo = [SELECT Id FROM User WHERE UserExternalID__c = :loggedInUserInfo.Servicing_Agent_Associate_Id__c + 'P' WITH SECURITY_ENFORCED LIMIT 1];
        return loggedInUserProxyInfo.Id;
    }
}