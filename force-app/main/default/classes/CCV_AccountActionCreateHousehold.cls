/**
@author CustomerView
@owner Team Atlas
@name CCV_AccountActionCreateHousehold
@createDate 12/23/2022
@ModifiedDate 
@description This class is used by LWC accountActionCreateHousehold to create Household
@version 1.0
*/
public with sharing class CCV_AccountActionCreateHousehold {
    private static final String CLASS_NAME = 'CCV_AccountActionCreateHousehold';
    private static final String HOUSEHOLD_RECORD_TYPE = 'IndustriesHousehold';

    /**
    * @description This method is used to initiate create household flow
    * @name : createHouseholdFlow
    * @param contactRecordId : input search key
    */
    @AuraEnabled
    public static void createHouseholdFlow(String contactRecordId) {
        String methodName = 'createHouseholdFlow';
        try {
            List<AccountContactRelation> existingAcrRecords = UTIL_HouseholdMemberHelper_Additional.getAllActiveMembersFromContactId(contactRecordId); 
            if(existingAcrRecords.isEmpty()) {
                AccountContactRelation insertAcr = buildAcrRecordWithNewHousehold(contactRecordId,null);
                insertACRrecordsAndGetFailedIds(new List<AccountContactRelation>{insertAcr});
            } else {
                if(existingAcrRecords.size() == 1) {
                    AccountContactRelation insertAcr = buildAcrRecordWithNewHousehold(contactRecordId, String.valueOf(existingAcrRecords[0].AccountId));
                    deleteACRrecordsAndLogFailures(existingAcrRecords);
                    insertACRrecordsAndGetFailedIds(new List<AccountContactRelation>{insertAcr});
                } else {
                    String v1 = 'Account is linked to multiple Household.';
                    throw new AccountCreateEditException(v1);
                }
            }
        }
        catch(Exception e) {
            LoggingService.logHandledException(e, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
            throw new AuraHandledException('CCV_AccountActionCreateHousehold Error: ' + e.getMessage());
        }
    }

    private static  AccountContactRelation buildAcrRecordWithNewHousehold(String acctContId, String householdId) {
        Boolean isPrimary = false;
        String hhRecId = householdId;
        if(String.isEmpty(hhRecId)) {
            hhRecId = createNewHousehold().Id;
            isPrimary = true;
        }
        
        AccountContactRelation acr = new AccountContactRelation();
        acr.AccountId = hhRecId;
        acr.ContactId = acctContId;
        acr.Roles = null;
        acr.FinServ__Rollups__c = 'All';
        acr.FinServ__PrimaryGroup__c = true;
        acr.FinServ__Primary__c = isPrimary;
        acr.IsActive = true;
        return acr;
    }

    private static Account createNewHousehold() {
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId();
        Account householdAccount = new Account(Name='Household', recordTypeId=householdRecordTypeId, AllowHousehold__c = true);
        UTIL_AccountDAO.insertAccount(householdAccount);
        return householdAccount;
    }

    private static void insertACRrecordsAndGetFailedIds(List<AccountContactRelation> insertACRList) {
        String methodName = 'insertACRrecordsAndGetFailedIds';
        if(insertACRList != null && !insertACRList.isEmpty()) {
            List<Database.SaveResult> insertResultsList = UTIL_HouseholdMemberDAO.insertACRAndReturnSaveResults(insertACRList);
            LoggingService.logDatabaseResult(insertResultsList, insertACRList, CLASS_NAME, methodName, System.LoggingLevel.ERROR);
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
