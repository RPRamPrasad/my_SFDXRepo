@isTest(seeAllData = false)
public class Batch_UpdateOppStagemanagement_Test {
     private static User sysAdminuser;
    public static User agentUser;
    private static User systemUser;
    private static User proxyUser;
    private static UserRole agentStandardUserRole;
    private static UserRole proxyStandardUserRole;
    private static UserRole agentTeamMemberUserRole;
    private static Account testAccount;
    private static  User procIDUser;
    private static Map<String, Schema.Recordtypeinfo> opportunityRecordTypeMap = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName();

    
    /**
     * @description testSetUpData
     */
   @TestSetup
    public static void testSetUpData(){
         String apiDataUserProfileId = getProfileId(UTIL_Constants.API_DATA_USER_ADMIN);
        systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();  
        insert systemUser;
        sysAdminuser= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert sysAdminuser;
       CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c(Override_All__c= false);
        insert objectBasedByPassTrigger;
        CS001_ByPassTriggerAtoF__c accountByPassTrigger= new CS001_ByPassTriggerAtoF__c(Override_AccountBeforeInsert__c=false,Override_AgentRoleAfterInsert__c=false);
        insert accountByPassTrigger;
        System.runAs(sysAdminUser){
              procIDUser = createUser(buildUser('TestUser6@sfa.com', apiDataUserProfileId));
            assignPermissionSet(procIDUser, 'SF_CRM_OpportunityAutoClose_PermSetPID');
            agentStandardUserRole= new UserRole(name='AgentRole');                    
            insert agentStandardUserRole;
             AgentTeamMemberUserRole = new UserRole(name= 'AgentTeamMemberRole', parentRoleId = agentStandardUserRole.id);
            insert AgentTeamMemberUserRole;
         proxyStandardUserRole = new UserRole(name='ProxyRole', parentRoleId = AgentTeamMemberUserRole.id);
            insert proxyStandardUserRole;
            User testProxyUser1 = new User(Alias='Prox',LastName='opportunityAg',Username='TestProxUserForOppTst11@statefarm.com',UserExternalID__c='123testP',Servicing_Agent_Associate_ID__c='123test');
         proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId= proxyStandardUserRole.id;
            Database.insert(proxyUser);
            User testAgentUser1 = new User(Alias='Alia',LastName='opportunityProxy',Username='TestAgtUserForOppTst11@statefarm.com',Associate_ID__c='123test',UserExternalID__c='123test',Servicing_Agent_Associate_ID__c='123test');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
            agentUser.userRoleId= agentStandardUserRole.id;
            Database.insert(agentUser);
            
            TestDataFactory_Account.byPassAccountBeforeTrigger();
            TestDataFactory_Opportunity.byPassOpportunityBeforeTrigger();  
             System.runAs(agentUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            Account act = buildAccountRecord('WCMGF8RBPXA');
            TestDataFactory_Account.byPassAccountBeforeTrigger();
            insert act;             
                  testAccount = [select id, ownerId,clientidentifier__c from Account where id =:act.id];
            Account act1 = buildAccountRecord('WCMGF8RBPXB');
            TestDataFactory_Account.byPassAccountBeforeTrigger();
            insert act1;    
            AgentRole__c newAgentRole1 = buildAgentRoleRecord(act1.id,agentUser.id );
            insert newAgentRole1;          
        }
           
        
        AgentRole__c newAgentRole = buildAgentRoleRecord(testAccount.id,agentUser.id );
        insert newAgentRole; 
 
        }
    }
     private static Account buildAccountRecord(String paramclientIdentifier) {
        return new Account(FirstName = 'rrrrr', LastName = 'tttttttt', ClientIdentifier__c = paramclientIdentifier);   
    }
     private static AgentRole__c buildAgentRoleRecord(String paramaccountId, String agentId) {
        return new AgentRole__c (RelationshipNature__c = 'Customer',
                       Agent__c = agentId, Customer__c = paramaccountId);
    }

