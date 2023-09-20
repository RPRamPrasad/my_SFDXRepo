/**
 * @description Test Class for the CreatePolicyOSCCase Class.
 *
 * @author Kiko Ferrer (VAD63S)
 * @version 1.1, 12/15/22
 * @see CreatePolicyOSCCase 
 * @since 1.0
*/
@isTest
private class CreatePolicyOSCCase_Test {
    // User fields
    private static final String SYSTEM_ADMIN_PROFILE_NAME = 'System Administrator';
    private static final String SYSTEM_ADMIN_LAST_NAME = 'systemAdmin';
    private static final String SYSTEM_ADMIN_USERNAME = 'systemAdminTest@statefarm.com';
    private static final String USER_ALIAS = 'VAD00X';
    private static final String STATE_AGENT_CODE = '49-6035';
    
    
    // Household fields
    private static final String HOUSEHOLD_RECORD_TYPE = 'IndustriesHousehold';
	private static final String HOUSEHOLD_NAME = 'Household';
    
    // Individual account fields
    private static final String INDIVIDUAL_RECORD_TYPE = 'Individual';
    private static final String INDIVIDUAL_F_NAME = 'IndividualAcc';

    // InsurancePolicy fields
    private static final String INSURANCE_POLICY_NAME = '247 7576-A08-49G';

    // Case input fields
    private static final String CASE_TYPE = 'Premium Change';
    private static final String CASE_REASON = 'Renewal Premium Diff PCU';
    private static final String QUESTION = 'How can I change my policy?';


