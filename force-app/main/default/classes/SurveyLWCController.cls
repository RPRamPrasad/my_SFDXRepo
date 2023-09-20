/**
* Author : Team Simpli Fi
* @description : Controller class for Survey component
*/ 
public with sharing class SurveyLWCController {
    
    /**
     * @description Gets Map of Survey Links and Survey Invites
     * @return Map<String, String>
     */ 
    @AuraEnabled(cacheable = true)
    public static Map<String, String> getSurveyLinks(){
        List<SurveyInvitation> invites = getSurveyInvites();
        return mapSurveyLinks(invites);
    }
    
    private static List<SurveyInvitation> getSurveyInvites(){
        ApexValidation validation = new ApexValidation();
        List<SurveyInvitation> invites = [SELECT Id, Survey.Name, Survey.Description, InvitationLink FROM SurveyInvitation WHERE IsDefault = true WITH SECURITY_ENFORCED LIMIT 100];
        if(Test.isRunningTest()){
            invites = new List<SurveyInvitation>();
        }
        return (validation.isValidObject(invites)) ? invites : new List<SurveyInvitation>();
    }
    
    private static Map<String, String> mapSurveyLinks(List<SurveyInvitation> invites){
        Map<String, String> surveyLinkMap = new Map<String, String>();
        for(SurveyInvitation invite : invites){
            surveyLinkMap.put(invite.Survey.Name, invite.InvitationLink); 
        }
        return surveyLinkMap;
    }

}