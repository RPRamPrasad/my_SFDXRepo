/**
* @name CombineCustomersControllerTest  
* @owner Atlas
* @date 10/11/2018  
* @description Combine Customers Page Onload controller to get customer group members
*/

@isTest(seeAllData = false)
public class CombineCustomersControllerTest {
    
    private static User testAPIUser;
    private static AccountRec accRec = new AccountRec();
    private static final String SYSADMIN_USER_ID = UTIL_TestUsername_TEST.getTestUsername('sysadmin');    
    private static User systemAdminUser;
    private static TestData_SalesRoleHierarchy salesRoleHierarchy1 ;

    private class AccountRec{
        private account accRecord1=new Account(FirstName='FNameForMerge1',LastName='LNameForMerge1',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='RFBSP71L8XB',PersonBirthdate=Date.valueOf('2013-05-05'));    
        private account accRecord2=new Account(FirstName='FNameForMerge2',LastName='LNameForMerge2',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='RFBSP81L8XB',PersonBirthdate=Date.valueOf('2009-05-05'));
        private account accRecord3=new Account(FirstName='FNameForMerge3',LastName='LNameForMerge3',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='RFBSP91L8XB');
        private account accRecord4=new Account(FirstName='FNameForMerge4',LastName='LNameForMerge4',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='RFBSP01L8XB');        
        private account accRecord5=new Account(FirstName='FNameForMerge5',LastName='LNameForMerge5',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='RFBSP11L8XB');        
        private account accRecord6=new Account(FirstName='FNameForMerge6',LastName='LNameForMerge6',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='RFBSP21L8XB');        
        
        private account accRecord7=new Account(FirstName='FNameForMerge',LastName='LNameForMerge7',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='RFBSP70L8XB');        
        private account accRecord8=new Account(FirstName='FNameForMerge8',LastName='LNameForMerge8',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='RFBSP80L8XB');        
        private account accRecord9=new Account(FirstName='FNameForMerge9',LastName='LNameForMerge9',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='RFBSP90L8XB');        
        private account accRecord10=new Account(FirstName='FNameForMerge10',LastName='LNameForMerge10',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='RFBSP96L8XB');        
        private account accRecord11=new Account(FirstName='FNameForMerge11',LastName='LNameForMerge11',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='RFBSP92L8XB');        
        private account accRecord12=new Account(FirstName='FNameForMerge12',LastName='LNameForMerge12',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='RFBSP93L8XB');        
        private account accRecord13=new Account(FirstName='FNameForMerge13',LastName='LNameForMerge13',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='RFBSP94L8XB');        
        private account accRecord14=new Account(FirstName='FNameForMerge14',LastName='LNameForMerge14',BillingAddressType__c='US',BillingCity='TX',ClientIdentifier__c='RFBSP95L8XB');        

    }
    
    private static CustomerGroupMember__c customergroupMember{get; set;}
    
