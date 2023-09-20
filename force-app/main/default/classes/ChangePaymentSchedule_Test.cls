/**
 * @description Test Class for the ChangePaymentSchedule Class.
 *
 * @author Kiko Ferrer (VAD63S)
 * @version 1.0, 03/04/23
 * @see ChangePaymentSchedule 
 * @since 1.0
*/
@isTest
public class ChangePaymentSchedule_Test {
    // User fields
    private static final String SYSTEM_ADMIN_LAST_NAME = 'systemAdmin';
    // Account fields
    private static final String HOUSEHOLD_RECORD_TYPE = 'IndustriesHousehold';
	private static final String HOUSEHOLD_NAME = 'Household';
    private static final String INDIVIDUAL_RECORD_TYPE = 'Individual';
    private static final String INDIVIDUAL_F_NAME = 'IndividualAcc';
    // Insurance Policy fields
    private static final String INSURANCE_POLICY_ANN_NAME = '247 7576-A08-49G';
    // Billing Account fields
    private static final String BILL_ACC_NUM = '2438564789';
    private static final String BILL_ACC_NUM_AM_DUE = '2438564666';
    private static final String BILL_ACC_NUM_SUS = '2438564777';
    private static final String BILL_ACC_NUM_AM_DUE_SUS = '2438564555';
    // Billing Policy fields
	private static final String BILL_POLICY_QUAR_EX_ID = '353850488';
    private static final String BILL_POLICY_QUAR_AMO_DUE_EX_ID = '353850000';
    private static final String BILL_POLICY_QUAR_SUS_EX_ID = '353850111';
    private static final String BILL_POLICY_QUAR_AMO_DUE_SUS_EX_ID = '353850222';
    
