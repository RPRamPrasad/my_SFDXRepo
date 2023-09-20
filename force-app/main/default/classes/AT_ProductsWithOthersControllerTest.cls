/**
* Author : Team Kraken
* Date Created : 9/7/2018
* @description : test for class that retrieves OData for AT_ProductsWithOthersCompetitors lightning component
* Version : 1.0
*/
@isTest
(SeeAllData=false)
public class AT_ProductsWithOthersControllerTest {
    
    public static String testClientId = '333';
    
    @isTest
    private static void testGetProductsWithOthersHappyPath() {
        ProductsWithOthersCompetitors__x pwc = new ProductsWithOthersCompetitors__x();
        pwc.ExternalId = 'ExternalID01';
        pwc.StateAgentCode__c = '12-1234';
        pwc.CarrierName__c = 'GEICO';
        pwc.ClientID__c = testClientId;
        pwc.ExpirationDate__c = Date.today();
        pwc.ExternalAgreementId__c = 'ExternalAgr01';
        pwc.ProductComments__c = 'Comments01';
        pwc.ProductLine__c = 'Fire';
        pwc.ProductType__c = 'Home Owners';
        ProductsWithOthersCompetitors__x pwoc = createProductsWithOthersCompetitors(pwc);
        AT_ProductsWithOthersController.mockProductsList.add(pwoc);
        UTIL_ReturnClientIdTest.setupTestClientIdQuery(testClientId);
        AT_ProductsWithOthersController.loggedInProfile = Label.CL_ATM_Profile;
        
        Test.startTest();
        List<AT_ProductsWithOthersController.ProductsWithOthersWrapper> testList = AT_ProductsWithOthersController.getProductsWithOthersList('1234');
        Test.stopTest();
        
        System.assert(testList.size() == 1, 'Policy list should have size 1');
        System.assert(testClientId == testList.get(0).clientID, 'Client ID in first policy in list should match param');
    }
    
    @isTest
    private static void testGetProductsWithOthersHappyPathWithNoExpirationDateAndUnformattedStateAgentCode() {
        ProductsWithOthersCompetitors__x pwc = new ProductsWithOthersCompetitors__x();
        pwc.ExternalId = 'ExternalID01';
        pwc.StateAgentCode__c = '121234';
        pwc.CarrierName__c = 'GEICO';
        pwc.ClientID__c = testClientId;
        pwc.ExpirationDate__c = null;
        pwc.ExternalAgreementId__c = 'ExternalAgr01';
        pwc.ProductComments__c = 'Comments01';
        pwc.ProductLine__c = 'Fire';
        pwc.ProductType__c = 'Home Owners';
        ProductsWithOthersCompetitors__x pwoc = createProductsWithOthersCompetitors(pwc);
        AT_ProductsWithOthersController.mockProductsList.add(pwoc);
        UTIL_ReturnClientIdTest.setupTestClientIdQuery(testClientId);
        AT_ProductsWithOthersController.loggedInProfile = Label.CL_ATM_Profile;
        
        Test.startTest();
        List<AT_ProductsWithOthersController.ProductsWithOthersWrapper> testList = AT_ProductsWithOthersController.getProductsWithOthersList('1234');
        Test.stopTest();
        
        System.assert(testList.size() == 1, 'Policy list should have size 1');
        System.assert(testClientId == testList.get(0).clientID, 'Client ID in first policy in list should match param');
        System.assert('' == testList.get(0).expirationDate, 'Expiration date in first policy in list should be blank');
        System.assert(testList.get(0).stateAgentCode.contains('-'), 'State agent code in first policy in list should be formatted');
    }
    
