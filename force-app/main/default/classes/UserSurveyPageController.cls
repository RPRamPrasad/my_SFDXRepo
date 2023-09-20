public without sharing class UserSurveyPageController {
    
    @AuraEnabled
    public static String handleResponses(UserSurveyWrapper wrapper){
        try {
            if(wrapper != null && wrapper.surveyResponse != null && wrapper.surveyQuestionResponses != null){
                // Create and validate that response was created.
                List<User_Survey_Response__c> responseList = new List<User_Survey_Response__c>{
                    wrapper.surveyResponse
                };
                String result = createSurveyResponse(responseList);
                if('Survey Response Created'.equals(result)) {
                    // Update question responses to reference survey response object.
                    for(User_Survey_Question_Response__c questionResponse : wrapper.surveyQuestionResponses) {
                        questionResponse.UserSurveyResponse__c = wrapper.surveyResponse.Id;
                    }

                    // Insert responses.
                    result = insertSurveyQuestionResponses(wrapper.surveyQuestionResponses);
                }
                return result;
            } else {
                return 'There were no responses submitted.';
            }
        }
        catch(Exception ex){
            LoggingService.logHandledException(ex, 'UserSurveyPageController', 'handleResponses',  LoggingLevel.ERROR);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    private static String createSurveyResponse(List<User_Survey_Response__c> responses) {
        Database.SaveResult[] srList = Database.insert(Security.stripInaccessible(AccessType.CREATABLE, responses, true).getRecords(), false);
        responses[0].Id = srList[0].getId();
        return 'Survey Response Created';
    }
    
    private static String insertSurveyQuestionResponses(List<User_Survey_Question_Response__c> responseList){
        insert Security.stripInaccessible(AccessType.CREATABLE, responseList, true).getRecords();
        return 'Survey Response Saved Successfully';
    }
    
}