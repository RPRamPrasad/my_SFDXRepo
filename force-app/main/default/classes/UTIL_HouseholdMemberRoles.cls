/**
@author Team Targaryen
@owner Team Targaryen
@name UTIL_HouseholdMemberRoles
@CreateDate 03/22/2022
@modifiedDate 
@description This class is used by LWC Household Manage Roles components to leverage the AccountContactRelation object operations
@version 1.0
*/
public with sharing class UTIL_HouseholdMemberRoles{
    
    @TestVisible 
    private static final String CLASS_NAME = 'UTIL_HouseholdMemberRoles';
    public static boolean isRoleUpdate = false;

    /**
    * @description This method retrieves members from AccountContactRelation without cache
    * @name : fetchMembersNoCache
    * @param hhAcctId : input account json
    * @return List<AccountContactRelation> : output list of HH members
    */
    @AuraEnabled (cacheable = false)
    public static List<AccountContactRelation> fetchMembersNoCache(String hhAcctId) {
        try {
            UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', hhAcctId, Account.class);
            return  UTIL_HouseholdMemberHelper.getAllActiveMembersFromHousehold(String.escapeSingleQuotes(hhAcctId));
        } catch(Exception e){
            throw new AuraHandledException('No members found');
        }
    
    }

    /**
    * @description This method retrieves members from AccountContactRelation
    * @name : fetchMembers
    * @param hhAcctId : input account json
    * @return List<AccountContactRelation> : output list of HH members
    */
    @AuraEnabled (cacheable = true)
    public static List<AccountContactRelation> fetchMembers(String hhAcctId) {
        try {
            UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', hhAcctId, Account.class);
            return  UTIL_HouseholdMemberHelper.getAllActiveMembersFromHousehold(String.escapeSingleQuotes(hhAcctId));
        } catch(Exception e){
            throw new AuraHandledException('No members found');
        }
    }

   /**
    * @description This method is used to retrieve household role data
    * @name : getHouseholdRoleOptions
    * @return List<String>
    */
    @AuraEnabled(cacheable = true)
    public static List<String> getHouseholdRoleOptions() {
        try {
            List<String> roleOptions = new List<String>();
            for(CS_Household_Role__c role : UTIL_HouseholdMemberHelper.getHouseholdRoleData()) { roleOptions.add(role.Name); }
            return roleOptions;
        } catch(Exception e){
            throw new AuraHandledException('Please refresh/reload page again');
        }
    }
    
    /**
     * @description Update Account Contact Relation
     * @param acrJSONList
     * @param hhId
     */
    @AuraEnabled
    public static void updateAccountContactRelation(String acrJSONList, String hhId) {
        String methodName = 'updateAccountContactRelation';
        isRoleUpdate = true;

        try {
            List<AccountContactRelation> updateACRList = new List<AccountContactRelation>();
            List<AccountContactRelation> acrList = (List<AccountContactRelation>) JSON.deserializeStrict(acrJSONList,List<AccountContactRelation>.class);
            for (AccountContactRelation acr: acrList) {
                AccountContactRelation acrUpdate = new AccountContactRelation();
                acrUpdate.Id = acr.Id;
                acrUpdate.FinServ__Primary__c = acr.FinServ__Primary__c;
                acrUpdate.Roles = acr.Roles;
                updateACRList.add(acrUpdate);
            }
            updateACRrecordsAndLogFailures(updateACRList);

            List<String> hhAcctIdList = new List<String>{hhId};
            UTIL_HouseholdMoveMember.updateHouseholdRecordWithCurrentTimestamp(hhAcctIdList); 
        }
        catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
            throw new AccountCreateEditException('removeAccountContactRelation Error: ' + e.getMessage());
        }

    }
    
    private static void updateACRrecordsAndLogFailures(List<AccountContactRelation> updateACRList) {
        String methodName = 'updateACRrecordsAndLogFailures';
        if(updateACRList != null && !updateACRList.isEmpty()) {
            List<Database.SaveResult> saveResultsList = UTIL_HouseholdMemberDAO.updateACRAndReturnSaveResults(updateACRList);
            LoggingService.logDatabaseResult(saveResultsList, updateACRList, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }

    }

}