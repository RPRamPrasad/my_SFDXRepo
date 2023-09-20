/**
@author Team STARK
@owner Team STARK
@name UTIL_HouseholdAddMember
@CreateDate 06/09/2021
@modifiedDate
@description This class is used by LWC Household Add Member components to leverage the AccountContactRelation object operations
@version 1.0
*/
public with sharing class UTIL_HouseholdAddMember {
   
    @TestVisible
    private static IDAO_AccountCreateEditHelper helperDAOInstance = new UTIL_AccountCreateEditHelper();
    private static final String CLASS_NAME = 'UTIL_HouseholdAddMember';
 
    /**
    * @description This method is used to retrieve household role data
    * @name : getHouseholdRoleOptions
    * @return List<String>
    */
    @AuraEnabled(cacheable = true)
    public static List<String> getHouseholdRoleOptions() {
        List<String> roleOptions = new List<String>();
        for(CS_Household_Role__c role : UTIL_HouseholdMemberHelper.getHouseholdRoleData()) { roleOptions.add(role.Name); }
        return roleOptions;
    }
 
    /**
    * @description This method fetch mailing (billing) address from account record
    * @name : fetchMailingAddresses
    * @param hhAcctId : input account json
    * @return List<Account> : output updated account id
    */
    @AuraEnabled
    public static List<Account> fetchMailingAddresses(String hhAcctId) {
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', hhAcctId, Account.class);
        List<Account> householdAddresses = UTIL_HouseholdMemberHelper.getBillingAddressForHousehold(String.escapeSingleQuotes(hhAcctId));
    
        Set<String> uniqueAddresses = new Set<String>();
        for(Account hhAddr : householdAddresses) {
            uniqueAddresses.add(hhAddr.get('BillingAddress').toString());
        }
       
        List<Account> deduped = new List<Account>();
        for(Account newHHAddr : householdAddresses) {
            if(uniqueAddresses.contains(newHHAddr.get('BillingAddress').toString())) {
                deduped.add(newHHAddr);
                uniqueAddresses.remove(newHHAddr.get('BillingAddress').toString());
            }
        }
        return deduped;
    }
 
    /**
    * @description This method is used to fetch account record for search
    * @name fetchRecord
    * @param selectedContact
    * @return Account
    **/
    @AuraEnabled(cacheable = true) 
    public static Account fetchAccountRecord(Id selectedContact) {
        String methodName = 'fetchAccountRecord';
        Account account = new Account();
        try {
            UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', selectedContact, Account.class);
            account = helperDAOInstance.getAccountDetails(selectedContact);
        }
        catch (Exception exp) {
          LoggingService.logHandledException(exp, CLASS_NAME,methodName, System.LoggingLevel.ERROR);
        }
        return account;
    }

     /**
    * @description This method insert and update AccountContactRelation
    * @name : createAccountContactRelation
    * @param acrJSONList : input account json
    * @return Object : output updated account id
    */
    @AuraEnabled
    public static Object createAccountContactRelation(String acrJSONList) {
        String methodName = 'createAccountContactRelation';
        Set<id> failedRecordsIds = new set<id>();
        Integer index = 0;
        System.debug(LoggingLevel.DEBUG,'JSON-->'+acrJSONList);
        try {
            List<AccountContactRelation> inputACRList = new List<AccountContactRelation>();
            List<AccountContactRelation> insertACRList = new List<AccountContactRelation>();
            List<AccountContactRelation> updateACRList = new List<AccountContactRelation>();
            List<ACRWrapper> inputACRWrapper = (List<ACRWrapper>) JSON.deserializeStrict(acrJSONList,List<ACRWrapper>.class);
            
            for (ACRWrapper acrwrap: inputACRWrapper) {
                AccountContactRelation acr = new AccountContactRelation();
                acr.AccountId = acrwrap.AccountId;
                acr.ContactId = acrwrap.ContactId;
                acr.Roles = acrwrap.Roles;
                acr.FinServ__Rollups__c = 'All';
                acr.FinServ__PrimaryGroup__c = true;
                acr.FinServ__Primary__c = false;
                acr.IsActive = true;
                inputACRList.add(acr);
            }
           
            String householdId = inputACRList[0].AccountId;
            UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', householdId, Account.class);
            List<AccountContactRelation> existingACRList = UTIL_HouseholdMemberHelper.getAllMembersFromHousehold(String.escapeSingleQuotes(householdId));
           
            //Prepare list of AccountContactRelation for insert and update
            for(AccountContactRelation singleInputACR: inputACRList) {
                boolean isACRExist = false;
                ProcessACRClass aCRData = new ProcessACRClass(singleInputACR, updateACRList, isACRExist);
                aCRData = findSingleACR(aCRData, existingACRList);
                updateACRList = aCRData.updateACRList;
                if(aCRData.isACRExist == false) {
                  insertACRList.add(singleInputACR); 
                }
            }

            insertACRrecordsAndGetFailedIds(insertACRList,failedRecordsIds, index);
            updateACRrecordsAndGetFailedIds(updateACRList, failedRecordsIds, index);
            System.debug(LoggingLevel.DEBUG,'failedRecordsIds-->'+failedRecordsIds);
            
            if(!UTIL_HouseholdMoveMember.isTransactionFromHouseholdMove){
            List<String> hhAcctIdList = new List<String>{inputACRWrapper.get(0).AccountId};
            UTIL_HouseholdMoveMember.updateHouseholdRecordWithCurrentTimestamp(hhAcctIdList);
            }
            return failedRecordsIds;
        }
        catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
            throw new AccountCreateEditException('createAccountContactRelation Error: ' + e.getMessage());
        }
    }
    
    
    /**
    * @description Find Single ACR
    * @param aCRData
    * @param existingACRList
    * @return ProcessACRClass 
    */
    private static ProcessACRClass findSingleACR(ProcessACRClass aCRData, List<AccountContactRelation> existingACRList) {
        ProcessACRClass outACRData = aCRData;

        for(AccountContactRelation singleExisitngACR: existingACRList) {
            if(aCRData.singleInputACR.ContactId == singleExisitngACR.ContactId && singleExisitngACR.IsActive == false){
                aCRData.singleInputACR.Id = singleExisitngACR.Id;
                aCRData.singleInputACR.FinServ__SourceSystemId__c = singleExisitngACR.FinServ__SourceSystemId__c;
                outACRData.updateACRList.add(aCRData.singleInputACR);
                outACRData.isACRExist = true;
                break;
            }
        }
        return outACRData;

    }
    
    /**
     * @description Process ACR Class
     */
    public class ProcessACRClass {
        AccountContactRelation singleInputACR = null;
        List<AccountContactRelation> updateACRList = null;
        boolean isACRExist = false;

        /**
         * @description ProcessACRClass constructor
         * @param singleInputACRIn
         * @param updateACRListIn
         * @param inACRExist
         */
        public ProcessACRClass(AccountContactRelation singleInputACRIn, List<AccountContactRelation> updateACRListIn, boolean inACRExist) {
            singleInputACR = singleInputACRIn;
            updateACRList = updateACRListIn;
            isACRExist = inACRExist;
        }
    }
    
    /**
    * @description This inner class is used to make account contact relation wrapper JSON
    * @name : ACRWrapper
    */
    public with sharing class ACRWrapper {
        public String accountId;
        public String contactId;
        public String roles;
    }

    private static void insertACRrecordsAndGetFailedIds(List<AccountContactRelation> insertACRList, Set<id> failedRecordsIds, Integer index) {
        Integer resultIndex = index;
        if(insertACRList != null && !insertACRList.isEmpty()) {
            List<Database.SaveResult> saveResultsList = UTIL_HouseholdMemberDAO.insertACRAndReturnSaveResults(insertACRList);
            for(Database.SaveResult saveResult: saveResultsList){
                if(!saveResult.isSuccess()){
                    failedRecordsIds.add(insertACRList.get(resultIndex).ContactId);
                }
                resultIndex++;
            }
        }
    }

    private static void updateACRrecordsAndGetFailedIds(List<AccountContactRelation> updateACRList, Set<id> failedRecordsIds, Integer index) {
        Integer resultIndex = index;
        if(updateACRList != null && !updateACRList.isEmpty()) {
            List<Database.SaveResult> saveResultsList = UTIL_HouseholdMemberDAO.updateACRAndReturnSaveResults(updateACRList);
            for(Database.SaveResult saveResult: saveResultsList){
                if(!saveResult.isSuccess()){
                    failedRecordsIds.add(updateACRList.get(resultIndex).ContactId);
                }
                resultIndex++;
            }
        }
    }

}