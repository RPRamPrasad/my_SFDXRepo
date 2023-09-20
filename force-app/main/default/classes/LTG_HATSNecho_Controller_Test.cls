/**
* Author : Team Poseidon
* Date Created : 06/30/2020
* Modified by Team STIA 10/4/2021
* Description : Test class for the LTG_HATSNecho_Controller_Test apex class.
*/

@isTest(seeAllData=false)
public class LTG_HATSNecho_Controller_Test {
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
    
    private static String setTestEnvUrl() {
        CS_EnvironmentURLCustomSetting__c testEnvUrl = new CS_EnvironmentURLCustomSetting__c(Name='S1BaseUrl',Value__c='https://statefarm--plnnnenv1.lightning.force.com');
        insert testEnvUrl;
        return testEnvUrl.Value__c;
    }

    private static String setPerfEnvUrl() {
        CS_EnvironmentURLCustomSetting__c testEnvUrl = new CS_EnvironmentURLCustomSetting__c(Name='S1BaseUrl',Value__c='https://statefarm--pfpbfarcus.lightning.force.com');
        insert testEnvUrl;
        return testEnvUrl.Value__c;
    }
    
    private static String setProdEnvUrl() {
        CS_EnvironmentURLCustomSetting__c prodEnvUrl = new CS_EnvironmentURLCustomSetting__c(Name='S1BaseUrl',Value__c='https://statefarm.lightning.force.com');
        insert prodEnvUrl;
        return prodEnvUrl.Value__c;
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
        caseRec.PolicyNumber__c = '3982108C1843';
        caseRec.Policy_Identifier__c = '2345678';
        caseRec.LOB__c = 'Auto';
        caseRec.ProductDescription__c = '2017 Ford Taurus 4dr';
        caseRec.ownerId = agentUser.Id;
        caseRec.Reason = setCaseReason('Policy - Change/Request');

        Map <String,Schema.RecordTypeInfo> recordTypeMap = Case.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getRecordTypeInfosByName();
        
        if (recordTypeMap.containsKey('Policy Change')) {
           caseRec.RecordTypeId = recordTypeMap.get('Policy Change').getRecordTypeId();
        }

        insert caseRec;
        return caseRec;
    }
    
    private static Case createCaseWithValuesATM() {
        Case caseRec = new Case();
        caseRec.AccountId =  testAccount.id;
        caseRec.Status = 'New';
        caseRec.PolicyNumber__c = '3982108C1843';
        caseRec.Policy_Identifier__c = '2345678';
        caseRec.LOB__c = 'Auto';
        caseRec.ProductDescription__c = '2017 Ford Taurus 4dr';
        caseRec.Reason = setCaseReason('Policy - Change/Request');

        Map <String,Schema.RecordTypeInfo> recordTypeMap = Case.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getRecordTypeInfosByName();
        
        if (recordTypeMap.containsKey('Policy Change')) {
           caseRec.RecordTypeId = recordTypeMap.get('Policy Change').getRecordTypeId();
        }

        insert caseRec;
        return caseRec;
    }

    private static Case createCaseForBilling() {
        Case caseRec = new Case();
        caseRec.AccountId =  testAccount.id;
        caseRec.Status = 'New';
        caseRec.PolicyNumber__c = '3982108C1843';
        caseRec.Policy_Identifier__c = '3982108';
        caseRec.LOB__c = 'Auto';
        caseRec.ProductDescription__c = '2017 Ford Taurus 4dr';

        Map <String,Schema.RecordTypeInfo> recordTypeMap = Case.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getRecordTypeInfosByName();
        
        if (recordTypeMap.containsKey('Billing')) {
           caseRec.RecordTypeId = recordTypeMap.get('Billing').getRecordTypeId();
        }

        insert caseRec;
        return caseRec;
    }