    private static InsurancePolicy insertInsurancePolicyData(Account account,User agentUser){
        InsurancePolicy insurancePolicy = new InsurancePolicy();
        insurancePolicy.name='Insurance Policy';
		
		insurancePolicy.status='In Force';
		insurancePolicy.Servicing_Agent__c=agentUser.id;
        insurancePolicy.NameInsuredId   = account.Id;
        return insurancePolicy;
    }
    
    /**
     * @description insertoppOpportunityData
     * @param lob 
     * @param product 
     * @param name 
     * @return  `Opportunity`
     */
    public static Opportunity insertoppOpportunityData(String lob,String product,String name){
            Opportunity opp = new Opportunity();
            opp.LOB__c = lob;
            opp.Product__c = product;              
            opp.OwnerId = proxyUser.Id;
            opp.StageName='Assigned';
            opp.name = name;
            opp.CloseDate = System.today()+60;
            opp.RecordTypeId = opportunityRecordTypeMap.get('Opportunity Management').RecordTypeId;   
        	return opp;
    }

    /**
     * @description testRetrieveData
     */
    @isTest
    public static void testRetrieveData(){

        procIDUser = [select id from user where alias = '12345' limit 1];
        agentUser = [select id from user where alias = 'Alia' limit 1];
        testAccount = [select id,clientidentifier__c from account where ClientIdentifier__c='WCMGF8RBPXA'];
		systemUser =  [select id from user where alias = 'SYSA' limit 1];
        InsurancePolicy insurancePolicy = insertInsurancePolicyData(testAccount, agentUser);
        insurancePolicy.PolicyType='Auto';
		insurancePolicy.PolicyName='Private Passenger';
        
        insurancePolicy.EffectiveDate = getYesterdayDateForEffDate(-1).addHours(12);
        insert insurancePolicy;
        
        InsurancePolicy insurancePolicy1 = insertInsurancePolicyData(testAccount, agentUser);
        insurancePolicy.PolicyType='';
		insurancePolicy.PolicyName='';
        insurancePolicy1.EffectiveDate = System.today();
        insert insurancePolicy1;
        System.runAs(systemUser)
        {
             insert new CS_AutoCloseBatch__c(ReprocessCount__c = 10,DaysToLookBackForIPData__c=3, Name = 'Test',AgreementStatus__c = 'In Force',BatchEmailRecipient__c='home.sys-sfdctestexception.773h00@statefarm.com');  
        }
        System.runAs(procIDUser){
            Batch_UpdateOppStagemanagement batchLoadOpp = new Batch_UpdateOppStagemanagement();
            Test.startTest();
            DataBase.executeBatch(batchLoadOpp);
            Test.stopTest();
        }
        List<InsurancePolicy> insurancePolicyList = [select id,name,EffectiveDate, NameInsured.ClientIdentifier__c,status,PolicyType,PolicyName,Servicing_Agent__r.Servicing_Agent_Associate_ID__c from InsurancePolicy where EffectiveDate=YESTERDAY and PolicyName !=null and PolicyType !=null ];
        System.assertEquals(1, insurancePolicyList.size(),'Insurance Policy List size is not valid');
    }