    /**
     * @description Setup method used to create records to be reused accross the different test methods.
     * 
     */
    @testSetup 
    public static void setup() {        
        // Bypass rules to be able to create Household account records
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;
        
        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false, SystemUser);
        insert passTriggerAll;
        
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemUser);
        objectBasedByPassTrigger.Override_AgentRoleAfterInsert__c = false;
        objectBasedByPassTrigger.Override_AgentRoleBeforeDelete__c = false;
        insert objectBasedByPassTrigger;
        
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
        insert sysAdminUserIdSetting;
  
        TestDataFactory_CustomSetting.createDeleteRecordConfig(SYSTEM_ADMIN_PROFILE_NAME, SYSTEM_ADMIN_USERNAME);
        
        // Create (System Admin) User
        User systemAdmin = UTIL_UserProvisioning_TEST.buildSystemAdmin(USER_ALIAS, SYSTEM_ADMIN_LAST_NAME, SYSTEM_ADMIN_USERNAME);
        systemAdmin.State_Agent_Code__c = STATE_AGENT_CODE;
        Id systemAdminId = Database.insert(systemAdmin).getId();
        
        // Create an Individual account and a related Household
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId();
        Id individualRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
        Account householdAccount;
        Id householdId;
        Account individualAccount;
        Id individualAccountId;
        System.runAs(systemAdmin) {
            householdAccount = new Account(recordTypeId=householdRecordTypeId, Name=HOUSEHOLD_NAME, AllowHousehold__c = true); // AllowHousehold__c false?
            householdId = Database.insert(householdAccount).getId();
            individualAccount = new Account(recordTypeId=individualRecordTypeId, Primary_Household__pc=householdId, FirstName=INDIVIDUAL_F_NAME, LastName='AccountOne', 
                                            ClientIdentifier__c='SFFSP81LZYX', AllowHousehold__c = false, 
                                            BillingAddressType__c='US', BillingStreet='1234 Main St', BillingCity='Bloomington', BillingState='IL', 
                                            BillingPostalCode='61704', BillingCountry='UNITED STATES');
            individualAccountId = Database.insert(individualAccount).getId();              
        }

        // Create InsurancePolicy
        InsurancePolicy insurancePolicy = new InsurancePolicy(Name=INSURANCE_POLICY_NAME, NameInsuredId=individualAccountId, FinServ__Household__c=householdId, 
        Servicing_Agent__c=systemAdminId, PolicyType='Auto', PolicyDescription='1969 Pontiac Gto 2dr');
        Database.insert(insurancePolicy);

    }


     /**
     * @description Method that test the creation of an ECRM case without passing a user (null) and validates the case fields.
     * 
     * @see CreatePolicyOSCCase#createPolicyCaseECRM()
     */
    @isTest
    static void createPolicyCaseECRM_withNullUser_success() {
        Test.setMock(HttpCalloutMock.class, new CreateCaseUsingPOSTCalloutSuccessMock());
        String actualCaseNumber;
        String expCaseSubject = 'Premium Change Inquiry for ' + INSURANCE_POLICY_NAME;
        Id expCaseOwnerId = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()].Id;  
        Account expCaseAccount = [SELECT Id, PersonContactId FROM Account WHERE FirstName = :INDIVIDUAL_F_NAME];
                             
        Test.startTest();
        CreatePolicyOSCCase.CreatePolicyCaseECRMWrapper createPolicyWrapper = new CreatePolicyOSCCase.CreatePolicyCaseECRMWrapper();
        createPolicyWrapper.userRecord = Null;
        createPolicyWrapper.policyName = INSURANCE_POLICY_NAME;
        createPolicyWrapper.caseType = CASE_TYPE;
        createPolicyWrapper.caseReason = CASE_REASON;
        createPolicyWrapper.question = QUESTION;
        actualCaseNumber = CreatePolicyOSCCase.createPolicyCaseECRM(createPolicyWrapper);
        Test.stopTest();

        // Assertions
        Assert.isNotNull(actualCaseNumber, 'createPolicyCaseECRM() did not return the ECRM Case number');
        // Query the created ECRM case and assert its fields.
        Case newECRMCase = [SELECT Id, Assigned_To__c, AccountId, FinServ__Household__c, ContactId, Insurance_Policy__c,
                                   Type, Reason, Question__c, Subject, Description, CaseNumber, ACMT_Case_Number__c, OwnerId
                            FROM Case WHERE CaseNumber = :actualCaseNumber LIMIT 1];
        System.assertEquals(expCaseAccount.Id, newECRMCase.AccountId, 'ECRM Case assigned to incorrect Account');
        System.assertEquals(expCaseAccount.PersonContactId, newECRMCase.ContactId, 'ECRM Case assigned to incorrect Contact');
        System.assertEquals(expCaseOwnerId, newECRMCase.OwnerId, 'ECRM Case assigned to incorrect Owner');
        System.assertEquals(expCaseOwnerId, newECRMCase.Assigned_To__c, 'ECRM Case assigned to incorrect Assigned_To__c');
        System.assertEquals(CASE_TYPE, newECRMCase.Type, 'ECRM Case type is incorrect');
        System.assertEquals(CASE_REASON, newECRMCase.Reason, 'ECRM Case reason is incorrect');
        System.assertEquals(expCaseSubject, newECRMCase.Subject, 'ECRM Case subject is incorrect');

    }

    /**
     * @description Method that test the creation of an ECRM case passing an specific user and validates the case fields.
     * 
     * @see CreatePolicyOSCCase#createPolicyCaseECRM()
     */
    @isTest
    static void createPolicyCaseECRM_withUser_success() {
        Test.setMock(HttpCalloutMock.class, new CreateCaseUsingPOSTCalloutSuccessMock());
        String actualCaseNumber;
        String expCaseSubject = 'Premium Change Inquiry for ' + INSURANCE_POLICY_NAME;
        User user = [SELECT Id, Name, Alias, State_Agent_Code__c FROM User WHERE Alias = :USER_ALIAS LIMIT 1];
        Account expCaseAccount = [SELECT Id, PersonContactId FROM Account WHERE FirstName = :INDIVIDUAL_F_NAME];
        Test.startTest();
        CreatePolicyOSCCase.CreatePolicyCaseECRMWrapper createPolicyWrapper = new CreatePolicyOSCCase.CreatePolicyCaseECRMWrapper();
        createPolicyWrapper.userRecord = user;
        createPolicyWrapper.policyName = INSURANCE_POLICY_NAME;
        createPolicyWrapper.caseType = CASE_TYPE;
        createPolicyWrapper.caseReason = CASE_REASON;
        createPolicyWrapper.question = QUESTION;
        actualCaseNumber = CreatePolicyOSCCase.createPolicyCaseECRM(createPolicyWrapper);
        Test.stopTest();

        // Assertions
        Assert.isNotNull(actualCaseNumber, 'createPolicyCaseECRM() did not return the ECRM Case number');
        // Query the created ECRM case and assert its fields
        Case newECRMCase = [SELECT Id, Assigned_To__c, AccountId, FinServ__Household__c, ContactId, Insurance_Policy__c,
                            Type, Reason, Question__c, Subject, Description, CaseNumber, ACMT_Case_Number__c, OwnerId
                            FROM Case WHERE CaseNumber = :actualCaseNumber LIMIT 1];
        System.assertEquals(expCaseAccount.Id, newECRMCase.AccountId, 'ECRM Case assigned to incorrect Account');
        System.assertEquals(expCaseAccount.PersonContactId, newECRMCase.ContactId, 'ECRM Case assigned to incorrect Contact');
        System.assertEquals(user.Id, newECRMCase.OwnerId, 'ECRM Case assigned to incorrect Owner');
        System.assertEquals(user.Id, newECRMCase.Assigned_To__c, 'ECRM Case assigned to incorrect Assigned_To__c');
        System.assertEquals(CASE_TYPE, newECRMCase.Type, 'ECRM Case type is incorrect');
        System.assertEquals(CASE_REASON, newECRMCase.Reason, 'ECRM Case reason is incorrect');
        System.assertEquals(expCaseSubject, newECRMCase.Subject, 'ECRM Case subject is incorrect');
    }

    /**
     * @description Private helper method that creates an successful callout mock for the calloutToOSCCaseController() method, 
     * which is indirectly called by createPolicyCaseECRM().
     * 
     * @see createPolicyCaseECRM_withUser_success()
     * @see createPolicyCaseECRM_withNullUser_success()
     */
    
    private class CreateCaseUsingPOSTCalloutSuccessMock implements HttpCalloutMock {
        /**
         * @description respond
         * @param request 
         * @return  `HTTPResponse`
         */
        public HTTPResponse respond(HTTPRequest request) {   
            HttpResponse response = new HttpResponse();
            response.setBody('{"id":"5003K000004wKrQQAU","caseNumber":"00047142","message":"Case is Successfully created in Salesforce","comments":"Agent code or Alias does not exist.","attachment":"Failed to insert the attachment"}');
            response.setStatusCode(201);
            response.setStatus('Created');
            return response;        
        }
    }
}