/**
 * @description Controller to pull ABS Activities Data using ODATA call
 */
public with sharing class AT_ABSActivitiesController {
    
    private static final String CLASS_NAME = 'AT_ABSActivitiesController';
    @TestVisible private static List<Activities__x> mockedTempActivityList = new List<Activities__x>();    
    
    /**
     * @description
     * @param recordId
     * @param statusFilter
     * @param isHouseholdPage
     * @return
     */
    @AuraEnabled
    public static List<ActivityWrapper> getActivitiesList(Id recordId, String statusFilter, boolean isHouseholdPage) {//Fetch data
        @TestVisible UTIL_CustomerSummaryViewManager customerSummaryView = new UTIL_CustomerSummaryViewManager();
        CS_CustomerSummaryView__c summaryViewAccess = customerSummaryView.getCustomerSummaryViewAccessDetails();
        List<Activities__x> oDataActivitiesList = null;
        List<ActivityWrapper> anActivityWrapperList = new List<ActivityWrapper>();
        
        //Query User table to get currentUser so that we can make the Activities OData Call
        User currentUser = UTIL_CurrentUser.retrieveCurrentUser();
        String loggedInAlias = currentUser.Alias;
        String loggedInServiceAssocId = currentUser.Servicing_Agent_Associate_ID__c;
        
        //Query Account/customerGrouping/FSC HH Group to get clientId(s) so that we can make the Activities OData Call
        List<String> clientIds = (recordId.getSObjectType() == Account.getSObjectType()) ? isHouseholdPage ? getClientIdFromFSCGroup(recordId) : getClientIdFromAccount(recordId) : getClientIdsFromGroup(recordId);
        
        try{ 
            oDataActivitiesList = getActivities(recordId, statusFilter, clientIds);
			if (!oDataActivitiesList.isEmpty()) {
                anActivityWrapperList = getActivityWrapperList(oDataActivitiesList); 
            }
        }
        catch(Exception dataSourceExp) {
            // setting the Wrapper List to null causes a message to be displayed to the user that there was a problem
            anActivityWrapperList = null;
            LoggingService.logHandledException(dataSourceExp, CLASS_NAME, 'getActivitiesList', System.LoggingLevel.ERROR);
        }  
        return anActivityWrapperList;
    }  
    
    @TestVisible 
    private static string formatDate(String dateToFormat) {
        if(String.isNotBlank(dateToFormat)) { 
            Date dateObject = null;
            try {
                dateObject = Date.valueOf(dateToFormat);            
            }
            catch(TypeException e) {
                return dateToFormat;
            }
            if(dateObject.year() > 1900) {       
                Datetime dateTimeObject = Datetime.newInstance(dateObject.year(), dateObject.month(),dateObject.day());
                return dateTimeObject.formatGmt('MM/dd/yyyy');
            } else {
                return '';
            }
        } else {
            return ''; 
        }
    }

    @TestVisible 
    private static string formatTimestamp(String timeStampToFormat) {
        if(String.isNotBlank(timeStampToFormat)) {
            try {
                Datetime dateTimeObject = Datetime.valueOfGmt(timeStampToFormat);
                return dateTimeObject.formatGmt('MM/dd/yyyy');
            } catch(TypeException e) {
                return timeStampToFormat;
            }
        } else {
            return ''; 
        }     
    }

    @TestVisible
    private static Boolean loggedInUserIsAnAgentOrATMProfile(){
        return FeatureManagement.checkPermission('Agency_User');
    }
    
    private static List<String> getClientIdFromAccount(Id recordId) {
        List<Account> clientAccounts = Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT ClientIdentifier__c FROM Account WHERE Id=:recordId LIMIT 1]).getRecords();

        List<String> clientIds = new List<String>();
        if(!clientAccounts.isEmpty()){
	        clientIds.add(clientAccounts[0].ClientIdentifier__c);            
        }
        return clientIds;
    }

    @TestVisible
    private static List<String> getClientIdsFromGroup(Id recordId){
        List<CustomerGroupMember__c> groupMembers = Security.stripInaccessible(
            AccessType.READABLE,
            [SELECT Customer__r.ClientIdentifier__C FROM CustomerGroupMember__c 
                WHERE Group__c=:recordId
                LIMIT 100
            ]).getRecords();

        List<String> clientIds = new List<String>();
        for(CustomerGroupMember__c member : groupMembers){
        	clientIds.add(member.Customer__r.ClientIdentifier__c);   
        }
        return clientIds;
    }
    
    private static List<String> getClientIdFromFSCGroup(Id recordId) {
        Map<String,Account> clientIdsToAccountMap = UTIL_CustomerGroupData_FSC.getClientIdsForGroup(recordId);
        List<String> clientIds = new List<String> (clientIdsToAccountMap.keySet());
        return clientIds;
    }

    /**
     * @description
     * @param activityId
     * @return
     */
    @AuraEnabled
    public static String fetchRemark(String activityId) {
        String remarks = AT_ABSActivitiesRemarksHandler.fetchRemark(activityId);
        return remarks;
    }

     /**
     * @description
     * @param activityId
     * @param statusFilter
     * @param ownerAssociateId
     * @return
     */
    @AuraEnabled
    public static String fetchWorkItems(String activityId, String statusFilter, String ownerAssociateId) {
        String workItems = AT_ABSActivitiesWorkItemsHandler.fetchWorkItems(activityId, statusFilter, ownerAssociateId);
        return workItems;
    }

    private static List<Activities__x> getActivities(Id recordId, String statusFilter, List<String> clientIds){
        User currentUser = UTIL_CurrentUser.retrieveCurrentUser();
        String loggedInAlias = currentUser.Alias;
        String loggedInServiceAssocId = currentUser.Servicing_Agent_Associate_ID__c;
        List<Activities__x> oDataActivitiesList = null;
        String activitiesQuery = 'SELECT User__r.Name, Category__c, AgentName__c, ClientID__c, Customer__c, Description__c, DueDate__c, LineOfBusiness__c, ModifiedDate__c, Status__c, AssociateID__c, ActivityID__c, HouseholdReminder__c FROM Activities__x WHERE ClientID__c in :clientIds AND UserID__c = :loggedInAlias AND StatusFilter__c = :statusFilter';

        if(loggedInUserIsAnAgentOrATMProfile()){
            activitiesQuery += ' AND AssociateId__c = :loggedInServiceAssocId';     
        }
        activitiesQuery += ' LIMIT 1500';
        if(Test.isRunningTest()) {
            oDataActivitiesList = mockedTempActivityList;
            if (null != oDataActivitiesList && oDataActivitiesList.size() > 0 &&
                oDataActivitiesList[0].ClientID__c == 'error') {
                    throw new DMLException('error');
                }
        } else{
        	oDataActivitiesList = Security.stripInaccessible(
                AccessType.READABLE,
                Database.query(activitiesQuery)).getRecords(); 
        }
        return oDataActivitiesList;
    }

    private static List<ActivityWrapper> getActivityWrapperList(List<Activities__x> oDataActivitiesList){

        List<ActivityWrapper> anActivityWrapperList = new List<ActivityWrapper>();
        for (Activities__x selectActivity : oDataActivitiesList) {
            ActivityWrapper anActivityWrapper = new ActivityWrapper();
            anActivityWrapper.dueDate =formatDate(selectActivity.DueDate__c);
            anActivityWrapper.modifiedDate = formatTimestamp(selectActivity.ModifiedDate__c); 
            anActivityWrapper.status = selectActivity.Status__c;
            anActivityWrapper.customer = selectActivity.Customer__c;
            anActivityWrapper.description = selectActivity.Description__c;
            anActivityWrapper.lob = UTIL_LOBFormatter.formatLOB(selectActivity.LineOfBusiness__c);
            anActivityWrapper.category = selectActivity.Category__c;
            anActivityWrapper.agentName =  selectActivity.User__r.Name;
            anActivityWrapper.activityID =  selectActivity.ActivityID__c;
            anActivityWrapper.associateID =  selectActivity.AssociateID__c;
            anActivityWrapper.clientID = selectActivity.ClientID__c;
            anActivityWrapper.householdReminder = selectActivity.HouseholdReminder__c;
            anActivityWrapperList.add(anActivityWrapper);
        }
        return anActivityWrapperList;
    }
}