     /**
     * @description Setup method used to create records to be reused accross the different test methods.
     * 
     */
    @TestSetup
    public static void setup() { 
        // Create User
        User systemAdmin = new User(ProfileId=[SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
                                        LastName=SYSTEM_ADMIN_LAST_NAME,
                                        UserName='systemAdminTest@statefarm.com',
                                        Alias='VAD00X',
                                        Email='testsystemadminuser@statefarm.com',
                                        TimeZoneSidKey='Europe/London',
                                        State_Agent_Code__c = '18-1AED',
                                        LocaleSidKey='en_US',
                                        EmailEncodingKey='UTF-8',
                                        LanguageLocaleKey='en_US');
        insert systemAdmin;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemAdmin.id);            
        insert sysAdminUserIdSetting;
        
        User agentOffice = TestDataFactory_User_Wrapper.generateAgentUser('aliis', '12345678912');
        agentOffice.LastName = SYSTEM_ADMIN_LAST_NAME + '-Office';
        agentOffice.State_Agent_Code__c = '18-1AED';
        agentOffice = TestDataFactory_User.insertUser(agentOffice);
        
        // Create Accounts (Individual and related Household)
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId();
        Id individualRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
        Account householdAccount;
        Account individualAccount;
        System.runAs(systemAdmin) {
            householdAccount = new Account(recordTypeId=householdRecordTypeId, Name=HOUSEHOLD_NAME, AllowHousehold__c = true); // AllowHousehold__c false?
            insert householdAccount;
            individualAccount = new Account(recordTypeId=individualRecordTypeId, Primary_Household__pc=householdAccount.Id, FirstName=INDIVIDUAL_F_NAME, LastName='AccountOne', 
                                            ClientIdentifier__c='SFFSP81LZYX', AllowHousehold__c = false, 
                                            BillingAddressType__c='US', BillingStreet='1234 Main St', BillingCity='Bloomington', BillingState='IL', 
                                            BillingPostalCode='61704', BillingCountry='UNITED STATES');
            insert individualAccount;
        }
        // Create (2) Insurance Policy: Name, EffectiveDate, PolicyTerm
        InsurancePolicy insurancePolicyAnnual = new InsurancePolicy(Name=INSURANCE_POLICY_ANN_NAME, NameInsuredId=individualAccount.Id, FinServ__Household__c=householdAccount.Id, 
                                                                    Servicing_Agent__c=systemAdmin.Id, PolicyType='Auto', PolicyDescription='1969 Pontiac Gto 2dr',
                                                                    EffectiveDate=Datetime.now().addMonths(-1), PolicyTerm='Annual');
        insert insurancePolicyAnnual;
        //  - PolicyTerm = Monthly
        
        // Create (4) Billing Accounts: AccountNumber__c, CalculatedCurrentAmountDue__c, Status__c, SourceSystem__c = SFPP,SourceSystemIdentifier__c=2438564789
        Billing_Account__c billingAccount = new Billing_Account__c(AccountNumber__c=BILL_ACC_NUM, CalculatedCurrentAmountDue__c=0, Status__c='Paid',
                                                                  SourceSystem__c='SFPP', SourceSystemIdentifier__c='2438564789');
        insert billingAccount;
        Billing_Account__c billingAccountAmoDue = new Billing_Account__c(AccountNumber__c=BILL_ACC_NUM_AM_DUE, CalculatedCurrentAmountDue__c=200, Status__c='Paid',
                                                                  		 SourceSystem__c='SFPP', SourceSystemIdentifier__c='2438564666');
        insert billingAccountAmoDue;
        Billing_Account__c billingAccountSusp = new Billing_Account__c(AccountNumber__c=BILL_ACC_NUM_SUS, CalculatedCurrentAmountDue__c=0, Status__c='BILLING SUSPENDED',
                                                                  		 SourceSystem__c='SFPP', SourceSystemIdentifier__c='2438564555');
        insert billingAccountSusp;
        
        Billing_Account__c billingAccountAmoDueSusp = new Billing_Account__c(AccountNumber__c=BILL_ACC_NUM_AM_DUE_SUS, CalculatedCurrentAmountDue__c=500, Status__c='BILLING SUSPENDED',
                                                                  		 	 SourceSystem__c='SFPP', SourceSystemIdentifier__c='2438564444');
        insert billingAccountAmoDueSusp;
        
        // Create Billing Participants (Relate with AccountID and BillingAccountID): SFPolicyRoleId__c = PAH
        Billing_Participant__c billParticipant = new Billing_Participant__c(BillingAccountID__c=billingAccount.Id, ParticipantAccountId__c=individualAccount.Id,
                                                                            Primary_Household__c=householdAccount.Id,
                                                                            SFPolicyRoleId__c='PAH', SourceSystemIdentifier__c='2438564790');
        
        insert billParticipant;
        Billing_Participant__c billParticipantAmoDue = new Billing_Participant__c(BillingAccountID__c=billingAccountAmoDue.Id, ParticipantAccountId__c=individualAccount.Id,
                                                                            	 Primary_Household__c=householdAccount.Id,
                                                                            	 SFPolicyRoleId__c='PAH', SourceSystemIdentifier__c='2438564666');
    	insert billParticipantAmoDue;
        Billing_Participant__c billParticipantSus = new Billing_Participant__c(BillingAccountID__c=billingAccountSusp.Id, ParticipantAccountId__c=individualAccount.Id,
                                                                            	 Primary_Household__c=householdAccount.Id,
                                                                            	 SFPolicyRoleId__c='PAH', SourceSystemIdentifier__c='2438564555');
    	insert billParticipantSus;
        Billing_Participant__c billParticipantAmoDueSus = new Billing_Participant__c(BillingAccountID__c=billingAccountAmoDueSusp.Id, ParticipantAccountId__c=individualAccount.Id,
                                                                            	     Primary_Household__c=householdAccount.Id,
                                                                            	     SFPolicyRoleId__c='PAH', SourceSystemIdentifier__c='2438564444');
    	insert billParticipantAmoDueSus;
        
        // Create Billing Policy (Relate with InsurancePolicyID and BillingAccountID): BillingFrequency__c
        Billing_Policy__c bilPolicyQuart = new Billing_Policy__c(BillingAccountID__c=billingAccount.Id, InsurancePolicyId__c=insurancePolicyAnnual.Id, 
                                                            BillingFrequency__c='QUARTERLY', SourceSystemIdentifier__c=BILL_POLICY_QUAR_EX_ID);
        insert bilPolicyQuart;
        
        Billing_Policy__c bilPolicyQuartAmoDue = new Billing_Policy__c(BillingAccountID__c=billingAccountAmoDue.Id, InsurancePolicyId__c=insurancePolicyAnnual.Id, 
                                                            		  BillingFrequency__c='QUARTERLY', SourceSystemIdentifier__c=BILL_POLICY_QUAR_AMO_DUE_EX_ID);
        insert bilPolicyQuartAmoDue;
        Billing_Policy__c bilPolicyQuartSus = new Billing_Policy__c(BillingAccountID__c=billingAccountSusp.Id, InsurancePolicyId__c=insurancePolicyAnnual.Id, 
                                                            		BillingFrequency__c='QUARTERLY', SourceSystemIdentifier__c=BILL_POLICY_QUAR_SUS_EX_ID);
        insert bilPolicyQuartSus;
        Billing_Policy__c bilPolicyQuartAmoDueSus = new Billing_Policy__c(BillingAccountID__c=billingAccountAmoDueSusp.Id, InsurancePolicyId__c=insurancePolicyAnnual.Id, 
                                                            		      BillingFrequency__c='QUARTERLY', SourceSystemIdentifier__c=BILL_POLICY_QUAR_AMO_DUE_SUS_EX_ID);
        insert bilPolicyQuartAmoDueSus;      
    }
    
