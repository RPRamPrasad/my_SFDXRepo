/**
  * @name UTIL_CustomerGroupAgentList
  * @author Poseidon
  * @createdDate 10/2/2018
  * @description Utility class to return Agents for CustomerGroupRelatedList component
  */

public with sharing class UTIL_CustomerGroupAgentList {
	private static final String AGENT_LIST_TYPE = 'AGENT';
    private static final String OBJECT_TO_QUERY = 'AgentRole__c';
    private static final String WHERE_CONDITION = ' WHERE Customer__r.Id IN:groupCustomerIdList';
    private static final Integer QUERY_LIMIT = 10;
    private static final String AGENT_ICON = 'standard:user';

    /**
     * @description Fetch Data
     * @param dataWrap
     * @return CustomerGroupRelatedListController.DataTableResponse
     */
    public static CustomerGroupRelatedListController.DataTableResponse fetchData(FetchDataWrapper dataWrap) {    	

        CustomerGroupRelatedListController.DataTableResponse response = new CustomerGroupRelatedListController.DataTableResponse();
        
        List<CustomerGroupRelatedListController.DataTableColumns> columns = new List<CustomerGroupRelatedListController.DataTableColumns>();
       
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Relationship Nature','relationshipNatureText','Text', true));
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Customer','customerUrl','url', true, 'customerName'));            
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Relationship Start Date','relationStartDate','date', true));  
        columns.add(new CustomerGroupRelatedListController.DataTableColumns('Agent','agentUrl','url', true,'agentName'));
        
        List<Id> groupCustomerIdList = UTIL_CustomerGroupList.fetchCustomerGroupMemberIds(dataWrap.groupRecordId);
        if (dataWrap.queryLimit == 0) { dataWrap.queryLimit = 200;}
        List<AgentRole__c> agents = Security.stripInaccessible(
                                                  AccessType.READABLE,
                                                  [SELECT Id, RelationshipNature__c, Customer__r.Name, Customer__r.Id, RelationshipStartDate__c, Agent__r.Name, Agent__r.Id
                                                   FROM AgentRole__c
                                                   WHERE Customer__r.Id IN:groupCustomerIdList
                                                   LIMIT :dataWrap.queryLimit])
                                                  .getRecords();
        List<AgentWrapper> agentWrappers = new List<AgentWrapper>();
        
        for (AgentRole__c agent : agents) {
            AgentWrapper agentWrapper = new AgentWrapper();          
            agentWrapper.id = agent.Id;
            agentWrapper.relationshipNatureText = UTIL_CustomerGroupList.handleNullString(agent.RelationshipNature__c);   
            agentWrapper.customerUrl = UTIL_CustomerGroupList.buildLightningUrl(agent.Customer__r.Id);                 
            agentWrapper.customerName = UTIL_CustomerGroupList.handleNullString(agent.Customer__r.Name);
            agentWrapper.relationStartDate = UTIL_CustomerGroupList.handleNullDate(agent.RelationshipStartDate__c);
            agentWrapper.agentUrl = UTIL_CustomerGroupList.buildLightningUrl(agent.Agent__r.Id);
            agentWrapper.agentName = UTIL_CustomerGroupList.handleNullString(agent.Agent__r.Name);
            agentWrappers.add(agentWrapper);
        }
        
		response.lstDataTableColumns = columns;
        response.lstDataTableData = agentWrappers;
        response.icon = AGENT_ICON;
        return response;    
   	}
    
    /**
     * @description Agent Wrapper
     */
    public with sharing class AgentWrapper {

        /**
         * @description Getters and Setters of the property id
         */
        @AuraEnabled
        public String id {get; set;}

        /**
         * @description Getters and Setters of the property relationshipNatureText
         */
        @AuraEnabled
        public String relationshipNatureText {get; set;}

        /**
         * @description Getters and Setters of the property customerUrl
         */
        @AuraEnabled
        public String customerUrl {get; set;}

        /**
         * @description Getters and Setters of the property customerName
         */
        @AuraEnabled
        public String customerName {get; set;}

        /**
         * @description Getters and Setters of the property agentName
         */
        @AuraEnabled
        public String agentName {get; set;}

        /**
         * @description Getters and Setters of the property relationStartDate
         */
        @AuraEnabled
        public String relationStartDate {get; set;}

        /**
         * @description Getters and Setters of the property agentUrl
         */
        @AuraEnabled
        public String agentUrl {get; set;}
       
    }

    /**
     * @description Fetch Data Wrapper
     */
    public class FetchDataWrapper{
        public String groupRecordId;
        public String relatedListType;
        public String accountId;
        public Integer queryLimit;
    }
}