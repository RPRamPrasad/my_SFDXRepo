/**
@author CustomerView
@owner Team Atlas
@name CCV_HouseholdStripHouseholdMembers
@createDate 01/28/2023
@ModifiedDate 
@description This class is used by LWC accountHouseholdMembers to fetch Household Members data on load
@version 1.0
*/
public with sharing class CCV_HouseholdStripHouseholdRelationships {
    /**
    * @description This method is used to members data in household
    * @name : fetchHouseholdRelationshipsDetails
    * @param hhRecordId : input record id
    * @return HouseholdMembersWrapper : output Household members wrapper
    */
    @AuraEnabled(cacheable = false)
    public static List<Relationship__c> fetchHouseholdRelationshipsDetails(String hhRecordId, String accRecordId) {
        try {
            return getRelationshipDetails(hhRecordId,accRecordId);
        }
        catch(Exception e){
            throw new AuraHandledException('Please refresh/reload page again');
        }
    }

    private static List<Relationship__c> getRelationshipDetails(String hhRecordId, String accRecordId) {
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', hhRecordId, Account.class);
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', accRecordId, Account.class);
        return Security.stripInaccessible(
            AccessType.READABLE,[
                SELECT Id, AccountOne__c, AccountTwo__r.Name, AccountTwo__c, AccountOne__r.Name,
                RelationshipType__c,AccountOne__r.Gender__pc , AccountOne__r.IsNotShareable__pc, AccountOne__r.PersonBirthdate,
                AccountOne__r.Age__c
                FROM Relationship__c 
                WHERE AccountTwo__c=:String.escapeSingleQuotes(accRecordId) 
                AND Primary_Household__c=:String.escapeSingleQuotes(hhRecordId)
                ORDER BY AccountOne__r.Name ASC
            ])
            .getRecords();
    }
}