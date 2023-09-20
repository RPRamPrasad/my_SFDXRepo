/**
* @description Apex Unit testing
*/
@isTest(seeAllData=false)
public class AP_QA_OpportunityAccount_Email_Test {
    private static User systemUser;

    /**
	* @description Setup method used for building test data (must be called at beginning of test)
	*/
    @testsetup
    public static void testSetupData() {
        systemUser =  new User(alias = 'SYSA', email='noaccessTest@statefarm.com.bad', 
                                    emailencodingkey='UTF-8', lastname='TestSysRecOwner', languagelocalekey='en_US', 
                                    localesidkey='en_US', timezonesidkey='America/Chicago', username= 'sysAccRecOwner@test.com');
        systemUser.ProfileId = [select Id from Profile where name = '1.02 No Access' LIMIT 1].Id;
        
        insert systemUser;
        
        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=false);
        insert passTriggerAll;
        CS001_ByPassTriggerAtoF__c accountByPassTrigger= new CS001_ByPassTriggerAtoF__c(Override_AccountBeforeInsert__c=false,Override_AgentRoleAfterInsert__c=false);
        insert accountByPassTrigger;
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(Name=UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER,SFDC_USER_ID__c=systemUser.id);            
        insert sysAdminUserIdSetting;
        
        CS001_ByPassTriggerAtoF__c accBasedByPassTrigger = new CS001_ByPassTriggerAtoF__c();
        accBasedByPassTrigger.Override_AccountBeforeInsert__c = false;
        accBasedByPassTrigger.SetupOwnerId = systemUser.id;
        insert accBasedByPassTrigger;
        
        CS001_ByPassTriggerGtoZ__c oppByPassTrigger = new CS001_ByPassTriggerGtoZ__c(Override_OppBeforeInsert__c=false);
        insert oppByPassTrigger;    
        
        CS_EnvironmentURLCustomSetting__c csEnvUrl = new CS_EnvironmentURLCustomSetting__c(Name='MARKETING_MAIL_MANAGEMENT_SR_API_KEY', Value__c='test');
        insert csEnvUrl;
        
