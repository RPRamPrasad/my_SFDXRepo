/*
* Test class for Account Ownership handling when Accounts are inserted or updated. 
* Accounts inserted to always be assigned/owned by StateFarm System User.
* Account owners cannot be updated to any other user than StateFarm System user. 
*
*/
@isTest
(seeAllData = false)
public class AP_AccountTriggers_Test {   
    private static final Integer ACCOUNT_TEST_BATCH_SIZE = 200;
    private static User systemUser;
    private static User agentUser;
 	private static AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting;
    public static final String FSC_HOUSEHOLD_PERMISSION_SET_NAME ='SF_CRMDM_FSCHH_PermSetPID';
    private static User testFSCHHUser;
    public static final String HOUSEHOLD_RECORD_TYPE = 'IndustriesHousehold';
    private static CS_Household_Check_For_Sync_User__c triggerCheck;
    
    @TestSetup
    static void makeData(){
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser; 
        User testAgentUser1 = new User(Alias='alias',LastName='accOwner',Username='accOwnerAgent@statefarm.com',Associate_ID__c='123test',UserExternalID__c='123test123te',Servicing_Agent_Associate_ID__c='123test');
        User agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
        insert agentUser; 
        
        triggerCheck = new CS_Household_Check_For_Sync_User__c(Username__c = 'apiUser');
        insert triggerCheck;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        System.runAs(systemUser){
        CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false,systemUser);
        insert passTriggerAll;
        
        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemUser);
        objectBasedByPassTrigger.Override_AccountBeforeInsert__c = false;
        insert objectBasedByPassTrigger;
        
        sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemUser.id);            
        insert sysAdminUserIdSetting;
        
        
        }

        
    }
   /**
    * @description test account creation without a custom setting 
    */
    @isTest
    public static void testStateFarmUserSetting() {    
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where alias='SYSA' ];
        sysAdminUserIdSetting=[Select  Id From AccountOwnerSystemUserCustomSetting__c where SFDC_USER_ID__c=:systemUser.Id]; 
        delete sysAdminUserIdSetting;
        Account account  = new Account(firstname ='SSSHHHH', lastname='SSSSSHHHH', ClientIdentifier__c = 'SFFSP81L8XB');
        Test.startTest();
        try  {          
            insert account;
            system.assert(false, 'An Exception not through when StateFarm User Id custom setting not available');
        }catch(System.DmlException e) {
            system.assertEquals(true,!String.isBlank(e.getMessage()),'DML Execption');  
        }
        Test.stopTest();
    }

  /**
    * @description  test account creation assignment to StateFarm Account 
    *  name   testAccountInsert
    */
    @isTest
    public static void testAccountInsert() {
        
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where alias='SYSA' ];
        
        Account account  = new Account(firstname ='SSSHHHH', lastname='SSSSSHHHH', ClientIdentifier__c = 'SFFSP81L8XB', PersonBirthDate = date.newInstance(1990, 05, 17));
        
        Test.startTest();
        insert account;
        
        Account savedAccount = [select id, ownerId,ClientIdentifier__c, DOBString__c, (select ClientIdentifier__c from contacts ) from Account where id = :account.id]; 
        Contact savedContact =  savedAccount.contacts;    
        system.assertEquals(systemUser.Id,savedAccount.ownerId,'Accounts can only be owned by State Farm User');
        system.assertEquals(savedContact.ClientIdentifier__c,savedAccount.ClientIdentifier__c,'Account client id is not matched');
        system.assertEquals(savedAccount.DOBString__c,'1990-05-17','DOBString pattern is not matched');
        
        List<Account> bulkAccountsList = new List<Account>();
        Integer clientIdDelta = 700;
        for(Integer i = 0; i<=AP_AccountTriggers_Test.ACCOUNT_TEST_BATCH_SIZE;i++) {
            clientIdDelta = clientIdDelta + 1;
            Account bAccount  = new Account(firstname ='SSSHHHH', lastname='SSSSSHHHH', ClientIdentifier__c = '12345678' + clientIdDelta);
            bulkAccountsList.add(bAccount);
        }
        insert bulkAccountsList;
        
        bulkAccountsList = [select id, ownerId, ClientIdentifier__c,ClientIdentifier__pc from Account where clientidentifier__c LIKE '%12345678%'];
        for(Account bAccount: bulkAccountsList) {
            system.assertEquals(systemUser.Id,bAccount.ownerId,'Accounts can only be owned by State Farm User');
            system.assertEquals(bAccount.ClientIdentifier__pc,bAccount.ClientIdentifier__c,'Bulk - Account client id is not matched');          
        }
        Test.stopTest();
    }
    
    /**
    * @method test Household account creation with Household Name  
    * @name   testHouseHold Account
    * @description test method to insert HouseHold Account
    */
    @isTest
    public static void testHouseholdAccountInsert() {
        
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where alias='SYSA' ];
        testFSCHHUser = UTIL_UserProvisioning_TEST.buildUserWith103APIProfile();
        insert testFSCHHUser;
        PermissionSetAssignment psassignment = assignPSet(testFSCHHUser);
        insert psassignment;
        
        Account account  = new Account(name ='Household', recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId(), FinServ__SourceSystemId__c = '45678');
        
        Test.startTest();
        System.runAs(testFSCHHUser){
        insert account;
        }

        Account savedAccount = [select id, ownerId, Name, RecordTypeId from Account where id = :account.id];    
        system.assertEquals(account.Name,savedAccount.Name,'Household name should be same as given household');
        system.assertEquals(systemUser.Id,savedAccount.ownerId,'Household Account record can only be owned by State Farm User');
        system.assertEquals(Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId(), savedAccount.RecordTypeId,'Record type should be same as Houldhold Record Type' );
        Test.stopTest();
    }

     /**
    * @description test Household account creation with Household Name Bulkify
    * @name   testBulkifyHouseholdAccountInsert Account
    */
    @isTest
    public static void testBulkifyHouseholdAccountInsert() {
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where alias='SYSA' ];
        testFSCHHUser = UTIL_UserProvisioning_TEST.buildUserWith103APIProfile();
        insert testFSCHHUser;
        PermissionSetAssignment psassignment = assignPSet(testFSCHHUser);
        insert psassignment;
            List<Account> bulkHHAccountsList = new List<Account>();
        Integer sysSourceIdDelta = 200;
        for(Integer i = 0; i<=AP_AccountTriggers_Test.ACCOUNT_TEST_BATCH_SIZE;i++) {
            sysSourceIdDelta = sysSourceIdDelta + 1;
            Account hhAccount  = new Account( Name ='Household', recordTypeId=Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId(), FinServ__SourceSystemId__c = '45678'+sysSourceIdDelta);
            bulkHHAccountsList.add(hhAccount);
        }
        System.runAs(testFSCHHUser){
            insert bulkHHAccountsList;
        }
        
        
        bulkHHAccountsList = [select id, ownerId, Name, RecordTypeId from Account where Name ='Household'];
        for(Account householdAccount: bulkHHAccountsList) {
            system.assertEquals(systemUser.Id,householdAccount.ownerId,'Accounts can only be owned by State Farm User');
            system.assertEquals(Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId(),
                                householdAccount.RecordTypeId,'Bulk - Record Type should be same as HouseHold');          
        } 
    }
    /**
    * @description test account creation with HealthSourced assignment to StateFarm Account 
    * testAccountInsertWithHealthSourced
    */
    @isTest
    public static void testAccountInsertWithHealthSourced() {
        
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where alias='SYSA' ];
        
        Account account  = new Account(firstname ='FNAMEHOLDINGCODE', lastname='LNAMEHOLDINGCODE', ClientIdentifier__c = 'H0LD1NGC0D3', IsHealthSourced__pc=True);
        
        Test.startTest();
        insert account;
        
        Account savedAccount = [select id, ownerId,ClientIdentifier__c,Health_Restricted_Flag__c, (select ClientIdentifier__c, IsHealthSourced__c from contacts ) from Account where id = :account.id]; 
        Contact savedContact =  savedAccount.contacts;    
        system.assertEquals(systemUser.Id,savedAccount.ownerId,'Accounts can only be owned by State Farm User');
        system.assertEquals(savedContact.ClientIdentifier__c,savedAccount.ClientIdentifier__c,'Account client id is not matched');
        system.assertEquals(savedAccount.Health_Restricted_Flag__c,savedContact.IsHealthSourced__c,'HealthSource indicator is not matched');
        
        List<Account> bulkAccountsList = new List<Account>();
        Integer clientIdDelta = 700;
        for(Integer i = 0; i<=AP_AccountTriggers_Test.ACCOUNT_TEST_BATCH_SIZE;i++) {
            clientIdDelta = clientIdDelta + 1;
            Account bAccount  = new Account(firstname ='FNAMEHOLDINGCODE', lastname='LNAMEHOLDINGCODE', ClientIdentifier__c = '12345678' + clientIdDelta, IsHealthSourced__pc=True);
            bulkAccountsList.add(bAccount);
        }
        insert bulkAccountsList;
        
        bulkAccountsList = [select id, ownerId, ClientIdentifier__c,ClientIdentifier__pc, IsHealthSourced__pc,Health_Restricted_Flag__c from Account where clientidentifier__c LIKE '%12345678%'];
        for(Account bAccount: bulkAccountsList) {
            system.assertEquals(systemUser.Id,bAccount.ownerId,'Accounts can only be owned by State Farm User');
            system.assertEquals(bAccount.ClientIdentifier__pc,bAccount.ClientIdentifier__c,'Bulk - Account client id is not matched');    
            system.assertEquals(bAccount.Health_Restricted_Flag__c,bAccount.IsHealthSourced__pc,'HealthSource indicator is not matched'); 
        }
        Test.stopTest();
    }
    
    /**
    * @description test account creation without Client Id 
    * name - testAccountInsertWithNoClientId
    */
    @isTest
    public static void testAccountInsertWithNoClientId() {
        
        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where alias='SYSA' ];
       
        Account account  = new Account(firstname ='SSSHHHH', lastname='SSSSSHHHH');
        
        Test.startTest();
       try  {          
            insert account;
        }catch(System.DmlException e) {
            system.assert(!String.isBlank(e.getMessage()),'DML Exception');
            system.assert(e.getMessage().contains(System.Label.CL_ErrorMsgForAccInsertWithoutClientId),'ClientId id is missing in account record');  
        }
        
        Account account2  = new Account(firstname ='HHHHSSSS', lastname='HHHHSSSSS', clientIdentifier__c='SFFSP81L8XB');
        List<Account> accList = new List<Account>{account, account2};
        
        Database.SaveResult[] srList = Database.insert(accList, false);
        Account savedAccount = [select id, firstname, ownerId, ClientIdentifier__c, (select ClientIdentifier__c from contacts ) from Account where clientIdentifier__c='SFFSP81L8XB'];
        for(Database.SaveResult sr: srList){
            if(sr.isSuccess()){        
                Contact savedContact =  savedAccount.contacts;
                system.assertEquals(account2.firstname, savedAccount.firstname,'Account2 is not matched');    
                system.assertEquals(systemUser.Id,savedAccount.ownerId,'Accounts can only be owned by State Farm User');
                system.assertEquals(savedContact.ClientIdentifier__c,savedAccount.ClientIdentifier__c,'ClientId id is matched in account2 record'); 
            }
            else {
                system.assert(sr.getErrors().get(0).getMessage().contains(System.Label.CL_ErrorMsgForAccInsertWithoutClientId),'Missing ClientID');
            }
        }
        
        Test.stopTest();
    }
    
    /**
    * @description test account creation assignment to StateFarm Account 
    * name   testAccountUpdate
    */
    @isTest
    public static void testAccountUpdate() {
        List<User> usrlist=[SELECT Id, Alias,Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where alias='SYSA' or UserExternalID__c='123test123te' ];
        for(User profileusrs:usrlist)
        {	if(profileusrs.alias=='SYSA'){
            systemUser=profileusrs;
                }
         	else {
            agentUser=profileusrs;
                }
        }
        

        Account account  = new Account(firstname ='SSSHHHH', lastname='SSSSSHHHH', ClientIdentifier__c = 'SFFSP81L8XB');
        insert account;
        
        Account savedAccount = [select id, ownerId from Account where id = :account.id];        
        
        Test.startTest();     
        savedAccount.ownerId = agentUser.id;            
        try { 
            update savedAccount;
        }catch(System.DMLException e) {
            system.assertEquals(true,!String.isBlank(e.getMessage()),'DML Exception');
        }
         
        Account queryAccountAgain = [select id, ownerId from Account where id = :account.id];                
        system.assertEquals(systemUser.Id,queryAccountAgain.ownerId,'Accounts can only be owned by State Farm User');
        
        List<Account> bulkAccountsList = new List<Account>();
        Integer clientIdDelta = 700;
        for(Integer i = 0; i<=ACCOUNT_TEST_BATCH_SIZE;i++) {
            clientIdDelta = clientIdDelta + 1;
            Account bAccount  = new Account(firstname ='SSSHHHH', lastname='SSSSSHHHH', ClientIdentifier__c = '12345678' + clientIdDelta);
            bulkAccountsList.add(bAccount);
        }
        insert bulkAccountsList;
        
        bulkAccountsList = [select id, ownerId from Account];
        for(Account bAccount: bulkAccountsList) {
            system.assertEquals(systemUser.Id,bAccount.ownerId,'Accounts can only be owned by State Farm User');
            bAccount.ownerId = agentUser.id;            
        }
        
        Account successAccountInMix = new Account(firstname ='SSSHHHH', lastname='SSSSSHHHH', ClientIdentifier__c = 'SFFSP81L8XA');
        insert successAccountInMix;
        
        bulkAccountsList.add(successAccountInMix);
        
        List<Database.SaveResult> updateResults = Database.update(bulkAccountsList, false);
        for(Database.SaveResult updateResult: updateResults) {
            if(updateResult.id!=successAccountInMix.id) {
                system.assertEquals(false, updateResult.isSuccess(),'Accounts are not updated successfully');
            }else {
                system.assertEquals(true, updateResult.isSuccess(),'Accounts are not updated successfully');
            }
        }
        
        Account acnt = new Account(firstname ='SSSHHHH', lastname='SSSSSHHHH', ClientIdentifier__c = 'SFFSP81LCID', PersonBirthDate = date.newInstance(1990, 06, 17));
        insert acnt;
        
        Account savedAcnt = [select id, PersonBirthDate, DOBString__c from Account where id = :acnt.id];
        savedAcnt.PersonBirthdate = date.newInstance(1990, 05, 29);
        update savedAcnt;
        
        Account queryAcnt = [select id, DOBString__c from Account where id = :acnt.id];                
        system.assertEquals(queryAcnt.DOBString__c,'1990-05-29','DOBString__c pattern is not matched');
        Test.stopTest();       
    }  

    /**
    * @description test account update for HAART user to StateFarm Account 
    * name   testAccountUpdateForHaart
    */
    @isTest
    public static void testAccountUpdateForHaart() {
        
                List<User> usrlist=[SELECT Id, Alias,Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where alias='SYSA' or UserExternalID__c='123test123te' ];
        for(User profileusrs:usrlist)
        {	if(profileusrs.alias=='SYSA'){
            systemUser=profileusrs;
                }
         	else {
            agentUser=profileusrs;
                }
        }
        

        Account account  = new Account(firstname ='SSSHHHH', lastname='SSSSSHHHH', ClientIdentifier__c = 'SFFSP81L8XB');
        insert account;
        
        Account savedAccount = [select id, ownerId from Account where id = :account.id];        
        
        Test.startTest();     
        savedAccount.ownerId = agentUser.id;  
        AP_AccountTrigger.iAmTrustworthy = true;          
        try { 
            update savedAccount;
        }catch(System.DMLException e) {
            system.assertEquals(true,!String.isBlank(e.getMessage()),'DML Exception');
        }
         
        Account queryAccountAgain = [select id, ownerId from Account where id = :account.id];                
        system.assertEquals(systemUser.Id,queryAccountAgain.ownerId,'Accounts can only be owned by State Farm User');
         
        Test.stopTest();       
    }  
    
        /**
    * @description test account update with HealthSourced assignment to StateFarm Account 
    * name   testAccountUpdateWithHealthSourced
    */
    @isTest
    public static void testAccountUpdateWithHealthSourced() {
        
    
                List<User> usrlist=[SELECT Id, Alias,Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where alias='SYSA' or UserExternalID__c='123test123te' ];
        for(User profileusrs:usrlist)
        {	if(profileusrs.alias=='SYSA'){
            systemUser=profileusrs;
                }
         	else {
            agentUser=profileusrs;
                }
        }
        
        
        Account account  = new Account(firstname ='FNAMEHOLDINGCODE', lastname='LNAMEHOLDINGCODE', ClientIdentifier__c = 'H0LD1NGC0D3');
        insert account;
        
        Account savedAccount = [select id, ownerId from Account where id = :account.id];        
        

        Test.startTest();     
        savedAccount.ownerId = agentUser.id;            
        try { 
            update savedAccount;
        }catch(System.DMLException e) {
            system.assertEquals(true,!String.isBlank(e.getMessage()),'DML Exception');
        }
         
        Account queryAccountAgain = [select id, ownerId from Account where id = :account.id];                
        system.assertEquals(systemUser.Id,queryAccountAgain.ownerId,'Accounts can only be owned by State Farm User');
        
        List<Account> bulkAccountsList = new List<Account>();
        Integer clientIdDelta = 700;
        for(Integer i = 0; i<=ACCOUNT_TEST_BATCH_SIZE;i++) {
            clientIdDelta = clientIdDelta + 1;
            Account bAccount  = new Account(firstname ='FNAMEHOLDINGCODE'+i, lastname='LNAMEHOLDINGCODE'+i, ClientIdentifier__c = '12345678' + clientIdDelta);
            bulkAccountsList.add(bAccount);
        }
        insert bulkAccountsList;
        
        bulkAccountsList = [select id, ownerId from Account];
        for(Account bAccount: bulkAccountsList) {
            system.assertEquals(systemUser.Id,bAccount.ownerId,'Accounts can only be owned by State Farm User');
            bAccount.ownerId = agentUser.id;            
        }
        
        Account successAccountInMix = new Account(firstname ='FNAMEHOLDINGCODE', lastname='FNAMEHOLDINGCODE', ClientIdentifier__c = 'H0LDINGC0DE', IsHealthSourced__pc=false);
        insert successAccountInMix;
        successAccountInMix.IsHealthSourced__pc=true;
        bulkAccountsList.add(successAccountInMix);    
       
        List<Database.SaveResult> updateResults = Database.update(bulkAccountsList, false);
        for(Database.SaveResult updateResult: updateResults) {
            if(updateResult.id!=successAccountInMix.id) {
                system.assertEquals(false, updateResult.isSuccess(),'Account is not updated successfully');
            }else {
                system.assertEquals(true, updateResult.isSuccess(),'Account is not updated successfully');
            }
        }
        
        Account savedHoldingCodeAccount = [SELECT Id, IsHealthSourced__pc, Health_Restricted_Flag__c from Account Where ClientIdentifier__c='H0LDINGC0DE'];
        system.assertEquals(savedHoldingCodeAccount.Health_Restricted_Flag__c,savedHoldingCodeAccount.IsHealthSourced__pc,'HealthSource flag is not matched');
        //system.assertEquals(true, savedHoldingCodeAccount.Health_Restricted_Flag__c);
        Test.stopTest();       
    }  
    /**
    * @description test account after updates  
    * Method name   handleAccountsAfterUpdateTest
    */
    @isTest
    public static void handleAccountsAfterUpdateTest() {
        
        AP_AccountTrigger accountTrigger = new AP_AccountTrigger();
        BDD_User_StepDefinitions userStepDefinitions = new BDD_User_StepDefinitions();

        
        

        List<Account> newAccounts = new List<Account>();
        Map<Id,Account> oldAccounts = new Map<Id,Account>();
        userStepDefinitions.givenAnUserSalesHierarchy();
        userStepDefinitions.givenAgentWithClickToDialPreferenceAs(userStepDefinitions.SalesUserHierarchy.Agent, '7', true);
        
        
        Campaign campaign;
        CampaignMember campaignMember;
        
        Account account = TestDataFactory_Account.createIndividualCustomer('Alex Cat');
        TestDataFactory_Account.byPassAccountBeforeTrigger();
        account = TestDataFactory_Account.insertAccount(account);
   
        
        campaign = TestDataFactory_Campaign.generateCampaign();
        campaign.OwnerId = userStepDefinitions.SalesUserHierarchy.AgentOffice.Id;
        campaign = TestDataFactory_Campaign.insertCampaign(campaign);
        
        Contact contact = [Select id from Contact where accountId = :account.id];

        systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, SubUserType__c FROM User where alias='SYSA' ];

        CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = CS001_ByPassTriggerAtoF__c.getInstance();
        objectBasedByPassTrigger.Override_CampaignMemberBeforeInsert__c = true;
        update objectBasedByPassTrigger;

        campaignMember = TestDataFactory_CampaignMember.generateCampaignMember(campaign,contact);
        campaignMember = TestDataFactory_CampaignMember.insertCampaignMember(campaignMember);
        campaignMember = [select Id,Status__c from CampaignMember where Id=:campaignMember.Id];
        List<Account> accounts = [SELECT id, personcontactid,personhomephone,personmobilephone from account where id= :account.id];
        accounts.get(0).PersonHomePhone = '1234567890';
        accounts.get(0).PersonMobilePhone = '1234567890';
        newAccounts.add(accounts.get(0));
        update newAccounts;
        Account priorAccount = new Account();
        priorAccount.Id =account.id;
        oldAccounts.put(priorAccount.Id, priorAccount);
        accountTrigger.handleAccountsAfterUpdate(newAccounts,oldAccounts);

         
        campaignMember = [select Id,Status__c from CampaignMember where Id=:campaignMember.Id];
        system.assertEquals('Not Contacted',campaignMember.Status__c,'CampaignMember status is not matched');
    }
     /**      
      * @Method: assignPSet <This method is used to get Standard testUser>
      * @description This method is used for assign a particular PermissionSet to a particular User
      * @param testUser
      * @return PermissionSetAssignment
      */     
    public static PermissionSetAssignment assignPSet (User testUser){
        PermissionSet ps = [Select Id, Name FROM PermissionSet WHERE Name=:FSC_HOUSEHOLD_PERMISSION_SET_NAME];
         return new PermissionSetAssignment(AssigneeId=testUser.Id,PermissionSetId=ps.Id);
    }
}