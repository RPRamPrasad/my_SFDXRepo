/**
* Author : Golden Spikes Team
* Date Created : 08/23/2017
* @description : Test class for the AP_SPISecurityManagerOpportunity_TEST apex class.
*/
@isTest (seeAllData=false)
public class AP_SPISecurityManagerOpportunity_TEST {

    private static String agentProfileId = getProfileId(UTIL_Constants.AGENT_PROFILE_NAME);
    private static String proxyProfileId = getProfileId(UTIL_Constants.PROXY_PROFILE_NAME);
    private static String adminProfileId = getProfileId(UTIL_Constants.SYSTEM_ADMIN_PROFILE_NAME);
    private static String noAccessProfileId = getProfileId('1.02 No Access');
    private static final String SECONDS_FORMAT= 'ssSSS';
    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap = Schema.Sobjecttype.Account.getRecordTypeInfosByName();
  //  private static Map<String, Schema.Recordtypeinfo> opportunityRecordTypeMap = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName();

    private static String optyRecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByDeveloperName().get('Opportunity_Management').getRecordTypeId();

    //method to bypass Trigger
    private static void byPassTrigger() {
        CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c();
        objectBasedByPassTrigger.Override_All__c = true;
        insert objectBasedByPassTrigger;
    }

    //method to get the ProfileId for the given Profile Name
    private static String getProfileId(String profileName) {
        return [SELECT Id FROM Profile WHERE name = :profileName LIMIT 1].Id;
        
    }

    //method to build user with the given parameter value
    private static User buildUser(String param_UserName, String param_profileId, String param_associateId, String param_servicingAgentAssociateId, String param_externalId) {
        return new User (alias = '12345', email = 'testUser@statefarm.com.bad', emailencodingkey='UTF-8', lastname='TestUserLastName',
            languagelocalekey='en_US',localesidkey='en_US', timezonesidkey='America/Chicago', 
            username= param_UserName, profileId = param_profileId,
            Associate_ID__c = param_associateId, Servicing_Agent_Associate_ID__c = param_servicingAgentAssociateId,
            UserExternalID__c = param_externalId
        );
    
    }

    //method to build userrole with parentRole with the given parameter value
    private static UserRole buildRoleWithParentRole(String roleName, String parentrole) {
        return new UserRole(name = roleName, parentRoleId = parentrole);
        
    }

    //method to build userrole with the given parameter value
    private static UserRole buildRole(String roleName) {
        return new UserRole(name = roleName);
        
    }

    //method to build Account Owner custom setting record with the given parameter value
    private static AccountOwnerSystemUserCustomSetting__c buildCustomSettingRecord(String userId) {
        return new AccountOwnerSystemUserCustomSetting__c(Name = UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER, SFDC_USER_ID__c = userId);
        
    }

    //method to build Account record with the given parameter value
    private static Account buildAccountRecord(String param_clientIdentifier) {
		UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        return new Account(FirstName = 'rrrrr', LastName = 'tttttttt',
        RecordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId, ClientIdentifier__c = param_clientIdentifier);

    }

    //method to build Agent Role record with the given parameter value
    private static AgentRole__c buildAgentRoleRecord(String param_accountId) {
        return new AgentRole__c (RelationshipNature__c = 'Customer',
                       Agent__c = userInfo.getUserId(), Customer__c = param_accountId);
    
    }

    //method to build Opportunity record with the given parameter value
    private static Opportunity buildOpportunityRecord(String param_accountId, String param_LOB, String param_StageName, String param_recordTypeId, String param_nextStep, String param_priorCallLogged, String param_ownerId) {
        return new Opportunity (Name = 'Tst Opty', AccountId = param_accountId, 
                            CloseDate = Date.today() + 1, LOB__c = param_LOB, Product__c = 'Commercial', ownerId = param_ownerId,
                            StageName = param_StageName, RecordTypeId = param_recordTypeId, NextStep__c = param_nextStep, PriorCallLogged__c = param_priorCallLogged
                          );

    }

