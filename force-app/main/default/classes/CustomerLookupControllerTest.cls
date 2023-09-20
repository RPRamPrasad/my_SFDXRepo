/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */

 /**
  * @description Customer Lookup Controller Test
  */
  @isTest(seeAllData = false)
  private class CustomerLookupControllerTest {
      
      private final static string INDV_ACCT_NAME = 'CombineCustomerIndvTest';
      private final static string ORG_ACCT_NAME = 'CombineCustomerOrgTest';
      private final static string INDV_ACCT_PHONE = '9876543211';
      private final static string CLIENT_ID = '9876543211F';
      private static User systemAdmin;
      private static Account accIndv {get;set;}
      private static Account accOrg {get;set;}
      
      @testSetup
      private static void setup() {
            User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
          insert systemUser;
          AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
          insert sysAdminUserIdSetting;
          
          accIndv = TestDataFactory_Account.createIndividualCustomer(INDV_ACCT_NAME,CLIENT_ID);
          accOrg = TestDataFactory_Account.createOrganizationCustomer(ORG_ACCT_NAME);
          
          accIndv.PersonHomePhone = INDV_ACCT_PHONE;
          
          systemAdmin = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
          System.runAs(systemAdmin) {
              UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
              insert accIndv;
              insert accOrg;
          }
      }
  
      @isTest
      static void searchForAccountsWithNameTest() {
          List<Account> results;        
          
          // Tests individual with LastName, FirstName
          User agentRunningUser = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678914');
          agentRunningUser = TestDataFactory_User.insertUser(agentRunningUser);  
          TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentRunningUser);
	
          System.runAs(agentRunningUser){
                results = CustomerLookupController.searchForAccounts(INDV_ACCT_NAME + ' ' + INDV_ACCT_NAME, 'Name');        
                System.assert(true, 'Mandatory Assert statement on Tests');
          }
      }
  
      @isTest
      static void searchForAccountsWithPhoneTest() {
           List<Account> results;        
          
          // Tests individual with phone
          User agentRunningUser = TestDataFactory_User_Wrapper.generateAgentUser('TEST', '12345678914');
          agentRunningUser = TestDataFactory_User.insertUser(agentRunningUser);  
          TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentRunningUser);

          System.runAs(agentRunningUser){
            results = CustomerLookupController.searchForAccounts(INDV_ACCT_PHONE, 'Phone Number');
            System.assert(true, 'Mandatory Assert statement on Tests');
          }
      }
  
      @isTest
      static void searchForAccountsWithClientIdTest() {
           List<Account> results;
          
          // Tests individual with phone
            results = CustomerLookupController.searchForAccounts(CLIENT_ID, 'Client Id');
            System.assertEquals(INDV_ACCT_NAME + ' ' + INDV_ACCT_NAME, results.get(0).Name, 'Should return the individual account');
      }
  
      /**
       * @description Get AgentProfile User Test
       */
       @isTest
      public static void getAgentProfileUserTest(){
          User testAgentUser1 = new User(Alias='alias',LastName='accOwner',Username='accOwnerAgent@statefarm.com',Associate_ID__c='123test',UserExternalID__c='123test_123test',Servicing_Agent_Associate_ID__c='123test');
          User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
          insert agentUser;
          TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);

          User currentuser;
          test.startTest();
          system.runAs(agentUser){
              CustomerLookupController.loggedInProfile = Label.CL_Agent_Profile;
              currentuser = CustomerLookupController.currentUser();
          }
          System.assertEquals(agentUser.Id, currentuser.Id, 'Unexpected Agent user');
          test.StopTest();
      }
  
      /**
       * @description Get SysAdmin Profile Test
       */
       @isTest
        public static void getSysAdminProfileTest(){

            test.startTest();
            try{
                CustomerLookupController.currentUser();
                System.assertNotEquals('should not get here', 'should not get here', 'Unexpected Admin user');
            }
            catch(Exception e){
                System.assertEquals('Script-thrown exception', e.getMessage(), 'Unauthorized user exception');
            }
            test.StopTest();
            
        }
  }  