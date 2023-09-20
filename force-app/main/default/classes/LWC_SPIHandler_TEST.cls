@isTest
(seeAllData=false)
public class LWC_SPIHandler_TEST {
    /**
     * @description checkForSpiTest
     */
    @isTest
    public static void checkForSpiTest(){
    	String comments = 'SSN 678-78-9345';
        String textlable = 'comments';
        String errorMsg = '';

        User sysAdminUser = TestDataFactory_User.getSysAdminUser();
        System.runAs(sysAdminUser){
        	UTIL_SPITestDataCreation_TEST.createSPISecurityControlForUSSSNPatternPreventOnBreach();
        	List<SPI_Security_Control__c> spiSecurityControls = [Select Regex_Pattern__c from SPI_Security_Control__c];
        	System.assert(spiSecurityControls.size()==1,'Size of spiSecurityControls should be 1');
        	UTIL_SPITestDataCreation_TEST.createSPIDataPreventionFieldsForCase(); 
            UTIL_SPITestDataCreation_TEST.createSPIChunkSize();
            errorMsg = LWC_SPIHandler.handleSpi(comments,textlable);
            System.assertEquals('Sensitive Personal Information (SPI) is not allowed to be entered in the comments field.', errorMsg,'Expected value is Sensitive Personal Information (SPI) is not allowed to be entered in the comments field. but actual value is '+errorMsg);
    	}
    }
}
