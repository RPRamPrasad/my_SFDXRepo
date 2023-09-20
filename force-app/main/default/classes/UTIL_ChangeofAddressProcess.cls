/**  
@Author Loco Motivated
@Name UTIL_ChangeofAddressProcess
@CreateDate 09/14/2017 
@description This class creates Case and Tasks for Change of Address on a particular account by CCC, Agent and ATM
@Version 1.0
*/
public without sharing class UTIL_ChangeofAddressProcess { 
    
    private static final String CLASS_NAME = 'UTIL_ChangeofAddressProcess';
    private static final String CASE_AND_TASK_ON_ADDRESS_CHANGE_METHOD_NAME = 'assigncaseAndTaskForAddressChange';
    private static final String SUB_USER_TYPE_AGENT = 'Agent';
    private static final String SUB_USER_TYPE_PSO = 'PSO';
    private static final String SUB_USER_TYPE_SFO = 'SFO';
    
    //Task creation Constant
    public static final String COA_APP_CODE = 'SFDC Change of Address';
    public static final String TASK_RECORD_TYPE = 'Task';
    public static final String ACTIVITY_TASK_TYPE_SERVICE = 'Service';
    
    //Case Constants
    public static final String CASE_STATUS = 'New';
    public static final String CASE_PRIORITY = 'Low';
    public static final String CASE_TYPE = 'Account Change';
    public static final String CASE_REASON ='Change of Address';
   
    /**
    * @method assignCaseAndTaskForAddressChange: Method for Case and Task creation on Address Change
    * @description Creates COA case for customer for all Agents with Customer relationship
    * @param customerId
    * @param changeDescription
    */
    @Future
    public static void assignCaseAndTaskForAddressChange(Id customerId, String changeDescription) {
        try {
            Account currentAccountForChangeOfAddress = [
            		SELECT Id, PersonContactId, (
        				SELECT Agent__c,  Agent__r.Servicing_Agent_Associate_ID__c
        				FROM Agent_Roles__r 
                		WHERE RelationshipNature__c =: System.Label.CL_CUSTOMER_RELATION_SHIP_NATURE
                        AND Agent__r.SubUserType__c in (:SUB_USER_TYPE_AGENT, :SUB_USER_TYPE_PSO, :SUB_USER_TYPE_SFO)
                    ) 
                    FROM Account 
                    WHERE Id =: customerId WITH SECURITY_ENFORCED LIMIT 1];
                                                        
            List<AgentRole__c> agentRoleList = currentAccountForChangeOfAddress.Agent_Roles__r;
            
            if (agentRoleList!=null && !agentRoleList.isEmpty()) {
                for (AgentRole__c agentrole:agentRoleList) {
                	try{
                    	caseCreationOnAddressChange(currentAccountForChangeOfAddress, changeDescription, agentrole); //creating case record for COA
                    } catch(Exception coaError){
                        coaError.setMessage('Unable to create COA for Account ID:' + customerId + ' with Agent (Agent ID: ' + agentrole.Agent__c + ') ' + coaError.getMessage());
            			LoggingService.logHandledException(coaError,CLASS_NAME, CASE_AND_TASK_ON_ADDRESS_CHANGE_METHOD_NAME , LoggingLevel.ERROR);
                    }
                }
            }
        }
        catch(Exception caseError){
            caseError.setMessage('Account ID: '+customerId+' '+caseError.getMessage());
            LoggingService.logHandledException(caseError,CLASS_NAME, CASE_AND_TASK_ON_ADDRESS_CHANGE_METHOD_NAME , LoggingLevel.ERROR);
        }                                            
     }
    
    /**
    * @method caseCreationOnAddressChange: case Creation for Change of Address
    * @description Created COA Case
    * @param currentAccountForChangeOfAddress
    * @param changeDescription
    * @param agentrole
    * @return Id CaseId
    * 
    */
    private static Id caseCreationOnAddressChange(Account currentAccountForChangeOfAddress, String changeDescription, AgentRole__c agentrole) {
        
        Case changeOfAddressCase = new Case(
            App_Code__c = COA_APP_CODE,
	        AccountId = currentAccountForChangeOfAddress.Id,
	        ContactId = currentAccountForChangeOfAddress.PersonContactId,
	        OwnerId = UTIL_AgentOfficeDetails.getProxyforGivenServicingAgentAssocId(agentrole.Agent__r.Servicing_Agent_Associate_ID__c).id,
	        Priority = CASE_PRIORITY,
	        Status = CASE_STATUS,
	        Subject = System.Label.CL_ADDRESS_CHANGE_SUBJECT,
	        Type = CASE_TYPE,
	        Reason = CASE_REASON,
	        Description = changeDescription
        );
        List<Case> caselist = new List<Case>();
        caselist.add(changeOfAddressCase);
        List<Database.SaveResult> caseSaveResultList = Database.insert(Security.stripInaccessible(AccessType.CREATABLE, caselist, true).getRecords(), true);
        return caseSaveResultList.get(0).getId();
    }
}