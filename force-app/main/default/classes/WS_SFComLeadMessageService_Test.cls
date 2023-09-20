/****************************************************************************************
@Author: Team Dream Builders
@name: SFComLeadMessageService_Test
@CreatedDate: 2/2/2017 
@Description: This class tests the functionality of service WS_SFComLeadMessageService
@Version <1.0>
@reference: WS_SFComLeadMessageService
******************************************************************************************/
/**
 * 
 * @description WS_SFComLeadMessageService_Test
 */
@isTest(SeeAllData = false)
public class WS_SFComLeadMessageService_Test {
    public static Map<String,Id> profileNameIdMap;  
    private static User proxyUser;
    private static User processId;
    private static PermissionSetAssignment psassignment;
    private static String lead_Message_Service_Perm_Set = 'SF_CRM_SFCOMLeadMsgSrvcs_PermSetPID';
    private static String chatter_Group_Name = 'NewHotProspectNotifications-';
    private static String process_ID_Username = 'lvmsSFComProcId@sfa.com';
    private static Integer countOfOpportunities = [Select count() From Opportunity];
    private static Integer countOfAccounts = [SELECT count() FROM Account];
    private static Integer countOfAgentRoles = [SELECT count() FROM AgentRole__c];
    private static Integer countOfChatterPosts = [SELECT count() FROM FeedItem];
 	private static String unitTest_Custom_Setting_URL  = 'ICP_TP_ENV';
    private static String unitTest_Setup_URL = 'unittest.statefarm.com';
    private static WS_SFComLeadMessageService_Wrapper leadMsgWrap = new WS_SFComLeadMessageService_Wrapper();
    @TestSetup
    private static void setup(){
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        CS001_ByPassTriggerAll__c bypassTriggerAll = new CS001_ByPassTriggerAll__c();
        bypassTriggerAll.Override_All__c = true;
        insert bypassTriggerAll;
        Profile sysProfile = [Select Id from Profile where name = :UTIL_Constants.SYSTEM_ADMIN_PROFILE_NAME LIMIT 1];
        leadMsgWrap.systemUser = buildtestUser('sepProcSysAd@statefarm.com', sysProfile);
        Profile apiProfile = [Select Id FROM Profile WHERE Name =:UTIL_StageOrchestrationConstants.STAGE_ORCHESTRATION_PROFILE_NAME];
        leadMsgWrap.testAPIUser = buildtestUser('testAPI@statefarm.com', apiProfile);
        Profile agentProfile = [Select Id FROM Profile WHERE Name =:UTIL_Constants.AGENT_PROFILE_NAME];
        leadMsgWrap.agentUser = buildAgentUser('testAgent@statefarm.com', agentProfile);
        Profile proxyProfile = [Select Id from Profile where name = :UTIL_Constants.PROXY_PROFILE_NAME LIMIT 1];      
        
        CS_EnvironmentURLCustomSetting__c envCS = new CS_EnvironmentURLCustomSetting__c();
        envCS.name = 'ICP_TP_ENV';
        envCS.value__c = unitTest_Setup_URL;
        insert envCS;
        
        insert leadMsgWrap.systemUser;
        insert leadMsgWrap.testAPIUser;
        insert leadMsgWrap.agentUser;
        User agentTemp = [select id,Proxy_External_ID__c from user where id=:leadMsgWrap.agentUser.id limit 1];
        proxyUser = buildProxyUser('testProxy@statefarm.com', proxyProfile, agentTemp);
        insert proxyUser;
        
       System.runAs(leadMsgWrap.systemUser) {
        	assignPermissionSet(leadMsgWrap.systemUser, lead_Message_Service_Perm_Set);
       }
    }
//method to fetch users
    private static void fetchUsers(){
        List<User> usrlist=[SELECT Id, Username,lastname,Alias, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, UserType__c FROM User where  lastname in('sepProcSysAd@statefarm.com','testAPI@statefarm.com','testAgent@statefarm.com','testProxy@statefarm.com')  ];
        for(User usrobj:usrlist){
            if(usrobj.lastname=='testAgent@statefarm.com')
            {
                leadMsgWrap.agentUser=usrobj;
            }
            else if(usrobj.lastname=='testProxy@statefarm.com'){
                proxyUser=usrobj;
            }
            else if(usrobj.lastname=='testAPI@statefarm.com'){
                proxyUser=usrobj;
            }
            else {
                leadMsgWrap.systemUser=usrobj; 
            }
    
        }
    }
    
