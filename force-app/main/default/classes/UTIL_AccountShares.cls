/**
 * @description This class will house various methods used for adding/removing Agreement Shares to/from the Database. 
 * @Date: 09/17/20
 * @author: Kalen Wood-Wardlow 
 */
public without sharing class UTIL_AccountShares extends UTIL_AgencyShares {

    private static final String CLASS_NAME = 'UTIL_AccountShares';

    private static final String KEY_SYMBOL = '+';
    public static final String AGENT_ACCOUNTACCESS_LEVEL = 'Edit';
    public static final String AGENT_OPPORTUNITY_ACCESS_LEVEL = 'None';
    public static final String AGENT_CASE_ACCESS_LEVEL = 'None';
    public static final String AGENT_CASE_READ_ACCESS_LEVEL = 'Read';
    private static final String MANUAL_ROW_CAUSE = 'Manual';

    /**
     * @description This method will be used to create new account shares for each new agent role.
     * @param List<AgentRole__c>
     * @param agentRoleData
     */
    public static void createAccountShares(AgentRoleData agentRoleData) {

        Set<AccountShare> sharesToAdd = new Set<AccountShare>();
        Map<Id,AccountShare> accountShareIdToObjectMap= new Map<Id,AccountShare>();

        // Loop through all agent roles and create corrasponding account shares.
        for(AgentRole__c newAgentRole : agentRoleData.agentRoles) {
            AccountShare share = new AccountShare();
            share.accountId = newAgentRole.Customer__c;
            share.AccountAccessLevel = AGENT_ACCOUNTACCESS_LEVEL;
            share.OpportunityAccessLevel = AGENT_OPPORTUNITY_ACCESS_LEVEL;
            share.CaseAccessLevel = AGENT_CASE_ACCESS_LEVEL;
            share.UserOrGroupId = agentRoleData.agentToProxyIds.get(newAgentRole.Agent__c);
            sharesToAdd.add(share);
        }

        // Get accounts for all new agent roles with their case data.
        Map<Id,Account> accountsWithCases = getAccountsAndCases(agentRoleData.agentRolesToAccountIds.values());
        //We need convert set to list in order to send for Insert.
        List<AccountShare> accountSharesToAdd = new List<AccountShare>(sharesToAdd);
        // Insert Account Shares
        List<Database.SaveResult> saveResults = insertAccountShareAndLogFailures(accountSharesToAdd);

        if(saveResults != null){

            // Once Shares are created we'll want to map share ID to Share to assist in the creation of Case Shares
            for(AccountShare share: accountSharesToAdd){
                accountShareIdToObjectMap.put(share.id, share);
            }

            // Create Case Shares for all new agent roles.
            createCaseShares(saveResults, accountShareIdToObjectMap, accountsWithCases);
        }

    }




    /**
     * @description This method will be used to delete account shares for each agent role that will be deleted.
     * @param List<AgentRole__c> deletedAgentRoleList
     * @param agentRoleData
     */
    public static void deleteAccountShares(AgentRoleData agentRoleData) {
        String methodName = 'deleteAccountShares';
           
        List<AccountShare> existingAccountShares = new List<AccountShare>();
        try {
             // Find all account shares where account id 
             // and proxy id match the provided roles to delete
             existingAccountShares = [
                SELECT Id, UserOrGroupId, AccountId 
                FROM AccountShare 
                WHERE AccountId IN : agentRoleData.agentRolesToAccountIds.values() 
                AND UserOrGroupId IN : agentRoleData.agentToProxyIds.values()
                AND RowCause = : MANUAL_ROW_CAUSE
            ];
        } catch (System.QueryException qe) {
            LoggingService.logHandledException(qe, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }
       
        Map<String, AccountShare> accountShareKeyMap = new Map<String, AccountShare>();

        // Create a helper map to help identify exact record using combination of user account id and proxy group id
        for (AccountShare accountShare : existingAccountShares) {
            accountShareKeyMap.put(accountShare.AccountId + KEY_SYMBOL + accountShare.UserOrGroupId, accountShare);
        }

        Set<AccountShare> acctSharesToDelete = new Set<AccountShare>();

        // Iterate through the deleted set again to exactly identify the share records
        for (AgentRole__c agentToDelete : agentRoleData.agentRoles) {

            String key = agentToDelete.Customer__c 
                + KEY_SYMBOL 
                + agentRoleData.agentToProxyIds.get(agentToDelete.Agent__c);

            if(accountShareKeyMap.containsKey(key)){
                acctSharesToDelete.add(accountShareKeyMap.get(key)); 
            }
             
        }

        //We need convert set to list in order to send to delete.
        List<AccountShare> sharesToDeleteFormatted = new List<AccountShare>();
        sharesToDeleteFormatted.addAll(acctSharesToDelete);
    
        deleteAccountShareAndLogFailures(sharesToDeleteFormatted);
    }




    /**
     * @description This method will use a list of account Id's to retrieve a list of account objects and their cases.
     * @param accountIds 
     * @return Map<Id, Account>
     */
    public static Map<Id, Account> getAccountsAndCases(List<Id> accountIds) {

        Map<Id, Account> accountDetails = new Map<Id, Account> ([SELECT Id,PersonContactId,
            (SELECT id,OwnerId,Reason FROM Cases) FROM Account 
            WHERE Id IN : accountIds]);

        return accountDetails;

    }




    /**
     * @description This method will use a list of account Id's to retrieve a list of account objects and their cases.
     * @param saveResults
     * @param accountShareIdToObjectMap
     * @param accountsWithCases 
     */
    public static void createCaseShares(List<Database.SaveResult> saveResults, Map<Id,AccountShare> accountShareIdToObjectMap,  Map<Id,Account> accountsWithCases){

        Set<CaseShare> caseSharesToAdd = new Set<CaseShare>();

        // For reach saved result we want to get the associated share, determine the account and add the neccessary shares.
        for(Database.SaveResult sr: saveResults) {
            if(sr.isSuccess()){

                // Get Account assoicated with the saved result.
                Account account = accountsWithCases.get(accountShareIdToObjectMap.get(sr.getId()).accountId);

                // Create the case and add it to the list of new cases
                for(Case c : account.cases) {
                    //filter out all users having ownership to a case
                    if(c.OwnerId == accountShareIdToObjectMap.get(sr.getId()).UserOrGroupId) {
                        continue;
                    }
                    CaseShare cs = new CaseShare();
                    cs.CaseId = c.Id;
                    cs.UserOrGroupId = accountShareIdToObjectMap.get(sr.getId()).UserOrGroupId;
                    cs.CaseAccessLevel = AGENT_CASE_READ_ACCESS_LEVEL;
                    caseSharesToAdd.add(cs);
                }
            }
        }   
        
        // Convert Set to a list so that it can be added to the database, the set was used to prevent duplicates.
        List<CaseShare> listOfCaseSharesToAdd = new List<CaseShare>(caseSharesToAdd);
        
        UTIL_CaseShareDAO.insertCaseShareAndLogFailures(listOfCaseSharesToAdd);
    }




    /**
     * @description Insert account shares into the database. Log and return the list of results.
     * @param listOfAccountShares 
     * @return List<Database.SaveResult>
     */
    public static List<Database.SaveResult> insertAccountShareAndLogFailures(List<AccountShare> listOfAccountShares) {

        if(listOfAccountShares != null) {

            String methodName='insertAccountShareAndLogFailures';

            List<Database.SaveResult> saveResults = Database.insert(listOfAccountShares, false);
            LoggingService.logDatabaseResult(saveResults, listOfAccountShares, CLASS_NAME, methodName, System.LoggingLevel.ERROR);

            return saveResults;

        }

        return null;
    }




    /**
     * @description Delete account shares into the database. Log the results.
     * @param listOfAccountShares 
     */
    public static void deleteAccountShareAndLogFailures(List<AccountShare> listOfAccountShares) {

        if(listOfAccountShares != null) {

            String methodName='deleteAccountShareAndLogFailures';

            List<Database.DeleteResult> deleteResults = Database.delete(listOfAccountShares, false);
            LoggingService.logDatabaseResult(deleteResults, listOfAccountShares, CLASS_NAME, methodName, System.LoggingLevel.ERROR);

        }

    }

}
