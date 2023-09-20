/****************************************************************************************
Name: SFComLeadVendorMessageService
Copyright © State Farm
=========================================================================================
Purpose:
-------
Decription: This class is responsible for taking SFCOMleads. It is part of a SOAP call from the TP (Techinal Platform)
Team: Dream Builders
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Kavitha Boppudi (F1A1)    01/21/2017            Initial Development

******************************************************************************************/
/**
 * @description WS_SFComLeadMessageService
 */
global with sharing class WS_SFComLeadMessageService {   
   
    private static final String CLASS_NAME = 'WS_SFComLeadMessageService';
    private static final String CREATE_LEAD_MESSAGE_METHOD_NAME = 'createSFCOMLeadMessage';
    private static final String OPPORTYNITY_CLOSED_WON_STAGE ='Closed Won';
    private static List<Opportunity> opportunityList;
    private static final String SPI_ERROR ='Found SPI data in OpportunityDetail filed';
    private static List<User> usr;
    private static User proxy;
    private static WS_SFComLeadMessageServiceWrapper wsSFCom = new WS_SFComLeadMessageServiceWrapper();
    
    /**
     * @description upsertSFComLead
     * @param sFComLead 
     */
	webservice static void upsertSFComLead(HLPR_SFComLeadRequest sFComLead) {
        ifUsrIsNotEmpty(sFComLead);
    
        // Below is decison point to update or insert the opprtunity
        if(opportunityList!=null && !opportunityList.isEmpty()) {
            try {
                //update the temprature field
                if(String.isNotBlank(sFComLead.leadopportunity.Temperature)) {
                    updateOpportunityWithTemprature(sFComLead, opportunityList[0], sFComLead.leadopportunity.Temperature);
                }
            } catch(Exception ex) {
               LoggingService.logHandledException(ex, CLASS_NAME , CREATE_LEAD_MESSAGE_METHOD_NAME, System.LoggingLevel.ERROR);
            }
            //Trigger Notification
            if(opportunityList!=null && !opportunityList.isEmpty()) {
                postMessages(opportunityList[0].ID);
            }                 
        } else {
            postMessagesNotification(sFComLead);
        }              
    }	
	  
    /**
     * @description ifUsrIsNotEmpty
     * @param sFComLead  
     */
    private static void ifUsrIsNotEmpty(HLPR_SFComLeadRequest sFComLead){
        try {
            String agtExternalId= sFComLead.leadagentrole.AgentAssociateID+'_'+sFComLead.leadagentrole.AgentAssociateID;                
        	if (sFComLead != null && String.isNotBlank(sFComLead.leadagentrole.AgentAssociateID)) {         
                usr = [SELECT id, Name, Alias FROM user WHERE UserExternalID__c =:agtExternalId and IsActive = true limit 1];
              
                if(usr != null && !usr.isEmpty()) {
                    proxy = UTIL_AgentProxySelection.retrieveProxyForLoggedInAgentOrATM(usr[0].Id);
                   
                    opportunityList=retrieveOpportunity(sFComLead,proxy);
                }else {
                   throw new SFCom_LeadMessageServiceException(System.Label.CL_AgentAssociateID_Invalid_Message);

                }
            }
        } catch (Exception ex) {
            //log exception
            throw new SFCom_LeadMessageServiceException(ex.getMessage(), ex);
             
        }
    }

    private static void postMessagesNotification(HLPR_SFComLeadRequest sFComLead){
        Savepoint sp1 = Database.setSavepoint();
        Opportunity opportunity;
        try {            
            if(usr != null && !usr.isEmpty() && proxy != null){
                 opportunity = doAllUpsertOpertation(sFcomLead, usr[0],proxy);
            } else {
                UTIL_SFComLead.errorMessageSetting(sFcomLead,proxy);              	
            }              
        } catch (Exception ex) {
            Database.rollback(sp1);
            LoggingService.logHandledException(ex, CLASS_NAME , CREATE_LEAD_MESSAGE_METHOD_NAME, System.LoggingLevel.ERROR);
            throw new SFCom_LeadMessageServiceException(ex.getMessage(), ex);
        }              
        //send the Notification 
        if(Opportunity!=null) {
            postMessages(opportunity.ID);
        }
    }

    /**
    *  Asynchronous post messages
    *  @description  postMessages
    *  @param opportunityId - The opportunity to Post
    */
    private static void postMessages(String opportunityId) {       
        try {
            UTIL_OpportunityNotificationManager.postOppNotifications(new List<String>{opportunityId}); 
            } catch(Exception ex) { 
                LoggingService.logHandledException(ex, CLASS_NAME , CREATE_LEAD_MESSAGE_METHOD_NAME, System.LoggingLevel.ERROR);
        }
    }
	    
    /*
     * This method is used to upsert Accout,AgentRole, and opportunity
     * @parm-sFComLead-HLPR_SFComLeadRequest
     * @parm-user-User
     * @parm-proxy-User
     * @retrun -Opportunity
	*/
    
	private static Opportunity doAllUpsertOpertation(HLPR_SFComLeadRequest sFcomLead, final User user, final User prxy) {
        Account account = upsertAccount(sFComLead);
        UTIL_SFComLead.upsertAgentRole(sFComLead, user, account);
        Opportunity opportunity = insertOpportunity(sFComLead, account, prxy);
        createAndInsertOpportunityNote(sFComLead, opportunity.ID);   
        return opportunity;
    }
     /*
     * This method is used to find the opportunity exist in SFDC or not with help of LOB and OwnerID,Opportunity orginator and clintID.
     * @parm-sFComLead-HLPR_SFComLeadRequest
     * @parm-proxy-User
     * @retrun -List<Opportunity>
	*/
    
    private static List<Opportunity> isLeadDuplicate(HLPR_SFComLeadRequest sFComLead, User prxy) {       
        opportunityList = [SELECT Id,StageName,OppNotNowFollowUpDateTime__c,OppClosedDateTime__c FROM Opportunity WHERE AccountID in (SELECT Id FROM Account 
        WHERE ClientIdentifier__c =:sFComLead.leadaccount.ClientID) 
        AND Opportunity_Originator__c =: UTIL_SFComLead.OPPORTYNITY_ORIGINATOR_SFCOM 
        AND LOB__c =:sFComLead.leadopportunity.LOB AND OwnerId=:prxy.Id 
        AND StageName NOT IN (:OPPORTYNITY_CLOSED_WON_STAGE) ORDER BY Id DESC LIMIT 1 ];
        
        return opportunityList;     
    }
    /*
     * This method is used to update the opportunity with temprature if the lead is duplicate.
     * @parm-opportunity-Opportunity
     * @parm-temprature-String
     * @retrun -void
	*/
      private static void  updateOpportunityWithTemprature(HLPR_SFComLeadRequest sFComLead, Opportunity opportunity, String temperature){
        Opportunity opp = new Opportunity();
        opp = opportunity;
        opp.Temperature__c = temperature;
        opp = UTIL_OpportunityUtil.updateStageIfReOpen(opp, sFComLead.leadopportunity.StageName);
        UTIL_OpportunityDAO.updateOpportunityForAccount(new List<Opportunity>{opp});   
        createAndInsertOpportunityNote(sFComLead, opp.ID);
    }
     /*
     * This method is used to upsert the Account
     * @parm-sFcomLead-HLPR_SFComLeadRequest
     * @retrun -Account
	*/
    private static Account upsertAccount(HLPR_SFComLeadRequest sFcomLead) {
        Account account;
        account = UTIL_SFComLead.constructAccount(sFcomLead);
        if(UTIL_SFComLead.isValidAccount(account)) {
            UTIL_AccountDAO.upsertAccountsByClientIdentifier(new List<Account>{account}); 
        } else {
            UTIL_SFComLead.errorMessageSetting(sFcomLead, proxy);           
        }
       
        return account;
    }
    /*
     * This method is used to upsert the opportunity
     * @parm-sFcomLead-HLPR_SFComLeadRequest
     * @parm-account-Account
     * @parm-proxy-User
     * @retrun -Opportunity
	*/
    private static Opportunity insertOpportunity(HLPR_SFComLeadRequest sFcomLead,Account account, User prxy) {
         Opportunity opportunity;
         opportunity = UTIL_SFComLead.constructOpportunity(sFComLead, account, prxy);
         if(UTIL_SFComLead.isValidOpportunity(opportunity)) {
                  checkSPIDataOnOpportunity(opportunity);
             UTIL_OpportunityDAO.insertOpportunityForAccount((new List<Opportunity>{opportunity}));
         } else {
             UTIL_SFComLead.errorMessageSetting(sFcomLead,proxy);
        }
        return opportunity;
    }
    /*
     * This method is used to create the opportunity note
     * @param-sFcomLead-HLPR_SFComLeadRequest
     * @param-opp-Opportunity
     * @return-OpportunityNote
	*/
    private static Opportunity_Note__c createAndInsertOpportunityNote(HLPR_SFComLeadRequest sFcomLead, Id oppId) {
         Opportunity_Note__c note;
         note = UTIL_SFComLead.constructOpportunityNote(sFComLead, oppId);
         if(String.isNotBlank(note.Comments__c)){
         	checkSPIDataonOpportunityNote(note);
         }
         UTIL_OpportunityDAO.insertOpportunityNote((new List<Opportunity_Note__c>{note}));

        return note;
    }
    
    /*
     * This method is used to retrieve the opportunity
     * @parm-sFcomLead-HLPR_SFComLeadRequest
     * @parm-proxy-User
     * @retrun -List-Opportunity
	*/
    private static List<Opportunity> retrieveOpportunity(HLPR_SFComLeadRequest sFcomLead, User prxy) {
       if(proxy != null && String.isNotBlank(sFComLead.leadaccount.ClientID) && String.isNotBlank(sFComLead.leadopportunity.LOB)) {
       	opportunityList = isLeadDuplicate(sFComLead, proxy);
       } else {
       	UTIL_SFComLead.errorMessageSetting(sFcomLead,prxy);
       }
       return opportunityList;
    }  
     /*
     * This method is used to check the SPI data
     * @parm-opportunity-Opportunity
     * @retrun -void
	*/
    private static void checkSPIDataOnOpportunityNote(Opportunity_Note__c note){
       
        SFDOTCOM_SPISecurityManager spiSecurityManager = new SFDOTCOM_SPISecurityManager();
        wsSFCom.checkSPIDataOnOpportunityNote(spiSecurityManager, note);
    }
    
     /*
     * This method is used to check the SPI data
     * @parm-opportunity-Opportunity
     * @retrun -void
	*/
    private static void checkSPIDataOnOpportunity(Opportunity opp){
       
        SFDOTCOM_SPISecurityManager spiSecurityManager = new SFDOTCOM_SPISecurityManager();
        wsSFCom.checkSPIDataOnOpportunity(spiSecurityManager, opp);
    }

    /**
     * @description WS_SFComLeadMessageServiceWrapper
     */
    private class WS_SFComLeadMessageServiceWrapper{

        private void checkSPIDataOnOpportunity(SFDOTCOM_SPISecurityManager spiSecurityManager, Opportunity opp){
            String spiErrorMessage=spiSecurityManager.handle(new List<Opportunity>{opp});        
            if(spiErrorMessage!=null && String.isNotBlank(spiErrorMessage)){
              throw new SFCom_LeadMessageServiceException(SPI_ERROR +':' +spiErrorMessage);
             }
        }

        private void checkSPIDataOnOpportunityNote(SFDOTCOM_SPISecurityManager spiSecurityManager, Opportunity_Note__c note){
            String spiErrorMessage=spiSecurityManager.handle(new List<Opportunity_Note__c>{note});        
            if(spiErrorMessage!=null && String.isNotBlank(spiErrorMessage)){
              throw new SFCom_LeadMessageServiceException(SPI_ERROR +':' +spiErrorMessage);
             }
        }
    }
}