/**
@author Team Targaryen
@owner Team Targaryen
@name UTIL_HouseholdRemoveMember
@CreateDate 07/22/2021
@modifiedDate 
@description This class is used by LWC Household Remove Member components to leverage the AccountContactRelation object operations
@version 1.0
*/
public with sharing class UTIL_HouseholdRemoveMember {
    
    @TestVisible 
    private static final String CLASS_NAME = 'UTIL_HouseholdRemoveMember';

    /**
    * @description This method retrieves members from AccountContactRelation without cache
    * @name : fetchMembersNoCache
    * @param hhAcctId : input account json
    * @return List<AccountContactRelation> : output list of HH members
    */
    @AuraEnabled (cacheable = false)
    public static List<AccountContactRelation> fetchMembersNoCache(String hhAcctId) {
        try{
            UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', hhAcctId, Account.class);
            return  UTIL_HouseholdMemberHelper.getAllActiveMembersFromHousehold(String.escapeSingleQuotes(hhAcctId));
        } 
        catch(Exception e){
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
    * @description This method updates ACR
    * @name : removeAccountContactRelation
    * @param acrJSONList : input ACR json
    * @param hhId
    */
    @AuraEnabled
    public static void removeAccountContactRelation(String acrJSONList, String hhId) {
        String methodName = 'removeAccountContactRelation';
      
        System.debug(LoggingLevel.DEBUG,'JSON-->'+acrJSONList);
        try {
            List<AccountContactRelation> deleteACRList = new List<AccountContactRelation>();
            List<Id> acrList = (List<Id>) JSON.deserializeStrict(acrJSONList,List<Id>.class);
            for (Id acr: acrList) {
                AccountContactRelation acrDelete = new AccountContactRelation(Id = acr); 
                deleteAcrList.add(acrDelete);
            }
            deleteACRrecordsAndLogFailures(deleteACRList);
           
            List<String> hhAcctIdList = new List<String>{hhId};
            UTIL_HouseholdMoveMember.updateHouseholdRecordWithCurrentTimestamp(hhAcctIdList); 
        }
        catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
            throw new AccountCreateEditException('removeAccountContactRelation Error: ' + e.getMessage());
        }

    }
    private static void deleteACRrecordsAndLogFailures(List<AccountContactRelation> deleteACRList) {
        String methodName = 'deleteACRrecordsAndLogFailures';
        if(deleteACRList != null && !deleteACRList.isEmpty()) {
            List<Database.DeleteResult> deleteResultsList = UTIL_HouseholdMemberDAO.deleteACRAndReturnSaveResults(deleteACRList);
            LoggingService.logDatabaseResult(deleteResultsList, deleteACRList, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }
    }
}