@isTest(seeAllData = false)
public with sharing class CustomSettingEnvironmentUrlCtl_Test {
    
    @isTest	
    private static void testGetUrl() {
        String urlName = 'Test_Env_URL';
        Test.startTest();
   	    createCustomSetting(urlName);
        CS_EnvironmentURLCustomSetting__c csUrl = CS_EnvironmentURLCustomSetting__c.getInstance(urlName);
        CS_EnvironmentURLCustomSetting__c resultUrl = CustomSettingEnvironmentUrlCtl.getEnvironmentUrl(urlName);
        Test.stopTest();

        System.assertNotEquals(null, resultUrl, 'no url found');
        System.assertEquals(csUrl.Value__c , resultUrl.Value__c, 'test url is incorrect');
    }

    @isTest	
    private static void testGetUrlNone() {
        String urlName = 'Fail_Test_URL';
        Test.startTest();
        try {
            CustomSettingEnvironmentUrlCtl.getEnvironmentUrl(urlName);
        } catch (Exception e) {
            System.assertEquals('No custom setting environment URL record with name of ' + urlName, e.getMessage(), 'did not get correct error message');
        }
        Test.stopTest();
    }

    private static CS_EnvironmentURLCustomSetting__c createCustomSetting(String urlName) {
        CS_EnvironmentURLCustomSetting__c testUrl = new CS_EnvironmentURLCustomSetting__c(Name=urlName,Value__c='https://test.com');
        insert testUrl;
        return testUrl;
    }
}