    private static Case createCaseForAddVehicle() {
        Case caseRec = new Case();
        caseRec.AccountId =  testAccount.id;
        caseRec.Status = 'New';
        caseRec.PolicyNumber__c = '3982108C1843';
        caseRec.Policy_Identifier__c = '3982108';
        caseRec.LOB__c = 'Auto';
        caseRec.ProductDescription__c = '2017 Ford Taurus 4dr';
        caseRec.Reason = setCaseReason('Added Vehicle');
        Map <String,Schema.RecordTypeInfo> recordTypeMap = Case.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getRecordTypeInfosByName();
        
        if (recordTypeMap.containsKey('Policy Change')) {
           caseRec.RecordTypeId = recordTypeMap.get('Policy Change').getRecordTypeId();
        }

        insert caseRec;
        return caseRec;
    }

    private static Case createCaseWithSpecialCharacters() {
        Case caseRec = new Case();
        caseRec.AccountId =  testAccount.id;
        caseRec.Status = 'New';
        caseRec.PolicyNumber__c = '3982108C1843';
        caseRec.Policy_Identifier__c = '2345678';
        caseRec.LOB__c = 'Auto';
        caseRec.ProductDescription__c = '2017 Ford Taurus 4dr #&(%!@^)1';
        caseRec.Reason = setCaseReason('Policy - Change/Request');

        Map <String,Schema.RecordTypeInfo> recordTypeMap = Case.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getRecordTypeInfosByName();
        
        if (recordTypeMap.containsKey('Policy Change')) {
           caseRec.RecordTypeId = recordTypeMap.get('Policy Change').getRecordTypeId();
        }

        insert caseRec;
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
        return caseRec;
    }
    
    @isTest
    private static void testGetPolicyDetailsJsonAsSingleAgentUser() {
        
        Test.StartTest();
        setup();
        
        System.runas(agentUser) {
            String envUrl = setTestEnvUrl();
            createAccount('testlastname');
            Case testCase = createCaseWithValues();
            String expectedJson ='%7B%22appIDWEL%22%3A%22L+NESAE0S1%22%2C%22caseId%22%3A%22' + testCase.Id + '%22%2C%22reason%22%3A%22Policy+-+Change%2FRequest%22%2C%22recordType%22%3A%22Policy+Change%22%2C%22workstationIDWEL%22%3A%22WPWFQD0T%22%2C%22selectionNumWEL%22%3A%221%22%2C%22accessAgentCodeWEL%22%3A%22431071%22%2C%22lob%22%3A%22A%22%2C%22policyNum%22%3A%223982108C1843%22%2C%22transactionType%22%3A%222%22%2C%22ownerAssociateId%22%3A%22AGNTName%22%2C%22clientId%22%3A%22null%22%2C%22policyDescription%22%3A%222017+Ford+Taurus+4dr%22%2C%22env%22%3A%22https%3A%2F%2Fstatefarm--plnnnenv1.lightning.force.com%22%7D'; 
            User loggedInUser = LTG_HATSNecho_Controller.getUserRecord();
            System.assertEquals('AGNTName', loggedInUser.Alias, 'logged in user does not match');
            
        	String json = LTG_HATSNecho_Controller.getPolicyDetailsJson(testCase.Id);
            System.assertEquals('https://statefarm--plnnnenv1.lightning.force.com', envUrl, 'expected url does not match');
        	System.assertEquals(false, LTG_HATSNecho_Controller.isProd, 'controller status is not as expected');
            
        	System.assertEquals(expectedJson, json, 'json values do not match check controller');           
    	}
    	Test.StopTest();
	}
    
