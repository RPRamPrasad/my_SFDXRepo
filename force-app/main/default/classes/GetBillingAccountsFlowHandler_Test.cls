/**
 * @description Test Class for the  GetBillingAccountsFlowHandler class.
 *
 * @author Kiko Ferrer (VAD63S)
 * @version 1.0, 06/15/23
 * @see GetBillingAccountsFlowHandler
 * @since 1.0
*/
@IsTest
public class GetBillingAccountsFlowHandler_Test {
    // System admin fields
    private static final String SYSTEM_ADMIN_EMAIL = 'testsystemadminuser@statefarm.com';
    private static final String SYSTEM_ADMIN_PROFILE_NAME = 'System Administrator';
    private static final String SYSTEM_ADMIN_LAST_NAME = 'systemAdmin';
    private static final String SYSTEM_ADMIN_USERNAME = 'systemAdminTest@statefarm.com';
    private static final String SYSTEM_ADMIN_ALIAS = 'VAD00X';
    // Account (Individual) fields
    private static final String INDIVIDUAL_RECORD_TYPE = 'Individual';
    private static final String ACC_LAST_NAME = 'Doe';
    private static final String ACC_FIRST_NAME = 'John';
    private static final String ACC_CLIENT_IDENT = 'SFFSP81LZYX';
    // Billing Account fields
    private static final String BILL_ACC_NUM_AUTO = '1331330151';
    private static final String BILL_ACC_NUM_FIRE = '0001330876';
    private static final String BILL_ACC_NUM_LIFE = '1119897899';
    private static final String BILL_ACC_NUM_HEALTH = '9897977778';
    // Billing Participant fields
    private static final String BILL_PAR_NAME_AUTO = 'Bill Participant Auto';
    private static final String BILL_PAR_NAME_FIRE = 'Bill Participant Fire';
    private static final String BILL_PAR_NAME_LIFE = 'Bill Participant Life';
    private static final String BILL_PAR_NAME_HEALTH = 'Bill Participant Health';
    
    /**
     * @description Setup method used to create records to be reused accross the different test methods.
     * 
     */
    @testSetup
    private static void setup(){ 
        // Create user with permissions
        User systemAdminUser = new User(ProfileId=[SELECT Id FROM Profile WHERE Name = :SYSTEM_ADMIN_PROFILE_NAME].Id,
                                        LastName=SYSTEM_ADMIN_LAST_NAME,
                                        UserName=SYSTEM_ADMIN_USERNAME,
                                        Alias=SYSTEM_ADMIN_ALIAS,
                                        Email=SYSTEM_ADMIN_EMAIL,
                                        TimeZoneSidKey='Europe/London',
                                        LocaleSidKey='en_US',
                                        EmailEncodingKey='UTF-8',
                                        LanguageLocaleKey='en_US');
        insert systemAdminUser;
        // Bypass triggers for to be able to create test data
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemAdminUser.id);            
        insert sysAdminUserIdSetting;
                // Create Individual Account
        System.runAs(systemAdminUser) {
            Id individualRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
            Account individualAccount = new Account(recordTypeId=individualRecordTypeId, FirstName=ACC_FIRST_NAME, LastName=ACC_LAST_NAME, 
                                                    ClientIdentifier__c=ACC_CLIENT_IDENT, AllowHousehold__c = false, 
                                                    BillingAddressType__c='US', BillingStreet='1234 Main St', BillingCity='Bloomington', BillingState='IL', 
                                                    BillingPostalCode='61704', BillingCountry='UNITED STATES');
            insert individualAccount;
            
                                                                                                                        
            // Create Billing Accounts
            Billing_Account__c billAccAuto = new Billing_Account__c(AccountNumber__c=BILL_ACC_NUM_AUTO, Name=BILL_ACC_NUM_AUTO,
                                                                    SourceSystemIdentifier__c=BILL_ACC_NUM_AUTO, SourceSystem__c='SF Billing', 
                                                                    Status__c='Active');
			insert billAccAuto;
            // Create Billing Participants
            Billing_Participant__c billPartAuto = new Billing_Participant__c(BillingAccountID__c=billAccAuto.Id, Name=BILL_PAR_NAME_AUTO,
                                                                            ParticipantAccountId__c=individualAccount.Id,
                                                                            SourceSystemIdentifier__c='9991330151~BH4NKBKGPPP');
            insert billPartAuto;

    	}
    }
    
    /**
     * @description Method that test a successfull call to the sfBillingAccounts() method returning valid accounts.
     * 
     * @see GetBillingAccountsFlowHandler#sfBillingAccounts()
     */
    @isTest
    static void sfBillingAccountsSuccess() {
        User usr = [SELECT Id FROM User WHERE Alias = :SYSTEM_ADMIN_ALIAS LIMIT 1];
        ID accId = [SELECT Id FROM Account WHERE LastName = :ACC_LAST_NAME LIMIT 1].Id;
        ID billAccId = [SELECT Id FROM Billing_Account__c WHERE Name = :BILL_ACC_NUM_AUTO LIMIT 1].Id;
        List<GetBillingAccountsFlowHandler.OutputVariables> outputList;
        List<GetBillingAccountsFlowHandler.InputVariables> inputVariables = new List<GetBillingAccountsFlowHandler.InputVariables>();
        GetBillingAccountsFlowHandler.InputVariables inputVariable = new GetBillingAccountsFlowHandler.InputVariables();
        inputVariable.accountId = accId;
        inputVariables.add(inputVariable);
        System.runAs(usr) {
            Test.startTest();
  			outputList = GetBillingAccountsFlowHandler.sfBillingAccounts(inputVariables);
            Test.stopTest();
        }
        System.assertEquals(1, outputList.size(), 'Number of billing accounts is not exactly equal to 1');
        Assert.areEqual(billAccId, outputList.get(0).billingAccountIds.get(0), 'Billing account ids do not match');
    }
}
