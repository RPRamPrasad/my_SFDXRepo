@IsTest(seeAllData=false)
public class AP_AccountMessageCleanupMCxDate_Test {

    public static User sysAdminUser = TestDataFactory_User.getSysAdminUser();

    private static final String OWNER_ID = '005210000078F7gAAE';
    private static final String CLASS_NAME = 'AP_AccountMessageJourneyCleanup';
    private static final String CLOSED_WON = 'Closed Won';
    private static final String CLOSED = 'Closed';
    private static final String AUTO = 'Auto';
    private static final String PRIVATE_PASSENGER = 'Private Passenger';
    private static final String XDATE_JOURNEY_SOURCE = 'Marketing Cloud - X-Date Journey';
    private static final String NOT_NOW_FOLLOW_UP = 'Not Now - Follow Up';
    private static final String CANCEL_JOURNEY = 'Cancelled - stopped journey';
    private static final String SCHEDULED = 'Scheduled';
    /**
     * @description setUp
     */
    @testSetup
    public static void setUp(){   
        AccountMessage__c accountMessage = new AccountMessage__c();
        accountMessage.OpportunityId__c = generateOldOpportunities().values()[0].Id;

        TestDataFactory_Account.byPassAgentRoleBeforeTrigger();
        TestDataFactory_Account.byPassAccountBeforeTrigger();

        Account account = TestDataFactory_Account.createIndividualCustomer('Alex');
        account = TestDataFactory_Account.insertAccount(account);

        accountMessage.Account__c = account.Id;
        accountMessage.Source__c = XDATE_JOURNEY_SOURCE;
        accountMessage.OpportunityId__c = '0062100000DeyLmAAJ';
        accountMessage.Status__c = SCHEDULED;
        insert accountMessage;

    }

    @isTest
    static void updateMCXDateOpportunityAccountMessages() {
        Map<ID, Opportunity> oldOpportunities = generateOldOpportunities();
        List<Opportunity> updatedOpportunities = generateUpdatedOpportunities();

        AP_AccountMessageCleanupMCxDate accountMessageCleanup = new AP_AccountMessageCleanupMCxDate();
        accountMessageCleanup.deleteAccountMessagesOfClosedMarketingCloudXDateJourneyOpportunities(oldOpportunities,updatedOpportunities);

        List<AccountMessage__c> accountMessages = [SELECT id,Status__c from AccountMessage__c limit 1];

        System.assertEquals(accountMessages.size(),1,'accountMessages size should be 1');
        System.assertEquals(accountMessages[0].Status__c,CANCEL_JOURNEY,'Expected value is '+accountMessages[0].Status__c+ ' ,but actual value is ' +CANCEL_JOURNEY);
    }
    @isTest
    static void doesNotUpdateMCXDateOpportunityAccountMessages() {
        Map<ID, Opportunity> oldOpportunities = generateOldOpportunities();
        List<Opportunity> updatedOpportunities = generateUpdatedOpportunities();
        oldOpportunities.put('0062100000DeyLmAAJ',new Opportunity());
        updatedOpportunities[0] = new Opportunity();
        AP_AccountMessageCleanupMCxDate accountMessageCleanup = new AP_AccountMessageCleanupMCxDate();
        accountMessageCleanup.deleteAccountMessagesOfClosedMarketingCloudXDateJourneyOpportunities(oldOpportunities,updatedOpportunities);

        List<AccountMessage__c> accountMessages = [SELECT id,Status__c from AccountMessage__c limit 1];

        System.assertEquals(accountMessages.size(),1,'accountMessages size should be 1');
        System.assertEquals(accountMessages[0].Status__c,SCHEDULED,'Expected value is '+accountMessages[0].Status__c+ ' ,but actual value is ' +SCHEDULED);
    }
    private static Map<ID, Opportunity> generateOldOpportunities(){
        Map<ID,Opportunity> opportunities = new Map<ID,Opportunity>();

        Opportunity opportunity1 = new Opportunity(Id='0062100000DeyLmAAJ',StageName=NOT_NOW_FOLLOW_UP,LOB__c = AUTO, Product__c=PRIVATE_PASSENGER, OwnerId =OWNER_ID);
        Opportunity opportunity2 = new Opportunity(Id='0062100000DeyLmAAL',StageName='New',LOB__c = AUTO, Product__c=PRIVATE_PASSENGER, OwnerId =OWNER_ID);
        Opportunity opportunity3 = new Opportunity(Id='0062100000DeyLmAAK',StageName=NOT_NOW_FOLLOW_UP,LOB__c = 'Fire', Product__c=PRIVATE_PASSENGER, OwnerId =OWNER_ID);
        Opportunity opportunity4 = new Opportunity(Id='0062100000DeyLmAAH',StageName=NOT_NOW_FOLLOW_UP,LOB__c = AUTO, Product__c='cat', OwnerId =OWNER_ID);
        Opportunity opportunity5 = new Opportunity(Id='0062100000DeyLmAAG',StageName=NOT_NOW_FOLLOW_UP,LOB__c = AUTO, Product__c='cat', OwnerId =OWNER_ID);
        Opportunity opportunity6 = new Opportunity(Id='0062100000DeyLmAAF',StageName=NOT_NOW_FOLLOW_UP,LOB__c = 'Fire', Product__c=PRIVATE_PASSENGER, OwnerId =OWNER_ID);


        opportunities.put(opportunity1.Id, opportunity1);
        opportunities.put(opportunity2.Id, opportunity2);
        opportunities.put(opportunity3.Id, opportunity3);
        opportunities.put(opportunity4.Id, opportunity4);
        opportunities.put(opportunity5.Id, opportunity5);
        opportunities.put(opportunity6.Id, opportunity6);

        return opportunities;
    }

    private static List<Opportunity> generateUpdatedOpportunities(){
        List<Opportunity> opportunities = generateOldOpportunities().values();

        opportunities[0].StageName = CLOSED;
        opportunities[3].StageName = CLOSED_WON;
        opportunities[4].StageName = CLOSED_WON;
        opportunities[5].StageName = CLOSED;

        return opportunities;
    }
}