    //test method to Validate SPI Prevention on "Nextstep" field on insert as an Agent for Manual Opportunity record.
    @isTest
    private static void testSPIPreventionOnOpportunityInsertAsAgent() {
        User agentUser;
        User proxyUser;
        User adminUser = buildUser(UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'spi1_test1Opty1Admn1' + '@sfa111.test.com', adminProfileId, '', '', '');

        System.runAs(adminUser) {
            byPassTrigger();
            UTIL_SPITestDataCreation_TEST.createSPIDataPreventionFieldsForOpportunity();
            UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
            UTIL_SPITestDataCreation_TEST.createSPIChunkSize();
            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            agentUser = buildUser(UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'spi1_test1Opty1Agnt1' + '@sfa111.test.com', agentProfileId , 'ppccww11ttc', 'ppccww11ttc', 'ppccww11ttc');
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;

            proxyUser = buildUser(UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'spi1_test1Opty1Prox1' + '@sfa111.test.com', proxyProfileId, '', 'ppccww11ttc', 'ppccww11ttcP');
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            User systemUser = buildUser(UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'spi1_test1Opty1Syst1' + '@sfa111.test.com', noAccessProfileId, '', '', '');
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);

        System.runAs(agentUser) {
            Account act = buildAccountRecord('9701011');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;

            CS001_ByPassTriggerAll__c objectBasedByPassTrigger = [Select id from CS001_ByPassTriggerAll__c limit 1];
            objectBasedByPassTrigger.Override_All__c = false;
            update objectBasedByPassTrigger;

            Test.startTest();
            try {
                Opportunity opty = buildOpportunityRecord(act.id, 'Auto', 'New', optyRecordTypeId, '123-45-6789', 'rrrrrrr', proxyUser.id);
                insert opty;
            } catch(Exception e) {
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.OPPORTUNITY_NEXT_STEP_ON_BREACH_ERROR_MSG),'Exception Message does not contain the value ' +UTIL_SPITestConstants.OPPORTUNITY_NEXT_STEP_ON_BREACH_ERROR_MSG);
            }
            List<Opportunity> opportunities = [Select Id from Opportunity limit 1];
            System.assert(opportunities.isEmpty(),'Expected value should be Empty, but actual value is:'+opportunities.isEmpty());
            Test.stopTest();
        }
    }

    //test method to Validate SPI Prevention on "Nextstep" and "Prior Call Logged" field on insert as an Agent for Manual Opportunity record.
    @isTest
    private static void testSPIPreventionForMultipleFieldsOnOpportunityInsertAsAgent() {
        User agentUser;
        User proxyUser;
        User adminUser = buildUser(UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'spi2_test2Opty2Admn2' + '@sfa222.test.com', adminProfileId, '', '', '');

        System.runAs(adminUser) {
            byPassTrigger();
            UTIL_SPITestDataCreation_TEST.createSPIDataPreventionFieldsForOpportunity();
            UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
            UTIL_SPITestDataCreation_TEST.createSPIChunkSize();
            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            agentUser = buildUser(UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'spi2_test2Opty2Agnt2' + '@sfa222.test.com', agentProfileId , 'ppccww22ttc', 'ppccww22ttc', 'ppccww22ttc');
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;

            proxyUser = buildUser(UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'spi2_test2Opty2Prox2' + '@sfa222.test.com', proxyProfileId, '', 'ppccww22ttc', 'ppccww22ttcP');
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            User systemUser = buildUser(UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'spi2_test2Opty2Syst2' + '@sfa222.test.com', noAccessProfileId, '', '', '');
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);

        System.runAs(agentUser) {
            Account act = buildAccountRecord('9702022');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;

            CS001_ByPassTriggerAll__c objectBasedByPassTrigger = [Select id from CS001_ByPassTriggerAll__c limit 1];
            objectBasedByPassTrigger.Override_All__c = false;
            update objectBasedByPassTrigger;

            Test.startTest();
            try {
                Opportunity opty = buildOpportunityRecord(act.id, 'Auto', 'New', optyRecordTypeId, '123-45-6789', '123-45-6789', proxyUser.id);
                insert opty;
            } catch(Exception e) {
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.OPPORTUNITY_NEXT_STEP_ON_BREACH_ERROR_MSG),'Exception Message does not contain the value ' +UTIL_SPITestConstants.OPPORTUNITY_NEXT_STEP_ON_BREACH_ERROR_MSG);
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.OPPORTUNITY_PRIOR_CALL_LOGGED_ON_BREACH_ERROR_MSG),'Exception Message does not contain the value ' +UTIL_SPITestConstants.OPPORTUNITY_PRIOR_CALL_LOGGED_ON_BREACH_ERROR_MSG);
            }
            List<Opportunity> opportunities = [Select Id from Opportunity limit 1];
            System.assert(opportunities.isEmpty(),'Expected value should be Empty, but actual value is:'+opportunities.isEmpty());
            Test.stopTest();
        }
    }

    //test method to validate SPI Prevention on "Prior Call Logged" field on update as an Agent for Manual Opportunity record.
    @isTest
    private static void testSPIPreventionOnOpportunityUpdateAsAgent() {
        User agentUser;
        User proxyUser;
        User adminUser = buildUser(UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'spi3_test3Opty3Admn3' + '@sfa333.test.com', adminProfileId, '', '', '');
        Opportunity optyToBeInserted;

        System.runAs(adminUser) {
            byPassTrigger();
            UTIL_SPITestDataCreation_TEST.createSPIDataPreventionFieldsForOpportunity();
            UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
            UTIL_SPITestDataCreation_TEST.createSPIChunkSize();

            UserRole agentUserRole = buildRole('AgentRole');
            insert agentUserRole;

            UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
            insert proxyUserRole;

            agentUser = buildUser(UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'spi3_test3Opty3Agnt3' + '@sfa333.test.com', agentProfileId , 'ppccww33ttc', 'ppccww33ttc', 'ppccww33ttc');
            agentUser.userRoleId = agentUserRole.id;
            insert agentUser;

            proxyUser = buildUser(UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'spi3_test3Opty3Prox3' + '@sfa333.test.com', proxyProfileId, '', 'ppccww33ttc', 'ppccww33ttcP');
            proxyUser.userRoleId = proxyUserRole.id;
            insert proxyUser;

            User systemUser = buildUser(UserInfo.getOrganizationId() + system.now().format(SECONDS_FORMAT) + 'spi3_test3Opty3Syst3' + '@sfa333.test.com', noAccessProfileId, '', '', '');
            insert systemUser;

            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
        }
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);

        System.runAs(agentUser) {
            Account act = buildAccountRecord('9703033');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            insert agentRole;

            CS001_ByPassTriggerAll__c objectBasedByPassTrigger = [Select id from CS001_ByPassTriggerAll__c limit 1];
            objectBasedByPassTrigger.Override_All__c = false;
            update objectBasedByPassTrigger;

            Opportunity opty = buildOpportunityRecord(act.id, 'Auto', 'New', optyRecordTypeId,'TstTstTstTstTst', 'Tst1Tst2Tst3Tst4Tst5',  proxyUser.id);
            insert opty;

            Test.startTest();
            try {
                optyToBeInserted = buildOpportunityRecord(act.id, 'Auto', 'New', optyRecordTypeId, 'rrrrrrr-nextStep', 'rrrrrr-priorCallLogged',  proxyUser.id);
                insert optyToBeInserted;
                Opportunity optyToBeUpdated = new Opportunity(id = optyToBeInserted.id, NextStep__c = '123-45-6789', PriorCallLogged__c = '123-45-6789');
                HLPR_SignedWrittenConsent.byPassOpportunityBeforeUpdate = false;
                update optyToBeUpdated;
            } catch(Exception e) {
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.OPPORTUNITY_NEXT_STEP_ON_BREACH_ERROR_MSG),'Exception Message does not contain the value '+UTIL_SPITestConstants.OPPORTUNITY_NEXT_STEP_ON_BREACH_ERROR_MSG);           
                System.assert(e.getMessage().contains(UTIL_SPITestConstants.OPPORTUNITY_PRIOR_CALL_LOGGED_ON_BREACH_ERROR_MSG),'Exception Message does not contain the value ' +UTIL_SPITestConstants.OPPORTUNITY_PRIOR_CALL_LOGGED_ON_BREACH_ERROR_MSG);
            }
            Opportunity tstOpportunity = [Select NextStep__c, PriorCallLogged__c from Opportunity where id =: optyToBeInserted.id];
            System.assertEquals('rrrrrrr-nextStep', tstOpportunity.NextStep__c,'Expected value is rrrrrrr-nextStep, but actual value is '+tstOpportunity.NextStep__c);
            System.assertEquals('rrrrrr-priorCallLogged', tstOpportunity.PriorCallLogged__c,'Expected value is rrrrrr-priorCallLogged, but actual value is '+tstOpportunity.PriorCallLogged__c);
            Test.stopTest();
        }
    }
}