     /**
     * @description Method that test successfull an successfull change payment schedule
     * 
     */
    @IsTest
    static void changePaymentScheduleSuccess() {
        List<ChangePaymentSchedule.InputVariables> inputVariables = new List<ChangePaymentSchedule.InputVariables>();
        ChangePaymentSchedule.InputVariables inputVariable = new ChangePaymentSchedule.InputVariables();        
        inputVariable.billPolicyId = [SELECT Id FROM Billing_Policy__c WHERE SourceSystemIdentifier__c = :BILL_POLICY_QUAR_EX_ID LIMIT 1].Id;
        inputVariable.billingFrequency = '3';
        inputVariable.policyTerm = 'Annual';
        inputVariables.add(inputVariable);
        List<ChangePaymentSchedule.OutputVariables> outputVariables = new List<ChangePaymentSchedule.OutputVariables>();
        Test.setMock(HttpCalloutMock.class, new SuccessfulChangePaymentSchedule());
        User systemAdminUser = [SELECT Id FROM User WHERE LastName = :SYSTEM_ADMIN_LAST_NAME LIMIT 1];
        Test.startTest();
        System.runAs(systemAdminUser) {
            outputVariables = ChangePaymentSchedule.changeThePaymentSchedule(inputVariables);
        }
        Test.stopTest();
       	System.assertEquals('You have successfully updated the payment schedule to Pay half for Policy 247 7576-A08-49G on Billing Account 2438564789.',
                           outputVariables[0].responseMessage, 'Incocrrect message on successfull change payment schedule');
        
        Task task = [SELECT Status, Type FROM Task WHERE Id = :outputVariables[0].taskId];
        System.assertEquals('Completed', task.Status, 'Incorrect task status');

    }
    
     /**
     * @description Method that test an unsuccessfull change payment schedule due to the billing account having an amount due.
     * 
     */
    @IsTest
    static void changePaymentScheduleAmountDue() {
        List<ChangePaymentSchedule.InputVariables> inputVariables = new List<ChangePaymentSchedule.InputVariables>();
        ChangePaymentSchedule.InputVariables inputVariable = new ChangePaymentSchedule.InputVariables();        
        inputVariable.billPolicyId = [SELECT Id FROM Billing_Policy__c WHERE SourceSystemIdentifier__c = :BILL_POLICY_QUAR_AMO_DUE_EX_ID LIMIT 1].Id;
        inputVariable.billingFrequency = '3';
        inputVariable.policyTerm = 'Annual';
        inputVariables.add(inputVariable);
        List<ChangePaymentSchedule.OutputVariables> outputVariables = new List<ChangePaymentSchedule.OutputVariables>();
        Test.setMock(HttpCalloutMock.class, new SuccessfulChangePaymentSchedule());
        User systemAdminUser = [SELECT Id FROM User WHERE LastName = :SYSTEM_ADMIN_LAST_NAME LIMIT 1];
        Test.startTest();
        System.runAs(systemAdminUser) {
            outputVariables = ChangePaymentSchedule.changeThePaymentSchedule(inputVariables);
        }
        Test.stopTest();
        System.assertEquals('Billing Account 2438564666 has an amount due of $200.00.\n A policy\'s payment schedule cannot be changed to be billed less often until the current amount due is paid in full.\n',
                           outputVariables[0].responseMessage, 'Incocrrect message on unsuccessfull change payment schedule');
        Assert.isNull(outputVariables[0].taskId, 'Task is incorrectly created');
    }
    
