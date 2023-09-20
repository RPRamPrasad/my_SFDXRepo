/****************************************************************************************
Name: VFC_ProductsWithOthersCompetitors_TEST
Copyright © State Farm
=========================================================================================
Purpose:
-------
Description: Test class for VFC_ProductsWithOthersCompetitors
Team: TrailBlazers
=========================================================================================
History
-------
VERSION         AUTHOR                           DATE                   DETAIL
1.0             Muralidharan Narasimhan (QKI7)   04/10/2018             Initial Development
2.0             ClubCar                          11/12/2018             Updated Testdata to cover shared Agent scenario
3.0				Kraken							 4/18/2019				Updated to Work with FSC Package
******************************************************************************************/
@isTest (seeAllData=false)
/**
 * @description VFC_ProductsWithOthersCompetitors_TEST
 */
public class VFC_ProductsWithOthersCompetitors_TEST {

    private static String agentProfileId = getProfileId(UTIL_Constants.AGENT_PROFILE_NAME);
    private static String proxyProfileId = getProfileId(UTIL_Constants.PROXY_PROFILE_NAME);
    private static String adminProfileId = getProfileId(UTIL_Constants.SYSTEM_ADMIN_PROFILE_NAME);
    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap=Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();
   	private static String recordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId;
    static User agentUser;
    static User adminUser;
    static Account acc; 

