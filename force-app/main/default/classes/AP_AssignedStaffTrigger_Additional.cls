/**
  * @name AP_AssignedStaffTrigger_Additional 
  * @author Choo Choo
  * @owner Stark
  * @createdDate 01/07/2021
  * @description This Additional class is used by AP_AssignedStaffTrigger
  */
  
  public with sharing class AP_AssignedStaffTrigger_Additional {

    private static final String CLASS_NAME = 'AP_AssignedStaffTrigger_Additional';
    private static final String TILDE = '~';

    /**
	* @method validateAssignedStaffUpdate: This method will validate the AssignedStaff__c Record/records to be updated
	* @description validateAssignedStaffUpdate
    * @param newAssignedStaffList
    * @param oldAssignedStaffMap
    */
    public static void validateAssignedStaffUpdate(List<AssignedStaff__c> newAssignedStaffList, Map<Id, AssignedStaff__c> oldAssignedStaffMap){
		String methodName = 'validateAssignedStaffUpdate';
    	try {
	    	set<Id> agentUserList = new set<Id>();
	        set<Id> userList = new set<Id>();
	        set<Id> accountList = new set<Id>();
			
		    User loggedInUser= (User)Security.stripInaccessible(AccessType.READABLE, [Select Id, Name, Profile.Name From User Where Id = :Userinfo.getUserid() LIMIT 1]).getRecords().get(0);            
	        //Adding Agent's SFDC Id to Set of Id's
	        for(AssignedStaff__c assignedStaffRec : newAssignedStaffList){
	            agentUserList.add(assignedStaffRec.Agent__c);
	            userList.add(assignedStaffRec.Staff__c);
	            accountList.add(assignedStaffRec.Customer__c);
	        }        
	        userList.addAll(agentUserList);
	        Map<Id, User> userMapById = populateUserMapForValidation(userList);
	        Map<Id, Account> accountMapById = populateAccountMapForValidation(accountList);
	    	for(AssignedStaff__c newAssignStaff: newAssignedStaffList){
	    		if(newAssignStaff.Agent__c != oldAssignedStaffMap.get(newAssignStaff.Id).Agent__c){
	    			newAssignStaff.addError(Label.CL_AS_AgentChange);
	    		}
	    		else if(!loggedInUser.Profile.Name.equalsIgnoreCase(Label.CL_APIUserProfile) && validateAgentHasAgentRole(newAssignStaff, accountMapById)){
					newAssignStaff.addError(Label.CL_AS_CustomerException);
				}
	    		else if(validateStaffIsRelatedToAgent(newAssignStaff, userMapById)){
					newAssignStaff.addError(Label.CL_AS_StaffException);
				}
				else {
					newAssignStaff.AssignedStaffIdentifier__c = retrieveUpdatedAssignedStaffIdentifier(newAssignStaff, accountMapById, userMapById);
				}
	    	}
    	}
    	catch(exception ex){
            LoggingService.logHandledException(ex, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
            UTIL_AgentProxySelection.tagAllErrors(newAssignedStaffList, ex.getMessage());
        }
	}

	/**
	* @description populateUserMapForValidation
    * @param userList
    * @return Map<Id, User>
    */
	public static Map<Id, User> populateUserMapForValidation(set<Id> userList){
    	Map<Id, User> userMapById = new Map<Id, User>();
    	for(User agtStaffUser : [Select Id, Associate_Id__c, Servicing_Agent_Associate_Id__c, Profile.Name From User Where Id in :userList]){
    		userMapById.put(agtStaffUser.Id, agtStaffUser);
    	}
    	return userMapById;
	}
	
	/**
	* @description populateAccountMapForValidation
    * @param accountList
    * @return Map<Id, Account>
    */
	public static Map<Id, Account> populateAccountMapForValidation(set<Id> accountList){
    	Map<Id, Account> accountMapById = new Map<Id, Account>();    	
    	for(Account acc: [Select id, clientIdentifier__c, (Select id, Agent__c from Agent_Roles__r) From Account where Id in :accountList]){
    		accountMapById.put(acc.Id, acc);
    	}
    	return accountMapById;
	}
	
	/**
	* @description retrieveUpdatedAssignedStaffIdentifierAdditional
	* @param assignStaffToUpdate
	* @param userMapById
	* @param assignStaffExtId
	* @param strAssignStaffExtId
    * @return String
    */
	public static String retrieveUpdatedAssignedStaffIdentifierAdditional(AssignedStaff__c assignStaffToUpdate, Map<Id, User> userMapById, String assignStaffExtId){
		String strAssignStaffExtId =assignStaffExtId;
		if(String.isNotEmpty(assignStaffExtId) && !assignStaffExtId.endsWith(TILDE)){
    		strAssignStaffExtId += TILDE;
    	}
    	if(assignStaffToUpdate.Staff__c != null && String.isNotEmpty(userMapById.get(assignStaffToUpdate.Staff__c).Associate_id__c)){
    		strAssignStaffExtId += userMapById.get(assignStaffToUpdate.Staff__c).Associate_id__c;
    	}
		return  strAssignStaffExtId ;
    }
    
    /**
	* @description validateAgentHasAgentRole
	* @param assignStaffToUpdate
	* @param accountMapById
    * @return Boolean
    */
	public static Boolean validateAgentHasAgentRole(AssignedStaff__c assignStaffToUpdate, Map<Id, Account> accountMapById){
		Boolean isRecordError = true;
		if(assignStaffToUpdate.customer__c!=null && assignStaffToUpdate.Agent__c!=null 
				&&  accountMapById.containsKey(assignStaffToUpdate.customer__c)){
			for(AgentRole__c agentRole: accountMapById.get(assignStaffToUpdate.customer__c).Agent_Roles__r){
				if(agentRole.Agent__c == assignStaffToUpdate.Agent__c){
					isRecordError = false;
					break;
				}
			}
		}
    	return isRecordError;    	
    }
    
    /**
	* @description validateStaffIsRelatedToAgent
	* @param assignStaffToUpdate
	* @param userMapById
    * @return Boolean
    */
    public static Boolean validateStaffIsRelatedToAgent(AssignedStaff__c assignStaffToUpdate, Map<Id, User> userMapById){
		Boolean isRecordError = true;
		if(assignStaffToUpdate.Agent__c!=null && assignStaffToUpdate.Staff__c!=null){
			if(userMapById.get(assignStaffToUpdate.Staff__c).Profile.Name.equalsIgnoreCase(Label.CL_Agent_Profile) 
					&& assignStaffToUpdate.Agent__c ==  assignStaffToUpdate.Staff__c){
				isRecordError = false;
			}
			else if(userMapById.get(assignStaffToUpdate.Staff__c).Profile.Name.equalsIgnoreCase(Label.CL_ATM_Profile) 
					&& userMapById.get(assignStaffToUpdate.Staff__c).Servicing_Agent_Associate_Id__c.equalsIgnoreCase(userMapById.get(assignStaffToUpdate.Agent__c).Associate_Id__c)){
				isRecordError = false;
			}
		}
		return isRecordError;
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
		
		assignStaffExtId = retrieveUpdatedAssignedStaffIdentifierAdditional(assignStaffToUpdate, userMapById, assignStaffExtId);
		return assignStaffExtId;
	}

}
