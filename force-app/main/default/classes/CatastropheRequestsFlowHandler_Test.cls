/**
 * @description Test Class for the CatastropheRequestsFlowHandler class.
 *
 * @author Kiko Ferrer (VAD63S)
 * @version 1.0, 05/31/23
 * @see CatastropheRequestsFlowHandler
 * @since 1.0
*/
@IsTest
private with sharing class CatastropheRequestsFlowHandler_Test {
    // System admin fields
    private static final String SYSTEM_ADMIN_EMAIL = 'testsystemadminuser@statefarm.com';
    private static final String SYSTEM_ADMIN_PROFILE_NAME = 'System Administrator';
    private static final String SYSTEM_ADMIN_LAST_NAME = 'systemAdmin';
    private static final String SYSTEM_ADMIN_USERNAME = 'systemAdminTest@statefarm.com';
    private static final String SYSTEM_ADMIN_ALIAS = 'VAD00X';
    // Agent admin fields
    private static final String AGENT_EMAIL = 'testagent@statefarm.com';
    private static final String AGENT_PROFILE_NAME = '2.00 Agent';
    private static final String AGENT_LAST_NAME = 'agent';
    private static final String AGENT_USERNAME = 'agentTest@statefarm.com';
    private static final String AGENT_ALIAS = 'PNN00N';
    // User no access fields
    private static final String NO_ACCESS_EMAIL = 'noaccessuser@statefarm.com';
    private static final String NO_ACCESS_PROFILE_NAME = '1.02 No Access';
    private static final String NO_ACCESS_LAST_NAME = 'noAccess';
    private static final String NO_ACCESS_USERNAME = 'noAccessTest@statefarm.com';
    private static final String NO_ACCESS_ALIAS = 'WSN00P';
    // Account (Individual) fields
    private static final String INDIVIDUAL_RECORD_TYPE = 'Individual';
    private static final String ACC_LAST_NAME = 'Doe';
    private static final String ACC_FIRST_NAME = 'John';
    private static final String ACC_CLIENT_IDENT = 'SFFSP81LZYX';
    // Account (individual) fields (standalone)
    private static final String ACC2_LAST_NAME = 'Jany';
    private static final String ACC2_FIRST_NAME = 'May';
    private static final String ACC2_CLIENT_IDENT = 'SFFSP81LNNN';
    // Insurance Policy fields
    private static final String INSURANCE_POLICY_AUTO_NAME = '247 7576-A08-03'; // Arizona AZ (03)
    private static final String INSURANCE_POLICY_FIRE_NAME = '15-IH-J400-3';
    private static final String INSURANCE_POLICY_LIFE_NAME = 'LF-6900-1110';
    private static final String INSURANCE_POLICY_HEALTH_NAME = 'H1234567 8605'; // 86: Servicing State Code |  05: Writing State Code
    // Billing Policy fields
    private static final String BILL_POLI_NAME_AUTO = 'Billing Policy Auto';
    private static final String BILL_POLI_NAME_FIRE = 'Billing Policy Fire';
    private static final String BILL_POLI_NAME_LIFE = 'Billing Policy Life';
    private static final String BILL_POLI_NAME_HEALTH = 'Billing Policy Health';
    // Billing Account fields
    private static final String BILL_ACC_NUM_AUTO = '1331330151';
    private static final String BILL_ACC_NUM_FIRE = '0001330876';
    private static final String BILL_ACC_NUM_LIFE = '1119897899';
    private static final String BILL_ACC_NUM_HEALTH = '9897977778';
    // Billing Participant fields
    private static final String BILL_PAR_NAME_AUTO = 'Bill Participant Auto';
    private static final String BILL_PAR_NAME_FIRE = 'Bill Participant Fire';
    private static final String BILL_PAR_NAME_LIFE = 'Bill Participant Life';
    private static final String BILL_PAR_NAME_HEALTH = 'Bill Participant Health';
    // Catastrophe fields (Cat_Status__c, State__c)
    private static final String CAT_AZ_NAME = 'Tornamde AZ';
    private static final String CAT_IL_NAME = 'Hurricane IL';
    // Open from Arizona (AZ) and from Illinois (IL)

    /**
     * @description Setup method used to create records to be reused accross the different test methods.
     * 
     */
    @testSetup
    private static void setup(){
        // Create user with permissions
        User systemAdminUser = new User(ProfileId=[SELECT Id FROM Profile WHERE Name = :SYSTEM_ADMIN_PROFILE_NAME].Id,
                                        LastName=SYSTEM_ADMIN_LAST_NAME,
                                        UserName=SYSTEM_ADMIN_USERNAME,
                                        Alias=SYSTEM_ADMIN_ALIAS,
                                        Email=SYSTEM_ADMIN_EMAIL,
                                        TimeZoneSidKey='Europe/London',
                                        LocaleSidKey='en_US',
                                        EmailEncodingKey='UTF-8',
                                        LanguageLocaleKey='en_US');
        insert systemAdminUser;
        
        // Bypass triggers for to be able to create test data
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemAdminUser.id);            
        insert sysAdminUserIdSetting;

        // Create Agent User
        User agentUser = new User(ProfileId=[SELECT Id FROM Profile WHERE Name = :AGENT_PROFILE_NAME].Id,
                                        LastName=AGENT_LAST_NAME,
                                        UserName=AGENT_USERNAME,
                                        Alias=AGENT_ALIAS,
                                        Email=AGENT_EMAIL,
                                        TimeZoneSidKey='Europe/London',
                                        LocaleSidKey='en_US',
                                        EmailEncodingKey='UTF-8',
                                        LanguageLocaleKey='en_US');
        insert agentUser;
        
        // Create user without permissions
        User noPermissionUser = new User(ProfileId=[SELECT Id FROM Profile WHERE Name = :NO_ACCESS_PROFILE_NAME].Id,
                                        LastName=NO_ACCESS_LAST_NAME,
                                        UserName=NO_ACCESS_USERNAME,
                                        Alias=NO_ACCESS_ALIAS,
                                        Email=NO_ACCESS_EMAIL,
                                        TimeZoneSidKey='Europe/London',
                                        LocaleSidKey='en_US',
                                        EmailEncodingKey='UTF-8',
                                        LanguageLocaleKey='en_US');
        insert noPermissionUser;
        
        // Create Individual Account
        System.runAs(systemAdminUser) {
            Id individualRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
            Id individualAccountId;
            Account individualAccount = new Account(recordTypeId=individualRecordTypeId, FirstName=ACC_FIRST_NAME, LastName=ACC_LAST_NAME, 
                                                    ClientIdentifier__c=ACC_CLIENT_IDENT, AllowHousehold__c = false, 
                                                    BillingAddressType__c='US', BillingStreet='1234 Main St', BillingCity='Bloomington', BillingState='IL', 
                                                    BillingPostalCode='61704', BillingCountry='UNITED STATES');
            Account individualAccount2 = new Account(recordTypeId=individualRecordTypeId, FirstName=ACC2_FIRST_NAME, LastName=ACC2_LAST_NAME, 
                                                    ClientIdentifier__c=ACC2_CLIENT_IDENT, AllowHousehold__c = false, 
                                                    BillingAddressType__c='US', BillingStreet='8888 State St', BillingCity='Autin', BillingState='TX', 
                                                    BillingPostalCode='61784', BillingCountry='UNITED STATES');
            individualAccountId = Database.insert(individualAccount).getId();
            insert individualAccount2;
            // Add Agent to Individual Account's Agent Role
            AgentRole__c agentRoleIndividualAccount = new AgentRole__c(Customer__c=individualAccount.Id, Agent__c=agentUser.Id);
            insert agentRoleIndividualAccount;
            AgentRole__c agentRoleIndividualAccount2 = new AgentRole__c(Customer__c=individualAccount2.Id, Agent__c=agentUser.Id);
            insert agentRoleIndividualAccount2;
            
            
            // Create Auto and Fire Insurance Policy
            Id insurancePolicyAutoId;
            Id insurancePolicyFireId; 
            Id insurancePolicyLifeId; 
            Id insurancePolicyHealthId;
            InsurancePolicy insurancePolicyAuto = new InsurancePolicy(Name=INSURANCE_POLICY_AUTO_NAME, NameInsuredId=individualAccountId, 
                                                    PolicyType='Auto', PolicyDescription='Insurance policy Auto');
            InsurancePolicy insurancePolicyFire = new InsurancePolicy(Name=INSURANCE_POLICY_FIRE_NAME, NameInsuredId=individualAccountId, 
                                                    PolicyType='Fire', PolicyDescription='Insurance policy Fire'); 
            InsurancePolicy insurancePolicyLife = new InsurancePolicy(Name=INSURANCE_POLICY_LIFE_NAME, NameInsuredId=individualAccountId, 
                                                    PolicyType='Life', PolicyDescription='Insurance policy Life'); 
            InsurancePolicy insurancePolicyHealth = new InsurancePolicy(Name=INSURANCE_POLICY_HEALTH_NAME, NameInsuredId=individualAccountId, 
                                                    PolicyType='Health', PolicyDescription='Insurance policy Health');                                          
            insurancePolicyAutoId = Database.insert(insurancePolicyAuto).getId();
            insurancePolicyFireId = Database.insert(insurancePolicyFire).getId();
            insurancePolicyLifeId = Database.insert(insurancePolicyLife).getId();
            insurancePolicyHealthId = Database.insert(insurancePolicyHealth).getId();
            // Create Insurance Policy Participant
            InsurancePolicyParticipant insurancePolicyAutoPartic = new InsurancePolicyParticipant(InsurancePolicyId=insurancePolicyAutoId, 
                                                                    PrimaryParticipantAccountId=individualAccountId, Role='Owner');
            InsurancePolicyParticipant insurancePolicyFirePartic = new InsurancePolicyParticipant(InsurancePolicyId=insurancePolicyFireId,
                                                                    PrimaryParticipantAccountId=individualAccountId, Role='Owner');
            InsurancePolicyParticipant insurancePolicyLifePartic = new InsurancePolicyParticipant(InsurancePolicyId=insurancePolicyLifeId, 
                                                                    PrimaryParticipantAccountId=individualAccountId, Role='Owner');
            InsurancePolicyParticipant insurancePolicyHealthPartic = new InsurancePolicyParticipant(InsurancePolicyId=insurancePolicyHealthId,
                                                                     PrimaryParticipantAccountId=individualAccountId, Role='Owner');
            insert insurancePolicyAutoPartic;
            insert insurancePolicyFirePartic;
            insert insurancePolicyLifePartic;
            insert insurancePolicyHealthPartic;                                                                                                               
            // Create Billing Accounts
            Id billAccAutoId;
            Id billAccFireId;
            Id billAccLifeId;
            Id billAccHealthId;
            Billing_Account__c billAccAuto = new Billing_Account__c(AccountNumber__c=BILL_ACC_NUM_AUTO, Name=BILL_ACC_NUM_AUTO,
                                                                    SourceSystemIdentifier__c=BILL_ACC_NUM_AUTO, SourceSystem__c='SF Billing', 
                                                                    Status__c='Active');
            Billing_Account__c billAccFire = new Billing_Account__c(AccountNumber__c=BILL_ACC_NUM_FIRE, Name=BILL_ACC_NUM_FIRE,
                                                                    SourceSystemIdentifier__c=BILL_ACC_NUM_FIRE,SourceSystem__c='SF Billing', 
                                                                    Status__c='Active');  
            Billing_Account__c billAccLife = new Billing_Account__c(AccountNumber__c=BILL_ACC_NUM_LIFE, Name=BILL_ACC_NUM_LIFE,
                                                                    SourceSystemIdentifier__c=BILL_ACC_NUM_LIFE,SourceSystem__c='SF Billing', 
                                                                    Status__c='Active');
            Billing_Account__c billAccHealth = new Billing_Account__c(AccountNumber__c=BILL_ACC_NUM_HEALTH, Name=BILL_ACC_NUM_HEALTH,
                                                                      SourceSystemIdentifier__c=BILL_ACC_NUM_HEALTH,SourceSystem__c='SF Billing', 
                                                                      Status__c='Active');                                                                                                                                  
            billAccAutoId = Database.insert(billAccAuto).getId();
            billAccFireId = Database.insert(billAccFire).getId();
            billAccLifeId = Database.insert(billAccLife).getId();
            billAccHealthId = Database.insert(billAccHealth).getId();
            // Create Billing Policies
            Billing_Policy__c billPolAuto = new Billing_Policy__c(BillingAccountID__c=billAccAutoId, Name=BILL_POLI_NAME_AUTO,
                                                                InsurancePolicyId__c=insurancePolicyAutoId, 
                                                                SourceSystemIdentifier__c='9831330151~205745599',
                                                                PolicyActive__c = true);
            Billing_Policy__c billPolFire = new Billing_Policy__c(BillingAccountID__c=billAccFireId, Name=BILL_POLI_NAME_FIRE,
                                                                InsurancePolicyId__c=insurancePolicyFireId,  
                                                                SourceSystemIdentifier__c='1331330151~205745588',
                                                                PolicyActive__c = true);
            Billing_Policy__c billPolLife = new Billing_Policy__c(BillingAccountID__c=billAccLifeId, Name=BILL_POLI_NAME_LIFE,
                                                                InsurancePolicyId__c=insurancePolicyLifeId,  
                                                                SourceSystemIdentifier__c='0013330151~205745577',
                                                                PolicyActive__c = true);
            Billing_Policy__c billPolHealth = new Billing_Policy__c(BillingAccountID__c=billAccHealthId, Name=BILL_POLI_NAME_HEALTH,
                                                                  InsurancePolicyId__c=insurancePolicyHealthId,  
                                                                  SourceSystemIdentifier__c='9991330151~205745566',
                                                                   PolicyActive__c = true);                                                                
            insert billPolAuto;
            insert billPolFire;
            insert billPolLife;
            insert billPolHealth;
            // Create Billing Participants
            Billing_Participant__c billPartAuto = new Billing_Participant__c(BillingAccountID__c=billAccAutoId, Name=BILL_PAR_NAME_AUTO,
                                                                            ParticipantAccountId__c=individualAccountId,
                                                                            SourceSystemIdentifier__c='9991330151~BH4NKBKGPPP');
            Billing_Participant__c billPartFire = new Billing_Participant__c(BillingAccountID__c=billAccFireId, Name=BILL_PAR_NAME_FIRE,
                                                                            ParticipantAccountId__c=individualAccountId,
                                                                            SourceSystemIdentifier__c='1331330151~BH4NKBKGTYC');
            Billing_Participant__c billPartLife = new Billing_Participant__c(BillingAccountID__c=billAccLifeId, Name=BILL_PAR_NAME_LIFE,
                                                                            ParticipantAccountId__c=individualAccountId,
                                                                            SourceSystemIdentifier__c='8881330151~BH4NKBKGNNS');
            Billing_Participant__c billPartHealth = new Billing_Participant__c(BillingAccountID__c=billAccHealthId, Name=BILL_PAR_NAME_HEALTH,
                                                                              ParticipantAccountId__c=individualAccountId,
                                                                              SourceSystemIdentifier__c='0001330151~BH4NKBKGYYY');
            insert billPartAuto;
            insert billPartFire;
            insert billPartLife;
            insert billPartHealth;
            // Create Catastrophes
            Catastrophe__c tornadoAZ = new Catastrophe__c(Name=CAT_AZ_NAME, State__c='AZ', Start_Date__c = Date.today()-1, End_Date__c = Date.today()+1);
            Catastrophe__c hurriIL = new Catastrophe__c(Name=CAT_IL_NAME, State__c='IL', Start_Date__c = Date.today()-1, End_Date__c = Date.today()+1);
            insert tornadoAZ;
            insert hurriIL;
        }
    }

    /**
     * @description Method that test a successfull call to the billAccsWithOpenCats() method.
     * 
     * @see CatastropheRequestsFlowHandler#billAccsWithOpenCats()
     */
    @isTest
    static void billAccsWithOpenCatsWithAccess() {
        User systemAdminUser = [Select Id, ProfileId FROM User WHERE LastName = :SYSTEM_ADMIN_LAST_NAME LIMIT 1];
        PermissionSet billingWPermSet = [SELECT Id FROM PermissionSet WHERE Name = 'Billing_W' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId=systemAdminUser.id, PermissionSetId=billingWPermSet.Id);
        
        Id accountId = [SELECT Id FROM Account WHERE FirstName = :ACC_FIRST_NAME LIMIT 1].Id;
        List<String> billingAccNumbs = new List<String>();
        List<String> expectedBillingAccNumbs = new List<String>();
        expectedBillingAccNumbs.add('1331330151');
        expectedBillingAccNumbs.add('0001330876');
        expectedBillingAccNumbs.add('1119897899');
        expectedBillingAccNumbs.add('9897977778');
        // For Flow Handler
        List<CatastropheRequestsFlowHandler.InputVariables> inputVariables = new List<CatastropheRequestsFlowHandler.InputVariables>();
        CatastropheRequestsFlowHandler.InputVariables inputVariable = new CatastropheRequestsFlowHandler.InputVariables();
        inputVariable.accountId = accountId;
        inputVariables.add(inputVariable);
        System.runAs(systemAdminUser) {
            Test.startTest();
            List<CatastropheRequestsFlowHandler.OutputVariables> outputList = CatastropheRequestsFlowHandler.billAccsWithOpenCats(inputVariables);
            billingAccNumbs = outputList.get(0).billingAccounts;
            Test.stopTest();
            System.assertEquals(expectedBillingAccNumbs, billingAccNumbs, 'Expected billing accounts does not match');
        }       
    }
}