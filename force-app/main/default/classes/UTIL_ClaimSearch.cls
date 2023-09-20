/**
* @author : Team Moneyball
* @name UTIL_ClaimSearch
* @description : finds claims using insurance policy and insurance policy participants
* for the account page in ECRM 3.0
*/
public with sharing class UTIL_ClaimSearch {

    private UTIL_ClaimSearch(){}
    
    /**
     * @name getClaimsByInsurancePolicyForAccount
     * @param clientIdentifier
     * @description returns a list of claims
     * @return List<Claim>
     */
    public static List<Claim> getClaimsByInsurancePolicyForAccount(String clientIdentifier) {
        // Using set to remove duplicates while the policy team adds the policy's named insured to 
        // InsurancePolicyParticipant object.  Once policy team fully implements this change, the call
        // to UTIL_ClaimSearch.getClaimsByInsurancePolicy can be deleted.
        Set<Claim> claims = new Set<Claim>(UTIL_ClaimSearch.getClaimsByInsurancePolicy(clientIdentifier));
        claims.addAll(UTIL_ClaimSearch.getClaimsByInsurancePolicyParticipant(clientIdentifier));
        return new List<Claim>(claims);
    }

    /**
     * @name getClaimsByHousehold
     * @param householdId
     * @description returns a list of claims
     * @return List<Claim>
     */
    public static List<Claim> getClaimsByHousehold(Id householdId) {
        return Security.stripInaccessible(
            AccessType.READABLE,
            [
                SELECT 
                    Id,
                    Name,
                    Status,
                    ClaimDescription__c,
                    PolicyNumber.Name,
                    PolicyNumber.AgreAccessKey__c,
                    PolicyNumber.Servicing_Agent__r.State_Agent_Code__c,
                    LossDate__c,
                    Account.Name,
                    ExternalClaimHandlerCompanyCd__c
                FROM Claim 
                WHERE FinServ__Household__c =: householdId
            ]).getRecords();
    }

    private static List<Claim> getClaimsByInsurancePolicy(String clientIdentifier) {
        return Security.stripInaccessible(
            AccessType.READABLE,
            [
                SELECT 
                    Id,
                    Name,
                    Status,
                    ClaimDescription__c,
                    PolicyNumber.Name,
                    PolicyNumber.AgreAccessKey__c,
                    PolicyNumber.Servicing_Agent__r.State_Agent_Code__c,
                    LossDate__c,
                    Account.Name,
                    ExternalClaimHandlerCompanyCd__c
                FROM Claim 
                WHERE PolicyNumberId IN (
                    SELECT Id 
                    FROM InsurancePolicy 
                    WHERE NameInsured.ClientIdentifier__c = :clientIdentifier
                )
            ]).getRecords();
    }

    private static List<Claim> getClaimsByInsurancePolicyParticipant(String clientIdentifier) {
        return Security.stripInaccessible(
            AccessType.READABLE,
            [
                SELECT 
                    Id,
                    Name,
                    Status,
                    ClaimDescription__c,
                    PolicyNumber.Name,
                    PolicyNumber.AgreAccessKey__c,
                    PolicyNumber.Servicing_Agent__r.State_Agent_Code__c,
                    LossDate__c,
                    Account.Name,
                    ExternalClaimHandlerCompanyCd__c
                FROM Claim 
                WHERE PolicyNumberId 
                IN (
                    SELECT InsurancePolicyId 
                    FROM InsurancePolicyParticipant 
                    WHERE PrimaryParticipantAccount.ClientIdentifier__c = :ClientIdentifier
                )
            ]).getRecords();
    }
}