    /**
     * @description testValidatetimeStampsForAllRecords
     */
    @isTest
    public static void testValidatetimeStampsForAllRecords(){
        procIDUser = [select id from user where alias = '12345' limit 1];
        proxyUser = [select id from user where alias = 'Prox' limit 1];
        agentUser = [select id from user where alias = 'Alia' limit 1];
        systemUser =  [select id from user where alias = 'SYSA' limit 1];
        testAccount = [select id,clientidentifier__c from account where ClientIdentifier__c='WCMGF8RBPXA'];
        InsurancePolicy insurancePolicy = insertInsurancePolicyData(testAccount, agentUser);
        insurancePolicy.PolicyType='Auto';
        insurancePolicy.PolicyName='Private Passenger';
        insurancePolicy.EffectiveDate = getYesterdayDateForEffDate(-1).addHours(12);
        insert insurancePolicy;
        InsurancePolicy insurancePolicy1 = insertInsurancePolicyData(testAccount, agentUser);
        insurancePolicy1.PolicyType='Fire';
        insurancePolicy1.PolicyName='Apartment';
        insurancePolicy1.EffectiveDate = getYesterdayDateForEffDate(-1).addHours(12);
        insert insurancePolicy1;
        InsurancePolicy insurancePolicy2 = insertInsurancePolicyData(testAccount, agentUser);
        insurancePolicy2.PolicyType='Fire';
        insurancePolicy2.PolicyName='Condominium Unitowners Policy';
        insurancePolicy2.EffectiveDate = getYesterdayDateForEffDate(-1).addHours(12);
        insert insurancePolicy2;
        System.runAs(systemUser)
        {
             insert new CS_AutoCloseBatch__c(ReprocessCount__c = 10,DaysToLookBackForIPData__c=3, Name = 'Test',AgreementStatus__c = 'In Force',BatchEmailRecipient__c='home.sys-sfdctestexception.773h00@statefarm.com');    
        }
        Opportunity opportunity;
        Opportunity opportunity1;
        Opportunity opportunity2;
        Batch_UpdateOppStagemanagement_TestWrapper wrap = insertOpportunityData(opportunity, opportunity1, opportunity2);
        opportunity = wrap.opportunity;
        opportunity1 = wrap.opportunity1;
        opportunity2 = wrap.opportunity2;
        Batch_UpdateOppStagemanagement batchLoadOpp = new Batch_UpdateOppStagemanagement();
		HLPR_SignedWrittenConsent.byPassOpportunityBeforeUpdate = false;
        
        System.runAs(procIDUser){
            Test.startTest();
            DataBase.executeBatch(batchLoadOpp);
            Test.stopTest();
        }
        Opportunity opp = [select closedate,id,Assigned_To__c,OppContactEstablishedDateTime__c,OppQuoteInProgressDateTime__c,OppQuoteProvidedDateTime__c,OppAppPendingDateTime__C,OppAppSubmittedDateTime__c,OppAssignedDateTime__c,stagename,lob__c,Sub_Status__c,Status__c,OppAutoCloseWonDatetime__c,TimetoCloseDays__c from opportunity where id = :opportunity.id];
        System.assertNotEquals(null, opp.OppAutoCloseWonDatetime__c,'Auto close won date is updated');
        System.assertNotEquals(null, opp.Assigned_To__c,'Assigned to field is not populated');
        System.assertNotEquals(null, opp.OppAssignedDateTime__c,'Assigned to time stamp is not updated');
        System.assertNotEquals(null, opp.OppContactEstablishedDateTime__c,'Contact Established time stamp is not updated');
        System.assertNotEquals(null, opp.OppQuoteInProgressDateTime__c,'Quote In Progress time stamp is not updated');
        System.assertNotEquals(null, opp.OppQuoteProvidedDateTime__c,'Quote Provided time stamp is not updated');
        System.assertNotEquals(null, opp.OppAppPendingDateTime__C,'App Pending  time stamp is not updated');
        System.assertNotEquals(null, opp.OppAppSubmittedDateTime__c,'App Submitted time stamp is not updated');
        System.assertNotEquals(null, opp.TimetoCloseDays__c,'Time To Close Days is not updated');
        System.assertEquals(System.today(), opp.closeDate,'');
        Opportunity opp1 = [select id,closedate,Assigned_To__c,TimetoCloseDays__c,OppContactEstablishedDateTime__c,OppQuoteInProgressDateTime__c,OppQuoteProvidedDateTime__c,OppAppPendingDateTime__C,OppAppSubmittedDateTime__c,OppAssignedDateTime__c,stagename,lob__c,Sub_Status__c,Status__c,OppAutoCloseWonDatetime__c from opportunity where id = :opportunity1.id];
        System.assertNotEquals(null, opp1.OppAutoCloseWonDatetime__c,'Auto close won date is updated');
        System.assertNotEquals(null, opp1.Assigned_To__c,'Assigned to field is not populated');
        System.assertNotEquals(null, opp1.OppAssignedDateTime__c,'Assigned to time stamp is not updated');
        System.assertNotEquals(null, opp1.OppContactEstablishedDateTime__c,'Contact Established time stamp is not updated');
        System.assertNotEquals(null, opp1.OppQuoteInProgressDateTime__c,'Quote In Progress time stamp is not updated');
        System.assertNotEquals(null, opp1.OppQuoteProvidedDateTime__c,'Quote Provided time stamp is not updated');
        System.assertNotEquals(null, opp1.OppAppPendingDateTime__C,'App Pending  time stamp is not updated');
        System.assertNotEquals(null, opp1.OppAppSubmittedDateTime__c,'App Submitted time stamp is not updated');
        System.assertNotEquals(null, opp1.TimetoCloseDays__c,'Time To Close Days is not updated');
        Opportunity opp2 = [select id,Assigned_To__c,OppContactEstablishedDateTime__c,TimetoCloseDays__c,OppQuoteInProgressDateTime__c,OppQuoteProvidedDateTime__c,OppAppPendingDateTime__C,OppAppSubmittedDateTime__c,OppAssignedDateTime__c,stagename,lob__c,Sub_Status__c,Status__c,OppAutoCloseWonDatetime__c from opportunity where id = :opportunity2.id];
        System.assertNotEquals(null, opp2.OppAutoCloseWonDatetime__c,'Auto close won date is updated');
        System.assertNotEquals(null, opp2.Assigned_To__c,'Assigned to field is not populated');
        System.assertNotEquals(null, opp2.OppAssignedDateTime__c,'Assigned to time stamp is not updated');
        System.assertNotEquals(null, opp2.OppContactEstablishedDateTime__c,'Contact Established time stamp is not updated');
        System.assertNotEquals(null, opp2.OppQuoteInProgressDateTime__c,'Quote In Progress time stamp is not updated');
        System.assertNotEquals(null, opp2.OppQuoteProvidedDateTime__c,'Quote Provided time stamp is not updated');
        System.assertNotEquals(null, opp2.OppAppPendingDateTime__C,'App Pending  time stamp is not updated');
        System.assertNotEquals(null, opp2.OppAppSubmittedDateTime__c,'App Submitted time stamp is not updated');
        System.assertNotEquals(null, opp2.TimetoCloseDays__c,'Time To Close Days is not updated');
    }