    @testSetup
/**
 * @description setUp
 */
    public static void setUp() {
    UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
	UTIL_OverrideSystemUser_TEST.doOverride();
      string userName='TestAdminUser@statefarm.com.bad';
      User admin_User = new User();
      admin_User.email = userName;
      admin_User.userName = userName;
      admin_User.lastname=userName.substringBefore('@');
      admin_User.profileId=adminProfileId;
      admin_User.Associate_ID__c='';
      admin_User.Servicing_Agent_Associate_ID__c='';
      admin_User.UserExternalID__c='';
      admin_User.UserType__c='';
      admin_User.State_Agent_Code__c='';
        User adminUser1 = buildUser(admin_User);
        insert adminUser1;
        //User agentUser, proxyUser, systemUser;
        User agentUser1;
        
        System.runAs(adminUser1) {
            byPassTrigger();

            UserRole agentUserRole = buildUserRole('AgentRole');
            insert agentUserRole;

            string userName1='TestAgentUser@statefarm.com.bad';
            User agent_User = new User();
            agent_User.email = userName1;
            agent_User.userName = userName1;
            agent_User.profileId=agentProfileId;
            agent_User.Associate_ID__c='ASSOCID0001';
            agent_User.Servicing_Agent_Associate_ID__c='ASSOCID0001';
            agent_User.UserExternalID__c='ASSOCID0001_ASSOCID0001';
            agent_User.UserType__c='Agent';
            agent_User.State_Agent_Code__c='23-7172';        
            agent_User.lastname=userName1.substringBefore('@');                  


            agentUser1 = buildUser(agent_User);
            agentUser1.userRoleId = agentUserRole.id;
            insert agentUser1;

        }
    }
/**
 * @description testProductsWithOthersCompetitorsForAccountAsAgentUser
 */
    @isTest
    public static void testProductsWithOthersCompetitorsForAccountAsAgentUser() {
        queryTestData();
        List<ProductsWithOthersCompetitors__x> productsWithOthersCompetitorsList = new List<ProductsWithOthersCompetitors__x>();
        ProductsWithOthersCompetitors__x pwc = new ProductsWithOthersCompetitors__x();
        pwc.ExternalId='ExternalID01';
        pwc.StateAgentCode__c='AGTSTATECD1';
        pwc.CarrierName__c='GEICO';
        pwc.ClientID__c='ClientID01';
        pwc.ExpirationDate__c= Date.today();
        pwc.ExternalAgreementId__c='ExternalAgr01';
        pwc.ProductComments__c='Comments01';
        pwc.ProductLine__c='Fire';
        pwc.ProductType__c='Home Owners';
        productsWithOthersCompetitorsList.add(pwc);
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            Test.startTest(); 
            Account testAccnt = createAccount('ClientID01');
            insert testAccnt;
           
            VFC_ProductsWithOthersCompetitors ctr = new VFC_ProductsWithOthersCompetitors();
            ctr.accountClientIdInContext = testAccnt.ClientIdentifier__c;
            ctr.accountIdInContext = testAccnt.id;
            ctr.isPWOCAccessible = true;
            Map<String, Account> accountMapByClientId = new Map<String, Account>();
            accountMapByClientId.put(testAccnt.ClientIdentifier__c, testAccnt);
            ctr.accountMapByClientIdObj = accountMapByClientId;
            ctr.groupId = '';

            ctr.mockODATAProductsWithOthersCompetitorsList.addAll(productsWithOthersCompetitorsList);
            ctr.fetchProductsWithOthersCompetitors();
            System.assertEquals('', ctr.displayMessage,'Expected displayMessage is empty, but actual value is'+ctr.displayMessage);
            
            List<VFC_ProductsWithOthersCompetitors.ProductsWithOthersCompetitorsWrapper> productsWithOthersCompetitorsWrapperResultantList = ctr.productsWithOthersCompetitorsList;
            System.assertEquals(productsWithOthersCompetitorsList.size(), productsWithOthersCompetitorsWrapperResultantList.size(),'Expected Resultant List size is'+productsWithOthersCompetitorsList.size()+productsWithOthersCompetitorsWrapperResultantList.size()+', but actual value is'+productsWithOthersCompetitorsWrapperResultantList.size());
            for(VFC_ProductsWithOthersCompetitors.ProductsWithOthersCompetitorsWrapper testProductsWithOthersCompetitorsWrapper: productsWithOthersCompetitorsWrapperResultantList) {
                System.assertEquals('GEICO', testProductsWithOthersCompetitorsWrapper.carrierName,'Expected carrier Name is GEICO, but actual value is'+testProductsWithOthersCompetitorsWrapper.carrierName);
                //System.assertEquals('carrierCode01', testProductsWithOthersCompetitorsWrapper.carrierCode);
                System.assertEquals(Date.today().format(), testProductsWithOthersCompetitorsWrapper.expirationDate,'Expected Expiration Date is'+Date.today().format()+', but actual is'+testProductsWithOthersCompetitorsWrapper.expirationDate);
                System.assertEquals('Fire', testProductsWithOthersCompetitorsWrapper.productLine,'Expected Product Line is Fire, but actual is'+testProductsWithOthersCompetitorsWrapper.productLine);
                System.assertEquals('Home Owners', testProductsWithOthersCompetitorsWrapper.productType,'Expected product Type is Home Owners, but actual is'+testProductsWithOthersCompetitorsWrapper.productType);
                //System.assertEquals(buildPWOCUrl(testAccnt.id, 'ClientID01', 'AGTSTATECD1', 'ExternalAgr01', 'Fire', 'carrierCode01', 'GEICO', 'Home //Owners', '10/04/2018', 'Comments01'), testProductsWithOthersCompetitorsWrapper.PWOCDetailPageURL);
            }
            Test.stopTest();
        }
    }
