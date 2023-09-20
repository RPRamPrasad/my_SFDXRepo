/*
 * Utility class to search and find duplicate customers during create customer and advance customer search
 * @name UTIL_SearchCustomer
 * @author Team Choo Choo
 * @owner Team Stark
 * @version 1.0
Team: Stark
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Choo_Choo                10/23/2017             Initial Development
1.2             Targaryen                02/14/2019             R4 2019 - Added Organization Enterprise Search
1.3             Atlas - CustomerView     08/15/2023             Enterprise Possible Duplicate Match for Individual Accounts
******************************************************************************************/

/**
 * @description UTIL Search Customer
 */
public without sharing class UTIL_SearchCustomer {

    private static final String AR_CUST_RELATION = 'Customer';
    private static final String TASK = 'Task';
    private static final String TASK_SUBJECT = 'Out of Book Access Granted';
    private static final String TASK_PRIORITY = 'No';
    private static final String TASK_APP_CODE = 'SFDC Customer Search';
    private static final String TASK_CATEGORY = 'Other';
    private static final String TASK_TYPE = 'Service';
    private static final String TASK_STATUS = 'Not Started';
    private static final String ACCESS_REASON = 'Access Reason: ';
    private static final String TOKEN_VERIFY_COUNT = 'Number of attempts to verify access key: ';
    private static final String ACCESS_COMMENTS = 'Access Comments: ';
    private static final String REQ_EMAIL = 'Requestor Email: ';
    private static final String REQ_NAME = 'Requestor Name: ';
    private static final String US = 'US';
    private static final String FOREIGN = 'Foreign';
    private static final String OVERSEAS_MILITARY = 'Overseas Military';
    private static final String SPL_HANDLING_RESOURCE_URI = '/resource/Protectedperson';
    private static final String CLASS_NAME = 'UTIL_SearchCustomer';
    private static final Date DUE_DATE = date.today();
    private enum Methods {CREATETASKFORSERVICINGAGENTS}
    private static String firedMatchingRuleName;
    private static final String ENTERPRISE_MATCH_RULE_US = 'Match_for_US_Address';
    private static final String ENTERPRISE_MATCH_RULE_NON_US = 'Match_For_Foreign_Address';
    private static final String ENTERPRISE_MATCH_RULE_POSSIBLE_DUPLICATE = 'Match_For_Possible_Duplicate';

    //Utility method to find duplicate customers for the input customer and its phone numbers
    /**
     * @description Find Duplicate Customers
     * @param searchCustomer
     * @param phoneNumbers
     * @return List<HLPR_CustSearchResultWrapper>
     */
    public static List<HLPR_CustSearchResultWrapper> findDuplicateCustomers(Account searchCustomer, List<String> phoneNumbers) {
        List<HLPR_CustSearchResultWrapper> searchResultWrapperList = null;
        CS_FeatureToggle__c skipCustMatchCS = CS_FeatureToggle__c.getInstance();
        if(skipCustMatchCS != null && !skipCustMatchCS.Skip_Customer_Search__c) {
            List<Id> dupCustIdList = new List<Id>();
           
            searchCustomer.DOBString__c = String.valueOf(searchCustomer.PersonBirthdate);
            
            Savepoint sp = Database.setSavepoint();
            searchCustomer.BillingStreet = searchCustomer.BillingStreet.replaceAll(UTIL_CreateCustomerConstants.LINE_BREAK, UTIL_CreateCustomerConstants.BLANK_SPACE);
            searchCustomer.BillingStreet = searchCustomer.BillingStreet.replaceAll(UTIL_CreateCustomerConstants.POUND, UTIL_CreateCustomerConstants.BLANK_SPACE);
            searchCustomer.ShippingStreet = searchCustomer.ShippingStreet.replaceAll(UTIL_CreateCustomerConstants.LINE_BREAK, UTIL_CreateCustomerConstants.BLANK_SPACE);
            searchCustomer.ShippingStreet = searchCustomer.ShippingStreet.replaceAll(UTIL_CreateCustomerConstants.POUND, UTIL_CreateCustomerConstants.BLANK_SPACE);

            Database.SaveResult saveResult = Database.insert(searchCustomer, false);
            if(!saveResult.isSuccess()) {
                for(Database.Error dupError : saveResult.getErrors()) {
                    createDuplicateCustomerIdList(dupError, dupCustIdList);
                }
                searchResultWrapperList = decideWhichDuplicateRuleToFire(dupCustIdList, phoneNumbers, searchCustomer);
                
            }
            else {
                Database.rollback(sp);
            }
        }
        return searchResultWrapperList;
    }

    /**
    * @description Create Duplicate CustomerId List
    * @param dupError
    * @param dupCustIdList
    */
    public static void createDuplicateCustomerIdList(Database.Error dupError, List<Id> dupCustIdList){
        if(dupError instanceof Database.DuplicateError) {
            Datacloud.DuplicateResult dupResults = ((Database.DuplicateError) dupError).getDuplicateResult();
            for(Datacloud.MatchResult dupMatchResult : dupResults.getMatchResults()) {
                firedMatchingRuleName = dupMatchResult.getRule();
                for(Datacloud.MatchRecord dupMatchRecord : dupMatchResult.getMatchRecords()) {
                    dupCustIdList.add(dupMatchRecord.getRecord().Id);
                }
            }
        }
    }

    private static List<HLPR_CustSearchResultWrapper> queryDuplicateCustomers(List<Id> dupCustIdList, List<String> phoneNumbers, Account searchCustomer) {
        List<HLPR_CustSearchResultWrapper> searchResultWrapperList = new List<HLPR_CustSearchResultWrapper>();
        for(Account dupCust : [SELECT Id, IsProtectedPerson__c, Name, PersonBirthdate, BillingStreet, BillingCity, BillingState, BillingPostalCode, ShippingPostalCode, PersonHomePhone, PersonMobilePhone, Phone, TDDPhone__c, RecordTypeId, IsHealthSourced__pc, Gender__pc,
                                (SELECT Agent__c, Agent__r.FirstName, Agent__r.LastName, Agent__r.Associate_Id__c, Agent__r.Phone, RelationshipNature__c FROM Agent_Roles__r WHERE RelationshipNature__c = :AR_CUST_RELATION) FROM Account WHERE Id IN :dupCustIdList]) {

            //set isMatch to opposite of isHealthSourced value;
            Boolean isMatch = !dupCust.IsHealthSourced__pc;

            isMatch = validateIsMatch(dupCust, phoneNumbers, searchCustomer);
            if(isMatch && String.isNotBlank(searchCustomer.Gender__pc)) {
                isMatch = matchGender(dupCust, searchCustomer.Gender__pc);
            }
            if(isMatch) {
                HLPR_CustSearchResultWrapper searchResultWrapper = populateResultWrapper(dupCust);
                searchResultWrapper.strictMatchType = true;
                if(searchResultWrapper.servicingAgents!=null && !searchResultWrapper.servicingAgents.isEmpty()) {
                    searchResultWrapperList.add(searchResultWrapper);
                }
            }
        }
        return searchResultWrapperList;
    }

    /**
    * @description Validate IsMatch
    * @param dupCust
    * @param phoneNumbers
    * @param searchCustomer
    * @return Boolean
    */
    public static Boolean validateIsMatch(Account dupCust, List<String> phoneNumbers, Account searchCustomer){

        Boolean isMatch = !dupCust.IsHealthSourced__pc;

        //	- if isMatch is false, then all later if statements fail;
        //	- if isMatch is true, then set isMatch to opposite of isProtectedPerson value;
        if(isMatch) {
            isMatch = !dupCust.IsProtectedPerson__c;
        }

        //  	* if 2nd set of isMatch is false, then all later if statements fail;
        if(isMatch) {
            ZipCodeWrapper zipcodeWrap = new ZipCodeWrapper();
            zipcodeWrap.billingAddressType = searchCustomer.BillingAddressType__c;
            zipcodeWrap.shippingAddressType = searchCustomer.ShippingAddressType__c;
            zipcodeWrap.billingZipInput = searchCustomer.BillingPostalCode;
            zipcodeWrap.shippingZipInput =  searchCustomer.ShippingPostalCode;
            zipcodeWrap.dupCust =  dupCust;

            isMatch = matchZipCode(zipcodeWrap);
        }
        if(isMatch && phoneNumbers!=null && !phoneNumbers.isEmpty()) {
            isMatch = matchPhoneNumber(dupCust, phoneNumbers);
        }
        if(isMatch && String.isNotBlank(searchCustomer.Suffix) && searchCustomer.PersonBirthdate!=null) {
            isMatch = matchDOB(dupCust, searchCustomer.PersonBirthdate);
        }

        return isMatch;
    }

    class ZipCodeWrapper{
        String billingAddressType;
        String shippingAddressType;
        String billingZipInput;
        String shippingZipInput;
        String billingZipFound;
        String shippingZipFound;
        Account dupCust;
    }

    private static Boolean matchZipCode(ZipCodeWrapper zipcodeWrap) {

        String billingAddressType = zipcodeWrap.billingAddressType;
        String shippingAddressType = zipcodeWrap.shippingAddressType;
        String billingZipInput = zipcodeWrap.billingZipInput;
        String shippingZipInput = zipcodeWrap.shippingZipInput;
        Account dupCust = zipcodeWrap.dupCust;

        Boolean isZipMatch = false;
        if(FOREIGN.equals(billingAddressType) && FOREIGN.equals(shippingAddressType)) {
            isZipMatch = true;
        }
        else {
            String billingZipFound = dupCust.BillingPostalCode;
            String shippingZipFound = dupCust.ShippingPostalCode;
            if( (US.equals(billingAddressType) || OVERSEAS_MILITARY.equals(billingAddressType)) && (String.isNotBlank(dupCust.BillingPostalCode)) ) {
                billingZipFound = dupCust.BillingPostalCode.subString(0,5);
                billingZipInput = billingZipInput.subString(0, 5);
            }
            if( (US.equals(shippingAddressType) || OVERSEAS_MILITARY.equals(shippingAddressType)) && (String.isNotBlank(dupCust.ShippingPostalCode)) ) {
                shippingZipFound = dupCust.ShippingPostalCode.subString(0, 5);
                shippingZipInput = shippingZipInput.subString(0, 5);
            }

            ZipcodeWrapper zipcodeWrap2 = new ZipcodeWrapper();
            zipcodeWrap2.billingAddressType = billingAddressType;
            zipcodeWrap2.shippingAddressType = shippingAddressType;
            zipcodeWrap2.billingZipInput = billingZipInput;
            zipcodeWrap2.shippingZipInput = shippingZipInput;
            zipcodeWrap2.billingZipFound = billingZipFound;
            zipcodeWrap2.shippingZipFound = shippingZipFound;

            isZipMatch = evaluateIsZipMatchByBillingAndShippingAddrType(zipcodeWrap2);
        }
        return isZipMatch;
    }

    /**
     * @description Evaluate IsZipMatch By Billing And Shipping Addr Type
     * @param zipcodeWrap
     * @return Boolean
     */
    public static Boolean evaluateIsZipMatchByBillingAndShippingAddrType(ZipcodeWrapper zipcodeWrap){

        String billingAddressType = zipcodeWrap.billingAddressType;
        String shippingAddressType = zipcodeWrap.shippingAddressType;
        String billingZipInput = zipcodeWrap.billingZipInput;
        String shippingZipInput = zipcodeWrap.shippingZipInput;
        String billingZipFound = zipcodeWrap.billingZipFound;
        String shippingZipFound = zipcodeWrap.shippingZipFound;

        Boolean isZipMatch = false;

        if( (!FOREIGN.equals(billingAddressType)) && (billingZipInput.equalsIgnoreCase(billingZipFound)) ) {
            isZipMatch = true;
        }
        if(!isZipMatch && !FOREIGN.equals(shippingAddressType) && shippingZipInput.equalsIgnoreCase(shippingZipFound)) {
            isZipMatch = true;
        }

        return isZipMatch;
    }

    private static Boolean matchPhoneNumber(Account dupCust, List<String> phoneNumbers){
        Boolean isPhoneMatch = false;
        for(String phoneNum : phoneNumbers) {            
            isPhoneMatch = evaluatePhoneNum(dupCust, phoneNum);
            if(isPhoneMatch){
                break;
            }
        }
        return isPhoneMatch;
    }

    private static Boolean evaluatePhoneNum(Account dupCust, String phoneNum){
        Boolean isPhoneMatch = false;

        if((String.isNotBlank(dupCust.PersonHomePhone) && phoneNum.equals(dupCust.PersonHomePhone.replaceAll(UTIL_CreateCustomerConstants.ONLY_DIGITS, UTIL_CreateCustomerConstants.EMPTY_STRING)))  ||
            (String.isNotBlank(dupCust.PersonMobilePhone) && phoneNum.equals(dupCust.PersonMobilePhone.replaceAll(UTIL_CreateCustomerConstants.ONLY_DIGITS, UTIL_CreateCustomerConstants.EMPTY_STRING))) ||
            (String.isNotBlank(dupCust.Phone) && phoneNum.equals(dupCust.Phone.replaceAll(UTIL_CreateCustomerConstants.ONLY_DIGITS, UTIL_CreateCustomerConstants.EMPTY_STRING))) ||
            (String.isNotBlank(dupCust.tddphone__c) && phoneNum.equals(dupCust.TDDPhone__c.replaceAll(UTIL_CreateCustomerConstants.ONLY_DIGITS, UTIL_CreateCustomerConstants.EMPTY_STRING)))) {
                isPhoneMatch = true;
        }
        return isPhoneMatch;
    }

    private static Boolean matchDOB(Account dupCust, Date dob) {
    	Boolean isDOBMatch = false;
    	if(dupCust.PersonBirthDate!=null && dupCust.PersonBirthDate==dob) {
    		isDOBMatch = true;
    	}
    	return isDOBMatch;
    }

    private static Boolean matchGender(Account dupCust, String gender) {
        Boolean isGenderMatch = false;
        if(String.isNotBlank(dupCust.Gender__pc) && gender.equals(dupCust.Gender__pc)) {
            isGenderMatch = true;
        }
        return isGenderMatch;
    }

    private static HLPR_CustSearchResultWrapper populateResultWrapper(Account resultCust) {
        HLPR_CustSearchResultWrapper resultWrapper = new HLPR_CustSearchResultWrapper();
        resultWrapper.accId = resultCust.Id;
        resultWrapper.custName = resultCust.Name;
        if(resultCust.IsProtectedPerson__c) {
            resultWrapper.splHandling = SPL_HANDLING_RESOURCE_URI;
        }
        if(resultCust.PersonBirthdate!=null) {
            resultWrapper.age = Integer.valueOf(resultCust.PersonBirthdate.daysBetween(Date.Today())/365.25);
        }
        resultWrapper.mailingAddress = resultCust.BillingStreet;
        if(String.isNotBlank(resultCust.BillingCity)) {
            resultWrapper.mailingAddress += UTIL_CreateCustomerConstants.COMMA + resultCust.BillingCity;
        }
        if(String.isNotBlank(resultCust.BillingState)) {
            resultWrapper.mailingAddress += UTIL_CreateCustomerConstants.COMMA + resultCust.BillingState;
        }
        if(String.isNotBlank(resultCust.BillingPostalCode)) {
            resultWrapper.mailingAddress += UTIL_CreateCustomerConstants.DASH + resultCust.BillingPostalCode;
        }
        for(AgentRole__c agentRole : resultCust.Agent_Roles__r) {
            resultWrapper.servicingAgents.add(new User(Id=agentRole.Agent__c, FirstName=agentRole.Agent__r.FirstName, LastName=agentRole.Agent__r.LastName, Associate_Id__c=agentRole.Agent__r.Associate_Id__c,
            Phone=agentRole.Agent__r.Phone, Title=agentRole.RelationshipNature__c));
        }
        return resultWrapper;
    }

    //Future method to create notification task (activity history) for the servicing agents once out of book search is verified successfully
    /**
     * @description Create Task For Servicing Agents
     * @param customerId
     * @param contactId
     * @param searchAgentName
     * @param searchAgentEmail
     * @param selectedReason
     * @param accessComments
     * @param accessKeyMatchCount
     * @param isIndividual
     */
    @future
    public static void createTaskForServicingAgents(Id customerId, Id contactId, String searchAgentName, String searchAgentEmail, String selectedReason, String accessComments, Integer accessKeyMatchCount, Boolean isIndividual) {
        try {
            List<Task> taskList = new List<Task>();
            Id defaultTaskRecordTypeId = [SELECT Id FROM RecordType Where SobjectType = :TASK AND DeveloperName = :TASK LIMIT 1].Id;
            for(AgentRole__c servicingAgentRole : [SELECT Agent__c FROM AgentRole__c WHERE RelationshipNature__c = :AR_CUST_RELATION AND Customer__c = :customerId]) {
                Task notificationTask = new Task();
                notificationTask.RecordTypeId = defaultTaskRecordTypeId;
                notificationTask.WhatId = customerId;
                notificationTask.WhoId = contactId;
                notificationTask.Subject = TASK_SUBJECT;
                notificationTask.Priority = TASK_PRIORITY;
                notificationTask.AppCode__c = TASK_APP_CODE;
                notificationTask.TaskCategory__c = TASK_CATEGORY;
                notificationTask.Task_Type__c = TASK_TYPE;
                notificationTask.Status = TASK_STATUS;
                notificationTask.OwnerId = servicingAgentRole.Agent__c;
                notificationTask.ActivityDate = DUE_DATE;
                if(isIndividual){
                notificationTask.Description = REQ_NAME + searchAgentName + UTIL_CreateCustomerConstants.LINE_BREAK + REQ_EMAIL + searchAgentEmail + UTIL_CreateCustomerConstants.LINE_BREAK +
                                                ACCESS_REASON + selectedReason + UTIL_CreateCustomerConstants.LINE_BREAK + TOKEN_VERIFY_COUNT + accessKeyMatchCount;
                }else{
                 notificationTask.Description = REQ_NAME + searchAgentName + UTIL_CreateCustomerConstants.LINE_BREAK + REQ_EMAIL + searchAgentEmail + UTIL_CreateCustomerConstants.LINE_BREAK +
                                                ACCESS_REASON + selectedReason;
                }
                if(String.isNotBlank(accessComments)) {
                    notificationTask.Description += UTIL_CreateCustomerConstants.LINE_BREAK + ACCESS_COMMENTS + accessComments;
                }
                taskList.add(notificationTask);
            }
            if(!taskList.isEmpty()) {
                Database.SaveResult[] taskSaveResults = Database.insert(taskList, false);
                LoggingService.logDatabaseResult(taskSaveResults, taskList, CLASS_NAME, Methods.CREATETASKFORSERVICINGAGENTS.name(), System.LoggingLevel.ERROR);
            }
        }
        catch(Exception exp) {
            LoggingService.logHandledException(exp, CLASS_NAME, Methods.CREATETASKFORSERVICINGAGENTS.name(), System.LoggingLevel.ERROR);
        }
    }

   
    /**
     * @description evaluate the Enterprise Possible Duplicate Account
     * @param dupCustIdList
     * @param searchCustomer
     * @return List<HLPR_CustSearchResultWrapper>
     */
    public static List<HLPR_CustSearchResultWrapper> queryEnterprisePossibleDuplicateAccount(List<Id> dupCustIdList, Account searchCustomer) {
        List<HLPR_CustSearchResultWrapper> searchResultWrapperList = null;

        CS_FeatureToggle__c skipCustMatchCS = CS_FeatureToggle__c.getInstance();
        
        if(skipCustMatchCS != null && !skipCustMatchCS.Skip_Customer_Search__c) {
 
            List<Account> queryAcctDupList = [
                                                SELECT Id, IsProtectedPerson__c, Name, PersonBirthdate, BillingStreet, BillingCity, BillingState, BillingPostalCode, ShippingPostalCode, RecordTypeId, IsHealthSourced__pc, Gender__pc, SSN__pc,
                                                (SELECT Agent__c, Agent__r.FirstName, Agent__r.LastName, Agent__r.Associate_Id__c, Agent__r.Phone, RelationshipNature__c FROM Agent_Roles__r)  
                                                FROM Account  
                                                WHERE Id IN :dupCustIdList 
                                                AND IsHealthSourced__pc = FALSE
                                                AND IsProtectedPerson__c = FALSE
            								];
           
            for(Account dupCust :queryAcctDupList){
                Boolean isPotentialMatch = determineSSN(searchCustomer.SSN__pc ,dupCust.SSN__pc);
                
                if(searchResultWrapperList == null && isPotentialMatch) {
                    searchResultWrapperList = buildSearchResultsWrapper(searchResultWrapperList, isPotentialMatch, dupCust);       
                } else if(searchResultWrapperList <> null && isPotentialMatch) {
                    searchResultWrapperList = null;
                    break; 
                }
            }
            
        }
        return searchResultWrapperList;
    }

    private static List<HLPR_CustSearchResultWrapper> decideWhichDuplicateRuleToFire(List<Id> dupCustIdList, List<String> phoneNumbers, Account searchCustomer){
        List<HLPR_CustSearchResultWrapper> searchResultWrapperList = null;
        
        if(firedMatchingRuleName.equals(ENTERPRISE_MATCH_RULE_US) ||  firedMatchingRuleName.equals(ENTERPRISE_MATCH_RULE_NON_US)){
            searchResultWrapperList = queryDuplicateCustomers(dupCustIdList, phoneNumbers, searchCustomer); 
        }else if(firedMatchingRuleName.equals(ENTERPRISE_MATCH_RULE_POSSIBLE_DUPLICATE)){
            searchResultWrapperList = queryEnterprisePossibleDuplicateAccount(dupCustIdList, searchCustomer);
        }
       return searchResultWrapperList; 
    }

    private static Boolean determineSSN(String ssn, String dbSSN) {
        Boolean validSSN = false;
        if(String.isEmpty(dbSSN) || String.isEmpty(ssn) || ssn.equalsIgnoreCase(dbSSN)) {
            validSSN = true;
        }

        return validSSN;
    }

    private static List<HLPR_CustSearchResultWrapper> buildSearchResultsWrapper( List<HLPR_CustSearchResultWrapper> searchResultWrapperList,Boolean isPotentialMatch, Account dupCust){
        List<HLPR_CustSearchResultWrapper> searchResultWrapperListTemp = searchResultWrapperList;
        if(isPotentialMatch) {
            searchResultWrapperListTemp = searchResultWrapperListTemp == null ? new List<HLPR_CustSearchResultWrapper>() : searchResultWrapperListTemp;
            HLPR_CustSearchResultWrapper searchResultWrapper = populateResultWrapper(dupCust);
            searchResultWrapper.strictMatchType = false;
            if(searchResultWrapper.servicingAgents != null && !searchResultWrapper.servicingAgents.isEmpty()) {
                searchResultWrapperListTemp.add(searchResultWrapper);
            }
        }
        return searchResultWrapperListTemp;
    }


}