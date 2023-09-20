/**
* @name UTIL_CustomerGroupMemberDetail_TEST
* @author Poseidon
* @createdDate 10/9/2018
* @description Test class to test utility class used by the CustomerGroupMemberDetail component
*/
@isTest(seeAllData = false)
public with sharing class UTIL_CustomerGroupMemberDetail_TEST {
	private static User agentUser {get;set;}
    private static User atmUser {get;set;}
    private static User noAccessUser {get;set;}
    private static Account acc {get;set;}
    private static Account acc2 {get;set;}
    private static CustomerGroup__c custGroup {get;set;}
    private static CustomerGroupMember__c custGrpMember {get;set;}
    private static Map<Id, String> relationshipMap {get;set;}
    
    private static void setup() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        custGroup = null;
        agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'AGNTName', 'AGNTName','AGNTName','AGNTName');
        atmUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.01 Agent Team Member', 'TestName', 'TestName','TestName','TestName');
        noAccessUser =  new User(alias = 'SYSA', email='noaccessTest@statefarm.com.bad', 
                                 emailencodingkey='UTF-8', lastname='TestSysRecOwner', languagelocalekey='en_US', 
                                 localesidkey='en_US', timezonesidkey='America/Chicago', username= 'sysAccRecOwner@test.com');
        noAccessUser.ProfileId = [select Id from Profile where name = '1.02 No Access' LIMIT 1].Id;
     
        atmUser.Servicing_Agent_Associate_ID__c = agentUser.Associate_ID__c;
        insert new List<User>{agentUser, atmUser, noAccessUser};
        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(true, agentUser);
        insert passTriggerAll;
        CS001_ByPassTriggerAll__c passTriggerAllNoAccess = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(true, noAccessUser);
        insert passTriggerAllNoAccess;
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(agentUser);
        objectBasedByPassTrigger.Override_CustomerGroupBeforeInsert__c = true;
        insert objectBasedByPassTrigger;   
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
    }
    
    private static CustomerGroup__c buildCustomerGroup(User agentUser) {
        CustomerGroup__c cg = new CustomerGroup__c();
        cg.name = 'Primary Household';
        cg.sfgroupidentifier__c = 'ABCD1234567';
        cg.OwnerId = agentUser.Id;
        return cg;
    }
    
    private static CustomerGroupMember__c buildCustomerGroupMember(Account cust, CustomerGroup__c grp, boolean isPrimaryContact) {
        custGrpMember = new CustomerGroupMember__c();
        custGrpMember.customer__c = cust.id;
        custGrpMember.group__c = grp.id;
        custGrpMember.groupmemberid__c = grp.sfgroupidentifier__c + '~' + cust.clientidentifier__c;
        custGrpMember.MemberPrimaryContact__c = isPrimaryContact;
        return custGrpMember;
    }
    
    private static void setupCustomerGroupWithAccount() {
        acc = createIndividualWithValues('Alice');
        acc.clientidentifier__c = 'TESTCLNTID8';
        insert acc;
        custGroup = buildCustomerGroup(agentUser);
        insert custGroup;
        CustomerGroupMember__c c3 = buildCustomerGroupMember(acc, custGroup, true);       
        insert c3;      
        acc = [SELECT id, name, personcontactId from Account where Id =: acc.Id];
    }
    
    private static void setupCustomerGroupWithSecondAccount() {
        acc = createIndividualWithValues('Alice');
        acc.clientidentifier__c = 'TESTCLNTID8';
        insert acc;
        acc2 = createSecondIndividualWithValues('Bob');
        acc2.clientidentifier__c = 'TESTCLNTID9';
        insert acc2;
        custGroup = buildCustomerGroup(agentUser);
        insert custGroup;
        CustomerGroupMember__c c3 = buildCustomerGroupMember(acc, custGroup, true);       
        insert c3; 
        CustomerGroupMember__c c4 = buildCustomerGroupMember(acc2, custGroup, false);       
        insert c4;
        acc = [SELECT id, name, personcontactId from Account where Id =: acc.Id];
        acc2 = [SELECT id, name, personcontactId from Account where Id =: acc2.Id];
    }
    
    private static Account createIndividualWithValues(String firstName) {
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
        acc.Gender__pc = 'Female';
        acc.PersonBirthdate = Date.parse('3/20/1987');
        acc.IsDeathNotificationReceived__pc = true;
        return acc;
    }
    
    private static Account createSecondIndividualWithValues(String firstName) {
        Account acc2 = UTIL_CreateCustomerTestData.createIndividualCustomer('Test Last Name');
        acc2.FirstName = firstName;
        acc2.BillingAddressType__c = 'US';
        acc2.BillingStreet = 'Test Street Test Street Test Street \n Test Street Test Street Test Street \n Test Street Test Street Test Street Test Street Test Street ';
        acc2.BillingCity = 'Bloomington';
        acc2.BillingState = 'IL';
        acc2.BillingPostalCode = '61704';
        acc2.BillingCountry = 'US';
        acc2.MailingAttention__c= 'Attn';
        acc2.ShippingAddressType__c = 'US';
        acc2.ShippingStreet = 'Test Street Test Street Test Street \n Test Street Test Street Test Street \n Test Street Test Street Test Street Test Street Test Street ';
        acc2.ShippingCity = 'Bloomington';
        acc2.ShippingState = 'IL';
        acc2.ShippingPostalCode = '61704';
        acc2.ShippingCountry = 'US';
        acc2.Gender__pc = 'Male';
        acc2.PersonBirthdate = Date.parse('7/14/1986');
        acc.IsDeathNotificationReceived__pc = false;
        return acc2;
    }
    
    private static Relationship__c buildRelationship(Account acctOne, Account acctTwo, String relationType) {
        Relationship__c relationship = new Relationship__c();
        relationship.AccountOne__c = acctOne.Id;
        relationship.AccountTwo__c = acctTwo.Id;
        relationship.RelationshipIdentifier__c = 'TESTCLNTID8~TESTCLNTID9';
        relationship.RelationshipType__c = relationType;
        insert relationship;
        
        return relationship;
    }
    
    @isTest
    static void testFetchDataMemberDetailFirstAccount() {
        Test.startTest();
        setup();
        
        System.runAs(agentUser) {
            UTIL_CustomerGroupMemberDetail.GroupMemberWrapper groupMemberWrapper = new UTIL_CustomerGroupMemberDetail.GroupMemberWrapper();
            setupCustomerGroupWithAccount(); 

            UTIL_CustomerGroupMemberDetail.FetchDataWrapper dataWrap = new UTIL_CustomerGroupMemberDetail.FetchDataWrapper();
            dataWrap.groupRecordId = custGroup.Id;
            dataWrap.relatedListType = 'Group Members';
            dataWrap.accountId = acc.id;
            dataWrap.queryLimit = 10;

            CustomerGroupRelatedListController.DataTableResponse customerGroupRelatedResponse = UTIL_CustomerGroupMemberDetail.fetchData(dataWrap);
            List<Object> dataRespList = customerGroupRelatedResponse.lstDataTableData;
            
            groupMemberWrapper = (UTIL_CustomerGroupMemberDetail.GroupMemberWrapper) dataRespList[0];
            System.assertEquals('/one/one.app#/sObject/'+ acc.Id, groupMemberWrapper.accountNameUrl, 'Expected URL is not equals to the actual URL');
            System.assertEquals('Alice Test Last Name', groupMemberWrapper.accountName, 'Expected account name is not equals to the actual account name');
            System.assertEquals('Female', groupMemberWrapper.gender, 'Expected Gender is not equals to the actual Gender');
            System.assertEquals(Date.parse('3/20/1987'), Date.parse(groupMemberWrapper.birthDate), 'Expected Date is not equals to the actual Date');
            System.assertEquals(true, groupMemberWrapper.isPrimaryContact, 'isPrimaryContact is false');
            System.assertEquals('Self', groupMemberWrapper.customerRelationship, '\'customerRelationship\' is not equals to \'Self\'');
            System.assertEquals('ABCD1234567', customerGroupRelatedResponse.externalId, 'Expected external id is not equals to the actual external id');
            System.assertEquals('DECEASED', groupMemberWrapper.deathNotification, 'Expected deathNotification is not equals to the actual deathNotification');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testFetchDataMemberDetailSecondAccount() {
        Test.startTest();
        setup();
        
        System.runAs(agentUser) {
            UTIL_CustomerGroupMemberDetail.GroupMemberWrapper groupMemberWrapper = new UTIL_CustomerGroupMemberDetail.GroupMemberWrapper();
            setupCustomerGroupWithSecondAccount();

            UTIL_CustomerGroupMemberDetail.FetchDataWrapper dataWrap = new UTIL_CustomerGroupMemberDetail.FetchDataWrapper();
            dataWrap.groupRecordId = custGroup.Id;
            dataWrap.relatedListType = 'Group Members';
            dataWrap.accountId = acc.id;
            dataWrap.queryLimit = 10;

            CustomerGroupRelatedListController.DataTableResponse customerGroupRelatedResponse = UTIL_CustomerGroupMemberDetail.fetchData(dataWrap);
            List<Object> dataRespList = customerGroupRelatedResponse.lstDataTableData;
            
            UTIL_CustomerGroupMemberDetail.GroupMemberWrapper response = new UTIL_CustomerGroupMemberDetail.GroupMemberWrapper();
            UTIL_CustomerGroupMemberDetail.GroupMemberWrapper actualGroupMember;
            for (Object dataResp : dataRespList) {
                response = (UTIL_CustomerGroupMemberDetail.GroupMemberWrapper) dataResp;
                if ('Bob Test Last Name'.equals(response.accountName)) {
                    actualGroupMember = response;
                    break;
                }
            }
            
            System.assertEquals('/one/one.app#/sObject/'+ acc2.Id, actualGroupMember.accountNameUrl, 'Expected URL is not equals to the actual URL');
            System.assertEquals('Bob Test Last Name', actualGroupMember.accountName, 'Expected Account Name is not equals to the actual Account Name');
            System.assertEquals('Male', actualGroupMember.gender, 'Gender is not Male');
            System.assertEquals(Date.parse('7/14/1986'), Date.parse(actualGroupMember.birthDate), 'Expected Date is not equals to the actual Date');
            System.assertEquals(false, actualGroupMember.isPrimaryContact, 'isPrimaryContact is true');
            System.assertEquals(null, groupMemberWrapper.deathNotification, 'deathNotification is not null');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCustomerRelationship() {
        Test.startTest();
        setup();
        
        System.runAs(agentUser) {
            setupCustomerGroupWithSecondAccount();
            Relationship__c relationship = buildRelationship(acc2, acc, 'Spouse');
            
            UTIL_CustomerGroupMemberDetail.FetchDataWrapper dataWrap = new UTIL_CustomerGroupMemberDetail.FetchDataWrapper();
            dataWrap.groupRecordId = custGroup.Id;
            dataWrap.relatedListType = 'Group Members';
            dataWrap.accountId = acc.id;
            dataWrap.queryLimit = 10;

            CustomerGroupRelatedListController.DataTableResponse customerGroupRelatedResponse = UTIL_CustomerGroupMemberDetail.fetchData(dataWrap);
            List<Object> dataRespList = customerGroupRelatedResponse.lstDataTableData;
            
            UTIL_CustomerGroupMemberDetail.GroupMemberWrapper response = new UTIL_CustomerGroupMemberDetail.GroupMemberWrapper();
            UTIL_CustomerGroupMemberDetail.GroupMemberWrapper actualGroupMember;
            
            for (Object dataResp : dataRespList) {
                response = (UTIL_CustomerGroupMemberDetail.GroupMemberWrapper) dataResp;
                if ('Bob Test Last Name'.equals(response.accountName)) {
                    actualGroupMember = response;
                    break;
                }
            }
            
            System.assertEquals(relationship.RelationshipType__c, actualGroupMember.customerRelationship, 'The given two parameters are not equal');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testUpdatePrimaryContact() {
    	Test.startTest();
        setup();
        
        System.runAs(agentUser) {
            setupCustomerGroupWithSecondAccount();
            String primaryContact = '';
            String requestedMemberContact = '';
            CustomerGroupMember__c primaryMember;
            CustomerGroupMember__c primaryToRequest;
            CustomerGroupMember__c updatedPrimaryMember;
            CustomerGroupMember__c updatedRequestedMember;
            
            List<CustomerGroupMember__c> groupMembers = [SELECT id, Customer__c, Customer__r.Name, Customer__r.PersonBirthDate, Customer__r.Gender__pc,
                                                   MemberPrimaryContact__c FROM CustomerGroupMember__c WHERE Group__c = :custGroup.Id];
            
            List<CustomerGroupMember__c> lstUpdateCustomerGrpMember = new List<CustomerGroupMember__c>();
            for (CustomerGroupMember__c member : groupMembers) {
                if (member.Customer__c == acc.Id) {
                    member.MemberPrimaryContact__c = true;
                    lstUpdateCustomerGrpMember.add(member);
                    primaryMember = member;
                    primaryContact = member.Customer__c;
                }
                if (member.Customer__c == acc2.Id) {
                    member.MemberPrimaryContact__c = false;
                    lstUpdateCustomerGrpMember.add(member);
                    primaryToRequest = member;
                    requestedMemberContact = member.Customer__c;
                }   
            }
            if(lstUpdateCustomerGrpMember != null && lstUpdateCustomerGrpMember.size() > 0){
                update lstUpdateCustomerGrpMember;
            }
            
         	Boolean result = false;

            UTIL_CustomerGroupMemberDetail.PrimaryContactWrapper prConWrap = new UTIL_CustomerGroupMemberDetail.PrimaryContactWrapper();
            prConWrap.primaryContact = primaryContact;
            prConWrap.requestedMember = requestedMemberContact;
            prConWrap.groupRecordId = custGroup.id;
            prConWrap.queryLimit = 10;

            result = UTIL_CustomerGroupMemberDetail.updatePrimaryContact(prConWrap);
            
            List<CustomerGroupMember__c> updatedGroupMembers = [SELECT id, Customer__c, Customer__r.Name, Customer__r.PersonBirthDate, Customer__r.Gender__pc,
                                                   MemberPrimaryContact__c FROM CustomerGroupMember__c WHERE Group__c = :custGroup.Id];
            
            for (CustomerGroupMember__c updatedMember : updatedGroupMembers) {
                if (updatedMember.Customer__c == acc.Id) {
                    updatedPrimaryMember = updatedMember;
                }
                if (updatedMember.Customer__c == acc2.Id) {
                    updatedRequestedMember = updatedMember;  
                }   
            }
            
            System.assert(result, 'result is false');
            System.assertEquals(false, updatedPrimaryMember.MemberPrimaryContact__c, 'MemberPrimaryContact__c is true');
            System.assertEquals(true, updatedRequestedMember.MemberPrimaryContact__c, 'MemberPrimaryContact__c is false');           
        }
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateAlreadyPrimaryContact() {
    	Test.startTest();
        setup();
        
        System.runAs(agentUser) {
            setupCustomerGroupWithSecondAccount();
            String primaryContact = '';
            String requestedMemberContact = '';
            CustomerGroupMember__c primaryMember;
            CustomerGroupMember__c primaryToRequest;
            CustomerGroupMember__c updatedPrimaryMember;
            CustomerGroupMember__c updatedRequestedMember;
            
            List<CustomerGroupMember__c> groupMembers = [SELECT id, Customer__c, Customer__r.Name, Customer__r.PersonBirthDate, Customer__r.Gender__pc,
                                                   MemberPrimaryContact__c FROM CustomerGroupMember__c WHERE Group__c = :custGroup.Id];
            
            List<CustomerGroupMember__c> lstUpdateCustomerGrpMember = new List<CustomerGroupMember__c>();
            for (CustomerGroupMember__c member : groupMembers) {
                if (member.Customer__c == acc.Id) {
                    member.MemberPrimaryContact__c = true;
                    lstUpdateCustomerGrpMember.add(member);
                    primaryMember = member;
                    primaryContact = member.Customer__c;
                }
                if (member.Customer__c == acc2.Id) {
                    member.MemberPrimaryContact__c = false;
                    lstUpdateCustomerGrpMember.add(member);
                    primaryToRequest = member;
                    requestedMemberContact = member.Customer__c;
                }   
            }
            if(lstUpdateCustomerGrpMember != null && lstUpdateCustomerGrpMember.size() > 0){
                update lstUpdateCustomerGrpMember;
            }

         	Boolean result = false;

            UTIL_CustomerGroupMemberDetail.PrimaryContactWrapper prConWrap = new UTIL_CustomerGroupMemberDetail.PrimaryContactWrapper();
            prConWrap.primaryContact = requestedMemberContact;
            prConWrap.requestedMember = primaryContact;
            prConWrap.groupRecordId = custGroup.id;
            prConWrap.queryLimit = 10;

            result = UTIL_CustomerGroupMemberDetail.updatePrimaryContact(prConWrap);
            
            List<CustomerGroupMember__c> updatedGroupMembers = [SELECT id, Customer__c, Customer__r.Name, Customer__r.PersonBirthDate, Customer__r.Gender__pc,
                                                   MemberPrimaryContact__c FROM CustomerGroupMember__c WHERE Group__c = :custGroup.Id];
            
            for (CustomerGroupMember__c updatedMember : updatedGroupMembers) {
                if (updatedMember.Customer__c == acc.Id) {
                    updatedPrimaryMember = updatedMember;
                }
                if (updatedMember.Customer__c == acc2.Id) {
                    updatedRequestedMember = updatedMember;  
                }   
            }
            
            System.assert(result, 'result is false');
            System.assertEquals(true, updatedPrimaryMember.MemberPrimaryContact__c, 'MemberPrimaryContact__c is false');
            System.assertEquals(false, updatedRequestedMember.MemberPrimaryContact__c, 'MemberPrimaryContact__c is true');           
        }
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateNonExistentPrimaryContact() {
        Test.startTest();
        setup();
        
        System.runAs(agentUser) {
        	setupCustomerGroupWithAccount();
            String primaryContact = '';
            String requestedMemberContact = '';
            CustomerGroupMember__c primaryToRequest;
            List<CustomerGroupMember__c> groupMembers = [SELECT id, Customer__c, Customer__r.Name, Customer__r.PersonBirthDate, Customer__r.Gender__pc,
                                                   MemberPrimaryContact__c FROM CustomerGroupMember__c WHERE Group__c = :custGroup.Id];
            for (CustomerGroupMember__c member : groupMembers) {
                if (member.Customer__c == acc.Id) {
                    primaryToRequest = member;
                    requestedMemberContact = member.Customer__c;
                }
            }

            UTIL_CustomerGroupMemberDetail.PrimaryContactWrapper prConWrap = new UTIL_CustomerGroupMemberDetail.PrimaryContactWrapper();
            prConWrap.primaryContact = primaryContact;
            prConWrap.requestedMember = requestedMemberContact;
            prConWrap.groupRecordId = custGroup.id;
            prConWrap.queryLimit = 10;

            Boolean result = UTIL_CustomerGroupMemberDetail.updatePrimaryContact(prConWrap);
            System.assert(result, 'result is false');
            System.assertEquals(true, primaryToRequest.MemberPrimaryContact__c, 'MemberPrimaryContact__c is false');
        }
        Test.stopTest();
    }
}