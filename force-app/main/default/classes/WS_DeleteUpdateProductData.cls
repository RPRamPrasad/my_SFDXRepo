/****************************************************************************************
Name: WS_DeleteUpdateProductData
=========================================================================================
Decription: 
@description - This REST Webservice class resides in Salesforce and will be invoked by
               JAVA webservice Product Retrieval Service developed by Team QuadCore.
This service will perform the below steps 
a) Retrieve the existingdata where status value is true 
b) Delete the data that was retrieved as part of Step a
c) Retrieve the data where status value is False
d) Update the status value from 'FALSE' to 'TRUE'
=========================================================================================
History
-------
VERSION         AUTHOR                    DATE                    DETAIL
1.00            Team QuadCore             05/10/2021              Initial Development
******************************************************************************************/
@RestResource(urlMapping='/productRetrievalServiceUpdate')
global with sharing class WS_DeleteUpdateProductData {
 
    private static final String CLASS_NAME = 'WS_DeleteUpdateProductData';
    private static final String RETRIEVE_METHOD_NAME = 'retrieveProductData';
    private static final String DELETE_METHOD_NAME = 'deleteProductData';
    private static final String UPDATE_METHOD_NAME = 'updateProductData';

    /**
     * @description Driver method that deletes and updates Opportunity Product data
     */
    @HttpGet
    global static void deleteUpdateProductData(){
        Savepoint sp = Database.setSavepoint();
        try{
            List<OpportunityProduct__c> opportunityProductList = retrieveProductData(true);
            deleteProductData(opportunityProductList); //8000
            Boolean updateStatus = updateProductData();//8000
            if(updateStatus){
                HLPR_OpportuntiyProductTrigger.updateProductFieldActiveList();
            }
        }
        catch(Exception dmlExp) {
			Database.rollback(sp);
			throw new ProductRetrievalServiceException(dmlExp.getMessage(), dmlExp);
		}	
    }
    /**
     * @description method that retrieves Opportunity Product info for a given status
     * @param status
     * @return list of Opportunity Products with the given status and that weren't created from the UI
     */
    private static List<OpportunityProduct__c> retrieveProductData(Boolean status){
        List<OpportunityProduct__c> opportunityProductList = new List<OpportunityProduct__c>();
        try{
                opportunityProductList = Security.stripInaccessible(
                AccessType.READABLE,
                [SELECT id from OpportunityProduct__c where status__c= :status and Is_Created_From_UI__c = false]).getRecords();
        }              
        catch(Exception dmlExp){
            LoggingService.logHandledException(dmlExp, CLASS_NAME, RETRIEVE_METHOD_NAME, System.LoggingLevel.ERROR);
            throw new ProductRetrievalServiceException(dmlExp.getMessage(), dmlExp);
        }
        return opportunityProductList;
    }

    /**
     * @description method that deletes the deletes the given Opportunity Product records
     * @param opportunityProductList
     * @return boolean if the records were successfully deleted or not
     */
    private static Boolean deleteProductData(List<OpportunityProduct__c> opportunityProductList){
        Boolean areRecordsDeleted = false;
        try{
            DELETE Security.stripInaccessible(AccessType.READABLE, opportunityProductList, true).getRecords();
            areRecordsDeleted = true;
        }
        catch(Exception dmlExp){
            LoggingService.logHandledException(dmlExp, CLASS_NAME, DELETE_METHOD_NAME, System.LoggingLevel.ERROR);
            throw new ProductRetrievalServiceException(dmlExp.getMessage(), dmlExp);
        }
        return areRecordsDeleted;
    }
    
    /**
     * @description method that updates the status__c field to true
     * @return boolean if the records were successfully updated or not
     */
    private static Boolean updateProductData(){
        Boolean areRecordsUpdated = false;
        try{
            List<OpportunityProduct__c> opportunityProductList = retrieveProductData(false);
            for(OpportunityProduct__c opportunityProdRecord : opportunityProductList){
                opportunityProdRecord.status__c = true;
            }
            update Security.stripInaccessible(AccessType.UPDATABLE, opportunityProductList, true).getRecords();        
            areRecordsUpdated = true;
        }
        catch(Exception dmlExp){
            LoggingService.logHandledException(dmlExp, CLASS_NAME, UPDATE_METHOD_NAME, System.LoggingLevel.ERROR);
            throw new ProductRetrievalServiceException(dmlExp.getMessage(), dmlExp);
        }
        return areRecordsUpdated;
    }
}