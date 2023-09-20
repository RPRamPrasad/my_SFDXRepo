/**
 * @description Test Class for the ChangeDueDate Class.
 *
 * @author Jacob Ira (VAB2Q2)
 * @version 1.0, 7/27/23
 * @see ChangeDueDate 
 * @since 1.0
*/
@isTest
public class ChangeDueDate_Test {
    
    /**
     * @description setup
     */
    @testSetup
    public static void setup(){
        User systemAdminUser = new User(ProfileId=[SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
                                        LastName='systemAdmin',
                                        UserName='systemAdminTest@statefarm.com',
                                        Alias='VAD00X',
                                        Email='testsystemadminuser@statefarm.com',
                                        TimeZoneSidKey='Europe/London',
                                        State_Agent_Code__c = '18-1AED',
                                        LocaleSidKey='en_US',
                                        EmailEncodingKey='UTF-8',
                                        LanguageLocaleKey='en_US');
        insert systemAdminUser;
        UTIL_SetFSCCustomSettings_TEST.setFSCSettings();
        AccountOwnerSystemUserCustomSetting__c sysAdminUserIdSetting = UTIL_AccountOwner_TEST.buildAccountOwnerCS(systemAdminUser.id);            
        insert sysAdminUserIdSetting;
        
        System.runAs(systemAdminUser){
            Id individualRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosBydeveloperName().get('Individual').getRecordTypeId();
            Account individualAccount = new Account(recordTypeId=individualRecordTypeId, FirstName='ACC_FIRST_NAME', LastName='ACC_LAST_NAME', ClientIdentifier__c='SFFSP81LNNN', AllowHousehold__c = false,BillingAddressType__c='US', BillingStreet='1234 Main St', BillingCity='Bloomington', BillingState='IL', BillingPostalCode='61704', BillingCountry='UNITED STATES');
            insert individualAccount;
            
            
            Billing_Account__c ba1 = new Billing_Account__c(AccountNumber__c = '0123456789', BillAccountDueDate__c = Date.newInstance(2022,01,01), Name = '0123456789', SourceSystemIdentifier__c = '0123456789');
            insert ba1;
            
            Billing_Participant__c bp = new Billing_Participant__c(Name = '0123456789', BillingAccountID__c = ba1.id, SourceSystemIdentifier__c = '0123456789', ParticipantAccountId__c = individualAccount.Id);
            insert bp;
            

            User agentOffice = TestDataFactory_User_Wrapper.generateAgentUser('aliis', '12345678912');
            agentOffice.LastName = 'User, 18-1AED-Office';
            agentOffice.State_Agent_Code__c = '18-1AED';
            agentOffice = TestDataFactory_User.insertUser(agentOffice);
            
        }
    }
    
    @isTest
    static void successfulDateChange(){
        List<String> baValue = new List<String>();
        List<ChangeDueDate.OutputVariables> outputVariables = new List<ChangeDueDate.OutputVariables>();
        Billing_Account__c ba = [SELECT Id FROM Billing_Account__c WHERE AccountNumber__c = '0123456789'];
        baValue.add(ba.Id+'+6');
        Test.setMock(HttpCalloutMock.class, new SuccessfulChange());
        Test.startTest();
        User systemAdminUser = [SELECT Id FROM User WHERE LastName = 'systemAdmin'];
        System.runAs(systemAdminUser) {
            outputVariables = ChangeDueDate.handleRequest(baValue);
        }
        Test.stopTest();
        System.assert(outputVariables[0].firstMessage.contains('You have successfully changed the due date'),outputVariables[0].firstMessage);
    }
    
    @isTest
    static void errorInTP2(){
        List<String> baValue = new List<String>();
        List<ChangeDueDate.OutputVariables> outputVariables = new List<ChangeDueDate.OutputVariables>();
        Billing_Account__c ba = [SELECT Id FROM Billing_Account__c WHERE AccountNumber__c = '0123456789'];
        baValue.add(ba.Id+'+6');
        Test.setMock(HttpCalloutMock.class, new ServerError());
        Test.startTest();
        outputVariables = ChangeDueDate.handleRequest(baValue);
        Test.stopTest();
        System.assert(outputVariables[0].firstMessage.contains('An Error occured because of the following reason:'),outputVariables[0].firstMessage);
    }
    
    @isTest
    static void errorInStatusCode(){
        List<String> baValue = new List<String>();
        List<ChangeDueDate.OutputVariables> outputVariables = new List<ChangeDueDate.OutputVariables>();
        Billing_Account__c ba = [SELECT Id FROM Billing_Account__c WHERE AccountNumber__c = '0123456789'];
        baValue.add(ba.Id+'+6');
        Test.setMock(HttpCalloutMock.class, new ErrorStatusCode());
        Test.startTest();
        outputVariables = ChangeDueDate.handleRequest(baValue);
        Test.stopTest();
        System.assert(outputVariables[0].firstMessage.contains('Error ->'),outputVariables[0].firstMessage);
    }
    
    private class SuccessfulChange implements HttpCalloutMock {
        /**
         * @description respond
         * @param request 
         * @return  `HTTPResponse`
         */
        public HTTPResponse respond(HTTPRequest request) {   
            HttpResponse response = new HttpResponse();
            response.setBody('{"statusCode":200,"message":"SUCCESS"}');
            response.setStatusCode(200);
            response.setStatus('Created');
            return response;        
        }
    }
    
    private class ServerError implements HttpCalloutMock {
        /**
         * @description respond
         * @param request 
         * @return  `HTTPResponse`
         */
        public HTTPResponse respond(HTTPRequest request) {   
            HttpResponse response = new HttpResponse();
            response.setBody('{"statusCode":500,"message":"An Error has Occured"}');
            response.setStatusCode(200);
            response.setStatus('Created');
            return response;        
        }
    }
    
    private class ErrorStatusCode implements HttpCalloutMock {
        /**
         * @description respond
         * @param request 
         * @return  `HTTPResponse`
         */
        public HTTPResponse respond(HTTPRequest request) {   
            HttpResponse response = new HttpResponse();
            response.setBody('{"statusCode":500,"message":"FAILED"}');
            response.setStatusCode(500);
            response.setStatus('Created');
            return response;        
        }
    }
}