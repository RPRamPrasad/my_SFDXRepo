/**
 * @name SObjectSPIHelper
 * @description reuseable class to initiate SPI check on a record
*/
public without sharing class SObjectSPIHelper {

    @TestVisible private List<SObject> sobjects = new List<SObject>();
    
    /**
     * @name SObjectSPIHelper
     * @description sets the sobjects variable and initiates SPI check 
     * @param sobjects
     */
    public SObjectSPIHelper(List<SObject> sobjects){
        this.sobjects = sobjects;
        handleSPI();
    }
    
    /**
     * @name handleSPI
     * @description performs the SPI check 
     * @param List<SObject>
     */
    @TestVisible
    private void handleSPI(){ 
        if(!this.sobjects.isEmpty()){
            AP_SPISecurityManager spiSecurity = new AP_SPISecurityManager();
       		spiSecurity.handle(sobjects);  
        }
    }
}