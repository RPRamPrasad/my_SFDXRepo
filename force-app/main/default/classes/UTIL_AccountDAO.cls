/**
@author Team Loco-Motivated/Impact Force
@owner Team Stark
@name UTIL_AccountDAO
@createDate 9/21/2016
@description Common class to access various Task related operations for various Processor.
@version 1.0
*/
public without sharing class UTIL_AccountDAO implements UTIL_AccountIDAO{
    
    /**
    * @description Takes the Account Records
    * @name deleteAccount
    * @param accRecord Records
    */
    public static void deleteAccount(Account accRecord){
        if(accRecord!=null)
        {
            delete accRecord;
        }
    }
    
    /**
    * @description insert account
    * @name insertAccount
    * @param account - Account object
    */
    public static void insertAccount(Account account) {
        if(account != null) {
            insert account; 
        }
    } 
    
   
    /**
    * @description update account
    * @name updateAccount
    * @param account - a Account object
    */
    public static void updateAccount(Account account) {
        if(account != null) {
            update account;          
        }
    }
    
    /**
    * @description upsert Account
    * @name upsertAccount
    * @param account - an Account object
    */
    public static void upsertAccount(Account account) {
        if(account != null) {
            upsert account ClientIdentifier__c;           
        }
    } 
    
    /**
    * @description Takes the account and upserts it based on the external id (Client Identifier)
    * @name : upsertAccountByClientIdentifier
    * @param account - an Account object
    */
    public static void upsertAccountByClientIdentifier(Account account) {
        if(account != null) {
            upsert account ClientIdentifier__c;
        } 
    }
    
   /**
    * @description Takes the List of Accounts and deletes them
    * @name : deletetAccounts
    * @param accountList
    */
    public static void deleteAccounts(List<Account> accountList) {
        if(accountList != null && !accountList.isEmpty()) {
            delete accountList;
        } 
    }
    
   /**
    * @description Takes the List of Accounts and inserts them
    * @name : insertAccounts
    * @param accountList
    */
    public static void insertAccounts(List<Account> accountList) {
        if(accountList != null && !accountList.isEmpty()) {
            insert accountList;
        } 
    }
    
   /**
    * @description Takes the List of Accounts and upserts them
    * @name : upsertAccounts
    * @param accountList
    */
    
    public static void upsertAccounts(List<Account> accountList) {
        if(accountList != null && !accountList.isEmpty()) {
            upsert accountList;
        } 
    }
    
    /**
    * @description Takes List of accounts and upserts it based on the external id (Client Identifier)
    * @name : upsertAccountsByClientIdentifier
    * @param accountList
    */
    
    public static void upsertAccountsByClientIdentifier(List<Account> accountList) {
        if(accountList != null && !accountList.isEmpty()) {
            upsert accountList ClientIdentifier__c;
        } 
    }
    
    /**
    * @description Takes the List of Accounts and updates them
    * @name : updateAccounts
    * @param accountList
    */
    public static void updateAccounts(List<Account> accountList) {
        if(accountList != null && !accountList.isEmpty()) {
            update accountList;
        } 
    }

    /**
    * @description insert account list
    * @name : insertAccountResult
    * @param accountsToBeInserted
    * @return List<Database.SaveResult>
    */
    public static List<Database.SaveResult> insertAccountResult(List<Account> accountsToBeInserted){
        List<Database.SaveResult> accountsInsertedResult = Database.insert(accountsToBeInserted, false);
        return accountsInsertedResult;
    }

    /**
    * @description update account list
    * @name : updatedAccountResult
    * @param accountsToBeUpdated
    * @return List<Database.SaveResult>
    */
    public static List<Database.SaveResult> updatedAccountResult(List<Account> accountsToBeUpdated){
        List<Database.SaveResult> accountsUpdatedResult = Database.update(accountsToBeUpdated, false);
        return accountsUpdatedResult;
    }
    
    /**
    * @description fetch account record
    * @name : getAccountInformation
    * @param accountId
    * @return Account
    */
	public static Account getAccountDetails(Id accountId){
        
		return [ SELECT Id, RecordTypeId, Name, Salutation, FirstName, MiddleName, LastName, Suffix, PreferredFirstName__c, Designation__pc, 
            PersonBirthdate, Gender__pc, MaritalStatus__pc, EmployerName__pc, DriversLicenseNumber__c, DriversLicenseStateProvince__c, 
            Type, MailingAttention__c, MailingInCareOf__c, BillingStreet, ShippingStreet, BillingCity, ShippingCity, isPersonAccount, PersonContactId,  
            BillingState, ShippingState, BillingPostalCode, ShippingPostalCode, BillingCountry, ShippingCountry, PersonHomePhone, Phone, 
            PersonMobilePhone, TDDPhone__c, Fax, PersonEmail, IsSubjecttoCASL__c, ClientIdentifier__c, BillingAddressType__c, ShippingAddressType__c, 
            IsNotShareable__pc, IsPrivacyOptionsShared__c, HasPermissionToServiceText__c, WorkPhoneExtension__c, HasConfirmedNoEmail__c, Citizenship__pc, 
            DeathDate__pc, IsDeathNotificationReceived__pc, HasPermissionToServiceEmail__c, HasPermissionToClaimEmail__c, HasPermissionToClaimText__c, 
            HasPermissionToMarketingEmail__c, IsHearingImpaired__pc, PreferredSpokenLanguage__pc, SSN__pc, TIN__c, OccupationCategory__pc, OccupationStatus__pc, 
            OccupationStartDate__pc, Occupation__pc, PersonEmailBouncedReason__c, Policy_Notices_Email__c, Billing_Statements__c, PolicyDocuments__c, 
            LivingArrangements__c, LivingArrangementsOtherDescription__c, BusinessOwnerIndicator__c, SFPPBillRemindersEmail__c, 
            Industry, AnnualRevenue, BillAlertText__c, RecordType.Name, RecordType.DeveloperName 
            FROM Account 
            WHERE  Id=:accountId WITH SECURITY_ENFORCED Limit 1 ];

	}
    
    /**
    * @description This method is used to upsert Account created or edited through Account page
    * @name : upsertCustomer
    * @param customer
    */
    public static void upsertCustomer(Account customer) {
        if(customer != null) {
            Database.upsert(customer, Account.Fields.ClientIdentifier__c, true);
        }
    }

    /**
    * @description This method is used to upsert Account created or edited through Account page
    * @name : upsertCustomerRec
    * @param customer
    */
    public void upsertCustomerRec(Account customer) {
        upsertCustomer(customer);
    }

    /**
    * @description This method is used to update Account edited through Account page
    * @name : updateCustomer
    * @param customer
    */
    public static void updateCustomer(Account customer) {
        if(customer != null) {
            Database.update(customer,true);
        }
    }

    /**
    * @description This method is used to update Account edited through Account page
    * @name : updateCustomerRec
    * @param customer
    */
    public void updateCustomerRec(Account customer) {
        updateCustomer(customer);
    }
    
}