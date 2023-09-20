@isTest(seeAllData=false)
public class WS_UpdateOpportunity_Test {
    
    private static final String NULL_SYMBOL='';
    private static String agentProfileId = getProfileId(UTIL_Constants.AGENT_PROFILE_NAME);
    private static String agentTeamMemberProfileId = getProfileId(UTIL_Constants.ATM_PROFILE_NAME);
    private static String proxyProfileId = getProfileId(UTIL_Constants.PROXY_PROFILE_NAME);
    private static String adminProfileId = getProfileId(UTIL_Constants.SYSTEM_ADMIN_PROFILE_NAME);
    private static String noAccessProfileId = getProfileId('1.02 No Access');
    private static String unittest_Custom_Setting_Url = 'ICP_TP_ENV';
    private static String unittest_Setup_Url = 'unittest.statefarm.com';
    private static String adminPermSet = 'Opportunity_FullAccess_W';
    
    private static User adminUser;
    private static User agentUser;
    private static User proxyUser;
    
    @testSetup
    private static void setupUserData() {
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        CS_EnvironmentURLCustomSetting__c envCS = new CS_EnvironmentURLCustomSetting__c();
        envCS.name = 'ICP_TP_ENV';
        envCS.value__c = unittest_Setup_Url;
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
    
    private static AccountOwnerSystemUserCustomSetting__c buildCustomSettingRecord(String userId) {
        AccountOwnerSystemUserCustomSetting__c actOwnerCs = new AccountOwnerSystemUserCustomSetting__c(Name = UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER, SFDC_USER_ID__c = userId);
        return actOwnerCs;
    }
    
    //method to build userrole with the given parameter value
    private static UserRole buildRole(String roleName) {
        UserRole role = new UserRole(name = roleName);
        return role;
    }
    
    //method to build user with the given parameter value
    private static User buildUser(String param_UserName, String param_profileId, String param_associateId, String param_servicingAgentAssociateId, String param_externalId) {
        User testUser = new User (alias = '12345', email = 'testUser@statefarm.com.bad', emailencodingkey='UTF-8', firstname='TestUserFirstname', lastname='TestUserLastName',
                                  languagelocalekey='en_US',localesidkey='en_US', timezonesidkey='America/Chicago',
                                  username= param_UserName, profileId = param_profileId,
                                  Associate_ID__c = param_associateId, Servicing_Agent_Associate_ID__c = param_servicingAgentAssociateId,
                                  UserExternalID__c = param_externalId
                                 );
        return testUser;
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
    
    private static Account createAccount(String passedClientIden) {
        Account acct = new Account();  
        acct.ClientIdentifier__c=passedClientIden; 
        acct.Type = 'Individual';
        acct.Phone = '(320) 555-0162';
        acct.PersonEmail = 'wmgckkvn@NOEMAIL.com';
        acct.FirstName = 'firstName';
        acct.LastName =  'lastName';       
        acct.PersonMailingCity='city';
        acct.PersonMailingCountry='US';
        acct.PersonMailingState='GA';      
        acct.PersonMobilePhone='(977) 555-0149';    
        return acct;       
    }
    
    private static AgentRole__c createAgentRole(String agentAssocId,String clientId,id accountId) {
        createAccount(clientId);
        AgentRole__c agentRole = new AgentRole__c();
        agentRole.Agent__c=agentUser.id;
        agentRole.AgentRoleIdentifier__c = agentAssocId + UTIL_Constants.TILT_SYMBOL + clientId;       
        agentRole.Customer__c=accountId;    
        return agentRole;       
    }
    
    private static Opportunity createOpportunity(id accountId,Integer appCode){
        
        Opportunity opp = new Opportunity();
        opp.RecordTypeId=getRecordTypeId('Opportunity Management');
        opp.Name='Opp Name';
        opp.Opportunity_Originator__c='Something';
        opp.StageName='New';
        opp.CloseDate=Date.today() + 60; 
        opp.LOB__c='A'; 
        opp.AccountId=accountId;
        opp.OwnerId = agentUser.id;
        opp.AppCode__c = appCode;
        opp.Phone__c='(320) 555-0163';
        
        return opp;
    }
    
    private static id getRecordTypeId(String recordType){
        
        Map<String, String> recordTypeMapById = new Map<String, String>();
        for(Schema.RecordTypeInfo rtInfo : Schema.Opportunity.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getRecordTypeInfos()) {
            recordTypeMapById.put(rtInfo.getName(),String.valueOf(rtInfo.getRecordTypeId()).subString(0, 15));             
        }             
        id recordtypeId = recordTypeMapById.get(recordType);        
        return recordtypeId;
    }
    
    //setting up opportunity data for the tests
    private static HLPR_UpdateOpportunityData updateOpportunityRequestBuilder(String oppId,String assignedTo) {
        
        HLPR_UpdateOpportunityData updateOpp = new HLPR_UpdateOpportunityData();
        updateopp.salesforceOpportunityId=oppId;
        updateOpp.stageName = 'New';
        updateOpp.Temperature = 'Hot';
        updateopp.totalPremium='2000';
        updateopp.monthlyPremium='1000';
        updateopp.opportunityDetail='oppDetail';       
        updateOpp.opportunityDescription = 'test data Opportunity';
        updateOpp.status='Appointment Set';
        updateOpp.subStatus='Duplicate opportunity';
        updateOpp.assignedTo= assignedTo;
        
        return updateOpp;
    }
    
    //setting up SFComLeadMessage for the tests
    private static HLPR_UpdateOppRequest updateOppRequest(String assocId, id oppId,boolean sendNotification,String assignedTo) {   
        
        HLPR_AgentOfficeData agentData = new HLPR_AgentOfficeData();
        agentData.agentAssociateID = assocId;  
        agentData.sendNotification=sendNotification;
        HLPR_UpdateOpportunityData  updateOppdata= updateOpportunityRequestBuilder(oppId,assignedTo);
        HLPR_UpdateOppRequest updateOpp = new HLPR_UpdateOppRequest();        
        updateOpp.agentOfficeData = agentData;
        updateOpp.updateOpportunityData = updateOppdata;
        return updateOpp;
    }
    
    private static void assertions(HLPR_UpdateOppRequest oppRequest){
        
        List<Opportunity> resultOpp = [Select id,officeassigned__C,StageName,Status__c,Sub_Status__c,Temperature__c,Amount,Monthly_Premium__c,Description,OpportunityDetail__c,Assigned_To__c from Opportunity where id=:oppRequest.updateOpportunityData.salesforceOpportunityId LIMIT 1];
        List<Opportunity_Note__c> resultOppNote = [Select Name,Comments__c,Category__c from Opportunity_Note__c where Opportunity__c=:oppRequest.updateOpportunityData.salesforceOpportunityId LIMIT 1];
        List<User> usr = [select id ,name from user where userexternalid__C=:proxyUser.UserExternalID__c] ;
        
        System.assert(resultOpp[0].id!=null, 'Found Opportunity to update');
        System.assertEquals(resultOpp[0].officeassigned__C, usr[0].name, 'Updated Office assigned');
        System.assertEquals(resultOpp[0].stageName, oppRequest.updateOpportunityData.stageName, 'Updated stagename');
        System.assertEquals(resultOpp[0].Temperature__c, oppRequest.updateOpportunityData.temperature, 'Updated temperature');
        System.assertEquals(resultOpp[0].Amount, decimal.valueof(oppRequest.updateOpportunityData.totalPremium), 'Updated totalPremium');
        System.assertEquals(resultOpp[0].Monthly_Premium__c, decimal.valueof(oppRequest.updateOpportunityData.monthlyPremium), 'Updated monthlyPremium');
        System.assertEquals(resultOppNote[0].name, oppRequest.updateOpportunityData.opportunityDescription,'Updated Description');
        System.assertEquals(resultOpp[0].Sub_Status__c,oppRequest.updateOpportunityData.subStatus,'Expected value is '+resultOpp[0].Sub_Status__c+', but actual value is '+oppRequest.updateOpportunityData.subStatus);
        System.assertEquals(resultOpp[0].Status__c,oppRequest.updateOpportunityData.status,'Expected value is '+resultOpp[0].Status__c+', but actual value is '+oppRequest.updateOpportunityData.status);
        System.assertEquals(resultOppNote[0].Comments__c, oppRequest.updateOpportunityData.opportunityDescription+'\n'+oppRequest.updateOpportunityData.opportunityDetail, 'Updated Detail');
        System.assertEquals(resultOpp[0].Assigned_To__c,agentUser.Id,'Expected value is '+resultOpp[0].Assigned_To__c+', but actual value is '+agentUser.Id);
    }
    
    private static Opportunity opportunitySetup(User adminUser,Integer appCode){
        String assocId ='rrccww11zzc';
        String clientId='clientID123';
        
        AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(adminUser.id);
        insert accountOwner;		
        Account acct = createAccount(clientId);
        insert acct;
        AgentRole__c agentRole = createAgentRole(assocId, clientId,acct.id);
        insert agentRole;
        Opportunity opp = createOpportunity(acct.id,appCode);
        insert opp;
        return opp;
    }
    
    private static void opportunityTest(HLPR_UpdateOppRequest oppRequest,RestRequest request,RestResponse response){
        
        String jsonMsg=JSON.serialize(oppRequest);            
        // Setting up REST parameters for PoSt Operation
        request.requestURI = '/services/apexrest/updateopportunity';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(jsonMsg);               
        Test.startTest();
        //Calling the actual webservice class            
        WS_UpdateOpportunity.updateOpportunity(oppRequest);           
        System.assert(response.responseBody.toString().contains(oppRequest.updateOpportunityData.salesforceOpportunityId),'Opportunity was not created through service');          
        assertions(oppRequest); 
        Test.stopTest();
    }
    
    @isTest
    private static void updateOppWithDescriptionGreaterThanEighty() {        
        //User/Agent Office data setUp
        testDataSetup();
        RestRequest request = new RestRequest(); 
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response= response;   
        
        System.runAs(adminUser){
            //setting Data for opp
            Opportunity opp = opportunitySetup(adminUser,1);
            HLPR_UpdateOppRequest oppRequest = updateOppRequest('rrccww11zzc',opp.id,true,'rrccww11zzc');
            oppRequest.updateOpportunityData.opportunityDescription = 'Internet Referral Complete Auto Quote Internet Referral Complete Auto Quote Inte';        
            opportunityTest(oppRequest,request,response);
            System.assert(response.responseBody.toString().contains(oppRequest.updateOpportunityData.salesforceOpportunityId),'Opportunity was not created through service');
        }
        
    }
    
    @isTest
    private static void opportunityNotFoundException() {        
        //User/Agent Office data setUp
        testDataSetup();
        RestRequest request = new RestRequest(); 
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response= response;   
        Boolean isException = false;
        System.runAs(adminUser){
            AccountOwnerSystemUserCustomSetting__c accountOwner = buildCustomSettingRecord(adminUser.id);
            insert accountOwner;		
            HLPR_UpdateOppRequest oppRequest = new HLPR_UpdateOppRequest();
            HLPR_UpdateOpportunityData updateOpportunityData = new  HLPR_UpdateOpportunityData();
            updateOpportunityData.salesforceOpportunityId='0062F000004j2tb';
            oppRequest.updateOpportunityData=updateOpportunityData;
            String jsonMsg=JSON.serialize(oppRequest);            
            // Setting up REST parameters for PoSt Operation
            request.requestURI = '/services/apexrest/updateopportunity';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueof(jsonMsg);               
            Test.startTest();      
            //Calling the actual webservice class           
            try{                
                WS_UpdateOpportunity.updateOpportunity(oppRequest);               
                List<Opportunity> existingOpp = [Select id from Opportunity where id=:oppRequest.updateOpportunityData.salesforceOpportunityId LIMIT 1];            
                System.assert(existingOpp.size() == 0, 'Found opportunity to update');
            }catch(Exception e){   
                isException = true;
                System.assertEquals(0, [SELECT count() FROM Opportunity],'Expected no.of.records of Opportunities should be equal to the actual no.of.records of Opportunities');                 
            }
            System.assert(isException == false, 'Unexpected exception occured');
            Test.stopTest();
        }     
    }
    
    @isTest
    private static void userRetrievalTest() {
        testDataSetup();       
        String assocId ='rrccww11zzc';
        
        RestRequest request = new RestRequest(); 
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response= response;   
        
        System.runAs(adminUser){
            Opportunity opp=opportunitySetup(adminUser,1);
            HLPR_UpdateOppRequest oppRequest = updateOppRequest(assocId,opp.id,false,'rrccww11zzc');
            String jsonMsg=JSON.serialize(oppRequest);            
            // Setting up REST parameters for PoSt Operation
            request.requestURI = '/services/apexrest/updateopportunity';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueof(jsonMsg);               
            Test.startTest();      
            //Calling the actual webservice class            
            WS_UpdateOpportunity.updateOpportunity(oppRequest);                     
            List<Opportunity> existingOpp = [Select id from Opportunity where id=:oppRequest.updateOpportunityData.salesforceOpportunityId LIMIT 1];
            List<User> usr= [SELECT id,Name,Alias FROM user WHERE Associate_ID__c <>: NULL_SYMBOL and Associate_ID__c =:assocId 
                             and UserExternalId__C=:(assocId+'_'+assocId)
                             and IsActive=true limit 1];
            //id oppId = 
            System.assert(existingOpp[0].id!=null, 'Found Opportunity to update');
            System.assert(usr[0].id!=null, 'No user to upsert AgentRole');
            //existingOpp.id
            Test.stopTest();
        }    
    }
    
    @isTest
    private static void userNotFoundExceptionTest() {       
        testDataSetup();       
        String assocId ='rrccww11zzc';
        
        RestRequest request = new RestRequest(); 
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response= response;   
        
        System.runAs(adminUser){
            Opportunity opp=opportunitySetup(adminUser,1);
            HLPR_UpdateOppRequest oppRequest = updateOppRequest(assocId,opp.id,false,'rrccww11zzc');
            String jsonMsg=JSON.serialize(oppRequest);            
            // Setting up REST parameters for PoSt Operation
            request.requestURI = '/services/apexrest/updateopportunity';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueof(jsonMsg);               
            Test.startTest();      
            //Calling the actual webservice class 
            try{            
                WS_UpdateOpportunity.updateOpportunity(oppRequest);             
            }catch(Exception e){                        
                List<Opportunity> existingOpp = [Select id from Opportunity where id=:oppRequest.updateOpportunityData.salesforceOpportunityId LIMIT 1];	       
                System.assert(existingOpp[0].id!=null, 'Found Opportunity to update');            
                System.assertEquals(e.getMessage(), System.Label.CL_AgentAssociateID_Invalid_Message+' : '+oppRequest.agentOfficeData.agentAssociateID,'Expected value is '+e.getMessage()+', but actual value is '+System.Label.CL_AgentAssociateID_Invalid_Message+' : '+oppRequest.agentOfficeData.agentAssociateID);
            }
            Test.stopTest();
        }    
    } 
    
    /**
* @description testExceptionScenario
*/
    @isTest
    public static void testExceptionScenario() {
        HLPR_updateOppRequest oppRequest = new HLPR_updateOppRequest();
        oppRequest.updateOpportunityData = new  HLPR_UpdateOpportunityData();
        oppRequest.updateOpportunityData.salesforceOpportunityId = '006q000000JnV9jAAF';
        try {
            WS_UpdateOpportunity.updateOpportunity(oppRequest);   
        }
        catch(Exception ex) {
            System.assertEquals(true, true, 'Expected value not equals actual value');   
        }
    }
    
    //PLMOD scenario
    @isTest
    private static void updateOpp_PLMOD() {        
        //User/Agent Office data setUp
        testDataSetup();
        RestRequest request = new RestRequest(); 
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response= response;   
        
        System.runAs(adminUser){
            //setting Data for opp
            Opportunity opp = opportunitySetup(adminUser,15);
            HLPR_UpdateOppRequest oppRequest = updateOppRequest('rrccww11zzc',opp.id,false,'rrccww11zzc');
            oppRequest.updateOpportunityData.opportunityDescription = 'Internet Referral Complete Auto Quote Internet Referral Complete Auto Quote Inte';        
            opportunityTest(oppRequest,request,response);
            System.assert(response.responseBody.toString().contains(oppRequest.updateOpportunityData.salesforceOpportunityId),'Opportunity was not created through service');
            
            List<Opportunity> oppList = [Select id,isOfficeNotified__c, Name,Temperature__c, owner.Proxy_External_ID__c, account.ClientIdentifier__c from Opportunity where Id =: opp.id];
            System.assertEquals(false,oppList[0].isOfficeNotified__c,'Expected value is true, but actual value is '+oppList[0].isOfficeNotified__c);          
        }
        
    }
    
    @isTest
    private static void updateOpp_PLMOD_Case2() {        
        //User/Agent Office data setUp
        testDataSetup();
        RestRequest request = new RestRequest(); 
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response= response;   
        
        System.runAs(adminUser){
            //setting Data for opp
            Opportunity opp = opportunitySetup(adminUser,15);
            HLPR_UpdateOppRequest oppRequest = updateOppRequest('rrccww11zzc',opp.id,true,'');
            oppRequest.updateOpportunityData.opportunityDescription = 'Internet Referral Complete Auto Quote Internet Referral';        
            
            String jsonMsg=JSON.serialize(oppRequest);            
            // Setting up REST parameters for PoSt Operation
            request.requestURI = '/services/apexrest/updateopportunity';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueof(jsonMsg);               
            Test.startTest();
            //Calling the actual webservice class            
            WS_UpdateOpportunity.updateOpportunity(oppRequest);           
            System.assert(response.responseBody.toString().contains(oppRequest.updateOpportunityData.salesforceOpportunityId),'Opportunity was not created through service');          
            List<Opportunity> resultOpp = [Select id,officeassigned__C,StageName,Status__c,Sub_Status__c,Temperature__c,Amount,Monthly_Premium__c,Description,OpportunityDetail__c,Assigned_To__c from Opportunity where id=:oppRequest.updateOpportunityData.salesforceOpportunityId LIMIT 1];
            List<Opportunity_Note__c> resultOppNote = [Select Name,Comments__c,Category__c from Opportunity_Note__c where Opportunity__c=:oppRequest.updateOpportunityData.salesforceOpportunityId LIMIT 1];
            List<User> usr = [select id ,name from user where userexternalid__C=:proxyUser.UserExternalID__c] ;
            
            System.assert(resultOpp[0].id!=null, 'Found Opportunity to update');
            System.assertEquals(resultOpp[0].officeassigned__C, usr[0].name, 'Updated Office assigned');
            System.assertEquals(resultOpp[0].stageName, oppRequest.updateOpportunityData.stageName, 'Updated stagename');
            System.assertEquals(resultOpp[0].Temperature__c, oppRequest.updateOpportunityData.temperature, 'Updated temperature');
            System.assertEquals(resultOpp[0].Amount, decimal.valueof(oppRequest.updateOpportunityData.totalPremium), 'Updated totalPremium');
            System.assertEquals(resultOpp[0].Monthly_Premium__c, decimal.valueof(oppRequest.updateOpportunityData.monthlyPremium), 'Updated monthlyPremium');
            System.assertEquals(resultOppNote[0].name, oppRequest.updateOpportunityData.opportunityDescription,'Updated Description');
            System.assertEquals(resultOpp[0].Sub_Status__c,oppRequest.updateOpportunityData.subStatus,'Expected value is '+resultOpp[0].Sub_Status__c+', but actual value is '+oppRequest.updateOpportunityData.subStatus);
            System.assertEquals(resultOpp[0].Status__c,oppRequest.updateOpportunityData.status,'Expected value is '+resultOpp[0].Status__c+', but actual value is '+oppRequest.updateOpportunityData.status);
            System.assertEquals(resultOppNote[0].Comments__c, oppRequest.updateOpportunityData.opportunityDescription+'\n'+oppRequest.updateOpportunityData.opportunityDetail, 'Updated Detail');
            System.assertEquals(resultOpp[0].Assigned_To__c,null,'Expected value is '+resultOpp[0].Assigned_To__c+', but actual value is '+null);
            
            
            System.assert(response.responseBody.toString().contains(oppRequest.updateOpportunityData.salesforceOpportunityId),'Opportunity was not created through service');
            
            List<Opportunity> oppList = [Select id,isOfficeNotified__c, Name,Temperature__c, owner.Proxy_External_ID__c, account.ClientIdentifier__c from Opportunity where Id =: opp.id];
            System.assertEquals(true,oppList[0].isOfficeNotified__c,'Expected value is true, but actual value is '+oppList[0].isOfficeNotified__c);            
            
            //updating again so office wont receive notifications
            HLPR_UpdateOppRequest oppRequest1 = updateOppRequest('rrccww11zzc',opp.id,true,'');
            oppRequest1.updateOpportunityData.opportunityDescription = 'Internet Referral Complete Auto Quote Internet Referral'; 
            oppRequest1.updateOpportunityData.submittedPhone = '(320) 555-0163';
            WS_UpdateOpportunity.updateOpportunity(oppRequest1);           
            System.assert(response.responseBody.toString().contains(oppRequest1.updateOpportunityData.salesforceOpportunityId),'Opportunity was not created through service');          
            List<Opportunity> resultOpp1 = [Select id,Phone__c,officeassigned__C,StageName,Status__c,Sub_Status__c,Temperature__c,Amount,Monthly_Premium__c,Description,OpportunityDetail__c,Assigned_To__c from Opportunity where id=:oppRequest.updateOpportunityData.salesforceOpportunityId LIMIT 1];
            List<Opportunity_Note__c> resultOppNote1 = [Select Name,Comments__c,Category__c from Opportunity_Note__c where Opportunity__c=:oppRequest.updateOpportunityData.salesforceOpportunityId LIMIT 1];
            List<User> usr1 = [select id ,name from user where userexternalid__C=:proxyUser.UserExternalID__c] ;
            
            System.assert(resultOpp1[0].id!=null, 'Found Opportunity to update');
            System.assertEquals(resultOpp1[0].officeassigned__C, usr1[0].name, 'Updated Office assigned');
            System.assertEquals(resultOpp1[0].stageName, oppRequest1.updateOpportunityData.stageName, 'Updated stagename');
            System.assertEquals(resultOpp1[0].Temperature__c, oppRequest1.updateOpportunityData.temperature, 'Updated temperature');
            System.assertEquals(resultOpp1[0].Amount, decimal.valueof(oppRequest1.updateOpportunityData.totalPremium), 'Updated totalPremium');
            System.assertEquals(resultOpp1[0].Monthly_Premium__c, decimal.valueof(oppRequest1.updateOpportunityData.monthlyPremium), 'Updated monthlyPremium');
            System.assertEquals(resultOppNote1[0].name, oppRequest1.updateOpportunityData.opportunityDescription,'Updated Description');
            System.assertEquals(resultOpp1[0].Sub_Status__c,oppRequest1.updateOpportunityData.subStatus,'Expected value is '+resultOpp[0].Sub_Status__c+', but actual value is '+oppRequest.updateOpportunityData.subStatus);
            System.assertEquals(resultOpp1[0].Status__c,oppRequest1.updateOpportunityData.status,'Expected value is '+resultOpp[0].Status__c+', but actual value is '+oppRequest.updateOpportunityData.status);
            System.assertEquals(resultOppNote1[0].Comments__c, oppRequest1.updateOpportunityData.opportunityDescription+'\n'+oppRequest.updateOpportunityData.opportunityDetail, 'Updated Detail');
            System.assertEquals(resultOpp1[0].Assigned_To__c,null,'Expected value is '+resultOpp1[0].Assigned_To__c+', but actual value is '+null);
            System.assertEquals(resultOpp1[0].Phone__c,'(320) 555-0163','Expected value is '+resultOpp1[0].Phone__c+', but actual value is '+'(320) 555-0163');
            
            System.assert(response.responseBody.toString().contains(oppRequest1.updateOpportunityData.salesforceOpportunityId),'Opportunity was not created through service');
            
            oppList = [Select id,isOfficeNotified__c, Name,Temperature__c, owner.Proxy_External_ID__c, account.ClientIdentifier__c from Opportunity where Id =: opp.id];
            System.assertEquals(true,oppList[0].isOfficeNotified__c,'Expected value is true, but actual value is '+oppList[0].isOfficeNotified__c);            
            
            Test.stopTest();
        }
        
    }
}