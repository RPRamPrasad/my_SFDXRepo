/**
* @name AP_CustomerGroupTrigger_TEST
* @author Loco Motivated
* @createdDate 12/13/2017
* @description Apex unit testing for GroupBeforeInsert Trigger
*/
@isTest
(seeAllData=false)
private class AP_CustomerGroupTrigger_TEST {
    
    private static final Integer GROUP_TEST_BATCH_SIZE=20;
    private static final String SYSADMIN_USER_ID = UTIL_TestUsername_TEST.getTestUsername('sysadmin');
    private static User  systemAdminUser;
    
    /**
    * @name testSetupData
    * @description getting systemAdminUser
    */
    @testsetup
    public static void testSetupData() {        
        systemAdminUser = AP_UserProvisioningProcess_TEST_UTIL.createGenericSystemAdmin(SYSADMIN_USER_ID);
    }
    
  /**
    * @method 
    * Given a System Admin user
    * When a Group is created
    * Then a Group will be created with the Agent Office as a owner
    * @name testGroupCreatedbySystemAdmin
    * @description test for the single group created by system Admin
    */
    @isTest
    public static void testGroupCreatedbySystemAdmin(){
        User systemAdminUser = [SELECT Id, username from User where Username=:SYSADMIN_USER_ID];
        TestData_SalesRoleHierarchy salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
        Test.startTest();
        CustomerGroup__c newGroup= new CustomerGroup__c(GroupCategory__c = 'Primary', Agent__c=salesRoleHierarchy1.Agent.Id, SFGroupIdentifier__c = 'BULKIFIED', ownerId=systemAdminUser.Id);
        system.runAs(systemAdminUser){
            insert newGroup;
        }
        Test.stopTest();
        CustomerGroup__c expectedGroup = [select id, ownerId from CustomerGroup__c where id  = : newGroup.id]; 
        system.assertEquals(salesRoleHierarchy1.AgentOffice.Id, expectedGroup.ownerId, 'Agent Office is not matched');         
        
    }  
    
  /**
    * @method 
    * Given a System Admin user
    * When list of Groups are created
    * Then all Group should be created with Agent office as the owner
    * @name testGroupCreatedbySystemAdminBulkified
    * @description test for bulk group(20)created by system Admin
    */
    @isTest
    public static void testGroupCreatedbySystemAdminBulkified(){
        TestData_SalesRoleHierarchy salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('A');
        User systemAdminUser = [SELECT Id, username from User where Username=:SYSADMIN_USER_ID];
        
        List<CustomerGroup__c> groupList = new List<CustomerGroup__c>();
        for (Integer groupCount=0;groupCount<GROUP_TEST_BATCH_SIZE;groupCount++){
            CustomerGroup__c newGroup= new CustomerGroup__c(GroupCategory__c = 'Primary', Agent__c=salesRoleHierarchy1.Agent.Id, SFGroupIdentifier__c = 'BULKIFIED'+groupCount, ownerId=systemAdminUser.Id);
            groupList.add(newGroup);
        }
        
        Test.startTest();
        system.runAs(systemAdminUser){
            insert groupList;
        }
        Test.stopTest();
        
        system.assertEquals(GROUP_TEST_BATCH_SIZE, groupList.size(), 'Batch size should be 20');
        List<CustomerGroup__c> expectedGroupList = [select id, ownerId from CustomerGroup__c where GroupCategory__c  = : 'Primary'];
        for(CustomerGroup__c singleGroup: expectedGroupList){
            system.assertEquals(salesRoleHierarchy1.AgentOffice.Id, singleGroup.ownerId, 'Agent Office is not matched');
        }
    }
    
