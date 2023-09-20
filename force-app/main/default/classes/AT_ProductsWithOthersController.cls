/**
* Author : Team Kraken
* Date Created : 9/5/2018
* @description retrieves OData for AT_ProductsWithOthers lightning component
* Version : 1.0
*/
public with sharing class AT_ProductsWithOthersController
{
    @TestVisible 
    public static List<ProductsWithOthersCompetitors__x> mockProductsList = new List<ProductsWithOthersCompetitors__x>();
    
    @TestVisible public static String loggedInProfile = UTIL_LtngProfileDataAccess.getProfileName();
    
    /**
     * @description Inner class describes Wrapper object for Product with Others
     */
    @TestVisible
    public with sharing class ProductsWithOthersWrapper {
        /**
         * @description client ID for an account
         */
        @AuraEnabled @TestVisible
        public String clientID{get;private set;}
        /**
         * @description Any comments existing on the PWOC policy
         */
        @AuraEnabled @TestVisible
        public String productComments{get;private set;}
        /**
         * @description Company name servicing the PWOC policy
         */
        @AuraEnabled @TestVisible
        public String carrierName{get;private set;}
        /**
         * @description Date the PWOC policy expires
         */
        @AuraEnabled @TestVisible
        public String expirationDate{get;private set;}
        /**
         * @description Agreement ID given to the PWOC policy
         */
        @AuraEnabled @TestVisible
        public String externalAgreementID{get;private set;}
        /**
         * @description Line of business of the PWOC policy
         */
        @AuraEnabled @TestVisible
        public String productLine{get;private set;}
        /**
         * @description Type of policy product
         */
        @AuraEnabled @TestVisible
        public String productType{get;private set;}
        /**
         * @description State agent code existing on policy
         */
        @AuraEnabled @TestVisible
        public String stateAgentCode{get;private set;}
        /**
         * @description ID value given to policy
         */
        @AuraEnabled @TestVisible
        public String id {get; private set;}
    }
    
    /**
     * @description Retrieves PWOC policy data through OData query
     * @param recordId of the given account with policy data
     * @return is list of PWOC policy data related to given account
     */
    @AuraEnabled
    public static List<ProductsWithOthersWrapper> getProductsWithOthersList(String recordId) {
        String loggedInPrimaryStateAgentCode;
        
        String clientId = UTIL_ReturnClientId.getAccountClientId(recordId);
        
        //query for state-agent code of logged-in user
        List<ProductsWithOthersWrapper> wrappers;
        try {        
            agentAndATMProfileEqualsLoggedInProfile();
            
            List<ProductsWithOthersCompetitors__x> pwocs;
            
            if (Test.isRunningTest()) {
                pwocs = mockProductsList;
                if (null != pwocs && pwocs.size() > 0 && 'ERROR'.equals(pwocs[0].StateAgentCode__c)) {
                    throw new DMLException('THIS IS AN ERROR');
                }
            }
            else {
                pwocs = retrieveProductsWithOthersFromDB(clientId, loggedInPrimaryStateAgentCode);
            }
            wrappers = new List<ProductsWithOthersWrapper>();
            
            for (ProductsWithOthersCompetitors__x pwoc : pwocs) {
                ProductsWithOthersWrapper wrapper = new ProductsWithOthersWrapper();
                wrapper.id = pwoc.id;
                wrapper.clientID = pwoc.ClientID__c;
                wrapper.productComments = pwoc.ProductComments__c;
                wrapper.carrierName = pwoc.CarrierName__c;
                wrapper.expirationDate = AT_ProductsWithOthersController.formatDate(pwoc.ExpirationDate__c);
                wrapper.externalAgreementID = pwoc.ExternalAgreementID__c;
                wrapper.productLine = pwoc.ProductLine__c;
                wrapper.productType = pwoc.ProductType__c;
                wrapper.stateAgentCode = AT_ProductsWithOthersController.formateStateAgentCode(pwoc.StateAgentCode__c);
                wrappers.add(wrapper);
            }
        }
        catch (Exception e) {
            // system.debug('AT_ProductsWithOthersController.getProductsWithOthersList:' + e.getMessage());
            LoggingService.logHandledException(e, 'AT_ProductsWithOthersController', 'getProductsWithOthersList', System.LoggingLevel.ERROR);
            throw new AuraHandledException('QUERY ERROR');
        }
        return wrappers;
    }


    /**
     * @description agentAndATMProfileEqualsLoggedInProfile
     * @param agentWrap 
     */
    private static void agentAndATMProfileEqualsLoggedInProfile( ){
        if(Label.CL_Agent_Profile.equals(loggedInProfile) || Label.CL_ATM_Profile.equals(loggedInProfile)) {

            // get loggedInUser
            User currentUser = getCurrentUser();
            
            //query for servicing agent of logged-in user
            getLoggedInUserPrimaryStateAgentCode(currentUser);
        }
    }

/**
     * @description Method returns list of productswithOthers for given clientId
     * @param clientId is client who's pwo records are to be retrieved.
     * @param loggedInPrimaryStateAgentCode logged in users primary stAgentCode
     * @return list of Products With Others Competitors
     */    
    public static List<ProductsWithOthersCompetitors__x> retrieveProductsWithOthersFromDB(String clientId, String loggedInPrimaryStateAgentCode ) {

        List<ProductsWithOthersCompetitors__x> pwocs;
        
        if (!String.isEmpty(loggedInPrimaryStateAgentCode)) {
            pwocs = Security.stripInaccessible(AccessType.READABLE, [
                SELECT Id, Agent__c, ClientID__c, StateAgentCode__c, CarrierName__c,
                    ExternalAgreementId__c, ProductLine__c, ExpirationDate__c,
                    ProductComments__c, ProductType__c
                FROM ProductsWithOthersCompetitors__x 
                WHERE ClientID__c  = :clientId AND StateAgentCode__c = :loggedInPrimaryStateAgentCode
                ORDER BY ProductLine__c LIMIT 100
            ]).getRecords();
        } else {
            pwocs = Security.stripInaccessible(AccessType.READABLE, [
                SELECT Id, Agent__c, ClientID__c, StateAgentCode__c, CarrierName__c,
                    ExternalAgreementId__c, ProductLine__c, ExpirationDate__c,
                    ProductComments__c, ProductType__c
                FROM ProductsWithOthersCompetitors__x 
                WHERE ClientID__c  = :clientId
                ORDER BY ProductLine__c LIMIT 100
            ]).getRecords();
        }

        return pwocs;
    }

    private static String getLoggedInUserPrimaryStateAgentCode(User currentUser) {

        String loggedInPrimaryStateAgentCode;
        List<User> stateAgentCodeQueryList;
                
        if (Test.isRunningTest()) {
            stateAgentCodeQueryList = new List<User>();
            User agent = new User(State_Agent_Code__c = '12-1234');
            stateAgentCodeQueryList.add(agent);
        }
        else {
            stateAgentCodeQueryList = Security.stripInaccessible(AccessType.READABLE, [
                SELECT State_Agent_Code__c, Id FROM User 
                WHERE UserExternalID__c = :currentUser.Servicing_Agent_External_ID__c AND SubUserType__c = 'Agent' LIMIT 1
            ]).getRecords();
        }
        
        if (stateAgentCodeQueryList != null) {
            String[] code = stateAgentCodeQueryList[0].State_Agent_Code__c.split('-');
            loggedInPrimaryStateAgentCode = code[0] + code[1];
        }

        return loggedInPrimaryStateAgentCode;

    }
    private static User getCurrentUser() {

        List<User> userQueryList;
        if (Test.isRunningTest()) {
            userQueryList = new List<User>();
            User u = new User(State_Agent_Code__c = '12-1234', Servicing_Agent_Associate_ID__c = '098765');
            userQueryList.add(u);
        }
        else {
            String userId = UserInfo.getUserId();
            userQueryList = Security.stripInaccessible(AccessType.READABLE, [
                SELECT State_Agent_Code__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c FROM User WHERE Id = :userId LIMIT 1
            ]).getRecords();
        }
        User currentUser = null;
        if (userQueryList != null) {
            currentUser = userQueryList[0];
        }

        return currentUser;
    }

    /**
     * @description Method formats date string into mm/dd/yyyy
     * @param expDate is date field to format
     * @return String version of new date format
     */
    public static String formatDate(Date expDate) {
        if (expDate != null) {
            String retMonth = String.valueOf(expDate.month());
            String retDay = String.valueOf(expDate.day());
            String retYear = String.valueOf(expDate.year());
            return retMonth + '/' + retDay + '/' + retYear;
        } else  {
            return '';
        }
    }
    
    /**
     * @description Method formats state agent code into ss-aaaa
     * @param code is value needing to format from ssaaaa
     * @return is new String of formatted code
     */
    public static String formateStateAgentCode(String code) {
        
        if (code.contains('-')) {
            return code;
        }
        else {
            return code.left(2) + '-' + code.right(4);
        }
    }
    
    /**
     * @description Method gives access to New PWOC button
     * @return is boolean value for button access
     */
    @AuraEnabled
    public static Boolean canViewNewButton() {
        return AT_ProfileAccess.hasCreateNewPWOCAccess();
    }
}