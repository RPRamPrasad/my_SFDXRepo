/**
 * @name ClaimTriggerHandler
 * @author NSYNC
 * @description Serves as the Apex handler for the Claim triggers.
 */
public with sharing class ClaimTriggerHandler {
    private static final String CLAIM_SYNC_PROCESS_NAME = 'SF_CRM_FSCCLAIMSYNC';
    public static Boolean recursiveTriggerCheck = false;

    // used by the ClaimTriggerHandler unit tests to verify that methods are called as expected
    @TestVisible private static Boolean handledMockClaimSyncOperation = false;

    @TestVisible
    private static UTIL_ToggleStrategyContext toggleContext = new UTIL_ToggleStrategyContext();

    private ClaimTriggerHandler(){}
    
    /**
     * @name handleAfterInsert
     * @description performs operations, such as ClaimShare management.
     * @param newClaims set of new claims
     */
    public static void handleAfterInsert(Set<Claim> newClaims) {
        Set<Claim> dedupInsertSet = new Set<Claim>(newClaims);
        List<Claim> dedupedClaimList = new List<Claim>(dedupInsertSet);
        
        Set<Claim> totalLossClaims = new Set<Claim>();
        for(Claim claimRecord : newClaims){
            if(claimIsTotalLossEligible(claimRecord)){
                   totalLossClaims.add(claimRecord);
            }
        }
		
        if(!totalLossClaims.isEmpty()){
            ClaimTotalLossTaskHandler.determineTotalLossClaims(totalLossClaims, 'insert');
        }
        
        if (isClaimSyncUser()) {           
            if (Test.isRunningTest()) {
                handledMockClaimSyncOperation = true;
            }
            
            if (isClaimTriggerTransactionEnabled()) {
                UTIL_ClaimShare.insertClaimShares(dedupedClaimList);
                System.debug(LoggingLevel.DEBUG, 'Inserted claim shares in the same transaction');
            } else {
                Id jobId = System.enqueueJob(new ClaimShareQueueable(dedupedClaimList, true));
                System.debug(LoggingLevel.DEBUG, 'Inserted claim shares with a queueable. Job ID: ' + jobId);
            }
        }
    }

    /**
     * @name handleAfterUpdate
     * @description performs operations, such as ClaimShare management.
     * @param triggerContext
     */
    public static void handleAfterUpdate(ClaimTriggerHandler.ClaimAfterUpdateTriggerContext triggerContext) {
        Set<Claim> duplicateEventRemovalSet = new Set<Claim>(triggerContext.getUpdatedClaims());
        Set<Claim> totalLossIndicatorChange = new Set<Claim>();
        
        for(Claim oldClaim : triggerContext.getOldClaimsMap().Values()){
            Claim updatedClaim = triggerContext.getUpdatedClaimsMap().get(oldClaim.Id);
            if(!oldClaim.TotalLossIndicator__c && updatedClaim.TotalLossIndicator__c && claimIsTotalLossEligible(updatedClaim)){
                totalLossIndicatorChange.add(updatedClaim);
            }
        }
        if(totalLossIndicatorChange.isEmpty()==false){
            ClaimTotalLossTaskHandler.determineTotalLossClaims(totalLossIndicatorChange, 'update');   
        }

        List<Claim> dedupedClaimsList = new List<Claim>(duplicateEventRemovalSet);
        if (isClaimSyncUser()) {
            if (Test.isRunningTest()) {
                handledMockClaimSyncOperation = true;
            }
            
            if (isClaimTriggerTransactionEnabled()) {
                UTIL_ClaimShare.updateClaimShares(dedupedClaimsList);
                System.debug(LoggingLevel.DEBUG, 'Updated claim shares in the same transaction');
            } else {
                Id jobId = System.enqueueJob(new ClaimShareQueueable(dedupedClaimsList, false));
                System.debug(LoggingLevel.DEBUG, 'Updated claim shares with a queueable. Job ID: ' + jobId);
            }
        }
    }

    /**
     * @name isClaimSyncUser
     * @description Answers if Claim Sync is the running user
     * @return true if running as the Claim Sync user
     */
    @TestVisible
    private static Boolean isClaimSyncUser() {
        return UserInfo.getName().equals(CLAIM_SYNC_PROCESS_NAME);
    }

    private static boolean isClaimTriggerTransactionEnabled() {
        return ClaimTriggerHandler.toggleContext.isActive(UTIL_Toggles.CLAIM_TRIGGER_TRANSACTION);
    }

    /**
    * @name ClaimAfterUpdateTriggerContext
    * @author NSYNC
    * @description collects the new and old trigger context variables.
    */
    public with sharing class ClaimAfterUpdateTriggerContext {
        private List<Claim> updatedClaims;
        Map<Id,Claim> updatedClaimsMap;
        List<Claim> oldClaims;
        Map<Id,Claim> oldClaimsMap;

        /**
        * @name setUpdatedValues
        * @param updatedClaims
        * @param updatedClaimsMap
        * @description Accepts the list and map of claims that have been updated
        */
        public void setUpdatedValues(List<Claim> updatedClaims, Map<Id,Claim> updatedClaimsMap) {
            this.updatedClaims = updatedClaims;
            this.updatedClaimsMap = updatedClaimsMap;
        }

        /**
        * @name setOldValues
        * @param oldClaims
        * @param oldClaimsMap
        * @description Accepts the list and map of claims with their previous values before the update occurred.
        */
        public void setOldValues(List<Claim> oldClaims, Map<Id,Claim> oldClaimsMap) {
            this.oldClaims = oldClaims;
            this.oldClaimsMap = oldClaimsMap;
        }

        /**
        * @name getUpdatedClaims
        * @return list of updated claims
        * @description Returns the list of updated claims
        */
        public List<Claim> getUpdatedClaims() {
            return this.updatedClaims;
        }

        /**
        * @name getOldClaimsMap
        * @return map of  claims' previous values
        * @description Returns the map of old claims
        */
        public Map<Id,Claim> getOldClaimsMap() {
            return this.oldClaimsMap;
        }
        
        /**
        * @name getUpdatedClaimsMap
        * @return map of updated claims
        * @description Returns the map of updated claims
        */
        public Map<Id,Claim> getUpdatedClaimsMap() {
            return this.updatedClaimsMap;
        }
    }

    private static Boolean claimIsTotalLossEligible(Claim claimRecord){
            return (claimRecord.ProdLineCd__c == 'A' && claimRecord.TotalLossIndicator__c && (claimRecord.ClaimStatusCd__c =='N' || claimRecord.ClaimStatusCd__c =='O'|| claimRecord.ClaimStatusCd__c =='R'));
    }
}