/**
* Author : Golden Spikes Team
* Date Created : 10/09/2017
* @description : Test class for the AP_SPISecurityManagerCase_TEST apex class.
*/
@isTest (seeAllData=false)
public class AP_SPISecurityManagerCase_TEST {

    private static String agentProfileId = getProfileId(UTIL_Constants.AGENT_PROFILE_NAME);
    private static String proxyProfileId = getProfileId(UTIL_Constants.PROXY_PROFILE_NAME);
    private static String adminProfileId = getProfileId(UTIL_Constants.SYSTEM_ADMIN_PROFILE_NAME);
    private static String noAccessProfileId = getProfileId('1.02 No Access');
    private static final String SECONDS_FORMAT= 'ssSSS';

    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap = Schema.Sobjecttype.Account.getRecordTypeInfosByName();   

    //method to bypass Trigger
    private static void byPassTrigger() {
        CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c();
        objectBasedByPassTrigger.Override_All__c = true;
        insert objectBasedByPassTrigger;
    }

    //method to get the ProfileId for the given Profile Name
    private static String getProfileId(String profileName) {
        String profileId = [SELECT Id FROM Profile WHERE name = :profileName LIMIT 1].Id;
        return profileId;
    }

    //method to build user with the given parameter value
    private static User buildUser(String param_UserName, String param_profileId, String param_associateId, String param_servicingAgentAssociateId, String param_externalId) {
        User testUser = new User (alias = '12345', email = 'testUser@statefarm.com.bad', emailencodingkey='UTF-8', lastname='TestUserLastName',
            languagelocalekey='en_US',localesidkey='en_US', timezonesidkey='America/Chicago', 
            username= param_UserName, profileId = param_profileId,
            Associate_ID__c = param_associateId, Servicing_Agent_Associate_ID__c = param_servicingAgentAssociateId,
            UserExternalID__c = param_externalId
        );
        return testUser;
    }

    //method to build userrole with parentRole with the given parameter value
    private static UserRole buildRoleWithParentRole(String roleName, String parentrole) {
        UserRole role = new UserRole(name = roleName, parentRoleId = parentrole);
        return role;
    }

    //method to build userrole with the given parameter value
    private static UserRole buildRole(String roleName) {
        UserRole role = new UserRole(name = roleName);
        return role;
    }

    //method to build Account Owner custom setting record with the given parameter value
    private static AccountOwnerSystemUserCustomSetting__c buildCustomSettingRecord(String userId) {
        AccountOwnerSystemUserCustomSetting__c actOwnerCs = new AccountOwnerSystemUserCustomSetting__c(Name = UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER, SFDC_USER_ID__c = userId);
        return actOwnerCs;
    }

    //method to build Account record with the given parameter value
    private static Account buildAccountRecord(String param_clientIdentifier) {
		UTIL_SetFSCCustomSettings_TEST.setFSCSettings(); 
        Account act = new Account(Edit_In_VFP__c=true,FirstName = 'rrrrr', LastName = 'tttttttt',
        RecordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId, ClientIdentifier__c = param_clientIdentifier);
        return act;
    }

    //method to build Agent Role record with the given parameter value
    private static AgentRole__c buildAgentRoleRecord(String param_accountId) {
        AgentRole__c agentRole = new AgentRole__c (RelationshipNature__c = 'Customer',
                       Agent__c = userInfo.getUserId(), Customer__c = param_accountId);
        return agentRole;
    }

    //method to build Case record with the given parameter value
    private static Case buildCaseRecord(String param_Status, String param_Origin, String param_accountId, String param_agentAssociateId , String param_nextStep, String param_ownerId) {
        Case tstCase = new Case(AccountId = param_accountId, 
                            Status = param_Status, Case_Originator__c = param_Origin, AgentAssociateId__c = param_agentAssociateId, ownerId = param_ownerId,
                            NextStep__c = param_nextStep
                          );
        return tstCase;
    }

