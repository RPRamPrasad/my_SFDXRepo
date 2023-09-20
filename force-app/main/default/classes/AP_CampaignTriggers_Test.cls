/* @Description:This is a test class for Campaign Trigger apex class.
 * @Author: Team ITIC.
 **Team TGV - Updated Test class to remove all references to Message Orchestration as per feature E-26062 (6-20-2017).
 **Team Dream Builders - added test method for prevent delete
*/
@isTest
(seeAllData = false)

public class AP_CampaignTriggers_Test {
   public static Map<String, Schema.Recordtypeinfo> campaignRecordTypeMap = Schema.Sobjecttype.Campaign.getRecordTypeInfosByName(); 
    /**
    * @method Setup method used for building test data 
    * @name   setUp
    * @description testSetupData
    */
    @testsetup
    public static void testSetupData() {
        
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser; 
        
        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=false);
        insert passTriggerAll;
        
        CS001_ByPassTriggerAtoF__c campaignByPassTrigger = new CS001_ByPassTriggerAtoF__c(Override_CampaignBeforeInsert__c=false);
        insert campaignByPassTrigger;     
        
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
        insert sysAdminUserIdSetting;  
 
    }
    
    /**
    * @method Test ByPass custom settings ON does not assign campaign to Proxy. 
    * @description  testByPassCustomSettings
    */
    @isTest
    public static void testByPassCustomSettings() {      
    CS001_ByPassTriggerAll__c passTriggerAll = [select Override_All__c from CS001_ByPassTriggerAll__c];
    passTriggerAll.Override_All__c = true;
    update passTriggerAll;
    
    User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
    insert systemAdmin;
    Campaign byPassedAllCampaignCreation;
    system.runAs(systemAdmin) {
    try {
    byPassedAllCampaignCreation= new Campaign(Name = 'TestCampaignByPassAll');  
    insert byPassedAllCampaignCreation; 
    }catch(Exception e){
         System.assert(e.getMessage().contains('Insert failed'),'Exception message should contain \'Insert failed\'');
    }
    byPassedAllCampaignCreation = [select id, ownerId from Campaign where Name = 'TestCampaignByPassAll']; 
    system.assertEquals(systemAdmin.id, byPassedAllCampaignCreation.ownerId,'Expected Owner Id is'+systemAdmin.id+', but actual value is'+byPassedAllCampaignCreation.ownerId);
    }
    
    passTriggerAll.Override_All__c = false;
    update passTriggerAll;
    
    CS001_ByPassTriggerAtoF__c campaignByPassTrigger = [select Override_CampaignBeforeInsert__c from CS001_ByPassTriggerAtoF__c];
    campaignByPassTrigger.Override_CampaignBeforeInsert__c = true;
    update campaignByPassTrigger;
    
    Campaign byPassedCampaignCreation;
    system.runAs(systemAdmin) {
    try {
    byPassedCampaignCreation = new Campaign(Name = 'TestCampaignByPassCampaign');   
    insert byPassedCampaignCreation;    
    }catch(Exception e){
        System.assert(e.getMessage().contains('Insert failed'),'Exception message should contain \'Insert failed\'');
    }
    byPassedCampaignCreation = [select id, ownerId from Campaign where Name = 'TestCampaignByPassCampaign']; 
    system.assertEquals(systemAdmin.id, byPassedCampaignCreation.ownerId,'Expected Owner Id is'+systemAdmin.id+', but actual value is'+byPassedCampaignCreation.ownerId);
    }
    }
    
    
    /**
    * @method Test Campaign Insert by Agent appropriately sets owner to Proxy when custom settings is OFF. 
    * @description   testCampaignInsertByAgent
    */   
    @isTest
    public static void testCampaignInsertByAgent() {    
        User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com'); 
        insert systemAdmin;
        UserRole agentStandardUserRole;
        UserRole proxyStandardUserRole;
        System.runAs(systemAdmin) {
            agentStandardUserRole = new UserRole(name='AgentRole');                    
            insert agentStandardUserRole; 
            proxyStandardUserRole = new UserRole(name='ProxyRole', parentRoleId = agentStandardUserRole.id);
            insert proxyStandardUserRole;       
        }
        User agentUser;
        User agentUserwithoutProxy;
        User proxyUser;       
        System.runAs(systemAdmin) {
            User testAgentUser1 = new User(Alias='alias',LastName='accOwner',Username='accOwnerAgent@statefarm.com',Associate_ID__c='123test',UserExternalID__c='123test12345',Servicing_Agent_Associate_ID__c='123test');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
            agentUser.userRoleId= agentStandardUserRole.id;
            insert agentUser;   
            testAgentUser1 = new User(Alias='alias',LastName='accOwner',Username='accOwnerAgent1@statefarm.com',Associate_ID__c='124test',UserExternalID__c='124test12345',Servicing_Agent_Associate_ID__c='124test'); 
            agentUserwithoutProxy = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
            insert agentUserwithoutProxy;            
            Campaign errorCampaign= new Campaign(Name = 'TestCampaign');
            insert errorCampaign;
            Campaign queryCmp = [Select id, OwnerId from Campaign where createdbyId =:systemAdmin.Id];
            system.assertEquals(queryCmp.OwnerId,systemAdmin.Id,'Campaign ownership to Sysadmin failed');
        }    
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser, agentUserwithoutProxy});
        system.runAs(agentUser) {
            String error;                               
            try {
                Campaign errorCampaign= new Campaign(Name = 'TestCampaign');
                insert errorCampaign;
            }
            catch(System.DMLException e) {
                error = e.getMessage();
            }
            system.assertEquals(false,String.isBlank(error),'Exception path for Campaign creation without Proxy failed');
        }
        system.runAs(agentUserwithoutProxy) {
            String error;                               
            try {
                Campaign errorCampaign= new Campaign(Name = 'TestCampaign1');
                insert errorCampaign;
            }
            catch(System.DMLException e) {
                error = e.getMessage();
            }
            system.assertEquals(false,String.isBlank(error),'Exception path for Campaign creation with No Proxy User');
        }        
        system.runAs(systemAdmin) {
            User testProxyUser1 = new User(Alias='Proxy',LastName='ProxyAccOwner',Username='proxyAgent@statefarm.com',UserExternalID__c='123testP',Servicing_Agent_Associate_ID__c='123test');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId= proxyStandardUserRole.id;
            ProxyUser.UserExternalID__c='abc123p'; 
            insert proxyUser;            
            agentUser.Servicing_Agent_Associate_ID__c='abc123'; 
            update agentUser;
        }               
        system.runAs(agentUser) {
            Campaign campaignObj= new Campaign(Name='CampaignTest');
            insert campaignObj;                   
            Campaign saveCampaign= [select id , ownerId from Campaign where id  = : campaignObj.id];                   
            system.assertEquals(proxyUser.id, saveCampaign.ownerId,'Expected Id is'+proxyUser.id+', but actual Id is'+saveCampaign.ownerId);
        }
    } 
  /**
   * @description testCampaignDeleteLocked
   */
    @isTest
    public static void testCampaignDeleteLocked() {
    User systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        UserRole agentStandardUserRole;
        UserRole proxyStandardUserRole;
        System.runAs(systemAdmin) {
            agentStandardUserRole = new UserRole(name='AgentRole');                    
            insert agentStandardUserRole;
            proxyStandardUserRole = new UserRole(name='ProxyRole', parentRoleId = agentStandardUserRole.id);
            insert proxyStandardUserRole;       
        }
        User agentUser;
        User proxyUser;
        System.runAs(systemAdmin) {
            User testAgentUser1 = new User(Alias='alias',LastName='accOwner',Username='accOwnerAgent@statefarm.com',Associate_ID__c='123test',UserExternalID__c='123test123te',Servicing_Agent_Associate_ID__c='123test');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
            agentUser.userRoleId= agentStandardUserRole.id;
            Insert agentUser;
        }
        system.runAs(systemAdmin) {
            User testProxyUser1 = new User(Alias='Proxy',LastName='ProxyAccOwner',Username='proxyAgent@statefarm.com',UserExternalID__c='123testP',Servicing_Agent_Associate_ID__c='123test');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId= proxyStandardUserRole.id;
            ProxyUser.UserExternalID__c='abc123p';
            insert ProxyUser;
            agentUser.Servicing_Agent_Associate_ID__c='abc123'; 
            update agentUser;
        }
        User testAgentUser1 = new User(Alias='alias2',LastName='accOwner2',Username='accOwnerAgent2@statefarm.com',Associate_ID__c='123test2',UserExternalID__c='123test2123t',Servicing_Agent_Associate_ID__c='123test2');
        User agentUser2 = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
        insert agentUser2;
        Campaign cmp;
		TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);        
        system.runAs(agentUser) {
    	cmp= new Campaign(Name = 'TestCampaignByPassAll', LockedCmp__c = 'Yes');  
    	insert cmp;   
        
        try{
            delete cmp;
        }catch(Exception ex){
            System.assert((ex.getMessage()).contains(UTIL_Constants.ERROR_MESSAGE_LOCKED_CAMPAIGN),'Exception message should contain the String passed as parameter');
        }
    }
    }
