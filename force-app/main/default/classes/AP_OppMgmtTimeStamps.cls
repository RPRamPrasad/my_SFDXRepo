/**
* @description AP_OppMgmtTimeStamps
* This is a Apex class which will be invoked from before update trigger and validate if the timestamps are null based on the stage of the opportunity
* @Author Team QuadCore
* @Date 9/08/2021
*/
public with sharing class AP_OppMgmtTimeStamps{
    public static final String ASSIGNED = 'Assigned';
    public static final String CONTACT_ESTBLSHD = 'Contact Established';
    public static final String QUOTING = 'Quoting';
    public static final String QUOTE_IN_PROGRESS = 'Quote In Progress';
    public static final String QUOTE_PROVIDED = 'Quote Provided';
    public static final String QUOTE_DISCUSSED= 'Quote Discussed';
    public static final String APPLICATION_PENDING = 'Application Pending';
    public static final String NNFP = 'Not Now -  Follow Up';
    public static final String APP_SUBMITTED = 'App Submitted';
    public static final String CLOSED_WON = 'Closed Won';
    public static final String CLOSED = 'Closed';
    /**
     * @description validateStageAndTimestamps
     *
     * @param updatedOpportunity (Opportunity): updatedOpportunity }
     * @param oldOpportunity (Opportunity): oldOpportunity }
     * @return Opportunity: Return Opportunity
     */
    public static Opportunity validateStageAndTimestamps(Opportunity updatedOpportunity, Opportunity oldOpportunity){
        return validateStageAssignedAndCE(updatedOpportunity, oldOpportunity);
    }
    /**
     * @description validateStageAssignedAndCE
     *
     * @param updatedOpportunity (Opportunity): updatedOpportunity }
     * @param oldOpportunity (Opportunity): oldOpportunity }
     * @return Opportunity: Return Opportunity
     */
    private static Opportunity validateStageAssignedAndCE(Opportunity updatedOpportunity, Opportunity oldOpportunity){
        Opportunity updatedOpp = new Opportunity();
        updatedOpp = updatedOpportunity;
        if (ASSIGNED.equalsIgnoreCase(updatedOpp.stageName) && CONTACT_ESTBLSHD.equalsIgnoreCase(updatedOpp.status__c)){
            updatedOpp = AP_OppMgmtSetTimeStamps.setContactEstablishedDate(updatedOpp);
        } else{
            updatedOpp = validateStageQutoingAndQIPRG(updatedOpp, oldOpportunity);
        }
        return updatedOpp;
    }
    /**
     * @description validateStageQutoingAndQIPRG
     *
     * @param updatedOpportunity (Opportunity): updatedOpportunity }
     * @param oldOpportunity (Opportunity): oldOpportunity }
     * @return Opportunity: Return Opportunity
     */
    private static Opportunity validateStageQutoingAndQIPRG(Opportunity updatedOpportunity, Opportunity oldOpportunity){
        Opportunity updatedOpp = new Opportunity();
        updatedOpp = updatedOpportunity;
        if (QUOTING.equalsIgnoreCase(updatedOpp.stageName) && (QUOTE_IN_PROGRESS.equalsIgnoreCase(updatedOpp.status__c) || ''.equals(updatedOpp.status__c) || null == updatedOpp.status__c)){
            if (updatedOpp.OppQuoteInProgressDateTime__c == null){
                updatedOpp = AP_OppMgmtSetTimeStamps.setQuoteInProgressDateTime(updatedOpp);
                updatedOpp = AP_OppMgmtSetTimeStamps.setContactEstablishedDate(updatedOpp);
            }
        } else{
            updatedOpp = validateStageQutoingAndQPVD(updatedOpp, oldOpportunity);
        }
        return updatedOpp;
    }
    /**
     * @description validateStageQutoingAndQPVD
     *
     * @param updatedOpportunity (Opportunity): updatedOpportunity }
     * @param oldOpportunity (Opportunity): oldOpportunity }
     * @return Opportunity: Return Opportunity
     */
    private static Opportunity validateStageQutoingAndQPVD(Opportunity updatedOpportunity, Opportunity oldOpportunity){
        Opportunity updatedOpp = new Opportunity();
        updatedOpp = updatedOpportunity;
        if (QUOTING.equalsIgnoreCase(updatedOpp.stageName) && QUOTE_PROVIDED.equalsIgnoreCase(updatedOpp.status__c)){
            if (oldOpportunity.OppQuoteProvidedDateTime__c == null || updatedOpp.OppQuoteProvidedDateTime__c == null){
                updatedOpp = AP_OppMgmtSetTimeStamps.setQuoteInProvidedDateTime(updatedOpp);
                updatedOpp = AP_OppMgmtSetTimeStamps.setContactEstablishedDate(updatedOpp);
                updatedOpp = AP_OppMgmtSetTimeStamps.setQuoteInProgressDateTime(updatedOpp);
                updatedOpp = AP_OppMgmtSetTimeStamps.setQuoteProvidedDate(updatedOpp);
                updatedOpp = AP_OppMgmtSetTimeStamps.setTimeToQuoteProvided(updatedOpp);
            }
        } else{
            updatedOpp = AP_OppMgmtSetTimeStamps.validateStageQutoingAndQDISCSD(updatedOpp, oldOpportunity);
        }
        return updatedOpp;
    }
   
 
    /**
     * @description validateStageQutoingAndAppPending
     *
     * @param updatedOpportunity (Opportunity): updatedOpportunity }
     * @param oldOpportunity (Opportunity): oldOpportunity }
     * @return Opportunity: Return Opportunity
     */
    public static Opportunity validateStageQutoingAndAppPending(Opportunity updatedOpportunity, Opportunity oldOpportunity){
        Opportunity updatedOpp = new Opportunity();
        updatedOpp = updatedOpportunity;
        if (QUOTING.equalsIgnoreCase(updatedOpp.stageName) && APPLICATION_PENDING.equalsIgnoreCase(updatedOpp.status__c)){
            if (updatedOpp.OppAppPendingDateTime__C == null){
                updatedOpp = AP_OppMgmtSetTimeStamps.setAppPendingDateTime(updatedOpp);
               updatedOpp = AP_OppMgmtSetTimeStamps.setContactEstablishedDate(updatedOpp);
                updatedOpp = AP_OppMgmtSetTimeStamps.setQuoteInProvidedDateTime(updatedOpp);
                updatedOpp = AP_OppMgmtSetTimeStamps.setQuoteInProgressDateTime(updatedOpp);
                updatedOpp = AP_OppMgmtSetTimeStamps.setQuoteProvidedDate(updatedOpp);
                updatedOpp = AP_OppMgmtSetTimeStamps.setTimeToQuoteProvided(updatedOpp);
            }
        } else{
            updatedOpp = validateStageNNFP(updatedOpp, oldOpportunity);
        }
        return updatedOpp;
    }
    /**
     * @description validateStageNNFP
     *
     * @param updatedOpportunity (Opportunity): updatedOpportunity }
     * @param oldOpportunity (Opportunity): oldOpportunity }
     * @return Opportunity: Return Opportunity
     */
    private static Opportunity validateStageNNFP(Opportunity updatedOpportunity, Opportunity oldOpportunity){
        Opportunity updatedOpp = new Opportunity();
        updatedOpp = updatedOpportunity;
        if ((!updatedOpp.stageName.equals(oldOpportunity.stageName)) && NNFP.equalsIgnoreCase(updatedOpp.stageName) && (updatedOpp.OppNotNowFollowUpDateTime__c == null)){
            updatedOpp.OppNotNowFollowUpDateTime__c = System.now();
        } else{
            updatedOpp = validateStageAppSubmitted(updatedOpp, oldOpportunity);
        }
        return updatedOpp;
    }
    /**
     * @description validateStageAppSubmitted
     *
     * @param updatedOpportunity (Opportunity): updatedOpportunity }
     * @param oldOpportunity (Opportunity): oldOpportunity }
     * @return Opportunity: Return Opportunity
     */
    private static Opportunity validateStageAppSubmitted(Opportunity updatedOpportunity, Opportunity oldOpportunity){
        Opportunity updatedOpp = new Opportunity();
        updatedOpp = updatedOpportunity;
        if ((!updatedOpp.stageName.equals(oldOpportunity.stageName)) && APP_SUBMITTED.equalsIgnoreCase(updatedOpp.stageName)){
            if (updatedOpp.OppAppSubmittedDateTime__c == null){
                updatedOpp = AP_OppMgmtSetTimeStamps.setAppSubmittedDateTime(updatedOpp);
                updatedOpp = AP_OppMgmtSetTimeStamps.setAppPendingDateTime(updatedOpp);
                updatedOpp = AP_OppMgmtSetTimeStamps.setContactEstablishedDate(updatedOpp);
                updatedOpp = AP_OppMgmtSetTimeStamps.setQuoteInProgressDateTime(updatedOpp);
                updatedOpp = AP_OppMgmtSetTimeStamps.setQuoteInProvidedDateTime(updatedOpp);
                updatedOpp = AP_OppMgmtSetTimeStamps.setQuoteProvidedDate(updatedOpp);
                updatedOpp = AP_OppMgmtSetTimeStamps.setTimeToQuoteProvided(updatedOpp);
                updatedOpp = AP_OppMgmtSetTimeStamps.setTimeToAppSubmitted(updatedOpp);
            }
        } else{
            updatedOpp = validateStageClosedWon(updatedOpp, oldOpportunity);
        }
        return updatedOpp;
    }
    /**
     * @description validateStageClosedWon
     *
     * @param updatedOpportunity (Opportunity): updatedOpportunity }
     * @param oldOpportunity (Opportunity): oldOpportunity }
     * @return Opportunity: Return Opportunity
     */
    private static Opportunity validateStageClosedWon(Opportunity updatedOpportunity, Opportunity oldOpportunity){
        Opportunity updatedOpp = new Opportunity();
        updatedOpp = updatedOpportunity;
        if ((!updatedOpp.stageName.equals(oldOpportunity.stageName)) && CLOSED_WON.equalsIgnoreCase(updatedOpp.stageName)){
            if (updatedOpp.OppClosedWonDateTime__c == null){
                updatedOpp.OppClosedWonDateTime__c = System.now();
                updatedOpp = AP_OppMgmtSetTimeStamps.setAppPendingDateTime(updatedOpp);
                updatedOpp = AP_OppMgmtSetTimeStamps.setAppSubmittedDateTime(updatedOpp);
                updatedOpp = AP_OppMgmtSetTimeStamps.setContactEstablishedDate(updatedOpp);
                updatedOpp = AP_OppMgmtSetTimeStamps.setQuoteInProgressDateTime(updatedOpp);
                updatedOpp = AP_OppMgmtSetTimeStamps.setQuoteInProvidedDateTime(updatedOpp);
                updatedOpp = AP_OppMgmtSetTimeStamps.setQuoteProvidedDate(updatedOpp);
                updatedOpp = AP_OppMgmtSetTimeStamps.setTimeToQuoteProvided(updatedOpp);
                updatedOpp = AP_OppMgmtSetTimeStamps.setTimeToAppSubmitted(updatedOpp);
                updatedOpp = AP_OppMgmtSetTimeStamps.setTimeToClose(updatedOpp);
            }
        } else{
            updatedOpp = updateStageClosed(updatedOpp, oldOpportunity);
        }
        return updatedOpp;
    }
    /**
     * @description updateStageClosed description
     *
     * @param updatedOpportunity (Opportunity): updatedOpportunity description}
     * @param oldOpportunity (Opportunity): oldOpportunity description}
     * @return Opportunity: Return Opportunity
     */
    private static Opportunity updateStageClosed(Opportunity updatedOpportunity, Opportunity oldOpportunity){
        Opportunity updatedOpp = new Opportunity();
        updatedOpp = updatedOpportunity;
        if ((!updatedOpp.stageName.equals(oldOpportunity.stageName)) && CLOSED.equalsIgnoreCase(updatedOpp.stageName) && (updatedOpp.OppClosedDateTime__c == null)){
            updatedOpp.OppClosedDateTime__c = System.now();
            updatedOpp = AP_OppMgmtSetTimeStamps.setTimeToClose(updatedOpp);
        }
        return updatedOpp;
    }
}