    @isTest
    static void testGetPolicyDetailsJsonAsAgentUserProd() {
        
        Test.StartTest();
        setup();
        
        System.runas(agentUser) {
            String envUrl = setProdEnvUrl();
            createAccount('testlastname1');
            Case testCase = createCaseWithValues();
            String expectedJson ='%7B%22appIDWEL%22%3A%22L+CICSEHTG%22%2C%22caseId%22%3A%22' + testCase.Id + '%22%2C%22reason%22%3A%22Policy+-+Change%2FRequest%22%2C%22recordType%22%3A%22Policy+Change%22%2C%22workstationIDWEL%22%3A%22WPWFQD0T%22%2C%22selectionNumWEL%22%3A%221%22%2C%22accessAgentCodeWEL%22%3A%22431071%22%2C%22lob%22%3A%22A%22%2C%22policyNum%22%3A%223982108C1843%22%2C%22transactionType%22%3A%222%22%2C%22ownerAssociateId%22%3A%22AGNTName%22%2C%22clientId%22%3A%22null%22%2C%22policyDescription%22%3A%222017+Ford+Taurus+4dr%22%2C%22env%22%3A%22https%3A%2F%2Fstatefarm.lightning.force.com%22%7D'; 
            
            User loggedInUser = LTG_HATSNecho_Controller.getUserRecord();
            System.assertEquals('AGNTName', loggedInUser.Alias, 'logged in user does not match');
       	
            String json = LTG_HATSNecho_Controller.getPolicyDetailsJson(testCase.Id);
            System.assertEquals('https://statefarm.lightning.force.com', envUrl, 'expected url does not match');
        	System.assertEquals(true, LTG_HATSNecho_Controller.isProd, 'controller status is not as expected');
            System.assertEquals(expectedJson, json, 'json values do not match check controller');              
        }
        Test.StopTest();
	}

    @isTest
    static void testGetPolicyDetailsJsonAsATMUser() {
        
        Test.StartTest();
        setup();
        
        System.runas(atmUser) {
            String envUrl = setTestEnvUrl();
            createAccount('testlastname1');
            Case testCase = createCaseWithValuesATM();
            String expectedJson ='%7B%22appIDWEL%22%3A%22L+NESAE0S1%22%2C%22caseId%22%3A%22' + testCase.Id + '%22%2C%22reason%22%3A%22Policy+-+Change%2FRequest%22%2C%22recordType%22%3A%22Policy+Change%22%2C%22workstationIDWEL%22%3A%22WPWFQD1T%22%2C%22selectionNumWEL%22%3A%221%22%2C%22accessAgentCodeWEL%22%3A%22132375%22%2C%22lob%22%3A%22A%22%2C%22policyNum%22%3A%223982108C1843%22%2C%22transactionType%22%3A%222%22%2C%22ownerAssociateId%22%3A%22AGNTName%22%2C%22clientId%22%3A%22null%22%2C%22policyDescription%22%3A%222017+Ford+Taurus+4dr%22%2C%22env%22%3A%22https%3A%2F%2Fstatefarm--plnnnenv1.lightning.force.com%22%7D';

            User loggedInUser = LTG_HATSNecho_Controller.getUserRecord();
            System.assertEquals('TestName', loggedInUser.Alias, 'logged in user does not match');
 
            String json = LTG_HATSNecho_Controller.getPolicyDetailsJson(testCase.Id);
            System.assertEquals('https://statefarm--plnnnenv1.lightning.force.com', envUrl, 'expected url does not match');
        	System.assertEquals(false, LTG_HATSNecho_Controller.isProd, 'controller status is not as expected');
            System.assertEquals(expectedJson, json, 'json values do not match check controller');              
        }
        Test.StopTest();
	}