    /**
     * This method is used for to build a test API user with a specific Profile
     * @description buildtestUser <This method is used to create test users>
     * @param t_lastName
     * @param testProfile
     * @return User
     */ 
    public static User buildtestUser(String t_lastName, Profile testProfile) {
        User testUser= new User(alias = 'test', email= 'testuser@statefarm.com', profileid = testProfile.id,
                                emailencodingkey='UTF-8', lastname=t_lastName, languagelocalekey='en_US', 
                                localesidkey='en_US', timezonesidkey='Europe/London', username= t_lastName+'@statefarm.com');
        return testUser;
    }
    /**
     * @description buildAgentUser
     * @param t_lastName 
     * @param testProfile 
     * @return  `User`
     */
    public static User buildAgentUser(String t_lastName, Profile testProfile) {
        User testUser= new User(alias = 'test', email= 'testuser@statefarm.com', profileid = testProfile.id,
                                emailencodingkey='UTF-8', lastname=t_lastName, languagelocalekey='en_US', 
                                localesidkey='en_US', timezonesidkey='Europe/London', username= t_lastName+'@statefarm.com', Associate_ID__c='GTKKMMM1234', 
                UserExternalID__c= 'GTKKMMM1234_GTKKMMM1234',
                Servicing_Agent_Associate_ID__c = 'GTKKMMM1234',
                Territory_Associate_ID__c= 'GTKKMMM',
                Servicing_Agent_Associate_ID_List__c='GTKKMMM1234',
                Territory_Associate_ID_List__c='GTKKMMM');
        return testUser;
    }
    
    /**
     * @description buildProxyUser
     * @param t_lastName 
     * @param testProfile 
     * @param usr 
     * @return  `User`
     */
    public static User buildProxyUser(String t_lastName, Profile testProfile, User usr) {
        User testUser= new User(alias = 'test', email= 'testuserp@statefarm.com', profileid = testProfile.id,
                                emailencodingkey='UTF-8', lastname=t_lastName, languagelocalekey='en_US', 
                                localesidkey='en_US', timezonesidkey='Europe/London', username= t_lastName+'@statefarm.com', Associate_ID__c='GTKKMMM1234', 
                UserExternalID__c= usr.Proxy_External_ID__c,
                Servicing_Agent_Associate_ID__c = 'GTKKMMM1234',
                Territory_Associate_ID__c= 'GTKKMMM'
                );
        return testUser;
    }
    
    //method to assign permissionset for the given user in parameter value
    private static void assignPermissionSet(User testUser, String permissionSetName) {
        PermissionSet queryPermissionSet = [Select id FROM PermissionSet WHERE Name =: permissionSetName Limit 1];
        PermissionSetAssignment assignPermissionSet = new PermissionSetAssignment();
        assignPermissionSet.AssigneeId = testUser.id;
        assignPermissionSet.PermissionSetId = queryPermissionSet.id;
        insert assignPermissionSet;
    }
    
    //setting up SFComLeadMessage for the tests
    private static HLPR_SFComLeadRequest setSFComMessage(User user) {   
        HLPR_LeadAccount la = createAccount();
              
        HLPR_LeadAgentRole lar = new HLPR_LeadAgentRole();
        lar.AgentAssociateID = user.Associate_ID__c;        
        
        HLPR_LeadOpportunity lo = new HLPR_LeadOpportunity();
        lo.Name = 'ggtfgqvzsshqvqw';
        lo.Email = 'lvmsEmail@NOEMAIL.com';
        lo.LeadId = 'Auto';
        lo.LeadTransactionId = '';
        lo.LeadType = 'Auto';
        lo.LOB = 'Auto';
        lo.Opportunity_Originator = 'Statefarm.com';
        lo.OpportunityDetail = 'lvmsOppDetailzzz';
        lo.StageName = 'New';
        lo.Temperature = 'Hot';
        lo.Description = 'Internet Referral Complete Auto Quote Internet Referral Complete Auto Quote Internet';
        
        HLPR_SFComLeadRequest sfcl = new HLPR_SFComLeadRequest();
        sfcl.leadaccount = la;
        sfcl.leadagentrole = lar;
        sfcl.leadopportunity = lo;
        sfcl.status='';
        
        return sfcl;
    } 
    
