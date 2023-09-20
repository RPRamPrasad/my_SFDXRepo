public class UserSurveyWrapper {

    @AuraEnabled
    public List<User_Survey_Question_Response__c> surveyQuestionResponses { get; set; }

    @AuraEnabled
    public User_Survey_Response__c surveyResponse { get; set; }
    
}