    @isTest
    static void testGetPolicyDetailsJsonAsATMUserProd() {
        
        Test.StartTest();
        setup();
        
        System.runas(atmUser) {
            String envUrl = setProdEnvUrl();
            createAccount('testlastname1');            
            Case testCase = createCaseWithValuesATM();
            String expectedJson ='%7B%22appIDWEL%22%3A%22L+CICSEATG%22%2C%22caseId%22%3A%22' + testCase.Id + '%22%2C%22reason%22%3A%22Policy+-+Change%2FRequest%22%2C%22recordType%22%3A%22Policy+Change%22%2C%22workstationIDWEL%22%3A%22WPWFQD1T%22%2C%22selectionNumWEL%22%3A%221%22%2C%22accessAgentCodeWEL%22%3A%22132375%22%2C%22lob%22%3A%22A%22%2C%22policyNum%22%3A%223982108C1843%22%2C%22transactionType%22%3A%222%22%2C%22ownerAssociateId%22%3A%22AGNTName%22%2C%22clientId%22%3A%22null%22%2C%22policyDescription%22%3A%222017+Ford+Taurus+4dr%22%2C%22env%22%3A%22https%3A%2F%2Fstatefarm.lightning.force.com%22%7D';
             
            User loggedInUser = LTG_HATSNecho_Controller.getUserRecord();
            System.assertEquals('TestName', loggedInUser.Alias, 'logged in user does not match');
            
            String json = LTG_HATSNecho_Controller.getPolicyDetailsJson(testCase.Id);
            System.assertEquals('https://statefarm.lightning.force.com', envUrl, 'expected url does not match');
        	System.assertEquals(true, LTG_HATSNecho_Controller.isProd, 'controller status is not as expected');
            System.assertEquals(expectedJson, json, 'json values do not match check controller');              
        }
        Test.StopTest();
	}

    @isTest
    private static void testGetPolicyDetailsJsonAsSingleAgentUserPerf() {
        
        Test.StartTest();
        setup();
        
        System.runas(agentUser) {
            String envUrl = setPerfEnvUrl();
            createAccount('testlastname');
            Case testCase = createCaseWithValues();
            String expectedJson ='%7B%22appIDWEL%22%3A%22L+CICS66TG%22%2C%22caseId%22%3A%22' + testCase.Id + '%22%2C%22reason%22%3A%22Policy+-+Change%2FRequest%22%2C%22recordType%22%3A%22Policy+Change%22%2C%22workstationIDWEL%22%3A%22WPWFQD0T%22%2C%22selectionNumWEL%22%3A%221%22%2C%22accessAgentCodeWEL%22%3A%22431071%22%2C%22lob%22%3A%22A%22%2C%22policyNum%22%3A%223982108C1843%22%2C%22transactionType%22%3A%222%22%2C%22ownerAssociateId%22%3A%22AGNTName%22%2C%22clientId%22%3A%22null%22%2C%22policyDescription%22%3A%222017+Ford+Taurus+4dr%22%2C%22env%22%3A%22https%3A%2F%2Fstatefarm--pfpbfarcus.lightning.force.com%22%7D'; 
           
            User loggedInUser = LTG_HATSNecho_Controller.getUserRecord();
            System.assertEquals('AGNTName', loggedInUser.Alias, 'logged in user does not match');
            
        	String json = LTG_HATSNecho_Controller.getPolicyDetailsJson(testCase.Id);
            System.assertEquals('https://statefarm--pfpbfarcus.lightning.force.com', envUrl, 'expected url does not match');
        	System.assertEquals(false, LTG_HATSNecho_Controller.isProd, 'controller status is not as expected');
            
        	System.assertEquals(expectedJson, json, 'json values do not match check controller');           
    	}
    	Test.StopTest();
	}

    @isTest
    static void testSpecialCharacters() {
        Test.startTest();
        setup();
        System.runAs(agentUser) {
            String envUrl = setTestEnvUrl();
            createAccount('testlastName');
            Case testCase = createCaseWithSpecialCharacters();
            String expectedJson ='%7B%22appIDWEL%22%3A%22L+NESAE0S1%22%2C%22caseId%22%3A%22' + testCase.Id + '%22%2C%22reason%22%3A%22Policy+-+Change%2FRequest%22%2C%22recordType%22%3A%22Policy+Change%22%2C%22workstationIDWEL%22%3A%22WPWFQD0T%22%2C%22selectionNumWEL%22%3A%221%22%2C%22accessAgentCodeWEL%22%3A%22431071%22%2C%22lob%22%3A%22A%22%2C%22policyNum%22%3A%223982108C1843%22%2C%22transactionType%22%3A%222%22%2C%22ownerAssociateId%22%3A%22AGNTName%22%2C%22clientId%22%3A%22null%22%2C%22policyDescription%22%3A%222017+Ford+Taurus+4dr+1%22%2C%22env%22%3A%22https%3A%2F%2Fstatefarm--plnnnenv1.lightning.force.com%22%7D';
            System.assertEquals('https://statefarm--plnnnenv1.lightning.force.com', envUrl, 'expected url does not match');
            String json = LTG_HATSNecho_Controller.getPolicyDetailsJson(testCase.Id);
            System.assertEquals(expectedJson, json, 'json values do not match check controller');
        }
        Test.StopTest();
    }