    //setting up SFComLeadMessage for the update tests
    private static HLPR_SFComLeadRequest setSFComMessageForUpdate(User user) {   
        HLPR_LeadAccount la = createAccount();
              
        HLPR_LeadAgentRole lar = new HLPR_LeadAgentRole();
        lar.AgentAssociateID = user.Associate_ID__c;        
        
        HLPR_LeadOpportunity lo = new HLPR_LeadOpportunity();
        lo.Name = 'ggtfgqvzsshqvqw';
        lo.Email = 'lvmsEmail@NOEMAIL.com';
        lo.LeadId = 'Auto';
        lo.LeadTransactionId = '';
        lo.LeadType = 'Auto';
        lo.LOB = 'Auto';
        lo.Opportunity_Originator = 'Statefarm.com';
        lo.OpportunityDetail = 'UpdatedDetails';
        lo.StageName = 'New';
        lo.Temperature = 'Urgent';
        lo.Description = 'Updated Description';
        
        HLPR_SFComLeadRequest sfc2 = new HLPR_SFComLeadRequest();
        sfc2.leadaccount = la;
        sfc2.leadagentrole = lar;
        sfc2.leadopportunity = lo;
        sfc2.status='';
        
        return sfc2;
    } 
    
    //setting up SFComLeadMessage for the tests
    private static HLPR_LeadAccount createAccount() {
        HLPR_LeadAccount acct = new HLPR_LeadAccount();
              
        String clientId = 'BBBTTTCC00Z';
        String accountType = 'Individual';
        String phone = '(320) 555-0162';
        String emailAddress = 'wmgckkvn@NOEMAIL.com';
        String firstName = 'BBBTT';
        String lastName = 'TTTC';
        String address = 'zgzvqd';
        String address2 = 'gpjvspgpfpvssbsskf';
        String city = 'cvbnmmm';
        String country = 'US';
        String state = 'GA';
        String zip = '11111';
        
        acct.ClientId = clientId;
        acct.AccountType = accountType;
        acct.Phone = phone;
        acct.EmailAddress = emailAddress;
        acct.FirstName = firstName;
        acct.LastName =  lastName;
        acct.Address = address;
        acct.Address2 = address2;
        acct.City = city;
        acct.Country = country;
        acct.State = state;
        acct.Zip = zip;
        
        acct.WorkPhoneExtension='555';
        acct.PersonMobilePhone='(977) 555-0149';
        acct.PersonHomePhone='(969) 555-0197';
        acct.TDDPhone='(462) 555-0105';
        acct.HasPermissiontoText='Yes';
        acct.HasPermissionToServiceText='Yes';
        acct.HasPermissionToClaimText='No';
        acct.IsHearingImpaired=false;
        acct.PersonDoNotCall=false;
        
        return acct;
    }
    
    //Description: Passing valid user and trying to Upsert Account,Agent Role and Insert Opportunity to test success scenario
    @isTest
    private static void verifyNewSFComOpportuity() {
        fetchUsers();
        HLPR_SFComLeadRequest sfcl = setSFComMessage(leadMsgWrap.agentUser);
         User proxy ;
        System.runAs(leadMsgWrap.systemUser) {           
            proxy = UTIL_AgentProxySelection.retrieveProxyForLoggedInAgentOrATM(leadMsgWrap.agentUser.Id);          
            Test.startTest();
            WS_SFComLeadMessageService.upsertSFComLead(sfcl);
            Test.stopTest();
        }
        List<Account> accountList=[SELECT PersonMobilePhone,HasPermissionToServiceText__c FROM Account Limit 1];
        System.assertEquals(countOfAccounts+1, accountList.size(),'Expected Size of AccountList should be equal to actual size of AccountList');
        System.assertEquals(countOfAgentRoles+1, [SELECT count() FROM AgentRole__c],'Expected no.of.records of AgentRoles should be equal to the actual no.of.records of AgentRoles');
        System.assertEquals(countOfOpportunities+1, [SELECT count() FROM Opportunity],'Expected no.of.records of Opportunities should be equal to the actual no.of.records of Opportunities'); 
        List<Opportunity> opportunityList=[SELECT OwnerId FROM Opportunity Limit 1];
        System.assertEquals('9775550149',accountList[0].PersonMobilePhone,'Expected value is 9775550149, but actual value is '+accountList[0].PersonMobilePhone);
        System.assertEquals('Yes',accountList[0].HasPermissionToServiceText__c,'Expected value is Yes, but actual value is '+accountList[0].HasPermissionToServiceText__c);
        System.assertEquals(proxy.id,opportunityList[0].OwnerId,'Expected value is '+proxy.id+', but actual value is '+opportunityList[0].OwnerId);
        List<Opportunity_Note__c> opportunityNoteList=[SELECT Name, Comments__c, Category__c FROM Opportunity_Note__c Limit 1];
        System.assertEquals('Internet Referral Complete Auto Quote Internet Referral Complete Auto Quote Internet\nlvmsOppDetailzzz', opportunityNoteList[0].Comments__c,'Expected value is Internet Referral Complete Auto Quote Internet Referral Complete Auto Quote Internet\nlvmsOppDetailzzz, but actual value is '+opportunityNoteList[0].Comments__c);
        System.assertEquals('System Generated', opportunityNoteList[0].Category__c,'Expected value is System Generated, but actual value is '+opportunityNoteList[0].Category__c);
        System.assertEquals('Internet Referral Complete Auto Quote Internet Referral Complete Auto Quote Inte', opportunityNoteList[0].Name,'Expected value is Internet Referral Complete Auto Quote Internet Referral Complete Auto Quote Inte, but actual value is '+opportunityNoteList[0].Name);
        
    }
    
