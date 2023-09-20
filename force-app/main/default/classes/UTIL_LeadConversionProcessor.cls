/**  
@Author Loco Motivated  
@Name UTIL_LeadConversionProcessor
@CreateDate 20/09/2016 
@Description This is a utility class that implements Mapping for Leadconversion Details and  LeadMessage operations
@Version 1.0
*/ 

/**  
@Author Loco Motivated  
@CreateDate 06/29/2017 
@Description Enhancing to handle LeadMessage from Axioum to Account Message
@Version 2.0
*/

/**
@Author Golden Spikes
@Updated 04/15/2019
@Description Updated to bypass the Acxiom Lead Message callout only for Partial Lead Record type.
*/

/**
@Author Golden Spikes
@Updated 08/07/2019
@description UTIL_LeadConversionProcessor : Updated to bypass the Acxiom Lead Message callout for Referral Lead Record type.
*/

public with sharing class UTIL_LeadConversionProcessor extends UTIL_StageOrchestrationProcessor{
    
    private List<CM_StageOrchestration_Mapping__mdt> mappingForLeadtoLeadConversionDetails;
    private string querystringForLead = '';
    private string leadId='';
    private string accId='';
    private static final string AGENT_ID = 'Agent__c';
    private static final String SUB_USER_TYPE_CCC = 'CCC Sales';
    private static final String SMALL_BUSINESS_CORPORATE_CAMPAIGN = 'Small Business Corporate Campaign';
    private static final String SMALL_BUSINESS_OUT_OF_BOOK_CAMPAIGN = 'Small Business Out of Book Campaign';

    //Constructor
    /**
     * @description UTIL_LeadConversionProcessor
     */
    public UTIL_LeadConversionProcessor(){
        this.mappingForLeadtoLeadConversionDetails = [SELECT Mapping_Type__c,Source_Field__c,Target_Field__c 
                                                      FROM CM_StageOrchestration_Mapping__mdt
                                                      WHERE Mapping_Type__c=:UTIL_StageOrchestrationConstants.LEAD_TO_LEADCONVERSIONDETAILS WITH SECURITY_ENFORCED];
    }
    
    /**
    * @description execute: Execute method for Mapping for Leadconversion Details and  LeadMessage operations
    * @param stageOrchestrationList String : stage orchestration
    * @throws StageProcessor Exception 
    */       
    public override void execute(List<StageOrchestration__c> stageOrchestrationList){
        StageOrchestration__c stageOrchestration = stageOrchestrationList.get(0);    
       Savepoint sp = Database.setSavepoint();
       Lead objLead;
        try{
             
            AP_StageOrchestrationJSONParser jsonParsing = parseJSON(stageOrchestration.Value__c);         
            leadId = jsonParsing.OrchestrationInfo.OrchestrationEventName.OrchestrationEventDetail.OrchestrationEventValues.leadId;
            accId = jsonParsing.OrchestrationInfo.OrchestrationEventName.OrchestrationEventDetail.OrchestrationEventValues.accountId;
            if(String.isBlank(leadId) || String.isBlank(accId) ){
                throw new StageProcessorException(UTIL_StageOrchestrationConstants.EXCP_STR_FOR_EMPTY_ACCOUNTID_LEADID);
            }
            for (CM_StageOrchestration_Mapping__mdt mappingLoopForListofLead : mappingForLeadtoLeadConversionDetails){   
                querystringForLead = querystringForLead + UTIL_StageOrchestrationConstants.COMMA + mappingLoopForListofLead.Source_Field__c;                                     
            }  
            string dynamicQuery = UTIL_StageOrchestrationConstants.SELECT_ID+ UTIL_StageOrchestrationConstants.COMMA +
            UTIL_StageOrchestrationConstants.OWNER_ID + UTIL_StageOrchestrationConstants.COMMA + AGENT_ID + UTIL_StageOrchestrationConstants.COMMA + 
            UTIL_StageOrchestrationConstants.RECORD_TYPE_DEV_NAME + querystringForLead + UTIL_StageOrchestrationConstants.FROM_LEAD_WHERE_ID; 
            objLead= Database.query(String.escapeSingleQuotes(dynamicQuery));
            leadToleadConversionDetailsMapping(objLead, accId);
        }
        catch(Exception ex){
            Database.rollback(sp); 
            throw new StageProcessorException(ex.getmessage(),ex);
        }

        //Callout to Axioum service to get Lead Messages which are of Sent and Failed Status
        calloutToAcxiomLeadMessage(objLead);
    }

    //Callout to Axiom LeadMesage service to get Lead Messages which are of Sent and Failed Status
    private void calloutToAcxiomLeadMessage(Lead objLead) {
        //Bypassing the Acxiom Lead Message callout for Partial Lead Record type and Referral Lead Record type
        if(objLead != null && !(UTIL_StageOrchestrationConstants.LEAD_PARTIAL_RECORD_TYPE_DEV_NAME.equals(objLead.RecordType.DeveloperName)  || 
            UTIL_StageOrchestrationConstants.LEAD_REFERRAL_RECORD_TYPE_DEV_NAME.equals(objLead.RecordType.DeveloperName))) {
            //Logged in User Details
            User loggedUserDetails = [Select Servicing_Agent_Associate_ID__c from User Where Id = :userinfo.getUserId() WITH SECURITY_ENFORCED];
            if(!Test.isRunningTest()) {
                //Callout to Axioum service to get Lead Messages which are of Sent and Failed Status
                HLPR_AxciomLeadMessageCallout.callAxciomLeadMailingHistoryService(leadId,loggedUserDetails.Servicing_Agent_Associate_ID__c,accId);
            }
        }
    }

    /**
    * @description leadToleadConversionDetailsMapping: For Mapping Lead Data to LeadConversionDetails
    * @param objLead : ID 
    * @param accId : ID 
    */        
    private void leadToleadConversionDetailsMapping(lead objLead, Id accId){           
        
        LeadConversionDetail__c leadConversionDetails = new LeadConversionDetail__c();

        if(SMALL_BUSINESS_CORPORATE_CAMPAIGN.equals(objLead.OriginalLeadSource__c) || SMALL_BUSINESS_OUT_OF_BOOK_CAMPAIGN.equals(objLead.OriginalLeadSource__c)) {
            leadConversionDetails.AssignedTo__c = objLead.AssignedTo__c;
            leadConversionDetails.Company__c = objLead.Company;
            leadConversionDetails.FirstName__c = objLead.FirstName;
            leadConversionDetails.LastName__c = objLead.LastName;
            leadConversionDetails.SubmittedFirstName__c = objLead.Submitted_First_Name__c;
            leadConversionDetails.SubmittedLastName__c = objLead.Submitted_Last_Name__c;
            leadConversionDetails.City__c = objLead.City;
            leadConversionDetails.Country__c = objLead.Country;
            leadConversionDetails.Street__c = objLead.Street;
            leadConversionDetails.State__c = objLead.State;
            leadConversionDetails.PostalCode__c = objLead.PostalCode;
            leadConversionDetails.State__c = objLead.State;
            leadConversionDetails.OriginalLeadSource__c = objLead.OriginalLeadSource__c;
            leadConversionDetails.Phone__c = objLead.Phone;
            leadConversionDetails.SubmittedPhoneNumber__c = objLead.Submitted_Phone_Number__c;
            leadConversionDetails.SubmittedDoNotCall__c = objLead.Submitted_Do_Not_Call__c;
        }
        else{
            for(CM_StageOrchestration_Mapping__mdt mappingLoopForList : mappingForLeadtoLeadConversionDetails){
            
            leadConversionDetails.put(mappingLoopForList.Target_Field__c,objLead.get(mappingLoopForList.Source_Field__c));               
            }
        } 
        if(String.isNotBlank(objLead.Company)){
            leadConversionDetails.Name=objLead.Company.left(UTIL_StageOrchestrationConstants.EIGHTY_CHAR_FIELD);
        }else{
            leadConversionDetails.Name=(((String.isNotBlank(objLead.FirstName))?objLead.FirstName+' ':'')+objLead.LastName).left(UTIL_StageOrchestrationConstants.EIGHTY_CHAR_FIELD);
        }
        
        leadConversionDetails.Customer__c = accId;

        String loggedInUserSubUserInfoType = [Select SubUserType__c from User Where Id=: UserInfo.getUserId() WITH SECURITY_ENFORCED Limit 1]?.SubUserType__c;
        if(SUB_USER_TYPE_CCC.equals(loggedInUserSubUserInfoType)) {
            leadConversionDetails.ownerId = objLead.Agent__c;
        }
        insert Security.stripInaccessible(AccessType.CREATABLE, new List<LeadConversionDetail__c>{leadConversionDetails}).getRecords();
    }
}