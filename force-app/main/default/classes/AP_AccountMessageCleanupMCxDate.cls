/**
 * @description AP_AccountMessageCleanupMCxDate
 */
public with sharing class AP_AccountMessageCleanupMCxDate {
    private static final String CLASS_NAME = 'AP_AccountMessageJourneyCleanup';
    private static final String CLOSED_WON = 'Closed Won';
    private static final String CLOSED = 'Closed';
    private static final String AUTO = 'Auto';
    private static final String PRIVATE_PASSENGER = 'Private Passenger';
    private static final String XDATE_JOURNEY_SOURCE = 'Marketing Cloud - X-Date Journey';
    private static final String CANCEL_JOURNEY = 'Cancelled - stopped journey';
    private static final String SCHEDULED = 'Scheduled';
    private static final String XDATE_JOURNEY_NAME = 'X-Date_Journey';
    private static final Integer NUMBER_OF_SENDS_PER_ENTRY = 2;

    private void updateAccountMessagesToCancelled(List<AccountMessage__c> accountMessages) {
        try{
            List<AccountMessage__c> updatedAccountMessages = new List<AccountMessage__c>();
            for(AccountMessage__c accountMessage :accountMessages){
                accountMessage.Status__c = CANCEL_JOURNEY;
                updatedAccountMessages.add(accountMessage);
            }
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, updatedAccountMessages);
            update securityDecision.getRecords();
        } catch(DmlException e) {
            Util_MessageLogger.error(CLASS_NAME,e.getMessage(),e);
        }
    }
    private Set<Id> getPossibleMCXDateOpportunitiesSetToClosed(Map<ID, Opportunity> oldOpportunities, List<Opportunity> updatedOpportunities){
        Set<Id> possibleClosedXDateOpportunities = new Set<Id>();
        Boolean isPossibleXDateOpportunity;
        for(Opportunity updatedOpportunity: updatedOpportunities){

            isPossibleXDateOpportunity = false;
            Opportunity oldOpportunity = oldOpportunities.get(updatedOpportunity.Id);

            if(CLOSED_WON.equalsIgnoreCase(updatedOpportunity.StageName) ||CLOSED.equalsIgnoreCase(updatedOpportunity.StageName) && !oldOpportunity.StageName.equalsIgnoreCase(updatedOpportunity.StageName) && AUTO.equalsIgnoreCase(updatedOpportunity.LOB__c) && PRIVATE_PASSENGER.equalsIgnoreCase(updatedOpportunity.Product__c)){


                        isPossibleXDateOpportunity = true;
            }
            if(isPossibleXDateOpportunity){
                possibleClosedXDateOpportunities.add(updatedOpportunity.Id);
            }
        }
        return possibleClosedXDateOpportunities;
    }
    private List<AccountMessage__c> getXDateAccountMessagesByOpportunityIdAndSource(Set<Id> opportunityIds,String source){
        

        List<AccountMessage__c> accountMessages = Security.stripInaccessible(AccessType.READABLE, [SELECT id,OpportunityId__c, Source__c from accountmessage__c where OpportunityId__c in :opportunityIds and Source__c = :source and Status__c = :SCHEDULED], true).getRecords();

        return accountMessages;
    }
/**
 * @description deleteAccountMessagesOfClosedMarketingCloudXDateJourneyOpportunities
 * @param oldOpportunities 
 * @param updatedOpportunities 
 */
    public void deleteAccountMessagesOfClosedMarketingCloudXDateJourneyOpportunities(Map<ID, Opportunity> oldOpportunities, List<Opportunity> updatedOpportunities){
        Set<Id> opportunityIds = getPossibleMCXDateOpportunitiesSetToClosed(oldOpportunities, updatedOpportunities);
        List<AccountMessage__c> accountMessages = new List<AccountMessage__c>();
        if(opportunityIds.size() > 0){
            accountMessages = getXDateAccountMessagesByOpportunityIdAndSource(opportunityIds, XDATE_JOURNEY_SOURCE);
            updateAccountMessagesToCancelled(accountMessages);
        }


        if(accountMessages.size() > 0){
            AP_MarketingCloudUpdateBudget budgetUpdate = new AP_MarketingCloudUpdateBudget();
            AP_MarketingCloudUpdateBudget.AP_MarketingCloudUpdateBudgetWrapper journeyBudgetWrap = new AP_MarketingCloudUpdateBudget.AP_MarketingCloudUpdateBudgetWrapper();
            journeyBudgetWrap.opportunities = oldOpportunities;
            journeyBudgetWrap.accountMessages = accountMessages;
            journeyBudgetWrap.journeyName = XDATE_JOURNEY_NAME;
            journeyBudgetWrap.divideCostPerEntryBy = NUMBER_OF_SENDS_PER_ENTRY;
            budgetUpdate.returnMoneyToMCJourneyBudget(journeyBudgetWrap);
        }

    }
}
