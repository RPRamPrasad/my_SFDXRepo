/**
 * @description OppProspectEvaluator_TEST
 * In a method no more than 15 lines
 * In a class 50 methods 
 */
@isTest
public with sharing class OppProspectEvaluator_TEST {
    private static User agentUser;
    private static User adminUser;
    private static User proxyUser;

    private static Account acc; 
    private static Opportunity opp;

    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap = Schema.Sobjecttype.Account.getRecordTypeInfosByName();

    /**
     * @description setUp
     */
    @testSetup
    public static void setUp() {
        
        User adminUser = UTIL_UserProvisioning_TEST.buildUserWithSystemAdminProfile('TestAdminUser@statefarm.com.bad');
        insert adminuser;

        User agentUser;
        User proxyUser; 

        System.runAs(adminUser) {
            byPassTrigger();

            UserRole agentUserRole = buildUserRole('AgentRole');
            insert agentUserRole;
            
            UserRole proxyUserRole = buildUserRoleWithParent('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            User testAgentUser = new User(Alias='X7PZ',LastName='agent,user,75-338-Office',Username='TestAgentUser@statefarm.com.bad',Associate_ID__c='ASSOCID0001',UserExternalID__c='EXTERNALID1',Servicing_Agent_Associate_ID__c='AGTASSOCID1',Territory_Associate_ID__c='',Servicing_Agent_Associate_ID_List__c='',Territory_Associate_ID_List__c='');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser (testAgentUser);
            agentUser.userRoleId = agentUserRole.id; 
                         
            insert agentUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);


            User testProxyUser = new User(Alias='X7PX',LastName='middle,Last,75-338-Office',Username='TestProxyUser@statefarm.com.bad',UserExternalID__c='EXTERNALID2',Servicing_Agent_Associate_ID__c='ASSOCID0001', Territory_Associate_ID__c='');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser(testProxyUser);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;
            
        }
        
        Account acc = buildAccountRecord('FST LST','111',agentUser.Id);
        insert acc;
        
        //Insert agent role to give account access to the Agent
        AgentRole__c agentRole;
        System.runAs(agentUser) {
            agentRole = buildAgentRoleRecord(acc.Id);
        }
        insert agentRole;
    }

     /**
     * @description buildUserRole
     * @param roleName
     * @return UserRole
     */
    //method to build userrole with the given parameter value
    public static UserRole buildUserRole(String roleName) {
        UserRole role = new UserRole(name = roleName);
        return role;
    }

    /**
     * @description buildUserRoleWithParent
     * @param roleName
     * @param parentRole
     * @return UserRole
     */
    //method to build userrole with parentRole with the given parameter value
    public static UserRole buildUserRoleWithParent(String roleName, String parentRole) {
        UserRole role = new UserRole(name = roleName, parentRoleId = parentRole);
        return role;
    }

    /**
     * @description buildAccountRecord
     * @param fstLstName
     * @param clientId
     * @param owner
     * @return Account
     */
    //method to build Account record with Client First Name, Last Name, and Client Id
    public static Account buildAccountRecord(String fstLstName, String clientId, Id owner) {
        String[] splitFSTLSTName = fstLstName.split(' ');
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        Account act = new Account(FirstName = splitFSTLSTName[0] , LastName = splitFSTLSTName[1], ownerId = owner,
                                  RecordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId, ClientIdentifier__c = clientId, BillingState = 'MD');
        return act;
    }
    
    /**
     * @description buildOpportunityRecord
     * @param accountId
     * @param lobProduct
     * @param ownerId
     * @return Opportunity
     */
    //method to build Opportunity record with Lob,Product, AccountId and OwnerId
    public static Opportunity buildOpportunityRecord(String accountId, String lobProduct, String ownerId) {
        String[] splitlobProduct = lobProduct.split('-');   
        Opportunity opp = new Opportunity(Name = splitlobProduct[0],
                                          AccountId = accountId, 
                                          LOB__c = splitlobProduct[0], 
                                          Product__c = (splitlobProduct.size()>1)?splitlobProduct[1]:'',
                                          StageName = 'New',
                                          CloseDate = Date.today()+60,
                                          ownerId = ownerId);
        return opp;
    }

    /**
     * @description byPassTrigger
     */
    //method to bypass Trigger
    public static void byPassTrigger() {
        CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c();
        objectBasedByPassTrigger.Override_All__c = true;
        insert objectBasedByPassTrigger;
    }

     /**
     * @description Grabs records from the User and Account SObjects and sets them to Apex objects for running
     * test code as different users.
     */ 
    private static void queryTestData() {
        agentUser = [SELECT Id, Associate_ID__c, UserExternalID__c FROM User WHERE username = 'TestAgentUser@statefarm.com.bad'];
        adminUser = [SELECT Id, Associate_ID__c FROM User WHERE username = 'TestAdminUser@statefarm.com.bad'];
        proxyUser = [SELECT Id, Associate_ID__c FROM User WHERE Alias = 'X7PXP'];
        acc = [SELECT Id, ClientIdentifier__c, Name FROM Account WHERE lastname = 'LST'];
    }

     /**
     * @description buildAgentRoleRecord
     * @param accountId
     * @return AgentRole__c
     */
    //method to build Agent Role record with Customer Account Id
    public static AgentRole__c buildAgentRoleRecord(String accountId) {
        AgentRole__c agentRole = new AgentRole__c (RelationshipNature__c = 'Customer',
                                                   Agent__c = userInfo.getUserId(), Customer__c = accountId);
        return agentRole;
    }
    
    @isTest
    public static void updateOppEvalStatusTrueToFalse() {
        queryTestData();

        Boolean expectedUpdateStatus = true; 
        Boolean expectedOppEvalStatus = false; // since the opp has the hasProspectEval__c of true before hitting the {updateEvalStatus} method, it should be changed to false subsetquently 

        Opportunity opp;
        assignPermissionSet(agentUser, 'SF_CRM_PROSPECTEVAL');
        System.runAs(agentUser) {
            opp = buildOpportunityRecord(acc.id,'Auto-GAINSCO', proxyUser.Id);
            insert opp;
        

        opp.hasProspectEval__c = true;
        update opp;

        Test.startTest();
            Boolean actualUpdateStatus = OppProspectEvaluator.updateEvalStatus(opp.Id);
            Opportunity oppAfterUpdate = [SELECT hasProspectEval__c FROM Opportunity WHERE Id = :opp.Id];
            Boolean actualOppEvalStatus = oppAfterUpdate.hasProspectEval__c;
        Test.stopTest();
       
        System.assertEquals(expectedUpdateStatus, actualUpdateStatus, 'unit method {updateEvalStatus} should return true, denoting a successful update'); 
        System.assertEquals(expectedOppEvalStatus, actualOppEvalStatus, 'unit method {updateEvalStatus} should update the opportunities hasProsepectEval__c to false');
        }
    }


    @isTest
    public static void updateOppEvalStatusFalseToTrue() {
        queryTestData();

        Boolean expectedUpdateStatus = true; 
        Boolean expectedOppEvalStatus = true; // since the opp has the hasProspectEval__c of true before hitting the {updateEvalStatus} method, it should be changed to false subsetquently 
        Boolean actualUpdateStatus;
        Opportunity opp;
        assignPermissionSet(agentUser, 'SF_CRM_PROSPECTEVAL');
        System.runAs(agentUser) {
            opp = buildOpportunityRecord(acc.id,'Auto-GAINSCO', proxyUser.Id);
            insert opp;
        

        opp.hasProspectEval__c = false;
        update opp;

        Test.startTest();
        actualUpdateStatus = OppProspectEvaluator.updateEvalStatus(opp.Id);
            Opportunity oppAfterUpdate = [SELECT hasProspectEval__c FROM Opportunity WHERE Id = :opp.Id];
            Boolean actualOppEvalStatus = oppAfterUpdate.hasProspectEval__c;
        Test.stopTest();
        System.assertEquals(expectedUpdateStatus, actualUpdateStatus, 'unit method {updateEvalStatus} should return true, denoting a successful update'); 
        System.assertEquals(expectedOppEvalStatus, actualOppEvalStatus, 'unit method {updateEvalStatus} should update the opportunities hasProsepectEval__c to true');
 
        }
        }
    
    //CREATE A FALSE UPDATE SCENARIO WHERE AGENT USER DOES NOT HAVE THE PERM SET
    @isTest
    public static void updateFailedShouldReturnFalse() {
        queryTestData();

        Boolean expectedUpdateStatus = true; 
        Boolean actualUpdateStatus;
        Opportunity opp;
        assignPermissionSet(agentUser, 'SF_CRM_PROSPECTEVAL');
        System.runAs(agentUser) {
            opp = buildOpportunityRecord(acc.id,'Auto-GAINSCO', proxyUser.Id);
            insert opp;

            Test.startTest();
                actualUpdateStatus = OppProspectEvaluator.updateEvalStatus(opp.Id);
            Test.stopTest();
            System.assertEquals(expectedUpdateStatus, actualUpdateStatus, 'unit method {updateEvalStatus} should return false, denoting a bad update'); 
        }

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
}
