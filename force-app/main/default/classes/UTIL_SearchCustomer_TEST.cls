/**
 * @author Team Choo Choo
 * @owner Team Stark
 * @name UTIL_SearchCustomer_TEST
 * Test class for UTIL_SearchCustomer
 * @description UTIL Search Customer Test
 **/
@isTest
private class UTIL_SearchCustomer_TEST {
    
    private static Account createIndividualWithValues() {
        Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('Test Last Name');
        acc.FirstName = 'Test First Name';
        acc.BillingAddressType__c = 'US';
        acc.BillingStreet = 'Test Street Test Street Test Street \n Test Street Test Street Test Street \n Test Street Test Street Test Street Test Street Test Street ';
        acc.BillingCity = 'Bloomington';
        acc.BillingState = 'IL';
        acc.BillingPostalCode = '61704';
        acc.BillingCountry = 'US';
        acc.PersonBirthDate=Date.today()-10000;
        return acc;
    }
    
        private static Account createOrganizationWithValues() {
        Account acc = UTIL_CreateCustomerTestData.createOrganizationCustomer('Test Org Name');
        acc.BillingAddressType__c = 'US';
        acc.BillingStreet = 'Test Street Test Street Test Street \n Test Street Test Street Test Street \n Test Street Test Street Test Street Test Street Test Street ';
        acc.BillingCity = 'Bloomington';
        acc.BillingState = 'IL';
        acc.BillingPostalCode = '61704';
        acc.BillingCountry = 'US';
        return acc;
    }
    
    private static Account createIndividualWithMatchValues(){
        Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('Doe');
        acc.FirstName = 'John';
        acc.BillingAddressType__c = 'US';
        acc.BillingStreet = '1 Statefarm Plz';
        acc.BillingCity = 'Bloomington';
        acc.BillingState = 'IL';
        acc.BillingPostalCode = '61710';
        acc.BillingCountry = 'US';
        acc.ShippingAddressType__c = 'US';
        acc.ShippingStreet='1 Statefarm Plz';
        acc.ShippingCity = 'Bloomington';
        acc.ShippingState = 'IL';
        acc.ShippingPostalCode = '61710';
        acc.ShippingCountry = 'US';
        return acc;
    }
    
    @isTest
    static void testCreateTaskForServicingAgents(){
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;
        
        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c();
        passTriggerAll.Override_All__c = true;
        insert passTriggerAll;
        
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
        insert sysAdminUserIdSetting;
        
        User agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'TestName', 'TestName','TestName','TestName');
        insert agentUser;
        
