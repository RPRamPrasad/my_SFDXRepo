/**
@Author Team Loco Motivated
@Name UTIL_CustomerGroupMemberDAO_Test
@CreateDate 12/21/2017
@description Common class to access various GroupMember operations for various Processor Test.
@Version 1.0
*/
@isTest(seeAllData=false)
public class UTIL_CustomerGroupMemberDAO_Test {
    
    private static User systemUser;
    private static User testAPIUser;
    private static final String CLIENT_IDENTIFIER='IAMCLIENT12';
    private static final String CLIENT_IDENTIFIER1='IAMCLIENT11';
    private static Account accrecord;
    private static Account accrecord1;
    
    private static final String SYSADMIN_USER_ID = UTIL_TestUsername_TEST.getTestUsername('sysadmin');
    
    /**
     * @description Setup - This method will create test data
     */
    public static void setup() {
        testAPIUser= UTIL_StageOrchestrationTestUtils.buildtestAPIUser('test','testing','test@statefarm.com');
        systemUser=UTIL_StageOrchestrationTestUtils.buildSystemAdmin('Alias','CmpMemSA','remCmpMemSysAd@statefarm.com');
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings(); 
        insert systemUser;
        insert testAPIUser;
    }
    
    /**
     * @description Test Setup Data
     */
    @testsetup
    public static void testSetupData() {        
        User systemAdminUser = AP_UserProvisioningProcess_TEST_UTIL.createGenericSystemAdmin(SYSADMIN_USER_ID); 
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(systemAdminUser);
        
    }
    
    @isTest
    static void testGroupMemberForUpsert(){
        TestData_SalesRoleHierarchy salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('A');
        accrecord = new Account(FirstName='Ftest',LastName='Ltest',BillingAddressType__c='US',ClientIdentifier__c=CLIENT_IDENTIFIER);
        List<CustomerGroupMember__c> groupMemberList= new List<CustomerGroupMember__c>();
        setup();        
        system.runAs(testAPIUser){
            Test.startTest();
            insert accrecord;
            CustomerGroup__c groupRec=new CustomerGroup__c(SFGroupIdentifier__c='GroupId1234',Agent__c=salesRoleHierarchy1.Agent.Id);
            system.runAs(systemUser){
                insert groupRec;
                groupRec = [select SFGroupIdentifier__c from CustomerGroup__c where id=:groupRec.Id];
            }
            groupMemberList.add(new CustomerGroupMember__c(GroupMemberId__c='GroupId1234~'+CLIENT_IDENTIFIER,Customer__c=accrecord.Id,Group__c=groupRec.id));
            UTIL_CustomerGroupMemberDAO.upsertCustomerGroupMemberList(groupMemberList);           
            Test.stopTest();   
        }
        
        List<CustomerGroupMember__c> testgroup=[SELECT Customer__c, GroupMemberId__c FROM CustomerGroupMember__c where id IN : groupMemberList];
        system.assertEquals(accrecord.Id, testgroup.get(0).Customer__c, 'The given two parameters are not equal');
        system.assertEquals('GroupId1234~'+CLIENT_IDENTIFIER, testgroup.get(0).GroupMemberId__c, 'The given two parameters are not equal');
    }
    
    @isTest
    static void testHouseholdGroupMemberForDelete(){
        TestData_SalesRoleHierarchy salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('A');
        accrecord = new Account(FirstName='Ftest',LastName='Ltest',BillingAddressType__c='US',ClientIdentifier__c=CLIENT_IDENTIFIER);
        
        List<CustomerGroupMember__c> groupMemberListForUpsert= new List<CustomerGroupMember__c>();
        List<CustomerGroupMember__c> groupMemberListForDelete= new List<CustomerGroupMember__c>();
        
        setup();        
        system.runAs(testAPIUser){
            
            insert accrecord;
            CustomerGroup__c groupRec=new CustomerGroup__c(SFGroupIdentifier__c='GroupId1234',Agent__c=salesRoleHierarchy1.Agent.Id);
            system.runAs(systemUser){
                insert groupRec;
                groupRec = [select SFGroupIdentifier__c from CustomerGroup__c where id=:groupRec.Id];
            }
            groupMemberListForUpsert.add(new CustomerGroupMember__c(GroupMemberId__c='GroupId1234~'+CLIENT_IDENTIFIER,Customer__c=accrecord.Id,Group__c=groupRec.id));
            UTIL_CustomerGroupMemberDAO.upsertCustomerGroupMemberList(groupMemberListForUpsert);           
        }
        Test.startTest();
        groupMemberListForDelete=[SELECT id from CustomerGroupMember__c Where GroupMemberId__c='GroupId1234~IAMCLIENT12']; 
        
        UTIL_CustomerGroupMemberDAO.deleteHouseholdCustomerGroupMemberList(groupMemberListForDelete);
        Test.stopTest();      
        
        try{
            CustomerGroupMember__c testGroupMember = [select Id from CustomerGroupMember__c where id=:groupMemberListForDelete.get(0).Id];
            system.assert(false,'CustomerGroupMember__c is not deleted');
        }catch(QueryException ex){
            system.assert(true, 'Assertion returns false'); 
        }
    }
    