    @isTest
    static void testNullProductDescription() {
        Test.startTest();
        setup();
        System.runAs(agentUser) {
            String envUrl = setTestEnvUrl();
            createAccount('testlastName');
            Case testCase = createCaseWithNullProductDescription();
            String expectedJson ='%7B%22appIDWEL%22%3A%22L+NESAE0S1%22%2C%22caseId%22%3A%22' + testCase.Id + '%22%2C%22reason%22%3A%22Policy+-+Change%2FRequest%22%2C%22recordType%22%3A%22Policy+Change%22%2C%22workstationIDWEL%22%3A%22WPWFQD0T%22%2C%22selectionNumWEL%22%3A%221%22%2C%22accessAgentCodeWEL%22%3A%22431071%22%2C%22lob%22%3A%22A%22%2C%22policyNum%22%3A%223982108C1843%22%2C%22transactionType%22%3A%222%22%2C%22ownerAssociateId%22%3A%22AGNTName%22%2C%22clientId%22%3A%22null%22%2C%22policyDescription%22%3A%22null%22%2C%22env%22%3A%22https%3A%2F%2Fstatefarm--plnnnenv1.lightning.force.com%22%7D';
            System.assertEquals('https://statefarm--plnnnenv1.lightning.force.com', envUrl, 'expected url does not match');
            String json = LTG_HATSNecho_Controller.getPolicyDetailsJson(testCase.Id);
            System.assertEquals(expectedJson, json, 'json values do not match check controller');
        }
        Test.StopTest();
    }

    @isTest
    static void testGetPolicyDetailsJsonAsCCCUser() {
        Test.startTest();
        setup();

        Case testCase;
        System.runAs(agentUser) {
            createAccount('testlastName');
            testCase = createCaseWithValues();
        }

        System.runAs(cccUser) {
            String envUrl = setTestEnvUrl();
            String expectedJson ='%7B%22appIDWEL%22%3A%22L+NESAE0S1%22%2C%22caseId%22%3A%22' + testCase.Id + '%22%2C%22reason%22%3A%22Policy+-+Change%2FRequest%22%2C%22recordType%22%3A%22Policy+Change%22%2C%22workstationIDWEL%22%3A%22WPWFQD2T%22%2C%22selectionNumWEL%22%3A%221%22%2C%22accessAgentCodeWEL%22%3A%22431071%22%2C%22lob%22%3A%22A%22%2C%22policyNum%22%3A%223982108C1843%22%2C%22transactionType%22%3A%222%22%2C%22ownerAssociateId%22%3A%22AGNTName%22%2C%22clientId%22%3A%22null%22%2C%22policyDescription%22%3A%222017+Ford+Taurus+4dr%22%2C%22env%22%3A%22https%3A%2F%2Fstatefarm--plnnnenv1.lightning.force.com%22%7D';
            System.assertEquals('https://statefarm--plnnnenv1.lightning.force.com', envUrl, 'expected url does not match');
            String json = LTG_HATSNecho_Controller.getPolicyDetailsJson(testCase.Id);
            System.assertEquals(expectedJson, json, 'json values do not match check controller');
        }
        Test.StopTest();
    }

