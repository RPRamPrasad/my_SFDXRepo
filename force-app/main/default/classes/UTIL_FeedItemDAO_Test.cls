/**
@Author Team Dream Builders/Impact Force
@Name UTIL_FeedItemDAO_Test
@CreateDate 11/10/2016
@description Common class to access various Task related operations for various Processor Test.
@Version 2.0
*/
@isTest(seeAllData=false)
private class UTIL_FeedItemDAO_Test {
    //mock system admin user
    private static User sysAdminUser = buildtestUser('remCmpMemSysAd@statefarm.com',UTIL_Constants.SYSTEM_ADMIN_PROFILE_NAME);
    private final static String ORIGINAL_CLIENT_TEST_ID = 'BBB5S6J0O';
    private static Integer countFeedItemBeforeInsert = [SELECT count() FROM FeedItem];
    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap=Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();
	private static String recordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId;
    /**
     * @description This method sets up for the test
	 */
    @TestSetup
    public static void setup() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=true);
        insert passTriggerAll;
    }
    /**
     * @description This method is used for to build a test API user with a specific Profile
     * 
     * @param t_lastName
     * @param profileName
     * @return User - user for testing
     */ 
    public static User buildtestUser(String t_lastName, String profileName) {
        Profile testProfile=[Select Id from Profile where name = :profileName LIMIT 1];
        User testUser= new User(alias = 'testFeed', email= 'testuserFeed@statefarm.com', profileid = testProfile.id,
                                emailencodingkey='UTF-8', lastname=t_lastName, languagelocalekey='en_US', 
                                localesidkey='en_US', timezonesidkey='Europe/London', username= t_lastName+'@statefarm.com');
        return testUser;
    }
    
    /**
     * @description This method is used to create new account
     * 
     * @param clientIdentifier String 
     * @return Account - record
     */
    public static Account createAccount(String clientIdentifier){
        Account getAccount = new Account(FirstName = 'tst1',LastName='Ltst'+clientIdentifier, ClientIdentifier__c = clientIdentifier,Edit_In_VFP__c = true,RecordTypeId = recordTypeId);
        return getAccount;
    }
    
   	/**
   	 * @description Test class that tests the method insertFeedItems
   	 * 
	 */
     @isTest
    private static void testInsertFeedItems() {
        
        List<Account> accountList = new List<Account>();
		accountList.add(createAccount(ORIGINAL_CLIENT_TEST_ID));
        System.runas(sysAdminUser){
            insert accountList;
        }
		List<FeedItem> feedItemList = createFeedItemList();
       
        System.runAs(sysAdminUser){
            test.startTest();
			UTIL_FeedItemDAO.insertFeedItems(feedItemList);
            FeedItem ft = [SELECT Id, Body FROM FeedItem WHERE CreatedById IN (SELECT Id FROM User WHERE Alias = 'testFeed')];
            System.assertEquals('testtest', ft.Body,'Expected value is testtest, but actual value is '+ft.Body);
            test.stopTest();
        }
    }
    
    /**
   	 * @description Test class that tests the method insertFeedItems failure
   	 * 
	 */
    @isTest
    private static void testInsertFeedItemsFailure() {
        
        List<Account> accountList = new List<Account>();
		accountList.add(createAccount(ORIGINAL_CLIENT_TEST_ID));
        System.runas(sysAdminUser){
            UTIL_AccountDAO.insertAccounts(accountList) ;
        }
        System.runAs(sysAdminUser){
            test.startTest();
			UTIL_FeedItemDAO.insertFeedItems(null);
            test.stopTest();
            Integer countFeedItemAfterInsert = [SELECT count() FROM FeedItem];
            System.assertEquals(countFeedItemBeforeInsert, countFeedItemAfterInsert,'Expected value is '+countFeedItemBeforeInsert+', but actual value is '+countFeedItemAfterInsert);            
        }
    }
    
    
    /**
   	 * @description Test class that tests the method updateFeedItems 
   	 * 
	 */
    @isTest
    private static void testUpdateFeedItems() {
        
        List<Account> accountList = new List<Account>();
		accountList.add(createAccount(ORIGINAL_CLIENT_TEST_ID));
        System.runas(sysAdminUser){
            UTIL_AccountDAO.insertAccounts(accountList) ;
        }
        System.runAs(sysAdminUser){
            List<FeedItem> feedItemList = createFeedItemList();
            test.startTest();
			UTIL_FeedItemDAO.insertFeedItems(feedItemList);
            FeedItem ft1 = [SELECT Id, Body FROM FeedItem WHERE CreatedById IN (SELECT Id FROM User WHERE Alias = 'testFeed')];
            ft1.Body = 'zeev';
            UTIL_FeedItemDAO.updateFeedItems(new List<FeedItem>{ft1});
            test.stopTest();
            FeedItem ft = [SELECT Id, Body FROM FeedItem WHERE CreatedById IN (SELECT Id FROM User WHERE Alias = 'testFeed')];
            System.assertEquals('zeev', ft.body,'Expected value is zeev, but actual value is '+ft.Body);            
        }
    }
     
    /**
   	 * @description Test class that tests the method updateFeedItems failure
   	 * 
	 */
    @isTest
    private static void testUpdateFeedItemsFailure() {
        
        List<Account> accountList = new List<Account>();
		accountList.add(createAccount(ORIGINAL_CLIENT_TEST_ID));
        System.runas(sysAdminUser){
            UTIL_AccountDAO.insertAccounts(accountList) ;
        }
        System.runAs(sysAdminUser){
            List<FeedItem> feedItemList = createFeedItemList();
            test.startTest();
			UTIL_FeedItemDAO.insertFeedItems(feedItemList);
            FeedItem ft1 = [SELECT Id, Body FROM FeedItem WHERE CreatedById IN (SELECT Id FROM User WHERE Alias = 'testFeed')];
            ft1.Body = 'zeev';
            UTIL_FeedItemDAO.updateFeedItems(null);
            test.stopTest();
            FeedItem ft = [SELECT Id, Body FROM FeedItem WHERE CreatedById IN (SELECT Id FROM User WHERE Alias = 'testFeed')];
            System.assertEquals('testtest', ft.body,'Expected value is testtest, but actual value is '+ft.Body);           
        }
    }
    
     /**
   	 * @description Test class that tests the method updateFeedItems 
   	 * 
	 */
    @isTest
    private static void testUpsertFeedItems() {
        
        List<Account> accountList = new List<Account>();
		accountList.add(createAccount(ORIGINAL_CLIENT_TEST_ID));
        System.runas(sysAdminUser){
            UTIL_AccountDAO.insertAccounts(accountList) ;
        }
        System.runAs(sysAdminUser){
            List<FeedItem> feedItemList = createFeedItemList();
            test.startTest();
			UTIL_FeedItemDAO.insertFeedItems(feedItemList);
            FeedItem ft1 = [SELECT Id, Body FROM FeedItem WHERE CreatedById IN (SELECT Id FROM User WHERE Alias = 'testFeed')];
            ft1.Body = 'zeev';
            UTIL_FeedItemDAO.upsertFeedItems(new List<FeedItem>{ft1});
            test.stopTest();
            FeedItem ft = [SELECT Id, Body FROM FeedItem WHERE CreatedById IN (SELECT Id FROM User WHERE Alias = 'testFeed')];
            System.assertEquals('zeev', ft.body,'Expected value is zeev, but actual value is '+ft.Body);            
        }
    }
    
        /**
   	 * @description Test class that tests the method upsertFeedItems failure
   	 * 
	 */
    @isTest
    private static void testUpsertFeedItemsFailure() {
        
        List<Account> accountList = new List<Account>();
		accountList.add(createAccount(ORIGINAL_CLIENT_TEST_ID));
        System.runas(sysAdminUser){
            UTIL_AccountDAO.insertAccounts(accountList);
        }
        System.runAs(sysAdminUser){
            List<FeedItem> feedItemList = createFeedItemList();
            test.startTest();
			UTIL_FeedItemDAO.insertFeedItems(feedItemList);
            FeedItem ft1 = [SELECT Id, Body FROM FeedItem WHERE CreatedById IN (SELECT Id FROM User WHERE Alias = 'testFeed')];
            ft1.Body = 'zeev';
            UTIL_FeedItemDAO.upsertFeedItems(null);
            test.stopTest();
            FeedItem ft = [SELECT Id, Body FROM FeedItem WHERE CreatedById IN (SELECT Id FROM User WHERE Alias = 'testFeed')];
            System.assertEquals('testtest', ft.body,'Expected value is testtest, but actual value is '+ft.Body);           
        }
    }
        
   	/**
   	 * @description Test class that tests the method DeleteFeedItems
   	 * 
	 */
     @isTest
    private static void testDeleteFeedItems() {
        
        List<Account> accountList = new List<Account>();
		accountList.add(createAccount(ORIGINAL_CLIENT_TEST_ID));
        System.runas(sysAdminUser){
            insert accountList;
        }
		List<FeedItem> feedItemList = createFeedItemList();
       
        System.runAs(sysAdminUser){
            test.startTest();
			UTIL_FeedItemDAO.insertFeedItems(feedItemList);
            FeedItem ft1 = [SELECT Id FROM FeedItem WHERE CreatedById IN (SELECT Id FROM User WHERE Alias = 'testFeed')];
            UTIL_FeedItemDAO.deleteFeedItems(new List<FeedItem>{ft1});
            test.stopTest();
            Integer countFeedItemAfterInsert = [SELECT count() FROM FeedItem];
            System.assertEquals(countFeedItemBeforeInsert, countFeedItemAfterInsert,'Expected value is '+countFeedItemBeforeInsert+', but actual value is '+countFeedItemAfterInsert);
            
        }
    }
    
       	/**
   	 * @description Test class that tests the method DeleteFeedItems failure
   	 * 
	 */
     @isTest
    private static void testDeleteFeedItemsFailure() {
        
        List<Account> accountList = new List<Account>();
		accountList.add(createAccount(ORIGINAL_CLIENT_TEST_ID));
        System.runas(sysAdminUser){
            insert accountList;
        }
		List<FeedItem> feedItemList = createFeedItemList();
       
        System.runAs(sysAdminUser){
            test.startTest();
			UTIL_FeedItemDAO.insertFeedItems(feedItemList);
            UTIL_FeedItemDAO.deleteFeedItems(null);
            test.stopTest();
            Integer countFeedItemAfterInsert = [SELECT count() FROM FeedItem];
            System.assertEquals(countFeedItemBeforeInsert, countFeedItemAfterInsert-1,'Expected value is '+countFeedItemBeforeInsert+', but actual value is '+(countFeedItemAfterInsert-1));
            
        }
    }

	/**
   	 * @description createFeedItemList - Create list of feed items
   	 * @return List<FeedItem>
	 */    
    private static List<FeedItem> createFeedItemList(){
        List<FeedItem> feedItemList = new List<FeedItem>();
        FeedItem post = new Feeditem();
        
        post.Body = 'testtest';
        post.Title = 'testtest2';
        Account acctOriFeedParent = [SELECT Id FROM Account WHERE ClientIdentifier__c =:ORIGINAL_CLIENT_TEST_ID];
        post.ParentId = acctOriFeedParent.id;
        
        feedItemList.add(post);
        
        return feedItemList;
    }

}