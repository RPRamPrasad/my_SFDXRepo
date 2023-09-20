/**
 * @name UTIL_ClaimShareHelper
 * @description Utility helper class that create a list of claims and set of ids. 
 */
public without sharing class UTIL_ClaimShareHelper {

    /**
     * @description Creating a list of claims and set of ids
     * @param claims
     * @param policyClaims
     * @param policyNumberIds
     */
    public static void getClaimRecords(List<Claim> claims, List<Claim> policyClaims, Set<Id> policyNumberIds){
        for (Claim claim : claims) {
            if (!String.isEmpty(claim.PolicyNumberId)) {
                policyClaims.add(claim);
                policyNumberIds.add(claim.PolicyNumberId);
            }
        }
    }
}