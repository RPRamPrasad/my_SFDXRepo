/**
  * @Name AP_QA_Opportunity_UpdateStage_CCC
  * @Author Team Dream Builders 1/15/2018
  * @description update the Opportunity Stage to Quote In Progress
  */
  public with sharing class AP_QA_Opportunity_UpdateStage_CCC implements AP_PreRedirectAction{

    private String opportunityId;
    private String newStageName;
    private static final List<String> EXCLUDE_STAGE_NAMES = new String[] {'Quoting','App Submitted', 'Closed Won'};
    private static final List<String> EXCLUDE_STATUS_NAMES = new String[] {'Quote In Progress','Quote Provided', 'Application Pending'};

    private static final String ERROR_MESSAGE_PARAM_NULL = 'Opportunity ID is null.';
    private static final String ERROR_MESSAGE_OPPORTUNITY_DOES_NOT_EXIST = 'Opportunity does not exist. Id: ';
    private static final String OPPORTUNITY_ID = 'opportunityId';
    private static final String NEW_STAGE_NAME = 'newStageName';
    private static final String APP_PENDING_STAGENAME = 'App Pending';
    private static final String APP_SUBMITTED_STAGENAME ='App Submitted';
    private static final String CLOSED_STAGENAME ='Closed';
    private static final String CLOSED_WON_STAGENAME ='Closed Won';
    private static final String QUOTE_IN_PROGRESS_STATUS ='Quote In Progress';
    private static final String QUOTE_ING_STAGENAME ='Quoting';

    /**
    * @description This method used to update the Opportunity Stage to Quote In Progress
    */
    public void execute(){
        String profileName = getProfileName();
        if (opportunityId == null) {
            NoDataFoundException ex = new NoDataFoundException();
            ex.setMessage(ERROR_MESSAGE_PARAM_NULL);
            throw ex;
        }
        if(Schema.sObjectType.Opportunity.isCreateable() && !profileName.equals(label.CL_TechSupport_Profile)){
            oppStageUpdate();
        }
    }
    private void oppStageUpdate(){
        List<Opportunity> opportunity = [SELECT ID, StageName,status__c FROM Opportunity WHERE ID = :opportunityId LIMIT 1];
       // String NEW_STAGE_VALUE = QUOTE_ING_STAGENAME;
        /*if(opportunity.get(0).StageName <> APP_SUBMITTED_STAGENAME && opportunity.get(0).StageName
           <> APP_PENDING_STAGENAME && opportunity.get(0).StageName <> CLOSED_STAGENAME && opportunity.get(0).StageName
           <> CLOSED_WON_STAGENAME && opportunity.get(0).StageName <> QUOTE_IN_PROGRESS_STAGENAME){
               opportunity.get(0).StageName = NEW_STAGE_VALUE;
               update opportunity;
           }*/

        Opportunity opp = opportunity.get(0);
        boolean isUpdated = false;
        if(!(EXCLUDE_STAGE_NAMES).contains( opp.StageName)){
            opp.StageName = QUOTE_ING_STAGENAME;
            isUpdated = true;
        }
        if(!EXCLUDE_STATUS_NAMES.contains(opp.status__c))
        {
            opp.status__c = QUOTE_IN_PROGRESS_STATUS;
            isUpdated = true;
        }
        if(isUpdated){
            update Security.stripInaccessible(AccessType.UPDATABLE, new List<Opportunity> {opp}).getRecords();
        }

    }
    
    /**
     * @description setRequestParameters
     * @param requestParameters 
     */
    public void setRequestParameters(Map<String, String> requestParameters){
        opportunityId = requestParameters.get(OPPORTUNITY_ID);
        newStageName = requestParameters.get(NEW_STAGE_NAME);
    }

    private static string getProfileName(){
        return UTIL_LtngProfileDataAccess.getProfileName();
    }
}