/**
 * @description testProductsWithOthersCompetitorsFeatureDisabled
 */
    @isTest
    public static void testProductsWithOthersCompetitorsFeatureDisabled() {
        queryTestData();
        List<ProductsWithOthersCompetitors__x> productsWithOthersCompetitorsList = new List<ProductsWithOthersCompetitors__x>();
        ProductsWithOthersCompetitors__x pwc = new ProductsWithOthersCompetitors__x();
        pwc.ExternalId='ExternalID01';
        pwc.StateAgentCode__c='AGTSTATECD1';
        pwc.CarrierName__c='GEICO';
        pwc.ClientID__c='ClientID01';
        pwc.ExpirationDate__c= Date.today();
        pwc.ExternalAgreementId__c='ExternalAgr01';
        pwc.ProductComments__c='Comments01';
        pwc.ProductLine__c='Fire';
        pwc.ProductType__c='Home Owners';
        productsWithOthersCompetitorsList.add(pwc);
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            Test.startTest();
            Account testAccnt = createAccount('ClientID01');
            insert testAccnt;
            
            VFC_ProductsWithOthersCompetitors ctr = new VFC_ProductsWithOthersCompetitors();
            ctr.accountClientIdInContext = testAccnt.ClientIdentifier__c;
            ctr.accountIdInContext = testAccnt.id;
            ctr.isPWOCAccessible = false;
            Map<String, Account> accountMapByClientId = new Map<String, Account>();
            accountMapByClientId.put(testAccnt.ClientIdentifier__c, testAccnt);
            ctr.accountMapByClientIdObj = accountMapByClientId;
            ctr.groupId = '';
            
            ctr.mockODATAProductsWithOthersCompetitorsList.addAll(productsWithOthersCompetitorsList);
            ctr.fetchProductsWithOthersCompetitors();
            System.assertEquals(Label.CL_FEATURE_DOWN, ctr.displayMessage,'Expected Display Message is'+Label.CL_FEATURE_DOWN+', but actual is'+ctr.displayMessage);
        }
        Test.stopTest();
    }