    @isTest
    private static void testGetPolicyDetailsJsonAsSingleAgentUserAddVehicle() {
        
        Test.StartTest();
        setup();
        
        System.runas(agentUser) {
            String envUrl = setTestEnvUrl();
            createAccount('testlastname');
            Case testCase = createCaseForAddVehicle();
            String expectedJson ='%7B%22appIDWEL%22%3A%22L+NESAE0S1%22%2C%22caseId%22%3A%22' + testCase.Id + '%22%2C%22reason%22%3A%22Added+Vehicle%22%2C%22recordType%22%3A%22Policy+Change%22%2C%22workstationIDWEL%22%3A%22WPWFQD0T%22%2C%22selectionNumWEL%22%3A%221%22%2C%22accessAgentCodeWEL%22%3A%22431071%22%2C%22lob%22%3A%22A%22%2C%22policyNum%22%3A%223982108C1843%22%2C%22transactionType%22%3A%222%22%2C%22ownerAssociateId%22%3A%22AGNTName%22%2C%22clientId%22%3A%22null%22%2C%22policyDescription%22%3A%222017+Ford+Taurus+4dr%22%2C%22env%22%3A%22https%3A%2F%2Fstatefarm--plnnnenv1.lightning.force.com%22%7D'; 
            User loggedInUser = LTG_HATSNecho_Controller.getUserRecord();
            System.assertEquals('AGNTName', loggedInUser.Alias, 'logged in user does not match');
            
        	String json = LTG_HATSNecho_Controller.getPolicyDetailsJson(testCase.Id);
            System.assertEquals('https://statefarm--plnnnenv1.lightning.force.com', envUrl, 'expected url does not match');
        	System.assertEquals(false, LTG_HATSNecho_Controller.isProd, 'controller status is not as expected');
            
        	System.assertEquals(expectedJson, json, 'json values do not match check controller');           
    	}
    	Test.StopTest();
	}

    @isTest
    private static void testGetPolicyDetailsJsonAsSingleAgentUserBilling() {
        
        Test.StartTest();
        setup();
        
        System.runas(agentUser) {
            String envUrl = setTestEnvUrl();
            createAccount('testlastname');
            Case testCase = createCaseForBilling();
            String expectedJson ='%7B%22appIDWEL%22%3A%22L+NESAE0S1%22%2C%22caseId%22%3A%22' + testCase.Id + '%22%2C%22reason%22%3A%22null%22%2C%22recordType%22%3A%22Billing%22%2C%22workstationIDWEL%22%3A%22WPWFQD0T%22%2C%22selectionNumWEL%22%3A%221%22%2C%22accessAgentCodeWEL%22%3A%22431071%22%2C%22lob%22%3A%22A%22%2C%22policyNum%22%3A%223982108C1843%22%2C%22transactionType%22%3A%222%22%2C%22ownerAssociateId%22%3A%22AGNTName%22%2C%22clientId%22%3A%22null%22%2C%22policyDescription%22%3A%222017+Ford+Taurus+4dr%22%2C%22env%22%3A%22https%3A%2F%2Fstatefarm--plnnnenv1.lightning.force.com%22%7D'; 
            User loggedInUser = LTG_HATSNecho_Controller.getUserRecord();
            System.assertEquals('AGNTName', loggedInUser.Alias, 'logged in user does not match');
            
        	String json = LTG_HATSNecho_Controller.getPolicyDetailsJson(testCase.Id);
            System.assertEquals('https://statefarm--plnnnenv1.lightning.force.com', envUrl, 'expected url does not match');
        	System.assertEquals(false, LTG_HATSNecho_Controller.isProd, 'controller status is not as expected');
            
        	System.assertEquals(expectedJson, json, 'json values do not match check controller');           
    	}
    	Test.StopTest();
	}

    @isTest
    static void testGetHost() {
        Test.startTest();
        setup();
        System.runAs(atmUser) {
            LTG_HATSNecho_Controller.isProd = true;
            LTG_HATSNecho_Controller.host = 'E01IBMVIPA1';
            String actualHost = LTG_HATSNecho_Controller.getHost();
			
            System.assertEquals(LTG_HATSNecho_Controller.host, actualHost, 'host does not match, check controller'); 
        }
        Test.StopTest();
    }
        
}