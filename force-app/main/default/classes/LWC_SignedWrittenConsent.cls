/****************************************************************************************
Name: LWC_SignedWrittenConsent
@description : This class will be invoked by signedWrittenConsentAlertToast and signedWrittenConsent LWC
Team: ClubCar
=========================================================================================
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Team ClubCar              10/09/2020              Initial Development
******************************************************************************************/ 
public with sharing class LWC_SignedWrittenConsent {
    
    private static final String CLASS_NAME = 'LWC_SignedWrittenConsent';
    private static final String METHODNAME_CONSENTREQUEST = 'signedWrittenConsentToastRequest';
    private static final String METHODNAME_UPDATEOPPORTUNITYSWC = 'updateOpportunitiesSignedWrittenConsent';
    
    /**
    @description wrapper class to store user and toggle response for signed written consent 
    **/   
    public with sharing class SignedWrittenConsentResponse {
        @AuraEnabled
        public Boolean isNotCustomerRelation = false;
        @AuraEnabled
        public Boolean isToggleOff = false;        
    }
    
    /**
    * @description - Invoked by signedWrittenConsentAlertToast Lightning web component to return user, agent role
    *                and signed written consent toggle details        
    * @name signedWrittenConsentToastRequest
    * @param accountId - Account Id
    * @return SignedWrittenConsentResponse
    */ 
    @AuraEnabled(cacheable = true)
    public static SignedWrittenConsentResponse signedWrittenConsentToastRequest(Id accountId){
        SignedWrittenConsentResponse signedWrittenConsentResponse = new SignedWrittenConsentResponse();
        try {
            User loggedInUser = getLoggedInUserInfo();            
            signedWrittenConsentResponse.isToggleOff = !HLPR_SignedWrittenConsent.isSignedWrittenConsentToggleOn();
            signedWrittenConsentResponse.isNotCustomerRelation = isNotCustomerAccountRelation(accountId,loggedInUser);
        }
        catch (Exception signedWrittenConsentException) {
            LoggingService.logHandledException(signedWrittenConsentException, CLASS_NAME, METHODNAME_CONSENTREQUEST, System.LoggingLevel.ERROR);
        }
        return signedWrittenConsentResponse;
    }
    
    /**
    * @description - Invoked by signedWrittenConsent Lightning web component to update opportunities
    *                signed written consent fields on submitting the signed written consent request                    
    * @name updateOpportunitiesSignedWrittenConsent
    * @param accountId
    * @param ownerId
    * @return Boolean
    */
    @AuraEnabled
    public static Boolean updateOpportunitiesSignedWrittenConsent(Id accountId, Id ownerId){
        try {        	
            List<Opportunity> opportunityToUpdateList = Security.stripInaccessible(AccessType.READABLE,[Select id,OppSignedWrittenConsentStatus__c,OppSignedWrittenConsentRequestedDate__c from Opportunity
                                                                                                        where AccountId =:accountId AND OwnerId = :ownerId]).getRecords();
            for(Opportunity oppty : opportunityToUpdateList){                                         
                updateOpportunitySwcFields(oppty);
            }
            
            if(!opportunityToUpdateList.isEmpty() && Schema.sObjectType.Opportunity.isUpdateable()){
                HLPR_SignedWrittenConsent.byPassOpportunityBeforeUpdate = true;                
                Database.update(opportunityToUpdateList);
            }
            return true;
        }
        catch (Exception updateOpportunitiesException) {             
            LoggingService.logHandledException(updateOpportunitiesException, CLASS_NAME, METHODNAME_UPDATEOPPORTUNITYSWC, System.LoggingLevel.ERROR);
            return false;
        }        
    }

    //Helper method to update signed written consent values in opportunity
    private static Opportunity updateOpportunitySwcFields(Opportunity oppRecord){
        oppRecord.OppSignedWrittenConsentStatus__c = 'Requested';
        oppRecord.OppSignedWrittenConsentRequestedDate__c = System.today();
        return oppRecord;
    }
    
    //Helper method to query agent role and check logged in user's agent has customer relation with the respective account or not
    private static Boolean isNotCustomerAccountRelation(Id accountId,User loggedInUser){
        Boolean isNotCustomerRelation = false;
        List<AgentRole__c> agentRoleList = Security.stripInaccessible(AccessType.READABLE,[Select Id,RelationshipNature__c from AgentRole__c where Customer__c = :accountId AND
                                                                                           Agent__r.UserExternalID__c = :loggedInUser.Servicing_Agent_External_ID__c]).getRecords();
        if(agentRoleList != null && !agentRoleList.isEmpty() && agentRoleList[0].RelationshipNature__c != 'Customer'){
            isNotCustomerRelation = true;
        }
        return isNotCustomerRelation;
    }
    
    //Helper method to get logged in user information
    private static User getLoggedInUserInfo(){
        List<User> loggedInUserList = Security.stripInaccessible(AccessType.READABLE,[Select id,Servicing_Agent_External_ID__c from user where id = :UserInfo.getUserId() LIMIT 1]).getRecords();
        return loggedInUserList[0];        
    }
/**
 * @description retrieveRelationshipStatus
 * @param accountId 
 * @return  `String`
 */
    @AuraEnabled
    public static String retrieveRelationshipStatus(Id accountId){
        User loggedInUser = getLoggedInUserInfo();
        List<AgentRole__c> agentRoleList = Security.stripInaccessible(AccessType.READABLE,[Select Id,RelationshipNature__c from AgentRole__c where Customer__c = :accountId AND
                                                                                           Agent__r.UserExternalID__c = :loggedInUser.Servicing_Agent_External_ID__c]).getRecords();
        return agentRoleList[0].RelationshipNature__c;                                                                 
    }
}