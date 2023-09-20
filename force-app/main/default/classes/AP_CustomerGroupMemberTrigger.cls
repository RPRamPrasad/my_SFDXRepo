/**
  * @name AP_CustomerGroupMemberTrigger 
  * @author Choo Choo
  * @owner Stark
  * @createdDate 03/08/2018
  * @description This class removes CustomerGroupMember__c record that are not not required
  */
public without sharing class AP_CustomerGroupMemberTrigger {
    private static final String CLASS_NAME = 'AP_CustomerGroupMemberTrigger';
    private static final String METHOD_NAME = 'removeOldGroupings';
    
	/**
	 * @description Remove Old Groupings
	 * @param groupMemberList
	 */
    public static void removeOldGroupings(List<CustomerGroupMember__c> groupMemberList) {
    	try {
    		Set<Id> accIdList = new set<Id>();
    		Set<Id> groupIdList = new set<Id>();
    		List<CustomerGroupMember__c> groupMembersToDelete = new List<CustomerGroupMember__c>();
    		Map<Id, List<Id>> groupMapByCustomer = new Map<Id, List<Id>>();
    		Map<Id, Id> agentMapByGroup = new Map<Id, Id>();
    		for(CustomerGroupMember__c grpMember : groupMemberList) {
    			if(groupMapByCustomer.get(grpMember.Customer__c) == null) {
    				accIdList.add(grpMember.Customer__c);
    				groupMapByCustomer.put(grpMember.Customer__c, new List<Id>{grpMember.group__c});
    			}
    			else {
    				List<Id> customerGroupIdList = groupMapByCustomer.get(grpMember.Customer__c);
    				customerGroupIdList.add(grpMember.group__c);
    				groupMapByCustomer.put(grpMember.Customer__c, customerGroupIdList);
    			}
    			groupIdList.add(grpMember.group__c);
    		}
    		for(CustomerGroup__c custgrp : [SELECT Id, Agent__c FROM CustomerGroup__c WHERE Id IN :groupIdList]) {
    			agentMapByGroup.put(custgrp.Id, custgrp.Agent__c);
    		}
    		for(CustomerGroupMember__c existingMember : [SELECT Id, Customer__c, Customer__r.ClientIdentifier__c, Group__r.Agent__c FROM CustomerGroupMember__c WHERE Customer__c IN :accIdList]) {
				for(Id groupId : groupMapByCustomer.get(existingMember.Customer__c)) {
    				if(existingMember.Group__r.Agent__c == agentMapByGroup.get(groupId)) {
    					groupMembersToDelete.add(existingMember);
    				}
    			}
    		}
    		if(!groupMembersToDelete.isEmpty()) {
    			Database.DeleteResult[] groupMembersDeleteResults = Database.delete(groupMembersToDelete, false);
    			LoggingService.logDatabaseResult(groupMembersDeleteResults, groupMembersToDelete, CLASS_NAME, METHOD_NAME, System.LoggingLevel.ERROR);
    		}
    	}
    	catch(exception ex) {
            LoggingService.logHandledException(ex, CLASS_NAME, METHOD_NAME, System.LoggingLevel.ERROR);
            UTIL_AgentProxySelection.tagAllErrors(groupMemberList, ex.getMessage());
        }
    }
}