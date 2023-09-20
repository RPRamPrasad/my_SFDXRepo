/****************************************************************************************
Name: HLPR_OppSFComLeadValidation
Copyright © State Farm
=========================================================================================
Purpose:
-------
Decription: This is a helper class is responsible for validating the account information and error message information.
Team: QuadCore
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Venkata Padigala        05/14/2020            Initial Development 

******************************************************************************************/
/**
 * @description HLPR_OppSFComLeadValidation
 */
public without sharing class HLPR_OppSFComLeadValidation {
    private static final String NULL_SYMBOL = '';
    /**
     * @description validAllAccountData This method valid the account data
     *
     * @param sFCom (HLPR_SFComLeadRequest): sFCom }
     * @param account (Account): account }
     * @return Account: account 
     */
    public static Account validAllAccountData(HLPR_SFComLeadRequest sFCom, Account account){
        validateStreet(sFCom,account);
        validateAccountData(sFCom,account);
        return account;
    }
    /**
     * @description validateStreet - this method validate the street data
     *
     * @param sFCom (HLPR_SFComLeadRequest): sFCom description}
     * @param account (Account): account description}
     * @return Account: account information which is updated with street address information
     */
    private static Account validateStreet(HLPR_SFComLeadRequest sFCom, Account account){
        String street;
        
        if(String.isNotBlank(sFCom.leadaccount.Address)){
            street=sFCom.leadaccount.Address;
        }
        if(String.isNotBlank(sFCom.leadaccount.Address2)){
            street=Street + NULL_SYMBOL + sFCom.leadaccount.Address2;
        }

        if(String.isNotBlank(street)) {
            account.BillingStreet=street;
        }
        
          // Below variables are created for Phone Defect fix
         if(String.isNotBlank(sFCom.leadaccount.Phone)){
            account.Phone=sFCom.leadaccount.Phone.replaceAll(UTIL_CreateCustomerConstants.ONLY_DIGITS, UTIL_CreateCustomerConstants.EMPTY_STRING);//Work
            if(String.isNotBlank(sFCom.leadaccount.WorkPhoneExtension)) {
                account.WorkPhoneExtension__c=sFCom.leadaccount.WorkPhoneExtension.replaceAll(UTIL_CreateCustomerConstants.ONLY_DIGITS, UTIL_CreateCustomerConstants.EMPTY_STRING);	
            }
        }
        return account;
    }
    /**
     * @description validateAccountData 
     *
     * @param sFCom (HLPR_SFComLeadRequest): sFCom description}
     * @param account (Account): account description}
     * @return Account: account information which is updated with all account information
     */
    private static Account validateAccountData(HLPR_SFComLeadRequest sFCom, Account account){
        
        validateMobilePhoneFields(sFCom, account);

        validatePermissions(sFCom, account);
        
        if(sFCom.leadaccount.IsHearingImpaired!=null) {
            account.IsHearingImpaired__pc=sFCom.leadaccount.IsHearingImpaired;
        }
        
        if(sFCom.leadaccount.PersonDoNotCall!=null) {
            account.PersonDoNotCall=sFCom.leadaccount.PersonDoNotCall;
        }
        
        validateAddress(sFCom, account);
        if(String.isNotBlank(sFCom.leadaccount.Zip)) {
            account.BillingPostalCode =sFCom.leadaccount.Zip;
        }
        return account;
    }
    /**
     * @description validateMobilePhoneFields 
     *
     * @param sFCom (HLPR_SFComLeadRequest): sFCom description}
     * @param account (Account): account description}
     * @return Account: account information which is updated with phone information
     */
    private static Account validateMobilePhoneFields(HLPR_SFComLeadRequest sFCom, Account account){
        if(String.isNotBlank(sFCom.leadaccount.PersonMobilePhone)) {
            account.PersonMobilePhone=sFCom.leadaccount.PersonMobilePhone.replaceAll(UTIL_CreateCustomerConstants.ONLY_DIGITS, UTIL_CreateCustomerConstants.EMPTY_STRING);//Mobile
        }
        
        if(String.isNotBlank(sFCom.leadaccount.PersonHomePhone)) {
            account.PersonHomePhone=sFCom.leadaccount.PersonHomePhone.replaceAll(UTIL_CreateCustomerConstants.ONLY_DIGITS, UTIL_CreateCustomerConstants.EMPTY_STRING);//Home phone
        }
        
        if(String.isNotBlank(sFCom.leadaccount.TDDPhone)) {
        	account.TDDPhone__c=sFCom.leadaccount.TDDPhone.replaceAll(UTIL_CreateCustomerConstants.ONLY_DIGITS, UTIL_CreateCustomerConstants.EMPTY_STRING);//Tdd phone
        }
        return account;
    }
    /**
     * @description validatePermissions 
     *
     * @param sFCom (HLPR_SFComLeadRequest): sFCom description}
     * @param account (Account): account description}
     * @return Account: account information which is updated with permision information
     */
    private static Account validatePermissions(HLPR_SFComLeadRequest sFCom, Account account){
        if(String.isNotBlank(sFCom.leadaccount.HasPermissiontoText)) {
        	account.HasPermissiontoText__c=sFCom.leadaccount.HasPermissiontoText;
        }
        
        if(String.isNotBlank(sFCom.leadaccount.HasPermissionToServiceText)) {
        	account.HasPermissionToServiceText__c=sFCom.leadaccount.HasPermissionToServiceText;
        }
        
        if(String.isNotBlank(sFCom.leadaccount.HasPermissionToClaimText)) {
        	account.HasPermissionToClaimText__c=sFCom.leadaccount.HasPermissionToClaimText;
        }
        return account;
    }
    /**
     * @description validateAddress 
     *
     * @param sFCom (HLPR_SFComLeadRequest): sFCom description}
     * @param account (Account): account description}
     * @return Account: account information which is updated with address information
     */
    private static Account validateAddress(HLPR_SFComLeadRequest sFCom, Account account){
        if(String.isNotBlank(sFCom.leadaccount.City)) {
            account.BillingCity=sFCom.leadaccount.City;
        }
        if(String.isNotBlank(sFCom.leadaccount.State)) {
            account.BillingState =sFCom.leadaccount.State;
        }
        if(String.isNotBlank(sFCom.leadaccount.Country)) {
            account.BillingCountry =sFCom.leadaccount.Country;
        }
        return account;
    }
     /**
     * @description This method is used to set the error message corresponding missing field
     * @param sFComLead -HLPR_SFComLeadRequest
     * @param proxy -User
	*/
    
    public static void nameErrorMessageSetting(HLPR_SFComLeadRequest sFComLead, User proxy){
        if(String.isBlank(sFComLead.leadaccount.ClientID) ){
            throw new SFCom_LeadMessageServiceException(System.Label.CL_Invalid_Client_Identifier);
        }else if(String.isBlank(sFComLead.leadaccount.LastName)) {
            throw new SFCom_LeadMessageServiceException(System.Label.CL_LastName_Reqd);
        }  else if(String.isBlank(sFComLead.leadaccount.AccountType)) {
            throw new SFCom_LeadMessageServiceException(System.Label.CL_AccountType_Invalid_Message);
        } else if(String.isBlank(sFComLead.leadopportunity.Name)) {
            throw new SFCom_LeadMessageServiceException(System.Label.CL_Name_Reqd);
        }      
    }   
}