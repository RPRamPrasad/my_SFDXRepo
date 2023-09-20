@isTest
public class WS_OpportunityApiRestEndpoint_Test { 
    
    private static String agentProfileId = getProfileId(UTIL_Constants.AGENT_PROFILE_NAME);
    private static String agentTeamMemberProfileId = getProfileId(UTIL_Constants.ATM_PROFILE_NAME);
    private static String proxyProfileId = getProfileId(UTIL_Constants.PROXY_PROFILE_NAME);
    private static String adminProfileId = getProfileId(UTIL_Constants.SYSTEM_ADMIN_PROFILE_NAME);
    private static String noAccessProfileId = getProfileId('1.02 No Access');
    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap = Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();
    private static User adminUser;
    private static User agentUser;
    private static User proxyUser;
      private static String adminPermSet = 'Opportunity_FullAccess_W';
    
    @testSetup
    private static void setupUserData() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        CS_EnvironmentURLCustomSetting__c envCS = new CS_EnvironmentURLCustomSetting__c();
        envCS.name = 'ICP_TP_ENV';
        envCS.value__c = 'unittest.statefarm.com';
        insert envCS;
    }
    
    //method to assign permissionset for the given user in parameter value
    private static void assignPermissionSet(User testUser, String permissionSetName) {
        PermissionSet queryPermissionSet = [Select id FROM PermissionSet WHERE Name =: permissionSetName Limit 1];
        PermissionSetAssignment assignPermissionSet = new PermissionSetAssignment();
        assignPermissionSet.AssigneeId = testUser.id;
        assignPermissionSet.PermissionSetId = queryPermissionSet.id;
        insert assignPermissionSet;
    }
    
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
    
    //method to build Account Owner custom setting record with the given parameter value
    private static AccountOwnerSystemUserCustomSetting__c buildCustomSettingRecord(String userId) {
        AccountOwnerSystemUserCustomSetting__c actOwnerCs = new AccountOwnerSystemUserCustomSetting__c(Name = UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER, SFDC_USER_ID__c = userId);
        return actOwnerCs;
    }
    
    //Helper method to set up Agent Office Data
    /**
     * @description testDataSetup
     */
    public static void testDataSetup() {
        
        adminUser = buildUser('TstAdmFtch111in111us111er@sfa111.com', adminProfileId, '', '', '');
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings(adminUser);
        
        assignPermissionSet(adminUser, adminPermSet);
        
        UserRole agentUserRole = buildRole('AgentRole');
        insert agentUserRole;
        
        UserRole proxyUserRole = buildRoleWithParentRole('ProxyRole', agentUserRole.id);
        insert proxyUserRole;
        
        agentUser = buildUser('TestFtchQtAgtUser111ForQtTst111@sfa111.com', agentProfileId , 'rrccww11zzc', 'rrccww11zzc', 'rrccww11zzc_rrccww11zzc');
        agentUser.userRoleId = agentUserRole.id;
        insert agentUser;
        
        proxyUser = buildUser('TestFtchQtAgt111Proxy111UserForOptyTest111@sfa111.com', proxyProfileId, '', 'rrccww11zzc', 'rrccww11zzcP');
        proxyUser.userRoleId = proxyUserRole.id;
        insert proxyUser;
        
    } 
    
    private static AgentRole__c buildAgentRoleRecord(String param_accountId) {
        AgentRole__c agentRole = new AgentRole__c (RelationshipNature__c = 'Customer',
                                                   Agent__c = userInfo.getUserId(), Customer__c = param_accountId);
        return agentRole;
    }
    
    
    //method to build Simple Conversation record with the given parameter value
    private static SimpleConversation__c buildSimpleConversationRecord(String param_accountId, String param_conductedBy, String param_AgentId, String param_OwnerId) {
        SimpleConversation__c simpleConvRecord = new SimpleConversation__c (Account__c = param_accountId,
                                                                            SimpleConversationType__c = 'Simple Conversation', Status__c = 'New', ConductedBy__c = param_conductedBy, SimpleConversationName__c = 'Test Simple Conv',
                                                                            Agent__c = param_AgentId, ownerId = param_OwnerId);
        return simpleConvRecord;
    }
    
    private static Account buildAccountRecord(String param_clientIdentifier) {
        Account act = new Account(FirstName = 'rrrrr', LastName = 'tttttttt',
                                  RecordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId, ClientIdentifier__c = param_clientIdentifier,Edit_In_VFP__c = true,IsMatchRequired__c=False);
        return act;
    }
    
    //setting up account data for the tests
    private static HLPR_LeadAccount createAccount(String passedClientIden) {
        HLPR_LeadAccount acct = new HLPR_LeadAccount();
        
        String clientId = passedClientIden;
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
    //setting up opportunity data for the tests
    private static HLPR_LeadOpportunity createLeadOpportunity(String oppName, String oppOg,String recordType,String marketingSource,String simpleId, Integer appCode) {
        HLPR_LeadOpportunity testOpp = new HLPR_LeadOpportunity();
        
        testOpp.Name = oppName;
        testOpp.Email = 'lvmsEmail@NOEMAIL.com';
        testOpp.LeadId = 'Auto';
        testOpp.LeadTransactionId = '';
        testOpp.LeadType = 'Auto';
        testOpp.Product='Commercial';
        testOpp.EventCode='code';
        testOpp.LOB = 'Auto';
        testOpp.Opportunity_Originator = oppOg;
        testOpp.MarketingSource =marketingSource;
        testOpp.MarketingSubSource = 'Micro site';
        testOpp.OpportunityDetail = 'lvmsOppDetailzzz';
        testOpp.StageName = 'New';
        testOpp.Description = 'test data Opportunity'; 
        testOpp.status='Appointment Set'; 
        testOpp.SubStatus = 'Do not follow up';
        testOpp.RecordType=recordType;
        if(!String.isEmpty(simpleId)) {
            testOpp.SimpleId= simpleId;
        }
        testOpp.EntryWebProperty = 'www.EntryWebProperty.com';
        testOpp.ReferringDomain = 'www.ReferringDomain.com';
        testOpp.CampaignID = 'ABC1234';
        testOpp.AgentProperty = '75-00338';
        testOpp.marketingChannel = 'Microsite';
        testOpp.appCode= appCode;
        testOpp.productSystemName='';
        testOpp.stateCode='MN / 12-1234';
        testOpp.effectiveDate=Date.today();
        testOpp.doNotDedup = false;
        testOpp.temperature = 'Hot';
        return testOpp;
    }
    
    //creating SimpleConversation object for test
    private static SimpleConversation__c createSimpleConversation() {
        SimpleConversation__c simpleConvo = new SimpleConversation__c();
        //      insert simpleConvo;
        return simpleConvo;
    }
    
    //setting up SFComLeadMessage for the tests
    private static HLPR_CreateOppRequest createOppRequest(String assocId, Boolean sendNotiifcation, String accClientidentifier, String oppName, String oppOg,String recordType,String marketingSource,String simpleId,Integer appCode) {   
        HLPR_LeadAccount la = createAccount(accClientidentifier);
        HLPR_LeadOpportunity lo;
        HLPR_AgentOfficeData lar = new HLPR_AgentOfficeData();
        lar.agentAssociateID = assocId;       
        lar.sendNotification=sendNotiifcation;		       
        lo= createLeadOpportunity(oppName, oppOg,recordType,marketingSource,simpleId,appCode);
        
        HLPR_CreateOppRequest sfcl = new HLPR_CreateOppRequest();
        sfcl.accountData = la;
        sfcl.agentOfficeData = lar;
        sfcl.opportunityData = lo;
        sfcl.status='';
        
        return sfcl;
    }
    
    /**
* @method Creation of Statefarm.com opportunity through Service 
* @description   createSFComOpp
*/
    @isTest
    private static void createSFComOpp() {        
        //User/Agent Office data setUp
        testDataSetup();
        User systemUser = buildUser('TestFtchQtAgt111Act111OwnerForOptyTest111@sfa111.com', noAccessProfileId, '', '', '');
        Account act;
        List<SimpleConversation__c> simpleConvRecords = new List<SimpleConversation__c>();
        insert systemUser; 
        String assocId = 'rrccww11zzc';
        String oppName = 'Demoopp1';
        String oppOriginator = 'Statefarm.com';
        String recordType='Opportunity Management'; //intentionally passing wrong value to verify it gets set as Opportunity Management anyway
        String clientIdentifier = 'BBBTTTCC00Z';
        String marketingSource = 'oppMktSrc';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response= res;   
        
        System.runAs(agentUser) {
            CollaborationGroup chatterGroup = new CollaborationGroup();
            chatterGroup.Name = 'NewHotProspectNotifications-'+agentUser.Alias;
            chatterGroup.CollaborationType = 'Private';
            insert chatterGroup;
        }
        
        System.runAs(adminUser){
            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
            
            act = buildAccountRecord(clientIdentifier);
            insert act;
            
            AgentRole__c agentRole = buildAgentRoleRecord(act.id);
            agentRole.Agent__c = agentUser.id;
            insert agentRole;
            
            
            
            simpleConvRecords.add(buildSimpleConversationRecord(act.id, agentUser.id, agentUser.id, proxyUser.id));
            
            insert simpleConvRecords;
            
            HLPR_CreateOppRequest oppRequest = createOppRequest(assocId, true, clientIdentifier, oppName, oppOriginator,recordType,marketingSource,simpleConvRecords[0].id,1);
            String jsonMsg=JSON.serialize(oppRequest);            
            // Setting up REST parameters for PoSt Operation
            req.requestURI = '/services/apexrest/createopportunity';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(jsonMsg);               
            Test.startTest();  
            Test.setCurrentPageReference(new PageReference('Page.VFP_individualCustomercreateEdit'));
            //Calling the actual webservice class
            WS_OpportunityApiRestEndpoint.createOpportunity(oppRequest);
            Test.stopTest();
        }
        // Asserts
        System.runAs(agentUser) {
            List<Opportunity> oppList = [Select id,isOfficeNotified__c,product_system_name__c,state_code__c,Requested_Effective_Date__c, Name, RecordType.Name, owner.Proxy_External_ID__c, account.ClientIdentifier__c,Product__C,EventCode__C, Status__c, Sub_Status__C,Entry_Web_Property__c,Referring_Domain__c,Campaign_ID__c,Agent_Property__c, Marketing_Channel__c, Marketing_Sub_Source__c,AppCode__c  from Opportunity where Opportunity.Account.ClientIdentifier__c =: clientIdentifier];
            String oppId = oppList[0].id;
            List<Opportunity_Note__C> oppNoteList =[Select id ,Name,Comments__c from Opportunity_Note__C where Opportunity__r.id=:oppId] ;
            System.assert(res.responseBody.toString().contains(oppList[0].id),'Opportunity was not created through service');
            System.assertEquals(clientIdentifier,oppList[0].account.ClientIdentifier__c,'Opportunity was not created under the right Account');
            System.assertEquals(assocId +'P',oppList[0].owner.Proxy_External_ID__c,'Opportunity was not created under the correct Agent Office');
            System.assertEquals('Opportunity Management',oppList[0].RecordType.Name,'Opportunity was not assigned with SFCom recordtype');
            System.assertEquals('Commercial',oppList[0].Product__C,'Product is vailable in opportunity');
            System.assertEquals('code',oppList[0].EventCode__C,'EventCode is available in opportunity');
            System.assertEquals('test data Opportunity',oppNoteList[0].name,'Product is vailable in opportunity');
            System.assertEquals('test data Opportunity'+'\n' +'lvmsOppDetailzzz',oppNoteList[0].Comments__C,'Product is vailable in opportunity');
            System.assertEquals('Appointment Set', oppList[0].Status__c,'Expected value is Appointment Set, but actual value is '+oppList[0].Status__c);
            System.assertEquals('Do not follow up',oppList[0].Sub_Status__c,'Expected value is Do not follow up, but actual value is '+oppList[0].Sub_Status__c);
            System.assertEquals('www.EntryWebProperty.com',oppList[0].Entry_Web_Property__c,'Expected value is www.EntryWebProperty.com, but actual value is '+oppList[0].Entry_Web_Property__c);
            System.assertEquals('www.ReferringDomain.com',oppList[0].Referring_Domain__c,'Expected value is www.ReferringDomain.com, but actual value is '+oppList[0].Referring_Domain__c);
            System.assertEquals('ABC1234',oppList[0].Campaign_ID__c,'Expected value is ABC1234, but actual value is '+oppList[0].Campaign_ID__c);
            System.assertEquals('75-00338',oppList[0].Agent_Property__c,'Expected value is 75-00338, but actual value is '+oppList[0].Agent_Property__c); 
            System.assertEquals(1,oppList[0].AppCode__c,'Expected value is 1, but actual value is '+oppList[0].AppCode__c); 
            System.assertEquals(null,oppList[0].product_system_name__c,'Expected value is null, but actual value is '+oppList[0].product_system_name__c); 
            System.assertEquals('MN / 12-1234',oppList[0].state_code__c,'Expected value to be MN / 12-1234, actual value to be '+oppList[0].state_code__c); 
			Date date1 = Date.today();
            System.assertEquals(Date.newInstance(date1.year(), date1.month(), date1.day()),oppList[0].Requested_Effective_Date__c,'Expected date is not equal to the actual date'); 
            System.assertEquals(false,oppList[0].isOfficeNotified__c,'Expected value is false, but actual value is '+oppList[0].isOfficeNotified__c);            
            //System.assertEquals('Microsite', oppList[0].Marketing_Channel__c);
            //System.assertEquals('Micro site', oppList[0].Marketing_Sub_Source__c);
        }
    }
    
    /**
* @method Updating of Statefarm.com opportunity through Service 
* @description   updateSFComOpp
*/
    @isTest
    private static void updateSFComOpp() {        
        //User/Agent Office data setUp
        testDataSetup();
        User systemUser = buildUser('TestFtchQtAgt111Act111OwnerForOptyTest111@sfa111.com', noAccessProfileId, '', '', '');
        insert systemUser; 
        String assocId = 'rrccww11zzc';
        String oppName = 'Demoopp1';
        String oppOriginator = 'Agent/Team Member';
        String recordType='Opportunity Management';
        String clientIdentifier = 'BBBTTTCC00Z';
        String marketingSource='oppMktSrc';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response= res;   
        
        System.runAs(adminUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            
            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
            HLPR_CreateOppRequest oppRequest = createOppRequest(assocId, true, clientIdentifier, oppName, oppOriginator,recordType,marketingSource,'',1);
            oppRequest.opportunityData.OpportunityDetail = 'Note contents';
            String jsonMsg=JSON.serialize(oppRequest);            
            // Setting up REST parameters for PoSt Operation
            req.requestURI = '/services/apexrest/createopportunity';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(jsonMsg);               
            
            //Calling the actual webservice class
            Test.startTest();
            WS_OpportunityApiRestEndpoint.createOpportunity(oppRequest);
            HLPR_CreateOppRequest oppRequest1 = createOppRequest(assocId, true, clientIdentifier, 'DemoOpp2', oppOriginator,recordType,marketingSource,'',1);
            oppRequest1.opportunityData.OpportunityDetail = 'Note contents';
            WS_OpportunityApiRestEndpoint.createOpportunity(oppRequest1);
            Test.stopTest();           
            
        }
        System.runAs(agentUser) {
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            List<Opportunity> oppList = [Select id, Name, owner.Proxy_External_ID__c, account.ClientIdentifier__c from Opportunity where Opportunity.Account.ClientIdentifier__c =: clientIdentifier AND Opportunity_Originator__c = 'Agent/Team Member'];
            List<Opportunity_Note__C> oppNoteList =[Select id ,Name,Comments__c from Opportunity_Note__C where Opportunity__r.id=:oppList[0].id];
            System.assert(res.responseBody.toString().contains(oppList[0].id),'Opportunity was not created through service');
            System.assertEquals(clientIdentifier,oppList[0].account.ClientIdentifier__c,'Opportunity was not created under the right Account');
            System.assertEquals(assocId +'P',oppList[0].owner.Proxy_External_ID__c,'Opportunity was not created under the correct Agent Office');
            System.assert(oppNoteList[1].Comments__c.contains('Note contents'),'Given String does not contain \'Note contents\'');
        }
    }
    
    //test method to verify exception when user/agent is not found in salesforce
    @isTest
    private static void testAgentNotFoundException() {        
        testDataSetup();
        User systemUser = buildUser('TestFtchQtAgt111Act111OwnerForOptyTest111@sfa111.com', noAccessProfileId, '', '', '');
        insert systemUser; 
        String assocId = 'nllgntslfrc';
        String oppName = 'Demoopp1';
        String oppOriginator = 'Statefarm.com';
        String recordType='Opportunity Management';
        String clientIdentifier = 'BBBTTTCC00Z';
        String marketingSource='oppMktSrc';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response= res;   
        
        System.runAs(adminUser){
            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
            HLPR_CreateOppRequest oppRequest = createOppRequest(assocId, true, clientIdentifier, oppName, oppOriginator,recordType,marketingSource,'',1);
            String jsonMsg=JSON.serialize(oppRequest);       
            req.requestURI = '/services/apexrest/createopportunity';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(jsonMsg);               
            Test.startTest();   
            try{    
                WS_OpportunityApiRestEndpoint.createOpportunity(oppRequest);
                System.assert(false, 'Failed test, an exception should have been thrown.');
            } catch(Exception ex) {         
                System.assertEquals(0, [SELECT count() FROM Account],'Expected no.of.records of Account should be equal to the actual no.of.records of Account');
                System.assertEquals(0, [SELECT count() FROM Opportunity],'Expected no.of.records of Opportunities should be equal to the actual no.of.records of Opportunities'); 
                System.assertEquals(ex.getMessage(), Label.CL_AgentAssociateID_Invalid_Message,'Expected value is '+ex.getMessage()+', actual value is '+Label.CL_AgentAssociateID_Invalid_Message);
            }
            Test.stopTest();
        }
    }
    
    //test method to verify if exception is generated with blank clientID
    @isTest
    private static void testBadClientIDException() {        
        testDataSetup();
        User systemUser = buildUser('TestFtchQtAgt111Act111OwnerForOptyTest111@sfa111.com', noAccessProfileId, '', '', '');
        insert systemUser;  
        String assocId = 'rrccww11zzc';
        String oppName = 'Demoopp1';
        String oppOriginator = 'Statefarm.com';
        String recordType='Opportunity Management';
        String clientIdentifier = '';
        String marketingSource='oppMktSrc';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response= res;   
        
        System.runAs(adminUser){
            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
            HLPR_CreateOppRequest oppRequest = createOppRequest(assocId, true, clientIdentifier, oppName, oppOriginator,recordType,marketingSource,'',1);
            String jsonMsg=JSON.serialize(oppRequest);       
            req.requestURI = '/services/apexrest/createopportunity';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(jsonMsg);               
            Test.startTest();   
            try{    
                WS_OpportunityApiRestEndpoint.createOpportunity(oppRequest);
                System.assert(false, 'Failed test, an exception should have been thrown.');
            } catch(Exception ex) {         
                System.assertEquals(0, [SELECT count() FROM Account],'Expected no.of.records of Account should be equal to the actual no.of.records of Account');
                System.assertEquals(0, [SELECT count() FROM Opportunity],'Expected no.of.records of Opportunities should be equal to the actual no.of.records of Opportunities'); 
                System.assertEquals(ex.getMessage(), Label.CL_Invalid_Client_Identifier,'Expected value is '+ex.getMessage()+', actual value is '+Label.CL_Invalid_Client_Identifier);
            }
            Test.stopTest();
        }
    }
    
    //test method to verify if exception is generated with clientID length more than 11 characters
    @isTest
    private static void testInvalidAccountException() {        
        testDataSetup();
        User systemUser = buildUser('TestFtchQtAgt111Act111OwnerForOptyTest111@sfa111.com', noAccessProfileId, '', '', '');
        insert systemUser;  
        String assocId = 'rrccww11zzc';
        String oppName = 'Demoopp1';
        String oppOriginator = 'Statefarm.com';
        String recordType='Opportunity Management';
        String clientIdentifier = 'BBBTTTCC00Z11';
        String marketingSource='oppMktSrc';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response= res;   
        
        System.runAs(adminUser){
            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
            HLPR_CreateOppRequest oppRequest = createOppRequest(assocId, true, clientIdentifier, oppName, oppOriginator,recordType,marketingSource,'',1);
            String jsonMsg=JSON.serialize(oppRequest);       
            req.requestURI = '/services/apexrest/createopportunity';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(jsonMsg);               
            Test.startTest();   
            try{    
                WS_OpportunityApiRestEndpoint.createOpportunity(oppRequest);
                System.assert(false, 'Failed test, an exception should have been thrown.');
            } catch(Exception ex) {         
                System.assertEquals(0, [SELECT count() FROM Account],'Expected no.of.records of Account should be equal to the actual no.of.records of Account');
                System.assertEquals(0, [SELECT count() FROM Opportunity],'Expected no.of.records of Opportunities should be equal to the actual no.of.records of Opportunities'); 
            }
            Test.stopTest();
        }
    }
    
    //test method to verify if exception is generated with invalid opportunity data
    @isTest
    private static void testInvalidOpportunityException() {        
        testDataSetup();
        User systemUser = buildUser('TestFtchQtAgt111Act111OwnerForOptyTest111@sfa111.com', noAccessProfileId, '', '', '');
        insert systemUser;  
        String assocId = 'rrccww11zzc';
        String oppName = '';
        String recordType='Opportunity Management';
        String oppOriginator = 'Statefarm.com';
        String clientIdentifier = 'BBBTTTCC00Z';
        String marketingSource='oppMktSrc';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response= res;   
        
        System.runAs(adminUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
            HLPR_CreateOppRequest oppRequest = createOppRequest(assocId, true, clientIdentifier, oppName, oppOriginator,recordType,marketingSource,'',1);
            String jsonMsg=JSON.serialize(oppRequest);       
            req.requestURI = '/services/apexrest/createopportunity';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(jsonMsg);               
            Test.startTest();   
            try{    
                WS_OpportunityApiRestEndpoint.createOpportunity(oppRequest);
                System.assert(false, 'Failed test, an exception should have been thrown.');
            } catch(Exception ex) {         
                System.assertEquals(0, [SELECT count() FROM Account],'Expected no.of.records of Account should be equal to the actual no.of.records of Account');
                System.assertEquals(0, [SELECT count() FROM Opportunity],'Expected no.of.records of Opportunities should be equal to the actual no.of.records of Opportunities'); 
                System.assertEquals(ex.getMessage(), Label.CL_Name_Reqd,'Expected value is '+ex.getMessage()+', actual value is '+Label.CL_Name_Reqd);
            }
            Test.stopTest();
        }
    }
    
    //test method to verify if exception is generated if proxy for an agent does not exist
    @isTest
    private static void testProxyNotFoundException() {  
        adminUser = buildUser('TstAdmFtch111in111us111er@sfa111.com', adminProfileId, '', '', '');
        
        UserRole agentUserRole = buildRole('AgentRole');
        insert agentUserRole;
        
        agentUser = buildUser('TestFtchQtAgtUser111ForQtTst111@sfa111.com', agentProfileId , 'rrccww11zzc', 'rrccww11zzc', 'rrccww11zzc_rrccww11zzc');
        agentUser.userRoleId = agentUserRole.id;
        insert agentUser;
        
        User systemUser = buildUser('TestFtchQtAgt111Act111OwnerForOptyTest111@sfa111.com', noAccessProfileId, '', '', '');
        insert systemUser; 
        
        String assocId = 'rrccww11zzc';
        String oppName = 'DemoOpp123';
        String oppOriginator = 'Statefarm.com';
        String recordType='Opportunity Management';
        String clientIdentifier = 'BBBTTTCC00Z';
        String marketingSource='oppMktSrc';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response= res;   
        adminUser = buildUser('TstAdmFtch111in111us111er@sfa111.com', adminProfileId, '', '', '');
        System.runAs(adminUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
            HLPR_CreateOppRequest oppRequest = createOppRequest(assocId, true, clientIdentifier, oppName, oppOriginator,recordType,marketingSource,'',1);
            String jsonMsg=JSON.serialize(oppRequest);       
            req.requestURI = '/services/apexrest/createopportunity';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(jsonMsg);               
            Test.startTest();   
            try{    
                WS_OpportunityApiRestEndpoint.createOpportunity(oppRequest);
                System.assert(false, 'Failed test, an exception should have been thrown.');
            } catch(Exception ex) {         
                System.assertEquals(0, [SELECT count() FROM Account],'Expected no.of.records of Account should be equal to the actual no.of.records of Account');
                System.assertEquals(0, [SELECT count() FROM Opportunity],'Expected no.of.records of Opportunities should be equal to the actual no.of.records of Opportunities'); 
                System.assert(ex.getMessage().contains(Label.CL_PROXY_NOT_FOUND_ERROR),'Message does not contain the value of the constant String variable Label.CL_PROXY_NOT_FOUND_ERROR');
            }
            Test.stopTest();
        }        
    }
    
    //test method to verify if exception is generated with invalid account record type from service
    @isTest
    private static void testExceptionForBadAccountRecordType() { 
        testDataSetup();
        User systemUser = buildUser('TestFtchQtAgt111Act111OwnerForOptyTest111@sfa111.com', noAccessProfileId, '', '', '');
        insert systemUser; 
        String assocId = 'rrccww11zzc';
        String oppName = 'Demoopp1';
        String oppOriginator = 'Statefarm.com';
        String recordType='Opportunity Management';
        String clientIdentifier = 'BBBTTTCC00Z';
        String marketingSource='oppMktSrc';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response= res;   
        
        System.runAs(adminUser){
            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
            
            HLPR_CreateOppRequest oppRequest = createOppRequest(assocId, true, clientIdentifier, oppName, oppOriginator,recordType,marketingSource,'',1);
            HLPR_LeadAccount la = createAccount(clientIdentifier);
            la.accountType = '';
            oppRequest.accountData = la;
            String jsonMsg=JSON.serialize(oppRequest);       
            req.requestURI = '/services/apexrest/createopportunity';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(jsonMsg);               
            Test.startTest();   
            
            try{    
                WS_OpportunityApiRestEndpoint.createOpportunity(oppRequest);
                System.assert(false, 'Failed test, an exception should have been thrown.');
            } catch(Exception ex) {
                System.assertEquals(0, [SELECT count() FROM Account],'Expected no.of.records of Account should be equal to the actual no.of.records of Account');
                System.assertEquals(0, [SELECT count() FROM Opportunity],'Expected no.of.records of Opportunities should be equal to the actual no.of.records of Opportunities'); 
                System.assertEquals(ex.getMessage(),Label.CL_AccountType_Invalid_Message,'Expected value is '+ex.getMessage()+', actual value is '+Label.CL_AccountType_Invalid_Message);
            }
            Test.stopTest();
        }
    }
    
    //test method to verify if exception is generated with blank account last name
    @isTest
    private static void testExceptionForBlankAccountLastName() {     
        testDataSetup();
        User systemUser = buildUser('TestFtchQtAgt111Act111OwnerForOptyTest111@sfa111.com', noAccessProfileId, '', '', '');
        insert systemUser; 
        String assocId = 'rrccww11zzc';
        String oppName = 'Demoopp1';
        String recordType='Opportunity Management';
        String oppOriginator = 'Statefarm.com';
        String clientIdentifier = 'BBBTTTCC00Z';
        String marketingSource='oppMktSrc';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response= res;   
        
        System.runAs(adminUser){
            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
            
            HLPR_CreateOppRequest oppRequest = createOppRequest(assocId, true, clientIdentifier, oppName, oppOriginator,recordType,marketingSource,'',1);
            HLPR_LeadAccount la = createAccount(clientIdentifier);
            la.lastName = '';
            oppRequest.accountData = la;
            String jsonMsg=JSON.serialize(oppRequest);       
            req.requestURI = '/services/apexrest/createopportunity';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(jsonMsg);               
            Test.startTest();   
            
            try{    
                WS_OpportunityApiRestEndpoint.createOpportunity(oppRequest);
                System.assert(false, 'Failed test, an exception should have been thrown.');
            } catch(Exception ex) {
                System.assertEquals(0, [SELECT count() FROM Account],'Expected no.of.records of Account should be equal to the actual no.of.records of Account');
                System.assertEquals(0, [SELECT count() FROM Opportunity],'Expected no.of.records of Opportunities should be equal to the actual no.of.records of Opportunities'); 
                System.assertEquals(ex.getMessage(),Label.CL_LastName_Reqd,'Expected value is '+ex.getMessage()+', actual value is '+Label.CL_LastName_Reqd);
            }
            Test.stopTest();
        }
    }
    
    //test method to verify if exception is generated with blank associateID
    @isTest
    private static void testExceptionBlankAssociateID() {  
        testDataSetup();
        User systemUser = buildUser('TestFtchQtAgt111Act111OwnerForOptyTest111@sfa111.com', noAccessProfileId, '', '', '');
        insert systemUser; 
        String assocId = '';
        String oppName = 'Demoopp1';
        String recordType='Opportunity Management';
        String oppOriginator = 'Statefarm.com';
        String clientIdentifier = 'BBBTTTCC00Z';
        String marketingSource='oppMktSrc';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response= res;   
        
        System.runAs(adminUser){
            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
            
            HLPR_CreateOppRequest oppRequest = createOppRequest(assocId, true, clientIdentifier, oppName, oppOriginator,recordType,marketingSource,'',1);
            String jsonMsg=JSON.serialize(oppRequest);       
            req.requestURI = '/services/apexrest/createopportunity';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(jsonMsg);               
            Test.startTest();   
            
            try{    
                WS_OpportunityApiRestEndpoint.createOpportunity(oppRequest);
                System.assert(false, 'Failed test, an exception should have been thrown.');
            } catch(Exception ex) {
                System.assertEquals(0, [SELECT count() FROM Account],'Expected no.of.records of Account should be equal to the actual no.of.records of Account');
                System.assertEquals(0, [SELECT count() FROM Opportunity],'Expected no.of.records of Opportunities should be equal to the actual no.of.records of Opportunities'); 
                System.assertEquals(ex.getMessage(),Label.CL_AgentAssociateID_Invalid_Message,'Expected value is '+ex.getMessage()+', actual value is '+Label.CL_AgentAssociateID_Invalid_Message);
            }
            Test.stopTest();
        }
    }

    //test method to verify plmod create opp flow
        @isTest
        private static void testCreateSFComOpp_PLMOD() {        
            //User/Agent Office data setUp
            testDataSetup();
            User systemUser = buildUser('TestFtchQtAgt111Act111OwnerForOptyTest111@sfa111.com', noAccessProfileId, '', '', '');
            Account act;
            List<SimpleConversation__c> simpleConvRecords = new List<SimpleConversation__c>();
            insert systemUser; 
            String assocId = 'rrccww11zzc';
            String oppName = 'Demoopp1';
            String oppOriginator = 'Statefarm.com';
            String recordType='Opportunity Management'; //intentionally passing wrong value to verify it gets set as Opportunity Management anyway
            String clientIdentifier = 'BBBTTTCC00Z';
            String marketingSource = 'oppMktSrc';
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            RestContext.request = req;
            RestContext.response= res;   
            
            System.runAs(agentUser) {
                CollaborationGroup chatterGroup = new CollaborationGroup();
                chatterGroup.Name = 'NewHotProspectNotifications-'+agentUser.Alias;
                chatterGroup.CollaborationType = 'Private';
                insert chatterGroup;
            }
            
            System.runAs(adminUser){
                AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
                insert accountOwner;
                
                act = buildAccountRecord(clientIdentifier);
                insert act;
                
                AgentRole__c agentRole = buildAgentRoleRecord(act.id);
                agentRole.Agent__c = agentUser.id;
                insert agentRole;
                
                
                
                simpleConvRecords.add(buildSimpleConversationRecord(act.id, agentUser.id, agentUser.id, proxyUser.id));
                
                insert simpleConvRecords;
                
                HLPR_CreateOppRequest oppRequest = createOppRequest(assocId, true, clientIdentifier, oppName, oppOriginator,recordType,marketingSource,simpleConvRecords[0].id,15);
                String jsonMsg=JSON.serialize(oppRequest);            
                // Setting up REST parameters for PoSt Operation
                req.requestURI = '/services/apexrest/createopportunity';
                req.httpMethod = 'POST';
                req.requestBody = Blob.valueof(jsonMsg);               
                Test.startTest();  
                Test.setCurrentPageReference(new PageReference('Page.VFP_individualCustomercreateEdit'));
                //Calling the actual webservice class
                WS_OpportunityApiRestEndpoint.createOpportunity(oppRequest);
                Test.stopTest();
            }
            // Asserts
            System.runAs(adminUser) {
                List<Opportunity> oppList = [Select id,isOfficeNotified__c,product_system_name__c,state_code__c,Requested_Effective_Date__c, Name, RecordType.Name, owner.Proxy_External_ID__c, account.ClientIdentifier__c,Product__C,EventCode__C, Status__c, Sub_Status__C,Entry_Web_Property__c,Referring_Domain__c,Campaign_ID__c,Agent_Property__c, Marketing_Channel__c, Marketing_Sub_Source__c,AppCode__c  from Opportunity where Opportunity.Account.ClientIdentifier__c =: clientIdentifier];
                String oppId = oppList[0].id;
                List<Opportunity_Note__C> oppNoteList =[Select id ,Name,Comments__c from Opportunity_Note__C where Opportunity__r.id=:oppId] ;
                System.assert(res.responseBody.toString().contains(oppList[0].id),'Opportunity was not created through service');
                System.assertEquals(clientIdentifier,oppList[0].account.ClientIdentifier__c,'Opportunity was not created under the right Account');
                System.assertEquals(assocId +'P',oppList[0].owner.Proxy_External_ID__c,'Opportunity was not created under the correct Agent Office');
                System.assertEquals('Opportunity Management',oppList[0].RecordType.Name,'Opportunity was not assigned with SFCom recordtype');
                System.assertEquals('Commercial',oppList[0].Product__C,'Product is vailable in opportunity');
                System.assertEquals('code',oppList[0].EventCode__C,'EventCode is available in opportunity');
                System.assertEquals('test data Opportunity',oppNoteList[0].name,'Product is vailable in opportunity');
                System.assertEquals('test data Opportunity'+'\n' +'lvmsOppDetailzzz',oppNoteList[0].Comments__C,'Product is vailable in opportunity');
                System.assertEquals('Appointment Set', oppList[0].Status__c,'Expected value is Appointment Set, but actual value is '+oppList[0].Status__c);
                System.assertEquals('Do not follow up',oppList[0].Sub_Status__c,'Expected value is Do not follow up, but actual value is '+oppList[0].Sub_Status__c);
                System.assertEquals('www.EntryWebProperty.com',oppList[0].Entry_Web_Property__c,'Expected value is www.EntryWebProperty.com, but actual value is '+oppList[0].Entry_Web_Property__c);
                System.assertEquals('www.ReferringDomain.com',oppList[0].Referring_Domain__c,'Expected value is www.ReferringDomain.com, but actual value is '+oppList[0].Referring_Domain__c);
                System.assertEquals('ABC1234',oppList[0].Campaign_ID__c,'Expected value is ABC1234, but actual value is '+oppList[0].Campaign_ID__c);
                System.assertEquals('75-00338',oppList[0].Agent_Property__c,'Expected value is 75-00338, but actual value is '+oppList[0].Agent_Property__c); 
                System.assertEquals(15,oppList[0].AppCode__c,'Expected value is 15, but actual value is '+oppList[0].AppCode__c); 
                System.assertEquals(null,oppList[0].product_system_name__c,'Expected value is null, but actual value is '+oppList[0].product_system_name__c); 
                System.assertEquals('MN / 12-1234',oppList[0].state_code__c,'Expected value to be MN / 12-1234, actual value to be '+oppList[0].state_code__c); 
                Date date1 = Date.today();
                System.assertEquals(Date.newInstance(date1.year(), date1.month(), date1.day()),oppList[0].Requested_Effective_Date__c,'Expected date is not equal to the actual date'); 
                System.assertEquals(true,oppList[0].isOfficeNotified__c,'Expected value is true, but actual value is '+oppList[0].isOfficeNotified__c);            
                //System.assertEquals('Microsite', oppList[0].Marketing_Channel__c);
                //System.assertEquals('Micro site', oppList[0].Marketing_Sub_Source__c);
            }
        }

	//test method to verify plmod update flow
	@isTest
    private static void updateSFComOpp_PLMOD() {        
        //User/Agent Office data setUp
        testDataSetup();
        User systemUser = buildUser('TestFtchQtAgt111Act111OwnerForOptyTest111@sfa111.com', noAccessProfileId, '', '', '');
        insert systemUser; 
        String assocId = 'rrccww11zzc';
        String oppName = 'Demoopp1';
        String oppOriginator = 'Agent/Team Member';
        String recordType='Opportunity Management';
        String clientIdentifier = 'BBBTTTCC00Z';
        String marketingSource='oppMktSrc';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response= res;   
        
        System.runAs(adminUser){
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            
            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(systemUser.id);
            insert accountOwner;
            HLPR_CreateOppRequest oppRequest = createOppRequest(assocId, false, clientIdentifier, oppName, oppOriginator,recordType,marketingSource,'',15);
            oppRequest.opportunityData.OpportunityDetail = 'Note contents';
            String jsonMsg=JSON.serialize(oppRequest);            
            // Setting up REST parameters for PoSt Operation
            req.requestURI = '/services/apexrest/createopportunity';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueof(jsonMsg);               
            
            //Calling the actual webservice class
            Test.startTest();
            WS_OpportunityApiRestEndpoint.createOpportunity(oppRequest);
            HLPR_CreateOppRequest oppRequest1 = createOppRequest(assocId, true, clientIdentifier, 'DemoOpp2', oppOriginator,recordType,marketingSource,'',15);
            oppRequest1.opportunityData.OpportunityDetail = 'Note contents';
            WS_OpportunityApiRestEndpoint.createOpportunity(oppRequest1);
            
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            List<Opportunity> oppList = [Select id,isOfficeNotified__c, Name, owner.Proxy_External_ID__c, account.ClientIdentifier__c from Opportunity where Opportunity.Account.ClientIdentifier__c =: clientIdentifier AND Opportunity_Originator__c = 'Agent/Team Member'];
            List<Opportunity_Note__C> oppNoteList =[Select id ,Name,Comments__c from Opportunity_Note__C where Opportunity__r.id=:oppList[0].id];
            System.assert(res.responseBody.toString().contains(oppList[0].id),'Opportunity was not created through service');
            System.assertEquals(clientIdentifier,oppList[0].account.ClientIdentifier__c,'Opportunity was not created under the right Account');
            System.assertEquals(assocId +'P',oppList[0].owner.Proxy_External_ID__c,'Opportunity was not created under the correct Agent Office');
            System.assert(oppNoteList[1].Comments__c.contains('Note contents'),'Given String does not contain \'Note contents\'');
            System.assertEquals(true,oppList[0].isOfficeNotified__c,'Expected value is true, but actual value is '+oppList[0].isOfficeNotified__c);
            
            //checking that agents office should not be notified again, in case a notification is already sent and the opp is not assigned to anyone yet
        	//as we notified in update request above. 
        	HLPR_CreateOppRequest oppRequest2 = createOppRequest(assocId, true, clientIdentifier, 'DemoOpp3', oppOriginator,recordType,marketingSource,'',15);
            oppRequest2.opportunityData.OpportunityDetail = 'Note contents';
            WS_OpportunityApiRestEndpoint.createOpportunity(oppRequest2);
            
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
            List<Opportunity> oppList2 = [Select id,isOfficeNotified__c, Name,Temperature__c, owner.Proxy_External_ID__c, account.ClientIdentifier__c from Opportunity where Opportunity.Account.ClientIdentifier__c =: clientIdentifier AND Opportunity_Originator__c = 'Agent/Team Member'];
            List<Opportunity_Note__C> oppNoteList2 =[Select id ,Name,Comments__c from Opportunity_Note__C where Opportunity__r.id=:oppList[0].id];
            System.assert(res.responseBody.toString().contains(oppList[0].id),'Opportunity was not created through service');
            System.assertEquals(clientIdentifier,oppList2[0].account.ClientIdentifier__c,'Opportunity was not created under the right Account');
            System.assertEquals(assocId +'P',oppList2[0].owner.Proxy_External_ID__c,'Opportunity was not created under the correct Agent Office');
            System.assert(oppNoteList2[1].Comments__c.contains('Note contents'),'Given String does not contain \'Note contents\'');
            System.assertEquals(true,oppList2[0].isOfficeNotified__c,'Expected value is true, but actual value is '+oppList2[0].isOfficeNotified__c); //there should be no change
            System.assertEquals('Hot',oppList2[0].Temperature__c,'Expected value is hot, but actual value is '+oppList2[0].Temperature__c);
            
            Test.stopTest();              
        }
    }  
    
}