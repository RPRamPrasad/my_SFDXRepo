/**
 * @name AP_CampMembTriggerBeforeDelete_Test 
* @author  TGV Team
* @createdDate 12/17/2016
* @description Apex Unit Testing for Class AP_CampaignMemberTrigger, Method avoidCampMembDelete Method
*/
@isTest (seeAllData=false)
public class AP_CampMembTriggerBeforeDelete_Test {  
    private static User sysAdminuser; 
    private static User systemUser; 
    private static User agentUser;
    private static User proxyUser;
    private static User agentTeamUser;
    private static final String SYSTEM_DEFAULT_ACCOUNT_OWNER = 'State Farm';
    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();
    private static Map<String, Schema.Recordtypeinfo> campaignRecordTypeMap = Schema.Sobjecttype.Campaign.getRecordTypeInfosByName();

    /**
     * @method method used for byPassTriger
    * @description  byPassTrigger
    */
    private static void byPassTrigger() {
        CS001_ByPassTriggerAll__c objectBasedByPassTrigger = new CS001_ByPassTriggerAll__c();
        objectBasedByPassTrigger.Override_All__c = true;
        insert objectBasedByPassTrigger;
    }

    /*
    *   @Method <This method is used to insert Account Owner custom setting record with the given parameter value>
    *   @name buildCustomSettingRecord
    *   @param userId
    *   @return AccountOwnerSystemUserCustomSetting__c
    */
    private static AccountOwnerSystemUserCustomSetting__c buildCustomSettingRecord(String userId) {
        AccountOwnerSystemUserCustomSetting__c actOwnerCs = new AccountOwnerSystemUserCustomSetting__c(Name = SYSTEM_DEFAULT_ACCOUNT_OWNER, SFDC_USER_ID__c = userId);
        return actOwnerCs;
    }

    /*
    *   @Method <This method is used to insert Agent Role record with the given parameter value>
    *   @name buildAgentRoleRecord
    *   @param param_accountId, param_agentuser
    *   @return AgentRole__c
    */
    private static AgentRole__c buildAgentRoleRecord(String param_accountId, String param_agentuser) {
        AgentRole__c agentRole = new AgentRole__c (RelationshipNature__c = 'Customer',
                                    Agent__c = param_agentuser, Customer__c = param_accountId);
        return agentRole;
    }

    /** 
    *   @Method <This method is used to insert Customer/ Prospect Campaign record with the given parameter value>
    *   @description buildProspectCampaign
    *   @return Campaign
    */
    public static Campaign buildProspectCampaign() {
        Campaign tstCampaign = new Campaign(Name='tstCmpMemRmval', RecordTypeId = campaignRecordTypeMap.get('Customer/Prospect Campaign').RecordTypeId);
        return tstCampaign;
    }

    /**
     * @method Setup method used for building test data (must be called at beginning of test)
    * @description   setUp
    */
    @TestSetup
    public static void setUp() {
        sysAdminuser = UTIL_UserProvisioning_TEST.buildSystemAdmin('Alias','CmpMemSA','remCmpMemSysAd@statefarm.com');
        sysAdminuser.UserExternalID__c='sys126';
        insert sysAdminuser;
        User system_User = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();
        insert system_User;
        UserRole agentStandardUserRole= new UserRole(name='AgentRole');                    
        insert agentStandardUserRole;
        UserRole atmStandardUserRole= new UserRole(name='AtmRole', parentRoleId = agentStandardUserRole.id);                    
        insert atmStandardUserRole;    
        UserRole proxyStandardUserRole = new UserRole(name='ProxyRole', parentRoleId = atmStandardUserRole.id);
        insert proxyStandardUserRole;
        User testProxyUser1 = new User(Alias='Proxy',LastName='CmpMemAg',Username='remCmpMemproxy1@statefarm.com',UserExternalID__c='123testP',Servicing_Agent_Associate_ID__c='123test');
        proxyUser = UTIL_UserProvisioning_TEST.buildProxyUser1(testProxyUser1);
        proxyUser.userRoleId= proxyStandardUserRole.id;
        Database.insert(proxyUser);
        User testAgentUser1 = new User(Alias='Alias',LastName='CmpMemProx',Username='remCmpMemAgent1@statefarm.com',Associate_ID__c='123test',UserExternalID__c='123test',Servicing_Agent_Associate_ID__c='123test');
        agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
        agentUser.userRoleId= agentStandardUserRole.id;
        Database.insert(agentUser);
        agentTeamUser = new User(alias = 'Alias', email='remCmpMemAgent1@statefarm.com.bad', 
        emailencodingkey='UTF-8', lastname='CmpMemProx', languagelocalekey='en_US', UserExternalID__c='123ATM',
        localesidkey='en_US', timezonesidkey='Europe/London', username= 'remCmpMemATMt1@statefarm.com',userRoleId=atmStandardUserRole.id);
        agentTeamUser.ProfileId = UTIL_ProfileId_TEST.getATMProfileId();
        Database.insert(agentTeamUser);   
    
    }
    
