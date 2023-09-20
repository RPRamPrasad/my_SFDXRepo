/****************************************************************************************
Name: AP_CustomerGroupMemberTrigger_TEST
Copyright © State Farm
=========================================================================================
Purpose:
-------
Test Class for AP_CustomerGroupMemberTrigger

Team: Stark
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                   DETAIL
******************************************************************************************/

/**
 * @description AP CustomerGroupMember Trigger TEST
 */
@isTest (seeAllData = false)
public with sharing class AP_CustomerGroupMemberTrigger_TEST {
    private static User agentUser{get;set;}
    private static User atmUser{get;set;}
    private static User salesleaderUser{get;set;}
    private static User sysAdmin{get;set;}
    
    private static CustomerGroup__c buildCustomerGroup(User agent, String groupExtId) {
        CustomerGroup__c cg = new CustomerGroup__c();
        cg.name = 'Primary Household';
        cg.sfgroupidentifier__c = groupExtId;
        cg.agent__c = agent.id;
        cg.OwnerId = agent.id;
        return cg;
    }
    
    private static CustomerGroupMember__c buildCustomerGroupMember(String clntId, String grpExtId){
        CustomerGroupMember__c custGrpMember = new CustomerGroupMember__c();
        custGrpMember.customer__r = new Account(clientidentifier__c = clntId);
        custGrpMember.group__r = new CustomerGroup__c(sfgroupidentifier__c = grpExtId);
        custGrpMember.groupmemberid__c = grpExtId + '~' + clntId;
        return custGrpMember;
    }
    
    private static Account createIndividualWithValues(String firstName, String clientId) {
        Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('Test Last Name');
        acc.FirstName = firstName;
        acc.BillingAddressType__c = 'US';
        acc.BillingStreet = 'Test Street Test Street Test Street \n Test Street Test Street Test Street \n Test Street Test Street Test Street Test Street Test Street ';
        acc.BillingCity = 'Bloomington';
        acc.BillingState = 'IL';
        acc.BillingPostalCode = '61704';
        acc.BillingCountry = 'US';
        acc.MailingAttention__c= 'Attn';
        acc.ShippingAddressType__c = 'US';
        acc.ShippingStreet = 'Test Street Test Street Test Street \n Test Street Test Street Test Street \n Test Street Test Street Test Street Test Street Test Street ';
        acc.ShippingCity = 'Bloomington';
        acc.ShippingState = 'IL';
        acc.ShippingPostalCode = '61704';
        acc.ShippingCountry = 'US';
        acc.clientidentifier__c = clientId;
        return acc;
    }
    
    private static AccountShare createAccountShare(Account acc, User agent){
    	return new AccountShare(accountId = acc.Id, AccountAccessLevel='Edit', OpportunityAccessLevel='None', CaseAccessLevel='None', UserOrGroupId=agent.Id );
    }
    
    private static void setup()
    {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        sysAdmin = UTIL_CreateCustomerTestData.createUserWithAssoId('System Administrator', 'SysAdmin', 'SysAdmin','SysAdmin','SysAdmin');
        insert sysAdmin;
        System.runAs(sysAdmin){
	        agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'AGNTName', 'AGNTName','AGNTName','AGNTName');
	        atmUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.01 Agent Team Member', 'TestName', 'TestName','TestName','TestName');
	        salesleaderUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.02 Sales Leader', 'TestNam1', 'TestNam1','TestNam1','TestNam1');
	        atmUser.Servicing_Agent_Associate_ID__c = agentUser.Associate_ID__c;
	        insert new List<User>{agentUser, atmUser,salesleaderUser};
	        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(true,sysAdmin);
	        insert passTriggerAll;        
	        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(agentUser);
	        objectBasedByPassTrigger.Override_CustomerGroupBeforeInsert__c = true;
	        insert objectBasedByPassTrigger;
	        UTIL_SetFSCCustomSettings_TEST.setFSCSettings(); 
			TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        }
    }
    
	@isTest
    static void testinsertNewGroupMemberNoExistingData(){
    	setup();
    	Test.startTest();
    	System.runAs(sysAdmin){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
	    	CustomerGroup__c custGroup = buildCustomerGroup(agentUser, 'TestId00001');
	    	insert custGroup;
	    	Account acc = createIndividualWithValues('John', 'CLNTID00001');
	    	insert acc;
	    	insert createAccountShare(acc, agentUser);
	    }
	    System.runAs(agentUser){
	    	CustomerGroupMember__c custMember = buildCustomerGroupMember('CLNTID00001', 'TestId00001');
	    	Database.insert(custMember);
			List<CustomerGroupMember__c> custGrpMemberFromtable  = [Select id, name, group__c, group__r.agent__c from CustomerGroupMember__c where group__r.agent__c = :agentUser.Id and customer__r.clientIdentifier__c = 'CLNTID00001'];
	    	System.assertEquals(1, custGrpMemberFromtable.size(), 'Size of \'custGrpMemberFromtable\' is not equals to 1');
	    }
	    Test.stopTest();
    }
    
	@isTest
    static void testinsertNewGroupMemberWithOneExistingRecord(){
    	setup();
    	Test.startTest();
    	System.runAs(sysAdmin){
	    	CustomerGroup__c custGroup = buildCustomerGroup(agentUser, 'TestId00001');
	    	insert custGroup;
	    	insert buildCustomerGroup(agentUser, 'TestId00002'); 
	    	Account acc = createIndividualWithValues('John', 'CLNTID00001');
	    	insert acc;
	    	insert createAccountShare(acc, agentUser);
	    	insert buildCustomerGroupMember('CLNTID00001', 'TestId00002');
	    }
	    System.runAs(agentUser){
	    	Id custMemberId = [Select Id, name from CustomerGroupMember__c where groupmemberid__c = 'TestId00002~CLNTID00001' LIMIT 1].Id;
	    	CustomerGroupMember__c custMember = buildCustomerGroupMember('CLNTID00001', 'TestId00001');
	    	Database.insert(custMember);
			List<CustomerGroupMember__c> custGrpMemberFromtable  = [Select id, name, group__c, group__r.agent__c, groupmemberid__c from CustomerGroupMember__c where group__r.agent__c = :agentUser.Id and customer__r.clientIdentifier__c = 'CLNTID00001'];
	    	System.assertEquals(1, custGrpMemberFromtable.size(), 'Size of \'custGrpMemberFromtable\' is not equals to 1');
	    	System.assertEquals('TestId00001~CLNTID00001', custGrpMemberFromtable.get(0).groupmemberid__c, 'The given two parameters are not equal');
	    	System.assertNotEquals(custMemberId, custGrpMemberFromtable.get(0).Id, 'The given two parameters are not equal');
	    }
	    Test.stopTest();
    }
    
	@isTest
    static void testinsertMultipleGroupMemberWithExistingRecord(){
    	setup();
    	Test.startTest();
    	Map<String, User> agtUserMap = new Map<String, User>();
    	System.runAs(sysAdmin){
	    	Account acc = createIndividualWithValues('John', 'CLNTID00001');
	    	insert acc;
	    	List<User> userToInsert = new List<User>();
	    	List<CustomerGroup__c> custGroupListInsert = new List<CustomerGroup__c>();
	    	List<CustomerGroupMember__c> custGroupMemberListInsert = new List<CustomerGroupMember__c>();
	    	for(Integer i=1; i<6; i++){
		    	User agtUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'AGTName'+String.valueOf(i), 'AGTName'+String.valueOf(i),'AGTName'+String.valueOf(i),'AGTName'+String.valueOf(i));
		    	userToInsert.add(agtUser);
	    	}
	    	insert userToInsert;
	    	List<AccountShare>  accShareList = new List<AccountShare>();
	    	for(User agtUser : [SELECT Id, name, userexternalid__c from User where profile.name='2.00 Agent' and alias like 'AGTName%']){
	    		agtUserMap.put(agtUser.userexternalid__c, agtUser);
	    	}
	    	for(Integer i=1; i<6; i++){
	    		custGroupListInsert.add(buildCustomerGroup(agtUserMap.get('AGTName'+String.valueOf(i)), 'TESTID0000'+String.valueOf(i)));
	    		custGroupListInsert.add(buildCustomerGroup(agtUserMap.get('AGTName'+String.valueOf(i)), 'TESTID1000'+String.valueOf(i)));
		    	custGroupMemberListInsert.add(buildCustomerGroupMember('CLNTID00001', 'TESTID0000'+String.valueOf(i)));
		    	accShareList.add(createAccountShare(acc, agtUserMap.get('AGTName'+String.valueOf(i))));
	    	}
	    	insert custGroupListInsert;
	    	insert custGroupMemberListInsert;
	    	insert accShareList;
	    	User sysAdmin1 = UTIL_CreateCustomerTestData.createUserWithAssoId('System Administrator', 'SysAdmi1', 'SysAdmi1','SysAdmi1','SysAdmi1');
        	insert sysAdmin1;
        	System.runAs(sysAdmin1){
		    	List<CustomerGroupMember__c> custMemberList = new List<CustomerGroupMember__c>();
		    	for(Integer i=1; i<6; i++){
			    	custMemberList.add(buildCustomerGroupMember('CLNTID00001', 'TESTID1000'+String.valueOf(i)));
		    	}
		    	Database.insert(custMemberList);
				List<CustomerGroupMember__c> custGrpMemberFromtable  = [Select id, name, group__c, group__r.agent__c, groupmemberid__c from CustomerGroupMember__c where customer__r.clientIdentifier__c = 'CLNTID00001'];
		    	System.assertEquals(5, custGrpMemberFromtable.size(), 'Size of \'custGrpMemberFromtable\' is not equals to 5');
			    Test.stopTest();
        	}
    	}
    }
    
	@isTest
    static void testCatchException(){
    	setup();
    	Test.startTest();
    	System.runAs(agentUser){
    		try {
    			AP_CustomerGroupMemberTrigger.removeOldGroupings(null);
    			List<ExceptionLog__c> exceptionList = [SELECT id, name from ExceptionLog__c where Class__c = 'AP_CustomerGroupMemberTrigger'];
    			System.assert(!exceptionList.isEmpty(), '\'exceptionList\' is empty'); 
    		}
    		catch(Exception e){
    			List<ExceptionLog__c> exceptionList = [SELECT id, name from ExceptionLog__c where Class__c = 'AP_CustomerGroupMemberTrigger'];
    			System.assert(!exceptionList.isEmpty(), '\'exceptionList\' is empty');  			
    		}
    	}
    	Test.stopTest();
    }
}