   private class Batch_UpdateOppStagemanagement_TestWrapper{
    Opportunity opportunity;
    Opportunity opportunity1;
    Opportunity opportunity2;
   }
    
    /**
     * @description insertOpportunityData
     * @param opportunity 
     * @param opportunity1 
     * @param opportunity2 
     * @return batchWrap
     */
    private static Batch_UpdateOppStagemanagement_TestWrapper insertOpportunityData(Opportunity opportunity, Opportunity opportunity1, Opportunity opportunity2){
        Batch_UpdateOppStagemanagement_TestWrapper batchWrap = new Batch_UpdateOppStagemanagement_TestWrapper();
        System.runAs(agentUser){
            opportunity  = insertoppOpportunityData('Auto','Private Passenger','AutoClosedWonSucc');
            opportunity.AccountId = testAccount.Id;
            insert opportunity;
            opportunity1  = insertoppOpportunityData('Fire','Apartment','AutoClosedWonFire');
            opportunity1.AccountId = testAccount.Id;
            insert opportunity1;
            opportunity2  = insertoppOpportunityData('Fire','Condominium Unitowners','AutoClosedWonCUT');
            opportunity2.AccountId = testAccount.Id;
            insert opportunity2;
            batchWrap.opportunity = opportunity;
            batchWrap.opportunity1 = opportunity1;
            batchWrap.opportunity2 = opportunity2;
        }
        return batchWrap;
    }

