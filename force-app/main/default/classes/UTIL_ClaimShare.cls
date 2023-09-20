/**
 * @name UTIL_ClaimShare
 * @author Hydra
 * @description Utility class that inserts and deletes ClaimShare records. 
 */
public without sharing class UTIL_ClaimShare {

    private static final String CLASS_NAME = 'UTIL_ClaimShare';
    private static final String INSERT_METHOD_NAME = 'insertClaimShares';
    private static final String UPDATE_METHOD_NAME = 'updateClaimShares';
    private static final String DELETE_METHOD_NAME = 'deleteClaimShares';

    private static final String ACCESS_LEVEL = 'Read';
    private static final String MANUAL_ROW_CAUSE = 'Manual';

    @TestVisible
    private static UTIL_ToggleStrategyContext toggleContext = new UTIL_ToggleStrategyContext();

    private UTIL_ClaimShare(){}
    
    /**
     * @name insertClaimShares
     * @description inserts ClaimShare records from the given Claim records.
     * @param claims
     * @return List<Database.SaveResult>
     */
    public static List<Database.SaveResult> insertClaimShares(List<Claim> claims) {
        if (!isClaimShareManagementEnabled()) {
            return new List<Database.SaveResult>();
        }
        
        Integer startingCpuTime = captureStartingTime();
        System.debug(LoggingLevel.DEBUG, CLASS_NAME + ' insertClaimShares (Claim) count: ' + claims.size());

        List<Claim> policyClaims = new List<Claim>();
        Set<Id> policyNumberIds = new Set<Id>();

        UTIL_ClaimShareHelper.getClaimRecords(claims, policyClaims, policyNumberIds);

        List<Database.SaveResult> saveResults = insertSharesByPolicyNumbers(policyClaims, policyNumberIds);
        System.debug(LoggingLevel.DEBUG, CLASS_NAME + ' insertClaimShares (Claim) CPU used: ' + (Limits.getCpuTime() - startingCpuTime));
        
        return saveResults;
    }

    private static List<Database.SaveResult> insertSharesByPolicyNumbers(List<Claim> policyClaims, Set<Id> policyNumberIds) {
        List<Database.SaveResult> saveResults = new List<Database.SaveResult>();

        if (!policyClaims.isEmpty()) {
            List<InsurancePolicyShare> policyShares = [SELECT Id, ParentId, UserOrGroupId, RowCause
                                                       FROM InsurancePolicyShare
                                                       WHERE Parent.Id IN :policyNumberIds
                                                       AND RowCause = :MANUAL_ROW_CAUSE];

            Map<Id,List<Id>> proxiesByPolicyMap = getProxiesByPolicyMap(policyShares);
            saveResults = insertClaimShares(policyClaims, proxiesByPolicyMap);
        }

        return saveResults;
    }

    /**
     * @name insertClaimShares
     * @description inserts ClaimShare records from the given InsurancePolicyShare records.
     * @param policyShares
     * @return List<Database.SaveResult>
     */
    public static List<Database.SaveResult> insertClaimShares(List<InsurancePolicyShare> policyShares) {
        if (!isClaimShareManagementEnabled()) {
            return new List<Database.SaveResult>();
        }

        Integer startingCpuTime = captureStartingTime();
        System.debug(LoggingLevel.DEBUG, CLASS_NAME + ' insertClaimShares (InsurancePolicyShare) count: ' + policyShares.size());
        Map<Id,List<Id>> proxiesByPolicyMap = getProxiesByPolicyMap(policyShares);

        List<Claim> claims = [SELECT Id, PolicyNumberId
                              FROM Claim
                              WHERE PolicyNumberId IN :proxiesByPolicyMap.keySet()];
        
        List<Database.SaveResult> results = insertClaimShares(claims, proxiesByPolicyMap);
        System.debug(LoggingLevel.DEBUG, CLASS_NAME + ' insertClaimShares (InsurancePolicyShare) CPU used: ' + (Limits.getCpuTime() - startingCpuTime));

        return results;
    }
    
    /**
     * @name insertClaimShares
     * @description inserts ClaimShare records from the given claims and proxy/policies map.
     * @param claims the list of claims
     * @param proxiesByPolicyMap a map with lists of proxies keyed by policy
     * @return List<Database.SaveResult>
     */
    private static List<Database.SaveResult> insertClaimShares(List<Claim> claims, Map<Id,List<Id>> proxiesByPolicyMap) {
        System.debug(LoggingLevel.Debug, 'insertClaimShares claims count: ' + claims.size());
        
        Integer proxiesCount = 0;
        List<ClaimShare> claimShares = new List<ClaimShare>();
        for (Claim claim : claims) {
            List<Id> proxies = proxiesByPolicyMap.get(claim.PolicyNumberId);
            if (CollectionUtils.isNullOrEmptyList(proxies)) {
                continue;
            }

            proxiesCount += proxies.size();
            for (Id proxyId : proxies) {
                ClaimShare claimShare = new ClaimShare();
                claimShare.ParentId = claim.Id;
                claimShare.UserOrGroupId = proxyId;
                claimShare.AccessLevel = ACCESS_LEVEL;
                claimShare.RowCause = MANUAL_ROW_CAUSE;
                claimShares.add(claimShare);
            }
        }

        System.debug(LoggingLevel.Debug, 'insertClaimShares proxies count: ' + proxiesCount);

        List<Database.SaveResult> saveResults = Database.insert(claimShares, false);
        LoggingService.logDatabaseResult(saveResults, claimShares, CLASS_NAME, INSERT_METHOD_NAME, System.LoggingLevel.ERROR);
        
        return saveResults;
    }

    /**
     * @name updateClaimShares
     * @description inserts new ClaimShare records and deletes ClaimShare records no longer valid, from the given Claim records.
     * @param claims
     * @return List<Object>
     */
    public static List<Object> updateClaimShares(List<Claim> claims) {
        List<Object> results = new List<Object>();
        List<ClaimShare> sharesForDelete = new List<ClaimShare>();
        List<ClaimShare> sharesForInsert = new List<ClaimShare>();

        if (!isClaimShareManagementEnabled()) {
            results.add(new List<Database.SaveResult>());
            results.add(new List<Database.DeleteResult>());
            return results;
        }
        
        Integer startingCpuTime = captureStartingTime();
        System.debug(LoggingLevel.DEBUG, CLASS_NAME + ' updateClaimShares count: ' + claims.size());

        List<ClaimShare> existingSharesList = [SELECT Id, ParentId, UserOrGroupId
                                                FROM ClaimShare
                                                WHERE Parent.Id IN :claims
                                                AND RowCause = :MANUAL_ROW_CAUSE];

        Map<String,ClaimShare> existingShares = new Map<String,ClaimShare>();
        for (ClaimShare existingShare : existingSharesList) {
            existingShares.put(generateClaimShareKey(existingShare), existingShare);
        }

        Map<String,ClaimShare> generatedShares = generateClaimShares(claims, getProxiesByPolicyMap(claims));
        for (String key : existingShares.keySet()) {
            if (!generatedShares.containsKey(key)) {
                sharesForDelete.add(existingShares.get(key));
            }
        }

        for (String key : generatedShares.keySet()) {
            if (!existingShares.containsKey(key)) {
                sharesForInsert.add(generatedShares.get(key));
            }
        }

        List<Database.SaveResult> saveResults = Database.insert(sharesForInsert, false);
        LoggingService.logDatabaseResult(saveResults, sharesForInsert, CLASS_NAME, UPDATE_METHOD_NAME, System.LoggingLevel.ERROR);       
        
        List<Database.DeleteResult> deleteResults = Database.delete(sharesForDelete, false);
        LoggingService.logDatabaseResult(deleteResults, sharesForDelete, CLASS_NAME, UPDATE_METHOD_NAME, System.LoggingLevel.ERROR);

        results.add(saveResults);
        results.add(deleteResults);
        
        System.debug(LoggingLevel.DEBUG, CLASS_NAME + ' updateClaimShares CPU used: ' + (Limits.getCpuTime() - startingCpuTime));

        return results;
    }

    /**
     * @name generateClaimShares
     * @description generates a list of ClaimShare records from the given Claim records and proxy/policy map.
     * @param claims
     * @param proxiesByPolicyMap
     * @return Map<String,ClaimShare>
     */
    private static Map<String,ClaimShare> generateClaimShares(List<Claim> claims, Map<Id,List<Id>> proxiesByPolicyMap) {
        Map<String, ClaimShare> claimShares = new Map<String, ClaimShare>();
		
        Integer startingCpuTime = Limits.getCpuTime();
		
        for (Claim claim : claims) {
            if (proxiesByPolicyMap.containsKey(claim.PolicyNumberId)) {
                List<Id> proxies = proxiesByPolicyMap.get(claim.PolicyNumberId);
                for (Id proxyId : proxies) {
                    ClaimShare claimShare = new ClaimShare();
                    claimShare.ParentId = claim.Id;
                    claimShare.UserOrGroupId = proxyId;
                    claimShare.AccessLevel = ACCESS_LEVEL;
                    claimShare.RowCause = MANUAL_ROW_CAUSE;
                    claimShares.put(generateClaimShareKey(claimShare), claimShare);
                }
            }
        }
        System.debug(LoggingLevel.DEBUG, CLASS_NAME + ' generateClaimShares claimShares count: ' + claimShares.size());
        System.debug(LoggingLevel.DEBUG, CLASS_NAME + ' generateClaimShares CPU: ' + (Limits.getCpuTime() - startingCpuTime));

        return claimShares;
    }

    /**
     * @name generateClaimShareKey
     * @description generates a unique key from a ClaimShare comprised of its ParentId and UserOrGroupId fields.
     * @param claimShare
     * @return String
     */
    private static String generateClaimShareKey(ClaimShare claimShare) {
        return claimShare.ParentId + '-' + claimShare.UserOrGroupId;
    }

    /**
     * @name deleteClaimShares
     * @description deletes ClaimShare records from the given InsurancePolicyShare records.
     * @param policyShares
     * @return Database.DeleteResult
     */
    public static List<Database.DeleteResult> deleteClaimShares(List<InsurancePolicyShare> policyShares) {
        if (!isClaimShareManagementEnabled()) {
            return new List<Database.DeleteResult>();
        }
		
        Integer startingCpuTime = captureStartingTime();
        System.debug(LoggingLevel.DEBUG, CLASS_NAME + ' deleteClaimShares (InsurancePolicyShare) count: ' + policyShares.size());

        Map<Id,List<Id>> proxiesByPolicyMap = getProxiesByPolicyMap(policyShares);
        Set<Id> claimIds = new Map<Id, Claim> ([SELECT Id, PolicyNumberId
                                                FROM Claim
                                                WHERE PolicyNumberId IN :proxiesByPolicyMap.keySet()]).keySet();

        List<ClaimShare> claimShares = [SELECT Id, ParentId, UserOrGroupId, Parent.PolicyNumberId
                                        FROM ClaimShare
                                        WHERE Parent.Id IN :claimIds
                                        AND RowCause = :MANUAL_ROW_CAUSE];
    
        List<ClaimShare> claimSharesToDelete = new List<ClaimShare>();
        for (ClaimShare claimShare : claimShares) {
            List<Id> proxies = proxiesByPolicyMap.get(claimShare.Parent.PolicyNumberId);
            for (Id proxy : proxies) {
                if (proxy.equals(claimShare.UserOrGroupId)) {
                    claimSharesToDelete.add(claimShare);
                }
            }
        }

        List<Database.DeleteResult> deleteResults = Database.delete(claimSharesToDelete, false);
        LoggingService.logDatabaseResult(deleteResults, claimShares, CLASS_NAME, DELETE_METHOD_NAME, System.LoggingLevel.ERROR);
		
        System.debug(LoggingLevel.DEBUG, CLASS_NAME + ' deleteClaimShares (InsurancePolicyShare) CPU used: ' + (Limits.getCpuTime() - startingCpuTime));
		
        return deleteResults;
    }

    /**
     * @name getProxiesByPolicyMap
     * @description Creates a map of proxy lists by policy
     * @param policyShares
     * @return map of proxy lists by policy
     */
    private static Map<Id,List<Id>> getProxiesByPolicyMap(List<InsurancePolicyShare> policyShares) {
        Map<Id,List<Id>> proxiesByPolicyMap = new Map<Id, List<Id>>();
        for (InsurancePolicyShare policyShare : policyShares) {
            if (!MANUAL_ROW_CAUSE.equals(policyShare.RowCause)) {
                continue;
            }

            if (proxiesByPolicyMap.get(policyShare.ParentId) != null) {
                List<Id> proxies = proxiesByPolicyMap.get(policyShare.ParentId);
                proxies.add(policyShare.UserOrGroupId);
            } else {
                proxiesByPolicyMap.put(policyShare.ParentId, new List<Id>{policyShare.UserOrGroupId});
            }
        }

        return proxiesByPolicyMap;
    }

    /**
     * @name getProxiesByPolicyMap
     * @description Creates a map of proxy lists from given Claim records.
     * @param claims
     * @return map of proxy lists by policy
     */
    private static Map<Id,List<Id>> getProxiesByPolicyMap(List<Claim> claims) {
        Set<Id> policyNumberIds = new Set<Id>();

        for (Claim claim : claims) {
            if (!String.isEmpty(claim.PolicyNumberId)) {
                policyNumberIds.add(claim.PolicyNumberId);
            }
        }

        if (!policyNumberIds.isEmpty()) {
            List<InsurancePolicyShare> policyShares = [SELECT Id, ParentId, UserOrGroupId, RowCause
                                                       FROM InsurancePolicyShare
                                                       WHERE Parent.Id IN :policyNumberIds
                                                       AND RowCause = :MANUAL_ROW_CAUSE];
            return getProxiesByPolicyMap(policyShares);
        } else {
            return new Map<Id,List<Id>>();
        }
    }

    private static boolean isClaimShareManagementEnabled() {
        return UTIL_ClaimShare.toggleContext.isActive(UTIL_Toggles.CLAIM_SHARES);
    }

    private static Integer captureStartingTime() {
        Integer startingCpuTime = Limits.getCpuTime();
        Integer remainingCpuTime = Limits.getLimitCpuTime() - startingCpuTime;
        System.debug(LoggingLevel.DEBUG, CLASS_NAME + ' - CPU time remaining: ' + remainingCpuTime);
        return startingCpuTime;
    }

}