/**
 * @Author: ITIC & Loco-Motivated
 * @description : Trigger Handler class for Standard Account (Customer) records
 * Updated 4/15/2019 by ITIC to trigger a blank update on associated campaign members when an account goes from no phone number to having a phone number
 * Updated 12/30/2020 By Targaryen to create Household records without Client Identifier and allow Sync User to set Ownership to System Record Owner
 */
public with sharing class AP_AccountTrigger {
    
    private static final String FINSERV_NAMESPACE = 'finserv__';
    public static boolean iAmTrustworthy = false;
    private static final String HOUSEHOLD_RECORD_TYPE = 'IndustriesHousehold';
    private static String householdRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId();

    @TestVisible private static UTIL_ToggleStrategyContext toggleContext = new UTIL_ToggleStrategyContext();
     /**
      * @description : This method will Set the Owner of input Account Record/records to the Default Statefarm System User
      * @param newAccountsList
      */
    public static void setAccountOwnerToSystemUser(List<Account> newAccountsList) {
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = AccountOwnerSystemUserCustomSetting__c.getInstance();
        
        if(sysAdminUserIdSetting != null && !String.isBlank(sysAdminUserIdSetting.SFDC_User_ID__c)) {
            for(Account customer : newAccountsList) {           
                if (!customer.recordTypeId.equals(householdRecTypeId)) { 
                   setForIndividualAndOrgAccount(customer,sysAdminUserIdSetting);
                }  else if(isSyncUser(UserInfo.getName())){   
                   customer.OwnerId = sysAdminUserIdSetting.SFDC_User_ID__c; // Keeping Household Owner as System Record Owner when HH is inserted by Sync User
                } else {
                    AP_AccountContactRelationHandler.isCreateHousehold = true; //Checking to run Create Household Flow
                }
            }
        }else {
            throw new RecordOwnerException(System.Label.CL_SystemUserNotFound);          
        }
    }

    /**
      * @description This static method will set the value of Ownership, Client Identifier and HealthSourced for Individual and Organization Account
      * @param customer
      * @param sysAdminUserIdSetting
      */
    private static void setForIndividualAndOrgAccount(Account customer, AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting){
        if(String.isNotBlank(customer.ClientIdentifier__c) || customer.IsMatchRequired__c) {                
            customer.OwnerId = sysAdminUserIdSetting.SFDC_User_ID__c;
            customer.clientIdentifier__pc = customer.clientIdentifier__c; // Mapping Account ClientIdentifier to PersonContact ClientIdentifier
            customer.Health_Restricted_Flag__c=customer.IsHealthSourced__pc; // Copied value of HealthSourced field of Contacts to HealthRestrictedFlag of Account
            customer.DOBString__c = String.valueOf(customer.PersonBirthdate);
        }
        else {
            customer.addError(System.Label.CL_ErrorMsgForAccInsertWithoutClientId);
        }
    }
    
    /**
      * @description This static method will restrict Users from updating the Account Owner to anyone other than Statefarm User -preventAccountOwnerChange
      * @param accountToUpdateOwner
      * @param oldAccountMap
      */
    public static void preventAccountOwnerChange(List<Account> accountToUpdateOwner, Map<Id, Account> oldAccountMap) {
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = AccountOwnerSystemUserCustomSetting__c.getInstance();
        
        if(sysAdminUserIdSetting != null) {
            for(Account customer : accountToUpdateOwner) {
                if(customer.ownerId!=oldAccountMap.get(customer.id).ownerId
                    && customer.ownerId != sysAdminUserIdSetting.SFDC_User_ID__c) {
                    customer.addError(System.Label.CL_AccountOwnerPreventError);
                }
                customer.Health_Restricted_Flag__c=customer.IsHealthSourced__pc; // Copied value of HealthSourced field of Contacts to HealthRestrictedFlag of Account
                customer.DOBString__c = String.valueOf(customer.PersonBirthdate);
            }
        }else {
            throw new RecordOwnerException(System.Label.CL_SystemUserNotFound);
        
        }

    }
    
    /**  
      *  @description Utility method to verify and disable inline edit of account from list views and allow edits from account VF pages
      *  @param  newAccountsList
      *  @param  oldAccountMap
      */
    public static void verifyAndDisableInlineEdit(List<Account> newAccountsList , Map<Id, Account> oldAccountMap) {
        List<String> finservAccountFields = new List<String>();
        for(String fieldName : Schema.SObjectType.Account.fields.getMap().keySet()) {
            if(fieldName.startsWith(FINSERV_NAMESPACE)) {
                finservAccountFields.add(fieldName);
            }
        }
        verifyAccountInlineEditAccess(newAccountsList, oldAccountMap, finservAccountFields);
    }
    private static void verifyAccountInlineEditAccess(List<Account> newAccountsList, Map<Id, Account> oldAccountMap,
                        List<String> finservAccountFields) {
        String pageUrl = UTIL_CreateCustomerConstants.EMPTY_STRING;
        if(ApexPages.currentPage() != null && ApexPages.currentPage().getUrl() != null){
            pageUrl = ApexPages.currentPage().getUrl().tolowerCase();
        }
        Boolean isAPIUser = toggleContext.isActive(UTIL_Toggles.RESTRICTACCOUNTINLINEEDIT);
        for(Account customer : newAccountsList) {
             if(isAPIUser || pageUrl.contains(UTIL_CreateCustomerConstants.IND_CREATE_EDIT_PAGE)
                    || pageUrl.contains(UTIL_CreateCustomerConstants.ORG_CREATE_EDIT_PAGE) || pageUrl.contains(UTIL_CreateCustomerConstants.ENT_CUST_SEARCH_PAGE)
                    || iAmTrustworthy) {
                 customer.Edit_In_VFP__c = true;
             }
             setInLineEditError(oldAccountMap, finservAccountFields, customer);           
             customer.Edit_In_VFP__c = false;
        }
    }
    
    private static void setInLineEditError(Map<Id, Account> oldAccountMap, List<String> finservAccountFields,
                        Account customer) {
        for(String finservField : finservAccountFields) {
                if(customer.get(finservField) != oldAccountMap.get(customer.Id).get(finservField)) {
                   customer.Edit_In_VFP__c = true;
                   break;
                }
        }
        if(!customer.Edit_In_VFP__c && !customer.recordTypeId.equals(householdRecTypeId)) {
                customer.addError(System.Label.CL_AccountInlineEditPreventMessage);
             }
    }
    /**
      *  @description method to handle accounts updates for compaign members
      *  @param  newStateOfAccounts 
      *  @param  priorStateOfAccounts  
      */
    public void handleAccountsAfterUpdate(List<Account> newStateOfAccounts, Map<Id,Account>  priorStateOfAccounts){
           AP_AccountTriggerHelper  accountTriggerHelper = new AP_AccountTriggerHelper();
           accountTriggerHelper.handleAccountsAfterUpdate(newStateOfAccounts, priorStateOfAccounts);
    }

    /** 
      * @description Method to update organization account records sourced from LeadConversion.
      * @param  accountList
    */
    public static void updateOrgAccountForLead(List<Account> accountList) {
        //Blanking the First Name for Organization Account - Sourced from LeadConversion
        AP_AccountTriggerHelper.updateOrgAccountForLead(accountList);
    }
    
     /**
      * @description This method is to determine if the user is sync API user
      * @param userName
      * @return boolean
      */
    public static boolean isSyncUser(String userName){
        return userName.equals(CS_Household_Check_For_Sync_User__c.getInstance().UserName__c);
    }
    
}