    /**
     * @description testUpdateClosedWonData
     */
    @isTest
    public static void testUpdateClosedWonData(){
        procIDUser = [select id from user where alias = '12345' limit 1];
        proxyUser = [select id from user where alias = 'Prox' limit 1];
        agentUser = [select id from user where alias = 'Alia' limit 1];
        systemUser =  [select id from user where alias = 'SYSA' limit 1];
        testAccount = [select id,clientidentifier__c from account where ClientIdentifier__c='WCMGF8RBPXA'];
        InsurancePolicy insurancePolicy = insertInsurancePolicyData(testAccount, agentUser);
        insurancePolicy.PolicyType='Auto';
		insurancePolicy.PolicyName='Private Passenger';

        insurancePolicy.EffectiveDate = getYesterdayDateForEffDate(-1).addHours(12);
        insert insurancePolicy;
        System.runAs(systemUser)
        {
             insert new CS_AutoCloseBatch__c(ReprocessCount__c = 10,DaysToLookBackForIPData__c=3, Name = 'Test',AgreementStatus__c = 'In Force',BatchEmailRecipient__c='home.sys-sfdctestexception.773h00@statefarm.com');  
        }
        Opportunity opportunity ;
        Opportunity oppNotAutoClosed;
        Batch_UpdateOppStagemanagement batchLoadOpp = new Batch_UpdateOppStagemanagement();
        
        System.runAs(agentUser){
            opportunity  = insertoppOpportunityData('Auto','Private Passenger','AutoClosedWonSucc');
            opportunity.AccountId = testAccount.Id;
            insert opportunity;
            oppNotAutoClosed = insertoppOpportunityData('Auto','Motorcycle','AutoClosedWonFail');
            oppNotAutoClosed.AccountId = testAccount.Id;
            insert oppNotAutoClosed;
        }
        System.runAs(procIDUser){
            Test.startTest();
            DataBase.executeBatch(batchLoadOpp);
            Test.stopTest();
        }
        Opportunity opp = [select id,Assigned_To__c,OppAssignedDateTime__c,stagename,lob__c,Sub_Status__c,Status__c,OppAutoCloseWonDatetime__c from opportunity where id = :opportunity.id];
        System.assertEquals('Closed Won', opp.stagename,'Stage got updated to Closed Won');
        System.assertEquals('Auto', opp.lob__c, 'Lob expected value not equals to actual value');
        System.assertEquals('Policy Issued', opp.Sub_Status__c,'Sub status value not equals to actual value');
        System.assertEquals('System Closed Won', opp.Status__c,'status value not equals to actual value');
        System.assertNotEquals(null, opp.OppAutoCloseWonDatetime__c,'Auto close won date is updated');
        System.assertNotEquals(null, opp.Assigned_To__c,'Assigned to field is not populated');
        System.assertNotEquals(null, opp.OppAssignedDateTime__c,'Assigned to time stamp is not updated');
        
        Opportunity oppNotUpdated = [select id,stagename from opportunity where id = :oppNotAutoClosed.id];
        System.assertNotEquals('Closed Won', oppNotUpdated.stagename,'Stage did not get updated to Closed Won');
   	
    }
    
    private static DateTime getYesterdayDateForEffDate(Integer numberOfDays){
        Date yesterday = Date.today().addDays(numberOfDays);
        DateTime dateTimeNowYesterday =  yesterday;
        yesterday = Date.today().addDays(numberOfDays);
        dateTimeNowYesterday =  yesterday;
        return dateTimeNowYesterday;
    }