  /**
    * @method 
    * Given a System Admin user
    * When single group with invalid Agent's offcie and list of groups are created with one invalid Agent's offcie
    * Then error being returned to the record which had invalid agent's office
    * @name   testGroupCreatedbySystemAdminSingleErrorAndBulkifiedErrors
    * @description test for GroupCreatedbySystemAdmin with Single Error And Bulki fied Errors
    */
    @isTest
    public static void testGroupCreatedbySystemAdminSingleErrorAndBulkifiedErrors(){
        TestData_SalesRoleHierarchy salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('A');
        TestData_SalesRoleHierarchy salesRoleHierarchy2 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('B');
        User systemAdminUser = [SELECT Id, username from User where Username=:SYSADMIN_USER_ID];
        
        List<CustomerGroup__c> groupList = new List<CustomerGroup__c>();
        for (Integer groupCount=0;groupCount<GROUP_TEST_BATCH_SIZE;groupCount++){
            CustomerGroup__c newGroup= new CustomerGroup__c(GroupCategory__c = 'Primary', Agent__c=salesRoleHierarchy1.Agent.Id, SFGroupIdentifier__c = 'BULKIFIED'+groupCount, ownerId=systemAdminUser.Id);
            groupList.add(newGroup);
        }
        
        CustomerGroup__c singleGroup= new CustomerGroup__c(GroupCategory__c = 'Primary', Agent__c=salesRoleHierarchy1.Agent.Id, SFGroupIdentifier__c = 'BULKIFIED', ownerId=systemAdminUser.Id);
        CustomerGroup__c singleGroup2= new CustomerGroup__c(GroupCategory__c = 'Primary', Agent__c=salesRoleHierarchy2.Agent.Id, SFGroupIdentifier__c = 'BULKIFIED', ownerId=systemAdminUser.Id);
        
        salesRoleHierarchy2.AgentOffice.UserExternalID__c='';
        
        Test.startTest();
        system.runAs(systemAdminUser){
            
            update salesRoleHierarchy2.AgentOffice;
            
            //single record error test
            try  {          
                insert singleGroup2;
            }catch(System.DmlException e) {
                system.assert(!String.isBlank(e.getMessage()),null);
                system.assert(e.getMessage().contains('This action cannot be completed at this time. Please try again later.'), null);  
            }
            
            //Mutiple group created with single record error test
            CustomerGroup__c singleGroup1= new CustomerGroup__c(GroupCategory__c = 'Primary', Agent__c=salesRoleHierarchy2.Agent.Id, SFGroupIdentifier__c = 'BULKIFIED23', ownerId=systemAdminUser.Id);
            List<CustomerGroup__c> groupList1 = new List<CustomerGroup__c>{singleGroup, singleGroup1};
            
            Database.SaveResult[] srList = Database.insert(groupList1, false);
            List<Id> savedAgentId = new List<Id>{salesRoleHierarchy1.Agent.Id, salesRoleHierarchy2.Agent.Id};
            List<CustomerGroup__c> savedAccounts = [select id,SFGroupIdentifier__c,ownerId from CustomerGroup__c where Agent__c IN :savedAgentId];
                                                                                                                             
            List<TestData_SalesRoleHierarchy> saveSalesRoleHierarchy = new  List<TestData_SalesRoleHierarchy>();
            saveSalesRoleHierarchy.add(salesRoleHierarchy1) ;
            saveSalesRoleHierarchy.add(salesRoleHierarchy2) ; 
            
            for(Integer i=0; i<srList.size();i++) {
                Database.SaveResult sr = srList.get(i);
                if(sr.isSuccess()){
                    system.assertEquals(groupList1[i].SFGroupIdentifier__c, savedAccounts.get(i).SFGroupIdentifier__c, 'Group Identifier is not matched');
                    system.assertEquals(saveSalesRoleHierarchy.get(i).AgentOffice.Id, savedAccounts.get(i).ownerId, 'Agent office id is not matched');
                }
                else {
                    system.assert(sr.getErrors().get(0).getMessage().contains('This action cannot be completed at this time. Please try again later.'), null);
                }
            }
        }
        Test.stopTest();
    }  
    
  /**
    * @method 
    * Given a System Admin user
    * When a empty group list is being sent to the trigger class
    * Then a Exception will be logged
    * @name   testGroupException
    * @description test for GroupException
    */
    @isTest
    public static void testGroupException(){
        User systemAdminUser = [SELECT Id, username from User where Username=:SYSADMIN_USER_ID];
        TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
        List<CustomerGroup__c> newGroupList;
        
        Test.startTest();
        system.runAs(systemAdminUser){
            try{
                AP_CustomerGroupTrigger.updateOwnerWithAgentProxy(newGroupList);
                system.assert(false, null);
            }catch(exception ex){
                system.assert(true, null);
                system.assert(!String.isBlank(ex.getMessage()), null);
            }
        }
        Test.stopTest();
        
        ExceptionLog__c actualException=[SELECT Id, Class__c, Exception_Message__c, Exception_Type__c, Method__c, Severity__c FROM ExceptionLog__c];
        system.assertEquals('AP_CustomerGroupTrigger', actualException.Class__c, 'Class name is not matched');
        system.assertEquals('System.NullPointerException', actualException.Exception_Type__c, 'Exception Message type is not matched');
        system.assertEquals('updateOwnerWithAgentProxy', actualException.Method__c, 'Method name is not matched');
        system.assertEquals('Attempt to de-reference a null object', actualException.Exception_Message__c, 'Exception Message is not matched');
        system.assertEquals('ERROR', actualException.Severity__c, 'Severity should be ERROR'); 
    }
    
  /**
    * @method 
    * Given a System Admin user
    * When a CustomerGroup__c is created a give data with bypassing the trigger
    * Then a Group will be created with the System Admin as owner
    * @name  testGroupInsertWithOverriddingTriggerLogic
    * @description test for GroupInsertWithOverriddingTriggerLogic
    */
    @isTest
    public static void testGroupInsertWithOverriddingTriggerLogic(){
        User systemAdminUser = [SELECT Id, username from User where Username=:SYSADMIN_USER_ID];
        TestData_SalesRoleHierarchy salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
    	
    	CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemAdminUser);
        objectBasedByPassTrigger.Override_CustomerGroupBeforeInsert__c = true;
        
        CustomerGroup__c newGroup= new CustomerGroup__c(GroupCategory__c = 'Primary', Agent__c=salesRoleHierarchy1.Agent.Id, SFGroupIdentifier__c = 'BULKIFIED99', ownerId=systemAdminUser.Id);
        
        Test.startTest();
        system.runAs(systemAdminUser){
            insert objectBasedByPassTrigger;
            insert  newGroup;
        }
        Test.stopTest();
        
        CustomerGroup__c actualGroup=[SELECT Id, SFGroupIdentifier__c, Agent__c, GroupCategory__c, ownerId FROM CustomerGroup__c where id=:newGroup.Id];
        system.assertEquals('BULKIFIED99', actualGroup.SFGroupIdentifier__c, 'Group Identifier is not matched');
        system.assertEquals(salesRoleHierarchy1.Agent.Id, actualGroup.Agent__c, 'Agent Id is not matched');
        system.assertEquals('Primary', actualGroup.GroupCategory__c, 'Group category is not matched');      
        system.assertEquals(systemAdminUser.Id, actualGroup.ownerId, 'OwnerId is not matched');
    }  
 
}