    //test method to Validate SPI Prevention on "Nextstep" and "Prior Call Logged" fields on Case insert as an Agent for Case.
    @isTest
    private static void testSPIPreventionOnCaseNextstepInsertAsAgent() {
        User agentUser;
        User proxyUser;
        Account act;
        User adminUser = buildUser(UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'spi1_test1Case1Admn1' + '@sfa111.test.com', adminProfileId, '', '', '');

        System.runAs(adminUser) {
            byPassTrigger();
            UTIL_SPITestDataCreation_TEST.createSPIDataPreventionFieldsForCaseNextSteps();
            UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
            UTIL_SPITestDataCreation_TEST.createSPIChunkSize();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            agentUser = buildUser(UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'spi1_test1Case1Agnt1' + '@sfa111.test.com', agentProfileId , 'ppccww11ttc', 'ppccww11ttc', 'ppccww11ttc');
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;

            proxyUser = buildUser(UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'spi1_test1Case1Prox1' + '@sfa111.test.com', proxyProfileId, '', 'ppccww11ttc', 'ppccww11ttcP');
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            User systemUser = buildUser(UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'spi1_test1Case1Syst1' + '@sfa111.test.com', noAccessProfileId, '', '', '');
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            act = buildAccountRecord('9201011');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;

            CS001_ByPassTriggerAll__c objectBasedByPassTrigger = [Select id from CS001_ByPassTriggerAll__c limit 1];
            objectBasedByPassTrigger.Override_All__c = false;
            update objectBasedByPassTrigger;
        }

        System.runAs(adminUser) {
            Test.startTest();
            try {
                Case tstCase = buildCaseRecord('New', 'CCC Sales', act.id, 'ppccww11ttc', 'Tst 673-46-3987', proxyUser.id);
                insert tstCase;
            } catch(Exception e) {
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.CASE_NEXT_STEP_ON_BREACH_ERROR_MSG), 'Error Message');
            }
            List<Case> cases = [Select Id from Case limit 1];
            System.assert(cases.isEmpty(),'Cases is empty');
            Test.stopTest();
        }
    }

    //test method to Validate SPI Prevention on  "Prior Call Logged" field on Case Insert as an Agent.
    @isTest
    private static void testSPIPreventionOnCaseUpdateAsAgent() {
        User agentUser;
        User proxyUser;
        Account act;
        Case tstCasetoInsert;
        User adminUser = buildUser(UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'spi3_test3Case3Admn3' + '@sfa333.test.com', adminProfileId, '', '', '');

        System.runAs(adminUser) {
            byPassTrigger();
            UTIL_SPITestDataCreation_TEST.createSPIDataPreventionFieldsForCaseNextSteps();
            UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
            UTIL_SPITestDataCreation_TEST.createSPIChunkSize();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            agentUser = buildUser(UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'spi3_test3Case3Agnt3' + '@sfa333.test.com', agentProfileId , 'ppccww33ttc', 'ppccww33ttc', 'ppccww33ttc');
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;

            proxyUser = buildUser(UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'spi3_test3Case3prox3' + '@sfa333.test.com', proxyProfileId, '', 'ppccww33ttc', 'ppccww33ttcP');
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            User systemUser = buildUser(UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'spi3_test3Case3Syst3' + '@sfa333.test.com', noAccessProfileId, '', '', '');
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
        System.runAs(agentUser) {
            act = buildAccountRecord('9203033');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;

            CS001_ByPassTriggerAll__c objectBasedByPassTrigger = [Select id from CS001_ByPassTriggerAll__c limit 1];
            objectBasedByPassTrigger.Override_All__c = false;
            update objectBasedByPassTrigger;
        }

        System.runAs(adminUser) {
            tstCasetoInsert = buildCaseRecord('New', 'CCC Sales', act.id, 'ppccww33ttc', 'kkkkkkkrrrrr', proxyUser.id);
            insert tstCasetoInsert;
        }

        System.runAs(agentUser) {
            Test.startTest();
            try {
                Case tstCasetoUpdate = new Case(id= tstCasetoInsert.id, NextStep__c = '647-59-3423', Case_Originator__c = 'CCC Sales');
                update tstCasetoUpdate;
            } catch(Exception e) {
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.CASE_PRIOR_CALL_LOGGED_ON_BREACH_ERROR_MSG), 'Error Message');
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.CASE_NEXT_STEP_ON_BREACH_ERROR_MSG), 'Error Message');
            }
            Case tstCase;
            tstCase = [Select NextStep__c from Case where id =: tstCasetoInsert.id];

            Test.stopTest(); 
        }
    }
}