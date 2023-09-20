/**
* @Name UTIL_OrchestrationJSONtoGroupDetails
* @Author Loco Motivated
* @description This is a utility class that implements Mapping for Group and GroupMember fields from JSON
*/
public without sharing class UTIL_OrchestrationJSONtoGroupDetails {

    private static final String AGENT_ROLE='Agent Role';
    private static final string PRIMARY='Primary';
    private static final string HOUSEHOLD='Household';

  /**
    * @method jsonGroupDetailsConverter: For Mapping Group and GroupMember field values from Json to List of Group and GroupMember records
    * @description JSON Group Details Converter
    * @param parseAgentJSON
    * @return HLPR_GroupAndGroupMemberWrapper
    */
    public static HLPR_GroupAndGroupMemberWrapper jsonGroupDetailsConverter(AP_StageOrchestrationJSONParser parseAgentJSON) {

        HLPR_GroupAndGroupMemberWrapper groupDetails =new HLPR_GroupAndGroupMemberWrapper();
        List<AP_StageOrchestrationJSONParser.OrchestrationDataValues> listOfGroupDetailDataToSync=new List<AP_StageOrchestrationJSONParser.OrchestrationDataValues>();

        for(AP_StageOrchestrationJSONParser.OrchestrationDataName orchDataName : parseAgentJSON.orchestrationInfo.orchestrationDataName){
            if(AGENT_ROLE.equalsIgnoreCase(orchDataName.orchestrationNameDetail.dataName)){
                listOfGroupDetailDataToSync.add(orchDataName.orchestrationNameDetail.orchestrationDataValues);
            }
        }

        if(!listOfGroupDetailDataToSync.isEmpty()){
            groupDetails=getListOfGroupDetails( listOfGroupDetailDataToSync);
        }
        return groupDetails;
    }

  /**
    * @method getListOfGroupDetails: For Mapping Group and GroupMember field values from Json to List of Group and GroupMember records
    * @description Get List Of Group Details
    * @param listOfGroupDetailDataToSync
    * @return HLPR_GroupAndGroupMemberWrapper
    */
    public static HLPR_GroupAndGroupMemberWrapper getListOfGroupDetails(List<AP_StageOrchestrationJSONParser.OrchestrationDataValues> listOfGroupDetailDataToSync){

        HLPR_GroupAndGroupMemberWrapper groupDetails = new HLPR_GroupAndGroupMemberWrapper();
        groupDetails.groupList=new List<CustomerGroup__c>();
        groupDetails.groupMemberList=new List<CustomerGroupMember__c>();
        set<string> jsonHouseholdIdSet=new set<String>();
        set<string> jsonHouseholdIdentifierSet=new set<String>(); 
        
        for(AP_StageOrchestrationJSONParser.OrchestrationDataValues jsonARValues:listOfGroupDetailDataToSync){
            if(!string.isEmpty(jsonARValues.HouseholdGroupId)){
              UTIL_OrchestrationJSONtoGroupDetails.GroupWrapper grpWrap = new UTIL_OrchestrationJSONtoGroupDetails.GroupWrapper();
              grpWrap.jsonARValues = jsonARValues;
              grpWrap.groupDetails = groupDetails;
              grpWrap.jsonHouseholdIdSet = jsonHouseholdIdSet;
              grpWrap.jsonHouseholdIdentifierSet = jsonHouseholdIdentifierSet;
            	createGroupWrapperDetails(grpWrap);
            }
        }

        //returns all the valid Group Details list
        return groupDetails;
    }
 
    /**
     * @description Group Wrapper
    */
    class GroupWrapper{
      AP_StageOrchestrationJSONParser.OrchestrationDataValues jsonARValues;
      HLPR_GroupAndGroupMemberWrapper groupDetails;
      set<string> jsonHouseholdIdSet;
      set<string> jsonHouseholdIdentifierSet;
    }

  /**
    * @method createGroupRecord: For Mapping Group fields values from Json to CustomerGroup__c record
    * @description Create Group Wrapper Details
    * @param grpWrap
    */    
    public static void createGroupWrapperDetails(GroupWrapper grpWrap){

      AP_StageOrchestrationJSONParser.OrchestrationDataValues jsonARValues = grpWrap.jsonARValues;
      HLPR_GroupAndGroupMemberWrapper groupDetails = grpWrap.groupDetails;
      set<string> jsonHouseholdIdSet = grpWrap.jsonHouseholdIdSet;
      set<string> jsonHouseholdIdentifierSet = grpWrap.jsonHouseholdIdentifierSet;

    	if(!jsonHouseholdIdSet.contains(jsonARValues.HouseholdGroupId)){
    		jsonHouseholdIdSet.add(jsonARValues.HouseholdGroupId);
    		 groupDetails.groupList.add(createGroupRecord(jsonARValues.HouseholdGroupId,jsonARValues.agent));
    	}
    	if(!jsonHouseholdIdSet.contains(jsonARValues.houseHoldGroupId+'~'+jsonARValues.customer)){
    		jsonHouseholdIdentifierSet.add(jsonARValues.houseHoldGroupId+'~'+jsonARValues.customer);
    		groupDetails.groupMemberList.add(createGroupMemberRecord(jsonARValues.houseHoldGroupId,jsonARValues.customer));
    	}
    }

  /**
    * @method createGroupRecord: For Mapping Group fields values from Json to CustomerGroup__c record
    * @description Create Group Record
    * @param householdGroupId
    * @param agentassocId
    * @return CustomerGroup__c
    */    
    public static CustomerGroup__c createGroupRecord(String householdGroupId,string agentassocId){
        CustomerGroup__c groupRec= new CustomerGroup__c();
        groupRec.Name=HOUSEHOLD;
        groupRec.Agent__r=new User(UserExternalID__c=agentassocId.trim()+UTIL_StageOrchestrationConstants.UNDERSCORE+agentassocId.trim());
        groupRec.SFGroupIdentifier__c=householdGroupId;
        groupRec.GroupCategory__c=PRIMARY;
        return groupRec;
    }

  /**
    * @method createGroupMemberRecord: For Mapping GroupMember fields values from Json to CustomerGroupMember__c record
    * @description Create Group Member Record
    * @param householdGroupId
    * @param clientId
    * @return CustomerGroupMember__c record
    */    
    public static CustomerGroupMember__c createGroupMemberRecord(String householdGroupId,string clientId){
        CustomerGroupMember__c groupMemberRec= new CustomerGroupMember__c();
        groupMemberRec.Group__r=new CustomerGroup__c(SFGroupIdentifier__c=householdGroupId);
        groupMemberRec.GroupMemberId__c= householdGroupId+UTIL_Constants.TILT_SYMBOL+ clientId;
        groupMemberRec.Customer__r=new account(clientidentifier__c=clientId);
        return groupMemberRec;
    }
    
    /**
     * @description HLPR Group And Group Member Wrapper
     */
    public with sharing class HLPR_GroupAndGroupMemberWrapper {

        /**
         * @description getters and setters of the member variable groupList
         * @return List<CustomerGroup__c>
         */
        public List<CustomerGroup__c> groupList{get;set;}

        /**
         * @description getters and setters of the member variable groupMemberList
         * @return List<CustomerGroupMember__c>
         */
        public List<CustomerGroupMember__c> groupMemberList{get;set;}        
    }
}