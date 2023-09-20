/**
* Author : Golden Spikes Team
* Date Created : 03/19/2017
* @description : Test class for the AP_QuoteTrigger apex class.
*/
@isTest(seeAllData=false)
private class AP_QuoteTrigger_Test {
    private static User adminUser;
    private static User agentUser;
    private static User proxyUser;
    private static User procIdUser;
    private static final String AUTO_QUOTE_RECORD_TYPE_NAME = 'Auto Quote';
    private static final String FIRE_QUOTE_RECORD_TYPE_NAME = 'Fire Quote';
    private static final String PRIMARY_AUTO_QUOTE_RECORD_TYPE_NAME = 'Primary Auto Quote';
    private static final String PRIMARY_FIRE_QUOTE_RECORD_TYPE_NAME = 'Primary Fire Quote';
    private static final String QUOTE_MGMT_PERM_SET_NAME ='SF_CRM_QuoteManagement_PermSetPID';

    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();
    private static String optyRecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunity_Management').getRecordTypeId();
    private static Map<String, Schema.Recordtypeinfo> quoteRecordTypeMap = Schema.Sobjecttype.Quote__c.getRecordTypeInfosByName();
    private static Account act;

    @TestSetup
    static void makeData(){
        User adminUser = UTIL_UserProvisioning_TEST.buildUserWithSystemAdminProfile('tstQuoteMgmtAdm@statefarm.com.bad');
        insert adminuser;

        User agentUser;
        User proxyUser; 

        System.runAs(adminUser) {
            byPassTrigger();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;
            
            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            User testAgentUser = new User(Alias='QMAG',LastName='agent',Username='tstQuoteMgmtAgt@statefarm.com.bad',Associate_ID__c='ASSOCID0001',UserExternalID__c='EXTERNALID1',Servicing_Agent_Associate_ID__c='AGTASSOCID1',Territory_Associate_ID__c='',Servicing_Agent_Associate_ID_List__c='',Territory_Associate_ID_List__c='');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser (testAgentUser);
            agentUser.userRoleId = agentUserRole.id;                          
            insert agentUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            User testProxyUser = new User(Alias='QMPX',LastName='middle',Username='tstQuoteMgmtPrxy@statefarm.com.bad',UserExternalID__c='EXTERNALID2',Servicing_Agent_Associate_ID__c='ASSOCID0001', Territory_Associate_ID__c='');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser(testProxyUser);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;
            
           // User testProcIdUser = new User(Alias='QMPR',LastName='last',Username='tstQuoteMgmtProc@statefarm.com.bad',UserExternalID__c='EXTERNALID3',Servicing_Agent_Associate_ID__c='ASSOCID0002', Territory_Associate_ID__c='');
			procIdUser = UTIL_UserProvisioning_TEST.buildUserAPIDataAdmin('tstQuoteMgmtProc@statefarm.com.bad');
        	insert procIdUser;
            
        }
		Account acc = buildAccountRecord('Quote MGMT','111',agentUser.Id);
        insert acc;    
        
       //Insert agent role to give account access to the Agent
        AgentRole__c agentRole;
        System.runAs(agentUser) {
            agentRole = buildAgentRoleRecord(acc.Id);
        }
        insert agentRole;
    }
    
    //method to bypass Trigger
    private static void byPassTrigger() {
        CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c();
        objectBasedByPassTrigger.Override_All__c = true;
        insert objectBasedByPassTrigger;
  }
    
    //method to build userrole with parentRole with the given parameter value
    private static UserRole buildRole(String roleName) {
        return new UserRole(name = roleName);
   }

    /**
     * @description buildUserRoleWithParent
     * @param roleName
     * @param parentRole
     * @return UserRole
     */
    //method to build userrole with parentRole with the given parameter value
    private static UserRole buildRoleWithParentRole(String roleName, String parentrole) {
        return new UserRole(name = roleName, parentRoleId = parentrole);
    }

