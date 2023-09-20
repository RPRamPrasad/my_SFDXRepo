@isTest(SeeAllData='false')
public class AT_ClaimDetailControllerTest 
{
    public static String testClientId = 'XT2PC0D3001';
    
    private static final String PAYLOAD = '{"serviceStatus":{"status":1},"payload":[{"links":[{"rel":"self","href":"https://claimsvc-test1.test.statefarm.com/claiminvestigation-api-estimates/v2,clmivtapiestimates-env3.cfapps-71b.opr.test.statefarm.org/claiminvestigation-api-estimates/v2/api/claims/05e31f75-4920-4bce-b336-c9c56ac36f78/vehicles/1/estimates"}], "performedBy": "CAPITOL BODY SHOP EAST", "performedByDate": "2011-04-04 15:50:56.0", "id": "g1qlSqPDxcGF0", "lineItemTotals": { "grossTotal": "4604.14", "netTotal": "4104.14", "partsAmount": "3287.53", "othersAmount": "490.21", "towAmount": "0.00", "laborAmount": "826.40", "laborHours": "8.0" }, "estimateVersion": "3", "type": "Final" }, { "links": [ { "rel": "self", "href": "https://claimsvc-test1.test.statefarm.com/claiminvestigation-api-estimates/v2,clmivtapiestimates-env3.cfapps-71b.opr.test.statefarm.org/claiminvestigation-api-estimates/v2/api/claims/05e31f75-4920-4bce-b336-c9c56ac36f78/vehicles/1/estimates" } ], "performedBy": "CAPITOL BODY SHOP EAST", "performedByDate": "2011-03-29 12:17:14.0", "id": "g1qlSqPDxcGF0", "lineItemTotals": { "grossTotal": "4461.64", "netTotal": "3961.64", "partsAmount": "3154.36", "othersAmount": "480.88", "towAmount": "0.00", "laborAmount": "826.40", "laborHours": "8.0" }, "estimateVersion": "0", "type": "Original" }, { "links": [ { "rel": "self", "href": "https://claimsvc-test1.test.statefarm.com/claiminvestigation-api-estimates/v2,clmivtapiestimates-env3.cfapps-71b.opr.test.statefarm.org/claiminvestigation-api-estimates/v2/api/claims/05e31f75-4920-4bce-b336-c9c56ac36f78/vehicles/1/estimates" } ], "performedBy": "CAPITOL BODY SHOP EAST", "performedByDate": "2011-04-01 08:13:25.0", "id": "g1qlSqPDxcGF0", "lineItemTotals": { "grossTotal": "4529.29", "netTotal": "4029.29", "partsAmount": "3217.58", "othersAmount": "485.31", "towAmount": "0.00", "laborAmount": "826.40", "laborHours": "8.0" }, "estimateVersion": "1", "type": "Supplemental" }, { "links": [ { "rel": "self", "href": "https://claimsvc-test1.test.statefarm.com/claiminvestigation-api-estimates/v2,clmivtapiestimates-env3.cfapps-71b.opr.test.statefarm.org/claiminvestigation-api-estimates/v2/api/claims/05e31f75-4920-4bce-b336-c9c56ac36f78/vehicles/1/estimates" } ], "performedBy": "CAPITOL BODY SHOP EAST", "performedByDate": "2011-04-01 13:37:59.0", "id": "g1qlSqPDxcGF0", "lineItemTotals": { "grossTotal": "4604.14", "netTotal": "4104.14", "partsAmount": "3287.53", "othersAmount": "490.21", "towAmount": "0.00", "laborAmount": "826.40", "laborHours": "8.0" }, "estimateVersion": "2", "type": "Supplemental" } ] }';
    
    public static User sysAdminUser = TestDataFactory_User.getSysAdminUser();

