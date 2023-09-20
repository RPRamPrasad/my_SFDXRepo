/**
* Author : Task Force
* Date Created : 03/28/2019
* @description : This class is the test class for the handler class of Future Dated Follow-ups triggers
* History:
*---------
* Task Force   03/28/2019:  Initial Development
* Task Force   03/28/2019:  Added Test for the Logic for lookup of Customer and Owner (User and Contact obejects) 
*/
@isTest (seeAllData=false)
public class AP_FutureDatedFollowUpTrigger_Test {

    private static User sysAdminuser;
    private static User agentUser;
    private static User atmUser;    
    private static User proxyUser;
    private static UserRole proxyStandardUserRole;
    private static UserRole atmStandardUserRole;
    private static UserRole agentStandardUserRole;
    private static final String SYSADMIN_USER_ID = UTIL_TestUsername_TEST.getTestUsername('sysadmin');
    private static final String USER_EXTERNAL_ID = 'UE123456P';
    private static final String ASSOCIATE_ID = 'UE123456';
    
    
    /**
    * @description : Setup Agents Office and Role heirarchy for testing 
    * @name :setUpAgentOffice
    * @author : TaskForce
    */
     public static void setUpAgentOffice() {
        agentStandardUserRole= new UserRole(name='AgentRole');
        insert agentStandardUserRole;
        atmStandardUserRole= new UserRole(name='ATMMRole', parentRoleId = agentStandardUserRole.id);
        insert atmStandardUserRole;
        proxyStandardUserRole = new UserRole(name='ProxyRole', parentRoleId = atmStandardUserRole.id);
        insert proxyStandardUserRole;
        User testProxyUser1 = new User(Alias='Proxy',LastName='TaskProxy',Username='verifytaskproxy@statefarm.com.bad',UserExternalID__c='123testP',Servicing_Agent_Associate_ID__c='123test');
        proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
        proxyUser.userRoleId= proxyStandardUserRole.id;
        proxyUser.UserExternalID__c = USER_EXTERNAL_ID; 
        Database.insert(proxyUser);
        atmUser = UTIL_UserProvisioning_TEST.buildAgentTeamUser('ATM', 'TaskATM', 'verifytaskAtm@statefarm.com.bad');
        atmUser.userRoleId= atmStandardUserRole.id;
        atmUser.Servicing_Agent_Associate_ID__c = '123test';
        Database.insert(atmUser);
        User testAgentUser1 = new User(Alias='Agent',LastName='TaskAgent',Username='verifytaskAgent@statefarm.com.bad',Associate_ID__c='123test',UserExternalID__c='123test',Servicing_Agent_Associate_ID__c='123test');
        agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
        agentUser.userRoleId= agentStandardUserRole.id;
        agentUser.Associate_ID__c = ASSOCIATE_ID;
        Database.insert(agentUser);
    }
    
    /**
    * @description : Setup a System Admin User
    * @name :setUpSystemAdminUser
    * @author : TaskForce
    */
    public static void setUpSystemAdminUser(){
        sysAdminuser = AP_UserProvisioningProcess_TEST_UTIL.createGenericSystemAdmin(SYSADMIN_USER_ID); 
        SystemRecordOwnerDetails_Test.configureSystemUserRecordOwner(sysAdminuser);  
    }

    /**
    * @description : Test Method for Insert of FDF record 
    * @name :testAgentAssociateIdTransformationToProxy
    * @author : TaskForce
    */
    @isTest
    public static void testAgentAssociateIdTransformationToProxy(){
        setUpAgentOffice();
        setUpSystemAdminUser();
        Test.startTest();
        system.runAs(sysAdminuser){
            Contact contact = new Contact(FirstName='Donald', LastName='Duck', ClientIdentifier__c='CLIENT12345');
            insert contact;
         	Future_Dated_Follow_up__c fdf = new Future_Dated_Follow_up__c();
			fdf.Agent_Associate_Id__c = agentUser.Associate_ID__c;
			fdf.Assigned_To_Associate_Id__c = agentUser.Associate_ID__c;
			fdf.ClientId__c = contact.ClientIdentifier__c;
			fdf.Due_Date__c = Date.today();
			fdf.Line_of_Business__c = 'Auto';
			fdf.Description__c = 'testAgentAssociateIdTransformationToProxy';
			fdf.Remarks__c = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec vehicula diam nec elementum nullam';
			fdf.Category__c = 'SFPP Payments';
			fdf.Activity_Qualifier__c = 'Hp111111 Lorem ipsum dolor sit amet, consectetur adipiscing elit. ';
			insert fdf;
            Future_Dated_Follow_up__c queryFdfForOwner = [SELECT Id, OwnerId FROM Future_Dated_Follow_up__c WHERE Category__c = 'SFPP Payments' LIMIT 1];
            Future_Dated_Follow_up__c queryFdfForAssignedTo = [SELECT Id, Assigned_To__c FROM Future_Dated_Follow_up__c WHERE Category__c = 'SFPP Payments' LIMIT 1];
            Future_Dated_Follow_up__c queryFdfForCustomer = [SELECT Id, Customer_Name__c FROM Future_Dated_Follow_up__c WHERE Category__c = 'SFPP Payments' LIMIT 1];
           	System.assertEquals(queryFdfForOwner.OwnerId, proxyUser.Id, 'Owner Id did not equal Proxy User Id');
            System.assertEquals(queryFdfForCustomer.Customer_Name__c, contact.Id, 'Customer Name did not equal Contact Id');
            System.assertEquals(queryFdfForAssignedTo.Assigned_To__c, agentUser.Id, 'Assigned To did not equal Agent User');
            Test.stopTest();
        }
    }
}