    //method to build Account record with the given parameter value
    private static Account buildAccountRecord(String fstLstName, String clientId, Id owner) {
        String[] splitFSTLSTName = fstLstName.split(' ');
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        return new Account(Edit_In_VFP__c=true,FirstName = splitFSTLSTName[0] , LastName = splitFSTLSTName[1], ownerId = owner,
                                  RecordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId, ClientIdentifier__c = clientId);
        //return new Account(Edit_In_VFP__c=true,FirstName = 'rrrrr', LastName = 'tttttttt',
             //              RecordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId, ClientIdentifier__c = param_clientIdentifier);
    }

    //method to build Agent Role record with the given parameter value
    private static AgentRole__c buildAgentRoleRecord(String param_accountId) {
        return new AgentRole__c(RelationshipNature__c = 'Customer',
                       Agent__c = userInfo.getUserId(), Customer__c = param_accountId);
    }

     //method to build Opportunity record with the given parameter value
    private static Opportunity buildOpportunityRecord(String param_accountId, Date param_XDate) {
        return new Opportunity(Name = 'Tst Opty', AccountId = param_accountId, Monthly_Premium__c = 600.00, 
                            CloseDate = Date.today() + 1, LOB__c = 'Auto',
                            StageName = 'New', RecordTypeId = optyRecordTypeId, Amount = 1200.00, CurrentInsurerName__c = 'testInsurer',  X_Date__c = param_XDate                            
                          );
    }

     //method to build Quote record with the given parameter value
    private static Quote__c buildQuoteRecord(String param_oppId, String param_recordTypeId, Boolean param_primaryQuote) {
        return new Quote__c(Name = 'Tst Quote', Opportunity__c= param_oppId, PrimaryQuote__c= param_primaryQuote, RecordTypeId = param_recordTypeId
                          );
    }
    
    //method to assign permissionset for the given user in parameter value
    private static void assignPermissionSet(User testUser, String permissionSetName) {
        PermissionSet queryPermissionSet = [Select id FROM PermissionSet WHERE Name =: permissionSetName Limit 1];
        PermissionSetAssignment assignPermissionSet = new PermissionSetAssignment();
        assignPermissionSet.AssigneeId = testUser.id;
        assignPermissionSet.PermissionSetId = queryPermissionSet.id;
        insert assignPermissionSet;
    }
    
    private static void fetchTestData() {
        agentUser = [SELECT Id, Associate_ID__c, UserExternalID__c FROM User WHERE username = 'tstQuoteMgmtAgt@statefarm.com.bad'];
        adminUser = [SELECT Id, Associate_ID__c FROM User WHERE username = 'tstQuoteMgmtAdm@statefarm.com.bad'];
        proxyUser = [SELECT Id, Associate_ID__c FROM User WHERE Alias = 'QMPXP'];
        procIdUser = [SELECT Id, Associate_ID__c FROM User WHERE username = 'tstQuoteMgmtProc@statefarm.com.bad'];
        act = [SELECT Id, ClientIdentifier__c, Name FROM Account WHERE lastname = 'MGMT'];
    }
    
