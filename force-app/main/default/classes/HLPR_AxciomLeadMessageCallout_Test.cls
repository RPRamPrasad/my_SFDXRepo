/**  
@Author Loco Motivated  
@Name HLPR_AxciomLeadMessageCallout_Test
@CreateDate 06/29/2017 
@description This is a Helper class which will get a response from Axciom for Lead Messages
@Version 1.0
*/ 
@isTest(SeeAllData=false)
public class HLPR_AxciomLeadMessageCallout_Test{
    
    private static User agentUser; 
    private static CS001_ByPassTriggerAll__c passTriggerAll;
    private static Lead lead;
    private static Account accrecord;
    private static final String CLIENT_IDENTIFIER='IAMCLIENT32';
    
    //Setup method for data creations
    /**
     * @description setup
     */
    public static void setup(){
        passTriggerAll = new CS001_ByPassTriggerAll__c(Override_All__c=false);
        insert passTriggerAll;
        passTriggerAll = [select Override_All__c from CS001_ByPassTriggerAll__c];
        passTriggerAll.Override_All__c = true;
        update passTriggerAll; 
        
        UTIL_StageOrchestrationTestUtils.AgentUserWrapper agentWrap = new UTIL_StageOrchestrationTestUtils.AgentUserWrapper();
        agentWrap.a_alias = 'alias';
        agentWrap.a_lastName = 'TestLN';
        agentWrap.a_UserName = 'acxioumLMUser@statefarm.com';
        agentWrap.a_associateId = 'mYAssOCID';
        agentWrap.a_userExternalId = 'mYExTerID';
        agentWrap.a_servicingAgentAssocId = 'mYServiceID';

        agentUser = UTIL_StageOrchestrationTestUtils.buildAgentUser(agentWrap);
        
        CS_TechnicalPlatform__c srKey = new CS_TechnicalPlatform__c();
        srKey.Name = 'SR_API_KEY';
        srKey.Value__c = 'TestKeyAPIValue';
        
        CS_TechnicalPlatform__c srCategory = new CS_TechnicalPlatform__c();
        srCategory.Name = 'SR_CATEGORY';
        srCategory.Value__c = 'a';
        insert new List<CS_TechnicalPlatform__c>{srKey, srCategory};
        
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
         
        lead = new Lead(FirstName = 'FTestLead',MiddleName = 'MTestLead',LastName = 'LTestLead', Status='Open',Email = 'testLM@noemail.com',External_Lead_ID__c='TestExtID');    
        accrecord = new Account(FirstName='Ftest',LastName='Ltest',BillingAddressType__c='US',ClientIdentifier__c=CLIENT_IDENTIFIER);
    }
    
    /**
    * @description testAxciomCalloutwithEmptyLeadMessages: Test method to validate the AxciomCallout Empty LeadMessage List
    */ 
    @isTest static void testAxciomCalloutwithEmptyLeadMessages() {
        setup();
        insert lead;
        Test.startTest();
        system.runAs(agentUser){
        insert accrecord;
        HLPR_AxciomLeadMessageMockHttpResponse fakeResponse = 
                                    new HLPR_AxciomLeadMessageMockHttpResponse(200,'Complete','{"Result": "Success","Message": "","LeadMessages": []');
        Test.setMock(HttpCalloutMock.class, fakeResponse);
            HLPR_AxciomLeadMessageCallout.callAxciomLeadMailingHistoryService(lead.Id,agentUser.Servicing_Agent_Associate_ID__c,accrecord.Id);
        }
        Test.stopTest();
        List<AccountMessage__c> objAccountMessage = [select id from AccountMessage__c where Account__c=:accrecord.Id];
        system.assertEquals(0, objAccountMessage.size(),'Expected value is 0, but actual value is'+objAccountMessage.size());
    }
    