/**
 * @description testProductsWithOthersCompetitorsForGroupAsAgentUser 
 */
    @isTest
    public static void testProductsWithOthersCompetitorsForGroupAsAgentUser() {
        queryTestData();
        List<ProductsWithOthersCompetitors__x> productsWithOthersCompetitorsList = new List<ProductsWithOthersCompetitors__x>();
        ProductsWithOthersCompetitors__x pwc = new ProductsWithOthersCompetitors__x();
        pwc.ExternalId='ExternalID02';
        pwc.StateAgentCode__c='AGTSTATECD1';
        pwc.CarrierName__c='GEICO';
        pwc.ClientID__c='ClientID02';
        pwc.ExpirationDate__c= Date.today();
        pwc.ExternalAgreementId__c='ExternalAgr02';
        pwc.ProductComments__c='Comments02';
        pwc.ProductLine__c='Fire';
        pwc.ProductType__c='Home Owners';
        productsWithOthersCompetitorsList.add(pwc);
        ProductsWithOthersCompetitors__x pwoc = new ProductsWithOthersCompetitors__x();
        pwoc.ExternalId='ExternalID03';
        pwoc.StateAgentCode__c='AGTSTATECD1';
        pwoc.CarrierName__c='AllState';
        pwoc.ClientID__c='ClientID03';
        pwoc.ExpirationDate__c= Date.today();
        pwoc.ExternalAgreementId__c='ExternalAgr03';
        pwoc.ProductComments__c='Comments03';
        pwoc.ProductLine__c='Auto';
        pwoc.ProductType__c='Private Passenger';
        productsWithOthersCompetitorsList.add(pwoc);
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            Test.startTest();
            Account testAccnt2 = createAccount('ClientID02');
            insert testAccnt2;
            Account testAccnt3 = createAccount('ClientID03');
            insert testAccnt3;
            List<Account> testAccountList = new List<Account> ();
            testAccountList.add(testAccnt2);
            testAccountList.add(testAccnt3);
            CustomerGroup__c customerGroup = createCustomerGroup(agentUser, testAccountList);
           
            VFC_ProductsWithOthersCompetitors ctr = new VFC_ProductsWithOthersCompetitors();
            ctr.accountIdInContext = testAccnt2.id;
            ctr.groupId = customerGroup.id;
            ctr.isPWOCAccessible = true;

            ctr.mockODATAProductsWithOthersCompetitorsList.addAll(productsWithOthersCompetitorsList);

            ctr.fetchProductsWithOthersCompetitors();
            System.assertEquals('', ctr.displayMessage,'Expected displayMessage is empty, but actual value is'+ctr.displayMessage);
            List<VFC_ProductsWithOthersCompetitors.ProductsWithOthersCompetitorsWrapper> productsWithOthersCompetitorsWrapperResultantList = ctr.productsWithOthersCompetitorsList;
            System.assertEquals(productsWithOthersCompetitorsList.size(), productsWithOthersCompetitorsWrapperResultantList.size(),'Expected Resultant List size is'+productsWithOthersCompetitorsList.size()+productsWithOthersCompetitorsWrapperResultantList.size()+', but actual value is'+productsWithOthersCompetitorsWrapperResultantList.size());
            for(VFC_ProductsWithOthersCompetitors.ProductsWithOthersCompetitorsWrapper testProductsWithOthersCompetitorsWrapper: productsWithOthersCompetitorsWrapperResultantList) {
                if('GEICO'.equals(testProductsWithOthersCompetitorsWrapper.carrierName)) {
                    System.assertEquals('GEICO', testProductsWithOthersCompetitorsWrapper.carrierName,'Expected carrier Name is GEICO, but actual value is'+testProductsWithOthersCompetitorsWrapper.carrierName);
                    //System.assertEquals('carrierCode01', testProductsWithOthersCompetitorsWrapper.carrierCode);
                    System.assertEquals(Date.today().format(), testProductsWithOthersCompetitorsWrapper.expirationDate,'Expected Expiration Date is'+Date.today().format()+', but actual is'+testProductsWithOthersCompetitorsWrapper.expirationDate);
                    System.assertEquals('Fire', testProductsWithOthersCompetitorsWrapper.productLine,'Expected Product Line is Fire, but actual is'+testProductsWithOthersCompetitorsWrapper.productLine);
                    System.assertEquals('Home Owners', testProductsWithOthersCompetitorsWrapper.productType,'Expected product Type is Home Owners, but actual is'+testProductsWithOthersCompetitorsWrapper.productType);
                    //System.assertEquals(buildPWOCUrl(testAccnt2.id, 'ClientID02', 'AGTSTATECD1', 'ExternalAgr02', 'Fire', 'carrierCode01', 'GEICO', //'Home Owners', '11/05/2018', 'Comments02'), testProductsWithOthersCompetitorsWrapper.PWOCDetailPageURL);
                } else if ('AllState'.equals(testProductsWithOthersCompetitorsWrapper.carrierName)) {
                    System.assertEquals('AllState', testProductsWithOthersCompetitorsWrapper.carrierName,'Expected carrier Name is AllState, but actual value is'+testProductsWithOthersCompetitorsWrapper.carrierName);
                    //System.assertEquals('carrierCode02', testProductsWithOthersCompetitorsWrapper.carrierCode);
                    System.assertEquals(Date.today().format(), testProductsWithOthersCompetitorsWrapper.expirationDate,'Expected Expiration Date is'+Date.today().format()+', but actual is'+testProductsWithOthersCompetitorsWrapper.expirationDate);
                    System.assertEquals('Auto', testProductsWithOthersCompetitorsWrapper.productLine,'Expected Product Line is Auto, but actual is'+testProductsWithOthersCompetitorsWrapper.productLine);
                    System.assertEquals('Private Passenger', testProductsWithOthersCompetitorsWrapper.productType,'Expected product Type is Private Passenger, but actual is'+testProductsWithOthersCompetitorsWrapper.productType);
                    //System.assertEquals(buildPWOCUrl(testAccnt3.id, 'ClientID03', 'AGTSTATECD1', 'ExternalAgr03', 'Auto', 'carrierCode02', 'AllState', //'Private Passenger', '05/12/2019', 'Comments03'), testProductsWithOthersCompetitorsWrapper.PWOCDetailPageURL);
                } else {
                    System.assert(false, 'Wrong Carrier in the list');
                }
            }
            Test.stopTest();
        }
    }
    