    //test method to verify opportunity quote information fields with blank value on deletion of Primary quote record as an Agent.
    @isTest  
    private static void testSyncOpportunityOnPrimaryQuoteAfterDelete() {
        fetchTestData();
		assignPermissionSet(agentUser, QUOTE_MGMT_PERM_SET_NAME);          
        System.runAs(agentUser) {
            Opportunity opty = buildOpportunityRecord(act.id, Date.newInstance(2015, 03, 16));
            insert opty;

            Quote__c primaryQuote = buildQuoteRecord(opty.id, quoteRecordTypeMap.get(PRIMARY_AUTO_QUOTE_RECORD_TYPE_NAME).RecordTypeId, true );
            primaryQuote.MonthlyPremium__c = 600.00;
            primaryQuote.TotalPremiumAllVehicles__c = 1200.00;
            insert primaryQuote;

            Quote__c selectedQuoteBefore = [select id, PrimaryQuote__c, Opportunity__c, MonthlyPremium__c, TotalPremiumAllVehicles__c, RecordType.Name, Opportunity__r.Monthly_Premium__c, 
                    Opportunity__r.Amount from Quote__c where id =:primaryQuote.id LIMIT 1];

            System.assertEquals(true, selectedQuoteBefore.PrimaryQuote__c, 'selectedQuoteBefore primaryQuote should be true');
            System.assertEquals(PRIMARY_AUTO_QUOTE_RECORD_TYPE_NAME, selectedQuoteBefore.RecordType.Name, 'selectedQuoteBefore record type should be '+PRIMARY_AUTO_QUOTE_RECORD_TYPE_NAME);
            System.assertEquals(600.00, selectedQuoteBefore.Opportunity__r.Monthly_Premium__c, 'selectedQuoteBefore Opportunity monthly premium should be 600.00');
            System.assertEquals(1200.00, selectedQuoteBefore.Opportunity__r.Amount, 'selectedQuoteBefore Opportunity amount should be 1200.00');
            
            CS001_ByPassTriggerAll__c objectBasedByPassTrigger = [Select id from CS001_ByPassTriggerAll__c limit 1];
            objectBasedByPassTrigger.Override_All__c = false;
            update objectBasedByPassTrigger;

            Test.startTest();
            delete primaryQuote;

            Opportunity optyAfterQuoteDelete = [select id, Monthly_Premium__c, Amount from opportunity where id=:opty.id LIMIT 1];

            System.assertEquals(null, optyAfterQuoteDelete.Monthly_Premium__c, 'optyAfterQuoteDelete monthly premium should be null');
            System.assertEquals(null, optyAfterQuoteDelete.Amount, 'optyAfterQuoteDelete amount should be null');
        }
    }
    //test method to verify quoteAfterDeleteException on deletion of Primary quote record as an Agent.
    @isTest
    private static void testExceptionOnPrimaryQuoteAfterDelete() {
        fetchTestData();
		assignPermissionSet(agentUser, QUOTE_MGMT_PERM_SET_NAME);   
        System.runAs(agentUser) {
            CS001_ByPassTriggerAll__c objectBasedByPassTrigger = [Select id from CS001_ByPassTriggerAll__c limit 1];
            objectBasedByPassTrigger.Override_All__c = false;
            update objectBasedByPassTrigger;

            List<ExceptionLog__c> exceptionLogBefore = [Select id from ExceptionLog__c where Class__c = 'AP_QuoteTrigger' and Method__c='syncOpportunityOnQuoteAfterDelete'];
            System.assert(exceptionLogBefore.isEmpty(), 'exceptionLogBefore should be empty');

            Test.startTest();
            List<Quote__c> quoteExceptionlist = new List<Quote__c>();
            quoteExceptionlist.add(buildQuoteRecord(null, quoteRecordTypeMap.get(AUTO_QUOTE_RECORD_TYPE_NAME).RecordTypeId, true));
            AP_QuoteTrigger qtTrigger = new AP_QuoteTrigger();
            qtTrigger.syncOpportunityOnQuoteAfterDelete(quoteExceptionlist);
            Test.stopTest();

            List<ExceptionLog__c> exceptionLogAfter = [Select id from ExceptionLog__c where Class__c = 'AP_QuoteTrigger' and Method__c='syncOpportunityOnQuoteAfterDelete'];
            System.assert(!exceptionLogAfter.isEmpty(), 'exceptionLogAfter should not be empty');
        }
    }


