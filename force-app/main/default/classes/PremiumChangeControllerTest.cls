/**
* @name PremiumChangeControllerTest
* @author Team PCU Orca
* @createDate 07/12/2023
* @description The Apex test class for PremiumChangeController class.
*/
@isTest
(seeAllData=false)
public class PremiumChangeControllerTest {

    private static final Integer ERROR_STATUS_CODE = 404;
	private static final String ERROR_RESPONSE_MESSAGE = 'Unable to find Dv information for given policy #';
    private static final String ERROR_RESPONSE = '{ "responseStatus" : ' + ERROR_STATUS_CODE  + ',"errorMsg" :' + ERROR_RESPONSE_MESSAGE + '}';
    private static final String SUCCESS_RESPONSE = '{"agreementSourceSystemCode":1,"policyNumber":"535 4281-D01-75E","lob":"A","applicationType":"ECRM","agreementAccessKey":"7565354281","loggedInUser":"SFDC_USER_1_07_Tech_Supp"}';


    /**
    * @description testSetup method to create insurance policy records
    */
    @testSetup 
    public static void setup() {
        UTIL_CaseTestData.setUpSystemUserRecordOwnerOnly();
        
        System.runAs(UTIL_CaseTestData.getSysAdminUser()){
            InsurancePolicy ipSuccess = new InsurancePolicy();
            ipSuccess = setNameForInsurancePolicyRecord('MOCKPOLICY', 'CLIENTID1', ipSuccess);
            insert ipSuccess;

            InsurancePolicy ipException = new InsurancePolicy();
            ipException = setNameForInsurancePolicyRecord('EXCEPTIONMOCKPOLICY', 'CLIENTID2', ipException);
            insert ipException;
        }
    }

    private static InsurancePolicy setNameForInsurancePolicyRecord(String policyName, String clientId, InsurancePolicy record) {
        Account namedInsuredAccount = TestDataFactory_Account.createIndividualCustomer('John Smith', clientId);
        TestDataFactory_Account.insertAccount(namedInsuredAccount);

        record.EffectiveDate = system.today().addDays(10);
        record.RenewalDate = system.today().addDays(10);
        record.Name = policyName;
        record.AgreSourceSysCd__c = '1';
        record.ProdLineCd__c = 'A';
        record.AgreAccessKey__c = '7565354281';
        record.NameInsuredId = namedInsuredAccount.Id;
        return record;
    }
    
    /**
    * @description mock http callout class to simulate a premium change callout response
    */
    public class PremiumChangeCalloutMock implements HttpCalloutMock {
        /**
        * @description mock response for premium change callout
        * @param req
        * @return HttpResponse string
        */
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            String reqBody = req.getBody();
            PremiumChangeController.BodyPayload parsedBody = (PremiumChangeController.BodyPayload)Json.deserialize(reqBody, PremiumChangeController.BodyPayload.class);
            if(parsedBody.policyNumber == 'MOCKPOLICY') {
                res.setStatusCode(200);
                res.setBody(SUCCESS_RESPONSE);
            } else {
                res.setStatusCode(404);
                throw new AuraHandledException(ERROR_RESPONSE);
            }
            return res;
        }
    }

    @isTest
    private static void testAccessTokenCall(){
        System.runAs(UTIL_CaseTestData.getSysAdminUser()){
            String token = PremiumChangeController.getAzureToken();
            System.assertEquals('fakeToken', token, 'problem with getting the fake token mock');
        }
    }

    @isTest
    private static void testPremiumChangeSuccessCallout() {
        System.runAs(UTIL_CaseTestData.getSysAdminUser()){
            InsurancePolicy ip = [SELECT Id FROM InsurancePolicy WHERE Name = 'MOCKPOLICY'];
            String policyId = ip.Id;

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new PremiumChangeCalloutMock());
            String response = PremiumChangeController.callPremiumChange(policyId);
            Test.stopTest();

            System.assertEquals(SUCCESS_RESPONSE, response, 'Response is invalid');
        }
    }

    @isTest
    private static void testPremiumChangeExceptionCallout() {
        System.runAs(UTIL_CaseTestData.getSysAdminUser()){
            InsurancePolicy ip = [SELECT Id FROM InsurancePolicy WHERE Name = 'EXCEPTIONMOCKPOLICY'];
            String policyId = ip.Id;

            Test.startTest();

            List<ExceptionLog__c> exceptionLogBefore = [SELECT id FROM ExceptionLog__c WHERE Class__c = 'PremiumChangeController'];
            System.assert(exceptionLogBefore.isEmpty(), 'Premium Change exception logs were not empty before');

            Test.setMock(HttpCalloutMock.class, new PremiumChangeCalloutMock());
            try {
                PremiumChangeController.callPremiumChange(policyId);
            }
            catch (Exception e){
                String response = ERROR_RESPONSE;
                System.assertEquals(ERROR_RESPONSE, response, 'Call is not successful');
            }

            List<ExceptionLog__c> exceptionLogAfter = [SELECT id FROM ExceptionLog__c WHERE Class__c = 'PremiumChangeController'];
            System.assert(!exceptionLogAfter.isEmpty(), 'No Premium Change Exception Occurred');
            Test.stopTest();
        }
	}

}