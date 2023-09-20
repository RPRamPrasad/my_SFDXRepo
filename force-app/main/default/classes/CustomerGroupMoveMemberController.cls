/**
  * @name CustomerGroupMoveMemberController
  * @author Poseidon
  * @createdDate 10/30/2018
  * @description Controller to manage moving members between households.
  */
  public with sharing class CustomerGroupMoveMemberController {

    private static final String CLASS_NAME = 'CustomerGroupMoveMemberController';
    private static final String DOB_STRING =' | DOB: ';
    private static final String GROUP_ID_PARAM = 'groupId';
    private static final String ACCOUNT_ID_PARAM = 'accountId';
    private static final string GROUP_CATEGORY = 'Primary';
    private static final string HOUSEHOLD = 'Household';
    private static final String UNDERSCORE = '_';
    private static final String TILDE = '~';
    private static final String PAYLOAD_REQUESTER_REF_TYPE = 'Enterprise ID - Associate';
    private static final String PAYLOAD_CALLING_AREA = 'CROM CAAM';
    private static final String PLATFORM_NAME = 'SALESFORCE';
    private static final String DOT = '.';
    private static final String EXTENSION = 'COM';
    private static String payloadCallingApp = PLATFORM_NAME + DOT + EXTENSION;
    public static final Integer EXCEPTION_STACKTRACE_SIZE_LIMIT = 32000;

    // Create the select options for the two select lists on the page
    /**
     * @description Fetch Group Members
     * @param accountId
     * @param customerGroupId
     * @return List<GroupMember>
     */
    @AuraEnabled
    public static List<GroupMember> fetchGroupMembers(String accountId,String customerGroupId) {


        if(String.isNotBlank(customerGroupId)) {
            UTIL_ParameterValidator_SalesforceId.isValidSalesforceId(GROUP_ID_PARAM, customerGroupId, CustomerGroup__c.class);
        }

        if(String.isBlank(customerGroupId)){
            UTIL_ParameterValidator_SalesforceId.isValidSalesforceId(ACCOUNT_ID_PARAM, accountId, Account.class);
            List<CustomerGroupMember__c> groupIds = getCustomerGroupIdFromAccountId(accountId);
            customerGroupId = groupIds.get(0).Group__c;
        }

        List<CustomerGroupMember__c> initialGMListToDisplay = new List<CustomerGroupMember__c>();
        initialGMListToDisplay.addAll(fetchGroupMemberList(customerGroupId));
        return buildGroupMembers(initialGMListToDisplay);
    }

    /**
     * @description Fetch Group Members For Searched Customer
     * @param accountId
     * @param agentId
     * @return List<GroupMember>
     */
    @AuraEnabled
    public static List<GroupMember> fetchGroupMembersForSearchedCustomer(String accountId, String agentId) {

        List<CustomerGroupMember__c> groupMemListWithGroup = new List<CustomerGroupMember__c>();
        List<CustomerGroupMember__c> groupMemList = new List<CustomerGroupMember__c>();

        if(!String.isBlank(agentId)){
            groupMemListWithGroup = Security.stripInaccessible(AccessType.READABLE, [SELECT Id, Group__c FROM CustomerGroupMember__c
                                                                                     where group__r.Agent__C = :agentId and Customer__c = :accountId LIMIT 1]).getRecords();
        }
        if(!groupMemListWithGroup.isEmpty()){
            groupMemList = Security.stripInaccessible(AccessType.READABLE, [SELECT Id, Group__c, Customer__r.Name, Customer__r.Id,Customer__r.PersonBirthdate, Customer__r.ClientIdentifier__c, Group__r.SFGroupIdentifier__c,Group__r.Id, Group__r.Agent__r.Associate_ID__c,Group__r.Agent__r.UserExternalID__c FROM CustomerGroupMember__c
                                                                            where group__c = :groupMemListWithGroup.get(0).Group__c ]).getRecords();
        }
        return buildGroupMembers(groupMemList);
    }

    /**
     * @description Build New Member Payload
     * @param newGroupMemberInfo
     * @return String
     */
    @AuraEnabled
    public static String buildNewMemberPayload(String newGroupMemberInfo ) {
        List<GroupMember> groupMemberList = (List<GroupMember>) JSON.deserialize(newGroupMemberInfo, List<GroupMember>.class);
        GroupMemberInfo groupMemberInfo = (GroupMemberInfo) JSON.deserialize(groupMemberList.get(0).GroupMemberInfo, GroupMemberInfo.class);
        String groupId = groupMemberInfo.SFDCGroupId;

        GroupMemberInfo customerMemberInfo = new GroupMemberInfo();
        List<UTIL_CustomerGroupMoveMemberRequest.CustomerGroupModification> groupListToModify = new List<UTIL_CustomerGroupMoveMemberRequest.CustomerGroupModification>();
        UTIL_CustomerGroupMoveMemberRequest.CustomerGroupModification groupToModify;

        if(!groupMemberList.isEmpty()){

            for(Integer i = 0; i < groupMemberList.size(); i++) {
                customerMemberInfo = (GroupMemberInfo) JSON.deserialize(groupMemberList.get(i).GroupMemberInfo, GroupMemberInfo.class);
                groupToModify = new UTIL_CustomerGroupMoveMemberRequest.CustomerGroupModification();
                groupToModify.customer = customerMemberInfo.clientId;
                groupToModify.oldGroup = customerMemberInfo.SFGroupId;
                groupToModify.newGroup = null;
                groupListToModify.add(groupToModify);
            }
        }

      // Build JSON Payload here...
        String jsonRequest = buidJSONPayload(groupListToModify, groupId);
        return jsonRequest;
    }

private static String buidJSONPayload(List<UTIL_CustomerGroupMoveMemberRequest.CustomerGroupModification> groupListToModify, String sfdcGroupId){
        UTIL_CustomerGroupMoveMemberRequest request = new UTIL_CustomerGroupMoveMemberRequest();
        UTIL_CustomerGroupMoveMemberRequest.CustomerGroupMemberMeta meta = new UTIL_CustomerGroupMoveMemberRequest.CustomerGroupMemberMeta();
        meta.callingApplication = payLoadCallingApp;
        meta.callingArea = PAYLOAD_CALLING_AREA;
        UTIL_CustomerGroupMoveMemberRequest.Requester agentRequester = new UTIL_CustomerGroupMoveMemberRequest.Requester();
        agentRequester.requesterReferenceId = UTIL_CurrentUser.retrieveCurrentUser().Associate_ID__c;
        agentRequester.requesterReferenceType = PAYLOAD_REQUESTER_REF_TYPE;
        meta.requester = agentRequester;
        UTIL_CustomerGroupMoveMemberRequest.CustomerGroupPayloadData data = new UTIL_CustomerGroupMoveMemberRequest.CustomerGroupPayloadData();
        data.agent = getServicingAgentAssociateID(sfdcGroupId);
        data.groups = groupListToModify;
        request.meta = meta;
        request.data = data;
        String jsonRequest = JSON.serialize(request);
        System.debug(LoggingLevel.INFO, 'Request ->> ' + jsonRequest);
        return jsonRequest;
    }

    /**
     * @description Build Existing Member Payload
     * @param diffMemberList
     * @param initialGroupId
     * @param initialSearchedGroupId
     * @return String
     */
    @AuraEnabled
    public static String buildExistingMemberPayload(String diffMemberList,String initialGroupId,String initialSearchedGroupId){

        List<GroupMember> groupMemberList = (List<GroupMember>) JSON.deserialize(diffMemberList, List<GroupMember>.class);
        GroupMemberInfo groupMemberInfo = (GroupMemberInfo) JSON.deserialize(groupMemberList.get(0).GroupMemberInfo, GroupMemberInfo.class);
        String groupId = groupMemberInfo.SFDCGroupId;

        GroupMemberInfo customerMemberInfo = new GroupMemberInfo();

        List<UTIL_CustomerGroupMoveMemberRequest.CustomerGroupModification> groupListToModify = new List<UTIL_CustomerGroupMoveMemberRequest.CustomerGroupModification>();
        UTIL_CustomerGroupMoveMemberRequest.CustomerGroupModification groupToModify;

        if(!groupMemberList.isEmpty()){

            for(Integer i = 0; i < groupMemberList.size(); i++) {
                customerMemberInfo = (GroupMemberInfo) JSON.deserialize(groupMemberList.get(i).GroupMemberInfo, GroupMemberInfo.class);
                groupToModify = new UTIL_CustomerGroupMoveMemberRequest.CustomerGroupModification();
                if(initialGroupId.equals(customerMemberInfo.SFGroupId)){
                    groupToModify.oldGroup = customerMemberInfo.SFGroupId;
                	groupToModify.newGroup = initialSearchedGroupId;

                }
                else{
                    groupToModify.oldGroup = customerMemberInfo.SFGroupId;
                	groupToModify.newGroup = initialGroupId;
                }

                groupToModify.customer = customerMemberInfo.clientId;

                groupListToModify.add(groupToModify);
            }
        }

        // Build JSON Payload here...
        String jsonRequest = buidJSONPayload(groupListToModify, groupId);
        return jsonRequest;
    }

    private static List<CustomerGroupMember__c> getCustomerGroupIdFromAccountId(String accountId) {
        List<CustomerGroupMember__c> groupMemList;
        groupMemList = Security.stripInaccessible(AccessType.READABLE, [SELECT Group__c FROM CustomerGroupMember__c WHERE Customer__c = :accountId LIMIT 100]).getRecords();
        return groupMemList;
    }

    private static String getServicingAgentAssociateID(String sfdcGroupId) {
        List<CustomerGroup__c> customerGroupList;
        customerGroupList = Security.stripInaccessible(AccessType.READABLE, [SELECT Id, Agent__r.Servicing_Agent_Associate_ID__c FROM CustomerGroup__c WHERE Id = :sfdcGroupId LIMIT 1]).getRecords();
        return customerGroupList.get(0).Agent__r.Servicing_Agent_Associate_ID__c;

    }

    private static List<CustomerGroupMember__c> fetchGroupMemberList(String groupId) {
        List<CustomerGroupMember__c> groupMemList;
        groupMemList = Security.stripInaccessible(AccessType.READABLE, [SELECT Id, Customer__r.Name, Customer__r.Id, Customer__r.PersonBirthdate, Customer__r.ClientIdentifier__c, Group__r.SFGroupIdentifier__c,
                                                         Group__r.Id, Group__r.Agent__r.Associate_ID__c, Group__r.Agent__r.UserExternalID__c, Group__r.Agent__c FROM CustomerGroupMember__c
                                                         WHERE Group__c = :groupId LIMIT 100]).getRecords();

		return groupMemList;
    }

    private static List<GroupMember> buildGroupMembers(List <CustomerGroupMember__c> groupMemberList) {

        List<GroupMember> groupMembers=new List<GroupMember>();

        if(!groupMemberList.isEmpty() && groupMemberList!=null){
            for(CustomerGroupMember__c customerGroupMember:groupMemberList){
                GroupMember groupMember = new GroupMember();
                if (customerGroupMember.Customer__r.PersonBirthdate!=null ){
                    groupMember.label=customerGroupMember.Customer__r.Name +DOB_STRING+String.valueOf(customerGroupMember.Customer__r.PersonBirthdate.format());
                }else{
                    groupMember.label=customerGroupMember.Customer__r.Name;
                }
                GroupMemberInfo groupMemberInfo=new GroupMemberInfo();
                groupMemberInfo.accountId=customerGroupMember.Customer__r.Id;
                groupMemberInfo.SFDCGroupId=customerGroupMember.Group__r.Id;
                groupMemberInfo.label=groupMember.label;
                groupMemberInfo.SFGroupId = customerGroupMember.Group__r.SFGroupIdentifier__c;
                groupMemberInfo.clientId = customerGroupMember.Customer__r.ClientIdentifier__c;
                groupMember.agentId = customerGroupMember.Group__r.Agent__c;
                groupMember.groupMemberInfo=JSON.serialize(groupMemberInfo);
                groupMembers.add(groupMember);
            }
        }

        return groupMembers;
    }

    /**
     * @description Update Group Members
     * @param jsonMemberList
     * @return String
     */
    @AuraEnabled
    public static String updateGroupMembers(String jsonMemberList){
        UTIL_CustomerGroupMoveMemberResponse sfdcMoveMembers = UTIL_CustomerGroupMoveMemberResponse.parse(jsonMemberList);
        // Get servicing agent associate id
        String servicingAgentAssociateId = sfdcMoveMembers.servicingAgentAssocId;
        List<CustomerGroup__c> customerGroupList = new List<CustomerGroup__c>();
        List<CustomerGroupMember__c> sfdcMemberList = new List<CustomerGroupMember__c>();
        String externalId = servicingAgentAssociateId.trim() + UNDERSCORE + servicingAgentAssociateId.trim();
        List<User> agentUserList = Security.stripInaccessible(AccessType.READABLE, [SELECT Id from User where UserExternalID__c =: externalId]).getRecords();
        User agentUser = agentUserList[0];
        Set<String> householdIdSet = new Set<String>();

        for(Integer i = 0; i < sfdcMoveMembers.data.groupings.size(); i++) {
            String sfdcGroupId = sfdcMoveMembers.data.groupings[i].groupId;
            String customerId = sfdcMoveMembers.data.groupings[i].customer;
            // Check if household ids are in set for group creation
            if (!householdIdSet.contains(sfdcGroupId)) {
                // If not in set, create the new group
                householdIdSet.add(sfdcGroupId);
                customerGroupList.add(createNewGroup(sfdcGroupId, agentUser.Id));
            }

            // Create new group members and set group id and client id to group member object
            sfdcMemberList.add(createNewGroupMember(sfdcGroupId, customerId));
        }

        // Upsert the updated lists to SFDC
        if (null != customerGroupList && !customerGroupList.isEmpty()) {
            Schema.SObjectField idField = CustomerGroup__c.Fields.SFGroupIdentifier__c;
            Database.Upsert( Security.stripInaccessible(AccessType.UPSERTABLE, customerGroupList).getRecords(), idField);
        }
        if (null != sfdcMemberList && !sfdcMemberList.isEmpty()) {
            Schema.SObjectField idField = CustomerGroupMember__c.Fields.GroupMemberId__c;
            Database.Upsert (Security.stripInaccessible(AccessType.UPSERTABLE, sfdcMemberList).getRecords(), idField);

        }

        return 'SUCCESS';
    }

    /**
     * @description Log HH Moves Exception
     * @param className
     * @param method
     * @param exceptionMessage
     */
    @AuraEnabled
    public static void logHHMovesException(String className, String method, String exceptionMessage){
       ExceptionLog__c exceptionLog = LoggingService.buildExceptionObject(className, method, exceptionMessage, true, LoggingLevel.ERROR);
       exceptionLog.Stack_Trace__c = exceptionMessage.left(EXCEPTION_STACKTRACE_SIZE_LIMIT);
       LoggingService.logException(exceptionLog);

    }

    private static CustomerGroup__c createNewGroup(String householdId, Id agentId) {
        CustomerGroup__c newCustomerGroup = new CustomerGroup__c();
        newCustomerGroup.Name = HOUSEHOLD;
        newCustomerGroup.Agent__c = agentId;
        newCustomerGroup.SFGroupIdentifier__c = householdId;
        newCustomerGroup.GroupCategory__c = GROUP_CATEGORY;
        return newCustomerGroup;
    }

    private static CustomerGroupMember__c createNewGroupMember(String sfGroupId, String customerId) {
        CustomerGroupMember__c customerGroupMember = new CustomerGroupMember__c();
        customerGroupMember.Group__r = new CustomerGroup__c(SFGroupIdentifier__c = sfGroupId);
        customerGroupMember.GroupMemberId__c = sfGroupId + TILDE + customerId;
        customerGroupMember.Customer__r = new Account(ClientIdentifier__c = customerId);
        return customerGroupMember;
    }

    /**
     * @description Group Member
     */
    public with sharing class GroupMember{

        /**
         * @description groupMemberInfo getters and setters
         */
        @AuraEnabled
        public String groupMemberInfo{get; set;}

        /**
         * @description label getters and setters
         */
        @AuraEnabled
        public String label {get; set;}

        /**
         * @description agentId getters and setters
         */
        @AuraEnabled
        public String agentId {get; set;}
    }

    /**
     * @description Group Member Info
    */
    public with sharing class GroupMemberInfo{

        /**
         * @description accountId getters and setters
         */
        @AuraEnabled
        public String accountId {get; set;}

        /**
         * @description SFDCGroupId getters and setters
         */
        @AuraEnabled
        public String SFDCGroupId {get; set;}

        /**
         * @description label getters and setters
         */
        @AuraEnabled
        public String label {get; set;}

        /**
         * @description SFGroupId getters and setters
         */
        @AuraEnabled
        public String SFGroupId {get; set;}

        /**
         * @description clientId getters and setters
         */
        @AuraEnabled
        public String clientId {get; set;}
    }
}
