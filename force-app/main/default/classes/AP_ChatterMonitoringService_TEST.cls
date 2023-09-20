/**
  * @name AP_ChatterMonitoringService_TEST
  * @author ITIC
  * @description Test class for AP_ChatterMonitoringService
  */
@isTest(SeeAllData=false)
public class AP_ChatterMonitoringService_TEST {
  /**
   * @description test method to test setup data
   */
	 @testsetup
    public static void testSetupData(){
		CS_TechnicalPlatform__c setupApiKey = new CS_TechnicalPlatform__c(Value__c='TestApiKey', Name='SR_API_KEY');
        CS_TechnicalPlatform__c setupSubCategory = new CS_TechnicalPlatform__c(Value__c='TestSubCategory', Name='SR_CATEGORY');
        List<CS_TechnicalPlatform__c> technicalPlatformCS = new List<CS_TechnicalPlatform__c>();
        technicalPlatformCS.add(setupApiKey);
        technicalPlatformCS.add(setupSubCategory);
        insert technicalPlatformCS;
        CS_SendToSize__c sendToCS = new CS_SendToSize__c(Name='ChatterMonitoring',SendToSize__c =100);
    	insert sendToCS;
    }

	 /**
    * @description Test method to validate exception captured for any status code other than 200
    */
    @isTest
    static void testCalloutException(){
    	String batchId = '12345';
    	Test.startTest();
    	AP_MockHttpResponseGenerator_TEST mockResponse = new AP_MockHttpResponseGenerator_TEST(401,'Unauthorized');
    	Test.setMock(HttpCalloutMock.class, mockResponse);
        String callOut;
        callOut = 'callout:ChatterMonitoringNamedCredential/'+batchId;
        AP_ChatterMonitoringService chatterMonitoringService = new AP_ChatterMonitoringService();

        chatterMonitoringService.getResponseFromService(batchId);
        Test.stopTest();
        List<ExceptionLog__c> log = [Select Class__c,Exception_Message__c from ExceptionLog__c where Class__c='AP_ChatterMonitoringService' order by createdDate desc limit 1 ];
        System.assert(log.get(0).Exception_Message__c!=null, 'Exception message object for log should not be null');
    }

    /**
    * @description Test method to validate exception not captured for any status code other than 200
    */
    @isTest
    static void testCalloutSucess(){
    	String batchId = '12345';
    	Test.startTest();
    	AP_MockHttpResponseGenerator_TEST mockResponse = new AP_MockHttpResponseGenerator_TEST(200,'OK');
    	Test.setMock(HttpCalloutMock.class, mockResponse);
        String callOut;
        callOut = 'callout:ChatterMonitoringNamedCredential/'+batchId;
        AP_ChatterMonitoringService chatterMonitoringService = new AP_ChatterMonitoringService();

        chatterMonitoringService.getResponseFromService(batchId);
        Test.stopTest();
        List<ExceptionLog__c> log = [Select Class__c,Exception_Message__c from ExceptionLog__c where Class__c='AP_ChatterMonitoringService' order by createdDate desc limit 1 ];
        System.assert(log.size()==0, 'size of the log should be equal to 0');
    }
 }