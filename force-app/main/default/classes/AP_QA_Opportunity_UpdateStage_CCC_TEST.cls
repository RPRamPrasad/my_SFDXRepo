/**
  * @Name AP_QA_Opportunity_UpdateStage_CCC_TEST
  * @Author Team Dream Builders 1/18/2018
  * @description update the Opportunity Stage to Quote In Progress unless Stage is already App Pending, App Submitted, Closed, or Closed Won
  Version     Author         Date         Description
  1.1         Opptimizers    9-8-2022     added @isTest annotations
 */
@isTest(seeAllData=false)
private class AP_QA_Opportunity_UpdateStage_CCC_TEST {
  
  private static AP_QA_Opportunity_UpdateStage_CCC updateQuoteStatus;
    private static UserRole ccc300StandardUserRole;
    private static User ccc300User;
    private static User systemAdmin;
    private static Account testAccount;
    private static String optyRecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunity_Management').getRecordTypeId();

  @testsetup
  private static void setUp() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        User systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert systemUser;
        
        CS001_ByPassTriggerAll__c passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=false);
        insert passTriggerAll;
        CS001_ByPassTriggerAtoF__c accountByPassTrigger= new CS001_ByPassTriggerAtoF__c(Override_AccountBeforeInsert__c=false,Override_AgentRoleAfterInsert__c=false);
        insert accountByPassTrigger;
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(Name=UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER,SFDC_USER_ID__c=systemUser.id);            
        insert sysAdminUserIdSetting;
        
        CS001_ByPassTriggerAtoF__c accBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(systemUser);
        accBasedByPassTrigger.Override_AccountBeforeInsert__c = false;
        insert accBasedByPassTrigger;
        
        CS001_ByPassTriggerGtoZ__c oppByPassTrigger = new CS001_ByPassTriggerGtoZ__c(Override_OppBeforeInsert__c=true);
        insert oppByPassTrigger;    
    }
    
    /**
     * @description setUpCCCUser
     */
    public static void setUpCCCUser(){
            ccc300StandardUserRole = new UserRole(name='CCCRole');
            insert ccc300StandardUserRole;
            ccc300User = UTIL_UserProvisioning_TEST.buildCCCLicensedUser();
            ccc300User.userRoleId = ccc300StandardUserRole.id;

            insert ccc300User;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(ccc300User);

                    
    }
    
    /**
     * @description createTestAccount
     */
    public static void createTestAccount(){
         systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com'); 
        insert systemAdmin;
        System.runas(systemAdmin){
            testAccount= new Account(firstname ='SSSHHHH', lastname='SSSSSHHHH', ClientIdentifier__c = 'cid1');
            insert testAccount;
        }
    }
    
    @isTest
    static void testUpdateStageName() {
        setUpCCCUser();
         createTestAccount();  
        Opportunity opportunity = new Opportunity(accountId = testAccount.id, name='Opp',closeDate=system.today(), stageName='Assigned',LOB__c='Auto',Description='Test Descrption',RecordTypeId=optyRecordTypeId);
        Test.startTest();
        system.runAs(ccc300User) { 
            insert opportunity;
             Map<String, String> requestParams = new Map<String, String>();
            requestParams.put('newStageName', 'Quoting');
          requestParams.put('opportunityId', opportunity.Id);
            
      updateQuoteStatus = new AP_QA_Opportunity_UpdateStage_CCC();
            updateQuoteStatus.setRequestParameters(requestParams);
          updateQuoteStatus.execute();
        }
        Test.stopTest();
        
    Opportunity actual = [SELECT ID, StageName,Status__c FROM Opportunity WHERE ID = :opportunity.ID];
        System.assertEquals('Quoting', actual.StageName, 'The actual stage is not Quoting');
        System.assertEquals('Quote In Progress', actual.Status__c, 'The actual Status is not Quote In Progress');
    }
    
    @isTest
    static void testUpdateStageNameNullParameter() {
        setUpCCCUser();
         createTestAccount();  
        Opportunity opportunity = new Opportunity(accountId = testAccount.id, name='Opp',closeDate=system.today(), stageName='Assigned',LOB__c='Auto',Description='Test Descrption',RecordTypeId=optyRecordTypeId);
        Test.startTest();
        system.runAs(ccc300User) { 
            insert opportunity;
             Map<String, String> requestParams = new Map<String, String>();
            
            try {
              updateQuoteStatus = new AP_QA_Opportunity_UpdateStage_CCC();
              updateQuoteStatus.setRequestParameters(requestParams);
            updateQuoteStatus.execute();
            } catch (NoDataFoundException ex) {
                System.assertEquals('Opportunity ID is null.', ex.getMessage(), 'The expected exception message does not match the actual value');
            }
        }
        Test.stopTest();
        
    Opportunity actual = [SELECT ID, StageName FROM Opportunity WHERE ID = :opportunity.ID];
        System.assertEquals('Assigned', actual.StageName, 'The actual stage name is not Assigned');
    }
    
    @isTest
    static void testUpdateStageNameIncorrectOpportunityId() {
        setUpCCCUser();
         createTestAccount();  
        Opportunity opportunity = new Opportunity(accountId = testAccount.id, name='Opp',closeDate=system.today(), stageName='Assigned',LOB__c='Auto',Description='Test Descrption',RecordTypeId=optyRecordTypeId);
        Test.startTest();
        system.runAs(ccc300User) { 
            insert opportunity;
             Map<String, String> requestParams = new Map<String, String>();
            
            try {
                updateQuoteStatus = new AP_QA_Opportunity_UpdateStage_CCC();
                updateQuoteStatus.setRequestParameters(requestParams);
            updateQuoteStatus.execute();
            } catch (NoDataFoundException ex) {
                System.assertEquals('Opportunity ID is null.', ex.getMessage(), 'The expected exception message does not match the actual value');
            }
        }
        Test.stopTest();
        
        Opportunity actual = [SELECT ID, StageName FROM Opportunity WHERE ID = :opportunity.ID];
        System.assertEquals('Assigned', actual.StageName, 'The actual stage name is not assigned');
    }

    @isTest
    static void testUpdateStageNameAppPending() {
        setUpCCCUser();
         createTestAccount();  
        Opportunity opportunity = new Opportunity(accountId = testAccount.id, name='Opp',closeDate=system.today(),Status__c='Application Pending', stageName='Quoting',LOB__c='Auto',Description='Test Descrption',RecordTypeId=optyRecordTypeId);
        Test.startTest();
        system.runAs(ccc300User) { 
            insert opportunity;
             Map<String, String> requestParams = new Map<String, String>();
            requestParams.put('newStageName', 'Quoting');
           
          requestParams.put('opportunityId', opportunity.Id);
            
      updateQuoteStatus = new AP_QA_Opportunity_UpdateStage_CCC();
            updateQuoteStatus.setRequestParameters(requestParams);
          updateQuoteStatus.execute();
        }
        Test.stopTest();
        
    Opportunity actual = [SELECT ID, StageName, Status__c FROM Opportunity WHERE ID = :opportunity.ID];
        System.assertEquals('Quoting', actual.StageName, 'The actual stage name is not Quoting');
        System.assertEquals('Application Pending', actual.Status__c, 'The actual Status is not Application Pending');
    }
    
    @isTest
    static void testUpdateStageNameClosed() {
        setUpCCCUser();
         createTestAccount();  
        Opportunity opportunity = new Opportunity(accountId = testAccount.id, name='Opp',closeDate=system.today(), stageName='Closed',LOB__c='Auto',Description='Test Descrption',RecordTypeId=optyRecordTypeId);
        Test.startTest();
        system.runAs(ccc300User) { 
            insert opportunity;
             Map<String, String> requestParams = new Map<String, String>();
            requestParams.put('newStageName', 'Quoting');
            requestParams.put('Status__c', 'Quote In Progress');
          requestParams.put('opportunityId', opportunity.Id);
            
      updateQuoteStatus = new AP_QA_Opportunity_UpdateStage_CCC();
            updateQuoteStatus.setRequestParameters(requestParams);
          updateQuoteStatus.execute();
        }
        Test.stopTest();
        
    Opportunity actual = [SELECT ID, StageName FROM Opportunity WHERE ID = :opportunity.ID];
        System.assertEquals('Quoting', actual.StageName, 'The actual Stage is not Closed');
    }
    
    @isTest
    static void testUpdateStageNameAppSubmitted() {
        setUpCCCUser();
         createTestAccount();  
        Opportunity opportunity = new Opportunity(accountId = testAccount.id, name='Opp',closeDate=system.today(), stageName='App Submitted',LOB__c='Auto',Description='Test Descrption',RecordTypeId=optyRecordTypeId);
        Test.startTest();
        system.runAs(ccc300User) { 
            insert opportunity;
             Map<String, String> requestParams = new Map<String, String>();
            requestParams.put('newStageName', 'Quoting');
            requestParams.put('Status__c', 'Quote In Progress');
          requestParams.put('opportunityId', opportunity.Id);
            
      updateQuoteStatus = new AP_QA_Opportunity_UpdateStage_CCC();
            updateQuoteStatus.setRequestParameters(requestParams);
          updateQuoteStatus.execute();
        }
        Test.stopTest();
        
    Opportunity actual = [SELECT ID, StageName FROM Opportunity WHERE ID = :opportunity.ID];
        System.assertEquals('App Submitted', actual.StageName, 'The autual Stage is not App Submitted');
    }
    
    @isTest
    static void testUpdateStageNameClosedWon() {
        setUpCCCUser();
         createTestAccount();  
        Opportunity opportunity = new Opportunity(accountId = testAccount.id, name='Opp',closeDate=system.today(), stageName='Closed Won',LOB__c='Auto',Description='Test Descrption',RecordTypeId=optyRecordTypeId);
        Test.startTest();
        system.runAs(ccc300User) { 
            insert opportunity;
             Map<String, String> requestParams = new Map<String, String>();
            requestParams.put('newStageName', 'Quoting');
            requestParams.put('Status__c', 'Quote In Progress');
          requestParams.put('opportunityId', opportunity.Id);
            
      updateQuoteStatus = new AP_QA_Opportunity_UpdateStage_CCC();
            updateQuoteStatus.setRequestParameters(requestParams);
          updateQuoteStatus.execute();
        }
        Test.stopTest();
        
    Opportunity actual = [SELECT ID, StageName FROM Opportunity WHERE ID = :opportunity.ID];
        System.assertEquals('Closed Won', actual.StageName, 'The actual Stage is not Closed Won');
    }
    
    @isTest
    static void testUpdateStageNameQuoteInProgress() {
        setUpCCCUser();
         createTestAccount();  
        Opportunity opportunity = new Opportunity(accountId = testAccount.id, name='Opp',closeDate=system.today(), stageName='Quoting',LOB__c='Auto',Description='Test Descrption',RecordTypeId=optyRecordTypeId);
        Test.startTest();
        system.runAs(ccc300User) { 
            insert opportunity;
             Map<String, String> requestParams = new Map<String, String>();
            requestParams.put('newStageName', 'Quoting');
            requestParams.put('opportunityId', opportunity.Id);
            
      updateQuoteStatus = new AP_QA_Opportunity_UpdateStage_CCC();
            updateQuoteStatus.setRequestParameters(requestParams);
          updateQuoteStatus.execute();
        }
        Test.stopTest();
        
    Opportunity actual = [SELECT ID, StageName, Status__c FROM Opportunity WHERE ID = :opportunity.ID];
        System.assertEquals('Quoting', actual.StageName, 'The actual Stage is not Quoting');
        System.assertEquals('Quote In Progress', actual.Status__c, 'The actual Status is not Quote In Progress');
    }

    @isTest
    static void testUpdateStageNameQuoteProvided() {
        setUpCCCUser();
         createTestAccount();  
        Opportunity opportunity = new Opportunity(accountId = testAccount.id, name='Opp',closeDate=system.today(), stageName='Quoting',LOB__c='Auto',Description='Test Descrption',RecordTypeId=optyRecordTypeId,status__c='Quote Provided');
        Test.startTest();
        system.runAs(ccc300User) { 
            insert opportunity;
             Map<String, String> requestParams = new Map<String, String>();
            requestParams.put('newStageName', 'Quoting');
            requestParams.put('opportunityId', opportunity.Id);
            
      updateQuoteStatus = new AP_QA_Opportunity_UpdateStage_CCC();
            updateQuoteStatus.setRequestParameters(requestParams);
          updateQuoteStatus.execute();
        }
        Test.stopTest();
        
    Opportunity actual = [SELECT ID, StageName, Status__c FROM Opportunity WHERE ID = :opportunity.ID];
        System.assertEquals('Quoting', actual.StageName, 'The actual Stage is not Quoting');
        System.assertEquals('Quote Provided', actual.Status__c, 'The actual Status is not Quote Provided');
    }
    
}