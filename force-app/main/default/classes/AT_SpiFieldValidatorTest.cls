/**
* Author : Team Kraken
* Date Created : 9/5/2018
* @description : test for class that retrieves OData for AT_StateFarmProducts lightning component
* Version : 1.0
*/
@isTest(SeeAllData=false)
public class AT_SpiFieldValidatorTest {

    private static User nonAPIUser;
    private static User apiUser;

    /**
    * @description Setup method used for building test data (must be called at beginning of test)
    * @name setUp
    */        
    public static void setUp(){
        nonAPIUser = UTIL_UserProvisioning_TEST.createNonAPITestUser();
        apiUser = UTIL_UserProvisioning_TEST.createAPITestUser();
    }

    @isTest
    private static void testValidateValid() {
        
        Test.startTest();
        String returnValue = AT_SpiFieldValidator.validate('this is a test 1234 for a field with no SPI inside it');
        Test.stopTest();
        
        System.assertEquals('VALID', returnValue,'Expected value is VALID, but actual value is '+returnValue);
    }
    @isTest
    private static void testValidateInvalid() {
        
        Test.startTest();
         String returnValue = AT_SpiFieldValidator.validate('123-45-6789');
        Test.stopTest();
        
        System.assertEquals('INVALID', returnValue,'Expected value is INVALID, but actual value is '+returnValue);
    }
    @isTest
    private static void testValidateValidLineBreak() {
        
        Test.startTest();
        String returnValue = AT_SpiFieldValidator.validate('this is a test 1234 for a field\n with no SPI inside it');
        Test.stopTest();
        
        System.assertEquals('VALID', returnValue,'Expected value is VALID, but actual value is '+returnValue);
    }
    @isTest
    private static void testValidateValidLineBreakCr() {
        
        Test.startTest();
        String returnValue = AT_SpiFieldValidator.validate('this his is a blah blah blah test 1234 forhis is a blah blah blah test 1234 forhis is a blah blah blah test 1234 forhis is a blah blah blah test 1234 forhis is a blah blah blah test 1234 forhis is a blah blah blah test 1234 forhis is a blah blah blah test 1234 forhis is a blah blah blah test 1234 foris a blah blah blah test 1234 for a field\n\r with no SPI inside it');
        Test.stopTest();
        
        System.assertEquals('VALID', returnValue,'Expected value is VALID, but actual value is '+returnValue);
    }
}