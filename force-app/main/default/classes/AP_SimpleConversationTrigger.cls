/**
* Author : Golden Spikes Team
* Date Created : 07/06/2018
* @description  Updates SimpleConversation ownerId field to Agent Proxy User.
                Updates SimpleConversation for Number of Times the conversation has been rescheduled.
                Updates SimpleConversation Last Conversation Date only on Simple Conversation create.
                Prevent the SimpleConversation being deleted.
*/

public with sharing class AP_SimpleConversationTrigger {

    private static final String SIMPLE_ACCOUNT_API_NAME = 'Account__c';
    private static final String SIMPLE_AGENT_API_NAME = 'Agent__c';
    private static final String LATEST_COMPLETED_DATE_TIME_ALIAS = 'latestCompletedDateTime';
    private static final String COMPLETED_STATUS = 'Completed';
    private static final String HYPEN_SYMBOL = '-';
    private static final String USER_EXTERNAL_ID_CONCATENATION_SYMBOL = '_';
    private AP_SimpleConversationTriggerWrapper apWrap = new AP_SimpleConversationTriggerWrapper();

    /**
    * @description Method invoked by Trigger VirtualMeetingParticipantsAfterDelete.
    * @param simpleConversationList
    */
    public void processSimpleConversationOnBeforeInsert(List<SimpleConversation__c> simpleConversationList) {
        try {
            updateOwnerWithAgentProxy(simpleConversationList);
            updateLastConversationDateTime(simpleConversationList);
        } catch(Exception simpleConvException) {
            UTIL_AgentProxySelection.tagAllErrors(simpleConversationList, simpleConvException.getMessage());
        }
    }

    /**
    * @description entry point method to process the simple conversation before update records.
    * @param simpleConversationList
    * @param oldSimpleConversationMap
    */
    public void processSimpleConversationOnBeforeUpdate(List<SimpleConversation__c> simpleConversationList, Map<Id, SimpleConversation__c> oldSimpleConversationMap) {
        try {
            updateSimpleConversationRescheduleCount(simpleConversationList, oldSimpleConversationMap);
        } catch(Exception simpleConvException) {
            UTIL_AgentProxySelection.tagAllErrors(simpleConversationList, simpleConvException.getMessage());
        }
    }

    /**
    * @description method to update the simple conversation record owner to proxy user.
    * @param simpleConversationList
    */
    private void updateOwnerWithAgentProxy(List<SimpleConversation__c> simpleConversationList) {
        Set<Id> servicingAgentAssociatIdSet = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id, Set<Id>> accountAgentRoleMap = new Map<Id, Set<Id>>();
        List<User> loggedInUserServicingAgentAssociateIdList = new List<User>();
        User loggedInUserInfo = [Select profile.name, Servicing_Agent_Associate_ID__c from user where id =: userinfo.getUserId() limit 1];

        if((UTIL_Constants.AGENT_PROFILE_NAME.equals(loggedInUserInfo.Profile.Name) || UTIL_Constants.ATM_PROFILE_NAME.equals(loggedInUserInfo.Profile.Name)) && String.isNotBlank(loggedInUserInfo.Servicing_Agent_Associate_ID__c)) {
                loggedInUserServicingAgentAssociateIdList = Security.stripInaccessible(AccessType.READABLE, [Select id from User Where UserExternalID__c =: loggedInUserInfo.Servicing_Agent_Associate_ID__c + USER_EXTERNAL_ID_CONCATENATION_SYMBOL  + loggedInUserInfo.Servicing_Agent_Associate_ID__c limit 1]).getRecords();
        }

        ServicingAgentAssociateIdWrapperList servicingAgentWrap = new ServicingAgentAssociateIdWrapperList();
			servicingAgentWrap.simpleConversationList = simpleConversationList;
			servicingAgentWrap.loggedInUserInfo = loggedInUserInfo;
			servicingAgentWrap.loggedInUserServicingAgentAssociateIdList = loggedInUserServicingAgentAssociateIdList;
			servicingAgentWrap.servicingAgentAssociatIdSet = servicingAgentAssociatIdSet;
			servicingAgentWrap.accountIdSet = accountIdSet;
	    servicingAgentAssociateIdEmpty(servicingAgentWrap);

        Map<Id, Id> agentProxyMap = UTIL_AgentOfficeDetails.getAgentProxyMapForGivenAgentIds(servicingAgentAssociatIdSet);
        accountAgentRoleMap = queryAccountAgentRole(accountIdSet);

        apWrap.setErrorOrOwnerId(simpleConversationList, accountAgentRoleMap, agentProxyMap);
    }

   private void servicingAgentAssociateIdEmpty(ServicingAgentAssociateIdWrapperList agentAssociateIdWrapper){
	List<SimpleConversation__c> simpleConversationList = agentAssociateIdWrapper.simpleConversationList;
	User loggedInUserInfo = agentAssociateIdWrapper.loggedInUserInfo;
	List<User> loggedInUserServicingAgentAssociateIdList = agentAssociateIdWrapper.loggedInUserServicingAgentAssociateIdList;
	Set<Id> servicingAgentAssociatIdSet = agentAssociateIdWrapper.servicingAgentAssociatIdSet;
	Set<Id> accountIdSet = agentAssociateIdWrapper.accountIdSet;
        for(SimpleConversation__c simpleConv: simpleConversationList) {
            if((UTIL_Constants.AGENT_PROFILE_NAME.equals(loggedInUserInfo.Profile.Name) || UTIL_Constants.ATM_PROFILE_NAME.equals(loggedInUserInfo.Profile.Name))			
            && !loggedInUserServicingAgentAssociateIdList.isEmpty() ) {
                    simpleConv.Agent__c = loggedInUserServicingAgentAssociateIdList.get(0).id;
            }
            servicingAgentAssociatIdSet.add(simpleConv.Agent__c);
            accountIdSet.add(simpleConv.Account__c);
        }
	}

    private class ServicingAgentAssociateIdWrapperList{
		private List<SimpleConversation__c> simpleConversationList;
		private User loggedInUserInfo;
		private List<User> loggedInUserServicingAgentAssociateIdList;
		private Set<Id> servicingAgentAssociatIdSet;
		private Set<Id> accountIdSet;
	}

    /**
    * @description  method to get the account agent role Info
    * @param accountIdSet
    * @return accountAgentRoleMap
    */
    private Map<Id, Set<Id>> queryAccountAgentRole(Set<Id> accountIdSet) {
        return apWrap.queryAccountAgentRole(accountIdSet);
    }

    /**
    * @description  method to update the Number of Times the simple conversation has been rescheduled.
    * @param simpleConversationList
    * @param simpleConversationOldMap
    */
    private void updateSimpleConversationRescheduleCount(List<SimpleConversation__c> simpleConversationList, Map<Id, SimpleConversation__c> simpleConversationOldMap) {
        apWrap.updateSimpleConversationRescheduleCount(simpleConversationList, simpleConversationOldMap);
    }

     /**
    * @description method to update the Last Conversation Date/Time for the newly created simple conversation records.
    * @param simpleConversationList
    */
    private void updateLastConversationDateTime(List<SimpleConversation__c> simpleConversationList) {
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> agentIdSet = new Set<Id>();
        Map<String, DateTime> accountMaxAppointmentEndDateTimeMap = new Map<String, DateTime>();
        List<SimpleConversation__c> simpleConversationToBeUpdated = new List<SimpleConversation__c>();

        lastConversationDateWrapperList updateLastConversationWrap = new lastConversationDateWrapperList();
			updateLastConversationWrap.simpleConversationList = simpleConversationList;
			updateLastConversationWrap.accountIdSet = accountIdSet;
			updateLastConversationWrap.agentIdSet = agentIdSet;
			updateLastConversationWrap.simpleConversationToBeUpdated = simpleConversationToBeUpdated;
		lastConversationDateNull(updateLastConversationWrap);

        if(!accountIdSet.isEmpty() && !agentIdSet.isEmpty()) {
            for(AggregateResult simpleAggResult: [Select Account__c, Agent__c, MAX(AppointmentEndDateTime__c) latestCompletedDateTime from
                SimpleConversation__c Where Account__c in: accountIdSet and Agent__c in: agentIdSet and Status__c =: COMPLETED_STATUS group by Account__c, Agent__c]) {
                accountMaxAppointmentEndDateTimeMap.put((String) simpleAggResult.get(SIMPLE_ACCOUNT_API_NAME) + HYPEN_SYMBOL + (Id) simpleAggResult.get(SIMPLE_AGENT_API_NAME), (DateTime) simpleAggResult.get(LATEST_COMPLETED_DATE_TIME_ALIAS));
            }

            if(!accountMaxAppointmentEndDateTimeMap.isEmpty()) {
                for(SimpleConversation__c simpleConversation: simpleConversationToBeUpdated) {
                    maxAppointmentEndDateTimeMap(accountMaxAppointmentEndDateTimeMap, simpleConversation);
                }
            }
        }
    }

    private void maxAppointmentEndDateTimeMap(Map<String, DateTime> accountMaxAppointmentEndDateTimeMap, SimpleConversation__c simpleConversation){
	    if(accountMaxAppointmentEndDateTimeMap.get(simpleConversation.Account__c + HYPEN_SYMBOL + simpleConversation.Agent__c)  != null) {
                        DateTime lastConversationDateTime = accountMaxAppointmentEndDateTimeMap.get(simpleConversation.Account__c + HYPEN_SYMBOL + simpleConversation.Agent__c);
                        simpleConversation.LastConversationDate__c = Date.newinstance(lastConversationDateTime.year(), lastConversationDateTime.month(), lastConversationDateTime.day());
                    }
	}

    private void lastConversationDateNull(LastConversationDateWrapperList conversationDateWrapper){
	List<SimpleConversation__c> simpleConversationList = conversationDateWrapper.simpleConversationList;
	Set<Id> accountIdSet = conversationDateWrapper.accountIdSet;
	Set<Id> agentIdSet = conversationDateWrapper.agentIdSet;
	List<SimpleConversation__c> simpleConversationToBeUpdated = conversationDateWrapper.simpleConversationToBeUpdated;
        LastConversationDateWrapperList varWrap = new LastConversationDateWrapperList();
        varWrap.simpleConversationList = simpleConversationList;
        varWrap.accountIdSet = accountIdSet;
        varWrap.agentIdSet = agentIdSet;
        varWrap.simpleConversationToBeUpdated = simpleConversationToBeUpdated;
        apWrap.addSimpleConvToBeUpdated(varWrap);
	}

    private class LastConversationDateWrapperList{
		private List<SimpleConversation__c> simpleConversationList;
		private Set<Id> accountIdSet;
		private Set<Id> agentIdSet;
		private List<SimpleConversation__c> simpleConversationToBeUpdated;
	}

     /**
    * @description method to prevent user from deleting SimpleConversation records
    * @param simpleConversationList
    */
    public void preventSimpleConversationDelete(List<SimpleConversation__c> simpleConversationList) {
        for(SimpleConversation__c deleteSimpleConversation : simpleConversationList) {
            deleteSimpleConversation.addError(Label.CL_SimpleConversationPreventDeleteMsg);
        }
    }

    /**
    * @description Call GNC API for update Host and Appointment change
    * @param simpleConversationList
    * @param simpleConversationOldMap
    */

    public void processSimpleConversationOnAfterUpdate(List<SimpleConversation__c> simpleConversationList, Map<Id, SimpleConversation__c> simpleConversationOldMap) {
        try {

            //Call GNC API for update Host and Appointment change
            SimpleConversation__c simpleConversation = simpleConversationList[0];
            UTIL_GoodNeighborConnect.VirtualMeetingAttributes attr = new UTIL_GoodNeighborConnect.VirtualMeetingAttributes();
            List<Virtual_Meeting__c> virtMeetingRecordList = [SELECT Id,Status__c,Assigned_To__c,start_time__c,end_time__c FROM Virtual_Meeting__C WHERE
                                                              Simple_Conversation__c =: simpleConversation.id WITH SECURITY_ENFORCED ORDER BY Createddate DESC LIMIT 1];
            if(virtMeetingRecordList != null && !virtMeetingRecordList.isEmpty()){
                if(simpleConversation.ConductedBy__c != virtMeetingRecordList[0].Assigned_To__c) {

                    attr.meetingHost = simpleConversation.ConductedBy__c;
                    attr.virtualMeetingId = virtMeetingRecordList[0].Id;
                    UTIL_GoodNeighborConnect.updateVirtualMeetingHost(attr,simpleConversation.id);
                }
                if((simpleConversation.Status__c != 'Completed') && (simpleConversation.AppointmentStartDateTime__c != virtMeetingRecordList[0].start_time__c || simpleConversation.AppointmentEndDateTime__c !=
                                                                     virtMeetingRecordList[0].end_time__c)) {
                       attr.virtualMeetingId = virtMeetingRecordList[0].Id;
                       attr.startDateTime = simpleConversation.AppointmentStartDateTime__c;
                       attr.endDateTime = simpleConversation.AppointmentEndDateTime__c;
                       UTIL_GoodNeighborConnect.rescheduleVirtualMeeting(attr,simpleConversation.id);
                   }
            }
        //Send Outlook Email with updated Date/Time Host if Send To Outlook Flag is true
        appointmentTimeUpdated(simpleConversation, simpleConversationOldMap, simpleConversationList);

        } catch(Exception simpleConvException) {
            UTIL_AgentProxySelection.tagAllErrors(simpleConversationList, simpleConvException.getMessage());
        }
    }

    /**
     * @description Send Outlook Email with updated Date/Time Host if Send To Outlook Flag is true
     * @param simpleConversation
     * @param simpleConversationOldMap
     * @param simpleConversationList
     */
    public void appointmentTimeUpdated(SimpleConversation__c simpleConversation, Map<Id, SimpleConversation__c> simpleConversationOldMap, List<SimpleConversation__c> simpleConversationList){
		if(checkIfAppointmentTimeUpdated(simpleConversation, simpleConversationOldMap) == true || simpleConversation.Status__c.equals('Customer Cancelled')) {
                HLPR_SimpleConversationTrigger.sendCalendarEmail(simpleConversationList);
		}
	}

    private boolean checkIfAppointmentTimeUpdated(SimpleConversation__c simpleConversation, Map<Id, SimpleConversation__c> simpleConversationOldMap) {
        return simpleConversation.IsSendToOutlook__c == true && (simpleConversation.AppointmentStartDateTime__c != simpleConversationOldMap.get(simpleConversation.id).AppointmentStartDateTime__c || simpleConversation.AppointmentEndDateTime__c != simpleConversationOldMap.get(simpleConversation.id).AppointmentEndDateTime__c || simpleConversation.ConductedBy__c != simpleConversationOldMap.get(simpleConversation.id).ConductedBy__c);
    }

    private with sharing class AP_SimpleConversationTriggerWrapper{

        private void fetchServiceAgentList(User loggedInUserInfo, List<User> loggedInUserServicingAgentAssociateIdList){
            if((UTIL_Constants.AGENT_PROFILE_NAME.equals(loggedInUserInfo.Profile.Name) || UTIL_Constants.ATM_PROFILE_NAME.equals(loggedInUserInfo.Profile.Name)) && String.isNotBlank(loggedInUserInfo.Servicing_Agent_Associate_ID__c)) {
                    loggedInUserServicingAgentAssociateIdList = [Select id from User Where UserExternalID__c =: loggedInUserInfo.Servicing_Agent_Associate_ID__c + USER_EXTERNAL_ID_CONCATENATION_SYMBOL  + loggedInUserInfo.Servicing_Agent_Associate_ID__c limit 1];
            }
        }

        private void setErrorOrOwnerId(List<SimpleConversation__c> simpleConversationList, Map<Id, Set<Id>> accountAgentRoleMap, Map<Id, Id> agentProxyMap){
            for(SimpleConversation__c simpleConv: simpleConversationList) {
                if(!String.isNotBlank(simpleConv.Agent__c) || !agentProxyMap.containsKey(simpleConv.Agent__c)) {
                    simpleConv.addError(Label.CL_PROXY_NOT_FOUND);
                } else if(!(accountAgentRoleMap.containsKey(simpleConv.Account__c) && accountAgentRoleMap.get(simpleConv.Account__c).contains(simpleConv.Agent__c))) {
                    simpleConv.addError(Label.CL_AGENT_NOT_FOUND_IN_BOOK_OF_BUSINESS);
                } else {
                    simpleConv.OwnerId = agentProxyMap.get(simpleConv.Agent__c);
                }
            }
        }
        
        private Map<Id, Set<Id>> queryAccountAgentRole(Set<Id> accountIdSet) {
            Map<Id, Set<Id>> accountAgentRoleMap = new Map<Id, Set<Id>>();
            for(AgentRole__c agntRole: [Select Agent__c, Customer__c from AgentRole__c Where Customer__c in: accountIdSet]) {
                if(accountAgentRoleMap.containsKey(agntRole.Customer__c)) {
                    Set<Id> agentSet = (accountAgentRoleMap.get(agntRole.Customer__c));
                    agentSet.add(agntRole.Agent__c);
                    accountAgentRoleMap.put(agntRole.Customer__c, agentSet);
                } else {
                    accountAgentRoleMap.put(agntRole.Customer__c, new Set<Id>{agntRole.Agent__c});
                }
            }
            return accountAgentRoleMap;
        }
        
        private void updateSimpleConversationRescheduleCount(List<SimpleConversation__c> simpleConversationList, Map<Id, SimpleConversation__c> simpleConversationOldMap) {
            for(SimpleConversation__c simpleConversation: simpleConversationList) {
                if(simpleConversationOldMap.get(simpleConversation.id).AppointmentStartDateTime__c != null && simpleConversationOldMap.get(simpleConversation.id).AppointmentStartDateTime__c != simpleConversation.AppointmentStartDateTime__c) {
                    if(simpleConversation.RescheduleCount__c != null) {
                        simpleConversation.RescheduleCount__c = simpleConversation.RescheduleCount__c + 1;
                    } else {
                        simpleConversation.RescheduleCount__c = 1;
                    }
                }
            }
        }
        
        private void addSimpleConvToBeUpdated(LastConversationDateWrapperList wrap){
            List<SimpleConversation__c> simpleConversationList = wrap.simpleConversationList;
            Set<Id> accountIdSet = wrap.accountIdSet;
		    Set<Id> agentIdSet = wrap.agentIdSet;
		    List<SimpleConversation__c> simpleConversationToBeUpdated = wrap.simpleConversationToBeUpdated;

            for(SimpleConversation__c simpleConversation: simpleConversationList) {
                if(simpleConversation.LastConversationDate__c == null) {
                    accountIdSet.add(simpleConversation.Account__c);
                    agentIdSet.add(simpleConversation.Agent__c);
                    simpleConversationToBeUpdated.add(simpleConversation);
                }
            }
        }
    }
}