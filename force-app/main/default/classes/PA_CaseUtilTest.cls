@isTest
public class PA_CaseUtilTest {
    
    private static final String POLICY_NUMBER = '1234567ABC';
    private static final String WHITE_SPACE_POLICY_NUMBER = '1234 567A BC';
    private static final String PRODUCT_DESC = '2020 BMW';
    private static User agentUser;
    private static Account account;
    private static PA_CaseUtil util;

    @testSetup
    private static void testSetUp(){
        TestUserSetupUtility.setupAllUsers();
        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            CaseTestDataUtility.createAccount();
            CaseTestDataUtility.setupAgentRole(TestUserSetupUtility.getAgentUser(), CaseTestDataUtility.getAccount());
            CaseTestDataUtility.addUserToCaseAPI(TestUserSetupUtility.getApiOnlyUser());
        }
    }
    
    private static void setCaseWithParameters(String lob, String reason){
        createCaseUtilAndSetAgentUser();
        account = CaseTestDataUtility.getAccount();
        util.setLOB(lob);
        util.setPolicyNumber(POLICY_NUMBER);
        util.setReason(reason);
        util.setProductDescription(PRODUCT_DESC);
        util.parentRecordId = account.Id;
        util.agentAssociateId = agentUser.Associate_ID__c;
    }

    private static void createCaseUtilAndSetAgentUser() {
        util = new PA_CaseUtil();
        agentUser = TestUserSetupUtility.getAgentUser();
    }
    
    @isTest
    private static void testCaseCreate(){
        setCaseWithParameters('Auto', 'Policy Change');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
           String result = util.setupPolicyTransactionCase();
           System.assert(String.isNotEmpty(result), 'case was not created');
        }
    }
    
    @isTest
    private static void testPLModCaseCreate(){
        setCaseWithParameters('Auto', 'Policy Change');
        util.sourceSystemCode = '24';
        util.isLegacyPolicy = false;
        util.isCaseMigrationAction = true;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
           String result = util.setupPolicyTransactionCase();
           System.assert(String.isNotEmpty(result), 'case was not created');
        }
    }

    @isTest
    private static void testPLModCaseCreateSAEUser(){
        setCaseWithParameters('Auto', 'Policy Change');
        util.sourceSystemCode = '24';
        util.isLegacyPolicy = false;
        util.isCaseMigrationAction = true;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
           String result = util.setupPolicyTransactionCase();
           System.assert(String.isNotEmpty(result), 'case was not created');
        }
    }
    
    @isTest
    private static void testSBLECaseCreate(){
        setCaseWithParameters('Auto', 'Policy Change');
        util.sourceSystemCode = '15';
        util.isLegacyPolicy = false;
        util.isCaseMigrationAction = true;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
           String result = util.setupPolicyTransactionCase();
           System.assert(String.isNotEmpty(result), 'case was not created');
        }
    }

    @isTest
    private static void testSBLECaseCreateSAEUser(){
        setCaseWithParameters('Auto', 'Policy Change');
        util.sourceSystemCode = '15';
        util.isLegacyPolicy = false;
        util.isCaseMigrationAction = true;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
           String result = util.setupPolicyTransactionCase();
           System.assert(String.isNotEmpty(result), 'case was not created');
        }
    }
    
    @isTest
    private static void testCaseCreateMockException(){
        setCaseWithParameters('Auto', 'Policy Change');
        util.mockThrowException = true;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
       	System.runAs(agentUser){
           String result = util.setupPolicyTransactionCase();
           System.assert(String.isNotEmpty(result), 'case was not created');
        }
    }

    @isTest
    private static void setupPolicyTransactionCaseException(){
        setCaseWithParameters('Auto', 'Policy Change');
        util.parentRecordId = null; //setting null to cause Case insert to fail
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
       	System.runAs(agentUser){
           String result = util.setupPolicyTransactionCase();
           System.assert(String.isEmpty(result), 'case was created when it should not have been');
        }
        ExceptionLog__c setupPolicyTransactionCaseException = [SELECT Id, Class__c, Method__c, Exception_Message__c FROM ExceptionLog__c];
        system.assertEquals('PA_CaseUtil', setupPolicyTransactionCaseException.Class__c, 'Class in Exception Log');
        system.assertEquals('setupPolicyTransactionCase', setupPolicyTransactionCaseException.Method__c, 'Exception Log Method');
        system.assertEquals('Policy:1234567ABC Attempt to de-reference a null object', setupPolicyTransactionCaseException.Exception_Message__c, 'Message in Exception Log');
    }
    
    @isTest
    private static void testCaseCreateWithContact(){
        setCaseWithParameters('Auto', 'Policy Change');
        util.caseContactAccountId = account.Id;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
           String result = util.setupPolicyTransactionCase();
           System.assert(String.isNotEmpty(result), 'case was not created');
        }
    }

    @isTest
    private static void testAddedVehicleCaseCreate(){
        setCaseWithParameters('Auto', 'Added Vehicle');
        util.isCaseMigrationAction = true;
        util.caseContactAccountId = account.Id;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
           String result = util.setupPolicyTransactionCase();
           System.assert(String.isNotEmpty(result), 'case was not created');
        }
    }
    
    @isTest
    private static void testAddedVehiclePLModCaseCreate(){
        setCaseWithParameters('Auto', 'Added Vehicle');
        util.isCaseMigrationAction = true;
        util.isLegacyPolicy = false;
        util.caseContactAccountId = account.Id;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser){
           String result = util.setupPolicyTransactionCase();
           System.assert(String.isNotEmpty(result), 'case was not created');
        }
    }
    
    @isTest
    private static void testGetPolicyIdentifierForAuto(){
        createCaseUtilAndSetAgentUser();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
       	System.runAs(agentUser){
           String autoPolicyId = PA_CaseUtilHelper.getPolicyIdForAuto(WHITE_SPACE_POLICY_NUMBER, true);
           System.assertEquals('1234567', autoPolicyId, 'Policy Identifier was not set correctly');
        }
    }
    
    @isTest
    private static void testGetPolicyIdentifierForModAuto(){
        createCaseUtilAndSetAgentUser();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
       	System.runAs(agentUser){
           String autoPolicyId = PA_CaseUtilHelper.getPolicyIdForAuto(WHITE_SPACE_POLICY_NUMBER, false);
           System.assertEquals('1234567ABC', autoPolicyId, 'Policy Identifier was not set correctly');
        }
    }
    
    @isTest
    private static void testGetPolicyIdentifierForNonAuto(){
        setCaseWithParameters('Fire', '');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
       	System.runAs(agentUser){
           util.setPolicyIdentifier();
           System.assertEquals(POLICY_NUMBER, util.caseRecord.Policy_Identifier__c, 'Policy Identifier was not set correctly');
        }
    }
}