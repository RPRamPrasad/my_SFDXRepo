/**
 * @name ClaimShareQueueable
 * @author Hydra
 * @description Class that inserts and deletes ClaimShare records asynchronously. 
 */
public with sharing class ClaimShareQueueable implements Queueable{

    private List<Claim> claims;
    private Boolean insertSharesOnly;

    /**
     * @name Constructor
     * @description creates a ClaimShareQueueable instance
     * @param claims
     * @param insertSharesOnly 
     */
    public ClaimShareQueueable(List<Claim> claims, Boolean insertSharesOnly) {
        this.claims = claims;
        this.insertSharesOnly = insertSharesOnly;
    }

    /**
     * @name execute
     * @description Manages the claim shares asynchronously.
     * @param context
    */ 
    public void execute(QueueableContext context) {
        if (!CollectionUtils.isNullOrEmptyList(claims)) {
            if (insertSharesOnly) {
                UTIL_ClaimShare.insertClaimShares(claims);
            } else {
                UTIL_ClaimShare.updateClaimShares(claims);
            }            
        }
    }
}
