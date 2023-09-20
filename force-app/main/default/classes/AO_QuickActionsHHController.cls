/**
 * @description This is the Apex controller for the AO_QuickActionsHH Aura component
 */
public with sharing class AO_QuickActionsHHController {

    @TestVisible private static Boolean isCatch = false;

    /**
     * @description Retrieves the Accounts associated to the household
     * @param householdId Household record id
     * @return List of Accounts associated to the household
     */
    @AuraEnabled(cacheable=true)
    public static List<Account> getHouseholdMembers(Id householdId) {
        List<Account> householdMembers = new List<Account>();
        try {
            householdMembers = Security.stripInaccessible(AccessType.READABLE,[
                            SELECT Id, Name, PersonContactId
                            FROM Account
                            WHERE Primary_Household__pc = :householdId
            ]).getRecords();

            if(isCatch){
                throw new DMLException();
            }

        } catch(Exception e) {
            LoggingService.logHandledException(e, 'AO_QuickActionsHHController','getHouseholdMembers', System.LoggingLevel.ERROR);
        }
        return householdMembers;
    }

    /**
     * @description returns recently accessed account id
     * @param householdId household id
     * @return accountId
     */
    @AuraEnabled
    public static String getRecentlyAccessedAccountId(Id householdId) {
        // When an account is accessed that is part of a household, the account gets cached by household id.
        try{
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.household');

            if(isCatch){
                throw new DMLException();
            }
            
            return (String)sessionPart.get(householdId);
        }catch(Exception e){
            throw new AuraHandledException('Failed to get recently accessed accounts, getRecentlyAccessedAccountId');
        }
        
    }
}