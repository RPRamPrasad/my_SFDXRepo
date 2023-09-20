@isTest
(seeAllData = false)
private class AO_QuickActionsHHControllerTest {
    private static final String CLIENT_IDENTIFIER1 = '12345678909';
    private static final String CLIENT_IDENTIFIER2 = '98765432101';
    private static Account account1;
    private static Account account2;
    private static Account household;
    private static List<Account> accounts;
    
    @testSetup
    private static void testSetup() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        TestUserSetupUtility.setupSystemAdminUser();
    }
    
    @isTest 
    private static void testGetHouseholdMembers() {
        System.runAs(TestUserSetupUtility.getSysAdminUser()) {
            createAccounts();
            insert accounts;
            createHousehold();
            updateAccountsWithHHId();
            Test.startTest();
            List<Account> hhMembers = AO_QuickActionsHHController.getHouseholdMembers(household.id);
            Test.stopTest();
            System.assertEquals(2, hhMembers.size(), 'household members were not found');
        }
    }

    @isTest 
    private static void testGetHouseholdMembersError() {
        System.runAs(TestUserSetupUtility.getSysAdminUser()) {
            createAccounts();
            insert accounts;
            createHousehold();
            updateAccountsWithHHId();
            Test.startTest();
            try{
                AO_QuickActionsHHController.isCatch = true;
                List<Account> hhMembers = AO_QuickActionsHHController.getHouseholdMembers(null);
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage(), 'Expected exception to match.');
            }            
            Test.stopTest();            
        }
    }

    @isTest 
    private static void testGetRecentlyAccessedAccountIdError() {
        System.runAs(TestUserSetupUtility.getSysAdminUser()) {
            createAccounts();
            insert accounts;
            createHousehold();
            updateAccountsWithHHId();
            Test.startTest();
            try{
                AO_QuickActionsHHController.isCatch = true;
                Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.household');
                sessionPart.put(household.id, account1.Id);
                String accountId = AO_QuickActionsHHController.getRecentlyAccessedAccountId(household.id);
            }catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage(), 'Expected exception to match.');
            }          
            Test.stopTest();
        }
    }

    @isTest 
    private static void testGetRecentlyAccessedAccountId() {
        System.runAs(TestUserSetupUtility.getSysAdminUser()) {
            createAccounts();
            insert accounts;
            createHousehold();
            updateAccountsWithHHId();
            Test.startTest();
            Cache.SessionPartition sessionPart = Cache.Session.getPartition('local.household');
            sessionPart.put(household.id, account1.Id);
            String accountId = AO_QuickActionsHHController.getRecentlyAccessedAccountId(household.id);
            Test.stopTest();
            System.assertEquals(account1.Id, accountId, 'household members were not found');
        }
    }

    
    
    private static void createAccounts() {
        account1 = new Account( 
            FirstName = 'FirstName1',
            LastName = 'LastName1',
            BillingAddressType__c = 'US',
            ClientIdentifier__c = CLIENT_IDENTIFIER1
        );

        account2 = new Account(
            FirstName = 'FirstName2',
            LastName = 'LastName2',
            BillingAddressType__c = 'US',
            ClientIdentifier__c = CLIENT_IDENTIFIER2
        );
        
        accounts = new List<Account>();
        accounts.add(account1);
        accounts.add(account2);
    }
    
    private static void createHousehold() {
        Id hhRecordtype = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName()
            .get('IndustriesHousehold')
            .getRecordTypeId();
        household = new Account(Name = 'Household', recordTypeId = hhRecordtype, AllowHousehold__c = true);
        insert household;
    }
    
    private static void updateAccountsWithHHId() {
        for (Account account : accounts) {
            account.Primary_Household__pc = household.Id;
        }
        update accounts;
    }
}