//  private static String buildPWOCUrl(String accountId, String cliendId, String agentAssociateId, String externalAgreementId, String productLine, //String carrierCode, String carrierName, String productType, String expirationDate, String productComments){
//        //When expiration date is available use the following append statement for expiration date
//        // LinkConstants.AMPERSAND_SYMBOL+ LinkConstants.EXPIRATION_DATE+LinkConstants.EQUALS_SYMBOL+expirationDate+    
//        return '/apex/VFP_PwocDetails?createMode=false' + LinkConstants.AMPERSAND_SYMBOL + LinkConstants.INPUT_PARAM_ACCOUNT_ID + //LinkConstants.EQUALS_SYMBOL + accountId +
//                LinkConstants.AMPERSAND_SYMBOL+ LinkConstants.AGENT_ASSOCIATE_ID+LinkConstants.EQUALS_SYMBOL + agentAssociateId+
//                LinkConstants.AMPERSAND_SYMBOL+ LinkConstants.CLIENT_ID+LinkConstants.EQUALS_SYMBOL+cliendId+
//                LinkConstants.AMPERSAND_SYMBOL+ LinkConstants.EXTERNAL_AGREEMENT_ID +LinkConstants.EQUALS_SYMBOL+externalAgreementId+
//                LinkConstants.AMPERSAND_SYMBOL+ LinkConstants.PRODUCT_LINE+LinkConstants.EQUALS_SYMBOL+productLine+ 
//                LinkConstants.AMPERSAND_SYMBOL+ LinkConstants.CARRIER_CODE+LinkConstants.EQUALS_SYMBOL+carrierCode+
//                LinkConstants.AMPERSAND_SYMBOL+ LinkConstants.CARRIER_NAME+LinkConstants.EQUALS_SYMBOL+carrierName+
//                LinkConstants.AMPERSAND_SYMBOL+ LinkConstants.PRODUCT_TYPE+LinkConstants.EQUALS_SYMBOL+productType+
                
