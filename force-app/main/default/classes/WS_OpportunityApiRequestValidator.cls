/**
 * @description WS_OpportunityApiRequestValidator
 */
public with sharing class WS_OpportunityApiRequestValidator {
    
    private static final String OPPORTYNITY_CLOSED_WON_STAGE ='Closed Won';
    
    /**
     * @description checkForValidAgent
     * @param agentAssociateId 
     * @return  `User`
     */
    public static User checkForValidAgent(String agentAssociateId) {
        List<User> user = new List<User>();    
        user = Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT id, Name, Alias FROM user WHERE Associate_ID__c <>:UTIL_Constants.NO_SPACE and Associate_ID__c =:agentAssociateId 
             and UserExternalid__C=:(agentAssociateId+'_'+agentAssociateId)
             and IsActive = true limit 1]
        ).getRecords();
        if(!user.isEmpty()) {
            return user.get(0);
        } else {
            throw new WS_OpportunityApiRequestException(System.Label.CL_AgentAssociateID_Invalid_Message);
        }
    } 
    
    /**
     * @description checkForDuplicateOpportunity
     * @param oppRequest 
     * @param prxy 
     * @return  `List<Opportunity>`
     */
    public static List<Opportunity> checkForDuplicateOpportunity(HLPR_CreateOppRequest oppRequest, String prxy)  { 
        List<Opportunity> opportunityList = new List<Opportunity>();
        opportunityList = Security.stripInaccessible(AccessType.READABLE, [SELECT Id,IsOfficeNotified__c,Assigned_To__c,StageName,OppNotNowFollowUpDateTime__c,OppClosedDateTime__c FROM Opportunity WHERE AccountID in (SELECT Id FROM Account 
                                                                                                                                      WHERE ClientIdentifier__c =:oppRequest.accountData.ClientID) 
                           AND Opportunity_Originator__c =: oppRequest.opportunityData.Opportunity_Originator
                           AND LOB__c =:oppRequest.opportunityData.LOB AND Owner.UserExternalID__c=:prxy and 
                           product__c= :oppRequest.opportunityData.Product AND CreatedDate = LAST_N_DAYS:59
                           AND StageName NOT IN (:OPPORTYNITY_CLOSED_WON_STAGE) ORDER BY Id DESC LIMIT 1]).getRecords();
        
        return opportunityList;     
    }
    
    /**
     * @description validateRequiredFields
     * @param oppRequest 
     */
    public static void validateRequiredFields(HLPR_CreateOppRequest oppRequest) {
        validateAccountFields(oppRequest);
        if (String.isBlank(oppRequest.agentOfficeData.agentAssociateID)) {
            throw new WS_OpportunityApiRequestException(System.Label.CL_AgentAssociateID_Invalid_Message);
        } else if (String.isBlank(oppRequest.opportunityData.Name)) {
            throw new WS_OpportunityApiRequestException(System.Label.CL_Name_Reqd);
        }
    }
    
    private static void validateAccountFields(HLPR_CreateOppRequest oppRequest) {
        if (validateClientId(oppRequest.accountData.ClientID)) {
            throw new WS_OpportunityApiRequestException(System.Label.CL_Invalid_Client_Identifier);
        } else if (validateAccountLastName(oppRequest.accountData.LastName)) {
            throw new WS_OpportunityApiRequestException(System.Label.CL_LastName_Reqd);
        } else if (String.isBlank(oppRequest.accountData.AccountType)) {
            throw new WS_OpportunityApiRequestException(System.Label.CL_AccountType_Invalid_Message);
        }
    }
    
    private static boolean validateClientId(String clientId) {
        return (String.isBlank(clientId) || clientId.length() == 0 || clientId.length() > 11);
    }
    
    private static boolean validateAccountLastName(String accountLastName) {
        return (String.isBlank(accountLastName) || accountLastName.length() == 0 || accountLastName.length() > 80);
    }
}