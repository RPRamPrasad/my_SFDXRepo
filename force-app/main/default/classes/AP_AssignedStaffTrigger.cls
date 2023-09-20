/**
  * @name AP_AssignedStaffTrigger 
  * @author Choo Choo
  * @owner Stark
  * @createdDate 4/20/2018
  * @description This class updates AssignedStaff__c OwnerId fields to Agent's Proxy User
  */

  public with sharing class AP_AssignedStaffTrigger {
    
    private static final String CLASS_NAME = 'AP_AssignedStaffTrigger';
    private static final String TILDE = '~';
    
  /**
    * @method updateOwnerWithAgentProxy: This method will Set the Owner of input AssignedStaff__c Record/records to the his Agent's Office as Owner
    * @description updateOwnerWithAgentProxy
    * @param assignedStaffList
    */  
    public static void updateOwnerWithAgentProxy(List<AssignedStaff__c> assignedStaffList) {
        String methodName = 'updateOwnerWithAgentProxy';
        try{
			OwnerDetails owner = new OwnerDetails();
            owner = updateOwnerWithAgentProxyHelper(assignedStaffList);
            
            //Getting Map of Agent's SFDC Id and his Proxy User Id
            Map<Id,Id> agentProxyMap = UTIL_AgentOfficeDetails.getAgentProxyMapForGivenAgentIds(owner.agentUserList);
            
            //Populate all Maps required to Validate Assigned Staff
            Map<Id, User> userMapById = AP_AssignedStaffTrigger_Additional.populateUserMapForValidation(owner.userList);
        	Map<Id, Account> accountMapById = AP_AssignedStaffTrigger_Additional.populateAccountMapForValidation(owner.accountList);
            
            for(AssignedStaff__c assignedStaffRec : assignedStaffList){
            	if(!agentProxyMap.containsKey(assignedStaffRec.Agent__c)){
            		assignedStaffRec.addError(Label.CL_Exception_Message);
            	}
            	else if(AP_AssignedStaffTrigger_Additional.validateAgentHasAgentRole(assignedStaffRec, accountMapById)){
            		assignedStaffRec.addError(Label.CL_AS_AgentException);
            	}
            	else if(AP_AssignedStaffTrigger_Additional.validateStaffIsRelatedToAgent(assignedStaffRec, userMapById)){
            		assignedStaffRec.addError(Label.CL_AS_StaffException);
            	}
            	else {
            		assignedStaffRec.OwnerId = agentProxyMap.get(assignedStaffRec.Agent__c);
	            	assignedStaffRec.AssignedStaffIdentifier__c = retrieveUpdatedAssignedStaffIdentifier(assignedStaffRec, accountMapById, userMapById);
            	}
                
            }
        }
        catch(exception ex){
            LoggingService.logHandledException(ex, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
            UTIL_AgentProxySelection.tagAllErrors(assignedStaffList, ex.getMessage());
        }
        
	}
	
	private static OwnerDetails updateOwnerWithAgentProxyHelper(List<AssignedStaff__c> assignedStaffList) {
		    set<Id> agentUserList = new set<Id>();
            set<Id> userList = new set<Id>();
            set<Id> accountList = new set<Id>();
            OwnerDetails ownerWrapper = new OwnerDetails();
            User loggedInUser = UTIL_CurrentUser.retrieveCurrentUser();            
            if((Label.CL_Agent_Profile.equalsIgnoreCase(loggedInUser.Profile.Name) || Label.CL_ATM_Profile.equalsIgnoreCase(loggedInUser.Profile.Name)) && String.isNotBlank(loggedInUser.Servicing_Agent_Associate_ID__c)) {                
                  updateAssignStaffAgentForAgentATM(loggedInUser, assignedStaffList);
			}
                                  
            //Adding Agent's SFDC Id to Set of Id's
            for(AssignedStaff__c assignedStaffRec : assignedStaffList){
                agentUserList.add(assignedStaffRec.Agent__c);
                userList.add(assignedStaffRec.Staff__c);
                accountList.add(assignedStaffRec.Customer__c);
            }
            
            userList.addAll(agentUserList);
        	ownerWrapper.agentUserList = agentUserList;
        	ownerWrapper.userList = userList;
        	ownerWrapper.accountList = accountList;
        	return ownerWrapper;
	}
	/**
    * @description OwnerDetails
    */ 
    public with sharing class OwnerDetails {
        set<Id> agentUserList{get; set;}
        set<Id> userList{get; set;}
        set<Id> accountList{get; set;}
    }
    
    private static void updateAssignStaffAgentForAgentATM(User loggedInUser, List<AssignedStaff__c> assignedStaffList){
    	List<User> agentUserList;
        if(loggedInUser.Associate_Id__c.equalsIgnoreCase(loggedInUser.Servicing_Agent_Associate_ID__c)){
      		agentUserList = new List<User>{loggedInUser};
        }
        else{
			String servicingAgentExtId = loggedInUser.Servicing_Agent_Associate_ID__c + UTIL_CreateCustomerConstants.UNDERSCORE + loggedInUser.Servicing_Agent_Associate_ID__c;         
            if(Schema.SObjectType.User.isAccessible()){
				agentUserList = [Select id from User Where UserExternalId__c = :servicingAgentExtId WITH SECURITY_ENFORCED limit 1];
			}
        }
    	if(!agentUserList.isEmpty() && agentUserList.get(0).id != null){
        	for(AssignedStaff__c assignedStaff: assignedStaffList){
            	assignedStaff.Agent__c = agentUserList.get(0).id;
            }  
        }
    }
    
    /**
    * @method validateAssignedStaffUpdate: This method will validate the AssignedStaff__c Record/records to be updated
    * @description validateAssignedStaffUpdate
    * @param newAssignedStaffList
    * @param oldAssignedStaffMap
    */
    public static void validateAssignedStaffUpdate(List<AssignedStaff__c> newAssignedStaffList, Map<Id, AssignedStaff__c> oldAssignedStaffMap){
        AP_AssignedStaffTrigger_Additional.validateAssignedStaffUpdate(newAssignedStaffList, oldAssignedStaffMap);
    }
    
   private static String retrieveUpdatedAssignedStaffIdentifier(AssignedStaff__c assignStaffToUpdate, Map<Id, Account> accountMapById, Map<Id, User> userMapById){
    	String assignStaffExtId = '';
    	if(assignStaffToUpdate.Customer__c != null && String.isNotEmpty(accountMapById.get(assignStaffToUpdate.Customer__c).clientIdentifier__c)){
    		assignStaffExtId += accountMapById.get(assignStaffToUpdate.Customer__c).clientIdentifier__c;
    	}
    	if(String.isNotEmpty(assignStaffExtId)){
    		assignStaffExtId += TILDE;
    	}
    	if(assignStaffToUpdate.Agent__c != null && String.isNotEmpty(userMapById.get(assignStaffToUpdate.Agent__c).Associate_id__c)){
    		assignStaffExtId += userMapById.get(assignStaffToUpdate.Agent__c).Associate_id__c;
    	}
		
		assignStaffExtId = AP_AssignedStaffTrigger_Additional.retrieveUpdatedAssignedStaffIdentifierAdditional(assignStaffToUpdate, userMapById, assignStaffExtId);
		return assignStaffExtId;
	}
    
}