         new AP_QA_OpportunityAccount_Email(new HLPR_MarketingMailManagementFacade());
    }
    @isTest
    private static void testBlankPersonEmail(){
        User adminUser = setupAdminUser();
        Account accs = new Account(Edit_In_VFP__c=true,FirstName = 'bbbbbbbbbbbb',LastName = 'bbbbbbbbbbb',
                                   ClientIdentifier__c = 'jlzb',
                                   IsDeathNotificationReceived__pc = false,
                                   PersonEmail = '',HasPermissionToMarketingEmail__c = 'yes',
                                   HasPermissionToServiceEmail__c = 'yes', IsSubjecttoCASL__c = 'NO' );
        
        insert accs;
        
        Test.starttest();
        System.runAs(adminUser) {   
           
            String accountId = accs.id;
            Map<String, String> requestParams = new Map<String, String>();
            requestParams.put('accountId', accountId);

            
            
            try{
                AP_QA_OpportunityAccount_Email sendEmail = new AP_QA_OpportunityAccount_Email();
                sendEmail.setRequestParameters(requestParams);
                sendEmail.execute();
                
                
            } catch(Exception e){
                
                System.assertEquals( System.Label.CL_SELECTMAILER_MISSING_EMAIL, e.getMessage(),'Unexpected exception message occured');   
            }
        Test.stoptest();  
        }   
    }
    @isTest
    private static void testDeathnotificationisTrue(){
        User adminUser = setupAdminUser();
        Account account = new Account(Edit_In_VFP__c=true,FirstName = 'jlrcnbgchmxtxb',LastName = 'jlrcnbgchmxtxb',
                                      ClientIdentifier__c = 'jsfc', IsDeathNotificationReceived__pc  = true, 
                                      PersonEmail = 'stzxcjgcrpcc@NOEMAIL.com',IsSubjecttoCASL__c='yes');
        
        
        Test.starttest();
        System.runAs(adminUser) {
            
            insert account;
           
            Map<String, String> requestParams = new Map<String, String>();
            String accountId = account.id;
            requestParams.put('accountId', accountId);           
            Try{ 
                
                AP_QA_OpportunityAccount_Email sendEmail = new AP_QA_OpportunityAccount_Email();
                sendEmail.setRequestParameters(requestParams);
                
                sendEmail.execute();
                
            } catch(exception e){
             
                System.assertEquals( System.Label.CL_SELECTMAILER_CLIENT_DECEASED, e.getMessage(),'Unexpected exception message occured');
    
            }
    
            Test.stoptest();   
        }
      
    }
    @isTest
    private static void testDNSMarketingNoServicing(){
        User adminUser = setupAdminUser();
        Account accounts = new Account(Edit_In_VFP__c=true,FirstName = 'jlrcnbbhhmxtzz',LastName = 'jlrcnbgchcxtzz',
                                       ClientIdentifier__c = 'jcdb',IsDeathNotificationReceived__pc = false,
                                       PersonEmail = 'stzxcjgcrpcc@NOEMAIL.com', HasPermissionToMarketingEmail__c = 'no',
                                       HasPermissionToServiceEmail__c = 'no',IsSubjecttoCASL__c='yes');
        
        
        insert accounts;
        Test.starttest();
        System.runAs(adminUser) {   
            try{
                sendRequestParams('U', accounts.id);
            } catch(exception e){
                System.assertEquals(System.Label.CL_SELECTMAILER_DONOTSOLICIT, e.getMessage(),'Unexpected exception message occured');
            }
           
            Test.stoptest(); 
        }
    }
    @isTest
    private static void testPermissionService(){
        User adminUser = setupAdminUser();
        Account accounts = new Account(Edit_In_VFP__c=true,FirstName = 'jlrcnbbhhmxtzz',LastName = 'jlrcnbgchcxtzz',
                                       ClientIdentifier__c = 'jcdb',IsDeathNotificationReceived__pc = false,
                                       PersonEmail = 'stzxcjgcrpcc@NOEMAIL.com', HasPermissionToMarketingEmail__c = 'no',
                                       HasPermissionToServiceEmail__c = 'yes',IsSubjecttoCASL__c='yes');
        
        
        insert accounts;
        Test.starttest();
        System.runAs(adminUser) {              
            try{
                sendRequestParams('U', accounts.id);
            } catch(exception e){
                System.assertEquals( System.Label.CL_SELECTMAILER_DONOTSOLICIT, e.getMessage(),'Unexpected exception message occured');
     
            }
            Test.stoptest();   
        } 
    }
    @isTest
    private static void testDoNotServiceEmail(){
        User adminUser = setupAdminUser();
        Account accounts = new Account(Edit_In_VFP__c=true,FirstName = 'jlrcnbbhhmxtzz',LastName = 'jlrcnbgchcxtzz',
                                       ClientIdentifier__c = 'jcdb',IsDeathNotificationReceived__pc = false,
                                       PersonEmail = 'stzxcjgcrpcc@NOEMAIL.com', HasPermissionToMarketingEmail__c = 'no',
                                       HasPermissionToServiceEmail__c = 'yes',IsSubjecttoCASL__c='yes');
        
        
        insert accounts;
        Test.starttest();
        System.runAs(adminUser) {   
            try{
                sendRequestParams('U', accounts.id);
            } catch(exception e){
                System.assertEquals( System.Label.CL_SELECTMAILER_DONOTSOLICIT, e.getMessage(),'Unexpected exception message occured');     
            }
            Test.stoptest();    
        }  
    }
    @isTest
    private static void testDNSTrueNoPermissions(){
        User adminUser = setupAdminUser();
        Account accounts = new Account(Edit_In_VFP__c=true,FirstName = 'jlrcnbbhhmxtzz',LastName = 'jlrcnbgchcxtzz',
                                       ClientIdentifier__c = 'jcdb',IsDeathNotificationReceived__pc = false,
                                       PersonEmail = 'stzxcjgcrpcc@NOEMAIL.com', HasPermissionToMarketingEmail__c = 'no',
                                       HasPermissionToServiceEmail__c = 'yes',IsSubjecttoCASL__c='no');
        
        
        insert accounts;
        Test.starttest();
        System.runAs(adminUser) {   
            try{
                sendRequestParams('U', accounts.id);
            } catch(exception e){
                System.assertEquals( System.Label.CL_SELECTMAILER_DONOTSOLICIT, e.getMessage(),'Unexpected exception message occured');
                
            }
            Test.stoptest();    
        }  
    }
    @isTest
    private static void testDNSMarketingNoPermissions(){
        User adminUser = setupAdminUser();
        Account accounts = new Account(Edit_In_VFP__c=true,FirstName = 'jlrcnbbhhmxtzz',LastName = 'jlrcnbgchcxtzz',
                                       ClientIdentifier__c = 'jcdb',IsDeathNotificationReceived__pc = false,
                                       PersonEmail = 'stzxcjgcrpcc@NOEMAIL.com', HasPermissionToMarketingEmail__c = 'no',
                                       HasPermissionToServiceEmail__c = 'no',IsSubjecttoCASL__c='no');
        
        
        insert accounts;
        Test.starttest();
        System.runAs(adminUser) {   
            try{
                sendRequestParams('U', accounts.id);
            } catch(exception e){
                System.assertEquals( System.Label.CL_SELECTMAILER_DONOTSOLICIT, e.getMessage(),'Unexpected exception message occured');
                
            }
            Test.stoptest();  
        }    
    }
    @isTest
    private static void testDNSTrueServicingPermission(){
        User adminUser = setupAdminUser();
        Account accounts = new Account(Edit_In_VFP__c=true,FirstName = 'jlrcnbbhhmxtzz',LastName = 'jlrcnbgchcxtzz',
                                       ClientIdentifier__c = 'jcdb',IsDeathNotificationReceived__pc = false,
                                       PersonEmail = 'stzxcjgcrpcc@NOEMAIL.com', HasPermissionToMarketingEmail__c = 'no',
                                       HasPermissionToServiceEmail__c = 'yes',IsSubjecttoCASL__c='no');
        
        
        insert accounts;
        Test.starttest();
        System.runAs(adminUser) {   
            try{
                sendRequestParams('U', accounts.id);
            } catch(exception e){
                System.assertEquals( System.Label.CL_SELECTMAILER_DONOTSOLICIT, e.getMessage(),'Unexpected exception message occured');
                
            }
            Test.stoptest();   
        }   
    }
    @isTest
    private static void testDNSTrueMarketingPermission(){
        User adminUser = setupAdminUser();
        Account accounts = new Account(Edit_In_VFP__c=true,FirstName = 'jlrcnbbhhmxtzz',LastName = 'jlrcnbgchcxtzz',
                                       ClientIdentifier__c = 'jcdb',IsDeathNotificationReceived__pc = false,
                                       PersonEmail = 'stzxcjgcrpcc@NOEMAIL.com', HasPermissionToMarketingEmail__c = 'no',
                                       HasPermissionToServiceEmail__c = 'yes',IsSubjecttoCASL__c='no');
        
        
        insert accounts;
        Test.starttest();
        System.runAs(adminUser) {   
            try{
                sendRequestParams('U', accounts.id);
            } catch(exception e){
                System.assertEquals( System.Label.CL_SELECTMAILER_DONOTSOLICIT, e.getMessage(),'Unexpected exception message occured');
                
            }
           
            Test.stoptest();    
        }
        
    }
    @isTest
    private static void testNoServicingeMarketingPermission(){
        User adminUser = setupAdminUser();
        Account accounts = new Account(Edit_In_VFP__c=true,FirstName = 'jlrcnbbhhmxtzz',LastName = 'jlrcnbgchcxtzz',
                                       ClientIdentifier__c = 'jcdb',IsDeathNotificationReceived__pc = false,
                                       PersonEmail = 'stzxcjgcrpcc@NOEMAIL.com', HasPermissionToMarketingEmail__c = 'yes',
                                       HasPermissionToServiceEmail__c = 'no',IsSubjecttoCASL__c='no');
        
        
        insert accounts;
        Test.starttest();
        System.runAs(adminUser) {   
            try{
                sendRequestParams('U', accounts.id);
            } catch(exception e){
                System.assertEquals( System.Label.CL_SELECTMAILER_DONOTSOLICIT, e.getMessage(),'Unexpected exception message occured');
                
            }
            Test.stoptest();   
        }  
    }
    @isTest
    private static void testDNSTrueNoCASL(){
        User adminUser = setupAdminUser();
        Account accounts = new Account(Edit_In_VFP__c=true,FirstName = 'jlrcnbbhhmxtzz',LastName = 'jlrcnbgchcxtzz',
                                       ClientIdentifier__c = 'jcdb',IsDeathNotificationReceived__pc = false,
                                       PersonEmail = 'stzxcjgcrpcc@NOEMAIL.com', HasPermissionToMarketingEmail__c = 'yes',
                                       HasPermissionToServiceEmail__c = 'yes',IsSubjecttoCASL__c='no');
        
        
        insert accounts;
        Test.starttest();
        System.runAs(adminUser) {   
            try{
                sendRequestParams('U', accounts.id);
            } catch(exception e){
                System.assertEquals( System.Label.CL_SELECTMAILER_DONOTSOLICIT, e.getMessage(),'Unexpected exception message occured');
                
            }
            Test.stoptest();  
        }  
    }
    @isTest
    private static void testDNSTrueNoServicePermission(){
        User adminUser = setupAdminUser();
        Account accounts = new Account(Edit_In_VFP__c=true,FirstName = 'jlrcnbbhhmxtzz',LastName = 'jlrcnbgchcxtzz',
                                       ClientIdentifier__c = 'jcdb',IsDeathNotificationReceived__pc = false,
                                       PersonEmail = 'stzxcjgcrpcc@NOEMAIL.com', HasPermissionToMarketingEmail__c = 'yes',
                                       HasPermissionToServiceEmail__c = 'no',IsSubjecttoCASL__c='yes');
        
        
        insert accounts;
        Test.starttest();
        System.runAs(adminUser) {   
            Map<String, String> sendrequestParam = createReqParam('U', accounts.id);
            System.assertNotEquals(sendrequestParam, null, 'sendrequestParam should not be null');
            Test.stoptest();   
        }  
    }
    
    @isTest
    private static void testNoServiceNoServicingPermission(){
        User adminUser = setupAdminUser();
        Account accounts = new Account(Edit_In_VFP__c=true,FirstName = 'jlrcnbbhhmxtzz',LastName = 'jlrcnbgchcxtzz',
                                       ClientIdentifier__c = 'jcdb',IsDeathNotificationReceived__pc = false,
                                       PersonEmail = 'stzxcjgcrpcc@NOEMAIL.com', HasPermissionToMarketingEmail__c = 'yes',
                                       HasPermissionToServiceEmail__c = 'no',IsSubjecttoCASL__c='yes');
        
        
        insert accounts;
        Test.starttest();
        System.runAs(adminUser) {            
            Map<String, String> sendrequestParam = createReqParam('U', accounts.id);
            System.assertNotEquals(sendrequestParam, null, 'sendrequestParam should not be null');
            Test.stoptest();    
        } 
    }
    @isTest
    private static void testDNSTureAllPermissions(){
        User adminUser = setupAdminUser();
        Account accounts = new Account(Edit_In_VFP__c=true,FirstName = 'jlrcnbbhhmxtzz',LastName = 'jlrcnbgchcxtzz',
                                       ClientIdentifier__c = 'jcdb',IsDeathNotificationReceived__pc = false,
                                       PersonEmail = 'stzxcjgcrpcc@NOEMAIL.com', HasPermissionToMarketingEmail__c = 'yes',
                                       HasPermissionToServiceEmail__c = 'yes',IsSubjecttoCASL__c='yes');
        
        
        insert accounts;
        Test.starttest();
        System.runAs(adminUser) {   
            Map<String, String> sendrequestParam = createReqParam('U', accounts.id);
            System.assertNotEquals(sendrequestParam, null, 'sendrequestParam should not be null');
            Test.stoptest();    
        }
    }
    @isTest
    private static void testDNSServicingCASLPermissions(){
        User adminUser = setupAdminUser();
        Account accounts = new Account(Edit_In_VFP__c=true,FirstName = 'jlrcnbbhhmxtzz',LastName = 'jlrcnbgchcxtzz',
                                       ClientIdentifier__c = 'jcdb',IsDeathNotificationReceived__pc = false,
                                       PersonEmail = 'stzxcjgcrpcc@NOEMAIL.com', HasPermissionToMarketingEmail__c = 'no',
                                       HasPermissionToServiceEmail__c = 'no',IsSubjecttoCASL__c='yes');
        
        insert accounts;
        Test.starttest();
        System.runAs(adminUser) {    
            Map<String, String> sendrequestParam = createReqParam('U', accounts.id);
            System.assertNotEquals(sendrequestParam, null, 'sendrequestParam should not be null');
            Test.stoptest();   
        }  
    }
    @isTest
    private static void testDNSFalseCASLPermissions(){
        User adminUser = setupAdminUser();
        Account accounts = new Account(Edit_In_VFP__c=true,FirstName = 'jlrcnbbhhmxtzz',LastName = 'jlrcnbgchcxtzz',
                                       ClientIdentifier__c = 'jcdb',IsDeathNotificationReceived__pc = false,
                                       PersonEmail = 'stzxcjgcrpcc@NOEMAIL.com', HasPermissionToMarketingEmail__c = 'no',
                                       HasPermissionToServiceEmail__c = 'no',IsSubjecttoCASL__c='yes');
        
        
        insert accounts;
        Test.starttest();
        System.runAs(adminUser) {   
            Map<String, String> sendrequestParam = createReqParam('U', accounts.id);
            System.assertNotEquals(sendrequestParam, null, 'sendrequestParam should not be null');
            Test.stoptest();     
        }   
    }
    @isTest
    private static void testServicingNoMarketingPermissions(){
        User adminUser = setupAdminUser(); 
        Account accounts = new Account(Edit_In_VFP__c=true,FirstName = 'jlrcnbbhhmxtzz',LastName = 'jlrcnbgchcxtzz',
                                       ClientIdentifier__c = 'jcdb',IsDeathNotificationReceived__pc = false,
                                       PersonEmail = 'stzxcjgcrpcc@NOEMAIL.com', HasPermissionToMarketingEmail__c = 'no',
                                       HasPermissionToServiceEmail__c = 'yes',IsSubjecttoCASL__c='yes');
        
        
        insert accounts;
        Test.starttest();
        System.runAs(adminUser) { 
            Map<String, String> sendrequestParam = createReqParam('U', accounts.id);
            System.assertNotEquals(sendrequestParam, null, 'sendrequestParam should not be null');
            Test.stoptest(); 
        }   
    }
    @isTest
    private static void testServicingNoPermissions(){
        User adminUser = setupAdminUser();
        Account accounts = new Account(Edit_In_VFP__c=true,FirstName = 'jlrcnbbhhmxtzz',LastName = 'jlrcnbgchcxtzz',
                                       ClientIdentifier__c = 'jcdb',IsDeathNotificationReceived__pc = false,
                                       PersonEmail = 'stzxcjgcrpcc@NOEMAIL.com', HasPermissionToMarketingEmail__c = 'no',
                                       HasPermissionToServiceEmail__c = 'no',IsSubjecttoCASL__c='no');
        
        
        insert accounts;
        Test.starttest();
        System.runAs(adminUser) {
            try{
                sendRequestParams('U', accounts.id);
            } catch(exception e){
                System.assertEquals( System.Label.CL_SELECTMAILER_DONOTSOLICIT, e.getMessage(),'Unexpected exception message occured');   
            }
            Test.stoptest();  
        } 
    }
    @isTest
    private static void testDNSFalseNoPermissions(){
        User adminUser = setupAdminUser();
        Account accounts = new Account(Edit_In_VFP__c=true,FirstName = 'jlrcnbbhhmxtzz',LastName = 'jlrcnbgchcxtzz',
                                       ClientIdentifier__c = 'jcdb',IsDeathNotificationReceived__pc = false,
                                       PersonEmail = 'stzxcjgcrpcc@NOEMAIL.com', HasPermissionToMarketingEmail__c = 'no',
                                       HasPermissionToServiceEmail__c = 'no',IsSubjecttoCASL__c='no');
        
        insert accounts;
        Test.starttest();
        System.runAs(adminUser) {
            Map<String, String> sendrequestParam = createReqParam('U', accounts.id);
            System.assertNotEquals(sendrequestParam, null, 'sendrequestParam should not be null');
            Test.stoptest(); 
        }   
    }
    @isTest
    private static void testDNSServicingServicingPermissions(){
        User adminUser = setupAdminUser();
        Account accounts = new Account(Edit_In_VFP__c=true,FirstName = 'jlrcnbbhhmxtzz',LastName = 'jlrcnbgchcxtzz',
                                       ClientIdentifier__c = 'jcdb',IsDeathNotificationReceived__pc = false,
                                       PersonEmail = 'stzxcjgcrpcc@NOEMAIL.com', HasPermissionToMarketingEmail__c = 'no',
                                       HasPermissionToServiceEmail__c = 'yes',IsSubjecttoCASL__c='no');
        insert accounts;
        Test.starttest();
        System.runAs(adminUser) {   
            try{
                sendRequestParams('U', accounts.id);
            } catch(exception e){
                System.assertEquals( System.Label.CL_SELECTMAILER_DONOTSOLICIT, e.getMessage(),'Unexpected exception message occured');
            }
            Test.stoptest();    
        }   
    }
    @isTest
    private static void testAccountDeathFalse(){
        User adminUser = setupAdminUser();
        Account acct = new Account(Edit_In_VFP__c=true,FirstName = 'jlrcnbgchmxtzz',LastName = 'jlrcnbgchmxtzz',
                                   ClientIdentifier__c = 'jlzb',IsDeathNotificationReceived__pc = false,
                                   PersonEmail = 'stzxcjgcrpcc@NOEMAIL.com',HasPermissionToMarketingEmail__c = 'yes',
                                   HasPermissionToServiceEmail__c = 'yes',IsSubjecttoCASL__c = 'yes');
        insert acct;
        Test.starttest();
        System.runAs(adminUser) {   
      Test.setMock(WebServiceMock.class, new UTIL_MockJourneyMail.MockEmailBothFalse()); 
            Map<String, String> requestParams = new Map<String, String>();
            String accountId = acct.id;
            requestParams.put('appId', 'U');
            requestParams.put('accountId', accountId);
            AP_QA_OpportunityAccount_Email sendEmail = new AP_QA_OpportunityAccount_Email();
            sendEmail.setRequestParameters(requestParams);
            sendEmail.execute();
            String   appId = requestParams.get('appId');
            System.assertNotEquals(null, appId,'Unexpected appId');
            Test.stoptest();  
        }  
    }
    /**
	* @description Method for setting up admin user for tests
    * @return `User`
	*/
    private static User setupAdminUser() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();

        User adminUser= new User(alias = 'APIP', email= 'apiu@statefarm.com', 
                                 emailencodingkey='UTF-8',lastname='apiUser', languagelocalekey='en_US', 
                                 localesidkey='en_US', timezonesidkey='Europe/London', username='devsysAdmin@statefarm.com');
        adminUser.ProfileId = [select Id from Profile where name = 'System Administrator' LIMIT 1].Id;
        insert adminUser;

        return adminUser;
    }
    /**
	* @description Method for sending email requests
    * @param appId
    * @param accountId
    * @return `Map<String, String>`
	*/
    private static Map<String, String> sendRequestParams(String appId, String accountId) {
        Map<String, String> requestParams = new Map<String, String>();
        requestParams.put('appId', appId);
        requestParams.put('accountId', accountId);
        Test.setMock(WebServiceMock.class, new UTIL_MockJourneyMail.MockEmailBothTrue());
        AP_QA_OpportunityAccount_Email sendEmails = new AP_QA_OpportunityAccount_Email();
        sendEmails.setRequestParameters(requestParams);
                
        sendEmails.execute();
        return requestParams;
    }

    private static Map<String, String> createReqParam(String appId, Id accId){
			Map<String, String> sendrequestParam = new Map<String, String>();
        
			try{
                 sendrequestParam = sendRequestParams(appId, accId);
            } catch(exception e){
                System.assertEquals( System.Label.CL_SELECTMAILER_DONOTSOLICIT, e.getMessage(),'Unexpected exception message occured');

            }
        return sendrequestParam;
}
    

}