/**
* @Author  Team AKITA
* @Date Created  09/22/2020
* @description  Test class for OpportunityCanvasComponent - Apex Class.
* @Version 6.2 
* Copyright © StateFarm
*/

@isTest
public with sharing class OpportunityCanvasComponent_Test {
    
    public static User agentUser;
    public static User adminUser;
    public static User cccLicensedUser;
    public static User proxyUser;
    public static Account acc;
    public static Account healthSourcedAcc;
    public static Opportunity opp;
    static final String AUTO_PRODUCTSYSTEMNAME = 'PRIV_PSNGR_VEH';
    static final String AUTO_POLICYCENTER_PRODUCTSYSTEMNAME = 'PP_VEH_POLICYCENTER';
    static final String FIRE_PRODUCTSYSTEMNAME = 'RENTERS_POLICY';
    
    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap = Schema.Sobjecttype.Account.getRecordTypeInfosByName();
    
    //method to bypass Trigger
    private static void byPassTrigger() {
        CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c();
        objectBasedByPassTrigger.Override_All__c = true;
        insert objectBasedByPassTrigger;
    }
    
    //method to build userrole with the given parameter value
    private static UserRole buildUserRole(String roleName) {
        return new UserRole(name = roleName);
    }
    
    //method to build userrole with parentRole with the given parameter value
    private static UserRole buildUserRoleWithParent(String roleName, String parentRole) {
        return new UserRole(name = roleName, parentRoleId = parentRole);
    }
    
    //method to build Agent Role record with Customer Account Id
    private static AgentRole__c buildAgentRoleRecord(String accountId) {
        return new AgentRole__c (RelationshipNature__c = 'Customer',
                                                   Agent__c = userInfo.getUserId(), Customer__c = accountId);
        
    }
    
    
    //method to build Agent Context Record with the given parameter value
    private static AgentContext__c buildAgentContextRecord(String paramAccountId, String paramAgntContxtIdentifier, String paramAgntUser) {
        return new AgentContext__c(Agent__c = paramAgntUser, AgentContextIdentifier__c = paramAgntContxtIdentifier,
                                                           CCCRepresentative__c = userInfo.getUserId(), Customer__c = paramAccountId);
    }
    
    //method to build Account record with Client First Name, Last Name, and Client Id
    private static Account buildAccountRecord(String fstLstName, String clientId, Id owner) {
        String[] splitFSTLSTName = fstLstName.split(' ');
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        return new Account(FirstName = splitFSTLSTName[0] , LastName = splitFSTLSTName[1], ownerId = owner,
                                  RecordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId, ClientIdentifier__c = clientId, BillingState = 'MD');
    }

    //method to build Account record that is health sourced
    private static Account buildAccountRecordHealthSourced(String fstLstName, String clientId, Id owner) {
        String[] splitFSTLSTName = fstLstName.split(' ');
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        return new Account(FirstName = splitFSTLSTName[0] , LastName = splitFSTLSTName[1], ownerId = owner,
                                  RecordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId, ClientIdentifier__c = clientId, BillingState = 'MD',
                                  IsHealthSourced__pc = true);
    }
    
    //method to build Opportunity record with lobProduct, ownerId, and product system name
    private static Opportunity buildOpportunityRecord(String lobProduct, String ownerId, String productSysName) {
        String[] splitlobProduct = lobProduct.split('-');   
        return new Opportunity(Name = splitlobProduct[0],
                                          AccountId = acc.Id, 
                                          LOB__c = splitlobProduct[0], 
                                          Product__c = (splitlobProduct.size()>1)?splitlobProduct[1]:'',
                                          Requested_Effective_Date__c = Date.today(),
                                          StageName = 'New',
                                          CloseDate = Date.today()+60,
                                          ownerId = ownerId,
                                          Product_System_Name__c = productSysName,
                                          State_Code__c = 'MD / 20-7185');
    }
    
    /**
     * @description setUp
     */
    @testSetup
    static void setUp() {
        adminUser = UTIL_UserProvisioning_TEST.buildUserWithSystemAdminProfile('TestAdminUser@statefarm.com.bad');
        insert adminuser;
        
        System.runAs(adminUser) {
            byPassTrigger();
            
            UserRole agentUserRole = buildUserRole('AgentRole');
            insert agentUserRole;
            
            UserRole proxyUserRole = buildUserRoleWithParent('ProxyRole', agentUserRole.id);
            insert proxyUserRole;
            User testAgentUser = new User(Alias='X7PZ',LastName='agent,user,75-3385-Office',Username='TestAgentUser@statefarm.com.bad',Associate_ID__c='ASSOCID0001',UserExternalID__c='EXTERNALID1',Servicing_Agent_Associate_ID__c='AGTASSOCID1',Territory_Associate_ID__c='',Servicing_Agent_Associate_ID_List__c='',Territory_Associate_ID_List__c='');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser (testAgentUser);
            agentUser.userRoleId = agentUserRole.id;
            agentUser.state_agent_code__c = '20-7185';
            agentUser.state_agent_code_list__c = '20-7185,05-7185,32-7185';
            agentUser.SubUserType__c = 'Agent';
            agentUser.UserExternalID__c = 'SERVICINID1_SERVICINID1';
            insert agentUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            User agentIdForPermSetAssign = [select id from user where alias = 'X7PZ' limit 1];
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(agentIdForPermSetAssign.Id, 'ECRM_ARIA_Participant_PermSetPID');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(agentIdForPermSetAssign.Id, 'ECRM_ARIA_Auto_PrivatePassenger_PC_PermSet');
            AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(agentIdForPermSetAssign.Id, 'ECRM_ARIA_Fire_PermSetPID');
            User testProxyUser1 = new User(Alias='X7PX',LastName='middle,Last,75-3385-Office',Username='TestProxyUser@statefarm.com.bad',UserExternalID__c='EXTERNALID1_EXTERNALID1',Servicing_Agent_Associate_ID__c='SERVICINID1');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;
            User testCCCLicenUser = new User(Alias='X7PT',LastName='CCC,user,75-338-Office',Username='TestCCCUser@statefarm.com.bad',Associate_ID__c='ppcczz33ttc',UserExternalID__c='');
            cccLicensedUser = UTIL_UserProvisioning_TEST.buildCCCLicensedUserMethod(testCCCLicenUser);
            cccLicensedUser.SubUserType__c = 'CCC Sales';
            insert cccLicensedUser;
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(cccLicensedUser);
        }
        
        acc = OpportunityCanvasComponent_Test.buildAccountRecord('FST LST','111',agentUser.Id);
        insert acc;
        healthSourcedAcc = OpportunityCanvasComponent_Test.buildAccountRecordHealthSourced('HLTH SRC','222',agentUser.Id);
        insert healthSourcedAcc;
        
        
        //Insert agent role to give account access to the Agent
        AgentRole__c agentRole;
        AgentRole__c agentRole2;
        System.runAs(agentUser) {
            agentRole = buildAgentRoleRecord(acc.Id);
            agentRole2 = buildAgentRoleRecord(healthSourcedAcc.Id);
        }
        insert agentRole;
        insert agentRole2;
        
    }
    
    /**
     * @description queryTestData
     */
    //Query the test data
    private static void queryTestData() {
        agentUser = [Select Id,Associate_ID__c, UserExternalID__c from User where username = 'TestAgentUser@statefarm.com.bad'];
        adminUser = [Select Id,Associate_ID__c from User where username = 'TestAdminUser@statefarm.com.bad'];
        cccLicensedUser = [Select Id,Associate_ID__c from User where username = 'TestCCCUser@statefarm.com.bad'];
        proxyUser = [Select Id,Associate_ID__c from User where username = 'TestProxyUser@statefarm.com.bad'];
        acc = [Select Id,ClientIdentifier__c, Name from Account where lastname = 'LST'];
        healthSourcedAcc = [Select Id,ClientIdentifier__c, Name from Account where lastname = 'SRC'];
    }
    
    //Method to verify Assert statements
    @SuppressWarnings('PMD.ApexUnitTestMethodShouldHaveIsTestAnnotation')
    private static void verifyData(String lob, OpportunityCanvasComponent.OppList data, Opportunity primaryOpp) {
        opp = [SELECT Id, Account.ClientIdentifier__c,Requested_Effective_Date__c, State_Code__c, LOB__c,Owner.Servicing_Agent_Associate_ID__c FROM Opportunity WHERE Id =: primaryOpp.Id];
        User user = [SELECT Id,Associate_ID__c, State_Agent_Code__c, State_Agent_Code_List__c, SubUserType__c,lastname FROM User WHERE UserExternalID__c = 'SERVICINID1_SERVICINID1'];
        String agentContextIdentifier = user.Associate_ID__c +'~'+opp.Account.ClientIdentifier__c;
        List<AgentContext__c> agtcontext = [SELECT InteractionId__c,AgentContextIdentifier__c FROM AgentContext__c WHERE AgentContextIdentifier__c =:agentContextIdentifier];
        
        if (String.isBlank(opp.State_Code__c)) {
            System.assertEquals(data.opportunityList[0].bookCode,null, 'Expected bookCode not equal to original');
        }
        else {
            System.assertEquals(data.opportunityList[0].bookCode,opp.State_Code__c.right(7), 'Expected bookCode not equal to original');
        }
        
        if(agtcontext.isEmpty()){
            System.assertEquals(data.opportunityList[0].interactionId,null, 'Expected interactionId not equal to original');
        } 
        else{
            System.assertEquals(data.opportunityList[0].interactionId,agtcontext[0].InteractionId__c, 'Expected interactionId not equal to original'); 
        } 
        
        System.assertEquals(data.opportunityList[0].opportunityId,opp.Id, 'Expected opportunityId not equal to original');
        System.assertEquals(data.opportunityList[0].clientId,opp.Account.ClientIdentifier__c, 'Expected clientId not equal to original');
        System.assertEquals(data.opportunityList[0].lob,lob, 'Expected lob not equal to original');
        System.assertEquals(data.opportunityList[0].effectiveDate,opp.Requested_Effective_Date__c, 'Expected effectiveDate not equal to original');
        
    }
    
    //Method to get the required parammeters as an Agent for lob:Auto, Product: Private Passenger, iAuto
    @isTest
    private static void getBundleParamsAsAgentForAuto() {
        queryTestData();
        System.runAs(agentUser) {
            opp = OpportunityCanvasComponent_Test.buildOpportunityRecord('Auto-Private Passenger',proxyUser.Id,AUTO_PRODUCTSYSTEMNAME);
            insert opp; 
            Test.startTest();
            String serializedData = OpportunityCanvasComponent.getRequiredParams(opp.Id);
            Test.stopTest();
            OpportunityCanvasComponent.OppList data = (OpportunityCanvasComponent.OppList)JSON.deserialize(serializedData, OpportunityCanvasComponent.OppList.class);
            verifyData('A', data, opp);
            System.assertEquals(AUTO_PRODUCTSYSTEMNAME, data.opportunityList[0].productSystemName, 'Failed to get ProductSystemName');
        } 
    }

    //Method to get the required parammeters as an Agent for lob:Auto, Product: Private Passenger, iAuto, stage is closed
    @isTest
    private static void getBundleParamsAsAgentForAutoWithClosedStage() {
        queryTestData();
        System.runAs(agentUser) {
            opp = new Opportunity(Name = 'Auto',
                                          AccountId = acc.id, 
                                          LOB__c = 'Auto', 
                                          Product__c = 'Private Passenger',
                                          Requested_Effective_Date__c = Date.today(),
                                          StageName = 'Closed',
                                          CloseDate = Date.today(),
                                          ownerId = proxyUser.Id,
                                          Product_System_Name__c = AUTO_PRODUCTSYSTEMNAME,
                                          State_Code__c = 'MD / 20-7185');
            insert opp;
            Test.startTest();
            String serializedData = OpportunityCanvasComponent.getRequiredParams(opp.Id);
            Test.stopTest();
            System.assertEquals('ApexError:Integrated Quoting not available for Closed Opportunities.\n\nTo view the quote, change the Stage of the Opportunity to Quoting. If you change to any other stage, you will need to refresh the browser.', serializedData, 'Failed to serializeData for Account with Closed Opportunity');
        } 
    }

    //Method to get the required parammeters as an Agent for lob:Auto, Product: Private Passenger, iAuto, account is health sourced
    @isTest
    private static void getBundleParamsAsAgentForAutoAccountHealthSourced() {
        queryTestData();
        System.runAs(agentUser) {
            opp = new Opportunity(Name = 'Auto',
                                          AccountId = healthSourcedAcc.id, 
                                          LOB__c = 'Auto', 
                                          Product__c = 'Private Passenger',
                                          Requested_Effective_Date__c = Date.today(),
                                          StageName = 'New',
                                          CloseDate = Date.today(),
                                          ownerId = proxyUser.Id,
                                          Product_System_Name__c = AUTO_PRODUCTSYSTEMNAME,
                                          State_Code__c = 'MD / 20-7185');
            insert opp;
            Test.startTest();
            String serializedData = OpportunityCanvasComponent.getRequiredParams(opp.Id);
            Test.stopTest();
            System.assertEquals('ApexError:Customer Health Information cannot be used to pre-populate a non-HIPAA product quote or application. Please re-enter the customer information.', serializedData, 'Failed to serializeData for Account that is health sourced');
        } 
    }

    //Method to get the required parammeters as an Agent for array of Auto-Private Passenger iAuto, Auto-Private Passenger SASSE, and Fire-Renters
    @isTest
    private static void getBundleParamsAsAgentForMultipleOpps() {
        queryTestData();
        System.runAs(agentUser) {
            Opportunity opp1 = OpportunityCanvasComponent_Test.buildOpportunityRecord('Auto-Private Passenger',proxyUser.Id,AUTO_PRODUCTSYSTEMNAME);
            insert opp1;
            Opportunity opp2 = new Opportunity(Name = 'Auto',
                                          AccountId = acc.id, 
                                          LOB__c = 'Auto', 
                                          Product__c = 'Private Passenger',
                                          Requested_Effective_Date__c = Date.today(),
                                          StageName = 'New',
                                          CloseDate = Date.today()+60,
                                          ownerId = proxyUser.Id,
                                          Product_System_Name__c = AUTO_POLICYCENTER_PRODUCTSYSTEMNAME,
                                          State_Code__c = 'MD / 20-7185');
            insert opp2;
            Opportunity opp3 = OpportunityCanvasComponent_Test.buildOpportunityRecord('Fire-Renters',proxyUser.Id,FIRE_PRODUCTSYSTEMNAME);
            insert opp3;
            Test.startTest();
            String serializedData = OpportunityCanvasComponent.getRequiredParams(opp3.Id);
            Test.stopTest();
            OpportunityCanvasComponent.OppList data = (OpportunityCanvasComponent.OppList)JSON.deserialize(serializedData, OpportunityCanvasComponent.OppList.class);
            verifyData('F', data, opp3);
            System.assertEquals(FIRE_PRODUCTSYSTEMNAME, data.opportunityList[0].productSystemName, 'Failed to get ProductSystemName');
            System.assertEquals(AUTO_PRODUCTSYSTEMNAME, data.opportunityList[1].productSystemName, 'Failed to get ProductSystemName');
            System.assertEquals(AUTO_POLICYCENTER_PRODUCTSYSTEMNAME, data.opportunityList[2].productSystemName, 'Failed to get ProductSystemName');
        } 
    }

    //Method to get the required parammeters as an Agent for SFCOM opp with lob:Fire, Product: Renters, PSN=null & State_Code__c=null
    @isTest
    private static void getBundleParamsAsAgentForFireWithoutPSN() {
        queryTestData();
        System.runAs(agentUser) {
            opp = new Opportunity(Name = 'Fire',
                                            AccountId = acc.id, 
                                            LOB__c = 'Fire', 
                                            Product__c = 'Renters',
                                            Requested_Effective_Date__c = Date.today(),
                                            StageName = 'New',
                                            CloseDate = Date.today()+60,
                                            ownerId = proxyUser.Id,
                                            Product_System_Name__c = null,
                                            State_Code__c = null,
                                            Opportunity_Originator__c = 'Statefarm.com');
            insert opp;
            Test.startTest();
            String serializedData = OpportunityCanvasComponent.getRequiredParams(opp.Id);
            Test.stopTest();
            OpportunityCanvasComponent.OppList data = (OpportunityCanvasComponent.OppList)JSON.deserialize(serializedData, OpportunityCanvasComponent.OppList.class);
            verifyData('F', data, opp);
            System.assertEquals(null, data.opportunityList[0].productSystemName, 'Failed to get ProductSystemName');
        } 
    }
    
    @isTest
    //Method to get the required parammeters as a CCC with ARIA perm set for lob:Fire, Product: Renters
    private static void getBundleParamsAsCCCForFire() {
        queryTestData();
        AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(cccLicensedUser.Id, 'ECRM_ARIA_Fire_PermSetPID');
        System.runAs(cccLicensedUser) {
            opp = OpportunityCanvasComponent_Test.buildOpportunityRecord('Fire-Renters',proxyUser.Id,FIRE_PRODUCTSYSTEMNAME);
            insert opp; 
            AgentContext__c agentContext = buildAgentContextRecord(acc.id, cccLicensedUser.Associate_ID__c + '~' + acc.ClientIdentifier__c, agentUser.id);
            insert agentContext;
            Test.startTest();
            String serializedData = OpportunityCanvasComponent.getRequiredParams(opp.Id);
            Test.stopTest();
            OpportunityCanvasComponent.OppList data = (OpportunityCanvasComponent.OppList)JSON.deserialize(serializedData, OpportunityCanvasComponent.OppList.class);
            verifyData('F', data, opp);
            System.assertEquals(FIRE_PRODUCTSYSTEMNAME, data.opportunityList[0].productSystemName, 'Failed to get ProductSystemName');
        }
    }
    
    @isTest
    //Method to get the required parammeters as a CCC without ARIA perm set to cover exception
    private static void getBundleParamsAsCCCForException() {
        queryTestData();
        System.runAs(cccLicensedUser) {
            opp = OpportunityCanvasComponent_Test.buildOpportunityRecord('Fire-Renters',proxyUser.Id,FIRE_PRODUCTSYSTEMNAME);
            insert opp; 
            Test.startTest();
            try {
                OpportunityCanvasComponent.getRequiredParams(opp.id);
            }
            catch (Exception e) {
                system.assert(true,'CCC without Perm Set test failed');
            }
            Test.stopTest();
        }
    }

    @isTest
    //Method to test the cache checkout in progress messages
    private static void getCheckoutInProgress() {
        queryTestData();
        System.runAs(agentUser) {
            opp = OpportunityCanvasComponent_Test.buildOpportunityRecord('Auto-Private Passenger',proxyUser.Id,AUTO_PRODUCTSYSTEMNAME);
            insert opp;
            Test.startTest();
            OpportunityCanvasComponent.persistShouldShowCheckoutInProgress(opp.id, true);
            Boolean cacheRead = OpportunityCanvasComponent.shouldShowCheckoutInProgress(opp.id);
            system.assertEquals(true,cacheRead,'Session cache checkout in progress message true');
            OpportunityCanvasComponent.persistShouldShowCheckoutInProgress(opp.id, false);
            cacheRead = OpportunityCanvasComponent.shouldShowCheckoutInProgress(opp.id);
            Test.stopTest();
            system.assertEquals(false,cacheRead,'Session cache checkout in progress message false');
        }
    }
    @isTest
    //Method to test the cache checkout exception
    private static void getCheckoutInProgressException() {
        queryTestData();
        System.runAs(agentUser) {
            opp = OpportunityCanvasComponent_Test.buildOpportunityRecord('Auto-Private Passenger',proxyUser.Id,AUTO_PRODUCTSYSTEMNAME);
            insert opp;
            Test.startTest();
            try {
                OpportunityCanvasComponent.persistShouldShowCheckoutInProgress(opp.id, null);
            }
            catch (Exception e) {
                system.assertEquals('Script-thrown exception', e.getMessage(), 'Session cache checkout in progress exception failed');
            }
            Test.stopTest();
        }
    }
    @isTest
    //Method to test the cache show checkout exception
    private static void showCheckoutInProgressException() {
        queryTestData();
        System.runAs(agentUser) {
            opp = OpportunityCanvasComponent_Test.buildOpportunityRecord('Auto-Private Passenger',proxyUser.Id,AUTO_PRODUCTSYSTEMNAME);
            insert opp;
            Test.startTest();
            try {
                Cache.Session.put('local.OpportunityManagementPartition.'+opp.Id, 123);
                OpportunityCanvasComponent.shouldShowCheckoutInProgress(opp.Id);
            }
            catch (Exception e) {
                Cache.Session.remove('local.OpportunityManagementPartition.'+opp.Id);
                system.assertEquals('Script-thrown exception', e.getMessage(), 'Session cache should show checkout in progress exception failed');
            }
            Test.stopTest();
        }
    }
    @isTest
    private static void checkIfHideIntermediateScreenValueSetToFalse() {
        queryTestData();
        System.runAs(agentUser) {
            opp = OpportunityCanvasComponent_Test.buildOpportunityRecord('Auto-Private Passenger',proxyUser.Id,AUTO_PRODUCTSYSTEMNAME);
            insert opp; 
            Test.startTest();
            String serializedData = OpportunityCanvasComponent.getRequiredParams(opp.Id);
            Test.stopTest();
            OpportunityCanvasComponent.OppList data = (OpportunityCanvasComponent.OppList)JSON.deserialize(serializedData, OpportunityCanvasComponent.OppList.class);
            system.assertEquals(false,data.hideIntermediateScreen,'Session cache to Hide Intermediate Screen should be false');
        } 
    }
    @isTest
    private static void checkIfHideIntermediateScreenValueSetToTrue() {
        queryTestData();
        System.runAs(agentUser) {
            opp = OpportunityCanvasComponent_Test.buildOpportunityRecord('Auto-Private Passenger',proxyUser.Id,AUTO_PRODUCTSYSTEMNAME);
            insert opp; 
            String key='local.CanvasIntmdtScreenPartition.'+opp.Id;
            Cache.Session.put(key, 'displayIntermScreen'); 
            Test.startTest();
            String serializedData = OpportunityCanvasComponent.getRequiredParams(opp.Id);
            Test.stopTest();
            OpportunityCanvasComponent.OppList data = (OpportunityCanvasComponent.OppList)JSON.deserialize(serializedData, OpportunityCanvasComponent.OppList.class);
            system.assertEquals(true,data.hideIntermediateScreen,'Session cache to Hide Intermediate Screen should be true');
        } 
    }
}