    /**
    * @description testAxciomCalloutFailureResponseException: Test method to validate the AxciomCallout Failure Response Exception
    */ 
    @isTest static void testAxciomCalloutFailureResponseException() {
        setup();
        insert accrecord;
        Test.startTest();
        system.runAs(agentUser){
        HLPR_AxciomLeadMessageMockHttpResponse fakeResponse = new HLPR_AxciomLeadMessageMockHttpResponse(500,'Failure',buildFailureLeadMessageJson());
        Test.setMock(HttpCalloutMock.class, fakeResponse);
            HLPR_AxciomLeadMessageCallout.callAxciomLeadMailingHistoryService('00Q0j000001dwqREAQ',agentUser.Servicing_Agent_Associate_ID__c,accrecord.Id);
        }
        Test.stopTest();
        ExceptionLog__c actualException=[SELECT Id, Class__c, Exception_Message__c, Exception_Type__c, Method__c, Severity__c FROM ExceptionLog__c];
        system.assertEquals('HLPR_AxciomLeadMessageCallout', actualException.Class__c,'Expected value is HLPR_AxciomLeadMessageCallout, but actual value is'+actualException.Class__c);
        system.assertEquals('callAxciomLeadMailingHistoryService', actualException.Method__c,'Expected value is callAxciomLeadMailingHistoryService, but actual value is'+actualException.Method__c);
        system.assertEquals('WARN', actualException.Severity__c,'Expected value is WARN, but actual value is'+actualException.Severity__c); 
    }
    
    /**
    * @description testAxciomCalloutwithInvalidIdException: Test method to validate the AxciomCallout InvalidId Exception
    */ 
    @isTest static void testAxciomCalloutwithInvalidIdException() {
        setup();
        Test.startTest();
        system.runAs(agentUser){
        HLPR_AxciomLeadMessageMockHttpResponse fakeResponse = new HLPR_AxciomLeadMessageMockHttpResponse(200,'Complete',buildSingleLeadMessageJson('clientId'));
        Test.setMock(HttpCalloutMock.class, fakeResponse);
            HLPR_AxciomLeadMessageCallout.callAxciomLeadMailingHistoryService('00Q0j000001dwqREAQ',agentUser.Servicing_Agent_Associate_ID__c,'');
        }
        Test.stopTest();
        ExceptionLog__c actualException=[SELECT Id, Class__c, Exception_Message__c, Exception_Type__c, Method__c, Severity__c FROM ExceptionLog__c];
        system.assertEquals('HLPR_AxciomLeadMessageCallout', actualException.Class__c,'Expected value is HLPR_AxciomLeadMessageCallout, but actual value is'+actualException.Class__c);
        system.assertEquals('callAxciomLeadMailingHistoryService', actualException.Method__c,'Expected value is callAxciomLeadMailingHistoryService, but actual value is'+actualException.Method__c);
        system.assertEquals('WARN', actualException.Severity__c,'Expected value is WARN, but actual value is'+actualException.Severity__c); 
    }
    