        // Create accounts
    Private static void createAccounts(){
        List<Account> accList= new List<Account>{accRec.accRecord1,accRec.accRecord2,accRec.accRecord3,accRec.accRecord4,accRec.accRecord5,accRec.accRecord6,accRec.accRecord7,accRec.accRecord8,accRec.accRecord9,accRec.accRecord10,accRec.accRecord11,accRec.accRecord12,accRec.accRecord13,accRec.accRecord14};
            insert accList;
    }
    // Create AgentRoles
    private static void createAgentRoles(){
        List<AgentRole__c> agentRoleList =new List<AgentRole__C>();
        agentRoleList.add(new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Customer',Customer__c=accRec.accRecord1.Id,agentroleIdentifier__c=salesRoleHierarchy1.Agent.Associate_id__c+'~'+accRec.accRecord1.clientIdentifier__C,RelationshipStartDate__c=Date.newInstance(2017, 12, 9)));
        agentRoleList.add(new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRec.accRecord2.Id,agentroleIdentifier__c=salesRoleHierarchy1.Agent.Associate_id__c+'~'+accRec.accRecord2.clientIdentifier__C,RelationshipStartDate__c=Date.newInstance(2017, 12, 9)));
        agentRoleList.add(new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Ex-Customer',Customer__c=accRec.accRecord3.Id,agentroleIdentifier__c=salesRoleHierarchy1.Agent.Associate_id__c+'~'+accRec.accRecord3.clientIdentifier__C,RelationshipStartDate__c=Date.newInstance(2016, 12, 9)));
        agentRoleList.add(new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Ex-Customer',Customer__c=accRec.accRecord4.Id,agentroleIdentifier__c=salesRoleHierarchy1.Agent.Associate_id__c+'~'+accRec.accRecord4.clientIdentifier__C,RelationshipStartDate__c=system.today()));
        agentRoleList.add(new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='',Customer__c=accRec.accRecord5.Id,agentroleIdentifier__c=salesRoleHierarchy1.Agent.Associate_id__c+'~'+accRec.accRecord5.clientIdentifier__C,RelationshipStartDate__c=system.today()));
        agentRoleList.add(new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRec.accRecord6.Id,agentroleIdentifier__c=salesRoleHierarchy1.Agent.Associate_id__c+'~'+accRec.accRecord6.clientIdentifier__C,RelationshipStartDate__c=system.today()));
        agentRoleList.add(new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRec.accRecord7.Id,agentroleIdentifier__c=salesRoleHierarchy1.Agent.Associate_id__c+'~'+accRec.accRecord7.clientIdentifier__C,RelationshipStartDate__c=system.today()));
        agentRoleList.add(new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRec.accRecord8.Id,agentroleIdentifier__c=salesRoleHierarchy1.Agent.Associate_id__c+'~'+accRec.accRecord8.clientIdentifier__C,RelationshipStartDate__c=system.today()));
        agentRoleList.add(new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRec.accRecord9.Id,agentroleIdentifier__c=salesRoleHierarchy1.Agent.Associate_id__c+'~'+accRec.accRecord9.clientIdentifier__C,RelationshipStartDate__c=system.today()));
        agentRoleList.add(new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRec.accRecord10.Id,agentroleIdentifier__c=salesRoleHierarchy1.Agent.Associate_id__c+'~'+accRec.accRecord10.clientIdentifier__C,RelationshipStartDate__c=system.today()));
        agentRoleList.add(new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRec.accRecord11.Id,agentroleIdentifier__c=salesRoleHierarchy1.Agent.Associate_id__c+'~'+accRec.accRecord11.clientIdentifier__C,RelationshipStartDate__c=system.today()));
        agentRoleList.add(new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRec.accRecord12.Id,agentroleIdentifier__c=salesRoleHierarchy1.Agent.Associate_id__c+'~'+accRec.accRecord12.clientIdentifier__C,RelationshipStartDate__c=system.today()));
        agentRoleList.add(new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRec.accRecord13.Id,agentroleIdentifier__c=salesRoleHierarchy1.Agent.Associate_id__c+'~'+accRec.accRecord13.clientIdentifier__C,RelationshipStartDate__c=system.today()));
        agentRoleList.add(new AgentRole__c(Agent__c=salesRoleHierarchy1.Agent.Id, RelationshipNature__c='Prospect',Customer__c=accRec.accRecord14.Id,agentroleIdentifier__c=salesRoleHierarchy1.Agent.Associate_id__c+'~'+accRec.accRecord14.clientIdentifier__C,RelationshipStartDate__c=system.today()));
        
        insert agentRoleList;
    }
    // Create Group and Group Members
    private static void createGroupAndGroupMembers(){
        CustomerGroup__c custGroup = new CustomerGroup__c(Agent__c=salesRoleHierarchy1.Agent.Id, SFGroupIdentifier__c='UNIQUEGROUP');
        insert custGroup;
        
        List<CustomerGroupMember__c> custGroupMemList = new List<CustomerGroupMember__c>();
        custGroupMemList.add(new CustomerGroupMember__c(Group__c=custGroup.id,Customer__c=accRec.accRecord1.Id,GroupMemberId__c=custGroup.SFGroupIdentifier__c+'~'+accRec.accRecord1.clientIdentifier__C)); 
        custGroupMemList.add(new CustomerGroupMember__c(Group__c=custGroup.id,Customer__c=accRec.accRecord2.Id,GroupMemberId__c=custGroup.SFGroupIdentifier__c+'~'+accRec.accRecord2.clientIdentifier__C)); 
        custGroupMemList.add(new CustomerGroupMember__c(Group__c=custGroup.id,Customer__c=accRec.accRecord3.Id,GroupMemberId__c=custGroup.SFGroupIdentifier__c+'~'+accRec.accRecord3.clientIdentifier__C)); 
        custGroupMemList.add(new CustomerGroupMember__c(Group__c=custGroup.id,Customer__c=accRec.accRecord4.Id,GroupMemberId__c=custGroup.SFGroupIdentifier__c+'~'+accRec.accRecord4.clientIdentifier__C));
        custGroupMemList.add(new CustomerGroupMember__c(Group__c=custGroup.id,Customer__c=accRec.accRecord5.Id,GroupMemberId__c=custGroup.SFGroupIdentifier__c+'~'+accRec.accRecord5.clientIdentifier__C));
        custGroupMemList.add(new CustomerGroupMember__c(Group__c=custGroup.id,Customer__c=accRec.accRecord6.Id,GroupMemberId__c=custGroup.SFGroupIdentifier__c+'~'+accRec.accRecord6.clientIdentifier__C));
        custGroupMemList.add(new CustomerGroupMember__c(Group__c=custGroup.id,Customer__c=accRec.accRecord7.Id,GroupMemberId__c=custGroup.SFGroupIdentifier__c+'~'+accRec.accRecord7.clientIdentifier__C));
        custGroupMemList.add(new CustomerGroupMember__c(Group__c=custGroup.id,Customer__c=accRec.accRecord8.Id,GroupMemberId__c=custGroup.SFGroupIdentifier__c+'~'+accRec.accRecord8.clientIdentifier__C));
        custGroupMemList.add(new CustomerGroupMember__c(Group__c=custGroup.id,Customer__c=accRec.accRecord9.Id,GroupMemberId__c=custGroup.SFGroupIdentifier__c+'~'+accRec.accRecord9.clientIdentifier__C));
        custGroupMemList.add(new CustomerGroupMember__c(Group__c=custGroup.id,Customer__c=accRec.accRecord10.Id,GroupMemberId__c=custGroup.SFGroupIdentifier__c+'~'+accRec.accRecord10.clientIdentifier__C));
        custGroupMemList.add(new CustomerGroupMember__c(Group__c=custGroup.id,Customer__c=accRec.accRecord11.Id,GroupMemberId__c=custGroup.SFGroupIdentifier__c+'~'+accRec.accRecord11.clientIdentifier__C));
        custGroupMemList.add(new CustomerGroupMember__c(Group__c=custGroup.id,Customer__c=accRec.accRecord12.Id,GroupMemberId__c=custGroup.SFGroupIdentifier__c+'~'+accRec.accRecord12.clientIdentifier__C));
        custGroupMemList.add(new CustomerGroupMember__c(Group__c=custGroup.id,Customer__c=accRec.accRecord13.Id,GroupMemberId__c=custGroup.SFGroupIdentifier__c+'~'+accRec.accRecord13.clientIdentifier__C));
        custGroupMemList.add(new CustomerGroupMember__c(Group__c=custGroup.id,Customer__c=accRec.accRecord14.Id,GroupMemberId__c=custGroup.SFGroupIdentifier__c+'~'+accRec.accRecord14.clientIdentifier__C));
        
        insert custGroupMemList;
    }
    @TestSetup
    private static void setup(){
        systemAdminUser = AP_UserProvisioningProcess_TEST_UTIL.createGenericSystemAdmin(SYSADMIN_USER_ID); 
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('A');
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.agent);

        System.runAs(systemAdminUser){  
        	UTIL_SetFSCCustomSettings_TEST.setFSCSettings();          
            createAccounts();
            createAgentRoles();            
            createGroupAndGroupMembers();
        }
    }

    /**
    * @method 
    * Given an Agent User
    * When user clicks on Combine Customers button
    * Then a page will be rendered with Profile customers and Householdmembers
    * @name testGetCustomerGroupMembers
    * @description Test Get Customer Group Members
    */ 
    @isTest
    private static void testGetCustomerGroupMembers(){
       salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('A');
        accRec.accRecord1=[Select Id from Account where Firstname='FNameForMerge1'];
        Test.startTest();
        System.runAs(salesRoleHierarchy1.Agent){ 
            List<Account> testAccountGroupMemberList = CombineCustomersController.getCustomerGroupMembers(accRec.accRecord1.Id);
            system.assertEquals(14, testAccountGroupMemberList.size(), 'Size of List<Account> should be 14');
       }
        Test.stopTest();
    }
    
    @isTest
    private static void testPickListValuesForIndividual(){
        salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('A');
        Test.startTest();
        System.runAs(salesRoleHierarchy1.Agent){ 
            CombineCustomersController.MergeUIPickListWrapper wrapper= CombineCustomersController.MergeUIPickListWrapper.getMergeUIPickListValuesForIndividual();
            system.assertEquals(169, wrapper.prefferedLanguage.size(), 'Size of \'prefferedLanguage\' should be 169');
            system.assertEquals(8, wrapper.maritalStatus.size(), 'Size of \'maritalStatus\' should be 8');
            system.assertEquals(4, wrapper.citizenship.size(), 'Size of \'citizenship\' should be 4');
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testPickListValuesForOrganization(){
        salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('A');
        Test.startTest();
        System.runAs(salesRoleHierarchy1.Agent){
            List<String> testOrganizationTypeList = CombineCustomersController.getMergeUIPickListValuesForOrganization();
            system.assertEquals(13, testOrganizationTypeList.size(), 'Size of List<String> should be 13');
        }
        Test.stopTest();
    }
    
}