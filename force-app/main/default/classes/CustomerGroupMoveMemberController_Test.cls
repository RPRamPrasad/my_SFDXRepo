@isTest(seeAllData = false)
public class CustomerGroupMoveMemberController_Test {
    
    private static final String SYSADMIN_USER_ID = UTIL_TestUsername_TEST.getTestUsername('sysadmin');
    private static User sysAdmUser {get;set;}
    
    private static User agentUser {get;set;}
    private static User atmUser {get;set;}
    private static User noAccessUser {get;set;}
    private static Account acc {get;set;}
    private static Account acc2 {get;set;}
    private static CustomerGroup__c custGroup {get;set;}
    private static CustomerGroupMember__c custGrpMember {get;set;}
    
    private static CustomerGroup__c custGroup2 {get;set;}
    private static CustomerGroup__c brandNewGroup {get;set;}
    private static Account acc3 {get;set;}
    private static Account acc4 {get;set;}
    @TestSetup
    private static void setup() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        custGroup = null;
        brandNewGroup = null;
        sysAdmUser = AP_UserProvisioningProcess_TEST_UTIL.createGenericSystemAdmin(SYSADMIN_USER_ID);
        
        agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'AGNTName', 'AGNTName','AGNTName','AGNTName_AGNTName');
        atmUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.01 Agent Team Member', 'TestName', 'TestName','TestName','TestName');
        noAccessUser =  new User(alias = 'SYSA', email='noaccessTest@statefarm.com.bad', 
                                 emailencodingkey='UTF-8', lastname='TestSysRecOwner', languagelocalekey='en_US', 
                                 localesidkey='en_US', timezonesidkey='America/Chicago', username= 'sysAccRecOwner@test.com');
        noAccessUser.ProfileId = [select Id from Profile where name = '1.02 No Access' LIMIT 1].Id;
        
        atmUser.Servicing_Agent_Associate_ID__c = agentUser.Associate_ID__c;
        insert new List<User>{agentUser, atmUser, noAccessUser};
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser, atmUser});
            
        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(true, agentUser);
        insert passTriggerAll;
        
        CS001_ByPassTriggerAll__c passTriggerAllNoAccess = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(true, noAccessUser);
        insert passTriggerAllNoAccess;
        
        
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(agentUser);
        objectBasedByPassTrigger.Override_CustomerGroupBeforeInsert__c = true;
        insert objectBasedByPassTrigger;   
        
    }
    
    private static CustomerGroup__c buildCustomerGroup(User agentUser, String identifier, String cgName) {
        CustomerGroup__c cg = new CustomerGroup__c();
        cg.name = cgName;
        cg.sfgroupidentifier__c = identifier;
        cg.OwnerId = agentUser.Id;
        cg.Agent__c = agentUser.Id;
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
        custGroup = buildCustomerGroup(agentUser, 'ABCD1234567', 'Primary Household');
        brandNewGroup = buildCustomerGroup(agentUser, 'ABCD1111111', 'Primary Household');
        insert custGroup;
        insert brandNewGroup;
        CustomerGroupMember__c c3 = buildCustomerGroupMember(acc, custGroup, true);       
        insert c3;      
        acc = [SELECT id, name, personcontactId, clientidentifier__c from Account where Id =: acc.Id];
    }
    
    private static void setupCustomerGroupWithSecondAccount() {
        acc = createIndividualWithValues('Alice');
        acc.clientidentifier__c = 'TESTCLNTID8';
        insert acc;
        acc2 = createSecondIndividualWithValues('Bob');
        acc2.clientidentifier__c = 'TESTCLNTID9';
        insert acc2;
        custGroup = buildCustomerGroup(agentUser, 'ABCD1234567', 'Primary Household');
        insert custGroup;
        CustomerGroupMember__c c3 = buildCustomerGroupMember(acc, custGroup, true);       
        insert c3; 
        CustomerGroupMember__c c4 = buildCustomerGroupMember(acc2, custGroup, false);       
        insert c4;
        acc = [SELECT id, name, personcontactId, clientidentifier__c from Account where Id =: acc.Id];
        acc2 = [SELECT id, name, personcontactId, clientidentifier__c from Account where Id =: acc2.Id];
    }
    
    private static void setupCustomerGroupWithSecondAccountDifferentGroups() {
        acc = createIndividualWithValues('Alice');
        acc.clientidentifier__c = 'TESTCLNTID8';
        insert acc;
        acc2 = createSecondIndividualWithValues('Bob');
        acc2.clientidentifier__c = 'TESTCLNTID9';
        insert acc2;
        custGroup = buildCustomerGroup(agentUser, 'ABCD1234567', 'Primary Household');
        insert custGroup;
        brandNewGroup = buildCustomerGroup(agentUser, 'EFGH1234567', 'Primary Household');
        insert brandNewGroup;
        CustomerGroupMember__c c3 = buildCustomerGroupMember(acc, custGroup, true);       
        insert c3; 
        CustomerGroupMember__c c4 = buildCustomerGroupMember(acc2, brandNewGroup, false);       
        insert c4;
        acc = [SELECT id, name, personcontactId, clientidentifier__c from Account where Id =: acc.Id];
        acc2 = [SELECT id, name, personcontactId, clientidentifier__c from Account where Id =: acc2.Id];
    }
    
    private static void setupNewCustomerGroupWithTwoAccounts() {
        custGroup2 = buildCustomerGroup(agentUser, 'ABCD1234567', 'Primary Household');
        insert custGroup2;
        acc3 = createIndividualWithValues('Tintin');
        acc3.clientidentifier__c = 'TESTCLNTID3';
        insert acc3;
        CustomerGroupMember__c cg3 = buildCustomerGroupMember(acc3, custGroup2, true);       
        insert cg3; 
        acc4 = createSecondIndividualWithValues('Snowy');
        acc4.clientidentifier__c = 'TESTCLNTID4';
        insert acc4;
        CustomerGroupMember__c cg4 = buildCustomerGroupMember(acc4, custGroup2, false);       
        insert cg4;
        acc3 = [SELECT id, name, personcontactId from Account where Id =: acc3.Id];
        acc4 = [SELECT id, name, personcontactId from Account where Id =: acc4.Id];
    }
    
    private static Account createIndividualWithValues(String firstName) {
        Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('TestLastName');
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
        return acc;
    }
    
    private static Account createSecondIndividualWithValues(String firstName) {
        Account acc2 = UTIL_CreateCustomerTestData.createIndividualCustomer('TestLastName');
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
        acc2.PersonBirthdate = null;     
        return acc2;
    }
    
    private static Account createAccountForSearch(String lastName, String firstName) {
        Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer(lastName);
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
        
        return acc;
    }
    
    @isTest
    static void fetchGroupMembersForSearchedCustomer(){
        User testAgentUser1 = new User(Alias='alias2',LastName='accOwner2',Username='accOwnerAgent2@statefarm.com',Associate_ID__c='123test2',UserExternalID__c='123test123te2',Servicing_Agent_Associate_ID__c='123test2');
        User agentUser2 = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
        User testProxyUser1 = new User(Alias='Proxy2',LastName='ProxyAccOwner2',Username='proxyAgent2@statefarm.com',UserExternalID__c='123test2P',Servicing_Agent_Associate_ID__c='123test2'); 
        User proxyUser2 = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);  
        User testTechUser =  new User(Username=UTIL_TestUsername_TEST.getTestUsername('techSupportUser'),Alias='TECH',Associate_ID__c='4321TEST321',UserExternalID__c='4321TEST321');
        User techSupport = AP_UserProvisioningProcess_TEST_UTIL.buildTechnicalsupportUserRecord(testTechUser);
        insert new User[]{agentUser2, proxyUser2, techSupport};
        agentUser = [SELECT Id, Username, Associate_ID__c FROM User where alias='AGNTName' ];
        noAccessUser = [SELECT Id, Username  FROM User where lastname='TestSysRecOwner' ];
		Account account  = new Account(firstname ='SSSHHHH', lastname='SSSSSHHHH', ClientIdentifier__c = 'SFFSP81L8XB');
        Account account2  = new Account(firstname ='SSSHHHH2', lastname='SSSSSHHHH2', ClientIdentifier__c = 'SFFSP81L8X2');
        List<Account> accountList = new List<Account>();
        accountList.add(account);
        accountList.add(account2);
		System.RunAs(agentUser) {
        	insert accountList;
        }
        
        List<AgentRole__c> arList = new List<AgentRole__c>();
       
        String agentroleidentifier = agentUser.Associate_ID__c+'~'+account.ClientIdentifier__c;
        AgentRole__c ar1 = new AgentRole__c(customer__c = account.id, Agent__c = agentUser.ID,  RelationshipNature__c = 'Prospect', agentroleidentifier__c = agentroleidentifier);
        AgentRole__c ar2 = new AgentRole__c(customer__c = account.id, Agent__c = agentUser2.ID,  RelationshipNature__c = 'Prospect', agentroleidentifier__c = agentUser2.Associate_ID__c+'~'+account.ClientIdentifier__c);
        AgentRole__c ar3 = new AgentRole__c(customer__c = account2.id, Agent__c = agentUser.ID,  RelationshipNature__c = 'Prospect', agentroleidentifier__c = agentUser.Associate_ID__c+'~'+account2.ClientIdentifier__c);
        AgentRole__c ar4 = new AgentRole__c(customer__c = account2.id, Agent__c = agentUser2.ID,  RelationshipNature__c = 'Prospect', agentroleidentifier__c = agentUser2.Associate_ID__c+'~'+account2.ClientIdentifier__c);
        arList.add(ar1);
        arList.add(ar2);
        arList.add(ar3);
        arList.add(ar4);
        
        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(true, techSupport);
        insert passTriggerAll;
        
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(techSupport);
        objectBasedByPassTrigger.Override_CustomerGroupBeforeInsert__c = true;
        insert objectBasedByPassTrigger;  
        
        CustomerGroup__c cg1 = buildCustomerGroup(agentUser, 'ABCD1234567', 'Primary Household');
        CustomerGroup__c cg2 = buildCustomerGroup(agentUser2, 'ABCD1111111', 'Primary Household');
        CustomerGroup__c cg3 = buildCustomerGroup(agentUser, 'ABCD1234562', 'Primary Household');
        
        PermissionSet permSet1 = [select Id from PermissionSet where Name = 'CoreComponents_AllUsers'];
        PermissionSetAssignment psa1 = new PermissionSetAssignment(AssigneeId = techSupport.Id, PermissionSetId = permSet1.Id);
        PermissionSet permSet2 = [select Id from PermissionSet where Name = 'CoreComponents_User_R'];
        PermissionSetAssignment psa2 = new PermissionSetAssignment(AssigneeId = techSupport.Id, PermissionSetId = permSet2.Id);
        PermissionSet permSet3 = [select Id from PermissionSet where Name = 'CustomerView_Support_ModifyAll'];
        PermissionSetAssignment psa3 = new PermissionSetAssignment(AssigneeId = techSupport.Id, PermissionSetId = permSet3.Id);
        User systemAdminUser = [select Id,Username from User where Username =: SYSADMIN_USER_ID];
        System.runas(systemAdminUser){
            insert psa1;
            insert psa2;
            insert psa3;
        }

        Test.startTest();
        system.runAs(techSupport) {
            insert arList;
            insert new CustomerGroup__c[]{cg1, cg2, cg3};
            CustomerGroupMember__c cgm1 = buildCustomerGroupMember(account, cg1, true);
            CustomerGroupMember__c cgm2 = buildCustomerGroupMember(account2, cg3, true);
            CustomerGroupMember__c cgm3 = buildCustomerGroupMember(account, cg2, true);
            CustomerGroupMember__c cgm4 = buildCustomerGroupMember(account2, cg2, true);
            insert new CustomerGroupMember__c[]{cgm1, cgm2, cgm3, cgm4};
            
            List<CustomerGroupMoveMemberController.GroupMember> groupMembers = CustomerGroupMoveMemberController.fetchGroupMembersForSearchedCustomer(account2.Id, agentUser.Id);
             boolean matchFound=false;
            for(CustomerGroupMoveMemberController.GroupMember groupMember: groupMembers){
                CustomerGroupMoveMemberController.GroupMemberInfo groupMemberInfo=(CustomerGroupMoveMemberController.GroupMemberInfo) JSON.deserialize(groupMember.groupMemberInfo, CustomerGroupMoveMemberController.GroupMemberInfo.class);
                System.assertEquals(cg3.id, groupMemberInfo.SFDCGroupId, 'Expected id should be equals to the actual id');
                System.assertEquals(account2.id, groupMemberInfo.accountId, 'Expected id should be equals to the actual id');
                matchFound=true;
            }
            
            System.assert(matchFound, 'No match found');
        }
        Test.stopTest();
    }

    @isTest
    static void testFetchGroupMembers(){
        Test.startTest();
          agentUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where UserExternalID__c='AGNTName_AGNTName' ];
        
        System.runAs(agentUser) {            
            setupCustomerGroupWithAccount();
            List<CustomerGroupMoveMemberController.GroupMember> groupMembers = CustomerGroupMoveMemberController.fetchGroupMembers(acc.Id,custGroup.Id);
            boolean matchFound=false;
            for(CustomerGroupMoveMemberController.GroupMember groupMember: groupMembers){
                if('Alice TestLastName | DOB: 3/20/1987'.equals(groupMember.label)){
                    matchFound=true;
                    CustomerGroupMoveMemberController.GroupMemberInfo groupMemberInfo=(CustomerGroupMoveMemberController.GroupMemberInfo) JSON.deserialize(groupMember.groupMemberInfo, CustomerGroupMoveMemberController.GroupMemberInfo.class);
                    System.assertEquals(groupMemberInfo.SFDCGroupId, custGroup.id, 'Expected id should be equals to the actual id');
                    System.assertEquals(groupMemberInfo.label, 'Alice TestLastName | DOB: 3/20/1987', 'Expected label should be equals to the actual label');
                    System.assertEquals(groupMemberInfo.accountId, acc.id, 'Expected id should be equals to the actual id');
                }
                
            }
            System.assert(matchFound, 'No match found');
            
            Test.stopTest();
        }
    }
    
    @isTest
    static void canFetchGroupMembersWhenCustomerIdIsNull(){
        
        Test.startTest();
          agentUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where UserExternalID__c='AGNTName_AGNTName' ];
        
        System.runAs(agentUser) {
            
            setupNewCustomerGroupWithTwoAccounts(); 
            
            List<CustomerGroupMoveMemberController.GroupMember> groupMembers=CustomerGroupMoveMemberController.fetchGroupMembers(acc3.Id, null);
            boolean matchFound=false;
            for(CustomerGroupMoveMemberController.GroupMember groupMember: groupMembers){
                if('Snowy TestLastName'.equals(groupMember.label)){
                    matchFound=true;
                    CustomerGroupMoveMemberController.GroupMemberInfo groupMemberInfo=(CustomerGroupMoveMemberController.GroupMemberInfo) JSON.deserialize(groupMember.groupMemberInfo, CustomerGroupMoveMemberController.GroupMemberInfo.class);
                    System.assertEquals(groupMemberInfo.SFDCGroupId, custGroup2.id, 'Expected id should be equals to the actual id');
                    System.assertEquals(groupMemberInfo.label, 'Snowy TestLastName', 'Expected label should be equals to the actual label');
                    System.assertEquals(groupMemberInfo.accountId, acc4.id, 'Expected id should be equals to the actual id');
                }
                
            }
            System.assert(matchFound, 'No match found');
        }
        Test.stopTest();
    } 

    @isTest
    static void testBuildNewGroupPayload(){
        
        Test.startTest();
          agentUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where UserExternalID__c='AGNTName_AGNTName' ];
        
        System.runAs(agentUser) {
            setupCustomerGroupWithAccount();
            CustomerGroupMoveMemberController.fetchGroupMembers(acc.Id,custGroup.Id);
            
            String fwdSl = '\\"';		
			String newGroupMemberInfo =  '[{\"'+'groupMemberInfo\":\"{'+fwdSl+'SFGroupId'+fwdSl+':'+fwdSl+'M4TC74NZ707'+fwdSl+','+fwdSl+'SFDCGroupId'+fwdSl+':'+fwdSl+''+custGroup.id+''+fwdSl+','+fwdSl+'label'+fwdSl+':'+fwdSl+'JOAN R ABBOTT | DOB: 1/15/1943'+fwdSl+','+fwdSl+'clientId'+fwdSl+':'+fwdSl+''+acc.clientidentifier__c+''+fwdSl+','+fwdSl+'accountId'+fwdSl+':'+fwdSl+''+acc.id+''+fwdSl+'}","label":"JOAN R ABBOTT | DOB: 1/15/1943"}]';
            String newGroupPayload = CustomerGroupMoveMemberController.buildNewMemberPayload(newGroupMemberInfo );
            String matchingStr = '"oldGroup":"M4TC74NZ707"';
            System.assert(newGroupPayload.contains(matchingStr), '\'contains\' method of String class should return true');
            
        }
        Test.stopTest();
    }

    @isTest
    static void testBuildExistingGroupsPayload(){
        
        Test.startTest();
          agentUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where UserExternalID__c='AGNTName_AGNTName' ];
        System.runAs(agentUser) {
            setupCustomerGroupWithAccount();
            String fwdSl = '\\"';		
			String existingOldGroupMemberInfo =  '[{\"'+'groupMemberInfo\":\"{'+fwdSl+'SFGroupId'+fwdSl+':'+fwdSl+'1111'+fwdSl+','+fwdSl+'SFDCGroupId'+fwdSl+':'+fwdSl+''+custGroup.id+''+fwdSl+','+fwdSl+'label'+fwdSl+':'+fwdSl+'BARBARA J CARLSON | DOB: 2/22/1952'+fwdSl+','+fwdSl+'clientId'+fwdSl+':'+fwdSl+''+'632756'+''+fwdSl+','+fwdSl+'accountId'+fwdSl+':'+fwdSl+''+'325146'+''+fwdSl+'}","label":"BARBARA J CARLSON | DOB: 2/22/1952"}]';
            String initialGroupId = '1111';
            String initialSearchedGroupId = '4444';
            String existingOldGroupPayload = CustomerGroupMoveMemberController.buildExistingMemberPayload(existingOldGroupMemberInfo,initialGroupId,initialSearchedGroupId);
            String matchingStr = '"oldGroup":"1111"';
            System.assert(existingOldGroupPayload.contains(matchingStr), '\'contains\' method of String class should return true');
            String existingNewGroupMemberInfo =  '[{\"'+'groupMemberInfo\":\"{'+fwdSl+'SFGroupId'+fwdSl+':'+fwdSl+'4444'+fwdSl+','+fwdSl+'SFDCGroupId'+fwdSl+':'+fwdSl+''+custGroup.id+''+fwdSl+','+fwdSl+'label'+fwdSl+':'+fwdSl+'BARBARA J CARLSON | DOB: 2/22/1952'+fwdSl+','+fwdSl+'clientId'+fwdSl+':'+fwdSl+''+'632756'+''+fwdSl+','+fwdSl+'accountId'+fwdSl+':'+fwdSl+''+'325146'+''+fwdSl+'}","label":"BARBARA J CARLSON | DOB: 2/22/1952"}]';
            String existingNewGroupPayload = CustomerGroupMoveMemberController.buildExistingMemberPayload(existingNewGroupMemberInfo,initialGroupId,initialSearchedGroupId);
            String newMatchingStr = '"newGroup":"1111"';
            System.assert(existingNewGroupPayload.contains(newMatchingStr), '\'contains\' method of String class should return true');           
        }
        Test.stopTest();
    }    
       
    @isTest
    static void updateNewGroupMembersWithJson() {
 
          agentUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where UserExternalID__c='AGNTName_AGNTName' ];
        
        System.runAs(agentUser) {
            Test.startTest();
            setupCustomerGroupWithAccount();
            
            String testJsonSinglePayload = '{\"data\":{\"groupings\":[{\"customer\":'+'"'+acc.clientidentifier__c+'"'+',\"groupId\":\"EFGH1234567\"}]},\"errors\":null,\"servicingAgentAssocId\":\"AGNTName\"}';
            CustomerGroupMoveMemberController.updateGroupMembers(testJsonSinglePayload);
            Test.stopTest();

            List<CustomerGroupMember__c> actualGroupMembers =[select id,Group__r.SFGroupIdentifier__c, Customer__c, GroupMemberId__c from CustomerGroupMember__c where Customer__c=:acc.Id];
            
            for (CustomerGroupMember__c groupMember: actualGroupMembers) {
                if (groupMember.GroupMemberId__c.equals('EFGH1234567~' + acc.ClientIdentifier__c)) {
                    System.assertEquals(acc.id, groupMember.Customer__c, 'Expected parameter should be equals to the actual parameter');
                  	System.assertEquals('EFGH1234567', groupMember.Group__r.SFGroupIdentifier__c, 'Expected parameter should be equals to the actual parameter');  
                }
            }
        }
        
    }
    
    @isTest
    static void updateExistingGroupMembersWithJson() {
       
          agentUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where UserExternalID__c='AGNTName_AGNTName' ];
        
        System.runAs(agentUser) {
            Test.startTest();
            setupCustomerGroupWithSecondAccountDifferentGroups();

            String testJsonPayload = '{\"data\":{\"groupings\":[{\"customer\":'+'"'+acc.clientidentifier__c+'"'+',\"groupId\":\"EFGH1234567\"},{\"customer\":'+'"'+acc2.clientidentifier__c+'"'+',\"groupId\":\"ABCD1234567\"}]},\"errors\":null, \"servicingAgentAssocId\":\"AGNTName\"}';
            CustomerGroupMoveMemberController.updateGroupMembers(testJsonPayload);
            Test.stopTest();
            
            List<CustomerGroupMember__c> actualGroupMembersAcc1 =[Select id,Group__r.SFGroupIdentifier__c, Customer__c, GroupMemberId__c From CustomerGroupMember__c Where Customer__c=:acc.Id];           
            for (CustomerGroupMember__c groupMember: actualGroupMembersAcc1) {
                if (groupMember.GroupMemberId__c.equals('EFGH1234567~' + acc.ClientIdentifier__c)) {
                    System.assertEquals(acc.id, groupMember.Customer__c, 'Expected parameter should be equals to the actual parameter');
                  	System.assertEquals('EFGH1234567', groupMember.Group__r.SFGroupIdentifier__c, 'Expected parameter should be equals to the actual parameter');  
                }
            }
            
            List<CustomerGroupMember__c> actualGroupMembersAcc2 =[Select id,Group__r.SFGroupIdentifier__c, Customer__c, GroupMemberId__c From CustomerGroupMember__c Where Customer__c=:acc2.Id];
			for (CustomerGroupMember__c groupMember: actualGroupMembersAcc2) {
                if (groupMember.GroupMemberId__c.equals('ABCD1234567~' + acc.ClientIdentifier__c)) {
                    System.assertEquals(acc2.id, groupMember.Customer__c, 'Expected parameter should be equals to the actual parameter');
                  	System.assertEquals('ABCD1234567', groupMember.Group__r.SFGroupIdentifier__c, 'Expected parameter should be equals to the actual parameter');  
                }
            }
        }
    }

    @isTest
    static void testLogHHMovesException(){
        String className = 'CustomerGroupMoveMember';
        String methodName = 'updateGroupMembers';
        String exceptionMessage = 'Household moves failed';

        Test.startTest();
          agentUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where UserExternalID__c='AGNTName_AGNTName' ];
        ExceptionLog__c querylog;
        System.runAs(agentUser) {
            CustomerGroupMoveMemberController.logHHMovesException(className, methodName, exceptionMessage);
            querylog = [SELECT IsHandled__c, Class__c, Method__c, Exception_Message__c
                        FROM ExceptionLog__c
                        ORDER BY systemmodstamp DESC
                        LIMIT 1];
        }
        Test.stopTest();
        System.assertEquals(className, querylog.Class__c, 'class name did not match expected value.');
        System.assertEquals(methodName, querylog.Method__c, 'method name did not match expected value.');
        System.assertEquals(true, querylog.IsHandled__c, 'isHandled value did not match');
        System.assertEquals(exceptionMessage, querylog.Exception_Message__c, 'message value did not match');
    }
}