/**
@author Team STARK
@owner Team STARK
@name UTIL_AccountSearchDuplicate
@createDate 05/31/2020
@description This class is used by LWC Account components for Searching Existing Account records (Matching rules)
@version 1.0
*/
public with sharing class UTIL_AccountSearchDuplicate {

    private static Account customer = new Account();
    private static CS_FeatureToggle__c featureToggle = CS_FeatureToggle__c.getInstance();
    private static final String CLASS_NAME = 'UTIL_AccountSearchDuplicate';
  
    private static final String CREATE_TASK_FOR_SERVICE_AGENT = 'createTaskForServiceAgent';
    private static final String UPDATE_AGENT_ROLE_AFTER_SEARCH = 'updateAgentRoleAfterSearch';
    
    
    /**
    * @description This method is used to retrieve skipCustomerSearch value
    * @name : skipCustomerSearch
    * @return Boolean
    */
    @AuraEnabled(cacheable=true)
    public static Boolean skipCustomerSearch() { return featureToggle.Skip_Customer_Search__c; } 
    
    
    /**
    * @description This method is used to find duplicate by matching rules
    * @name : findDuplicateCustomers
    * @param accountJSON : input account json
    * @return Object : output search list
    */
    @AuraEnabled
    public static Object findDuplicateCustomers(String accountJSON) {
        Account customer = (Account) JSON.deserializeStrict(accountJSON, Account.class);
        customer.IsMatchRequired__c = true;
        
        List<HLPR_CustSearchResultWrapper> dupSearchList =  UTIL_SearchCustomer.findDuplicateCustomers(customer, populateSearchPhoneList(customer));
        
        return JSON.serialize(dupSearchList);
    }

    /**
    * @description This method is used to show verification popup
    * @name : gotoVerificationPopup
    * @param accountId : input account id
    * @return DuplicateCustomerDataWrap : output duplicate customer wrapper
    */
    @AuraEnabled
    public static DuplicateCustomerDataWrap gotoVerificationPopup(String accountId) {
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', accountId, Account.class);
        DuplicateCustomerDataWrap duplicateDataWrap = new DuplicateCustomerDataWrap();
        Account verifyCustomer = UTIL_AccountDAO.getAccountDetails(accountId);
        duplicateDataWrap.isAlreadyServicing = false;
        duplicateDataWrap.verifyCustomer = verifyCustomer;
        return duplicateDataWrap;
    }

    /**
    * @description This method is used to create task for servicing agent and update agent relationship
    * @name : createTaskAndUpdateAgentRole
    * @param searchReasonJSON : input search reason json
    */
    @AuraEnabled
    public static void createTaskAndUpdateAgentRole(String searchReasonJSON) {
        CaseReasonWrapper reasonData = (CaseReasonWrapper) JSON.deserializeStrict(searchReasonJSON,CaseReasonWrapper.class);
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', reasonData.accountId, Account.class);
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', reasonData.personContactId, Contact.class);
        updateAgentRoleAfterSearch(reasonData);
        createTaskForServicingAgent(reasonData);
    }

    private static void updateAgentRoleAfterSearch(CaseReasonWrapper reasonData) {
        AgentRole__c agentRole = new AgentRole__c();
        agentRole.AgentRoleIdentifier__c =  reasonData.agentAssociateId +UTIL_CreateCustomerConstants.TILDE+ reasonData.clientId;
        agentRole.RelationshipReason__c = reasonData.selectedReason;
        try {
            UTIL_AgentRoleDAO.upsertedAgentRolesResult(new List<AgentRole__c>{agentRole});
        }
        catch (Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, UPDATE_AGENT_ROLE_AFTER_SEARCH, System.LoggingLevel.ERROR);
            throw new AccountCreateEditException('updateAgentRoleAfterSearch '+e.getMessage()+' Linenumber '+e.getLineNumber());
        }
    }

    private static void createTaskForServicingAgent(CaseReasonWrapper reasonData) {
        try {
            UTIL_SearchCustomer.createTaskForServicingAgents(reasonData.accountId, reasonData.personContactId, UserInfo.getName(), UserInfo.getUserEmail(), reasonData.selectedReason, reasonData.accessComments, reasonData.accessKeyMatchCount, reasonData.isIndividual);
        }
        catch (Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, CREATE_TASK_FOR_SERVICE_AGENT, System.LoggingLevel.ERROR);
            throw new AccountCreateEditException('createTaskForServiceAgent '+e.getMessage()+' Linenumber '+e.getLineNumber());
        }
    }
  
    private static List<String> populateSearchPhoneList(Account customer) {
        List<String> phoneList = new List<String>();
        if(String.isNotBlank(customer.PersonMobilePhone)) {
            phoneList.add(customer.PersonMobilePhone.replaceAll(UTIL_CreateCustomerConstants.ONLY_DIGITS, UTIL_CreateCustomerConstants.EMPTY_STRING));
        }
        if(String.isNotBlank(customer.PersonHomePhone)) {
            phoneList.add(customer.PersonHomePhone.replaceAll(UTIL_CreateCustomerConstants.ONLY_DIGITS, UTIL_CreateCustomerConstants.EMPTY_STRING));
        }
        if(String.isNotBlank(customer.Phone)) {
            phoneList.add(customer.Phone.replaceAll(UTIL_CreateCustomerConstants.ONLY_DIGITS, UTIL_CreateCustomerConstants.EMPTY_STRING));
        }
        if(String.isNotBlank(customer.TDDPhone__c)) {
            phoneList.add(customer.TDDPhone__c.replaceAll(UTIL_CreateCustomerConstants.ONLY_DIGITS, UTIL_CreateCustomerConstants.EMPTY_STRING));
        }
        return phoneList;  
    }

    /**
    * @description This inner class is used to make duplicate customer wrapper JSON
    * @name : DuplicateCustomerDataWrap
    */
    public with sharing class DuplicateCustomerDataWrap {
        /**
        * @description This property is used to get set is already a servicing agent
        * @name : isAlreadyServicing
        */
        @AuraEnabled
        public Boolean isAlreadyServicing { get; set; }

        /**
        * @description This property is used to get set verify customer
        * @name : verifyCustomer
        */
        @AuraEnabled
        public Account verifyCustomer { get; set; }
    }

    /**
    * @description This inner class is used to make case reason wrapper JSON
    * @name : CaseReasonWrapper
    */
    public with sharing class CaseReasonWrapper {
        String accountId;
        String personContactId;
        String clientId;
        String agentAssociateId;
        String  selectedReason;
        String accessComments;
        Integer accessKeyMatchCount;
        Boolean isIndividual;
    } 

}