/**
 * @description testCampaignExpirationDateFieldsPopulated
 */
    // testmethod to verify expiration date fields are populated with given End date 
    @isTest
    public static void testCampaignExpirationDateFieldsPopulated(){
    User agentUser;
    User proxyUser;
    
    UTIL_UserProvisioning_TEST.setUpAgentUser(1);
    agentUser = UTIL_UserProvisioning_TEST.getAgentUser(1);
    proxyUser = UTIL_UserProvisioning_TEST.getAgentProxyUser(1);

    Campaign customerProsectCampaign = TestDataFactory_Campaign.buildCampaignRecord(campaignRecordTypeMap.get('Customer/Prospect Campaign').RecordTypeId, proxyUser.id);
    TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser); 
        System.runAs(agentUser){
        Test.startTest();
            customerProsectCampaign.EndDate = Date.today().addDays(30);
            insert customerProsectCampaign;
        Test.stopTest();
        Campaign campaignAfterInsert = [Select id, OriginalExpirationDate__c,enddate,HardExpirationDate__c from Campaign where id=:customerProsectCampaign.id ];
        System.assertEquals(campaignAfterInsert.EndDate, campaignAfterInsert.OriginalExpirationDate__c,'Expected Expiration Date is'+campaignAfterInsert.EndDate+', but actual is'+campaignAfterInsert.OriginalExpirationDate__c);
        System.assertEquals(campaignAfterInsert.HardExpirationDate__c, campaignAfterInsert.EndDate.addYears(1),'Expected End Date is'+campaignAfterInsert.HardExpirationDate__c+', but actual value is'+campaignAfterInsert.EndDate.addYears(1));
        }
    }
