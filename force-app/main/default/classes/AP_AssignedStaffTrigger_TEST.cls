/**
* @name AP_AssignedStaffTrigger_TEST
* @author Choo_Choo
* @owner Stark
* @createdDate 04/23/2018
* @description Apex unit testing for AssignedStaffBeforeInsert Trigger
*/

@isTest
(seeAllData=false)
public with sharing class AP_AssignedStaffTrigger_TEST {
	
    private static final String SYSADMIN_USER_ID = UTIL_TestUsername_TEST.getTestUsername('sysadmin');
    private static final String AGENT_USER_ID = UTIL_TestUsername_TEST.getTestUsername('sysadmin');
    private static User  systemAdminUser;
   
    /**
     * When agent is created
     * @description setUp
     */
    @testsetup
    public static void setUp()
    {	
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemAdminUser = AP_UserProvisioningProcess_TEST_UTIL.createGenericSystemAdmin(SYSADMIN_USER_ID);
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemAdminUser.id);            
        insert sysAdminUserIdSetting;
        TestData_SalesRoleHierarchy salesRoleHierarchy1 = TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('S');
        TestDataFactory_SalesRoleHierarchy.generateSalesRoleHierarchy('B');
        User agentTeamMember;
        system.runAs(systemAdminUser){
	        
	        agentTeamMember = TestDataFactory_User_Wrapper.generateAgentTeamMemberUser('ATM2', '222222223S');
	    	agentTeamMember.UserRoleId = salesRoleHierarchy1.AgentTeamMember.UserRoleId;
	        agentTeamMember.Servicing_Agent_Associate_ID__c = salesRoleHierarchy1.Agent.Associate_Id__c;
	        agentTeamMember.Servicing_Agent_Associate_ID_List__c = salesRoleHierarchy1.Agent.Associate_Id__c;
	        insert agentTeamMember;
            User agentUser = salesRoleHierarchy1.Agent;
            agentUser.UserExternalId__c = agentUser.Associate_Id__c + '_' + agentUser.Associate_Id__c;
            update agentuser;
        }
    }
    /**
     * @description testAssignedStaffUpdateForAgent
     */ 
    @isTest
    public static void testAssignedStaffUpdateForAgent(){
        
         TestData_SalesRoleHierarchy salesRoleHierarchy1=TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('S');
        Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('agents');
        acc.clientIdentifier__c = '12345678901';
        insert acc;
        AgentRole__c agtRole = new AgentRole__c (Customer__c = acc.id, Agent__c = salesRoleHierarchy1.Agent.Id, RelationshipNature__c = 'Prospect');
        insert agtRole;
        AssignedStaff__c newAssignedStaff= new AssignedStaff__c(Customer__c=acc.Id,Staff__c=salesRoleHierarchy1.AgentTeamMember.Id);
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.Agent);
        system.runAs(salesRoleHierarchy1.Agent){
            insert newAssignedStaff;
        }
        Test.stopTest();
        AssignedStaff__c assignedStaff = [Select id,name,ownerId from AssignedStaff__c where AssignedStaffIdentifier__c = :acc.clientIdentifier__c+'~'+salesRoleHierarchy1.Agent.Associate_ID__c+'~'+salesRoleHierarchy1.AgentTeamMember.Associate_Id__c limit 1];
        system.assertEquals(salesRoleHierarchy1.AgentOffice.Id, assignedStaff.ownerId, 'AgentOffice and Owner Id is same');   
    }
    
    /**
     * @description testAssignedStaffUpdateForAgentTeamMember
     */ 
    @isTest
    public static void testAssignedStaffUpdateForAgentTeamMember(){
    	 TestData_SalesRoleHierarchy salesRoleHierarchy1=TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('S');
      
        Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('agents');
        acc.clientIdentifier__c = '12345678901';
        insert acc;
        AgentRole__c agtRole = new AgentRole__c (Customer__c = acc.id, Agent__c = salesRoleHierarchy1.Agent.Id, RelationshipNature__c = 'Prospect');
        insert agtRole;
        AssignedStaff__c newAssignedStaff= new AssignedStaff__c(Customer__c=acc.Id,Staff__c=salesRoleHierarchy1.AgentTeamMember.Id);
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.AgentTeamMember);
        system.runAs(salesRoleHierarchy1.AgentTeamMember){
            insert newAssignedStaff;
        }
        Test.stopTest();
        AssignedStaff__c assignedStaff = [Select id,name,ownerId from AssignedStaff__c where AssignedStaffIdentifier__c = :acc.clientIdentifier__c+'~'+salesRoleHierarchy1.Agent.Associate_ID__c+'~'+salesRoleHierarchy1.AgentTeamMember.Associate_Id__c limit 1];
        system.assertEquals(salesRoleHierarchy1.AgentOffice.Id, assignedStaff.ownerId, 'AgentOffice and Owner Id is same');   
    }

  /**
    * @method 
    * Given a System Admin user
    * When a Assigned Staff is created
    * Then a Assigned Staff will be created with the Agent Office as a owner
    * @description testAssignedStaffCreatedbySystemAdmin
    */
    @isTest
    public static void testAssignedStaffCreatedbySystemAdmin(){
    	User systemAdminUser=[Select Id,alias from user where alias='admin' and username=:SYSADMIN_USER_ID and profile.name='System Administrator'];
       TestData_SalesRoleHierarchy salesRoleHierarchy1=TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('S');
        Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('Sharma');
        acc.clientIdentifier__c = '12345678901';
        insert acc;
        AgentRole__c agtRole = new AgentRole__c (Customer__c = acc.id, Agent__c = salesRoleHierarchy1.Agent.Id, RelationshipNature__c = 'Prospect');
        insert agtRole;
        AssignedStaff__c newAssignedStaff= new AssignedStaff__c(Agent__c=salesRoleHierarchy1.Agent.Id,Customer__c=acc.Id,Staff__c=salesRoleHierarchy1.AgentTeamMember.Id);
        Test.startTest();
        system.runAs(systemAdminUser){
            insert newAssignedStaff;
        }
        Test.stopTest();
        AssignedStaff__c assignedStaff = [Select id,name,ownerId from AssignedStaff__c where AssignedStaffIdentifier__c = :acc.clientIdentifier__c+'~'+salesRoleHierarchy1.Agent.Associate_ID__c+'~'+salesRoleHierarchy1.AgentTeamMember.Associate_Id__c limit 1];
        system.assertEquals(salesRoleHierarchy1.AgentOffice.Id, assignedStaff.ownerId, 'AgentOffice and Owner Id is same');         
     }  
    
     /**
    * @method 
    * Given a System Admin user
    * When list of Assigned Staff are created
    * Then all Assigned Staff should be created with Agent office as the owner
    * @description testAssignedStaffCreatedbySystemAdminBulkified
    */
    @isTest
    public static void testAssignedStaffCreatedbySystemAdminBulkified(){
    	
        TestData_SalesRoleHierarchy salesRoleHierarchy1=TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('S');
       TestData_SalesRoleHierarchy salesRoleHierarchy2=TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('B');
        User systemAdminUser=[Select Id,alias from user where alias='admin' and username=:SYSADMIN_USER_ID and profile.name='System Administrator'];

        Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('Steve');
        acc.clientIdentifier__c = '12345678901';
        insert acc;
        AgentRole__c agtRole = new AgentRole__c (Customer__c = acc.id, Agent__c = salesRoleHierarchy1.Agent.Id, RelationshipNature__c = 'Prospect');
        AgentRole__c agtRole1 = new AgentRole__c (Customer__c = acc.id, Agent__c = salesRoleHierarchy2.Agent.Id, RelationshipNature__c = 'Prospect');
        insert new List<AgentRole__c>{agtRole, agtRole1};
        List<AssignedStaff__c> assignedStaffList = new List<AssignedStaff__c>();
        assignedStaffList.add(new AssignedStaff__c(Agent__c=salesRoleHierarchy1.Agent.Id, Customer__c=acc.Id,Staff__c=salesRoleHierarchy1.AgentTeamMember.Id));
        assignedStaffList.add(new AssignedStaff__c(Agent__c=salesRoleHierarchy2.Agent.Id, Customer__c=acc.Id,Staff__c=salesRoleHierarchy2.AgentTeamMember.Id));
        Test.startTest();
        system.runAs(systemAdminUser){
            insert assignedStaffList;
        }
        Test.stopTest();
        List<AssignedStaff__c> expectedAssignedStaffList = [Select id,name,Agent__c,ownerId from AssignedStaff__c];
        system.assertEquals(2, expectedAssignedStaffList.size(), 'Assigned Staff List = 2');
        for(AssignedStaff__c singleAssignedStaff: expectedAssignedStaffList){
        	if(singleAssignedStaff.Agent__c == salesRoleHierarchy1.Agent.Id){
            	system.assertEquals(salesRoleHierarchy1.AgentOffice.Id, singleAssignedStaff.ownerId, 'AgentOffice and Owner Id is same');
        	}
        	else {
        		system.assertEquals(salesRoleHierarchy2.AgentOffice.Id, singleAssignedStaff.ownerId, 'AgentOffice and Owner Id is same');
        	}
        }
	}
    /**
    * @method 
    * Given a System Admin user
    * When single Assigned Staff with invalid Agent's office and list of Assigned Staff are created with one invalid Agent's offcie
    * Then error being returned to the record which had invalid agent's office
    * @description testAssignedStaffCreatedbySystemAdminSingleErrorAndBulkifiedErrors
    */
    @isTest
    public static void testAssignedStaffCreatedbySystemAdminSingleErrorAndBulkifiedErrors(){
    	
         TestData_SalesRoleHierarchy salesRoleHierarchy1=TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('S');
         TestData_SalesRoleHierarchy salesRoleHierarchy2=TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('B');
       User systemAdminUser=[Select Id,alias from user where alias='admin' and username=:SYSADMIN_USER_ID and profile.name='System Administrator'];

        
        Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('Sharma');
        acc.clientIdentifier__c = '12345678901';
        insert acc;
        
        AgentRole__c agtRole = new AgentRole__c (Customer__c = acc.id, Agent__c = salesRoleHierarchy1.Agent.Id, RelationshipNature__c = 'Prospect');
        AgentRole__c agtRole1 = new AgentRole__c (Customer__c = acc.id, Agent__c = salesRoleHierarchy2.Agent.Id, RelationshipNature__c = 'Prospect');
        insert new List<AgentRole__c>{agtRole, agtRole1};
         
        AssignedStaff__c newAssignedStaff= new AssignedStaff__c(Agent__c=salesRoleHierarchy1.Agent.Id, Customer__c=acc.Id,Staff__c=salesRoleHierarchy1.AgentTeamMember.Id);
        AssignedStaff__c newAssignedStaff4= new AssignedStaff__c(Agent__c=salesRoleHierarchy1.Agent.Id, Customer__c=acc.Id,Staff__c=salesRoleHierarchy1.Agent.Id);
        AssignedStaff__c newAssignedStaff3= new AssignedStaff__c(Agent__c=salesRoleHierarchy1.Agent.Id, Customer__c=acc.Id,Staff__c=salesRoleHierarchy1.AgentTeamMember.Id);
        AssignedStaff__c newAssignedStaff2= new AssignedStaff__c(Agent__c=salesRoleHierarchy2.Agent.Id, Customer__c=acc.Id,Staff__c=salesRoleHierarchy2.AgentTeamMember.Id);
        
        salesRoleHierarchy2.AgentOffice.UserExternalID__c='';
        Test.startTest();
        system.runAs(systemAdminUser){
            
            update salesRoleHierarchy2.AgentOffice;
            
            //single record error test
            try  {          
                insert newAssignedStaff2;
            }catch(System.DmlException e) {
                system.assert(!String.isBlank(e.getMessage()), 'Exception Message');
                system.assert(e.getMessage().contains('There is a problem with the action you performed'), 'There is a problem with the action you performed');  
            }
            
            //Mutiple assigned staff created with single record error test
            AssignedStaff__c newAssignedStaff1= new AssignedStaff__c(Agent__c=salesRoleHierarchy2.Agent.Id, AssignedStaffIdentifier__c =acc.clientIdentifier__c+'~'+salesRoleHierarchy2.Agent.Associate_ID__c+'~'+salesRoleHierarchy2.AgentTeamMember.Associate_Id__c,Customer__c=acc.Id,Staff__c=salesRoleHierarchy1.AgentTeamMember.Id);
            List<AssignedStaff__c> assignedStaffList1 = new List<AssignedStaff__c>{newAssignedStaff, newAssignedStaff1,newAssignedStaff3,newAssignedStaff4};
            
            Database.SaveResult[] srList = Database.insert(assignedStaffList1, false);
            
            List<Id> assignedStaffIdList = new List<Id>();
            for(Database.SaveResult sr: srList) {
                if(sr.isSuccess()) {
                    assignedStaffIdList.add(sr.getId());
                }
                else {
                    system.assert(sr.getErrors().get(0).getMessage().contains('There is a problem with the action you performed') || sr.getErrors().get(0).getMessage().contains('duplicate value'), 'Records were not saved');
                }
            }
            for(AssignedStaff__c assignedStaff : [SELECT OwnerId FROM AssignedStaff__c WHERE id IN :assignedStaffIdList]) {
                system.assertEquals(salesRoleHierarchy1.AgentOffice.Id, assignedStaff.ownerId, 'AgentOffice and Owner Id is same');
             }
        }
        Test.stopTest();
    }
     
     /**
    * @method 
    * Given a System Admin user
    * When a empty assigned staff list is being sent to the trigger class
    * Then a Exception will be logged
    * @description testAssignedStaffException
    */
    @isTest
    public static void testAssignedStaffException(){
    User systemAdminUser=[Select Id,alias from user where alias='admin' and username=:SYSADMIN_USER_ID and profile.name='System Administrator'];

        List<AssignedStaff__c> assignedStaffList;
        Test.startTest();
        system.runAs(systemAdminUser){
            try{
                AP_AssignedStaffTrigger.updateOwnerWithAgentProxy(assignedStaffList);
                system.assert(false, 'Updated Assigned Staff List');
            }catch(exception ex){
                system.assert(true, 'Exception Message');
                system.assert(!String.isBlank(ex.getMessage()), 'Exception Message');
            }
        }
        Test.stopTest();
        ExceptionLog__c actualException=[SELECT Id, Class__c, Exception_Message__c, Exception_Type__c, Method__c, Severity__c FROM ExceptionLog__c];
        system.assertEquals('AP_AssignedStaffTrigger', actualException.Class__c, 'Class in Exception Log');
        system.assertEquals('System.NullPointerException', actualException.Exception_Type__c, 'Type of Exception Log');
        system.assertEquals('updateOwnerWithAgentProxy', actualException.Method__c, 'Exception Log Method');
        system.assertEquals('Attempt to de-reference a null object', actualException.Exception_Message__c, 'Message in Exception Log');
        system.assertEquals('ERROR', actualException.Severity__c, 'Severity of Exception Log'); 
    }
    
     /**
    * @method 
    * Given a System Admin user
    * When a empty assigned staff list is being sent to the trigger class
    * Then a Exception will be logged
    * @description testAssignedStaffExceptionUpdate
    */
    @isTest
    public static void testAssignedStaffExceptionUpdate(){
    User systemAdminUser=[Select Id,alias from user where alias='admin' and username=:SYSADMIN_USER_ID and profile.name='System Administrator'];

        List<AssignedStaff__c> assignedStaffList;
        Map<Id, AssignedStaff__c> oldStaffMap;
        Test.startTest();
        system.runAs(systemAdminUser){
            try{
                AP_AssignedStaffTrigger.validateAssignedStaffUpdate(assignedStaffList, oldStaffMap);
                system.assert(false, 'Staff List Updated');
            }catch(exception ex){
                system.assert(true, 'Exception Message');
                system.assert(!String.isBlank(ex.getMessage()), 'Exception Message');
            }
        }
        Test.stopTest();
        ExceptionLog__c actualException=[SELECT Id, Class__c, Exception_Message__c, Exception_Type__c, Method__c, Severity__c FROM ExceptionLog__c];
        system.assertEquals('AP_AssignedStaffTrigger_Additional', actualException.Class__c, 'Class in Exception Log');
        system.assertEquals('System.NullPointerException', actualException.Exception_Type__c, 'Type in Exception Log');
        system.assertEquals('validateAssignedStaffUpdate', actualException.Method__c, 'Method in Exception Log');
        system.assertEquals('Attempt to de-reference a null object', actualException.Exception_Message__c, 'Message in Exception Log');
        system.assertEquals('ERROR', actualException.Severity__c, 'Severity of Exception Log'); 
    }
    
     /**
    * @method 
    * Given a System Admin user
    * When a AssignedStaff__c is created a give data with bypassing the trigger
    * Then a Assigned Staff will be created with the System Admin as owner
    * @description testAssignedStaffInsertWithOverriddingTriggerLogic
    */
    @isTest
    public static void testAssignedStaffInsertWithOverriddingTriggerLogic(){
    	
        TestData_SalesRoleHierarchy salesRoleHierarchy1=TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('S');
        User systemAdminUser=[Select Id,alias from user where alias='admin' and username=:SYSADMIN_USER_ID and profile.name='System Administrator'];

        Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('Sharma');
        acc.clientIdentifier__c = '12345678901';
        insert acc;
    	
    	CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemAdminUser);
        objectBasedByPassTrigger.Override_AssignedStaffBeforeInsert__c = true;
        objectBasedByPassTrigger.Override_AssignedStaffBeforeUpdate__c = true;
        
        AssignedStaff__c newAssignedStaff= new AssignedStaff__c(Agent__c=salesRoleHierarchy1.Agent.Id, AssignedStaffIdentifier__c =acc.clientIdentifier__c+'~'+salesRoleHierarchy1.Agent.Associate_ID__c+'~'+salesRoleHierarchy1.AgentTeamMember.Associate_Id__c,Customer__c=acc.Id,Staff__c=salesRoleHierarchy1.AgentTeamMember.Id);
        Test.startTest();
        system.runAs(systemAdminUser){
            insert objectBasedByPassTrigger;
            insert  newAssignedStaff;
        }
        AssignedStaff__c actualAssignedStaff = [Select Agent__c,ownerId from AssignedStaff__c where id=:newAssignedStaff.Id];
        system.assertEquals(salesRoleHierarchy1.Agent.Id, actualAssignedStaff.Agent__c, 'Both Ids are same');  
        system.assertEquals(systemAdminUser.Id, actualAssignedStaff.ownerId, 'Both Ids are same');
        newAssignedStaff.Agent__c = null;
        system.runAs(systemAdminUser) {
        	update newAssignedStaff;
        }
        AssignedStaff__c actualAssignedStaff1 = [Select Agent__c,ownerId from AssignedStaff__c where id=:newAssignedStaff.Id];
        system.assertEquals(null, actualAssignedStaff1.Agent__c, 'No Assigned Staff');  
        system.assertEquals(systemAdminUser.Id, actualAssignedStaff1.ownerId, 'Both Ids are same');
    }
    
     /**
    * @method 
    * Given a System Admin user inserts a Assigned staff data that already exists
    * Then a error should be thrown
    * @description testAssignedStaffInsertWithSameExistingData
    */
    @isTest
    public static void testAssignedStaffInsertWithSameExistingData(){
    	User systemAdminUser=[Select Id,alias from user where alias='admin' and username=:SYSADMIN_USER_ID and profile.name='System Administrator'];

        TestData_SalesRoleHierarchy salesRoleHierarchy1=TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('S');
        Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('Sharma');
        acc.clientIdentifier__c = '12345678901';
        insert acc;
        AgentRole__c agtRole = new AgentRole__c (Customer__c = acc.id, Agent__c = salesRoleHierarchy1.Agent.Id, RelationshipNature__c = 'Prospect');
        insert agtRole;
        AssignedStaff__c newAssignedStaff= new AssignedStaff__c(Agent__c=salesRoleHierarchy1.Agent.Id, Customer__c=acc.Id,Staff__c=salesRoleHierarchy1.AgentTeamMember.Id);
        insert newAssignedStaff;
        AssignedStaff__c assignedStaff1 = new AssignedStaff__c(Agent__c=salesRoleHierarchy1.Agent.Id, Customer__c=acc.Id,Staff__c=salesRoleHierarchy1.AgentTeamMember.Id);
        Test.startTest();
        System.runAs(systemAdminUser){
        	try {
        		insert assignedStaff1;
        	}
        	catch(System.DmlException e) {
                system.assert(!String.isBlank(e.getMessage()), 'Exception Message');
                system.assert(e.getMessage().contains('duplicate value'), 'Exception Message');  
            }
        }
        Test.stopTest();
    }
    
     /**
    * @method 
    * Given a System Admin user inserts a Assigned staff with staff not related to agent
    * Then a error should be thrown
    * @description testAssignedStaffInsertWithDifferentStaff
    */
    @isTest
    public static void testAssignedStaffInsertWithDifferentStaff(){
    	User systemAdminUser=[Select Id,alias from user where alias='admin' and username=:SYSADMIN_USER_ID and profile.name='System Administrator'];

        TestData_SalesRoleHierarchy salesRoleHierarchy1=TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('S');
        TestData_SalesRoleHierarchy salesRoleHierarchy2=TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('B');
        Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('Sharma');
        acc.clientIdentifier__c = '12345678901';
        insert acc;
        AgentRole__c agtRole = new AgentRole__c (Customer__c = acc.id, Agent__c = salesRoleHierarchy1.Agent.Id, RelationshipNature__c = 'Prospect');
        insert agtRole;
        AssignedStaff__c newAssignedStaff= new AssignedStaff__c(Agent__c=salesRoleHierarchy1.Agent.Id, Customer__c=acc.Id,Staff__c=salesRoleHierarchy2.AgentTeamMember.Id);
        Test.startTest();
        System.runAs(systemAdminUser){
        	try {
        		insert newAssignedStaff;
        	}
        	catch(System.DmlException e) {
                system.assert(!String.isBlank(e.getMessage()), 'Exception Message');
                system.assert(e.getMessage().contains(Label.CL_AS_StaffException), 'Exception Message');  
            }
        }
        Test.stopTest();
    }
    
     /**
    * @method 
    * Given a System Admin user inserts a Assigned staff with not related to agent
    * Then a error should be thrown
    * @description testAssignedStaffInsertWithNoAgentRole
    */
    @isTest
    public static void testAssignedStaffInsertWithNoAgentRole(){
    	User systemAdminUser=[Select Id,alias from user where alias='admin' and username=:SYSADMIN_USER_ID and profile.name='System Administrator'];

        TestData_SalesRoleHierarchy salesRoleHierarchy1=TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('S');
        TestData_SalesRoleHierarchy salesRoleHierarchy2=TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('B');
        Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('Sharma');
        acc.clientIdentifier__c = '12345678901';
        insert acc;
        AgentRole__c agtRole = new AgentRole__c (Customer__c = acc.id, Agent__c = salesRoleHierarchy1.Agent.Id, RelationshipNature__c = 'Prospect');
        insert agtRole;
        AssignedStaff__c newAssignedStaff= new AssignedStaff__c(Agent__c=salesRoleHierarchy2.Agent.Id, Customer__c=acc.Id,Staff__c=salesRoleHierarchy2.AgentTeamMember.Id);
        Test.startTest();
        System.runAs(systemAdminUser){
        	try {
        		insert newAssignedStaff;
        	}
        	catch(System.DmlException e) {
                system.assert(!String.isBlank(e.getMessage()), 'Exception Message');
                system.assert(e.getMessage().contains(Label.CL_AS_AgentException), 'Exception Message');  
            }
        }
        Test.stopTest();
    }
    
     /**
    * @method 
    * Given a System Admin user updates a Assigned staff with error
    * Then a error should be thrown
    * @description testAssignedStaffUpdateWithErrors
    */
    @isTest
    public static void testAssignedStaffUpdateWithErrors(){

       TestData_SalesRoleHierarchy salesRoleHierarchy1=TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('S');
       TestData_SalesRoleHierarchy salesRoleHierarchy2=TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('B');
        Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('Sharma');
        acc.clientIdentifier__c = '12345678901';
        insert acc;
        Account acc1 = UTIL_CreateCustomerTestData.createIndividualCustomer('Dhawan');
        acc1.clientIdentifier__c = '12345678902';
        insert acc1;
        AgentRole__c agtRole = new AgentRole__c (Customer__c = acc.id, Agent__c = salesRoleHierarchy1.Agent.Id, RelationshipNature__c = 'Prospect');
        insert agtRole;
        AssignedStaff__c newAssignedStaff= new AssignedStaff__c(Agent__c=salesRoleHierarchy1.Agent.Id, Customer__c=acc.Id,Staff__c=salesRoleHierarchy1.AgentTeamMember.Id);
        insert newAssignedStaff;
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.Agent);
        System.runAs(salesRoleHierarchy1.Agent){
        	try {
        		newAssignedStaff = [Select Id, name, Agent__c, Customer__c, Staff__c from AssignedStaff__c where id = :newAssignedStaff.Id LIMIT 1];
        		newAssignedStaff.customer__c = acc1.id;
        		update newAssignedStaff;
        		system.assert(false, 'Assigned Staff Id');
        	}
        	catch(System.DmlException e) {
                system.assert(!String.isBlank(e.getMessage()), 'Exception Message');
            }
            try {
            	newAssignedStaff = [Select Id, name, Agent__c, Customer__c, Staff__c from AssignedStaff__c where id = :newAssignedStaff.Id LIMIT 1];
            	newAssignedStaff.Agent__c = salesRoleHierarchy2.Agent.Id;
            	update newAssignedStaff;
            	system.assert(false, 'Updated Assigned Staff Id');
            }
            catch(System.DmlException e) {
            	system.assert(!String.isBlank(e.getMessage()), 'Exception Message');
                system.assert(e.getMessage().contains(Label.CL_AS_AgentChange), 'Exception Message');
            }
            try {
            	newAssignedStaff = [Select Id, name, Agent__c, Customer__c, Staff__c from AssignedStaff__c where id = :newAssignedStaff.Id LIMIT 1];
            	newAssignedStaff.Staff__c = salesRoleHierarchy2.AgentTeamMember.Id;
            	update newAssignedStaff;
            	system.assert(false, 'Staff Id');
            }
            catch(System.DmlException e) {
            	system.assert(!String.isBlank(e.getMessage()), 'Exception Message');
            }
        }
        Test.stopTest();
    }
    
     /**
    * @method 
    * Given a System Admin user updates a Assigned staff with success
    * Then a error should be thrown
    * @description testAssignedStaffUpdateSuccess
    */
    @isTest
    public static void testAssignedStaffUpdateSuccess(){
    	
        TestData_SalesRoleHierarchy salesRoleHierarchy1=TestDataFactory_SalesRoleHierarchy.retrieveSalesRoleHierarchy('S');
       User agentTeamMember=[Select Id,Associate_id__c,Alias from User where alias='ATM2'];
        
        Account acc = UTIL_CreateCustomerTestData.createIndividualCustomer('Sharma');
        acc.clientIdentifier__c = '12345678901';
        insert acc;
        Account acc1 = UTIL_CreateCustomerTestData.createIndividualCustomer('Dhawan');
        acc1.clientIdentifier__c = '12345678902';
        insert acc1;
        AgentRole__c agtRole = new AgentRole__c (Customer__c = acc.id, Agent__c = salesRoleHierarchy1.Agent.Id, RelationshipNature__c = 'Prospect');
        insert agtRole;
        AgentRole__c agtRole1 = new AgentRole__c (Customer__c = acc1.id, Agent__c = salesRoleHierarchy1.Agent.Id, RelationshipNature__c = 'Prospect');
        insert agtRole1;
        AssignedStaff__c newAssignedStaff= new AssignedStaff__c(Agent__c=salesRoleHierarchy1.Agent.Id, Customer__c=acc.Id,Staff__c=salesRoleHierarchy1.AgentTeamMember.Id);
        insert newAssignedStaff;
        Test.startTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(salesRoleHierarchy1.Agent);
        System.runAs(salesRoleHierarchy1.Agent){
            try {
                newAssignedStaff.Customer__c = acc1.id;
                update newAssignedStaff;
                newAssignedStaff = [Select id, AssignedStaffIdentifier__c, Agent__c, Customer__C, Staff__c from AssignedStaff__c where id = :newAssignedStaff.id LIMIT 1];
                system.assert(false, 'Staff Id');
            }
            catch(System.DmlException e) {
            	system.assert(!String.isBlank(e.getMessage()), 'Exception Message');
            }
            try {
                newAssignedStaff.Staff__c = agentTeamMember.Id;
        	    update newAssignedStaff;
        	    newAssignedStaff = [Select id, AssignedStaffIdentifier__c, Agent__c, Customer__C, Staff__c from AssignedStaff__c where id = :newAssignedStaff.id LIMIT 1];
                system.assert(false, 'Staff Id');
            }
            catch(System.DmlException e) {
            	system.assert(!String.isBlank(e.getMessage()), 'Exception Message');
            }
            try {
                newAssignedStaff.Staff__c = salesRoleHierarchy1.AgentTeamMember.Id;
        	    newAssignedStaff.Customer__c = acc.id;
        	    update newAssignedStaff;
        	    newAssignedStaff = [Select id, AssignedStaffIdentifier__c, Agent__c, Customer__C, Staff__c from AssignedStaff__c where id = :newAssignedStaff.id LIMIT 1];
            }
        	catch(System.DmlException e) {
            	system.assert(!String.isBlank(e.getMessage()), 'Exception Message');
            }
        }
        Test.stopTest();
    }    
}