     /**
     * @description Method that test an unsuccessfull change payment schedule due to the billing account being suspended.
     * 
     */
    @IsTest
    static void changePaymentScheduleSuspended() {
        List<ChangePaymentSchedule.InputVariables> inputVariables = new List<ChangePaymentSchedule.InputVariables>();
        ChangePaymentSchedule.InputVariables inputVariable = new ChangePaymentSchedule.InputVariables();        
        inputVariable.billPolicyId = [SELECT Id FROM Billing_Policy__c WHERE SourceSystemIdentifier__c = :BILL_POLICY_QUAR_SUS_EX_ID LIMIT 1].Id;
        inputVariable.billingFrequency = '3';
        inputVariable.policyTerm = 'Annual';
        inputVariables.add(inputVariable);
        List<ChangePaymentSchedule.OutputVariables> outputVariables = new List<ChangePaymentSchedule.OutputVariables>();
        Test.setMock(HttpCalloutMock.class, new SuccessfulChangePaymentSchedule());
        User systemAdminUser = [SELECT Id FROM User WHERE LastName = :SYSTEM_ADMIN_LAST_NAME LIMIT 1];
        Test.startTest();
        System.runAs(systemAdminUser) {
            outputVariables = ChangePaymentSchedule.changeThePaymentSchedule(inputVariables);
        }
        Test.stopTest();
        System.assertEquals('Billing Account 2438564777 has billing suspended status.\n A policy\'s payment schedule cannot be changed to be billed less often until the policy status is Active, Billed, or Paid.',
                           outputVariables[0].responseMessage, 'Incocrrect message on unsuccessfull change payment schedule');
        Assert.isNull(outputVariables[0].taskId, 'Task is incorrectly created');
    }
    
     /**
     * @description Method that test an unsuccessfull change payment schedule due to the billing account having an amount due and being suspended
     * 
     */
    @IsTest
    static void changePaymentScheduleAmountDueSuspended() {
        List<ChangePaymentSchedule.InputVariables> inputVariables = new List<ChangePaymentSchedule.InputVariables>();
        ChangePaymentSchedule.InputVariables inputVariable = new ChangePaymentSchedule.InputVariables();        
        inputVariable.billPolicyId = [SELECT Id FROM Billing_Policy__c WHERE SourceSystemIdentifier__c = :BILL_POLICY_QUAR_AMO_DUE_SUS_EX_ID LIMIT 1].Id;
        inputVariable.billingFrequency = '3';
        inputVariable.policyTerm = 'Annual';
        inputVariables.add(inputVariable);
        List<ChangePaymentSchedule.OutputVariables> outputVariables = new List<ChangePaymentSchedule.OutputVariables>();
        Test.setMock(HttpCalloutMock.class, new SuccessfulChangePaymentSchedule());
        User systemAdminUser = [SELECT Id FROM User WHERE LastName = :SYSTEM_ADMIN_LAST_NAME LIMIT 1];
        Test.startTest();
        System.runAs(systemAdminUser) {
            outputVariables = ChangePaymentSchedule.changeThePaymentSchedule(inputVariables);
        }
        Test.stopTest();
        System.assertEquals('Billing Account 2438564555 has an amount due of $500.00.\n A policy\'s payment schedule cannot be changed to be billed less often until the current amount due is paid in full.\nBilling Account 2438564555 has billing suspended status.\n A policy\'s payment schedule cannot be changed to be billed less often until the policy status is Active, Billed, or Paid.',
                           outputVariables[0].responseMessage, 'Incocrrect message on unsuccessfull change payment schedule');
        Assert.isNull(outputVariables[0].taskId, 'Task is incorrectly created');
    }
    
     /**
     * @description Method that test an unsuccessfull call to the Billing Account Policy Administration API.
     * 
     */
	@IsTest
    static void changePaymentScheduleFailHttpCall() {
        List<ChangePaymentSchedule.InputVariables> inputVariables = new List<ChangePaymentSchedule.InputVariables>();
        ChangePaymentSchedule.InputVariables inputVariable = new ChangePaymentSchedule.InputVariables();        
        inputVariable.billPolicyId = [SELECT Id FROM Billing_Policy__c WHERE SourceSystemIdentifier__c = :BILL_POLICY_QUAR_EX_ID LIMIT 1].Id;
        inputVariable.billingFrequency = '3';
        inputVariable.policyTerm = 'Annual';
        inputVariables.add(inputVariable);
        List<ChangePaymentSchedule.OutputVariables> outputVariables = new List<ChangePaymentSchedule.OutputVariables>();
        Test.setMock(HttpCalloutMock.class, new UnsuccessfulChangePaymentSchedule());
        User systemAdminUser = [SELECT Id FROM User WHERE LastName = :SYSTEM_ADMIN_LAST_NAME LIMIT 1];
        Test.startTest();
        System.runAs(systemAdminUser) {
            outputVariables = ChangePaymentSchedule.changeThePaymentSchedule(inputVariables);
        }
        Test.stopTest();
        System.assertEquals('Error 500: Internal Server Error',
                           outputVariables[0].responseMessage, 'Incocrrect message on unsuccessfull call to change payment schedule');
        Assert.isNull(outputVariables[0].taskId, 'Task is incorrectly created');
    }
    
