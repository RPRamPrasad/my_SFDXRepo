/**
 * Author : Golden Spikes Team
 * Date Created : 11/14/2019
 * @description : This is a helper class for WS_CreateLeadService.
 */
public with sharing class HLPR_CreateLeadService {
    private static final String USER_EXTERNAL_ID_CONCATENATION_SYMBOL = '_';    
    private static final String SPACE_SYMBOL = ' ';
    private static final String PROXY_CONCAT = 'P';
    private static final String INVALID_PROXY_ERROR = 'Proxy User not found with given Associate Id: ';

    //Account Constants
    private static final String ACCOUNT_INDIVIDUAL_RECORD_TYPE_DEV_NAME = 'Individual';

    //Agent Role Constants
    private static final String TILT_SYMBOL = '~';

    //Opportunity Constants
    private static final String OPPORTUNITY_STAGE_NAME = 'New';

    //Opportunity Note Constants
    private static final String OPPORTUNITY_NOTE_CATEGORY = 'System Generated';

    //Task Constants
    private static final String SUBJECT_PREFIX = 'New';
    private static final String TASK_RECORD_TYPE_DEV_NAME = 'Task';
    private static final String TASK_APP_CODE = 'Lead Management';
    private static final String TASK_PRIORITY = 'None';
    private static final String TASK_STATUS = 'Not Started';
    private static final String TASK_MARKETING = 'Marketing';
    private static final String TASK_TYPE = 'Sales';

    private static final String PARTIAL_LEAD_RECORD_TYPE_LABEL = 'Partial Lead';
    private static final String LEAD_SOURCE_MAPPING_TYPE = 'External Lead Service';
/**
 * @description getRecordTypeId
 * @param objType 
 * @param recordTypeDeveloperName 
 * @return  `Id`
 */
    public static Id getRecordTypeId(Schema.DescribeSObjectResult objType, String recordTypeDeveloperName) {
        return objType.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
    }
/**
 * @description buildAccount
 * @param leadAct 
 * @return  `Account`
 */
    public static Account buildAccount(HLPR_CreateLeadRequest.leadAccount leadAct) {
        Account newAccount = new Account();
        newAccount.FirstName = leadAct.firstName;
        newAccount.LastName = leadAct.lastName;
        newAccount.ClientIdentifier__c = leadAct.clientID;
        newAccount.RecordTypeId = getRecordTypeId(Schema.SObjectType.Account, ACCOUNT_INDIVIDUAL_RECORD_TYPE_DEV_NAME);
        return newAccount;
    }
/**
 * @description buildAgentRole
 * @param leadAgentRole 
 * @param customer 
 * @return  `AgentRole__c`
 */
    public static AgentRole__c buildAgentRole(HLPR_CreateLeadRequest.leadAgentRole leadAgentRole, Account customer) {
        AgentRole__c newAgentRole = new AgentRole__c();
        newAgentRole.Agent__r = new User(UserExternalID__c = leadAgentRole.agentAssociateID + USER_EXTERNAL_ID_CONCATENATION_SYMBOL + leadAgentRole.agentAssociateID);
        newAgentRole.AgentRoleIdentifier__c = leadAgentRole.AgentAssociateID + TILT_SYMBOL + customer.ClientIdentifier__c;
        newAgentRole.Customer__c = customer.Id;
        return newAgentRole;
    }
/**
 * @description OpportunityRequest
 */
    public with sharing class OpportunityRequest {
        public HLPR_CreateLeadRequest.LeadOpportunity ldOpportunity;
        public Id accountId;
        public String agentAssoicateId;
        public CMOpportunityMapping__mdt ldSourceMapping;
    }
/**
 * @description buildOpportunity 
 * @param opportunityRequest 
 * @return  `Opportunity`
 */
    public static Opportunity buildOpportunity(HLPR_CreateLeadService.OpportunityRequest opportunityRequest) {
        Opportunity newOpportunity = new Opportunity();
        newOpportunity.Owner = new User(UserExternalID__c = opportunityRequest.agentAssoicateId + PROXY_CONCAT);
        newOpportunity.AccountId = opportunityRequest.accountId;
        if (opportunityRequest.ldSourceMapping != null) {
            newOpportunity.LeadSource = opportunityRequest.ldSourceMapping.LeadSource__c;
            newOpportunity.Opportunity_Originator__c = opportunityRequest.ldSourceMapping.OpportunityOriginator__c;
            newOpportunity.Marketing_Source__c = opportunityRequest.ldSourceMapping.MarketingSource__c;
            newOpportunity.Marketing_Sub_Source__c = opportunityRequest.ldSourceMapping.MarketingSubSource__c;
        }
        newOpportunity.StageName = OPPORTUNITY_STAGE_NAME;
        newOpportunity.CloseDate = Date.today() + 60;
        if (String.isNotBlank(opportunityRequest.ldOpportunity.name)) {
            newOpportunity.Name = (opportunityRequest.ldOpportunity.name).left(120);
        }
        newOpportunity.LOB__c = opportunityRequest.ldOpportunity.lob;
        newOpportunity.Product__c = opportunityRequest.ldOpportunity.product;
        newOpportunity.EventCode__c = opportunityRequest.ldOpportunity.eventCode;
        newOpportunity.EventName__c = opportunityRequest.ldOpportunity.eventName;
        newOpportunity.Source_Comments__c = opportunityRequest.ldOpportunity.sourceComments;
        newOpportunity.Phone__c = opportunityRequest.ldOpportunity.submittedPhone;
        newOpportunity.Email__c = opportunityRequest.ldOpportunity.submittedEmail;
        return newOpportunity;
    }
/**
 * @description buildOpportunityNotes
 * @param newOpportunities 
 * @param opportunityNoteCommentsMap 
 * @return  `List<Opportunity_Note__c>`
 */
    public static List<Opportunity_Note__c> buildOpportunityNotes(List<Opportunity> newOpportunities, Map<Integer, String> opportunityNoteCommentsMap) {
        List<Opportunity_Note__c> newOpportunityNotes = new List<Opportunity_Note__c>();
        Integer i = 0;
        for (Opportunity opty : newOpportunities) {
            if (opportunityNoteCommentsMap.get(i) != null) {
                Opportunity_Note__c optyNote = new Opportunity_Note__c(
                    Category__c = OPPORTUNITY_NOTE_CATEGORY, Comments__c = (opportunityNoteCommentsMap.get(i)).left(10000),
                    Opportunity__c = opty.Id, Name = (SUBJECT_PREFIX + SPACE_SYMBOL + opty.LeadSource).left(80)
                );
                newOpportunityNotes.add(optyNote);
            }
            i++;
        }
        return newOpportunityNotes;
    }
/**
 * @description buildTask
 * @param newLd 
 * @return  `Task`
 */
    public static Task buildTask(Lead newLd) {
        Task newTask = new Task();
        newTask.AppCode__c = TASK_APP_CODE;
        newTask.Subject = SUBJECT_PREFIX + SPACE_SYMBOL + (String.isNotBlank(newLd.leadSource) ? newLd.leadSource : '');
        newTask.Priority = TASK_PRIORITY;
        newTask.Status = TASK_STATUS;
        newTask.Task_Type__c = TASK_TYPE;
        newTask.TaskCategory__c = TASK_MARKETING;
        newTask.Source__c = TASK_MARKETING;
        newTask.WhoId = newLd.Id;
        newTask.OwnerId = newLd.ownerId;
        newTask.RecordTypeId = getRecordTypeId(Schema.SObjectType.Task, TASK_RECORD_TYPE_DEV_NAME);
        newTask.AgentAssociateId__c = newLd.AgentAssociateId__c;
        newTask.ActivityDate = Date.Today();
        if (String.isNotBlank(newLd.description)) {
            newTask.Description = (newLd.description).left(32000);
        }
        return newTask;
    }
/**
 * @description buildCreateLeadMetrics
 * @param newLd 
 * @return  `LeadMetrics__c`
 */
    public static LeadMetrics__c buildCreateLeadMetrics(Lead newLd) {
        LeadMetrics__c newLeadMetrics = new LeadMetrics__c();
        newLeadMetrics.ExternalLeadId__c = newLd.External_Lead_ID__c;
        newLeadMetrics.LeadCreatedBy__c = newLd.createdById;
        newLeadMetrics.LeadCreatedDate__c = newLd.createdDate;
        newLeadMetrics.LeadName__c = newLd.Name;
        newLeadMetrics.LeadRecordType__c = PARTIAL_LEAD_RECORD_TYPE_LABEL;
        newLeadMetrics.LeadSfdcId__c = newLd.Id;
        newLeadMetrics.OriginalLeadSource__c = newLd.OriginalLeadSource__c;
        newLeadMetrics.OwnerId = newLd.OwnerId;
        newLeadMetrics.SCode__c = newLd.SCode__c;
        newLeadMetrics.MultiLOB__c = newLd.MultiLOB__c;
        newLeadMetrics.SourcedFromCCC__c = newLd.SourcedFromCCC__c;
        newLeadMetrics.LeadScore__c = newLd.LeadScore__c;
        newLeadMetrics.LeadTemperature__c = newLd.LeadTemperature__c;
        newLeadMetrics.State__c = newLd.State;
        return newLeadMetrics;
    }
/**
 * @description getLeadSourceMapping
 * @param externalLeadSource 
 * @return  `CMOpportunityMapping__mdt`
 */
    public static CMOpportunityMapping__mdt getLeadSourceMapping(String externalLeadSource) {
        CMOpportunityMapping__mdt leadSourceRecord = new CMOpportunityMapping__mdt();
        for (CMOpportunityMapping__mdt ldSource : [SELECT Notification__c, OpportunityNoteComments__c, Description__c, ExternalLeadSource__c, LeadSource__c, MappingType__c, MarketingSource__c, MarketingSubSource__c, OpportunityOriginator__c
            FROM CMOpportunityMapping__mdt WHERE MappingType__c = :LEAD_SOURCE_MAPPING_TYPE AND ExternalLeadSource__c = :externalLeadSource WITH SECURITY_ENFORCED LIMIT 1]) {
                leadSourceRecord = ldSource;
        }
        return leadSourceRecord;
    }
/**
 * @description getAgentProxyId
 * @param agentAssociateId 
 * @return  `Id`
 */
    public static Id getAgentProxyId(String agentAssociateId) {
        List<User> users = [SELECT Id FROM User WHERE UserExternalID__c = :agentAssociateID + PROXY_CONCAT WITH SECURITY_ENFORCED LIMIT 1];
        if (users.isEmpty()) {
            throw new HLPR_CreateLeadRequest.LeadServiceException(INVALID_PROXY_ERROR + agentAssociateID);
        }
        return users[0].Id;
    }
}