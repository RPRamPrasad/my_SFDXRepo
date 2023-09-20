/**
* @name CombineCustomersController  
* @owner Atlas
* @date 10/11/2018  
* @description Combine Customers Page Onload controller to get customer group members
*/
public with sharing class CombineCustomersController {
    private static final String CLASS_NAME = 'CombineCustomersController';
    private static final String ERROR_MESSAGE = 'There is a problem with the action you performed. Please Try Again. If the problem persists, please contact your normal support channel.';
	

    /**
    * @description : This method will load all the Household members for a given record Id
    * @name :getCustomerGroupMembers
    * @param recordId
    * @return :  List<Account>
    */
    
    @AuraEnabled
    public static List<Account> getCustomerGroupMembers(Id recordId){
        String methodName = 'getCustomerGroupMembers';
        try {
            Id customerGroup =  getCustomerGroupDetails(recordId);
            List<Id> customerIds = getCustomerIdsInGroup(customerGroup);
            List<Account> groupMembers = getGroupMembers(customerIds);
            return groupMembers;
        } catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
			throw new AuraHandledException(ERROR_MESSAGE);
        }

    }
   
    private static String getLoggedInUser(){
        String userId = userInfo.getUserId();
        List<User> loggedInUser =  Security.stripInaccessible(AccessType.READABLE,[ select Id, Name, Associate_ID__c, profileId, Servicing_Agent_External_ID__c 
                                                                                    from User where Id =:userId limit 1]).getRecords();
        return loggedInUser.get(0).Servicing_Agent_External_ID__c;
    }
    
    private static Id getCustomerGroupDetails(Id recordId) {
        String servicingAgentExternalId = getLoggedInUser();
        List<CustomerGroupMember__c> customerGroupMembers;
        
        customerGroupMembers = Security.stripInaccessible(AccessType.READABLE,[select Id, Group__r.Agent__c, Group__c, Customer__r.FirstName, Customer__r.LastName
                                                                                from CustomerGroupMember__c where Group__r.Agent__r.UserExternalID__c =:servicingAgentExternalId AND Customer__c =:recordId limit 1]).
                                                                                getRecords();
        return customerGroupMembers.get(0).Group__c;
    }
    
    private static List<Account> getGroupMembers(List<Id> customerIds){
        
        List<Account> accountList  = Security.stripInaccessible(AccessType.READABLE,[select RecordType.Name, Id, clientidentifier__c, Name, LastName, FirstName, PersonBirthdate, 
                                                                BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, PersonHomePhone, PersonMobilePhone, 
                                                                PersonOtherPhone, Phone, PersonEmail, DriversLicenseNumber__c, DriversLicenseStateProvince__c, EmployerName__pc 
                                                                from Account where id IN :customerIds]).getRecords();
        return accountList;
    }
    
    private static List<Id> getCustomerIdsInGroup(Id customerGroup) {
        List<Id> customerIds = new List<Id>();
        
        List<SObject> customersList = Security.stripInaccessible(AccessType.READABLE,[select Customer__c from CustomerGroupMember__c where Group__c =:customerGroup]).getRecords();
        for(SObject customerSObj : customersList) {
            customerIds.add((Id) customerSObj.get('Customer__c'));
        }
        return customerIds;
    }
    
    
    // Added for PickList options
   /**
    * @description Get Merge UI PickList Values For Individual
    * @return MergeUIPickListWrapper
    */
    @AuraEnabled
    public static MergeUIPickListWrapper getMergeUIPickListValuesForIndividual() {
        String methodName = 'getMergeUIPickListValuesForIndividual';
        List<String> languageOptions = new List<String>();
        List<String> maritalStatusOptions = new List<String>();
        List<String> citizenshipOptions = new List<String>();

        try {
            Schema.DescribeFieldResult maritalStatusfieldResult = Contact.MaritalStatus__c.getDescribe();
            for (Schema.PicklistEntry singleMSvalue:maritalStatusfieldResult.getPickListValues()){
                maritalStatusOptions.add(singleMSvalue.getValue());
            }

            Schema.DescribeFieldResult pLanguagefieldResult = Contact.PreferredSpokenLanguage__c.getDescribe();
            for (Schema.PicklistEntry singlePLvalue:pLanguagefieldResult.getPickListValues()){
                languageOptions.add(singlePLvalue.getValue());
            }
            
            Schema.DescribeFieldResult citizenshipfieldResult = Contact.Citizenship__c.getDescribe();
            for (Schema.PicklistEntry singleCitizenshipvalue:citizenshipfieldResult.getPickListValues()){
                citizenshipOptions.add(singleCitizenshipvalue.getValue());
            }
            
            MergeUIPickListWrapper mergeUIPickListWrapper = new MergeUIPickListWrapper();
            mergeUIPickListWrapper.prefferedLanguage = languageOptions;
            mergeUIPickListWrapper.maritalStatus = maritalStatusOptions;
            mergeUIPickListWrapper.citizenship = citizenshipOptions;
    
            return mergeUIPickListWrapper;
            
        } catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
			throw new AuraHandledException(ERROR_MESSAGE);
        }
    } 
    
    /**
     * @description Get Merge UI PickList Values For Organization
     * @return List<String>
     */
    @AuraEnabled
    public static List<String> getMergeUIPickListValuesForOrganization() {
        String methodName = 'getMergeUIPickListValuesForOrganization';
        List<String> organizationTypeOptions = new List<String>();
        try {
            Schema.DescribeFieldResult organizationTypefieldResult = Account.Type.getDescribe();
            for (Schema.PicklistEntry singleTypevalue:organizationTypefieldResult.getPickListValues()){
                organizationTypeOptions.add(singleTypevalue.getValue());
            }
            return organizationTypeOptions;
        } catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
			throw new AuraHandledException(ERROR_MESSAGE);
        }

    }
    
    /**
     * @description Merge UI PickList Wrapper
     */
    public with sharing class MergeUIPickListWrapper {

        /**
         * @description prefferedLanguage getters and setters
         */
        @AuraEnabled
        @TestVisible public List<String> prefferedLanguage {get; set;}        

        /**
         * @description maritalStatus getters and setters
         */
        @AuraEnabled
        @TestVisible public List<String> maritalStatus {get; set;}

        /**
         * @description citizenship getters and setters
         */
        @AuraEnabled
        @TestVisible public List<String> citizenship {get; set;}
    }
}