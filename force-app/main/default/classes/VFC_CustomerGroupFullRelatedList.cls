/****************************************************************************************
Name: VFC_CustomerGroupFullRelatedList
Copyright © State Farm
=========================================================================================
Purpose:
-------
This is the controller class to Customer Group Full Related List VF page.

Team: Choo Choo
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Choo_Choo                2/15/2018             2018 R2 Release

******************************************************************************************/
/**
 * @description VFC_CustomerGroupFullRelatedList
 */
public with sharing class VFC_CustomerGroupFullRelatedList {

    private static final String S1_THEME = 'Theme4t';
    private static final String SOBJECT_TYPE_PARAM = 'sObjectType';
    private static final String CASE_SOBJECT_TYPE = 'Case';
    private static final String ACC_NOTES_SOBJECT_TYPE = 'Account_Note__c';
    private static final String AGENT_ROLE_SOBJECT_TYPE = 'AgentRole__c';
    private static final String OPPORTUNITY_SOBJECT_TYPE = 'Opportunity';
    private static final String OPEN_TASK_SOBJECT_TYPE = 'OpenTasks';
    private static final String CLOSED_TASK_SOBJECT_TYPE = 'TaskHistory';
    private static final String OPEN_EVENT_SOBJECT_TYPE = 'OpenEvents';
    private static final String CLOSED_EVENT_SOBJECT_TYPE = 'EventHistory';
    private static final String CUSTOMER_ID_PARAM = 'customerId';

    /**
     * @description isS1Request
     */
    public Boolean isS1Request {get; set;}

    /**
     * @description sObjectType
     */
    public String sObjectType {get; set;}

    /**
     * @description groupId
     */
    public String groupId {get; set;}

    /**
     * @description customergroupRecord
     */
    public CustomerGroup__c customergroupRecord {get; set;}

    /**
     * @description relatedListName
     */
    public String relatedListName {get; set;}
    
    /**
     * @description custInContext
     */
    public Id custInContext {get; set;}

    //Default constructor
    /**
     * @description VFC_CustomerGroupFullRelatedList
     */
    public VFC_CustomerGroupFullRelatedList() {
        AP_ClickJackPrevention.setRequiredHeaders();
        isS1Request = false;
        if(S1_THEME.equalsIgnoreCase(UserInfo.getUiThemeDisplayed())) {
            isS1Request = true;
        }
        sObjectType = UTIL_PageParameterHelper.retrieveCurrentPageParameter(SOBJECT_TYPE_PARAM, ParameterType.SOBJECT_NAME);
        groupId = UTIL_PageParameterHelper.retrieveCurrentPageParameter(UTIL_CreateCustomerConstants.GROUP_ID, ParameterType.SALESFORCE_ID);
        custInContext = UTIL_PageParameterHelper.retrieveCurrentPageParameter(CUSTOMER_ID_PARAM, ParameterType.SALESFORCE_ID);
    }

    //init method
    /**
     * @description init
     */
    public void init() {
        customergroupRecord = (CustomerGroup__c)Security.stripInaccessible(AccessType.READABLE, [SELECT Id, Name FROM CustomerGroup__c WHERE Id = :groupId LIMIT 1]).getRecords()[0];
        relatedListName = System.Label.CL_PoliciesBillingTabName;
        if(String.isNotEmpty(sObjectType)){
            Boolean isRelatedListNameAssigned = false;
            if(CASE_SOBJECT_TYPE.equalsIgnoreCase(sObjectType)) {
                relatedListName = System.Label.CL_Cases;    
                isRelatedListNameAssigned = true;
            }
            else if(ACC_NOTES_SOBJECT_TYPE.equalsIgnoreCase(sObjectType)) {
                relatedListName = System.Label.CL_AccountNotes; 
                isRelatedListNameAssigned = true;
            }
            else if(AGENT_ROLE_SOBJECT_TYPE.equalsIgnoreCase(sObjectType)) {
                relatedListName = System.Label.CL_Agent;    
                isRelatedListNameAssigned = true;
            }else if(isRelatedListNameAssigned == false){
                evaluateRelatedListName();
            }

        }   
    }
    
    void evaluateRelatedListName(){

        if(OPPORTUNITY_SOBJECT_TYPE.equalsIgnoreCase(sObjectType)){
            relatedListName = System.Label.CL_Opportunities;
        }
        else if(OPEN_TASK_SOBJECT_TYPE.equalsIgnoreCase(sObjectType)) {
            relatedListName = System.Label.CL_OpenTasks;    
        }
        else if(CLOSED_TASK_SOBJECT_TYPE.equalsIgnoreCase(sObjectType)) {
            relatedListName = System.Label.CL_TaskHistory; 
        }
        else if(OPEN_EVENT_SOBJECT_TYPE.equalsIgnoreCase(sObjectType)) {
            relatedListName = System.Label.CL_OpenEvents;    
        }
        else if(CLOSED_EVENT_SOBJECT_TYPE.equalsIgnoreCase(sObjectType)){
            relatedListName = System.Label.CL_EventHistory;
        }   
    }
}