/**
 * @description testCampaignExpirationDateFieldsNoEndDate
 */
// testmethod to verify expiration date fields are populated with no End date 
    @isTest
    public static void testCampaignExpirationDateFieldsNoEndDate(){
    User agentUser;
    User proxyUser;
    Date expectedHardExpiryDate;
    
    UTIL_UserProvisioning_TEST.setUpAgentUser(1);
    agentUser = UTIL_UserProvisioning_TEST.getAgentUser(1);
    proxyUser = UTIL_UserProvisioning_TEST.getAgentProxyUser(1);

    Campaign customerProsectCampaign = TestDataFactory_Campaign.buildCampaignRecord(campaignRecordTypeMap.get('Customer/Prospect Campaign').RecordTypeId, proxyUser.id);

    Test.startTest();
    TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser); 
    System.runAs(agentUser){
        insert customerProsectCampaign;
        expectedHardExpiryDate = Date.today().addYears(1);
    }
    Test.stopTest();
    Campaign campaignAfterInsert = [Select id, OriginalExpirationDate__c,enddate,HardExpirationDate__c from Campaign where id=:customerProsectCampaign.id ];
    System.assertEquals(null, campaignAfterInsert.OriginalExpirationDate__c,'Expected Expiration Date is null , but actual is'+campaignAfterInsert.OriginalExpirationDate__c);
    System.assertEquals(campaignAfterInsert.HardExpirationDate__c, expectedHardExpiryDate,'Expected Expiry Date is'+campaignAfterInsert.HardExpirationDate__c+', but actual value is'+expectedHardExpiryDate);
    }
}