    @isTest
    public static void testIsOriginalDocumentUploadVisible() {

        Boolean expected = AT_ClaimDetailController.toggleContext.isActive(UTIL_Toggles.DISPLAY_ORIGINAL_DOCUMENT_UPLOAD);
        Boolean actual1;
        Test.startTest();
        Boolean actual = AT_ClaimDetailController.isOriginalDocumentUploadVisible();
        try {
            AT_ClaimDetailController.isErrorTest=true;
            actual1 = AT_ClaimDetailController.isOriginalDocumentUploadVisible();
        }
        catch(Exception ex) {
            System.assertEquals('Script-thrown exception', ex.getMessage(), 'Exception thrown');
        }
        Test.stopTest();

        System.assertEquals(expected, actual, 'Actual value returned from isOriginalDocumentUploadVisible does not match expected value');
    }

    @isTest
    public static void testChatEligibleUsers() {
        User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678913');
        agent = TestDataFactory_User.insertUser(agent);

        User agentTeamMember = TestDataFactory_User_Wrapper.generateAgentTeamMemberUser('TEST', '12345678914');
        agentTeamMember = TestDataFactory_User.insertUser(agentTeamMember);

        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agent,agentTeamMember});

        Boolean agentResult = null;
        Boolean agentResult1 = null;
        Boolean agentTeamMemberResult = null;
        
        Test.startTest();
        System.runAs(agent) {
            agentResult = AT_ClaimDetailController.isUserEligibleForClaimsChat();
        }
        System.runAs(agentTeamMember) {
            agentTeamMemberResult = AT_ClaimDetailController.isUserEligibleForClaimsChat();
        }
        try {
            AT_ClaimDetailController.isErrorTest=true;
            agentResult1 = AT_ClaimDetailController.isUserEligibleForClaimsChat();
        }
        catch(Exception ex) {
            System.assertEquals('Script-thrown exception', ex.getMessage(), 'Exception thrown');
        }
        Test.stopTest();

        System.assertEquals(true, agentResult, 'Agent result should be true');
        System.assertEquals(true, agentTeamMemberResult, 'Agent team member result should be true');
    }
    
    @isTest
    public static void testChatIneligibleUser() {
        User cccUser = TestDataFactory_User_Wrapper.generateActiveCCCLicensedUser('TEST', '12345678913');
        cccUser = TestDataFactory_User.insertUser(cccUser);
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccUser);

        Boolean result = null;
        Boolean result1 = null;
        Test.startTest();
        System.runAs(cccUser) {
            result = AT_ClaimDetailController.isUserEligibleForClaimsChat();
        }
        try {
            AT_ClaimDetailController.isErrorTest=true;
            result1 = AT_ClaimDetailController.isUserEligibleForClaimsChat();
        } catch(Exception ex) {
            System.assertEquals('Script-thrown exception', ex.getMessage(), 'Exception thrown');
        }
        Test.stopTest();

        System.assertEquals(false, result, 'Result should be false');
    }
    
    @isTest
    public static void testEmptyPayload() {
        List<Object> result1;
        Test.startTest();
        List<Object> result = AT_ClaimDetailController.getClaimEstimates('');
        try {
            AT_ClaimDetailController.isErrorTest=true;
            result1 = AT_ClaimDetailController.getClaimEstimates('');
        } catch(Exception ex) {
            System.assertEquals('Script-thrown exception', ex.getMessage(), 'Exception thrown');
        }
        Test.stopTest();
        System.assert(result.isEmpty(), 'Result size should be zero');
    }
    
    @isTest
    public static void testFullPowerPayload() {
        Test.startTest();
        List<Object> result = AT_ClaimDetailController.getClaimEstimates(PAYLOAD);
        Test.stopTest();
        System.assert(!result.isEmpty(), 'Result size should be greater than zero');
    }
    
    @isTest
    public static void testForLogPromiseRejection(){
        Test.startTest();
        String error = 'data not found';
        AT_ClaimDetailController.logPromiseRejection(error);
        Test.stopTest();
        System.assertEquals('data not found', error, 'Should return error, no data found');
    }
    
    @isTest
    private static void testIsClaimDocumentUploadIframeOn() {
        AT_ClaimDetailController.toggleContext = UTIL_ToggleTestUtils.buildContext(UTIL_Toggles.CLAIM_DOCUMENT_UPLOAD_IFRAME, true);
        Boolean resultValue1;
        Test.startTest();
        Boolean resultValue = AT_ClaimDetailController.isClaimDocumentUploadIframe();
        try {
            AT_ClaimDetailController.isErrorTest=true;
            resultValue1 = AT_ClaimDetailController.isClaimDocumentUploadIframe();
        } catch(Exception ex) {
            System.assertEquals('Script-thrown exception', ex.getMessage(), 'Exception thrown');
        }
        Test.stopTest();
        System.assertEquals(true, resultValue, 'CLAIM_DOCUMENT_UPLOAD_IFRAME toggle should be on');
    }

    @isTest
    public static void testGetFolAcronymList(){
        List<CM_Auto_FOL_Acronym__mdt> results1;
        Test.startTest();
        List<CM_Auto_FOL_Acronym__mdt> results = AT_ClaimDetailController.getFolAcronymList();
        try {
            AT_ClaimDetailController.isErrorTest=true;
            results1 = AT_ClaimDetailController.getFolAcronymList();
        } catch(Exception ex) {
            System.assertEquals('Script-thrown exception', ex.getMessage(), 'Exception thrown');
        }
        Test.stopTest();

        System.assert(!results.isEmpty(), 'Acronym list size should be greater than zero');
    }

    @isTest
    public static void testGetFireFolAcronymList(){
        List<CM_Fire_FOL_Acronym__mdt> results1;
        Test.startTest();
        List<CM_Fire_FOL_Acronym__mdt> results = AT_ClaimDetailController.getFireFolAcronymList();
        try{
            AT_ClaimDetailController.isErrorTest=true;
            results1 = AT_ClaimDetailController.getFireFolAcronymList();
        } catch(Exception ex) {
            System.assertEquals('Script-thrown exception', ex.getMessage(), 'Exception thrown');
        }
        Test.stopTest();

        System.assert(!results.isEmpty(), 'Should have fire claim acronyms in CM_Fire_FOL_Acronym__mdt');
    }

    @isTest 
    public static void testIsSandboxEnvironment(){
        User agent = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678913');
        agent = TestDataFactory_User.insertUser(agent);
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agent);

        Boolean isSandboxResult = null;
        Boolean isSandboxResult1 = null;
        
        Test.startTest();
        System.runAs(agent) {
            isSandboxResult = AT_ClaimDetailController.isSandboxEnvironment();

        }
        try {
            AT_ClaimDetailController.isErrorTest=true;
            isSandboxResult1 = AT_ClaimDetailController.isSandboxEnvironment();
        } catch(Exception ex) {
            System.assertEquals('Script-thrown exception', ex.getMessage(), 'Exception thrown');
        }
        Test.stopTest();

        System.assertEquals(true, isSandboxResult, 'isSandboxResult should be true');
    }

    @isTest
    public static void testGetBillingAddressInfo(){
        Account account = TestDataFactory_Account.createIndividualCustomer('FFFFFF1', testClientId);
        account.BillingCity = 'Tempe';
        account.BillingState = 'AZ';
        System.runAs(sysAdminUser){
            TestDataFactory_Account.byPassAccountBeforeTrigger();
            TestDataFactory_Opportunity.byPassOpportunityBeforeTrigger();
            account = TestDataFactory_Account.insertAccount(account);
        }
       
        List<Object> billingInfo;
        List<Object> billingInfo1;
        List<Account> expectedBillingInfo = new List<Account>();
        expectedBillingInfo.add(new Account(Id = account.Id, BillingCity = 'Tempe', BillingState = 'AZ'));
        
        Test.startTest();
        billingInfo = AT_ClaimDetailController.getBillingAddressInfo(testClientId);
        try {
            AT_ClaimDetailController.isErrorTest=true;
            billingInfo1 = AT_ClaimDetailController.getBillingAddressInfo(testClientId);
        } catch(Exception ex) {
            System.assertEquals('Script-thrown exception', ex.getMessage(), 'Exception thrown');
        }
        Test.stopTest();
        
        System.assertEquals(expectedBillingInfo, billingInfo, 'Billing info does not match');
    }
}
