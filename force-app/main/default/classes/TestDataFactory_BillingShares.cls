/**
* @author: Stephen White YCDB, Jonathan Larkin VAASTT
* @description : Used to generate Test Data for Billing Shares
* @version 1.0
* @dateCreated 10/25/2021
*/
@isTest
public with sharing class TestDataFactory_BillingShares extends UTIL_AgencyShares {

    public static final String INDIVIDUAL_RECORD_TYPE = 'Individual';

    public final static String ACCOUNT_ONE_LASTNAME = 'Riker';
    public final static String ACCOUNT_TWO_LASTNAME = 'Crusher';
    public final static String ACCOUNT_THREE_LASTNAME = 'Bashier';
    public final static String ACCOUNT_FOUR_LASTNAME = 'Smough';
    public final static String ACCOUNT_FIVE_LASTNAME = 'Mcluvvin';
    public final static String ACCOUNT_SIX_LASTNAME = 'Gwyn';

    public final static String AGENT_ONE_EMAIL = 'jean.picard.entd@statefarm.com';
    public final static String AGENT_TWO_EMAIL = 'ben.sisko.ds9@statefarm.com';
    public final static String AGENT_THREE_EMAIL = 'chris.farley.cf0@statefarm.com';
    public final static String AGENT_FOUR_EMAIL = 'stan.lee.sl0@statefarm.com';

    public final static String PROXY_ONE_EMAIL = 'entd@statefarm.com';
    public final static String PROXY_TWO_EMAIL = 'ds9@statefarm.com';
    public final static String PROXY_THREE_EMAIL = 'cf0@statefarm.com';
    public final static String PROXY_FOUR_EMAIL = 'sl0@statefarm.com';
    private static final String AGENT = 'Agent';


    /**
     * @description <etjpd tp Gemerate All Data for Billing Testing.
     */
    public static void generateBillingShareTestData(){

        UTIL_UserProvisioning_TEST.buildSystemAdmin('1701B','systemUserTest2','systemUserTest2@statefarm.com'); 
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get(INDIVIDUAL_RECORD_TYPE).getRecordTypeId();
 
        generateAgentData();
        generateAccountData();
        generateBillingAccountsAndParticipants();
        TestDataFactory_BillingSharesPolicy.generateBillingShareInsurancePolicyTestData();
    }

    /**
     * @description Method to Generate Agent Data for Testing.
     */
    private static void generateAgentData(){

        User systemAdmin = UTIL_UserProvisioning_TEST.buildSystemAdmin('1701B','systemUserTest2','systemUserTest2@statefarm.com'); 
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();

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
            User agentUser1 = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
            agentUser1.userRoleId = agentStandardUserRole.id;
            agentUser1.State_Agent_Code__c = '01-9999';
            agentUser1.SubUserType__c = AGENT;
            agentUser1.MasterUserRecord__c = true;
            Database.insert(agentUser1);
            agentUser1 = [SELECT id, email FROM User WHERE id=:agentUser1.id];

            /**************************** Agent 2 ****************************/

            // Create Proxy/Office
            testProxyUser1 = new User(Alias='Jean-Luc',LastName='Sisko, DS9, 46-1711-office',Username=PROXY_TWO_EMAIL,UserExternalID__c='456P',Servicing_Agent_Associate_ID__c='456');
            User proxyUser2 = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser2.userRoleId = proxyStandardUserRole.id; 
            Database.insert(proxyUser2);

            // Create Agent
            testAgentUser1 = new User(Alias='Ben',LastName='Sisko, DS9, 46-1711',Username=AGENT_TWO_EMAIL,Associate_ID__c='456',UserExternalID__c='456_456',Servicing_Agent_Associate_ID__c='456');
            User agentUser2 = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
            agentUser2.userRoleId = agentStandardUserRole.id;
            agentUser2.State_Agent_Code__c = '02-9999';
            agentUser2.SubUserType__c = AGENT;
            agentUser2.MasterUserRecord__c = true;
            Database.insert(agentUser2);
            agentUser2 = [SELECT id, email FROM User WHERE id=:agentUser2.id];

            /**************************** Agent 3 ****************************/

            // Create Proxy/Office
            testProxyUser1 = new User(Alias='Chris',LastName='Farley, FO0, 46-1801-office',Username=PROXY_THREE_EMAIL,UserExternalID__c='789P',Servicing_Agent_Associate_ID__c='789');
            User proxyUser3 = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser3.userRoleId = proxyStandardUserRole.id; 
            Database.insert(proxyUser3);

            // Create Agent
            testAgentUser1 = new User(Alias='Chris',LastName='Farley, FO0, 46-1801',Username=AGENT_THREE_EMAIL,Associate_ID__c='789',UserExternalID__c='789_789',Servicing_Agent_Associate_ID__c='789');
            User agentUser3 = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
            agentUser3.userRoleId = agentStandardUserRole.id;
            agentUser3.State_Agent_Code__c = '03-9999';
            agentUser3.SubUserType__c = AGENT;
            agentUser3.MasterUserRecord__c = true;
            Database.insert(agentUser3);
            agentUser3 = [SELECT id, email FROM User WHERE id=:agentUser3.id];

            /**************************** Agent 4 ****************************/

            // Create Proxy/Office
            testProxyUser1 = new User(Alias='Stan',LastName='Lee, FO1, 46-1901-office',Username=PROXY_FOUR_EMAIL,UserExternalID__c='246P',Servicing_Agent_Associate_ID__c='246');
            User proxyUser4 = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser4.userRoleId = proxyStandardUserRole.id; 
            Database.insert(proxyUser4);

            // Create Agent
            testAgentUser1 = new User(Alias='Stan',LastName='Lee, FO1, 46-1901',Username=AGENT_FOUR_EMAIL,Associate_ID__c='246',UserExternalID__c='246_246',Servicing_Agent_Associate_ID__c='246');
            User agentUser4 = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
            agentUser4.userRoleId = agentStandardUserRole.id;
            agentUser4.State_Agent_Code__c = '04-9999';
            agentUser4.SubUserType__c = AGENT;
            agentUser4.MasterUserRecord__c = true;
            Database.insert(agentUser4);
            agentUser4 = [SELECT id, email FROM User WHERE id=:agentUser4.id];

        }
    }

    /** 
     * @description Method to Generate Account Data for Testing.
     */ 
    private static void generateAccountData(){

        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();

        User agent1 = getAgent1();
        User agent2 = getAgent2();
        User agent3 = getAgent3();
        User agent4 = getAgent4();
 
        // Create Accounts Under Agent 1.
        System.RunAs(agent1) {
            
            Account account1 = new Account(firstname ='Will', lastname=ACCOUNT_ONE_LASTNAME, ClientIdentifier__c = 'SFFSP81L8XA');
            insert account1;

            Account account2 = new Account(firstname ='Beverly', lastname=ACCOUNT_TWO_LASTNAME, ClientIdentifier__c = 'SFFSP81L8XB');
            insert account2;
        }

        // Create Accounts Under Agent 2
        System.RunAs(agent2) {
            Account account3 = new Account(firstname ='Julian', lastname=ACCOUNT_THREE_LASTNAME, ClientIdentifier__c = 'SFFSP81L8XC');
            insert account3;
        } 

        // Create Accounts Under Agent 3
        System.RunAs(agent3) {
            Account account4 = new Account(firstname ='Ornstein', lastname=ACCOUNT_FOUR_LASTNAME, ClientIdentifier__c = 'SFFSP81L8XD');
            insert account4;
        }

        // Create Accounts Under Agent 4
        System.RunAs(agent4) {
            Account account5 = new Account(firstname ='Leroy', lastname=ACCOUNT_FIVE_LASTNAME, ClientIdentifier__c = 'SFFSP81L8XE');
            insert account5;

            Account account6 = new Account(firstname ='Lord', lastname=ACCOUNT_SIX_LASTNAME, ClientIdentifier__c = 'SFFSP81L8XF');
            insert account6;
        }

    }
    
    private static void generateBillingAccountsAndParticipants(){
        String billingAccountNumber1 = '1234567890';          
        String billingAccountNumber2 = '0987654321';
        String billingAccountNumber3 = '0111101111';   
        String billingAccountNumber4 = '0222202222';           
        String stateAgentCode1 = '01-9999';          
        String stateAgentCode2 = '02-9999';
        String stateAgentCode3 = '03-9999';
        String stateAgentCode4 = '04-9999';

        Billing_Account__c billingAccount1 = createBillingAccount(billingAccountNumber1, stateAgentCode1);
        Billing_Account__c billingAccount2 = createBillingAccount(billingAccountNumber2, stateAgentCode2);
        createBillingAccount(billingAccountNumber3, stateAgentCode3);
        Billing_Account__c billingAccount4 = createBillingAccount(billingAccountNumber4, stateAgentCode4);

        // create Participants, and then we're done we dont need Insurance Policies for this test.
        createBillingParticipant(getAccount1().Id, billingAccount1.Id, billingAccount1.AccountNumber__c);
        createBillingParticipant(getAccount1().Id, billingAccount2.Id, billingAccount2.AccountNumber__c);
        createBillingParticipant(getAccount2().Id, billingAccount2.Id, billingAccount2.AccountNumber__c);
        createBillingParticipant(getAccount5().Id, billingAccount4.Id, billingAccount4.AccountNumber__c);
        createBillingParticipant(getAccount6().Id, billingAccount4.Id, billingAccount4.AccountNumber__c);


    }

    private static Billing_Account__c createBillingAccount(String billingAccountNumber, String servicingAgentStateAgentCode) {
        // Mock data for creating external id, will be unique in prod, but can be fake in our tests
        String roCode = '00';

        Billing_Account__c account = new Billing_Account__c();
        account.SourceSystemIdentifier__c = billingAccountNumber + '~' + roCode;
        account.AccountNumber__c = billingAccountNumber;
        account.ServicingAgent__c = servicingAgentStateAgentCode;
        insert account;

        return account;
    }

    private static Billing_Participant__c createBillingParticipant(Id accountId, Id billingAccountId, String billingAccountNumber) {
        // Mock data for creating external id, will be unique in prod, but can be fake in our tests
        String roCode = '00';

        Billing_Participant__c bp = new Billing_Participant__c();
        bp.BillingAccountID__c = billingAccountId;
        bp.SourceSystemIdentifier__c = billingAccountNumber + '~' + roCode + '~' + accountId;
        bp.ParticipantAccountId__c = accountId;
        insert bp;

        return bp;
    }

    /**
     * @name - getAgent1
     * @description - Returns the first agent.
     * @return User
     */
    public static USER getAgent1(){
        return [SELECT id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email FROM User WHERE email=:AGENT_ONE_EMAIL];
    }

    /**
     * @name - getAgent2
     * @description - Returns the second agent.
     * @return User
     */
    public static USER getAgent2(){
        return [SELECT id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email FROM User WHERE email=:AGENT_TWO_EMAIL];
    }

    /**
     * @name - getAgent3
     * @description - Returns the third agent.
     * @return User
     */
    public static USER getAgent3(){
        return [SELECT id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email FROM User WHERE email=:AGENT_THREE_EMAIL];
    }

    /**
     * @name - getAgent4
     * @description - Returns the fourth agent.
     * @return User
     */
    public static USER getAgent4(){
        return [SELECT id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email FROM User WHERE email=:AGENT_FOUR_EMAIL];
    }

    /**
     * @name - getAgentProxy1
     * @description - Returns the proxy for the first agent.
     * @return User
     */
    public static USER getAgentProxy1(){
        return [SELECT id, email FROM User WHERE email=:PROXY_ONE_EMAIL];
    }

    /**
     * @name - getAgentProxy2
     * @description - Returns the proxy for the second agent.
     * @return User
     */
    public static USER getAgentProxy2(){
        return [SELECT id, email FROM User WHERE email=:PROXY_TWO_EMAIL];
    }

    /**
     * @name - getAgentProxy3
     * @description - Returns the proxy for the third agent.
     * @return User
     */
    public static USER getAgentProxy3(){
        return [SELECT id, email FROM User WHERE email=:PROXY_THREE_EMAIL];
    }

    /**
     * @name - getAgentProxy4
     * @description - Returns the proxy for the fourth agent.
     * @return User
     */
    public static USER getAgentProxy4(){
        return [SELECT id, email FROM User WHERE email=:PROXY_FOUR_EMAIL];
    }
    
    /**
     * @name - getAccount1
     * @description - Returns the first account.
     * @return Account
     */
    public static Account getAccount1() {
        return [SELECT Id, name, lastname FROM Account WHERE lastname = :ACCOUNT_ONE_LASTNAME];
    }

    /**
     * @name - getAccount2
     * @description - Returns the second account.
     * @return Account
     */
    public static Account getAccount2() {
        return [SELECT Id, name, lastname FROM Account WHERE lastname = :ACCOUNT_TWO_LASTNAME];
    }

    /**
     * @name - getAccount3
     * @description - Returns the third account.
     * @return Account
     */
    public static Account getAccount3() {
        return [SELECT Id, name, lastname FROM Account WHERE lastname = :ACCOUNT_THREE_LASTNAME];
    }

    /**
     * @name - getAccount4
     * @description - Returns the fourth account.
     * @return Account
     */
    public static Account getAccount4() {
        return [SELECT Id, name, lastname FROM Account WHERE lastname = :ACCOUNT_FOUR_LASTNAME];
    }

    /**
     * @name - getAccount5
     * @description - Returns the fifth account.
     * @return Account
     */
    public static Account getAccount5() {
        return [SELECT Id, name, lastname FROM Account WHERE lastname = :ACCOUNT_FIVE_LASTNAME];
    }

    /**
     * @name - getAccount6
     * @description - Returns the sixth account.
     * @return Account
     */
    public static Account getAccount6() {
        return [SELECT Id, name, lastname FROM Account WHERE lastname = :ACCOUNT_SIX_LASTNAME];
    }

    /**
     * @name - getBillingAccount1
     * @description - Returns the first billing account.
     * @return Billing_Account__c
     */
    public static Billing_Account__c getBillingAccount1() {
        String billingAccountNumber1 = '1234567890';          
        return [SELECT Id, SourceSystemIdentifier__c, AccountNumber__c FROM Billing_Account__c WHERE AccountNumber__c = :billingAccountNumber1];
    }

    /**
     * @name - getBillingAccount2
     * @description - Returns the second billing account.
     * @return Billing_Account__c
     */
    public static Billing_Account__c getBillingAccount2() {
        String billingAccountNumber2 = '0987654321';
        return [SELECT Id, SourceSystemIdentifier__c, AccountNumber__c FROM Billing_Account__c WHERE AccountNumber__c = :billingAccountNumber2];
    }

    /**
     * @name - getBillingAccount3
     * @description - Returns the third billing account.
     * @return Billing_Account__c
     */
    public static Billing_Account__c getBillingAccount3() {
        String billingAccountNumber3 = '0111101111';
        return [SELECT Id, SourceSystemIdentifier__c, AccountNumber__c FROM Billing_Account__c WHERE AccountNumber__c = :billingAccountNumber3];
    }

    /**
     * @name - getBillingAccount4
     * @description - Returns the fourth billing account.
     * @return Billing_Account__c
     */
    public static Billing_Account__c getBillingAccount4() {
        String billingAccountNumber4 = '0222202222';
        return [SELECT Id, SourceSystemIdentifier__c, AccountNumber__c FROM Billing_Account__c WHERE AccountNumber__c = :billingAccountNumber4];
    }

    /**
     * @name - getBillingParticipant1
     * @description - get Billing Participant: Customer Account 1/ Billing Account 1
     * @return Billing_Participant__c
    */
    public static Billing_Participant__c getBillingParticipant1() {
        return [
            SELECT Id, SourceSystemIdentifier__c, ParticipantAccountId__c, BillingAccountID__c 
            FROM Billing_Participant__c 
            WHERE ParticipantAccountId__c = :getAccount1().Id AND BillingAccountID__c = :getBillingAccount1().Id
        ];
   }

    /**
     * @name - getBillingParticipant2
     * @description - get Billing Participant: Customer Account 1/ Billing Account 2
     * @return Billing_Participant__c
    */
    public static Billing_Participant__c getBillingParticipant2() {
        return [
            SELECT Id, SourceSystemIdentifier__c, ParticipantAccountId__c, BillingAccountID__c 
            FROM Billing_Participant__c 
            WHERE ParticipantAccountId__c = :getAccount1().Id AND BillingAccountID__c = :getBillingAccount2().Id
        ];
    } 

    /**
     * @name - getBillingParticipant3
     * @description - get Billing Participant: Customer Account 2/ Billing Account 2
     * @return Billing_Participant__c
    */
    public static Billing_Participant__c getBillingParticipant3() {
        return [
            SELECT Id, SourceSystemIdentifier__c, ParticipantAccountId__c, BillingAccountID__c 
            FROM Billing_Participant__c 
            WHERE ParticipantAccountId__c = :getAccount2().Id AND BillingAccountID__c = :getBillingAccount2().Id
        ];
    } 

    /**
     * @name - getBillingParticipant4
     * @description - get Billing Participant: Customer Account 5/ Billing Account 4
     * @return Billing_Participant__c
    */
    public static Billing_Participant__c getBillingParticipant4() {
        return [
            SELECT Id, SourceSystemIdentifier__c, ParticipantAccountId__c, BillingAccountID__c 
            FROM Billing_Participant__c 
            WHERE ParticipantAccountId__c = :getAccount5().Id AND BillingAccountID__c = :getBillingAccount4().Id
        ];
    }

    /**
     * @name - getBillingParticipant5
     * @description - get Billing Participant: Customer Account 6/ Billing Account 4
     * @return Billing_Participant__c
    */
    public static Billing_Participant__c getBillingParticipant5() {
        return [
            SELECT Id, SourceSystemIdentifier__c, ParticipantAccountId__c, BillingAccountID__c 
            FROM Billing_Participant__c 
            WHERE ParticipantAccountId__c = :getAccount6().Id AND BillingAccountID__c = :getBillingAccount4().Id
        ];
    }
}
