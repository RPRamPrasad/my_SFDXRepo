/**
* Team : ITIC
* Date Created : 4/12/2021
* @description : LWC_SPIHandler AuraEnabled method that uses AP_SPISecurityValidator to check free form text for spi in LWC components.
* Version : 1.0
*/
public with sharing class LWC_SPIHandler {
    /**
     * @description handleSpi
     * @param comments 
     * @param textlabel 
     * @return  `string`
     */
    @AuraEnabled
    public static string handleSpi(String comments, String textlabel){
        AP_SPISecurityValidator spiSecurity = new AP_SPISecurityValidator();
        return spiSecurity.handle(comments, textlabel);
    }
}
