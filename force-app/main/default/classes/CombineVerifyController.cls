/**
* @name CombineVerifyController  
* @owner Atlas
* @description Combine Customers Page Onload controller to get customer group members
*/

public with sharing class CombineVerifyController {
    private static final String CLASS_NAME = 'CombineVerifyController';
    private static final String ERROR_MESSAGE = 'There is a problem with the action you performed. Please Try Again. If the problem persists, please contact your normal support channel.';
	private static List<Id> acctIds = new List<Id>();
	private static Map<Id,String> idRelationshipMap = new Map<Id,String>();
	private static Map<Id,String> idNameMap = new Map<Id,String>();
	private static List<List<String>> relations = new List<List<String>>();
	
    /**
     * @description Get Relationship Details
     * @param clientIds
     * @return List<List<String>>
     */
	@AuraEnabled
    public static List<List<String>> getRelationshipDetails(List<String> clientIds) {
        String methodName = 'getRelationshipDetails';

        List<String> verifiedClientIds = new List<String>();
        try {
            for(String clientId: clientIds){
 
                clientId = String.escapeSingleQuotes(clientId);
                verifiedClientIds.add(clientId);
                }
                List<Relationship__c> relationships = queryRelationships(verifiedClientIds);
                
                mapRelationshipAndId(relationships);
                
                List<Account> accounts = queryAccounts();
                
                mapAccountsAndId(accounts);
                  
                mapNamesAndRelationships();
                
                return relations;
        } catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
			throw new AuraHandledException(ERROR_MESSAGE);
    		
        }
    }
    
    private static void mapNamesAndRelationships() {
    	for (id key: idNameMap.keySet()) {
            List<String> temp = new List<String>();
            temp.add(idNameMap.get(key));
            temp.add(idRelationshipMap.get(key));
            relations.add(temp);
        }
    }
    
    private static void mapRelationshipAndId(List<Relationship__c> relationships) {
    	for(Relationship__c relationship : relationships) {
            acctIds.add(relationship.AccountOne__c);
            idRelationshipMap.put(relationship.AccountOne__c, relationship.RelationshipType__c);
        }
    }
    
    private static void mapAccountsAndId(List<Account> accounts) {
    	for(Account acct: accounts){
            idNameMap.put(acct.Id,acct.Name);
        }
    }
    
    private static List<Account> queryAccounts() {
        return Security.stripInaccessible(AccessType.READABLE,[ Select Name From Account WHERE Id in :acctIds]).getRecords();
    }
    
    private static List<Relationship__c> queryRelationships(List<String> clientIds) {
        return Security.stripInaccessible(AccessType.READABLE,[ Select AccountOne__r.name, RelationshipType__c 
                                          From Relationship__c WHERE AccountTwo__r.clientIdentifier__c in :clientIds]).getRecords();
       
    }
    
    /**
     * @description Get Looged In User alias
     * @return String
     */
    @AuraEnabled
    public static String getLoggedInUserAlias(){
        String methodName = 'getLoggedInUserAlias';
        try {
            String userId = userInfo.getUserId();
            List<User> loggedInUser = Security.stripInaccessible(AccessType.READABLE,[ Select Id, Name, Alias
                                                                 From User WHERE Id =:userId]).getRecords();
            return loggedInUser.get(0).Alias;
        } catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
			throw new AuraHandledException(ERROR_MESSAGE);
        }

    }
}