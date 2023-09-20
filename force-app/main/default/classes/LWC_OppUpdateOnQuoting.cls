/** 
@Author Team Optimizers
@Name LWC_OppUpdateOnQuoting
@CreateDate 02/07/2022  
@description This class is used to update opportunity and invoke the New App Quote application.
@Version 1.0 
Copyright © StateFarm  
Version     Author      Date                           Description
*/

public with sharing class LWC_OppUpdateOnQuoting {
    private static final List<String> EXCLUDE_STAGE_NAMES = new String[] {'App Submitted', 'Quoting', 'Closed Won'};
    private static final String QUOTE_IN_PROGRESS_STATUS = 'Quote In Progress';
    private static final String QUOTING_STAGENAME = 'Quoting';
    private static final List<String> EXCLUDE_STATUS_NAMES = new String[] {'Quote Provided', 'Application Pending'};
    static final String CLASS_NAME = 'LWC_OppUpdateOnQuoting';
    static final String UPDATE_OPPORTUNITY = 'updateOpportunityAndInvokeNewAppQuote';
    static final String STATUS = 'status';
    static final String SUCCESS = 'success';
    static final String FAILURE = 'failure';
    static final String URL_TO_LAUNCH = 'urlToLaunch';
    static final String DISPLAY_INTERMEDIATE_SCREEN = 'displayIntermScreen';
    static final String CANVAS_OPPMGMNT_PARTITION = 'local.CanvasIntmdtScreenPartition.';
    /**
     * @description OpportunityUpdateRequest Inner class that is used to get the request from LWC
     */
    public with sharing class OpportunityUpdateRequest{

        /**
         * @description productDetails
         */
        @AuraEnabled
        public List<Map<String,String>> productDetails{get;set;}

        /**
         * @description lob
         */
        @AuraEnabled
        public String lob {get; set;} 

        /**
         * @description stateCode
         */
        @AuraEnabled
        public String stateCode {get; set;} 

        /**
         * @description effectiveDate
         */
        @AuraEnabled
        public Date effectiveDate {get; set;} 

        /**
         * @description oppRecordId
         */
        @AuraEnabled
        public String oppRecordId {get; set;} 

        /**
         * @description stageName
         */
        @AuraEnabled
        public  string stageName {get;set;}

        /**
         * @description status
         */
        @AuraEnabled
        public  string status {get;set;}
        /**
         * @description The additional owner of Investments Opportunities
         */
        @AuraEnabled
        public string additionalOwner {get;set;}

        /**
         * @description The type of relationship between the primary and additional Accounts on Investments 
         * Joint Opportunities
         */
        @AuraEnabled
        public string jointType {get;set;}
    }
    
    /**
     * @description updateOpportunityAndInvokeNewAppQuote retrieves the data from LWC, process the message and calls a DML operation to update the data in opportunity
     * and invoke the new app quote
     * @param opportunityUpdateRequest (LWC_OppUpdateOnQuoting.OpportunityUpdateRequest): opportunityUpdateRequest description}
     * @return String: Return string of status and url to launch
     */
    @AuraEnabled(cacheable=false)
    public static String updateOpportunityAndInvokeNewAppQuote(LWC_OppUpdateOnQuoting.OpportunityUpdateRequest opportunityUpdateRequest){
        Map<String,String> returnData = new Map<String,String>();
        if(opportunityUpdateRequest.productDetails == null){
            returnData.put(STATUS,FAILURE);
            return JSON.serialize(returnData);
        }

        try{
            if(Schema.sObjectType.Opportunity.isCreateable() && validateisNotTechProfile()){ 
                updateOpportunity(opportunityUpdateRequest);
            }
        }
        catch(Exception e){
            returnData.put(STATUS,FAILURE);
            LoggingService.logHandledException(e, CLASS_NAME, UPDATE_OPPORTUNITY,System.LoggingLevel.ERROR);
            return JSON.serialize(returnData);
        }
        try{
            OpportunityProduct__c oProduct = new OpportunityProduct__c();
            for(Map<String,String> productDetail : opportunityUpdateRequest.productDetails){
                oProduct.Product_Id__c=productDetail.get('ProductId'); //Required
                oProduct.Lob_Cd__c=productDetail.get('LobCd'); //Required
            }
            
            String url = HLPR_OppButtonController.newAppQuoteUrl(opportunityUpdateRequest.oppRecordId, Json.serialize(oProduct));
            returnData.put(STATUS,SUCCESS);
            if('QuoteIsCanvasable'.equalsIgnoreCase(url)){
                hideIntermediateScreen(opportunityUpdateRequest.oppRecordId,true);
            }
            returnData.put(URL_TO_LAUNCH,url);
        }
        catch(Exception e){
            returnData.put(STATUS,FAILURE);
            LoggingService.logHandledException(e, CLASS_NAME, UPDATE_OPPORTUNITY,System.LoggingLevel.ERROR);
            return JSON.serialize(returnData);
        }
        return JSON.serialize(returnData);
    }

    /**
     * @description updateOpportunity 
     *
     * @param opportunityUpdateRequest (OpportunityUpdateRequest): opportunityUpdateRequest description}
     */
    private static void updateOpportunity(OpportunityUpdateRequest opportunityUpdateRequest){
       Opportunity updateOpp = new Opportunity();
       updateOpp.Id = opportunityUpdateRequest.oppRecordId;
       updateOpp.State_Code__c = opportunityUpdateRequest.stateCode;
       updateOpp.lob__c=opportunityUpdateRequest.lob;
       updateOpp.Requested_Effective_Date__c= opportunityUpdateRequest.effectiveDate;
       String stageName = opportunityUpdateRequest.stageName;
       String status = opportunityUpdateRequest.status;
       if (!(EXCLUDE_STAGE_NAMES).contains(stageName)){
            updateOpp.stageName=QUOTING_STAGENAME;
            if(!EXCLUDE_STATUS_NAMES.contains(status))
            	{
                	updateOpp.status__c = QUOTE_IN_PROGRESS_STATUS;
            	}
       }
       for(Map<String,String> productDetail : opportunityUpdateRequest.productDetails){
            updateOpp.Product_system_name__c=productDetail.get('ProductSystemName');
            updateOpp.Product__c = productDetail.get('ProductDescription');
       }
       updateOpp.JointType__c = String.isNotEmpty(opportunityUpdateRequest.jointType) ? opportunityUpdateRequest.jointType : null;
       updateOpp.AdditionalOwner__c = String.isNotEmpty(opportunityUpdateRequest.additionalOwner) ? opportunityUpdateRequest.additionalOwner: null;
       update Security.stripInaccessible(AccessType.UPDATABLE, new List<Opportunity>{updateOpp}).getRecords(); 
    }

    /**
     * @description getStateCodeInfoFromOppOfficeId 
     *
     * @param selectedAgentId (String): selectedAgentContextAssociateID description}
     * @return LWC_NewOpportunityWorkflow.StateSelectionOptions : Return description
     */
    @AuraEnabled(cacheable=true)
    public static LWC_NewOpportunityWorkflow.StateSelectionOptions getStateCodeInfoFromOppOfficeId(String selectedAgentId){
        List<User> userlist = Security.stripInaccessible(
                AccessType.READABLE,
                [SELECT State_Agent_Code__c,State_Agent_Code_List__c FROM User WHERE UserExternalId__c = :selectedAgentId + '_' + selectedAgentId]
            ).getRecords();
        return LWC_NewOpportunityWorkflow.getStateCodeWrapperList(userlist); 
    }

    /**
     *  @description This method validates the stages and updates the opportunity if the stage is not one of the Exclude stage names
     *  @param opp
     *  @return String
     */
    public static String validateAndInvokeOpp(Opportunity opp) { 
        if (!(EXCLUDE_STAGE_NAMES).contains(opp.StageName) && Schema.sObjectType.Opportunity.isCreateable() && validateisNotTechProfile()){
            hideIntermediateScreen(opp.id,true);
            return UTIL_OppQuoteValidation.updateOpportunity(opp);
        }
        else{
            return 'StageInQuoting';
        }
    }

    /**
     * @description This method validates the profile is Technical profile or not and returns a boolean value as true if Technical Support profile.
     * @return Boolean
     */
    public static Boolean validateisNotTechProfile(){
        User user = [SELECT SubUserType__c,UserType__c,IsActive FROM User WHERE Id = :UserInfo.getUserId() and isActive=true WITH SECURITY_ENFORCED Limit 1];
        if('SFDC_USER_1_07_Tech_Supp'.equals(user.SubUserType__c) && 'Support'.equals(user.UserType__c)){
            return false;
        }
        return true;
    }
    
    /**
     *  @description This method takes the opportunity id and boolean value and inserts a key value pair in the session cache.
     *  @param opportunityId
     *  @param shouldShowMessage
     */
    @AuraEnabled
    public static void hideIntermediateScreen(Id opportunityId, Boolean shouldShowMessage) {
        String key = CANVAS_OPPMGMNT_PARTITION + opportunityId;
        if (shouldShowMessage) {
            Cache.Session.put(key, DISPLAY_INTERMEDIATE_SCREEN);
        } else {
            Cache.Session.remove(key);
        }
    }
    /**
     * @description retrieve ProspectDataFields.
     * @param recordId
     * @return
     */
    @AuraEnabled(cacheable=false)
    public static Opportunity getProspectEvalData(String recordId){
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('recordId', recordId, Opportunity.class);
        List<Opportunity> oppList = Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT  Opportunity_Score__c,Temperature_Evaluator__c,hasProspectEval__c from Opportunity where id=:recordId
             ] ).getRecords();
        return !oppList.isEmpty() && oppList.size()>0 ? (Opportunity)oppList.get(0) : null;
    }
}