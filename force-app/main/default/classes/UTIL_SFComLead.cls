/**
@Author Team Dream Builders/Impact Force
@Name UTIL_Validator
@CreateDate 01/27/2017
@description Common class to validate fields
@Version 1.0
*/
public without sharing class UTIL_SFComLead {
    private static final String NULL_SYMBOL = '';
    private static final Date CLOSED_DATE = Date.today() + 60; 
    private static final String OPPORTUNITY_OPPMGMNT_RECORD_TYPE = 'Opportunity Management';
    public static final String OPPORTYNITY_ORIGINATOR_SFCOM ='Statefarm.com';
    public static final String OPPORTYNITY_STAGE_NEW ='New';
    private static final String OPPORTUNITY_NOTE_CATEGORY = 'System Generated';
     /** 
     * @description This method is used to validate Account oject on ClientIdentifier__c and LastName fields
     * @param acct -Account
     * @return boolean
	*/
    public static boolean isValidAccount(Account acct) {
        if (acct.ClientIdentifier__c == null || acct.ClientIdentifier__c.length() == 0 || acct.ClientIdentifier__c.length() > 11) {
            return false;
        }
        else if (acct.LastName == null || acct.LastName.length() == 0 || acct.LastName.length() > 80) {
            return false;
        }
        else if (String.isBlank(acct.RecordTypeId)) {
            return false;
        }
       
        return true;
    }
    /**
     * @description This method is used to validate Opportunity oject on Name and StageName 
     * @param opp -Opportunity
     * @return boolean
	*/
    public static boolean isValidOpportunity(Opportunity opp) {
        if (opp.CloseDate == null) {
            return false;
        }
        else if (opp.Name == null || opp.Name.length() == 0) {
            return false;
        }
             
        return true;
    }
    /**
     * @description This method is used to validate AgentRole oject on agentAssociateId
     * @param agentAssociateId -String
     * @return boolean
	*/
    public static boolean isValidAgentRole(final String agentAssociateId) {
        
        return String.isNotEmpty(agentAssociateId) ? true : false;
    }
    
    /**
    *  Sets up and Upserts the AgentRole
    *  @description  upsertAgentRole
    *  @param sFComLead - The incoming LeadVendorMessage
    *  @param usr - The Agent User for the Agent Role
    *  @param acc - The upserted Account
    *  @return agentRole - The upserted AgentRole is returned
    */
    
     public static AgentRole__c upsertAgentRole(HLPR_SFComLeadRequest sFComLead, User usr, Account acc) {
         AgentRole__c agentRole = new AgentRole__c();

         agentRole.Agent__c=usr.id;
         agentRole.AgentRoleIdentifier__c= sFComLead.leadagentrole.AgentAssociateID + UTIL_Constants.TILT_SYMBOL + sFComLead.leadaccount.ClientID;
         agentRole.Customer__c=  acc.id;    
         UTIL_AgentRoleDAO.upsertUserAgentRoles(new List<AgentRole__c>{agentRole});         
         return agentRole;
    }
    /**
     * @description This method is used to constructAccount, just creating new Account object and copy the date from HLPR_SFComLeadRequest.leadAccount to Account
     * @param sFCom -HLPR_SFComLeadRequest
     * @return -Account
	*/
    public static Account constructAccount(HLPR_SFComLeadRequest sFCom) {
      
        String accountRecordTypeId = '';
        Map<String, Schema.Recordtypeinfo> accountRecordTypeMap=Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();
        accountRecordTypeId = accountRecordTypeMap.get(sFCom.leadaccount.AccountType).RecordTypeId;
        
        if(String.isBlank(accountRecordTypeId)) {// we shouldn't throw exception. this field should set by prospect management service.
            throw new SFCom_LeadMessageServiceException(System.Label.CL_AccountType_Invalid_Message);  
        }
        
        Account account = new Account();         
        account.RecordTypeId = accountRecordTypeId; 
        account.ClientIdentifier__c  = sFCom.leadaccount.ClientID;
        account.FirstName = sFCom.leadaccount.FirstName;
        account.LastName = sFCom.leadaccount.LastName;
       
        if(String.isNotBlank(sFCom.leadaccount.EmailAddress)) {
            account.PersonEmail=sFCom.leadaccount.EmailAddress;
        }
        
        HLPR_OppSFComLeadValidation.validAllAccountData(sFCom,account);
        return account;
    }
    /**
     * @description This method is used to constructOpportunity, just creating new Opportunity object and copy the date from HLPR_SFComLeadRequest.leadopportunity to Opportunity
     * @param sFCom -HLPR_SFComLeadRequest
     * @param account
     * @param proxy
     * @return Opportunity
	*/
    public static Opportunity constructOpportunity(HLPR_SFComLeadRequest sFCom, Account account, User proxy) {
        Opportunity opp = new Opportunity();
         
        Map<String, String> recordTypeMapById = new Map<String, String>();
        for(Schema.RecordTypeInfo rtInfo : Schema.Opportunity.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getRecordTypeInfos()) {
            recordTypeMapById.put(rtInfo.getName(),String.valueOf(rtInfo.getRecordTypeId()).subString(0, 15));             
        }
        
        opp.RecordTypeId = recordTypeMapById.get(OPPORTUNITY_OPPMGMNT_RECORD_TYPE);
        opp.Name = sFCom.leadopportunity.Name;
        opp.StageName =OPPORTYNITY_STAGE_NEW;
        opp.CloseDate = CLOSED_DATE;
        opp.LOB__c = sFCom.leadopportunity.LOB;
        
        if(String.isNotBlank(sFCom.leadopportunity.Opportunity_Originator)){
            opp.Opportunity_Originator__c = sFCom.leadopportunity.Opportunity_Originator;
        	 if(OPPORTYNITY_ORIGINATOR_SFCOM.equals(opp.Opportunity_Originator__c)){
                opp.Marketing_Source__c = OPPORTYNITY_ORIGINATOR_SFCOM;
            }
        }
        
         if(String.isNotBlank(sFCom.leadopportunity.Temperature)) {
             opp.Temperature__c = sFCom.leadopportunity.Temperature;
         }

        opp.AccountId = account.Id;
        opp.OwnerId = proxy.Id;         
        return opp;
    }
    
    /**
     * @description This method is used to construct an Opportunity Note and populate its contents with the values from the Description and 
     * OpportunityDetail fields from the SFComLeadRequest
     * @param sFComLead -HLPR_SFComLeadRequest
     * @param oppId -oppId
     * @return Opportunity_Note__c
	*/
    public static Opportunity_Note__c constructOpportunityNote(HLPR_SFComLeadRequest sFComLead, Id oppId) {        
        Opportunity_Note__c note = new Opportunity_Note__c(Category__c = OPPORTUNITY_NOTE_CATEGORY, Comments__c=createOpportunityNoteComment(sfComLead), 
                                                           Opportunity__c=oppId);
       if(String.isNotBlank(sFComLead.leadopportunity.Description))
     {
       string description = sFComLead.leadopportunity.Description.trim();
	
		 if(description.length() <=80)
        {
          note.Name = description; 
        
        }
         	else
			{
			 description= description.substring(0,80);
			 note.Name = description; 
           	}
       }
			return note;
    }
    /**
     * @description This method is used to create the contents of an Opportunity Note using the values from the Description and 
     * OpportunityDetail fields from the SFComLeadRequest
     * @param sFComLead -HLPR_SFComLeadRequest
     * @return String
	*/
    
    public static String createOpportunityNoteComment(HLPR_SFComLeadRequest sFComLead) {
        String commentText = '';
        
        if(String.isNotBlank(sFComLead.leadopportunity.Description)) {
            commentText += sFComLead.leadopportunity.Description;
        }        
        if(String.isNotBlank(sFComLead.leadopportunity.OpportunityDetail)) {
            commentText += '\n' + sFComLead.leadopportunity.OpportunityDetail;
        }
      	
        return commentText;
    }
     /**
     * @description This method is used to set the error message corresponding missing field
     * @param sFComLead -HLPR_SFComLeadRequest
     * @param proxy -User
	*/
    public static void errorMessageSetting(HLPR_SFComLeadRequest sFComLead, User proxy) {
        if (sFComLead == null) {
            throw new SFCom_LeadMessageServiceException(System.Label.CL_AgentAssociateID_Invalid_Message);
        } else if (String.isBlank(sFComLead.leadagentrole.AgentAssociateID)) {
            throw new SFCom_LeadMessageServiceException(System.Label.CL_AgentAssociateID_Invalid_Message);
        } else if (proxy == null){
            throw new SFCom_LeadMessageServiceException(System.Label.CL_PROXY_NOT_FOUND_ERROR);
        } 
        HLPR_OppSFComLeadValidation.nameErrorMessageSetting(sFComLead, proxy);
    }
    
}