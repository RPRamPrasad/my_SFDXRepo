/****************************************************************************************
Author Team ClubCar
Name - LWC_SignedWrittenConsent_TEST
@description Test class written for LWC_SignedWrittenConsent 
=========================================================================================
VERSION         AUTHOR                    DATE                   DETAIL
1.0             Team ClubCar              10/09/2020              Initial Development
******************************************************************************************/
@isTest()
public class LWC_SignedWrittenConsent_TEST {
    
    private static User sysAdminuser;
    private static User agentUser;
    private static User atmUser;
    private static User proxyUser;
    private static User systemUser;
    private static UserRole proxyStandardUserRole;
    private static UserRole agentStandardUserRole;
    private static UserRole agentTeamMemberUserRole;
    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap=Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();
    
    //Setup method used to build test data 
    @TestSetup
    private static void setUpTriggerAndUserData() {
        systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();  
        insert systemUser;
        CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c(Override_All__c= false);
        insert objectBasedByPassTrigger;
        CS001_ByPassTriggerAtoF__c accountByPassTrigger= new CS001_ByPassTriggerAtoF__c(Override_AccountBeforeInsert__c=false,Override_AgentRoleAfterInsert__c=false);
        insert accountByPassTrigger;
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(Name=UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER,SFDC_USER_ID__c=systemUser.id);            
        insert sysAdminUserIdSetting;
        CS001_ByPassTriggerGtoZ__c oppByPassTrigger = new CS001_ByPassTriggerGtoZ__c(Override_OppBeforeInsert__c=false);
        insert oppByPassTrigger;
        sysAdminuser= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert sysAdminuser;           
        
        System.runAs(sysAdminuser) {
            agentStandardUserRole= new UserRole(name='AgentRole');                    
            insert agentStandardUserRole;
            agentTeamMemberUserRole = new UserRole(name= 'AgentTeamMemberRole', parentRoleId = agentStandardUserRole.id);
            insert agentTeamMemberUserRole;
            proxyStandardUserRole = new UserRole(name='ProxyRole', parentRoleId = agentTeamMemberUserRole.id);
            insert proxyStandardUserRole;
            User testProxyUser1 = new User(Alias='Prox',LastName='opportunityAg',Username='TestProxUserForOppTst11@statefarm.com',UserExternalID__c='123testP',Servicing_Agent_Associate_ID__c='123test');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId= proxyStandardUserRole.id;
            Database.insert(proxyUser);
            User testAgentUser1 = new User(Alias='Alia',LastName='opportunityProxy',Username='TestAgtUserForOppTst11@statefarm.com',Associate_ID__c='123test',UserExternalID__c='123test_123test',Servicing_Agent_Associate_ID__c='123test');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
            agentUser.userRoleId= agentStandardUserRole.id;
            Database.insert(agentUser);
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            HLPR_SignedWrittenConsent_TEST.createSwcToggleRecord();
        }
    }
    
    //method to build Account record with the given parameter value
    private static Account buildAccountRecord(String paramClientIdentifier) {
        String acctRecordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId;
        Account acctRecord = new Account(FirstName = 'rrrrr', LastName = 'tttttttt', ClientIdentifier__c = paramClientIdentifier,RecordTypeId = acctRecordTypeId,
                                         Edit_In_VFP__c = true,PersonDoNotCall = true);
        return acctRecord;
    }
    
    //method to build Opportunity record with the given parameter value
    private static Opportunity buildOpportunityRecord(String paramAccountId, String paramLOB) {
        Opportunity opptyRecord = new Opportunity (Name = 'Tst Opportunity', AccountId = paramAccountId,
                                                   CloseDate = System.today().addDays(10), LOB__c = paramLOB,
                                                   StageName = 'New',DateCaptured__c = System.today().addDays(-9));
        return opptyRecord; 
    }

