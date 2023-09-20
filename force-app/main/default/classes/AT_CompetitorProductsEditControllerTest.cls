/**
* Author : Team Kraken
* Date Created : 9/7/2018
* @description : test for class that retrieves OData for AT_ProductsWithOthersCompetitors lightning component
* Version : 1.0
*/
/* @Refactor
 * @Team - Incognito
 * @date modified - 19/08/2022
 * @description - Reduced duplicated code
 * @version - 2.0
 */
    
    @isTest
    (SeeAllData=false)
    public class AT_CompetitorProductsEditControllerTest {
    
   /* @Refactor
    * @method- returnWrapperPdt
    * @date modified - 19/08/2022
    * @return - AT_CompetitorProductsEditController.AT_CompetitorProductsEditControllerWrapperClass
    * @description -   method used for return wrapper date of type AT_CompetitorProductsEditController.AT_CompetitorProductsEditControllerWrapperClass
    */
    private static AT_CompetitorProductsEditController.AT_CompetitorProductsEditControllerWrapperClass returnWrapperPdt() {
        AT_CompetitorProductsEditController.AT_CompetitorProductsEditControllerWrapperClass wrap = new AT_CompetitorProductsEditController.AT_CompetitorProductsEditControllerWrapperClass();
        wrap.recordId = 'recordId';
        wrap.clientId = 'clientId';
        wrap.productComments = 'productComments';
        wrap.carrierName = 'carrierName';
        wrap.externalAgreementId = 'externalAgreementId';
        wrap.productLine = 'productLine';
        wrap.productType = 'productType';
        wrap.stateAgentCode = 'stateAgentCode';
        wrap.expirationDateString = '2018-10-30';
        return wrap;
    } 
   /* @Refactor
    * @method- getWrapperPdt
    * @date modified -  19/08/2022
    * @return - AT_CompetitorProductsEditController.AT_CompetitorProductsEditControllerWrapper
    * @description -   method used for return wrapper date of type AT_CompetitorProductsEditController.AT_CompetitorProductsEditControllerWrapperClass
    */
    private static AT_CompetitorProductsEditController.AT_CompetitorProductsEditControllerWrapper getWrapperPdt() {
        AT_CompetitorProductsEditController.AT_CompetitorProductsEditControllerWrapper wrap = new AT_CompetitorProductsEditController.AT_CompetitorProductsEditControllerWrapper();
        wrap.comments = 'productComments';
        wrap.carrierName = 'carrierName';
        wrap.productLine = 'productLine';
        wrap.productType = 'productType';
        wrap.expirationDateString = '2018-10-30';
        wrap.agent = 'agent';
        wrap.accountRecordId = 'accountRecordId';
        return wrap;
    }
  
    @isTest
    private static void testSaveCompetitorProductsHappyPath() {
        Test.startTest();
        Database.SaveResult sr = (Database.SaveResult)
            JSON.deserialize('{"success":true,"id":"0013000000abcde"}', Database.SaveResult.class);
        AT_CompetitorProductsEditController.mockResult = sr;
        /* @Refactor
         * callig returnWrapperPdt()
         */
        Boolean resultValue = AT_CompetitorProductsEditController.saveCompetitorProducts(JSON.serialize(returnWrapperPdt()));
        Test.stopTest();
        System.assertEquals(resultValue,true,'Expected Value is'+resultValue+', but actual is true');
    }        
    
    @isTest
    private static void testSaveCompetitorProductsSadPath() {
        Test.startTest();
        Database.SaveResult sr = (Database.SaveResult)
            JSON.deserialize('{"success":false,"errors":[{"message":"You cannot do this...","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}', Database.SaveResult.class);
        AT_CompetitorProductsEditController.mockResult = sr;
         /* @Refactor
          * calling returnWrapperPdt()
          */
        Boolean resultValue = AT_CompetitorProductsEditController.saveCompetitorProducts(JSON.serialize(returnWrapperPdt()));
        Test.stopTest();
        System.assertEquals(resultValue,false,'Expected Value is'+resultValue+', but actual is false');
    }        
    
    @isTest
    private static void testSaveCompetitorProductsNullExpDateCmnts() {
        Test.startTest();
        Database.SaveResult sr = (Database.SaveResult)
            JSON.deserialize('{"success":true,"id":"0013000000abcde"}', Database.SaveResult.class);
        AT_CompetitorProductsEditController.mockResult = sr;
        AT_CompetitorProductsEditController.AT_CompetitorProductsEditControllerWrapperClass wrap = new AT_CompetitorProductsEditController.AT_CompetitorProductsEditControllerWrapperClass();
        wrap.recordId = 'recordId';
        wrap.clientId = 'clientId';
        wrap.productComments = null;
        wrap.carrierName = 'carrierName';
        wrap.externalAgreementId = 'externalAgreementId';
        wrap.productLine = 'productLine';
        wrap.productType = 'productType';
        wrap.stateAgentCode = 'stateAgentCode';
        wrap.expirationDateString = null;
        Boolean resultValue = AT_CompetitorProductsEditController.saveCompetitorProducts(JSON.serialize(wrap));
        Test.stopTest();
        System.assertEquals(resultValue,true,'Expected Value is'+resultValue+', but actual is true');
    }        
    
    @isTest
    private static void testCreateCompetitorProductHappyPath() {
        Test.startTest();
        Database.SaveResult sr = (Database.SaveResult)
            JSON.deserialize('{"success":true,"id":"0013000000abcde"}', Database.SaveResult.class);
        AT_CompetitorProductsEditController.mockResult = sr;
        /* @Refactor
         * calling getWrapperPdt
         */
        String resultValue = AT_CompetitorProductsEditController.createCompetitorProduct(JSON.serialize(getWrapperPdt()));         
        Test.stopTest();
        System.assertNotEquals(null,resultValue,'Expected Result Value is null, but actual is'+resultValue);
    }        
    
    @isTest
    private static void testCreateCompetitorProductSadPath() {
        Test.startTest();
        Database.SaveResult sr = (Database.SaveResult)
            JSON.deserialize('{"success":false,"errors":[{"message":"You cannot do this...","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}', Database.SaveResult.class);
        AT_CompetitorProductsEditController.mockResult = sr;
        /* @Refactor
         * calling getWrapperPdt()
         */
        String resultValue = AT_CompetitorProductsEditController.createCompetitorProduct(JSON.serialize(getWrapperPdt()));         
        Test.stopTest();
        System.assertEquals(null,resultValue,'Expected Result Value is null, but actual is'+resultValue);
    }        
    
    @isTest
    private static void testCreateCompetitorProductNullExpDateCmnts() {
        Test.startTest();
        Database.SaveResult sr = (Database.SaveResult)
            JSON.deserialize('{"success":true,"id":"0013000000abcde"}', Database.SaveResult.class);
        AT_CompetitorProductsEditController.mockResult = sr;
        AT_CompetitorProductsEditController.AT_CompetitorProductsEditControllerWrapper wrap = new AT_CompetitorProductsEditController.AT_CompetitorProductsEditControllerWrapper();
        wrap.comments = null;
        wrap.carrierName = 'carrierName';
        wrap.productLine = 'productLine';
        wrap.productType = 'productType';
        wrap.expirationDateString = null;
        wrap.agent = 'agent';
        wrap.accountRecordId = 'accountRecordId';
        String resultValue = AT_CompetitorProductsEditController.createCompetitorProduct(JSON.serialize(wrap));         
        Test.stopTest();
        
        System.assertNotEquals(null,resultValue,'Expected Result Value is null, but actual is'+resultValue);
    }     
    @isTest
    private static void testValidateField() {
        Test.startTest();
        String resultValue = AT_CompetitorProductsEditController.validateField('productComments');         
        Test.stopTest();
        System.assertEquals(resultValue,'VALID','Expected value is'+resultValue+', but actual is VALID');
    }        
    
    @isTest
    private static void testCheckIfNonAgencyUserTrue() {
        AT_CompetitorProductsEditController.loggedInProfile = Label.CL_Agent_Profile;
        Test.startTest();
        Boolean resultValue = AT_CompetitorProductsEditController.checkIfNonAgencyUser();         
        Test.stopTest();
        System.assertEquals(false,resultValue,'Expected Result Value is false, but actual is'+resultValue);
    }        
    
    @isTest
    private static void testCheckIfNonAgencyUserFalse() {
        AT_CompetitorProductsEditController.loggedInProfile = Label.CL_TechSupport_Profile;
        Test.startTest();
        Boolean resultValue = AT_CompetitorProductsEditController.checkIfNonAgencyUser();         
        Test.stopTest();
        System.assertEquals(true, resultValue,'Expected Result Value is true, but actual is'+resultValue);
    }        
    
    @isTest
    private static void testFormatStateAgentCode() {
        AT_CompetitorProductsEditController.loggedInProfile = Label.CL_TechSupport_Profile;
        Test.startTest();
        String resultValue = AT_CompetitorProductsEditController.formatStateAgentCode('123456');         
        Test.stopTest();
        System.assertEquals('123456', resultValue,'Expected Result Value is 123456, but actual value is'+resultValue);
    }        
    
}