    @isTest
    static void testHouseholdGroupMemberForDeleteWithException(){
        TestData_SalesRoleHierarchy salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('A');
        List<Account> accountList = new List<Account>();
        accrecord = new Account(FirstName='Ftest',LastName='Ltest',BillingAddressType__c='US',ClientIdentifier__c=CLIENT_IDENTIFIER);
        accrecord1 = new Account(FirstName='Ftest1',LastName='Ltest1',BillingAddressType__c='US',ClientIdentifier__c=CLIENT_IDENTIFIER1);
        accountList.add(accrecord);
        accountList.add(accrecord1);    
        List<CustomerGroupMember__c> groupMemberListForUpsert= new List<CustomerGroupMember__c>();
        List<CustomerGroupMember__c> groupMemberListForDelete= new List<CustomerGroupMember__c>();
        List<CustomerGroupMember__c> deleteGroupMemberList = new List<CustomerGroupMember__c>();
        CustomerGroupMember__c houseHoldGroupMember1;
        CustomerGroupMember__c houseHoldGroupMember2;
        setup();        
        system.runAs(systemUser){
            
            insert accountList;
            CustomerGroup__c groupRec=new CustomerGroup__c(SFGroupIdentifier__c='GroupId1234',Agent__c=salesRoleHierarchy1.Agent.Id);
            
            insert groupRec;
            groupRec = [select SFGroupIdentifier__c from CustomerGroup__c where id=:groupRec.Id];
            
            houseHoldGroupMember1 =new CustomerGroupMember__c(GroupMemberId__c='GroupId1234~'+CLIENT_IDENTIFIER,Customer__c=accountList.get(0).Id,Group__c=groupRec.id);
            houseHoldGroupMember2 =new CustomerGroupMember__c(GroupMemberId__c='GroupId1234~'+CLIENT_IDENTIFIER1,Customer__c=accountList.get(1).Id,Group__c=groupRec.id);
            groupMemberListForUpsert.add(houseHoldGroupMember1);
            groupMemberListForUpsert.add(houseHoldGroupMember2);
            UTIL_CustomerGroupMemberDAO.upsertCustomerGroupMemberList(groupMemberListForUpsert);
            groupMemberListForDelete.add(houseHoldGroupMember1);
            groupMemberListForDelete.add(houseHoldGroupMember2);
            deleteGroupMemberList.add(houseHoldGroupMember1);
            deleteGroupMemberList.add(houseHoldGroupMember2);
            delete deleteGroupMemberList;
        }
        Test.startTest();
        UTIL_CustomerGroupMemberDAO.deleteHouseholdCustomerGroupMemberList(groupMemberListForDelete);
        Test.stopTest();      
        ExceptionLog__c results = [SELECT IsHandled__c,Class__c,Method__c,Exception_Message__c  FROM ExceptionLog__c 
                                   where class__c like '%UTIL_CustomerGroupMemberDAO%' limit 1];
        System.assertEquals('UTIL_CustomerGroupMemberDAO' , results.Class__c, 'Class__c is not equals to \'UTIL_CustomerGroupMemberDAO\'');
        System.assertEquals('deleteHouseholdCustomerGroupMemberList', results.Method__c, 'Method__c is not equals to \'deleteHouseholdCustomerGroupMemberList\'');
        System.assertEquals(true, results.IsHandled__c, 'IsHandled__c is false'); 
        System.assertEquals('Records already deleted: '+houseHoldGroupMember1.id+','+houseHoldGroupMember2.id, results.Exception_Message__c, 'Expected exception message is not equals to the actual exception message');
    }
}