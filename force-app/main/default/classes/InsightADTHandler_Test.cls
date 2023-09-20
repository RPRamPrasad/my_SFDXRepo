/**
@author Team Skynet
@name InsightADTHandler_Test
@createDate 5/8/2023
@description Handles testing for InsightADTHandler class
*/
@isTest
public with sharing class InsightADTHandler_Test {
    @TestVisible private static final String ACCOUNT_CLIENT_ID = '12345678915';
    private static User agentUser {get;set;}
    private static User sysAdmin {get;set;}

    @testSetup
    private static void testSetup(){
        TestUserSetupUtility.setupAgentOffice();
        TestUserSetupUtility.setupSystemAdminUser();

        System.runAs(TestUserSetupUtility.getSysAdminUser()){
            //Setup Configuration - Bypass Triggers
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(false,TestUserSetupUtility.getSysAdminUser());
            insert passTriggerAll;
            CS001_ByPassTriggerAtoF__c objectBasedByPassTrigger = UTIL_ByPassTrigger_TEST.buildBypassTriggerAtoF(TestUserSetupUtility.getSysAdminUser());

            insert objectBasedByPassTrigger;

            //Setup Users
            User  agentUser1 = TestUserSetupUtility.getAgentUser();
           
            
            agentUser = TestUserSetupUtility.getAgentUser();
            agentUSer.Servicing_Agent_Associate_ID__c = 'test01';
            agentUSer.FederationIdentifier = 'test01';
        
			update agentUSer;
			     
            sysAdmin = TestUserSetupUtility.getSysAdminUser();
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);

            //Setup Permission Sets
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Insights_Permset'];
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'Insurance_W'];
            PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'InsightsAdt'];
            insert new PermissionSetAssignment(AssigneeId = agentUser.id, PermissionSetId = ps.Id);
            insert new PermissionSetAssignment(AssigneeId = sysAdmin.id, PermissionSetId = ps.Id);
            insert new PermissionSetAssignment(AssigneeId = agentUser.id, PermissionSetId = ps1.Id);
             insert new PermissionSetAssignment(AssigneeId = sysAdmin.id, PermissionSetId = ps1.Id);
             insert new PermissionSetAssignment(AssigneeId = agentUser.id, PermissionSetId = ps2.Id);
             insert new PermissionSetAssignment(AssigneeId = sysAdmin.id, PermissionSetId = ps2.Id);
        }
    }

    @TestVisible private static Account createAccountIL(){
        Account accountRecord = new Account(Edit_In_VFP__c=true,FirstName='fstName',LastName='lstName',
                                            BillingAddressType__c='US',BillingCity='Bloomington',BillingState='IL',
                                            ClientIdentifier__c=ACCOUNT_CLIENT_ID,
                                           PersonDoNotCall=false, DoNotMail__c=false, HasPermissionToMarketingEmail__c ='Yes');
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        insert accountRecord;
        return accountRecord;
    }

    @TestVisible public static void createHouseholdPolicy(Account acc,string agentuserID,Boolean createprimaryPartipant){
        InsurancePolicy insurPolicy = new InsurancePolicy(Name='policy890',NameInsuredId=acc.Id,policyName='Homeowners policy');
        if(agentuserID != null){
            insurPolicy.Servicing_Agent__c= agentuserID;
        }
        insert insurPolicy;
        InsurancePolicyParticipant participant =  new InsurancePolicyParticipant(
            RoleNameCd__c = '12',
            SecondaryRoleNameCd__c = '29',
           
            InsurancePolicyId = insurPolicy.Id,
            Role = 'Insured Party'
        );
        
        if(createprimaryPartipant){
             participant.PrimaryParticipantAccountId = acc.ID;
        }else{
            participant.RelatedParticipantAccountId = acc.ID;
        }
        insert participant;
       
    }


    @TestVisible private static Account createAccountIN(){
        Account accountRecord = new Account(Edit_In_VFP__c=true,FirstName='AstName',LastName='lstName',
                                            BillingAddressType__c='US',BillingCity='Boone',BillingState='IN',
                                            ClientIdentifier__c=ACCOUNT_CLIENT_ID,
                                           PersonDoNotCall=false, DoNotMail__c=false, HasPermissionToMarketingEmail__c ='Yes');
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        insert accountRecord;
        return accountRecord;
    }

    @TestVisible private static Account createAccountPA(){
        Account accountRecord = new Account(Edit_In_VFP__c=true,FirstName='AstName',LastName='lstName',
                                            BillingAddressType__c='US',BillingCity='Large', BillingState='PA',
                                            ClientIdentifier__c=ACCOUNT_CLIENT_ID,
                                           PersonDoNotCall=false, DoNotMail__c=false, HasPermissionToMarketingEmail__c ='Yes');
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        insert accountRecord;
        return accountRecord;
    }

    @TestVisible private static Account createAccountNotPilotState(){
        Account accountRecord = new Account(Edit_In_VFP__c=true,FirstName='AstName',LastName='lstName',
                                            BillingAddressType__c='US',BillingCity='Fake', BillingState='GA',
                                            ClientIdentifier__c=ACCOUNT_CLIENT_ID);
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        insert accountRecord;
        return accountRecord;
    }



    @isTest
    public static void testADTILAccount() {
        User agent_User = TestUserSetupUtility.getAgentUser();
        Boolean isADTEligible;
        List<Account> accList = new List<Account>();
        Test.startTest();
	
        Account accountRecord = createAccountIL();
            createHouseholdPolicy(accountRecord,agent_User.Id,true);
            Account acc  = [SELECT Id, BillingState, DoNotMail__c, HasPermissionToMarketingEmail__c, PersonDoNotCall,
            (SELECT Id,InsurancePolicy.Servicing_Agent__c FROM PrimaryParticipants  ),
            (SELECT Id,InsurancePolicy.Servicing_Agent__c FROM RelatedParticipants)
         					FROM Account WHERE Id=: accountRecord.Id];
           accList.add(acc); 
        System.runAs(agent_User) {
            
            isADTEligible = InsightADTHandler.isADTEligible(accList);
        }
        Test.stopTest();

        System.assertEquals(true, isADTEligible, 'Unexpected eligibility');
    }
    
     @isTest
    public static void testADTILAccount1() {
        User agent_User = TestUserSetupUtility.getAgentUser();
        Boolean isADTEligible;
        List<Account> accList = new List<Account>();
        Test.startTest();
	
        Account accountRecord = createAccountIL();
            createHouseholdPolicy(accountRecord,null,true);
            Account acc  = [SELECT Id, BillingState, DoNotMail__c, HasPermissionToMarketingEmail__c, PersonDoNotCall,
            (SELECT Id,InsurancePolicy.Servicing_Agent__c FROM PrimaryParticipants  ),
            (SELECT Id,InsurancePolicy.Servicing_Agent__c FROM RelatedParticipants)
         					FROM Account WHERE Id=: accountRecord.Id];
        
            accList.add(acc); 
        System.runAs(agent_User) {
            
            isADTEligible = InsightADTHandler.isADTEligible(accList);
        }
        Test.stopTest();

        System.assertEquals(false, isADTEligible, 'Unexpected eligibility');
    }
    


    @isTest
    public static void testADTINAccount() {
        User agent_User = TestUserSetupUtility.getAgentUser();
        Boolean isADTEligible;
        List<Account> accList = new List<Account>();
        Test.startTest();

        System.runAs(agent_User) {
            Account accountRecord = createAccountIN();
            createHouseholdPolicy(accountRecord,agent_User.Id,false);

            Account acc  = [SELECT Id, BillingState, DoNotMail__c, HasPermissionToMarketingEmail__c, PersonDoNotCall,
     						(SELECT policyName FROM InsurancePolicies )
         					FROM Account WHERE Id=: accountRecord.Id];
          
            accList.add(acc);
            isADTEligible = InsightADTHandler.isADTEligible(accList);
        }
        Test.stopTest();

        System.assertEquals(false, isADTEligible, 'Unexpected eligibility');
    }

    @isTest
    public static void testADTPAAccount() {
        User agent_User = TestUserSetupUtility.getAgentUser();
        Boolean isADTEligible;
        List<Account> accList = new List<Account>();
        Test.startTest();

        System.runAs(agent_User) {
             Account accountRecord = createAccountPA();
             createHouseholdPolicy(accountRecord,agent_User.Id,false);
             Account acc  = [SELECT Id, BillingState, DoNotMail__c, HasPermissionToMarketingEmail__c, PersonDoNotCall,
     						(SELECT policyName FROM InsurancePolicies )
         					FROM Account WHERE Id=: accountRecord.Id];
            accList.add(acc);
            isADTEligible = InsightADTHandler.isADTEligible(accList);
        }
        Test.stopTest();

        System.assertEquals(false, isADTEligible, 'Unexpected eligibility');
    }

    @isTest
    public static void testADTAccountNotPilotState() {
        User agent_User = TestUserSetupUtility.getAgentUser();
        Boolean isADTEligible;
        List<Account> accList = new List<Account>();
        Test.startTest();

        System.runAs(agent_User) {
            Account accountRecord = createAccountNotPilotState();
            accList.add(accountRecord);
            isADTEligible = InsightADTHandler.isADTEligible(accList);
        }
        Test.stopTest();

        System.assertEquals(false, isADTEligible, 'Unexpected eligibility');
    }


}