    //Description: Passing valid user and trying to update Opportunity to test success scenario
    @isTest
    private static void verifyUpdateSFComOpportunity() {
        fetchUsers();
        HLPR_SFComLeadRequest sfcl = setSFComMessageForUpdate(leadMsgWrap.agentUser);
        Account acct = createAccount(sfcl);
        insert acct;
        
        Opportunity oppt = createOpportunity(sfcl, acct);
        insert oppt;

        System.assertEquals(countOfAccounts+1, [SELECT count() FROM Account],'Expected no.of.records of Account should be equal to the actual no.of.records of Account');
		System.assertEquals(countOfOpportunities+1, [SELECT count() FROM Opportunity],'Expected no.of.records of Opportunities should be equal to the actual no.of.records of Opportunities');
        
        System.runAs(leadMsgWrap.systemUser) {            
            Test.startTest();
            WS_SFComLeadMessageService.upsertSFComLead(sfcl);
            Test.stopTest();
        }
        Opportunity opp = [SELECT Temperature__c FROM Opportunity WHERE Name=:sfcl.leadopportunity.Name];

        System.assertEquals(countOfAccounts+1, [SELECT count() FROM Account],'Expected no.of.records of Account should be equal to the actual no.of.records of Account');
        System.assertEquals(countOfAgentRoles, [SELECT count() FROM AgentRole__c],'Expected no.of.records of AgentRoles should be equal to the actual no.of.records of AgentRoles');
        System.assertEquals(countOfOpportunities+1, [SELECT count() FROM Opportunity],'Expected no.of.records of Opportunities should be equal to the actual no.of.records of Opportunities');
        System.assertEquals('Urgent', opp.Temperature__c,'Expected value is Urgent, but actual value is '+opp.Temperature__c);
        List<Opportunity_Note__c> opportunityNoteList=[SELECT Name, Comments__c, Category__c FROM Opportunity_Note__c Limit 1];
        System.assertEquals('Updated Description\nUpdatedDetails', opportunityNoteList[0].Comments__c,'Expected value is Updated Description\nUpdatedDetails, but actual value is '+opportunityNoteList[0].Comments__c);
        System.assertEquals('System Generated', opportunityNoteList[0].Category__c,'Expected value is System Generated, but actual value is '+opportunityNoteList[0].Category__c);
        System.assertEquals('Updated Description', opportunityNoteList[0].Name,'Expected value is Updated Description, but actual value is '+opportunityNoteList[0].Name);

    }
    
    //Description: Passing valid user and trying to update Opportunity to test success scenario
    @isTest
    private static void verifyInvalidAccount() {
        fetchUsers();
        HLPR_SFComLeadRequest sfcl = setSFComMessage(leadMsgWrap.agentUser);
        sfcl.leadaccount.ClientId = '';
        
        System.runAs(leadMsgWrap.systemUser) {
           Test.startTest();
            try{                   
            WS_SFComLeadMessageService.upsertSFComLead(sfcl);
                System.assert(false, 'Failed test, an exception should have been thrown.');
            } catch (Exception ex) {
                System.assertEquals(countOfAccounts, [SELECT count() FROM Account],'Expected no.of.records of Account should be equal to the actual no.of.records of Account');
                System.assertEquals(countOfAgentRoles, [SELECT count() FROM AgentRole__c],'Expected no.of.records of AgentRoles should be equal to the actual no.of.records of AgentRoles');
                System.assertEquals(countOfOpportunities, [SELECT count() FROM Opportunity],'Expected no.of.records of Opportunities should be equal to the actual no.of.records of Opportunities');
            }
            Test.stopTest();
        }
       
        Integer actualCountOfAccounts = [SELECT count() FROM Account];
        System.assertEquals(countOfAccounts, actualCountOfAccounts,'Expected value is '+countOfAccounts+', actual value is '+actualCountOfAccounts);
    }
    
