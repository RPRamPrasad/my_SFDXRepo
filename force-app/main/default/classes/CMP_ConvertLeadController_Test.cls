/**
 * Author : Golden Spikes Team
 * Date Created : 06/12/2019
 * Description : Test class for the CMP_ConvertLeadController apex class.
 * @description CMP_ConvertLeadController_Test
 */
@isTest(seeAllData=false)
private class CMP_ConvertLeadController_Test {
    private static final String SECONDS_FORMAT = 'ssSSS';
    private static Map<String, Schema.Recordtypeinfo> leadRecordTypeMap = Schema.Sobjecttype.Lead.getRecordTypeInfosByName();
    private static User agentUser;
    private static User atmUser;
    private static User cccLUser;
    private static User proxyUser;
    private static User adminUser;
    private static UserRole proxyStandardUserRole;
    private static UserRole atmStandardUserRole;
    private static UserRole agentStandardUserRole;

    @TestSetup
    private static void makeData() {
        adminUser = UTIL_UserProvisioning_TEST.buildSystemAdmin('alias', 'systemAdmin', 'systemAdminTestcvtdx@statefarm.com');
        System.runAs(adminUser) {
            agentStandardUserRole = new UserRole(name = 'AgentRole');
            insert agentStandardUserRole;
            atmStandardUserRole = new UserRole(name = 'ATMMRole', parentRoleId = agentStandardUserRole.id);
            insert atmStandardUserRole;
            proxyStandardUserRole = new UserRole(name = 'ProxyRole', parentRoleId = atmStandardUserRole.id);
            insert proxyStandardUserRole;
            User testProxyUser1 = new User(Alias='Proxy',LastName='TaskProxy',Username='testcvtproxyleadfetchdx@statefarm.com',UserExternalID__c='11rrtt22zzcP',Servicing_Agent_Associate_ID__c='11rrtt22zzc');
            proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
            proxyUser.userRoleId = proxyStandardUserRole.id;
            proxyUser.UserExternalID__c = '11rrtt22zzcP';
            Database.insert(proxyUser);
            atmUser = UTIL_UserProvisioning_TEST.buildAgentTeamUser('ATM', 'TaskATM', 'testcvtAtmleadfetchdx@statefarm.com');
            atmUser.userRoleId = atmStandardUserRole.id;
            atmUser.Servicing_Agent_Associate_ID__c = '11rrtt22zzc';
            Database.insert(atmUser);
            User testAgentUser1 = new User(Alias='Agent',LastName='TaskAgent',Username='testcvtAgentleadfetchdx@statefarm.com',Associate_ID__c='11rrtt22zzc',UserExternalID__c='11rrtt22zzc_11rrtt22zzc',Servicing_Agent_Associate_ID__c='11rrtt22zzc');
            agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
            agentUser.userRoleId = agentStandardUserRole.id;
            agentUser.UserExternalID__c = '11rrtt22zzc_11rrtt22zzc';
            agentUser.UserPermissionsMarketingUser = true;            
            cccLUser = UTIL_UserProvisioning_TEST.buildCCCLicensedUser(); 
            cccLUser.UserExternalID__c = 'LdConvCCC';
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser, cccLUser});
            cccLUser.SubUserType__c = 'CCC Sales';
            Database.update(cccLUser);
        }
    }

    //method to fetch Users
    private static void fetchUsers() {
        List<User> usrlist = [SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c,
            Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, UserType__c, SubUserType__c FROM User
            WHERE UserExternalID__c IN ('11rrtt22zzc_11rrtt22zzc', '11rrtt22zzcP')];
        for (User usrobj : usrlist) {
            if (usrobj.UserExternalID__c == '11rrtt22zzc_11rrtt22zzc') {
                agentUser = usrobj;
            } else {
                proxyUser = usrobj;
            }
        }
    }

    //Convert Lead: test method to fetch the Lead Record Info as an Agent.
    @isTest private static void testFetchConvetInfoAsAgent() {
        fetchUsers();
        System.runAs(agentUser) {
            Lead leadRec = new Lead(LastName = 'LeadTest123', ownerId = proxyUser.id, recordtypeId = leadRecordTypeMap.get('Lead').RecordTypeId);
            insert leadRec;
            Test.startTest();
            CMP_ConvertLeadController.ConvertLeadWrapper ldWrp = CMP_ConvertLeadController.fetchConvertInfo(leadRec.id);
            System.assertEquals(leadRec.Id, ldWrp.leadRecordInfo.Id,'Expected Id is'+leadRec.Id+', but actual value is'+ldWrp.leadRecordInfo.Id);
            System.assert(ldWrp.isSuccessOnFetchValues,'Assertion Failed');
            Test.stopTest();
        }
    }

    //Convert Lead: test method to fetch the Lead Record Info as CCC User.
    @isTest private static void testFetchConvetInfoAsCCC() {
        cccLUser = [select id, SubUserType__c from user where alias = 'CCCL' limit 1];
        String agentContextValue = '';
        System.runAs(cccLUser) { 
            Lead leadRec = new Lead(LastName = 'LeadTest123', AgentAssociateId__c = '11rrtt22zzc', recordtypeId = leadRecordTypeMap.get('Lead').RecordTypeId);
            User agentContextId = [Select Id from User where UserExternalID__c = '11rrtt22zzc_11rrtt22zzc' limit 1];
            agentContextValue = agentContextId.Id;
            insert leadRec;
            Test.startTest();
            CMP_ConvertLeadController.ConvertLeadWrapper ldWrp = CMP_ConvertLeadController.fetchConvertInfo(leadRec.id);
            ldWrp.agentContextInfo = CMP_ConvertLeadController.fetchAgentContextForCCCUser(leadRec.AgentAssociateId__c);
            System.assertEquals(leadRec.Id, ldWrp.leadRecordInfo.Id,'Expected Id is'+leadRec.Id+', but actual value is'+ldWrp.leadRecordInfo.Id);
            System.assertEquals(agentContextValue, ldWrp.agentContextInfo,'Expected Context is'+agentContextValue+', but actual value is'+ldWrp.agentContextInfo);
            System.assert(ldWrp.isSuccessOnFetchValues,'Assertion Failed');
            Test.stopTest();
        }
    }

    //Convert Lead: test method to fetch the Convert Info for any exception.
    @isTest private static void testFetchConvetInfoForException() {
        fetchUsers();
        String leadRecordId = '';
        Lead leadRec = new Lead(LastName = 'LeadTest123', recordtypeId = leadRecordTypeMap.get('Lead').RecordTypeId);
        insert leadRec;
        leadRecordId = leadRec.Id;
        System.runAs(agentUser) {
            Test.startTest();
            CMP_ConvertLeadController.ConvertLeadWrapper ldWrp = CMP_ConvertLeadController.fetchConvertInfo(leadRecordId);
            System.assert(ldWrp.leadRecordInfo == null,'leadRecordInfo should be null');
            System.assert(!ldWrp.isSuccessOnFetchValues,'Assertion Failed');
            Test.stopTest();
        }
    }
    
    //Convert Lead: test method to fetch the Agent Context Info for any exception.
    @isTest private static void testFetchAgentContextInfoForException() {
        cccLUser = [select id, SubUserType__c from user where alias = 'CCCL' limit 1];
        System.runAs(cccLUser) { 
        String leadRecordId = '';
        String agentContextInfo = '';
        Lead leadRec = new Lead(LastName = 'LeadTest123', AgentAssociateId__c = '', recordtypeId = leadRecordTypeMap.get('Lead').RecordTypeId);
        insert leadRec;
        leadRecordId = leadRec.Id;
            Test.startTest();
            CMP_ConvertLeadController.ConvertLeadWrapper ldWrp = CMP_ConvertLeadController.fetchConvertInfo(leadRecordId);
            ldWrp.agentContextInfo = CMP_ConvertLeadController.fetchAgentContextForCCCUser(leadRec.AgentAssociateId__c);
            System.assert(ldWrp.isSuccessOnFetchValues,'Assertion Failed');
            Test.stopTest();
        }
    }
}