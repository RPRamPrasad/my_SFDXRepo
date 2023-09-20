/****************************************************************************************
Name: UTIL_OpportunityProcessing
Purpose: Dependent processing class for WS_OpportunityApiRestEndpoint
VERSION History         AUTHOR                    DATE                   DETAIL
1.0                     CLUB_CAR                  07-01-2018             2018 R6 Release
******************************************************************************************/
/**
 * @description UTIL_OpportunityProcessing
 */
public with sharing class UTIL_OpportunityProcessing {
    
    public static final String OPPORTYNITY_ORIGINATOR_SFCOM ='Statefarm.com';   
    private static final String NULL_SYMBOL = '';
    private static final Date CLOSED_DATE = Date.today() + 60; 
    private static final String OPPORTUNITY_OPPMGMNT_RECORD_TYPE = 'Opportunity_Management';
    private static final String OPPORTUNITY_ORIGINATOR_ILP = 'Internet Lead Provider';
    public static final String OPPORTYNITY_STAGE_NEW ='New';
    public static final Integer PLMOD_APP_CODE = 15;
    
    /**
     * @description setStringOppField
     * @param opp 
     * @param fieldName 
     * @param fieldValue 
     */
    public static void setStringOppField(Opportunity opp, Schema.SObjectField fieldName, String fieldValue) {
        if(String.isNotBlank(fieldValue)) {
            opp.put(fieldName, fieldValue);
        }
    }
    
    private static void setStringAcctField(Account acct, Schema.SObjectField fieldName, String fieldValue) {
        if(String.isNotBlank(fieldValue)) {
            acct.put(fieldName, fieldValue);
        }
    }
    
    private static void setAccountFields(Account acct, HLPR_CreateOppRequest createOpp) {
        acct.ClientIdentifier__c  = createOpp.accountData.ClientID;
        acct.FirstName = createOpp.accountData.FirstName;
        acct.LastName = createOpp.accountData.LastName;
        //acct.isHearingImpaired__pc = createOpp.accountData?.IsHearingImpaired;
        //acct.PersonDoNotCall = createOpp.accountData?.PersonDoNotCall;
        if(createOpp.accountData.IsHearingImpaired!=null) {
            acct.IsHearingImpaired__pc=createOpp.accountData.IsHearingImpaired;
        }
        
        if(createOpp.accountData.PersonDoNotCall!=null) {
            acct.PersonDoNotCall=createOpp.accountData.PersonDoNotCall;
        }
        setStringAcctField(acct, Account.PersonEmail, createOpp.accountData.EmailAddress);
        setStringAcctField(acct, Account.PersonMobilePhone, createOpp.accountData.PersonMobilePhone.replaceAll(UTIL_CreateCustomerConstants.ONLY_DIGITS, UTIL_CreateCustomerConstants.EMPTY_STRING));
        setStringAcctField(acct, Account.PersonHomePhone, createOpp.accountData.PersonHomePhone.replaceAll(UTIL_CreateCustomerConstants.ONLY_DIGITS, UTIL_CreateCustomerConstants.EMPTY_STRING));
        setStringAcctField(acct, Account.TDDPhone__c, createOpp.accountData.TDDPhone.replaceAll(UTIL_CreateCustomerConstants.ONLY_DIGITS, UTIL_CreateCustomerConstants.EMPTY_STRING));  
        setStringAcctField(acct, Account.HasPermissiontoText__c, createOpp.accountData.HasPermissiontoText);
        setStringAcctField(acct, Account.HasPermissionToServiceText__c, createOpp.accountData.HasPermissionToServiceText);
        setStringAcctField(acct, Account.HasPermissionToClaimText__c, createOpp.accountData.HasPermissionToClaimText);
        setStringAcctField(acct, Account.BillingCity, createOpp.accountData.City);   
        setStringAcctField(acct, Account.BillingState, createOpp.accountData.State);   
        setStringAcctField(acct, Account.BillingCountry, createOpp.accountData.Country);   
        setStringAcctField(acct, Account.BillingPostalCode, createOpp.accountData.Zip);     
    }
    
    /**
*  Sets up and Upserts the AgentRole
*  @description  upsertAgentRole
*  @param oppRequest - The incoming LeadVendorMessage
*  @param usr - The Agent User for the Agent Role
*  @param acc - The upserted Account
*  @return agentRole - The upserted AgentRole is returned
*/
    
    public static AgentRole__c upsertAgentRole(HLPR_CreateOppRequest oppRequest, User usr, Account acc) {
        AgentRole__c agentRole = new AgentRole__c();
        
        agentRole.Agent__c=usr.id;
        agentRole.AgentRoleIdentifier__c= oppRequest.agentOfficeData.agentAssociateID + UTIL_Constants.TILT_SYMBOL + oppRequest.accountData.ClientID;
        agentRole.Customer__c=  acc.id;    
        UTIL_AgentRoleDAO.upsertUserAgentRoles(new List<AgentRole__c>{agentRole});         
        return agentRole;
    }
    /**
* @description This method is used to constructAccount, just creating new Account object and copy the date from HLPR_CreateOppRequest.accountData to Account
* @param createOpp -HLPR_CreateOppRequest
* @return -Account
*/
    public static Account constructAccount(HLPR_CreateOppRequest createOpp) {
        
        String accountRecordTypeId = '';
        Map<String, Schema.Recordtypeinfo> accountRecordTypeMap=Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();
        try {
            accountRecordTypeId = accountRecordTypeMap.get(createOpp.accountData.AccountType).RecordTypeId;
        } catch (Exception e) {
            throw new SFCom_LeadMessageServiceException(System.Label.CL_AccountType_Invalid_Message);            
        }
        
        if(String.isBlank(accountRecordTypeId)) {// we shouldn't throw exception. this field should set by prospect management service.
            throw new SFCom_LeadMessageServiceException(System.Label.CL_AccountType_Invalid_Message);  
        }
        
        Account acct = new Account(); 
        acct.RecordTypeId = accountRecordTypeId; 
        String street;        
        if(String.isNotBlank(createOpp.accountData.Address)){
            street=createOpp.accountData.Address;
        }
        if(String.isNotBlank(createOpp.accountData.Address2)){
            street=Street + NULL_SYMBOL + createOpp.accountData.Address2;
        }        
        setStringAcctField(acct, Account.BillingStreet, street);  
        
        // Below variables are created for Phone Defect fix
        setStringAcctField(acct, Account.Phone, createOpp.accountData.Phone.replaceAll(UTIL_CreateCustomerConstants.ONLY_DIGITS, UTIL_CreateCustomerConstants.EMPTY_STRING));
        if(String.isNotBlank(createOpp.accountData.WorkPhoneExtension) && String.isNotBlank(acct.Phone)) {
            acct.WorkPhoneExtension__c=createOpp.accountData.WorkPhoneExtension.replaceAll(UTIL_CreateCustomerConstants.ONLY_DIGITS, UTIL_CreateCustomerConstants.EMPTY_STRING);
        } 
        setAccountFields(acct, createOpp);
        return acct;
    }
    /**
* @description This method is used to constructOpportunity, just creating new Opportunity object and copy the date from HLPR_CreateOppRequest.opportunityData to Opportunity
* @param createOpp -HLPR_CreateOppRequest
* @param account
* @param proxyExternalID
* @return -Opportunity
*/
    public static Opportunity constructOpportunity(HLPR_CreateOppRequest createOpp, Account account, String proxyExternalID) {
        Opportunity opp = new Opportunity();     
        opp.recordtypeId = assignRecordTypeIDtoOpportunity(OPPORTUNITY_OPPMGMNT_RECORD_TYPE);
        opp.Name = createOpp.opportunityData.Name;
        opp.StageName =OPPORTYNITY_STAGE_NEW;
        opp.CloseDate = CLOSED_DATE;
        opp.LOB__c = createOpp.opportunityData.LOB;
        Id profileId = userinfo.getProfileId();
        String profileName = [Select Id, Name from Profile where Id=:profileId].Name;
        String partnerProfileName = System.label.ServiceUser;
        if(partnerProfileName.equals(profileName) ) {
            opp.DateCaptured__c = system.now();
        }
        setStringOppField(opp, Opportunity.Opportunity_Originator__c, createOpp.opportunityData.Opportunity_Originator);
        setStringOppField(opp, Opportunity.Marketing_Source__c, createOpp.opportunityData.MarketingSource);
        setStringOppField(opp, Opportunity.Temperature__c, createOpp.opportunityData.Temperature);
        setStringOppField(opp, Opportunity.Product__c, createOpp.opportunityData.Product);
        setStringOppField(opp, Opportunity.EventCode__c, createOpp.opportunityData.EventCode);
        opp.Simple_Conversation__c = createOpp.opportunityData?.SimpleId;
        setStringOppField(opp, Opportunity.Status__c, createOpp.opportunityData.Status);
        setStringOppField(opp, Opportunity.Sub_Status__c, createOpp.opportunityData.SubStatus);
        setStringOppField(opp, Opportunity.Entry_Web_Property__c, createOpp.opportunityData.EntryWebProperty); 
        setStringOppField(opp, Opportunity.Agent_Property__c, createOpp.opportunityData.AgentProperty); 
        setStringOppField(opp, Opportunity.Referring_Domain__c, createOpp.opportunityData.ReferringDomain); 
        setStringOppField(opp, Opportunity.Campaign_ID__c, createOpp.opportunityData.CampaignID); 
        setStringOppField(opp, Opportunity.Marketing_Channel__c, createOpp.opportunityData.marketingChannel); 
        setStringOppField(opp, Opportunity.Email__c, createOpp.opportunityData.email); 
        setStringOppField(opp, Opportunity.Phone__c, createOpp.opportunityData.phone); 
        setStringOppField(opp, Opportunity.Source_Comments__c, createOpp.opportunityData.SourceComments); 
        setStringOppField(opp, Opportunity.Marketing_Sub_Source__c, createOpp.opportunityData.MarketingSubSource);   
        setStringOppField(opp, Opportunity.Product_system_name__c,createOpp.opportunityData.productSystemName);
        opp.Requested_Effective_Date__c=createOpp.opportunityData.effectiveDate;
        setStringOppField(opp, Opportunity.State_Code__c,createOpp.opportunityData.stateCode);
        opp.AppCode__c=createOpp.opportunityData.appcode;
        opp.AccountId = account.Id;
        opp.Owner = new User(UserExternalID__c = proxyExternalID);
        if(createOpp.opportunityData.appcode == PLMOD_APP_CODE && createOpp.agentOfficeData.sendNotification) { 
            opp.IsOfficeNotified__c = true;
        }
        return opp;
    }
    
    //This method is used to assign record type
    private static id assignRecordTypeIDtoOpportunity(String recordType){
        return Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(recordType).getRecordTypeId();
    }
    
}