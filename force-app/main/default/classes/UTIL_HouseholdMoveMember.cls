/**
@author Team Targaryen
@owner Team Targaryen
@name UTIL_HouseholdMoveMember
@CreateDate 09/20/2021
@modifiedDate
@description Controller class to access household move members methods
@version 1.0
*/

public with sharing class UTIL_HouseholdMoveMember {

    private static final String HOUSEHOLD_RECORD_TYPE = 'IndustriesHousehold';
    private static final String CLASS_NAME = 'UTIL_HouseholdMoveMember';
    public static boolean isTransactionFromHouseholdMove = false;


    /**
    * @description This method retrieves ACR  records
    * @name : fetchHouseholdMembers
    * @param hhAcctId : input account Id
    * @return List<AccountContactRelation> : output list of HH members
    */
    @AuraEnabled (cacheable = false)
    public static List<AccountContactRelation> fetchHouseholdMembers(String hhAcctId) { 
        return UTIL_HouseholdMemberHelper.getAllActiveMembersFromHousehold(hhAcctId); 
    
    }

    /**
    * @description This method retrieves all ACR  records with or without BoB
    * @name : getAllHouseholdMembers
    * @param hhAcctId : input account Id
    * @return List<AccountContactRelation> : output list of HH members
    */
    @AuraEnabled (cacheable = false)
    public static List<AccountContactRelation> getAllActiveMembersInHousehold(String hhAcctId) { 
        return UTIL_HouseholdMemberHelper_Additional.getAllActiveMembersFromHousehold(hhAcctId); 
    
    }

    /**
    * @description This method to move members from left to right and vis-versa
    * @name : moveMembersBetweenHousehold
    * @param oldHHActId : input old Household account Id
    * @param newHHActId : input new household account Id (moved into)
    * @param acrList : input map of left household Id to ACRs
    */
    @AuraEnabled
    public static void moveMembersBetweenHousehold(String oldHHActId, String newHHActId, List<AccountContactRelation> acrList) {
        String strNewHHActId =newHHActId;
        String methodName = 'moveMembersBetweenHousehold';
        isTransactionFromHouseholdMove = true;
        try{
            if( String.isBlank(newHHActId) && acrList.size() == 1){
                removeAccountContactRelation(acrList);
           
            } else {
                if(!String.isNotBlank(newHHActId)) {
                    strNewHHActId = createNewHousehold();
                }

                Map<Id,List<AccountContactRelation>> hhAcctIdToACRs = new Map<Id,List<AccountContactRelation>>();
                for(AccountContactRelation acr : acrList) {
                    if(hhAcctIdToACRs.containsKey(acr.AccountId)){
                        hhAcctIdToACRs.get(acr.AccountId).add(acr);
                    }
                    else {
                        hhAcctIdToACRs.put(acr.AccountId, new List<AccountContactRelation>{acr});
                    }
                }

                List<String> hhAcctIdList = new List<String>{oldHHActId, strNewHHActId};
                updateHouseholdRecordWithCurrentTimestamp(hhAcctIdList);
                
                List<AccountContactRelation> removeAcrList = hhAcctIdToACRs.get(oldHHActId);
                removeAccountContactRelation(removeAcrList);
                List<UTIL_HouseholdAddMember.ACRWrapper> insertAcrList = buildAcrRecordWithNewHousehold(oldHHActId, strNewHHActId, hhAcctIdToACRs);
                UTIL_HouseholdAddMember.createAccountContactRelation(JSON.serialize(insertAcrList));
                
                

            }
            
        }
        catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
            throw new AccountCreateEditException('moveMembersBetweenHousehold Error: ' + e.getMessage());
        }
        
    }

    /**
    * @description This method updates ACR
    * @name : removeAccountContactRelation
    * @param acrJSONList : input ACR json
    */
    @AuraEnabled
    public static void removeAccountContactRelation(List<AccountContactRelation> acrJSONList) {
        String methodName = 'removeAccountContactRelation';
        System.debug(LoggingLevel.DEBUG,'JSON-->'+acrJSONList);
        try {
            List<AccountContactRelation> deleteACRList = new List<AccountContactRelation>();
            List<AccountContactRelation> acrList = acrJSONList;
            for (AccountContactRelation acrDelete: acrList) {
                deleteAcrList.add(acrDelete);
            }
            deleteACRrecordsAndLogFailures(deleteACRList);
        }
        catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
            throw new AccountCreateEditException('removeAccountContactRelation Error: ' + e.getMessage());
        }

    }

    private static  List<UTIL_HouseholdAddMember.ACRWrapper> buildAcrRecordWithNewHousehold(String oldHhAcctId, String newHhAcctId, Map<Id,List<AccountContactRelation>> hhAcctToACRs) {
        List<UTIL_HouseholdAddMember.ACRWrapper> newACRWrapList = new List<UTIL_HouseholdAddMember.ACRWrapper>();
        for(AccountContactRelation oldAcr: hhAcctToACRs.get(oldHhAcctId)){
            UTIL_HouseholdAddMember.ACRWrapper newACRWrap = new UTIL_HouseholdAddMember.ACRWrapper();
            newACRWrap.accountId = newHhAcctId;
            newACRWrap.contactId = oldAcr.ContactId;
            newACRWrap.roles = null;
            newACRWrapList.add(newACRWrap);
        }
        return newACRWrapList;
    }

    private static String createNewHousehold() {
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId();
        Account householdAccount = new Account(Name='Household', recordTypeId=householdRecordTypeId, AllowHousehold__c = true);
        UTIL_AccountDAO.insertAccount(householdAccount);
        return String.valueOf(householdAccount.Id);
    }

    private static void deleteACRrecordsAndLogFailures(List<AccountContactRelation> deleteACRList) {
        String methodName = 'deleteACRrecordsAndLogFailures';
        if(deleteACRList != null && !deleteACRList.isEmpty()) {
            List<Database.DeleteResult> deleteResultsList = UTIL_HouseholdMemberDAO.deleteACRAndReturnSaveResults(deleteACRList);
            LoggingService.logDatabaseResult(deleteResultsList, deleteACRList, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
        }
    }

    //Create New UTIL_HouseholdManagement class later
     /**
     * @description Update Household Record ID With Current Timestamp
     * @param hhAcctIdList
     */
    public static void updateHouseholdRecordWithCurrentTimestamp(List<String> hhAcctIdList) {
        List<Account> accountList=new List<Account>();
        if(hhAcctIdList.size()==2){  
        for(String hhAcctId : hhAcctIdList) {
           Account hhAcctRecord = new Account(Id=hhAcctId, AllowHousehold__c=true);
           accountList.add(hhAcctRecord);
        }  
           UTIL_AccountDAO.updateAccounts(accountList);
        }else{
            Account hhAcctRecord = new Account(Id=hhAcctIdList.get(0), AllowHousehold__c=true); 
            accountList.add(hhAcctRecord);
            UTIL_AccountDAO.updateAccounts(accountList);
        }
    } 
}