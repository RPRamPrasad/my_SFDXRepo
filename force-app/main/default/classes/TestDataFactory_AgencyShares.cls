/*
* @author Team Kraken (kdcv)
* @description : Used to insert necessary data to do testing on Shares code
* @version 1.0
* @dateCreated 11/02/2020
*/
@isTest
public with sharing class TestDataFactory_AgencyShares extends UTIL_AgencyShares {
   
   public final static String ACCOUNT_ONE_LASTNAME = 'Riker';
   public final static String ACCOUNT_TWO_LASTNAME = 'Crusher';
   public final static String ACCOUNT_THREE_LASTNAME = 'Bashier';
   public final static String ACCOUNT_FOUR_LASTNAME = 'of Nine';
   public final static String ACCOUNT_FIVE_LASTNAME = 'of Ten';
   public final static String ACCOUNT_SIX_LASTNAME = 'O\'Brian';

   public final static String AGENT_ONE_EMAIL = 'Jean.Picard.entd@statefarm.com';
   public final static String AGENT_TWO_EMAIL = 'Ben.Sisko.ds9@statefarm.com';
   public final static String AGENT_THREE_EMAIL = 'Jonathan.Archer.nx01@statefarm.com';
   public final static String AGENT_FOUR_EMAIL = 'Kathryn.Janeway.abcd@statefarm.com';
   public final static String AGENT_FIVE_EMAIL = 'MyTest.LastName.qwer@statefarm.com';
   public final static String AGENT_SIX_EMAIL = 'Locutus.of.Borg@statefarm.com';

   public final static String PROXY_ONE_EMAIL = 'entd@statefarm.com';
   public final static String PROXY_TWO_EMAIL = 'ds9@statefarm.com';
   public final static String PROXY_THREE_EMAIL = 'nx01@statefarm.com';
   public final static String PROXY_FOUR_EMAIL = 'abcd@statefarm.com';
   public final static String PROXY_FIVE_EMAIL = 'qwer@statefarm.com';
   public final static String PROXY_SIX_EMAIL = 'loc.borg@statefarm.com';

   public final static Integer AGENT_ROLE_COUNT = 7;
   public final static String HOUSEHOLD_NAME = 'Household';
   public static final String HOUSEHOLD_RECORD_TYPE = 'IndustriesHousehold';
   public static final String INDIVIDUAL_RECORD_TYPE = 'Individual';
   private static final String AGENT = 'Agent';

   /**
     * @description : This method will be used to generate the Agent Role Data Object from the agent roles list. Once
     * this object has been instantiated with the desired data then we can  call our utility methods for
     * creating and deleting Agreement Risks directly.
     * @param agentRolesList
     * @return AgentRoleData
     */
    public static AgentRoleData populateAgentRoleDataObject(List<AgentRole__c> agentRolesList){

    
        Map<id,id>  agentRolesToAgentIds = new Map<id,id>();
        Map<id,id>  agentRolesToAccountIds = new Map<id,id>();
        Map<Id, Set<Id>> agentToAccountsAgentRoleMap = new Map<Id, Set<Id>> ();
        Map<Id, Id>  agentRolesToHouseholdIds = new Map<Id,Id>();
        Map<Id, Set<Id>> householdToAgentsAgentRoleMap = new Map<Id, Set<Id>> ();

        // Create a Map of Agent Roles and Agents/Agent Roles and Accounts.
        for(AgentRole__c agentRole: agentRolesList){

            agentRolesToAgentIds.put(agentRole.Id, agentRole.Agent__c);
            agentRolesToAccountIds.put(agentRole.Id, agentRole.Customer__c);

            if (agentToAccountsAgentRoleMap.containsKey(agentRole.Agent__c)) {
                agentToAccountsAgentRoleMap.get(agentRole.Agent__c).add(agentRole.Customer__c);
            } else {
                Set<Id> accounts = new Set<Id>();
                accounts.add(agentRole.Customer__c);
                agentToAccountsAgentRoleMap.put(agentRole.Agent__c,accounts);
            }

            if (agentRole.Primary_Household__c != null) {
                agentRolesToHouseholdIds.put(agentRole.Id, agentRole.Primary_Household__c);
                if (householdToAgentsAgentRoleMap.containsKey(agentRole.Primary_Household__c)) {
            		householdToAgentsAgentRoleMap.get(agentRole.Primary_Household__c).add(agentRole.Agent__c);
        		} else {
                    Set<Id> agents = new Set<Id>();
                    agents.add(agentRole.Agent__c);
                    householdToAgentsAgentRoleMap.put(agentRole.Primary_Household__c,agents);
        		}
            }
        }

        // Get a map of Agent's and there associated office/Proxy ID.
        Map<Id,Id> agentToProxyIds = getAgentProxyMap(agentRolesToAgentIds.values());

        // Use Agent Role Data object to limit parameters
        AgentRoleData agentRoleData = new AgentRoleData();
        agentRoleData.agentRoles = agentRolesList;
        agentRoleData.agentRolesToAccountIds = agentRolesToAccountIds;
        agentRoleData.agentToProxyIds = agentToProxyIds;
        agentRoleData.agentToAccountsAgentRoleMap = agentToAccountsAgentRoleMap;
        agentRoleData.agentRolesToHouseholdIds = agentRolesToHouseholdIds;
        agentRoleData.householdToAgentsAgentRoleMap = householdToAgentsAgentRoleMap;

        return agentRoleData;

    }




   /**
    * @description create data shares will have a boolean option to ignore agent role creation,
    * use overloading to default to true if no boolean is provided.
    */
   public static void createDataForSharesTesting() {
       createDataForSharesTesting(true);
   }



   /**
    * @description This is a generic method that will be used to create test data used by multiple tests.
    * @param generateAgentRoles  
    */
   public static void createDataForSharesTesting(boolean generateAgentRoles) {
       
       User systemAdmin = UTIL_UserProvisioning_TEST.buildSystemAdmin('1701B','systemUserTest2','systemUserTest2@statefarm.com'); 
       UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
       Id individualRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(INDIVIDUAL_RECORD_TYPE).getRecordTypeId();

       /**************************** Add Agents ****************************/
       User agentUser1;
       User agentUser2;
       User agentUser4;
       User agentUser5;
       User agentUser6;

       System.runAs(systemAdmin) {
           // Create User Roles    
           UserRole agentStandardUserRole = new UserRole(name='AgentRole');                    
           insert agentStandardUserRole;
           UserRole proxyStandardUserRole = new UserRole(name='ProxyRole', parentRoleId = agentStandardUserRole.id);
           insert proxyStandardUserRole;

           /**************************** Agent 1 ****************************/

           // Create Proxy/Office
           User testProxyUser1 = new User(Alias='Jean-Luc',LastName='Picard, ENTD, 46-1701-office',Username=PROXY_ONE_EMAIL,UserExternalID__c='123P',Servicing_Agent_Associate_ID__c='123');
           User proxyUser1 = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
           proxyUser1.userRoleId = proxyStandardUserRole.id; 
           Database.insert(proxyUser1);

           // Create Agent
           User testAgentUser1 = new User(Alias='Jean-Luc',LastName='Picard, ENTD, 46-1701',Username=AGENT_ONE_EMAIL,Associate_ID__c='123',UserExternalID__c='123_123',Servicing_Agent_Associate_ID__c='123');
           agentUser1 = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
           agentUser1.userRoleId = agentStandardUserRole.id;
           agentUser1.State_Agent_Code__c = '01-9999';
           agentUser1.SubUserType__c = AGENT;
           agentUser1.MasterUserRecord__c = true;
           Database.insert(agentUser1);
           agentUser1 = [SELECT id, email FROM User WHERE id=:agentUser1.id];

           /**************************** Agent 2 ****************************/

           // Create Proxy/Office
           testProxyUser1 = new User(Alias='Ben',LastName='Sisko, DS9, 46-1711-office',Username=PROXY_TWO_EMAIL,UserExternalID__c='456P',Servicing_Agent_Associate_ID__c='456P');
           User proxyUser2 = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
           proxyUser2.userRoleId = proxyStandardUserRole.id; 
           Database.insert(proxyUser2);

           // Create Agent
           testAgentUser1 = new User(Alias='Ben',LastName='Sisko, DS9, 46-1711',Username=AGENT_TWO_EMAIL,Associate_ID__c='456',UserExternalID__c='456_456',Servicing_Agent_Associate_ID__c='456');
           agentUser2 = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
           agentUser2.userRoleId = agentStandardUserRole.id;
           agentUser2.State_Agent_Code__c = '02-9999';
           agentUser2.SubUserType__c = AGENT;
           agentUser2.MasterUserRecord__c = true;
           Database.insert(agentUser2);
           agentUser2 = [SELECT id, email FROM User WHERE id=:agentUser2.id];

           /**************************** Agent 3 ****************************/

           // Create Proxy/Office
           testProxyUser1 = new User(Alias='Jonathan',LastName='Archer, NX01, 46-1700-office',Username=PROXY_THREE_EMAIL,UserExternalID__c='789P',Servicing_Agent_Associate_ID__c='789');
           User proxyUser3 = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
           proxyUser3.userRoleId = proxyStandardUserRole.id; 
           Database.insert(proxyUser3);

           // Create Agent
           testAgentUser1 = new User(Alias='Jonathan',LastName='Archer, NX01, 46-1700',Username=AGENT_THREE_EMAIL,Associate_ID__c='789',UserExternalID__c='789_789',Servicing_Agent_Associate_ID__c='789');
           User agentUser3 = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
           agentUser3.userRoleId = agentStandardUserRole.id;
           agentUser3.State_Agent_Code__c = '03-9999';
           agentUser3.SubUserType__c = AGENT;
           agentUser3.MasterUserRecord__c = true;
           Database.insert(agentUser3);

           /**************************** Agent 4 ****************************/

           // Create Proxy/Office
           testProxyUser1 = new User(Alias='Kathryn',LastName='Janeway, NX01, 12-345-office',Username=PROXY_FOUR_EMAIL,UserExternalID__c='456asdfP',Servicing_Agent_Associate_ID__c='456asdf');
           User proxyUser4 = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
           proxyUser4.userRoleId = proxyStandardUserRole.id; 
           Database.insert(proxyUser4);

           // Create Agent
           testAgentUser1 = new User(Alias='Kathryn',LastName='Janeway, NX01, 12-345',Username=AGENT_FOUR_EMAIL,Associate_ID__c='456asdf',UserExternalID__c='456asdf_456asdf',Servicing_Agent_Associate_ID__c='456asdf');
           agentUser4 = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
           agentUser4.userRoleId = agentStandardUserRole.id;
           agentUser4.State_Agent_Code__c = '04-9999';
           agentUser4.SubUserType__c = AGENT;
           Database.insert(agentUser4);
           agentUser4 = [SELECT Id, email FROM User WHERE id=:agentUser4.id];

           /**************************** Agent 5 SFO ****************************/

           //Create Proxy/Office
           testProxyUser1 = new User(Alias='Kathryn',LastName='JOHN, NX01, 12-346',Username=PROXY_FIVE_EMAIL,UserExternalID__c='help123P',Servicing_Agent_Associate_ID__c='help123');
           User proxyUser5 = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
           proxyUser5.userRoleId = proxyStandardUserRole.id; 
           Database.insert(proxyUser5);

           // Create Agent
           testAgentUser1 = new User(Alias='Agent 5',LastName='12-1234 SFO',Username=AGENT_FIVE_EMAIL,Associate_ID__c='help123',UserExternalID__c='help123_help123',Servicing_Agent_Associate_ID__c='help123');
           agentUser5 = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
           agentUser5.userRoleId = agentStandardUserRole.id;
           agentUser5.State_Agent_Code__c = '05-9999';
           agentUser5.SubUserType__c = 'SFO';
           agentUser5.MasterUserRecord__c = true;
           Database.insert(agentUser5);
           agentUser5 = [SELECT Id, email FROM User WHERE id=:agentUser5.id];

            /**************************** Agent 6 MSA (multi-state agent) ****************************/

           // Create Proxy/Office
           testProxyUser1 = new User(Alias='Proxy 6',LastName='FRED, NX01, 12-3469',Username=PROXY_SIX_EMAIL,UserExternalID__c='456asdf9P',Servicing_Agent_Associate_ID__c='456asd9');
           User proxyUser6 = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
           proxyUser6.userRoleId = proxyStandardUserRole.id; 
           Database.insert(proxyUser6);

           // Create Agent
           testAgentUser1 = new User(Alias='Agent 6',LastName='FRED, NX01, 12-3469',Username=AGENT_SIX_EMAIL,Associate_ID__c='456asdf9',UserExternalID__c='456asdf9_456asd9',Servicing_Agent_Associate_ID__c='456asd9');
           agentUser6 = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
           agentUser6.userRoleId = agentStandardUserRole.id;
           agentUser6.State_Agent_Code__c = '06-9999'; // this is primary state agent code
           agentUser6.State_Agent_Code_List__c = '11-1111,22-2222'; // Set other state agent codes since this agent is multi state
           agentUser6.Servicing_Agent_Associate_ID__c = '456asdf9';
           agentUser6.Associate_ID__c = '456asdf9';
           agentUser6.SubUserType__c = AGENT;
           agentUser6.MasterUserRecord__c = true;
           Database.insert(agentUser6);
           agentUser6 = [SELECT Id, email FROM User WHERE id=:agentUser6.id];
       }

       Account account1;
       Account account2;
       Account account3;
       Account account4;
       Account account5;
       Account account6;
        /**************************** Add Accounts ****************************/
       System.RunAs(agentUser1) {
           account1 = new Account(firstname ='Will', lastname=ACCOUNT_ONE_LASTNAME, ClientIdentifier__c = 'SFFSP81L8XA', recordTypeId=individualRecordTypeId);
           insert account1;

           account2 = new Account(firstname ='Beverly', lastname=ACCOUNT_TWO_LASTNAME, ClientIdentifier__c = 'SFFSP81L8XB', recordTypeId=individualRecordTypeId);
           insert account2;
       }

       System.RunAs(agentUser2) {
           account3 = new Account(firstname ='Julian', lastname=ACCOUNT_THREE_LASTNAME, ClientIdentifier__c = 'SFFSP81L8XC', recordTypeId=individualRecordTypeId);
           insert account3;
       } 

       System.RunAs(agentUser4) {
           account4 = new Account(firstname ='Seven', lastname=ACCOUNT_FOUR_LASTNAME, ClientIdentifier__c = 'SFFSP81L8XD', recordTypeId=individualRecordTypeId);
           insert account4;
       } 

        System.RunAs(agentUser5) {
            account5 = new Account(firstname ='Seven', lastname=ACCOUNT_FIVE_LASTNAME, ClientIdentifier__c = 'SFFSP81L8XE', recordTypeId=individualRecordTypeId);
            insert account5;
        } 

        System.RunAs(agentUser6) {
            account6 = new Account(firstname ='Miles', lastname=ACCOUNT_SIX_LASTNAME, ClientIdentifier__c = 'SFFSP81L8XF', recordTypeId=individualRecordTypeId);
            insert account6;
        } 
        generateCases(account1, account4);
       generateHouseholds(systemAdmin);
       /**************************** Create Five New Roles ****************************/
       if(generateAgentRoles){
       
           System.runAs(systemAdmin) {
            // Agent 1 has two accounts
            AgentRole__c newAgentRole1 = new AgentRole__c(customer__c=account1.id, Agent__c=agentUser1.id);
            AgentRole__c newAgentRole2 = new AgentRole__c(customer__c=account2.id, Agent__c=agentUser1.id);
            
            // Account 3 has Agent 2
            AgentRole__c newAgentRole3 = new AgentRole__c(customer__c=account3.id, Agent__c=agentUser2.id);
            
            // Account 3 also has Agent 4
            AgentRole__c newAgentRole3a = new AgentRole__c(customer__c=account3.id, Agent__c=agentUser4.id);
            
            // Account 4 has one Agent 4
            AgentRole__c newAgentRole4 = new AgentRole__c(customer__c=account4.id, Agent__c=agentUser4.id);
            
            AgentRole__c newAgentRole5 = new AgentRole__c(customer__c=account5.id, Agent__c=agentUser5.id);
            
            AgentRole__c newAgentRole6 = new AgentRole__c(customer__c=account6.id, Agent__c=agentUser6.id);
            
            List<AgentRole__c> newAgentRoles = new List<AgentRole__c>{ newAgentRole1,newAgentRole2,newAgentRole3,
                newAgentRole3a,newAgentRole4,newAgentRole5,newAgentRole6 };
            insert(newAgentRoles);
            }
       }
   }

   /**
    * @description This is a generic method that will be used to create test data for cases.
    * @param account1
    * @param account4
    */
    private static void generateCases(Account account1, Account account4) {
        /**************************** Create Account Cases ****************************/
       //User techSupport=AP_UserProvisioningProcess_TEST_UTIL.buildTechnicalsupportUserRecord(UTIL_TestUsername_TEST.getTestUsername('techSupportUser'),'TECH','4321TEST321','4321TEST321');
       User systemAdmin = UTIL_UserProvisioning_TEST.buildSystemAdmin('1702B','systemUserTest3','systemUserTest3@statefarm.com'); 
       List<case> newCases = new List<case>();

       case case1= new Case(Status = 'New', Case_Originator__c='Agent Office', AgentAssociateId__c = null, AccountId = account1.Id);
       newCases.add(case1);

       case case2= new Case(Status = 'New', Case_Originator__c='Agent Office', AgentAssociateId__c = null, AccountId = account4.Id);
       newCases.add(case2);

       system.runAs(systemAdmin){
           insert newCases;
       }
    }

   /**
    * @description This is a generic method that will be used to create test data for household.
    * @param systemAdmin
    */
   private static void generateHouseholds(User systemAdmin) {
    /**************************** Create Three New Household Accounts ****************************/
    Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(HOUSEHOLD_RECORD_TYPE).getRecordTypeId();
    System.RunAs(systemAdmin) {
        Account household1 = new Account(Name=HOUSEHOLD_NAME, recordTypeId=householdRecordTypeId, AllowHousehold__c = true);
        Account household2 = new Account(Name=HOUSEHOLD_NAME, recordTypeId=householdRecordTypeId, AllowHousehold__c = true);
        Account household3 = new Account(Name=HOUSEHOLD_NAME, recordTypeId=householdRecordTypeId, AllowHousehold__c = true);
        List<Account> lstHousehold = new List<Account>{ household1, household2, household3 };
        insert lstHousehold;
    }
   }

    /**
    * @description use provided account number, region code and source system id to create a Billing_Account__c Object
    * @param accountNumber
    * @param regionCode
    * @param sourceSystemId
    * @return Billing_Account__c
    */
    public static Billing_Account__c insertBillingAccountNoAgent(String accountNumber, String regionCode, String sourceSystemId) {
        Billing_Account__c billingAccount = new Billing_Account__c(AccountNumber__c = accountNumber, RegionCode__c = regionCode, SourceSystemIdentifier__c = sourceSystemId);
        insert billingAccount;
        return [SELECT Id, AccountNumber__c, SourceSystemIdentifier__c FROM Billing_Account__c WHERE SourceSystemIdentifier__c = :sourceSystemId];
    }

    
    /**
    * @description use provided billing account Id, insurance policy Id to create a Billing_Policy__c Object
    * @param insurancePolicyId
    * @param billingAccountId
    * @return Billing_Policy__c
    */
    public static Billing_Policy__c insertBillingPolicy(Id insurancePolicyId, Id billingAccountId) {
        String roCode = '12';

        Billing_Policy__c bp = new Billing_Policy__c(InsurancePolicyId__c = insurancePolicyId, BillingAccountID__c = billingAccountId, SourceSystemIdentifier__c = billingAccountId + '~' + roCode + '~' + insurancePolicyId);
        insert bp;
        return [
            SELECT Id, SourceSystemIdentifier__c, InsurancePolicyId__c, BillingAccountID__c 
            FROM Billing_Policy__c 
            WHERE InsurancePolicyId__c = :insurancePolicyId AND BillingAccountID__c = :billingAccountId
        ];
    }

    /**
    * @description use provided billing account Id, insurance policy Id to generate a Billing_Policy__c Object
    * @param insurancePolicyId
    * @param billingAccountId
    * @return Billing_Policy__c
    */
    public static Billing_Policy__c generateBillingPolicy(Id insurancePolicyId, Id billingAccountId) {
        String roCode = '12';
        return new Billing_Policy__c(InsurancePolicyId__c = insurancePolicyId, BillingAccountID__c = billingAccountId, SourceSystemIdentifier__c = billingAccountId + '~' + roCode + '~' + insurancePolicyId);
    }

    /**
     * @description InsertBillingParticipantWrapper
     */
    public class InsertBillingParticipantWrapper{
       public String billingAccountNumber; 
       public String regionCode; 
       public String clientId;
    }

    /**
    * @description use provided billing account Id, account Id, billing account number, region code, client Id to create a Billing_Participant__c Object
    * @param accountId
    * @param billingAccountId
    * @param insertWrap
    * @return Billing_Participant__c
    */
    public static Billing_Participant__c insertBillingParticipant(Id accountId, Id billingAccountId, InsertBillingParticipantWrapper insertWrap) {
        Billing_Participant__c billingParticipant = new Billing_Participant__c(ParticipantAccountId__c = accountId, BillingAccountID__c = billingAccountId, SourceSystemIdentifier__c = insertWrap.billingAccountNumber + '~' + insertWrap.regionCode + '~' + insertWrap.clientId);
        insert billingParticipant;
        return [
            SELECT Id, SourceSystemIdentifier__c, ParticipantAccountId__c, BillingAccountID__c 
            FROM Billing_Participant__c 
            WHERE ParticipantAccountId__c = :accountId AND BillingAccountID__c = :billingAccountId
        ];
    }

    /**
     * @description GenerateBillingParticipantWrapper
     */
    public class GenerateBillingParticipantWrapper{
        public String billingAccountNumber; 
        public String regionCode; 
        public String clientId;
    }

    /**
    * @description use provided billing account Id, account Id, billing account number, region code, client Id to generate a Billing_Participant__c Object
    * @param accountId
    * @param billingAccountId
    * @param generateWrap
    * @return Billing_Participant__c
    */
    public static Billing_Participant__c generateBillingParticipant(Id accountId, Id billingAccountId, GenerateBillingParticipantWrapper generateWrap) {
        return new Billing_Participant__c(ParticipantAccountId__c = accountId, BillingAccountID__c = billingAccountId, SourceSystemIdentifier__c = generateWrap.billingAccountNumber + '~' + generateWrap.regionCode + '~' + generateWrap.clientId); 
    }



   /**
    * @description use provided name and account ID to create an Insurance Policy Object
    * @param name
    * @param accountId
    * @return InsurancePolicy
    */
   public static InsurancePolicy insertPolicy(String name, Id accountId) {
       InsurancePolicy policy = new InsurancePolicy(Name = name, NameInsuredId = accountId);
       insert policy;
       return [SELECT Id, Name, NameInsuredId, Servicing_Agent__r.Name, Servicing_Agent__r.State_Agent_Code__c FROM InsurancePolicy WHERE Name = :name];
   }

   /**
    * @description use provided account ID and Policy ID to create an Insurance Policy Participant.
    * @param accountId
    * @param policyId
    * @return InsurancePolicyParticipant
    */
   public static InsurancePolicyParticipant insertParticipant(Id accountId, Id policyId) {
       InsurancePolicyParticipant participant = new InsurancePolicyParticipant(PrimaryParticipantAccountId = accountId, InsurancePolicyId = policyId, Role='Insured');
       insert participant;
       return [
           SELECT Id, PrimaryParticipantAccountId, InsurancePolicyId, InsurancePolicy.Servicing_Agent__r.State_Agent_Code__c, InsurancePolicy.Servicing_Agent__r.Name
           FROM InsurancePolicyParticipant 
           WHERE PrimaryParticipantAccountId = :accountId AND InsurancePolicyId = :policyId
       ];
   }

   /**
    * @description retrieve account 1
    * @return Account
    */
   public static Account getAccount1() {
       return [SELECT Id, name, lastname FROM Account WHERE lastname = :TestDataFactory_AgencyShares.ACCOUNT_ONE_LASTNAME].get(0);
   }

   /**
    * @description retrieve account 2
    * @return Account
    */
   public static Account getAccount2() {
       return [SELECT Id, name, lastname FROM Account WHERE lastname = :TestDataFactory_AgencyShares.ACCOUNT_TWO_LASTNAME].get(0);
   }

   /**
    * @description retrieve account 3
    * @return Account
    */
   public static Account getAccount3() {
       return [SELECT Id, name, lastname FROM Account WHERE lastname = :TestDataFactory_AgencyShares.ACCOUNT_THREE_LASTNAME].get(0);
   }

   /**
    * @description retrieve account 4
    * @return Account
    */
   public static Account getAccount4() {
       return [SELECT Id, name, lastname FROM Account WHERE lastname = :TestDataFactory_AgencyShares.ACCOUNT_FOUR_LASTNAME].get(0);
   }

   /**
    * @description retrieve account 5
    * @return Account
    */
    public static Account getAccount5() {
        return [SELECT Id, name, lastname FROM Account WHERE lastname = :TestDataFactory_AgencyShares.ACCOUNT_FIVE_LASTNAME].get(0);
    }

    /**
    * @description retrieve account 6
    * @return Account
    */
    public static Account getAccount6() {
        return [SELECT Id, name, lastname FROM Account WHERE lastname = :TestDataFactory_AgencyShares.ACCOUNT_SIX_LASTNAME].get(0);
    }

    /**
    * @description retrieve household 1
    * @return Account
    */
    public static Account gethousehold1() {
        return [SELECT Id, name, RecordType.Name FROM Account WHERE name = :TestDataFactory_AgencyShares.HOUSEHOLD_NAME].get(0);
    }
    
    /**
    * @description retrieve household 2
    * @return Account
    */
    public static Account gethousehold2() {
        return [SELECT Id, name, RecordType.Name FROM Account WHERE name = :TestDataFactory_AgencyShares.HOUSEHOLD_NAME].get(1);
    }
    
    /**
    * @description retrieve household 3
    * @return Account
    */
    public static Account gethousehold3() {
        return [SELECT Id, name, RecordType.Name FROM Account WHERE name = :TestDataFactory_AgencyShares.HOUSEHOLD_NAME].get(2);
    }
}
