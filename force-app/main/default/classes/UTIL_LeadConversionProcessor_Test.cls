/**  
@Author Loco Motivated  
@Name UTIL_LeadConversionProcessor_Test
@CreateDate 20/09/2016 
@description : This class contains unit tests for validating the Lead Conversion Details Mapping
@Version 1.0
*/

@isTest(seeAllData=false)
public class UTIL_LeadConversionProcessor_Test {  
    
    private static Lead lead;
    private static Account acc;
    private static User systemAdmin;
    private static User agentUser; 
    private static UserRole agentStandardUserRole;
    private static UserRole proxyStandardUserRole; 
    private static User agentUser1;
    private static User proxyUser;
    private static List<CM_StageOrchestration_Mapping__mdt> mappingForLeadtoLeadConversionDetailsforTest ;
    private static string querystringForLead = '';
    private static string querystringForLeadMessage='';
    private static string querystringForAccountMessage='';
    private static string leadLastName='';
    private static String dynamicQuery='';
    private static CS001_ByPassTriggerAll__c passTriggerAll;
    //method to set common data
    @TestSetup
    static void setup(){
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=false);
        insert passTriggerAll;
        passTriggerAll = [select Override_All__c from CS001_ByPassTriggerAll__c];
        passTriggerAll.Override_All__c = true;
        update passTriggerAll; 
        User testAgentUser1 = new User(Alias='alias',LastName='TestLN',Username='accOwnerAgent@statefarm.com',Associate_ID__c='mYAssOCID',UserExternalID__c='mYExTerID',Servicing_Agent_Associate_ID__c='mYServiceID');
        agentUser = UTIL_UserProvisioning_TEST.buildAgentUser1(testAgentUser1);
        insert agentUser;
        systemAdmin= UTIL_UserProvisioning_TEST.buildSystemAdmin('alias','systemAdmin','systemAdminTest@statefarm.com'); 
        agentStandardUserRole = new UserRole(name='AgentRole'); 
        User cccLUser = UTIL_UserProvisioning_TEST.buildCCCLicensedUser();
        cccLUser.UserExternalID__c = 'LdConvCCC';
        cccLUser.SubUserType__c = 'CCC Sales';
        insert cccLUser;
        TestFactory_PermSetAssignmentByUser.assignBasePermissionsToUsers(new List<User>{agentUser, cccLUser});
    }
    //method to get lead data 
    private static void getLead(){
        lead = new Lead(FirstName = 'FTestLead',MiddleName = 'MTestLead',LastName = 'LTestLead', Status='Open',Email = 'JhnD@noemail.com',External_Lead_ID__c='TestExtID');
    }
    //method to fetch users
    private static void getAgentUser(){
        agentUser=[SELECT Id, Username, Associate_ID__c, Proxy_External_ID__c, Servicing_Agent_Associate_ID__c, Servicing_Agent_External_ID__c, UserExternalID__c, Agent_Name_Alias__c, UserType__c FROM User where UserExternalID__c='mYExTerID' ];
    }
    
    private static User getCCCUser() {
        return [Select Id from User where UserExternalId__c = 'LdConvCCC' LIMIT 1];
    }
    /**
    * @description populateRequiredMapping: Populating Required Mapping as per the requirment 
    */
    public static void populateRequiredMapping(){
        
        mappingForLeadtoLeadConversionDetailsforTest = [SELECT Mapping_Type__c,Source_Field__c,Target_Field__c 
                                                        FROM CM_StageOrchestration_Mapping__mdt
                                                        WHERE Mapping_Type__c=:UTIL_StageOrchestrationConstants.LEAD_TO_LEADCONVERSIONDETAILS];        
    }    
    
    
    /**
    * @description testLeadToLeadConversionMapping: Test method to validate Lead Conversion Details Mapping with Lead Details
    */     
    @isTest static void testLeadToLeadConversionMapping(){
        getLead();
        acc = new Account(FirstName=lead.LastName,LastName=lead.LastName,BillingAddressType__c='US',ClientIdentifier__c='extTestId');
        getAgentUser();
        populateRequiredMapping();
        Test.startTest(); 
        System.runAs(agentUser) {
            lead.OriginalLeadSource__c = 'Enterprise Facebook Lead';
            insert lead;
            insert acc;
            List<StageOrchestration__c> stgOrchList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = buildJSON(lead.Id,acc.Id);
            stgOrchList.add(testStageOrchestration);
            new UTIL_LeadConversionProcessor().execute(stgOrchList);
            Test.stopTest();   
            for (CM_StageOrchestration_Mapping__mdt mappingLoopForListofLead : mappingForLeadtoLeadConversionDetailsforTest){
                
                querystringForLead = querystringForLead +','+ mappingLoopForListofLead.Target_Field__c;                                     
            } 
            leadLastName = lead.LastName;
            dynamicQuery = UTIL_StageOrchestrationConstants.SELECT_ID + querystringForLead +' FROM LeadConversionDetail__c where LastName__c= :leadLastName LIMIT 1'; 
            LeadConversionDetail__c testConversionDetails = Database.query(dynamicQuery);
            
            for(CM_StageOrchestration_Mapping__mdt testCustomMetadta : mappingForLeadtoLeadConversionDetailsforTest){
                testConversionDetails.put(testCustomMetadta.Target_Field__c,Lead.get(testCustomMetadta.Source_Field__c));                
                system.assertEquals(lead.get(testCustomMetadta.Source_Field__c), testConversionDetails.get(testCustomMetadta.Target_Field__c),'Expected value is'+lead.get(testCustomMetadta.Source_Field__c)+', but actual value is' +testConversionDetails.get(testCustomMetadta.Target_Field__c));
            } 
        } 
    }

    @isTest static void testLeadToLeadConversionMappingAsCCCUser(){
        getLead();
        acc = new Account(FirstName=lead.LastName,LastName=lead.LastName,BillingAddressType__c='US',ClientIdentifier__c='extTestId');
        getAgentUser();
        populateRequiredMapping();
        Test.startTest(); 
        System.runAs(getCCCUser()) {
            lead.Agent__c = UserInfo.getUserId();
            lead.OriginalLeadSource__c = 'Enterprise Facebook Lead';
            insert lead;
            insert acc;
            List<StageOrchestration__c> stgOrchList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = buildJSON(lead.Id,acc.Id);
            stgOrchList.add(testStageOrchestration);
            new UTIL_LeadConversionProcessor().execute(stgOrchList);
            Test.stopTest();   
            for (CM_StageOrchestration_Mapping__mdt mappingLoopForListofLead : mappingForLeadtoLeadConversionDetailsforTest){
                querystringForLead = querystringForLead +','+ mappingLoopForListofLead.Target_Field__c;                                     
            } 
            leadLastName = lead.LastName;
            dynamicQuery = UTIL_StageOrchestrationConstants.SELECT_ID + querystringForLead +' FROM LeadConversionDetail__c where LastName__c= :leadLastName LIMIT 1'; 
            LeadConversionDetail__c testConversionDetails = Database.query(dynamicQuery);
            
            for(CM_StageOrchestration_Mapping__mdt testCustomMetadta : mappingForLeadtoLeadConversionDetailsforTest){
                testConversionDetails.put(testCustomMetadta.Target_Field__c,Lead.get(testCustomMetadta.Source_Field__c));                
                system.assertEquals(lead.get(testCustomMetadta.Source_Field__c), testConversionDetails.get(testCustomMetadta.Target_Field__c),'Expected value is'+lead.get(testCustomMetadta.Source_Field__c)+', but actual value is' +testConversionDetails.get(testCustomMetadta.Target_Field__c));
            } 
        } 
    }
    
    @isTest static void testLeadToLeadConversionMappingForDandBLeads(){
        getLead();
        acc = new Account(FirstName=lead.LastName,LastName=lead.LastName,BillingAddressType__c='US',ClientIdentifier__c='extTestId');
        getAgentUser();
        populateRequiredMapping();
        Test.startTest(); 
        System.runAs(agentUser) {
            lead.OriginalLeadSource__c = 'Small Business Corporate Campaign';
            insert lead;
            insert acc;
            List<StageOrchestration__c> stgOrchList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = buildJSON(lead.Id,acc.Id);
            stgOrchList.add(testStageOrchestration);
            new UTIL_LeadConversionProcessor().execute(stgOrchList);
            Test.stopTest();
            LeadConversionDetail__c leadConversionDetails = new LeadConversionDetail__c(OriginalLeadSource__c=lead.OriginalLeadSource__c);
            system.assertEquals('Small Business Corporate Campaign', leadConversionDetails.OriginalLeadSource__c, 'Original Lead Source is Incorrect.');  
        }
    }

    /**
    * @description testLeadProcessorException: Test method to validate QueryException exception 
    */     
    @isTest static void testLeadProcessorException(){
        getLead();
        acc = new Account(FirstName=lead.LastName,LastName=lead.LastName,BillingAddressType__c='US',ClientIdentifier__c='extTestId');
        getAgentUser();
        Test.startTest(); 
        System.runAs(agentUser) {
            insert lead;
            
            insert acc;

            List<StageOrchestration__c> stgOrchList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = buildJSON(acc.Id,acc.Id);
            stgOrchList.add(testStageOrchestration);
            try{
                new UTIL_LeadConversionProcessor().execute(stgOrchList);
                System.assert(false, 'No Lead Processor Exception Occured');
            }
            catch(StageProcessorException ex){
                System.assert(ex.getCause() instanceof QueryException,'Assertion Failed');  
            }
            Test.stopTest();
        }         
    }
    
    /**
    * @description testLeadProcessorDMLException: Test method to validate DMLException Exception 
    */     
    @isTest static void testLeadProcessorDMLException(){
        getLead();
        acc = new Account(FirstName=lead.LastName,LastName=lead.LastName,BillingAddressType__c='US',ClientIdentifier__c='extTestId');
        getAgentUser();
        Test.startTest(); 
        System.runAs(agentUser) {
            lead.Company='asasasasasasassaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
            lead.OriginalLeadSource__c = 'Enterprise Facebook Lead';
            insert lead;            
            insert acc;

            List<StageOrchestration__c> stgOrchList = new List<StageOrchestration__c>();
            StageOrchestration__c stgorc = new StageOrchestration__c();
            stgorc.Value__c = buildJSON(lead.Id, lead.Id);
            stgOrchList.add(stgorc);
            try{
                new UTIL_LeadConversionProcessor().execute(stgOrchList);
                System.assert(false, 'Expected StageProcessorException'); 
            }
            catch(StageProcessorException ex){
                System.assert(ex.getCause() instanceof DMLException,'Assertion failed');  
            }
            Test.stopTest();
        }         
    }
    
    /**
    * @description testLeadProcessorDMLException: Test method to validate DMLException Exception 
    */     
    @isTest static void testLeadProcessorStringException(){
        getLead();
        acc = new Account(FirstName=lead.LastName,LastName=lead.LastName,BillingAddressType__c='US',ClientIdentifier__c='extTestId');
        getAgentUser();
        Test.startTest(); 
        System.runAs(agentUser) {
            insert lead;            
            insert acc;

            List<StageOrchestration__c> stgOrchList = new List<StageOrchestration__c>();
            StageOrchestration__c stgorc = new StageOrchestration__c();
            try{
                stgorc.Value__c = '{"orchestrationInfo" : {"jsonVersionNumber" : "1.0","orchestrationEventName" : {"orchestrationEventType" : "LeadConversion","orchestrationEventDetail" : {"orchestrationEventValues" : { "leadId" : "" ,"accountId" : ""}}}}}' ;
                stgOrchList.add(stgorc);
                new UTIL_LeadConversionProcessor().execute(stgOrchList);           
            }
            catch(StageProcessorException ex){                
                System.assertNotEquals(null, ex.getmessage(), 'Exception message should be null');  
            }
            Test.stopTest();
        }         
    }
    
    /**
    * @description testLeadProcessorNullPointerException: Test method to validate NullException exception 
    */     
    @isTest static void testLeadProcessorNullPointerException(){
        getLead();
        acc = new Account(FirstName=lead.LastName,LastName=lead.LastName,BillingAddressType__c='US',ClientIdentifier__c='extTestId');
        getAgentUser();
        Test.startTest(); 
        System.runAs(agentUser) {            
            List<StageOrchestration__c> stgOrchList = new List<StageOrchestration__c>();
            StageOrchestration__c testStageOrchestration = new StageOrchestration__c();
            testStageOrchestration.Value__c = null;
            stgOrchList.add(testStageOrchestration);
            try{
                new UTIL_LeadConversionProcessor().execute(stgOrchList);
            }
            catch(StageProcessorException ex){ 
                System.assert(ex.getCause() != null, 'Exception message should not be null');
                System.assert(ex.getCause() instanceof InvalidInputException, 'Assertion Failed');
                System.assertEquals(UTIL_StageOrchestrationConstants.EMPTY_JSON_EXCEPTION_MESSAGE, ex.getMessage(), 'Expected value is: '+UTIL_StageOrchestrationConstants.EMPTY_JSON_EXCEPTION_MESSAGE+', but actual value is: '+ex.getMessage());
            }
            Test.stopTest();
        }         
    }
    
    /**
    * @description buildJSON: Method to generate a JSON String 
    * @param leadId : Lead Id 
    * @param accId : Account Id 
    * @return static : JSON
    */  
    private static String buildJSON(id leadId,id accId) {
        
        string jsonString = '{ '+
            '"orchestrationInfo" : { '+
            '"jsonVersionNumber" : "1.0", '+
            '"orchestrationEventName" : { '+
            '"orchestrationEventType" : "Conversion Lead Details",'+
            '"orchestrationEventDetail" : { '+
            '"orchestrationEventValues" : { '+
            '"leadId" : "'+leadId+'", '+
            '"accountId" : "'+accId+'" '+
            '} '+
            '} '+
            '} '+
            '} '+
            '}';
        return jsonString;
    }
}