/**
 * Author : Golden Spikes Team
 * Date Created : 04/09/2019
 * @description : This Apex Class is responsible for taking event leads(opportunities) and partial leads(leads). It is part of a SOAP call from the TP (Techinal Platform)
 */
global with sharing class WS_CreateLeadService {
    private static final String CLASS_NAME = 'WS_CreateLeadService';
    private static final String HANDLE_POST_NOTIFICATIONS_METHOD_NAME = 'postNotifications';

    //Account Constants
    private static final String INVALID_CLIENT_ID_ERROR = '11 character Client ID is expected';

    //Opportunity Constants
    private static final String OPPORTUNIY_MGMT_RECORD_TYPE_NAME = 'Opportunity_Management';

    //Opportunity Note Constants
    private static final String OPPORTUNITY_NOTE_COMMENTS_TARGET_LOB_STRING = '{LOB}';

    private static Savepoint sp;
    private static Map<String, Boolean> notificationMap;
    private static Map<Integer, String> opportunityNoteCommentsMap;
/**
 * @description handleOpportunityRequest
 * @param leadAct 
 * @param leadAgtRole 
 * @param leadOpportunities 
 */
    webservice static void handleOpportunityRequest(HLPR_CreateLeadRequest.LeadAccount leadAct, HLPR_CreateLeadRequest.LeadAgentRole leadAgtRole, List<HLPR_CreateLeadRequest.LeadOpportunity> leadOpportunities) {
        sp = Database.setSavepoint();
        Account customer = handleAccount(leadAct);
        handleAgentRole(leadAgtRole, customer);
        handleOpportunities(leadOpportunities, customer, leadAgtRole.agentAssociateID);
    }
/**
 * @description handleLeadRequest
 * @param leadInfo 
 * @return  `String`
 */
    webservice static String handleLeadRequest(HLPR_CreateLeadRequest.LeadInformation leadInfo) {
        sp = Database.setSavepoint();
        return handleLead(leadInfo);
    }
/**
 * @description isCCCEligible
 * @param externalLeadSource 
 * @return  `Boolean`
 */
    webservice static Boolean isCCCEligible(String externalLeadSource) {
        return LeadCCCHandler.isCCCEligible(externalLeadSource);
    }

    private static Account handleAccount(HLPR_CreateLeadRequest.leadAccount leadAct) {
        if (String.isBlank(leadAct.ClientID) || leadAct.ClientID.length() != 11) {
            throw new HLPR_CreateLeadRequest.LeadServiceException(INVALID_CLIENT_ID_ERROR);
        }
        List<Account> accounts = [SELECT Id, ClientIdentifier__c FROM Account WHERE ClientIdentifier__c = :leadAct.ClientID WITH SECURITY_ENFORCED LIMIT 1];
        if (accounts.isEmpty()) {
            accounts.add(createAccount(leadAct));
        }
        return accounts[0];
    }

    private static Account createAccount(HLPR_CreateLeadRequest.leadAccount leadAct) {
        Account newAccount = new Account();
        try {
            newAccount = HLPR_CreateLeadService.buildAccount(leadAct);
            UTIL_AccountDAO.insertAccount(newAccount);
        } catch (Exception ex) {
            Database.rollback(sp);
            throw new HLPR_CreateLeadRequest.LeadServiceException(ex.getMessage(), ex);
        }
        return newAccount;
    }

    private static void handleAgentRole(HLPR_CreateLeadRequest.leadAgentRole leadAgentRole, Account customer) {
        AgentRole__c newAgentRole = new AgentRole__c();
        try {
            newAgentRole = HLPR_CreateLeadService.buildAgentRole(leadAgentRole, customer);
            UTIL_AgentRoleDAO.upsertUserAgentRoles(new List<AgentRole__c>{ newAgentRole });
        } catch (Exception ex) {
            Database.rollback(sp);
            throw new HLPR_CreateLeadRequest.LeadServiceException(ex.getMessage(), ex);
        }
    }

    private static void handleOpportunities(
        List<HLPR_CreateLeadRequest.LeadOpportunity> leadOpportunities, Account customer, String agentAssociateId) {
        try {
            if (leadOpportunities != null && !leadOpportunities.isEmpty()) {
                List<Opportunity> newOpportunities = new List<Opportunity>();
                notificationMap = new Map<String, Boolean>();
                opportunityNoteCommentsMap = new Map<Integer, String>();
                Id opportunityRecordTypeId = HLPR_CreateLeadService.getRecordTypeId(Schema.SObjectType.Opportunity, OPPORTUNIY_MGMT_RECORD_TYPE_NAME);
                Integer i = 0;
                CMOpportunityMapping__mdt leadSourceMapping = HLPR_CreateLeadService.getLeadSourceMapping(leadOpportunities[0].externalLeadSource);
                for (HLPR_CreateLeadRequest.LeadOpportunity eachOpportunity : leadOpportunities) {
                    HLPR_CreateLeadService.OpportunityRequest optyReq = new HLPR_CreateLeadService.OpportunityRequest();
                    optyReq.ldOpportunity = eachOpportunity;
                    optyReq.accountId = customer.Id;
                    optyReq.agentAssoicateId = agentAssociateId;
                    optyReq.ldSourceMapping = leadSourceMapping;
                    Opportunity newOpportunity = HLPR_CreateLeadService.buildOpportunity(optyReq);
                    newOpportunity.RecordTypeId = opportunityrecordTypeId;
                    newOpportunities.add(newOpportunity);
                    if (leadSourceMapping != null) {
                        populateOpportunityNoteComments(eachOpportunity, leadSourceMapping, i);
                    }
                    i++;
                }
                UTIL_OpportunityDAO.insertOpportunityForAccount(newOpportunities);
                handleOpportunityNote(newOpportunities, opportunityNoteCommentsMap);
                postNotifications(newOpportunities);
            }
        } catch (Exception ex) {
            Database.rollback(sp);
            throw new HLPR_CreateLeadRequest.LeadServiceException(ex.getMessage(), ex);
        }
    }

    private static void populateOpportunityNoteComments(HLPR_CreateLeadRequest.LeadOpportunity eachOpportunity, CMOpportunityMapping__mdt leadSourceMapping, Integer i) {
        if (String.isNotBlank(eachOpportunity.lob) && String.isNotBlank(leadSourceMapping.OpportunityNoteComments__c)) {
            opportunityNoteCommentsMap.put(i, (leadSourceMapping.OpportunityNoteComments__c).replace(OPPORTUNITY_NOTE_COMMENTS_TARGET_LOB_STRING, eachOpportunity.lob));
        }
        notificationMap.put(leadSourceMapping.LeadSource__c, leadSourceMapping.Notification__c);
    }

    private static void handleOpportunityNote(List<Opportunity> newOpportunities, Map<Integer, String> opportunityNoteCommentsMap) {
        if (!opportunityNoteCommentsMap.isEmpty()) {
            List<Opportunity_Note__c> newOpportunityNotes = HLPR_CreateLeadService.buildOpportunityNotes(newOpportunities, opportunityNoteCommentsMap);
            UTIL_OpportunityDAO.insertOpportunityNote(newOpportunityNotes);
        }
    }

    private static void postNotifications(List<Opportunity> newOpportunities) {
        try {
            for (Opportunity opp : newOpportunities) {
                if (notificationMap.get(opp.LeadSource) != null & notificationMap.get(opp.LeadSource)) {
                    UTIL_OpportunityNotificationManager.postOppNotifications(new List<Id>{ opp.Id });
                }
            }
        } catch (Exception ex) {
            LoggingService.logHandledException(ex, CLASS_NAME, HANDLE_POST_NOTIFICATIONS_METHOD_NAME, System.LoggingLevel.ERROR);
        }
    }

    private static String handleLead(HLPR_CreateLeadRequest.LeadInformation leadInfo) {
        CMOpportunityMapping__mdt leadSourceMapping;
        Lead newLd;
        Boolean isCCCEligible = false;
        try {
            isCCCEligible = LeadCCCHandler.preCCCEligibleCheck(leadInfo) ? LeadCCCHandler.isCCCEligible(leadInfo.externalLeadSource) : false;
            leadSourceMapping = HLPR_CreateLeadService.getLeadSourceMapping(leadInfo.externalLeadSource);
            newLd = handleLeadCreation(leadInfo, isCCCEligible, leadSourceMapping);
            handleLeadNotification(newLd, isCCCEligible);
            handleLeadMetrics(newLd);
        } catch (Exception ex) {
            Database.rollback(sp);
            throw new HLPR_CreateLeadRequest.LeadServiceException(ex.getMessage(), ex);
        }
        return newLd.Id;
    }

    private static Lead handleLeadCreation(HLPR_CreateLeadRequest.LeadInformation leadInfo, Boolean isCCCEligible, CMOpportunityMapping__mdt leadSourceMapping) {
        String leadOwnerId;
        if (isCCCEligible) {
            leadOwnerId = (AccountOwnerSystemUserCustomSetting__c.getInstance()).SFDC_User_ID__c;
        } else {
            leadOwnerId = HLPR_CreateLeadService.getAgentProxyId(leadInfo.agentAssociateID);
        }
        PartialLeadBuilder.LeadRequest leadReq = new PartialLeadBuilder.LeadRequest();
        leadReq.ldInfo = leadInfo;
        leadReq.agentProxySFDCID = leadOwnerId;
        leadReq.ldSourceMapping = leadSourceMapping;
        leadReq.isCCCEligible = isCCCEligible;
        Lead newld = PartialLeadBuilder.buildLead(leadReq);
        UTIL_LeadDAO.insertLead(new List<Lead>{ newLd });
        return newLd;
    }

    private static void handleLeadNotification(Lead newLd, Boolean isCCCEligible) {
        if (isCCCEligible) {
            LeadCCCHandler.sendEmail(newLd);
        } else {
            Task newtsk = HLPR_CreateLeadService.buildTask(newLd);
            UTIL_TaskDAO.insertTasks(new List<Task>{ newtsk });
        }
    }

    private static void handleLeadMetrics(Lead newLd) {
        Lead ldRecord = [SELECT Id, External_Lead_ID__c, createdById, createdDate, Name, OriginalLeadSource__c, OwnerId, 
            SCode__c, MultiLOB__c, SourcedFromCCC__c, LeadScore__c, LeadTemperature__c, State FROM Lead WHERE Id = :newLd.Id WITH SECURITY_ENFORCED LIMIT 1];
        LeadMetrics__c newLeadMetrics = HLPR_CreateLeadService.buildCreateLeadMetrics(ldRecord);
        insert Security.stripInaccessible(AccessType.CREATABLE, new List<LeadMetrics__c>{ newLeadMetrics }).getRecords();
    }
}