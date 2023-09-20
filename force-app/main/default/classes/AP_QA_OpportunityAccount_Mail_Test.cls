/**
* @description AP_QA_OpportunityAccount_Mail_Test
*/
@isTest(seeAllData=false)

public class AP_QA_OpportunityAccount_Mail_Test {

    /**
	* @description Setup method used for building test data (must be called at beginning of test)
	*/
    @testsetup
    public static void testSetupData() {
        User systemUser =  new User(alias = 'SYSA', email='noaccessTest@statefarm.com.bad', 
        emailencodingkey='UTF-8', lastname='TestSysRecOwner', languagelocalekey='en_US', 
        localesidkey='en_US', timezonesidkey='Europe/London', username= 'sysAccRecOwner@test.com');
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
        
    }
    @isTest
    private static void testDeathNotificationisTrue(){
        
        User systemAdmin= new User(alias = 'SYSA', email='SYSA@statefarm.com', 
        emailencodingkey='UTF-8', lastname='sysAdmUser', languagelocalekey='en_US', 
        localesidkey='en_US', timezonesidkey='Europe/London', username= 'SYSA@statefarm.com');
        
        systemAdmin.ProfileId = [select Id from Profile where name = 'System Administrator' LIMIT 1].Id;
        insert systemAdmin;
    
        User adminUser= new User(alias = 'APIP', email= 'apiu@statefarm.com', 
        emailencodingkey='UTF-8',lastname='apiUser', languagelocalekey='en_US', 
        localesidkey='en_US', timezonesidkey='Europe/London', username='devsysAdmin@statefarm.com');
        adminUser.ProfileId = [select Id from Profile where name = 'System Administrator' LIMIT 1].Id;
        insert adminUser;
		UTIL_SetFSCCustomSettings_TEST.setFSCSettings(systemAdmin); 
            Account account = new Account();
        	account.Edit_In_VFP__c=true;
            account.FirstName = 'jlrcnbgchmxtxb';
            account.LastName = 'jlrcnbgchmxtxb';
            account.ClientIdentifier__c = 'jssc'; 
            account.IsDeathNotificationReceived__pc = true;
            insert account;
            Test.starttest();
   
            System.runAs(systemAdmin) {
          
            Map<String, String> requestParams = new Map<String, String>();
            String accountId = account.id;
            requestParams.put('accountId', accountId);
            
            Try{
             
            AP_QA_OpportunityAccount_Mail sendMail = new AP_QA_OpportunityAccount_Mail();
            sendMail.setRequestParameters(requestParams);
            sendMail.execute();
            
            }catch(LinkBuilderController.LinkException e){ 
              
               System.assertEquals(System.Label.CL_SELECTMAILER_CLIENT_DECEASED, e.getMessage(),'Messages are not matched');
            
            } 
        }
        
    }
    @isTest
    private static void testAccountDeathFalse(){
        
        User systemAdmin= new User(alias = 'SYSA', email='SYSA@statefarm.com', 
        emailencodingkey='UTF-8', lastname='sysAdmUser', languagelocalekey='en_US', 
        localesidkey='en_US', timezonesidkey='Europe/London', username= 'SYSA@statefarm.com');
        
        systemAdmin.ProfileId = [select Id from Profile where name = 'System Administrator' LIMIT 1].Id;
        insert systemAdmin;
        Test.starttest(); 
        System.runAs(systemAdmin) {
            
			UTIL_SetFSCCustomSettings_TEST.setFSCSettings(); 
            Account acct = new Account();
            acct.Edit_In_VFP__c=true;
            acct.FirstName = 'jlrcnbgchmxtzz';
            acct.LastName = 'jlrcnbgchmxtzz';
            acct.ClientIdentifier__c = 'jlzb'; 
            acct.IsDeathNotificationReceived__pc = false;
            insert acct;
 
            
            Map<String, String> requestParams = new Map<String, String>();
            String accountId = acct.id;
            requestParams.put('appId', 'G');
            requestParams.put('accountId', accountId);
            
            
          
            
           AP_QA_OpportunityAccount_Mail sendMail = new AP_QA_OpportunityAccount_Mail();
           sendMail.setRequestParameters(requestParams);
           sendMail.execute();
           String appId = requestParams.get('appId');
           System.assertNotEquals(null, appId,'Unexpected appId');
           Test.stoptest(); 
            
        }
        
    }
    
}