    /**
     * @description testNewProduct
     */
    @isTest
    public static void testNewProduct(){
        procIDUser = [select id from user where alias = '12345' limit 1];
        proxyUser = [select id from user where alias = 'Prox' limit 1];
        agentUser = [select id from user where alias = 'Alia' limit 1];
	systemUser =  [select id from user where alias = 'SYSA' limit 1];
         testAccount = [select id,clientidentifier__c from account where ClientIdentifier__c='WCMGF8RBPXA'];
		InsurancePolicy insurancePolicy1 = insertInsurancePolicyData(testAccount, agentUser);
        insurancePolicy1.PolicyType='Auto';
		insurancePolicy1.PolicyName='Testing';
        
        insurancePolicy1.EffectiveDate = getYesterdayDateForEffDate(-1).addHours(12);
        insert insurancePolicy1;
        System.runAs(systemUser)
        {
             insert new CS_AutoCloseBatch__c(ReprocessCount__c = 10,DaysToLookBackForIPData__c=3, Name = 'Test',AgreementStatus__c = 'In Force',BatchEmailRecipient__c='home.sys-sfdctestexception.773h00@statefarm.com');  
        }
        Opportunity productMapOpp;
        Batch_UpdateOppStagemanagement batchLoadOpp = new Batch_UpdateOppStagemanagement();
        System.runAs(agentUser){
            productMapOpp  = insertoppOpportunityData('Auto','Private Passenger','AutoClosedWonSucc');
            productMapOpp.AccountId = testAccount.Id;
            insert productMapOpp;
        }
         System.runAs(procIDUser){
            Test.startTest();
            DataBase.executeBatch(batchLoadOpp);
            Test.stopTest();
        }
        Opportunity opp = [select id,stagename from opportunity where id = :productMapOpp.id];
        System.assertNotEquals('Closed Won', opp.stagename,'Stage not updated due to new Product');
        
    }
    
    /**
     * @description testMismatchProductInsurancePolicyVsSalesforce
     */
    @isTest
    public static void testMismatchProductInsurancePolicyVsSalesforce(){
        procIDUser = [select id from user where alias = '12345' limit 1];
        proxyUser = [select id from user where alias = 'Prox' limit 1];
        agentUser = [select id from user where alias = 'Alia' limit 1];
        systemUser =  [select id from user where alias = 'SYSA' limit 1];

         testAccount = [select id,clientidentifier__c from account where ClientIdentifier__c='WCMGF8RBPXA'];
		InsurancePolicy insurancePolicy1 = insertInsurancePolicyData(testAccount, agentUser);
        insurancePolicy1.PolicyType='Fire';
		insurancePolicy1.PolicyName='Condominium Unitowners Policy';
        
        insurancePolicy1.EffectiveDate = getYesterdayDateForEffDate(-1).addHours(12);
        insert insurancePolicy1;
        System.runAs(systemUser)
        {
             insert new CS_AutoCloseBatch__c(ReprocessCount__c = 10,DaysToLookBackForIPData__c=3, Name = 'Test',AgreementStatus__c = 'In Force',BatchEmailRecipient__c='home.sys-sfdctestexception.773h00@statefarm.com');    
        }
        Opportunity productMapOpp;
        Batch_UpdateOppStagemanagement batchLoadOpp = new Batch_UpdateOppStagemanagement();
        
        System.runAs(agentUser){

            productMapOpp  = insertoppOpportunityData('Fire','Condominium Unitowners','FireClosedWonSucc');
            productMapOpp.AccountId = testAccount.Id;
            insert productMapOpp;
        }
  		HLPR_SignedWrittenConsent.byPassOpportunityBeforeUpdate = false;

         System.runAs(procIDUser){
             
            Test.startTest();
            DataBase.executeBatch(batchLoadOpp);
            Test.stopTest();
        }
        Opportunity opp = [select id,timetoCloseDays__c,closedate,Assigned_To__c,OppContactEstablishedDateTime__c,OppQuoteInProgressDateTime__c,OppQuoteProvidedDateTime__c,OppAppPendingDateTime__C,OppAppSubmittedDateTime__c,OppAssignedDateTime__c,stagename,lob__c,Sub_Status__c,Status__c,OppAutoCloseWonDatetime__c from opportunity where id = :productMapOpp.id];
        System.assertEquals('Closed Won', opp.stagename,'Stage not updated due to new Product');
        System.assertEquals('System Closed Won', opp.status__c,'Status not updated due to new Product');
        System.assertEquals('Policy Issued', opp.Sub_Status__c,'Sub status not updated due to new Product');
        System.assertNotEquals(null, opp.OppAutoCloseWonDatetime__c,'Auto close won date is updated');
        System.assertNotEquals(null, opp.Assigned_To__c,'Assigned to field is not populated');
        System.assertNotEquals(null, opp.OppAssignedDateTime__c,'Assigned to time stamp is not updated');
        System.assertNotEquals(null, opp.OppContactEstablishedDateTime__c,'Contact Established time stamp is not updated');
        System.assertNotEquals(null, opp.OppQuoteInProgressDateTime__c,'Quote In Progress time stamp is not updated');
        System.assertNotEquals(null, opp.OppQuoteProvidedDateTime__c,'Quote Provided time stamp is not updated');
        System.assertNotEquals(null, opp.OppAppPendingDateTime__C,'App Pending  time stamp is not updated');
        System.assertNotEquals(null, opp.OppAppSubmittedDateTime__c,'App Submitted time stamp is not updated');
        System.assertNotEquals(null, opp.TimetoCloseDays__c,'Time To Close Days is not updated');
        System.assertEquals(System.today(), opp.closeDate,'');
    }

