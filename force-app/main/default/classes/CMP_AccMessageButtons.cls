/**
Author Team ClubCar
Name - CMP_AccMessageButtons
@description This class will be invoked by AccMessageButtons lightning component
Team: ClubCar
========================================================================================================================================+
History
-------
VERSION         AUTHOR                      DATE                    DETAIL
1.0             Team ClubCar                12/26/2018              Initial Development
2.0             Team ClubCar                01/17/2019              Added logic to return data based on passed Account Id or OppId
3.0             Team ClubCar                03/06/2019              Production Defect Fix for Account Message buttons without Opportunity
4.0             Team ClubCar                01/07/2020              MOA Production Defect Fix for SendMail/SendEmail buttons by passing loggedin user's servicing agent's alias
5.0             Team ClubCar                03/10/2020              Holding Code Production Defect Fix for SendMail/SendEmail/Mail History Buttons
******************************************************************************************************************************************/
public with sharing class CMP_AccMessageButtons {
    private static final String CLASS_NAME = 'CMP_AccMessageButtons';
    private static final String METHOD_NAME = 'getLaunchButtonData';
    private static String validatedSObjectType = null;
    private static String validatedServicingAgentExternalId = null;
    private static Id validatedOpporAccId = null;
    private static final String AGENT = 'Agency_User';
    
    /**
    * @description Inner Class to return Opportunity Details required by AccMessageButtons Lightning Component
    */
    public with sharing class AccMessageButtonsWrapper {
        
        @AuraEnabled
        public String clientIdentifier = null;
        
        @AuraEnabled
        public String sfAccountId = null;
        
        @AuraEnabled
        public String agentId = null;
        
        @AuraEnabled
        public String agentAlias = null;

        @AuraEnabled
        public boolean isValidUser = true;  
    }
    
    /**
    * @description Inner Class used to get Opportunity,Account and user Details from AccMessageButtons Lightning Component
    */
    public with sharing class AccMessageButtonsData {        
        public String sObjectType;
        public String servicingAgentExternalId;
        public Id oppOrAccId;
    }
    
    /**
    * @description - Invoked by  AccMessageButtons Lightning Component
    *           	This method will return AccountId, ClientIdentifier, Agentid,AgentAlias and ProfileValidty based on passed Opp Or Account Id and ServicingAgentExternalId of logged in user.
	*				Based on passed id, corresponding helper method is called to pull record details for that ID           
    * @name - getLaunchButtonData
    * @param sObjectType : jsonString - passed Opportunity or Account Id, sObjectName and servicingAgentExternalId in jsonString
    * @param oppOrAccountId
    * @return - AccMessageButtonsWrapper
    */    
    @AuraEnabled
    public static AccMessageButtonsWrapper getLaunchButtonData (String sObjectType, Id oppOrAccountId) {
        validateJsonStringandReturnParams(sObjectType, oppOrAccountId);
        AccMessageButtonsWrapper launchButtonDataResp = new AccMessageButtonsWrapper();
        try {
            if (validatedOpporAccId!= null && validatedSObjectType != null) {
                if(validatedSObjectType.equalsIgnoreCase('Account')) {            
                    Account queriedAccRecord = getAccountRecord(validatedOpporAccId);
                    launchButtonDataResp.clientIdentifier = queriedAccRecord.ClientIdentifier__c;
                    launchButtonDataResp.sfAccountId = queriedAccRecord.Id;
                }
                else {
                    Opportunity queriedOppRecord = getOpportunityRecord(validatedOpporAccId);
                    launchButtonDataResp.clientIdentifier = queriedOppRecord.Account.ClientIdentifier__c;
                    launchButtonDataResp.sfAccountId = queriedOppRecord.AccountId;  
                }
                launchButtonDataResp = getServicingAgentAliasAndAgentId(launchButtonDataResp); 
                launchButtonDataResp.isValidUser = isUserAnAgent();
            }
            
        } catch (Exception launchButtonDataException) {
            LoggingService.logHandledException(launchButtonDataException, CLASS_NAME, METHOD_NAME, System.LoggingLevel.ERROR);
        }
        return launchButtonDataResp;
    }    
    
    //Helper method to query opportunity record
    private static Opportunity getOpportunityRecord(Id opportunityId) {
        List<Opportunity> queryOppResultList = [Select Id,AccountId,Account.ClientIdentifier__c From Opportunity WHERE Id =:opportunityId WITH SECURITY_ENFORCED LIMIT 1];          
        return queryOppResultList[0];
    }
    
    //Helper method to query account record
    private static Account getAccountRecord(Id accountId) {
        List<Account> accQueryResultsList = [Select Id,ClientIdentifier__c From Account WHERE Id =:accountId WITH SECURITY_ENFORCED LIMIT 1];
        return accQueryResultsList[0];
    }

    //Helper method to return Servicing Agent's Alias and AgentID_c for logged in user.
    private static AccMessageButtonsWrapper getServicingAgentAliasAndAgentId (AccMessageButtonsWrapper launchButtonDataResp){
        String servicingAgentExternalId = [Select Servicing_Agent_External_ID__c From User Where Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED][0].Servicing_Agent_External_ID__c;

        if (!String.isBlank(servicingAgentExternalId) && isUserAnAgent()) {
            List<User> queryUserResultList = [Select Alias,AgentId__c From User WHERE UserExternalID__c =:servicingAgentExternalId WITH SECURITY_ENFORCED LIMIT 1];
            if(!queryUserResultList.isEmpty()){
                launchButtonDataResp.agentAlias = queryUserResultList[0].Alias;
                launchButtonDataResp.agentId = queryUserResultList[0].AgentId__c;
            }            
        }
        return launchButtonDataResp;
    }
    //method to validate Agent custom permission 
    private static Boolean isUserAnAgent() {
        return FeatureManagement.checkPermission(AGENT);
    }

    //Helper method to validate paramters
    private static void validateJsonStringandReturnParams(String sObjectType, Id oppOrAccountId){
    
        UTIL_ParameterValidator_SObjectName sObjectNameValidator = new UTIL_ParameterValidator_SObjectName();
        UTIL_ParameterValidator_SalesforceId salesforceIdValidator = new UTIL_ParameterValidator_SalesforceId();
        validatedSObjectType = sObjectNameValidator.validateParameter('ObjectType', sObjectType);
        validatedOpporAccId = salesforceIdValidator.validateParameter('oppOrAccId', oppOrAccountId);
    }
    
    //Helper method to validate servicingagentexternalid parameter
    private static String validateServicingAgentExternalIdParameter(String parameterName, String parameterValue) {
        String servicingAgentExternalIdRegex = '^[a-zA-Z0-9_]{1,23}$';
        if (!Pattern.matches(servicingAgentExternalIdRegex, parameterValue)) {
            throw new InvalidParameterValueException(parameterName + ' failed Servicing Agent External Id validation');
        }
        return parameterValue;
    }
}