    //test method to verify primary got removed on quote afterUndelete, if the deleted Quote is Primary.
    @isTest
    private static void testremovePrimaryOnQuoteAfterUnDelete() {
        fetchTestData();
		assignPermissionSet(agentUser, QUOTE_MGMT_PERM_SET_NAME);
        
        System.runAs(agentUser) {
            Opportunity opty = buildOpportunityRecord(act.id, Date.newInstance(2015, 03, 16));
            insert opty;

            Quote__c primaryQuote = buildQuoteRecord(opty.id,quoteRecordTypeMap.get(PRIMARY_AUTO_QUOTE_RECORD_TYPE_NAME).RecordTypeId, true);
            insert primaryQuote;

            Quote__c selectedQuoteBefore = [select id, PrimaryQuote__c, Opportunity__c, RecordType.Name, Opportunity__r.Monthly_Premium__c, 
                    Opportunity__r.Amount from Quote__c where id =:primaryQuote.id LIMIT 1];

            System.assertEquals(true, selectedQuoteBefore.PrimaryQuote__c, 'selectedQuoteBefore primaryQuote should be true');
            System.assertEquals(PRIMARY_AUTO_QUOTE_RECORD_TYPE_NAME, selectedQuoteBefore.RecordType.Name, 'selectedQuoteBefore record type should be '+PRIMARY_AUTO_QUOTE_RECORD_TYPE_NAME);

            CS001_ByPassTriggerAll__c objectBasedByPassTrigger = [Select id from CS001_ByPassTriggerAll__c limit 1];
            objectBasedByPassTrigger.Override_All__c = false;
            update objectBasedByPassTrigger;

            delete primaryQuote;

            Test.startTest();
            undelete primaryQuote;

            Quote__c quoteAfterUnDelete = [select id, PrimaryQuote__c, RecordType.Name from Quote__c where id=:primaryQuote.id LIMIT 1];

            System.assertEquals(false, quoteAfterUnDelete.PrimaryQuote__c, 'quoteAfterUnDelete primaryQuote should be false');
            System.assertEquals(AUTO_QUOTE_RECORD_TYPE_NAME, quoteAfterUnDelete.RecordType.Name, 'quoteAfterUnDelete record type should be '+AUTO_QUOTE_RECORD_TYPE_NAME);
        }
    }

    //test method to verify quoteAfterUnDeleteException on Undeletion of Primary quote record as an Agent.
    @isTest
    private static void testremovePrimaryOnQuoteAfterUnDeleteForException() {
        fetchTestData();
		assignPermissionSet(agentUser, QUOTE_MGMT_PERM_SET_NAME);     

        System.runAs(agentUser) {
            Opportunity opty = buildOpportunityRecord(act.id, Date.newInstance(2015, 03, 16));
            insert opty;

            CS001_ByPassTriggerAll__c objectBasedByPassTrigger = [Select id from CS001_ByPassTriggerAll__c limit 1];
            objectBasedByPassTrigger.Override_All__c = false;
            update objectBasedByPassTrigger;

            List<Quote__c> quoteUndeletelist = new List<Quote__c>();
            quoteUndeletelist.add(buildQuoteRecord(opty.id, quoteRecordTypeMap.get(AUTO_QUOTE_RECORD_TYPE_NAME).RecordTypeId, true));

            AP_QuoteTrigger qtTrigger = new AP_QuoteTrigger();
            qtTrigger.syncOpportunityOnQuoteAfterDelete(quoteUndeletelist);

            List<ExceptionLog__c> exceptionLogBefore = [Select id from ExceptionLog__c where Class__c = 'AP_QuoteTrigger' and Method__c='removePrimaryOnQuoteAfterUnDelete'];
            System.assert(exceptionLogBefore.isEmpty(), 'exceptionLogBefore should be empty');

            Test.startTest();
            qtTrigger.processQuoteAfterUndelete(quoteUndeletelist);
            Test.stopTest();

            List<ExceptionLog__c> exceptionLogAfter = [Select id from ExceptionLog__c where Class__c = 'AP_QuoteTrigger' and Method__c='removePrimaryOnQuoteAfterUnDelete'];
            System.assert(!exceptionLogAfter.isEmpty(), 'exceptionLogAfter should not be empty');
        }
    }