    /**
     * @description test3DaysDataFromInsurancePolicy
     */
    @isTest
    public static void test3DaysDataFromInsurancePolicy(){
        procIDUser = [select id from user where alias = '12345' limit 1];
        proxyUser = [select id from user where alias = 'Prox' limit 1];
        agentUser = [select id from user where alias = 'Alia' limit 1];
        systemUser =  [select id from user where alias = 'SYSA' limit 1];

         testAccount = [select id,clientidentifier__c from account where ClientIdentifier__c='WCMGF8RBPXA'];
        Account testAccount1 = [select id,clientidentifier__c from account where ClientIdentifier__c= 'WCMGF8RBPXB'];
		InsurancePolicy insurancePolicy1 = insertInsurancePolicyData(testAccount, agentUser);
        insurancePolicy1.PolicyType='Fire';
		insurancePolicy1.PolicyName='Condominium Unitowners Policy';
        
        insurancePolicy1.EffectiveDate = getYesterdayDateForEffDate(-1).addHours(12);
        insert insurancePolicy1;

        InsurancePolicy insurancePolicy2 = insertInsurancePolicyData(testAccount1, agentUser);
        insurancePolicy2.PolicyType='Fire';
		insurancePolicy2.PolicyName='Condominium Unitowners Policy';
        insurancePolicy2.EffectiveDate = getYesterdayDateForEffDate(+5).addHours(12);
        insert insurancePolicy2;

        System.runAs(systemUser)
        {
             insert new CS_AutoCloseBatch__c(ReprocessCount__c = 10,DaysToLookBackForIPData__c=3, Name = 'Test',AgreementStatus__c = 'In Force',BatchEmailRecipient__c='home.sys-sfdctestexception.773h00@statefarm.com');    
        }
        Opportunity productMapOpp;
        Batch_UpdateOppStagemanagement batchLoadOpp = new Batch_UpdateOppStagemanagement();
        Opportunity opp1;
        System.runAs(agentUser){
            productMapOpp  = insertoppOpportunityData('Fire','Condominium Unitowners','FireClosedWonSucc');   
            productMapOpp.AccountId = testAccount.Id;
            insert productMapOpp;
            opp1  = insertoppOpportunityData('Fire','Condominium Unitowners','FireClosedWonSucc');   
            opp1.AccountId = testAccount1.Id;
            insert opp1;  
        }
         System.runAs(procIDUser){  
            Test.startTest();
            DataBase.executeBatch(batchLoadOpp);
            Test.stopTest();
            Opportunity opp = [select id,Assigned_To__c,OppAssignedDateTime__c,stagename,lob__c,Sub_Status__c,Status__c,OppAutoCloseWonDatetime__c from opportunity where id = :productMapOpp.id];
            Opportunity oppp2 = [select id,Account.clientidentifier__c,Assigned_To__c,OppAssignedDateTime__c,stagename,lob__c,Sub_Status__c,Status__c,OppAutoCloseWonDatetime__c from opportunity where id = :opp1.id];
			
             System.assertEquals('Closed Won', opp.stagename,'Stage not updated due to new Product');
             System.assertNotEquals('Closed Won', oppp2.stagename,'Stage not updated due to new Product');
        }
    }
    
