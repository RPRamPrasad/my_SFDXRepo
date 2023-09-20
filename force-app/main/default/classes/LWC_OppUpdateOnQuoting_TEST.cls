@isTest()
public with sharing class LWC_OppUpdateOnQuoting_TEST {
    private static User sysAdminuser;
    private static User agentUser;
    private static User atmUser;
    private static User proxyUser;
    private static User systemUser;
    private static UserRole proxyStandardUserRole;
    private static UserRole agentStandardUserRole;
    private static UserRole agentTeamMemberUserRole;
    private static User technicalUser;
    
    private static Map<String, Schema.Recordtypeinfo> accountRecordTypeMap=Schema.Sobjecttype.Account.getRecordTypeInfosByDeveloperName();
    public static Map<String,List<SalesAttempt__c>> salesAttemptMap = new Map<String,List<SalesAttempt__c>>();

    @TestSetup
    private static void setUpTriggerAndUserData() {
        systemUser = UTIL_UserProvisioning_TEST.buildStateFarmAccountOwner();  
        insert systemUser;
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = new AccountOwnerSystemUserCustomSetting__c(Name=UTIL_CreateCustomerConstants.SYSTEM_DEFAULT_ACCOUNT_OWNER,SFDC_USER_ID__c=systemUser.id);            
        insert sysAdminUserIdSetting;
        sysAdminuser= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com');
        insert sysAdminuser;           
        
        System.runAs(sysAdminuser) {
            User testTechUser = new User(Alias='OTECH',LastName='TAUser1',Username=UTIL_TestUsername_TEST.getTestUsername(),Associate_ID__c='OOA1',UserExternalID__c='OOA1');
            technicalUser = UTIL_UserProvisioning_TEST.buildTechnicalUser(testTechUser);
            technicalUser.isactive = true;
            technicalUser.federationIdentifier = null;
            technicalUser.isactive = true;
            technicalUser.SubUserType__c='SFDC_USER_1_07_Tech_Supp';
            technicalUser.UserType__c='Support';
            insert technicalUser;             
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
            agentUser.State_Agent_Code__c = '35-9585';
            agentUser.State_Agent_Code_List__c=  '35-9585';
            agentUser.userRoleId= agentStandardUserRole.id;
            Database.insert(agentUser);
            TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUser(agentUser);
            UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
             CS001_ByPassTriggerGtoZ__c byPass = CS001_ByPassTriggerGtoZ__c.getInstance();
            byPass.Override_OpportunityAfterInsert__c = true;
            insert byPass;
        }
    }

    private static Account buildAccountRecord(String paramClientIdentifier) {
        String acctRecordTypeId = accountRecordTypeMap.get('Individual').RecordTypeId;
        Account acctRecord = new Account(FirstName = 'rrrrr', LastName = 'tttttttt', ClientIdentifier__c = paramClientIdentifier,RecordTypeId = acctRecordTypeId,Edit_In_VFP__c = true
                                         );
        return acctRecord;
    }

    private static Opportunity buildOpportunityRecord(Account testAccount) {
        Opportunity opptyRecord = new Opportunity ();
        opptyRecord.Name = 'Tst Opportunity';
        opptyRecord.AccountId = testAccount.id;
        opptyRecord.CloseDate = System.today().addDays(10);
        opptyRecord.LOB__c = 'Fire';
        opptyRecord.StageName = 'New';
        opptyRecord.Requested_Effective_Date__c = System.today();
        return opptyRecord; 
    }

    private static OpportunityProduct__c createOpportunityProduct(){
        OpportunityProduct__c oProduct = new OpportunityProduct__c();
        Date todaysDate = System.today();
     //   String todaysDateStr = todaysDate.format('yyyy-MM-dd');
        oProduct.Product_Start_Date__c=todaysDate;
        oProduct.Product_System_Name__c='ProductSystemName';
        oProduct.Product_Type__c='ProductType';
        oProduct.Product_Line__c='A';
        oProduct.Product_Form_Num__c = 'ProductFormNum'; 
        oProduct.Product_Postal_State__c = 'KY';  
        oProduct.Product_Description__c = 'ProductDescription';
        oProduct.Product_Id__c='ProductId';  
		oProduct.Lob_Cd__c='27';
       // String endDate = (System.today().addDays(10)).format('yyyy-MM-dd');
        Date endDate = System.today().addDays(10);
        oProduct.Product_END_Date__c=endDate;
        insert oProduct;
        return oProduct;
    }

    // test getProspectEvalData method return val
    @isTest
    private static void getProspectEvalDataReturnsValidData() {    
        User testAgentUser1 = new User(Alias='AGNT',LastName='opportunityProxy',Username='TestAgtUserForOppTst12@statefarm.com',Associate_ID__c='123test',UserExternalID__c='1234test_1234test',Servicing_Agent_Associate_ID__c='1234test');
        User agent = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1); 
        insert agent;
        String agentOwnerId = [SELECT Id FROM User WHERE Alias = 'AGNT'].Id;

        Account account = buildAccountRecord('121312');
        insert account;
        String accountId = [SELECT Id FROM Account WHERE ClientIdentifier__c = '121312'].Id;

        Opportunity opp = UTIL_OpportunityNotificationManager_TEST.buildOpportunityRecord(
            accountId, 'Investments-Joint', agentOwnerId);
        insert opp;
        opp.hasProspectEval__c = false;
        update opp;

        List<Opportunity> queriedOpp = [SELECT Id FROM Opportunity WHERE Account.ClientIdentifier__c = '121312'];
        Opportunity expectedOpp = queriedOpp[0];

        Opportunity actualOpp = new Opportunity();
        System.runAs(agent){
            Test.startTest();
                actualOpp = LWC_OppUpdateOnQuoting.getProspectEvalData(expectedOpp.Id);
            Test.stopTest();
        }
        System.assertEquals(expectedOpp.Id, actualOpp.Id, 'Opportunities must match');
    }

    @isTest
    private static void updateOpportunityAndInvokeNewAppQuote(){
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
        Opportunity opp;
        Account acctRecord ;
        AP_UserProvisioningProcess_TEST_UTIL.assignPermissionSet(agentUser.Id, 'Opportunity_PartialAccess');
        System.runAs(agentUser){
            acctRecord = buildAccountRecord('1213121');
            insert acctRecord;
        }
        sysAdminuser = [select id from user where alias = 'alias' limit 1];
        System.runAs(sysAdminuser) {
            AgentRole__c newAgentRole = new AgentRole__c(customer__c=acctRecord.id, agent__c=agentUser.id);
            insert newAgentRole;
        }
        system.runAs(agentUser){
             opp = buildOpportunityRecord(acctRecord);
            opp.product__c='Renters';
            opp.State_Code__c='KY / 12-1234';
            insert opp;
        }     
        OpportunityProduct__c oppProduct;
        System.runAs(sysAdminuser) {
           oppProduct = createOpportunityProduct();
        }
        
        LWC_OppUpdateOnQuoting.OpportunityUpdateRequest updateRequest = new LWC_OppUpdateOnQuoting.OpportunityUpdateRequest();
        updateRequest.lob='Fire';
        updateRequest.stateCode='KY / 12-1234';
        Date todaysDate = System.today();
        //String todaysDateStr = todaysDate.format('yyyy-MM-dd');
        updateRequest.effectiveDate=todaysDate;
        updateRequest.oppRecordId=opp.Id;
        Map<String,String> pd = new Map<String,String>();
        List<Map<String,String>> productDetails =new List<Map<String,String>>();
        pd.put('ProductDescription','Renters');
        pd.put('ProductType','Product Type');    
        pd.put('ProductFormNum','AP8103');
        pd.put('ProductId','P1');
        pd.put('ProductLine','F');
        pd.put('ProductSystemName','PP_PRSNL_PREF');
        pd.put('productStartDate','2022-01-01');
        pd.put('ProductPostalState','KY');
        pd.put('LobCd','24');
        productDetails.add(pd);
        updateRequest.productDetails=productDetails;
                String responseJson =  '{"urlToLaunch":"/c/ExternalLinkApp.app?linkId=88&accountId='+acctRecord.id+'&opportunityId='+opp.Id+'&lob=Fire&newStageName=Quoting&PID=P1&effectiveDate='+String.valueOf(System.today())+'&stateAgentCode=12-1234&LOBCD=24&appName=ECRM 3.0&jointSecondClientId=&jointType=","status":"success"}';
                    System.runAs(agentUser) {
             AppDefinition definition = [SELECT Id, DeveloperName, Label, Description, UtilityBar, HeaderColor, DurableId  
                                       FROM AppDefinition WHERE DeveloperName ='ECRM_3_0' LIMIT 1];
		    
            UserAppInfo userAppInfo = new UserAppInfo();
            userAppInfo.UserId=agentUser.Id;
            userAppInfo.AppDefinitionId=definition.DurableId;
            userAppInfo.FormFactor='Large';
            insert userAppInfo;
        	String response = LWC_OppUpdateOnQuoting.updateOpportunityAndInvokeNewAppQuote(updateRequest);  
            System.assertEquals(responseJson,response,'Response is not matching');
        }
    }

    @isTest
    private static void updateOpportunityAndInvokeNewAppQuoteFailure(){
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
        Opportunity opp;
        Account acctRecord ;
        System.runAs(agentUser){
            acctRecord = buildAccountRecord('1213121');
            insert acctRecord;
        }
        
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=acctRecord.id, agent__c=agentUser.id);
        insert newAgentRole;
        system.runAs(agentUser){
             opp = buildOpportunityRecord(acctRecord);
            opp.product__c='Renters';
            opp.State_Code__c='KY';
            insert opp;
        }
     
        sysAdminuser = [select id from user where alias = 'alias' limit 1];
        OpportunityProduct__c oppProduct;
        System.runAs(sysAdminuser) {
           oppProduct = createOpportunityProduct();
        }
        
        LWC_OppUpdateOnQuoting.OpportunityUpdateRequest updateRequest = new LWC_OppUpdateOnQuoting.OpportunityUpdateRequest();
        updateRequest.lob='Fire';
        updateRequest.stateCode='KY';
        Date todaysDate = System.today();
        updateRequest.effectiveDate=todaysDate;
        List<Map<String,String>> productDetails =new List<Map<String,String>>();
        updateRequest.productDetails=productDetails;
        String responseJson =  '{"status":"failure"}';
        System.runAs(agentUser) {
        	String response = LWC_OppUpdateOnQuoting.updateOpportunityAndInvokeNewAppQuote(updateRequest);  
            System.assertEquals(responseJson,response,'Response is not matching');
        }
    }

    @isTest
    private static void noProductOpportunityUpdateFailure() {
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
        Opportunity opp;
        Account acctRecord ;
        System.runAs(agentUser){
            acctRecord = buildAccountRecord('1213121');
            insert acctRecord;
        }
        
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=acctRecord.id, agent__c=agentUser.id);
        insert newAgentRole;
        system.runAs(agentUser){
             opp = buildOpportunityRecord(acctRecord);
            opp.product__c='Renters';
            opp.State_Code__c='KY';
            insert opp;
        }
     
        sysAdminuser = [select id from user where alias = 'alias' limit 1];
        OpportunityProduct__c oppProduct;
        System.runAs(sysAdminuser) {
           oppProduct = createOpportunityProduct();
        }
        
        LWC_OppUpdateOnQuoting.OpportunityUpdateRequest updateRequest = new LWC_OppUpdateOnQuoting.OpportunityUpdateRequest();
        updateRequest.lob='Fire';
        updateRequest.oppRecordId=opp.Id;
        updateRequest.stateCode='KY / 12-1234';
        Date todaysDate = System.today();
        updateRequest.effectiveDate=todaysDate;
        List<Map<String,String>> productDetails =new List<Map<String,String>>();
        updateRequest.productDetails=null;
        String responseJson =  '{"status":"failure"}';
        System.runAs(agentUser) {
        	String response = LWC_OppUpdateOnQuoting.updateOpportunityAndInvokeNewAppQuote(updateRequest);  
            System.assertEquals(responseJson,response,'Response does not match');
            Opportunity updateOpp = [select id,stagename,status__c,product_system_name__c,Product__c,state_code__c from opportunity where id= :opp.id];
            System.assertEquals('New', updateOpp.stageName,'Stage is not valid');
            System.assertEquals(null, updateOpp.Status__c,'Status is not valid');
        }
    }
    
    @isTest
    private static void stateSelections() {
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
        agentUser.State_Agent_Code__c = '35-9585';
        agentUser.State_Agent_Code_List__c=  '35-9585';
        
        System.runAs(agentUser) {
            LWC_NewOpportunityWorkflow.StateSelectionOptions stateSelections = LWC_OppUpdateOnQuoting.getStateCodeInfoFromOppOfficeId(agentUser.Associate_ID__c);
            System.assertEquals('OH / 35-9585',stateSelections.selectedState,'Selected State is not equal to agent state');
            System.assertEquals('OH / 35-9585',stateSelections.stateList[0].label,'State List label is not valid');
            System.assertEquals(1,stateSelections.stateList.size(),'State List is not valid');
        }
    }

    @isTest
    private static void multiStateSelections() {
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
        User updateUser = new User();
        updateUser.id=agentUser.id;
        updateUser.State_Agent_Code__c = '35-9585';
        updateUser.State_Agent_Code_List__c=  '35-9585,13-3338';
        Database.update(updateUser);
        System.runAs(agentUser) {
            LWC_NewOpportunityWorkflow.StateSelectionOptions stateSelections = LWC_OppUpdateOnQuoting.getStateCodeInfoFromOppOfficeId(agentUser.Associate_ID__c);
            System.assertEquals('OH / 35-9585',stateSelections.selectedState,'Selected State is not equal to agent state');
            System.assertEquals('OH / 35-9585',stateSelections.stateList[0].label,'State List label is not valid');
            System.assertEquals('IL / 13-3338',stateSelections.stateList[1].label,'State List label is not valid');
            System.assertEquals(2,stateSelections.stateList.size(),'State List is not valid');
        }
    }

    @isTest
    private static void validateAndInvokeUpp() {
      
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
        Opportunity opp;
        Account acctRecord ;
        System.runAs(agentUser){
            acctRecord = buildAccountRecord('1213121');
            insert acctRecord;
        }
        
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=acctRecord.id, agent__c=agentUser.id);
        insert newAgentRole;
         technicalUser = [select id from user where alias = 'OTECH' limit 1];
        system.runAs(agentUser){
            opp = buildOpportunityRecord(acctRecord);
            opp.product__c='Renters';
            opp.State_Code__c='KY / 12-1234';
           
            insert opp;
        }
  		system.runAs(technicalUser){
                String stageValue = LWC_OppUpdateOnQuoting.validateAndInvokeOpp(opp);
                System.assertEquals('StageInQuoting',stageValue,'Value is not valid');
        }
       
    }

    @isTest
    private static void validateAndInvokeUppStage() {
        User queryAgent = [Select id,Proxy_External_ID__c,UserExternalID__c,Associate_ID__c,Alias,lastname,email,Servicing_Agent_External_ID__c from User where username = 'TestAgtUserForOppTst11@statefarm.com' LIMIT 1];      
        agentUser= queryAgent;
        Opportunity opp;
        Account acctRecord ;
        System.runAs(agentUser){
            acctRecord = buildAccountRecord('1213121');
            insert acctRecord;
        }
        
        AgentRole__c newAgentRole = new AgentRole__c(customer__c=acctRecord.id, agent__c=agentUser.id);
        insert newAgentRole;
        system.runAs(agentUser){
            opp = buildOpportunityRecord(acctRecord);
            opp.product__c='Renters';
            opp.State_Code__c='KY / 12-1234';
            opp.StageName='Assigned';
            insert opp;
        }
 		system.runAs(agentUser){
            String stageValue = LWC_OppUpdateOnQuoting.validateAndInvokeOpp(opp);
            System.assertEquals('Success',stageValue,'Value is not valid');
        }
    }
}
