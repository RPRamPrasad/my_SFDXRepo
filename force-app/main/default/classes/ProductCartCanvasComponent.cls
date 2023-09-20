/** 
@Author Team AKITA
@Name ProductCartCanvasComponent
@CreateDate 10/21/2021  
@description This class is used to get the required cart parameters based on the record Id.
@Version 2.1
Copyright © StateFarm  
*/
public with sharing class ProductCartCanvasComponent {

    static final String CLASS_NAME = 'ProductCartCanvasComponent';
    static final String ROUTE_REQUEST_METHOD_NAME_NEXT = 'getRequiredCartParams';

    /**
    * @description Method to get the required parameters for the Cart
    * @param recordId
    * @return string of cart parameters in JSON format
    */
    @AuraEnabled
    public static String getRequiredCartParams(Id recordId) {  
        String returnValue = '';  
        try {
            List<User> oppOwnerResult;
            
            List<Opportunity> primaryOpp;
            primaryOpp = OpportunityCanvasComponentDataRetriever.oppQuery(recordId);
            
            oppOwnerResult = OpportunityCanvasComponentDataRetriever.oppOwnerQuery(primaryOpp);
            if (oppOwnerResult.isEmpty() || String.isBlank(oppOwnerResult[0].State_Agent_Code_List__c)) {
                throw new DataNotFoundException('ApexError:Query error. Please contact your normal support channels.');
            }
            String userRecordBookCodes = oppOwnerResult[0].State_Agent_Code_List__c;
        	List<String> userRecordBookCodeList = userRecordBookCodes.split(',');
            
            CartParameters cartParameters = new CartParameters();
            
            cartParameters.clientId = primaryOpp[0].Account.ClientIdentifier__c;
            cartParameters.bookCodeList = userRecordBookCodeList;
            

            returnValue = JSON.serialize(cartParameters);  
        }
        catch (Exception e){
            LoggingService.logHandledException(e, CLASS_NAME, ROUTE_REQUEST_METHOD_NAME_NEXT,System.LoggingLevel.ERROR);
            throw new AuraHandledException(e.getMessage());
        }    
        return returnValue;
    }

    /**
     * @description Helper class to pass the parameters to the cart
     */
    public with sharing class CartParameters {
        /**
         * @description clientId
         */
        public String clientId{get;set;}
        /**
         * @description bookCodeList
         */
        public List<String> bookCodeList{get;set;}
    }
}