    /**
     * @description getProfileId
     * @param profileName 
     * @return  `String`
     */
     public static String getProfileId(String profileName) {
        return [SELECT Id FROM Profile WHERE name = :profileName LIMIT 1].Id;
    }

    /**
     * @description buildUser
     * @param paramUserName 
     * @param paramprofileId 
     * @return  `User`
     */
    public static User buildUser(String paramUserName, String paramprofileId) {
        return new User(alias = '12345', email='testUser@statefarm.com.bad', emailencodingkey='UTF-8', lastname='TestUserLastName',
                            languagelocalekey='en_US',localesidkey='en_US', timezonesidkey='America/Chicago', 
                            username= paramUserName, profileId = paramprofileId
                        );
        //testUser.put('UserPermissionsMarketingUser', true);
        
    }

    /**
     * @description createUser
     * @param testUser 
     * @return  `User`
     */
     public static User createUser(User testUser) {
        insert testUser;
        return testUser;
    }

    /**
     * @description assignPermissionSet
     * @param testUser 
     * @param permissionSetName 
     */
    public static void assignPermissionSet(User testUser, String permissionSetName) {
        PermissionSet queryPermissionSet = [Select id FROM PermissionSet WHERE Name =: permissionSetName Limit 1];
        PermissionSetAssignment assignPermissionSet = new PermissionSetAssignment();
        assignPermissionSet.AssigneeId = testUser.id;
        assignPermissionSet.PermissionSetId = queryPermissionSet.id;
        insert assignPermissionSet;
    }

    /**
     * @description testNotToHappenAutoClosed
     */
    @isTest
    public static void testNotToHappenAutoClosed(){
        procIDUser = [select id from user where alias = '12345' limit 1];
        proxyUser = [select id from user where alias = 'Prox' limit 1];
        agentUser = [select id from user where alias = 'Alia' limit 1];
	    systemUser =  [select id from user where alias = 'SYSA' limit 1];
        System.runAs(systemUser)
        {
             insert new CS_AutoCloseBatch__c(ReprocessCount__c = 10,DaysToLookBackForIPData__c=3, Name = 'Test',AgreementStatus__c = 'In Force',BatchEmailRecipient__c='home.sys-sfdctestexception.773h00@statefarm.com');    
        }
         testAccount = [select id,clientidentifier__c from account where ClientIdentifier__c='WCMGF8RBPXA'];
		InsurancePolicy insurancePolicy1 = insertInsurancePolicyData(testAccount, agentUser);
        insurancePolicy1.PolicyType='Auto';
		insurancePolicy1.PolicyName='Private Passenger';
        Opportunity productMapOpp;
        Batch_UpdateOppStagemanagement batchLoadOpp = new Batch_UpdateOppStagemanagement();
        Opportunity opp1;
        System.runAs(agentUser){
            productMapOpp  = insertoppOpportunityData('Auto','Private Passenger','TestNotClosed');   
            productMapOpp.AccountId = testAccount.Id;
            insert productMapOpp;
            opp1  = insertoppOpportunityData('Auto','Private Passenger','TestNotClosed');   
            opp1.AccountId = testAccount.Id;
            insert opp1;  
        }
        System.runAs(procIDUser){  
            Test.startTest();
            DataBase.executeBatch(batchLoadOpp);
            Test.stopTest();
            Opportunity opp = [select id,Assigned_To__c,OppAssignedDateTime__c,stagename,lob__c,Sub_Status__c,Status__c,OppAutoCloseWonDatetime__c from opportunity where id = :productMapOpp.id];
            Opportunity oppp2 = [select id,Account.clientidentifier__c,Assigned_To__c,OppAssignedDateTime__c,stagename,lob__c,Sub_Status__c,Status__c,OppAutoCloseWonDatetime__c from opportunity where id = :opp1.id];
			
            System.assertNotEquals('Closed Won', opp.stagename,'Stage not updated due to Multiple opp with same data');
            System.assertNotEquals('Closed Won', oppp2.stagename,'Stage not updated due to Multiple opp with same data');
        }
    }
}