        Account acc = createIndividualWithValues();
        acc.ClientIdentifier__c = 'SGGSP81L8XB';
        
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            System.runAs(agentUser) {
            insert acc;
            AgentRole__c agentRoleCreation1 = new AgentRole__c(Agent__c=agentUser.Id, RelationshipNature__c='Customer',Customer__c=acc.Id ); 
            insert agentRoleCreation1;
            String selectedReason='Testreason';
            String comments='TestComments';
            Integer countAccess=1;
            Boolean isIndividual=true;
            UTIL_SearchCustomer.createTaskForServicingAgents(acc.id, acc.PersonContactId, agentUser.Name, agentuser.Email, selectedReason, comments, countAccess, isIndividual);
            System.assert([Select id, whatId from Task where whatId = :acc.Id] !=null, 'SOQL query returns null');
            }
        Test.stopTest();        
    }
    
    @isTest
    static void testCreateTaskForServicingAgentsForOrg(){
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;
        
        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c();
        passTriggerAll.Override_All__c = true;
        insert passTriggerAll;
        
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
        insert sysAdminUserIdSetting;
        
        User agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'TestName', 'TestName','TestName','TestName');
        insert agentUser;
        
        Account acc = createOrganizationWithValues();
        acc.ClientIdentifier__c = 'SHHSP81L8XB';
        
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            System.runAs(agentUser) {
            insert acc;
            AgentRole__c agentRoleCreation1 = new AgentRole__c(Agent__c=agentUser.Id, RelationshipNature__c='Customer',Customer__c=acc.Id ); 
            insert agentRoleCreation1;
            String selectedReason='Testreason';
            String comments='TestComments';
            Integer countAccess=1;
            Boolean isIndividual=false;
            UTIL_SearchCustomer.createTaskForServicingAgents(acc.id, acc.PersonContactId, agentUser.Name, agentuser.Email, selectedReason, comments, countAccess, isIndividual);
            System.assert([Select id, whatId from Task where whatId = :acc.Id] !=null, 'SOQL query returns null');
            }
        Test.stopTest();        
    }
    
    @isTest
    static void testfindDuplicateCustomers(){
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        UTIL_ByPassTrigger_TEST.createTriggerBypassAllCustomSetting();        
        Test.startTest();
            User agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'TestName', 'TestName','TestName','TestName');
            insert agentUser;
            Account acc = createIndividualWithMatchValues();
            acc.DriversLicenseNumber__c='0000';
            insert acc;
            AgentRole__c agentRoleCreation = new AgentRole__c(Agent__c=agentUser.Id, RelationshipNature__c='Customer',Customer__c=acc.Id ); 
            insert agentRoleCreation;
            Account acc2 = createIndividualWithMatchValues();
            acc2.IsMatchRequired__c = true;
            List<HLPR_CustSearchResultWrapper> resultSet = UTIL_SearchCustomer.findDuplicateCustomers(acc2, null);
            System.assert(!resultSet.isEmpty(), '\'resultSet\' is empty');
        Test.stopTest();        
    }
    
    @isTest
    static void testfindDuplicateCustomersByDateofBirth(){
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        UTIL_ByPassTrigger_TEST.createTriggerBypassAllCustomSetting();        
        Test.startTest();
            User agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'TestName', 'TestName','TestName','TestName');
            insert agentUser;
            Account acc = createIndividualWithMatchValues();
            acc.DriversLicenseNumber__c='0000';
        	acc.Gender__pc = 'Male';
        	acc.Suffix = 'III';
        	acc.PersonBirthdate = Date.valueOf('1987-11-24');
        	acc.IsProtectedPerson__c = false;
            insert acc;
            AgentRole__c agentRoleCreation = new AgentRole__c(Agent__c=agentUser.Id, RelationshipNature__c='Customer',Customer__c=acc.Id ); 
            insert agentRoleCreation;
            Account acc2 = createIndividualWithMatchValues();
            acc2.IsMatchRequired__c = true;
        	acc2.Suffix = 'III';
        	acc2.PersonBirthdate = Date.valueOf('1987-11-24');
        	acc2.Gender__pc = 'Male';
            List<HLPR_CustSearchResultWrapper> resultSet = UTIL_SearchCustomer.findDuplicateCustomers(acc2, null);
            System.assert(!resultSet.isEmpty(), '\'resultSet\' is empty');
        Test.stopTest();        
    }

    @isTest
    static void testfindDuplicateCustomersWithPersonHomePhone(){
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        UTIL_ByPassTrigger_TEST.createTriggerBypassAllCustomSetting();        
        Test.startTest();
            User agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'TestName', 'TestName','TestName','TestName');
            insert agentUser;  
            Account acc = createIndividualWithMatchValues();
            acc.DriversLicenseNumber__c='0000';
        	acc.PersonHomePhone = '3096784123';
        	acc.Phone = '3094782341';
        	acc.PersonMobilePhone = '3096217845';
        	acc.TDDPhone__c = '3096784767';
        	acc.Gender__pc = 'Male';
            insert acc;
            AgentRole__c agentRoleCreation = new AgentRole__c(Agent__c=agentUser.Id, RelationshipNature__c='Customer',Customer__c=acc.Id ); 
            insert agentRoleCreation;
            Account acc2 = createIndividualWithMatchValues();
            acc2.IsMatchRequired__c = true;
        	acc2.PersonHomePhone = '3096784123';
        	acc2.Phone = '3094782341';
        	acc2.PersonMobilePhone = '3096217845';
        	acc2.TDDPhone__c = '3096784767';
        	acc2.Gender__pc = 'Male';
        	List<String> phoneList = new List<String>{'3096784123'};
            List<HLPR_CustSearchResultWrapper> resultSet = UTIL_SearchCustomer.findDuplicateCustomers(acc2, phoneList);
            System.assert(!resultSet.isEmpty(), '\'resultSet\' is empty');
        Test.stopTest();        
    }
    
    @isTest
    static void testfindDuplicateCustomersWithPhone(){
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        UTIL_ByPassTrigger_TEST.createTriggerBypassAllCustomSetting();        
        Test.startTest();
            User agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'TestName', 'TestName','TestName','TestName');
            insert agentUser;
            Account acc = createIndividualWithMatchValues();
            acc.DriversLicenseNumber__c='0000';
        	acc.PersonHomePhone = '3096784123';
        	acc.Phone = '3094782341';
        	acc.PersonMobilePhone = '3096217845';
        	acc.TDDPhone__c = '3096784767';
        	acc.Gender__pc = 'Male';
            insert acc;
            AgentRole__c agentRoleCreation = new AgentRole__c(Agent__c=agentUser.Id, RelationshipNature__c='Customer',Customer__c=acc.Id ); 
            insert agentRoleCreation;
            Account acc2 = createIndividualWithMatchValues();
            acc2.IsMatchRequired__c = true;
        	acc2.PersonHomePhone = '3096784123';
        	acc2.Phone = '3094782341';
        	acc2.PersonMobilePhone = '3096217845';
        	acc2.TDDPhone__c = '3096784767';
        	acc2.Gender__pc = 'Male';
        	List<String> phoneList = new List<String>{'3094782341'};
            List<HLPR_CustSearchResultWrapper> resultSet = UTIL_SearchCustomer.findDuplicateCustomers(acc2, phoneList);
            System.assert(!resultSet.isEmpty(), '\'resultSet\' is empty');
        Test.stopTest();        
    }
    
    @isTest
    static void testfindDuplicateCustomersWithPersonMobilePhone(){
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        UTIL_ByPassTrigger_TEST.createTriggerBypassAllCustomSetting();        
        Test.startTest();
            User agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'TestName', 'TestName','TestName','TestName');
            insert agentUser; 
            Account acc = createIndividualWithMatchValues();
            acc.DriversLicenseNumber__c='0000';
        	acc.PersonHomePhone = '3096784123';
        	acc.Phone = '3094782341';
        	acc.PersonMobilePhone = '3096217845';
        	acc.TDDPhone__c = '3096784767';
        	acc.Gender__pc = 'Male';
            insert acc;
            AgentRole__c agentRoleCreation = new AgentRole__c(Agent__c=agentUser.Id, RelationshipNature__c='Customer',Customer__c=acc.Id ); 
            insert agentRoleCreation;
            Account acc2 = createIndividualWithMatchValues();
            acc2.IsMatchRequired__c = true;
        	acc2.PersonHomePhone = '3096784123';
        	acc2.Phone = '3094782341';
        	acc2.PersonMobilePhone = '3096217845';
        	acc2.TDDPhone__c = '3096784767';
        	acc2.Gender__pc = 'Male';
        	List<String> phoneList = new List<String>{'3096217845'};
            List<HLPR_CustSearchResultWrapper> resultSet = UTIL_SearchCustomer.findDuplicateCustomers(acc2, phoneList);
            System.assert(!resultSet.isEmpty(), '\'resultSet\' is empty');
        Test.stopTest();        
    }
    
    @isTest
    static void testfindDuplicateCustomersWithTDDPhone(){
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        UTIL_ByPassTrigger_TEST.createTriggerBypassAllCustomSetting();        
        Test.startTest();
            User agentUser = UTIL_CreateCustomerTestData.createUserWithAssoId('2.00 Agent', 'TestName', 'TestName','TestName','TestName');
            insert agentUser;
            Account acc = createIndividualWithMatchValues();
            acc.DriversLicenseNumber__c='0000';
        	acc.PersonHomePhone = '3096784123';
        	acc.Phone = '3094782341';
        	acc.PersonMobilePhone = '3096217845';
        	acc.TDDPhone__c = '3096784767';
        	acc.Gender__pc = 'Male';
            insert acc;
            AgentRole__c agentRoleCreation = new AgentRole__c(Agent__c=agentUser.Id, RelationshipNature__c='Customer',Customer__c=acc.Id ); 
            insert agentRoleCreation;
            Account acc2 = createIndividualWithMatchValues();
            acc2.IsMatchRequired__c = true;
        	acc2.PersonHomePhone = '3096784123';
        	acc2.Phone = '3094782341';
        	acc2.PersonMobilePhone = '3096217845';
        	acc2.TDDPhone__c = '3096784767';
        	acc2.Gender__pc = 'Male';
        	List<String> phoneList = new List<String>{'3096784767'};
            List<HLPR_CustSearchResultWrapper> resultSet = UTIL_SearchCustomer.findDuplicateCustomers(acc2, phoneList);
            System.assert(!resultSet.isEmpty(), '\'resultSet\' is empty');
        Test.stopTest();        
    }
}