    @isTest
    private static void testRetrievingRelationshipStatusToAgent(){
        User queryAgent = [Select id from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];        
        agentUser= queryAgent;        
        Account testAccount;
        System.runAs(agentUser) {
            testAccount = buildAccountRecord('1213121');
            insert testAccount;            
        }
        
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentUser.id,RelationshipNature__c = 'Prospect');
        insert newAgentRole;
        System.runAs(agentUser) {            
            Test.startTest();
            String relationshipNature = LWC_SignedWrittenConsent.retrieveRelationshipStatus(testAccount.Id);
            Test.stopTest();
            System.assertEquals('Prospect', relationshipNature, 'Agent Account Relation is not as expected');
        }     
    }
    
    //testMethod to test signed written consent response as agent user
    @isTest
    private static void testSignedWrittenConsentAsAgent(){
        User queryAgent = [Select id from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];        
        agentUser= queryAgent;        
        Account testAccount;
        System.runAs(agentUser) {
            testAccount = buildAccountRecord('1213121');
            insert testAccount;            
        }
        
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentUser.id,RelationshipNature__c = 'Prospect');
        insert newAgentRole;
        System.runAs(agentUser) {            
            Test.startTest();
            LWC_SignedWrittenConsent.SignedWrittenConsentResponse signedWrittenConsentData = LWC_SignedWrittenConsent.signedWrittenConsentToastRequest(testAccount.Id);
            Test.stopTest();
            System.assertEquals(true, signedWrittenConsentData.isNotCustomerRelation, 'Agent Account Relation is not as expected');
            System.assertEquals(true, signedWrittenConsentData.isToggleOff, 'Signed Written Consent toggle is on');
        }        
    }
    
    //testMethod to test signed written consent response as support user
    @isTest
    private static void testSignedWrittenConsentAsSupportUser(){
        User querySupportUser = [Select id from User where username = 'systemAdminTest@statefarm.com' LIMIT 1];
        sysAdminuser = querySupportUser;
        System.runAs(sysAdminuser) {
            Account testAccount = buildAccountRecord('1213121');
            insert testAccount;             
            Test.startTest();
            LWC_SignedWrittenConsent.SignedWrittenConsentResponse signedWrittenConsentData = LWC_SignedWrittenConsent.signedWrittenConsentToastRequest(testAccount.Id);
            Test.stopTest();
            System.assertEquals(false, signedWrittenConsentData.isNotCustomerRelation, 'Agent Account Relation is not as expected');
            System.assertEquals(true, signedWrittenConsentData.isToggleOff, 'Signed Written Consent toggle is on');
        }        
    }
    
    //testMethod to test update signed written consent values in opportunities on swc request
    @isTest
    private static void testUpdateOpportunitiesSwc(){
        User queryAgent = [Select id from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];        
        agentUser= queryAgent;
        User queryProxyUser = [Select id from User where username = 'TestProxUserForOppTst11@statefarm.com' LIMIT 1];
        proxyUser = queryProxyUser;
        Account testAccount;
        System.runAs(agentUser) {
            testAccount = buildAccountRecord('1213121');
            insert testAccount;            
        }
        
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=testAccount.id, agent__c=agentUser.id,RelationshipNature__c = 'Prospect');
        insert newAgentRole;
        System.runAs(agentUser) {
            List<Opportunity> oppList = new List<Opportunity>();
            oppList.add(buildOpportunityRecord(testAccount.id, 'Auto'));
            oppList.add(buildOpportunityRecord(testAccount.id, 'Fire'));
            insert oppList;
            Test.startTest();
            LWC_SignedWrittenConsent.updateOpportunitiesSignedWrittenConsent(testAccount.Id,proxyUser.Id);            
            Test.stopTest();
            List<Opportunity> updatedOpportunityList = [Select id,OppSignedWrittenConsentStatus__c,OppSignedWrittenConsentRequestedDate__c,Assigned_To__c from Opportunity where OwnerId =:proxyUser.Id];
            for(Opportunity updatedOpportunity : updatedOpportunityList){
                System.assertEquals('Requested', updatedOpportunity.OppSignedWrittenConsentStatus__c, 'Opportunity signed written consent status is not as expected');
                System.assertEquals(System.Today(),updatedOpportunity.OppSignedWrittenConsentRequestedDate__c, 'Opportunity signed written consent requested date is not as expected');
                System.assertEquals(null,updatedOpportunity.Assigned_To__c, 'Opportunity assigned to is not as expected');
            }                      
        }
    }
}
