/**
 * @description This is a class on the Case object that creates the appropriate case share.
 * @author GrumpyCats
 * @since 12/2/2019
 */
public without sharing class AP_CreateCaseShare {
    
    /**
    * @description createAppropriateCaseShare: Provides the Case Record access for Appropriate Users
    * @param caseList 
    */
	public static void createAppropriateCaseShare(List<Case> caseList){
        	Set<id> caseAccountId =new Set<Id>();
        	for(Case singleCase:caseList){
            	caseAccountId.add(singleCase.AccountId);
        	}
        	List<Account> accountDetailsList=getAccountDetails(caseAccountId);
        	Map<Id, Account> accountIdMap = new Map<Id,Account> (accountDetailsList);
        	Map<Id,Id> agentProxyMap=UTIL_AgentOfficeDetails.getMapOfAgentAndProxyIds(getAgentRoleListFromAccounts(accountDetailsList));
        	if(!agentProxyMap.keySet().isEmpty()){
            	insertCaseShare(getProxyIdsToShareCases(accountIdMap,caseList,agentProxyMap));
        	}
    }
    
    /**
    * @description getProxyIdsToShareCases: Gets the Agent proxy Ids for given Cases
    * @param accountIdMap 
    * @param caseList 
    * @param agentProxyMap 
    * @return  `Map<Case,List<id>>`
    */
    private static Map<Case,List<id>> getProxyIdsToShareCases(Map<Id, Account> accountIdMap,List<Case> caseList,Map<Id,Id> agentProxyMap){
        Map<Case,List<Id>> mapOfCaseToProxyIds=new Map<Case,List<Id>>();
        for(Case caseRecord:caseList){
            List<AgentRole__c> agentRolesForCase=getListOfAgentRolesForGivenCase(caseRecord,accountIdMap);
            if(!agentRolesForCase.isEmpty()) {
                mapOfCaseToProxyIds.put(caseRecord,getListOfProxyIds(agentRolesForCase,agentProxyMap,caseRecord));
            }
        }
        return mapOfCaseToProxyIds;
    }
    
    /**
    * @description insertCaseShare: Creates case share record list and insert into Case share table
    * @param mapOfCaseAndOfficeProxyToShareWith 
    */
    private static void insertCaseShare(Map<Case,List<id>> mapOfCaseAndOfficeProxyToShareWith){
        
        List<CaseShare> caseShareRecordsList=new List<CaseShare>();
        for(Case caseRecord:mapOfCaseAndOfficeProxyToShareWith.keySet()){
            if(!mapOfCaseAndOfficeProxyToShareWith.get(caseRecord).isEmpty()) {
                caseShareRecordsList.addAll(createCaseShare(caseRecord,mapOfCaseAndOfficeProxyToShareWith.get(caseRecord)));
            }
        }
        UTIL_CaseShareDAO.insertCaseShareAndLogFailures(caseShareRecordsList);
    }
    

    /**
    * @description createCaseShare Creates case share record list
    * @param caseRecord 
    * @param proxyUserIds 
    * @return  `List<CaseShare>`
    */
    private static List<CaseShare> createCaseShare(Case caseRecord,List<Id> proxyUserIds){
        List<CaseShare> listCaseShareRecordsList=new List<CaseShare>();
        
        for(id proxyUserId:proxyUserIds){
            CaseShare cs=new CaseShare();
            cs.CaseId=caseRecord.id;
            cs.UserOrGroupId=proxyUserId;
            cs.CaseAccessLevel= 'Read';
            listCaseShareRecordsList.add(cs);
        }
        boolean caseIsDataAccessRequest = (caseRecord.RecordTypeId == CaseHandlerConstants.CASE_RECORDTYPE_ID_DATA_ACCESS_REQUEST);
        if(caseIsDataAccessRequest && caseRecord.OwnerId != UTIL_QueueDetails.QUEUE_DAR_CASE_QUEUE_ID){
            listCaseShareRecordsList.add(createCaseShareForGroup(caseRecord, UTIL_QueueDetails.QUEUE_DAR_CASE_QUEUE_ID));
        }

        return listCaseShareRecordsList;
    }

    
    /**
    * @Author : ebcl
    * @description createCaseShareForGroup Method to create a Case share for a Group
    * @param caseRecord 
    * @param groupId 
    * @return  `CaseShare`
    */
    private static CaseShare createCaseShareForGroup(Case caseRecord,Id groupId){
        CaseShare caseShareForGroup = new CaseShare();    
        caseShareForGroup.CaseId=caseRecord.Id;   
        caseShareForGroup.UserOrGroupId=groupId;    
        caseShareForGroup.CaseAccessLevel= 'Edit';    
        return caseShareForGroup;
    }
   /**
    * @description getAccountDetails Gets the Account Details for the given account Ids
    * @param accountIdsList 
    * @return  `List<Account>`
    */
    private static List<Account> getAccountDetails(Set<id> accountIdsList){
        List<Account> accountDetailsList=[SELECT Id,PersonContactId,
                                          (SELECT Customer__c,Agent__c,RelationshipNature__c,Agent__r.Proxy_External_ID__c,Agent__r.UserExternalID__c, Is_Logged_in_User_Owner__c FROM Agent_Roles__r) 
                                          FROM Account WHERE Id =: accountIdsList];
        return accountDetailsList;
    }
    
    /**
    * @description getAgentRoleListFromAccounts: Returns all agentRoles for the List of Accounts
    * @param listOfAccounts 
    * @return  `List<AgentRole__c>`
    */
    private static List<AgentRole__c> getAgentRoleListFromAccounts(List<Account> listOfAccounts){
        List<AgentRole__c> agentRoleList=new List<AgentRole__c>();
        for(Account accountdetails:listOfAccounts){
            agentRoleList.addAll(accountdetails.Agent_Roles__r);
        }
        return agentRoleList;
    }
    
    /**
    * @description getListOfAgentRolesForGivenCase: Returns all agentRoles for a given Case record
    * @param caseRecord 
    * @param accountIdMap 
    * @return  `List<AgentRole__c>`
    */
    private static List<AgentRole__c> getListOfAgentRolesForGivenCase(Case caseRecord, Map<Id,Account> accountIdMap){
        List<AgentRole__c> agentRoleList=new List<AgentRole__c>();
        Account accountDetails = accountIdMap.get(caseRecord.AccountId);
        
        if(accountDetails != null){
            agentRoleList.addAll(accountdetails.Agent_Roles__r);
        }
        return agentRoleList;
    }
    
    /**
    * @description getListOfProxyIds: Get the List proxy Ids of all agent roles for a given case
    * @param agentRolesForCase 
    * @param agentProxyMap 
    * @param caseRecord 
    * @return  `List<Id>`
    */
    private static List<Id> getListOfProxyIds(List<AgentRole__c> agentRolesForCase,Map<Id,Id> agentProxyMap, Case caseRecord){
        List<Id> proxyIdsList=new List<Id>();
        for(AgentRole__c agentRole:agentRolesForCase){

            if(agentHasProxy(agentRole, agentProxyMap) && isNotAgentCaseOwner(agentRole, agentProxyMap, caseRecord)) {
                proxyIdsList.add(agentProxyMap.get(agentRole.Agent__c));
            }
        }      
        return proxyIdsList;
    }
    
    /**
    * @description  isNotAgentCaseOwner: returns true if the case owner is not the proxy, agent or atm that created the case 
    * @param agentRole 
    * @param agentProxyMap 
    * @param caseRecord 
    * @return  `boolean`
    */
    private static boolean isNotAgentCaseOwner(AgentRole__c agentRole,Map<Id,Id> agentProxyMap, Case caseRecord){
        	boolean isCaseOwnerProxy = agentProxyMap.values().contains(caseRecord.OwnerId);
            if (isCaseOwnerProxy) { // if the case owner id exists in the AgentProxyMap values
                return agentProxyMap.get(agentRole.Agent__c)!= caseRecord.OwnerId; // checks if the proxy is not the case owner
            } else if(agentProxyMap.containsKey(caseRecord.OwnerId)) { // if the owner id is a key in the agent proxy map
                return agentRole.Agent__c != caseRecord.OwnerId; // check if the agent is the case owner
            }
        		// checks if agent role to see if the logged in user is the owner. Specifically, if an ATM creates a case
                return agentProxyMap.get(agentRole.Agent__c)!= caseRecord.OwnerId && !agentRole.Is_Logged_in_User_Owner__c;
    }
    
    /**
    * @description agentHasProxy: returns true if an agent has a proxy id
    * @param agentRole 
    * @param agentProxyMap 
    * @return  `boolean`
    */
    private static boolean agentHasProxy(AgentRole__c agentRole,Map<Id,Id> agentProxyMap) {
        return agentProxyMap.containsKey(agentRole.Agent__c);
    }
}