     //Description: Not passing name and trying to Upsert Account,Agent Role and Insert Opportunity to test fail scenario
     @isTest
    private static void verifyFailedOpportunity() {
        fetchUsers();
          
      	HLPR_SFComLeadRequest sfcl = setSFComMessage(leadMsgWrap.agentUser);
        sfcl.leadopportunity.Name = null;
        System.runAs(leadMsgWrap.systemUser) {
            
            Test.starttest();
            try{    
                WS_SFComLeadMessageService.upsertSFComLead(sfcl);
                System.assert(false, 'Failed test, an exception should have been thrown.');
            } catch(Exception ex) {         
                 System.assertEquals(countOfAccounts, [SELECT count() FROM Account],'Expected no.of.records of Account should be equal to the actual no.of.records of Account');
                 System.assertEquals(countOfAgentRoles, [SELECT count() FROM AgentRole__c],'Expected no.of.records of AgentRoles should be equal to the actual no.of.records of AgentRoles');
                 System.assertEquals(countOfOpportunities, [SELECT count() FROM Opportunity],'Expected no.of.records of Opportunities should be equal to the actual no.of.records of Opportunities'); 
            }
            Test.stoptest();          
        }
    }
   
     //Description: Not passing account last name and client ID and trying to Upsert Account,Agent Role and Insert Opportunity to test fail scenario
     @isTest
    private static void verifyFailedAccount() {
        fetchUsers();

        HLPR_SFComLeadRequest sfcl = setSFComMessage(leadMsgWrap.agentUser);
        sfcl.leadaccount.LastName = null;
        sfcl.leadaccount.ClientID = null;
        System.runAs(leadMsgWrap.systemUser) {
            
            Test.starttest();
            try{    
                WS_SFComLeadMessageService.upsertSFComLead(sfcl);
                System.assert(false, 'Failed test, an exception should have been thrown.');
            } catch(Exception ex) {         
                 System.assertEquals(countOfAccounts, [SELECT count() FROM Account],'Expected no.of.records of Account should be equal to the actual no.of.records of Account');
                 System.assertEquals(countOfAgentRoles, [SELECT count() FROM AgentRole__c],'Expected no.of.records of AgentRoles should be equal to the actual no.of.records of AgentRoles');
                 System.assertEquals(countOfOpportunities, [SELECT count() FROM Opportunity],'Expected no.of.records of Opportunities should be equal to the actual no.of.records of Opportunities'); 
            }
            Test.stoptest();          
        }    
       
    }
    //Description: Not passing AgentAssociateID trying to call upsertSFCom lead service, the service will fail since with out AgentAssociateID can not do any operation
    @isTest
    private static void verifyFailedAgentRole() {
        fetchUsers();

        HLPR_SFComLeadRequest sfcl = setSFComMessage(leadMsgWrap.agentUser);
        sfcl.leadagentrole.AgentAssociateID = null;
       
        System.runAs(leadMsgWrap.systemUser) {
            
            Test.starttest();
            try{    
                WS_SFComLeadMessageService.upsertSFComLead(sfcl);
                System.assert(false, 'Failed test, an exception should have been thrown.');
            } catch(Exception ex) {         
                 System.assertEquals(countOfAccounts, [SELECT count() FROM Account],'Expected no.of.records of Account should be equal to the actual no.of.records of Account');
                 System.assertEquals(countOfAgentRoles, [SELECT count() FROM AgentRole__c],'Expected no.of.records of AgentRoles should be equal to the actual no.of.records of AgentRoles');
                 System.assertEquals(countOfOpportunities, [SELECT count() FROM Opportunity],'Expected no.of.records of Opportunities should be equal to the actual no.of.records of Opportunities'); 
            }
            Test.stoptest();          
        }    
       
    }
    
    private static Account createAccount(HLPR_SFComLeadRequest sfcl) {
        
        Account acct = new Account();
        acct.ClientIdentifier__c = sfcl.leadaccount.ClientId;
        acct.FirstName = sfcl.leadaccount.FirstName;
        acct.LastName = sfcl.leadaccount.LastName;
        
        return acct;
    }
    
    private static Opportunity createOpportunity(HLPR_SFComLeadRequest sfcl, Account acct) {
        
        Opportunity oppt = new Opportunity();
        oppt.AccountId = acct != null ? acct.Id : '';
        oppt.LOB__c = sfcl.leadopportunity.LOB;
        oppt.Name = sfcl.leadopportunity.Name;
        oppt.Opportunity_Originator__c = sfcl.leadopportunity.Opportunity_Originator;
        oppt.OwnerId = proxyUser.Id;
        oppt.StageName = sfcl.leadopportunity.StageName;
        oppt.CloseDate = Date.today() +1;
        
        return oppt;
    }

    private class WS_SFComLeadMessageService_Wrapper{
        private User systemUser;
        private User testAPIUser;
        private User agentUser;
    }
    
}