     /**
     * @description Method that test Monthly billing frequency code.
     * 
     */
    @IsTest   
    static void billingFreqCodeConversionMonthly() {
        String billingFreqCode;
        User systemAdminUser = [SELECT Id FROM User WHERE LastName = :SYSTEM_ADMIN_LAST_NAME LIMIT 1];
        Test.startTest();
        System.runAs(systemAdminUser) {
            billingFreqCode = ChangePaymentSchedule.billingFreqCodeConversion('1');
        }
        Test.stopTest();
        System.assertEquals('Monthly', billingFreqCode, 'Incocrrect billing frequency code');
    }
     /**
     * @description Method that test a Pay in Full billing frequency code.
     * 
     */
    @IsTest   
    static void billingFreqCodeConversionPayInFull() {
        String billingFreqCode;
        User systemAdminUser = [SELECT Id FROM User WHERE LastName = :SYSTEM_ADMIN_LAST_NAME LIMIT 1];
        Test.startTest();
        System.runAs(systemAdminUser) {
            billingFreqCode = ChangePaymentSchedule.billingFreqCodeConversion('2');
        }
        Test.stopTest();
        System.assertEquals('Pay in full', billingFreqCode, 'Incocrrect billing frequency code');
    }
     /**
     * @description Method that test a Quarterly billing frequency code.
     * 
     */
    @IsTest   
    static void billingFreqCodeConversionQuarterly() {
        String billingFreqCode;
        User systemAdminUser = [SELECT Id FROM User WHERE LastName = :SYSTEM_ADMIN_LAST_NAME LIMIT 1];
        Test.startTest();
        System.runAs(systemAdminUser) {
            billingFreqCode = ChangePaymentSchedule.billingFreqCodeConversion('5');
        }
        Test.stopTest();
        System.assertEquals('Quarterly', billingFreqCode, 'Incocrrect billing frequency code');
    }
     /**
     * @description Method that test an invalid billing frequency code.
     * 
     */
    @IsTest   
    static void billingFreqCodeConversionInvalid() {
        String billingFreqCode;
        User systemAdminUser = [SELECT Id FROM User WHERE LastName = :SYSTEM_ADMIN_LAST_NAME LIMIT 1];
        Test.startTest();
        System.runAs(systemAdminUser) {
            billingFreqCode = ChangePaymentSchedule.billingFreqCodeConversion('9');
        }
        Test.stopTest();
        System.assertEquals('<Invalid frequency>', billingFreqCode, 'Incocrrect billing frequency code');
    }
    
    
    /**
     * @description Static nested class that creates an successful callout mock for the Billing Account Policy Administration (Rest Service).
     * 
     * @see changePaymentScheduleSuccess()
     * @see changePaymentScheduleAmountDue()
     * @see changePaymentScheduleSuspended()
     * @see changePaymentScheduleAmountDueSuspended()
     */
   private class SuccessfulChangePaymentSchedule implements HttpCalloutMock {
       
         /**
         * @description Method to create mock responses from the Billing Account Policy Administration (Rest Service).
         * 
     	 * @param request : request from the API
     	 * @return HTTPResponse from the API
         * @see changePaymentScheduleAmountDueSuspended()
         */
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setBody('{"statusCode":200,"message":"SUCCESS"}');
            response.setStatusCode(200);
            return response; 
        }
	}
    
     /**
     * @description Static nested class that creates an unsuccessful callout mock for the Billing Account Policy Administration (Rest Service).
     * 
     * @see changePaymentScheduleFailHttpCall()
     */
   private class UnsuccessfulChangePaymentSchedule implements HttpCalloutMock {
         /**
         * @description Method to create mock responses from the Billing Account Policy Administration (Rest Service).
         * 
     	 * @param request : request from the API
     	 * @return HTTPResponse from the API
         * @see changePaymentScheduleAmountDueSuspended()
         */
        public HTTPResponse respond(HTTPRequest request) {   
            HttpResponse response = new HttpResponse();
            response.setBody('{"statusCode":500,"message":"{\"status\":\"INTERNAL_SERVER_ERROR\"}"');
            response.setStatusCode(500);
            return response;        
        }
    }
}