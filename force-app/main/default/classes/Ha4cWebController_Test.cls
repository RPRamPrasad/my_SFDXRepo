/**
* Author : Team LHIPS/GlitterCloud
* Date Created : 30/12/2022
* @description : Test class for the Ha4cWebController class
*/
@isTest
public with sharing class Ha4cWebController_Test {
    private static String accountId;
    
    
    private static final String SYSTEM_RECORD_OWNER_USERNAME = UTIL_TestUsername_TEST.getTestUsername('recowner');
    private static final String SYSADMIN_USER_ID = AP_UserProvisioningProcess_TEST_UTIL.getTestUsername('sysadmin');
    
    private static User sysAdmUser {get;set;}
    private static User agentUser {get;set;}
    private static User atmUser {get;set;}
    private static User noAccessUser {get;set;}
    private static User cccUser {get;set;}
    
    private static Case caseRecord {get;set;}
    private static Case caseRec {get;set;}
    private static Account testAccount {get;set;}
    private static String transactionType {get;set;}
    private static String caseReason {get;set;}
    
    private static void setup() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'AGNTName', 'AGNTName','AGNTName','AGNTName');
        atmUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.01 Agent Team Member', 'TestName', 'TestName','TestName','TestName');
        cccUser = UTIL_CreateCustomerTestData.createUserWithAssoId('3.00 CCC Licensed', 'TeCCCNa', 'TestCCCName','','TestCCCName_TestCCCName');
        cccUser.UserType__c = 'CCC';
        cccUser.SubUserType__c = 'CCC Sales';
        noAccessUser =  new User(alias = 'SYSA', email='noaccessTest@statefarm.com.bad', 
                                 emailencodingkey='UTF-8', lastname='TestSysRecOwner', languagelocalekey='en_US', 
                                 localesidkey='en_US', timezonesidkey='America/Chicago', username= 'sysAccRecOwner@test.com');
        noAccessUser.ProfileId = [select Id from Profile where name = '1.02 No Access' LIMIT 1].Id;
        
        atmUser.Servicing_Agent_Associate_ID__c = agentUser.Associate_ID__c;
        agentUser.State_Agent_Code__c = '43-1071';
        atmUser.State_Agent_Code__c = '13-2375';
        agentUser.WorkstationID__c = 'WPWFQD0T';
        atmUser.WorkstationID__c = 'WPWFQD1T';
        cccUser.WorkstationID__c = 'WPWFQD2T';
        
        agentUser.UserExternalID__c = 'AGNTName_AGNTName';
        
        insert new List<User>{agentUser, atmUser, noAccessUser, cccUser};
            CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(true, agentUser);
        insert passTriggerAll;
        CS001_ByPassTriggerAll__c passTriggerAllATM = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(true, atmUser);
        insert passTriggerAllATM;
        CS001_ByPassTriggerAll__c passTriggerAllNoAccess = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(true, noAccessUser);
        insert passTriggerAllNoAccess;
        CS001_ByPassTriggerAll__c passTriggerAllCCC = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(true, cccUser);
        insert passTriggerAllCCC;        
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(agentUser);
        objectBasedByPassTrigger.Override_CustomerGroupBeforeInsert__c = true;
        insert objectBasedByPassTrigger;
        CS001_ByPassTriggerAtoF__c objectBasedByPassTriggerATM = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(atmUser);
        objectBasedByPassTriggerATM.Override_CustomerGroupBeforeInsert__c = true;
        insert objectBasedByPassTriggerATM;
        CS001_ByPassTriggerAtoF__c objectBasedByPassTriggerCCC = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(cccUser);
        objectBasedByPassTriggerCCC.Override_CustomerGroupBeforeInsert__c = true;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser, atmUser, cccUser});
    }
    
    private static String setTestNechoUrl() {
        CS_Ha4cNechoURL__c testNechoUrl = new CS_Ha4cNechoURL__c(Name='Ha4cNechoURL',Ha4cNechoURL__c='https://necholauncher-v1-env3.app-71a.opr.test.statefarm.org');
        insert testNechoUrl;
        return testNechoUrl.Ha4cNechoURL__c;
    }
    
    private static Account createAccount(String lastName) {
        testAccount = UTIL_CreateCustomerTestData.createIndividualCustomer(lastName);
        insert testAccount;  
        return testAccount;
    }
    
    private static String setCaseReason(String value) {
        List<SelectOption> options = new List<SelectOption>();
        
        
        Schema.DescribeFieldResult fieldResult =
            Case.Reason.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
            if(f.getLabel() == value) {
                caseReason = f.getValue();
            }
        }
        return caseReason;
    }
    
    private static Case createCaseWithValues() {
        Case caseRec = new Case();
        caseRec.AccountId =  testAccount.id;
        caseRec.Status = 'New';
        caseRec.PolicyNumber__c = '599 7365-C04-25B';
        caseRec.Policy_Identifier__c = '5997365';
        caseRec.LOB__c = 'Auto';
        caseRec.ProductDescription__c = '2017 Ford Taurus 4dr';
        caseRec.ownerId = agentUser.Id;
        caseRec.Reason = setCaseReason('Policy - Change/Request');
        
        Map <String,Schema.RecordTypeInfo> recordTypeMap = Case.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getRecordTypeInfosByName();
        
        if (recordTypeMap.containsKey('Policy Change')) {
            caseRec.RecordTypeId = recordTypeMap.get('Policy Change').getRecordTypeId();
        }
        
        insert caseRec;
        InsurancePolicy ip = new InsurancePolicy();
        ip.NameInsuredId = testAccount.id;
        ip.PolicyName = 'Multiple Vehicle';
        ip.name= '599 7365-C04-25B';
        insert ip;
        return caseRec;
    }     
    
    private static Case createCaseWithValuesATM() {
        Case caseRec = new Case();
        caseRec.AccountId =  testAccount.id;
        caseRec.Status = 'New';
        caseRec.PolicyNumber__c = '599 7365-C04-25B';
        caseRec.Policy_Identifier__c = '5997365';
        caseRec.LOB__c = 'Auto';
        caseRec.ProductDescription__c = '2017 Ford Taurus 4dr';
        caseRec.Reason = setCaseReason('Policy - Change/Request');
        
        Map <String,Schema.RecordTypeInfo> recordTypeMap = Case.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getRecordTypeInfosByName();
        
        if (recordTypeMap.containsKey('Policy Change')) {
            caseRec.RecordTypeId = recordTypeMap.get('Policy Change').getRecordTypeId();
        }
        
        insert caseRec;
        InsurancePolicy ip = new InsurancePolicy();
        ip.NameInsuredId = testAccount.id;
        ip.PolicyName = 'Multiple Vehicle';
        ip.name= '599 7365-C04-25B';
        insert ip;
        return caseRec;
    }
    
    private static Case createCaseForBilling() {
        Case caseRec = new Case();
        caseRec.AccountId =  testAccount.id;
        caseRec.Status = 'New';
        caseRec.PolicyNumber__c = '599 7365-C04-25B';
        caseRec.Policy_Identifier__c = '5997365';
        caseRec.LOB__c = 'Auto';
        caseRec.ProductDescription__c = '2017 Ford Taurus 4dr';
        
        Map <String,Schema.RecordTypeInfo> recordTypeMap = Case.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getRecordTypeInfosByName();
        
        if (recordTypeMap.containsKey('Billing')) {
            caseRec.RecordTypeId = recordTypeMap.get('Billing').getRecordTypeId();
        }
        insert caseRec;
        InsurancePolicy ip = new InsurancePolicy();
        ip.NameInsuredId = testAccount.id;
        ip.PolicyName = 'Multiple Vehicle';
        ip.name= '599 7365-C04-25B';
        insert ip;
        return caseRec;
    }
    
    private static Case createCaseForAddVehicle() {
        Case caseRec = new Case();
        caseRec.AccountId =  testAccount.id;
        caseRec.Status = 'New';
        caseRec.PolicyNumber__c = '599 7365-C04-25B';
        caseRec.Policy_Identifier__c = '5997365';
        caseRec.LOB__c = 'Auto';
        caseRec.ProductDescription__c = '2017 Ford Taurus 4dr';
        caseRec.Reason = setCaseReason('Added Vehicle');
        Map <String,Schema.RecordTypeInfo> recordTypeMap = Case.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getRecordTypeInfosByName();
        
        if (recordTypeMap.containsKey('Policy Change')) {
            caseRec.RecordTypeId = recordTypeMap.get('Policy Change').getRecordTypeId();
        }
        
        insert caseRec;
        
        InsurancePolicy ip = new InsurancePolicy();
        ip.NameInsuredId = testAccount.id;
        ip.PolicyName = 'Multiple Vehicle';
        ip.name= '599 7365-C04-25B';
        insert ip;
        return caseRec;
        
        
    }
    
    private static Case createCaseWithSpecialCharacters() {
        Case caseRec = new Case();
        caseRec.AccountId =  testAccount.id;
        caseRec.Status = 'New';
        caseRec.PolicyNumber__c = '599 7365-C04-25B';
        caseRec.Policy_Identifier__c = '5997365';
        caseRec.LOB__c = 'Auto';
        caseRec.ProductDescription__c = '2017 Ford Taurus 4dr #&(%!@^)1';
        caseRec.Reason = setCaseReason('Policy - Change/Request');
        
        Map <String,Schema.RecordTypeInfo> recordTypeMap = Case.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getRecordTypeInfosByName();
        
        if (recordTypeMap.containsKey('Policy Change')) {
            caseRec.RecordTypeId = recordTypeMap.get('Policy Change').getRecordTypeId();
        }
        
        insert caseRec;
        
        InsurancePolicy ip = new InsurancePolicy();
        ip.NameInsuredId = testAccount.id;
        ip.PolicyName = 'Multiple Vehicle';
        ip.name= '599 7365-C04-25B';
        insert ip;
        return caseRec;
    }
    
    private static Case createCaseWithNullProductDescription() {
        Case caseRec = new Case();
        caseRec.AccountId =  testAccount.id;
        caseRec.Status = 'New';
        caseRec.PolicyNumber__c = '3982108C1843';
        caseRec.Policy_Identifier__c = '2345678';
        caseRec.LOB__c = 'Auto';
        caseRec.Reason = setCaseReason('Policy - Change/Request');
        
        Map <String,Schema.RecordTypeInfo> recordTypeMap = Case.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getRecordTypeInfosByName();
        
        if (recordTypeMap.containsKey('Policy Change')) {
            caseRec.RecordTypeId = recordTypeMap.get('Policy Change').getRecordTypeId();
        }
        
        insert caseRec;
        InsurancePolicy ip = new InsurancePolicy();
        ip.NameInsuredId = testAccount.id;
        ip.PolicyName = 'Multiple Vehicle';
        ip.name= '599 7365-C04-25B';
        insert ip;
        return caseRec;
    }
    @isTest
    private static  void testGetPolicyDetailsParmAsSingleAgentUserHA4C() {
        Test.StartTest();
        setup(); 
        System.runas(agentUser) {
            setTestNechoUrl();
            createAccount('testlastname'); 
            Case testCase = createCaseWithValues();
            string	clientIdentifier = Ha4cWebController.getClientIdentifier(testCase.AccountId);
            String expectedParm = 'https://necholauncher-v1-env3.app-71a.opr.test.statefarm.org/nechoLauncher/launchHA4C?selPolicy=599 7365-C04-25B&selPolOpt=2&lob=A&caseID='+testCase.Id+'&associateID=AGNTName&clientID='+clientIdentifier;
            User loggedInUser = Ha4cWebController.getUserRecord();
            System.assertEquals('AGNTName', loggedInUser.Alias, 'logged in user does not match');
            String parm = Ha4cWebController.getPolicyDetailsParmHA4C(testCase.Id);
            System.assertEquals(expectedParm, parm, 'Parm values do not match check controller');           
        }
        Test.StopTest();
    }
    
    
    
    
    @isTest
    private static void testGetPolicyDetailsParmAsSingleAgentUserAddVehicle() {
        Test.StartTest();
        setup();
        System.runas(agentUser) {
            setTestNechoUrl();
            createAccount('testlastname'); 
            Case testCase = createCaseForAddVehicle();
            string	clientIdentifier = Ha4cWebController.getClientIdentifier(testCase.AccountId);
            String expectedParm = 'https://necholauncher-v1-env3.app-71a.opr.test.statefarm.org/nechoLauncher/launchHA4C?selPolicy=599 7365-C04-25B&selPolOpt=2&lob=A&caseID='+testCase.Id+'&associateID=AGNTName&clientID='+clientIdentifier;
            User loggedInUser = Ha4cWebController.getUserRecord();
            System.assertEquals('AGNTName', loggedInUser.Alias, 'logged in user does not match');
            String parm = Ha4cWebController.getPolicyDetailsParmHA4C(testCase.Id);
            System.assertEquals(expectedParm, parm, 'Parm values do not match check controller');   
        }
        Test.StopTest();
    }
    
    @isTest
    private static void testGetPolicyDetailsParmAsSingleAgentUserBilling() {
        
        Test.StartTest();
        setup();
        
        System.runas(agentUser) {
            setTestNechoUrl();
            createAccount('testlastname'); 
            Case testCase = createCaseForBilling();
            string	clientIdentifier = Ha4cWebController.getClientIdentifier(testCase.AccountId);
            String expectedParm = 'https://necholauncher-v1-env3.app-71a.opr.test.statefarm.org/nechoLauncher/launchHA4C?selPolicy=599 7365-C04-25B&selPolOpt=2&lob=A&caseID='+testCase.Id+'&associateID=AGNTName&clientID='+clientIdentifier;
            User loggedInUser = Ha4cWebController.getUserRecord();
            System.assertEquals('AGNTName', loggedInUser.Alias, 'logged in user does not match');
            String parm = Ha4cWebController.getPolicyDetailsParmHA4C(testCase.Id);
            System.assertEquals(expectedParm, parm, 'Parm values do not match check controller');            
        }
        Test.StopTest();
    }

@isTest
    private static  void testGetPolicyDetailsParmAsCCCUser() {
        Test.startTest();
        setup();
        Case testCase;
        System.runAs(agentUser) {
            createAccount('testlastname1'); 
            testCase = createCaseWithValues();
        }
        
        System.runAs(cccUser) {
			setTestNechoUrl();
            string	clientIdentifier = Ha4cWebController.getClientIdentifier(testCase.AccountId);
            String expectedParm = 'https://necholauncher-v1-env3.app-71a.opr.test.statefarm.org/nechoLauncher/launchHA4C?selPolicy=599 7365-C04-25B&selPolOpt=2&lob=A&caseID='+testCase.Id+'&associateID=AGNTName&clientID='+clientIdentifier;

            User loggedInUser = Ha4cWebController.getUserRecord();
            System.assertEquals('TeCCCNa', loggedInUser.Alias, 'logged in user does not match');
            String parm = Ha4cWebController.getPolicyDetailsParmHA4C(testCase.Id);
            System.assertEquals(expectedParm, parm, 'Parm values do not match check controller'); 
        }
        Test.StopTest();
    }

    
    
}