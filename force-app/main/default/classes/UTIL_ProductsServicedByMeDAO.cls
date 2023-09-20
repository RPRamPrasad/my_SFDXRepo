/**
 *  @Author Loco Motivated 
 *  @description UTIL_ProductsServicedByMeDAO
 *  @CreateDate 04/18/2018
 *  @Description Utility Method for Products Serviced By Me
 *  @Version 1.0
 */
public without sharing class UTIL_ProductsServicedByMeDAO {
	private UTIL_ProductsServicedByMeDAO(){
        AP_LogHolder logHolder = new AP_LogHolder();
        logHolder.info('UTIL_ProductsServicedByMeDAO', 'start time of execution: ' + System.now());
        logHolder.writeToLogExceptionObject();
    }
    
   /**
    * Takes the List<ProductsServicedByMe__c> and deletes from SFDC datastore
    * @description deleteProductsServicedByMe
    * @param productsServicedByMeList List<ProductsServicedByMe__c> - Products Serviced By Me to be deleted (Id for each is REQUIRED)
    */    
    public static void deleteProductsServicedByMe(List<ProductsServicedByMe__c> productsServicedByMeList) {   
        if(productsServicedByMeList != null && !productsServicedByMeList.isEmpty()) {
            delete productsServicedByMeList;
        }
    }
    
    /**
    * Takes the List<ProductsServicedByMe__c> and updates from SFDC datastore
    * @description updateProductsServicedByMe
    * @param productsServicedByMeList List<ProductsServicedByMe__c> 
    */ 
    public static void updateProductsServicedByMe(List<ProductsServicedByMe__c> productsServicedByMeList) {
        if(productsServicedByMeList != null && !productsServicedByMeList.isEmpty()) {
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.UPDATABLE, productsServicedByMeList);
            update securityDecision.getRecords();
        }
    } 
}