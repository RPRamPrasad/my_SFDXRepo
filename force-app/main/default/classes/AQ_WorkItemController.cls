/**
  * @name AQ_WorkItemController
  * @author Team Skynet
  * @createdDate 12/07/2022
  * @description  This class will handle Data retrieval for Agent Queue Consolidated work items View
*/
public with sharing class AQ_WorkItemController {

    /**
    * @name: getOpportunities
    * @description Method to return Opportunity Work Items
    * @param assignedTo For My work items queue
    * @return List of Opportunity work items
    */
    @AuraEnabled(cacheable=true)
    public static List<AQ_WorkItem> getOpportunities(Id assignedTo){
        List<AQ_WorkItem> opportunities = new List<AQ_WorkItem>();
        try{
            opportunities = AQ_OpportunityDAO.getWorkItems(assignedTo);
        }catch(Exception e){
            AP_LogHolder logHolder = new AP_LogHolder();
              logHolder.info('AQ_WorkItemController', e.getMessage() + System.now());
              logHolder.writeToLogExceptionObject();
        }
        return opportunities;
    }


    /**
    * @name: getLeads
    * @description Method to return Lead Work Items
    * @param assignedTo For My work items queue
    * @return List of Lead work items
    */
    @AuraEnabled(cacheable=true)
    public static List<AQ_WorkItem> getLeads(Id assignedTo){
        List<AQ_WorkItem> leads = new List<AQ_WorkItem>();
        try{
            leads = AQ_LeadDAO.getWorkItems(assignedTo);
        }catch(Exception e){
            AP_LogHolder logHolder = new AP_LogHolder();
              logHolder.info('AQ_WorkItemController', e.getMessage() + System.now());
              logHolder.writeToLogExceptionObject();
        }
        return leads;
    }
}