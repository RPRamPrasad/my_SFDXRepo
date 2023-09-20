/**
@author CustomerView
@owner Team Atlas
@name CCV_AccountStripAtAGlance
@createDate 09/11/2022
@ModifiedDate 
@description This class is used by LWC accountAtAGlanceHouseholdMembersStrip to fetch Account data on load
@version 1.0
*/
public with sharing class CCV_AccountStripAtAGlance {
    /**
    * @description This method is used to retreive account data
    * @name : fetchAccountDetails
    * @param recordId : input record id
    * @param objectApiName : input object api name
    * @return AtAGlanceWrapper : output at a glance wrapper
    */
    @AuraEnabled (cacheable=false)
    public static AtAGlanceWrapper fetchAccountDetails(String recordId, String objectApiName) {
        try{
            String accountId;
            Account retAccount = new Account();
            Opportunity retOppty = new Opportunity();
            switch on objectApiName {
                when 'Account' {
                    retAccount = getAccountDetails(recordId);
                }
                when 'Case' {
                    accountId = CCV_RetrieveAccountIdQueryHelper.getAccountIdFromCase(recordId);
                    retAccount = getAccountDetails(accountId);
                }
                when 'Opportunity' {
                    retOppty = CCV_RetrieveAccountIdQueryHelper.getOpportunity(recordId);
                    accountId = retOppty.AccountId;
                    retAccount = getAccountDetails(accountId);
                }
                when 'InsurancePolicy' {
                    accountId = CCV_RetrieveAccountIdQueryHelper.getAccountIdFromInsurancePolicy(recordId);
                    retAccount = getAccountDetails(accountId);
                }
                when 'Billing_Account__c' {
                    accountId = CCV_RetrieveAccountIdQueryHelper.getAccountIdFromBillingAccount(recordId);
                    retAccount = getAccountDetails(accountId);
                }
                when 'Claim' {
                    accountId = CCV_RetrieveAccountIdQueryHelper.getAccountIdFromClaim(recordId);
                    retAccount = getAccountDetails(accountId);
                }
                when 'FinancialAccount__c' {
                    accountId = CCV_RetrieveAccountIdQueryHelper.getAccountIdFromFinancialAccount(recordId);
                    retAccount = getAccountDetails(accountId);
                }
            }
            AtAGlanceWrapper wrapper = new AtAGlanceWrapper();
            wrapper.account = retAccount;
            wrapper.opportunity = retOppty;
            wrapper.uiTheme = UserInfo.getUIThemeDisplayed();
            wrapper.isEditAccount = isUpdateable('Account');
            return wrapper;
        }
        catch(Exception e){
            throw new AuraHandledException('Please refresh/reload page again');
        }
    }
    
    private static Account getAccountDetails(String accountId) {
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', accountId, Account.class);
        List<Account> accounts = Security.stripInaccessible(
                                    AccessType.READABLE, [
                                    SELECT Id, RecordTypeId, RecordType.Name, RecordType.DeveloperName, Primary_Household__pc, Primary_Household__pr.Name,
                                    PreferredFirstName__c, PersonBirthdate, Age__c, Type, Industry, MailingAttention__c, PersonEmail, PersonEmailBouncedReason__c,
                                    BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, DoNotMail__c,
                                    PersonHomePhone, Phone, PersonMobilePhone, Fax, TDDPhone__c, WorkPhoneExtension__c, PersonDoNotCall, HasPermissionToServiceText__c,
                                    DeathDate__pc, IsDeathNotificationReceived__pc, PreferredSpokenLanguage__pc, HasPermissionToMarketingEmail__c,
                                    IsNotShareable__pc, IsProtectedPerson__c, IsSubjecttoCASL__c, IsHealthSourced__pc, Client_ID__c, ClientIdentifier__c, PersonContactId
                                    FROM Account
                                    WHERE Id =:String.escapeSingleQuotes(accountId)
                                    LIMIT 1
                                    ]
                                )
                                .getRecords();
        return accounts[0];
    }

    private static Boolean isUpdateable(String sObjectType){
        SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
        return schemaType.getDescribe().isUpdateable();
    }

    /**
    * @description This inner class is used to make request At A Glance Wrapper JSON
    * @name : AtAGlanceWrapper
    */
    public with sharing class AtAGlanceWrapper {
        /**
        * @description account
        */
        @AuraEnabled
        public Account account{get;set;}
        /**
        * @description opportunity
        */
        @AuraEnabled
        public Opportunity opportunity{get;set;}
        /**
        * @description uiTheme
        */
        @AuraEnabled
        public String uiTheme{get;set;}
        /**
        * @description isEditAccount
        */
        @AuraEnabled
        public Boolean isEditAccount{get;set;}
        /**
        * @description isViewAccount
        */
        @AuraEnabled
        public Boolean isViewAccount{get;set;}
    }
}