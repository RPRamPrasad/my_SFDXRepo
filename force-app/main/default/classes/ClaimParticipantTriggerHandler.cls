/**
 * @name ClaimParticipantTriggerHandler
 * @author Moneyball
 * @description Serves as the Apex handler for the Claim Participant triggers.
 */
public with sharing class ClaimParticipantTriggerHandler {
    
    private static final String CLASS_NAME = 'ClaimParticipantTriggerHandler';

    // used by trigger to prevent recursion
    @TestVisible public static Boolean firstcall = false;

    // used by the ClaimParticipantTriggerHandler unit tests to verify that methods are called as expected
    @TestVisible private static Boolean handledMockClaimParticipantInsertOperation = false;

    @TestVisible private static UTIL_ToggleStrategyContext toggleContext = new UTIL_ToggleStrategyContext();

    private ClaimParticipantTriggerHandler(){}
    
    /**
     * @name handleAfterInsert
     * @description handles claim shares for claim participants
     * @param newClaimParticipants list of new claims participants
     */
    public static void handleAfterInsert(List<ClaimParticipant> newClaimParticipants) {
        if (toggleContext.isActive(UTIL_Toggles.CLAIMANT_SHARES)) {
            if (Test.isRunningTest()) {
                handledMockClaimParticipantInsertOperation = true;
            }

            try {
                List<Database.SaveResult> claimSharesData = UTIL_ClaimShareClaimant.insertClaimShares(newClaimParticipants);
                System.debug(LoggingLevel.INFO, 'claimSharesData after insert:' + claimSharesData);
            } catch (Exception e) {
                LoggingService.logHandledException(e, CLASS_NAME, 'handleAfterInsert', System.LoggingLevel.ERROR);
            }
        }
    }

}