    @isTest
    private static void testGetProductsWithOthersHappyPathError() {
        ProductsWithOthersCompetitors__x pwc = new ProductsWithOthersCompetitors__x();
        pwc.ExternalId = 'ExternalID01';
        pwc.StateAgentCode__c = 'ERROR';
        pwc.CarrierName__c = 'GEICO';
        pwc.ClientID__c = testClientId;
        pwc.ExpirationDate__c = Date.today();
        pwc.ExternalAgreementId__c = 'ExternalAgr01';
        pwc.ProductComments__c = 'Comments01';
        pwc.ProductLine__c = 'Fire';
        pwc.ProductType__c = 'Home Owners';
        ProductsWithOthersCompetitors__x pwoc = createProductsWithOthersCompetitors(pwc);
        AT_ProductsWithOthersController.mockProductsList.add(pwoc);
        UTIL_ReturnClientIdTest.setupTestClientIdQuery(testClientId);
        AT_ProductsWithOthersController.loggedInProfile = Label.CL_ATM_Profile;
        Test.startTest();
        try {  
         AT_ProductsWithOthersController.getProductsWithOthersList('1234');
        System.assertNotEquals('should not get to this line', 'should not get to this line', 'Test should not reach this assert');
        }
        catch(Exception e) {
            System.AssertEquals('Script-thrown exception', e.getMessage(), 'Exception thrown during test should match message');
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testGetProductsWithOthersWithNoQueryResults() {
        UTIL_ReturnClientIdTest.setupTestClientIdQuery(testClientId);
         AT_ProductsWithOthersController.loggedInProfile = Label.CL_ATM_Profile;
        
        Test.startTest();
        List<AT_ProductsWithOthersController.ProductsWithOthersWrapper> testList = AT_ProductsWithOthersController.getProductsWithOthersList('1234');
        Test.stopTest();
        
        System.assert(testList.size() == 0, 'policy list returned should be empty');
    }
    
    /**
     * @description Method creates PWOC test data
     * @param sampleBuild
     * @return is PWOC policy object
     */
    public static ProductsWithOthersCompetitors__x createProductsWithOthersCompetitors(ProductsWithOthersCompetitors__x sampleBuild){
        ProductsWithOthersCompetitors__x getProductsWithOthersCompetitors = 
            new ProductsWithOthersCompetitors__x(ExternalId = sampleBuild.ExternalId, 
                                                 StateAgentCode__c = sampleBuild.StateAgentCode__c, 
                                                 CarrierName__c = sampleBuild.CarrierName__c, 
                                                 ClientID__c = sampleBuild.ClientID__c, 
                                                 ExpirationDate__c = sampleBuild.ExpirationDate__c, 
                                                 ExternalAgreementId__c = sampleBuild.ExternalAgreementId__c, 
                                                 ProductComments__c = sampleBuild.ProductComments__c, 
                                                 ProductLine__c = sampleBuild.ProductLine__c, 
                                                 ProductType__c = sampleBuild.ProductType__c);
        return getProductsWithOthersCompetitors;
    }
    
    @isTest
    public static void testcanViewNewButtonTrue() {
        AT_ProfileAccess.mockCustomerSummaryView  = new CS_CustomerSummaryView__c(
        Billing_Summary__c=False,           //access is controlled by tab filtering
        Claim_Summary__c=False,             //access is controlled by tab filtering
        ABS_Activities_Summary__c=False,    //access is controlled by tab filtering
        ProductsServicedByMe__c=False, 
        ProductsWithOthers__c=False, 
        Life_Asc_Policy_View__c=False, 
        Life_Policy_View__c=False, 
        AutoLoadProductsOnGroupingPage__c = False, 
        AutoLoadProductsOnAccountPage__c = False, 
        Phoenix_Policy_View__c=False, 
        Claims_Detail__c=False, 
        Create_New_SFPP__c=False, 
        Policy_Transactions__c=False, 
        StateFarm_Products__c=False, 
        Create_New_PSBM__c=False, 
        Create_New_PWOC__c=True,
        View_CreateTask__c=False);
        
        Test.startTest();
        Boolean returnValue = AT_ProductsWithOthersController.canViewNewButton();
        Test.stopTest();
        
        System.assertEquals(true, returnValue, 'Boolean New button access value should be true');
    }
    
}