//                LinkConstants.AMPERSAND_SYMBOL+ LinkConstants.EXPIRATION_DATE+LinkConstants.EQUALS_SYMBOL+'oDataPWOC.ExpirationDate__c'+
//                LinkConstants.AMPERSAND_SYMBOL+ LinkConstants.PRODUCT_COMMENTS+LinkConstants.EQUALS_SYMBOL+productComments;
//    }
/**
 * @description testProductsWithOthersCompetitorsForAccountNoRecordsFoundAsAgentUser
 */
    @isTest
    public static void testProductsWithOthersCompetitorsForAccountNoRecordsFoundAsAgentUser() {
        queryTestData();        
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            Test.startTest();
            Account testAccnt = createAccount('ClientID01');
            insert testAccnt;
            VFC_ProductsWithOthersCompetitors ctr = new VFC_ProductsWithOthersCompetitors();
            ctr.accountClientIdInContext = testAccnt.ClientIdentifier__c;
            ctr.accountIdInContext = testAccnt.id;
            Map<String, Account> accountMapByClientId = new Map<String, Account>();
            accountMapByClientId.put(testAccnt.ClientIdentifier__c, testAccnt);
            ctr.accountMapByClientIdObj = accountMapByClientId;
            ctr.groupId = '';
            ctr.isPWOCAccessible = true;
            
            ctr.fetchProductsWithOthersCompetitors();
            System.assertEquals(Label.CL_NO_RECORDS, ctr.displayMessage,'Expected Display Message is'+Label.CL_NO_RECORDS+', but actual is'+ctr.displayMessage);
            System.assert(ctr.productsWithOthersCompetitorsList == null || ctr.productsWithOthersCompetitorsList.size() == 0, 'resultantList');
            Test.stopTest();
        }
    }
    /**
     * @description testProductsWithOthersCompetitorsForGroupForExceptionAsAgentUser
     */
    @isTest
    public static void testProductsWithOthersCompetitorsForGroupForExceptionAsAgentUser() {
        queryTestData();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            Test.startTest();
            Account testAccnt4 = createAccount('ClientID04');
            insert testAccnt4;
            List<Account> testAccountList = new List<Account> ();
            // create Customer Group with no members ie. empty account list
            CustomerGroup__c customerGroup = createCustomerGroup(agentUser, testAccountList);
            VFC_ProductsWithOthersCompetitors ctr = new VFC_ProductsWithOthersCompetitors();
            ctr.accountIdInContext = testAccnt4.id;
            ctr.groupId = customerGroup.id;
            ctr.isPWOCAccessible = true;
            ctr.fetchProductsWithOthersCompetitors();
            System.assertEquals(Label.CL_TRY_LATER, ctr.displayMessage,'Expected Display Message is'+Label.CL_TRY_LATER+', but actual is'+ctr.displayMessage);   
            Test.stopTest();
        }
    }
    
    //method to build Account record with the given clientID
    /**
     * @description createAccount
     * @param clientIdentifier 
     * @return Account
     */ 
    
    public static Account createAccount(String clientIdentifier){
        Account getAccount = new Account(FirstName = 'tst1', LastName='Ltst'+clientIdentifier, ClientIdentifier__c  = clientIdentifier);
        return getAccount;
    }
    
    //method to get the ProfileId for the given Profile Name
    private static String getProfileId(String profileName) {
        String profileId = TestDataFactory_Helper_ProfileLookup.lookupProfileID(profileName);
        return profileId;
    }
    
    //method to build user with the given parameter value
    private static User buildUser(User sampleUser) {
        User testUser = new User (alias = 'XXXX', email = sampleUser.email, emailencodingkey='UTF-8', lastname=sampleUser.lastname,
            languagelocalekey='en_US',localesidkey='en_US', timezonesidkey='America/Chicago', 
            username= sampleUser.userName, profileId = sampleUser.profileId, Associate_ID__c = sampleUser.Associate_ID__c, 
            Servicing_Agent_Associate_ID__c = sampleUser.Servicing_Agent_Associate_ID__c , UserExternalID__c = sampleUser.UserExternalID__c, UserType__c = sampleUser.UserType__c, State_Agent_Code__c=sampleUser.State_Agent_Code__c);
        return testUser;
    }
    
    //method to bypass Trigger
    private static void byPassTrigger() {
        CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c();
        objectBasedByPassTrigger.Override_All__c = true;
        insert objectBasedByPassTrigger;
    }
    
    //method to build User Role with the given parameter value
    private static UserRole buildUserRole(String roleName) {
        UserRole role = new UserRole(name = roleName);
        return role;
    }
    
    //method to build User Role with parentRoleId as the given parameter value
    private static UserRole buildUserRole(String roleName, String parentRoleId) {
        UserRole role = new UserRole(name = roleName, parentRoleId = parentRoleId);
        return role;
    }
    
    //Query the test data
    /**
     * @description queryTestData
     */
    
    public static void queryTestData(){
        agentUser = [Select Id, Associate_ID__c , UserExternalID__c, UserType__c,  Servicing_Agent_Associate_ID__c,  Servicing_Agent_External_ID__c from User where username = 'TestAgentUser@statefarm.com.bad'];
        adminUser = [Select Id from User where username = 'TestAdminUser@statefarm.com.bad'];
    }
    
    //method to create Customer Group
    /**
     * @description createCustomerGroup
     * @param agentUser 
     * @param testAccountList 
     * @return  `CustomerGroup__c`
     */
    
    public static CustomerGroup__c createCustomerGroup(User agentUser, List<Account> testAccountList){
        CustomerGroup__c cg = new CustomerGroup__c();
        cg.name = 'Primary Household';
        cg.sfgroupidentifier__c = 'ABCD1234567';
        cg.OwnerId = agentUser.Id;
        insert cg;
        List<CustomerGroupMember__c> memberList = new List<CustomerGroupMember__c>();
        for(Account testAccount : testAccountList){
          CustomerGroupMember__c custGrpMember = new CustomerGroupMember__c();
          custGrpMember.customer__c = testAccount.id;
          custGrpMember.group__c = cg.id;
          custGrpMember.groupmemberid__c = cg.sfgroupidentifier__c + '~' + testAccount.clientidentifier__c;
          memberList.add(custGrpMember);
        }
        if(!(memberList== null || memberList.isEmpty())) {
            insert memberList;
        }
        return cg;
    }
    
    
}