    //test method to verify primary got removed on quote afterUndelete, if the deleted Quote is Primary. (bulk scenario)
    @isTest
    private static void testremovePrimaryOnQuoteAfterUnDeleteOnBulk() {
        fetchTestData();
		assignPermissionSet(agentUser, QUOTE_MGMT_PERM_SET_NAME);         

        System.runAs(agentUser) {
            Opportunity opty = buildOpportunityRecord(act.id, Date.newInstance(2015, 03, 16));
            insert opty;

            List<Quote__c> quotelist = new List<Quote__c>();
            for(Integer i=0; i<10; i++) {
                quotelist.add(buildQuoteRecord(opty.id, quoteRecordTypeMap.get(PRIMARY_AUTO_QUOTE_RECORD_TYPE_NAME).RecordTypeId, true ));
            }            
            insert quotelist;

            List<Quote__c> quoteBeforeUndelete = [select id, PrimaryQuote__c, RecordType.Name from Quote__c where Opportunity__c=:opty.id];
            for(integer i=0;i<quoteBeforeUndelete.size();i++) {
                System.assertEquals(true, quoteBeforeUndelete[i].PrimaryQuote__c, 'quoteBeforeUndelete['+i+'] primary quote should be true');
                System.assertEquals(PRIMARY_AUTO_QUOTE_RECORD_TYPE_NAME, quoteBeforeUndelete[i].RecordType.Name, 'quoteBeforeUndelete['+i+'] record type should be '+PRIMARY_AUTO_QUOTE_RECORD_TYPE_NAME);
            }

            CS001_ByPassTriggerAll__c objectBasedByPassTrigger = [Select id from CS001_ByPassTriggerAll__c limit 1];
            objectBasedByPassTrigger.Override_All__c = false;
            update objectBasedByPassTrigger;

            delete quotelist;

            AP_QuoteTrigger qtTrigger = new AP_QuoteTrigger();

            Test.startTest();
            qtTrigger.processQuoteAfterUndelete(quotelist);
            Test.stopTest();

            List<Quote__c> quoteAfterUnDelete = [select id, PrimaryQuote__c, RecordType.Name from Quote__c where Opportunity__c=:opty.id];
            for(integer i=0; i<quoteAfterUnDelete.size(); i++) {
                System.assertEquals(false, quoteAfterUnDelete[i].PrimaryQuote__c, 'quoteAfterUnDelete['+i+'] primary quote should be false');
                System.assertEquals(AUTO_QUOTE_RECORD_TYPE_NAME, quoteAfterUnDelete[i].RecordType.Name, 'quoteAfterUnDelete['+i+'] record type should be '+AUTO_QUOTE_RECORD_TYPE_NAME);
            }
        }
    }


    //test method to prevent undeleting duplicate Automatic Quote
    @isTest
    private static void testPreventUndeletingQuoteOnUndelete() {
        fetchTestData();
		assignPermissionSet(agentUser, QUOTE_MGMT_PERM_SET_NAME);

        System.runAs(agentUser) {
            Opportunity opty = buildOpportunityRecord(act.id, Date.newInstance(2020, 08, 12));
            insert opty;

            Quote__c primaryQuote = buildQuoteRecord(opty.id, quoteRecordTypeMap.get(PRIMARY_FIRE_QUOTE_RECORD_TYPE_NAME).RecordTypeId, true );
            primaryQuote.AttachMethod__c = 'Automatic';
            primaryQuote.LineOfBusiness__c = 'Fire';
            insert primaryQuote;

            CS001_ByPassTriggerAll__c objectBasedByPassTrigger = [Select id from CS001_ByPassTriggerAll__c limit 1];
            objectBasedByPassTrigger.Override_All__c = false;
            update objectBasedByPassTrigger;

            delete primaryQuote;

            Quote__c primaryQuote1 = buildQuoteRecord(opty.id, quoteRecordTypeMap.get(PRIMARY_FIRE_QUOTE_RECORD_TYPE_NAME).RecordTypeId, true);
            primaryQuote1.AttachMethod__c = 'Automatic';
            primaryQuote1.LineOfBusiness__c = 'Fire';
            insert primaryQuote1;

            Test.startTest();
            try {
                undelete primaryQuote;
                System.assert(true, 'Failed on Undelete');
            } catch(Exception e) {
                System.assert(e.getMessage().contains('You are not allowed to undelete the selected quote.'), 'Unexpected Exception Message');
            }
            Test.stopTest();
        }
    }

