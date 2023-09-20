/**
@author CustomerView
@owner Team Atlas
@name CCV_RetrieveAccountIdQueryHelper
@createDate 12/10/2022
@ModifiedDate 
@description This class is used to SOQL to get account Id from others objects
@version 1.0
*/
public with sharing class CCV_RetrieveAccountIdQueryHelper {

    /**
    * @description This method is used to retrieve Account Id From Case
    * @name : getAccountIdFromCase
    * @param recordId : input case record id
    * @return String : output AccountId
    */
    public static String getAccountIdFromCase(String recordId) {
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', recordId, Case.class);
        List<Case> caselst = Security.stripInaccessible(
            AccessType.READABLE, [
                SELECT AccountId 
                FROM Case 
                WHERE Id =:String.escapeSingleQuotes(recordId)
            ]
        ).getRecords();

        if(!caselst.isEmpty()) {
            return caselst[0].AccountId;
        }
        return null;
    }
    /**
    * @description This method is used to retrieve Account Id From Case
    * @name : getAccountIdFromOpportunity
    * @param recordId : input Opportunity record id
    * @return String : output AccountId
    */
    public static String getAccountIdFromOpportunity(String recordId) {
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', recordId, Opportunity.class);
        List<Opportunity> opptylst = Security.stripInaccessible(
            AccessType.READABLE, [
                SELECT AccountId 
                FROM Opportunity 
                WHERE Id =:String.escapeSingleQuotes(recordId)
            ]
        ).getRecords();

        if(!opptylst.isEmpty()) {
            return opptylst[0].AccountId;
        }
        return null;
    }

    /**
    * @description This method is used to retrieve Opportunity
    * @name : getOpportunity
    * @param recordId : input Opportunity record id
    * @return String : output Opportunity
    */
    public static Opportunity getOpportunity(String recordId) {
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', recordId, Opportunity.class);
        List<Opportunity> opptlst = Security.stripInaccessible(
            AccessType.READABLE, [
                SELECT Id, AccountId, DisplayDoNotMarket__c, Email__c, Phone__c,
                Total_Calls_Made__c, Total_Email__c, Total_Text__c, Total_Calls__c,
                TCM_New__c, Total_New_Email__c, Total_New_Text__c, Total_New_Calls__c, 
                StageName, OppClosedDateTime__c, OppNotNowFollowUpDateTime__c, Opportunity_Originator__c,
                LOB__c, OfficeAssigned__c, Credit_Status__c
                FROM Opportunity 
                WHERE Id =:String.escapeSingleQuotes(recordId)
            ]
        ).getRecords();
        if(!opptlst.isEmpty()) {
            return opptlst[0];
        }
        return null;
    }
    /**
    * @description This method is used to retrieve Account Id From InsurancePolicy
    * @name : getAccountIdFromInsurancePolicy
    * @param recordId : input InsurancePolicy record id
    * @return String : output NameInsuredId
    */
    public static String getAccountIdFromInsurancePolicy(String recordId) {
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', recordId, InsurancePolicy.class);
        List<InsurancePolicy> policylst = Security.stripInaccessible(
            AccessType.READABLE, [
                SELECT NameInsuredId 
                FROM InsurancePolicy 
                WHERE Id =:String.escapeSingleQuotes(recordId)
            ]
        ).getRecords();
        if(!policylst.isEmpty()) {
            return policylst[0].NameInsuredId;
        }
        return null;
    }
    /**
    * @description This method is used to retrieve Account Id From Claim
    * @name : getAccountIdFromClaim
    * @param recordId : input Claim record id
    * @return String : output AccountId
    */
    public static String getAccountIdFromClaim(String recordId) {
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', recordId, Claim.class);
        List<Claim> claimlst = Security.stripInaccessible(
            AccessType.READABLE, [
                SELECT AccountId 
                FROM Claim 
                WHERE Id =:String.escapeSingleQuotes(recordId)
            ]
        ).getRecords();
        if(!claimlst.isEmpty()) {
            return claimlst[0].AccountId;
        }
        return null;
    }
    /**
    * @description This method is used to retrieve Account Id From Billing_Participant__c
    * @name : getAccountIdFromBillingAccount
    * @param recordId : input BillingAccountID__c record id
    * @return String : output ParticipantAccountId__c
    */
    public static String getAccountIdFromBillingAccount(String recordId) {
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', recordId, Billing_Account__c.class);
        List<Billing_Participant__c> billPartlst = Security.stripInaccessible(
            AccessType.READABLE, [
                SELECT ParticipantAccountId__c, BillingAccountID__r.SourceSystem__c, SFPolicyRoleId__c
                FROM Billing_Participant__c 
                WHERE BillingAccountID__c =:String.escapeSingleQuotes(recordId)
            ]
        ).getRecords();
        if(!billPartlst.isEmpty()) {
            for(Billing_Participant__c billPart: billPartlst) {
                if(billPart.BillingAccountID__r.SourceSystem__c == 'SFPP' && billPart.SFPolicyRoleId__c == 'PAH') {
                    return billPart.ParticipantAccountId__c;
                }
            }
            return billPartlst[0].ParticipantAccountId__c;
        }
        return null;
    }
    /**
    * @description This method is used to retrieve Account Id From FinancialAccountRole__c
    * @name : getAccountIdFromFinancialAccount
    * @param recordId : input FinancialAccountId__c record id
    * @return String : output AccountId__c
    */
    public static String getAccountIdFromFinancialAccount(String recordId) {
        UTIL_ParameterValidator_SalesforceId.isValidSalesforceId('Id', recordId, FinancialAccount__c.class);
        List<FinancialAccountRole__c> finActRolelst = Security.stripInaccessible(
            AccessType.READABLE, [
                SELECT AccountId__c 
                FROM FinancialAccountRole__c 
                WHERE FinancialAccountId__c =:String.escapeSingleQuotes(recordId)
            ]
        ).getRecords();
        if(!finActRolelst.isEmpty()) {
            return finActRolelst[0].AccountId__c;
        }
        return null;
    }
}