    /**
    * @description testAxciomCalloutTypeException: Test method to validate the AxciomCallout Type Exception
    */ 
    @isTest static void testAxciomCalloutTypeException() {
        setup();
        Test.startTest();
        system.runAs(agentUser){
            HLPR_AxciomLeadMessageCallout.callAxciomLeadMailingHistoryService('00Q0j000001dwqREAQ','','');
        }
        Test.stopTest();
        ExceptionLog__c actualException=[SELECT Id, Class__c, Exception_Message__c, Exception_Type__c, Method__c, Severity__c FROM ExceptionLog__c];
        system.assertEquals('HLPR_AxciomLeadMessageCallout', actualException.Class__c,'Expected value is HLPR_AxciomLeadMessageCallout, but actual value is'+actualException.Class__c);
        system.assertEquals('System.TypeException', actualException.Exception_Type__c,'Expected value is System.TypeException, but actual value is'+actualException.Exception_Type__c);
        system.assertEquals('callAxciomLeadMailingHistoryService', actualException.Method__c,'Expected value is callAxciomLeadMailingHistoryService, but actual value is'+actualException.Method__c);
        system.assertEquals('Methods defined as TestMethod do not support Web service callouts', actualException.Exception_Message__c,'Expected value is Methods defined as TestMethod do not support Web service callouts, but actual value is'+actualException.Exception_Message__c);
        system.assertEquals('WARN', actualException.Severity__c,'Expected value is WARN, but actual value is'+actualException.Severity__c);
    }
    /**
     * @description buildSingleLeadMessageJson
     * @param associateId 
     * @return  `String`
     */
    public static String buildSingleLeadMessageJson(String associateId) {
        return '{'+
                '"Result": "Success",'+
                '"Message": "",'+
                '"LeadMessages":    [{'+
                '"associateID": "'+associateId+'",'+
                '"bundleID": null, '+
                '"businessLineCode": null, '+
                '"categoryName": null, '+
                '"contactMethodName": "Mail",'+
                '"creatorRoleCode": null, '+
                '"customDemographicsID": false,'+
                '"customGreetingText": null, '+
                '"derivedMethodID1": null, '+
                '"derivedMethodID2": null, '+
                '"derivedMethodID3": null, '+
                '"derivedMethodID4": null, '+
                '"derivedMethodID5": null, '+
                '"designationsID": true,'+
                '"estimateTotalCost": "32.23", '+
                '"estimateUnitCost": "12.21", '+
                '"giveawayOptionCode": null, '+
                '"globalItemVarblSeqNum1": null, '+
                '"globalItemVarblSeqNum2": null, '+
                '"globalItemVarblSeqNum3": null, '+
                '"globalItemVarblSeqNum4": null, '+
                '"globalItemVarblSeqNum5": null, '+
                '"globalItemVarblSeqNum6": null, '+
                '"globalItemVarblSeqNum7": null, '+
                '"globalItemVarblSeqNum8": null, '+
                '"globalItemVarblSeqNum9": null, '+
                '"globalItemVarblSeqNum10": null, '+
                '"globalItemVarblSeqNum11": null, '+
                '"globalItemVarblValText1": null, '+
                '"globalItemVarblValText2": null, '+
                '"globalItemVarblValText3": null, '+
                '"globalItemVarblValText4": null, '+
                '"globalItemVarblValText5": null, '+
                '"globalItemVarblValText6": null, '+
                '"globalItemVarblValText7": null, '+
                '"globalItemVarblValText8": null, '+
                '"globalItemVarblValText9": null, '+
                '"globalItemVarblValText10": null, '+
                '"globalItemVarblValText11": null, '+
                '"greetingCode": null, '+
                '"greetingOptionCode": 0,'+
                '"itemID": "D205",'+
                '"itemVarbleSeqNum1": null, '+
                '"itemVarbleSeqNum2": null, '+
                '"itemVarbleSeqNum3": null, '+
                '"itemVarbleSeqNum4": null, '+
                '"itemVarbleSeqNum5": null, '+
                '"itemVarblValText1": null, '+
                '"itemVarblValText2": null, '+
                '"itemVarblValText3": null, '+
                '"itemVarblValText4": null, '+
                '"itemVarblValText5": null, '+
                '"journeyDescription": null, '+
                '"journeyFundingID": null, '+
                '"journeyID": null, '+
                '"journeyName": null, '+
                '"journeyNumber": null, '+
                '"journeyStepID": 0,'+
                '"languageCode": "E",'+
                '"languageFilterCode": null, '+
                '"mailCategoryCode": null, '+
                '"mailClassCode": null, '+
                '"mediaTypeFilterText": null, '+
                '"objectTypeID": null, '+
                '"phoneOptionCode": null, '+
                '"preferenceObjectID": null, '+
                '"signatureOptionCode": null, '+
                '"staffEmailID": "", '+
                '"stateCode": "25",'+ 
                '"stepNumber": 0,'+
                '"stepTypeCode": 0,'+
                '"targetGroupCode": 0,'+
                '"timingTypeCode": 0,'+
                '"transmissionDate":"2017-07-05T00:00:00.000+0000",'+
                '"status": "Sent", '+
                '"satelliteOffice": false'+
                '}]'+
                '}';
    }
    /**
     * @description buildFailureLeadMessageJson
     * @return  `String`
     */
    public static String buildFailureLeadMessageJson() {
        return '{'+
                '"Result": "Failure",'+
                '"Message": "InvalidInputException: Field agentassociateID is too long or short the length should be 11 chars",'+
                '"LeadMessages": null'+
                '} ';
    }
}