    //test method to prevent undeleting duplicate Automatic Quote
    @isTest
    private static void testQuoteMarkPrimaryOnBeforeInsert() {
		fetchTestData();
		assignPermissionSet(agentUser, QUOTE_MGMT_PERM_SET_NAME);
        System.runAs(agentUser) {
            Opportunity opty = buildOpportunityRecord(act.id, Date.newInstance(2020, 08, 12));
            insert opty;

            CS001_ByPassTriggerAll__c objectBasedByPassTrigger = [Select id from CS001_ByPassTriggerAll__c limit 1];
            objectBasedByPassTrigger.Override_All__c = false;
            update objectBasedByPassTrigger;

            Quote__c fireQuote = buildQuoteRecord(opty.id, quoteRecordTypeMap.get(FIRE_QUOTE_RECORD_TYPE_NAME).RecordTypeId, true);
            fireQuote.MonthlyPremium__c = 600.00;
            fireQuote.TotalPremiumAllVehicles__c = 1200.00;
            fireQuote.AttachMethod__c = 'Automatic';
            fireQuote.LineOfBusiness__c = 'Fire';

            Test.startTest();
            insert fireQuote;
            Test.stopTest();

            Quote__c quoteAfterInsert = [select id, PrimaryQuote__c, RecordType.Name, Opportunity__r.Monthly_Premium__c, Opportunity__r.StageName, Opportunity__r.Status__c, Opportunity__r.Amount from Quote__c where id=:fireQuote.id LIMIT 1];
           
            System.assertEquals(600.00, quoteAfterInsert.Opportunity__r.Monthly_Premium__c, 'quoteAfterInsert Opportunity monthly premium should be 600.00');
            System.assertEquals(1200.00, quoteAfterInsert.Opportunity__r.Amount, 'quoteAfterInsert Opportunity amount should be 1200.00');
            
        }
    }
    
    //test method to Sync Opportunity after Auto Automatic attach Quote
    @isTest
    private static void syncOpportunityOnAutomaticAutoQuote() {
        fetchTestData();
		assignPermissionSet(agentUser, QUOTE_MGMT_PERM_SET_NAME);
       // procIdUser = [Select id from User where username = 'QtMg1ProcId1User1ForFireQt1@sfa111.com' LIMIT 1];
        System.runAs(agentUser) {

            Opportunity opty = buildOpportunityRecord(act.id, Date.newInstance(2020, 08, 12));
            insert opty;
        	
            CS001_ByPassTriggerAll__c objectBasedByPassTrigger = [Select id from CS001_ByPassTriggerAll__c limit 1];
            objectBasedByPassTrigger.Override_All__c = false;
            update objectBasedByPassTrigger;

            Quote__c autoAutomaticQuote = buildQuoteRecord(opty.id, quoteRecordTypeMap.get(AUTO_QUOTE_RECORD_TYPE_NAME).RecordTypeId, false );
            autoAutomaticQuote.MonthlyPremium__c = 700.00;
            autoAutomaticQuote.TotalPremiumAllVehicles__c = 1100.00;
            autoAutomaticQuote.AttachMethod__c = 'Automatic';
            autoAutomaticQuote.LineOfBusiness__c = 'Auto';

            Test.startTest();
            insert autoAutomaticQuote;
            Test.stopTest();
        
            Quote__c quoteAfterInsert = [select id, PrimaryQuote__c, RecordType.Name, Opportunity__r.Monthly_Premium__c, Opportunity__r.StageName, Opportunity__r.Status__c, Opportunity__r.Amount from Quote__c where id=:autoAutomaticQuote.id LIMIT 1];

            System.assertEquals(false, quoteAfterInsert.PrimaryQuote__c, 'quoteAfterInsert primaryQuote should be false');
            System.assertEquals(AUTO_QUOTE_RECORD_TYPE_NAME, quoteAfterInsert.RecordType.Name, 'quoteAfterInsert record type should be '+AUTO_QUOTE_RECORD_TYPE_NAME);
            System.assertEquals(700.00, quoteAfterInsert.Opportunity__r.Monthly_Premium__c, 'quoteAfterInsert Opportunity monthly premium should be 700.00');
            System.assertEquals(1100.00, quoteAfterInsert.Opportunity__r.Amount, 'quoteAfterInsert Opportunity amount should be 1100.00');
                }
    }
}