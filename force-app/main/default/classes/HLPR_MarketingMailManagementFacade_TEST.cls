/*
* @Author: TrailBlazers
* @description Unit test for the facade that consumes TP Service MarketingMailManagement
* Class Under Test: HLPR_MarketingMailManagementFacade
*/
@isTest(SeeAllData=false)
private class HLPR_MarketingMailManagementFacade_TEST {
    
    private static HLPR_MarketingMailManagementFacade facade = new HLPR_MarketingMailManagementFacade();
    
    /**
    * @description Setup method used for building test data
    */
    @testSetup
    public static void testSetupData() {
        CS_EnvironmentURLCustomSetting__c csEnvUrl = new CS_EnvironmentURLCustomSetting__c(Name='MARKETING_MAIL_MANAGEMENT_SR_API_KEY', Value__c='test');
        insert csEnvUrl;
    }
    
    @isTest
    private static void retrieveDoNotSolicitMailIndicatorTrue() {
        Test.setMock(WebServiceMock.class, new UTIL_MockJourneyMail.MockMailTrue()); 
        Test.startTest();
        System.assertEquals(true, facade.retrieveDoNotSolicitMailIndicator('zzzz'),'DoNotSolicitMailIndicator did not match');
        Test.stopTest();
    }
    
    @isTest
    private static void retrieveDoNotSolicitMailIndicatorFalse() {
        Test.setMock(WebServiceMock.class, new UTIL_MockJourneyMail.MockMailFalse()); 
        Test.startTest();
        System.assertEquals(false, facade.retrieveDoNotSolicitMailIndicator('zzzz'),'DoNotSolicitMailIndicator did not match');
        Test.stopTest();
    }
    
    @isTest
    private static void retrieveDoNotSolicitEmailIndicatorBothFalse() {
        Test.setMock(WebServiceMock.class, new UTIL_MockJourneyMail.MockEmailBothFalse()); 
        Test.startTest();
        Map<String, Boolean> response = facade.retrieveDoNotSolicitEmailIndicator('ftgzvwxglwzpzrvm@NOEMAIL.com');
        System.assertEquals(false, response.get('doNotSolicitServiceIndicator'),'DoNotSolicitServiceIndicator did not match');
        System.assertEquals(false, response.get('doNotSolicitMarketingIndicator'),'DoNotSolicitMarketingIndicator did not match');
        Test.stopTest();
    } 
    
    @isTest
    private static void retrieveDoNotSolicitEmailIndicatorBothTrue() {
        Test.setMock(WebServiceMock.class, new UTIL_MockJourneyMail.MockEmailBothTrue()); 
        Test.startTest();
        Map<String, Boolean> response = facade.retrieveDoNotSolicitEmailIndicator('ftgzvwxglwzpzrvm@NOEMAIL.com');
        System.assertEquals(true, response.get('doNotSolicitServiceIndicator'),'DoNotSolicitServiceIndicator did not match');
        System.assertEquals(true, response.get('doNotSolicitMarketingIndicator'),'DoNotSolicitMarketingIndicator did not match');
        Test.stopTest();
    } 
    
    @isTest
    private static void retrieveDoNotSolicitEmailIndicatorServiceFalseMarketingTrue() {
        Test.setMock(WebServiceMock.class, new UTIL_MockJourneyMail.MockEmailServiceFalseMarketingTrue()); 
        Test.startTest();
        Map<String, Boolean> response = facade.retrieveDoNotSolicitEmailIndicator('ftgzvwxglwzpzrvm@NOEMAIL.com');
        System.assertEquals(false, response.get('doNotSolicitServiceIndicator'),'DoNotSolicitServiceIndicator did not match');
        System.assertEquals(true, response.get('doNotSolicitMarketingIndicator'),'DoNotSolicitMarketingIndicator did not match');
        Test.stopTest();
    } 
    
    @isTest
    private static void retrieveDoNotSolicitEmailIndicatorServiceTrueMarketingFalse() {
        Test.setMock(WebServiceMock.class, new UTIL_MockJourneyMail.MockEmailServiceTrueMarketingFalse()); 
        Test.startTest();
        Map<String, Boolean> response = facade.retrieveDoNotSolicitEmailIndicator('ftgzvwxglwzpzrvm@NOEMAIL.com');
        System.assertEquals(true, response.get('doNotSolicitServiceIndicator'),'DoNotSolicitServiceIndicator did not match');
        System.assertEquals(false, response.get('doNotSolicitMarketingIndicator'),'DoNotSolicitMarketingIndicator did not match');
        Test.stopTest();
    } 
    
    @isTest
    private static void retrieveDoNotSolicitEmailIndicatorThrowsError() {
        Test.setMock(WebServiceMock.class, new UTIL_MockJourneyMail.MockEmailThrowsError()); 
        Test.startTest();
        try {
            facade.retrieveDoNotSolicitEmailIndicator('ftgzvwxglwzpzrvm@NOEMAIL.com');
        } catch (Exception e) {
            System.assertEquals(System.Label.CL_SELECTMAILER_MMM_SERVICE_FAIL, e.getMessage(),'Exception Message did not match');
        }
        Test.stopTest();
    } 

    @isTest
    private static void retrieveDoNotSolicitMailIndicatorThrowsError() {
        Test.setMock(WebServiceMock.class, new UTIL_MockJourneyMail.MockMailThrowsError()); 
        Test.startTest();
        System.assertEquals(true, facade.retrieveDoNotSolicitMailIndicator('zzzzzz'),'DoNotSolicitMailIndicator did not match');
        Test.stopTest();
    } 
}