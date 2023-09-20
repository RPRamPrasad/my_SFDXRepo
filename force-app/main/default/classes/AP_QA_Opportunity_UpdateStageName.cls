/****************************************************************************************
Name: AP_QA_Opportunity_UpdateStageName
Copyright © State Farm
=========================================================================================
Purpose:
-------
Decription: This class is responsible for updating the stage name when the agent clicks on New/AppQuote button
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
R9              Venkata Padigala        05/13/2020              Updated the logic to update the stage and status

******************************************************************************************/
/**
 * @description AP_QA_Opportunity_UpdateStageName
 */
public with sharing class AP_QA_Opportunity_UpdateStageName implements AP_PreRedirectAction {

    private String opportunityId;
    private String newStageName;
    private static final String QUOTE_IN_PROGRESS_STAGENAME ='Quote In Progress';
    private static final String ERROR_MESSAGE_PARAM_NULL = 'Opportunity ID is null.';
    private static final String ERROR_MESSAGE_OPPORTUNITY_DOES_NOT_EXIST = 'Opportunity does not exist. Id: ';
    private static final String OPPORTUNITY_ID = 'opportunityId';
    private static final String NEW_STAGE_NAME = 'newStageName';
    private static final List<String> EXCLUDE_STAGE_NAMES = new String[] {'Quoting','App Submitted', 'Closed Won'};
    private static final List<String> EXCLUDE_STATUS_NAMES = new String[] {'Quote In Progress','Quote Provided', 'Application Pending'}; //

    /**
     * @description execute
     */
    public void execute() {
        if (String.isBlank(opportunityId)) {
    		NoDataFoundException ex = new NoDataFoundException();
    		ex.setMessage(ERROR_MESSAGE_PARAM_NULL);
    		throw ex;
    	}
    	updateOpportunity(opportunityId);
    }
    /**
    *  method to update the stage and status if the stage name is coming as Quoting
    *  @description  updateOpportunity
    *  @param opportunityId String
    */
    public void updateOpportunity(String opportunityId){
        List<Opportunity> opportunityList = [SELECT ID, StageName,status__c FROM Opportunity WHERE ID = :opportunityId WITH SECURITY_ENFORCED];

    	if (CollectionUtils.isNullOrEmptyList(opportunityList)) {
    		NoDataFoundException ex = new NoDataFoundException();
    		ex.setMessage(ERROR_MESSAGE_OPPORTUNITY_DOES_NOT_EXIST + opportunityId);
    		throw ex;
        } else {
            Opportunity opportunity = opportunityList.get(0);
            boolean isUpdated = false;

            if(!(EXCLUDE_STAGE_NAMES).contains(opportunity.StageName)){
                opportunity.StageName = newStageName;
                isUpdated = true;
            }
            if(!EXCLUDE_STATUS_NAMES.contains(opportunity.status__c))
            {
                opportunity.status__c = QUOTE_IN_PROGRESS_STAGENAME;
                isUpdated = true;
            }
            if(isUpdated){
                update Security.stripInaccessible(AccessType.UPDATABLE, new List<Opportunity> {opportunity}).getRecords();
            }

        }
    }
    /**
     * @description setRequestParameters This method is used to set the parameters that are being sent by the link
     *
     * @param requestParameters (Map<StringString>): requestParameters description}
     */
    public void setRequestParameters(Map<String, String> requestParameters) {
        opportunityId = requestParameters.get(OPPORTUNITY_ID);
    	newStageName = requestParameters.get(NEW_STAGE_NAME);
    }
}