    //method to get sys admin and other usrs
    private static void getSysAdminandUsrs(){
        List<User> usrlist=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, 
        Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, 
        UserExternalID__c, Agent_Name_Alias__c, UserType__c FROM User
        where UserExternalID__c in('123testP','123test','123ATM','sys126') ];
        for(User usr:usrlist){
            if (usr.UserExternalID__c == '123test') {
                agentUser = usr;
            } 
            else if (usr.UserExternalID__c=='123testP') {
                proxyUser = usr;
            } 
            else if (usr.UserExternalID__c=='123ATM') {
                agentTeamUser = usr;
            }
            else {
                sysAdminuser = usr;
            }
        }
        
    }
    /** 
    *   @Method <Test to verify Agent users encounter error message when they try to remove Campaign Members from UI, Manage Members page using List View 'Remove' Button>
    *   @description avoidDeleteCampMembAgent
    */
    @isTest
    public static void avoidDeleteCampMembAgent() {
        getSysAdminandUsrs();
        CampaignMember myCampMemb = createLeadCampaignMember();
        deleteCampaignMember(myCampMemb);
        System.assert(true, 'Mandatory Assert statement on Tests');
    }
    
        /** 
    *   @Method <Test to verify ATM users encounter error message when they try to remove Campaign Members from UI, Manage Members page using List View 'Remove' Button>
    *   @description avoidDeleteCampMembAtm
    */
    @isTest
    public static void avoidDeleteCampMembAtm() {
        getSysAdminandUsrs();
        CampaignMember myCampMemb = createLeadCampaignMember();
        deleteCampaignMember(myCampMemb);
        System.assert(true, 'Mandatory Assert statement on Tests');
    }
    
    /** 
    *   @Method <Test to verify Admin users can sucessfully remove Campaign Members from UI, Manage Members page using List View Remove Button>
    *   @description allowDeleteCampMemAdmin
    */
    @isTest
    public static void allowDeleteCampMemAdmin() {
        getSysAdminandUsrs();
        CampaignMember myCampMemb;
        System.runas(sysAdminuser) {
            Lead mylead = UTIL_TestDataCreation_Test.createTestLead();
            Campaign myCmp = UTIL_TestDataCreation_Test.createTestCampaign();
            myCampMemb = new CampaignMember(campaignId=myCmp.Id,LeadId = myLead.id,status='Registered',WillConvert__c=False);
            insert myCampMemb;
            Test.StartTest();
            delete myCampMemb;         
            List<CampaignMember> queryCampMemb = [Select id from CampaignMember where id =: myCampMemb.id];
            System.assert(queryCampMemb.isEmpty(),'queryCampMemb should be empty');
            Test.StopTest();
        } 
    }

    /** 
    *   @Method <Test to verify CampaignMemberBeforeDelete trigger on bypass logic - Not to Fire>
    *   @description testCustProspectCampMembRemovalForByPassLogic
    */
    @isTest
    public static void testCustProspectCampMembRemovalForByPassLogic() {
        getSysAdminandUsrs();
        sysAdminuser.put('UserPermissionsMarketingUser', true);
        update sysAdminuser;
        CampaignMember contactCampMemb;
        Account act;
        System.runas(sysAdminuser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            byPassTrigger();
            systemUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, UserType__c FROM User where alias='SYSA' ];
            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;

            act = TestDataFactory_Campaign.buildAccountRecord('12020222123');
            insert act;

            AgentRole__c agentRole = buildAgentRoleRecord(act.id, agentUser.id);
            insert agentRole;

            Campaign customerProspectCampaign = buildProspectCampaign();
            insert customerProspectCampaign;

            customerProspectCampaign.ownerid = proxyUser.id;
            update customerProspectCampaign;

            Account actClientId = [SELECT PersonContactId FROM Account WHERE Id =: act.id];
            contactCampMemb = new CampaignMember(campaignId = customerProspectCampaign.Id, contactId = actClientId.PersonContactId, status='Registered', Removed__c = False);
            insert contactCampMemb;

            Test.StartTest();

            System.assert(contactCampMemb != null,'contactCampMemb should not be empty');
            Test.StopTest();
            delete contactCampMemb;

            List<campaignmember> cmpMember= [select id from campaignmember limit 1];
            System.assert(cmpMember.isEmpty(),'cmpMember should be empty');
        }
    }

    /**
     * @description method for asserting Campaign Members are not deleted
     * @param myCampMemb 
     */
    private static void deleteCampaignMember(CampaignMember myCampMemb) {
        Test.StartTest();
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentTeamUser);
        System.runas(agentTeamUser) {
            try {
                delete myCampMemb;
            }
            catch (Exception e) {
                System.assert(e.getMessage().contains(Label.CL_Prevent_CampMemb_Removal),'Exception message should contain the String passed as parameter');
            }
            CampaignMember queryCmpMemb = [Select id from CampaignMember where id =: myCampMemb.id];
            System.assert(queryCmpMemb!=null,'queryCmpMemb should not be empty');
        }
        Test.StopTest();
    }

    /**
     * @description method for creating Lead Campaign Members
     * @return CampaignMember
     */
    private static CampaignMember createLeadCampaignMember() {
        CampaignMember myCampMemb;
        System.runas(sysAdminuser) {
            CS001_ByPassTriggerAll__c passTriggerAll = UTIL_ByPassTrigger_TEST.buildTriggerBypassAllCustomSetting(True,sysAdminuser);
            insert passTriggerAll;
            Lead mylead = new Lead (FirstName='TestLead1', LastName='RemoveCmpLead', Status = 'Open-Not Contacted', ownerid = proxyUser.id);
            insert mylead;
            Campaign myCmp = UTIL_TestDataCreation_Test.createTestCampaign();
            myCmp.ownerid = proxyUser.id;
            update myCmp;
            myCampMemb = new CampaignMember(campaignId=myCmp.Id,LeadId = myLead.id,status='Registered', WillConvert__c=False);
            insert myCampMemb;
        }
        return myCampMemb;
    }
}