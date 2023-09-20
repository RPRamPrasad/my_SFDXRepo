/**
@author Team CustomerView
@owner Team CustomerView
@name UTIL_HouseholdChangeofAddressProcess
@CreateDate 10/10/2022
@modifiedDate 
@description This class creates Case and Tasks for Change of Address on accounts in household by CCC, Agent and ATM
@version 1.0
*/
public with sharing class UTIL_HouseholdChangeofAddressProcess {
    
    private static final String CLASS_NAME = 'UTIL_HouseholdChangeofAddressProcess';
    private static final String CASE_AND_TASK_ON_ADDRESS_CHANGE_METHOD_NAME = 'assignedCasesAndTasksForMembers';
    private static final String SUB_USER_TYPE_AGENT = 'Agent';
    private static final String SUB_USER_TYPE_PSO = 'PSO';
    private static final String SUB_USER_TYPE_SFO = 'SFO';
    
    //Case Constants
    public static final String COA_APP_CODE = 'SFDC Change of Address';
    public static final String CASE_STATUS = 'New';
    public static final String CASE_PRIORITY = 'Low';
    public static final String CASE_TYPE = 'Account Change';
    public static final String CASE_REASON ='Change of Address';

    /**
    * @description This method used to create case and task for members
    * @name : assignedCasesAndTasksForMembers
    * @param sfdcIds : sfdc Ids
    * @param idToDescriptionMap : id to description map
    */
    @Future
    public static void assignedCasesAndTasksForMembers(List<Id> sfdcIds, Map<Id, String> idToDescriptionMap) {
        Map<Id,Account> idToMembersMap = createMapOfIdAndAccount(sfdcIds);
        List<Case> insertCases = new List<Case>();
        OperationWrapper opWrap = new OperationWrapper();
        opWrap.idToMembersMap = idToMembersMap;
        opWrap.idToDescriptionMap = idToDescriptionMap;
        opWrap.insertCases = insertCases;
        for(Id customerId :idToMembersMap.keySet()) {
            opWrap.customerId = customerId;
            insertCases = createCaseForAgentRoles(opWrap);
        }
        if(insertCases != null && !insertCases.isEmpty()){
            List<Database.SaveResult> caseSaveResultList;
            caseSaveResultList = Database.insert(Security.stripInaccessible(AccessType.CREATABLE, insertCases, true).getRecords(), false);
        }

    }

    private static List<Case> createCaseForAgentRoles(OperationWrapper opWrap){
        List<AgentRole__c> agentRoleList = opWrap.idToMembersMap.get(opWrap.customerId).Agent_Roles__r;
        if (agentRoleList != null && !agentRoleList.isEmpty()) {
            for (AgentRole__c agentrole :agentRoleList) {
                try{
                    if(String.isEmpty(opWrap.idToDescriptionMap.get(opWrap.customerId))) {
                        continue;
                    }
                    Case aCase = caseCreationOnAddressChange(opWrap.idToMembersMap.get(opWrap.customerId), opWrap.idToDescriptionMap.get(opWrap.customerId), agentrole); //creating case record for COA
                    opWrap.insertCases.add(aCase);
                } catch(Exception coaError) {
                    coaError.setMessage('Unable to create COA for Account ID:' + opWrap.customerId + ' with Agent (Agent ID: ' + agentrole.Agent__c + ') ' + coaError.getMessage());
                    LoggingService.logHandledException(coaError,CLASS_NAME, CASE_AND_TASK_ON_ADDRESS_CHANGE_METHOD_NAME , LoggingLevel.ERROR);
                }
            }
        }
        return opWrap.insertCases;
    }

    private static Map<Id,Account> createMapOfIdAndAccount(List<Id> sfdcIds) {
        return new Map<Id,Account>([
            SELECT Id, PersonContactId, (
        		SELECT Agent__c,  Agent__r.Servicing_Agent_Associate_ID__c
        		FROM Agent_Roles__r 
                WHERE RelationshipNature__c =: System.Label.CL_CUSTOMER_RELATION_SHIP_NATURE
                AND Agent__r.SubUserType__c in (:SUB_USER_TYPE_AGENT, :SUB_USER_TYPE_PSO, :SUB_USER_TYPE_SFO)
            ) 
            FROM Account 
            WHERE Id IN :sfdcIds  WITH SECURITY_ENFORCED
        ]);
    }

    /**
    * @method caseCreationOnAddressChange: case Creation for Change of Address
    * @description Created COA Case
    * @param customer
    * @param changeDescription
    * @param agentrole
    * @return Case
    * 
    */
    private static Case caseCreationOnAddressChange(Account customer, String changeDescription, AgentRole__c agentrole) {
        
        return  new Case(
            App_Code__c = COA_APP_CODE,
	        AccountId = customer.Id,
	        ContactId = customer.PersonContactId,
	        OwnerId = UTIL_AgentOfficeDetails.getProxyforGivenServicingAgentAssocId(agentrole.Agent__r.Servicing_Agent_Associate_ID__c).id,
	        Priority = CASE_PRIORITY,
	        Status = CASE_STATUS,
	        Subject = System.Label.CL_ADDRESS_CHANGE_SUBJECT,
	        Type = CASE_TYPE,
	        Reason = CASE_REASON,
	        Description = changeDescription
        );
    }
    
    private with sharing class OperationWrapper {
        Map<Id,Account> idToMembersMap;
        Map<Id, String> idToDescriptionMap;
        Id customerId;
        List<Case> insertCases;
    }

}
