public without sharing class UserSurveyController {
    // Gets a map of available surveys for the current user.
    @AuraEnabled(cacheable=false)
    public static Map<Id, User_Survey__c> getSurveys(){
        try {
            Map<Id, User_Survey__c> surveyMap = new Map<Id, User_Survey__c>();
            List<User_Survey__c> surveys = fetchSurveys();

            // Return empty map if survey list is empty.
            if(!surveys.isEmpty()){
                // Filter for surveys that still need a response.
                surveyMap = new Map<Id, User_Survey__c>(nonRespondedSurveys(surveys)); 
            }

            // Return the final map of surveys.
            return surveyMap;
        }
        catch(Exception ex){
            String errorMessage = 'Failed to retrieve list of available surveys.';
            AuraHandledException error = new AuraHandledException(errorMessage);
            error.setMessage(errorMessage);
            LoggingService.logHandledException(ex, 'UserSurveyPageController', 'getSurveys',  LoggingLevel.ERROR);
            throw new AuraHandledException(errorMessage);
        }
    }

    @AuraEnabled(cacheable=false)
    public static User_Survey__c getSurveyByName(String userSurveyName){
        try {
            // Return the final map of surveys.
            return fetchSurveyByName(userSurveyName);
        }
        catch(Exception ex){
            String errorMessage = 'Failed to retrieve surveys by name.';
            AuraHandledException error = new AuraHandledException(errorMessage);
            error.setMessage(errorMessage);
            LoggingService.logHandledException(ex, 'UserSurveyPageController', 'getSurveyByName',  LoggingLevel.ERROR);
            throw new AuraHandledException(errorMessage);
        }
    }

    @AuraEnabled(cacheable=false)
    public static User_Survey__c getSurveyByFeature(String feature){
        try {
            // Return the final map of surveys.
            return fetchSurveyByFeature(feature);
        }
        catch(Exception ex){
            String errorMessage = 'Failed to retrieve surveys by feature.';
            AuraHandledException error = new AuraHandledException(errorMessage);
            error.setMessage(errorMessage);
            LoggingService.logHandledException(ex, 'UserSurveyPageController', 'getSurveyByFeature',  LoggingLevel.ERROR);
            throw new AuraHandledException(errorMessage);
        }
    }

    // Filter the list of active user surveys to only those which can be responded to.
    private static List<User_Survey__c> nonRespondedSurveys(List<User_Survey__c> surveys) {
        // Store list of surveys that don't have a response yet.
        List<User_Survey__c> nonResponded = new List<User_Survey__c>();
        // For each active survey check if the user has answered it yet.
        for (User_Survey__c survey : surveys) {
            if(!hasRespondedToSurvey(survey)) {
                nonResponded.add(survey);
            }
        }
        // Return only surveys that do not yet have a response.
        return nonResponded;

    }

    // Check if there exists a Survey Question response from the requesting user.
    private static Boolean hasRespondedToSurvey(User_Survey__c survey) {
        String userId = UserInfo.getUserId();
        // Check if any responses exist for this survey from the requesting user.

        String queryToExecute = (
            'SELECT Id FROM User_Survey_Response__c WHERE '
            + 'CreatedById = \'' + userId +'\''
            + ' AND UserSurvey__c = \'' + survey.Id +'\''
        );
        List<User_Survey_Response__c> response = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute).replace('\\', ''))).getRecords();
        return !response.isEmpty();
    }
    
    // Fetch any available active surveys for the requesting user if they are in the
    // targeted user groups and have not responded already.
    private static List<User_Survey__c> fetchSurveys(){
        List<String> targetUserGroups = buildUserTargetGroupsQuery();
        String targetUserGroupsAsString = '(\'' + String.join(targetUserGroups, '\', \'') + '\')';
        String queryToExecute = (
            'SELECT Id, Name, Description__c, Note__c, Title__c, Targeted_User_Groups__c, OwnerId, (SELECT Id, Name, Note__c, Title__c, Question_Position__c, QuestionType__c FROM User_Survey_Questions__r ORDER BY Question_Position__c ASC ) FROM User_Survey__c WHERE IsActive__c = true '
            + ' AND Targeted_User_Groups__c INCLUDES ' + targetUserGroupsAsString
            + ' LIMIT 50'
        );
        
        List<User_Survey__c> surveys = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute).replace('\\', ''))).getRecords();
        return surveys;     
    }

    private static User_Survey__c fetchSurveyByName(String userSurveyName){  
        List<String> targetUserGroups = buildUserTargetGroupsQuery();
        String targetUserGroupsAsString = '(\'' + String.join(targetUserGroups, '\', \'') + '\')';
        String queryToExecute = (
            'SELECT Id, Name, Description__c, Note__c, Title__c, Targeted_User_Groups__c, OwnerId, (SELECT Id, Name, Note__c, Title__c, Question_Position__c, QuestionType__c FROM User_Survey_Questions__r ORDER BY Question_Position__c ASC ) FROM User_Survey__c WHERE IsActive__c = true '
            + ' AND Title__c = \'' + userSurveyName + '\''
            + ' AND Targeted_User_Groups__c INCLUDES ' + targetUserGroupsAsString
            + ' LIMIT 1'
        );
        
        List<User_Survey__c> surveys = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute).replace('\\', ''))).getRecords();
        return surveys[0];     
    }

    private static User_Survey__c fetchSurveyByFeature(String feature){  
        List<String> targetUserGroups = buildUserTargetGroupsQuery();
        String targetUserGroupsAsString = '(\'' + String.join(targetUserGroups, '\', \'') + '\')';
        String queryToExecute = (
            'SELECT Id, Name, Description__c, Note__c, Title__c, Targeted_User_Groups__c, OwnerId, (SELECT Id, Name, Note__c, Title__c, Question_Position__c, QuestionType__c FROM User_Survey_Questions__r ORDER BY Question_Position__c ASC ) FROM User_Survey__c WHERE IsActive__c = true '
            + ' AND Feature__c = \'' + feature + '\''
            + ' AND Targeted_User_Groups__c INCLUDES ' + targetUserGroupsAsString
            + ' LIMIT 1'
        );
        
        List<User_Survey__c> surveys = Security.stripInaccessible(AccessType.READABLE, Database.query(String.escapeSingleQuotes(queryToExecute).replace('\\', ''))).getRecords();
        return surveys[0];     
    }

    // Generates the WHERE clause to filter the query for user surveys targeted to the requesting user.
    private static List<String> buildUserTargetGroupsQuery() {
        // Retrieve values from Feature Access.
        List<String> criteriaPerms = AP_FeatureAccess.getFeatureAccessMetadataForUserCriteria('FeedbackManagement');
        String subuserTypePerms = AP_FeatureAccess.getFeatureAccessMetadataForSubuserType('FeedbackManagement');

        // Used to store final list of permissions the user has.
        List<String> perms = new List<String>();

        // Add if perms returned are non-empty.
        if(criteriaPerms != null && criteriaPerms.size() > 0) {
            perms.addAll(criteriaPerms);
        }

        // Add if perms returned are non-null.
        if(subuserTypePerms != null) {
            perms.add(subuserTypePerms);
        }

        // Store matching target groups for the feedback management tool.
        List<String> includedTargetGroups = new List<String>();

        // Translate retrieved permissions into SOQL WHERE clause.
        if(perms.size() > 0) {
            for(String data: perms) {
                // Parse JSON data into map.
                Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(data);
                // Check state of each included value.
                for(String targetField: dataMap.keySet()) {
                    // If target field included, then add query clause for corresponding surveys.
                    if((Boolean) dataMap.get(targetField)) {
                        includedTargetGroups.add(targetField);
                    }
                }
            }
        }

        return includedTargetGroups;
    }
}